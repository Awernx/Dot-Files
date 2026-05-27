-- 🅲 🅷 🅰 🅽 🅳 🅴 🆁
----------------------------------------------------------------------------------
-- Chander's HammerSpoon configuration
-- Location: ~/.config/hammerspoon/

-- For XDG config file location, execute the following command
-- defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

-- Setup instructions:
--   1) After installing HammerSpoon, RESET its permissions by running
--   *  tccutil reset All org.hammerspoon.Hammerspoon
--   2) Install SpoonInstall; other spoons will auto-install

-- *******************************************************************************
--                         Global shortcut prefixes
-- *******************************************************************************
hyper    = { "ctrl", "alt", "cmd" } -- For launching apps
super    = { "ctrl", "alt" }        -- For performing actions
chooser  = { "ctrl", "cmd" }        -- For launching choosers
finder   = { "shift", "ctrl" }      -- For launching finder windows
informer = { "shift", "alt" }       -- For displaying information on screen
expander = { "shift", "cmd" }       -- For expanding / typing in text

-- *******************************************************************************
--            Startup Actions: Will execute when Hammerspoon starts
-- *******************************************************************************

-- Hammerspoon requires 'Location Services' permissions to display Wi-Fi SSID
-- Following line registers Hammerspoon as an app in Settings > Location Services
-- This setting must be turned 'on' if not already granted
-- https://github.com/Hammerspoon/hammerspoon/issues/3537
----------------------------------------------------------------------------------
hs.location.get()

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
Install = spoon.SpoonInstall

-- Display Hammerspoon logo to indicate successful configuration loading
----------------------------------------------------------------------------------
Install:andUse("FadeLogo", {
    config = {
        fade_out_time = 1.5,
        run_time      = 0.5,
        zoom          = false,
    },
    start  = true
})

-- Spoon 'WindowHalfsAndThirds' for Window management on large screens
----------------------------------------------------------------------------------
Install:andUse("WindowHalfsAndThirds")
spoon.WindowHalfsAndThirds:bindHotkeys(spoon.WindowHalfsAndThirds.defaultHotkeys)

-- Turn Off NATURAL scrolling for 🖱️ Mice, and not Trackpads!
----------------------------------------------------------------------------------
hs.eventtap.new({ hs.eventtap.event.types.scrollWheel },
    function(event)
        local isTrackpad = event:getProperty(hs.eventtap.event.properties.scrollWheelEventIsContinuous)
        if isTrackpad == 1 then
            return false -- trackpad: pass the event along
        end

        event:setProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1,
            -event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1))
        return false -- pass the event along
    end
):start()

-- ********************************************************************************
--                       System Shortcuts Section
-- ********************************************************************************

-- Bind Option + Space to open Launchpad
hs.hotkey.bind({ "alt" }, "space", function()
    hs.spaces.toggleLaunchPad()
end)

-- ********************************************************************************
--                       Application Launcher Section
-- ********************************************************************************

local function hyperBind(shortcutKey, applicationName)
    hs.hotkey.bind(hyper, shortcutKey,
        function()
            hs.application.open(applicationName, 1, true)
        end
    )
end

local function hyperBindFile(shortcutKey, fileLocation)
    hs.hotkey.bind(hyper, shortcutKey,
        function()
            hs.execute("open " .. fileLocation)
        end
    )
end

-- Application launchers
-- Ctrl + Alt + Cmd + .....
----------------------------------------------------------------------------------
hyperBind("B", "com.apple.Safari")
hyperBind("C", "com.google.Chrome")
hyperBind("I", "com.apple.MobileSMS")
hyperBind("L", "com.apple.iCal")
hyperBind("M", "com.apple.mail")
hyperBind("N", "com.apple.Notes")
hyperBind("O", "md.obsidian")
hyperBind("P", "com.apple.Passwords")
hyperBind("S", "com.microsoft.teams2")
hyperBind("T", "com.googlecode.iterm2")
hyperBind("V", "dev.zed.Zed")
hyperBindFile("Y", "~/MEGA/Kitchen\\ Sink/Srivatsas.kdbx")
hyperBindFile("U", "~/MEGA/Personal\\ Backups/Chander/Sillarai\\ LLC/Sillarai.kdbx")

