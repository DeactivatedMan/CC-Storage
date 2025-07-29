local mainChest = "minecraft:barrel_0"

local function iterate(itemid, displayname, originSlot, amount)
    local amountLeft = amount

    local fileR = fs.open("items.json", "r")
    local jsonStr = fileR.readAll()
    fileR.close()

    local data = textutils.unserialiseJSON(jsonStr)

    if type(data) ~= "table" or #data == 0 then
        data = {}
    end

    for _,entry in pairs(data) do -- Checks pre-existing data
        if entry[1] == itemid and entry[2] == displayname then
            local store = peripheral.wrap("sophisticatedbackpacks:backpack_"..tostring(entry[3]))
            local item = store.getItemDetail(entry[4])

            if item.count < store.getItemLimit(entry[4]) then
                local transferred = store.pullItems( mainChest, originSlot, amountLeft, entry[4] )
                amountLeft = amountLeft - transferred

                if amountLeft <= 0 then
                    return 0
                end
            end
        end
    end

    if amountLeft > 0 then
        local potentials = peripheral.getNames()

        for _,name in pairs(potentials) do
            if name:find("backpack") then
                local store = peripheral.wrap(name)

                if #store.list() < store.size() then
                    for slot=1,store.size() do
                        local slotData = store.getItemDetail(slot)

                        if not slotData then
                            local transferred = store.pullItems( mainChest, originSlot, amountLeft, slot )
                            amountLeft = amountLeft - transferred
                            
                            table.insert(data, {itemid, displayname, name:match(".*_(.+)$"), slot, transferred})

                            local fileW = fs.open("items.json", "w")
                            fileW.write(textutils.serialiseJSON(data))
                            fileW.close()

                            if amountLeft <= 0 then
                                return 0
                            end
                        end

                        if amountLeft <= 0 then
                            return 0
                        end
                    end
                end
            end

            if amountLeft <= 0 then
                return 0
            end
        end
    end

    return amountLeft
end

while true do

    local items = peripheral.wrap(mainChest).list()

    if textutils.serialize(items) ~= "{}" then
        for slot,item in pairs(items) do
            item = peripheral.wrap("minecraft:barrel_0").getItemDetail(slot)

            local archive = {item.count, item.name}

            local amountLeft = item.count
            amountLeft = iterate(item.name, item.displayName, slot, amountLeft)
            
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