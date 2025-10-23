---@diagnostic disable: lowercase-global
-- mGBA Scripting Docs: https://mgba.io/docs/scripting.html
-- Uses Lua 5.4
MGBA = {}

MGBA.Symbols = {
	Menu = {
		Hamburger = "☰",
		ListItem = "╰",
	},
}

local function printf(str, ...)
	print(string.format(str, ...))
end

function MGBA.initialize()
	if Main.IsOnBizhawk() then return end
end

function MGBA.run()
end

function MGBA.clearConsole()
	-- This "clears" the Console for mGBA
	printf(string.rep("\n", 30))
end

function MGBA.printStartupInstructions()
	-- Lazy solution to spot it from doubling instructions if you load script before game ROM
	if MGBA.hasPrintedInstructions then
		return
	end

	printf("")
	for _, line in ipairs(Resources.MGBA.StartupInstructions or {}) do
		printf(line)
	end
	MGBA.hasPrintedInstructions = true
end

function MGBA.setupActiveRunCallbacks()
	if Main.frameCallbackId == nil then
		Main.frameCallbackId = callbacks:add("frame", Program.mainLoop)
	end
	if Main.keysreadCallbackId == nil then
		Main.keysreadCallbackId = callbacks:add("keysRead", Input.checkJoypadInput)
	end
end

function MGBA.removeActiveRunCallbacks()
	if Main.frameCallbackId ~= nil then
		callbacks:remove(Main.frameCallbackId)
		Main.frameCallbackId = nil
	end
	if Main.keysreadCallbackId ~= nil then
		callbacks:remove(Main.keysreadCallbackId)
		Main.keysreadCallbackId = nil
	end
end


-- Controls the display order of the TextBuffers in the mGBA Scripting window

local function errorOptionNotExist(optionKey)
	return string.format("%s: %s", Resources.MGBA.OptionKeyError, tostring(optionKey))
end

MGBA.Screens = {