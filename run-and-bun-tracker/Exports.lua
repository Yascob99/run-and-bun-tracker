function getPartyPrint(mon)
	str = ""
	str = str .. mons[mon.species]
	if (item[mon.heldItem]) then
		str = str .. string.format(" @ %s", item[mon.heldItem])
	end
	str = str .. string.format("\n")
	str = str .. "Ability: " .. string.format("%s", getAbility(mon)) .. string.format("\n")
	str = str .. string.format("Level: %d\n", mon.level)
	str = str .. string.format("%s", getNature(mon)) .. " Nature" .. string.format("\n")
	str = str .. string.format("IVs: %d HP / %d Atk / %d Def / %d SpA / %d SpD / %d Spe", mon.hpIV, mon.attackIV, mon.defenseIV, mon.spAttackIV, mon.spDefenseIV, mon.speedIV) .. string.format("\n")
	for i=1,4 do
		local mv = move[mon.moves[i] + 1]
		if(mv == "Hidden Power") then
			str = str .. string.format("- Hidden Power %s\n", getHP(mon))
			else
			if(mv ~= "") then
				str = str .. string.format("- %s\n", mv)
			end
		end
	end
	str = str .. string.format("\n")
	return str
end

function startScript()
	console:log('To update your exports type "export()"')
	if not partyBuffer then
		partyBuffer = console:createBuffer("Showdown Export")
		partyBuffer:setSize(200,1000)
		export()
	end
end
function export()
	if not partyBuffer then
		console:log("error")
		return
	end
	printPartyStatus(partyBuffer)
end