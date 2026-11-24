-- Connect to Svalbard and open it in Finder only when explicitly invoked.
local SvalbardConnector = {}
local SHARE_URL = "smb://Mjolnir.local/Svalbard"
local MOUNT_PATH = "/Volumes/Svalbard"

local activeTask, timeoutTimer, connectionAlert
local log = hs.logger.new("Svalbard-Connector", "info")

local function notify(message)
    hs.notify.new({
        title = "Svalbard network share",
        informativeText = message,
        withdrawAfter = 0,
    }):send()
end

local function closeConnectionAlert()
    if connectionAlert then
        hs.alert.closeSpecific(connectionAlert)
        connectionAlert = nil
    end
end

-- Run one background command at a time; no polling or automatic retries.
local function run(command, arguments, onComplete)
    local task
    task = hs.task.new(command, function(exitCode, stdout, stderr)
        if activeTask ~= task then return end
        activeTask = nil
        closeConnectionAlert()
        if timeoutTimer then
            timeoutTimer:stop(); timeoutTimer = nil
        end
        if exitCode ~= 0 then log.e(stderr or "Command failed") end
        onComplete(exitCode, stdout or "")
    end, arguments)

    activeTask = task
    if not task or not task:start() then
        activeTask = nil
        closeConnectionAlert()
        notify("Could not start the command. Try the shortcut again.")
        return
    end

    timeoutTimer = hs.timer.doAfter(75, function()
        timeoutTimer = nil
        if activeTask ~= task then return end
        activeTask = nil
        task:terminate()
        closeConnectionAlert()
        notify("The request timed out. Check your home network and try again.")
    end)
end

local function openFinder(path)
    hs.execute("open " .. path)
end

function SvalbardConnector.Connect()
    if activeTask then
        hs.alert.show("Svalbard connection request is already in progress")
        return
    end

    if hs.fs.volume.allVolumes(true)[MOUNT_PATH] then
        openFinder(MOUNT_PATH)
        return
    end

    local script = [[
        on run argv
            with timeout of 60 seconds
                set mountedShare to mount volume (item 1 of argv)
                return POSIX path of mountedShare
            end timeout
        end run
    ]]
    -- A nonnumeric duration keeps the alert visible until explicitly closed.
    connectionAlert = hs.alert.show("Connecting to Svalbard …", "indefinite")
    run("/usr/bin/osascript", { "-e", script, SHARE_URL }, function(exitCode, stdout)
        if exitCode ~= 0 then
            notify("Could not connect to Svalbard. Check your home network and try again.")
            return
        end
        -- Use the actual mount path returned by macOS, even if its name changed.
        local path = stdout:gsub("[\r\n]+$", "")
        if path:sub(1, 1) ~= "/" then
            notify("Svalbard did not return a valid mount path. Try again.")
            return
        end
        openFinder(path)
    end)
end

return SvalbardConnector
