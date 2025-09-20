Program = {
	selectedPokemon = {
		id = 0
	},
	trainerPokemonTeam = {},
	enemyPokemonTeam = {},
	trainerInfo = {},
	isInBattle = false,
	inTrainersView = false,
	isWildEncounter = false
}
Program.rng = {
	current = 0,
	previous = 0,
	grid = {}
}
Program.map = {
	id = 0,
	encounters = {
		{
			encrate = -1,
			SLOTS = 12,
			RATES = {20,20,10,10,10,10,5,5,4,4,1,1}
		},
		{
			encrate = -1,
			SLOTS = 5,
			RATES = {60,30,5,4,1}
		},
		{
			encrate = -1,
			SLOTS = 5,
			RATES = {60,30,5,4,1}
		}
	}
}
Program.catchdata = {
	pokemon = 1,
	curHP = 20,
	maxHP = 20,
	level = 5,
	ball = 4,
	status = 0,
	rng = 0,
	rate = 0
}

function Program.main()
	Input.update()
	Program.trainerPokemonTeam = Program.getTrainerData(1)
	
	Program.trainerInfo = Program.getTrainerInfo()
	local battleFlags = Memory.readdword(GameSettings.gBattleTypeFlags)
	
	if Program.getBattleOutcome() == 0 and not Program.isInBattle then -- Happens once at battle start
		Program.isInBattle = true
		Program.isWildEncounter = Utils.getbits(battleFlags, 3, 1) == 0
		Program.enemyPokemonTeam = Program.getTrainerData(2)
	elseif Program.getBattleOutcome() == 0 then --loops while in battle
		Program.isInBattle = true -- for if the player starts the script mid-battle
		Program.enemyPokemonTeam = Program.getTrainerData(2)
	elseif Program.isInBattle then -- Happens once after a battle ends
		Program.isInBattle = false
		Program.enemyPokemonTeam = Program.getBlankTrainerData()
		LayoutSettings.pokemonIndex.player = 1
		LayoutSettings.pokemonIndex.slot = 1
	else --loops out of battle
		Program.enemyPokemonTeam = Program.getBlankTrainerData()
	end
	if LayoutSettings.showRightPanel and Program.trainerPokemonTeam[1]["pkmID"] ~= 0 then
		local pokemonaux = Program.getPokemonData(LayoutSettings.pokemonIndex)
		Program.selectedPokemon = pokemonaux

		Drawing.drawPokemonView()
	end
	if LayoutSettings.menus.main.selecteditem == LayoutSettings.menus.main.MAP then
		Drawing.drawMap()
	end
	Drawing.drawButtons()
end

function Program.getTrainerInfo()
	local trainer = GameSettings.trainerpointer
	if Memory.readbyte(trainer) == 0 then
		return {
			gender = -1,
			tid = 0,
			sid = 0
		}
	else
		return {
			gender = Memory.readbyte(trainer + 8),
			tid = Memory.readword(trainer + 10),
			sid = Memory.readword(trainer + 12)
		}
	end
end

function Program.updateCatchData()
	if LayoutSettings.menus.catch.selecteditem == LayoutSettings.menus.catch.AUTO then
		local pokemonaux = Program.getPokemonData({player = 2, slot = 1})
		Program.catchdata.pokemon = pokemonaux.pokemonID
		Program.catchdata.curHP = pokemonaux.curHP 
		Program.catchdata.maxHP = pokemonaux.maxHP 
		Program.catchdata.level = pokemonaux.level
		Program.catchdata.status = pokemonaux.status
	end
	
	local m = Program.catchdata.maxHP
	local h = Program.catchdata.curHP
	local c = PokemonData.catchrate[Program.catchdata.pokemon + 1]
	
	local s = 1
	if Program.catchdata.status == 1 or Program.catchdata.status == 4 then
		s = 2
	elseif Program.catchdata.status > 1 then
		s = 1.5
	end
	
	local b = 1
	if Program.catchdata.ball == 2 then
	elseif Program.catchdata.ball == 2 then
		b = 1.5
	elseif Program.catchdata.ball == 3 then
		b = 1.5
	elseif Program.catchdata.ball == 5 then
		b = 1.5
	end
	
	local x = math.floor((3 * m - 2 * h) * math.floor(c * b))
	x = math.floor(x / (3*m))
	x = math.floor(x * s)
	
	local y = 65536
	if (x < 255 and Program.catchdata.ball > 1) then		
		y = math.floor(math.sqrt(16711680 / x))
		y = math.floor(math.sqrt(y))
		y = math.floor(1048560 / y)
	end
	Program.catchdata.rng = y
	Program.catchdata.rate = (y/65536) * (y/65536) * (y/65536) * (y/65536)
