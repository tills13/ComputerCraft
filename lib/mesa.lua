mesa = { __espanol = true }
mesa.__index = mesa

function mesa.new(data)
	local table = data or {}
	setmetatable(table, mesa)
	return table
end

function mesa:push(item)
	table.insert(self, item)
end

function mesa:enqueue(item)
	table.insert(self, 1, item)
end

function mesa:pop(item)
	return table.remove(self)
end

function mesa:dequeue(item)
	return table.remove(self, 1)
end

function mesa:contains(value)
	for k,v in pairs(self) do
		if (value == v) then return true end
	end

	return false
end

function mesa:join(delimiter)
	local result = ""

	for i = 1, #self do
		result = result .. tostring(self[i])
		if (i ~= (#self)) then result = result .. delimiter end
	end

	return result
end

function mesa:slice(mStart, mEnd)
	local mTable = mesa.new()
	print ("slicing from " .. mStart .. " to " .. mEnd .. " -> " .. (mEnd - mStart))
	for i = mStart, (mEnd - 1) do
		mTable:push(self[i])
	end

	return mTable
end

function mesa:append(table)
	if (not table.__espanol) then table = mesa.new(table) end

	for i in table.iterator() do
		self:push(i)
	end

	return self
end

--mesa:union = mesa:append

function mesa:replace(...)
	local args = {...}

	if (#args < 2) then return false end

	local startIndex,replace,endIndex = args[1],nil,nil

	if (#args == 2) then 
		replace = args[3]
		endIndex = startIndex + #replace
	else
		endIndex = args[2]
		replace = args[3]
	end

	local beginning = self:slice(1, startIndex)
	local ending = self:slice((endIndex + 1), (#self + 1))
	return beginning.append(replace).append(ending)
end

function mesa:prune(value)
	if (not type(value) == "array") then value = {value} end

	return self
end

function mesa:iterator()
	return coroutine.wrap(function() 
		for i = 1,#self do
			coroutine.yield(self[i])
		end
	end)
end

function mesa:dump()
	print (self:join(" "))
end

-- metamethods

mesa.__add = function(lhs, rhs)
	return lhs.append(rhs)
end

mesa.__concat = function(lhs, rhs)
	return lhs.append(rhs)
end

mesa.__eq = function(lhs, rhs)
	for k,v in pairs(lhs) do
		if (not (rhs[k] == v)) then return false end
	end

	return true and (#lhs == #rhs)
end

-- extra

local DIRECTION_UP = "0"
local DIRECTION_DOWN = "1"
local DIRECTION_FORWARD = "2"
local DIRECTION_BACK = "3"
local DIRECTION_TURN_LEFT = "4"
local DIRECTION_TURN_RIGHT = "5"

local SEP_NEWPATH = "("
local SEP_FINISHPATH = ")"
local SEP_SPACE = " "

function mesa:balance()
	print("balancing " .. self:join(" "))
	local sepStack = mesa.new()
	local moveStack = mesa.new()

	local previousValue = nil 

	for i = 1, #self do
		if (self[i] == SEP_NEWPATH) then sepStack.push(i)
		elseif (self[i] == SEP_FINISHPATH) then
			start = sepStack.pop()

			local balanced = self:slice((start + 1), i).balance()
			print (balanced)
			temp = (temp or self).replace(start, i, balanced)
			--temp.dump()
		else
			moveStack.push(self[i])
			if not previousValue then previousValue = self[i] end
		end
	end
	
	return moveStack
end

return mesa