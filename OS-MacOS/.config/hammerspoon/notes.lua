-- 🅲 🅷 🅰 🅽 🅳 🅴 🆁
----------------------------------------------------------------------------------
-- Chander's HammerSpoon configuration file
-- Location: ~/.config/hammerspoon/

-- Function to create/append note in Notes app
----------------------------------------------------------------------------------
function CreateOrAppendToNote(title, text)
    local script = [[
        tell application "Notes"
            tell default account
                set noteName to "]] .. title .. [["
                set newText to "]] .. text .. [["

                set existingNotes to (every note whose name is noteName)

                if (count of existingNotes) > 0 then
                    set targetNote to item 1 of existingNotes
                    set oldBody to body of targetNote
                    set body of targetNote to oldBody & newText
                else
                    set targetNote to (make new note at default folder with properties {body: "<h1>]] .. title .. [[</h1>" & newText})
                end if

                activate
                show targetNote

            end tell
        end tell
    ]]

    hs.osascript.applescript(script)
end
