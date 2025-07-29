local file = fs.open("items.json", "r")
local jsonStr = file.readAll()
file.close()
local json = textutils.unserializeJSON(jsonStr) or {}

local sameItems = {}

for _, entry in ipairs(json) do
  local key = entry[INDEXES.id] .. entry[INDEXES.displayName]
  if not sameItems[key] then
    sameItems[key] = {}
  end
  table.insert(sameItems[key], entry)
end


for itemName, entries in pairs(sameItems) do
  if #entries > 1 then
    write("\nFound multiple entries for item: " .. itemName .. "\n")
    local i = 1
    while i <= #entries do
      if entries[i][INDEXES.amount] < 128 then
        for x = #entries, i + 1, -1 do
          local entry1 = entries[i]
          local entry2 = entries[x]
          local toMove = math.min(128 - entry1[INDEXES.amount], entry2[INDEXES.amount])
          entry1[INDEXES.amount] = entry1[INDEXES.amount] + toMove
          entry2[INDEXES.amount] = entry2[INDEXES.amount] - toMove
          local toChest = peripheral.wrap("sophisticatedbackpacks:backpack_" .. tostring(entry1[INDEXES.storeId]))
          toChest.pullItems("sophisticatedbackpacks:backpack_" .. tostring(entry2[INDEXES.storeId]), entry2
          [INDEXES.slot], toMove, entry1[INDEXES.slot])
          if entry2[INDEXES.amount] <= 0 then
            table.remove(entries, x)
          end
        end
      end
      i = i + 1
    end
  end
end


local result = {}
for key, entry in pairs(sameItems) do
  for _, item in ipairs(entry) do
    if item[5] > 0 then
      table.insert(result, item)
    end
  end
end


local newfile = fs.open("items.json", "w")
newfile.write(textutils.serialiseJSON(result))
newfile.close()
