--TODO: depth doesn't seem to be recorded properly.

ts = dofile("turtlestuff.lua")

max_depth = 30
print("Digging a mineshaft for "..max_depth.." meters.")

checker = ts.FuelChecker:new()
depth = 0

function digOne()
    local result = false

    if not ts:tryDig(ts.FORWARD) then
        return false
    end

    checker:forward()
    return ts:tryDig(ts.UP)
end

function exitShaft(depth)
    ts.turn.back()

    for _=1,depth do
        checker:forward()
        if not ts:tryDig(ts.FORWARD) or checker:getFuelLevel() <= 1 then
            break
        end
    end

    turtle.turnLeft()
    digOne()
    ts.turn.back()
end

while true do
    if digOne() then
        depth = depth+1
        if depth >= max_depth then
            exitShaft(depth)
            break
        elseif checker:getFuelLevel() <= depth and checker:getFuelCount() <= 0 then
            print("Not enough fuel to finish shaft. Exiting...")
            exitShaft(depth)
            break
        end
    else
        print("Failed to dig for unknown reasons.")
        break
    end
end
