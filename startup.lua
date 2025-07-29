local function readWithTimeout(timeout, default)
    --term.write("> ")
    local input = ""
    local timer = os.startTimer(timeout)

    while true do
        local event, p1 = os.pullEvent()

        if event == "char" then
            input = input .. p1
            term.write(p1)
        elseif event == "key" and p1 == keys.enter then
            print()
            return input -- User pressed Enter
        elseif event == "timer" and p1 == timer then
            print("\n[Timeout]")
            return default -- Timeout occurred
        end
    end
end

local branch = settings.get("branch.setting", "main")

-- Checks if first install and downloads files
if not fs.exists("startup.lua") then
    local branch = readWithTimeout(10, "main")
    settings.define("branch.setting", {
        description = "Which branch CC-Storage is using",
        default = "main",
        type = "string"
    })
    settings.set("branch.setting", branch)
    shell.run("wget https://raw.githubusercontent.com/DeactivatedMan/CC-Storage/refs/heads/" ..
        branch .. "/startup.lua")
end

if not fs.exists("items.json") then
    local file = fs.open("items.json", "w")
    file.write("{}")
    file.close()
end
if not fs.exists("CONSTANTS.lua") then
    shell.run("wget https://raw.githubusercontent.com/DeactivatedMan/CC-Storage/refs/heads/" ..
        branch .. "/CONSTANTS.lua")
end

if not fs.exists("input.lua") then
    shell.run("wget https://raw.githubusercontent.com/DeactivatedMan/CC-Storage/refs/heads/" ..
        branch .. "/input.lua")
end

if not fs.exists("output.lua") then
    shell.run("wget https://raw.githubusercontent.com/DeactivatedMan/CC-Storage/refs/heads/" ..
        branch .. "/output.lua")
end

if not fs.exists("defragment.lua") then
    shell.run("wget https://raw.githubusercontent.com/DeactivatedMan/CC-Storage/refs/heads/" ..
        branch .. "/defragment.lua")
end
if not fs.exists("redoJson.lua") then
    shell.run("wget https://raw.githubusercontent.com/DeactivatedMan/CC-Storage/refs/heads/" ..
        branch .. "/redoJson.lua")
end

-- Sanity checking and condensing storage
if fs.exists("defragment.lua") then
    write("\nDefragmenting storage, please wait.\n")
    os.run({}, "defragment.lua")
    write("\nDefragmentation is complete!\n\n")
end
if fs.exists("redoJson.lua") then
    write("Attempt rewrite of JSON? Y // N\n > ")
    local yn = string.lower(readWithTimeout(5, ""))

    if string.find(yn, "y") then
        write("\nRewriting JSON.\n")
        os.run({}, "redoJson.lua")
        write("\nRewrite is complete!\n\n")
    end
end

-- Executes main scripts
if fs.exists("input.lua") then
    local input = multishell.launch({}, "input.lua")
    multishell.setTitle(input, "")
end

if fs.exists("output.lua") then
    local output = multishell.launch({}, "output.lua")
    multishell.setTitle(output, "Output")
    multishell.setFocus(output)
end

-- Asks end user if they wish to update
write("Attempt update? Y // N\n > ")
local yn = string.lower(readWithTimeout(15, ""))

if string.find(yn, "y") then
    shell.run("wget https://raw.githubusercontent.com/DeactivatedMan/CC-Storage/refs/heads/" .. branch .. "/input.lua")  -- Downloads input script
    shell.run("wget https://raw.githubusercontent.com/DeactivatedMan/CC-Storage/refs/heads/" .. branch .. "/output.lua") -- Downloads output script
    shell.run("wget https://raw.githubusercontent.com/DeactivatedMan/CC-Storage/refs/heads/" .. branch ..
        "/defragment.lua")                                                                                               -- Downloads defrag script
    write("Updated! (Or did absolutely nothing other than reset the files..)\nrun 'reboot' to initialise\n")
end
