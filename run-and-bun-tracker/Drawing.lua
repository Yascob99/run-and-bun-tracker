Drawing = {}

function Drawing.drawLayout()
	gui.drawRectangle(
		GraphicConstants.SCREEN_WIDTH,
		0,
		GraphicConstants.RIGHT_GAP - 1,
		GraphicConstants.UP_GAP +  GraphicConstants.DOWN_GAP + GraphicConstants.SCREEN_HEIGHT - 1,
		GameSettings.gamecolor,
		0x00000000
	)
	gui.drawRectangle(
		0,
		GraphicConstants.SCREEN_HEIGHT + GraphicConstants.UP_GAP,
		GraphicConstants.SCREEN_WIDTH,
		GraphicConstants.DOWN_GAP - 1,
		GameSettings.gamecolor,
		0x00000000
	)
	gui.drawRectangle(
		0,
		0,
		GraphicConstants.SCREEN_WIDTH,
		GraphicConstants.UP_GAP,
		GameSettings.gamecolor,
		GameSettings.gamecolor - 0x80000000
	)
end

function Drawing.drawPokemonIcon(id, x, y, selectedPokemon)
	if selectedPokemon then
		gui.drawRectangle(x,y,36,36, GraphicConstants.SELECTEDCOLOR[1], GraphicConstants.SELECTEDCOLOR[2])
	else
		gui.drawRectangle(x,y,36,36, GraphicConstants.NONSELECTEDCOLOR, 0xFF222222)
	end
	if id ~= nil and id ~= 0 and GameSettings.names[id] ~= nil and type(GameSettings.names[id]) == "string" then
		local name = PokemonData.name[id]:gsub(" ", "-"):lower()
		gui.drawImage(DATA_FOLDER .. "/images/pokemon-gen8/regular/" .. name .. ".png", x- 16, y - 24)
	end
end
function Drawing.drawStatusIcon(status, x, y)
	if status ~= nil and status ~= "None" then
		status = status:gsub(" ", "-")
		gui.drawImage(DATA_FOLDER .. "/images/status/" .. status .. ".png", x, y)
	end
end

function Drawing.drawText(x, y, text, color)
	gui.drawText( x, y, text, color, null, 9, "Franklin Gothic Medium")
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
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 5, GraphicConstants.UP_GAP + GraphicConstants.SCREEN_HEIGHT + GraphicConstants.DOWN_GAP - 40, "RNG seed:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, GraphicConstants.UP_GAP + GraphicConstants.SCREEN_HEIGHT + GraphicConstants.DOWN_GAP - 40, GameSettings.rngseed .. " (" .. Utils.tohex(GameSettings.rngseed) .. ")", "yellow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 5, GraphicConstants.UP_GAP + GraphicConstants.SCREEN_HEIGHT + GraphicConstants.DOWN_GAP - 30, "RNG frame:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, GraphicConstants.UP_GAP + GraphicConstants.SCREEN_HEIGHT + GraphicConstants.DOWN_GAP - 30, Utils.getRNGDistance(GameSettings.rngseed, currng), "yellow")
end