-- ********************************************************************************
--                               Finders Section
-- ********************************************************************************

local function bindDirectory(shortcutKey, directory)
    hs.hotkey.bind(finder, shortcutKey,
        function()
            hs.execute('open -a Finder ' .. directory)
        end
    )
end

-- Finder shortcuts
-- Shift + Ctrl + .......
----------------------------------------------------------------------------------
bindDirectory("E", "~")
bindDirectory("W", "~/Workspace")
bindDirectory("J", "~/Downloads")
bindDirectory("K", "~/MEGA/Kitchen\\ Sink")
bindDirectory("T", "~/MEGA/-TEMP-")
bindDirectory("D", "~/MEGA/Sensitive\\ Family\\ Documents")
bindDirectory("P", "~/MEGA/Personal\\ Backups/Chander")
bindDirectory("S", "/Volumes/Svalbard")

-- ********************************************************************************
--                         Text Expanders Section
-- ********************************************************************************
local function expandText(shortcutKey, text)
    hs.hotkey.bind(expander, shortcutKey,
        function()
            hs.eventtap.keyStrokes(text)
        end
    )
end

-- Expansion shortcuts
-- Shift + Cmd + .......
----------------------------------------------------------------------------------
local function loadPassword()
    local data = hs.plist.read(os.getenv("HOME") .. "/.local/state/awernx/.ragasiyam")
    return data and data["AccountPassword"] or ""
end

expandText("C", loadPassword())

-- ********************************************************************************
--                            Actions Section
-- ********************************************************************************

-- Unformatted Paste from Clipboard
-- Ctrl + Alt + V
hs.hotkey.bind(super, "V",
    function()
        hs.eventtap.keyStrokes(hs.pasteboard.getContents())
    end
)

-- Password generator: Generates and copies to the clipboard
-----------------------------------------------------------------------------------
Install:andUse("PasswordGenerator", {
    config = {
        password_style = 'xkcd',
        word_count = 3,
        word_separators = '_',
        word_uppercase = 3,
        word_leet = 3
    }
})

-- Generate Password
-- Ctrl + Alt + P
hs.hotkey.bind(super, "P",
    function()
        password = spoon.PasswordGenerator:copyPassword()
        local button = hs.dialog.blockAlert(password, "", "", "")
    end
)

-- Reload this HammerSpoon configuration
-- Ctrl + Alt + R
hs.hotkey.bind(super, "R",
    function()
        hs.reload()
    end
)

-- Mute Microphone and display a band on screen
-- Ctrl + Alt + .
hs.hotkey.bind(super, ".",
    function()
        mic = hs.audiodevice.defaultInputDevice()
        if (mic:inputMuted()) then
            mic:setMuted(false)
            if micMuteStatusLine then
                micMuteStatusLine:delete()
            end
        else
            mic:setMuted(true)

            micMuteStatusLineColor = { ["red"] = 1, ["blue"] = 0, ["green"] = 0, ["alpha"] = 1 }
            max = hs.screen.primaryScreen():fullFrame()
            micMuteStatusLine = hs.drawing.rectangle(hs.geometry.rect(max.x, max.y, max.w, max.h))
            micMuteStatusLine:setStrokeColor(micMuteStatusLineColor)
            micMuteStatusLine:setFillColor(micMuteStatusLineColor)
            micMuteStatusLine:setFill(false)
            micMuteStatusLine:setStrokeWidth(20)
            micMuteStatusLine:show()
        end
    end
)

-- ********************************************************************************
--                                Choosers Section
-- ********************************************************************************
local t = require("hs.webview.toolbar")
local globalIncrement = 1

AwernxChooser = { hotkey = "", title = "", icon = nil, launcherCallback = nil }
AwernxChooser.__index = AwernxChooser

