os.loadAPI 'ahto'

local args = {...}

if #args ~= 1 then
    print "Usage: excavate <diameter>"
    return
end

-- Mine in a quarry pattern until we hit something we can't dig
local size = tonumber( args[1] )
if size < 1 then
    print "Excavate diameter must be positive"
    return
end

local depth     = 0
local unloaded  = 0
local collected = 1

local xPos, zPos = 0, 0
local xDir, zDir = 0, 1

local goTo
local refuel

local function unload(keepOneFuelStack)
    print "Unloading items..."

    for n=1,16 do
        local count = ahto.getItemCount(n)

        if count > 0 then
            if keepOneFuelStack and turtle.refuel(0) then
                keepOneFuelStack = false
            else
                ahto.drop(n, ahto.d.forward)
                unloaded = unloaded + count
            end
        end
    end

    collected = 0
end

local function returnSupplies()
    local x, y, z = xPos, depth, zPos
    local xd, zd = xDir, zDir
    local fuelNeeded = 2*(x+y+z) + 1

    print "Returning to surface..."
    goTo(0,0,0,0,-1)

    if not refuel( fuelNeeded ) then
        unload(true)
        print "Waiting for fuel"

        while not refuel(fuelNeeded) do
            os.pullEvent("turtle_inventory")
        end
    else
        unload(true)
    end

    print "Resuming mining..."
    goTo( x,y,z, xd,zd )
end

local function collect()
    local full = true -- no empty inv slots
    local totalItems = 0

    for n=1,16 do
        local count = ahto.getItemCount(n)

        if count == 0 then
            full = false
        end

        totalItems = totalItems + count
    end

    if totalItems > collected then
        collected = totalItems

        if math.fmod(collected + unloaded, 50) == 0 then
            print("Mined "..(collected + unloaded).." items.")
        end
    end

    if full then
        print "No empty slots left."
        return false
    else
        return true
    end
end

function refuel(amount)
    local a
    local needed = amount or (xPos + zPos + depth + 2)

    if ahto.fuel() == "unlimited" then
        return true
    end

    if ahto.fuel() < needed then
        for n=1,16 do
            if ahto.getItemCount(n) > 0  and ahto.refuel(n, 1) then
                while ahto.getItemCount(n) > 0 and ahto.fuel() < needed do
                    ahto.refuel(n, 1)
                end

                if ahto.fuel() >= needed then  return true  end
            end
        end

        return false
    end

    return true
end

local function tryForward()
    if not refuel() then
        print "Not enough Fuel"
        returnSupplies()
    end

    while not ahto.move(ahto.d.forward) do
        if turtle.detect() then
            if ahto.dig(ahto.d.forward) then
                if not collect() then
                    returnSupplies()
                end
            else
                return false
            end
        elseif ahto.attack(ahto.d.forward) then
            if not collect() then
                returnSupplies()
            end
        else
            sleep( 0.5 )
        end
    end

    xPos = xPos + xDir
    zPos = zPos + zDir
    return true
end

local function tryDown()
    if not refuel() then
        print "Not enough Fuel"
        returnSupplies()
    end

    while not turtle.down() do
        if turtle.detectDown() then
            if ahto.dig(ahto.d.down) then
                if not collect() then
                    returnSupplies()
                end
            else
                return false
            end
        elseif ahto.attack(ahto.d.down) then
            if not collect() then
                returnSupplies()
            end
        else
            sleep( 0.5 )
        end
    end

    depth = depth + 1
    if math.fmod( depth, 10 ) == 0 then
        print( "Descended "..depth.." metres." )
    end

    return true
end

local function turnLeft()
    ahto.turn(ahto.d.left)
    xDir, zDir = -zDir, xDir
end

local function turnRight()
    ahto.turn(ahto.d.right)
    xDir, zDir = zDir, -xDir
end

function goTo( x, y, z, xd, zd )
    while depth > y do
        if ahto.move(ahto.d.up) then
            depth = depth - 1
        elseif ahto.dig(ahto.d.up) or ahto.attack(ahto.d.up)then
            collect()
        else
            sleep( 0.5 )
        end
    end

    if xPos > x then
        while xDir ~= -1 do
            turnLeft()
        end

        while xPos > x do
            if ahto.move(ahto.d.forward) then
                xPos = xPos - 1
            elseif ahto.dig(ahto.d.forward) or ahto.attack(ahto.d.forward) then
                collect()
            else
                sleep( 0.5 )
            end
        end
    elseif xPos < x then
        while xDir ~= 1 do
            turnLeft()
        end

        while xPos < x do
            if ahto.move(ahto.d.forward) then
                xPos = xPos + 1
            elseif ahto.dig(ahto.d.forward) or ahto.attack(ahto.d.forward) then
                collect()
            else
                sleep( 0.5 )
            end
        end
    end

    if zPos > z then
        while zDir ~= -1 do
            turnLeft()
        end
        while zPos > z do
            if ahto.move(ahto.d.forward) then
                zPos = zPos - 1
            elseif ahto.dig(ahto.d.forward) or ahto.attack(ahto.d.forward) then
                collect()
            else
                sleep( 0.5 )
            end
        end
    elseif zPos < z then
        while zDir ~= 1 do
            turnLeft()
        end
        while zPos < z do
            if ahto.move(ahto.d.forward) then
                zPos = zPos + 1
            elseif ahto.dig(ahto.d.forward) or ahto.attack(ahto.d.forward) then
                collect()
            else
                sleep( 0.5 )
            end
        end
    end

    while depth < y do
        if turtle.down() then
            depth = depth + 1
        elseif ahto.dig(ahto.d.down) or ahto.attack(ahto.d.down) then
            collect()
        else
            sleep( 0.5 )
        end
    end

    while zDir ~= zd or xDir ~= xd do
        turnLeft()
    end
end

if not refuel() then
    print "Out of Fuel"
    return
end

print "Excavating..."

local reseal = false
turtle.select(1)
if ahto.dig(ahto.d.down) then
    reseal = true
end

local alternate = 0
local done = false

while not done do
    for n=1,size do
        for m=1,size-1 do
            if not tryForward() then
                done = true
                break
            end
        end

        if done then  break  end

        if n < size then
            if math.fmod(n + alternate,2) == 0 then
                turnLeft()

                if not tryForward() then
                    done = true
                    break
                end

                turnLeft()
            else
                turnRight()

                if not tryForward() then
                    done = true
                    break
                end

                turnRight()
            end
        end
    end

    if done then  break  end

    if size > 1 then
        if math.fmod(size,2) == 0 then
            turnRight()
        else
            if alternate == 0 then
                turnLeft()
            else
                turnRight()
            end

            alternate = 1 - alternate
        end
    end

    if not tryDown() then
        done = true
        break
    end
end

print "Returning to surface..."

-- Return to where we started
goTo( 0,0,0,0,-1 )
unload( false )
goTo( 0,0,0,0,1 )

-- Seal the hole
if reseal then  turtle.placeDown()  end

print( "Mined "..(collected + unloaded).." items total." )
