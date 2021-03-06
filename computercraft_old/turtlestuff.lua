ts = {
    FORWARD = "forward",
    BACK = "back",
    UP = "up",
    DOWN = "down",
    LEFT = "left",
    RIGHT = "right",
}

ts.turn = {
    [ts.LEFT] = turtle.turnLeft,
    [ts.RIGHT] = turtle.turnRight,
    [ts.BACK] = function()
        turtle.turnLeft()
        turtle.turnLeft()
    end,
}

ts.opposites = {
    [ts.FORWARD] = ts.BACK,
    [ts.UP] = ts.DOWN,
    [ts.LEFT] = ts.RIGHT,
}

for k, v in pairs(ts.opposites) do
    ts.opposites[v] = k
end

ts.doDir = function(self, dir, func)
    local result
    self.turn[dir]()
    result = func()
    self.turn[opposites[dir]]()
    return result
end

ts.move = {
    [ts.FORWARD] = turtle.forward,
    [ts.BACK] = turtle.back,
    [ts.UP] = turtle.up,
    [ts.DOWN] = turtle.down,
    [ts.LEFT] = function() return ts:doDir(ts.LEFT, turtle.forward) end,
    [ts.RIGHT] = function() return ts:doDir(ts.RIGHT, turtle.forward) end,
}

ts.detect = {
    [ts.FORWARD] = turtle.detect,
    [ts.BACK] = function() return ts:doDir(ts.BACK, turtle.detect) end,
    [ts.UP] = turtle.detectUp,
    [ts.DOWN] = turtle.detectDown,
    [ts.LEFT] = function() return ts:doDir(ts.LEFT, turtle.detect) end,
    [ts.RIGHT] = function() return ts:doDir(ts.RIGHT, turtle.detect) end,
}

ts.dig = {
    [ts.FORWARD] = turtle.dig,
    [ts.BACK] = function() return ts:doDir(ts.BACK, turtle.dig) end,
    [ts.UP] = turtle.digUp,
    [ts.DOWN] = turtle.digDown,
    [ts.LEFT] = function() return ts:doDir(ts.LEFT, turtle.dig) end,
    [ts.RIGHT] = function() return ts:doDir(ts.RIGHT, turtle.dig) end,
}

ts.tryDig = function(self, dir)
    local MAXGRAVEL = 20
    local result
    local detect = self.detect[dir]
    local dig = self.dig[dir]

    dig()
    result = not detect()

    if dir == self.FORWARD and not result then
        print("Possibly dug some gravel. Let's try to get the rest of it...")
        for i=1,MAXGRAVEL do
            dig()
            result = not detect()

            if result then
                print("Gravel cleared!")
                return true
            end
        end

        if not result then
            print("Failed to clear the 'gravel' after "..MAXGRAVEL.." tries.")
            print("It was probably bedrock or something.")
            return false
        end
    else
        return result
    end
end

ts.FuelChecker = {
    new = function(self, slot)
        local o = {}
        o.slot = slot or 1
        setmetatable(o, self)
        self.__index = self
        return o
    end,

    getFuelCount = function(self)
        return turtle.getItemCount(self.slot)-1
    end,

    check = function(self)
        if turtle.getFuelLevel() > 0 then
            return true
        elseif self.slot > 0 and self:getFuelCount(self.slot) > 0 then
            -- checks if the slot has > 1 items so no items will be picked up in that slot later.
            local oldFuel = turtle.getFuelLevel()
            turtle.select(self.slot)
            turtle.refuel(1)
            self.fuelPerItem = turtle.getFuelLevel() - oldFuel
            return true
        else
            print("<= 1 items found in fuel slot "..self.slot..".")
            print("Exiting...")
            return false
        end
    end,

    getFuelLevel = function(self)
        if self.fuelPerItem then
            return (self:getFuelCount() * self.fuelPerItem) + turtle.getFuelLevel()
        else
            return turtle.getFuelLevel()
        end
    end,
}

for k, v in pairs(ts.move) do
    ts.FuelChecker[k] = function (self)
        local result = v()
        self:check()
        return result
    end
end

return ts
