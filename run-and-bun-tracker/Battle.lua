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
    opponent1ID = nil,
    prevLocation = nil,
    lastLocation = nil,
    starterChoice = 0
}

--- Updates all battle related data, and runs code relevant to battle.
function Battle.update()
	Battle.battleOutcome = Memory.readbyte(GameSettings.gBattleOutcome)
    Battle.mapID = Memory.readword(GameSettings.mapid)
    Battle.regionID = Map.regionDict[Battle.mapID]
    Battle.prevLocation = Battle.location
    Battle.location = Map.names[Battle.regionID]
    -- None of this needs to run until an event happens.
    if Program.isValidMapLocation() and not Program.isNewRun then
        if Battle.prevLocation ~= Battle.location then -- on moving regions
            Battle.lastLocation = Battle.prevLocation 
            if (Battle.lastLocation == "Mauville City" and Encounters.encounters["Mauville City"] == nil) or (Battle.lastLocation == "Route 119" and Encounters.encounters["Route 119"]) then -- Handle gift mons
                Encounters.findPreviousEncounters() -- No way to do this cleanly other than fully checking each mon.
                Encounters.updateEncounterTracker()
            end
            Program.Save()
        end
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
        if Battle.hasFoughtRival then
            Encounters.tryAddEncounter(Battle.location, Program.enemyPokemonTeam[1].pkmID)
            Program.Save()
        else
            console.log("An unexpected error occured. Attempting to rebuild encounters manually")
            Battle.hasFoughtRival = true -- Failsafe for if something unexpected occurs like attempt data getting corrupted.
            Encounters.findPreviousEncounters() -- Should run this once to ensure encounters is up to date
            Encounters.tryAddEncounter(Battle.location, Program.enemyPokemonTeam[1].pkmID)
            Program.Save()
        end
    end
    -- Fled or KOed
    if Battle.battleOutcome == 4 or Battle.battleOutcome == 1 and Battle.isWildEncounter then
        -- Confirms that the mon was not from the tutorial fight
        if Battle.battleFlags ~= 20 and Battle.hasFoughtRival then
            Encounters.tryAddEncounter(Battle.location, Program.enemyPokemonTeam[1].pkmID, true)
            Encounters.updateEncounterTracker()
        elseif Battle.battleFlags == 20 then
            Battle.starterChoice = Program.trainerPokemonTeam[1].pkmID
            Program.Save()
        end
    end
    if Battle.battleOutcome == 1 and not Battle.isWildEncounter then
       Battle.opponent1ID = Memory.readword(GameSettings.gBattleOpponentA)
       if  Utils.isInTable({ 520, 523, 526, 529, 532, 535 }, Battle.opponent1ID)  then
            Battle.hasFoughtRival = true
            Encounters.tryAddEncounter("Starter", Program.trainerPokemonTeam[1].pkmID)
            Program.Save()
       end
    end
    if Battle.battleOutcome == 2 and Battle.hasFoughtRival then
        -- start new run
    end
    Program.enemyPokemonTeam = Program.getBlankTrainerData()
end

--- Runs on loop while in Battle
function Battle.battleLoop()
    Battle.isInBattle = true -- for if the player starts the script mid-battle
	Program.enemyPokemonTeam = Program.getTrainerData(2)
end