function AwernxChooser:init(hotkey, title, icon, prepareCallback, launcherCallback)
    local awernxChooser = {} -- our new object
    setmetatable(awernxChooser, AwernxChooser)

    awernxChooser.icon = icon
    awernxChooser.items = {}
    awernxChooser.toolbar = t.new("" .. globalIncrement, { { id = title, selectable = false, image = icon } })
    awernxChooser.chooser = hs.chooser.new(launcherCallback)
    awernxChooser.chooser:attachedToolbar(awernxChooser.toolbar)

    hs.hotkey.bind(chooser, hotkey,
        function()
            if prepareCallback then prepareCallback(awernxChooser) end
            awernxChooser.chooser:show()
        end
    )
    globalIncrement = globalIncrement + 1

    return awernxChooser
end

function AwernxChooser:addItem(item)
    if not item.image then item.image = self.icon end

    table.insert(self.items, item)
    self.chooser:choices(self.items)
end

function AwernxChooser:clear()
    self.items = {}
end

----------------------------------------------------------------------------------
-- Chooser for Browser URLs
-- Ctrl + Alt + B
----------------------------------------------------------------------------------
local safariBrowserimage = hs.image.imageFromURL(
    "https://upload.wikimedia.org/wikipedia/en/7/71/Safari_Liquid_Glass_icon.png")

local chromeBrowserimage = hs.image.imageFromURL(
    "https://upload.wikimedia.org/wikipedia/commons/e/e1/Google_Chrome_icon_%28February_2022%29.svg")

local safariBrowser = "safari"
local chromeBrowser = "chrome"

AddSafariItem = function(item)
    item.browser = safariBrowser
    item.image = safariBrowserimage
    return item
end

AddChromeItem = function(item)
    item.browser = chromeBrowser
    item.image = chromeBrowserimage
    return item
end

local browserItemLauncher = function(choice)
    if not choice then return end

    if choice.browser == chromeBrowser then
        choice.profile = choice.profile or "Default"
        hs.task.new("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", nil, {
            "--profile-directory=" .. choice.profile,
            choice.subText
        }):start()
    else
        hs.urlevent.openURLWithBundle(choice.subText, "com.apple.Safari")
    end
end

local genericBrowserIcon = hs.image.imageFromURL(
    "https://upload.wikimedia.org/wikipedia/commons/7/74/Breezeicons-apps-48-konqueror.svg")

BrowserList = AwernxChooser:init("B", "Websites", genericBrowserIcon, nil, browserItemLauncher)
BrowserList:addItem(AddSafariItem { text = "Chat GPT", subText = "https://chatgpt.com" })
BrowserList:addItem(AddSafariItem { text = "Zoho Mail", subText = "https://mail.zoho.com/zm/#mail/folder/inbox" })
BrowserList:addItem(AddSafariItem { text = "LIC", subText = "https://nriebiz.licindia.in" })
BrowserList:addItem(AddSafariItem { text = "HDFC Netbanking", subText = "https://now.hdfc.bank.in" })
BrowserList:addItem(AddSafariItem { text = "IOB Netbanking", subText = "https://ibanking.iob.bank.in/obmb/?bank_id=IOB" })
BrowserList:addItem(AddSafariItem { text = "SBI State Bank of India", subText = "https://retail.sbi.bank.in/retail/login.htm" })
BrowserList:addItem(AddSafariItem { text = "Schwab", subText = "https://client.schwab.com/app/accounts/positions/#/" })
BrowserList:addItem(AddSafariItem { text = "RoseRock - Wealth Accounts", subText = "https://wealth.emaplan.com/ema/CS/Home" })
BrowserList:addItem(AddSafariItem { text = "RoseRock - Wealth Performance", subText = "https://roserock.portal.tamaracinc.com/ClientDashboard.aspx" })
BrowserList:addItem(AddSafariItem { text = "TN Power Finance - TNPFC", subText = "https://www.tnpowerfinance.com/tnpfc-web" })
BrowserList:addItem(AddSafariItem { text = "Shriram Finance", subText = "https://secure.shriramfinance.in" })

