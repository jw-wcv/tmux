------------------------------------------------------------
-- Configuration and Logger
------------------------------------------------------------
local logger = hs.logger.new('windowManager', 'debug')
local configFile = os.getenv("HOME") .. "/.hammerspoon/window_config.json"

------------------------------------------------------------
-- Helper Functions
------------------------------------------------------------

-- Returns a table of URLs for all tabs in the given Chrome window using its unique window id.
local function fetchChromeURLs(chromeWinID)
    local script = string.format([[
        tell application "Google Chrome"
            set windowUrls to {}
            repeat with w in windows
                if id of w = %d then
                    set theTabs to tabs of w
                    repeat with aTab in theTabs
                        set end of windowUrls to URL of aTab
                    end repeat
                    exit repeat
                end if
            end repeat
            return windowUrls
        end tell
    ]], chromeWinID)
    local success, tabList = hs.osascript.applescript(script)
    if success and type(tabList) == "table" then
        return tabList
    else
        logger.e("Failed to fetch URLs for Chrome window id " .. chromeWinID)
        return nil
    end
end

-- Fetch VS Code active document path.
local function fetchVSCodeProjectPath()
    -- Note: Visual Studio Code’s AppleScript support is limited.
    local script = [[
        tell application "Visual Studio Code"
            try
                return path of active document
            on error
                return ""
            end try
        end tell
    ]]
    local success, projectPath = hs.osascript.applescript(script)
    if success and projectPath and projectPath ~= "" then
        return projectPath
    else
        logger.e("Failed to fetch project path from Visual Studio Code")
        return nil
    end
end

-- Saves the current state (geometry and extra info) for each visible window.
local function saveWindowPositions()
    local allWindows = hs.window.allWindows()
    local windowData = {}
    logger.i("Saving window positions for all visible windows.")

    for _, win in ipairs(allWindows) do
        if win:isVisible() and win:isStandard() then  -- Only standard visible windows
            local app = win:application()
            if app then
                local appName = app:name()
                local pos = win:topLeft()
                local size = win:size()
                local curScreen = win:screen()
                local windowInfo = {
                    WindowName = win:title(),
                    AppName    = appName,
                    Position   = { pos.x, pos.y },
                    Size       = { size.w, size.h },
                    Screen     = curScreen and curScreen:name() or "unknown",
                }
                
                -- Special handling for Google Chrome: record the unique window id and tab URLs
                if appName == "Google Chrome" then
                    windowInfo.ChromeID = win:id()
                    local urls = fetchChromeURLs(win:id())
                    if urls then
                        windowInfo.URLs = urls
                    end
                end

                -- Special handling for Visual Studio Code: record the active document’s path
                if appName == "Visual Studio Code" then
                    local projectPath = fetchVSCodeProjectPath()
                    if projectPath then
                        windowInfo.ProjectPath = projectPath
                    end
                end

                table.insert(windowData, windowInfo)
                logger.d("Saved window: " .. win:title() .. " from app: " .. appName)
            else
                logger.w("No application associated with window: " .. win:title())
            end
        else
            logger.d("Skipping non-visible or non-standard window: " .. win:title())
        end
    end

    if hs.json.write(windowData, configFile, true, true) then
        logger.i("Successfully saved window positions to: " .. configFile)
    else
        logger.e("Error writing window positions to file: " .. configFile)
    end
end

