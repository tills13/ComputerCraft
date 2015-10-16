dev = not turtle

if (not dev) then
	mesa = loadfile("/lib/mesa.lua")()
	faketurtle = loadfile("/lib/faketurtle.lua")()
else
	mesa = loadfile("mesa.lua")()
	faketurtle = loadfile("faketurtle.lua")()
end

local DIRECTION_UP = "0"
local DIRECTION_DOWN = "1"
local DIRECTION_FORWARD = "2"
local DIRECTION_BACK = "3"
local DIRECTION_TURN_LEFT = "4"
local DIRECTION_TURN_RIGHT = "5"

local SEP_NEWPATH = "("
local SEP_FINISHPATH = ")"
local SEP_SPACE = " "


--------


turtle = turtle or faketurtle.create({
	{ id = "minecraft:dirt", count = 20, damage = 0 },
	{ id = "minecraft:stone", count = 20, damage = 0 },
	{ id = "minecraft:coal", count = 64, damage = 0 },
	{ id = "minecraft:diamond_pick", count = 1, damage = 0 }
})

avoid = mesa.new({
	"minecraft:dirt",
	"minecraft:stone",
	"minecraft:gravel",
	"minecraft:sand",
	"minecraft:sandstone",
	"minecraft:water",
	"minecraft:flowing_warter",
	"minecraft:lava",
	"minecraft:flowing_lava",
	"minecraft:cobblestone"
})

tortoise = {}
tortoise.__index = tortoise

function tortoise.create(options)
	local mTortoise = {}
	setmetatable(mTortoise, tortoise)

	mTortoise.fuelThreshold = 0.10
	mTortoise.stack = mesa:new()
	mTortoise.options = mesa.new({})

	return mTortoise
end

if (dev) then
	function tortoise:turtle()
		return turtle
	end
end

function tortoise:shouldRefuel()
	local fuel = turtle.getFuelLevel()
	local totalFuel = turtle.getFuelLimit()
	
	if (type(fuel) == "string") then return false end -- maybe

	return ((fuel / totalFuel) < (self.fuelThreshold))
end

function tortoise:refuel(percent)
	if percent > 1 then percent = percent / 100 end -- "normalize"

	for i = 1, 16 do
		turtle.select(i) -- change to the slot

		if turtle.refuel(0) then -- valid fuel
			local stack = math.ceil(turtle.getItemCount(i) * percent)
			turtle.refuel(stack) -- consume the stack as fuel
		end
	end
end

function tortoise:getRemainingInventory()
	local total,running = 0,0

	for i = 1, 16 do
		running = turtle.getItemCount(i)
		total = running + turtle.getItemSpace(i)
	end

	return running/total
end

function tortoise:turn(direction, push)
	if (direction == "left" and turtle.turnLeft()) then 
		if (push) then self.stack:push(DIRECTION_TURN_LEFT) end
	elseif (direction == "right" and turtle.turnRight()) then
		if (push) then self.stack:push(DIRECTION_TURN_RIGHT) end
	end

	return true
end

function tortoise:turnAround()
	return turtle.turnLeft() and turtle.turnLeft()
end

function tortoise:move(direction, push)
	if (direction == "up") then 
		if (turtle.up() and push) then self.stack:push(DIRECTION_UP) end
	elseif (direction == "down") then 
		if (turtle.down() and push) then self.stack:push(DIRECTION_DOWN) end
	elseif (direction == "forward") then
		if (turtle.forward() and push) then self.stack:push(DIRECTION_FORWARD) end
	elseif (direction == "back") then
		if (turtle.back() and push) then self.stack:push(DIRECTION_BACK) end
	end

	return true
end

function tortoise:dig(direction)
	if (direction == "up") then 
		return turtle.digUp()
	elseif (direction == "down") then 
		return turtle.digDown()
	elseif (direction == "forward") then
		return turtle.dig()
	end
end

function tortoise:digAndMove(direction, track, callback)
	if (not self:dig(direction)) then return false end

	if self:move(direction, track or false) then 
		if (callback) then callback() end 
		return true
	end
end

function tortoise:inspect(direction)
	local b,block = false,nil

	if (direction == "up") then 
		b,block = turtle.inspectUp()
	elseif (direction == "down") then
		b,block = turtle.inspectDown()
	elseif (direction == "forward") then 
		b,block = turtle.inspect("asd")
	end

	return b,block
end

function tortoise:collect(direction)
	self:digAndMove(direction, false, nil)

	for k,d in pairs({"up", "down", "forward"}) do
		s,block = self:inspect(d)
		if (s and direction ~= "down" and d == "up" and not avoid:contains(block.name)) then
			self:collect("up")
		elseif (s and direction ~= "up" and d == "down" and not avoid:contains(block.name)) then
			self:collect("down")
		elseif (d == "forward") then
			for i = 1, 4 do
				turn("left", false)
				s,block = self:inspect(d)
				if (s and not avoid:contains(block.name)) then
					self:collect("forward")
				end
			end 
		end
	end

	if (direction == "up") then
		turtle.down()
	elseif (direction == "down") then
		turtle.up()
	elseif (direction == "forward") then
		turtle.back()
	end
