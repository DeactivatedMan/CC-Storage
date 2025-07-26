local mainChest = "minecraft:barrel_1"

local function searchAndOutput(itemid, amount, isEnchant) -- Used to check for items and output them
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

                if isEnchant and item.name == "minecraft:enchanted_book" then -- Checks if enchanted_book and requested enchantment
                    local enchantments = item.enchantments
                    for _,enchant in pairs(enchantments) do
                        if enchant.name:find(itemid) or string.lower(item.displayName):find(itemid) then
                            store.pushItems(mainChest, slot, 1)
                            amountLeft = math.max(0, amountLeft - 1)

                            if amountLeft <= 0 then
                                return amountLeft
                            end
                        end
                    end
                else

                    if item.name:find(itemid) or string.lower(item.displayName):find(itemid) then
                        store.pushItems(mainChest, slot, amountLeft)
                        amountLeft = math.max(0, amountLeft - item.count)
                        
                        if amountLeft <= 0 then
                            return amountLeft
                        end

                    end
                end
            end

        end
    end

    return amountLeft
end

local function splitItemString(input)
    local lastSpace = input:find(" [^ ]*$")
    local a = input
    local b = "1"
    local c = input:match("^e ")

    if lastSpace then
        local first = input:sub(1, lastSpace -1)
        local second = input:sub(lastSpace +1)

        if not second:find("%D") then
            --return first, second, input:match("^e ")
            a = first
            b = second
        end
    end

    if c then
        a = a:sub(3)
    end
    
    return a,b,c
end


--write("\nSelf attempt: "..table.concat(splitItemString("minecraft:chest 1")", ").."\n\n")

while true do
    write("\nRequest Formats:\n A]     itemmod:item integer\n B]     itemname integer\n C]     e enchantname integer\n\n > ")
    local req = read()
    local itemid, amount, isEnchant = splitItemString( string.lower(req) )

    write("You are requesting:")
    write("\n Name:       "..itemid)
    write("\n Amount:     "..amount)
    write("\n Is Enchant: "..(isEnchant and "yes" or "no"))
    write("\nYes or No?\n > ")
    local yn = string.lower(read())

    if yn:find("y") then
        if amount:find("%D") then
            write("Amount entered contains non-integer characters, did you spell it wrong?\n")
        else
            write("Looking for: "..amount.."x "..itemid.."\n")
            local amountLeft = searchAndOutput(itemid,tonumber(amount), isEnchant)

            if amountLeft == 0 then
                write("\nTransferred all items!\n")
            elseif amountLeft < tonumber(amount) then
                write("\nCould not transfer all items.\n")()
            else
                write("\nOut of stock!\n")
            end
        end
    else
        write("\nRequest cancelled.\n")
    end
end