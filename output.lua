local mainChest = "minecraft:barrel_1"

local function splitAtFirstColon(str)
    local left, right = str:match("^(.-):(.*)$")
    if left and right then
        return right
    else
        return str
    end
end

local function searchAndOutput(itemid, amount, isEnchant)
    local amountLeft = amount

    local file = fs.open("stores.json", "r")
    local jsonStr = file.readAll()
    file.close()

    local data = textutils.unserialiseJSON(jsonStr)
    local names = false
    local letter = splitAtFirstColon(itemid):sub(1, 1)

    if isEnchant then
        letter = "en"
    end
    for i,entry in ipairs(data) do
        if entry.category == letter then
            names = entry.peripherals
            break
        end
    end

    for _,name in pairs(names) do
        if amount <= 0 then
            return amountLeft
        end

        if name:find(":") and amountLeft > 0 and name ~= mainChest then
            local store = peripheral.wrap(name)

            for slot,item in pairs(store.list()) do
                item = store.getItemDetail(slot) -- Better item details

                if isEnchant and item.name == "minecraft:enchanted_book" then
                    local enchantments = item.enchantments
                    for _,enchant in pairs (enchantments) do
                        if enchant.name:find(itemid) or string.lower(item.displayName):find(itemid) then
                            store.pushItems(mainChest, slot, math.min(amountLeft, item.count))
                            amountLeft = math.max(0, amountLeft-item.count)

                            if amountLeft <= 0 then
                                return amountLeft
                            end
                        end
                    end
                else
                    if item.name:find(itemid) or string.lower(item.displayName):find(itemid) then
                        store.pushItems(mainChest, slot, amountLeft)
                        amountLeft = math.max(0, amountLeft-item.count)

                        if amountLeft <= 0 then
                            return amountLeft
                        end
                    end
                end
            end
        end
    end
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

while true do
    write("\nRequest Formats:")
    write("\n A]     itemmod:item  integer")
    write("\n B]     itemname      integer")
    write("\n C]     e enchantname integer\n\n > ")
    local req = string.lower(read()):match("^%s*(.-)%s*$")
    local itemid, amount, isEnchant = splitItemString( req )

    write("\nYou are requesting:")
    write("\n Name:    "..itemid)
    write("\n Amount:  "..amount)
    write("\n Enchant: "..(isEnchant and "yes" or "no"))
    write("\nYes or No?\n > ")
    local yn = string.lower(read())

    if yn:find("y") then
        if amount:find("%D") then
            write("\nAmount entered contains non-integer characters, did you spell it wrong?\n")
        else
            write("\nLooking for your item...")
            local amountLeft = searchAndOutput(itemid,tonumber(amount), isEnchant)

            if amountLeft == 0 then
                write("\nTransferred all items!\n")
            elseif amountLeft < tonumber(amount) then
                write("\nCould not transfer all items.\n")
            else
                write("\nOut of stock!\n")
            end
        end
    else
        write("\nRequest cancelled.\n")
    end
end