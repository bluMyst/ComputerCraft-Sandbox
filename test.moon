-- Designed to be run with busted: https://olivinelabs.com/busted/

-- It's important that these requires are in this order, because ahto requires
-- the fake turtle functions to be able to run properly.
require "unittest.turtle"
require "ahto"

-- TODO: getItemCount, getItemSpace, getItemDetail, fuel()

describe "dir2string", ->
    it "dir2string(FORWARD)", ->
        assert.is.equal dir2string(FORWARD), 'forward'

    it "dir2string(BACK)", ->
        assert.is.equal dir2string(BACK), 'back'

    it "dir2string(UP)", ->
        assert.is.equal dir2string(UP), 'up'

    it "dir2string(DOWN)", ->
        assert.is.equal dir2string(DOWN), 'down'

    it "dir2string(LEFT)", ->
        assert.is.equal dir2string(LEFT), 'left'

    it "dir2string(RIGHT)", ->
        assert.is.equal dir2string(RIGHT), 'right'

describe "isTurnDir", ->
    it "isTurnDir should return false here", ->
        for dir in *{UP, DOWN, FORWARD}
            assert.is_false isTurnDir dir

    it "isTurnDir should return true here", ->
        for dir in *{LEFT, RIGHT, BACK}
            assert.is_true isTurnDir dir

it "partial", ->
    testFunc = (...) -> {...}

    testFuncFoo    = partial testFunc, 'foo'
    testFuncFooBar = partial testFunc, 'foo', 'bar'

    assert.is.same testFuncFoo('baz'),    {'foo', 'baz'}
    assert.is.same testFuncFooBar('baz'), {'foo', 'bar', 'baz'}

    -- Test them again to make sure partial can handle multiple calls. Why not?
    assert.is.same testFuncFoo('baz'),    {'foo', 'baz'}
    assert.is.same testFuncFooBar('baz'), {'foo', 'bar', 'baz'}

describe "direction constants", ->
    it "dirs aliases", ->
        assert.is.equals dirs, d, directions

    it "forward", ->
        assert.is.equals FORWARD, F, dirs.forward, dirs.f

    it "back", ->
        assert.is.equals BACK, BACKWARD, B, dirs.back, dirs.backward, dirs.b

    it "up", ->
        assert.is.equals UP, U, dirs.up, dirs.u

    it "down", ->
        assert.is.equals DOWN, D, dirs.down, dirs.d

    it "left", ->
        assert.is.equals LEFT, L, dirs.left, dirs.l

    it "right", ->
        assert.is.equals RIGHT, R, dirs.right, dirs.r

describe "turn tests", ->
    -- Reset the heading before each test and after the describe block ends.
    resetHeading = -> turtleAPIEmulator.heading = 0
    before_each resetHeading
    teardown resetHeading

    describe "turn()", ->
        it "left", ->
            assert.is_true turn LEFT
            assert.is.equal turtleAPIEmulator.heading, 270

        it "right", ->
            assert.is_true turn RIGHT
            assert.is.equal turtleAPIEmulator.heading, 90

        it "back", ->
            assert.is_true turn BACK
            assert.is.equal turtleAPIEmulator.heading, 180

        it "invalid turns should return false", ->
            assert.is_false turn UP
            assert.is_false turn DOWN
            assert.is_false turn FORWARD

    describe "turnDo()", ->
        it "left", ->
            turnDo LEFT, ->
                assert.is.equal turtleAPIEmulator.heading, 270

            assert.is.equal turtleAPIEmulator.heading, 0

        it "right", ->
            turnDo RIGHT, ->
                assert.is.equal turtleAPIEmulator.heading, 90

            assert.is.equal turtleAPIEmulator.heading, 0

        it "back", ->
            turnDo BACK, ->
                assert.is.equal turtleAPIEmulator.heading, 180

            assert.is.equal turtleAPIEmulator.heading, 0

    describe "turnDoWrapper", ->
        fail = ->
            assert.is_true false

        noTurn = ->
            assert.is.equal turtleAPIEmulator.heading, 0

        turnLeft = ->
            assert.is.equal turtleAPIEmulator.heading, 270

        turnRight = ->
            assert.is.equal turtleAPIEmulator.heading, 90

        turnAround = ->
            assert.is.equal turtleAPIEmulator.heading, 180

        describe "no turn", ->
            it "forward", -> turnDoWrapper(noTurn, fail, fail, fail)(FORWARD)
            it "up",      -> turnDoWrapper(fail, noTurn, fail, fail)(UP)
            it "down",    -> turnDoWrapper(fail, fail, noTurn, fail)(DOWN)
            it "back",    -> turnDoWrapper(fail, fail, fail, noTurn)(BACK)

        describe "turn", ->
            it "left", ->   turnDoWrapper(turnLeft, fail, fail, fail)(LEFT)
            it "right", ->  turnDoWrapper(turnRight, fail, fail, fail)(RIGHT)
            it "around", -> turnDoWrapper(turnAround, fail, fail)(BACK)

describe "slot-modifying", ->
    -- Reset the heading before each test and after the describe block ends.
    resetSlot = -> turtleAPIEmulator.selectedSlot = 1
    before_each resetSlot
    teardown resetSlot

    it "slotDo", ->
        for i in *{1, 2, 14, 16}
            slotDo i, ->
                assert.is.equal turtleAPIEmulator.selectedSlot, i

            assert.is.equal turtleAPIEmulator.selectedSlot, 1

    it "slotDoWrapper", ->
        slotDoTest = slotDoWrapper (targetSlot, ...) ->
            assert.is.equal turtleAPIEmulator.selectedSlot, targetSlot
            return {...}

        assert.is.same slotDoTest(2, 2, 'foo', 'bar'), {'foo', 'bar'}
        assert.is.same slotDoTest(1, 1, 'baz'), {'baz'}
        assert.is.same slotDoTest(16, 16), {}

describe "fuel-modifying", ->
    resetStuff = ->
        turtleAPIEmulator.fuelLevel = 0
        turtleAPIEmulator.heading = 0
        turtleAPIEmulator.pos = {0, 0, 0}
        turtleAPIEmulator.selectedSlot = 1

    before_each resetStuff
    teardown resetStuff

    it "fuel()", ->
        for i=1, 16
            turtleAPIEmulator.fuelLevel = i
            assert.is.equal fuel(), turtleAPIEmulator.fuelLevel

    describe "Fueler", ->
        -- I hope this doesn't overwrite the old before_each!
        local fueler

        before_each ->
            fueler = Fueler\create 16

        it "move forward a bunch", ->
            for _=1, 16
                fueler\move FORWARD
                assert.is_true turtleAPIEmulator.fuelLevel >= 0

            assert.is.equal turtleAPIEmulator.pos[3], 16
