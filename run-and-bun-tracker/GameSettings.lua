GameSettings = {
	game = 0,
	gamename = "",
	gamecolor = 0,
	rngseed = 0,
	mapbank = 0,
	mapid = 0,
	encountertable = 0,
	pstats = 0,
	estats = 0,
	rng = 0,
	rng2 = 0,
	wram = 0,
	version = 0,
	language = 0,
	trainerpointer = 0,
	coords = 0,
	roamerpokemonoffset = 0
}
GameSettings.VERSIONS = {
	RS = 1,
	E = 2,
	FRLG = 3
}
GameSettings.LANGUAGES = {
	U = 1,
	J = 2,
	F = 3,
	S = 4,
	G = 5,
	I = 6
}

function GameSettings.initialize()
	local gamecode = memory.read_u32_be(0x0000AC, "ROM")

	if gamecode == 0x42504545 then
		GameSettings.game = 2
		GameSettings.gamename = "Pokemon Emerald (U)"
		GameSettings.gamecolor = 0xFF009D07
		GameSettings.version = GameSettings.VERSIONS.E
		GameSettings.language = GameSettings.LANGUAGES.U
	else
		GameSettings.game = 0
		GameSettings.gamename = "Unsupported game"
	end
	-- If it is pokemon Emerald, then
	if GameSettings.game > 0 then
		GameSettings.pstats  = 0x2023a98
		GameSettings.estats  = 0x2023CF0
		GameSettings.inventoryAddress = 0x2023CF8
		GameSettings.rng = 0x3005D90
		GameSettings.wram = 0x2020000
		GameSettings.mapbank = 0x203BC80
		GameSettings.regionID = 0x20368F0 -- The current overall region
		GameSettings.mapid = 0x20368EE -- the current map ID
		GameSettings.trainerpointer = 0x202401F
		GameSettings.coords = 0x2005E6C
		GameSettings.gBattlersCount = 0x20233E4 -- 0 by default, changes to 2 on first battle. DOES NOT REVERT AFTER Battle. Goes to 4 in double battles
		GameSettings.pokemonDataTable = 0x83B7CE0
		GameSettings.pokemonNameTable = 0x83A0F80
		GameSettings.abilityNameTable = 0x83AC0C9
		GameSettings.moveNameTable = 0x83A4486
		GameSettings.moveDataTable = 0x83B0C5C -- 20 bytes per move
		GameSettings.rngseed = Memory.readword(GameSettings.wram)
		GameSettings.gBattleOutcome = 0x2023716 -- BattleStatus [0 = In battle, 1 = Won the match, 2 = Lost the match, 4 = Fled, 7 = Caught]
		GameSettings.gBattleTypeFlags = 0x2023364 -- Value 20 for tutorial fight, 0 then 4 for wild, (went to 8 then 12 for rival fight). Basically extra information about the battle is stored here.
		GameSettings.gPokemonStorage = 0x2028848
		GameSettings.gPlayerPartyCount = 0x2023a95
		GameSettings.encounterTable = 0x862863C
		GameSettings.gBattleOpponentA = 0x20381AE -- confirmed to be the opponent's trainer ID
		GameSettings.gSaveBlock1ptr = 0x3005D8C -- save block1 pointer
		GameSettings.trainerStatsTable = 0x8398880
		GameSettings.mapbankAddress =  0x8552AB4
		GameSettings.mapDetailsAddress = 0x86A1960
		GameSettings.specialMapNames = 0x86A2008 -- terminates in D5 D5
		GameSettings.layoutBank = 0x854E2EC
		GameSettings.trainerStatsTable = 0x8398880 -- 40 bytes per entry
		GameSettings.trainerClassNames = 0x8398524 -- 13 byte string names
		local monData = GameSettings.populatePokemonDetails()
		GameSettings.mons = monData[1] -- Probably should move this to the Data section.
		GameSettings.names =  monData[2] -- Probably should move this to the Data section. 
		GameSettings.populateMoveData()
		GameSettings.populateTrainerClassNames()
		GameSettings.populateTrainerStats()
	end
end

