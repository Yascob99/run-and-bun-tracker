WebUI = {
    isStarted = false,
    lastSentBattle = nil,
    lastSentTrainerTeam = nil,
    lastSentEnemyTeam = nil,
}

function WebUI.checkStarted()
    if comm.socketServerIsConnected then
        WebUI.isStarted = true
    else
        WebUI.isStarted = false
    end
end

function WebUI.updateBattle()
    WebUI.checkStarted()
    if WebUI.isStarted then
        local battle = Json.encode(Utils.getAttributesFromGlobal(Battle))
        if battle ~= WebUI.lastSentBattle then
            comm.socketServerSend('{"Battle":'.. battle .. '}')
            WebUI.lastSentBattle = battle
        end
    end
end

function WebUI.updateTrainerTeam()
    WebUI.checkStarted()
    if WebUI.isStarted then
        local team = Json.encode( Program.trainerPokemonTeam)
        if team ~= WebUI.lastSentTrainerTeam then
            comm.socketServerSend('{"TrainerTeam":'.. team .. '}')
            WebUI.lastSentTrainerTeam = team
        end
    end
end

function WebUI.updateEnemyTeam()
    WebUI.checkStarted()
    if WebUI.isStarted then
        local team = Json.encode(Program.trainerPokemonTeam)
        if team ~= WebUI.lastSentEnemyTeam then
            comm.socketServerSend('{"EnemyTeam":'.. team .. '}')
            WebUI.lastSentEnemyTeam = team
        end
    end
end

function WebUI.updateEncounters()
    WebUI.checkStarted()
    if WebUI.isStarted then
        local encounters = Json.encode(Encounters.encounters)
        comm.socketServerSend('{"Encounters":'.. encounters .. '}')
        WebUI.lastSentEnemyTeam = encounters
    end
end