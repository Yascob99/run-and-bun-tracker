Utils = {}

function Utils.ifelse(condition, ifcase, elsecase)
	if condition then
		return ifcase
	else
		return elsecase
	end
end

-- Shifts bits of 'value', 'n' bits to the left
function Utils.bit_lshift(value, n)
	return math.floor(value) * (2 ^ n)
end

-- Shifts bits of 'value', 'n' bits to the right
function Utils.bit_rshift(value, n)
	return math.floor(value / (2 ^ n))
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

function Utils.rngAdvanceMulti(a, n) -- TODO, use tables to make this in O(logn) time
	for i = 1, n, 1 do
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
			color = 0xFF00FF00
		elseif nature % 5 == 0 then
			color = "red"
		end
	elseif stat == "def" then
		if nature > 4 and nature < 10 then
			color = 0xFF00FF00
		elseif nature % 5 == 1 then
			color = "red"
		end
	elseif stat == "spe" then
		if nature > 9 and nature < 15 then
			color = 0xFF00FF00
		elseif nature % 5 == 2 then
			color = "red"
		end
	elseif stat == "spa" then
		if nature > 14 and nature < 20 then
			color = 0xFF00FF00
		elseif nature % 5 == 3 then
			color = "red"
		end
	elseif stat == "spd" then
		if nature > 19 then
			color = 0xFF00FF00
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