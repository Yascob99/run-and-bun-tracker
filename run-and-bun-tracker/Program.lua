Program = {
	selectedPokemon = {
		id = 0
	},
	trainerPokemonTeam = {},
	enemyPokemonTeam = {},
	trainerInfo = {},
	inTrainersView = false,
	runCounter = 0,
	lostRun = false,
	awaitingLoad = true,
	isNewRun = false,
	frames = 0,
	initialLoad = true,
	awaitingStateLoad = false,
	isSaveStateLoad = false
}

-- Main loop for the program. This is run every 10 frames currently (called in Main.).
function Program.mainLoop()
	if GameSettings.isRomLoaded() then -- wait until the rom is loaded
		Battle.update()
		if Program.isValidMapLocation() then
			Program.trainerPokemonTeam = Program.getTrainerData(1)
			Program.trainerInfo = Program.getTrainerInfo()
			if (Program.awaitingLoad and Battle.lastLocation == nil and not Program.awaitingStateLoad and not Program.isNewRun) or (Program.initialLoad and Program.awaitingLoad) then
				print("Loading run data")
        		if Program.Load() then
					Program.awaitingLoad = false
					Program.isNewRun = false
				end
				Program.initialLoad = false
			end
			if Program.isNewRun then
				Drawing.drawLayout()
				Drawing.drawNewRunScreen()
			elseif Program.awaitingLoad  then
				Drawing.drawLayout()
				Drawing.drawAwaitingLoad()
			elseif Program.lostRun then
				Drawing.drawLayout()
				Drawing.drawButtons()
				Drawing.drawGameOverScreen()
			else
				-- Displays pokemon data on the right if there is a pokemon in the party in slot 1.
				if LayoutSettings.showRightPanel and Program.trainerPokemonTeam[1]["pkmID"] ~= 0 then 
					local pokemonaux = Program.getPokemonData(LayoutSettings.pokemonIndex)
					Program.selectedPokemon = pokemonaux
					Drawing.drawPokemonView()
				end
				-- Draws the Map if required.
				if LayoutSettings.menus.main.selecteditem == LayoutSettings.menus.main.MAP then
					Drawing.drawMap()
				end
				-- Draws encounters if on tab
				if LayoutSettings.menus.main.selecteditem == LayoutSettings.menus.main.ENCOUNTERS then
					Drawing.drawEncounters()
				end
				Drawing.drawButtons()
				Drawing.drawLayout()
			end
		else
			if Program.awaitingLoad and not Program.isValidMapLocation() and Battle.lastLocation ~= nil then
				Program.isNewRun = false
				Drawing.drawLayout()
				Drawing.drawAwaitingLoad()
			elseif Program.isNewRun then
				Drawing.drawLayout()
				Drawing.drawNewRunScreen()
			else
				Drawing.drawLayout()
				Drawing.drawAwaitingLoad()
			end
		end
	else
		print("No rom currently loaded")
	end
end

function Program.loadNewFile()
	if (Program.awaitingLoad or Program.awaitingStateLoad) and Program.isValidMapLocation() then
		Program.isSaveStateLoad = true
		print("Loading run data")
		if Program.Load() then
			Program.awaitingLoad = false
			Program.isNewRun = false
		end
	else
		-- run the mainloop once to update the current state immediately
		Program.mainLoop()
	end
end

--- Runs on loop while out of Battle
function Program.outOfBattleLoop()
	Program.enemyPokemonTeam = Program.getBlankTrainerData()
end

-- gets the information on the player character for the map and other functions
function Program.getTrainerInfo()
	local trainer = Utils.getSaveBlock1Addr()
	if trainer == 0 then
		return {
			gender = -1, -- Set to negative to clarify that it is not set
			tid = 0,
			sid = 0,
		}
	else
		return {
			gender = Memory.readbyte(trainer + 8),
			tid = Memory.readword(trainer + 10),
			sid = Memory.readword(trainer + 12)
		}
	end
end

function Program.getSecurityKey()
	return Memory.readword(Utils.getSaveBlock1Addr() + 492)
end

