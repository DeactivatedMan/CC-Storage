local mainChest = "minecraft:chest_12"
local inputChest = peripheral.find(mainChest)

local function iterate(itemid, originSlot, amount, filter)
    write("function called\n")
    local names = peripheral.getNames()
    write("names obtained, ".. table.concat(names,"\n") )
    local amountLeft = amount

    write("loop start\n")
    for _,name in pairs(names) do -- Iterates through
        write("looped\n")
    
        if amountLeft <= 0 then
            break
        end

        if string.find(name, ":") and amountLeft > 0 then -- Removes any directional peripherals
            write("Looking in "..name.."\n")
            local store = peripheral.wrap(name) -- References the storage object itself
            
            if filter then -- Checks specifically for slots with the same itemid
                for slot,item in pairs(store.list()) do
                    write("looped B\n")
                    write(item.name.."at slot"..slot.."\n")
                    if item.name == itemid then
                        store.pullItems(mainChest, originSlot, amountLeft, slot)
                        write("Transferred "..math.min(item.maxCount-item.count, amountLeft).." items..\n")
                        amountLeft = math.max(0, amountLeft - (item.maxCount-item.count) )

                        if amountLeft <= 0 then
                            break
                        end

                    end
                end
            elseif #store.list() < store.size() then -- Checks specifically all blank slots
                for slot=1,store.size() do
                    if not store.getItemDetail(slot) then
                        store.pullItems(mainChest, originSlot, amountLeft, slot)
                        write("Transferred "..math.max(amountLeft,64).." items..\n")
                        amountLeft = math.max(0, amountLeft-64)

                        if amountLeft <= 0 then
                            break
                        end
                    end
                end
            end

        end
    end

    return amountLeft
end

while true do

    local items = peripheral.wrap("minecraft:chest_12").list()
    write("items is of type "..type(items).." and contains "..items.."\n")

    if items ~= {} then
        for slot,item in pairs(items) do
            --searchAndInput(item.name, slot, item.count)

            local amountLeft = item.count
            amountLeft = iterate(item.name, slot, amountLeft, true)

            if amountLeft > 0 then
                amountLeft = iterate(item.name, slot, amountLeft, false)
            end

            write("amountLeft is of type "..type(amountLeft).." and contains "..amountLeft.."\n")
            if amountLeft == 0 then
                write("Transferred all items!\n")
            elseif amountLeft < item.count then
                write("Could not transfer all items.\n")
                break
            else
                write("Out of storage!\n")
                break
            end
        end
    end

    sleep(3)
end