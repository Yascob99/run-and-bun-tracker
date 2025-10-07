Utils = {}

function Utils.ifelse(condition, ifcase, elsecase)
	if condition then
		return ifcase
	else
		return elsecase
	end
end

-- Shifts bits of 'value', 'level' bits to the left
function Utils.bit_lshift(value, level)
	return math.floor(value) * (2 ^ level)
end

-- Shifts bits of 'value', 'level' bits to the right
function Utils.bit_rshift(value, level)
	return math.floor(value / (2 ^ level))
end

-- gets bits from least significant to most
function Utils.getbits(value, startIndex, numBits)
	return math.floor(Utils.bit_rshift(value, startIndex) % Utils.bit_lshift(1, numBits))
end

function Utils.gettop(a)
	return (a >> 16)
end

function Utils.addhalves(a)
	local b = Utils.getbits(a,0,16)
	local c = Utils.getbits(a,16,16)
	return b + c
end

function Utils.mult32(a, b)
	local c = (a >> 16)
	local d = a % 0x10000
	local e = (b >> 16)
	local f = b % 0x10000
	local g = (c*f + d*e) % 0x10000
	local h = d*f
	local i = g*0x10000 + h
	return i
end

function Utils.rngDecrease(a)
	return (Utils.mult32(a,0xEEB9EB65) + 0x0A3561A1) % 0x100000000
end

function Utils.rngAdvance(a)
	return (Utils.mult32(a, 0x41C64E6D) + 0x6073) % 0x100000000
end

function Utils.rngAdvanceMulti(a, level) -- TODO, use tables to make this in O(logn) time
	for i = 1, level, 1 do
		a = (Utils.mult32(a, 0x41C64E6D) + 0x6073) % 0x100000000
	end
	return a
end

function Utils.rng2Advance(a)
	return (Utils.mult32(a, 0x41C64E6D) + 0x3039) % 0x100000000
end

function Utils.getRNGDistance(b,a)
    local distseed = 0
    for j=0,31,1 do
		if Utils.getbits(a,j,1) ~= Utils.getbits(b,j,1) then
			b = Utils.mult32(b, RNGData.multspa[j+1])+ RNGData.multspb[j+1]
			distseed = distseed + (1 << j)
			if j == 31 then
				distseed = distseed + 0x100000000
			end
		end
    end
	return distseed
end

function Utils.tohex(a)
	local mystr = bizstring.hex(a)
	while string.len(mystr) < 8 do
		mystr = "0" .. mystr
	end
	return mystr
end

function Utils.getStatus(address)
	local status_aux = Memory.readdword(address)
	local status_result = 0
	if status_aux == 0 then
		return PokemonData.status[1]
	elseif status_aux < 8 then
		return PokemonData.status[2]
	elseif status_aux == 8 then
		return PokemonData.status[3]	
	elseif status_aux == 16 then
		return PokemonData.status[4]	
	elseif status_aux == 32 then
		return PokemonData.status[5]	
	elseif status_aux == 64 then
		return PokemonData.status[6]
	elseif status_aux == 128 then
		return PokemonData.status[7]
	end
	return PokemonData.status[1]
end

function Utils.getNatureColor(stat, nature)
	local color = "white"
	if nature % 6 == 0 then
		color = "white"
	elseif stat == "atk" then
		if nature < 5 then
			color = "0xFF00FF00"
		elseif nature % 5 == 0 then
			color = "red"
		end
	elseif stat == "def" then
		if nature > 4 and nature < 10 then
			color = "0xFF00FF00"
		elseif nature % 5 == 1 then
			color = "red"
		end
	elseif stat == "spe" then
		if nature > 9 and nature < 15 then
			color = "0xFF00FF00"
		elseif nature % 5 == 2 then
			color = "red"
		end
	elseif stat == "spa" then
		if nature > 14 and nature < 20 then
			color = "0xFF00FF00"
		elseif nature % 5 == 3 then
			color = "red"
		end
	elseif stat == "spd" then
		if nature > 19 then
			color = "0xFF00FF00"
		elseif nature % 5 == 4 then
			color = "red"
		end
	end
	return color
end

function Utils.getTableValueIndex(myvalue, mytable)
	for i=1,#mytable,1 do
		if myvalue == mytable[i] then
			return i
		end
	end
	return 1
end

function Utils.toString(address, length)
	local nickname = ""
	for i=0, length - 1, 1 do
		local charByte = Memory.readbyte(address + i)
		if charByte == 0xFF then break end -- end of sequence
		nickname = nickname .. CharData.charmap[charByte]
	end
	return nickname
end

-- Bitwise AND operation
function Utils.bit_and(value1, value2)
	return Utils.bit_oper(value1, value2, 4)
end

-- Bitwise OR operation
function Utils.bit_or(value1, value2)
	return Utils.bit_oper(value1, value2, 1)
end

-- Bitwise XOR operation
function Utils.bit_xor(value1, value2)
	return Utils.bit_oper(value1, value2, 3)
end

-- operand: 1 = OR, 3 = XOR, 4 = AND
function Utils.bit_oper(a, b, operand)
	local r, m, s = 0, 2^31, nil
	repeat
		s,a,b = a+b+m, a%m, b%m
		r,m = r + m*operand%(s-a-b), m/2
	until m < 1
	return math.floor(r)
end

function Utils.indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function Utils.calcLevel(exp, ID)
	local level = 1
	while (exp >= Utils.expRequired(ID,level+1)) do
		level=level+1
	end
	return level
end

function Utils.expRequired(id,level)
	local expCurve = GameSettings.mons[GameSettings.names[id + 1]]["levelUpType"]
	if (expCurve == 0) then -- medium fast curve
		return level^3 
	end 
	if (expCurve == 1) then -- erratic curve
		if (level<=50) then
        	return math.floor(((100 - level)*level^3)/50)
    	end
   		if (level<=68) then
        	return math.floor(((150 - level)*level^3)/100)
    	end
    	if (level<=98) then
        	return math.floor(math.floor((1911 - 10 * level) / 3) * level^3 / 500)
    	end
    	return math.floor((160 - level) * level^3 / 100)
	end 
	if (expCurve == 2) then -- fluctuating curve
		if (level<15) then
			return math.floor((math.floor((level + 1) / 3) + 24) * level^3 / 50)
		end
		if (level<=36) then
			return math.floor((level + 14) * level^3 / 50)
		end
		return math.floor((math.floor(level / 2) + 32) * level^3 / 50)
	end
	if (expCurve == 3) then return -- medium slow curve
		math.floor((6 * (level)^3) / 5) - (15 * (level)^2) + (100 * level) - 140 
	end
	if (expCurve == 4) then -- fast curve
		return math.floor((4*(level^3))/5)
	end
	if (expCurve == 5) then -- slow curve
		return math.floor((5*(level^3))/4)
	end
end