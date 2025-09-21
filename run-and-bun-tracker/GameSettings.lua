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
		GameSettings.encountertable = 0x8552D48 -- Unsure if correct, may have to update
		GameSettings.version = GameSettings.VERSIONS.E
		GameSettings.language = GameSettings.LANGUAGES.U
	else
		GameSettings.game = 0
		GameSettings.gamename = "Unsupported game"
		GameSettings.encountertable = 0
	end
	-- If it is pokemon Emerald, then
	if GameSettings.game > 0 then
		GameSettings.pstats  = 0x2023a98
		GameSettings.estats  = 0x2023CF0
		GameSettings.rng = 0x3005D90
		GameSettings.wram = 0x2020000
		GameSettings.mapbank = 0x203BC80
		GameSettings.mapid = 0x20368F0
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
		GameSettings.gBattleTypeFlags = 0x2023364 -- Value 20 for tutorial fight, 0 then 4 for wild, (went to 8 then 12 for rival fight)
		GameSettings.gPokemonStorage = 0x2028848
		GameSettings.gPlayerPartyCount = 0x2023a95
		local monData = GameSettings.generatePokemonDetails()
		GameSettings.mons = monData[1] -- Probably should move this to the Data section.
		GameSettings.names =  monData[2] -- Probably should move this to the Data section. 
	end
end

function GameSettings.generatePokemonDetails()
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
		mon.type2 = PokemonData.type[Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 7) + 1]
		mon.catchrate = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 8)
		-- 1 byte of padding
		mon.bXP = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 10)
		mon.unknown1 = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 11) -- Unsure. Values 0-2
		mon.evYields = Memory.readword(GameSettings.pokemonDataTable + dataOffset + 12)
		mon.item1 = Memory.readword(GameSettings.pokemonDataTable + dataOffset + 14)
		mon.item2 = Memory.readword(GameSettings.pokemonDataTable + dataOffset + 16)
		mon.genderThreshold = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 18)
		mon.eggCycles = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 19)
		mon.baseFriendship = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 20)
		mon.levelUpType = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 21)
		mon.eggGroup1 = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 22)
		mon.eggGroup2 = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 23)
		mon.ability1 = Memory.readword(GameSettings.pokemonDataTable + dataOffset + 24) -- Abilities Now are 2 Bytes (possibly for more than 256)
		mon.ability2 = Memory.readword(GameSettings.pokemonDataTable + dataOffset + 26) -- Abilities Now are 2 Bytes (possibly for more than 256)
		mon.hiddenAbility = Memory.readword(GameSettings.pokemonDataTable + dataOffset + 28) -- Abilities Now are 2 Bytes (possibly for more than 256)
		mon.sRunRate = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 30)
		mon.colorFlip = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 31)
		mon.unknown2 = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 32) -- Unsure. Values 0-230
		mon.unknown3 = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 33) -- Unsure. values 0-4
		mon.unknown4 = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 34) -- Unsure values 0-255
		mon.unknown5 = Memory.readbyte(GameSettings.pokemonDataTable + dataOffset + 35) -- Unsure values 0-39
		address = GameSettings.pokemonNameTable + nameOffset
		name = GameSettings.toString(address, monNameLength)
		mons[name] = mon 
		names[i] = name
	end
	return {mons, names}
end
---Gets the ROM name as defined by the emulator, or an empty string if not found
---@return string
function GameSettings.getRomName()
	return gameinfo.getromname() or ""
end
function GameSettings.toString(address, length)
	local nickname = ""
	for i=0, length - 1, 1 do
		local charByte = Memory.readbyte(address + i)
		if charByte == 0xFF then break end -- end of sequence
		nickname = nickname .. CharData.charmap[charByte]
	end
	return nickname
end