end

function tortoise:shouldCollect(direction, callback)
	print ("shouldcollect")
	if not direction then
		for index,value in ipairs({"up", "down", "forward"}) do
			if (self:shouldCollect(value, nil) and callback) then callback(value) end
		end

		self:turn("left", false)
		if (self:shouldCollect("forward") and callback) then callback("forward") end
		self:turn("right", false)
		self:turn("right", false)
		if (self:shouldCollect("forward") and callback) then callback("forward") end
		self:turn("left", false)

		return
	end

	s,block = self:inspect(direction)
	if (s and not avoid:contains(block.name)) then 
		self:collect(direction) 
	end
end

function tortoise:equip(side, tool)
	if (type(tool) == "number") then
		local validTools = mesa.new({"minecraft:diamond_hoe","minecraft:diamond_shovel","minecraft:diamond_pick","minecraft:diamond_axe","minecraft:crafting_table"})
		local item = turtle.getItemDetail(tool)

		if (item and (validTools:contains(item.id))) then
			local selected = turtle.getSelectedSlot()
			turtle.select(tool)

			local result = turtle.equipLeft()
			turtle.select(selected)

			return result
		else return false end
	else
		for i = 0, 16 do
			local item = turtle.getItemDetail(i)

			if (item and (type(tool) == "string") and (tool == item.id) and (item.damage == 0)) then
				return self:equip(side, i)
			end
		end
	end

	return false
end

--[[function tortoise:use()
	local shovel = mesa.new({"minecraft:gravel","minecraft:dirt","minecraft:dirt"})

	s,block = turtle.inspect("forward")
	if (not s) then return nil end
end]]--

local function bind(t, k)
    return function(...) return t[k](t, ...) end
end

local mode = 0
local tunnels = 2
local tunnelLength = 2
local gapLength = 3

function tortoise:mine()
	print ("asdasd")
	local stop = false

	while mode == 0 and not stop do
		for tunnel = 1, tunnels do
			for j = 1, (tunnelLength / 2) do
				self:digAndMove("up", true, bind(self, "shouldCollect"))
				self:digAndMove("forward", true, bind(self, "shouldCollect"))
				self:digAndMove("down", true, bind(self, "shouldCollect"))
				self:digAndMove("forward", true, bind(self, "shouldCollect"))
			end

			if (stop) then break end

			if (tunnel % 2 == 1) then self:turn("right", true)
			else self:turn("left", true) end
			for k = 0, (gapLength / 2) do
				self:digAndMove("up", true, bind(self, "shouldCollect"))
				self:digAndMove("forward", true, bind(self, "shouldCollect"))
				self:digAndMove("down", true, bind(self, "shouldCollect"))
				self:digAndMove("forward", true, bind(self, "shouldCollect"))
			end

			if (tunnel % 2 == 1) then self:turn("right", true)
			else self:turn("left", true) end
		end

		mode = 3
	end

	-- go back to start
	while mode == 1 do
		if (self:back()) then mode = 2 end
		stop = false
	end

	-- offload
	while mode == 2 do

	end
end

-- mType = right or left
function tortoise:clear(d, mType)
	local dimensions = { x = 4, y = 4, z = 2 }
	--dimensions = d or dimensions
	self:turn(mType or "right")

	for y = 1, (dimensions.y + 1) do -- 
		for z = 1, dimensions.z do
			for x = 1, (dimensions.x - 1) do
				self:digAndMove("forward")
			end

			if (z ~= dimensions.z) then
				if (y % 2 == 1) then 
					self:digAndMove("up")
				else 
					self:digAndMove("down")
				end

				self:turnAround()
			end
		end

		if (y % 2 == 0 or dimensions.y % 2 == 0) then
			self:turn("right")
			self:digAndMove("forward")
			self:turn("right")
		else 
			self:turn("left")
			self:digAndMove("forward")
			self:turn("left")
		end
	end
end

--[[
function tortoise:back(callback)
	--stack = stack:resolve()

	for i = 0, #stack do
		if stack[i] == DIRECTION_UP then self:move("down", false)
		elseif stack[i] == DIRECTION_DOWN then self:move("up", false)
		elseif stack[i] == DIRECTION_FORWARD then self:move("back", false)
		elseif stack[i] == DIRECTION_BACK then self:move("forward", false)
		elseif stack[i] == DIRECTION_TURN_RIGHT then self:turn("left", false)
		elseif stack[i] == DIRECTION_TURN_LEFT then self:turn("right", false)
		end
	end

	if callback then callback() end

	return true
end

function tortoise:empty(callback)
	for i,direction in ipairs({"up", "down", "forward"}) do
		s,block = self:inspect(direction)
		if (s and block.name == "minecraft:chest") then
			for m = 1,16 do
				if (not turtle.getItemCount(m) == 0) then
					turtle.select(m)
					if not self:drop(direction, turtle.getItemCount(m)) then
						if callback then return callback(false) else return false end
					end
				end
			end

			if callback then return callback(true) else return true end
		end
	end

	if callback then return callback(true) else return true end
end ]]--

return tortoise