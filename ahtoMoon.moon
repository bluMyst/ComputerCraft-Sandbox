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

dir2string = (dir) ->
    return switch dir
        when FORWARD then 'forward'
        when BACK    then 'back'
        when UP      then 'up'
        when DOWN    then 'down'
        when LEFT    then 'left'
        when RIGHT   then 'right'

isTurnDir = (dir) ->
    return switch dir
        when LEFT  then true
        when RIGHT then true
        when BACK  then true
        else            false

turn = (dir) ->
    return switch dir
        when BACK  then turn(RIGHT) and turn(RIGHT)
        when LEFT  then turtle.turnLeft()
        when RIGHT then turtle.turnRight()
        else            false

turnBack = (dir) ->
    return switch dir
        when FORWARD then true
        when UP      then true
        when DOWN    then true

        when BACK  then turn BACK
        when LEFT  then turn RIGHT
        when RIGHT then turn LEFT
        else            false

turnDo = (dir, f) ->
    -- TODO: eDir is a horrible variable name.
    eDir = if isTurnDir(dir) then FORWARD else dir

    turn(dir)
    return_ = { f(eDir) }
    turnBack(dir)

    return unpack(return_)
