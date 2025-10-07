FileManager = {}
-- Define file separator. Windows is \ and Linux is /
FileManager.slash = package.config:sub(1,1) or "\\"

-- Pattern for identifying if the path is correct.
FileManager.INVALID_FILE_PATTERN = '[%<%>%:%"%/%\\%|%?%*]'

FileManager.Folders = {}

FileManager.Folders.TrackerCode = "run-and-bun-tracker"
FileManager.Folders.Images = FileManager.Folders.TrackerCode .. FileManager.slash .. "images"
FileManager.Folders.Pokemon = FileManager.Folders.Images .. FileManager.slash .. "pokemon"
FileManager.Folders.RegularSprite = FileManager.Folders.Pokemon .. FileManager.slash .. "regular"
FileManager.Folders.ShinySprite = FileManager.Folders.Pokemon .. FileManager.slash .. "shiny"
FileManager.Folders.Maps = FileManager.Folders.Images .. FileManager.slash .. "map"
FileManager.Folders.Player = FileManager.Folders.Images .. FileManager.slash .. "player"
FileManager.Folders.Status = FileManager.Folders.Images .. FileManager.slash .. "status"
FileManager.Folders.Type = FileManager.Folders.Images .. FileManager.slash .. "types"

FileManager.Files = {
	SETTINGS = "Settings.ini",
	TRACKER_CORE = "run-and-bun-tracker.lua",
	OSEXECUTE_OUTPUT = FileManager.Folders.TrackerCode .. FileManager.slash .. "osexecute-output.txt",
	ERROR_LOG = FileManager.Folders.TrackerCode .. FileManager.slash .. "errorlog.txt",
	CRASH_REPORT = FileManager.Folders.TrackerCode .. FileManager.slash .. "crashreport.txt",
	KNOWN_WORKING_DIR = FileManager.Folders.TrackerCode .. FileManager.slash .. "knownworkingdir.txt",
	}
	FileManager.LuaCode = {
	-- First set of core files
	{ name = "Inifile", filepath = "Inifile.lua", },
	{ name = "Json", filepath = "Json.lua", },
	{ name = "Pickle", filepath = "Pickle.lua", },
	{ name = "Constants", filepath = "Constants.lua", },
	{ name = "Data", filepath = "Data.lua", },
	{ name = "Utils", filepath = "Utils.lua", },
	{ name = "Memory", filepath = "Memory.lua", },
	{ name = "GameSettings", filepath = "GameSettings.lua", },
	--{ name = "Encounters", filepath = "Encounters.lua",},
	-- Second set of core files
	{ name = "Buttons", filepath = "Buttons.lua", },
	{ name = "LayoutSettings", filepath = "LayoutSettings.lua", },
	{ name = "Options", filepath = "Options.lua", },
	{ name = "Drawing", filepath = "Drawing.lua", },
	{ name = "ExternalUI", filepath = "ExternalUI.lua", },
	{ name = "Program", filepath = "Program.lua", },
	{ name = "Input", filepath = "Input.lua", },
	{ name = "Map", filepath = "Map.lua", },
	-- { name = "RNG", filepath = "RNG.lua", },
	}

function FileManager.exportCurrentMons(filename)
    	local file = io.open(filename, "w")
		if file ~= nil then
        	FileManager.printPartyStatus(file)
			file:close()
		end
end

function FileManager.printPartyStatus(file)
    local address = GameSettings.gPokemonStorage + 4
    local i = 0
	for _, mon in ipairs(FileManager.getParty()) do
		if (mon.pokemonID ~= 0) then
			file:write(FileManager.getPartyPrint(mon))
		end
	end
    while i<120 do
		if (Memory.readdword(address) ~=0) then 
			file:write((FileManager.getPCPrint(Program.readBoxMon(address))))
		end
		i = i+1
		address = address + 80
	end
end

function FileManager.getParty()
	local party = {}
	local monStart = GameSettings.pstats
	for i = 1, Memory.readword(GameSettings.gPlayerPartyCount) do
		party[i] = Program.getPokemonData({player = 1,slot = i})
		monStart = monStart + 100
	end
	return party
end

