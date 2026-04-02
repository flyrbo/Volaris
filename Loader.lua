--[[
 █████   █████          ████                       ███             █████   █████            █████    
▒▒███   ▒▒███          ▒▒███                      ▒▒▒             ▒▒███   ▒▒███            ▒▒███     
 ▒███    ▒███   ██████  ▒███   ██████   ████████  ████   █████     ▒███    ▒███  █████ ████ ▒███████ 
 ▒███    ▒███  ███▒▒███ ▒███  ▒▒▒▒▒███ ▒▒███▒▒███▒▒███  ███▒▒      ▒███████████ ▒▒███ ▒███  ▒███▒▒███
 ▒▒███   ███  ▒███ ▒███ ▒███   ███████  ▒███ ▒▒▒  ▒███ ▒▒█████     ▒███▒▒▒▒▒███  ▒███ ▒███  ▒███ ▒███
  ▒▒▒█████▒   ▒███ ▒███ ▒███  ███▒▒███  ▒███      ▒███  ▒▒▒▒███    ▒███    ▒███  ▒███ ▒███  ▒███ ▒███
    ▒▒███     ▒▒██████  █████▒▒████████ █████     █████ ██████     █████   █████ ▒▒████████ ████████ 
     ▒▒▒       ▒▒▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒▒▒▒▒ ▒▒▒▒▒     ▒▒▒▒▒ ▒▒▒▒▒▒     ▒▒▒▒▒   ▒▒▒▒▒   ▒▒▒▒▒▒▒▒ ▒▒▒▒▒▒▒▒  
                                                                                                     

Made by 			░▒▓████████▓▒░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░ 
				      ░▒▓█▓▒░      ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░ 
				      ░▒▓█▓▒░      ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░ 
				      ░▒▓██████▓▒░ ░▒▓█▓▒░    ░▒▓██████▓▒░  
				      ░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░     
				      ░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░     
				      ░▒▓█▓▒░      ░▒▓████████▓▒░▒▓█▓▒░     
                                      
Credits to Nebula Softworks © for the UI Library.

loadstring(game:HttpGet("https://raw.githubusercontent.com/flyrbo/Volaris/refs/heads/main/Loader.lua"))()


                      !!WARNING!!
This script is created for educational and testing purposes only.
I do not encourage or promote exploiting in any Roblox game.

By using this script, you acknowledge that:
- You are responsible for your own actions.
- Using exploits may violate Roblox's Terms of Service.
- Your account may be permanently banned or restricted.

I am not responsible for any consequences resulting from its use.

If you do not agree with these terms, do not use this script.
--]]

--/ UI Library import
local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()


--/ SUPPORTED FUNCTIONS CHECK
local function checkExecutor()
    local missing = {}

    local function check(name, func)
        if typeof(func) ~= "function" then
            table.insert(missing, name)
        end
    end

    check("loadstring", loadstring)
    check("HttpGet", game.HttpGet)
    check("getgenv", getgenv)
    check("firetouchinterest", firetouchinterest)
    check("fireproximityprompt", fireproximityprompt)

    if #missing > 0 then
        warn("Executor missing required functions:")

        for _, v in ipairs(missing) do
            warn("- " .. v)
        end

        return false
    end

    return true
end

--/ LOADER USED CHECK
if not checkExecutor() then
    local Loaded = Starlight:Notification({
    	Title = "Unsupported Executor",
    	Icon = NebulaIcons:GetIcon('shield-x', 'Lucide'),
    	Content = "This script will lose key functionality using this executor. Please report the name of the executor on the GitHub page.",
	}, "UNSUPPORTED EXECUTOR")
    return
end

getgenv().funcCheck = true

if tostring(game.PlaceId) == "130818457717791" or tostring(game.PlaceId) == "80953732024525" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/flyrbo/Volaris/refs/heads/main/STI/script.lua"))() -- Survive The Island
else
    local Loaded = Starlight:Notification({
    	Title = "UNSUPPORTED GAME!",
    	Icon = NebulaIcons:GetIcon('shield-x', 'Lucide'),
    	Content = "Volaris could not find an appropriate script for this game!",
	}, "INVALID_PLACEID")
end