-- Not currently used, but maintained for if it's wanted as a feature later.
-- function Program.updateCatchData()
-- 	if LayoutSettings.menus.catch.selecteditem == LayoutSettings.menus.catch.AUTO then
-- 		local pokemonaux = Program.getPokemonData({player = 2, slot = 1})
-- 		Program.catchdata.pokemon = pokemonaux.pokemonID
-- 		Program.catchdata.curHP = pokemonaux.curHP 
-- 		Program.catchdata.maxHP = pokemonaux.maxHP 
-- 		Program.catchdata.level = pokemonaux.level
-- 		Program.catchdata.status = pokemonaux.status
-- 	end
	
-- 	local m = Program.catchdata.maxHP
-- 	local h = Program.catchdata.curHP
-- 	local c = PokemonData.catchrate[Program.catchdata.pokemon + 1]
	
-- 	local s = 1
-- 	if Program.catchdata.status == 1 or Program.catchdata.status == 4 then
-- 		s = 2
-- 	elseif Program.catchdata.status > 1 then
-- 		s = 1.5
-- 	end
	
-- 	local b = 1
-- 	if Program.catchdata.ball == 2 then
-- 	elseif Program.catchdata.ball == 2 then
-- 		b = 1.5
-- 	elseif Program.catchdata.ball == 3 then
-- 		b = 1.5
-- 	elseif Program.catchdata.ball == 5 then
-- 		b = 1.5
-- 	end
	
-- 	local x = math.floor((3 * m - 2 * h) * math.floor(c * b))
-- 	x = math.floor(x / (3*m))
-- 	x = math.floor(x * s)
	
-- 	local y = 65536
-- 	if (x < 255 and Program.catchdata.ball > 1) then		
-- 		y = math.floor(math.sqrt(16711680 / x))
-- 		y = math.floor(math.sqrt(y))
-- 		y = math.floor(1048560 / y)
-- 	end
-- 	Program.catchdata.rng = y
-- 	Program.catchdata.rate = (y/65536) * (y/65536) * (y/65536) * (y/65536)
-- end

-- gets a blank trainer with blank pokemon data
function Program.getBlankTrainerData()
	local trainerdata = {}
	for i = 1,6,1 do
		trainerdata[i] = {
			pkmID = 0,
			status = 0,
			curHP = 0,
			maxHP = 0,
			level = 0,
			isEnemy = false,
			isShiny = false
		}
	end
	return trainerdata
end

-- -- Based on the original tracker with some code from Ironmon tracker for determining Shinyness
function Program.getTrainerData(index)
	local trainerdata = {}
	local st = 0
	local isEnemyMon = false
	if index == 1 then
		st = GameSettings.pstats
	else
		st = GameSettings.estats
		isEnemyMon = true
	end
	for i = 1,6,1 do
		local start = st + 100 * (i - 1)
		local personality = Memory.readdword(start)
		local magicword = (personality ~ Memory.readdword(start + 4))
		local growthoffset = (TableData.growth[(personality % 24) + 1] - 1) * 12
		local otId = Memory.readdword(start + 4)
		local tid = Utils.getbits(otId, 0, 16)
		local sid = Utils.getbits(otId, 16, 16)
		local growth = (Memory.readdword(start + 32 + growthoffset) ~ magicword)
		local p1 = math.floor(personality / 65536)
		local p2 = personality % 65536
		local isShinyMon = Utils.bit_xor(Utils.bit_xor(Utils.bit_xor(tid, sid), p1), p2) < 8
		trainerdata[i] = {
			pkmID = Utils.getbits(growth, 0, 16),
			status = Utils.getStatus(start+80),
			curHP = Memory.readword(start + 86),
			maxHP = Memory.readword(start + 88),
			level = Memory.readbyte(start + 84),
			isEnemy = isEnemyMon,
			isShiny = isShinyMon
		}
	end
	return trainerdata
end

