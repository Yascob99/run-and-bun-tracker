Encounters = {}

Encounters.encounters = {}
-- Hardcoded encounter rates based on Run and Bun resources since all of these have been changed.
Encounters.encounterGroups = {
    ["land_mons"] = {20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1},
    ["surf_mons"] = {30, 30, 20, 10, 10},
    ["rock_smash_mons"] = {60, 30, 5, 4, 1},
    ["fishing_mons"] = {20, 20, 10, 10, 10, 10, 10, 5, 4, 1}
}
Encounters.routeEncounters = {}
Encounters.routeEncounters.Keys = {'land', 'surf', 'rock', 'fish'}
Encounters.routeEncounters.land = {
    ['Keys'] = {},
    ['lengths'] = {}
}
Encounters.routeEncounters.surf = {
    ['Keys'] = {},
    ['lengths'] = {}
}
Encounters.routeEncounters.rock = {
    ['Keys'] = {},
    ['lengths'] = {}
}
Encounters.routeEncounters.fish = {
    ['Keys'] = {},
    ['lengths'] = {}
}



--- Updates the encounter tracker with any existing caught pokemon. This doesn't work for missed encounters
function Encounters.findPreviousEncounters()
    local partyAddress = GameSettings.pstats
    local boxAddress = GameSettings.gPokemonStorage + 4
    local mon = nil;
    local id = 0
    -- Party
    if Encounters.encounters == nil then
        Encounters.encounters = {}
    end
    for i = 1, Memory.readword(GameSettings.gPlayerPartyCount) do
        id = Program.getMonID(partyAddress)
        -- Excludes starters due to potential route overlap.
        if id > 386 and id < 396 then
            Encounters.encounters["starter"] = GameSettings.names[id]
        elseif (id ~=0) then
            mon = Program.readPartyMon(partyAddress)
            if Encounters.encounters[Encounters.getSanitizedLocation(mon.metLocation)] ~= nil then
                Encounters.encounters[Encounters.getSanitizedLocation(mon.metLocation)] = GameSettings.names[id]
            end
		end
	end
    local i = 0
    -- Boxes
    while i<420 do
        id = Program.getMonID(boxAddress)
		if (id ~=0) then 
			mon = Program.readBoxMon(boxAddress)
            local location = Encounters.encounters[Encounters.getSanitizedLocation(mon.metLocation)]
            if location ~= nil then
                location = Encounters.getSanitizedLocation(mon.metLocation)
                Encounters.encounters[location] = GameSettings.names[id]
            end
		end
		i = i+1
		boxAddress = boxAddress + 80
	end
end

--- Checks if the encounter is available for this location based on the location provided
function Encounters.isEncounterAvailable(location)
    if Encounters.encounters == nil then
        if Memory.readword(GameSettings.gPlayerPartyCount) > 0 then
            Encounters.findPreviousEncounters()
        else
            if not Utils.isInTable(PokemonData.encounterRoutes, location) then
                return false
            end
            return true
        end
    elseif Encounters.encounters[location] ~= nil then
        return false
    else
        return true
    end
end

--- LoadsEncounters from the Encounters File (if it exists)
function Encounters.loadEncounterFile()
    local encounters = FileManager.readTableFromFile(FileManager.Files.ENCOUNTER_LOG)
    if encounters ~= nil then
        Encounters.encounters = encounters
    end
end
--- Writes the current encounter list to file
function Encounters.updateEncounterTracker()
    FileManager.writeTableToFile(Encounters.encounters, FileManager.Files.ENCOUNTER_LOG)
    -- writes to a CSV file as well for easier tracking in the order that routes are accessible.
    FileManager.writeTabletoCSV(Encounters.encounters, FileManager.Files.ENCOUNTER_CSV, PokemonData.encounterRoutes)
end

--- Clears the encounter list. (For use in starting a new run)
function Encounters.clear()
    Encounters.encounters = {}
    Encounters.updateEncounterTracker()
end

--- If the location is a variation of a location like an underwater version then change the location to match the location for the purposes of encounter tracking
function Encounters.getSanitizedLocation(locationId)
    if locationId == 255 then
        return "Starter"
    end
    local location = PokemonData.map[locationId + 1]
    local isOpen = false
    local newLoc = ""
    if location:match('[%(]') then
        for Char in location:gmatch"." do
            if isOpen and Char ~= ")" then
                newLoc = newLoc .. Char
            elseif Char == "(" then
                isOpen = true
            end
        end
        location = newLoc
    end
    return location
