Drawing = {}

function Drawing.drawLayout()
	gui.drawRectangle(
		Constants.Graphics.SCREEN_WIDTH,
		0,
		Constants.Graphics.RIGHT_GAP - 1,
		Constants.Graphics.UP_GAP +  Constants.Graphics.DOWN_GAP + Constants.Graphics.SCREEN_HEIGHT - 1,
		GameSettings.gamecolor,
		0x00000000
	)
	gui.drawRectangle(
		0,
		Constants.Graphics.SCREEN_HEIGHT + Constants.Graphics.UP_GAP,
		Constants.Graphics.SCREEN_WIDTH,
		Constants.Graphics.DOWN_GAP - 1,
		GameSettings.gamecolor,
		0x00000000
	) 
	local location = PokemonData.map[Battle.regionID]
	local encounterstatus = "Encounter Available"
	local color = 0xFF009D07
	if not Encounters.isEncounterAvailable(location) then
		encounterstatus = "Encounter Not Available"
		color = 0xFF004D07
	end
	gui.drawRectangle(
		0,
		0,
		Constants.Graphics.SCREEN_WIDTH,
		Constants.Graphics.UP_GAP,
		color,
		color - 0x80000000
	)
	gui.drawText(
		Constants.Graphics.SCREEN_WIDTH / 2 - ((string.len(encounterstatus) + 5) * 3),
		3,
		encounterstatus,
		"white",
		0x00000000,
		10,
		"Lucida Console"
	)
end

function Drawing.drawPokemonIcon(id, x, y, selectedPokemon, isShiny)
	if selectedPokemon then
		gui.drawRectangle(x,y,36,36, Constants.Graphics.SELECTEDCOLOR[1], Constants.Graphics.SELECTEDCOLOR[2])
	else
		gui.drawRectangle(x,y,36,36, Constants.Graphics.NONSELECTEDCOLOR, 0xFF222222)
	end
	if id ~= nil and id ~= 0 and GameSettings.names[id] ~= nil and type(GameSettings.names[id]) == "string" then
		local name = GameSettings.names[id]:gsub(" ", "-"):lower()
		local path = FileManager.prependDir(FileManager.Folders.RegularSprite, true)
		if isShiny then
			path = FileManager.prependDir(FileManager.Folders.ShinySprite, true)
		end
		gui.drawImage(path .. name .. ".png", x- 16, y - 24)
	end
end

function Drawing.drawPokemonIconByName(name, x, y)
	
	if Encounters.encounters[Battle.location] == name then
		gui.drawRectangle(x,y,36,36, Constants.Graphics.SELECTEDCOLOR[1], Constants.Graphics.SELECTEDCOLOR[2])
	else
		gui.drawRectangle(x,y,36,36, Constants.Graphics.NONSELECTEDCOLOR, 0xFF222222)
	end
	local path = FileManager.prependDir(FileManager.Folders.RegularSprite, true)
	gui.drawImage(path .. name .. ".png", x- 16, y - 24)
end

function Drawing.drawStatusIcon(status, x, y)
	if status ~= nil and status ~= "None" then
		status = status:gsub(" ", "-")
		gui.drawImage(FileManager.prependDir(FileManager.Folders.Status, true) .. status .. ".png", x, y)
	end
end
function Drawing.drawTypeIcon(type, x, y)
	if type ~= nil and type ~= "" then
		gui.drawImage(FileManager.prependDir(FileManager.Folders.Type, true) .. type .. ".png", x, y)
	end
end

function Drawing.drawText(x, y, text, color)
	gui.drawText( x, y, text, color, nil, 9, "Franklin Gothic Medium")
end

function Drawing.drawTriangleRight(x, y, size, color)
	gui.drawRectangle(x, y, size, size, color)
	gui.drawPolygon({{4+x,4+y},{4+x,y+size-4},{x+size-4,y+size/2}}, color, color)
end
function Drawing.drawTriangleLeft(x, y, size, color)
	gui.drawRectangle(x, y, size, size, color)
	gui.drawPolygon({{x+size-4,4+y},{x+size-4,y+size-4},{4+x,y+size/2}}, color, color)
end

