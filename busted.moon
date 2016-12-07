require "ahto"

describe "dir2string", ->
    it "dir2string(FORWARD)", ->
        assert.is_true dir2string(FORWARD) == 'forward'

    it "dir2string(BACK)", ->
        assert.is_true dir2string(BACK) == 'back'

    it "dir2string(UP)", ->
        assert.is_true dir2string(UP) == 'up'

    it "dir2string(DOWN)", ->
        assert.is_true dir2string(DOWN) == 'down'

    it "dir2string(LEFT)", ->
        assert.is_true dir2string(LEFT) == 'left'

    it "dir2string(RIGHT)", ->
        assert.is_true dir2string(RIGHT) == 'right'

describe "isTurnDir", ->
    it "isTurnDir should return false here", ->
        for dir in *{UP, DOWN, FORWARD}
            assert.is_false isTurnDir dir

    it "isTurnDir should return true here", ->
        for dir in *{LEFT, RIGHT, BACK}
            assert.is_true isTurnDir dir

describe "turn", ->
    pending()

describe "turnBack", ->
    pending()
