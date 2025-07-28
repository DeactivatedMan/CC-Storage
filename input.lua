local mainChest = "minecraft:barrel_0"
local inputChest = peripheral.find(mainChest)

local function findEmptyAndAdd(input)
    local potentials = peripheral.getNames()
    local name = false

    for _,entry in pairs(potentials) do -- Iterates through
        if string.find(entry, ":") and not entry:find("barrel") then
            local store = peripheral.wrap(entry)

            if #store.list() == 0 then
                table.insert(names, entry)
                name = entry
                break
            end
        end
    end

    return table.insert(input, name)
end

local function splitAtFirstColon(str)
    local left, right = str:match("^(.-):(.*)$")
    if left and right then
        return right
    else
        return str
    end
end

local function iterate(itemid, originSlot, amount, filter, assignNew)
    local amountLeft = amount

    local file = fs.open("stores.json", "r")
    local jsonStr = file.readAll()
    file.close()

    local data = textutils.unserialiseJSON(jsonStr)
    local names = false
    local letter = splitAtFirstColon(itemid):sub(1, 1)

    local foundEntry = false

    for i,entry in ipairs(data) do
        if entry.category == letter then
            foundEntry = true
            if not assignNew then
                names = entry.peripherals
            elseif assignNew then
                names = findEmptyAndAdd(entry.peripherals)
                data[i].peripherals = names

                file = fs.open("stores.json", "w")
                file.write(textutils.serialiseJSON(data,true))
                file.close()
            end
            break
        end
    end

    if not foundEntry then
        table.insert(data, {category=letter, peripherals=findEmptyAndAdd({})})
        file = fs.open("stores.json", "w")
        file.write(textutils.serialiseJSON(data,true))
        file.close()
    end

    for _,name in pairs(names) do
        if amountLeft <= 0 then
            break
        end

        if amountLeft > 0 and not name:find("barrel") then
            local store = peripheral.wrap(name)
            
            if filter then
                for slot,item in pairs(store.list()) do
                    item = store.getItemDetail(slot) -- Hate it but gives more information

                    if item.name == itemid and item.count < store.getItemLimit(slot) then
                        store.pullItems(mainChest, originSlot, math.min( store.getItemLimit(slot)-item.count, amountLeft ), slot)

                        local originItem = peripheral.wrap("minecraft:barrel_0").getItemDetail(originSlot)
                        amountLeft = 0
                        if originItem then amountLeft = originItem.count end

                        if amountLeft <= 0 then
                            break
                        end
                    end
                end
            elseif #store.list() < store.size() then
                for slot=1,store.size() do
                    if not store.getItemDetail(slot) then
                        store.pullItems(mainChest, originSlot, amountLeft, slot)

                        local originItem = peripheral.wrap("minecraft:barrel_0").getItemDetail(originSlot)
                        amountLeft = 0
                        if originItem then amountLeft = originItem.count end
                        
                        if amountLeft <= 0 then
                            break
                        end
                    end
                end
            end
        end
    end
    

    --if not names then
    --    table.insert( data, {category=letter, peripherals=findEmptyAndAdd({})} )
    --end
    

    return amountLeft
end

while true do

    local items = peripheral.wrap("minecraft:barrel_0").list()

    if textutils.serialize(items) ~= "{}" then
        for slot,item in pairs(items) do
            item = peripheral.wrap("minecraft:barrel_0").getItemDetail(slot)

            local archive = {item.count, item.name}

            local amountLeft = item.count
            if item.count < item.maxCount then
                amountLeft = iterate(item.name, slot, amountLeft, true, false)
            end

            if amountLeft > 0 then
                amountLeft = iterate(item.name, slot, amountLeft, false, false)
            end

            if amountLeft > 0 then
                amountLeft = iterate(item.name, slot, amountLeft, false, true)
            end
            
            if amountLeft == 0 then
                write("Transferred "..archive[1].."x "..archive[2].."!\n")
            elseif amountLeft < item.count then
                write("Could not transfer item "..archive[2].."\n")
                break
            else
                write("Out of storage!\n")
                break
            end
        end
    else
        sleep(1)
    end
end