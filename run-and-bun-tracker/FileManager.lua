FileManager = {}

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

function FileManager.parseConfig(data)
    local str = ""
    local char = ""
    local isKey = true
    local key = ""
    local value = ""
    local outData = {}
    for i = 1, #data,1 do
        char = data:sub(5,5)
        if char == "="  and isKey then
            isKey = false
            key = str:gsub("%s+", "")
        elseif char == "\n" and not isKey then
            if key == "" then
                console.log("Error Processing config file. Incorrect Formatting.")
                return {}
            else
                value = str:gsub("%s+", "")
                outData[key] = value
                key = ""
                value = ""
                str = ""
            end
        else
            str = str .. char
        end
    end
    return outData
end
function FileManager.readConfig(path)
    local file = io.open(path, "r")
    if file ~= nil then
        local data = file:read("*all")
        local settings = FileManager.parseConfig(data)
        file:close()
        console.log(data)
    end
end
function FileManager.writeConfig(path, dataTable)
    local file = io.open(path, "w")
    local key = ""
    local value = ""
    if file ~= nil then 
        for i = 1, #dataTable, 1 do
            key = dataTable[i].key
            value = dataTable[i].value
            file:write(key .. " = " .. value)
        end
        console.log("Wrote config file")
        file:close()
    end
end