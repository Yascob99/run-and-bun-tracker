Input = {
	mousetab = {},
	mousetab_prev = {},
	prevJoypadInput = {},
	allowNewRunCombo = false, -- Disable button combo for 1 second to prevents accidental, consecutive triggers
	timeoutFrame = 0
	
}
Input.OrderedControllerInputs = { "A", "B",  "Select",  "Start",  "Right",  "Left",  "Up",  "Down",  "R",  "L" }

function Input.update()
	Input.mousetab = input.getmouse()
	if Input.mousetab["Left"] and not Input.mousetab_prev["Left"] then
		local xmouse = Input.mousetab["X"]
		local ymouse = Input.mousetab["Y"] + Constants.Graphics.UP_GAP
		Input.check(xmouse, ymouse)
	end
	Input.mousetab_prev = Input.mousetab
	Input.checkJoypadInput()
end

function Input.check(xmouse, ymouse)
	for i = 1, #Buttons, 1 do
		if Buttons[i].visible() then
			if Buttons[i].type == ButtonType.singleButton then
				if Input.isInRange(xmouse, ymouse, Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[3], Buttons[i].box[4]) then
					Buttons[i].onclick()
				end
			elseif Buttons[i].type == ButtonType.horizontalMenu then
				local itemcount = #LayoutSettings.menus[Buttons[i].model].items
				local itemwidth = Buttons[i].box[3] / itemcount
				for j = 1, itemcount, 1 do
					if Input.isInRange(xmouse, ymouse, (j-1) * itemwidth + Buttons[i].box[1], Buttons[i].box[2], itemwidth, Buttons[i].box[4]) then
						LayoutSettings.menus[Buttons[i].model].selecteditem = j
					end
				end
			elseif Buttons[i].type == ButtonType.horizontalMenuBar then
				local itemcount = #LayoutSettings.menus[Buttons[i].model].items
				local itemwidth = (Buttons[i].box[3] - (Buttons[i].box[4] * 2)) / Buttons[i].visibleitems
				if Input.isInRange(xmouse, ymouse, Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[4], Buttons[i].box[4]) then
					if Buttons[i].firstvisible > 1 then
						Buttons[i].firstvisible = Buttons[i].firstvisible - 1
					end
				end
				if Input.isInRange(xmouse, ymouse, Buttons[i].box[1] + Buttons[i].box[3] - Buttons[i].box[4], Buttons[i].box[2], Buttons[i].box[4], Buttons[i].box[4]) then
					if Buttons[i].firstvisible < itemcount - Buttons[i].visibleitems + 1 then
						Buttons[i].firstvisible = Buttons[i].firstvisible + 1
					end
				end
				for j = Buttons[i].firstvisible, Buttons[i].firstvisible + Buttons[i].visibleitems - 1, 1 do
					if Input.isInRange(xmouse, ymouse, (j-Buttons[i].firstvisible) * itemwidth + Buttons[i].box[1] + Buttons[i].box[4], Buttons[i].box[2], itemwidth, Buttons[i].box[4]) then
						LayoutSettings.menus[Buttons[i].model].selecteditem = j
					end
				end
			elseif Buttons[i].type == ButtonType.verticalMenu then
				local itemcount = #LayoutSettings.menus[Buttons[i].model].items
				for j = 1, itemcount, 1 do
					if Input.isInRange(xmouse, ymouse, Buttons[i].box_first[1], Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4], Buttons[i].box_first[3], Buttons[i].box_first[4]) then
						LayoutSettings.menus[Buttons[i].model].selecteditem = j
					elseif LayoutSettings.menus[Buttons[i].model].accuracy and LayoutSettings.menus[Buttons[i].model].accuracy[j] ~= -1 then
						if Input.isInRange(xmouse, ymouse, Buttons[i].box_first[1] + Buttons[i].box_first[3], Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4], Buttons[i].box_first[4], Buttons[i].box_first[4]) then
							LayoutSettings.menus[Buttons[i].model].selecteditem = j
							LayoutSettings.menus[Buttons[i].model].accuracy[j] = LayoutSettings.menus[Buttons[i].model].accuracy[j] - LayoutSettings.menus[Buttons[i].model].accuracy_step
							if LayoutSettings.menus[Buttons[i].model].accuracy[j] < 0 then
								LayoutSettings.menus[Buttons[i].model].accuracy[j] = 0
							end
						elseif Input.isInRange(xmouse, ymouse, Buttons[i].box_first[1] + Buttons[i].box_first[3] + Buttons[i].box_first[4], Buttons[i].box_first[2] + (j-1) * Buttons[i].box_first[4], Buttons[i].box_first[4], Buttons[i].box_first[4]) then
							LayoutSettings.menus[Buttons[i].model].selecteditem = j
							LayoutSettings.menus[Buttons[i].model].accuracy[j] = LayoutSettings.menus[Buttons[i].model].accuracy[j] + LayoutSettings.menus[Buttons[i].model].accuracy_step
							if LayoutSettings.menus[Buttons[i].model].accuracy[j] > 100 then
								LayoutSettings.menus[Buttons[i].model].accuracy[j] = 100
							end
						end
					end
				end
			elseif Buttons[i].type == ButtonType.pokemonteamMenu then
				for j = 1, 6, 1 do
					if Input.isInRange(xmouse, ymouse, Buttons[i].position[1] + (j-1) * 39, Buttons[i].position[2], 36, 36) and Buttons[i].selectable(j) then
						LayoutSettings.pokemonIndex.player = Buttons[i].team
						LayoutSettings.pokemonIndex.slot = j
					end
				end
			end
		end
	end	
end

function Input.isInRange(xmouse,ymouse,x,y,xregion,yregion)
	if xmouse >= x and xmouse <= x + xregion then
		if ymouse >= y and ymouse <= y + yregion then
			return true
		end
	end
	return false
end

function Input.checkJoypadInput()
	local joypad = Input.getJoypadInput()
    -- handles the Start New Run Combo
	if not Program.isNewRun and not Program.awaitingLoad and Input.allowNewRunCombo then
		local allpressed = true
		for _, button in ipairs({"A", "B", "Start"}) do
			
			if not joypad[button] then
				allpressed = false
				break -- breakout of loop if one of the buttons is currently not pressed.
			end
		end
		if allpressed then
			Input.timeoutFrame = Program.frames + 60
			Battle.update()
			if Program.isValidMapLocation() then
				Program.startNewAttempt(true)
			else
				Program.startNewAttempt()
			end
		end
	end
	Input.prevJoypadInput = joypad
	-- 1 second timeout for the new run combo to prevent it from starting new runs multiple times.
	if not Input.allowNewRunCombo and Input.timeoutFrame <= Program.frames then
		Input.allowNewRunCombo  = true
	end
end
function Input.getJoypadInput()
	return joypad.get()
end