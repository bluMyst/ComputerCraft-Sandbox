-- Pretend to be the ComputerCraft turtle API. For unit testing.

export class Turtle
    -------------------------------------------------------------
    -------------------- Constants and new() --------------------
    -------------------------------------------------------------
    new: =>
        -- Heading is where the turtle is facing. 0 is north, 90 is east, etc.
        @heading = 0
        @selectedSlot = 1
        @pos = {0, 0, 0}
        @fuelLevel = 0

        -- This is necessary because it generates all of the methods that call
        -- handlers. Without this, @dig, @placeDown, etc. will just be nil.
        @clearAllHandlers()

    ---------------------------------------------------
    -------------------- Handlers. --------------------
    ---------------------------------------------------
    -- These are for if you want to simulate inputs. Helpful for unittesting.
    -- For example, when @dig gets called, it returns the result of
    -- @digHandler(1), because 1 is agreed to be FORWARD by my other code.
    --
    -- The handlers will get called with either 1 (FORWARD), 3 (UP), or 4
    -- (DOWN).
    setXHandler: (x, handler) =>
        -- x is a string like 'suck', 'drop', 'attack', etc.
        @[x.."Handler"] = handler

        @[x]         = => handler 1
        @[x.."Up"]   = => handler 2
        @[x.."Down"] = => handler 3

    setDigHandler:      (handler) => setXHandler 'dig',      handler
    setDetectHandler:   (handler) => setXHandler 'detect',   handler
    setInspectHandler:  (handler) => setXHandler 'inspect',  handler
    setPlaceHandler:    (handler) => setXHandler 'place',    handler
    setSuckHandler:     (handler) => setXHandler 'suck',     handler
    setDropHandler:     (handler) => setXHandler 'drop',     handler
    setAttackHandler:   (handler) => setXHandler 'attack',   handler

    clearAllHandlers: =>

        -- A function that does nothing.
        nop = ->

        for i in *{'dig', 'detect', 'inspect', 'place',
                   'suck', 'drop', 'attack'}
            @setXHandler i, nop

    -------------------------------------------------------------
    -------------------- Moving and turning. --------------------
    -------------------------------------------------------------
    turn: (angle) =>
        -- This also works for negative values. -90 % 360 == 270. Cool!
        @heading = (@heading + angle) % 360

    move: (delta, useFuel=true) =>
        if useFuel and not @useFuel(1)
            return false

        for i, v in ipairs(delta)
            @pos[i] += v

        return true

    turnLeft:  => @turn -90
    turnRight: => @turn  90

    -- TODO: Fuel checks for forward, back, etc.
    moveForward: (distance) =>
        -- Move relative to the current heading. Used for forward (distance 1)
        -- and back (distance -1) because they move in different directions
        -- depending on where the turtle is facing.

        if @heading == 0
            --    z
            -- -x ^ x
            --   -z
            @move {0, 0, distance}
        elseif @heading == 90
            --    z
            -- -x -> x
            --   -z
            @move {distance, 0, 0}
        elseif @heading == 180
            --    z
            -- -x V x
            --   -z
            @move {0, 0, -distance}
        elseif @heading == 270
            --     z
            -- -x <- x
            --    -z
            @move {-distance, 0, 0}

    up:   => @move {0,  1, 0}
    down: => @move {0, -1, 0}

    forward:  => moveForward 1
    back:     => moveForward -1

    -------------------------------------------------------------
    -------------------- Inventory and fuel. --------------------
    -------------------------------------------------------------
    setSelectedSlot: (slot) => @selectedSlot = slot
    getSelectedSlot:        => @selectedSlot

    getFuelLevel: => @fuelLevel

    refuel: =>
        -- Only gives a tiny amount of fuel at a time, to stress-test refueling
        -- code.
        @fuelLevel += 4

    useFuel: (amount=1) =>
        -- Returns whether we have that much fuel available. If so, subtracts
        -- that much from our @fuelLevel.
        --
        -- Call this inside of stuff like @forward to make sure we have enough.

        if @fuelLevel - amount < 0
            return false
        else
            @fuelLevel -= amount
            return true
