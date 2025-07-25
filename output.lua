local mainChest = "minecraft:chest_18"

local function searchAndOutput(itemid, amount) -- Used to check for items and output them
    local names = peripheral.getNames()
    local amountLeft = amount

    for _,name in pairs(names) do -- Iterates through
    
        if amountLeft <= 0 then
            return amountLeft
        end

        if string.find(name, ":") and amountLeft > 0 and name ~= mainChest then -- Removes any directional peripherals
            local store = peripheral.wrap(name) -- References the storage object itself
            
            for slot,item in pairs(store.list()) do
                if item.name == itemid then
                    item = store.getItemDetail(slot) -- I hate this but it has to be here
                    store.pushItems(mainChest, slot, amountLeft)
                    amountLeft = math.max(0, amountLeft - item.count)
                    --write("Transferred "..math.min(amountLeft, item.count).." items..\n")
                    
                    if amountLeft <= 0 then
                        return amountLeft
                    end

                end
            end

        end
    end

    return amountLeft
end

local function splitItemString(input)
    local first, second = input:match("^(%S+)%s+(%S+)$")
    if first and second then
        return first, second
    else
        return input, "16"
    end
end


--write("\nSelf attempt: "..table.concat(splitItemString("minecraft:chest 1")", ").."\n\n")

while true do
    write("\nRequest Format:\n  itemmod:item integer\n  ")
    local req = read()
    write("Message inputted: "..req.."\n")
    local itemid, amount = splitItemString(req)

    sleep(1)
    if not string.find(itemid, ":") then
        write("Could not find required : in itemid, did you spell it wrong?\n")
    elseif amount:find("%D") then
        write("Amount entered contains non-integer characters, did you spell it wrong?\n")
    else
        write("Search and output started for "..amount.." "..itemid.."(s)\n")
        sleep(1)
        local amountLeft = searchAndOutput(itemid,tonumber(amount))

        if amountLeft == 0 then
            write("\nTransferred all items!\n")
        elseif amountLeft < tonumber(amount) then
            write("\nCould not transfer all items.\n")
        else
            write("\nOut of stock!\n")
        end
    end
    sleep(1)
end