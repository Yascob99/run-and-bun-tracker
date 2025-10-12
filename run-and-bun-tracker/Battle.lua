Battle = {
    isInBattle = false,
    battleOutcome = nil, -- BattleStatus [0 = In battle, 1 = Won the match, 2 = Lost the match, 4 = Fled, 7 = Caught]
    battleFlags = nil, -- Contains extra battle information, needs to be further divided based on needs.
    prevbattleFlags = nil,
    isWildEncounter = false, -- If the encounter is a wild encounter
    regionID = 0,
    mapID = 0,
    location = "",
    hasFoughtRival = false,
    Opponent1ID = nil
}

--- Updates all battle related data, and runs code relevant to battle.
function Battle.update()
	Battle.battleOutcome = Memory.readbyte(GameSettings.gBattleOutcome)
    Battle.mapID = Memory.readword(GameSettings.mapid)
    Battle.regionID = Map.regionDict[Battle.mapID]
    Battle.location = Map.names[Battle.regionID]
    local newBattleFlags = Memory.readdword(GameSettings.gBattleTypeFlags)
    if newBattleFlags ~= Battle.battleFlags then
        Battle.prevbattleFlags = Battle.battleFlags
    end
    Battle.battleFlags = newBattleFlags
    if Battle.battleOutcome == 0 and not Battle.isInBattle then -- Happens once at battle start
        Battle.battleStart()
    elseif Battle.battleOutcome == 0 then --loops while in battle
        Battle.battleLoop()
    elseif Battle.isInBattle then -- Happens once after a battle ends
        Battle.battleEnd()
    else --loops out of battle
        Program.outOfBattleLoop()
    end
end

--- Runs once after a battle has started.
function Battle.battleStart()
    Battle.isInBattle = true
	Battle.isWildEncounter = Utils.getbits(Battle.battleFlags, 3, 1) == 0
	Program.enemyPokemonTeam = Program.getTrainerData(2)
end

--- Runs once at the end of a battle
function Battle.battleEnd()
    Battle.isInBattle = false
    LayoutSettings.pokemonIndex.player = 1
    LayoutSettings.pokemonIndex.slot = 1
    -- Caught
    if Battle.battleOutcome == 7  and Battle.isWildEncounter then
        --todo add case for wally catching tutorial
        if Encounters.isEncounterAvailable(Battle.location) and Encounters.encounters[Battle.location] == nil and Battle.hasFoughtRival then
            Encounters.encounters[Battle.location] = GameSettings.names[Program.enemyPokemonTeam[1].pkmID]
            Encounters.updateEncounterTracker()
        end
    end
    -- Fled or KOed
    if Battle.battleOutcome == 4 or Battle.battleOutcome == 1 and Battle.isWildEncounter then
        -- Confirms that the mon was not from the tutorial fight
        -- todo add checks for if rival has been defeated.
        if Encounters.isEncounterAvailable(Battle.location) and Encounters.encounters[Battle.location] == nil and Battle.battleFlags ~= 20 and Battle.hasFoughtRival then
            Encounters.encounters[Battle.location] = GameSettings.names[Program.enemyPokemonTeam[1].pkmID] .. "-Missed"
            Encounters.updateEncounterTracker()
        end
    end
    if Battle.BattleOutcome == 1 and not Battle.isWildEncounter then
       Battle.Opponent1ID = Memory.readword(GameSettings.gBattleOpponentA)
       if Battle.Opponent1ID == Program.getRivalID() then
            Battle.hasFoughtRival = true
       end
    end
    Program.enemyPokemonTeam = Program.getBlankTrainerData()
end

--- Runs on loop while in Battle
function Battle.battleLoop()
    Battle.isInBattle = true -- for if the player starts the script mid-battle
	Program.enemyPokemonTeam = Program.getTrainerData(2)
end
