if not os.loadAPI 'ahto' then
    print 'FATAL: unable to load ahto api'
    exit()
end

-- ---------- CONFIG HERE ----------

-- Maximum distance to mine.
MAX_DIST  = 32

-- Slot to get fuel from.
FUEL_SLOT = 16

-- ---------- END OF CONFIG ----------

-- What we're looking for.
ORE_TYPES = {
    "minecraft:emerald_ore",
    "minecraft:lapis_ore",
    "minecraft:redstone_ore",
    "minecraft:coal_ore",

    "minecraft:iron_ore",
    "minecraft:gold_ore",
    "minecraft:diamond_ore",

    "minecraft:nether_quartz_ore",
}

-- Stuff we can safely tunnel through.
ROCK_TYPES = {
    "minecraft:dirt",
    "minecraft:stone",

    "minecraft:sand",
    "minecraft:gravel",

    "minecraft:netherrack",
}

-- Obviously it's safe to dig up ores.
ahto.tableAppend(ROCK_TYPES, ORE_TYPES)



function fatal(s)
    print("FATAL: "..s)
    exit() -- TODO: This doesn't work.
end

function error_(s) print("ERROR: "..s) end

dist = 0 -- distance travelled from start
fueler = ahto.Fueler:create(FUEL_SLOT)

function errorWrap(f, verb)
    return (function (dir, ...)
        if not f(dir, unpack{...}) then
            error_("unable to "..verb.." in direction: "..ahto.dir2string(dir))
            return false
        end

        return true
    end)
end

move    = errorWrap(ahto.partial(fueler.move,    fueler), 'move')
digMove = errorWrap(ahto.partial(fueler.digMove, fueler), 'digMove')
dig     = errorWrap(ahto.dig, 'dig')

for _=1, MAX_DIST do
    if fueler:totalFuel() <= dist then
        print "Nearly out of fuel."
        break
    end

    if not digMove(ahto.dirs.forward, ROCK_TYPES) then break end
    dist = dist + 1
    if not dig(ahto.dirs.up, ROCK_TYPES) then break end
end

print "Returning to base."
ahto.turnDo(ahto.dirs.back, function (eDir)
    for _=1, dist do
        while not digMove(eDir, ROCK_TYPES) do os.sleep(0.2) end
    end
end)
