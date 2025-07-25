local mainChest = "left"

local function searchAndOutput(itemid, amount) -- Used to check for items and output them
    local names = peripheral.getNames()
    local amountLeft = amount

    for name in names do -- Iterates through
    
        if amountLeft <= 0 then
            break
        end

        if string.find(name, ":") and amountLeft > 0 then -- Removes any directional peripherals
            local store = peripheral.wrap(name) -- References the storage object itself
            
            for slot,item in pairs(store.list()) do
                if item.name == itemid then
                    store.pushItems(mainChest, slot, amountLeft)
                    amountLeft = math.max(0, amountLeft - slot.count)
                    write("Transferred "..math.min(amountLeft, slot.count).." items..")

                    if amountLeft <= 0 then
                        break
                    end

                end
            end

        end
    end

    if amountLeft == 0 then
        write("Transferred all items!")
    elseif amountLeft < amount then
        write("Could not transfer all items.")
    else
        write("Out of stock!")
    end
end

while true do
    write("Request Format:\n  itemmod:item integer\n  ")
    local itemid, amount = string.gmatch( read(), "%a+" ) -- Splits item into itemid and amount
    print("Obtaining",itemid)

    searchAndOutput(itemid,amount)
end