--- populates tables from the pokemon data on the ROM and assigns it to global variables. Needs changes to handle pokemon variants starting at 1009
function GameSettings.populatePokemonDetails()
	local mons = {}
	local names = {}
	local numMons = 1234
	local monNameLength = 11
	local monDataLength = 36
	local nameOffset = 0
	local dataOffset = 0
	local mon = {}
	local address = 0
	local name = ""
	local prevName = ""
	local variantCounter = 1
	for i = 1, numMons, 1 do
		nameOffset = i * monNameLength
		dataOffset = i * monDataLength
		mon = {}
		mon.bHP = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset)
		mon.bAttack = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 1)
		mon.bDefense = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 2)
		mon.bSpeed = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 3)
		mon.bSpAttack = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 4)
		mon.bSpDefense = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 5)
		mon.type1 = PokemonData.type[Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 6) + 1]
		mon.type2 = PokemonData.type[Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 7) + 1] -- Same as type 1 if mono-type
		mon.catchrate = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 8)
		-- 1 byte of padding
		mon.bXP = Memory.readword(GameSettings.pokemonDataTable + dataOffset + 10) -- now 2 bytes to represent higher base experience yields
		mon.evYields = Memory.readword(GameSettings.pokemonDataTable + dataOffset + 12)
		mon.item1 = Memory.readword(GameSettings.pokemonDataTable + dataOffset + 14)
		mon.item2 = Memory.readword(GameSettings.pokemonDataTable + dataOffset + 16)
		mon.genderThreshold = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 18)
		mon.eggCycles = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 19)
		mon.baseFriendship = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 20)
		mon.levelUpType = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 21)
		mon.eggGroup1 = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 22)
		mon.eggGroup2 = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 23)
		mon.ability1 = Memory.readword(GameSettings.pokemonDataTable + dataOffset + 24) -- Abilities Now are 2 Bytes 
		mon.ability2 = Memory.readword(GameSettings.pokemonDataTable + dataOffset + 26) -- Abilities Now are 2 Bytes 
		mon.hiddenAbility = Memory.readword(GameSettings.pokemonDataTable + dataOffset + 28) -- Abilities Now are 2 Bytes
		mon.abilities = {mon.ability1, mon.ability2, mon.hiddenAbility}
		mon.sRunRate = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 30)
		mon.colorFlip = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 31)
		mon.unknown1 = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 32) -- Unsure. Values 0-230
		mon.unknown2 = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 33) -- Unsure. values 0-4
		mon.unknown3 = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 34) -- Unsure values 0-255
		mon.unknown4 = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 35) -- Unsure values 0-39
		-- Create a way of tracking variants
		mon.isVariant = i > 905
		address = GameSettings.pokemonNameTable + nameOffset
		
		if mon.isVariant then
			mon.variant = variantCounter
			if name == prevName then
				variantCounter = variantCounter + 1
			else
				variantCounter = 1
			end
			name = PokemonData.variants[i - 905]
		else
			name = Utils.toString(address, monNameLength)
			mon.variant = 0
		end
		mons[i] = mon 
		names[i] = name
		prevName = name
	end
	return {mons, names}
end

---Gets the ROM name as defined by the emulator, or an empty string if not found
---@return string
function GameSettings.getRomName()
	return gameinfo.getromname() or ""
end
---Returns the rom if loaded
---@return string|true
function GameSettings.isRomLoaded()
	return GameSettings.getRomName() == "" or GameSettings.getRomName()
