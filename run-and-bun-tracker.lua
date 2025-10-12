-- Lua Script made by MKDasher
-- Based on MKdasher's pokemon gen 3 lua extension for bizhawk, with some extra features. Also borrows some code and ideas from Besteon's Ironmon-Tracker.
-- NOTE: On Bizhawk, go to Config / Display... Then uncheck Stretch pixels by integers only.

-- TODO
-- Add attempts tracker.
-- add encounter tracking
-- add settings and a settings form.

-- This file is the first file loaded by Bizhawk or mGBA.
-- This file is NOT automatically updated live; requires Bizhawk restart
-- Ideally this file should be as small as possible, and should not contain important code that requires maintaining

-- This prevents multiple of the same Tracker script from being loaded into mGBA
if RunAndBunTracker == nil then
	RunAndBunTracker = {
		isRunning = (RunAndBunTracker ~= nil and RunAndBunTracker.isRunning)
	}
end

-- Loads/reloads most of the Tracker scripts (except this single script loaded into Bizhawk)
function RunAndBunTracker.startTracker()
	-- Required garbage collection to release old Tracker files after an auto-update
	collectgarbage()

	RunAndBunTracker.setupEmulatorSpecifics()

	-- Only continue with starting up the Tracker if the 'Main' script was able to be loaded
	if RunAndBunTracker.tryLoad() then
		-- Then verify the remainder of the Tracker files were able to be setup and initialized
		if Main.Initialize() then
			Main.Run()
		end
	end
end

function RunAndBunTracker.setupEmulatorSpecifics()
	-- This function doesn't exist in Bizhawk, only mGBA
	RunAndBunTracker.isOnBizhawk = (console.createBuffer == nil)

	-- Redefine Lua print function to be compatible with outputting to mGBA's scripting console
	local trackerLabel
	if RunAndBunTracker.isOnBizhawk then
		trackerLabel = "Bizhawk (Gen 3)"
		print = function(...) console.log(...) end
		console.clear()
	else
		trackerLabel = "mGBA (lite edition)"
		print = function(...) console:log(...) end
		print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n") -- This "clears" the Console for mGBA
	end

	print(string.format("Loading Run and Bun Tracker for %s", trackerLabel))
end

-- Returns true if all appropriate conditions are met; false otherwise
function RunAndBunTracker.tryLoad()
	-- Prevent annoying mGBA script duplication
	if RunAndBunTracker.isRunning and not RunAndBunTracker.isOnBizhawk then
		print("")
		print("> Loading paused. A Tracker script is already active and in use.")
		print('> To reload the Tracker, "Reset" or "Clear out" the script(s) first then try again.')
		return false
	end
	RunAndBunTracker.isRunning = true

	-- Get the current working directory of the Tracker script, needed for mGBA
	if RunAndBunTracker.workingDir == nil then -- required to prevent overwrite in rare cases
		local pathLookup = debug.getinfo(2, "S").source:sub(2)
		RunAndBunTracker.workingDir = pathLookup:match("(.*[/\\])") or ""
	end
	if RunAndBunTracker.isOnBizhawk and RunAndBunTracker.workingDir == "/" then -- specifically for Bizhawk on Linux
		RunAndBunTracker.workingDir = ""
	end

	-- Verify the Main.lua Tracker file exists
	local mainFilePath = RunAndBunTracker.workingDir .. "run-and-bun-tracker/Main.lua"
	local file = io.open(mainFilePath, "r")
	if file == nil then
		print('> Error starting up the Tracker: Unable to load the required main Tracker file.')
		print('> The "run-and-bun-tracker.lua" script file should be in the same folder as the other Tracker files that came with the release download.')
		return false
	end
	io.close(file)

	-- Load the Main Tracker script which will setup all the other files
	dofile(mainFilePath)
	return true
end

RunAndBunTracker.startTracker()