function Drawing.drawPokemonView()
	Drawing.drawPokemonIcon(Program.selectedPokemon.pokemonID, GraphicConstants.SCREEN_WIDTH + 5, 5, Program.selectedPokemon)
	local colorbar = "white"

	if Program.selectedPokemon["hp"] / Program.selectedPokemon["maxHP"] <= 0.2 then
		colorbar = "red"
	elseif Program.selectedPokemon["hp"] / Program.selectedPokemon["maxHP"] <= 0.5 then
		colorbar = "yellow"
	end
	local name = PokemonData.name[Program.selectedPokemon["pokemonID"]] or ""
	local genderColor = 0xFFFF9C94
	if Program.selectedPokemon.gender == "Male" then
		genderColor = 0xFF42CEFF
	elseif Program.selectedPokemon.gender == "Unknown" then
		gender = "White"
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 45, 7, name, genderColor)
	if Program.selectedPokemon["status"] ~= "None"  then
		Drawing.drawStatusIcon(Program.selectedPokemon["status"], GraphicConstants.SCREEN_WIDTH + 6, 6)
	elseif Program.selectedPokemon["hp"] == 0 and Program.selectedPokemon["maxHP"] ~= 0 then
		Drawing.drawStatusIcon("Fainted", GraphicConstants.SCREEN_WIDTH + 6, 6)
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 45, 17, "HP:")
	if Program.selectedPokemon.isEnemy and Program.isWildEncounter then
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 17, "?" .. " / " .. "?", colorbar)
	elseif Program.selectedPokemon.isEnemy then
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 17, "?" .. " / " .. Program.selectedPokemon["maxHP"], colorbar)
	else
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 17, Program.selectedPokemon["hp"] .. " / " .. Program.selectedPokemon["maxHP"], colorbar)
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 45, 27, "Level: " .. Program.selectedPokemon["level"])
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 5, 43, "Item:")
	if Program.selectedPokemon.isEnemy and Program.isWildEncounter then
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 42, 43, "???", "yellow")
	else
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 42, 43, PokemonData.item[Program.selectedPokemon["heldItem"]], "yellow")
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 5, 53, "Abilty:")
	if Program.selectedPokemon.isEnemy and Program.isWildEncounter then
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 42, 53, "???", "yellow")
	else	
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 42, 53, Program.getAbility(Program.selectedPokemon), "yellow")
	end	
	local tid = Utils.getbits(Program.selectedPokemon["otId"], 0, 16)
	local sid = Utils.getbits(Program.selectedPokemon["otId"], 16, 16)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 5, 63, "OT ID:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 42, 63, tid, "yellow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 75, 63, "OT SID:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 112, 63, sid, "yellow")
	
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 75, GraphicConstants.RIGHT_GAP - 11, 85,0xFFAAAAAA, 0xFF222222)
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 80, "Stat", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 80, "IV", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 80, "EV", "white")
	
	
	
	if Program.selectedPokemon.isEnemy and Program.isWildEncounter then
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 95, "HP", Utils.getNatureColor("hp", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 105, "Attack", Utils.getNatureColor("atk", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 115, "Defense", Utils.getNatureColor("def", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 125, "Sp. Atk", Utils.getNatureColor("spa", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 135, "Sp. Def", Utils.getNatureColor("spd", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 145, "Speed", Utils.getNatureColor("spe", "white")

		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 95, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 105, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 115, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 125, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 135, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 145, "?", "white")
		
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 95, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 105, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 115, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 125, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 135, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 145, "?", "white")
		
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 95, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 105, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 115, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 125, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 135, "?", "white")
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 145, "?", "white")
	else
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 95, "HP", Utils.getNatureColor("hp", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 105, "Attack", Utils.getNatureColor("atk", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 115, "Defense", Utils.getNatureColor("def", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 125, "Sp. Atk", Utils.getNatureColor("spa", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 135, "Sp. Def", Utils.getNatureColor("spd", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 145, "Speed", Utils.getNatureColor("spe", Program.selectedPokemon["nature"]))

		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 95, Program.selectedPokemon["maxHP"], Utils.getNatureColor("hp", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 105, Program.selectedPokemon["attack"], Utils.getNatureColor("atk", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 115, Program.selectedPokemon["defense"], Utils.getNatureColor("def", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 125, Program.selectedPokemon["spAttack"], Utils.getNatureColor("spa", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 135, Program.selectedPokemon["spDefense"], Utils.getNatureColor("spd", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 145, Program.selectedPokemon["speed"], Utils.getNatureColor("spe", Program.selectedPokemon["nature"]))

		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 95, Program.selectedPokemon["hpIV"], Utils.getNatureColor("hp", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 105, Program.selectedPokemon["attackIV"], Utils.getNatureColor("atk", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 115, Program.selectedPokemon["defenseIV"], Utils.getNatureColor("def", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 125, Program.selectedPokemon["spAttackIV"], Utils.getNatureColor("spa", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 135, Program.selectedPokemon["spDefenseIV"], Utils.getNatureColor("spd", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 145, Program.selectedPokemon["speedIV"], Utils.getNatureColor("spe", Program.selectedPokemon["nature"]))
		
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 95, Program.selectedPokemon["hpEV"], Utils.getNatureColor("hp", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 105, Program.selectedPokemon["attackEV"], Utils.getNatureColor("atk", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 115, Program.selectedPokemon["defenseEV"], Utils.getNatureColor("def", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 125, Program.selectedPokemon["speedEV"], Utils.getNatureColor("spa", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 135, Program.selectedPokemon["spAttackEV"], Utils.getNatureColor("spd", Program.selectedPokemon["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 145, Program.selectedPokemon["spDefenseEV"], Utils.getNatureColor("spe", Program.selectedPokemon["nature"]))
	end
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 15, 162, "Nature:")
	if Program.selectedPokemon.isEnemy and Program.isWildEncounter then
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 80, 162, "???", "yellow")
	else
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 80, 162, PokemonData.nature[Program.selectedPokemon["nature"] + 1], "yellow")
	end
	local hptype = Program.getHiddenPower(Program.selectedPokemon)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 15, 172, "Hidden Power:")
	if Program.selectedPokemon.isEnemy and Program.isWildEncounter then
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 80, 172, "???", PokemonData.typeColor[hptype])
	else
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 80, 172, PokemonData.type[hptype], PokemonData.typeColor[hptype])
	end
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 185, GraphicConstants.RIGHT_GAP - 11, 65,0xFFAAAAAA, 0xFF222222)
	if Program.selectedPokemon.moves[1] then
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 205, PokemonData.move[Program.selectedPokemon.moves[1] + 1])
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 215, PokemonData.move[Program.selectedPokemon.moves[2] + 1])
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 225, PokemonData.move[Program.selectedPokemon.moves[3] + 1])
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 235, PokemonData.move[Program.selectedPokemon.moves[4] + 1])
	end
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 190, "PP")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 205, Program.selectedPokemon.pp[1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 215, Program.selectedPokemon.pp[2])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 225, Program.selectedPokemon.pp[3])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 90, 235, Program.selectedPokemon.pp[4])
end

function Drawing.drawMap()
	gui.drawImage(DATA_FOLDER .. "/images/map/" .. Map.file .. ".png", 1, GraphicConstants.UP_GAP + GraphicConstants.SCREEN_HEIGHT + 17, GraphicConstants.SCREEN_WIDTH - 1, 167)
	local position = {-7, GraphicConstants.UP_GAP + GraphicConstants.SCREEN_HEIGHT}
	local tilesize = 8
	local coords = Map.findCoords(Memory.readbyte(GameSettings.mapid))
	if roameravailable == 1 and roamermapid > 0 then
		local roamerid = Memory.readword(roameraddr + 8)
		local roamercoords = Map.findCoords(roamermapid)
		gui.drawImage(DATA_FOLDER .. "/images/pokemon/" .. roamerid .. ".gif", position[1] + (roamercoords[1] - 1)*8 - 8, position[2] + (roamercoords[2] - 1)*8 - 12, 32, 32)
	end
	
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
		gui.drawImage(DATA_FOLDER .. "/images/player/" .. gender .. ".png", position[1] + (coords[1] - 1)*8, position[2] + (coords[2] - 1)*8, 16, 16)
	end
	gui.drawText(
		2,
		GraphicConstants.UP_GAP + GraphicConstants.SCREEN_HEIGHT + 19,
		PokemonData.map[Memory.readbyte(GameSettings.mapid) + 1],
		"white",
		0x00000000,
		9,
		"Lucida Console"
	)
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
					gui.drawRectangle((j-1) * itemwidth + Buttons[i].box[1], Buttons[i].box[2], itemwidth, Buttons[i].box[4], GraphicConstants.NONSELECTEDCOLOR)
					Drawing.drawText((j-1) * itemwidth + Buttons[i].box[1] + 2, Buttons[i].box[2] + (Buttons[i].box[4] - 12) / 2 + 1, menuitems[j], GraphicConstants.NONSELECTEDCOLOR)
				end
				gui.drawRectangle((selecteditem-1) * itemwidth + Buttons[i].box[1], Buttons[i].box[2], itemwidth, Buttons[i].box[4], GraphicConstants.SELECTEDCOLOR[1], GraphicConstants.SELECTEDCOLOR[2])
				Drawing.drawText((selecteditem-1) * itemwidth + Buttons[i].box[1] + 2, Buttons[i].box[2] + (Buttons[i].box[4] - 12) / 2 + 1, menuitems[selecteditem], GraphicConstants.SELECTEDCOLOR[1])
			elseif Buttons[i].type == ButtonType.horizontalMenuBar then
				local selecteditem = LayoutSettings.menus[Buttons[i].model].selecteditem
				local menuitems = LayoutSettings.menus[Buttons[i].model].items
				local itemcount = #menuitems
				local itemwidth = (Buttons[i].box[3] - (Buttons[i].box[4] * 2)) / Buttons[i].visibleitems
				gui.drawRectangle(Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[4], Buttons[i].box[4], GraphicConstants.NONSELECTEDCOLOR)
				if Buttons[i].firstvisible > 1 then
					Drawing.drawTriangleLeft(Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[4], GraphicConstants.NONSELECTEDCOLOR)
				end
				gui.drawRectangle(Buttons[i].box[1] + Buttons[i].box[3] - Buttons[i].box[4], Buttons[i].box[2], Buttons[i].box[4], Buttons[i].box[4], GraphicConstants.NONSELECTEDCOLOR)
				if Buttons[i].firstvisible < itemcount - Buttons[i].visibleitems + 1 then
					Drawing.drawTriangleRight(Buttons[i].box[1] + Buttons[i].box[3] - Buttons[i].box[4], Buttons[i].box[2], Buttons[i].box[4], GraphicConstants.NONSELECTEDCOLOR)
				end
				for j = Buttons[i].firstvisible, Buttons[i].firstvisible + Buttons[i].visibleitems - 1, 1 do
					gui.drawRectangle((j-Buttons[i].firstvisible) * itemwidth + Buttons[i].box[1] + Buttons[i].box[4], Buttons[i].box[2], itemwidth, Buttons[i].box[4], GraphicConstants.NONSELECTEDCOLOR)
					Drawing.drawText((j-Buttons[i].firstvisible) * itemwidth + Buttons[i].box[1] + Buttons[i].box[4] + 2, Buttons[i].box[2] + (Buttons[i].box[4] - 12) / 2 + 1, menuitems[j], GraphicConstants.NONSELECTEDCOLOR)
				end
				local selecteditemposition = selecteditem - Buttons[i].firstvisible
				if selecteditemposition >= 0 and selecteditemposition < Buttons[i].visibleitems then 
					gui.drawRectangle(selecteditemposition * itemwidth + Buttons[i].box[1] + Buttons[i].box[4], Buttons[i].box[2], itemwidth, Buttons[i].box[4], GraphicConstants.SELECTEDCOLOR[1], GraphicConstants.SELECTEDCOLOR[2])
					Drawing.drawText(selecteditemposition * itemwidth + Buttons[i].box[1] + Buttons[i].box[4] + 2, Buttons[i].box[2] + (Buttons[i].box[4] - 12) / 2 + 1, menuitems[selecteditem], GraphicConstants.SELECTEDCOLOR[1])
				end
			elseif Buttons[i].type == ButtonType.verticalMenu then
				local selecteditem = LayoutSettings.menus[Buttons[i].model].selecteditem
				local menuitems = LayoutSettings.menus[Buttons[i].model].items
				local itemcount = #menuitems
				for j = 1, itemcount, 1 do
					gui.drawRectangle(Buttons[i].box_first[1], Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4], Buttons[i].box_first[3], Buttons[i].box_first[4], GraphicConstants.NONSELECTEDCOLOR)
					local itemtext = menuitems[j]
					if LayoutSettings.menus[Buttons[i].model].accuracy and LayoutSettings.menus[Buttons[i].model].accuracy[j] ~= -1 then
						itemtext = menuitems[j] .. ' (' .. LayoutSettings.menus[Buttons[i].model].accuracy[j] .. '% acc.)'
						gui.drawRectangle(Buttons[i].box_first[1] + Buttons[i].box_first[3], Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4], Buttons[i].box_first[4], Buttons[i].box_first[4], GraphicConstants.NONSELECTEDCOLOR)
						gui.drawRectangle(Buttons[i].box_first[1] + Buttons[i].box_first[3] + Buttons[i].box_first[4], Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4], Buttons[i].box_first[4], Buttons[i].box_first[4], GraphicConstants.NONSELECTEDCOLOR)
						Drawing.drawText(Buttons[i].box_first[1] + Buttons[i].box_first[3] + 3, Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4] + (Buttons[i].box_first[4] - 12) / 2 + 1, '-', GraphicConstants.NONSELECTEDCOLOR)
						Drawing.drawText(Buttons[i].box_first[1] + Buttons[i].box_first[3] + Buttons[i].box_first[4] + 3, Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4] + (Buttons[i].box_first[4] - 12) / 2 + 1, '+', GraphicConstants.NONSELECTEDCOLOR)
					end
					Drawing.drawText(Buttons[i].box_first[1] + 2, Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4] + (Buttons[i].box_first[4] - 12) / 2 + 1, itemtext, GraphicConstants.NONSELECTEDCOLOR)
				end
				gui.drawRectangle(Buttons[i].box_first[1], Buttons[i].box_first[2] + (selecteditem-1) * Buttons[i].box_first[4], Buttons[i].box_first[3], Buttons[i].box_first[4], GraphicConstants.SELECTEDCOLOR[1], GraphicConstants.SELECTEDCOLOR[2])
				local itemtext = menuitems[selecteditem]
				if LayoutSettings.menus[Buttons[i].model].accuracy and LayoutSettings.menus[Buttons[i].model].accuracy[selecteditem] ~= -1 then
					itemtext = menuitems[selecteditem] .. ' (' .. LayoutSettings.menus[Buttons[i].model].accuracy[selecteditem] .. '% acc.)'
					gui.drawRectangle(Buttons[i].box_first[1] + Buttons[i].box_first[3], Buttons[i].box_first[2] + (selecteditem-1) * Buttons[i].box_first[4], Buttons[i].box_first[4], Buttons[i].box_first[4], GraphicConstants.SELECTEDCOLOR[1], GraphicConstants.SELECTEDCOLOR[2])
					gui.drawRectangle(Buttons[i].box_first[1] + Buttons[i].box_first[3] + Buttons[i].box_first[4], Buttons[i].box_first[2] + (selecteditem-1) * Buttons[i].box_first[4], Buttons[i].box_first[4], Buttons[i].box_first[4], GraphicConstants.SELECTEDCOLOR[1], GraphicConstants.SELECTEDCOLOR[2])
					Drawing.drawText(Buttons[i].box_first[1] + Buttons[i].box_first[3] + 3, Buttons[i].box_first[2] + (selecteditem-1) * Buttons[i].box_first[4] + (Buttons[i].box_first[4] - 12) / 2 + 1, '-', GraphicConstants.SELECTEDCOLOR[1])
					Drawing.drawText(Buttons[i].box_first[1] + Buttons[i].box_first[3] + Buttons[i].box_first[4] + 3, Buttons[i].box_first[2] + (selecteditem-1) * Buttons[i].box_first[4] + (Buttons[i].box_first[4] - 12) / 2 + 1, '+', GraphicConstants.SELECTEDCOLOR[1])
				end
				Drawing.drawText(Buttons[i].box_first[1] + 2, Buttons[i].box_first[2] + (selecteditem-1) * Buttons[i].box_first[4] + (Buttons[i].box_first[4] - 12) / 2 + 1, itemtext, GraphicConstants.SELECTEDCOLOR[1])
			elseif Buttons[i].type == ButtonType.pokemonteamMenu then
				local team = Program.trainerPokemonTeam
				local isEnemy = false
				if Buttons[i].team == 2 then
					team = Program.enemyPokemonTeam
					isEnemy = true
				end
				gui.drawText(Buttons[i].position[1] + 4, Buttons[i].position[2] - 13, Buttons[i].text, 'cyan', null, 10, 'Arial')
				for j = 1,6,1 do
					Drawing.drawPokemonIcon(team[j]['pkmID'], Buttons[i].position[1] + (j-1) * 39, Buttons[i].position[2], LayoutSettings.pokemonIndex.player == Buttons[i].team and LayoutSettings.pokemonIndex.slot == j)
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
							if isEnemy and Program.isWildEncounter then
								Drawing.drawText(Buttons[i].position[1] + (j-1) * 39 - 1, Buttons[i].position[2] + 46, "?" .. "/" .. "?", colorbar)
							elseif isEnemy then
								Drawing.drawText(Buttons[i].position[1] + (j-1) * 39 - 1, Buttons[i].position[2] + 46,"?" .. "/" .. team[j]['maxHP'], colorbar)
							else
								Drawing.drawText(Buttons[i].position[1] + (j-1) * 39 - 1, Buttons[i].position[2] + 46, team[j]['curHP'] .. "/" .. team[j]['maxHP'], colorbar)
							end
						end
					end
				end
			elseif Buttons[i].type == ButtonType.encounterSlots then
				local encountermode = LayoutSettings.menus[Buttons[i].model].selecteditem
				if Program.map.encounters[encountermode].encrate > 0 then
					for j = 1, Program.map.encounters[encountermode].SLOTS, 1 do
						local levelstr = Program.map.encounters[encountermode].pokemon[j].minlevel
						if Program.map.encounters[encountermode].pokemon[j].minlevel ~= Program.map.encounters[encountermode].pokemon[j].maxlevel then
							levelstr = levelstr .. '-' .. Program.map.encounters[encountermode].pokemon[j].maxlevel
						end
						if LayoutSettings.selectedslot[j] then
							gui.drawRectangle(Buttons[i].box_first[1], Buttons[i].box_first[2] + j * (Buttons[i].box_first[4] + 2), Buttons[i].box_first[4], Buttons[i].box_first[4], 'white', GraphicConstants.SLOTCOLORS[j])
							Drawing.drawText(Buttons[i].box_first[1] + 10, Buttons[i].box_first[2] - 2 + j * (Buttons[i].box_first[4] + 2), "Slot " .. j .. " (" .. Program.map.encounters[encountermode].RATES[j] .. "%):")
							Drawing.drawText(Buttons[i].box_first[1] + 61, Buttons[i].box_first[2] - 2 + j * (Buttons[i].box_first[4] + 2), PokemonData.name[Program.map.encounters[encountermode].pokemon[j].id + 1] .. " Lv. " .. levelstr)
						else
							gui.drawRectangle(Buttons[i].box_first[1], Buttons[i].box_first[2] + j * (Buttons[i].box_first[4] + 2), Buttons[i].box_first[4], Buttons[i].box_first[4], 'gray', GraphicConstants.SLOTCOLORS[j])
							Drawing.drawText(Buttons[i].box_first[1] + 10, Buttons[i].box_first[2] - 2 + j * (Buttons[i].box_first[4] + 2), "Slot " .. j .. " (" .. Program.map.encounters[encountermode].RATES[j] .. "%):", "gray")
							Drawing.drawText(Buttons[i].box_first[1] + 61, Buttons[i].box_first[2] - 2 + j * (Buttons[i].box_first[4] + 2), PokemonData.name[Program.map.encounters[encountermode].pokemon[j].id + 1] .. " Lv. " .. levelstr, "gray")
						end
					end
				else
					Drawing.drawText(Buttons[i].box_first[1] + 10, Buttons[i].box_first[2] + 7, 'No encounters')
				end
			elseif Buttons[i].type == ButtonType.pickupData then
				local pickupitem = PickupData[GameSettings.version].item
				local pickuprarity = PickupData[GameSettings.version].rarity
				if GameSettings.version == GameSettings.VERSIONS.E then
					pickupitem = pickupitem[LayoutSettings.menus.pickuplevel.selecteditem]
				end
				for j = 1, #pickupitem, 1 do
					if LayoutSettings.selectedslot[j] then
						gui.drawRectangle(Buttons[i].box_first[1], Buttons[i].box_first[2] + j * (Buttons[i].box_first[4] + 2), Buttons[i].box_first[4], Buttons[i].box_first[4], 'white', GraphicConstants.SLOTCOLORS[j])
						Drawing.drawText(Buttons[i].box_first[1] + 10, Buttons[i].box_first[2] - 2 + j * (Buttons[i].box_first[4] + 2), "(" .. pickuprarity[j] .. "%):")
						Drawing.drawText(Buttons[i].box_first[1] + 40, Buttons[i].box_first[2] - 2 + j * (Buttons[i].box_first[4] + 2), PokemonData.item[pickupitem[j] + 1])
					else
						gui.drawRectangle(Buttons[i].box_first[1], Buttons[i].box_first[2] + j * (Buttons[i].box_first[4] + 2), Buttons[i].box_first[4], Buttons[i].box_first[4], 'gray', GraphicConstants.SLOTCOLORS[j])
						Drawing.drawText(Buttons[i].box_first[1] + 10, Buttons[i].box_first[2] - 2 + j * (Buttons[i].box_first[4] + 2), "(" .. pickuprarity[j] .. "%):", 'gray')
						Drawing.drawText(Buttons[i].box_first[1] + 40, Buttons[i].box_first[2] - 2 + j * (Buttons[i].box_first[4] + 2), PokemonData.item[pickupitem[j] + 1], 'gray')
					end
				end
			elseif Buttons[i].type == ButtonType.catchData then
				local enabled = Buttons[i].enabled()
				local data = Buttons[i].data()
				for j = 1, #Buttons[i].text, 1 do
					local itemcolor = GraphicConstants.NONSELECTEDCOLOR
					if enabled[j] then
						itemcolor = 'white'
					end
					gui.drawRectangle(Buttons[i].box_first[1], Buttons[i].box_first[2] + j * Buttons[i].box_first[4], Buttons[i].box_first[3], Buttons[i].box_first[4], GraphicConstants.NONSELECTEDCOLOR)
					Drawing.drawText(Buttons[i].box_first[1] + 2 - 50, Buttons[i].box_first[2] + j * Buttons[i].box_first[4] + 1, Buttons[i].text[j], GraphicConstants.NONSELECTEDCOLOR)
					Drawing.drawText(Buttons[i].box_first[1] + 2, Buttons[i].box_first[2] + j * Buttons[i].box_first[4] + 1, data[j], itemcolor)
				end
			end
		end
	end
end


