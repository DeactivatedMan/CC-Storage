local mainChest = "right"
local inputChest = peripheral.find(mainChest)

local function iterate(itemid, originSlot, amount, filter)
    local names = peripheral.getNames()
    local amountLeft = amount

    for _,name in pairs(names) do -- Iterates through
    
        if amountLeft <= 0 then
            break
        end

        if string.find(name, ":") and amountLeft > 0 then -- Removes any directional peripherals
            local store = peripheral.wrap(name) -- References the storage object itself
            
            if filter then
                for slot,item in pairs(store.list()) do
                    if item.name == itemid then
                        store.pullItems(mainChest, originSlot, amountLeft, slot)
                        write("Transferred "..math.min(item.maxCount-item.count, amountLeft).." items..")
                        amountLeft = math.max(0, amountLeft - (item.maxCount-item.count) )

                        if amountLeft <= 0 then
                            break
                        end

                    end
                end
            elseif #store.list() < store.size then
                for slot=1,store.size() do
                    if not store.getItemDetail(slot) then
                        store.pullItems(mainChest, originSlot, amountLeft, slot)
                        write("Transferred "..math.max(amountLeft,64).." items..")
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
    --write("Request Format:\n  itemmod:item integer\n  ")
    --local itemid, amount = string.gmatch( read(), "%a+" ) -- Splits item into itemid and amount
    --print("Obtaining",itemid)

    local items = peripheral.wrap("right").list()

    if items ~= {} then
        for slot,item in pairs(items) do
            --searchAndInput(item.name, slot, item.count)

            local amountLeft = item.count
            amountLeft = iterate(itemid, originSlot, amountLeft, false)

            if amountLeft > 0 then
                amountLeft = iterate(itemid, originSlot, amountLeft, true)
            end

            if amountLeft == 0 then
                write("Transferred all items!")
            elseif amountLeft < item.count then
                write("Could not transfer all items.")
                break
            else
                write("Out of storage!")
                break
            end
        end
    end
end