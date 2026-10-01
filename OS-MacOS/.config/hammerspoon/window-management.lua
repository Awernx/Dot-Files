-- 🅲 🅷 🅰 🅽 🅳 🅴 🆁
----------------------------------------------------------------------------------
-- Chander's HammerSpoon configuration file
-- Location: ~/.config/hammerspoon/

-- Provides keyboard shortcuts for quickly positioning the currently focused
-- window into predefined areas of the screen.
----------------------------------------------------------------------------------

-- Spoon 'WindowHalfsAndThirds' for Window management on large screens
----------------------------------------------------------------------------------
Install:andUse("WindowHalfsAndThirds")
spoon.WindowHalfsAndThirds:bindHotkeys(spoon.WindowHalfsAndThirds.defaultHotkeys)

----------------------------------------------------------------------------------
-- Custom function to cycle QUARTERS and SIXTHS of the screen
-- Repeatedly pressing the same shortcut cycles the focused window through
-- each position defined for that layout.

-- Format: {x, y, width, height}
local quadPositions = {
    { 0,   0,   0.5, 0.5 }, -- Top Left
    { 0.5, 0,   0.5, 0.5 }, -- Top Right
    { 0.5, 0.5, 0.5, 0.5 }, -- Bottom Right
    { 0,   0.5, 0.5, 0.5 }  -- Bottom Left
}

local sixthPositions = {
    { 0,     0,   1 / 3, 0.5 }, -- Top Left
    { 1 / 3, 0,   1 / 3, 0.5 }, -- Top Middle
    { 2 / 3, 0,   1 / 3, 0.5 }, -- Top Right
    { 2 / 3, 0.5, 1 / 3, 0.5 }, -- Bottom Right
    { 1 / 3, 0.5, 1 / 3, 0.5 }, -- Bottom Middle
    { 0,     0.5, 1 / 3, 0.5 }  -- Bottom Left
}

local function bindPositionCycle(positions, mods, hotkey)
    local currentStep = 1

    hs.hotkey.bind(mods, hotkey, function()
        local win = hs.window.focusedWindow()

        if win then
            win:moveToUnit(positions[currentStep])
            currentStep = (currentStep % #positions) + 1
        end
    end)
end

--  Ctrl + Alt + 4
--  Cycle through QUARTERS of the screen:
-- ┌──────────┬──────────┬──────────┐
-- │    1     │    2     │    3     │
-- ├──────────┼──────────┼──────────┤
-- │    6     │    5     │    4     │
-- └──────────┴──────────┴──────────┘
function BindWindowQuadCycle(mods)
    bindPositionCycle(quadPositions, mods, "4")
end

--  Ctrl + Alt + 6
--  Cycle through SIXTHS of the screen:
-- ┌───────────────┬───────────────┐
-- │      1        │       2       │
-- ├───────────────┼───────────────┤
-- │      4        │       3       │
-- └───────────────┴───────────────┘
function BindWindowSixthCycle(mods)
    bindPositionCycle(sixthPositions, mods, "6")
end
