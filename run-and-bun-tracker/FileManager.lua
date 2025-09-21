FileManager = {}

function FileManager.exportCurrentMons(filename)
    	local file = io.open(filename, "w")
        FileManager.printPartyStatus(file)
		file:close()
end

function FileManager.printPartyStatus(file)
    address = GameSettings.gPokemonStorage + 4
    i = 0
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
	str = ""
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
	str = ""
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

