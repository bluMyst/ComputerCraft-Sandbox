export dirs = {
    forward:   1,
    f:         1,

    back:      2,
    backward:  2,
    b:         2,

    up:        3,
    u:         3,

    down:      4,
    d:         4,

    left:      5,
    l:         5,

    right:     6,
    r:         6,
}

-- Some aliases.
export d, directions = dirs, dirs

export FORWARD  = 1
export F        = 1

export BACK     = 2
export BACKWARD = 2
export B        = 2

export UP       = 3
export U        = 3

export DOWN     = 4
export D        = 4

export LEFT     = 5
export L        = 5

export RIGHT    = 6
export R        = 6

export dir2string = (dir) ->
    return switch dir
        when FORWARD then 'forward'
        when BACK    then 'back'
        when UP      then 'up'
        when DOWN    then 'down'
        when LEFT    then 'left'
        when RIGHT   then 'right'

export isTurnDir = (dir) ->
    return switch dir
        when LEFT  then true
        when RIGHT then true
        when BACK  then true
        else            false

export turn = (dir) ->
    return switch dir
        when BACK  then turn(RIGHT) and turn(RIGHT)
        when LEFT  then turtle.turnLeft()
        when RIGHT then turtle.turnRight()
        else            false

export turnBack = (dir) ->
    return switch dir
        when FORWARD then true
        when UP      then true
        when DOWN    then true

        when BACK  then turn BACK
        when LEFT  then turn RIGHT
        when RIGHT then turn LEFT
        else            false

export turnDo = (dir, f) ->
    -- TODO: eDir is a horrible variable name.
    eDir = if isTurnDir(dir) then FORWARD else dir

    turn dir
    return_ = { f eDir }
    turnBack dir

    return unpack return_

export slotDo = (slot, f) ->
    oldSlot = turtle.getSelectedSlot()

    turtle.select slot
    return_ = { f() }
    turtle.select oldSlot

    return unpack return_

export slotDoWrapper = (f) ->
    return (slot, ...) ->
        f_with_args = -> f ...
        return slotDo slot, f_with_args

export turnDoWrapper = (f, u, d, b=nil) ->
    -- TODO: Better name.
    -- forward, up, down, back (optional)
    -- this is for turtle functions like dig where there's dig (forward), digUp, and digDown

    return (dir, ...) ->
        func = switch dir
            when FORWARD then f
            when UP      then u
            when DOWN    then d
            when BACK    then b
            else              nil

        -- If we need to turn to reach a certain direction, then we should
        -- turnDo it.
        if func == nil
            return turnDo dir, -> f ...

        return func ...

-- turnDoWrapped functions
export move    = turnDoWrapper turtle.forward, turtle.up,        turtle.down,        turtle.back
export attack  = turnDoWrapper turtle.attack,  turtle.attackUp,  turtle.attackDown
export place   = turnDoWrapper turtle.place,   turtle.placeUp,   turtle.placeDown
export detect  = turnDoWrapper turtle.detect,  turtle.detectUp,  turtle.detectDown
export inspect = turnDoWrapper turtle.inspect, turtle.inspectUp, turtle.inspectDown
export compare = turnDoWrapper turtle.compare, turtle.compareUp, turtle.compareDown

-- slotDoWrapped functions
-- TODO: Untested.
export drop = slotDoWrapper( turnDoWrapper(turtle.drop, turtle.dropUp, turtle.dropDown) )
export suck = slotDoWrapper( turnDoWrapper(turtle.suck, turtle.suckUp, turtle.suckDown) )
-- E.G.:
-- drop(slot, direction)
-- suck(slot, direction)
