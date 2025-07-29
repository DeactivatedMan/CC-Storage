local names = peripheral.getNames()

local data = {}

for _,name in pairs(names) do
    if name:find("backpack") then
        local store = peripheral.wrap(name)

        if #store.list() > 0 then
            for slot=1,store.size() do
                local item = store.getItemDetail(slot)

                if item then
                    table.insert(data, {item.name, item.displayName, name:match(".*_(.+)$"), slot})
                end
            end
        end
    end
end

local fileW = fs.open("items.json", "w")
fileW.write(textutils.serialiseJSON(data))
fileW.close()