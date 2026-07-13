-- 🅲 🅷 🅰 🅽 🅳 🅴 🆁
----------------------------------------------------------------------------------
-- Chander's HammerSpoon configuration file
-- Location: ~/.config/hammerspoon/

-- Function to open a sticky note with an (optional) random color
----------------------------------------------------------------------------------
function StickyNote(disableRandomColor)
    hs.application.launchOrFocus("Stickies")
    hs.timer.usleep(200000)

    local stickies = hs.application.find("Stickies")
    if not stickies then return end

    stickies:selectMenuItem({ "File", "New Note" })

    if disableRandomColor == nil or not disableRandomColor then
        -- Add a tiny pause for the window to settle, then type
        hs.timer.usleep(50000)
        local colors = { "Yellow", "Blue", "Green", "Pink", "Purple", "Gray" }
        local randomColor = colors[math.random(#colors)]
        stickies:selectMenuItem({ "Color", randomColor })
    end

    return stickies
end

-- Function to open a sticky note with an (optional) random color, AND
-- paste the clipboard contents into it
----------------------------------------------------------------------------------
function StickyNoteWithClipboardContents(disableRandomColor)
    local stickies = StickyNote(disableRandomColor)

    if stickies then
        hs.timer.usleep(50000)
        hs.eventtap.keyStroke({"cmd"}, "v")
        hs.timer.usleep(50000)
        hs.eventtap.keyStroke({}, "return")
    end
end
