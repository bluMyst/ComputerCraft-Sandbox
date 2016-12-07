-- to be part of a store interface. Prints a reciept for a customer.

function findPrinter()
    local sides = ['top', 'bottom', 'left', 'right', 'front', 'back']

    for i=0, table.maxn(sides) do
        if peripheral.getType(sides[i]) == 'printer' then
            return sides[i]
        end

        return nil
    end
end

p = findPrinter()
if p = nil then exit() end
