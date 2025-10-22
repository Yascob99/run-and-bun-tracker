Pegasus = require 'pegasus'
Router = require 'pegasus.plugins.router'
WebFiles = require 'pegasus.plugins.files'
WebUI = {
    updateCoroutine = nil,
    webUIUpadates = {},
    server = Pegasus:new({
        host = '127.0.0.1',
        port = '9090',
        location = FileManager.Folders.TrackerCode .. FileManager.slash .. "run-and-bun-tracker/webserver/",
        plugins = {
        WebFiles:new {
            location = "./",
            default = "index.html",
            },
        },
        Router:new{
            prefix = "/api/",
            routes = {
                preFunction = function(req, resp)
                    local stop = false
                    -- this gets called before any path specific callback
                    return stop
                end,
                ["/battle"] = {
                preFunction = function(req, resp)
                    local stop = false
                    return stop
                end,
                GET = function(req, resp)
                    local stop = false
                    resp:statusCode(200)
                    resp:addHeader("Content-Type", "application/json")
                    resp:write(Json.encode(Utils.getAttributesFromGlobal(Battle)))
                    return stop
                end,},
                ["/program"] = {
                    preFunction = function(req, resp)
                        local stop = false
                        return stop
                        end,
                    GET = function(req, resp)
                        local stop = false
                        if WebUI.isUpdate then
                            resp:statusCode(200)
                            resp:addHeader("Content-Type", "application/json")
                            resp:write(Json.encode(Utils.getAttributesFromGlobal(Program)))
                        else
                            resp:statusCode(204)
                        end
                        return stop
                    end,
                },
                ["/update"] = {
                    preFunction = function(req, resp)
                        local stop = false
                        return stop
                        end,
                    GET = function (req, resp)
                        local stop = false
                        resp:statusCode(200)
                        resp:addHeader("Content-Type", "application/json")
                        resp:write(WebUI.webUIUpadates:concat())
                        WebUI.webUIUpadates = {}
                        return stop
                    end
                },
            },
        },
    }),
    isStarted = false,
    isUpdate = false
}

function WebUI.start()
    Pegasus:start(
        function (request, response)
            print("WebUI Started")
        end)
end

function WebUI.stop()
    Pegasus:stop()
end