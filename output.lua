local mainChest = "minecraft:barrel_1"

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
                item = store.getItemDetail(slot) -- I hate this but it has to be here
                if item.name:find(itemid) or item.displayName:find(itemid) then
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
    local lastSpace = input:find(" [^ ]*$")

    if lastSpace then
        local first = input:sub(1, lastSpace -1)
        local second = input:sub(lastSpace +1)

        return first, second
    else
        return input, "1"
    end
end


--write("\nSelf attempt: "..table.concat(splitItemString("minecraft:chest 1")", ").."\n\n")

while true do
    write("\nRequest Formats:\n A]     itemmod:item integer\n B]     itemname integer\n\n > ")
    local req = read()
    write("Message inputted: "..req.."\n")
    local itemid, amount = splitItemString( string.lower(req) )

    sleep(1)
    --if not string.find(itemid, ":") then
    --    write("Could not find required : in itemid, did you spell it wrong?\n")
    --elseif amount:find("%D") then
    if amount:find("%D") then
        write("Amount entered contains non-integer characters, did you spell it wrong?\n")
    else
        write("Looking for: "..amount.."x "..itemid.."\n")
        sleep(1)
        local amountLeft = searchAndOutput(itemid,tonumber(amount))

        if amountLeft == 0 then
            write("\nTransferred all items!\n")
        elseif amountLeft < tonumber(amount) then
            write("\nCould not transfer all items.\n")()
        else
            write("\nOut of stock!\n")
        end
    end
    sleep(1)
end