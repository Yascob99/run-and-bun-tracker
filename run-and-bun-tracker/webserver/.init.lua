local fm = require "fullmoon"

-- fm.setRoute("/", function(r)
--     return fm.serveAsset("index.html")
-- end)
HidePath('/usr/share/zoneinfo/')
HidePath('/usr/share/ssl/')

fm.setRoute(fm.GET"/js/*", fm.serveAsset)
fm.setRoute(fm.GET"/css/*", fm.serveAsset)
-- fm.setRoute(fm.GET"/{id}/Attempt.json", ServeAsset)
LaunchBrowser()
fm.run({uniprocess = true})