function Drawing.drawGeneralInfo()
	local currng = Memory.readdword(GameSettings.rng)
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 5, Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + Constants.Graphics.DOWN_GAP - 40, "RNG seed:")
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + Constants.Graphics.DOWN_GAP - 40, GameSettings.rngseed .. " (" .. Utils.tohex(GameSettings.rngseed) .. ")", "yellow")
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 5, Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + Constants.Graphics.DOWN_GAP - 30, "RNG frame:")
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + Constants.Graphics.DOWN_GAP - 30, Utils.getRNGDistance(GameSettings.rngseed, currng), "yellow")
end

function Drawing.drawPokemonView()
	Drawing.drawPokemonIcon(Program.selectedPokemon.pokemonID, Constants.Graphics.SCREEN_WIDTH + 5, 5, Program.selectedPokemon, Program.selectedPokemon.isShiny)
	local colorbar = "white"
	local types = Program.getPokemonTypes(Program.selectedPokemon.pokemonID)
	Drawing.drawTypeIcon(types[1],  Constants.Graphics.SCREEN_WIDTH + 100, 32)
	if types[1] ~= types[2] and types[2] ~= nil then
		Drawing.drawTypeIcon(types[2],  Constants.Graphics.SCREEN_WIDTH + 100, 44)
	end
	if Program.selectedPokemon["hp"] / Program.selectedPokemon["maxHP"] <= 0.2 then
		colorbar = "red"
	elseif Program.selectedPokemon["hp"] / Program.selectedPokemon["maxHP"] <= 0.5 then
		colorbar = "yellow"
	end
	local name = ""
	if GameSettings.names[Program.selectedPokemon["pokemonID"]] ~= nil then
		name = GameSettings.names[Program.selectedPokemon["pokemonID"]]:gsub("-", " ") or ""
	end
	local genderColor = 0xFFFF9C94
	if Program.selectedPokemon.gender == "Male" then
		genderColor = 0xFF42CEFF
	elseif Program.selectedPokemon.gender == "Unknown" then
		genderColor = 0xFF000000
	end
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 45, 7, name, genderColor)
	if Program.selectedPokemon["status"] ~= "None"  then
		Drawing.drawStatusIcon(Program.selectedPokemon["status"], Constants.Graphics.SCREEN_WIDTH + 6, 6)
	elseif Program.selectedPokemon["hp"] == 0 and Program.selectedPokemon["maxHP"] ~= 0 then
		Drawing.drawStatusIcon("Fainted", Constants.Graphics.SCREEN_WIDTH + 6, 6)
	end
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 45, 17, "HP:")
	if Program.selectedPokemon.isEnemy and Battle.isWildEncounter then
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 17, "?" .. " / " .. "?", colorbar)
	elseif Program.selectedPokemon.isEnemy then
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 17, "?" .. " / " .. Program.selectedPokemon["maxHP"], colorbar)
	else
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 17, Program.selectedPokemon["hp"] .. " / " .. Program.selectedPokemon["maxHP"], colorbar)
	end
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 45, 27, "Level: " .. Program.selectedPokemon["level"])
	
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 5, 43, "Item:")
	if Program.selectedPokemon.isEnemy and Battle.isWildEncounter then
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 42, 43, "???", "yellow")
	else
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 42, 43, PokemonData.item[Program.selectedPokemon["heldItem"]], "yellow")
	end
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 5, 53, "Abilty:")
	if Program.selectedPokemon.isEnemy and Battle.isWildEncounter then
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 42, 53, "???", "yellow")
	else	
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 42, 53, Program.getAbility(Program.selectedPokemon), "yellow")
	end	
	local tid = Utils.getbits(Program.selectedPokemon["otId"], 0, 16)
	local sid = Utils.getbits(Program.selectedPokemon["otId"], 16, 16)
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 5, 63, "OT ID:")
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 42, 63, tid, "yellow")
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 75, 63, "OT SID:")
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 112, 63, sid, "yellow")
	
	gui.drawRectangle(Constants.Graphics.SCREEN_WIDTH + 5, 75, Constants.Graphics.RIGHT_GAP - 11, 85,0xFFAAAAAA, 0xFF222222)
	
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 80, "Stat", "white")
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 80, "IV", "white")
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 120, 80, "EV", "white")
	
	
	
	if Program.selectedPokemon.isEnemy and Battle.isWildEncounter then
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 95, "HP",  "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 105, "Attack",  "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 115, "Defense",  "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 125, "Sp. Atk",  "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 135, "Sp. Def",  "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 145, "Speed",  "white")

		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 95, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 105, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 115, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 125, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 135, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 145, "?", "white")
		
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 95, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 105, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 115, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 125, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 135, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 145, "?", "white")
		
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 120, 95, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 120, 105, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 120, 115, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 120, 125, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 120, 135, "?", "white")
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 120, 145, "?", "white")
	else
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 95, "HP", Utils.getNatureColor("hp", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 105, "Attack", Utils.getNatureColor("atk", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 115, "Defense", Utils.getNatureColor("def", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 125, "Sp. Atk", Utils.getNatureColor("spa", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 135, "Sp. Def", Utils.getNatureColor("spd", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 145, "Speed", Utils.getNatureColor("spe", Program.selectedPokemon["nature"]))

		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 95, Program.selectedPokemon["maxHP"], Utils.getNatureColor("hp", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 105, Program.selectedPokemon["attack"], Utils.getNatureColor("atk", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 115, Program.selectedPokemon["defense"], Utils.getNatureColor("def", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 125, Program.selectedPokemon["spAttack"], Utils.getNatureColor("spa", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 135, Program.selectedPokemon["spDefense"], Utils.getNatureColor("spd", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 60, 145, Program.selectedPokemon["speed"], Utils.getNatureColor("spe", Program.selectedPokemon["nature"]))

		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 95, Program.selectedPokemon["hpIV"], Utils.getNatureColor("hp", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 105, Program.selectedPokemon["attackIV"], Utils.getNatureColor("atk", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 115, Program.selectedPokemon["defenseIV"], Utils.getNatureColor("def", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 125, Program.selectedPokemon["spAttackIV"], Utils.getNatureColor("spa", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 135, Program.selectedPokemon["spDefenseIV"], Utils.getNatureColor("spd", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 145, Program.selectedPokemon["speedIV"], Utils.getNatureColor("spe", Program.selectedPokemon["nature"]))
		
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 120, 95, Program.selectedPokemon["hpEV"], Utils.getNatureColor("hp", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 120, 105, Program.selectedPokemon["attackEV"], Utils.getNatureColor("atk", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 120, 115, Program.selectedPokemon["defenseEV"], Utils.getNatureColor("def", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 120, 125, Program.selectedPokemon["speedEV"], Utils.getNatureColor("spa", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 120, 135, Program.selectedPokemon["spAttackEV"], Utils.getNatureColor("spd", Program.selectedPokemon["nature"]))
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 120, 145, Program.selectedPokemon["spDefenseEV"], Utils.getNatureColor("spe", Program.selectedPokemon["nature"]))
	end
	
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 15, 162, "Nature:")
	if Program.selectedPokemon.isEnemy and Battle.isWildEncounter then
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 80, 162, "???", "yellow")
	else
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 80, 162, PokemonData.nature[Program.selectedPokemon["nature"] + 1], "yellow")
	end
	local hptype, hpcolor = Program.getHP(Program.selectedPokemon)
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 15, 172, "Hidden Power:")
	if Program.selectedPokemon.isEnemy and Battle.isWildEncounter then
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 80, 172, "???")
	else
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 80, 172, hptype, hpcolor)
	end
	gui.drawRectangle(Constants.Graphics.SCREEN_WIDTH + 5, 185, Constants.Graphics.RIGHT_GAP - 11, 65,0xFFAAAAAA, 0xFF222222)
	if Program.selectedPokemon.moves[1] then
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 205, PokemonData.move[Program.selectedPokemon.moves[1] + 1])
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 215, PokemonData.move[Program.selectedPokemon.moves[2] + 1])
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 225, PokemonData.move[Program.selectedPokemon.moves[3] + 1])
		Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 10, 235, PokemonData.move[Program.selectedPokemon.moves[4] + 1])
	end
	
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 190, "PP")
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 205, Program.selectedPokemon.pp[1])
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 215, Program.selectedPokemon.pp[2])
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 225, Program.selectedPokemon.pp[3])
	Drawing.drawText(Constants.Graphics.SCREEN_WIDTH + 90, 235, Program.selectedPokemon.pp[4])