-- Pretty much copy pasted from the Run and Bun MGBA lua. With some modifications to get extra dervived values for this tracker.
function Program.readBoxMon(address)
	local mon = {}
	local monNameLength=10
	local speciesNameLength=11
	local playerNameLength=10
	mon.personality = Memory.readdword(address + 0)
	mon.otId = Memory.readdword(address + 4)
	mon.tid = Utils.getbits(mon.otId, 0, 16)
	mon.sid = Utils.getbits(mon.otId, 16, 16)
	local p1 = math.floor(mon.personality / 65536)
	local p2 = mon.personality % 65536
	mon.isShiny = Utils.bit_xor(Utils.bit_xor(Utils.bit_xor(mon.tid, mon.sid), p1), p2) < 8
	mon.nickname = Utils.toString(address + 8, monNameLength)
	mon.language = Memory.readbyte(address + 18)
	local flags = Memory.readbyte(address + 19)
	mon.isBadEgg = flags & 1
	mon.hasSpecies = (flags >> 1) & 1
	mon.isEgg = (flags >> 2) & 1
	mon.otName = Utils.toString(address + 20, playerNameLength)
	mon.markings = Memory.readbyte(address + 27)

	local key = mon.otId ~ mon.personality
	local substructSelector = {
		[ 0] = {0, 1, 2, 3},
		[ 1] = {0, 1, 3, 2},
		[ 2] = {0, 2, 1, 3},
		[ 3] = {0, 3, 1, 2},
		[ 4] = {0, 2, 3, 1},
		[ 5] = {0, 3, 2, 1},
		[ 6] = {1, 0, 2, 3},
		[ 7] = {1, 0, 3, 2},
		[ 8] = {2, 0, 1, 3},
		[ 9] = {3, 0, 1, 2},
		[10] = {2, 0, 3, 1},
		[11] = {3, 0, 2, 1},
		[12] = {1, 2, 0, 3},
		[13] = {1, 3, 0, 2},
		[14] = {2, 1, 0, 3},
		[15] = {3, 1, 0, 2},
		[16] = {2, 3, 0, 1},
		[17] = {3, 2, 0, 1},
		[18] = {1, 2, 3, 0},
		[19] = {1, 3, 2, 0},
		[20] = {2, 1, 3, 0},
		[21] = {3, 1, 2, 0},
		[22] = {2, 3, 1, 0},
		[23] = {3, 2, 1, 0},
	}

	local pSel = substructSelector[mon.personality % 24]
	local ss0 = {}
	local ss1 = {}
	local ss2 = {}
	local ss3 = {}

	for i = 0, 2 do
		ss0[i] = Memory.readdword(address + 32 + pSel[1] * 12 + i * 4) ~ key
		ss1[i] = Memory.readdword(address + 32 + pSel[2] * 12 + i * 4) ~ key
		ss2[i] = Memory.readdword(address + 32 + pSel[3] * 12 + i * 4) ~ key
		ss3[i] = Memory.readdword(address + 32 + pSel[4] * 12 + i * 4) ~ key
	end

	mon.pokemonID = ss0[0] & 0xFFFF
	mon.heldItem = ss0[0] >> 16
	mon.experience = ss0[1]
	mon.ppBonuses = ss0[2] & 0xFF
	mon.friendship = (ss0[2] >> 8) & 0xFF
	mon.nature = mon.personality % 25

	mon.moves = {
		ss1[0] & 0xFFFF,
		ss1[0] >> 16,
		ss1[1] & 0xFFFF,
		ss1[1] >> 16
	}
	mon.pp = {
		ss1[2] & 0xFF,
		(ss1[2] >> 8) & 0xFF,
		(ss1[2] >> 16) & 0xFF,
		ss1[2] >> 24
	}

	mon.hpEV = ss2[0] & 0xFF
	mon.attackEV = (ss2[0] >> 8) & 0xFF
	mon.defenseEV = (ss2[0] >> 16) & 0xFF
	mon.speedEV = ss2[0] >> 24
	mon.spAttackEV = ss2[1] & 0xFF
	mon.spDefenseEV = (ss2[1] >> 8) & 0xFF
	mon.cool = (ss2[1] >> 16) & 0xFF
	mon.beauty = ss2[1] >> 24
	mon.cute = ss2[2] & 0xFF
	mon.smart = (ss2[2] >> 8) & 0xFF
	mon.tough = (ss2[2] >> 16) & 0xFF
	mon.sheen = ss2[2] >> 24

	mon.pokerus = ss3[0] & 0xFF
	mon.metLocation = (ss3[0] >> 8) & 0xFF
	flags = ss3[0] >> 16
	mon.metLevel = flags & 0x7F
	mon.metGame = (flags >> 7) & 0xF
	mon.pokeball = (flags >> 11) & 0xF
	mon.otGender = (flags >> 15) & 0x1
	flags = ss3[1]
	mon.hpIV = (flags >> 1) & 0x1F
	mon.attackIV = (flags >> 6) & 0x1F
	mon.defenseIV = (flags >> 11) & 0x1F
	mon.speedIV = (flags >> 16) & 0x1F
	mon.spAttackIV = (flags >> 21) & 0x1F
	mon.spDefenseIV = (flags >> 26) & 0x1F
	-- Bit 30 is another "isEgg" bit
	flags = ss3[2]
	mon.coolRibbon = flags & 7
	mon.beautyRibbon = (flags >> 3) & 7
	mon.cuteRibbon = (flags >> 6) & 7
	mon.smartRibbon = (flags >> 9) & 7
	mon.toughRibbon = (flags >> 12) & 7
	mon.championRibbon = (flags >> 15) & 1
	mon.winningRibbon = (flags >> 16) & 1
	mon.victoryRibbon = (flags >> 17) & 1
	mon.artistRibbon = (flags >> 18) & 1
	mon.effortRibbon = (flags >> 19) & 1
	mon.marineRibbon = (flags >> 20) & 1
	mon.landRibbon = (flags >> 21) & 1
	mon.skyRibbon = (flags >> 22) & 1
	mon.countryRibbon = (flags >> 23) & 1
	mon.nationalRibbon = (flags >> 24) & 1
	mon.earthRibbon = (flags >> 25) & 1
	mon.worldRibbon = (flags >> 26) & 1
	mon.altAbility = (flags >> 29) & 3
	if mon.pokemonID ~= nil and mon.pokemonID ~= 0 and type(mon.pokemonID) == "number" then
		local pGender = mon.personality % 256
		if  GameSettings.mons[mon.pokemonID] ~= nil then
			local genderThreshold = GameSettings.mons[mon.pokemonID]["genderThreshold"]
			if genderThreshold ~= nil then
				if genderThreshold == 0 or pGender < genderThreshold then
					mon.gender = "Female"
				elseif genderThreshold == 255 then
					mon.gender = "Unknown"
				else
					mon.gender = "Male"
				end
			else
				mon.gender = "Unknown"
			end
		else
			mon.gender = "Unknown"
		end
	else
		mon.gender = "Unknown"
	end
	return mon