function FileManager.getPartyPrint(mon)
    local hptype = Program.getHP(mon)
	local str = ""
	str = str .. PokemonData.name[mon.pokemonID]
	if (PokemonData.item[mon.heldItem]) then
		str = str .. string.format(" @ %s", PokemonData.item[mon.heldItem])
	end
	str = str .. string.format("\n")
	str = str .. "Ability: " .. string.format("%s", Program.getAbility(mon) .. string.format("\n"))
	str = str .. string.format("Level: %d\n", mon.level)
	str = str .. string.format("%s", PokemonData.nature[mon.nature] .. " Nature" .. string.format("\n"))
	str = str .. string.format("IVs: %d HP / %d Atk / %d Def / %d SpA / %d SpD / %d Spe", mon.hpIV, mon.attackIV, mon.defenseIV, mon.spAttackIV, mon.spDefenseIV, mon.speedIV) .. string.format("\n")
	for i=1,4 do
		local mv = PokemonData.move[mon.moves[i] + 1]
		if(mv == "Hidden Power") then
            
			str = str .. string.format("- Hidden Power %s\n", Program.getHP(mon))
			else
			if(mv ~= "") then
				str = str .. string.format("- %s\n", mv)
			end
		end
	end
	str = str .. string.format("\n")
	return str
end

function FileManager.getPCPrint(mon)
    local hptype = Program.getHP(mon)
	local str = ""
	str = str ..  PokemonData.name[mon.pokemonID]
	if (PokemonData.item[mon.heldItem]) then
		str = str .. string.format(" @ %s", PokemonData.item[mon.heldItem])
	end
	str = str .. string.format("\n")
	str = str .. "Ability: " .. string.format("%s", Program.getAbility(mon) .. string.format("\n"))
	str = str .. string.format("Level: %d\n", Utils.calcLevel(mon.experience, mon.pokemonID))
	str = str .. string.format("%s", PokemonData.nature[mon.nature]) .. " Nature" .. string.format("\n")
	str = str .. string.format("IVs: %d HP / %d Atk / %d Def / %d SpA / %d SpD / %d Spe", mon.hpIV, mon.attackIV, mon.defenseIV, mon.spAttackIV, mon.spDefenseIV, mon.speedIV) .. string.format("\n")
	for i=1,4 do
		local mv = PokemonData.move[mon.moves[i] + 1]
		if(mv == "Hidden Power") then
			str = str .. string.format("- Hidden Power %s\n", Program.getHP(mon))
			else
			if(mv ~= "") then
				str = str .. string.format("- %s\n", mv)
			end
		end
	end
	str = str .. string.format("\n")
	return str
end

-- Returns true if a file exists at its absolute file path; false otherwise
function FileManager.fileExists(filepath)
	return FileManager.getPathIfExists(filepath) ~= nil
end

function FileManager.folderExists(folderpath)
	if folderpath == nil then return false end
	folderpath = FileManager.tryAppendSlash(folderpath)

	-- Hacky but simply way to check if a folder exists: try to rename it
	-- The "code" return value only exists in Lua 5.2+, but not required to use here
	local exists, err, code = os.rename(folderpath, folderpath)
	-- Code 13 = Permission denied, but it exists
	if exists or (not exists and code == 13) then
		return true
	end

	-- Otherwise check the absolute path of the file
	folderpath = FileManager.prependDir(folderpath)
	exists, err, code = os.rename(folderpath, folderpath)
	if exists or (not exists and code == 13) then
		return true
	end

	return false
end

-- Returns the path that allows opening a file at 'filepath', if one exists and it can be opened; otherwise, returns nil
---@return string|nil filepath
function FileManager.getPathIfExists(filepath)
	filepath = string.match(filepath or "", "^%s*(.-)%s*$") -- remove leading/trailing spaces

	-- Empty filepaths "" can be opened successfully on Linux, as directories are considered files
	if filepath == "" then return nil end

	local file = io.open(filepath, "r")
	if file ~= nil then
		io.close(file)
		return filepath
	end

	-- Otherwise check the absolute path of the file
	filepath = FileManager.prependDir(filepath)
	file = io.open(filepath, "r")
	if file ~= nil then
		io.close(file)
		return filepath
	end

	return nil
end

