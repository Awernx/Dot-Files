-- 🅲 🅷 🅰 🅽 🅳 🅴 🆁
----------------------------------------------------------------------------------
-- Chander's HammerSpoon configuration
-- Location: ~/.config/hammerspoon/

require("configuration-common")

-- ********************************************************************************
--                                Choosers
-- ********************************************************************************

BrowserList:addItem(
    AddChromeItem { text = "ACT - Astro Course Tracker", subText = "https://readiness.my.site.com/act/" }, true)
BrowserList:addItem(AddChromeItem { text = "OKTA SSO", subText = "https://salesforce.okta.com/" }, true)
BrowserList:addItem(AddChromeItem { text = "Workday", subText = "https://wd12.myworkday.com/salesforce" }, true)
BrowserList:addItem(AddChromeItem { text = "Forma - Expenses", subText = "https://client.joinforma.com" }, true)
BrowserList:addItem(AddChromeItem { text = "Concur - Travel & Expenses", subText = "https://us2.concursolutions.com" },
    true)

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
    local foundWindow = nil

    -- Loop through all visible windows to find the calendar one
    for _, win in pairs(hs.window.visibleWindows()) do
        if win:application():name() == "Google Chrome" and string.sub(win:title(), 1, string.len(calendarTitlePrefix)) == calendarTitlePrefix then
            foundWindow = win
            break
        end
    end

    if foundWindow then
        -- Focus the found window
        foundWindow:focus()
    else
        -- Open the default URL
        hs.urlevent.openURL(targetURL)
    end
end

hs.hotkey.bind(Hyper, "l", openCalendarOrURL)
