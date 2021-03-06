-- vim: foldmethod=marker
-- TODOs {{{1
-- TODO: folding isn't totally finished yet

-- TODO: Allcaps dirs.FORWARD and etc since they're constants?
-- TODO: Should I also allcaps DIRS and D?
-- TODO: Gravel-clearing dig.

function tablePrint(tbl, indent) -- {{{1
    -- Pretty-prints a table to the console.

    -- This isn't my code but I don't remember where I got it.
    -- Invaluable for debugging.
    if not indent then indent = 0 end

    for k, v in pairs(tbl) do
        formatting = string.rep(" ", indent) .. k .. ": "

        if type(v) == "table" then
            print(formatting)
            tprint(v, indent+1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        else
            print(formatting .. v)
        end
    end
end

function tableCopy(orig) -- {{{1
    -- Taken from: http://lua-users.org/wiki/CopyTable
    local orig_type = type(orig)
    local copy

    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[tableCopy(orig_key)] = tableCopy(orig_value)
        end
        setmetatable(copy, tableCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end

    return copy
end

function tableAppend(t, ...) -- {{{1
    -- Returns boolean success.
    -- Sets t to have the other table arguments on the end of it in order.
    for _,i in ipairs{t, ...} do
        if type(i) ~= 'table' then
            return false
        end
    end

    u = u or {}

    -- ipairs is like pairs but for numerical indicies only and guaranteed to
    -- be in order
    for _, table in ipairs{...} do
        for _, i in ipairs(table) do
            t[#t+1] = i
        end
    end

    return true
end

function tableConcat(t, ...) -- {{{1
    -- Returns t with all other table args on the end in order. Does not modify either table.
    local ct = tableCopy(t)

    tableAppend(ct, unpack{...})

    return ct
end

function inTable(v, l) -- {{{1
    for _, i in ipairs(l) do
        if i == v then
            return true
        end
    end

    return false
end

function partial(f, ...) -- {{{1
    -- lets you partially apply arguments to a function.
    local first_args = {...}

    return function(...)
        local second_args = {...}
        local full_args   = tableConcat(first_args, second_args)
        return f( unpack(full_args) )
    end
end

function inheritsFrom( baseClass ) -- {{{1
    -- based heavily on: http://lua-users.org/wiki/InheritanceTutorial
    -- call with nil to create a generic class
    local new_class = {}
    -- class_metatable
    local class_mt  = { __index = new_class }

    function new_class:init(o)
        -- Generic constructor that lets you set arbitrary properties.
        -- Don't overwrite init, instead overwrite create and call init inside to make
        -- a new instance. See Fueler for example.
        local newinst = o or {}
        setmetatable(newinst, class_mt)
        return newinst
    end

    --[[ Example create method for class constructor:

    function ExampleClass:create(property)
        return self:init{property=property}
    end

    ]]

    new_class.create = new_class.init

    if baseClass ~= nil then
        setmetatable( new_class, {__index = baseClass} )
    end

    function new_class:class()      return new_class end
    function new_class:superClass() return baseClass end

    function new_class:isa( theClass )
        -- Return true if the caller is an instance of theClass
        local b_isa     = false
        local cur_class = new_class

        while (cur_class ~= nil) and (b_isa == false) do
            if cur_class == theClass then
                b_isa = true
            else
                cur_class = cur_class:superClass()
            end
        end

        return b_isa
    end

    return new_class
end

-- direction constants
dirs = { -- {{{1
    forward  = 1,
    f        = 1,

    back     = 2,
    backward = 2,
    b        = 2,

    up       = 3,
    u        = 3,

    down     = 4,
    d        = 4,

    left     = 5,
    l        = 5,

    right    = 6,
    r        = 6,
}

-- Some aliases.
d, directions = dirs, dirs

FORWARD  = 1
F        = 1

BACK     = 2
BACKWARD = 2
B        = 2

UP       = 3
U        = 3

DOWN     = 4
D        = 4

LEFT     = 5
L        = 5

RIGHT    = 6
R        = 6

function dir2string(dir) -- {{{1
    local lookupTable = {
        [d.forward] = 'forward',
        [d.back]    = 'back',
        [d.up]      = 'up',
        [d.down]    = 'down',
        [d.left]    = 'left',
        [d.right]   = 'right',
    }

    return lookupTable[dir]
end

function isTurnDir(dir) -- {{{1
    -- this is a direction we need to turn to reach
    return inTable( dir, {dirs.left, dirs.right, dirs.back} )
end

function turn(dir) -- {{{1
    if dir == dirs.back then
        return turn(d.right) and turn(d.right)
    elseif dir == dirs.left then
        return turtle.turnLeft()
    elseif dir == dirs.right then
        return turtle.turnRight()
    else
        return false
    end
end

function turnBack(dir) -- {{{1
    -- turn back from turning in a direction
    local lookupTable = {
        [dirs.forward] = dirs.forward,
        [dirs.back]    = dirs.back,

        [dirs.up]      = dirs.up,
        [dirs.down]    = dirs.down,

        [dirs.left]    = dirs.right,
        [dirs.right]   = dirs.left,
    }

    local turnDir = lookupTable[dir]

    if turnDir == nil then
        return false
    end

    return turn(turnDir)
end

function turnDo(dir, f) -- {{{1
    -- function f will get 1 argument; direction after rotating
    local eDir = isTurnDir(dir) and dirs.f or dir

    turn(dir)

    -- in a table so if f returns multiple things they're all captured
    local return_ = { f(eDir) }

    turnBack(dir)

    -- unpack return_ from its table.
    -- return unpack{1, 2} is the same as
    -- return 1, 2
    return unpack(return_)
end

function slotDo(slot, f) -- {{{1
    local oldSlot = turtle.getSelectedSlot()

    turtle.select(slot)
    local return_ = { f() }
    turtle.select(oldSlot)

    return unpack(return_)
end

function slotDoWrapper(f) -- {{{1
    return function (slot, ...)
        -- TODO: Will this work?
        --f_with_args = partial(f, ...)
        args = {...}
        function f_with_args()
            return f( unpack(args) )
        end

        return slotDo(slot, f_with_args)
    end
end

function turnDoWrapper(f, u, d, b) -- {{{1
    -- TODO: Better name.
    -- forward, up, down, back (optional)
    -- this is for turtle functions like dig where there's dig (forward), digUp, and digDown

    return function (dir, ...)
        local funcLookupTable = {
            [dirs.forward] = f,
            [dirs.up]      = u,
            [dirs.down]    = d,
            [dirs.back]    = b,
        }

        local arg  = {...}
        local func = funcLookupTable[dir]

        -- if there's no b argument then func will be nil
        if func == nil then
            return turnDo(dir, function()
                return f( unpack(arg) )
            end)
        else
            return func( unpack(arg) )
        end
    end
end

-- turnDoWrapped functions {{{1
move    = turnDoWrapper(turtle.forward, turtle.up,        turtle.down,        turtle.back)
attack  = turnDoWrapper(turtle.attack,  turtle.attackUp,  turtle.attackDown)
place   = turnDoWrapper(turtle.place,   turtle.placeUp,   turtle.placeDown)
detect  = turnDoWrapper(turtle.detect,  turtle.detectUp,  turtle.detectDown)
inspect = turnDoWrapper(turtle.inspect, turtle.inspectUp, turtle.inspectDown)
compare = turnDoWrapper(turtle.compare, turtle.compareUp, turtle.compareDown)

-- drop(slot, direction)
-- suck(slot, direction)
-- TODO: Untested.
drop    = slotDoWrapper( turnDoWrapper(turtle.drop, turtle.dropUp, turtle.dropDown) )
suck    = slotDoWrapper( turnDoWrapper(turtle.suck, turtle.suckUp, turtle.suckDown) )

-- directly copied functions {{{1
-- copying these over directly since they already take slot parameters
getItemCount  = turtle.getItemCount
getItemSpace  = turtle.getItemSpace
getItemDetail = turtle.getItemDetail

-- seriously why is this function name so long?
fuel = turtle.getFuelLevel

function safeBlock(dir, list, isBlacklist) -- {{{1
    -- TODO: better name
    -- Returns true if there's just air.
    -- also accepts single types instead of list
    -- lets you know if the block in a direction is or isn't in a list

    isBlacklist = isBlacklist or false -- just making it explicit

    if not list then  return true  end

    return turnDo(dir, function(eDir)
        local success, block = inspect(eDir)
        local match = nil

        -- if there's no block to inspect then it's a match... because.
        if not success then  return true  end

        if type(list) == 'table' then
            match = inTable(block.name, list)
        else
            match = block.name == list
        end

        if isBlacklist then
            return not match
        else
            return match
        end
    end)
end

function dig(dir, list, isBlacklist) -- {{{1
    -- digs in a given direction unless the
    -- block is in the blacklist or it isn't
    -- in the whitelist
    -- also accepts single types instead of list
    -- digs multiple times in case there's gravel or sand

    -- dig func without black/white listing
    local _dig = turnDoWrapper(turtle.dig, turtle.digUp, turtle.digDown)

    -- Maximum number of falling blocks to dig before giving up.
    local MAX_FALLING_BLOCKS = 32

    return turnDo(dir, function(eDir)
        if not detect(eDir) then
            return true
        elseif safeBlock(eDir, list, isBlacklist) then
            for _=1, MAX_FALLING_BLOCKS do
                _dig(eDir)
                -- Pause for gravel to fall.
                os.sleep(0.5) -- TODO: Experiment with timing.

                if not detect(eDir) then return true end
            end
        end

        return false
    end)
end

function digMove(dir, list, isBlacklist) -- {{{1
    return turnDo(dir, function(eDir)
        dig(eDir, list, isBlacklist) -- returns false on dig air so not returned

        return move(eDir)
    end)
end

function equip(slot, dir, ...) -- {{{1
    -- TODO: Untested.
    -- returns false if you give it an invalid direction
    local equipLeft  = turnDoWrapper(turtle.equipLeft)
    local equipRight = turnDoWrapper(turtle.equipRight)

    if dir == dirs.l then
        -- equipLeft and equipRight don't take args yet(?) but this feels safer
        return turtle.equipLeft(slot, unpack(arg))
    elseif dir == dirs.r then
        return turtle.equipRight(slot, unpack(arg))
    else
        return false
    end
end

function refuel(slot, quantity) -- {{{1
    -- like turtle.refuel except you can specify slot and quantity default is 1, not infinity
    local refuel_ = slotDoWrapper(turtle.refuel)

    -- default quantity is 1
    quantity = quantity or 1

    return refuel_(slot, quantity)
end

fuelValues = { -- {{{1
    -- This is only a small subset of the valid fuels in the game.
    ['minecraft:lava_bucket'] = 1000,
    ['minecraft:coal_block']  =  800,
    ['minecraft:blaze_rod']   =  120,

    ['minecraft:charcoal']    =   80,
    ['minecraft:coal']        =   80,

    ['minecraft:log']         =   15,
    ['minecraft:log2']        =   15,
    ['minecraft:planks']      =   15,
}

function fuelValue(item, wholeStack) -- {{{1
    -- takes slot number, item detail, or item name E.G. "minecraft:coal"
    -- wholeStack means if you want the whole stack's fuel value
    -- returns -1 if it's an invalid item or if it doesn't know that item.
    if wholeStack == nil then  wholeStack = true  end

    local ti = type(item)
    if ti ~= 'table' then
        if ti == 'number' or ti == 'nil' then
            item = getItemDetail(item)

            if item == nil then  return 0  end
        elseif ti == 'string' then
            item = {name=item}
        end
    end

    if not wholeStack or item.count == nil then
        item.count = 1
    end

    -- 0 or -1 returns 0 so this is safe to do
    return (item.count * fuelValues[item.name]) or -1
end

Fueler = inheritsFrom() -- {{{1

function Fueler:create(fuelSlot) -- {{{2
    -- constructor
    return self:init{fuelSlot=fuelSlot}
end

function Fueler:setFuelSlot(fuelSlot) -- {{{2
    self.fuelSlot = fuelSlot
end

function Fueler:fuel() -- {{{2
    return fuel(self.fuelSlot)
end

function Fueler:fuelCheck() -- {{{2
    return self:fuel() > 0 or self:refuel(1)
end

-- Fueler:checkDoWrapper(f) {{{2
function Fueler:checkDoWrapper(f)
    return function(self,  ...)
        return self:fuelCheck() and f( unpack{...} )
    end
end

-- Fueler:fuelValue(wholeStack) {{{2
function Fueler:fuelValue(wholeStack)
    return fuelValue(self.fuelSlot, wholeStack)
end

-- Fueler:totalFuel() {{{2
function Fueler:totalFuel()
    return self:fuelValue() + self:fuel()
end

-- Fueler:refuel(quantity) {{{2
function Fueler:refuel(quantity)
    -- TODO:
    -- Make sure to keep at least 1 fuel in the slot so other items don't end up
    -- there by mistake.
    -- The problem is this means fuelValue() returns the wrong number when at 1 fuel.
    return refuel(self.fuelSlot, quantity)
end

-- Fueler:move, Fueler:digMove {{{2
Fueler.move      = Fueler:checkDoWrapper(move)
Fueler.digMove   = Fueler:checkDoWrapper(digMove)