end

-- Gets encounters from the game files and stores them to a table.
function Encounters.getEncounterData()
    local notTerminated = true
    local addr = GameSettings.encounterTable
    local route = nil
    local grassAddress = 0x000000
    local surfAddress = 0x000000
    local rockAddress = 0x000000
    local fishAddress = 0x000000
    local rate = 0
    local data = nil
    local lowlevel = 0
    local highlevel = 0
    local monName = ""
    local length = 0
    local zoneRate = 0
    local mapbank = 0
    local mapID = nil
    while notTerminated do
        mapbank = Memory.readbyte(addr) + 1 -- read the map bank.
        mapID = Memory.readbyte(addr + 1) + 1 -- read the route number and add 1 to account for lua's indexing
        if mapbank ~= 256 and mapID ~= 256 then
            route = Map.banks[mapbank][mapID].layoutID
            -- 2 bytes of blank data
            grassAddress = Memory.readdword(addr + 4) -- 4 byte address that points to a location on rom
            data = nil
            if grassAddress ~= 0 then
                zoneRate = Memory.readbyte(grassAddress)
                length = #Encounters.encounterGroups['land_mons'] - 1
                -- Handle land zones with roamer slots
                if zoneRate == 4 then
                    length = 3
                end
                grassAddress = Memory.readdword(grassAddress + 4) -- get the address the initial address points to
                for j = 0, length, 1 do
                    lowlevel = Memory.readbyte(grassAddress + 4 * j) -- 1 byte integer representing the lowest level the mon can appear at
                    highlevel = Memory.readbyte(grassAddress + 1 + 4 * j) -- 1 byte integer representing the highest level the mon can appear at
                    monName = GameSettings.names[Memory.readword(grassAddress + 2 + 4 * j)] -- 2 byte integer representing the mon's ID
                    rate = Encounters.encounterGroups['land_mons'][j + 1]
                    if data ~= nil and monName ~= nil then
                        if data[monName] ~= nil then
                            data[monName]['rate'] = data[monName]['rate'] + rate -- if already storing mon coalate encounter rates.
                        else
                            data[monName] = {}
                            data[monName]['rate'] = rate
                        end
                        data[monName]['lowlevel'] = lowlevel
                        data[monName]['highlevel'] = highlevel
                        
                    elseif monName ~= nil then
                        data = {}
                        data[monName] = {
                                ['rate'] = rate,
                                ['lowlevel'] = lowlevel,
                                ['highlevel'] = highlevel
                            }
                    end
                end

                Encounters.routeEncounters.land['lengths'][route] = length
                Encounters.routeEncounters.land['Keys'] = route
                Encounters.routeEncounters.land[route] = data -- add the land encounters to the land table
            end
            data = nil
            surfAddress = Memory.readdword(addr + 8) -- 4 byte address that points to a location on rom
            if surfAddress ~= 0 then
                surfAddress = Memory.readdword(surfAddress + 4) -- get the address the initial address points to
                for j = 0, #Encounters.encounterGroups['surf_mons'] - 1, 1 do
                    lowlevel = Memory.readbyte(surfAddress + 4 * j) -- 2 byte integer representing the lowest level the mon can appear at
                    highlevel = Memory.readbyte(surfAddress + 1 + 4 * j) -- 2 byte integer representing the highest level the mon can appear at
                    monName = GameSettings.names[Memory.readword(surfAddress + 2 + 4 * j)] -- Unscramble the id then get the name of the mon.
                    rate = Encounters.encounterGroups['surf_mons'][j + 1]
                    if data ~= nil then
                        if data[monName] ~= nil then
                            data[monName]['rate'] = data[monName]['rate'] + rate -- if already storing mon coalate encounter rates.
                        else
                            data[monName] = {}
                            data[monName]['rate'] = rate
                        end
                        data[monName]['lowlevel'] = lowlevel
                        data[monName]['highlevel'] = highlevel
                    else
                        data = {}
                        data[monName] = {
                                ['rate'] = rate,
                                ['lowlevel'] = lowlevel,
                                ['highlevel'] = highlevel
                            }
                    end
                end
                Encounters.routeEncounters.surf[route] = data -- add the surf encounters to the surf table
                Encounters.routeEncounters.surf['lengths'][route] = #Encounters.encounterGroups['surf_mons']
                Encounters.routeEncounters.surf['keys'] = route
            end
            data = nil
            rockAddress = Memory.readdword(addr + 12) -- 4 byte address that points to a location on rom
            if rockAddress ~= 0 then
                rockAddress = Memory.readdword(rockAddress + 4) -- get the address the initial address points to
                for j = 0, #Encounters.encounterGroups['rock_smash_mons'] - 1, 1 do
                    lowlevel = Memory.readbyte(rockAddress + 4 * j) -- 2 byte integer representing the lowest level the mon can appear at
                    highlevel = Memory.readbyte(rockAddress + 1 + 4 * j) -- 2 byte integer representing the highest level the mon can appear at
                    monName = GameSettings.names[Memory.readword(rockAddress + 2 + 4 * j)] -- Unscramble the id then get the name of the mon.
                    rate = Encounters.encounterGroups['rock_smash_mons'][j + 1]
                    if data ~= nil then
                        if data[monName] ~= nil then
                            data[monName]['rate'] = data[monName]['rate'] + rate -- if already storing mon coalate encounter rates.
                        else
                            data[monName] = {}
                            data[monName]['rate'] = rate
                        end
                        data[monName]['lowlevel'] = lowlevel
                        data[monName]['highlevel'] = highlevel
                    else
                        data = {}
                        data[monName] = {
                                ['rate'] = rate,
                                ['lowlevel'] = lowlevel,
                                ['highlevel'] = highlevel
                            }
                    end
                end
                Encounters.routeEncounters.rock[route] = data -- add the rock smash encounters to the rock table
                Encounters.routeEncounters.rock['lengths'][route] = #Encounters.encounterGroups['rock_smash_mons']
                Encounters.routeEncounters.rock['Keys'] = route
            end
            data = nil
            fishAddress = Memory.readdword(addr + 16)
            if fishAddress ~= 0 then
                fishAddress = Memory.readdword(fishAddress + 4) -- get the address the initial address points to
                for j = 0, #Encounters.encounterGroups['fishing_mons'] - 1, 1 do
                    lowlevel = Memory.readbyte(fishAddress + 4 * j) -- 2 byte integer representing the lowest level the mon can appear at
                    highlevel = Memory.readbyte(fishAddress + 1 + 4 * j) -- 2 byte integer representing the highest level the mon can appear at
                    monName = GameSettings.names[Memory.readword(fishAddress + 2 + 4 * j)] -- Unscramble the id then get the name of the mon.
                    rate = Encounters.encounterGroups['fishing_mons'][j + 1]
                    if data ~= nil then
                        if data[monName] ~= nil then
                            data[monName]['rate'] = data[monName]['rate'] + rate -- if already storing mon coalate encounter rates.
                        else
                            data[monName] = {}
                            data[monName]['rate'] = rate
                        end
                        data[monName]['lowlevel'] = lowlevel
                        data[monName]['highlevel'] = highlevel
                    else
                        data = {}
                        data[monName] = {
                                ['rate'] = rate,
                                ['lowlevel'] = lowlevel,
                                ['highlevel'] = highlevel
                            }
                    end
                end
                Encounters.routeEncounters.fish[route] = data -- add the fishing encounters to the fish table
                Encounters.routeEncounters.fish['lengths'][route] = #Encounters.encounterGroups['fishing_mons']
                Encounters.routeEncounters.fish['Keys'] = route
            end
        else
            notTerminated = false
        end
        addr = addr + 20 -- each route table is 20 bytes long.
    end
end

--- Takes an address and gets the pokemon ID from the encounter list (the first byte and second byte are in reversed order)
function Encounters.getMonFromReference(address)
     return Memory.readbyte(address) | Memory.readbyte(address + 2) << 8 -- get each byte individually, then shift the second byte 3 places to the right
end

function Encounters.doesMapHaveEncounters(location)
    if location ~= nil then
        return Utils.isInTable(PokemonData.encounterRoutes, location)
    end
    return false
end