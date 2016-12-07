ts = turtlestuff

commands = {
    f = turtle.forward,
    b = turtle.back,
    l = turtle.turnLeft,
    r = turtle.turnRight,
    u = turtle.up,
    d = turtle.down,
    df = turtle.dig,
    du = turtle.digUp,
    dd = turtle.digDown,
    x = function () os.exit(0) end,
}

function split(string)
    local result = {}
    for i in string:gmatch('%w+') do
        table.insert(result, i)
    end

    return result
end

--[[ function usage()
    print('usage: m <command> [number of times] [--help]')
end

function help()
    usage()
    print('')
    print('<command> can be any of:')
    print('    [f]orward')
    print('    [b]ack')
    print('    [l]eft')
    print('    [r]ight')
    print('    [u]p')
    print('    [d]own')
    print('    [d]ig [f]orward')
    print('    [d]ig [u]p')
    print('    [d]ig [d]own')
    print('    e[x]it')
    print('')
    print('If [number of times] is omitted, it is assumed to be 1.')
end ]]

while true do
    io.write('$ ')
    input = split(io.read())

    input[2] = input[2] or 1

    if commands[input[1]] ~= nil then
        for i=1,tonumber(input[2]) do
            commands[input[1]]()
        end
    else
        print("Unknown command: '"..input.."'")
        os.exit(0)
    end
end
