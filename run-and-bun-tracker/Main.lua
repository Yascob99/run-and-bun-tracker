Main = {}

-- The latest version of the tracker. Should be updated with each PR.
Main.Version = { major = "0", minor = "2", patch = "0" }

Main.CreditsList = { -- based on the PokemonBizhawkLua project by MKDasher and Ironmon-tracker by Besteon
	CreatedBy = "Yascob",
    Contributors ={"Yascob"},
    OtherCredits = { "UTDZac", "Fellshadow", "ninjafriend", "OnlySpaghettiCode", "Aeiry", "Amber Cyprian", "bdjeffyp", "thisisatest", "kittenchilly", "IMTYP0", "brdy", "Harkenn", "TheRealTaintedWolf", "eusebyo", "Kurumas", "davidhouweling", "AKD", "rcj001", "GB127", },
}

Main.EMU = {
	MGBA = "mGBA", -- Lua 5.4 currently not in use. May reuse if I add back the MGBA exports script
	BIZHAWK_OLD = "Bizhawk Old", -- Non-compatible Bizhawk version
	BIZHAWK28 = "Bizhawk 2.8", -- Lua 5.1
	BIZHAWK29 = "Bizhawk 2.9", -- Lua 5.4
	BIZHAWK_FUTURE = "Bizhawk Future", -- Lua 5.4
}

-- Returns false if an error occurs that completely prevents the Tracker from functioning; otherwise, returns true
function Main.Initialize()
	Main.TrackerVersion = string.format("%s.%s.%s", Main.Version.major, Main.Version.minor, Main.Version.patch)
	Main.CrashReport = {
		crashedOccurred = false,
	}
	Main.hasRunOnce = false

	-- Game loop control variables
	Main.forceRestart = false -- When enabled, exits the game loop to refresh and reload all Tracker scripts

    Main.MetaSettings = {}
	-- Set seed based on epoch seconds; required for other features
	Main.SetupEmulatorInfo()

	-- Check the version of BizHawk that is running
	if Main.emulator == Main.EMU.BIZHAWK_OLD then
		print("> ERROR: This version of BizHawk is not supported for use with the Tracker.")
		print("> Please update to version 2.8 or higher.")
		Main.DisplayError("This version of BizHawk is not supported for use with the Tracker.\n\nPlease update to version 2.8 or higher.")
		return false
	end

	if not Main.SetupFileManager() then
		return false
	end

	if FileManager.slash == "\\" then
		Main.OS = "Windows"
	else
		Main.OS = "Linux"
	end

	-- Check if the Tracker was previously running; used to prevent self-update until a full restart
	if Program ~= nil then
		Main.hasRunOnce = (Program.hasRunOnce == true)
	end

	for _, luafile in ipairs(FileManager.LuaCode) do
		if not FileManager.loadLuaFile(luafile.filepath) then
			return false
		end
	end
	Main.LoadSettings()

	print(string.format("Run and Bun Tracker v%s successfully loaded", Main.TrackerVersion))

	return true
end

