-- 🅲 🅷 🅰 🅽 🅳 🅴 🆁
----------------------------------------------------------------------------------
-- Chander's HammerSpoon configuration
-- Location: ~/.config/hammerspoon/

require("configuration-common")

-- ********************************************************************************
--                                Choosers
-- ********************************************************************************

BrowserList:addItem(AddChromeItem { text = "ACT - Astro Course Tracker", subText = "https://readiness.my.site.com/act/" })
BrowserList:addItem(AddChromeItem { text = "OKTA SSO", subText = "https://salesforce.okta.com/" })
BrowserList:addItem(AddChromeItem { text = "Workday", subText = "https://wd12.myworkday.com/salesforce" })
BrowserList:addItem(AddChromeItem { text = "Forma - Expenses", subText = "https://client.joinforma.com" })
BrowserList:addItem(AddChromeItem { text = "Concur - Travel & Expenses", subText = "https://us2.concursolutions.com" })

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
