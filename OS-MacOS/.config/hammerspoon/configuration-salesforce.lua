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