end

function Drawing.drawMap()
	gui.drawImage(FileManager.prependDir(FileManager.Folders.Maps, true) .. Map.file .. ".png", 1, Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + 17, Constants.Graphics.SCREEN_WIDTH - 1, 167)
	local position = {-7, Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT}
	local coords = Map.findCoords(Memory.readbyte(GameSettings.regionID)) -- Uses an outdated map id. Will look into replacing in the future.
	
	if Program.trainerInfo.gender >= 0 then
		local gender = 'girl'
		if Program.trainerInfo.gender == 0 then
			gender = 'boy'
		end
		if GameSettings.version == GameSettings.VERSIONS.E then
			gender = gender .. '-e'
		elseif GameSettings.version == GameSettings.VERSIONS.RS then
			gender = gender .. '-rs'
		else --frlg
			gender = gender .. '-frlg'
		end
		gui.drawImage(FileManager.prependDir(FileManager.Folders.Player, true) .. gender .. ".png", position[1] + (coords[1] - 1)*8, position[2] + (coords[2] - 1)*8, 16, 16)
	end
	gui.drawText(
		2,
		Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + 19,
		Battle.location,
		"white",
		0x00000000,
		9,
		"Lucida Console"
	)
end

function Drawing.drawEncounterTab(encounters, encounterType, map, numEncounters)
	local output = ""
	local half = 6
	local offset = 39
	local topOffset = 39
	local bottomOffset = 0
	local bottomShift = 0
	local bottomleftGap = 5
	local topleftGap = 5
	if encounters ~= nil then
		if numEncounters > 6 then
			local isOdd = numEncounters%2 == 1
			half = math.floor(numEncounters/2)
			bottomOffset = offset * 6 / half
			topOffset = bottomOffset
			bottomleftGap = (Constants.Graphics.SCREEN_WIDTH - offset * half)/2
			if isOdd then
				half = half + 1
				topOffset = offset * 6 / half
			end
			bottomShift = half - numEncounters - 1
			topleftGap = (Constants.Graphics.SCREEN_WIDTH - offset * half)/2
		end
		
		local i = 0
		local levels = ""
		for name, data in pairs(encounters) do
			levels = data.lowlevel
			if data.lowlevel ~= data.highlevel then
				levels = levels .. "-" .. data.highlevel
			end
			if i < half then
				Drawing.drawPokemonIconByName(name, topleftGap + (i) * topOffset, Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + 60)
				gui.drawText(topleftGap + (i) * topOffset, Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + 46,levels  ,"white", 0x00000000, 10,"Lucida Console")
				gui.drawText(topleftGap + (i) * topOffset, Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + 100,data.rate .. "%" ,"white", 0x00000000, 10,"Lucida Console")
			else
				Drawing.drawPokemonIconByName(name, bottomleftGap + (i-6) * bottomOffset, Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + 130)
				gui.drawText(bottomleftGap + (i + bottomShift) * bottomOffset, Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + 116,levels  ,"white", 0x00000000, 10,"Lucida Console")
				gui.drawText(bottomleftGap + (i + bottomShift) * bottomOffset, Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + 170,data.rate .. "%" ,"white", 0x00000000, 10,"Lucida Console")
			end
			i = i + 1
		end
	else
		output = "No ".. encounterType .. " encounters in" 
		gui.drawText(
			Constants.Graphics.SCREEN_WIDTH / 2 - ((string.len(output) + 5) * 3),
			Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + (Constants.Graphics.DOWN_GAP + 12) / 2,
			output,
			"white",
			0x00000000,
			10,
			"Lucida Console"
		)
		gui.drawText(
			Constants.Graphics.SCREEN_WIDTH / 2 - ((string.len(map) + 5) * 3),
			12 + Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + (Constants.Graphics.DOWN_GAP + 12) / 2,
			map,
			"white",
			0x00000000,
			10,
			"Lucida Console"
		)
	end
