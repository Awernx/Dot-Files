-- 🅲 🅷 🅰 🅽 🅳 🅴 🆁
----------------------------------------------------------------------------------
-- Chander's HammerSpoon configuration
-- Location: ~/.config/hammerspoon/

require("configuration-common")

-- ********************************************************************************
--                                Choosers Section
-- ********************************************************************************

local addRevorraItem = function(item)
    item = AddChromeItem(item)
    item.profile = "Profile 2"
    return item
end

BrowserList:addItem(addRevorraItem { text = "Confluence Revorra", subText = "https://home.atlassian.com/o/346e5fca-bc8d-42e5-9d43-e10c6203acb8?cloudId=1f1170ce-1a0b-45ef-a3cc-bd3f109f9bd2" })
BrowserList:addItem(addRevorraItem { text = "GitHub Revorra", subText = "https://github.com/revorra/RevorraMVP" })
BrowserList:addItem(addRevorraItem { text = "Local Revorra", subText = "http://localhost:3000" })