---Returns the absolute file path using a local filename/path and the working directory of the Tracker
---@param filenameOrPath string
---@param includeTrailingSlash? boolean (Optional) If true, appends the system's path separator (slash)
---@return string
function FileManager.prependDir(filenameOrPath, includeTrailingSlash)
	local suffix = includeTrailingSlash and FileManager.slash or ""
	return FileManager.dir .. (filenameOrPath or "") .. suffix
end

-- An absolute path working directory is required for Bizhawk (Windows or Linux)
function FileManager.setupWorkingDirectory()
	FileManager.dir = ""
	local dir = tostring(RunAndBunTracker.workingDir or "")

	-- First check if the working directory has been looked up before
	local knownDirPath = FileManager.Files.KNOWN_WORKING_DIR
	local knownDirFile = io.open(knownDirPath, "r")
	-- If the file doesn't exist, try another path
	if knownDirFile == nil then
		knownDirPath = dir .. knownDirPath
		knownDirFile = io.open(knownDirPath, "r")
	end

	-- If the working directory is known (used in the past), then load that instead of running an os execute
	if knownDirFile ~= nil then
		dir = knownDirFile:read("*a") or ""
		knownDirFile:close()
		dir = tostring(dir:gsub("^%s*(.-)%s*$", "%1"))
		-- Then verify that this saved working directory is correct and usable (user might have moved files/folders)
		if not FileManager.fileExists(dir .. FileManager.Files.TRACKER_CORE) then
			dir = ""
		end
	end

	-- Properly format the path
	local function formatPath(filepath)
		filepath = FileManager.formatPathForOS(filepath)
		filepath = FileManager.tryAppendSlash(filepath)
		-- Linux Bizhawk 2.8 doesn't support popen or working dir absolute path
		if Main.emulator == Main.EMU.BIZHAWK28 and filepath == FileManager.slash then
			filepath = ""
		end
		return filepath
	end

	-- Otherwise, if no known working directory was found, look it up the hard way
	if knownDirFile == nil or dir == "" then
		-- For Bizhawk, use luaconsole script list as a quick backup solution
		if Main.IsOnBizhawk() then
			local pathCheckFile = io.open(dir .. FileManager.Files.TRACKER_CORE, "r")
			if pathCheckFile then
				pathCheckFile:close()
			else
				local luaconsole = client.gettool("luaconsole")
				local luaImp = luaconsole and luaconsole.get_LuaImp()
				local scriptList = luaImp and luaImp.ScriptList or { Count = 0 }
				for i = 0, scriptList.Count - 1, 1 do
					local scriptPath = scriptList[i].Path or scriptList[i].path or ""
					local index = scriptPath:find(FileManager.Files.TRACKER_CORE, 1, true)
					if index then
						dir = scriptPath:sub(1, index - 1)
						break
					end
				end
				dir = formatPath(dir)
			end
		end
		-- If still can't find the filepath, use a command to get it
		if dir == "" then
			-- Windows: "cd", Linux: "pwd"
			local getDirCommand = FileManager.slash == "\\" and "cd" or "pwd"
			-- Bizhawk handles current working directory differently, this is the only way to get it
			local success, fileLines = FileManager.tryOsExecute(getDirCommand)
			if success and #fileLines > 0 and Main.IsOnBizhawk() then
				dir = fileLines[1]
			end
			dir = formatPath(dir)
		end

		-- Save known working directory to file to load for future startups
		if dir ~= "" then
			knownDirFile = io.open(knownDirPath, "w")
			if knownDirFile then
				knownDirFile:write(dir)
				knownDirFile:flush()
				knownDirFile:close()
			end
		end
	end

	-- The current known working directory of the Tracker
	FileManager.dir = dir
	RunAndBunTracker.workingDir = dir
end

-- Attempts to execute the command, returning two results: success, outputTable
function FileManager.tryOsExecute(command, errorFile)
	local tempOutputFile = FileManager.prependDir(FileManager.Files.OSEXECUTE_OUTPUT)
	local commandWithOutput = string.format('%s >"%s"', command, tempOutputFile)
	if errorFile ~= nil then
		commandWithOutput = string.format('%s 2>"%s"', commandWithOutput, errorFile)
	end

	-- An attempted fix to allow non-english characters in paths; but this is only half of it, so it's incomplete.
	-- Leaving this here in case some more research is done to figure out how to work around this.
	-- local foreignCompatibleCommand = "@chcp 65001>nul && " .. commandWithOutput

	local result = os.execute(commandWithOutput)
	local success = (result == true or result == 0) -- 0 = success in some cases
	if not success then
		return success, {}
	end
	return success, FileManager.readLinesFromFile(tempOutputFile)
