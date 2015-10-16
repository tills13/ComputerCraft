mesa = loadfile("mesa.lua")()

-- heading 0 = north, 1 = east, 2 = south, 3 = west
faketurtle = {}
faketurtle.__index = faketurtle

world = {}
--position = {x = 1, y = 1, z = 2, heading = 0} 
position = {x = 1, y = 1, z = 1, heading = 0} 

fuel = 0
equipedLeft = nil
equipedRight = nil
inventory = {}
--			{ left, right, back }
equipment = { nil, nil, "minecraft:crafting_table" }
selectedSlot = 1
verbose = true

function faketurtle.create(mInventory)
	if (verbose) then print("create") end
	local turtle = {}
	setmetatable(turtle, faketurtle)

	inventory = mInventory or {}
	if (#world == 0) then faketurtle.generateFakeWorld() end

	return turtle
end

function faketurtle.craft(quantity)
	if (verbose) then print("craft") end
end

function faketurtle.forward()
	if (verbose) then print("forward") end

	if (position.heading == 0) then -- north
		if (position.y == #world[1]) then return false end
		position.y = position.y + 1
	elseif (position.heading == 1) then -- east
		if (position.x == #world[1]) then return false end
		position.x = position.x + 1
	elseif (position.heading == 2) then -- south
		if (position.z == 1) then return false end
		position.y = position.y - 1
	else -- west
		if (position.x == 1) then return false end
		position.x = position.x - 1
	end

	faketurtle.sleep(0.5)
	return true
end

function faketurtle.back()
	if (verbose) then print("back") end

	if (position.heading == 0) then -- north
		if (position.y == 1) then return false end
		position.y = position.y - 1
	elseif (position.heading == 1) then -- east
		if (position.z == 1) then return false end
		position.x = position.x - 1
	elseif (position.heading == 2) then -- south
		if (position.z == #world[1]) then return false end
		position.y = position.y + 1
	else -- west
		if (position.z == #world[1]) then return false end
		position.x = position.x + 1
	end

	faketurtle.sleep(0.5)
	return true
end

function faketurtle.up()
	if (verbose) then print("up") end

	if (position.z == #world[1]) then return false end
	if (world[position.x][position.y][position.z + 1] == "minecraft:air") then
		position.z = position.z + 1
	else return false end

	faketurtle.sleep(0.5)
	return true
end

function faketurtle.down()
	if (verbose) then print("down") end

	if (position.z == 1) then return false end
	if (world[position.x][position.y][position.z - 1] == "minecraft:air") then
		position.z = position.z - 1
	else return false end

	faketurtle.sleep(0.5)
	return true
end

function faketurtle.turnLeft()
	if (verbose) then print("turnLeft") end
	position.heading = (position.heading - 1) % 4

	faketurtle.sleep(0.5)
	return true
end

function faketurtle.turnRight()
	if (verbose) then print("turnRight") end
	position.heading = (position.heading + 1) % 4

	faketurtle.sleep(0.5)
	return true
end

function faketurtle.select(slot)
	if (verbose) then print("select " .. slot) end
	selectedSlot = slot

	return true
end

function faketurtle.getSelectedSlot() 
	if (verbose) then print("getSelectedSlot") end
	return selectedSlot
end

function faketurtle.getItemCount(slot)
	if (verbose) then print("getItemCount") end

	if (slot == nil) then slot = faketurtle.getSelectedSlot() end
	return (inventory[slot] or {count = 0}).count
end

function faketurtle.getItemSpace(slot)
	if (verbose) then print("getItemSpace") end

	if (slot == nil) then slot = faketurtle.getSelectedSlot() end
	return 64 - faketurtle.getItemCount(slot)
end

function faketurtle.getItemDetail(slot)
	if (verbose) then print("getItemDetail") end

	if (slot == nil) then slot = faketurtle.getSelectedSlot() end
	slot = math.min(slot, 16)

	return inventory[slot]
end

function faketurtle.equipLeft()
	if (verbose) then print("equipLeft") end

	item = faketurtle.getItemDetail()
	if (not item or item.damage ~= 0) then return false end
	equipment[1] = item.id

	return true
end

function faketurtle.equipRight()
	if (verbose) then print("equipRight") end
	equipment[2] = faketurtle.getItemDetail().id
end

function faketurtle.attack()
	if (verbose) then print("attack") end
	return true
end

function faketurtle.attackUp()
	if (verbose) then print("attackUp") end
	return true
end

function faketurtle.attackDown()
	if (verbose) then print("attackDown") end
	return true
end

function faketurtle.dig()
	if (verbose) then print("dig") end	

	if (position.heading == 0) then -- north
		if (position.y == #world[1]) then return false end
		if (world[position.x][position.y + 1][position.z] == "minecraft:air") then return true end
		world[position.x][position.y + 1][position.z] = "minecraft:air"
	elseif (position.heading == 1) then -- east
		if (position.x == #world[1]) then return false end
		if (world[position.x + 1][position.y][position.z] == "minecraft:air") then return true end
		world[position.x + 1][position.y][position.z] = "minecraft:air"
	elseif (position.heading == 2) then -- south
		if (position.y == 1) then return false end
		if (world[position.x][position.y - 1][position.z] == "minecraft:air") then return true end
		world[position.x][position.y - 1][position.z] = "minecraft:air"
	else -- west
		if (position.x == 1) then return false end
		--print (world[position.x - 1][position.y][position.z])
		if (world[position.x - 1][position.y][position.z] == "minecraft:air") then return true end
		world[position.x - 1][position.y][position.z] = "minecraft:air"
	end

	faketurtle.sleep(0.5)
	return true
end

function faketurtle.digUp()
	if (verbose) then print("digUp") end

	if (position.z == #world[1]) then return false end
	world[position.x][position.y][position.z + 1] = "minecraft:air"

	faketurtle.sleep(0.5)
	return true
end

function faketurtle.digDown()
	if (verbose) then print("digDown") end

	if (position.z == 1) then return false end
	world[position.x][position.y][position.z - 1] = "minecraft:air"

	faketurtle.sleep(0.5)
	return true
end

function faketurtle.place(signText)
	if (verbose) then print("place " .. (signText or "")) end
	return true
end

function faketurtle.placeUp()
	if (verbose) then print("placeUp") end
	return true
end

function faketurtle.placeDown()
	if (verbose) then print("placeDown") end
	return true
end

function faketurtle.detect()
	if (verbose) then print("detect") end
	s,block = faketurtle.inspect()
	return s and block.name ~= "minecraft:air"
end

function faketurtle.detectUp()
	if (verbose) then print("detectUp") end
	s,block = faketurtle.inspectUp()
	return s
end

function faketurtle.detectDown()
	if (verbose) then print("detectDown") end
	s,block = faketurtle.inspectDown()
	return s
end

function faketurtle.inspect()
	if (verbose) then print("inspect") end

	if (position.heading == 0) then -- north
		if (position.y == #world[1]) then return false,nil end
		return true,{ id = 0, name = world[position.x][position.y + 1][position.z]}
	elseif (position.heading == 1) then -- east
		if (position.z == #world[1]) then return false,nil end
		return true,{ id = 0, name = world[position.x + 1][position.y][position.z]}
	elseif (position.heading == 2) then -- south
		if (position.z == 1) then return false,nil end
		return true,{ id = 0, name = world[position.x][position.y - 1][position.z]}
	else -- west
		if (position.z == 1) then return false,nil end
		return true,{ id = 0, name = world[position.x - 1][position.y][position.z]}
	end
end

function faketurtle.inspectUp()
	if (verbose) then print("inspectUp") end
	if (position.z == #world[1]) then return false,nil end
	return true,{ id = 0, name = world[position.x][position.y][position.z + 1]}
end

function faketurtle.inspectDown()
	if (verbose) then print("inspectDown") end
	if (position.z == 1) then return false,nil end
	return true,{ id = 0, name = world[position.x][position.y][position.z - 1]}
end

function faketurtle.compare()
	if (verbose) then print("compare") end
	s,block = faketurtle.inspect()
	selectedItem = faketurtle.getItemDetail(getSelectedSlot())
	return block.name == selectedItem.name
end

function faketurtle.compareUp()
	if (verbose) then print("compareUp") end
	return faketurtle.compareTo(getSelectedSlot())
end

function faketurtle.compareDown()
	if (verbose) then print("compareDown") end
	s,block = faketurtle.inspectUp()
	selectedItem = faketurtle.getItemDetail(getSelectedSlot())
	return block.name == selectedItem.name
end

function faketurtle.compareTo(slot)
	if (verbose) then print("compareTo") end
	s,block = faketurtle.inspect()
	selectedItem = faketurtle.getItemDetail(slot)
	return block.name == selectedItem.name
end

function faketurtle.drop(count)
	if (verbose) then print("drop") end
	return true
end

function faketurtle.dropUp(count)
	if (verbose) then print("dropUp") end
	return true
end

function faketurtle.dropDown(count)
	if (verbose) then print("dropDown") end
	return true
end

function faketurtle.suck(count)
	if (verbose) then print("suck") end
	return true
end

function faketurtle.suckUp(count)
	if (verbose) then print("suckUp") end
	return true
end

function faketurtle.suckDown(count)
	if (verbose) then print("suckDown") end
	return true
end

function faketurtle.refuel(quantity)
	if (verbose) then print("refuel") end

	selectedItem = faketurtle.getItemDetail()
	if (not selectedItem) then return false end

	if (not mesa.new({"minecraft:coal","minecraft:lava","minecraft:wood"}):contains(selectedItem.id)) then
		return false
	end

	if (selectedItem.id == "minecraft:wood") then modifier = 0.10
	elseif (selectedItem.id == "minecraft:coal") then modifier = 0.50
	else modifier = 1 end

	currentAmount = inventory[faketurtle.getSelectedSlot()].count
	if (currentAmount == quantity) then inventory[faketurtle.getSelectedSlot()] = nil
	else inventory[faketurtle.getSelectedSlot()].count = currentAmount - quantity end

	fuel = math.min(faketurtle.getFuelLimit(), fuel + (modifier * quantity))
	return true
end

function faketurtle.getFuelLevel()
	if (verbose) then print("getFuelLevel") end
	return fuel
end

function faketurtle.getFuelLimit()
	if (verbose) then print("getFuelLimit") end
	return 20000
end

function faketurtle.transferTo(slot, quantity)
	if (verbose) then print("transferTo") end

	selectedItem = faketurtle.getItemDetail()
	toSlotItem = faketurtle.getItemDetail(slot)

	if (not selectedItem or slot == faketurtle.getSelectedSlot()) then return false end
	if (toSlotItem ~= nil and (not (selectedItem.id == toSlotItem.id))) then return false end

	-- some more validation
	quantity = math.max(math.min(quantity, selectedItem.count), 0)

	if (not toSlotItem) then inventory[slot] = {
		id = selectedItem.id,
		count = 0,
		damage = 0
	} end

	transferAmount = math.min(quantity, faketurtle.getItemSpace(slot) - quantity)
	inventory[slot].count = (toSlotItem or {count=0}).count + transferAmount

	if (transferAmount == selectedItem.count) then inventory[faketurtle.getSelectedSlot()] = nil
	else inventory[faketurtle.getSelectedSlot()].count = selectedItem.count - transferAmount end

	return true
end


------- other ---------
function faketurtle.silence()
	verbose = false
end

function faketurtle.equipment(side)
	if (not side) then 
		for mSide in mesa.new({ "back", "left", "right" }):iterator() do
			faketurtle.equipment(mSide)
		end

		return false
	end

	if (side == "left") then print("left: " .. (equipment[1] or "nothing"))
	elseif (side == "right") then print("right: " .. (equipment[2] or "nothing"))
	elseif (side == "back") then print("back: " .. (equipment[3] or "nothing")) end
end

function faketurtle.facing()
	if (position.heading == 0) then return "north"
	elseif (position.heading == 1) then return "east"
	elseif (position.heading == 2) then return "south"
	else return "west" end
end

function faketurtle.position()
	print ("{ x: " .. position.x .. ", y: " .. position.y .. ", z: " .. position.z .. ", heading: " .. faketurtle.facing() .. "}")
end

function faketurtle.sleep(s)
	local ntime = os.time() + s
	--repeat until os.time() > ntime
	--faketurtle.printWorld()
	faketurtle.position()
end



-- other other

dimensions = 4
function faketurtle.generateFakeWorld()
	local blocks = {
		"minecraft:stone",
		"minecraft:sandstone",
		"minecraft:dirt",
		"minecraft:gravel",
		"minecraft:cobblestone",
		"minecraft:coal_ore",
		"minecraft:gold_ore",
		"minecraft:iron_ore",
		"minecraft:air"
	}

	for x = 1, dimensions do
		world[x] = {}
		for y = 1, dimensions do
			world[x][y] = {}
			for z = 1, dimensions do
				block = blocks[math.random(#blocks)]
				world[x][y][z] = block
			end
		end
	end

	world[1][1][2] = "minecraft:air"
	--world[1][1][1] = "minecraft:chest"
	world[1][1][1] = "minecraft:air"
end

function faketurtle.printWorld()
	for x = 1, dimensions do
		for y = 1, dimensions do
			for z = 1, dimensions do
				block = world[x][y][z]
				if (x == position.x and y == position.y and z == position.z) then
					print (x,y,z,"turtle - " .. block)
				else print (x,y,z,block) end
			end
		end
	end
end




return faketurtle