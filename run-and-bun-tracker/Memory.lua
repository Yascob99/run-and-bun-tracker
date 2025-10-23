Memory = {}
--- Reads data from a given game address
---@param addr number address to read from
---@param size number amount of data to read
---@param signed? boolean Optional, deafults to false, If the data should be read as a signed integer
---@return integer data an integer representation of the data
function Memory.read(addr, size, signed)
	signed = signed or false
	
	if Main.IsOnBizhawk() then
		local mem = ""
		local memdomain = (addr >> 24)
		if memdomain == 0 then
			mem = "BIOS"
		elseif memdomain == 2 then
			mem = "EWRAM"
		elseif memdomain == 3 then
			mem = "IWRAM"
		elseif memdomain == 8 then
			mem = "ROM"
		end
		addr = (addr & 0xFFFFFF)
		if signed then
			if size == 1 then
				return memory.read_s8(addr,mem)
			elseif size == 2 then
				return memory.read_s16_le(addr,mem)
			elseif size == 3 then
				return memory.read_s24_le(addr,mem)
			else
				return memory.read_s32_le(addr,mem)
			end
		else
			if size == 1 then
				return memory.read_u8(addr,mem)
			elseif size == 2 then
				return memory.read_u16_le(addr,mem)
			elseif size == 3 then
				return memory.read_u24_le(addr,mem)
			else
				return memory.read_u32_le(addr,mem)
			end
		end
	else
		if signed then
			if size == 1 then
				return Utils.toSignedInt(emu:read8(addr))
			elseif size == 2 then
				return  Utils.toSignedInt(emu:read16(addr))
			elseif size == 3 then
				return  Utils.toSignedInt(emu:readRange(addr, size))
			else
				return  Utils.toSignedInt(emu:read32(addr))
			end
		else
			if size == 1 then
				return emu:read8(addr)
			elseif size == 2 then
				return emu:read16(addr)
			elseif size == 3 then
				return emu:readRange(addr, size)
			else
				return emu:read32(addr)
			end
		end
	end
end

--- Reads 4 bytes of data from a memory address
---@param addr number address to read from
---@param signed? boolean  Optional, deafults to false, If the data should be read as a signed integer
---@return integer data an integer representation of the data
function Memory.readdword(addr, signed)
	signed = signed or false
	return Memory.read(addr, 4, signed)
end

--- Reads 2 bytes of data from a memory address
---@param addr number address to read from
---@param signed? boolean  Optional, deafults to false, If the data should be read as a signed integer
---@return integer data an integer representation of the data
function Memory.readword(addr, signed)
	signed = signed or false
	return Memory.read(addr, 2, signed)
end

--- Reads 1 bytes of data from a memory address
---@param addr number address to read from
---@param signed? boolean  Optional, deafults to false, If the data should be read as a signed integer
---@return integer data an integer representation of the data
function Memory.readbyte(addr, signed)
	signed = signed or false
	return Memory.read(addr, 1, signed)
end