BrowserList:addItem(AddChromeItem { text = "Gmail", subText = "https://mail.google.com/mail/u/0/#inbox" })
BrowserList:addItem(AddChromeItem { text = "Gemini", subText = "https://gemini.google.com/app" })
BrowserList:addItem(AddChromeItem { text = "Google Meet", subText = "https://meet.google.com" })
BrowserList:addItem(AddChromeItem { text = "Google Voice", subText = "https://voice.google.com/u/0/messages" })
BrowserList:addItem(AddChromeItem { text = "Google Drive", subText = "https://drive.google.com/drive/u/0/" })
BrowserList:addItem(AddChromeItem { text = "NRO -- 0811", subText = "https://docs.google.com/spreadsheets/d/1oXGTnOp7kcpqkrMPKGCU0_NsxFNBcwo3e5tnt1CizfI" })
BrowserList:addItem(AddChromeItem { text = "NRE -- 0520", subText = "https://docs.google.com/spreadsheets/d/1SWFd5rvd-FgfmvpPfHuaKDGvWAbF4FmfG9Padv6CfAE" })
BrowserList:addItem(AddChromeItem { text = "My Investments", subText = "https://docs.google.com/spreadsheets/d/19U2-7TLjkuT_LrZTdE9VlHu9DR2BVpfS4ZfDTrmQTso" })
BrowserList:addItem(AddChromeItem { text = "Parents - Current Investments", subText = "https://docs.google.com/spreadsheets/d/1ro9Wj9bH-nyM0brJf92UpiskrtKHkZwgJNgB8FgoT9s" })
BrowserList:addItem(AddChromeItem { text = "Parents - 2026 Tax Spreadsheet", subText = "https://docs.google.com/spreadsheets/d/1M7uAbCeNFRBCz5Z09ngIQ5TnrdgDQssOsw9KZtP3sJE" })
BrowserList:addItem(AddChromeItem { text = "Parents - 2025 Tax Spreadsheet", subText = "https://docs.google.com/spreadsheets/d/1W7NBbBaQLfEPGUM5T7YhqjLqz-YmMdhpQhrYbn9zPUY" })

----------------------------------------------------------------------------------
-- Chooser for ZED Workspaces
-- Ctrl + Alt + V
----------------------------------------------------------------------------------

local workspaceItemLoader = function(chooser)
    if chooser then chooser:clear() end

    dirPath = hs.fs.pathToAbsolute("~/Workspace")
    for file in hs.fs.dir(dirPath) do
        if file ~= "." and file ~= ".." then
            local fullPath = dirPath .. "/" .. file
            local attr = hs.fs.attributes(fullPath)
            if attr and attr.mode == "directory" then
                chooser:addItem { text = file, subText = fullPath }
            end
        end
    end
end

local vsWorkspaceLauncher = function(choice)
    if not choice then return end
    hs.execute('open -a Zed ' .. choice.subText)
end

local vscodeImage = hs.image.imageFromURL(
    "https://framerusercontent.com/images/OXB5j8ebQcVXhZ5zICr4TB0N0.webp?width=400&height=400")
AwernxChooser:init("V", "Zed Workspaces", vscodeImage, workspaceItemLoader, vsWorkspaceLauncher)

----------------------------------------------------------------------------------
-- Chooser for GitHub Repositories
-- Ctrl + Alt + G
----------------------------------------------------------------------------------
local githubImage = hs.image.imageFromURL("https://images.icon-icons.com/3685/PNG/512/github_logo_icon_229278.png")

local githubRepoLauncher = function(choice)
    if not choice then return end

    local cmd = string.format("git -C %q remote get-url origin 2>/dev/null", choice.subText)
    local output, status = hs.execute(cmd, true)

    local remoteUrl
    if status and output and output ~= "" then
        remoteUrl = output
            :gsub("%s+$", "")                                -- trim trailing whitespace
            :gsub("^git@github.com:", "https://github.com/") -- replace SSH prefix
            :gsub("%.git$", "")                              -- strip trailing .git

        hs.urlevent.openURLWithBundle(remoteUrl, "com.apple.Safari")
    end
end

AwernxChooser:init("G", "GitHub Repositories", githubImage, workspaceItemLoader, githubRepoLauncher)

-- ********************************************************************************
--               Informer Section
-- ********************************************************************************

-- Display current audio input and output devices
-- Shift + Alt + A
hs.hotkey.bind(informer, "A",
    function()
        local input = hs.audiodevice.defaultInputDevice()
        local output = hs.audiodevice.defaultOutputDevice()
        local inputName = input and input:name() or "None"
        local outputName = output and output:name() or "None"
        hs.alert.show("🎤 Input: " .. inputName .. "\n\n🔊 Output: " .. outputName)
    end
)