end
function Program.readPartyMon(address)
	local mon = Program.readBoxMon(address)
	mon.status = Utils.getStatus(address + 80)
	mon.level = Memory.readbyte(address + 84)
	mon.mail = Memory.readdword(address + 85)
	mon.hp = Memory.readword(address + 86)
	mon.maxHP = Memory.readword(address + 88)
	mon.attack = Memory.readword(address + 90)
	mon.defense = Memory.readword(address + 92)
	mon.speed = Memory.readword(address + 94)
	mon.spAttack = Memory.readword(address + 96)
	mon.spDefense = Memory.readword(address + 98)
	return mon
end

function Program.getPokemonData(index)

		local address = 0
		local isEnemyMon = false
		if index.player == 1 then
			address = GameSettings.pstats + 100 * (index.slot - 1)
		else
			address = GameSettings.estats + 100 * (index.slot - 1)
			isEnemyMon = true
		end
		local mon = Program.readPartyMon(address)
		mon.isEnemy = isEnemyMon
		return mon
end

function Program.getAbility(mon)
	local speciesData = GameSettings.mons[mon.pokemonID]
	if speciesData == nil then
		return 0
	end
    local current = speciesData.abilities[mon.altAbility + 1]
    if (current == "None") then
        current = speciesData.ability1
    end
    return current
end

function Program.getPartyCount()
	return Memory.readword(GameSettings.gPlayerPartyCount)
end

-- checks if a pokemon is valid
function Program.isValidPokemon(pokemonID)
	return pokemonID ~= nil and GameSettings.names[pokemonID] ~= nil
end