end
--- Creates tables from the move information on ROM and assigns them to global varaibles
function GameSettings.populateMoveData()
	local moveCount = 779
	local moveLength = 20
	local nameLength = 13
	local moveNameAddress = GameSettings.moveNameTable
	local moveDataAddress = GameSettings.moveDataTable
	local name = ""
	local data = {}
	local nameAddress =  moveNameAddress
	local moveAddress = moveDataAddress
	local iNameOffset = 0
	local iMoveOffset = 0
	GameSettings.moves = {}
	GameSettings.moves.names = {}
	for i = 1, moveCount, 1 do
		iNameOffset = (i-1) * nameLength
		nameAddress = moveNameAddress + iNameOffset
		name = Utils.toString(nameAddress, 13)
		iMoveOffset = (i-1) * moveLength
		moveAddress = moveDataAddress + iMoveOffset
		table.insert(GameSettings.moves.names, name)
		GameSettings.moves[name] = {
			moveEffects = Memory.readbyte(moveAddress),
			unknownflag1 = Memory.readbyte(moveAddress + 1),
			power = Memory.readbyte(moveAddress + 2),
			unknownflag2 = Memory.readbyte(moveAddress + 3),
			type = PokemonData.type[Memory.readbyte(moveAddress + 4)],
			accuracy = Utils.checkAccuracy(Memory.readbyte(moveAddress + 5)),
			pp = Memory.readbyte(moveAddress + 6),
			effectAccuracy = Memory.readbyte(moveAddress + 7),
			moveTargets = Utils.checkTargets(Memory.readbyte(moveAddress + 8)),
			priority = Memory.readbyte(moveAddress + 9, true),
			unknownFlag3 = Memory.readbyte(moveAddress + 10),
			unknownFlag4 = Memory.readbyte(moveAddress + 11),
			unknownFlag5 = Memory.readbyte(moveAddress + 12),
			moveFlags = Memory.readbyte(moveAddress + 13), -- Can be broken into parts, but looks like extra data has been added for the romhack's purpose
			unknownFlag6 = Memory.readbyte(moveAddress + 14),
			unknownFlag7 = Memory.readbyte(moveAddress + 15),
			unknownFlag8 = Memory.readbyte(moveAddress + 16),
			unknownFlag9 = Memory.readbyte(moveAddress + 17),
			unknownFlag10 = Memory.readbyte(moveAddress + 18),
			unknownFlag11 = Memory.readbyte(moveAddress + 19),
		}
	end
end
function GameSettings.populateTrainerClassNames()
	local address = GameSettings.trainerClassNames
	local dataEnd = GameSettings.trainerStatsTable - 2
	local trainerClassNames = {}
	while address < dataEnd do
		table.insert(trainerClassNames, Utils.toString(address, 13))
		address = address + 13
	end
	GameSettings.trainerClassList = trainerClassNames
end

function GameSettings.populateTrainerStats()
	local length = 864
	local trainers = {}
	local trainersByName = {}
	local address = GameSettings.trainerStatsTable
	local data = {}
	local name = ""
	for i = 0, length - 1, 1 do
		data = {}
		data.trainerStructtype = Memory.readbyte(address)
		data.trainerClass = GameSettings.trainerClassList[Memory.readbyte(address + 1) + 1]
		data.musicandGenderFlags = Memory.readbyte(address + 2) -- first 7 bits are the intro music, last bit is gender
		data.spriteFront = Memory.readbyte(address + 3)
		data.name = Utils.toString(address + 4, 12)
		data.prizeMoney = Memory.readbyte(address + 15) -- requires more calculation. Not that I'll probably need it.
		data.item1 = Memory.readword(address + 16) -- ID of item
		data.item2 = Memory.readword(address + 18)
		data.item3 = Memory.readword(address + 20)
		data.item4 = Memory.readword(address + 22)
		data.isDoubleBattle = Memory.readbyte(address + 24) == 1
		-- 3 bytes of padding
		data.trainerAi = Memory.readbyte(address + 28)
		-- 3 bytes of padding
		data.pokemonCount = Memory.readbyte(address + 32)
		data.unknown = Memory.readbyte(address + 33)
		-- 2 bytes of padding
		data.trainerPartyPointer = Memory.readdword(address + 36) -- Points to the data about that trainer's party composition.
		address = address + 40
		if data.trainerClass == nil then
			data.trainerClass = ""
			name = data.name
		else
			name = data.trainerClass .. " " .. data.name
		end
		data.fullName = name
		if trainersByName[name] == nil then
			trainersByName[name] = {}
		end
		trainersByName[name][i] = data
		trainers[i] = data 
	end
	GameSettings.trainers = trainers
	GameSettings.trainersByName = trainersByName
end