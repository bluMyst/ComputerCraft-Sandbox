-- Pretend to be the ComputerCraft turtle API. For unit testing.

class Turtle
    -- Heading is where the turtle is facing. 0 is north, 90 is east, etc.
    @@heading = 0
    @@selectedSlot = 1

    -- These are for if you want to simulate inputs. Helpful for unittesting.
    -- For example, when @dig gets called, it returns the result of
    -- @digHandler(1), because 1 is agreed to be FORWARD by my other code.
    --
    -- The handlers will get called with either 1 (FORWARD), 3 (UP), or 4
    -- (DOWN).
    @digHandler     = ->
    @detectHandler  = ->
    @inspectHandler = ->
    @placeHandler   = ->
    @suckHandler    = ->
    @dropHandler    = ->
    @attackHandler  = ->

    @setHeading: (newHeading) =>
        -- This also works for negative values. -90 % 360 == 270. Cool!
        @@heading = newHeading % 360

    turnLeft:  => @@setHeading @@heading - 90
    turnRight: => @@setHeading @@heading + 90

    setSelectedSlot: (slot) => @@selectedSlot = slot
    getSelectedSlot:        => @@selectedSlot

    forwardUpDownHandler = (func) ->
        -- This lets you split a handler into three little sub-functions. One
        -- for @dig, one for @digUp, and one for @digDown. Or inspect or detect
        -- or whatever.
        --
        -- Note that the function isn't called with a "self". This runs
        -- self.handler, rather than self\handler.

        forward = => func 1
        up      = => func 3
        down    = => func 4

        return forward, up, down

    -- TODO: Is this passed by reference or by value? This approach probably
    -- won't work.
    @dig,      @digUp,      @digDown     = forwardUpDownWrapper @digHandler
    @detect,   @detectUp,   @detectDown  = forwardUpDownWrapper @detectHandler
    @inspect,  @inspectUp,  @inspectDown = forwardUpDownWrapper @inspectHandler
    @place,    @placeUp,    @placeDown   = forwardUpDownWrapper @placeHandler
    @suck,     @suckUp,     @suckDown    = forwardUpDownWrapper @suckHandler
    @drop,     @dropUp,     @dropDown    = forwardUpDownWrapper @dropHandler
    @attack,   @attackUp,   @attackDown  = forwardUpDownWrapper @attackHandler
