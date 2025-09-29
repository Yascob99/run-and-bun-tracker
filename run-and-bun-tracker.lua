-- Lua Script made by MKDasher
-- Based on MKdasher's pokemon gen 3 lua extension for bizhawk, with some extra features. Also borrows some code and ideas from Besteon's Ironmon-Tracker.
-- NOTE: On Bizhawk, go to Config / Display... Then uncheck Stretch pixels by integers only.

-- TODO
-- Pickup
-- Roaming

--

DATA_FOLDER = "run-and-bun-tracker"

-- load important modules before 
dofile (DATA_FOLDER .. "/Data.lua")
dofile (DATA_FOLDER .. "/Json.lua")
dofile (DATA_FOLDER .. "/Memory.lua")
dofile (DATA_FOLDER .. "/Utils.lua")
dofile (DATA_FOLDER .. "/GameSettings.lua")
dofile (DATA_FOLDER .. "/FileManager.lua")
dofile (DATA_FOLDER .. "/Inifile.lua")
 
-- wait for rom to be loaded before initializing the script
if GameSettings.isRomLoaded() then
	print("> Waiting for a game ROM to be loaded... (File -> Open ROM)")
	while not GameSettings.romloaded do
		if GameSettings.isRomLoaded() then
			GameSettings.romloaded = true
		end
	end
end


-- Initialize Game Settings before loading other files.
GameSettings.initialize()

dofile (DATA_FOLDER .. "/Program.lua")
dofile (DATA_FOLDER .. "/GraphicConstants.lua")
dofile (DATA_FOLDER .. "/LayoutSettings.lua")
dofile (DATA_FOLDER .. "/Forms.lua")
dofile (DATA_FOLDER .. "/Map.lua")
dofile (DATA_FOLDER .. "/Buttons.lua")
dofile (DATA_FOLDER .. "/Input.lua")
dofile (DATA_FOLDER .. "/RNG.lua")
dofile (DATA_FOLDER .. "/Exports.lua")
dofile (DATA_FOLDER .. "/Drawing.lua")
dofile (DATA_FOLDER .. "/ExternalUI.lua")

-- Main loop
if GameSettings.game == 0 then
	client.SetGameExtraPadding(0, 0, 0, 0)
	while true do
		gui.text(0, 0, "Lua error: " .. GameSettings.gamename)
		emu.frameadvance()
	end
else
	client.SetGameExtraPadding(0, GraphicConstants.UP_GAP, GraphicConstants.RIGHT_GAP, GraphicConstants.DOWN_GAP)
	gui.defaultTextBackground(0)
	while true do
		collectgarbage()
		Program.main()
		Program.advance10Frames()
	end
end