end

-- Attempts to load a file as Lua code. Returns true if successful; false otherwise.
function FileManager.loadLuaFile(filename, silenceErrors)
	-- First try and load the file from the folder that contains most/all the Tracker lua code
	local filepath = FileManager.getPathIfExists(FileManager.Folders.TrackerCode .. FileManager.slash .. filename)
	if filepath ~= nil then
		dofile(filepath)
		return true
	end

	-- Otherwise, check if the file exists on the root Tracker folder (UpdateOrInstall.lua lives here)
	filepath = FileManager.getPathIfExists(filename)
	if filepath ~= nil then
		dofile(filepath)
		return true
	end

	if not silenceErrors then
		print("Unable to load " .. filename .. "\nMake sure all of the downloaded Tracker's files are still together.")
		Main.DisplayError("Unable to load " .. filename .. "\n\nMake sure all of the downloaded Tracker's files are still together.")
	end

	return false
end

-- Executes 'functionName' for all code files loaded in the Tracker, except Main and FileManager
function FileManager.executeEachFile(functionName)
	local globalRef
	if Main.emulator == Main.EMU.BIZHAWK28 then
		globalRef = _G -- Lua 5.1 only
	else
		---@diagnostic disable-next-line: undefined-global
		globalRef = _ENV -- Lua 5.4
	end

	for _, luafile in ipairs(FileManager.LuaCode) do
		local luaObject = globalRef[luafile.name or ""] or {}
		if type(luaObject[functionName]) == "function" then
			luaObject[functionName]()
		end
	end
end

---Removes the system's path separator (slash) from the end of the path, or returns the path unchanged
---@param path string
---@return string
function FileManager.trimSlash(path)
	if (path or "") == "" or not path:find("[/\\]$") then
		return path
	end
	return path:sub(1, -2)
end

---Appends the system's path separator (slash) to the path if it's not already present
---@param path string
---@return string
function FileManager.tryAppendSlash(path)
	if (path or "") == "" or path:find("[/\\]$") then
		return path
	end
	return path .. FileManager.slash
end

-- Returns a properly formatted path that contains only the correct path-separators based on the OS
function FileManager.formatPathForOS(path)
	path = path or ""
	if FileManager.slash == "/" then
		path = path:gsub("\\", "/")
	else
		path = path:gsub("/", "\\")
	end
	return path
end

-- Returns true if it creates the folder, false if it already exists (I think)
function FileManager.createFolder(folderpath)
	if folderpath == nil then return end
	folderpath = FileManager.trimSlash(folderpath)
	local command
	if Main.OS == "Windows" then
		command = string.format('mkdir "%s"', folderpath)
	else
		command = string.format('mkdir -p "%s"', folderpath)
	end
	return FileManager.tryOsExecute(command)
end

-- Returns a list of file names found in a given folder
function FileManager.getFilesFromDirectory(folderpath)
	local files = {}

	-- Not supported on Linux Bizhawk 2.8, Lua 5.1
	if folderpath == nil or (Main.OS ~= "Windows" and Main.emulator == Main.EMU.BIZHAWK28) then
		return files
	end

	local scanDirCommand
	if Main.OS == "Windows" then
		scanDirCommand = string.format('dir "%s" /b', folderpath)
	else
		-- Note: "-A" removes "." and ".." from the listing
		scanDirCommand = string.format('ls -A "%s"', folderpath)
	end
	local success, fileLines = FileManager.tryOsExecute(scanDirCommand)
	if success then
		for _, filename in ipairs(fileLines) do
			table.insert(files, filename)
		end
	end

	return files
end

