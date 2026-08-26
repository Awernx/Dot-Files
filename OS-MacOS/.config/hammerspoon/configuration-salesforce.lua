-- 🅲 🅷 🅰 🅽 🅳 🅴 🆁
----------------------------------------------------------------------------------
-- Chander's HammerSpoon configuration
-- Location: ~/.config/hammerspoon/

require("configuration-common")

-- ********************************************************************************
--                                Choosers
-- ********************************************************************************

BrowserList:addItem(AddChromeItem { text = "ACT - Astro Course Tracker", subText = "https://readiness.my.site.com/act/" }, true)
BrowserList:addItem(AddChromeItem { text = "OKTA SSO", subText = "https://salesforce.okta.com/" }, true)
BrowserList:addItem(AddChromeItem { text = "Workday", subText = "https://wd12.myworkday.com/salesforce" }, true)
BrowserList:addItem(AddChromeItem { text = "Forma - Expenses", subText = "https://client.joinforma.com" }, true)
BrowserList:addItem(AddChromeItem { text = "Concur - Travel & Expenses", subText = "https://us2.concursolutions.com" }, true)
BrowserList:addItem(AddChromeItem { text = "Org62", subText = "https://org62.lightning.force.com/lightning/page/home" }, true)
BrowserList:addItem(AddChromeItem { text = "Opportunities", subText = "https://org62.lightning.force.com/lightning/o/Opportunity/list?filterName=Chander_s_Open_Opportunities" }, true)

-- ********************************************************************************
--                                Expanders
-- ********************************************************************************
ExpandText("U", "cramamurthy@salesforce.com")

-- ********************************************************************************
--                                Launchers
-- ********************************************************************************
HyperBind("B", "com.google.Chrome")
HyperBind("S", "com.tinyspeck.slackmacgap")
HyperBind("T", "com.apple.Terminal")

-- Use Google Calendar to override Ctrl + Alt + Cmd + L
local function openCalendarOrURL()
    local calendarTitlePrefix = "Salesforce.com - Calendar -"
    local targetURL = "https://calendar.google.com/calendar/u/0/r"

    -- AppleScript to search ALL windows and background tabs in Chrome
    local script = [[
        tell application "Google Chrome"
            set foundTab to false
            -- Loop through every window
            repeat with w in windows
                set tabIndex to 1
                -- Loop through every tab inside that window
                repeat with t in tabs of w
                    if title of t starts with "]] .. calendarTitlePrefix .. [[" then
                        -- Bring Chrome to the front
                        activate
                        -- Switch the window to focus this specific background tab
                        set active tab index of w to tabIndex
                        -- Bring the parent window to the front
                        set index of w to 1
                        set foundTab to true
                        exit repeat
                    end if
                    set tabIndex to tabIndex + 1
                end repeat
                if foundTab then exit repeat
            end repeat

            -- Return whether we successfully found and focused the tab
            return foundTab
        end tell
    ]]

    -- Execute the AppleScript
    local success, isTabFound, raw = hs.osascript.applescript(script)

    -- If the tab wasn't found (or Chrome isn't open), fall back to opening the URL
    if not success or not isTabFound then
        hs.urlevent.openURL(targetURL)
    end
end

hs.hotkey.bind(Hyper, "l", openCalendarOrURL)