-- Restores window positions and reopens Chrome/VS Code windows as needed.
local function restoreWindowPositions()
    local windowData = hs.json.read(configFile)
    if not windowData then
        logger.e("Cannot read window configuration from file: " .. configFile)
        return
    end
    logger.i("Restoring window positions from file.")

    for _, info in ipairs(windowData) do
        local appName = info.AppName
        local app = hs.application.get(appName)

        if not app then
            -- Try launching the application if it’s not running.
            logger.i("Application " .. appName .. " not running. Attempting to launch...")
            app = hs.application.launchOrFocus(appName)
            if not app then
                logger.e("Failed to launch application: " .. appName)
                goto continue
            end
            -- Allow some time for the app to start and create windows.
            hs.timer.doAfter(0.5, function() end)
        end
        app:activate(true)

        -- Special handling for Google Chrome:
        if appName == "Google Chrome" and info.URLs and #info.URLs > 0 then
            -- For Chrome we open a new window with the stored URLs.
            local chromeScript = [[
                tell application "Google Chrome"
                    set newWindow to make new window
                    set newTabs to tabs of newWindow
                    delete newTabs -- remove the default tab
            ]]
            for _, url in ipairs(info.URLs) do
                chromeScript = chromeScript .. string.format('tell newWindow to make new tab with properties {URL:"%s"}\n', url)
            end
            chromeScript = chromeScript .. "return id of newWindow\nend tell"
            local success, newChromeID = hs.osascript.applescript(chromeScript)
            if success then
                logger.d("Opened new Chrome window with id: " .. tostring(newChromeID))
            else
                logger.e("Failed to open new Chrome window for saved URLs.")
            end

        -- Special handling for Visual Studio Code:
        elseif appName == "Visual Studio Code" and info.ProjectPath then
            local vsCodeScript = string.format(
                [[
                tell application "Visual Studio Code"
                    open "%s"
                end tell
                ]], info.ProjectPath)
            local success = hs.osascript.applescript(vsCodeScript)
            if success then
                logger.d("Opened project in Visual Studio Code: " .. info.ProjectPath)
            else
                logger.e("Failed to open project path in Visual Studio Code: " .. info.ProjectPath)
            end
        end

        -- Try to restore the window position of any matching window.
        local restored = false
        local attempt = 0
        repeat
            local targetScreen = hs.screen.find(info.Screen) or hs.screen.primaryScreen()
            for _, w in ipairs(app:allWindows()) do
                if w:title() == info.WindowName and w:isStandard() then
                    local f = hs.geometry.rect(info.Position[1], info.Position[2], info.Size[1], info.Size[2])
                    w:move(f, targetScreen, true)
                    restored = true
                    logger.d("Restored window '" .. info.WindowName .. "' on screen: " .. targetScreen:name())
                    break
                end
            end
            if not restored then
                attempt = attempt + 1
                hs.timer.usleep(200000)  -- wait 200ms before retrying
            end
        until restored or attempt > 5

        if not restored then
            logger.w("Could not restore window: " .. info.WindowName)
        end

        ::continue::
    end
end

------------------------------------------------------------
-- Hotkey Bindings
------------------------------------------------------------

-- Save window positions (CMD+ALT+CTRL+S)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", function()
    saveWindowPositions()
end)

-- Restore window positions (CMD+ALT+CTRL+R)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
    restoreWindowPositions()
end)

------------------------------------------------------------
-- HTTP Command Server on Port 8888 (Singleton API)
------------------------------------------------------------
local httpserver = require("hs.httpserver")

-- Disable file serving by setting the document root to an empty string.
httpserver.documentRoot = ""

-- Assign the dispatch function. We also remove any trailing slash from the request path.
httpserver.dispatch = function(request)
    local path = request.path or ""
    path = path:gsub("/$", "")  -- remove trailing slash if present
    logger.i("Received HTTP request on path: " .. path)
    if path == "/save" then
        logger.i("Dispatch: Executing saveWindowPositions()")
        saveWindowPositions()
        return "text/plain", 200, "Saved window positions\n"
    elseif path == "/restore" then
        logger.i("Dispatch: Executing restoreWindowPositions()")
        restoreWindowPositions()
        return "text/plain", 200, "Restored window positions\n"
    else
        logger.e("Dispatch: Invalid command")
        return "text/plain", 400, "Invalid command\n"
    end
end

-- Set the HTTP server options.
httpserver.port = 8888
httpserver.ssl  = false  -- disable SSL if not required

-- Start the server if there is a start method, otherwise assume it auto-starts.
if httpserver.start then
    local success = httpserver.start()
    if success then
        hs.alert.show("HTTP command server running on port 8888")
        logger.i("HTTP command server started on port 8888")
    else
        hs.alert.show("Failed to start HTTP command server!")
        logger.e("Failed to start HTTP command server on port 8888")
    end
else
    hs.alert.show("HTTP command server configured on port 8888 (auto-started)")
    logger.i("HTTP command server configured on port 8888; no start() method found, assuming auto-start")
end
