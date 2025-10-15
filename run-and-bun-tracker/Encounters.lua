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
Encounters.routeEncounters.Keys = {'land', 'surf', 'rock', 'fish', 'other'}
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
Encounters.routeEncounters.other = { -- Hardcoded due to no easy way to get this data.
    ['Keys'] = {
        185,
        35, 
        5, 
        36,
        144,
        7
},
    ['lengths'] = {
        [185] = 2,
        [35] = 1,
        [5] = 1,
        [36] = 1,
        [144] = 1,
        [7] = 1
},
    [185] = { -- New Mauville static encounters
        ["Voltorb-Hisui"] = {
            ['rate'] = 50,
            ['highlevel'] = 40,
            ['lowlevel'] = 40
        },
        ["Electrode-Hisui"] = {
            ['rate'] = 50,
            ['highlevel'] = 50,
            ['lowlevel'] = 50
        },
    },
    [35] = { -- Route 119 gift castform
        ["Castform"] = {
            ['rate'] = 100,
            ['lowlevel'] = 25,
            ['highlevel'] = 25
        }
    },
    [5] = { -- Fortree city static kecleon
        ["Kecleon"] = {
            ['rate'] = 100,
            ['lowlevel'] = 55,
            ['highlevel'] = 55
        }
    },
    [36] = { -- Route 120 static kecleon
        ["Kecleon"] = {
            ['rate'] = 100,
            ['lowlevel'] = 55,
            ['highlevel'] = 55
        }
    },
    [144] = { -- Aqua Hideout B1F static Electrode-H
        ["Electrode-Hisui"] = {
            ['rate'] = 100,
            ['highlevel'] = 75,
            ['lowlevel'] = 75
        }
    },
    [7] = { -- Gift Mossdeep Kubfu
        ["Kubfu"] = {
            ['rate'] = 100,
            ['highlevel'] = 5,
            ['lowlevel'] = 5
        }
    },   
}
-- Game Corner is too much data to handle cleanly with the current display. Will look to improve.
Encounters.routeEncounters.gamecorner = {
    {"Smoochum", "Elekid", "Magby"},
    {"Tauros", "Miltank"},
    {"Throh", "Sawk"},
    {"Pinsir", "Heracross"},
    {"Larvitar", "Beldum"},
    {"Dratini", "Bagon", "Deino"},
    {"Gible", "Goomy", "Jangmo-o", "Dreepy"},
    {"Mew", "Celebi", "Jirachi", "Victini"}
}

-- For a later updated Encounters view
Encounters.routeEncounters.sublocations ={
    ["Granite Cave"] = {
        {132, "Granite Cave 1F"},
        {133, "Granite Cave B1F"},
        {134, "Granite Cave B2F"},
        {288, "Granite Cave Steven"}
    },
    ["Mirage Tower"] = {
        {381,"Mirage Tower 1F"},
        {382,"Mirage Tower 2F"},
        {383,"Mirage Tower 3F"},
        {388,"Mirage Tower 4F"},
    },
    ["Meteor Falls"] = {
        {125, "Meteor Falls 1F 1R"},
        {126, "Meteor Falls 1F 2R"},
        {127, "Meteor Falls B1F 1R"},
        {431, "Meteor Falls Steven"}
    },
    ["New Mauville"] = {
        {184, "New Mauville 1"},
        {184, "New Mauville 2"}
    },
    ["Safari Zone"] = {
        {238, "Safari Zone NW"},
        {239, "Safari Zone NE"},
        {240, "Safari Zone SW"},
        {241, "Safari Zone SE"}
    },
    ["Mt. Pyre"] = {
        {137, "Mt. Pyre 1F"},
        {138, "Mt. Pyre 2F"},
        {139, "Mt. Pyre 3F"},
        {140, "Mt. Pyre 4F"},
        {141, "Mt. Pyre 5F"},
        {142, "Mt. Pyre 6F"},
        {302, "Mt. Pyre Ext."},
        {303, "Mt. Pyre Summit"}
    },
    ["Magma Hideout"] = { -- Needs verifying
        {336, "Magma Hideout 1R"},
        {337, "Magma Hideout 2R"},
        {338, "Magma Hideout 3R"},
        {339, "Magma Hideout 4R"},
        {340, "Magma Hideout 5R"},
        {341, "Magma Hideout 6R"},
        {379, "Magma Hideout 7R"},
        {380, "Magma Hideout 8R"},
    },
    ["Shoal Cave"] = {
        {164, "Shoal Cave Lo-1"},
        {165, "Shoal Cave Lo-2"},
        {166, "Shoal Cave Lo-3"},
        {167, "Shoal Cave Lo-4"},
        {168, "Shoal Cave Hi-1"},
        {169, "Shoal Cave Hi-2"}
    },
    ["Seafloor Cavern"] = {
        {147, "Seafloor Cavern Entrance"},
        {148, "Seafloor Cavern 1"},
        {149, "Seafloor Cavern 2"},
        {150, "Seafloor Cavern 3"},
        {151, "Seafloor Cavern 4"},
        {152, "Seafloor Cavern 5"},
        {153, "Seafloor Cavern 6"},
        {154, "Seafloor Cavern 7"},
        {155, "Seafloor Cavern 8"},
    },
    ["Cave of Origin"] = {
        {157, "Cave of Origin Entrance"},
        {158, "Cave of Origin 1F"}
    },
    ["Sky Pillar"] = {
        {322, "Sky Pillar 1F"},
        {324, "Sky Pillar 3F"},
        {330, "Sky Pillar 5F"},
    },
    ["Victory Road"] = {
        {163, "Victory Road 1F"},
        {285, "Victory Road B1F"},
        {286, "Victory Road B2F"}
    },
    ["Game Corner"] = {
        "Knuckle Badge",
        "Stone Badge",
        "Dynamo Badge",
        "Balance Badge",
        "Heat Badge",
        "Feather Badge",
        "Mind Badge",
        "Rain Badge"
    }
}