function Program.getHP(mon)
    local hptype = ((mon.hpIV%2 + (2*(mon.attackIV%2))+(4*(mon.defenseIV%2))+(8*(mon.speedIV%2))+(16*(mon.spAttackIV%2))+(32*(mon.spDefenseIV%2)))*5)/21
    hptype = math.floor(hptype)
	if (hptype == 0) then
		return "Fighting", 0xFFFF8000
	end
	if (hptype == 1) then
		return "Flying", 0xFF81B9EF
	end
	if (hptype == 2) then
		return "Poison", 0xFF9141CB
	end
	if (hptype == 3) then
		return "Ground", 0xFF915121
	end
	if (hptype == 4) then
		return "Rock", 0xFFAFA981
	end
	if (hptype ==5) then
		return "Bug", 0xFF91A119
	end
	if (hptype == 6) then
		return "Ghost", 0xFF704170
	end
	if (hptype ==7) then
		return "Steel", 0xFF60A1B8
	end
	if (hptype == 8) then
		return "Fire", 0xFFE62829
	end
	if (hptype == 9) then
		return "Water", 0xFF2980EF
	end
	if (hptype == 10) then
		return "Grass", 0xFF3FA129
	end
	if (hptype == 11) then
		return "Electric", 0xFFFAC000
	end
	if (hptype == 12) then
		return "Psychic", 0xFFEF4179
	end
	if (hptype == 13) then
		return "Ice", 0xFF3DCEF3
	end
	if (hptype == 14) then
		return "Dragon", 0xFF5060E1
	end
	if (hptype == 15) then
		return "Dark", 0xFF624D4E
	end
	if (hptype == 16) then
		return "Fairy", 0xFFEF70EF
	end
end

-- Returns focus back to Bizhawk, using the name of the rom as the name of the Bizhawk window (from Ironmon Tracker)
function Program.focusBizhawkWindow()
	if not Main.IsOnBizhawk() then return end
	local bizhawkWindowName = GameSettings.getRomName()
	if not Utils.isNilOrEmpty(bizhawkWindowName) then
		local command = string.format("AppActivate(%s)", bizhawkWindowName)
		FileManager.tryOsExecute(command)
	end
end

-- Get's the pokemon's types. 
function Program.getPokemonTypes(ID)
	local mon = GameSettings.mons[ID]
	if mon ~= nil then
		if mon.type2 == nil then
			mon.type2 = ""
		end
		return {mon["type1"], mon["type2"]}
	else
		return {"", ""}
	end
end

--- Gets the mon ID from a memory address
function Program.getMonID(address)
	local personality = Memory.readdword(address)
	local magicword = (personality ~ Memory.readdword(address + 4))
	local growthoffset = (TableData.growth[(personality % 24) + 1] - 1) * 12
	local growth = (Memory.readdword(address+ 32 + growthoffset) ~ magicword)
	return Utils.getbits(growth, 0, 16)
end

--- Returns true if the trainer has been defeated by the player; false otherwise (unsure if this works as intended. Does appear to work for rival for now)
function Program.hasDefeatedTrainer(trainerId, saveBlock1Addr)
	-- Don't reveal defeated trainers if player isn't actively playing the game (e.g. title screen w/ old save data)
	if not Program.isValidMapLocation() then
		return false
	end
	saveBlock1Addr = saveBlock1Addr or Utils.getSaveBlock1Addr()
	local idAddrOffset = math.floor((1840 + trainerId) / 8)
	local idBit = (1840 + trainerId) % 8
	local trainerFlagAddr = saveBlock1Addr + 4720 + idAddrOffset
	console.log(trainerId)
	console.log(string.format("%x", trainerFlagAddr))
	local result = Memory.readbyte(trainerFlagAddr)
	return Utils.getbits(result, idBit, 1) ~= 0
end

---Returns 1, 2, or 3 depending on game.
---1==Piplup (right), 2=Turtwig (left), 3=Chimchar (middle) (the order gets real fucked up by the mod)
---@return number starterChoice
function Program.getStarterChoice()
	local starters = {393, 387, 390}
	for i, starter in ipairs(starters) do
		if Battle.starterChoice == starter then
			return i
		end
	end
	return 0
end

--- returns the ID of the starter if the given ID is the starter or an evolution of the starter.
function Program.getStarterbyEvolution(id)
	local starters = {393, 387, 390}
	for _, starter in pairs(starters) do
		if starter == id then
			return starter
		elseif Utils.isInTable(GameSettings.evolutionPool[id], starter) then
			return starter
		end
	end
	return 0
end

--- Returns the Rivals trainer ID for the first fight. Depends on playergender and the starterChoice
function Program.getRivalID()
	local starterChoice = Program.getStarterChoice()
	local gender = Program.trainerInfo.gender or 0
	local id = 520
	return id + (1 - gender) * 9 + (starterChoice - 1) * 3 -- 520 is the first rival for if the player is a girl, 529 is the first for if the player is a boy, then there are variants for each starter choice 
