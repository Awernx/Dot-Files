local MeetingMuter = {}

MeetingMuter.restoreFocus = true -- jump back to the window you were in after toggling

local TEAMS_IDS = { "com.microsoft.teams2", "com.microsoft.teams" }
local SLACK_ID = "com.tinyspeck.slackmacgap"
local FACETIME_ID = "com.apple.FaceTime"

-- Window-title fragments (lowercase) that indicate an active call
local TEAMS_CALL_TITLES = { "meeting", "call", "compact view" }
local SLACK_CALL_TITLES = { "huddle" }

local MEET_URL_PATTERNS = {
    "^https://meet%.google%.com/%l%l%l%-%l%l%l%l%-%l%l%l",
    "^https://meet%.google%.com/lookup/",
}

local SAFARI = { name = "Safari", id = "com.apple.Safari" }
local MEET_BROWSERS = {
    { name = "Google Chrome", id = "com.google.Chrome" },
    SAFARI,
}

local CALL_FOUND = 2
local APP_RUNNING = 1

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function runningApp(bundleID)
    local apps = hs.application.applicationsForBundleID(bundleID)
    return apps and apps[1] or nil
end

local function windowTitleMatches(app, fragments)
    for _, win in ipairs(app:allWindows()) do
        local title = (win:title() or ""):lower()
        for _, frag in ipairs(fragments) do
            if title:find(frag, 1, true) then return win end
        end
    end
    return nil
end

local function isMeetURL(url)
    for _, pat in ipairs(MEET_URL_PATTERNS) do
        if url:match(pat) then return true end
    end
    return false
end

local function micInUse()
    local dev = hs.audiodevice.defaultInputDevice()
    return dev ~= nil and dev:inUse()
end

-- Bring `win` (or `app`) forward, send the shortcut, optionally restore focus.
local function focusAndSend(app, win, mods, key, delay)
    local previous = hs.window.focusedWindow()
    if win then win:focus() else app:activate(true) end
    hs.timer.doAfter(delay or 0.15, function()
        hs.eventtap.keyStroke(mods, key, 0)
        if MeetingMuter.restoreFocus and previous and previous:application() ~= app then
            hs.timer.doAfter(0.2, function() previous:focus() end)
        end
    end)
end

-- Returns a list of { window = n, tab = n } for Meet tabs in a browser.
local function findMeetTabs(browser)
    local script = string.format([[
    set sep to ASCII character 9
    tell application "%s"
      set out to ""
      repeat with wi from 1 to count of windows
        try
          repeat with ti from 1 to count of tabs of window wi
            set out to out & wi & sep & ti & sep & (URL of tab ti of window wi) & linefeed
          end repeat
        end try
      end repeat
      return out
    end tell
  ]], browser.name)
    local ok, result = hs.osascript.applescript(script)
    local found = {}
    if not ok or type(result) ~= "string" then return found end
    for line in result:gmatch("[^\n]+") do
        local wi, ti, url = line:match("^(%d+)\t(%d+)\t(.*)$")
        if url and isMeetURL(url) then
            table.insert(found, { window = tonumber(wi), tab = tonumber(ti) })
        end
    end
    return found
end

local function selectTab(browser, loc)
    local script
    if browser.id == SAFARI.id then
        script = string.format([[
      tell application "Safari"
        set current tab of window %d to tab %d of window %d
        set index of window %d to 1
      end tell
    ]], loc.window, loc.tab, loc.window, loc.window)
    else
        script = string.format([[
      tell application "%s"
        set active tab index of window %d to %d
        set index of window %d to 1
      end tell
    ]], browser.name, loc.window, loc.tab, loc.window)
    end
    hs.osascript.applescript(script)
end

---------------------------------------------------------------------------
-- Providers expose detect(), owns(app), and toggle().
-- detect() returns CALL_FOUND, APP_RUNNING, or nil when unavailable.
---------------------------------------------------------------------------

local providers = {}

-- Google Meet (browser tab or installed Meet PWA)
local meet = { name = "Google Meet" }
function meet.locate()
    -- Meet installed as a Chrome app
    for _, app in ipairs(hs.application.runningApplications()) do
        if app:name() == "Google Meet" then return { app = app } end
    end
    for _, b in ipairs(MEET_BROWSERS) do
        local app = runningApp(b.id) -- only query browsers that are already running
        if app then
            local tabs = findMeetTabs(b)
            if #tabs > 0 then return { app = app, browser = b, loc = tabs[1] } end
        end
    end
    return nil
end

