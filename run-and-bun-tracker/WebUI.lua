WebUI = {
    isStarted = false
}

function WebUI.start()
    --local webserver = io.popen(".\\run-and-bun-tracker\\webserver\\redbean-RBT.com -vv -d -L redbean.log -P redbean.pid")
    -- webserver:close()
    WebUI.isStarted = true
end

function WebUI.stop()
    if Utils.isWindows() then
        os.execute("taskkill /F /IM redbean-RBT.com") -- windows kill
    else
        os.execute("pkill -15 redbean-RBT.com") -- Should work on linux and mac
    end
end

function WebUI.updateBattle()
    if WebUI.isStarted then
        -- comm.httpPost("http://127.0.0.1:8080", Json.encode(Utils.getAttributesFromGlobal(Battle))) doesn't work without command line, looking into alternatives
    end
end