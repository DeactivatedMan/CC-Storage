local mainChest = "minecraft:barrel_1"

local function iterate(itemid, amount, isEnchant)
    local amountLeft = amount

    local file = fs.open("items.json", "r")
    local jsonStr = file.readAll()
    file.close()

    local data = textutils.unserialiseJSON(jsonStr)

    for index,entry in pairs(data) do
        if entry.itemid:find(itemid) or string.lower(entry.displayname):find(itemid) then
            local store = peripheral.wrap("sophisticatedbackpacks:backpack_"..tostring(entry.storeid))
            local item = store.getItemDetail(entry.slot)

            if item.count < store.getItemLimit(entry.slot) then
                local transferred = store.pushItems( mainChest, entry.slot, amountLeft)
                amountLeft = amountLeft - transferred
                
                if transferred == item.count then
                    table.remove(data, index)

                    local file = fs.open("items.json", "w")
                    file.write(textutils.serialiseJSON(data))
                    file.close()
                end

                if amountLeft <= 0 then
                    break
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
            local amountLeft = iterate(itemid,tonumber(amount), isEnchant)

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