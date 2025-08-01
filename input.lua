local mainChest = "minecraft:barrel_0"
local inputChest = peripheral.wrap(mainChest)

local function addToBackpack(slot, item)
    local potentials = peripheral.getNames()

    for id, entry in pairs(potentials) do
        if entry:find("backpack") then
            local store = peripheral.wrap(entry)
            if #store.list() < store.size() then
                store.pullItems(mainChest, slot, item.count, #store.list() + 1)
                local file = fs.open("items.json", "r")
                local jsonStr = file.readAll()
                file.close()
                local data = textutils.unserializeJSON(jsonStr)
                if type(data) ~= "table" or #data == 0 then
                    data = {}
                end
                --table.insert(json, { storage = entry, slot = #store.list(), name = item.name, count = item.count })
                table.insert(data, { item.name, item.displayName, entry:match(".*_(.+)$"), #store.list(), item.count })
                file = fs.open("items.json", "w")
                file.write(textutils.serializeJSON(data))
                file.close()
                print("Added item from slot " .. slot .. " to backpack " .. id)
                return
            end
        end
    end
end

local defragmented = true

while true do
    local items = inputChest.list()
    if textutils.serialize(items) ~= "{}" then
        for slot, item in pairs(items) do
            addToBackpack(slot, inputChest.getItemDetail(slot))
            if inputChest.getItemDetail(slot) ~= nil then
                write("\nNot enough storage, running defragmentation.\n")
                shell.run("defragment")
                write("\nDefragmentation is complete!\n\n")
                defragmented = true
            else
                write("Added new item " .. item.name .. " (" .. item.count .. ") " .. " to backpack.")
                defragmented = false
            end
        end
    else
        if defragmented then
            sleep(1)
        else
            write("\nDefragmenting storage, please wait.\n")
            shell.run("defragment")
            write("\nDefragmentation is complete!\n\n")
            defragmented = true
        end
    end
end
