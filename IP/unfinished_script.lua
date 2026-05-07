local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TargetRemote = ReplicatedStorage:FindFirstChild("SaveData")

if not TargetRemote then
    warn("SaveData remote not found")
    return
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if self == TargetRemote and (method == "FireServer" or method == "fireServer") then
        local data = args[1]
        if type(data) == "table" then
            print("Intercepted")
            
            -- Resource Manipulation
            data.totalBeli = 99999999999999
            data.gems = 999999999
            data.hakiScrolls = 10000
            data.raceScrolls = 10000
            data.clanScrolls = 10000
            data.totalPower = 999999
            data.playerHP = 1000000
            data.playerATK = 1000000
            data.currentClanRarity = "Secret"
            data.currentClanName = "Imu Lineage"
            data.currentRaceName = "Lunarian Keng"
            data.pity = {Gear = {mythic = 75,legendary = 4,secret = 1790},Weapon = {mythic = 350,legendary = 45,secret = 1790},Characters = {mythic = 0,legendary = 0,secret = 1790},DevilFruit = {mythic = 0,legendary = 0,secret = 1790}}
            data.beliMult = 99
            data.xpMult = 99
            data.dmgMult = 99
            data.currentRaceRarity = "Secret"
            data.currentRaceName = "Ancient Weapon Vessel"
            data.currentHakiRarity = "Secret"
            data.currentHakiName = "True Keng Haki"
		    data.equippedWeaponName = "Saturn\'s Ring"
            data.equippedFeetName = "True Sun Steps"
            data.equippedChestName = "True Sun God Form"
            data.equippedHeadName = "True Sun Crown"
            data.equippedDevilFruitName = "Ancient Weapon Power"
            data.characterStorage = {{name = "Ase",rarity = "Legendary"},{name = "Krokodile",rarity = "Legendary"},{name = "Enol",rarity = "Legendary"},{name = "Akainu",rarity = "Mythic"},{name = "Kaedo",rarity = "Secret"}, {name = "Saturn",rarity = "Secret"}}
		    data.ownedBundles = {}
		    data.ownedPasses = {AutoBattle = true,DoubleBeli = true,DoubleDrops = true,DoubleGems = true,DoubleTraining = true,WillOfD = true,DoubleDevilFruit = true,ExtraSkillSlot = true}
		    data.rebirthCount = 99
		    data.weaponStorage = {{type = "Weapon",rarity = "Secret",symbol = "\240\159\146\160",bleedTurns = 99,name = "Saturn\'s Ring",weaponType = "Sword",icon = "rbxassetid://72403262951229",bleedPct = 999,atkPct = 9999,moves = {{["name"] = "Authority Slash",["dmg"] = 99,["cd"] = 1,["desc"] = "9900% DMG + Authority Bleed"}}}}
            data.devilFruitStorage = {{name = "Ancient Weapon Power",type = "Devil Fruit",rarity = "Secret",moves = {{["name"] = "Sea Cannon",["dmg"] = 5,["desc"] = "500% DMG",["cd"] = 5},{["name"] = "World Break",["dmg"] = 9.1,["desc"] = "910% DMG",["cd"] = 7},{["name"] = "Cataclysm",["dmg"] = 15,["desc"] = "1500% DMG",["cd"] = 10},{["name"] = "Ocean Control",["dmg"] = 0,["desc"] = "Disable Enemy 2T",["cd"] = 7}}}}
		    data.gearStorage = {{type = "Chest",name = "True Sun God Form",symbol = "\240\159\140\160",hpPct = 99999,rarity = "Secret",icon = "rbxassetid://103605629244664",slot = "Chest"},{type = "Feet",name = "True Sun Steps",symbol = "\240\159\148\134",hpPct = 99999,rarity = "Secret",icon = "rbxassetid://136600571847069",slot = "Feet"},{type = "Head",name = "True Sun Crown",symbol = "\240\159\140\158",hpPct = 99999,rarity = "Secret",icon = "rbxassetid://77961035641564",slot = "Head"}}

            
            print("Success")
        end
        return oldNamecall(self, unpack(args))
    end
    
    return oldNamecall(self, ...)
end)

print("Save Hijacker Loaded")