end

function Program.updateEncounterData()
	-- Search map in ROM's table
	if Program.map.id == 0 then
		Program.map.encounters[1].encrate = -1
		Program.map.encounters[2].encrate = -1
		Program.map.encounters[3].encrate = -1
		return
	end
	local mapid_aux = Memory.readword(GameSettings.encountertable)
	local index = 0
	while mapid_aux ~= Program.map.id do
		index = index + 1
		mapid_aux = Memory.readword(GameSettings.encountertable + 20*index)
		if mapid_aux == 0xFFFF then
			Program.map.encounters[1].encrate = -1
			Program.map.encounters[2].encrate = -1
			Program.map.encounters[3].encrate = -1
			return
		end
	end
	
	-- Search encounter data
	for i=1,3,1 do
		local minl = {}
		local maxl = {}
		local pkm = {}
		local pointer = Memory.readdword(GameSettings.encountertable + 20*index + 4*i)
		if pointer == 0 then
			Program.map.encounters[i].encrate = -1
		else
			local ratio = Memory.readword(pointer)
			if ratio == 0xFFFF then
				Program.map.encounters[i].encrate = -1
			else
				Program.map.encounters[i].encrate = ratio
				Program.map.encounters[i].pokemon = {}
				pointer = Memory.readdword(pointer + 4)
				for j = 1, Program.map.encounters[i].SLOTS,1 do
					local pkmdata = Memory.readdword(pointer + (j-1)*4)
					Program.map.encounters[i].pokemon[j] = {
						minlevel = Utils.getbits(pkmdata, 0, 8),
						maxlevel = Utils.getbits(pkmdata, 8, 8),
						id = Utils.getbits(pkmdata, 16, 16)
					}
				end
			end
		end
	end
end
function Program.getBlankTrainerData()
	local trainerdata = {}
	for i = 1,6,1 do
		trainerdata[i] = {
			pkmID = 0,
			curHP = 0,
			maxHP = 0,
			level = 0
		}
	end
	return trainerdata
end

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
		local growth = (Memory.readdword(start + 32 + growthoffset) ~ magicword)
		trainerdata[i] = {
			pkmID = Utils.getbits(growth, 0, 16),
			status = Utils.getStatus(start+80),
			curHP = Memory.readword(start + 86),
			maxHP = Memory.readword(start + 88),
			level = Memory.readbyte(start + 84),
			isEnemy = isEnemyMon
		}
	end
	return trainerdata
end

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
		if  GameSettings.mons[GameSettings.names[mon.pokemonID + 1]] ~= nil then
			local genderThreshold = GameSettings.mons[GameSettings.names[mon.pokemonID + 1]]["genderThreshold"]
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
function readPartyMon(address)
	local mon = Program.readBoxMon(address)
	mon.status = Utils.getStatus(address + 80)
	mon.sleepTurns = sleep_turns_result
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
		local mon = readPartyMon(address)
		mon.isEnemy = isEnemyMon
		return mon
end

function Program.getBattleOutcome()
	return Memory.readbyte(GameSettings.gBattleOutcome)
end

function Program.getAbility(mon)
	local pokemonID = mon.pokemonID
    current = PokemonData.ability[(pokemonID*3)+1+mon.altAbility]
    if (current == "None") then
        current = PokemonData.ability[(pokemonID*3)+1]
    end
    return current
end

function Program.getHiddenPower(mon)
    return math.floor(((mon.hpIV%2 + (2*(mon.attackIV%2))+(4*(mon.defenseIV%2))+(8*(mon.speedIV%2))+(16*(mon.spAttackIV%2))+(32*(mon.spDefenseIV%2)))*5)/21) + 1
end

function Program.isValidPokemon(pokemonID)
	return pokemonID ~= nil and PokemonData.name[pokemonID] ~= nil
end
function Program.advance10Frames()
	for i = 0, 10, 1 do
		emu.frameadvance()
	end
end