-- Erases the contents of the ERROR_LOG and adds a header for diagnostics
function FileManager.setupErrorLog()
	FileManager.ErrorsLogged = {}

	local file = io.open(FileManager.prependDir(FileManager.Files.ERROR_LOG), "w")
	if file ~= nil then
		-- Diagnostics information
		local version = string.format("Tracker Version: %s", Main.TrackerVersion or "N/A")
		local gamerom = string.format("Rom Name: %s", GameSettings.getRomName() or "N/A")
		local gamename = string.format("Game: %s", GameSettings.gamename or "N/A")
		local date = string.format("Date: %s", os.date())
		local divider = string.rep("-", 30)
		file:write(version .. "\n")
		file:write(gamerom .. "\n")
		file:write(gamename .. "\n")
		file:write(date .. "\n")
		file:write(divider .. "\n\n")

		file:flush()
		file:close()
	end
end

-- Logs a message to the ERROR_LOG file
function FileManager.logError(errorMessage)
	errorMessage = errorMessage or "(No error message.)"
	local fullErrorMsg = string.format("%s\n%s\n\n", errorMessage, debug.traceback() or "Stack Trace N/A")
	if not FileManager.ErrorsLogged[fullErrorMsg] then
		FileManager.ErrorsLogged[fullErrorMsg] = true

		-- Only print to user the first part of the error, that describes what went wrong; less overall clutter
		print(errorMessage)

		-- And print the full error and its stack trace in the log file
		local file = io.open(FileManager.prependDir(FileManager.Files.ERROR_LOG), "a")
		if file ~= nil then
			local currentTime = os.date("[%H:%M]")
			file:write(string.format("%s %s", currentTime, fullErrorMsg))
			file:flush()
			file:close()
		end
	end
end

---Returns the filepath of the currently loaded ROM. Note: Only works for Bizhawk emulator
---@return string|nil filepath
function FileManager.getLoadedRomPath()
	if not Main.IsOnBizhawk() then
		return nil
	end
	local luaconsole = client.gettool("luaconsole")
	local luaImp = luaconsole and luaconsole.get_LuaImp()
	local filepath = luaImp and luaImp.PathEntries and luaImp.PathEntries.LastRomPath or ""
	if filepath ~= "" then
		return filepath
	end
	return nil
end

---@param path string
---@return string
function FileManager.extractFolderNameFromPath(path)
	if path == nil or path == "" then return "" end

	path = FileManager.trimSlash(path)

	local folderStartIndex = path:match("^.*()[\\/]") -- path to folder
	if folderStartIndex ~= nil then
		local foldername = path:sub(folderStartIndex + 1)
		if foldername ~= nil then
			return foldername
		end
	end

	return ""
end

---@param path string
---@param includeExtension? boolean Optional, includes the file extension; default: false
---@return string
function FileManager.extractFileNameFromPath(path, includeExtension)
	if path == nil or path == "" then return "" end

	local _, filename, extension = FileManager.getPathParts(path)
	if includeExtension and filename then
		return filename .. (extension or "")
	else
		return filename or ""
	end
end

---@param path string
---@return string
function FileManager.extractFileExtensionFromPath(path)
	if path == nil or path == "" then return "" end

	local _, _, extension = FileManager.getPathParts(path)
	if extension and #extension > 1 then
		return extension:sub(2) -- remove the leading '.'
	else
		return ""
	end
end

--- Returns the folder, filename, and extension for the given filepath
--- @param filepath string The full file path to split apart
--- @return string folder, string filename, string extension
function FileManager.getPathParts(filepath)
	return string.match(filepath or "", "^(.-)([^\\/]-)(%.[^\\/%.]-)%.?$")
end

