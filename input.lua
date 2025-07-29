local mainChest = "minecraft:barrel_0"

local function iterate(itemid, displayname, originSlot, amount)
    local amountLeft = amount

    local file = fs.open("items.json", "r")
    local jsonStr = file.readAll()
    file.close()

    local data = textutils.unserialiseJSON(jsonStr)

    if data ~= "[]" then
        for _,entry in pairs(data) do -- Checks pre-existing data
            if entry.itemid == itemid or entry.displayname == displayname then
                local store = peripheral.wrap("sophisticatedbackpacks:backpack_"..tostring(entry.storeid))
                local item = store.getItemDetail(entry.slot)

                if item.count < store.getItemLimit(entry.slot) then
                    local transferred = store.pullItems( mainChest, originSlot, amountLeft, entry.slot )
                    amountLeft = amountLeft - transferred

                    if amountLeft <= 0 then
                        break
                    end
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
                            
                            table.insert(data, {itemid=itemid, displayname=displayname, storeid=name:match(".*_(.+)$"), slot=slot})

                            file = fs.open("items.json", "w")
                            file.write(textutils.serialiseJSON(data))
                            file.close()

                            if amountLeft <= 0 then
                                break
                            end
                        end
                    end
                end
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