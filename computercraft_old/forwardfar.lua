os.loadAPI("turtlestuff")

checker = turtlestuff.FuelChecker:new()

while not turtle.detect() do
    if not checker:forward() then exit() end
end