end

function Drawing.drawEncounters()
	local mapID = Battle.mapID
	local map = Battle.location
	local encounters = nil
	local output = ""
	local length = 0
	if Encounters.doesMapHaveEncounters(map) then
		for i, encounterType in ipairs(LayoutSettings.menus.encounters.types) do
			encounters = Encounters.routeEncounters[Encounters.routeEncounters.Keys[i]][mapID]
			length = Encounters.routeEncounters[Encounters.routeEncounters.Keys[i]]['lengths'][mapID]
			if LayoutSettings.menus.encounters.selecteditem == i then
				Drawing.drawEncounterTab(encounters, encounterType, map, length)
			end
		end
	else
		gui.drawText(
			Constants.Graphics.SCREEN_WIDTH / 2 - ((string.len(output) + 5) * 3),
			Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + (Constants.Graphics.DOWN_GAP + 34) / 2,
			"This route has no Encounters",
			"white",
			0x00000000,
			10,
			"Lucida Console"
		)
	end
end

function Drawing.drawButtons()
	for i = 1, #Buttons, 1 do
		if Buttons[i].visible() then
			if Buttons[i].type == ButtonType.singleButton then
				gui.drawRectangle(Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[3], Buttons[i].box[4], Buttons[i].backgroundcolor[1], Buttons[i].backgroundcolor[2])
				Drawing.drawText(Buttons[i].box[1] + 2, Buttons[i].box[2] + (Buttons[i].box[4] - 12) / 2 + 1, Buttons[i].text, Buttons[i].textcolor)
			elseif Buttons[i].type == ButtonType.horizontalMenu then
				local selecteditem = LayoutSettings.menus[Buttons[i].model].selecteditem
				local menuitems = LayoutSettings.menus[Buttons[i].model].items
				local itemcount = #menuitems
				local itemwidth = Buttons[i].box[3] / itemcount
				for j = 1, itemcount, 1 do
					gui.drawRectangle((j-1) * itemwidth + Buttons[i].box[1], Buttons[i].box[2], itemwidth, Buttons[i].box[4], Constants.Graphics.NONSELECTEDCOLOR)
					Drawing.drawText((j-1) * itemwidth + Buttons[i].box[1] + 2, Buttons[i].box[2] + (Buttons[i].box[4] - 12) / 2 + 1, menuitems[j], Constants.Graphics.NONSELECTEDCOLOR)
				end
				gui.drawRectangle((selecteditem-1) * itemwidth + Buttons[i].box[1], Buttons[i].box[2], itemwidth, Buttons[i].box[4], Constants.Graphics.SELECTEDCOLOR[1], Constants.Graphics.SELECTEDCOLOR[2])
				Drawing.drawText((selecteditem-1) * itemwidth + Buttons[i].box[1] + 2, Buttons[i].box[2] + (Buttons[i].box[4] - 12) / 2 + 1, menuitems[selecteditem], Constants.Graphics.SELECTEDCOLOR[1])
			elseif Buttons[i].type == ButtonType.horizontalMenuBar then
				local selecteditem = LayoutSettings.menus[Buttons[i].model].selecteditem
				local menuitems = LayoutSettings.menus[Buttons[i].model].items
				local itemcount = #menuitems
				local itemwidth = (Buttons[i].box[3] - (Buttons[i].box[4] * 2)) / Buttons[i].visibleitems
				gui.drawRectangle(Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[4], Buttons[i].box[4], Constants.Graphics.NONSELECTEDCOLOR)
				if Buttons[i].firstvisible > 1 then
					Drawing.drawTriangleLeft(Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[4], Constants.Graphics.NONSELECTEDCOLOR)
				end
				gui.drawRectangle(Buttons[i].box[1] + Buttons[i].box[3] - Buttons[i].box[4], Buttons[i].box[2], Buttons[i].box[4], Buttons[i].box[4], Constants.Graphics.NONSELECTEDCOLOR)
				if Buttons[i].firstvisible < itemcount - Buttons[i].visibleitems + 1 then
					Drawing.drawTriangleRight(Buttons[i].box[1] + Buttons[i].box[3] - Buttons[i].box[4], Buttons[i].box[2], Buttons[i].box[4], Constants.Graphics.NONSELECTEDCOLOR)
				end
				for j = Buttons[i].firstvisible, Buttons[i].firstvisible + Buttons[i].visibleitems - 1, 1 do
					gui.drawRectangle((j-Buttons[i].firstvisible) * itemwidth + Buttons[i].box[1] + Buttons[i].box[4], Buttons[i].box[2], itemwidth, Buttons[i].box[4], Constants.Graphics.NONSELECTEDCOLOR)
					Drawing.drawText((j-Buttons[i].firstvisible) * itemwidth + Buttons[i].box[1] + Buttons[i].box[4] + 2, Buttons[i].box[2] + (Buttons[i].box[4] - 12) / 2 + 1, menuitems[j], Constants.Graphics.NONSELECTEDCOLOR)
				end
				local selecteditemposition = selecteditem - Buttons[i].firstvisible
				if selecteditemposition >= 0 and selecteditemposition < Buttons[i].visibleitems then 
					gui.drawRectangle(selecteditemposition * itemwidth + Buttons[i].box[1] + Buttons[i].box[4], Buttons[i].box[2], itemwidth, Buttons[i].box[4], Constants.Graphics.SELECTEDCOLOR[1], Constants.Graphics.SELECTEDCOLOR[2])
					Drawing.drawText(selecteditemposition * itemwidth + Buttons[i].box[1] + Buttons[i].box[4] + 2, Buttons[i].box[2] + (Buttons[i].box[4] - 12) / 2 + 1, menuitems[selecteditem], Constants.Graphics.SELECTEDCOLOR[1])
				end
			elseif Buttons[i].type == ButtonType.verticalMenu then
				local selecteditem = LayoutSettings.menus[Buttons[i].model].selecteditem
				local menuitems = LayoutSettings.menus[Buttons[i].model].items
				local itemcount = #menuitems
				for j = 1, itemcount, 1 do
					gui.drawRectangle(Buttons[i].box_first[1], Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4], Buttons[i].box_first[3], Buttons[i].box_first[4], Constants.Graphics.NONSELECTEDCOLOR)
					local itemtext = menuitems[j]
					if LayoutSettings.menus[Buttons[i].model].accuracy and LayoutSettings.menus[Buttons[i].model].accuracy[j] ~= -1 then
						itemtext = menuitems[j] .. ' (' .. LayoutSettings.menus[Buttons[i].model].accuracy[j] .. '% acc.)'
						gui.drawRectangle(Buttons[i].box_first[1] + Buttons[i].box_first[3], Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4], Buttons[i].box_first[4], Buttons[i].box_first[4], Constants.Graphics.NONSELECTEDCOLOR)
						gui.drawRectangle(Buttons[i].box_first[1] + Buttons[i].box_first[3] + Buttons[i].box_first[4], Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4], Buttons[i].box_first[4], Buttons[i].box_first[4], Constants.Graphics.NONSELECTEDCOLOR)
						Drawing.drawText(Buttons[i].box_first[1] + Buttons[i].box_first[3] + 3, Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4] + (Buttons[i].box_first[4] - 12) / 2 + 1, '-', Constants.Graphics.NONSELECTEDCOLOR)
						Drawing.drawText(Buttons[i].box_first[1] + Buttons[i].box_first[3] + Buttons[i].box_first[4] + 3, Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4] + (Buttons[i].box_first[4] - 12) / 2 + 1, '+', Constants.Graphics.NONSELECTEDCOLOR)
					end
					Drawing.drawText(Buttons[i].box_first[1] + 2, Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4] + (Buttons[i].box_first[4] - 12) / 2 + 1, itemtext, Constants.Graphics.NONSELECTEDCOLOR)
				end
				gui.drawRectangle(Buttons[i].box_first[1], Buttons[i].box_first[2] + (selecteditem-1) * Buttons[i].box_first[4], Buttons[i].box_first[3], Buttons[i].box_first[4], Constants.Graphics.SELECTEDCOLOR[1], Constants.Graphics.SELECTEDCOLOR[2])
				local itemtext = menuitems[selecteditem]
				if LayoutSettings.menus[Buttons[i].model].accuracy and LayoutSettings.menus[Buttons[i].model].accuracy[selecteditem] ~= -1 then
					itemtext = menuitems[selecteditem] .. ' (' .. LayoutSettings.menus[Buttons[i].model].accuracy[selecteditem] .. '% acc.)'
					gui.drawRectangle(Buttons[i].box_first[1] + Buttons[i].box_first[3], Buttons[i].box_first[2] + (selecteditem-1) * Buttons[i].box_first[4], Buttons[i].box_first[4], Buttons[i].box_first[4], Constants.Graphics.SELECTEDCOLOR[1], Constants.Graphics.SELECTEDCOLOR[2])
					gui.drawRectangle(Buttons[i].box_first[1] + Buttons[i].box_first[3] + Buttons[i].box_first[4], Buttons[i].box_first[2] + (selecteditem-1) * Buttons[i].box_first[4], Buttons[i].box_first[4], Buttons[i].box_first[4], Constants.Graphics.SELECTEDCOLOR[1], Constants.Graphics.SELECTEDCOLOR[2])
					Drawing.drawText(Buttons[i].box_first[1] + Buttons[i].box_first[3] + 3, Buttons[i].box_first[2] + (selecteditem-1) * Buttons[i].box_first[4] + (Buttons[i].box_first[4] - 12) / 2 + 1, '-', Constants.Graphics.SELECTEDCOLOR[1])
					Drawing.drawText(Buttons[i].box_first[1] + Buttons[i].box_first[3] + Buttons[i].box_first[4] + 3, Buttons[i].box_first[2] + (selecteditem-1) * Buttons[i].box_first[4] + (Buttons[i].box_first[4] - 12) / 2 + 1, '+', Constants.Graphics.SELECTEDCOLOR[1])
				end
				Drawing.drawText(Buttons[i].box_first[1] + 2, Buttons[i].box_first[2] + (selecteditem-1) * Buttons[i].box_first[4] + (Buttons[i].box_first[4] - 12) / 2 + 1, itemtext, Constants.Graphics.SELECTEDCOLOR[1])
			elseif Buttons[i].type == ButtonType.pokemonteamMenu then
				local team = Program.trainerPokemonTeam
				local isEnemy = false
				if Buttons[i].team == 2 then
					team = Program.enemyPokemonTeam
					isEnemy = true
				end
				gui.drawText(Buttons[i].position[1] + 4, Buttons[i].position[2] - 13, Buttons[i].text, 'cyan', nil, 10, 'Arial')
				for j = 1,6,1 do
					Drawing.drawPokemonIcon(team[j]['pkmID'], Buttons[i].position[1] + (j-1) * 39, Buttons[i].position[2], LayoutSettings.pokemonIndex.player == Buttons[i].team and LayoutSettings.pokemonIndex.slot == j, team[j]['isShiny'])
					if team[j]['pkmID'] > 0 and team[j]['pkmID'] < 1238 then
						local colorbar = 'white'
						local status = team[j]['status']
						if team[j]['curHP'] / team[j]['maxHP'] <= 0.2 then
							colorbar = 'red'
						elseif team[j]['curHP'] / team[j]['maxHP'] <= 0.2 then
							colorbar = 'yellow'
						end
						if team[j]['curHP'] == 0 then
							status = "Fainted"
						end
						Drawing.drawStatusIcon(status, Buttons[i].position[1] + (j-1) * 39 + 1, Buttons[i].position[2] + 1)
						Drawing.drawText(Buttons[i].position[1] + (j-1) * 39, Buttons[i].position[2] + 36, "Lv. " .. team[j]['level'])
						if team[j]['curHP'] > 0 then
							if isEnemy and Battle.isWildEncounter then
								Drawing.drawText(Buttons[i].position[1] + (j-1) * 39 - 1, Buttons[i].position[2] + 46, "?" .. "/" .. "?", colorbar)
							elseif isEnemy then
								Drawing.drawText(Buttons[i].position[1] + (j-1) * 39 - 1, Buttons[i].position[2] + 46,"?" .. "/" .. team[j]['maxHP'], colorbar)
							else
								Drawing.drawText(Buttons[i].position[1] + (j-1) * 39 - 1, Buttons[i].position[2] + 46, team[j]['curHP'] .. "/" .. team[j]['maxHP'], colorbar)
							end
						end
					end
				end
			end
		end
	end
end


