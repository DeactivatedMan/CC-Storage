local mainChest = "minecraft:chest_14"

local function searchAndOutput(itemid, amount) -- Used to check for items and output them
    local names = peripheral.getNames()
    local amountLeft = string.tointeger(amount)

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
                    write("Transferred "..math.min(amountLeft, slot.count).." items..\n")

                    if amountLeft <= 0 then
                        break
                    end

                end
            end

        end
    end

    if amountLeft == 0 then
        write("Transferred all items!\n")
    elseif amountLeft < amount then
        write("Could not transfer all items.\n")
    else
        write("Out of stock!\n")
    end
end

local function splitItemString(input)
    local first, second = input:match("^(%S+)%s+(%S+)$")
    if first and second then
        return { first, second }
    else
        return { input, "16" }
    end
end


write("\nSelf attempt: "..table.concat(splitItemString("minecraft:chest 1")", ").."\n\n")

while true do
    write("Request Format:\n  itemmod:item integer\n  ")
    local req = read()
    write("Message inputted: "..req.."\n")
    local itemid, amount = splitItemString(req)


    if not string.find(itemid, ":") then
        write("Could not find required : in itemid, did you spell it wrong?\n")
    elseif amount:find("%D") then
        write("Amount entered contains non-integer characters, did you spell it wrong?\n")
    else
        write("Search and output started for "..amount.." "..itemid.."(s)\n")
        searchAndOutput(itemid,amount)
    end
end