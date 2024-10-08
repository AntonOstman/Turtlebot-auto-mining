local math = require("math")

-- Robot states

DIRECTIONS = {"N","W","S","E"}
CURRENT_DIRECTION = "N"
POS = {x = 0, y = 0, z = 0}
MAP = {}
MAP[1] = POS
MAP_LENGTH = 1

local function pop_map()
    local popped = MAP[MAP_LENGTH]
    MAP[MAP_LENGTH] = nil
    MAP_LENGTH = MAP_LENGTH - 1
    return popped
end

local function push_map(pos)
    MAP_LENGTH = MAP_LENGTH + 1
    MAP[MAP_LENGTH] = pos
end

local function refuel()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" or fuelLevel > 0 then
        return
    end

    local function tryRefuel()
        for n = 1, 16 do
            if turtle.getItemCount(n) > 0 then
                turtle.select(n)
                if turtle.refuel(1) then
                    turtle.select(1)
                    return true
                end
            end
        end
        turtle.select(1)
        return false
    end

    if not tryRefuel() then
        print("Add more fuel to continue.")
        while not tryRefuel() do
            os.pullEvent("turtle_inventory")
        end
        print("Resuming Tunnel.")
    end
end


local function change_direction(new_direction)
    while (new_direction ~= CURRENT_DIRECTION) do
        refuel()
        turtle.turnLeft()
        if CURRENT_DIRECTION == "N" then
            CURRENT_DIRECTION = "W"
        elseif CURRENT_DIRECTION == "W" then
            CURRENT_DIRECTION = "S"
        elseif CURRENT_DIRECTION == "S" then
            CURRENT_DIRECTION = "E"
        elseif CURRENT_DIRECTION == "E" then
            CURRENT_DIRECTION = "N"
        end
    end
end

local function move_forward()
    refuel()
    turtle.dig()
    turtle.forward()
    local newpos = {}
    print("test")
    if CURRENT_DIRECTION == "N" then
        newpos = {x = POS.x, y = POS.y, z = POS.z - 1}
    elseif CURRENT_DIRECTION == "W" then
        newpos = {x = POS.x - 1, y = POS.y, z = POS.z}
    elseif CURRENT_DIRECTION == "S" then
        newpos = {x = POS.x, y = POS.y, z = POS.z + 1}
    elseif CURRENT_DIRECTION == "E" then
        newpos = {x = POS.x + 1, y = POS.y, z = POS.z}
    else
        print("newpos not set during move_forward")
    end
    POS = newpos
end

local function update_map(is_new_pos)
    if is_new_pos then
        push_map(POS)
    end
end


local function move_vertical(deltay)
    refuel()
    local newpos = {}
    if deltay < 0 then
        newpos = {x = POS.x, y = POS.y - 1, z = POS.z}
        turtle.down()
    elseif deltay > 0 then
        newpos = {x = POS.x, y = POS.y + 1, z = POS.z}
        turtle.up()
    else
        return
    end
    POS = newpos
end

local function go_to(x,y,z, is_new_pos)
    refuel()
    local distx = x - POS.x
    local disty = y - POS.y
    local distz = z - POS.z

    for i=1,math.abs(distx) do
        if distx > 0 then
            change_direction("E")
        elseif distx < 0 then
            change_direction("W")
        else
            print("ERROR distx 0 but still moving forward")
        end
        move_forward()
        update_map(is_new_pos)
    end

    for i=1,math.abs(distz) do
        if distz < 0 then
            change_direction("N")
        elseif distz > 0 then
            change_direction("S")
        else
            print("ERROR distz 0 but still moving forward")
        end
        move_forward()
        update_map(is_new_pos)
    end

    for i=1,math.abs(disty) do
        move_vertical(disty)
        update_map(is_new_pos)
    end

end

local function printpos(pos)
    print("==pos==")
    print(pos.x, pos.y, pos.z)
end
local function printstate()
    print("==state==")
    print("dir", CURRENT_DIRECTION)
    print("len", MAP_LENGTH)
    print("POS", POS.x, POS.y, POS.z)
end

local function back_track()
    while(MAP_LENGTH > 0) do
        printstate()
        local pos = pop_map()
        printpos(pos)
        go_to(pos.x, pos.y, pos.z, false)
    end
end

local function search()

end

local function refuel_from_chest()
    local chest = peripheral.find("minecraft:chest")
    chest.pushItems("front", 1)
end

local function dump_items()
    local chest = peripheral.find("minecraft:chest")
    for i = 2, 15 do
        chest.pullItems("front", i)
        -- pushItems(peripheral.getName(chest), i)
    end
end

-- local x_pos = arg[1]
-- local y_pos = arg[2]
-- local z_pos = arg[3]

go_to(0,2,2, true)

back_track()