-- Shows the current CURSOR position by animating circle around it
-- Shift + Alt + .
hs.hotkey.bind(informer, ".",
    function()
        local minRadius = 25
        local screen = hs.screen.mainScreen()
        local frame = screen:frame()
        local maxRadius = math.min(frame.w, frame.h) / 2 - 20
        local steps = 100     -- Fewer steps for faster animation
        local duration = 0.25 -- seconds, much faster
        local interval = duration / steps

        -- Get current mouse position
        local mousePoint = hs.mouse.absolutePosition()
        local centerX = mousePoint.x
        local centerY = mousePoint.y

        local circle = hs.canvas.new {
            x = centerX - maxRadius,
            y = centerY - maxRadius,
            w = maxRadius * 2,
            h = maxRadius * 2
        }:appendElements({
            type = "circle",
            strokeColor = { red = 1, green = 0, blue = 0.06, alpha = 1 }
        })

        circle:show()

        local currentStep = 0
        local animTimer

        animTimer = hs.timer.doEvery(interval, function()
            currentStep = currentStep + 1
            local t = currentStep / steps
            local radius = maxRadius - (maxRadius - minRadius) * t

            circle:frame({
                x = centerX - radius,
                y = centerY - radius,
                w = radius * 2,
                h = radius * 2
            })

            if currentStep >= steps then
                animTimer:stop()
                hs.timer.doAfter(0.5, function() circle:delete() end)
            end
        end)
    end
)

-- Display IP Addresses - Basically invoke the Shortcuts app shortcut
-- Shift + Alt + I
hs.hotkey.bind(informer, "I",
    function()
        hs.shortcuts.run("IP Address")
    end
)

-- ********************************************************************************
--               SPECIALITY : Network interfaces and display
-- ********************************************************************************

local lastKnownInterfaceName = ""

local function displayNetworkBanner(imageUrl, message)
    local image = hs.image.imageFromURL(imageUrl)
    image = image:size({ w = 250, h = 250 })
    hs.alert.showWithImage("", image)
    hs.alert(message)
end

local function displayEthernetBanner()
    displayNetworkBanner("https://cdn-icons-png.flaticon.com/512/9118/9118846.png", "🟢 Connected via Ethernet")
end

local function displayWiFiBanner(ssid)
    displayNetworkBanner(
        "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/WiFi_Logo.svg/1280px-WiFi_Logo.svg.png",
        "🟢 Connected to " .. hs.wifi.currentNetwork())
end

local function displayCurrentInterfaceName(forceDisplay)
    forceDisplay = forceDisplay or false
    local currentInterface = hs.network.interfaceName()

    if currentInterface == nil then                          -- No network connection
        if lastKnownInterfaceName ~= "" or forceDisplay then -- Just recently lost connection
            lastKnownInterfaceName = ""
            hs.alert("🔴 Network connection lost")
        end
        do return end
    end

    if not forceDisplay and currentInterface == lastKnownInterfaceName then
        do return end -- Nothing has changed, return
    end

    if string.find(currentInterface, "LAN") then
        callback = displayEthernetBanner
    elseif string.find(currentInterface, "Wi%-Fi") then
        callback = displayWiFiBanner
    end

    if forceDisplay or lastKnownInterfaceName ~= currentInterface then
        lastKnownInterfaceName = currentInterface
        if callback then
            callback()
        end
    end
end

-- Watch 'Network Service' for network configuration changes
----------------------------------------------------------------------------------
local networkConfiguration = hs.network.configuration.open()
networkConfiguration:monitorKeys("State:/Network/Service/.*/IPv4", true)
networkConfiguration:setCallback(
    function(store, keys)
        hs.timer.doAfter(1, displayCurrentInterfaceName)
    end
)
networkConfiguration:start()

-- Display currently used network interface name
-- Shift + Alt + N
hs.hotkey.bind(informer, "N",
    function()
        displayCurrentInterfaceName(true)
    end
)