--- Updates the encounter tracker with any existing caught pokemon. This doesn't work for missed encounters
function Encounters.findPreviousEncounters()
    local partyAddress = GameSettings.pstats
    local boxAddress = GameSettings.gPokemonStorage + 4
    local mon = nil;
    local id = 0
    local starters = {387, 390, 393}
    local location = ""
    -- Party
    if Encounters.encounters == nil then
        Encounters.encounters = {}
    end
    for i = 1, Memory.readword(GameSettings.gPlayerPartyCount) do
        mon = Program.trainerPokemonTeam[i]
        if mon ~= nil then
            id = mon.id
        end
        if (id ~=0) then
            mon = Program.readPartyMon(partyAddress)
            location = Encounters.getSanitizedLocation(mon.metLocation)
            if location == "Starter" then
                local starter = starters[Program.getStarterChoice()] or nil
                if starter ~= nil then
                    Encounters.tryAddEncounter("Starter",starters[Program.getStarterChoice()])
                end
            else
                Encounters.tryAddEncounter(location, id)
            end
		end
	end
    local i = 0
    -- Boxes
    while i<420 do
        id = Program.getMonID(boxAddress)
		if (id ~=0) then 
			mon = Program.readBoxMon(boxAddress)
            location = Encounters.getSanitizedLocation(mon.metLocation)
             if location == "Starter" then
                local starter = starters[Program.getStarterChoice()] or nil
                if starter ~= nil then
                    Encounters.tryAddEncounter("Starter",starters[Program.getStarterChoice()])
                end
            else
                Encounters.tryAddEncounter(location, id)
            end
		end
		i = i+1
		boxAddress = boxAddress + 80
	end
end

--- Checks if the encounter is available for this location based on the location provided
--- @param location string The name of the region for this encounter.
--- @returns boolean isEncounterAvailable 
function Encounters.isEncounterAvailable(location)
    if Encounters.doesMapHaveEncounters(location) and Battle.hasFoughtRival then
        if Encounters.encounters ~= nil then
            if #Encounters.encounters == 1 then
                return true
            elseif Encounters.encounters[location] == nil then
                return true
            end
        end
        return true
    end
    return false
end

--- Writes the current encounter list to file
function Encounters.updateEncounterTracker(force)
    force = force or Battle.hasFoughtRival
    -- Don't write anything until 
    if force then
        FileManager.writeTableToFile(Encounters.encounters, FileManager.Files.ENCOUNTER_LOG)
        -- writes to a CSV file as well for easier tracking in the order that routes are accessible.
        local encounters = Encounters.encounters or {}
        -- Remove the pool element as it will cause issues.
        if encounters['pool'] ~= nil then
            encounters['pool'] = nil
        end
        FileManager.writeTabletoCSV(encounters, FileManager.Files.ENCOUNTER_CSV, PokemonData.encounterRoutes)
    end
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

-- checks if a map has encounters
function Encounters.doesMapHaveEncounters(location)
    if location ~= nil then
        return Utils.isInTable(PokemonData.encounterRoutes, location)
    end
    return false
end

-- Tries to add an encounter to encounter tracker
function Encounters.tryAddEncounter(location, id, missed, beatRival)
    missed = missed or false
    beatRival = beatRival or Battle.hasFoughtRival
    local inPool = Encounters.isInPool(id)
    if Encounters.isEncounterAvailable(Battle.location) and not inPool then
        local name = GameSettings.names[id]
        if missed then
            if Encounters.encounters == nil then
                Encounters.encounters = {}  
            end
            name = name .. "-Missed"
            Encounters.encounters[location] = name
        else
            if Encounters.encounters == nil then
                Encounters.encounters = {}  
                Encounters.encounters['pool'] = GameSettings.evolutionPool[id]
            end
            Encounters.encounters[location] = name
        end
    end
end

function Encounters.isInPool(id)
    if Encounters.encounters ~= nil then
        if Encounters.encounters['pool'] ~= nil then
            return Utils.isInTable(Encounters.encounters['pool'], id)
        end
    end
    return false
end