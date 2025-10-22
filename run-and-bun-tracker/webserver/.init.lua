local fm = require "fullmoon"
local json = require "Json"
Data = {
    trainerteam = json.encode({}),
    enemyteam = json.encode({}),
    battle = json.encode({}),
    program = json.encode({}),
    time_since_last_request = GetDate()
}

-- Team API
fm.setRoute(fm.POST{"/team/player", routeName="team-player-set"},
function(r)
    Data.trainerteam = r.body
    return r
end)
fm.setRoute(fm.POST{"/team/enemy", routeName="team-enemy-set"},
function(r)
    Data.enemyteam = r.body
    return r
end)
fm.setRoute(fm.GET{"/team/player", routeName="team-player-get"},
function(r)
    return Data.trainerteam
end)

fm.setRoute(fm.GET{"/team/enemy", routeName="team-enemy-get"},
function(r)
    return Data.enemyteam
end)

-- Battle API
fm.setRoute(fm.POST{"/Battle", routeName="battle-set"},
function(r)
    print(r.body)
    Data.battle = r.body
    return r.body
end)

fm.setRoute(fm.GET{"/Battle", routeName="battle-get"},
function(r)
    return Data.battle
end)

-- Program API
fm.setRoute(fm.POST{"/Program", routeName="program-set"},
function(r)
    Data.program = r.body
    return r
end)

fm.setRoute(fm.GET{"/Program", routeName="program-get"},
function(r)
    return Data.program
end)

fm.setRoute("/", function(r)
    return fm.serveAsset("index.html")
end)
--fm.setRoute("/*", "/js/*")
--fm.setRoute("/*", "/css/*")

fm.setRoute(fm.GET"/js/*", fm.serveAsset)
fm.setRoute(fm.GET"/css/*", fm.serveAsset)
LaunchBrowser()
fm.run({uniprocess = true})