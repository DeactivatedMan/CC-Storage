write("Start storage processes? Y // N")
local yn = string.lower(read())

if string.find(yn, "y") then
    --shell.run("delete input.lua")
    --shell.run("delete output.lua")

    shell.run("wget https://raw.githubusercontent.com/DeactivatedMan/CC-Storage/refs/heads/main/input.lua")  -- Downloads input script
    shell.run("wget https://raw.githubusercontent.com/DeactivatedMan/CC-Storage/refs/heads/main/output.lua") -- Downloads output script

    multishell.launch({}, "input.lua")
    multishell.launch({}, "output.lua")
end