-- Copies file at 'filepath' to 'filecopyPath' with option to overwrite the file if it exists, or append to it
-- overwriteOrAppend: 'overwrite' replaces any existing file, 'append' adds to it instead, otherwise no change if file already exists
function FileManager.CopyFile(filepath, filepathCopy, overwriteOrAppend)
	if filepath == nil or filepath == "" then
		return false
	end

	local originalFile = io.open(filepath, "rb")
	if originalFile == nil then
		-- The originalFile to copy doesn't exist, simply do nothing and don't copy
		return false
	end

	-- filecopyPath = filecopyPath or (filepath .. " (Copy)") -- TODO: Fix this later, currently unused

	-- If the file exists but the option to overwrite/append was not specified, avoid altering the file
	if FileManager.fileExists(filepathCopy) and not (overwriteOrAppend == "overwrite" or overwriteOrAppend == "append") then
		-- print(string.format('Error: Unable to modify file "%s", no overwrite/append option specified.', filepathCopy))
		return false
	end

	local copyOfFile
	if overwriteOrAppend == "append" then
		copyOfFile = io.open(filepathCopy, "ab")
	else
		-- Default to overwriting the file even if no option specified
		copyOfFile = io.open(filepathCopy, "wb")
	end

	if copyOfFile == nil then
		print(string.format('Error: Failed to write to file "%s"', filepathCopy))
		return false
	end

	if overwriteOrAppend == "append" then
		copyOfFile:seek("end")
	end

	local nextBlock = originalFile:read(2^13)
	while nextBlock ~= nil do
		copyOfFile:write(nextBlock)
		nextBlock = originalFile:read(2^13)
	end

	originalFile:close()
	copyOfFile:close()

	return true
end

function FileManager.deleteFile(filepath)
	if (filepath or "") == "" then
		return false
	end
	pcall(function()
		os.remove(filepath)
	end)
end

---Writes the contents of `table` to the file at `filepath`
---@param table table
---@param filepath string
function FileManager.writeTableToFile(table, filepath)
	if type(table) ~= "table" or (filepath or "") == "" then
		return
	end
	local file = io.open(filepath, "w")
	if not file then
		return
	end
	local dataString = Pickle.pickle(table)
	--append a trailing \n if one is absent
	if dataString:sub(-1) ~= "\n" then
		dataString = dataString .. "\n"
	end
	for dataLine in dataString:gmatch("(.-)\n") do
		file:write(dataLine .. "\n")
	end
	file:flush()
	file:close()
end

---Returns the contents of the file at `filepath` as a luatable
---@param filepath string
---@return table|nil
function FileManager.readTableFromFile(filepath)
	if (filepath or "") == "" then
		return nil
	end
	local file = io.open(filepath, "r")
	if not file then
		return nil
	end

	local dataString = file:read("*a")
	file:close()
	if (dataString or "") == "" then
		return nil
	end
	return Pickle.unpickle(dataString)
end

-- Returns a table that contains an entry for each line from a filename/filepath
function FileManager.readLinesFromFile(filename)
	local lines = {}

	local filepath = FileManager.getPathIfExists(filename)
	if filepath == nil then
		return lines
	end

	local file = io.open(filepath, "r")
	if file == nil then
		return lines
	end

	local fileContents = file:read("*a")
	if fileContents ~= nil and fileContents ~= "" then
		for line in fileContents:gmatch("([^\r\n]+)[\r\n]*") do
			if line ~= nil then
				table.insert(lines, line)
			end
		end
	end
	file:close()

	return lines
end

--- Returns true if data is written to file, false if resulting json is empty, or nil if no file
---@param filepath string
---@param data table
---@return boolean|nil dataWritten
function FileManager.encodeToJsonFile(filepath, data)
	local file = filepath and io.open(filepath, "w")
	if not file then
		return nil
	end
	if not Json then
		return false
	end
	-- Empty Json is "[]"
	local output = "[]"
	pcall(function()
		output = Json.encode(data) or "[]"
	end)
	file:write(output)
	file:close()
	return (#output > 2)
end

--- Returns a lua table of the decoded json string from a file, or nil if no file
---@param filepath string
---@return table|nil data
function FileManager.decodeJsonFile(filepath)
	local file = filepath and io.open(filepath, "r")
	if not file then
		return nil
	end
	if not Json then
		return {}
	end
	local input = file:read("*a") or ""
	file:close()
	local decodedTable = {}
	if #input > 0 then
		pcall(function()
			decodedTable = Json.decode(input) or {}
		end)
	end
	return decodedTable
end


---Recursively copies the contents of 'source' table into 'destination' table
---@param source table
---@param destination? table Optional, creates a new empty table if none provided
---@return table destination
function FileManager.copyTable(source, destination)
	destination = destination or {}
	for key, val in pairs(source or {}) do
		if type(val) == "table" then
			destination[key] = {}
			FileManager.copyTable(val, destination[key])
		else
			destination[key] = val
		end
	end
	return destination
end