-- Waits for game to be loaded, then begins the Main loop. From here after, do NOT trust values from RunAndBunTracker.lua
function Main.Run()
	if Main.IsOnBizhawk() then
		if GameSettings.getRomName() == "" or GameSettings.getRomName() == "Null" then
			print("> Waiting for a game ROM to be loaded... (File -> Open ROM)")
		end
		local romLoaded = false
		while not romLoaded do
			if GameSettings.getRomName() ~= "" and GameSettings.getRomName() ~= "Null" then
				romLoaded = true
			end
			client.SetGameExtraPadding(0, 0, 0, 0)
			Main.frameAdvance()
		end
	end
	
	GameSettings.initialize()

	-- If the loaded game is unsupported, remove the Tracker padding but continue to let the game play.
	if GameSettings.gamename == nil or GameSettings.gamename == "Unsupported Game" then
		print("> Unsupported Game detected, please load a supported game ROM")
		print("> Check the README.txt file in the tracker folder for supported games")
		return
	end

	-- After a game is successfully loaded, then initialize the remaining Tracker files
	FileManager.setupErrorLog()
	FileManager.executeEachFile("initialize") -- initialize all tracker files
	Main.tempQuickloadFiles = nil -- From now on, quickload files should be re-checked

	-- Final garbage collection prior to game loops beginning
	collectgarbage()

	if Main.IsOnBizhawk() then
		-- Bizhawk 2.9+ doesn't properly refocus onto the emulator window after Quickload
		if Options["Refocus emulator after load"] and Main.emulator ~= Main.EMU.BIZHAWK28 and not Drawing.AnimatedPokemon:isVisible() then
			Program.focusBizhawkWindow()
		end

		Main.hasRunOnce = true
		Program.hasRunOnce = true
		client.SetGameExtraPadding(0, Constants.Graphics.UP_GAP, Constants.Graphics.RIGHT_GAP, Constants.Graphics.DOWN_GAP)
		gui.defaultTextBackground(0)
		-- Allow emulation until something needs to happen, advancing 10 frames at a time (the code doesn't neet to run a ton)
		while not (Main.forceRestart) do
			Program.mainLoop()
			Main.advance10Frames()
		end
		if Main.forceRestart then
			RunAndBunTracker.startTracker()
        end
    end
end



-- Check which emulator is in use (from Ironmon tracker)
function Main.SetupEmulatorInfo()
	local frameAdvanceFunc
	if console.createBuffer == nil then -- This function doesn't exist in Bizhawk, only mGBA
		Main.emulator = Main.GetBizhawkVersion()
		Main.supportsSpecialChars = (Main.emulator == Main.EMU.BIZHAWK29 or Main.emulator == Main.EMU.BIZHAWK_FUTURE)
		frameAdvanceFunc = function()
			emu.frameadvance()
		end
	else
		Main.emulator = Main.EMU.MGBA
		Main.supportsSpecialChars = true
		frameAdvanceFunc = function()
			-- emu:runFrame() -- don't use this, use callbacks:add("frame", func) instead
		end
	end
	Main.frameAdvance = frameAdvanceFunc
end

-- returns that the tracker is Bizhawk (from Ironmon tracker)
function Main.IsOnBizhawk()
	return Main.emulator == Main.EMU.BIZHAWK28 or Main.emulator == Main.EMU.BIZHAWK29 or Main.emulator == Main.EMU.BIZHAWK_FUTURE
end

-- Checks if Bizhawk version is 2.8 or later (from Ironmon tracker)
function Main.GetBizhawkVersion()
	-- Significantly older Bizhawk versions don't have a client.getversion function
	if client == nil or client.getversion == nil then return Main.EMU.BIZHAWK_OLD end

	-- Check the major and minor version numbers separately, to account for versions such as "2.10"
	local major, minor = string.match(client.getversion(), "(%d+)%.(%d+)")

	local majorNumber = tonumber(tostring(major)) or 0 -- tostring first allows nil input
	local minorNumber = tonumber(tostring(minor)) or 0

	if majorNumber >= 3 then
		-- Versions 3.0 or higher (not yet released)
		return Main.EMU.BIZHAWK_FUTURE
	elseif majorNumber < 2 or minorNumber < 8 then
		-- Versions 2.7 or lower (old, incompatible releases)
		return Main.EMU.BIZHAWK_OLD
	elseif minorNumber == 8 then
		return Main.EMU.BIZHAWK28
	elseif minorNumber == 9 then
		return Main.EMU.BIZHAWK29
	else
		-- Versions 2.10+
		return Main.EMU.BIZHAWK_FUTURE
	end
end

function Main.SetupFileManager()
	local slash = package.config:sub(1,1) or "\\" -- Windows is \ and Linux is /
	local fileManagerPath = "run-and-bun-tracker" .. slash .. "FileManager.lua"

	local fileManagerFile = io.open(fileManagerPath, "r")
	if fileManagerFile == nil then
		fileManagerPath = (RunAndBunTracker.workingDir or "") .. fileManagerPath
		fileManagerFile = io.open(fileManagerPath, "r")
		if fileManagerFile == nil then
			local err1 = string.format("Unable to load a Tracker code file: %s", fileManagerPath)
			local err2 = "Make sure all of the Tracker's code files are still together."
			print("> " .. err1)
			print("> " .. err2)
			Main.DisplayError(err1 .. "\n\n" .. err2)
			return false
		end
	end
	io.close(fileManagerFile)

	dofile(fileManagerPath)
	FileManager.setupWorkingDirectory()

	-- Confirm the working directory was setup properly. Currently a necessary check for accented characters in Windows username.
	if not FileManager.fileExists(FileManager.Files.TRACKER_CORE) then
		local err1 = "Error locating Tracker files. Can't find path:"
		local err2 = FileManager.dir or ""
		print("> " .. err1)
		print("> " .. err2)
		Main.DisplayError(err1 .. "\n\n" .. err2)
		return false
	end

	return true
end

---Displays a given error message in a pop-up dialogue box
---@param errMessage string
---@param moreInfoBtnLabel string? Optional label for a "More Info" button
---@param moreInfoFunc function? Optional function to execute for "More Info" button
---@return number? formId The id of the form handle that is created
function Main.DisplayError(errMessage, moreInfoBtnLabel, moreInfoFunc)
	if not Main.IsOnBizhawk() then return nil end -- Only Bizhawk allows popup form windows

	client.pause()
	local formTitle = string.format("[v%s] Woops, there's been an issue!", Main.TrackerVersion)
	-- Create the form directly through Bizhawk and not ExternalUI, as it's possible that UI has not been loaded yet
	local form = forms.newform(400, 150, formTitle, function() client.unpause() end)
	local actualLocation = client.transformPoint(100, 50)
	forms.setproperty(form, "Left", client.xpos() + actualLocation['x'] )
	forms.setproperty(form, "Top", client.ypos() + actualLocation['y'] + 64) -- so we are below the ribbon menu

	forms.label(form, errMessage or "", 18, 10, 350, 65)
	forms.button(form, "Close", function()
		client.unpause()
		forms.destroy(form)
	end, 155, 80)

	-- Optional additional info button and event function
	if type(moreInfoFunc) == "function" then
		forms.button(form, moreInfoBtnLabel or "(?)", moreInfoFunc, 20, 80, 110, 22)
	end
	return form
end

function Main.LoadSettings()
	local settings = nil

	local file = io.open(FileManager.prependDir(FileManager.Files.SETTINGS))
	if file ~= nil then
		settings = Inifile.parse(file:read("*a"), "memory")
		io.close(file)
	end

	if settings == nil then
		return false
	end

	-- Keep the meta data for saving settings later in a specified order
	Main.MetaSettings = settings

    for configKey, _ in pairs(Options.FILES) do
        local configValue = settings.config[string.gsub(configKey, " ", "_")]
        if configValue ~= nil then
            Options.FILES[configKey] = configValue
        end
    end
    for configKey, _ in pairs(Options.PATHS) do
        local configValue = settings.config[string.gsub(configKey, " ", "_")]
        if configValue ~= nil then
            Options.PATHS[configKey] = configValue
        end
    end
	return true
end

function Main.advance10Frames()
	for i = 0, 10, 1 do
		emu.frameadvance()
	end
end