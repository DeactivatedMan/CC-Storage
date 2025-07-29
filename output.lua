local mainChest = "minecraft:barrel_1"

local function iterate(itemid, amount)
    local amountLeft = amount

    local file = fs.open("items.json", "r")
    local jsonStr = file.readAll()
    file.close()

    local data = textutils.unserialiseJSON(jsonStr)
    local endData = data; local offset = 0

    for index, entry in pairs(data) do
        local check = false
        -- Checks if itemid (minecraft:andesite) has itemid in, then if displayname (Andesite) has itemid in
        if string.find(entry[1], itemid) or string.find(string.lower(entry[INDEXES.displayName]), itemid) then check = true end

        if check then write("\nFound\n") end

        local store = peripheral.wrap("sophisticatedbackpacks:backpack_" .. tostring(entry[INDEXES.storeId]))
        local item = store.getItemDetail(entry[INDEXES.slot])

        -- Checks enchantments if the item has any and user is looking for enchants
        if entry[INDEXES.id] == "minecraft:enchanted_book" and item.enchantments then
            for _, enchant in pairs(item.enchantments) do
                if string.find(enchant.name, itemid) or string.find(string.lower(enchant.displayName), itemid) then check = true end
            end
        end

        if check then
            local transferred = store.pushItems(mainChest, entry[4], amountLeft)
            amountLeft = amountLeft - transferred

            if transferred == item.count then
                table.remove(endData, index + offset)
                offset = offset - 1
            elseif transferred > 0 then
                endData[index + offset][INDEXES] = endData[index + offset][INDEXES.amount] - transferred
            end

            if amountLeft <= 0 then
                break
            end
        end
    end

    local file = fs.open("items.json", "w")
    file.write(textutils.serialiseJSON(endData))
    file.close()

    return amountLeft
end

local function splitItemString(input)
    local roman = {
        ["0"] = "n", -- Optional: 0 isn't typically Roman, using "N" (nulla) or skip it
        ["1"] = "i",
        ["2"] = "ii",
        ["3"] = "iii",
        ["4"] = "iv",
        ["5"] = "v",
        ["6"] = "vi",
        ["7"] = "vii",
        ["8"] = "viii",
        ["9"] = "ix",
    }

    local lastSpace = input:find(" [^ ]*$")
    local a = input
    local b = "1"

    if lastSpace then
        local first = input:sub(1, lastSpace - 1)
        local second = input:sub(lastSpace + 1)

        if not second:find("%D") then -- second is digits only
            a = first
            b = second
        end
    end

    -- Replace a single-digit number in `a` with its Roman numeral
    a = a:gsub("%f[%d](%d)%f[%D]", function(digit)
        return roman[digit] or digit
    end, 1) -- Only replace the first occurrence

    return a, b
end


while true do
    write("\nRequest Formats:")
    write("\n A]     itemmod:item  amount")
    write("\n B]     itemname      amount")
    write("\n C]     enchantname   level    amount\nAnything after name is optional\n\n > ")
    local req = string.lower(read()):match("^%s*(.-)%s*$")
    local itemid, amount = splitItemString(req)

    write("\nYou are requesting:")
    write("\n Name:    " .. itemid)
    write("\n Amount:  " .. amount)
    write("\nYes or No?\n > ")
    local yn = string.lower(read())

    if yn:find("y") then
        if amount:find("%D") then
            write("\nAmount entered contains non-integer characters, did you spell it wrong?\n")
        else
            write("\nLooking for your item...")
            local amountLeft = iterate(itemid, tonumber(amount), isEnchant)

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