end

--- Gets items from the inventory given an offset and an amount of data to get.
--- @param offset number
--- @param size number
--- @return table? data Or nil if for some reason this data is not accessible
function Program.checkInventory(offset, size)
	local address = Utils.getSaveBlock1Addr() + GameSettings.inventoryOffset + offset
	-- check that the offset is divisible by 4. If it isn't, the offset will result in invalid data.
	if offset % 4 ~= 0 then
		return nil
	end
	if size % 4 ~= 0 then
		size = math.floor(size/4)*4
	end
	local data = {}
	local itemID = 0
	local quantity = 0
	local iOffset = 0
	local sKey = Program.getSecurityKey()
	for i = 1, size/4, 1 do
		iOffset = (i-1) * 4
		itemID = Memory.readword(address + iOffset)
		if itemID ~= 0 then
			quantity = Utils.bit_xor(Memory.readword(address + 2 + iOffset), sKey)
		else
			quantity = 0
		end
		if itemID ~= 0 or quantity ~= 0 then
			table.insert(data, {itemID, quantity})
		end
	end
	return data
end

--- Checks the first slot of the ball inventory for balls, if there is balls, returns true.
---@return boolean
function Program.checkForBalls()
	local data = Program.checkInventory(700, 4)
	if data ~= nil then
		return true
	end
	return false
end

---Returns a byte such that each badge is a bit packed into the byte. 1st badge is least-significant bit (position 0)
---@return number badgeBits
function Program.readBadgeBits()
	-- Don't bother checking badge data if in the pre-game intro screen (where old data exists)
	if not Program.isValidMapLocation() then
		return 0
	end
	local saveblock1Addr = Utils.getSaveBlock1Addr()
	return Utils.getbits(Memory.readword(saveblock1Addr + 4988), 7, 8)
end

--- Returns the total number of badges obtained.
---@return number badgeCount
function Program.getBadgesObtained()
	-- Don't bother checking badge data if in the pre-game intro screen (where old data exists)
	if not Program.isValidMapLocation() then
		return 0
	end

	local badgeBits = Program.readBadgeBits()
	local badgecount = 0
	for index = 1, 8, 1 do
		local badgeState = Utils.getbits(badgeBits, index - 1, 1)
		if badgeState == 1 then
			badgecount = badgecount + 1
		end
	end
	return badgecount
end

-- More or less used to determine if the player has begun playing the game, returns true if so.
function Program.isValidMapLocation()
	return Battle.mapID ~= nil and Battle.mapID ~= 0
end

-- Saves data about the current run
function Program.Save()
	if Encounters.encounters ~= nil then
		Encounters.updateEncounterTracker(true)
	end
	local battle = {}
	for key, value in pairs(Battle) do
		if type(value) ~= "function" then
			battle[key] = value
		end
	end
	FileManager.writeTableToFile(table.pack(battle, Program.trainerInfo), FileManager.Files.CURRENT_ATTEMPT_DATA)
end

-- Reads the current run number from the Runs.txt file. If that file doesn't exist, the data in that file is invalid, or the attemptFolder doesn't exist, use a fallback
function Program.readCurrentRuns()
	if FileManager.fileExists(FileManager.Files.RUNS_LOG) then
		local lines = FileManager.readLinesFromFile(FileManager.Files.RUNS_LOG)
		if lines ~= nil then
			local runs = tonumber(lines[1])
			if runs ~= nil then
				local attemptFolder = FileManager.Folders.Attempts .. FileManager.slash .. lines[1]
				if FileManager.folderExists(attemptFolder) then
					Program.setAttemptsFolder(runs)
					return runs
				end
			end
		end
	end
	return Program.getCurrentAttempt()
end

-- Saves the current Run number to Runs.txt
function Program.saveCurrentRuns()
	FileManager.writeLinesToFile({tostring(Program.runCounter)},FileManager.Files.RUNS_LOG)
end

