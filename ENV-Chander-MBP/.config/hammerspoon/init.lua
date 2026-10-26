-- 🅲 🅷 🅰 🅽 🅳 🅴 🆁
-------------------------------------------
-- Chander's MBP HammerSpoon configuration
--
-- Location: ~/.config/hammerspoon/init.lua

require('configuration-common')

local SvalbardConnector = require("svalbard-connector")
hs.hotkey.bind(Finder, "S", SvalbardConnector.Connect)