function meet.detect()
    meet.target = meet.locate()
    return meet.target and CALL_FOUND or nil
end

function meet.owns(app)
    local t = meet.target or meet.locate()
    return t ~= nil and t.app:pid() == app:pid()
end

function meet.toggle()
    local t = meet.target or meet.locate()
    if not t then return false end
    if t.browser then selectTab(t.browser, t.loc) end
    focusAndSend(t.app, nil, { "cmd" }, "d", 0.25)
    return true
end

table.insert(providers, meet)

-- FaceTime: uses the menu item, so no focus change needed
local facetime = { name = "FaceTime" }
local function faceTimeMenuPath(app)
    for _, path in ipairs({ { "Video", "Mute" }, { "Video", "Unmute" } }) do
        local item = app:findMenuItem(path)
        if item and item.enabled then return path end
    end
    return nil
end
function facetime.detect()
    local app = runningApp(FACETIME_ID)
    if not app then return nil end
    return faceTimeMenuPath(app) and CALL_FOUND or APP_RUNNING
end

function facetime.owns(app) return app:bundleID() == FACETIME_ID end

function facetime.toggle()
    local app = runningApp(FACETIME_ID)
    if not app then return false end
    local path = faceTimeMenuPath(app)
    if path then return app:selectMenuItem(path) end
    focusAndSend(app, nil, { "cmd", "shift" }, "m")
    return true
end

table.insert(providers, facetime)

-- Teams and Slack share window-title detection and shortcut-based toggling.
local function shortcutProvider(name, bundleIDs, callTitles, mods, key)
    local provider = { name = name }

    local function appForProvider()
        for _, bundleID in ipairs(bundleIDs) do
            local app = runningApp(bundleID)
            if app then return app end
        end
        return nil
    end

    function provider.detect()
        local app = appForProvider()
        if not app then return nil end
        return windowTitleMatches(app, callTitles) and CALL_FOUND or APP_RUNNING
    end

    function provider.owns(app)
        for _, bundleID in ipairs(bundleIDs) do
            if app:bundleID() == bundleID then return true end
        end
        return false
    end

    function provider.toggle()
        local app = appForProvider()
        if not app then return false end
        focusAndSend(app, windowTitleMatches(app, callTitles), mods, key)
        return true
    end

    return provider
end

-- Keep provider order: Meet, FaceTime, Teams, Slack.
table.insert(providers, shortcutProvider(
    "Microsoft Teams", TEAMS_IDS, TEAMS_CALL_TITLES, { "cmd", "shift" }, "m"
))
table.insert(providers, shortcutProvider(
    "Slack", { SLACK_ID }, SLACK_CALL_TITLES, { "cmd", "shift" }, "space"
))

---------------------------------------------------------------------------
-- Choosing and toggling
---------------------------------------------------------------------------

local function choose()
    local scores = {}
    for _, p in ipairs(providers) do scores[p] = p.detect() end

    -- 1. Prefer the frontmost app only when it has a detected call.
    local front = hs.application.frontmostApplication()
    if front then
        for _, p in ipairs(providers) do
            if scores[p] == CALL_FOUND and p.owns(front) then return p end
        end
    end

    -- 2. A detected call takes priority over any merely running app.
    for _, p in ipairs(providers) do
        if scores[p] == CALL_FOUND then return p end
    end

    -- 3. With no detected call, use running apps only while the mic is live.
    if micInUse() then
        if front then
            for _, p in ipairs(providers) do
                if scores[p] == APP_RUNNING and p.owns(front) then return p end
            end
        end
        for _, p in ipairs(providers) do
            if scores[p] == APP_RUNNING then return p end
        end
    end
    return nil
end

function MeetingMuter.toggle()
    local p = choose()
    if not p then
        hs.alert.show("🎙️ No active meeting found")
        return
    end
    if p.toggle() then
        hs.alert.show("🎙️ Toggled mute: " .. p.name, 0.8)
    else
        hs.alert.show("🎙️ Couldn't toggle mute in " .. p.name)
    end
end

-- Remove the binding created by this module, if any.
function MeetingMuter.unbind()
    if MeetingMuter.hotkeyObj then
        MeetingMuter.hotkeyObj:delete()
        MeetingMuter.hotkeyObj = nil
    end
end

-- Bind explicitly from init.lua; calling again replaces the previous binding.
function MeetingMuter.bind(mods, key)
    MeetingMuter.unbind()
    MeetingMuter.hotkeyObj = hs.hotkey.bind(mods, key, MeetingMuter.toggle)
    return MeetingMuter.hotkeyObj
end

return MeetingMuter
