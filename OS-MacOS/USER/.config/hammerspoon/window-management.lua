-- 🅲 🅷 🅰 🅽 🅳 🅴 🆁
----------------------------------------------------------------------------------
-- Chander's HammerSpoon configuration file
-- Location: ~/.config/hammerspoon/

-- Provides keyboard shortcuts for quickly positioning the currently focused
-- window into predefined areas of the screen.
----------------------------------------------------------------------------------

-- Format: {x, y, width, height}
local halfPositions = {
    { 0,   0, 0.5, 1 }, -- Left
    { 0.5, 0, 0.5, 1 }  -- Right
}

local thirdPositions = {
    { 0,    0, 0.33, 1 }, -- Left
    { 0.33, 0, 0.33, 1 }, -- Middle
    { 0.66, 0, 0.33, 1 }  -- Right
}

local centerTwothirdPositions = {
    { 0,    0, 0.25, 1 }, -- Left
    { 0.25, 0, 0.5,  1 }, -- Middle
    { 0.75, 0, 0.25, 1 }  -- Right
}

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

--  <Mod> + 2
--  Cycle through Left Half or Right Half of the screen:
-- ┌──────────┬──────────┐
-- │    1     │    2     │
-- └──────────┴──────────┘
function BindWindowHalfCycle(mods)
    bindPositionCycle(halfPositions, mods, "2")
end

--  <Mod> + Right
--  Cycle through 1/4 or 1/2 or 1/4 sections of the screen:
-- ┌─────┬──────────┬─────┐
-- │  1  │    2     │  3  │
-- └─────┴──────────┴─────┘
function BindWindowTwoThirdCycle(mods)
    bindPositionCycle(centerTwothirdPositions, mods, "right")
    bindPositionCycle(centerTwothirdPositions, mods, "left")
end

--  <Mod> + 3
--  Cycle through 1/3 of the screen:
-- ┌──────────┬──────────┬──────────┐
-- │    1     │    2     │    3     │
-- └──────────┴──────────┴──────────┘
function BindWindowThirdCycle(mods)
    bindPositionCycle(thirdPositions, mods, "3")
end

--  <Mod> + 4
--  Cycle through QUARTERS of the screen:
-- ┌──────────┬──────────┬──────────┐
-- │    1     │    2     │    3     │
-- ├──────────┼──────────┼──────────┤
-- │    6     │    5     │    4     │
-- └──────────┴──────────┴──────────┘
function BindWindowQuadCycle(mods)
    bindPositionCycle(quadPositions, mods, "4")
end

--  <Mod> + 6
--  Cycle through SIXTHS of the screen:
-- ┌───────────────┬───────────────┐
-- │      1        │       2       │
-- ├───────────────┼───────────────┤
-- │      4        │       3       │
-- └───────────────┴───────────────┘
function BindWindowSixthCycle(mods)
    bindPositionCycle(sixthPositions, mods, "6")
end

--  <Mod> + Down Arrow
--  Make the window tall by expanding it VERTICALLY
function BindWindowTall(mods)
    hs.hotkey.bind(mods, "down", function()
        local win = hs.window.focusedWindow()
        if not win then return end

        local frame = win:frame()
        local screen = win:screen():frame()

        frame.y = screen.y
        frame.h = screen.h

        win:setFrame(frame, 0)
    end)
end

--  <Mod> + Up Arrow
--  Maximize window
function BindWindowMaximize(mods)
    hs.hotkey.bind(mods, "up", function()
        local win = hs.window.focusedWindow()
        if win then
            win:maximize()
        end
    end)
end

--  <Mod> + F
--  Make window go full-screen
function BindWindowFullScreen(mods)
    hs.hotkey.bind(mods, "F", function()
        local win = hs.window.focusedWindow()
        if win then
            win:toggleFullScreen()
        end
    end)
end

--  <Mod> + C
--  Make window go to the center of the screen
function BindWindowCenter(mods)
    hs.hotkey.bind(mods, "C", function()
        local win = hs.window.focusedWindow()
        if win then
            win:moveToUnit({ 0.25, 0.2, 0.5, 0.6 }
            )
        end
    end)
end