-- Gets every folder in the attemptFolder and finds the highest numbered file, the highest number will be set as the current run number
function Program.getCurrentAttempt()
	if not FileManager.folderExists(FileManager.Folders.Attempts) then
		FileManager.createFolder(FileManager.Folders.Attempts)
	end
	local filepaths = FileManager.getFilesFromDirectory(FileManager.Folders.Attempts)
	local attemptNumber = 0
	local attemptFolder = nil
	for _, file in ipairs(filepaths) do
		attemptFolder = tonumber(file)
		if attemptFolder ~= nil then
			if attemptFolder > attemptNumber then
				attemptNumber = attemptFolder
			end
		end
	end
	if attemptNumber > 0 then
		-- Writes Runs to a run file for easier tracking on future loads
		Program.setAttemptsFolder(attemptNumber)
		FileManager.writeLinesToFile({tostring(attemptNumber)},FileManager.Files.RUNS_LOG)
		return attemptNumber
	end
	Program.setAttemptsFolder(1)
	FileManager.writeLinesToFile({tostring(1)},FileManager.Files.RUNS_LOG)
	return 1
end

-- Sets all the file locations and Folders to the current attempt number and creates the folder if it doesn't exist.
function Program.setAttemptsFolder(attemptNumber)
	local attemptFolder = FileManager.Folders.Attempts .. FileManager.slash .. tostring(attemptNumber)
	if not FileManager.folderExists(attemptFolder) then
		FileManager.createFolder(attemptFolder)
	end
	FileManager.Folders.CurrentAttempt = attemptFolder
	FileManager.Files.ENCOUNTER_LOG = attemptFolder .. FileManager.slash .. "Encounters.txt"
	FileManager.Files.ENCOUNTER_CSV = attemptFolder .. FileManager.slash .. "Encounters.CSV"
	FileManager.Files.CURRENT_ATTEMPT_DATA = attemptFolder ..  FileManager.slash .. "Attempt.txt"
end

-- Attempts to load the current Run and loads any missed data into 
function Program.Load()
	Program.trainerInfo = Program.getTrainerInfo()
	Program.setAttemptsFolder(Program.runCounter)
	local attemptData = FileManager.readTableFromFile(FileManager.Files.CURRENT_ATTEMPT_DATA)
	local partyCount = Program.getPartyCount()
	if attemptData ~= nil then
		local trainerData = attemptData[2]
		-- Check trainer id, secret ID and gender to determine if the loaded file is correct for the save data.
		for key, value in pairs(trainerData) do
			if Program.trainerInfo[key] ~= value then
				print("Trainer Data does not match attempt data on file, please load the correct Save")
				Program.awaitingStateLoad = true
				return false
			end
		end
		Program.awaitingStateLoad = false
		local battle = attemptData[1]
		local matches = true
		if battle ~= nil then
			for key, value in pairs(battle) do
				if key ~= "hasFoughtRival" and value ~=nil and key ~= "starterChoice" then
					if Battle[key] ~= value then
						matches = false
					end
				-- handling with an elseif for if I add extra stored data in later versions
				elseif key == "hasFoughtRival" then
					-- If the player has no pokemon in party then there is no way they could have beaten the rival
					if partyCount == 1 then
						matches = false
						if battle[key] == true then
							Battle[key] = true
						end
					elseif partyCount > 1 then
						Battle[key] = true
						matches = false
					end
				elseif key == "starterChoice" then
					-- If the player has no pokemon in party then there is no way they could have beaten the tutorial battle 
					if partyCount == 0 and battle[key] == 0 then
						Battle[key] = battle[key]	
					elseif partyCount > 0 and battle[key] == 0 then
						matches = false
					end
				end
			end
		end
		if not matches then
			if not matches then
				Encounters.findPreviousEncounters()
				Encounters.updateEncounterTracker(true)
			end
		end
	elseif partyCount > 0 then
		Encounters.findPreviousEncounters()
		Encounters.updateEncounterTracker(true)
		Battle.hasFoughtRival = Program.hasDefeatedTrainer(Program.getRivalID())
		if partyCount > 1 then
			Battle.hasFoughtRival = true
		end
	end
	Program.isSaveStateLoad = false
	Program.Save()
	return true
end

function Program.startNewAttempt()
	Program.Save()

	print("Starting new run")
	Program.isNewRun = true
	Program.runCounter = Program.runCounter + 1
	if Program.isValidMapLocation() then
		Program.awaitingLoad = true
	end
	FileManager.createFolder(FileManager.Folders.Attempts .. FileManager.slash .. tostring(Program.runCounter))
	Program.setAttemptsFolder(Program.runCounter)
	Program.saveCurrentRuns()
end