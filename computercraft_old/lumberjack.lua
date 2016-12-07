ts = dofile('turtlestuff.lua')

local FUELSLOT = 1
local SAPLINGSLOT = 2
local BONEMEALSLOT = 3

local CHECKWAIT = 5

print('Fuel in slot #'..FUELSLOT)
print('Saplings in slot #'..SAPLINGSLOT)
print('Bonemeal in slot #'..BONEMEALSLOT)

print('Waiting for '..CHECKWAIT..' seconds between checks.')

checker = ts.FuelChecker:new(FUELSLOT)

function chopTree()
    turtle.dig()
    checker:forward()

    while turtle.detectUp() do
        turtle.digUp()
        checker:up()
    end

    while checker:down() do end

    checker:back()
end

function treeGrown()
    return turtle.detect() and not turtle.compareTo(SAPLINGSLOT)
end

function plantTree()
    if turtle.getItemCount(SAPLINGSLOT) <= 1 then
        return false
    end

    turtle.select(SAPLINGSLOT)
    turtle.place()

    if turtle.getItemCount(BONEMEALSLOT) > 1 then
        turtle.select(BONEMEALSLOT)
        turtle.place()
    end

    return true
end

function inventoryFull()
    for i=1,16 do
        if i == FUELSLOT or i == BONEMEALSLOT or i == SAPLINGSLOT then
        elseif turtle.getItemCount(i) < 64 then
            return false
        end
    end

    return true
end

while true do
    if treeGrown() then
        chopTree()
    end

    if turtle.getItemCount(SAPLINGSLOT) <= 1 or inventoryFull() then
        break
    end

    if not turtle.detect() then
        plantTree()
    end

    os.sleep(CHECKWAIT)
    while not treeGrown() do os.sleep(CHECKWAIT) end
end
