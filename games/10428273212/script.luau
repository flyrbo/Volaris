--[[
 █████   █████          ████                       ███             █████   █████            █████    
▒▒███   ▒▒███          ▒▒███                      ▒▒▒             ▒▒███   ▒▒███            ▒▒███     
 ▒███    ▒███   ██████  ▒███   ██████   ████████  ████   █████     ▒███    ▒███  █████ ████ ▒███████ 
 ▒███    ▒███  ███▒▒███ ▒███  ▒▒▒▒▒███ ▒▒███▒▒███▒▒███  ███▒▒      ▒███████████ ▒▒███ ▒███  ▒███▒▒███
 ▒▒███   ███  ▒███ ▒███ ▒███   ███████  ▒███ ▒▒▒  ▒███ ▒▒█████     ▒███▒▒▒▒▒███  ▒███ ▒███  ▒███ ▒███
  ▒▒▒█████▒   ▒███ ▒███ ▒███  ███▒▒███  ▒███      ▒███  ▒▒▒▒███    ▒███    ▒███  ▒███ ▒███  ▒███ ▒███
    ▒▒███     ▒▒██████  █████▒▒████████ █████     █████ ██████     █████   █████ ▒▒████████ ████████ 
     ▒▒▒       ▒▒▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒▒▒▒▒ ▒▒▒▒▒     ▒▒▒▒▒ ▒▒▒▒▒▒     ▒▒▒▒▒   ▒▒▒▒▒   ▒▒▒▒▒▒▒▒ ▒▒▒▒▒▒▒▒  
                                                                                                     


Made by									███████╗██╗  ██╗   ██╗
										██╔════╝██║  ╚██╗ ██╔╝
										█████╗  ██║   ╚████╔╝ 
										██╔══╝  ██║    ╚██╔╝  
										██║     ███████╗██║   
										╚═╝     ╚══════╝╚═╝  
                      

Credits to Nebula Softworks © for the UI Library.

loadstring(game:HttpGet("https://raw.githubusercontent.com/flyrbo/Volaris/refs/heads/main/Loader.luau"))()


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


--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Configuration

--//// Game
local Config = {
	placeId = 100248945884133,
	pixelSize = 1 / 3,
	brushStuds = 2,
	flatMask = Vector3.new(1, 0, 1),
	maxRounds = 8,
	stallLimit = 4,
	jumpDist = 20,
	twoOptMax = 1500,
	bandDenseFrac = 0.3,
	bandMinRows = 3,
	bandMinCount = 40,
	bandMinRowCount = 4,
	bandTurnTime = 0.35,
}


--//// URLs
local libraryUrls = {
	Starlight = "https://raw.nebulasoftworks.xyz/starlight",
	NebulaIcons = "https://raw.nebulasoftworks.xyz/nebula-icon-library-loader",
}

--// Boot

--//// Unload Guard
if typeof(getgenv) == "function" then
	local previous = getgenv().Volaris and getgenv().Volaris.PaintMangaHub
	if previous then
		previous.Restarting = true
		if previous.Unload then
			previous.Unload()
		end
	end
	pcall(function()
		local host = (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui")
		local orphan = host and host:FindFirstChild("PaintMangaHub")
		if orphan then
			orphan:Destroy()
		end
	end)
	if getgenv().PaintManga and type(getgenv().PaintManga.Stop) == "function" then
		pcall(function() getgenv().PaintManga.Stop() end)
	end
end

--//// Executor Compatibility
local genv = typeof(getgenv) == "function" and getgenv() or nil
local Volaris = genv and genv.Volaris or nil

if not (Volaris and Volaris.funcCheck == true) then
	local missing = {}

	for _, requirement in {
		{ name = "loadstring", value = loadstring },
		{ name = "HttpGet", value = game.HttpGet },
		{ name = "getgenv", value = getgenv },
	} do
		if typeof(requirement.value) ~= "function" then
			table.insert(missing, requirement.name)
		end
	end

	if #missing > 0 then
		warn(("[Volaris] Executor is missing %d required function(s): %s. Report executor name on the GitHub page.")
			:format(#missing, table.concat(missing, ", ")))
		return
	end
end

genv = getgenv()
genv.Volaris = genv.Volaris or {}
Volaris = genv.Volaris

--//// Library Init
local NebulaIcons, okStarlight, Starlight
do
getgenv().InterfaceName = "PaintMangaHub"

local libCache = "VolarisHub/libs"
local canCache = typeof(writefile) == "function" and typeof(readfile) == "function"

local function patchLibSource(key: string, src: string): string
	local function patched(gsubbed, expected)
		if gsubbed == src then
			warn("[Volaris] library patch missed (" .. tostring(expected)
				.. ") - Starlight likely updated; report this on the GitHub page")
		end
		return gsubbed
	end
	if key == "starlight" then
		-- colorpicker
		local s1 = src:gsub(
			"NestedElement = nil%s+Parent%.Instance%.Header%.Size = UDim2%.fromOffset%(Parent%.Instance%.Header%.Size%.X%.Offset %- 26, 20%)",
			"NestedElement = nil")
		src = patched(s1, "colorpicker destroy")
		-- bind
		local s2 = src:gsub(
			"Parent%.Instance%.Header%.Size = UDim2%.fromOffset%(Parent%.Instance%.Header%.Size%.X%.Offset %+ 26, 20%)",
			"")
		src = patched(s2, "bind destroy")
		-- slider/other
		local s3 = src:gsub(
			"Parent%.Instance%.Size = UDim2%.fromOffset%(0, Parent%.Instance%.Size%.Y%.Offset %- additionSize%)",
			"")
		src = patched(s3, "slider destroy")
		-- loading screen pacing
		local s4 = src:gsub("task%.wait%(3%.24%)", "task.wait(0.4)")
		src = patched(s4, "loading spin wait")
		local s5 = src:gsub("task%.wait%(1%.72%)", "task.wait(0.25)")
		src = patched(s5, "loading login wait")
	end
	return src
end

local function bootLib(key, urls)
	local cachePath = libCache .. "/" .. key .. ".luau"
	local lastErr = "no source loaded"
	local function httpGetDeadline(url: string, seconds: number): (boolean, string)
		local done, okHttp, body = false, false, nil
		task.spawn(function()
			local ok, data = pcall(function()
				return game:HttpGet(url)
			end)
			okHttp, body, done = ok, data, true
		end)
		local t0 = os.clock()
		while not done and os.clock() - t0 < seconds do
			task.wait(0.1)
		end
		if not done then
			return false, "timeout after " .. seconds .. "s"
		end
		return okHttp, body
	end

	local function cacheFirst()
		if not canCache then return false end
		local okCache, cached = pcall(readfile, cachePath)
		if not (okCache and type(cached) == "string" and #cached > 512) then
			return false
		end
		local marker = "--vol:raw\n"
		local libSrc = cached
		if cached:sub(1, #marker) == marker then
			libSrc = patchLibSource(key, cached:sub(#marker + 1))
		end
		local okFn, fn = pcall(loadstring, libSrc)
		if not (okFn and fn) then
			lastErr = ("cache compile failed: %.120s"):format(tostring(fn))
			return false
		end
		local okRun, lib = pcall(fn)
		if not (okRun and lib ~= nil) then
			lastErr = ("cache run failed: %.120s"):format(tostring(lib))
			return false
		end
		task.spawn(function()
			for _, url in ipairs(urls) do
				local okHttp, raw = httpGetDeadline(url, 20)
				if okHttp and type(raw) == "string" and #raw > 512 then
					local okFn2, fn2 = pcall(loadstring, patchLibSource(key, raw))
					if okFn2 and fn2 then
						pcall(writefile, cachePath, "--vol:raw\n" .. raw)
						break
					end
				end
			end
		end)
		return true, lib
	end
	local okCached, cachedLib = cacheFirst()
	if okCached then
		return true, cachedLib
	end
	for _, url in ipairs(urls) do
		local okHttp, raw = httpGetDeadline(url, 20)
		if okHttp and type(raw) == "string" and #raw > 512 then
			local src = patchLibSource(key, raw)
			local okFn, fn = pcall(loadstring, src)
			if okFn and fn then
				local okRun, lib = pcall(fn)
				if okRun and lib ~= nil then
					if canCache then
						pcall(function()
							if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
								if not isfolder("VolarisHub") then
									makefolder("VolarisHub")
								end
								if not isfolder(libCache) then
									makefolder(libCache)
								end
							end
							writefile(cachePath, "--vol:raw\n" .. raw)
						end)
					end
					return true, lib
				end
				lastErr = ("run failed: %.120s"):format(tostring(lib))
			else
				lastErr = ("compile failed: %.120s"):format(tostring(fn))
			end
		else
			lastErr = ("fetch failed: %.120s"):format(tostring(src))
		end
	end
	if canCache then
		local okCache, cached = pcall(readfile, cachePath)
		if okCache and type(cached) == "string" and #cached > 512 then
			local okFn, fn = pcall(loadstring, patchLibSource(key, cached))
			if okFn and fn then
				local okRun, lib = pcall(fn)
				if okRun and lib ~= nil then
					return true, lib
				end
				lastErr = ("cache run failed: %.120s"):format(tostring(lib))
			end
		end
	end
	return false, lastErr
end

okStarlight, Starlight = bootLib("starlight", {
	libraryUrls.Starlight,
	"https://raw.githubusercontent.com/Nebula-Softworks/Starlight-Interface-Suite/Gen1/Source.lua",
	"https://cdn.jsdelivr.net/gh/Nebula-Softworks/Starlight-Interface-Suite@Gen1/Source.lua",
})

local iconPacks, iconCount = {}, 0
for pack, file in pairs({ Material = "MaterialIcons", Lucide = "LucideIcons" }) do
	local ok, tab = bootLib("icons_" .. pack:lower(), {
		"https://cdn.jsdelivr.net/gh/Nebula-Softworks/Nebula-Icon-Library@master/" .. file .. ".luau",
		"https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/master/" .. file .. ".luau",
	})
	if ok and type(tab) == "table" then
		iconPacks[pack] = tab
		iconCount += 1
	end
end

local okIcons = iconCount > 0
NebulaIcons = nil
if okIcons then
	NebulaIcons = {
		GetIcon = function(_, name, pack)
			local set = iconPacks[pack] or iconPacks.Material or iconPacks.Lucide
			return set and set[name] or nil
		end,
	}
end

if not okStarlight or not okIcons then
	warn("[Volaris] Library boot failed. Starlight: "
		.. (okStarlight and "ok" or tostring(Starlight))
		.. " | Icons: "
		.. (okIcons and ("ok (" .. iconCount .. "/2 packs)") or "no pack loaded"))
	return
end
end

--//// Game Check
if game.PlaceId ~= Config.placeId then
	Starlight:Notification({
		Title = "Volaris Hub",
		Content = "Wrong game! This script is for \"Paint a Manga!\".",
		Icon = NebulaIcons:GetIcon("circle-alert", "Lucide"),
		Duration = 8,
	}, "PM_WRONG_GAME")
	return
end

--//// Global State
Volaris.PaintMangaHub = Volaris.PaintMangaHub or {}
local Global = Volaris.PaintMangaHub
Global.Toggles = Global.Toggles or {}
Global.Running = Global.Running or {}
Global.Connections = Global.Connections or {}
Global.Dropdowns = Global.Dropdowns or {}
Global.Values = Global.Values or {}
Global.Stats = Global.Stats or {}
Global.Restarting = nil
Global.Alive = true

Global.Values.WalkSpeed = Global.Values.WalkSpeed or 52
Global.Values.GeneralWalkSpeed = Global.Values.GeneralWalkSpeed or 16
task.spawn(function()
	while Global.Alive do
		task.wait(1)
		if not (Global.Toggles and Global.Toggles.AutoPaint) then
			local ch = Players.LocalPlayer.Character
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			if hum and hum.WalkSpeed > (Global.DetectedSprint or 0) then
				Global.DetectedSprint = hum.WalkSpeed
				if (Global.Values.WalkSpeed or 0) <= 52 then
					Global.Values.WalkSpeed = Global.DetectedSprint
				end
			end
		end
	end
end)
Global.Values.Queue = Global.Values.Queue or {}
Global.Values.QTitle = Global.Values.QTitle or ""
Global.Dropdowns.QueueDifficulty = Global.Dropdowns.QueueDifficulty or { "Normal" }
Global.Toggles.Blatant = false
Global.BlatantGen = Global.BlatantGen or 0
Global.Webhook = Global.Webhook or { url = "", template = "" }
local Webhook = {
	onBuilt = function() end,
	onCompleted = function() end,
	onStopped = function() end,
	onPaused = function() end,
	sessionEnd = function() end,
}
local BlatantToggle = nil

local Stats = Global.Stats
Stats.phase = Stats.phase or "idle"
Stats.layer = Stats.layer or 0
Stats.layerCount = Stats.layerCount or 0
Stats.layerLeft = Stats.layerLeft or 0
Stats.total = Stats.total or 0
Stats.filled = Stats.filled or 0
Stats.colorsDone = Stats.colorsDone or 0
Stats.coversDone = Stats.coversDone or 0
Stats.baselineFilled = Stats.baselineFilled or 0
Stats.activeSeconds = Stats.activeSeconds or 0
if Stats.coverStartClock and Stats.coverStartClock < 1e9 then
	Stats.coverStartClock = nil
end

local Labels: { [string]: any } = {}
local QueueParagraph = nil

--// Engine

--//// Remotes
local Remotes = {}
local LP, Net: any, plots, loadNextFromQueue
do
LP = Players.LocalPlayer
Net = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Net")

local function waitRemote(name): any
	local remote = Net:WaitForChild(name, 30)
	if not remote then
		warn(("[Volaris] Remote '%s' is missing - the game likely changed. Report this on the GitHub page."):format(name))
		error("Volaris: missing remote " .. name)
	end
	return remote
end
Remotes.builtEvent = waitRemote("RE/CanvasBuilt")
Remotes.fillsEvent = waitRemote("RE/CanvasFills")
Remotes.clearedEvent = waitRemote("RE/CanvasCleared")
Remotes.activeEvent = waitRemote("RE/ActiveChanged")
Remotes.setActiveEvent = waitRemote("RE/SetActive")
Remotes.completedEvent = waitRemote("RE/Completed")
Remotes.requestRemote = waitRemote("RF/RequestCanvas")
Remotes.searchRemote = waitRemote("RF/Search")
Remotes.loadRemote = waitRemote("RF/LoadCover")
Remotes.galleryRemote = waitRemote("RF/Gallery")

plots = {}
end


--//// Visual State
local Visuals, ActorBridge, requestActorScan, requestActorPlan
do
Visuals = {
	plots = {},
	green = {},
	greenPlot = nil,
	greenLayer = nil,
	greenW = 0,
	greenH = 0,
	greenTotal = 0,
	greenCount = 0,
	greenRow = nil,
	greenCol = nil,
	rescanAt = 0,
	captureAt = 0,
	dirty = true,
	writeHook = nil,
	renderModule = nil,
	upvalueRegistry = nil,
	upvalRetryAt = 0,
}

local greenRescanAfter = 8

local function stateKeys(state)
	return state.Plot or state.Name,
		state.ActiveLayer or state.Layer,
		state.W or state.Width,
		state.H or state.Height
end

function Visuals.invalidate()
	Visuals.dirty = true
end

function Visuals.OnBuilt(plotName)
	Visuals.dirty = true
end

function Visuals.OnFills(plotName, fillBuf)
	if plotName ~= Visuals.greenPlot or typeof(fillBuf) ~= "buffer" then return end
	local green = Visuals.green
	local rowC, colC = Visuals.greenRow, Visuals.greenCol
	local W = Visuals.greenW
	if buffer.len(fillBuf) % 4 == 0 then
		for off = 0, buffer.len(fillBuf) - 4, 4 do
			local idx = buffer.readu32(fillBuf, off)
			if green[idx] then
				green[idx] = nil
				Visuals.greenCount -= 1
				if rowC then
					local i = idx - 1
					local x = i % W
					local z = i // W
					rowC[z + 1] -= 1
					colC[x + 1] -= 1
				end
			end
		end
	end
end

function Visuals.OnLayerChanged(plotName)
	Visuals.dirty = true
end

function Visuals.OnCleared(plotName)
	Visuals.plots[plotName] = nil
	if Visuals.greenPlot == plotName then
		Visuals.green = {}
		Visuals.greenPlot = nil
		Visuals.greenCount = 0
		Visuals.greenTotal = 0
		Visuals.greenRow = nil
		Visuals.greenCol = nil
		Visuals.dirty = true
	end
end

function Visuals.rescan(state)
	if Visuals.rescanning then
		local t0 = os.clock()
		while Visuals.rescanning and os.clock() - t0 < 3 do
			task.wait(0.05)
		end
		return
	end
	Visuals.rescanning = true
	local name, layer, W, H = stateKeys(state)
	local L, F = state.Layers, state.Filled
	if not name or not layer or not W or not H
		or typeof(L) ~= "buffer" or typeof(F) ~= "buffer" then
		Visuals.rescanning = false
		return
	end

	local second = state.Second or state.SecondLayer
	if not (second and second > 0) or second == layer then second = nil end
	local g = {}
	local rowC = table.create(H, 0)
	local colC = table.create(W, 0)
	local layerTotal = 0
	local count = 0
	local chunk = 0
	for i = 0, (W * H) - 1 do
		local li = buffer.readu8(L, i)
		if li == layer or (second and li == second) then
			layerTotal += 1
			if buffer.readu8(F, i) ~= 1 then
				g[i + 1] = true
				count += 1
				local x = i % W
				local z = i // W
				rowC[z + 1] += 1
				colC[x + 1] += 1
			end
		end
		chunk += 1
		if chunk >= 65536 then
			chunk = 0
			task.wait()
		end
	end
	Visuals.green = g
	Visuals.greenPlot = name
	Visuals.greenLayer = layer
	Visuals.greenW = W
	Visuals.greenH = H
	Visuals.greenTotal = layerTotal
	Visuals.greenCount = count
	Visuals.greenRow = rowC
	Visuals.greenCol = colC
	Visuals.rescanAt = os.clock()
	Visuals.dirty = false
	Visuals.rescanning = false
end

requestActorScan = nil
requestActorPlan = nil
ActorBridge = nil

function Visuals.applyActorCounts(rowC, colC, count, layerTotal)
	Visuals.greenRow = rowC
	Visuals.greenCol = colC
	Visuals.greenCount = count
	Visuals.greenTotal = layerTotal
	Visuals.rescanAt = os.clock()
end

function Visuals.greensFor(state, serverLeft)
	local name, layer = stateKeys(state)
	local refreshAfter = (ActorBridge and ActorBridge.ok and 3) or greenRescanAfter
	if Visuals.greenPlot ~= name or Visuals.greenLayer ~= layer or Visuals.dirty then
		Visuals.rescan(state)
	elseif serverLeft and Visuals.greenCount == 0 and serverLeft > 0 then
		if not (requestActorScan and requestActorScan(state)) then
			Visuals.rescan(state)
		end
	elseif serverLeft and math.abs(serverLeft - Visuals.greenCount) > math.max(64, serverLeft * 0.25) then
		if not (requestActorScan and requestActorScan(state)) then
			Visuals.rescan(state)
		end
	elseif os.clock() - Visuals.rescanAt > refreshAfter then
		if not (requestActorScan and requestActorScan(state)) then
			Visuals.rescan(state)
		end
	end
	return Visuals
end
end

--//// State Helpers
local function on()
	return Global.Toggles.AutoPaint == true
		and Global.PaintGen ~= nil
		and Global.PaintGen == (Global.Gens and Global.Gens.AutoPaint or 0)
end

local function setPhase(txt)
	Stats.phase = txt
end

local function refreshStatsFrom(plotState)
	if not plotState or not plotState.Active then return end
	Stats.plot = plotState.Name
	Stats.total = plotState.Total
	Stats.filled = plotState.FilledCount or 0
	Stats.layer = plotState.Layer or 0
	Stats.layerCount = #(plotState.LayerRemaining or {})
	local left = plotState.LayerRemaining and plotState.LayerRemaining[plotState.Layer or 0] or 0
	if plotState.Second and type(plotState.LayerRemaining) == "table" then
		left += plotState.LayerRemaining[plotState.Second] or 0
	end
	Stats.layerLeft = (type(left) == "number") and left or 0
	local done = 0
	if type(plotState.LayerRemaining) == "table" then
		for _, v in ipairs(plotState.LayerRemaining) do
			if type(v) == "number" and v == 0 then done += 1 end
		end
	end
	Stats.colorsDone = done
end

local function activePlot()
	local best
	for _, s in pairs(plots) do
		if s.Active and (not best or s.FilledCount < best.FilledCount) then best = s end
	end
	return best
end

local function plotPartOf(name)
	local map = workspace:FindFirstChild("Map")
	local folder = map and map:FindFirstChild("Plots")
	local holder = folder and folder:FindFirstChild(name)
	return holder and holder:FindFirstChild("Plot")
end

local function getChar()
	local c = LP.Character
	if not c then return nil, nil, nil end
	return c, c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
end

local function applyWalkSpeed()
	if (Global.Crawling or 0) > 0 then return end
	local _, hum = getChar()
	if hum then
		hum.WalkSpeed = math.clamp(Global.Values.WalkSpeed or 26, 16, 150)
	end
end

--//// Remote Mirror
do
local function ensureMirror()
	if Global.Connections.Mirror then return end
	local conns = {}
	conns[#conns + 1] = Remotes.builtEvent.OnClientEvent:Connect(function(d)
		if type(d) ~= "table" or type(d.Plot) ~= "string" then return end
		local total = (d.Width or 0) * (d.Height or 0)
		if total <= 0 or typeof(d.Layers) ~= "buffer" or typeof(d.Filled) ~= "buffer" then return end
		plots[d.Plot] = {
			Name = d.Plot, W = d.Width, H = d.Height, Total = total,
			Layer = d.ActiveLayer, Second = (d.SecondLayer and d.SecondLayer > 0) and d.SecondLayer or nil,
			Layers = d.Layers, Filled = d.Filled,
			LayerRemaining = d.LayerRemaining, FilledCount = d.FilledCount or 0,
			Active = d.Active == true, part = plotPartOf(d.Plot),
		}
		Stats.lastBuiltAt = os.clock()
		Visuals.OnBuilt(d.Plot)
		if d.Active == true then
			refreshStatsFrom(plots[d.Plot])
			Stats.coverStartClock = os.time()
			Stats.officialCoverTime = nil
			Global.CoverBuiltAt = os.clock()
			task.spawn(Webhook.onBuilt)
		end
	end)
	conns[#conns + 1] = Remotes.fillsEvent.OnClientEvent:Connect(function(plotName, fillBuf, filledCount, layerRemaining)
		local s = plots[plotName]
		if not s then return end
		if typeof(fillBuf) == "buffer" and buffer.len(fillBuf) % 4 == 0 then
			for off = 0, buffer.len(fillBuf) - 4, 4 do
				local idx = buffer.readu32(fillBuf, off)
				if idx >= 1 and idx <= s.Total then
					buffer.writeu8(s.Filled, idx - 1, 1)
				end
			end
		end
		if type(filledCount) == "number" then s.FilledCount = filledCount end
		Global.LastFillAt = Global.LastFillAt or {}
		Global.LastFillAt[s.Name] = os.clock()
		if type(layerRemaining) == "table" then s.LayerRemaining = layerRemaining end
		Visuals.OnFills(plotName, fillBuf)
		if s.Active then refreshStatsFrom(s) end
	end)
	conns[#conns + 1] = Remotes.activeEvent.OnClientEvent:Connect(function(plotName, layer, second)
		local s = plots[plotName]
		Visuals.OnLayerChanged(plotName)
		if s then
			s.Layer = layer
			s.Second = (second and second > 0) and second or nil
			if s.Active then refreshStatsFrom(s) end
		end
	end)
	conns[#conns + 1] = Remotes.clearedEvent.OnClientEvent:Connect(function(plotName)
		Visuals.OnCleared(plotName)
		Global.LoadedCover = nil
		if plots[plotName] then
			plots[plotName] = nil
			if Stats.plot == plotName then
				Stats.plot = nil
				setPhase("waiting for cover")
			end
		end
	end)
	conns[#conns + 1] = Remotes.completedEvent.OnClientEvent:Connect(function(d)
		Global.LastCompletedAt = os.clock()
		Stats.coversDone += 1
		Stats.officialCoverTime = (type(d) == "table" and tonumber(d.Seconds)) or nil
		if Stats.coverStartClock then
			local secs = os.time() - Stats.coverStartClock
			if secs >= 30 and (Stats.total or 0) > 0 then
				Stats.lastCover = ("%d studs in %d:%02d (%.0f studs/min)"):format(
					Stats.total or 0, secs // 60, secs % 60,
					(Stats.total or 0) / (secs / 60))
			end
			Stats.coverStartClock = nil
		end
		if Global.Gallery then Global.Gallery.fetchedAt = 0 end
		setPhase("cover finished")
		task.spawn(Webhook.onCompleted)
		task.delay(3, function()
			if Global.Alive and Global.Toggles.AutoPaint and #Global.Values.Queue > 0 then
				loadNextFromQueue()
			end
		end)
		pcall(function()
			Starlight:Notification({
				Title = "Cover finished!",
				Content = ("\"%s\" is done."):format(tostring(type(d) == "table" and d.Title or "?"))
					.. (#Global.Values.Queue > 0 and " Loading the next queued cover..." or " Queue more on the Queue tab."),
				Icon = NebulaIcons:GetIcon("celebration", "Material"),
				Duration = 10,
			}, "PM_COMPLETED")
		end)
	end)
	Global.Connections.Mirror = conns
end

ensureMirror()
task.spawn(function()
	pcall(function() Remotes.requestRemote:InvokeServer() end)
end)
end

--//// Canvas Geometry
local okPasses, Passes = pcall(require, ReplicatedStorage.Client.Systems.Passes)

local function brushRadiusCells()
	local scale = 1
	if okPasses and Passes and type(Passes.GetBrushScale) == "function" then
		local ok, s = pcall(Passes.GetBrushScale, Passes)
		if ok and type(s) == "number" and s >= 1 then scale = s end
	end
	return Config.brushStuds * scale / Config.pixelSize
end

local function cellToWorld(s, x, y)
	local p = s.part
	return Vector3.new(
		p.Position.X - p.Size.X * 0.5 + (x + 0.5) * Config.pixelSize,
		p.Position.Y + p.Size.Y * 0.5,
		p.Position.Z - p.Size.Z * 0.5 + (y + 0.5) * Config.pixelSize
	)
end

local function worldToCell(s, pos)
	local p = s.part
	return (pos.X - (p.Position.X - p.Size.X * 0.5)) / Config.pixelSize,
	       (pos.Z - (p.Position.Z - p.Size.Z * 0.5)) / Config.pixelSize
end

local function charCell(s)
	local _, _, root = getChar()
	if not root then return 0, 0 end
	return worldToCell(s, root.Position)
end

local function greenAround(s, cx, cy, r)
	local n = 0
	local x0, x1 = math.max(0, math.floor(cx - r)), math.min(s.W - 1, math.ceil(cx + r))
	local y0, y1 = math.max(0, math.floor(cy - r)), math.min(s.H - 1, math.ceil(cy + r))
	local r2 = r * r
	for y = y0, y1 do
		for x = x0, x1 do
			local idx = y * s.W + x + 1
			if buffer.readu8(s.Filled, idx - 1) ~= 1
				and buffer.readu8(s.Layers, idx - 1) == s.Layer then
				local dx, dy = x + 0.5 - cx, y + 0.5 - cy
				if dx * dx + dy * dy <= r2 then n += 1 end
			end
		end
	end
	return n
end

--//// Layer Helpers
local function layerRemainingOf(s, layer)
	if type(s.LayerRemaining) ~= "table" then return nil end
	local n = s.LayerRemaining[layer]
	if type(n) ~= "number" then return nil end
	if layer == s.Layer and s.Second then
		n += s.LayerRemaining[s.Second] or 0
	end
	return n
end

local function allLayersDone(s)
	if type(s.LayerRemaining) ~= "table" or #s.LayerRemaining == 0 then return false end
	for i = 1, #s.LayerRemaining do
		local v = s.LayerRemaining[i]
		if type(v) ~= "number" or v <= 0 then continue end
		if s.Abandoned and s.Abandoned[i] then continue end
		if i >= (s.Layer or 0) then return false end
	end
	return true
end

local function nextLayerWithRemaining(s, from)
	if type(s.LayerRemaining) ~= "table" then return nil end
	for i = from + 1, #s.LayerRemaining do
		local v = s.LayerRemaining[i]
		if type(v) == "number" and v > 0 and not (s.Abandoned and s.Abandoned[i]) then return i end
	end
	return nil
end

local function nextLayerCentroid(s, fromLayer)
	local nl = nextLayerWithRemaining(s, fromLayer)
	if not nl then return nil end
	local sumX, sumY, cnt = 0, 0, 0
	local L, F = s.Layers, s.Filled
	local W = s.W
	local x, y = 0, 0
	local chunk = 0
	for i = 0, s.Total - 1 do
		if buffer.readu8(F, i) ~= 1 and buffer.readu8(L, i) == nl then
			sumX += x
			sumY += y
			cnt += 1
		end
		x += 1
		if x == W then
			x = 0
			y += 1
		end
		chunk += 1
		if chunk >= 65536 then
			chunk = 0
			task.wait()
		end
	end
	if cnt == 0 then return nil end
	return cellToWorld(s, sumX / cnt, sumY / cnt)
end

--//// Tour Building
local plannerChunk = [==[
local function activeRuns(counts, size, minRowCount)
	local runs = {}
	local start, total = nil, 0
	for i = 1, size do
		if (counts[i] or 0) >= minRowCount then
			if not start then
				start = i
				total = 0
			end
			total += counts[i]
		elseif start then
			runs[#runs + 1] = { a = start, b = i - 1, count = total }
			start, total = nil, 0
		end
	end
	if start then
		runs[#runs + 1] = { a = start, b = size, count = total }
	end
	return runs
end

local function bandCenters(a0, b0, halfStep)
	local centers = {}
	local thickness = b0 - a0 + 1
	if thickness <= 2 * halfStep then
		centers[1] = math.floor((a0 + b0) / 2)
		return centers
	end
	local n = math.ceil(thickness / (2 * halfStep))
	local spacing = thickness / n
	for i = 1, n do
		centers[i] = math.floor(a0 + spacing * (i - 0.5))
	end
	return centers
end

local function twoOptRefine(tour, sx, sy, opts)
	opts = opts or {}
	local n = #tour
	local maxN = opts.maxN or 900
	if n < 4 or n > maxN then return end
	local function d2(a, b)
		local dx, dy = a.x - b.x, a.y - b.y
		return dx * dx + dy * dy
	end
	local start = { x = sx, y = sy }
	local passes = opts.passes or 2
	local deadline = opts.deadline
	local yield = opts.yield
	local improved, round = true, 0
	while improved do
		round += 1
		if round > passes then break end
		if deadline and os.clock() > deadline then break end
		improved = false
		for i = 1, n - 1 do
			local prev = (i == 1) and start or tour[i - 1]
			for j = i + 1, n do
				local nxt = tour[j + 1]
				local before = d2(prev, tour[i]) + (nxt and d2(tour[j], nxt) or 0)
				local after = d2(prev, tour[j]) + (nxt and d2(tour[i], nxt) or 0)
				if after + 1e-9 < before then
					local lo, hi = i, j
					while lo < hi do
						tour[lo], tour[hi] = tour[hi], tour[lo]
						lo += 1
						hi -= 1
					end
					improved = true
				end
			end
			if n > 300 and i % 100 == 0 then
				if deadline and os.clock() > deadline then return end
				if yield then yield() end
			end
		end
	end
end

local function orderTour(points, startCx, startCy, cfg, yield)
	local n = #points
	local used = table.create(n, false)
	local tour = {}
	local cx, cy = startCx, startCy
	local scanned = 0
	for _ = 1, n do
		local bestJ, bestD = nil, math.huge
		for j, p in ipairs(points) do
			if not used[j] then
				local dx, dy = p.x - cx, p.y - cy
				local d = dx * dx + dy * dy
				if d < bestD then bestD = d; bestJ = j end
			end
		end
		used[bestJ] = true
		tour[#tour + 1] = points[bestJ]
		cx, cy = points[bestJ].x, points[bestJ].y
		scanned += 1
		if yield and scanned % 32 == 0 then yield() end
	end
	local passes = cfg.twoOptPasses or 2
	if n >= 4 and n <= (cfg.twoOptMax or 400) then
		local maxPasses = (n < 300 and passes) or (n < 750 and math.ceil(passes / 2)) or 2
		twoOptRefine(tour, startCx, startCy, { passes = maxPasses, yield = yield })
	end
	return tour
end

local function groupCells(cells, W, H, radius)
	local n = #cells
	local stops = {}
	if n == 0 then return stops end
	local r2 = radius * radius
	local loX = math.min(radius - 0.5, (W - 1) * 0.5)
	local hiX = math.max(W - radius - 0.5, (W - 1) * 0.5)
	local loY = math.min(radius - 0.5, (H - 1) * 0.5)
	local hiY = math.max(H - radius - 0.5, (H - 1) * 0.5)
	local bs = math.max(1, radius)
	local gw = math.floor((W - 1) / bs) + 1
	local gh = math.floor((H - 1) / bs) + 1
	local buckets = {}
	for i = 1, n do
		local c = cells[i]
		local b = math.floor(c.y / bs) * gw + math.floor(c.x / bs) + 1
		local bucket = buckets[b]
		if bucket then
			bucket[#bucket + 1] = i
		else
			buckets[b] = { i }
		end
	end
	local covered = table.create(n, false)
	for i = 1, n do
		if not covered[i] then
			covered[i] = true
			local cell = cells[i]
			local nearX = cell.x < loX or cell.x > hiX
			local nearY = cell.y < loY or cell.y > hiY
			local sx = (nearX and not nearY) and math.clamp(cell.x, loX, hiX) or cell.x
			local sy = (nearY and not nearX) and math.clamp(cell.y, loY, hiY) or cell.y
			local bx0 = math.max(0, math.floor((sx - radius) / bs))
			local bx1 = math.min(gw - 1, math.floor((sx + radius) / bs))
			local by0 = math.max(0, math.floor((sy - radius) / bs))
			local by1 = math.min(gh - 1, math.floor((sy + radius) / bs))
			for by = by0, by1 do
				for bx = bx0, bx1 do
					local bucket = buckets[by * gw + bx + 1]
					if bucket then
						for _, j in ipairs(bucket) do
							if not covered[j] then
								local dx, dy = cells[j].x - sx, cells[j].y - sy
								if dx * dx + dy * dy <= r2 then covered[j] = true end
							end
						end
					end
				end
			end
			stops[#stops + 1] = { x = sx, y = sy }
		end
	end
	return stops
end

local function leftoverTours(leftover, W, H, cfg, yield, fragments)
	if #leftover == 0 then return end
	local stops = groupCells(leftover, W, H, cfg.radius)
	local gap = cfg.radius * 3 + 4
	local areas = {}
	for _, st in ipairs(stops) do
		local best, bestD = nil, gap * gap
		for _, area in ipairs(areas) do
			local dx = math.max(area.x0 - st.x, 0, st.x - area.x1)
			local dy = math.max(area.y0 - st.y, 0, st.y - area.y1)
			local d = dx * dx + dy * dy
			if d < bestD then
				bestD = d
				best = area
			end
		end
		if best then
			best.stops[#best.stops + 1] = st
			if st.x < best.x0 then best.x0 = st.x end
			if st.x > best.x1 then best.x1 = st.x end
			if st.y < best.y0 then best.y0 = st.y end
			if st.y > best.y1 then best.y1 = st.y end
		else
			areas[#areas + 1] = { stops = { st }, x0 = st.x, x1 = st.x, y0 = st.y, y1 = st.y }
		end
	end
	for _, area in ipairs(areas) do
		fragments[#fragments + 1] = {
			kind = "tour",
			stops = orderTour(area.stops, cfg.scx, cfg.scy, cfg, yield),
			covered = #area.stops,
			bbox = { area.x0, area.y0, area.x1, area.y1 },
		}
	end
end

local function scoreFrags(frags, pixel, speed, turnCost)
	local total = 0
	local px, py = nil, nil
	for _, f in ipairs(frags) do
		local st = f.stops
		for _, p in ipairs(st) do
			if px then
				local seg = math.sqrt((p.x - px) ^ 2 + (p.y - py) ^ 2)
				total += seg * pixel / speed

				if seg * pixel > 30 then
					total += seg * pixel / speed * 0.8
				end
			end
			px, py = p.x, p.y
		end
		total += turnCost
	end
	return total
end

local function polish2Opt(stops, startX, startY, deadline)
	twoOptRefine(stops, startX, startY, { deadline = deadline, maxN = 900, passes = math.huge })
end

local function planFromCells(cells, W, H, cfg, yield)
	if #cells == 0 then return {} end
	local brushR = cfg.brushR
	local claimR = brushR
	local rowC, colC = {}, {}
	for _, i in ipairs(cells) do
		local x = i % W
		local z = i // W
		rowC[z + 1] = (rowC[z + 1] or 0) + 1
		colC[x + 1] = (colC[x + 1] or 0) + 1
	end
	local fragments = {}
	local bandFrags = {}
	local claimed = {}
	local function carve(runs, horizontal, pre, size)
		local runOf = {}
		for id, run in ipairs(runs) do
			for v = run.a, run.b do
				runOf[v] = id
			end
			run.minV = math.huge
			run.maxV = -math.huge
		end
		local runCellBuckets = {}
		for _, i in ipairs(cells) do
			if yield then yield() end
			local x, z = i % W, i // W
			local id = runOf[(horizontal and z or x) + 1]
			if id then
				local v = horizontal and x or z
				local e = runs[id]
				if v < e.minV then e.minV = v end
				if v > e.maxV then e.maxV = v end
				local bucket = runCellBuckets[id]
				if not bucket then
					bucket = {}
					runCellBuckets[id] = bucket
				end
				bucket[#bucket + 1] = i
			end
		end
		for id, run in ipairs(runs) do
			local rows = run.b - run.a + 1
			local width = run.maxV - run.minV + 1
			if run.maxV < run.minV or rows < cfg.bandMinRows or run.count < cfg.bandMinCount
				or width < 4 or run.count / (rows * width) < cfg.bandDense then
				continue
			end
			local centers = bandCenters(run.a - 1, run.b - 1, brushR)
			local covered = 0
			for _, yc in ipairs(centers) do
				local a = math.max(1, yc - brushR + 1)
				local b = math.min(size, yc + brushR + 1)
				covered += pre[b + 1] - pre[a]
			end
			local stops = {}
			local flip = false
			for _, c in ipairs(centers) do
				local s, e = run.minV, run.maxV
				if flip then s, e = e, s end
				if horizontal then
					stops[#stops + 1] = { x = s, y = c }
					stops[#stops + 1] = { x = e, y = c }
				else
					stops[#stops + 1] = { x = c, y = s }
					stops[#stops + 1] = { x = c, y = e }
				end
				flip = not flip
			end
			local approach = math.sqrt((cfg.scx - stops[1].x) ^ 2 + (cfg.scy - stops[1].y) ^ 2)
			local pathTime = ((run.maxV - run.minV + 2 * brushR) * #centers * cfg.pixel) / cfg.speed
				+ #centers * cfg.bandTurn
			local cy0, cy1 = math.huge, -math.huge
			for _, yc in ipairs(centers) do
				if yc < cy0 then cy0 = yc end
				if yc > cy1 then cy1 = yc end
			end
			bandFrags[#bandFrags + 1] = {
				kind = "band",
				bands = #centers,
				stops = stops,
				covered = covered,
				score = covered / (approach * cfg.pixel / cfg.speed + pathTime + 0.001),
				bbox = horizontal
					and { run.minV, cy0, run.maxV, cy1 }
					or { cy0, run.minV, cy1, run.maxV },
			}
			run.centers = centers
			for _, i in ipairs(runCellBuckets[id] or {}) do
				if not claimed[i] then
					local x, z = i % W, i // W
					local c = horizontal and z or x
					local v = horizontal and x or z
					for _, yc in ipairs(centers) do
						if math.abs(c - yc) <= claimR and v >= run.minV and v <= run.maxV then
							claimed[i] = true
							break
						end
					end
				end
			end
		end
	end
	local rowPre = table.create(H + 1, 0)
	for z = 1, H do
		rowPre[z + 1] = rowPre[z] + (rowC[z] or 0)
	end
	carve(activeRuns(rowC, H, cfg.bandMinRowCount), true, rowPre, H)
	local colL = table.create(W, 0)
	for _, i in ipairs(cells) do
		if not claimed[i] then
			colL[(i % W) + 1] += 1
		end
	end
	local colLPre = table.create(W + 1, 0)
	for x = 1, W do
		colLPre[x + 1] = colLPre[x] + colL[x]
	end
	carve(activeRuns(colL, W, cfg.bandMinRowCount), false, colLPre, W)
	for _, f in ipairs(bandFrags) do
		fragments[#fragments + 1] = f
	end

	local leftover = {}
	for _, i in ipairs(cells) do
		if not claimed[i] then
			leftover[#leftover + 1] = { x = i % W, y = i // W }
		end
	end
	leftoverTours(leftover, W, H, cfg, yield, fragments)

	return fragments
end


local SQRT2 = math.sqrt(2)

local function planStrokes(cells, W, H, cfg, yield)
	if #cells == 0 then return {} end
	local brushR = cfg.brushR
	local claimed = {}
	local fragments = {}
	local orients = {
		{
			diag = false, size = H,
			perp = function(i) return (i // W) + 1 end,
			along = function(i) return i % W end,
			stopsFor = function(c0, aMin, aMax)
				return { x = aMin, y = c0 }, { x = aMax, y = c0 }
			end,
		},
		{
			diag = false, size = W,
			perp = function(i) return (i % W) + 1 end,
			along = function(i) return i // W end,
			stopsFor = function(c0, aMin, aMax)
				return { x = c0, y = aMin }, { x = c0, y = aMax }
			end,
		},
		{
			diag = true, size = W + H - 1,
			perp = function(i) return (i % W) - (i // W) + H end,
			along = function(i) return (i % W) + (i // W) end,
			stopsFor = function(c0, aMin, aMax)
				local d = c0 + 1 - H
				return { x = (aMin + d) / 2, y = (aMin - d) / 2 }, { x = (aMax + d) / 2, y = (aMax - d) / 2 }
			end,
		},
		{
			diag = true, size = W + H - 1,
			perp = function(i) return (i % W) + (i // W) + 1 end,
			along = function(i) return (i % W) - (i // W) + H end,
			stopsFor = function(c0, aMin, aMax)
				local d = c0
				return { x = (d + aMin - H) / 2, y = (d - aMin + H) / 2 }, { x = (d + aMax - H) / 2, y = (d - aMax + H) / 2 }
			end,
		},
	}
	for _, o in ipairs(orients) do
		if yield then yield() end
		local halfStep = o.diag and brushR * SQRT2 or brushR
		local lineC = table.create(o.size, 0)
		for _, i in ipairs(cells) do
			if not claimed[i] then
				local p = o.perp(i)
				lineC[p] = (lineC[p] or 0) + 1
			end
		end
		local pre = table.create(o.size + 1, 0)
		for p = 1, o.size do
			pre[p + 1] = pre[p] + (lineC[p] or 0)
		end
		local runs = activeRuns(lineC, o.size, o.diag and 1 or cfg.bandMinRowCount)
		local runOf = {}
		for id, run in ipairs(runs) do
			for v = run.a, run.b do
				runOf[v] = id
			end
			run.minA = math.huge
			run.maxA = -math.huge
		end
		local runCellBuckets = {}
		local stepped = 0
		for _, i in ipairs(cells) do
			stepped += 1
			if yield and stepped % 4096 == 0 then yield() end
			if not claimed[i] then
				local id = runOf[o.perp(i)]
				if id then
					local a = o.along(i)
					local e = runs[id]
					if a < e.minA then e.minA = a end
					if a > e.maxA then e.maxA = a end
					local bucket = runCellBuckets[id]
					if not bucket then
						bucket = {}
						runCellBuckets[id] = bucket
					end
					bucket[#bucket + 1] = i
				end
			end
		end
		for id, run in ipairs(runs) do
			local rows = run.b - run.a + 1
			if run.maxA >= run.minA then
				local steps = o.diag and (run.maxA - run.minA) / 2 or (run.maxA - run.minA)
				local width = o.diag and (run.maxA - run.minA) or (run.maxA - run.minA + 1)
				local area = o.diag and (2 * rows * steps) or (rows * width)
				local thin = o.diag and rows <= 3 or rows <= 3 * brushR
				local spine = (o.diag and steps >= 4 or width >= 4) and thin
					and (width + 1) / (run.count + 1) <= 3
				local okShape = o.diag and (steps >= 4 or rows >= 3)
					or (width >= 4 and (rows >= cfg.bandMinRows or spine))
				local okFill = spine and run.count >= 4
					or (run.count >= cfg.bandMinCount and run.count / (area + 0.001) >= cfg.bandDense)
				if okShape and okFill then
					local centers = bandCenters(run.a - 1, run.b - 1, halfStep)
					local stops = {}
					local covered = 0
					local claimedNow = {}
					local flip = false
					for _, c0 in ipairs(centers) do
						local p1 = c0 + 1
						local lo, hi = p1 - halfStep, p1 + halfStep
						local cMinA, cMaxA = math.huge, -math.huge
						local cellsNow = {}
						for _, i in ipairs(runCellBuckets[id] or {}) do
							if not claimed[i] and not claimedNow[i] then
								local p = o.perp(i)
								if p >= lo and p <= hi then
									local a = o.along(i)
									if a < cMinA then cMinA = a end
									if a > cMaxA then cMaxA = a end
									cellsNow[#cellsNow + 1] = i
								end
							end
						end
						if cMaxA >= cMinA then
							covered += #cellsNow
							local s, e = o.stopsFor(c0, cMinA, cMaxA)
							if flip then s, e = e, s end
							stops[#stops + 1] = s
							stops[#stops + 1] = e
							flip = not flip
							for _, i in ipairs(cellsNow) do
								claimedNow[i] = true
							end
						end
					end
					if #stops >= 2 then
						local bx0, by0, bx1, by1 = math.huge, math.huge, -math.huge, -math.huge
						for _, st in ipairs(stops) do
							if st.x < bx0 then bx0 = st.x end
							if st.x > bx1 then bx1 = st.x end
							if st.y < by0 then by0 = st.y end
							if st.y > by1 then by1 = st.y end
						end
						local lenCells = o.diag and steps * SQRT2 or (run.maxA - run.minA + 1)
						local approach = math.sqrt((cfg.scx - stops[1].x) ^ 2 + (cfg.scy - stops[1].y) ^ 2)
						local pathTime = ((lenCells + 2 * brushR) * #centers * cfg.pixel) / cfg.speed
							+ #centers * cfg.bandTurn
						fragments[#fragments + 1] = {
							kind = "band",
							bands = #centers,
							stops = stops,
							covered = covered,
							score = covered / (approach * cfg.pixel / cfg.speed + pathTime + 0.001),
							bbox = { bx0, by0, bx1, by1 },
						}
						for i in pairs(claimedNow) do
							claimed[i] = true
						end
					end
				end
			end
		end
	end

	local leftover = {}
	for _, i in ipairs(cells) do
		if not claimed[i] then
			leftover[#leftover + 1] = { x = i % W, y = i // W }
		end
	end
	leftoverTours(leftover, W, H, cfg, yield, fragments)

	return fragments
end

local function chainStops(frags, ex, ey, nx, ny)
	local n = #frags
	if n == 0 then return nil end
	local ends = {}
	for fi, f in ipairs(frags) do
		local st = f.stops
		ends[fi] = { st[1], st[#st] }
	end
	local function cost(seq)
		local px, py = ex, ey
		local total = 0
		for _, it in ipairs(seq) do
			local e = ends[it.fi]
			local a = it.rev and e[2] or e[1]
			local b = it.rev and e[1] or e[2]
			total += (a.x - px) ^ 2 + (a.y - py) ^ 2
			px, py = b.x, b.y
		end
		if nx then
			total += (nx - px) ^ 2 + (ny - py) ^ 2
		end
		return total
	end
	local seq
	if n <= 6 then
		local best, bestC = nil, nil
		local used, cur = {}, {}
		local function rec(d)
			if d > n then
				local c = cost(cur)
				if not bestC or c < bestC then
					bestC = c
					best = {}
					for i = 1, n do best[i] = cur[i] end
				end
				return
			end
			for fi = 1, n do
				if not used[fi] then
					used[fi] = true
					cur[d] = { fi = fi, rev = false }
					rec(d + 1)
					cur[d] = { fi = fi, rev = true }
					rec(d + 1)
					used[fi] = false
				end
			end
		end
		rec(1)
		seq = best
	else
		seq = {}
		local remaining = {}
		for fi = 1, n do remaining[fi] = true end
		local px, py = ex, ey
		for _ = 1, n do
			local bestFi, bestRev, bestD = nil, false, nil
			for fi in pairs(remaining) do
				local e = ends[fi]
				for r = 0, 1 do
					local a = (r == 1) and e[2] or e[1]
					local d = (a.x - px) ^ 2 + (a.y - py) ^ 2
					if not bestD or d < bestD then
						bestD, bestFi, bestRev = d, fi, r == 1
					end
				end
			end
			remaining[bestFi] = nil
			seq[#seq + 1] = { fi = bestFi, rev = bestRev }
			local e = ends[bestFi]
			local b = bestRev and e[1] or e[2]
			px, py = b.x, b.y
		end
	end
	local out = {}
	for _, it in ipairs(seq) do
		local st = frags[it.fi].stops
		if it.rev then
			for i = #st, 1, -1 do
				out[#out + 1] = st[i]
			end
		else
			for i = 1, #st do
				out[#out + 1] = st[i]
			end
		end
	end

	twoOptRefine(out, ex, ey, { passes = 2 })
	return out
end

local function planBoxes(cells, W, H, cfg, yield)
	if #cells == 0 then return {} end
	local R = cfg.brushR
	local B = cfg.boxCells or math.clamp(R * 8, 18, 64)
	local gw = math.ceil(W / B)
	local boxes = {}
	for _, i in ipairs(cells) do
		local bx, by = (i % W) // B, (i // W) // B
		local key = by * gw + bx + 1
		local box = boxes[key]
		if not box then
			local x0, y0 = bx * B, by * B
			box = {
				x0 = x0, y0 = y0,
				x1 = math.min(W - 1, x0 + B - 1),
				y1 = math.min(H - 1, y0 + B - 1),
				cells = {},
			}
			boxes[key] = box
		end
		local bc = box.cells
		bc[#bc + 1] = i
		if yield and #bc % 4000 == 0 then yield() end
	end
	local list = {}
	for _, box in pairs(boxes) do
		local sx, sy = 0, 0
		for _, i in ipairs(box.cells) do
			sx += i % W
			sy += i // W
		end
		box.x = sx / #box.cells
		box.y = sy / #box.cells
		list[#list + 1] = box
	end
	table.sort(list, function(a, b)
		if a.y0 ~= b.y0 then return a.y0 < b.y0 end
		return a.x0 < b.x0
	end)
	local ordered = orderTour(list, cfg.scx, cfg.scy, {
		twoOptMax = cfg.twoOptMax or 400,
		twoOptPasses = cfg.twoOptPasses or 2,
	}, yield)
	local boxCfg = {}
	for k, v in pairs(cfg) do boxCfg[k] = v end
	boxCfg.bandMinCount = math.max(10, (cfg.bandMinCount or 40) // 4)
	boxCfg.brushR = math.max(1, R - 0.3)
	local fragments = {}
	local px, py = cfg.scx, cfg.scy
	for bi = 1, #ordered do
		if yield then yield() end
		local box = ordered[bi]
		local nb = ordered[bi + 1]
		local ex = math.clamp(px, box.x0, box.x1)
		local ey = math.clamp(py, box.y0, box.y1)
		local nx, ny
		if nb then
			nx = math.clamp(nb.x, box.x0, box.x1)
			ny = math.clamp(nb.y, box.y0, box.y1)
		elseif cfg.exitCx then
			nx = math.clamp(cfg.exitCx, box.x0, box.x1)
			ny = math.clamp(cfg.exitCy, box.y0, box.y1)
		end
		boxCfg.scx = ex - box.x0
		boxCfg.scy = ey - box.y0
		local lw = box.x1 - box.x0 + 1
		local lh = box.y1 - box.y0 + 1
		local localCells = {}
		for _, i in ipairs(box.cells) do
			localCells[#localCells + 1] = ((i // W) - box.y0) * lw + ((i % W) - box.x0)
		end
		local sub = planStrokes(localCells, lw, lh, boxCfg, yield)
		local stops = nil
		if #sub == 1 then
			local st = sub[1].stops
			local lx, ly = ex - box.x0, ey - box.y0
			local dA = (st[1].x - lx) ^ 2 + (st[1].y - ly) ^ 2
			local dB = (st[#st].x - lx) ^ 2 + (st[#st].y - ly) ^ 2
			if nx then
				local tx, ty = nx - box.x0, ny - box.y0
				dA += (st[#st].x - tx) ^ 2 + (st[#st].y - ty) ^ 2
				dB += (st[1].x - tx) ^ 2 + (st[1].y - ty) ^ 2
			end
			if dB < dA then
				stops = {}
				for j = #st, 1, -1 do stops[#stops + 1] = st[j] end
			else
				stops = st
			end
		elseif #sub > 1 then
			stops = chainStops(sub, ex - box.x0, ey - box.y0,
				nx and (nx - box.x0) or nil, ny and (ny - box.y0) or nil)
		end
		if stops and #stops >= 2 then
			for _, st in ipairs(stops) do
				st.x += box.x0
				st.y += box.y0
			end
			fragments[#fragments + 1] = {
				kind = "box",
				stops = stops,
				covered = #box.cells,
				bbox = { box.x0, box.y0, box.x1, box.y1 },
			}
			px, py = stops[#stops].x, stops[#stops].y
		else
			px, py = box.x, box.y
		end
	end
	return fragments
end

]==]

local plannerOK, planner = pcall(function()
	local fn = loadstring(plannerChunk
		.. "\nreturn { planFromCells = planFromCells, planStrokes = planStrokes, planBoxes = planBoxes, orderTour = orderTour, groupCells = groupCells }")
	if not fn then error("planner chunk compile failed", 0) end
	return fn()
end)
if not plannerOK or type(planner) ~= "table" then
	error("[Volaris] planner failed to compile: " .. tostring(planner))
end

local function planConfig(radius, brushR, scx, scy, forActor)
	return {
		radius = radius,
		brushR = brushR,
		scx = scx,
		scy = scy,
		speed = math.max(16, Global.Values.WalkSpeed or 52),
		pixel = Config.pixelSize,
		bandDense = Config.bandDenseFrac,
		bandMinRows = Config.bandMinRows,
		bandMinCount = Config.bandMinCount,
		bandMinRowCount = Config.bandMinRowCount,
		bandTurn = Config.bandTurnTime,
		twoOptMax = forActor and 400 or Config.twoOptMax,
		twoOptPasses = forActor and 2 or 8,
		boxCells = tonumber(Global.Values.BoxCells) or nil,
	}
end

local function makeYield()
	local budget = 150000
	return function()
		budget -= 1
		if budget <= 0 then
			budget = 150000
			task.wait()
		end
	end
end

local function orderTour(points, startCx, startCy)
	return planner.orderTour(points, startCx, startCy, {
		twoOptMax = Config.twoOptMax,
		twoOptPasses = 8,
	}, makeYield())
end

local function groupCells(s, cells, radius)
	return planner.groupCells(cells, s.W, s.H, radius)
end

local function simplifyRuns(tour, brushR)
	local segments = {}
	local n = #tour
	if n == 0 then return segments end
	local slack2 = (brushR * 0.3) ^ 2
	local i = 1
	while i <= n do
		local p0 = tour[i]
		if not p0 then
			i += 1
			continue
		end
		local ax, ay = p0.x, p0.y
		local last = i
		local j = i + 1
		while j <= n do
			local pj = tour[j]
			if not pj then break end
			local bx, by = pj.x, pj.y
			local dx, dy = bx - ax, by - ay
			local len2 = dx * dx + dy * dy
			local ok = true
			for k = i + 1, j - 1 do
				local pk = tour[k]
				if not pk then
					ok = false
					break
				end
				local px, py = pk.x - ax, pk.y - ay
				local t = 0
				if len2 > 0 then
					t = math.clamp((px * dx + py * dy) / len2, 0, 1)
				end
				local ex, ey = px - t * dx, py - t * dy
				if ex * ex + ey * ey > slack2 then
					ok = false
					break
				end
			end
			if not ok then break end
			last = j
			j += 1
		end
		segments[#segments + 1] = { i0 = i, i1 = last }
		i = last + 1
	end
	return segments
end

local function sweepOrder(stops, cx, cy, bandH)
	local n = #stops
	if n <= 2 then
		return orderTour(stops, cx, cy)
	end
	local x0, y0, x1, y1 = math.huge, math.huge, -math.huge, -math.huge
	for _, st in ipairs(stops) do
		if st.x < x0 then x0 = st.x end
		if st.x > x1 then x1 = st.x end
		if st.y < y0 then y0 = st.y end
		if st.y > y1 then y1 = st.y end
	end
	local w, h = x1 - x0, y1 - y0
	bandH = math.max(1, bandH)
	local depth = math.min(w, h) / bandH
	local fill = n / math.max(1, ((w + 1) / bandH) * ((h + 1) / bandH))
	if depth > 2.5 and fill < 0.75 then
		return orderTour(stops, cx, cy)
	end
	local horizontal = w >= h
	local bands = {}
	for _, st in ipairs(stops) do
		local b = math.floor(((horizontal and st.y or st.x) - (horizontal and y0 or x0)) / bandH)
		local band = bands[b]
		if band then
			band[#band + 1] = st
		else
			bands[b] = { st }
		end
	end
	local order = {}
	for b in pairs(bands) do
		order[#order + 1] = b
	end
	table.sort(order)
	local flip = (horizontal and cy or cx) > (horizontal and (y0 + y1) or (x0 + x1)) * 0.5
	if flip then
		local rev = table.create(#order, nil)
		for i = #order, 1, -1 do
			rev[#order - i + 1] = order[i]
		end
		order = rev
	end
	local desc = (horizontal and cx or cy) > (horizontal and (x0 + x1) or (y0 + y1)) * 0.5
	local out = {}
	for _, b in ipairs(order) do
		local band = bands[b]
		table.sort(band, function(p, q)
			local pm = horizontal and p.x or p.y
			local qm = horizontal and q.x or q.y
			if desc then return pm > qm end
			return pm < qm
		end)
		for _, st in ipairs(band) do
			out[#out + 1] = st
		end
		desc = not desc
	end
	return out
end

local function fragSummary(fragments)
	local bands, stops = 0, 0
	for _, frag in ipairs(fragments) do
		if frag.kind == "band" then
			bands += frag.bands
		end
		stops += #frag.stops
	end
	if bands > 0 then
		return ("%d bands + %d stops"):format(bands, stops)
	end
	return ("%d stops"):format(stops)
end

local function cellsFromSet(set, W)
	local cells = {}
	for idx in pairs(set) do
		local i = idx - 1
		cells[#cells + 1] = { x = i % W, y = i // W }
	end
	return cells
end

local function collectGreenCells()
	local cells = {}
	for idx in pairs(Visuals.green) do
		cells[#cells + 1] = idx - 1
	end
	return cells
end

local function buildFragments(cur, radius, brushR, scx, scy, cellsOverride)
	local cells = cellsOverride or collectGreenCells()
	if #cells == 0 then return {} end
	return planner.planFromCells(cells, cur.W, cur.H, planConfig(radius, brushR, scx, scy, false), makeYield())
end

local function buildStrokes(cur, radius, brushR, scx, scy, cellsOverride)
	local cells = cellsOverride or collectGreenCells()
	if #cells == 0 then return {} end
	local cfg = planConfig(radius, brushR, scx, scy, false)
	if nextLayerWithRemaining(cur, cur.Layer) then
		local centroid = nextLayerCentroid(cur, cur.Layer)
		if centroid then
			cfg.exitCx, cfg.exitCy = worldToCell(cur, centroid)
		end
	end
	return planner.planBoxes(cells, cur.W, cur.H, cfg, makeYield())
end

local function greensInBox(s, x0, y0, x1, y1, margin, wantLayer)
	wantLayer = wantLayer or s.Layer
	local second = (wantLayer == s.Layer) and s.Second or nil
	x0 = math.max(0, math.floor(x0 - margin))
	y0 = math.max(0, math.floor(y0 - margin))
	x1 = math.min(s.W - 1, math.ceil(x1 + margin))
	y1 = math.min(s.H - 1, math.ceil(y1 + margin))
	local cells = {}
	local W = s.W
	local scanned = 0
	for y = y0, y1 do
		local base = y * W
		for x = x0, x1 do
			local idx = base + x + 1
			if buffer.readu8(s.Filled, idx - 1) ~= 1 then
				local li = buffer.readu8(s.Layers, idx - 1)
				if li == wantLayer or (second and li == second) then
					cells[#cells + 1] = { x = x, y = y }
				end
			end
		end
		scanned += x1 - x0 + 1
		if scanned >= 150000 then
			scanned = 0
			task.wait()
		end
	end
	return cells
end

--//// Movement
local executeTour
do
local function segmentGreen(cur, tour, seg, brushR)
	local i0, i1 = seg.i0, seg.i1
	local span = i1 - i0
	local step = math.max(1, brushR)
	if span > step * 40 then
		step = math.ceil(span / 40)
	end
	for i = i0, i1, step do
		local p = tour[i]
		if p then
			if greenAround(cur, p.x, p.y, brushR) > 0 then
				return true
			end
		elseif os.clock() - (Global.TourGapWarnedAt or 0) > 30 then
			Global.TourGapWarnedAt = os.clock()
			warn(("[Volaris] tour gap at %d (seg %d-%d, n=%s)"):format(i, i0, i1, tostring(#tour)))
		end
	end
	local p = tour[i1]
	return p ~= nil and greenAround(cur, p.x, p.y, brushR) > 0
end

local function streamCellTour(s, tour, passDist)
	local layer = s.Layer
	local brushR = brushRadiusCells()
	local lastCheck = os.clock()
	local _, _, root0 = getChar()
	local lastPos = root0 and root0.Position or Vector3.zero
	local visited = 0
	local myGen = Global.BlatantGen or 0
	local segs = simplifyRuns(tour, brushR)
	local prevTarget = nil
	for si, seg in ipairs(segs) do
		if not on() then return visited end
		if (Global.BlatantGen or 0) ~= myGen then return visited, true end
		local cur = plots[s.Name]
		if not cur or cur.Layer ~= layer then break end
		if segmentGreen(cur, tour, seg, brushR) then
			local pEnd = tour[seg.i1]
			if not pEnd then continue end
			visited += seg.i1 - seg.i0 + 1
			local target = cellToWorld(cur, pEnd.x, pEnd.y)
			local _, _, rootAt = getChar()
			local dist = rootAt and ((target - rootAt.Position) * Config.flatMask).Magnitude or 0
			local _, hAt = getChar()
			local ws = hAt and math.max(10, hAt.WalkSpeed * 0.8) or 14
			local timeout = math.min(1.0 + dist / ws, 20)
			local reach = passDist
			if rootAt and prevTarget then
				local dir = (target - prevTarget) * Config.flatMask
				local dirMag = dir.Magnitude
				if dirMag > 0.5 then
					local rel = ((rootAt.Position - prevTarget) * Config.flatMask):Dot(dir / dirMag)
					if rel > passDist then
						prevTarget = target
						continue
					end
				end
			end
			local t0 = os.clock()
			local lastMag = math.huge
			while on() do
				if (Global.BlatantGen or 0) ~= myGen then return visited, true end
				local _, h, root = getChar()
				if not h or not root then return visited end
				local mag = ((root.Position - target) * Config.flatMask).Magnitude
				if mag <= reach then break end
				if mag > lastMag + 1 then break end
				lastMag = mag
				h:MoveTo(target)
				if os.clock() - t0 > timeout then break end
				if os.clock() - lastCheck >= 1.2 then
					if ((root.Position - lastPos) * Config.flatMask).Magnitude < 0.5 then
						h.Jump = true
					end
					lastPos = root.Position
					lastCheck = os.clock()
				end
				task.wait(0.05)
			end
			prevTarget = target
		end
	end
	return visited
end

local function blatantTour(s, tour, dwell)
	local layer = s.Layer
	local brushR = brushRadiusCells()
	local visited = 0
	local myGen = Global.BlatantGen or 0
	local _, h0, r0 = getChar()
	local glideY = r0 and r0.Position.Y
	if h0 and r0 then pcall(function() h0:MoveTo(r0.Position) end) end
	local glideSpeed = 300
	local stepTick = 0.03
	for _, seg in ipairs(simplifyRuns(tour, brushR)) do
		if not on() then return visited end
		if (Global.BlatantGen or 0) ~= myGen then return visited, true end
		local cur = plots[s.Name]
		if not cur or cur.Layer ~= layer then break end
		if segmentGreen(cur, tour, seg, brushR) then
			local pStart, pEnd = tour[seg.i0], tour[seg.i1]
			if not pStart or not pEnd then continue end
			visited += seg.i1 - seg.i0 + 1
			local pos = cellToWorld(cur, pStart.x, pStart.y)
			local target = cellToWorld(cur, pEnd.x, pEnd.y)
			local _, _, root = getChar()
			if not root then return visited end
			if ((root.Position - pos) * Config.flatMask).Magnitude > Config.jumpDist then
				root.CFrame = CFrame.new(pos.X, pos.Y + 2, pos.Z)
				if dwell >= 0.2 then
					task.wait(dwell * 0.4)
					local _, _, root2 = getChar()
					if root2 then
						root2.CFrame = CFrame.new(pos.X, pos.Y + 2, pos.Z)
					end
					task.wait(dwell * 0.6)
				else
					task.wait(dwell)
				end
				local _, _, rG = getChar()
				if rG then glideY = rG.Position.Y end
			end
			local segDist = ((target - pos) * Config.flatMask).Magnitude
			local deadline = os.clock() + math.min(4 + segDist / glideSpeed, 30)
			while on() do
				if (Global.BlatantGen or 0) ~= myGen then return visited, true end
				local _, h2, root2 = getChar()
				if not h2 or not root2 then return visited end
				local flat = (target - root2.Position) * Config.flatMask
				local mag = flat.Magnitude
				if mag <= 2 then break end
				local stepDist = math.min(glideSpeed * stepTick, mag)
				local np = root2.Position + (flat / mag) * stepDist
				root2.CFrame = CFrame.new(np.X, glideY or np.Y, np.Z)
				root2.AssemblyLinearVelocity = Vector3.zero
				if os.clock() > deadline then break end
				task.wait(stepTick)
			end
		end
	end
	return visited
end

executeTour = function(s, tour, passDist, dwell)
	local visited, switched
	if Global.Toggles.Blatant then
		visited, switched = blatantTour(s, tour, dwell or 0.2)
	else
		visited, switched = streamCellTour(s, tour, passDist)
	end
	if switched and on() then
		if Global.Toggles.Blatant then
			visited = blatantTour(s, tour, dwell or 0.2)
		else
			visited = streamCellTour(s, tour, passDist)
		end
	end
	return visited
end
end


--//// Coop
Global.Coop = Global.Coop or {
	active = false, members = {}, ownerUserId = nil, plot = "", lastRefresh = 0,
}
local Coop = Global.Coop
Coop.motion = {}
do
	local coopRemote = Net:FindFirstChild("RF/GetCoopParty")
	
	local function coopRefresh()
		if not coopRemote then return false end
		local ok, res = pcall(function()
			return coopRemote:InvokeServer()
		end)
		if ok and type(res) == "table" and type(res.Members) == "table" then
			local members = {}
			for _, m in ipairs(res.Members) do
				if type(m) == "table" and type(m.UserId) == "number" then
					members[#members + 1] = {
						userId = m.UserId,
						name = tostring(m.Name or m.UserId),
						owner = m.IsOwner == true,
					}
				end
			end
			table.sort(members, function(a, b)
				return a.userId < b.userId
			end)
			Coop.members = members
			Coop.ownerUserId = tonumber(res.OwnerUserId)
			Coop.plot = tostring(res.Plot or "")
			Coop.active = #members >= 2
			Coop.lastRefresh = os.clock()
			return true
		end
		Coop.active = false
		return false
	end
	
	local function coopAmLeader()
		if not Coop.active then return true end
		local leader = Coop.ownerUserId or (Coop.members[1] and Coop.members[1].userId)
		return leader == Players.LocalPlayer.UserId
	end
	
	local function coopPartnerNames()
		local myId = Players.LocalPlayer.UserId
		local names = {}
		for _, m in ipairs(Coop.members) do
			if m.userId ~= myId then
				names[#names + 1] = m.name
			end
		end
		return names
	end
	

	if Global.Connections.CoopParty then
		Global.Connections.CoopParty:Disconnect()
		Global.Connections.CoopParty = nil
	end
	local coopEvent = Net:FindFirstChild("RE/CoopParty")
	if coopEvent then
		Global.Connections.CoopParty = coopEvent.OnClientEvent:Connect(function()
			task.spawn(coopRefresh)
		end)
	end
	task.spawn(coopRefresh)
	
	Coop.refresh = coopRefresh
	Coop.amLeader = coopAmLeader
	Coop.partnerNames = coopPartnerNames
end

function Coop.partnerZones(cur, margin)
	local zones = {}
	for _, m in ipairs(Coop.members) do
		if m.userId ~= Players.LocalPlayer.UserId then
			local plr = Players:GetPlayerByUserId(m.userId)
			local char = plr and plr.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				local x, y = worldToCell(cur, root.Position)
				if x >= -margin and y >= -margin and x <= cur.W + margin and y <= cur.H + margin then
					zones[#zones + 1] = { x - margin, y - margin, x + margin, y + margin }
				end
			end
		end
	end
	return zones
end

local CoopMesh = { available = nil, rates = {}, seen = {} }
Coop.mesh = CoopMesh
local meshDir = "VolarisHub/coop"

--//// Coop area partition
do
local coopStripCache = nil
function Coop.stripCuts(s, layer)
	local myId = Players.LocalPlayer.UserId
	local key = s.Name .. ":" .. layer .. ":" .. #Coop.members .. ":" .. myId
	if coopStripCache and coopStripCache.key == key then
		return coopStripCache.data
	end
	local myIndex, count = nil, #Coop.members
	for i, m in ipairs(Coop.members) do
		if m.userId == myId then
			myIndex = i
			break
		end
	end
	if not myIndex then return nil end
	local L = s.Layers
	if typeof(L) ~= "buffer" or not s.Total then return nil end
	local colW, rowW = {}, {}
	local bx0, bx1, by0, by1 = math.huge, -math.huge, math.huge, -math.huge
	local any = false
	for i = 0, s.Total - 1 do
		if buffer.readu8(L, i) == layer then
			any = true
			local x, y = i % s.W, i // s.W
			colW[x] = (colW[x] or 0) + 1
			rowW[y] = (rowW[y] or 0) + 1
			if x < bx0 then bx0 = x end
			if x > bx1 then bx1 = x end
			if y < by0 then by0 = y end
			if y > by1 then by1 = y end
		end
		if i % 200000 == 199999 then task.wait() end
	end
	if not any then return nil end
	local axis = (bx1 - bx0) >= (by1 - by0) and "x" or "y"
	local hist = axis == "x" and colW or rowW
	local lo = axis == "x" and bx0 or by0
	local hi = axis == "x" and bx1 or by1
	local total = 0
	for c = lo, hi do
		local n = hist[c] or 0
		total += (n > 0 and n <= 2) and n * 3 or n
	end
	local weights, wtotal = {}, 0
	local published = nil
	if CoopMesh.available == true then
		local leaderId = Coop.ownerUserId or (Coop.members[1] and Coop.members[1].userId)
		local rateFile = meshDir .. "/rates_" .. tostring(s.Name or "?") .. "_" .. tostring(layer) .. ".json"
		if leaderId == myId then
			if s.CoopRatesWrittenLayer ~= layer then
				s.CoopRatesWrittenLayer = layer
				local ratesOut = {}
				for _, m in ipairs(Coop.members) do
					local r = (m.userId == myId) and (Global.MyPaintRate or 0) or (CoopMesh.rates[m.userId] or 0)
					r = math.floor((r + 12.5) / 25) * 25
					ratesOut[tostring(m.userId)] = math.max(25, r)
				end
				pcall(function()
					writefile(rateFile, game:GetService("HttpService"):JSONEncode(
						{ layer = layer, rates = ratesOut, t = os.time() }))
				end)
			end
		elseif not s.CoopRatesWaited then
			s.CoopRatesWaited = true
			local t0 = os.clock()
			while not isfile(rateFile) and os.clock() - t0 < 1.5 do
				task.wait(0.1)
			end
		end
		pcall(function()
			if isfile(rateFile) then
				local decoded = game:GetService("HttpService"):JSONDecode(readfile(rateFile))
				if type(decoded) == "table" and decoded.layer == layer and type(decoded.rates) == "table" then
					published = decoded.rates
				end
			end
		end)
	end
	for i, m in ipairs(Coop.members) do
		local r = published and tonumber(published[tostring(m.userId)])
		if not r or r <= 0 then r = 1 end
		weights[i] = r
		wtotal += r
	end
	local wPrefix = {}
	local wsum = 0
	for i = 1, count do
		wsum += weights[i]
		wPrefix[i] = wsum
	end
	local cuts = { lo }
	local acc, ci = 0, 1
	for c = lo, hi do
		local n = hist[c] or 0
		acc += (n > 0 and n <= 2) and n * 3 or n
		while ci < count and acc >= total * (wPrefix[ci] / wtotal) do
			cuts[#cuts + 1] = c + 1
			ci += 1
		end
	end
	while #cuts < count + 1 do
		cuts[#cuts + 1] = hi + 1
	end
	cuts[#cuts] = hi + 1
	local data = { cuts = cuts, axis = axis, count = count, myIndex = myIndex }
	coopStripCache = { key = key, data = data }
	return data
end
function Coop.stripFor(s, layer)
	if not (Coop.active and Coop.members and #Coop.members >= 2) then
		return nil
	end
	if os.clock() - (Coop.lastRefresh or 0) > 5 and Coop.refresh then
		Coop.refresh()
	end
	local data = Coop.stripCuts(s, layer)
	if not data then return nil end
	return {
		axis = data.axis,
		a0 = data.cuts[data.myIndex],
		a1 = data.cuts[data.myIndex + 1] - 1,
		cuts = data.cuts,
		count = data.count,
	}
end
end

--//// Paint Pass
local paintCrawlCells, paintLayer, advanceLayer
do
local function paintCrawlCellsJob(s, cells, force, dwellPerCell)
	local blatant = Global.Toggles.Blatant == true
	local confirmWait = dwellPerCell or 0.9
	for _, st in ipairs(cells) do
		if not on() then return end
		local cur = plots[s.Name]
		if not cur or cur.Layer ~= s.Layer then return end
		local key = st.y * cur.W + st.x
		if not force and buffer.readu8(cur.Filled, key) == 1 then continue end
		local pos = cellToWorld(cur, st.x, st.y)
		local _, hum, root = getChar()
		if not hum or not root then return end
		if blatant then
			if ((root.Position - pos) * Config.flatMask).Magnitude > 1 then
				root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
			end
		else
			local oldWs = hum.WalkSpeed
			local t0 = os.clock()
			while on() and os.clock() - t0 < 4 do
				if ((root.Position - pos) * Config.flatMask).Magnitude <= 6 then break end
				hum:MoveTo(pos)
				task.wait(0.05)
				_, hum, root = getChar()
				if not hum or not root then return end
			end
			if on() and hum and root then
				hum.WalkSpeed = math.min(hum.WalkSpeed, 24)
				local t1 = os.clock()
				while on() and os.clock() - t1 < 2 do
					if ((root.Position - pos) * Config.flatMask).Magnitude <= 1 then break end
					hum:MoveTo(pos)
					task.wait(0.05)
					_, hum, root = getChar()
					if not hum or not root then break end
				end
				local _, hR = getChar()
				if hR then hR.WalkSpeed = oldWs end
			end
		end
		local confirmT = os.clock()
		while on() and os.clock() - confirmT < confirmWait do
			local cur2 = plots[s.Name]
			if cur2 and buffer.readu8(cur2.Filled, key) == 1 then break end
			task.wait(0.08)
		end
	end
end

paintCrawlCells = function(s, cells, force, dwellPerCell)
	Global.Crawling = (Global.Crawling or 0) + 1
	local okC, errC = pcall(paintCrawlCellsJob, s, cells, force, dwellPerCell)
	Global.Crawling = math.max(0, (Global.Crawling or 1) - 1)
	if not okC then
		error(errC)
	end
end

local function spliceEntry(cur, fragments, brushR, area)
	local f1 = fragments[1]
	if not f1 or type(f1.stops) ~= "table" or #f1.stops == 0 then return end
	local pcx, pcy = charCell(cur)
	local bestK, bestD = 1, math.huge
	for k, st in ipairs(f1.stops) do
		local d = (st.x - pcx) ^ 2 + (st.y - pcy) ^ 2
		if d < bestD then
			bestD, bestK = d, k
		end
	end
	if bestK > 1 then
		local n = #f1.stops
		local rotated = table.create(n, nil)
		for i = bestK, n do
			rotated[i - bestK + 1] = f1.stops[i]
		end
		for i = 1, bestK - 1 do
			rotated[n - bestK + i] = f1.stops[i]
		end
		f1.stops = rotated
		f1.bbox = nil
	end
	local green = Visuals.green
	if not green or Visuals.greenPlot ~= cur.Name or Visuals.greenLayer ~= cur.Layer then
		return
	end
	local entry = f1.stops[1]
	local dx, dy = entry.x - pcx, entry.y - pcy
	local len2 = dx * dx + dy * dy
	if len2 < 1 then return end
	local band2 = brushR * brushR
	local corridor = {}
	local walked = 0
	for key in pairs(green) do
		local i0 = key - 1
		local x, y = i0 % cur.W, i0 // cur.W
		local inArea = not area
			or (area.axis == "x" and x >= area.a0 and x <= area.a1)
			or (area.axis == "y" and y >= area.a0 and y <= area.a1)
		if inArea then
			local t = math.clamp(((x - pcx) * dx + (y - pcy) * dy) / len2, 0, 1)
			local ex, ey = pcx + t * dx, pcy + t * dy
			local ddx, ddy = x - ex, y - ey
			if ddx * ddx + ddy * ddy <= band2 then
				corridor[#corridor + 1] = { x = x, y = y, t = t }
			end
		end
		walked += 1
		if walked % 65536 == 0 then
			task.wait()
		end
	end
	if #corridor == 0 then return end
	table.sort(corridor, function(a, b) return a.t < b.t end)
	local stops = {}
	local lastT = -math.huge
	local step = (brushR * 0.8) / math.sqrt(len2)
	for _, c in ipairs(corridor) do
		if c.t - lastT >= step then
			stops[#stops + 1] = { x = c.x, y = c.y }
			lastT = c.t
		end
	end
	local lastC = corridor[#corridor]
	local lastStop = stops[#stops]
	if not lastStop or lastStop.x ~= lastC.x or lastStop.y ~= lastC.y then
		stops[#stops + 1] = { x = lastC.x, y = lastC.y }
	end
	table.insert(fragments, 1, { kind = "box", stops = stops, covered = #stops })
end
paintLayer = function(s)
	local layer = s.Layer
	local brushR = brushRadiusCells()
	local blatant = Global.Toggles.Blatant == true
	local lastCount = math.huge
	local stalls = 0
	local forcedRescan = false
	local round = 0
	local round1Frags = nil
	s.Refused = s.Refused or {}
	local refused = s.Refused[layer] or {}
	s.Refused[layer] = refused
	s.Attempts = s.Attempts or {}
	local attempts = s.Attempts[layer] or {}
	s.Attempts[layer] = attempts
	local layerRescanned = false
	if s.Abandoned and s.Abandoned[layer] then
		return
	end
	local prefetchFired = false
	local function fireNextPrefetch(pfCur, radius, brushR, ex, ey)
		if prefetchFired or not on() then return end
		if not (pfCur and pfCur.Layer == layer and ActorBridge and ActorBridge.firePrefetch) then return end
		local nextL = nextLayerWithRemaining(pfCur, layer)
		if not nextL then
			prefetchFired = true
			return
		end
		local L, F = pfCur.Layers, pfCur.Filled
		if typeof(L) ~= "buffer" or typeof(F) ~= "buffer" or not pfCur.Total then return end
		local nArea = Coop.stripFor(pfCur, nextL)
		local nCells = {}
		local chunk = 0
		for i = 0, pfCur.Total - 1 do
			if buffer.readu8(L, i) == nextL and buffer.readu8(F, i) ~= 1 then
				local keep = true
				if nArea then
					local x, y = i % pfCur.W, i // pfCur.W
					keep = (nArea.axis == "x" and x >= nArea.a0 and x <= nArea.a1)
						or (nArea.axis == "y" and y >= nArea.a0 and y <= nArea.a1)
				end
				if keep then
					nCells[#nCells + 1] = i + 1
				end
			end
			chunk += 1
			if chunk >= 65536 then
				chunk = 0
				task.wait()
			end
		end
		if #nCells == 0 then
			prefetchFired = true
			return
		end
		local est = #nCells / math.max(Global.MyPaintRate or 40, 12)
		local budget = math.clamp(est * 0.7, 8, 150)
		if ActorBridge.firePrefetch(pfCur, radius, brushR, ex, ey, nextL, nCells, budget) then
			prefetchFired = true
		end
	end
	local area = Coop.stripFor(s, layer)
	local areaFilter = nil
	if area then
		if area.axis == "x" then
			areaFilter = function(c)
				return c.x >= area.a0 and c.x <= area.a1
			end
		else
			areaFilter = function(c)
				return c.y >= area.a0 and c.y <= area.a1
			end
		end
	end
	while round < Config.maxRounds do		round += 1
		if not on() then return end
		local cur = plots[s.Name]
		if not cur or cur.Layer ~= layer then return end
		local left = layerRemainingOf(cur, layer)
		local greens = Visuals.greensFor(cur, left)
		local n = greens.greenCount
		if n == 0 then
			if (left or 0) > 0 and not forcedRescan then
				forcedRescan = true
				Visuals.invalidate()
				task.wait(0.3)
				continue
			end
			if (left or 0) > 0 then
				if not Global.PhantomResyncAt or os.clock() - Global.PhantomResyncAt > 30 then
					Global.PhantomResyncAt = os.clock()
					Visuals.invalidate()
					pcall(function() Remotes.requestRemote:InvokeServer() end)
					task.wait(1.0)
				end
				if not areaFilter then
					s.Abandoned = s.Abandoned or {}
					s.Abandoned[layer] = true
					s.GaveUp = layer
				end
			end
			return
		end
		forcedRescan = false

		local radius = (round == 1) and brushR * 0.85 or brushR * 0.7
		local scx, scy = charCell(cur)
		local okFrags, fragments = true, nil
		local actorPlanned = false
		if round == 1 then
			local areaCellIdx = nil
			if areaFilter then
				areaCellIdx = {}
				for _, c in ipairs(greensInBox(cur, 0, 0, cur.W - 1, cur.H - 1, 0, layer)) do
					local key = c.y * cur.W + c.x
					if not refused[key] and areaFilter(c) then
						areaCellIdx[#areaCellIdx + 1] = key
					end
				end
			end
			local ps = Global.PrefetchStats or { hit = 0, miss = 0, localPlan = 0 }
			Global.PrefetchStats = ps
			if areaCellIdx and #areaCellIdx == 0 then
				fragments = {}
			else
				local pf = ActorBridge and ActorBridge.prefetch
				if pf and pf.frags and pf.plot == cur.Name and pf.layer == cur.Layer then
					fragments = pf.frags
					ActorBridge.prefetch = nil
					actorPlanned = true
					ps.hit += 1
					local lf = fragments[#fragments]
					local ex, ey = charCell(cur)
					if lf and type(lf.stops) == "table" and #lf.stops > 0 then
						local st = lf.stops[#lf.stops]
						ex, ey = st.x, st.y
					end
					fireNextPrefetch(cur, radius, brushR, ex, ey)
				elseif requestActorPlan then
					ps.miss += 1
					local extWindow = nil
					if not s.Planned1 then
						s.Planned1 = true
						extWindow = 6
					end
					fragments = requestActorPlan(cur, radius, brushR, scx, scy, "boxes", extWindow, areaCellIdx)
					actorPlanned = fragments ~= nil
					if fragments then
						local lf = fragments[#fragments]
						local ex, ey = charCell(cur)
						if lf and type(lf.stops) == "table" and #lf.stops > 0 then
							local st = lf.stops[#lf.stops]
							ex, ey = st.x, st.y
						end
						fireNextPrefetch(cur, radius, brushR, ex, ey)
					end
				end
				if not fragments then
					ps.localPlan += 1
					okFrags, fragments = pcall(buildStrokes, cur, radius, brushR, scx, scy, areaCellIdx)
					if not okFrags or not fragments or #fragments == 0 then
						if not okFrags then
							warn("[Volaris] box planning failed: " .. tostring(fragments))
						end
						okFrags, fragments = pcall(buildFragments, cur, radius, brushR, scx, scy, areaCellIdx)
					end
					if not okFrags or not fragments or #fragments == 0 then
						if not okFrags then
							warn("[Volaris] fragment planning failed: " .. tostring(fragments))
						end
						local cells
						if areaCellIdx then
							cells = {}
							for _, i in ipairs(areaCellIdx) do
								cells[#cells + 1] = { x = i % cur.W, y = i // cur.W }
							end
						else
							cells = cellsFromSet(Visuals.green, cur.W)
						end
						fragments = { {
							kind = "tour",
							stops = sweepOrder(groupCells(cur, cells, radius), scx, scy, radius),
							covered = #cells,
						} }
					end
				end
			end
			round1Frags = {}
			for _, f in ipairs(fragments) do
				round1Frags[#round1Frags + 1] = f
			end
			if actorPlanned then
				spliceEntry(cur, fragments, brushR, area)
			end
		else
			local cells = {}
			local nPartner = 0
			for _, c in ipairs(greensInBox(cur, 0, 0, cur.W - 1, cur.H - 1, 0, layer)) do
				local key = c.y * cur.W + c.x
				if not refused[key] then
					if not areaFilter or areaFilter(c) then
						cells[#cells + 1] = c
					else
						nPartner += 1
					end
				end
			end
			if #cells == 0 then
				if areaFilter and (left or 0) > 0 then
					if nPartner == 0 then
						areaFilter = nil
					else
						if nPartner ~= s.CoopPartnerLast then
							s.CoopPartnerLast = nPartner
							s.CoopPartnerChangedAt = os.clock()
						end
						s.CoopPartnerChangedAt = s.CoopPartnerChangedAt or os.clock()
						if os.clock() - s.CoopPartnerChangedAt > 45 then
							areaFilter = nil
							warn("[Volaris] coop: partner idle for 45s. finishing the colour solo")
						end
					end
					task.wait(0.5)
					continue
				end
				if (left or 0) > 0 and not layerRescanned then
					layerRescanned = true
					Visuals.invalidate()
					task.wait(0.25)
					continue
				end
				if (left or 0) > 0 then
					if not Global.PhantomResyncAt or os.clock() - Global.PhantomResyncAt > 30 then
						Global.PhantomResyncAt = os.clock()
						Visuals.invalidate()
						pcall(function() Remotes.requestRemote:InvokeServer() end)
						task.wait(1.0)
					end
					if not areaFilter then
						s.Abandoned = s.Abandoned or {}
						s.Abandoned[layer] = true
						s.GaveUp = layer
					end
				end
				return
			end
			if round == 2 then
				Global.LastLeftovers = { layer = layer, count = #cells }
				fragments = { {
					kind = "tour",
					stops = sweepOrder(groupCells(cur, cells, radius), scx, scy, radius),
					covered = #cells,
				} }
			else
				paintCrawlCells(cur, cells)
				for _, c in ipairs(cells) do
					local cur2 = plots[s.Name]
					if not cur2 or cur2.Layer ~= layer then return end
					local key = c.y * cur2.W + c.x
					if buffer.readu8(cur2.Filled, key) ~= 1 then
						attempts[key] = (attempts[key] or 0) + 1
						if attempts[key] >= 2 then
							refused[key] = true
							warn(("[Volaris] colour %d: cell %d,%d refused after crawled attempts"):format(layer, c.x, c.y))
						end
					end
				end
				continue
			end
		end
		for _, frag in ipairs(fragments) do
			if not frag.bbox then
				local x0, y0, x1, y1 = math.huge, math.huge, -math.huge, -math.huge
				for _, st in ipairs(frag.stops) do
					if st.x < x0 then x0 = st.x end
					if st.x > x1 then x1 = st.x end
					if st.y < y0 then y0 = st.y end
					if st.y > y1 then y1 = st.y end
				end
				frag.bbox = { x0, y0, x1, y1 }
			end
		end
		setPhase(((round == 1)
				and ((blatant and "teleporting" or "sweeping") .. (" Colour %d (%d studs, %s)"):format(layer, n, fragSummary(fragments)))
				or ("verifying Colour %d, round %d, %d left"):format(layer, round - 1, n))
			.. (actorPlanned and " · parallel" or "")
			.. (Coop.active and " · coop" or ""))

		local passDist = round == 1 and 1.0 or 0.6
		local dwell = round == 1 and 0.12 or 0.3
		local ignoreZones = false
		local skippedAll = 0
		while #fragments > 0 do
			if not on() then return end
			local cur2 = plots[s.Name]
			if not cur2 or cur2.Layer ~= layer then return end
			local ccx, ccy = charCell(cur2)
			local zones = (Coop.active and not areaFilter and not ignoreZones)
				and Coop.partnerZones(cur2, brushR * 2 + 8) or nil
			local bestI = nil
			if fragments[1].kind == "box" then
				for i, frag in ipairs(fragments) do
					local b = frag.bbox
					if zones then
						local hit = false
						for _, z in ipairs(zones) do
							if b[1] <= z[3] and b[3] >= z[1] and b[2] <= z[4] and b[4] >= z[2] then
								hit = true
								break
							end
						end
						if hit then continue end
					end
					bestI = i
					break
				end
			else
				local bestD = math.huge
				for i, frag in ipairs(fragments) do
					local b = frag.bbox
					if zones then
						local hit = false
						for _, z in ipairs(zones) do
							if b[1] <= z[3] and b[3] >= z[1] and b[2] <= z[4] and b[4] >= z[2] then
								hit = true
								break
							end
						end
						if hit then continue end
					end
					local dx = math.max(b[1] - ccx, 0, ccx - b[3])
					local dy = math.max(b[2] - ccy, 0, ccy - b[4])
					local d = dx * dx + dy * dy
					if d < bestD then
						bestD = d
						bestI = i
					end
				end
			end
			if not bestI then
				local kept = {}
				for _, frag in ipairs(fragments) do
					local b = frag.bbox
					if #greensInBox(cur2, b[1], b[2], b[3], b[4], 0, layer) > 0 then
						kept[#kept + 1] = frag
					end
				end
				fragments = kept
				if #fragments == 0 then break end
				skippedAll += 1
				if skippedAll > 25 then
					ignoreZones = true
				end
				task.wait(0.4)
				continue
			end
			skippedAll = 0
			local frag = table.remove(fragments, bestI)
			local stops = frag.stops
			if next(refused) then
				local kept = {}
				for _, st in ipairs(stops) do
					if not refused[st.y * cur2.W + st.x] then
						kept[#kept + 1] = st
					end
				end
				if #kept == 0 then
					continue
				end
				stops = kept
			end
			if frag.kind == "band" then
				local first, last = stops[1], stops[#stops]
				local dFirst = (first.x - ccx) ^ 2 + (first.y - ccy) ^ 2
				local dLast = (last.x - ccx) ^ 2 + (last.y - ccy) ^ 2
				if dLast < dFirst then
					local rev = table.create(#stops, nil)
					for i = #stops, 1, -1 do
						rev[#stops - i + 1] = stops[i]
					end
					stops = rev
				end
			elseif frag.kind ~= "box" then
				stops = sweepOrder(stops, ccx, ccy, radius)
			end
			local flog = Global.FragmentLog
			if type(flog) ~= "table" then
				flog = {}
				Global.FragmentLog = flog
			end
			flog[#flog + 1] = {
				t = os.clock(), layer = layer, round = round, kind = frag.kind,
				n = #stops, bx0 = frag.bbox[1], by0 = frag.bbox[2],
				bx1 = frag.bbox[3], by1 = frag.bbox[4],
				a = stops[1] and { stops[1].x, stops[1].y },
				b = stops[#stops] and { stops[#stops].x, stops[#stops].y },
			}
			while #flog > 24 do
				table.remove(flog, 1)
			end
			executeTour(cur2, stops, passDist, dwell)

			local curS = plots[s.Name]
			if curS and curS.Layer == layer and on() then
				local scx2, scy2 = charCell(curS)
				local pr = brushRadiusCells() + 2
				local nearCells = greensInBox(curS, scx2 - pr, scy2 - pr, scx2 + pr, scy2 + pr, 0, layer)
				if areaFilter then
					local mine = {}
					for _, c in ipairs(nearCells) do
						if areaFilter(c) then
							mine[#mine + 1] = c
						end
					end
					nearCells = mine
				end
				if #nearCells > 0 then
					executeTour(curS, sweepOrder(groupCells(curS, nearCells, pr), scx2, scy2, pr), 0.6, 0.12)
					local curT = plots[s.Name]
					if curT and curT.Layer == layer and on() then
						local tcx, tcy = charCell(curT)
						local rest = greensInBox(curT, tcx - pr, tcy - pr, tcx + pr, tcy + pr, 0, layer)
						if #rest > 0 then
							paintCrawlCells(curT, rest, false, 0.3)
						end
					end
				end
			end
		end


		local pfCur = plots[s.Name]
		if round == 1 and pfCur and pfCur.Layer == layer and not prefetchFired then
			local ex, ey = charCell(pfCur)
			if round1Frags and #round1Frags > 0 then
				local lastFrag = round1Frags[#round1Frags]
				if type(lastFrag.stops) == "table" and #lastFrag.stops > 0 then
					local st = lastFrag.stops[#lastFrag.stops]
					ex, ey = st.x, st.y
				end
			end
			fireNextPrefetch(pfCur, radius, brushR, ex, ey)
		end

		if not on() then return end
		if n >= lastCount then
			stalls += 1
			if stalls >= Config.stallLimit then
				warn(("[Volaris] Colour %d not clearing (%d left). moving on"):format(layer, n))
				return
			end
			task.wait(0.3)
		else
			stalls = 0
		end
		lastCount = n
	end
end

advanceLayer = function(s, doneLayer)
	setPhase("advancing to next Colour")
	if not nextLayerWithRemaining(s, doneLayer) then return end
	local centroid = nextLayerCentroid(s, doneLayer)
	local entryL = nextLayerWithRemaining(s, doneLayer)
	local pf = ActorBridge and ActorBridge.prefetch
	if entryL and pf and pf.frags and pf.layer == entryL
		and pf.frags[1] and type(pf.frags[1].stops) == "table"
		and pf.frags[1].stops[1] then
		local st = pf.frags[1].stops[1]
		pcall(function()
			centroid = cellToWorld(s, st.x, st.y)
		end)
	end
	local waited = 0
	while on() and plots[s.Name] and plots[s.Name].Layer == doneLayer and waited < 2.0 do
		local _, h, root = getChar()
		if h and root and centroid then
			if Global.Toggles.Blatant then
				if ((root.Position - centroid) * Config.flatMask).Magnitude > 8 then
					root.CFrame = CFrame.new(centroid + Vector3.new(0, 2, 0))
				end
			elseif ((root.Position - centroid) * Config.flatMask).Magnitude > 2 then
				h:MoveTo(centroid)
			end
		end
		task.wait(0.2)
		waited += 0.2
	end
	s = plots[s.Name]
	if not on() or not s or s.Layer ~= doneLayer or allLayersDone(s) then return end
	local nextL = nextLayerWithRemaining(s, doneLayer)
	if nextL then
		Remotes.setActiveEvent:FireServer(nextL)
		waited = 0
		while on() and plots[s.Name] and plots[s.Name].Layer == doneLayer and waited < 2 do
			task.wait(0.2)
			waited += 0.2
		end
	end
end
end

--//// End-of-cover audit
local function auditSweep(s, gameTruth)
	if Coop.active and not Coop.amLeader() then
		return true
	end
	local F, L, W, Total = s.Filled, s.Layers, s.W, s.Total
	if gameTruth then
		local reg = Visuals.upvalueRegistry
		local gs = (type(reg) == "table") and reg[s.Name] or nil
		if not (gs and typeof(gs.Filled) == "buffer") and type(reg) == "table" then
			for _, st in pairs(reg) do
				if type(st) == "table" and st.Plot == s.Name and typeof(st.Filled) == "buffer" then
					gs = st
					break
				end
			end
		end
		if gs and typeof(gs.Filled) == "buffer" and typeof(gs.Layers) == "buffer" and gs.Total then
			F, L = gs.Filled, gs.Layers
			W = gs.Width or s.W
			Total = math.min(gs.Total, buffer.len(F), buffer.len(L))
		end
	end
	if typeof(F) ~= "buffer" or typeof(L) ~= "buffer" or not Total then
		return true
	end
	local audited = s.AuditTried or {}
	s.AuditTried = audited
	local strikes = s.AuditStrikes or {}
	s.AuditStrikes = strikes
	for aRound = 1, 3 do
		if not on() then return true end
		local byLayer = {}
		local total = 0
		local chunk = 0
		for i = 0, Total - 1 do
			if buffer.readu8(F, i) ~= 1 then
				local key = i + 1
				if not audited[key] then
					local l = buffer.readu8(L, i)
					if l > 0 and not (s.Refused and s.Refused[l] and s.Refused[l][i]) then
						byLayer[l] = byLayer[l] or {}
						byLayer[l][#byLayer[l] + 1] = { x = i % W, y = i // W, key = key }
						total += 1
					end
				end
			end
			chunk += 1
			if chunk >= 200000 then
				chunk = 0
				task.wait()
			end
		end
		if total == 0 then return true end
		setPhase(("auditing: %d unpainted studs left"):format(total))
		for l2, cells in pairs(byLayer) do
			if not on() then return true end
			local cur = plots[s.Name]
			if not cur or not cur.Active then return true end
			if cur.Layer ~= l2 then
				Remotes.setActiveEvent:FireServer(l2)
				local t0 = os.clock()
				while os.clock() - t0 < 2 do
					cur = plots[s.Name]
					if not cur or not cur.Active then return true end
					if cur.Layer == l2 then break end
					task.wait(0.1)
				end
			end
			cur = plots[s.Name]
			if cur and cur.Layer == l2 then
				if aRound == 1 then
					executeTour(cur, sweepOrder(cells, cells[1].x, cells[1].y, 4), 1.0, 0.12)
				else
					paintCrawlCells(cur, cells, gameTruth)
				end
				local lf = Global.LastFillAt and Global.LastFillAt[s.Name] or 0
				local since = os.clock() - lf
				if since < 0.5 then
					task.wait(0.5 - since)
				end
				for _, c in ipairs(cells) do
					if buffer.readu8(F, c.y * W + c.x) ~= 1 then
						strikes[c.key] = (strikes[c.key] or 0) + 1
						if strikes[c.key] >= 2 then
							audited[c.key] = true
							warn(("[Volaris] audit: cell %d,%d (colour %d) unpaintable after 2 passes"):format(c.x, c.y, l2))
						end
					end
				end
			else
				for _, c in ipairs(cells) do
					strikes[c.key] = (strikes[c.key] or 0) + 1
					if strikes[c.key] >= 6 then
						audited[c.key] = true
					end
				end
			end
		end
	end
	return true
end

--// Cover Queue

--//// Gallery
Global.Gallery = Global.Gallery or { cache = nil, fetchedAt = 0 }

local function fetchGallery(force)
	local G = Global.Gallery
	if not force and G.cache and os.clock() - G.fetchedAt < 30 then
		return G.cache
	end
	local ok, res = pcall(function()
		return Remotes.galleryRemote:InvokeServer({ Action = "List", IncludeDraft = true })
	end)
	if ok and type(res) == "table" and res.Ok == true and type(res.Entries) == "table" then
		local byKey = {}
		for _, e in ipairs(res.Entries) do
			if type(e.CoverUrl) == "string" and e.CoverUrl ~= "" then
				byKey[e.CoverUrl .. "\0" .. tostring(e.Difficulty or "")] = e
			end
		end
		G.cache, G.fetchedAt = byKey, os.clock()
		if res.Loading then
			task.delay(3, function()
				if Global.Alive then fetchGallery(true) end
			end)
		end
	end
	return G.cache or {}
end

--//// Queueing
local queueNotify, sessionSave, entryDisplay, queueSummaryLines, renderQueueEditor, renderSearchResults, refreshQueueDisplay, queueInsertItem, collectVolumes
do
queueNotify = function(title, content)
	pcall(function()
		Starlight:Notification({
			Title = title,
			Content = content,
			Icon = NebulaIcons:GetIcon("playlist_play", "Material"),
			Duration = 6,
		}, "PM_QUEUE_NOTE")
	end)
end

local function volumeInfo(entry)
	local title = tostring(entry and entry.Title or "")
	local vol = title:match("Vol%.%s*([%d%.]+)")
	if not vol then return nil end
	local base = entry.Series
	if type(base) ~= "string" or base == "" then
		base = title:match("^(.-)%s*Vol%.")
	end
	if not base or base == "" then return nil end
	return base, tonumber(vol)
end



entryDisplay = function(e, maxLen)
	local function dispWidth(s)
		local ok, total = pcall(function()
			local t = 0
			for _, code in utf8.codes(s) do
				t += 1
				if code >= 0x1100 and (code <= 0x115F or code >= 0x2E80) then
					t += 1
				end
			end
			return t
		end)
		return ok and total or #s
	end

	local function cutToWidth(s, maxCells)
		local total = 0
		local _, err = pcall(function()
			for pos, code in utf8.codes(s) do
				local w = 1 + ((code >= 0x1100 and (code <= 0x115F or code >= 0x2E80)) and 1 or 0)
				if total + w > maxCells then
					error(pos, 0)
				end
				total += w
			end
			error(#s + 1, 0)
		end)
		local cut = tonumber(err)
		return cut and s:sub(1, cut - 1) or s
	end

	maxLen = maxLen or 46
	local title = tostring(e.Title or "?")
	local ed = tostring(e.Edition or "")
	local tail, fromTitle
	if ed ~= "" and not title:find(ed, 1, true) then
		tail, fromTitle = ed, false
	else
		tail = title:match("%f[%w][Vv]ol%.?%s*[%d%.]+%s*%b()%s*$")
			or title:match("%f[%w][Vv]ol%.?%s*[%d%.]+$")
		fromTitle = tail ~= nil
	end
	if tail then
		local head = fromTitle and title:sub(1, #title - #tail) or title
		head = head:gsub("%s*[%s~·%-]+$", ""):gsub("%s+$", "")
		if head == "" then return tail end
		if dispWidth(head) + dispWidth(tail) + 3 <= maxLen then
			return head .. " · " .. tail
		end
		local keep = math.max(4, maxLen - dispWidth(tail) - 4)
		if dispWidth(head) > keep then
			head = cutToWidth(head, keep):gsub("%s+$", "")
			head = head:match("^(.-)%s+%S+$") or head
			head = head:gsub("%s+$", "") .. "…"
		end
		return head .. " · " .. tail
	end
	if dispWidth(title) > maxLen then
		return cutToWidth(title, maxLen - 1):gsub("%s+$", "") .. "…"
	end
	return title
end

queueSummaryLines = function()
	local q = Global.Values.Queue
	if #q == 0 then
		return { "(empty! queued covers load automatically when the current one finishes)" }
	end
	local lines = {}
	local i = 1
	while i <= #q do
		local base, vol = volumeInfo(q[i])
		local runEnd, runVol = i, vol
		if base and vol then
			while runEnd + 1 <= #q do
				local b2, v2 = volumeInfo(q[runEnd + 1])
				if b2 ~= base or v2 ~= runVol + 1
					or q[runEnd + 1].Difficulty ~= q[i].Difficulty then
					break
				end
				runEnd += 1
				runVol = v2
			end
		end
		if runEnd > i then
			local langTag = tostring(q[i].Title):match("%(([^)]+)%)%s*$")
			lines[#lines + 1] = ("%d-%d. %s Vols. %g-%g%s - %s"):format(
				i, runEnd, base, vol, runVol,
				langTag and (" (%s)"):format(langTag) or "",
				tostring(q[i].Difficulty))
		else
			lines[#lines + 1] = ("%d. %s - %s"):format(i,
				entryDisplay(q[i]), tostring(q[i].Difficulty))
		end
		i = runEnd + 1
	end
	return lines
end



queueInsertItem = function(item, difficulty)
	local diff = difficulty or "Normal"
	local prior = fetchGallery()[item.CoverUrl .. "\0" .. diff]
	if prior then
		if prior.InProgress then
			local pct = tonumber(prior.Percent) or 0
			queueNotify("Queue", ("You are already painting \"%s\" (%d%% done).")
				:format(item.Title, pct))
		else
			local times = tonumber(prior.Count) or 1
			queueNotify("Queue", ("\"%s\" is already in your gallery (%s).")
				:format(item.Title, times > 1 and ("painted %d times"):format(times) or "completed"))
		end
		return false
	end
	for _, e in ipairs(Global.Values.Queue) do
		if e.CoverUrl == item.CoverUrl and e.Difficulty == diff then
			queueNotify("Queue", ("\"%s\" (%s) is already queued."):format(item.Title, diff))
			return false
		end
	end
	table.insert(Global.Values.Queue, {
		Title = item.Title,
		Series = item.Series,
		Edition = item.Edition,
		CoverUrl = item.CoverUrl,
		ThumbUrl = item.ThumbUrl,
		Difficulty = diff,
	})
	refreshQueueDisplay()
	queueNotify("Queue", ("Queued \"%s\" (%s)."):format(item.Title, diff))
	return true
end

function refreshQueueDisplay()
	sessionSave()
	if not QueueParagraph then return end
	local lines = queueSummaryLines()
	pcall(function()
		QueueParagraph:Set({Content = table.concat(lines, "\n")})
	end)
	if renderQueueEditor then pcall(renderQueueEditor) end
end

local function parseVolume(query)
	local s, n = query:match("^(.-)%s*[vV][oO][lL][uU]?[mM]?[eE]?%.?%s*(%d+)$")
	if s and n and s ~= "" then
		return s, tonumber(n)
	end
	s, n = query:match("^(.-)%s+[vV]%s*(%d+)$")
	if s and n and s ~= "" then
		return s, tonumber(n)
	end
	return query, nil
end

local langNames = {
	english = "en", japanese = "ja", spanish = "es", italian = "it",
	french = "fr", german = "de", chinese = "zh", korean = "ko",
	portuguese = "pt", russian = "ru", arabic = "ar", polish = "pl",
	dutch = "nl", thai = "th", vietnamese = "vi", indonesian = "id",
	turkish = "tr", ukrainian = "uk", czech = "cs", danish = "da",
	finnish = "fi", swedish = "sv", norwegian = "no", hungarian = "hu",
	romanian = "ro", greek = "el", hebrew = "he", hindi = "hi",
	bengali = "bn", mongolian = "mn", bulgarian = "bg", croatian = "hr",
	catalan = "ca", tagalog = "tl", filipino = "tl", esperanto = "eo",
	malay = "ms", serbian = "sr", slovak = "sk", slovenian = "sl",
	lithuanian = "lt", latvian = "lv", estonian = "et", persian = "fa",
	farsi = "fa", afrikaans = "af", ptbr = "pt-br", brazilian = "pt-br",
	zhcn = "zh-cn", zhtw = "zh-tw", jp = "ja", kr = "ko",
}
local langCodes = {
	en = true, ja = true, es = true, it = true, fr = true, de = true,
	zh = true, ko = true, pt = true, ru = true, ar = true, pl = true,
	nl = true, th = true, vi = true, id = true, tr = true, uk = true,
	cs = true, da = true, fi = true, sv = true, no = true, hu = true,
	ro = true, el = true, he = true, hi = true, bn = true, mn = true,
	bg = true, hr = true, ca = true, tl = true, eo = true, ms = true,
	sr = true, sk = true, sl = true, lt = true, lv = true, et = true,
	fa = true, af = true, sq = true, hy = true, az = true, eu = true,
	be = true, ka = true, kk = true, mk = true, ne = true, sh = true,
} -- would you believe me if I said this was one of the biggest headaches I had from the 3000+ lines of code I had to write

local function normalizeLang(token)
	token = tostring(token or ""):lower():gsub("[%s_]+", "")
	if token == "" then return nil end
	return langNames[token]
		or (langCodes[token] and token)
		or langNames[(token:gsub("%-", ""))]
end

local function parseQuery(query)
	local lang, volNum = nil, nil
	for _ = 1, 4 do
		query = query:gsub("%s+$", "")
		local progress = false
		local pos, inner = query:match("()%[([^%]]+)%]%s*$")
		if pos then
			local code = normalizeLang(inner)
			if code then
				lang = code
				query = query:sub(1, pos - 1)
				progress = true
			end
		else
			local head, tail = query:match("^(.-)%s+(%a[%a%-]*)$")
			if head and head ~= "" then
				local low = tail:lower()
				local code = low ~= "vol" and low ~= "volume" and low ~= "v"
					and normalizeLang(tail) or nil
				if code then
					lang = code
					query = head
					progress = true
				end
			end
		end
		if not progress then
			local s, n = parseVolume(query)
			if n then
				volNum = n
				query = s
				progress = true
			end
		end
		if not progress then break end
	end
	return query, volNum, lang
end

collectVolumes = function(series, lang)
	local perSeries, seriesOrder = {}, {}
	local page = 1
	while page <= 10 do
		local ok, res = pcall(function()
			return Remotes.searchRemote:InvokeServer({ Query = series, Page = page })
		end)
		if not ok or type(res) ~= "table" or res.Ok ~= true
			or type(res.Results) ~= "table" or #res.Results == 0 then
			break
		end
		for _, r in ipairs(res.Results) do
			if type(r.CoverUrl) == "string" and r.CoverUrl ~= ""
				and type(r.ThumbUrl) == "string" and type(r.Title) == "string" then
				local sName = type(r.Series) == "string" and r.Series ~= "" and r.Series or nil
				local ed = tostring(r.Edition or "")
				local plainNum = ed:match("^Vol%.%s*([%d%.]+)$")
				local sfxNum, sfx = ed:match("^Vol%.%s*([%d%.]+)%s*%(([^)]+)%)$")
				local num = plainNum or sfxNum
				if sName and num then
					local data = perSeries[sName]
					if not data then
						data = { plain = {}, langs = {}, count = 0 }
						perSeries[sName] = data
						seriesOrder[#seriesOrder + 1] = sName
					end
					data.count += 1
					if plainNum and not data.plain[num] then
						data.plain[num] = r
					end
					if sfx then
						local code = sfx:lower()
						local bucket = data.langs[code]
						if not bucket then
							bucket = {}
							data.langs[code] = bucket
						end
						if not bucket[num] then
							bucket[num] = r
						end
					end
				end
			end
		end
		if res.HasNext ~= true then break end
		page += 1
	end
	local main, mainCount = nil, -1
	for _, sName in ipairs(seriesOrder) do
		local data = perSeries[sName]
		if data.count > mainCount then
			main, mainCount = sName, data.count
		end
	end
	if not main then
		return {}, 0, nil
	end
	local data = perSeries[main]
	local winner = lang
	if not lang then
		local codes = {}
		for code in pairs(data.langs) do
			codes[#codes + 1] = code
		end
		table.sort(codes)
		local best, bestN = nil, 0
		for _ in pairs(data.plain) do
			bestN += 1
		end
		for _, code in ipairs(codes) do
			local n = 0
			for _ in pairs(data.langs[code]) do
				n += 1
			end
			if n > bestN then
				best, bestN = code, n
			end
		end
		winner = best
	end
	local source = data.plain
	if lang then
		source = data.langs[lang] or {}
	elseif winner then
		source = data.langs[winner] or {}
	end
	local list = {}
	for num, r in pairs(source) do
		list[#list + 1] = { num = tonumber(num), result = r }
	end
	table.sort(list, function(a, b)
		return (a.num or 0) < (b.num or 0)
	end)
	local mainNums = {}
	for num in pairs(data.plain) do
		mainNums[num] = true
	end
	for _, bucket in pairs(data.langs) do
		for num in pairs(bucket) do
			mainNums[num] = true
		end
	end
	local allCount = 0
	for _ in pairs(mainNums) do
		allCount += 1
	end
	return list, allCount, winner
end

local function pickSearchResult(query, volNum, lang)
	local page, picked, topSeries = 1, nil, nil
	while page <= 3 do
		local ok, res = pcall(function()
			return Remotes.searchRemote:InvokeServer({ Query = query, Page = page })
		end)
		if not ok or type(res) ~= "table" or res.Ok ~= true
			or type(res.Results) ~= "table" or #res.Results == 0 then
			break
		end
		for _, r in ipairs(res.Results) do
			if type(r.CoverUrl) == "string" and type(r.ThumbUrl) == "string"
				and type(r.Title) == "string" then
				if topSeries == nil and type(r.Series) == "string" and r.Series ~= "" then
					topSeries = r.Series
				end
				local sameSeries = topSeries == nil or r.Series == topSeries
				local ed = tostring(r.Edition or "")
				if sameSeries then
					if not volNum and not lang then
						picked = r
						break
					elseif volNum and lang then
						if ed == ("Vol. %d (%s)"):format(volNum, lang) then
							picked = r
							break
						end
					elseif volNum then
						if ed == ("Vol. %d"):format(volNum) then
							picked = r
							break
						end
					else
						local tag = "(" .. lang .. ")"
						if ed:sub(-#tag) == tag then
							picked = r
							break
						end
					end
				end
			end
		end
		if not picked and volNum then
			for _, r in ipairs(res.Results) do
				if type(r.CoverUrl) == "string" and type(r.ThumbUrl) == "string"
					and type(r.Title) == "string"
					and (topSeries == nil or r.Series == topSeries)
					and tostring(r.Edition or ""):match("^Vol%.%s*" .. volNum .. "%f[%s%(]") then
					picked = r
					break
				end
			end
		end
		if picked or res.HasNext ~= true then break end
		page += 1
	end
	return picked
end

local lastAddKey, lastAddAt = "", 0

local function queueAdd(query, difficulty)
	query = tostring(query or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if query == "" then
		queueNotify("Queue", "Type a title first.")
		return false
	end
	local addKey = query .. "\0" .. tostring(difficulty or "Normal")
	if addKey == lastAddKey and os.clock() - lastAddAt < 1.5 then return false end
	lastAddKey, lastAddAt = addKey, os.clock()

	local series, volNum, lang = parseQuery(query)
	local item = pickSearchResult(series, volNum, lang)
	if not item then
		queueNotify("Queue", volNum
			and ("No results for \"%s\" (wanted Vol. %d%s). try just the series name.")
				:format(series, volNum, lang and (" in (%s)"):format(lang) or "")
			or ("No results for \"%s\"."):format(series))
		return false
	end
	return queueInsertItem(item, difficulty)
end

Global.QueueAdd = queueAdd

end

--//// Cover Preview
local CoverPreview = {}
do
	local previewCache, previewCount = {}, 0
	local previewOrder = {}

	local function fetchCoverContent(url)
		local cached = previewCache[url]
		if cached then return cached.content end
		local rf = Net:FindFirstChild("RF/CoverBytes")
		if not rf then return nil, "no remote" end
		local okI, res = pcall(function()
			return rf:InvokeServer(url)
		end)
		if not okI or type(res) ~= "table" or res.Ok ~= true or typeof(res.Bytes) ~= "string" then
			return nil, (type(res) == "table" and tostring(res.Error)) or "invoke failed"
		end
		local okD, dec = pcall(function()
			return require(ReplicatedStorage.Shared.Libraries.Decoder).Decode(res.Bytes)
		end)
		if not okD or type(dec) ~= "table" or not dec.X or not dec.Y or typeof(dec.Pixels) ~= "table" then
			return nil, "decode failed"
		end
		local okE, editable = pcall(function()
			return game:GetService("AssetService"):CreateEditableImage({ Size = Vector2.new(dec.X, dec.Y) })
		end)
		if not okE or not editable then return nil, "image budget exhausted" end
		local okW = pcall(function()
			local buf = buffer.create(dec.X * dec.Y * 4)
			local R, G, B = dec.Pixels[1], dec.Pixels[2] or dec.Pixels[1], dec.Pixels[3] or dec.Pixels[1]
			for i = 1, dec.X * dec.Y do
				local o = (i - 1) * 4
				buffer.writeu8(buf, o, math.clamp(math.round(R[i]), 0, 255))
				buffer.writeu8(buf, o + 1, math.clamp(math.round(G[i]), 0, 255))
				buffer.writeu8(buf, o + 2, math.clamp(math.round(B[i]), 0, 255))
				buffer.writeu8(buf, o + 3, 255)
			end
			editable:WritePixelsBuffer(Vector2.zero, Vector2.new(dec.X, dec.Y), buf)
		end)
		if not okW then return nil, "pixel write failed" end
		local okC, content = pcall(function()
			return Content.fromObject(editable)
		end)
		if not okC then return nil, "content failed" end
		previewOrder[#previewOrder + 1] = url
		previewCache[url] = { content = content, editable = editable }
		previewCount += 1
		while previewCount > 12 and #previewOrder > 0 do
			local oldest = table.remove(previewOrder, 1)
			local entry = previewCache[oldest]
			if entry then
				pcall(function() entry.editable:Destroy() end)
				previewCache[oldest] = nil
				previewCount -= 1
			end
		end
		return content
	end

	local gui, frame, shadowHolder, imageLabel, titleLabel, statusLabel

	local function ensureGui()
		if gui and gui.Parent then
			return gui
		end
		local host = (typeof(gethui) == "function" and gethui())
			or game:GetService("CoreGui")
		pcall(function()
			for _, old in ipairs(host:GetChildren()) do
				if old.Name == "VolarisCoverPreview" then
					old:Destroy()
				end
			end
		end)

		local theme = nil
		pcall(function() theme = Starlight.CurrentTheme end)
		local bgDark = theme and theme.Backgrounds and theme.Backgrounds.Dark or Color3.fromRGB(23, 25, 29)
		local bgMedium = theme and theme.Backgrounds and theme.Backgrounds.Medium or Color3.fromRGB(27, 29, 33)
		local bgGroupbox = theme and theme.Backgrounds and theme.Backgrounds.Groupbox or Color3.fromRGB(33, 36, 42)
		local fgMedium = theme and theme.Foregrounds and theme.Foregrounds.Medium or Color3.fromRGB(165, 165, 165)
		local fgDark = theme and theme.Foregrounds and theme.Foregrounds.Dark or Color3.fromRGB(120, 122, 130)
		local shadow3 = theme and theme.Miscellaneous and theme.Miscellaneous.LighterShadow or Color3.fromRGB(15, 16, 19)
		local accentGrad = theme and theme.Accents and theme.Accents.Main or nil

		gui = Instance.new("ScreenGui")
		gui.Name = "VolarisCoverPreview"
		gui.ResetOnSpawn = false
		gui.DisplayOrder = 1000000001
		local parented = pcall(function()
			gui.Parent = host
		end)
		if not parented or not gui.Parent then
			gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		end

		shadowHolder = Instance.new("Frame")
		shadowHolder.Name = "DropShadowHolder"
		shadowHolder.BackgroundTransparency = 1
		shadowHolder.Size = UDim2.fromOffset(300, 390)
		shadowHolder.Position = UDim2.new(1, -330, 0.5, -195)
		shadowHolder.Parent = gui
		for _, layer in ipairs({
			{ name = "antumbraShadow", image = "rbxassetid://5587865193", slice = Rect.new(80, 78, 189, 318),
				sizeX = 1.054, sizeY = 1.34, trans = 0.94 },
			{ name = "penumbraShadow", image = "rbxassetid://8992230677", slice = Rect.new(99, 99, 99, 99),
				sizeX = 1.175, sizeY = 1.27, trans = 0.55 },
			{ name = "umbraShadow", image = "rbxassetid://76200300325831", slice = Rect.new(46, 43, 351, 355),
				sizeX = 1.027, sizeY = 1.043, trans = 0.1 },
		}) do
			local shadow = Instance.new("ImageLabel")
			shadow.Name = layer.name
			shadow.ZIndex = 0
			shadow.BackgroundTransparency = 1
			shadow.Image = layer.image
			shadow.ImageColor3 = shadow3
			shadow.ImageTransparency = layer.trans
			shadow.ScaleType = Enum.ScaleType.Slice
			shadow.SliceCenter = layer.slice
			shadow.AnchorPoint = Vector2.new(0.5, 0.5)
			shadow.Position = UDim2.fromScale(0.5, 0.5)
			shadow.Size = UDim2.new(layer.sizeX, 0, layer.sizeY, 0)
			shadow.Parent = shadowHolder
		end

		frame = Instance.new("Frame")
		frame.Name = "Window"
		frame.Size = UDim2.fromScale(1, 1)
		frame.Position = UDim2.fromScale(0, 0)
		frame.BackgroundColor3 = bgMedium
		frame.BorderSizePixel = 0
		frame.Active = true
		frame.Parent = shadowHolder
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = frame
		local stroke = Instance.new("UIStroke")
		stroke.Name = "UIStroke"
		stroke.Color = shadow3
		stroke.Parent = frame

		local accentBar = Instance.new("Frame")
		accentBar.Name = "AccentBar"
		accentBar.ZIndex = 2
		accentBar.Size = UDim2.new(1, -24, 0, 2)
		accentBar.Position = UDim2.fromOffset(12, 30)
		accentBar.BackgroundColor3 = Color3.fromRGB(161, 169, 225)
		accentBar.BorderSizePixel = 0
		accentBar.Parent = frame
		local abCorner = Instance.new("UICorner")
		abCorner.CornerRadius = UDim.new(1, 0)
		abCorner.Parent = accentBar
		if accentGrad then
			local abg = Instance.new("UIGradient")
			abg.Color = accentGrad
			abg.Parent = accentBar
		end

		local titleBar = Instance.new("Frame")
		titleBar.Name = "TitleBar"
		titleBar.Size = UDim2.new(1, 0, 0, 30)
		titleBar.BackgroundTransparency = 1
		titleBar.Active = true
		titleBar.Parent = frame

		titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "Title"
		titleLabel.BackgroundTransparency = 1
		titleLabel.Position = UDim2.fromOffset(14, 0)
		titleLabel.Size = UDim2.new(1, -58, 1, 0)
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Font = Enum.Font.GothamMedium
		titleLabel.TextSize = 14
		titleLabel.TextColor3 = theme and theme.Foregrounds and theme.Foregrounds.Active or Color3.fromRGB(255, 255, 255)
		titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
		titleLabel.Text = "Cover preview"
		titleLabel.Parent = titleBar

		local closeIcon = nil
		pcall(function()
			if typeof(NebulaIcons) == "table" and type(NebulaIcons.GetIcon) == "function" then
				closeIcon = NebulaIcons:GetIcon("close", "Material")
			end
		end)
		local closeBtn
		if type(closeIcon) == "number" or type(closeIcon) == "string" then
			closeBtn = Instance.new("ImageButton")
			closeBtn.Image = "rbxassetid://" .. closeIcon
			closeBtn.ImageColor3 = fgMedium
		else
			closeBtn = Instance.new("TextButton")
			closeBtn.Text = "X"
			closeBtn.Font = Enum.Font.GothamBold
			closeBtn.TextSize = 13
			closeBtn.TextColor3 = fgMedium
		end
		closeBtn.Name = "Close"
		closeBtn.Size = UDim2.fromOffset(26, 26)
		closeBtn.Position = UDim2.new(1, -36, 0, 2)
		closeBtn.BackgroundColor3 = bgGroupbox
		closeBtn.BackgroundTransparency = 0.35
		closeBtn.AutoButtonColor = true
		closeBtn.BorderSizePixel = 0
		closeBtn.Parent = titleBar
		local cc = Instance.new("UICorner")
		cc.CornerRadius = UDim.new(0, 6)
		cc.Parent = closeBtn
		closeBtn.MouseButton1Click:Connect(function()
			gui.Enabled = false
		end)

		imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Cover"
		imageLabel.Position = UDim2.fromOffset(14, 44)
		imageLabel.Size = UDim2.new(1, -28, 1, -74)
		imageLabel.BackgroundColor3 = bgDark
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.Parent = frame
		local ic = Instance.new("UICorner")
		ic.CornerRadius = UDim.new(0, 6)
		ic.Parent = imageLabel
		local iStroke = Instance.new("UIStroke")
		iStroke.Color = shadow3
		iStroke.Parent = imageLabel

		statusLabel = Instance.new("TextLabel")
		statusLabel.Name = "Status"
		statusLabel.BackgroundTransparency = 1
		statusLabel.Position = UDim2.new(0, 14, 1, -26)
		statusLabel.Size = UDim2.new(1, -28, 0, 18)
		statusLabel.Font = Enum.Font.Gotham
		statusLabel.TextSize = 12
		statusLabel.TextColor3 = fgDark
		statusLabel.TextXAlignment = Enum.TextXAlignment.Left
		statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
		statusLabel.Text = ""
		statusLabel.Parent = frame

		local dragStart, guiStart
		titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragStart = input.Position
				guiStart = shadowHolder.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragStart = nil
					end
				end)
			end
		end)
		game:GetService("UserInputService").InputChanged:Connect(function(input)
			if dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				shadowHolder.Position = UDim2.new(
					guiStart.X.Scale, guiStart.X.Offset + delta.X,
					guiStart.Y.Scale, guiStart.Y.Offset + delta.Y)
			end
		end)
		return gui
	end

	function CoverPreview.show(entry)
		local url = tostring(entry and entry.ThumbUrl or "")
		if url == "" then
			queueNotify("Preview", "No thumbnail URL for this cover.")
			return
		end
		local g = ensureGui()
		g.Enabled = true
		titleLabel.Text = entryDisplay(entry, 40)
		statusLabel.Text = "loading cover..."
		task.spawn(function()
			local content, err = fetchCoverContent(url)
			if content then
				pcall(function()
					imageLabel.ImageContent = content
				end)
				statusLabel.Text = ""
			else
				statusLabel.Text = "couldn't load cover (" .. tostring(err or "?") .. ")"
			end
		end)
	end
end
Global.CoverPreview = CoverPreview

--//// Session Persistence
local function copyTree(src, dst)
	for _, path in ipairs(listfiles(src)) do
		path = path:gsub("[/\\]+$", "")
		local name = string.match(path, "[^/\\]+$")
		if name and name ~= "" then
			if isfolder(path) then
				if not isfolder(dst .. "/" .. name) then
					pcall(makefolder, dst .. "/" .. name)
				end
				copyTree(path, dst .. "/" .. name)
			elseif isfile(path) and not isfile(dst .. "/" .. name) then
				local okr, data = pcall(readfile, path)
				if okr then
					pcall(writefile, dst .. "/" .. name, data)
				end
			end
		end
	end
end

local Session = { fsOk = nil }

--//// Per-Account Storage
local accountDir, filesystemWorks, sessionRestore
do
local accountSettings = { perAccountConfigs = false, defaultConfig = "", accounts = {} }
accountDir = "VolarisHub"
do
	local myId = tostring(Players.LocalPlayer.UserId)
	local raw = nil
	pcall(function()
		if isfile("VolarisHub/settings.json") then
			raw = game:GetService("HttpService"):JSONDecode(readfile("VolarisHub/settings.json"))
		end
	end)
	if type(raw) == "table" then
		accountSettings.perAccountConfigs = raw.perAccountConfigs == true
		accountSettings.defaultConfig = tostring(raw.defaultConfig or "")
		if type(raw.accounts) == "table" then
			accountSettings.accounts = raw.accounts
		end
	end

	if accountSettings.perAccountConfigs
		and type(isfolder) == "function" and type(listfiles) == "function"
		and type(isfile) == "function" then
		accountDir = "VolarisHub/accounts/" .. myId
		local fresh = not isfolder(accountDir)
		if fresh then
			pcall(function()
				if not isfolder("VolarisHub/accounts") then
					makefolder("VolarisHub/accounts")
				end
				makefolder(accountDir)
			end)
			pcall(function()
				if isfolder("VolarisHub/Paint a Manga") then
					copyTree("VolarisHub/Paint a Manga", accountDir .. "/Paint a Manga")
				end
				if isfolder("VolarisHub/themes") then
					copyTree("VolarisHub/themes", accountDir .. "/themes")
				end
				for _, f in ipairs({ "session.json", "webhook.json" }) do
					if isfile("VolarisHub/" .. f) and not isfile(accountDir .. "/" .. f) then
						local okr, data = pcall(readfile, "VolarisHub/" .. f)
						if okr then
							pcall(writefile, accountDir .. "/" .. f, data)
						end
					end
				end
			end)
		end
		local bound = accountSettings.accounts[myId] or accountSettings.defaultConfig
		if bound and bound ~= "" then
			pcall(function()
				local cfgDir = accountDir .. "/Paint a Manga/configs"
				if not isfolder(cfgDir) then
					makefolder(cfgDir)
				end
				writefile(cfgDir .. "/autoload.txt", bound)
			end)
		end
	end
end
Global.AccountDir = accountDir
Global.AccountSettings = accountSettings

function Global.AccountSettingsWrite()
	if type(writefile) ~= "function" then return end
	pcall(function()
		if not isfolder("VolarisHub") then
			makefolder("VolarisHub")
		end
		writefile("VolarisHub/settings.json",
			game:GetService("HttpService"):JSONEncode(Global.AccountSettings))
	end)
end

local sessionDir = accountDir
local sessionFile = sessionDir .. "/session.json"

filesystemWorks = function()
	if Session.fsOk ~= nil then return Session.fsOk end
	Session.fsOk = false
	if type(makefolder) == "function" and type(writefile) == "function"
		and type(readfile) == "function" then
		pcall(function()
			if type(isfolder) ~= "function" or not isfolder(sessionDir) then
				makefolder(sessionDir)
			end
		end)
		pcall(function()
			local probe = sessionDir .. "/.probe"
			writefile(probe, "vol_ok")
			if readfile(probe) == "vol_ok" then
				Session.fsOk = true
			end
			if type(delfile) == "function" then
				pcall(delfile, probe)
			end
		end)
	end
	Global.SessionFiles = Session.fsOk
	return Session.fsOk
end

function sessionSave()
	if not filesystemWorks() then return end
	local ok = pcall(function()
		writefile(sessionFile, game:GetService("HttpService"):JSONEncode({
			time = os.time(),
			resume = Global.Toggles.AutoPaint == true,
			queue = Global.Values.Queue,
		}))
	end)
	if not ok then
		Session.fsOk = false
	end
end

sessionRestore = function()
	if not filesystemWorks() then return end
	local ok, raw = pcall(readfile, sessionFile)
	if not ok or type(raw) ~= "string" then return end
	local decoded
	pcall(function()
		decoded = game:GetService("HttpService"):JSONDecode(raw)
	end)
	if type(decoded) ~= "table" or type(decoded.time) ~= "number" then
		return
	end
	local recent = os.time() - decoded.time <= 600
	if type(decoded.queue) == "table" then
		local gallery = fetchGallery()
		for _, entry in ipairs(decoded.queue) do
			if type(entry) == "table" and type(entry.CoverUrl) == "string" then
				local prior = gallery[entry.CoverUrl .. "\0" .. tostring(entry.Difficulty or "Normal")]
				if not prior then
					table.insert(Global.Values.Queue, entry)
				end
			end
		end
	end
	if recent and decoded.resume == true then
		Global.Start()
	end
	pcall(refreshQueueDisplay)
	return
end
end

--//// Auto Load
local fmtDuration
do
local queueLoadLock = 0

local loadSkips = nil
loadNextFromQueue = function(explicit)
	if os.clock() < queueLoadLock then return end
	if Coop.active and not Coop.amLeader() then
		if explicit then
			queueNotify("Queue", "Coop: only the party owner's queue can load covers right now.")
		end
		return
	end
	queueLoadLock = os.clock() + 6
	local q = Global.Values.Queue
	if #q == 0 then
		if loadSkips and #loadSkips > 0 then
			queueNotify("Queue", ("Skipped %d already-painted cover(s). nothing left to load."):format(#loadSkips))
			loadSkips = nil
		end
		return
	end
	local entry = table.remove(q, 1)
	local prior = fetchGallery()[entry.CoverUrl .. "\0" .. tostring(entry.Difficulty or "Normal")]
	if prior then
		if explicit then
			queueNotify("Queue", prior.InProgress and "Skipping (still being painted)." or "Skipping (already in your gallery).")
		else
			loadSkips = loadSkips or {}
			loadSkips[#loadSkips + 1] = entry.Title
		end
		refreshQueueDisplay()
		queueLoadLock = 0
		return loadNextFromQueue(explicit)
	end
	refreshQueueDisplay()
	loadSkips = nil
	setPhase(("loading next cover: %s"):format(entry.Title))
	Global.LoadedCover = { title = entry.Title, difficulty = entry.Difficulty }
	local requestedAt = os.clock()
	local ok, res = pcall(function()
		return Remotes.loadRemote:InvokeServer({
			CoverUrl = entry.CoverUrl,
			ThumbUrl = entry.ThumbUrl,
			Title = entry.Title,
			Difficulty = entry.Difficulty,
		})
	end)
	if not ok then
		warn("[Volaris] queue: load failed: " .. tostring(res))
		queueNotify("Queue", ("Failed to load \"%s\" - skipped."):format(entry.Title))
	elseif type(res) == "table" and res.Ok == false then
		warn("[Volaris] queue: load refused: " .. tostring(res.Error))
		queueNotify("Queue", ("Server refused \"%s\" (%s) - skipped.")
			:format(entry.Title, tostring(res.Error)))
	end
	task.delay(8, function()
		if not Global.Alive or not Global.Toggles.AutoPaint then return end
		if Stats.lastBuiltAt and Stats.lastBuiltAt > requestedAt then return end
		if activePlot() then return end
		if #Global.Values.Queue == 0 then return end
		queueNotify("Queue", "Previous cover didn't load. trying the next.")
		loadNextFromQueue()
		return
	end)
end

--// Features
fmtDuration = function(sec)
	sec = math.max(0, math.floor(sec))
	if sec < 60 then return sec .. "s" end
	if sec < 3600 then return ("%dm %02ds"):format(sec // 60, sec % 60) end
	return ("%dh %02dm"):format(sec // 3600, (sec % 3600) // 60)
end
end

--//// Discord Webhook
local Features, runExclusive
do
do
local hookCurrent
local hookSessionStart = os.date("%Y-%m-%d %H:%M:%S")
local HOOK_COLORS = {
	active = 3447003,
	completed = 3066993,
	stopped = 15158332,
	paused = 15938324,
	ended = 9807270,
}
local HOOK_LINES = {
	active = "▶️ | %d%% painted",
	paused = "⏸ | %d%% (paused)",
	stopped = "❌ | %d%% (stopped)",
	completed = "✅ | %d%% (completed)",
	ended = "⏹ | %d%% (session ended)",
}

local function hookStatus(text)
	if Labels.Hook then
		pcall(function()
			Labels.Hook:Set({ Name = "Status: " .. text })
		end)
	end
end

local function hookEnabled()
	return Global.Toggles.Webhook == true and (Global.Webhook.url or "") ~= ""
end

local function hookPct()
	local total = Stats.total or 0
	if total <= 0 then return 0 end
	return math.floor((Stats.filled or 0) / total * 100 + 0.5)
end

local function hookHttp(opts)
	if typeof(request) == "function" then
		local ok, res = pcall(request, opts)
		if ok and typeof(res) == "table" then
			return true, res.Body or res.body or "", res.StatusCode or res.status_code or res.Status
		end
		return false, tostring(res), nil
	end
	if typeof(http_request) == "function" then
		local ok, res = pcall(http_request, opts)
		if ok and typeof(res) == "table" then
			return true, res.Body or res.body or "", res.StatusCode or res.status_code or res.Status
		end
		return false, tostring(res), nil
	end
	if type(syn) == "table" and typeof(syn.request) == "function" then
		local ok, res = pcall(syn.request, opts)
		if ok and typeof(res) == "table" then
			return true, res.Body or res.body or "", res.StatusCode or res.status_code or res.Status
		end
		return false, tostring(res), nil
	end
	local ok, res = pcall(function()
		return game:GetService("HttpService"):RequestAsync(opts)
	end)
	if ok and typeof(res) == "table" then
		return res.Success == true, res.Body, res.StatusCode
	end
	return false, tostring(res), nil
end

local function hookUrl()
	local url = (Global.Webhook.url or ""):gsub("/+$", "")
	if url ~= "" and url:sub(1, 8) ~= "https://" then
		return ""
	end
	return url
end

local function hookIdentity()
	local map = workspace:FindFirstChild("Map")
	local folder = map and map:FindFirstChild("Plots")
	local holder = Stats.plot and folder and folder:FindFirstChild(Stats.plot)
	if not holder then return nil end
	local thumb = holder:GetAttribute("CoverThumb")
	local known = Global.LoadedCover
	local difficulty = (known and known.difficulty)
		or holder:GetAttribute("Difficulty") or "Normal"
	local knownTitle = known and known.title or nil
	if knownTitle ~= nil and knownTitle ~= "" then
		if not thumb or thumb == "" then return nil end
		local uuid = thumb:match("covers/([^/]+)/")
		return {
			title = knownTitle,
			difficulty = difficulty,
			thumb = thumb:gsub("%.256%.", ".512."),
			url = uuid and ("https://mangadex.org/title/" .. uuid) or nil,
		}
	end
	local title
	for _, d in ipairs(holder:GetDescendants()) do
		if d:IsA("TextLabel") then
			local t = d.Text
			if t:match("^Current Album:") then
				t = t:match("^Current Album:%s*(.+)$") or ""
			end
			if t ~= "" and not t:match("^Fly %(") and not t:match("^Total Painted") then
				if not title or #t > #title then
					title = t
				end
			end
		end
	end
	if not title or not thumb or thumb == "" then return nil end
	local uuid = thumb:match("covers/([^/]+)/")
	return {
		title = title,
		difficulty = difficulty,
		thumb = thumb:gsub("%.256%.", ".512."),
		url = uuid and ("https://mangadex.org/title/" .. uuid) or nil,
	}
end

local function hookQueueText()
	local lines = queueSummaryLines()
	local out, size = {}, 0
	for i, line in ipairs(lines) do
		if size + #line + 1 > 980 and #out > 0 then
			out[#out + 1] = ("...and %d more"):format(#lines - i + 1)
			break
		end
		out[#out + 1] = line
		size += #line + 1
	end
	return table.concat(out, "\n")
end

local HOOK_DEFAULT_TEMPLATE = [==[{"title":"{COVER_NAME}  |  {DIFFICULTY}","url":"{MANGADEX_URL}","color":{COLOR},"fields":[{"name":"🚀 | Progress","value":"{STATE}\n🔳 | {STUDS_PROGRESS} studs / {STUDS_REMAINING} studs\n🎨 | Colour {COLOUR_PROGRESS}","inline":true},{"name":"📊 | Stats","value":"⏳ | ETA: {OVERALL_COVER_ETA}\n⏳ | Colour ETA: {INCOLOR_ETA}\n🏃‍♂️ | Speed: {STUDS_PER_MINUTE}\n**⏱️ | Cover Time: {COVER_TIME}**\n\n📃 | Covers Finished: {COVERS_FINISHED}\n⌚ | Session: {SESSION_TIME}","inline":true},{"name":"🔌 | Server","value":"👥 | Players: {PLAYERS_ON_SERVER_COUNT}\n🔘 | Blatant mode: {BLATANT_MODE}\n🤝 | Coop: {PARTNERS}","inline":true},{"name":"📋 | Queue","value":"{QUEUE}"}],"image":{"url":"{COVER_IMAGE_URL}"},"footer":{"text":"{PLAYER} · session started: {SESSION_STARTED}"},"timestamp":{TIMESTAMP}}]==]
local RAW_HOOK_TOKENS = { TIMESTAMP = true, COLOR = true }

local function hookJsonEscape(v)
	local s = tostring(v)
	s = s:gsub("\\", "\\\\")
	s = s:gsub('"', '\\"')
	s = s:gsub("\n", "\\n")
	s = s:gsub("\r", "\\r")
	s = s:gsub("\t", "\\t")
	return s
end

local function hookTokens(state, stopReason)
	local id = hookIdentity()
	local cur = hookCurrent
	if not id and cur then
		id = { title = cur.title, difficulty = cur.difficulty, thumb = cur.thumb, url = cur.url }
	end
	local filled = Stats.filled or 0
	local total = Stats.total or 0
	local pct = hookPct()
	local speed = "--"
	if (Stats.ratePerMin or 0) > 0 then
		speed = ("%.0f studs/min"):format(Stats.ratePerMin)
	end
	local partners = Coop.partnerNames and Coop.partnerNames() or {}
	return {
		COVER_NAME = id and id.title or "Unknown cover",
		DIFFICULTY = id and id.difficulty or "?",
		MANGADEX_URL = id and id.url or "",
		COVER_IMAGE_URL = id and id.thumb or "",
		PLAYER = ("%s (@%s)"):format(Players.LocalPlayer.DisplayName, Players.LocalPlayer.Name),
		PARTNERS = #partners > 0 and table.concat(partners, ", ") or "solo",
		PROGRESS = tostring(pct),
		STATE = (HOOK_LINES[state] or HOOK_LINES.active):format(pct),
		STUDS_PROGRESS = tostring(filled),
		STUDS_REMAINING = tostring(math.max(0, total - filled)),
		COLOUR_PROGRESS = ("%d / %d (%d done)"):format(Stats.layer or 0, Stats.layerCount or 0, Stats.colorsDone or 0),
		OVERALL_COVER_ETA = Stats.coverEta and fmtDuration(Stats.coverEta) or "--",
		INCOLOR_ETA = Stats.layerEta and fmtDuration(Stats.layerEta) or "--",
		STUDS_PER_MINUTE = speed,
		COVER_TIME = (state == "completed" and tonumber(Stats.officialCoverTime))
			and fmtDuration(Stats.officialCoverTime) or nil,
		SESSION_TIME = fmtDuration(Stats.activeSeconds or 0),
		COVERS_FINISHED = tostring(Stats.coversDone or 0),
		PLANNER = tostring(ActorBridge and ActorBridge.lastStrategy or "portfolio"),
		QUEUE = hookQueueText(),
		PLAYERS_ON_SERVER_COUNT = tostring(#Players:GetPlayers()),
		BLATANT_MODE = Global.Toggles.Blatant and "🟢 ON" or "🔴 OFF",
		SESSION_STARTED = hookSessionStart,
		ERROR = state == "stopped" and tostring(stopReason or "") or "",
		TIMESTAMP = ('"%s"'):format(os.date("!%Y-%m-%dT%H:%M:%SZ")),
		COLOR = tostring(HOOK_COLORS[state] or HOOK_COLORS.active),
	}
end

local function hookFill(template, tokens)
	local out = template:gsub("{([%w_]+)}", function(tok)
		if tokens[tok] == nil then
			return "{" .. tok .. "}"
		end
		if RAW_HOOK_TOKENS[tok] then
			return tokens[tok]
		end
		return hookJsonEscape(tokens[tok])
	end)
	out = out:gsub("%c?%*%*[^%c]*{COVER_TIME}[^%c]*%*%*", "")
	local ok, decoded = pcall(function()
		return game:GetService("HttpService"):JSONDecode(out)
	end)
	if not ok or type(decoded) ~= "table" or type(decoded.fields) ~= "table" or #decoded.fields == 0 then
		return nil
	end
	if decoded.image and decoded.image.url == "" then
		decoded.image = nil
	end
	if decoded.url == "" then
		decoded.url = nil
	end
	return decoded
end

local function hookEmbed(state, stopReason)
	local template = Global.Webhook.template
	if type(template) ~= "string" or template == "" then
		template = HOOK_DEFAULT_TEMPLATE
	end
	local embed = hookFill(template, hookTokens(state, stopReason))
	if embed then
		if state == "stopped" and stopReason and not template:find("{ERROR}") then
			embed.fields[#embed.fields + 1] = {
				name = "⚠️ | Error",
				value = ("```%s```"):format(tostring(stopReason):sub(1, 300)),
			}
		end
		return embed
	end
	if template ~= HOOK_DEFAULT_TEMPLATE then
		hookStatus("invalid template, using default")
		embed = hookFill(HOOK_DEFAULT_TEMPLATE, hookTokens(state, stopReason))
		if embed then
			return embed
		end
	end
	return {
		title = "Volaris",
		color = HOOK_COLORS[state] or HOOK_COLORS.active,
		fields = { { name = "🚀 | State", value = tostring(state) } },
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	}
end

local function hookPayload(embed)
	return game:GetService("HttpService"):JSONEncode({ embeds = { embed } })
end

local function hookPost(embed)
	local url = hookUrl()
	if url == "" then return nil end
	local ok, body, code = hookHttp({
		Url = url .. "?wait=true",
		Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = hookPayload(embed),
	})
	if ok and type(body) == "string" and body ~= "" then
		local okJson, decoded = pcall(function()
			return game:GetService("HttpService"):JSONDecode(body)
		end)
		if okJson and type(decoded) == "table" and decoded.id then
			return decoded.id
		end
	end
	hookStatus(("send failed (%s) %s"):format(tostring(code), os.date("%H:%M:%S")))
	return nil
end

local function hookPatchOnce(messageId, embed)
	local url = hookUrl()
	local ok, _, code = hookHttp({
		Url = url .. "/messages/" .. messageId,
		Method = "PATCH",
		Headers = { ["Content-Type"] = "application/json" },
		Body = hookPayload(embed),
	})
	return ok and (code == nil or code == 200 or code == 204), code
end

local function hookPatch(messageId, embed)
	local url = hookUrl()
	if url == "" or not messageId then return false end
	local ok, code = hookPatchOnce(messageId, embed)
	if ok then return true end
	if code == 429 then
		task.wait(2.5)
		ok = hookPatchOnce(messageId, embed)
		if ok then return true end
	end
	hookStatus(("edit failed (%s) %s"):format(tostring(code), os.date("%H:%M:%S")))
	return false
end

local hookFile = accountDir .. "/webhook.json"
local hookSaved
local hookRecordLoaded = false

local function hookSaveRecord()
	if not filesystemWorks() then return end
	pcall(function()
		writefile(hookFile, game:GetService("HttpService"):JSONEncode({
			time = os.time(),
			url = Global.Webhook.url,
			message = hookCurrent and {
				id = hookCurrent.id,
				title = hookCurrent.title,
				difficulty = hookCurrent.difficulty,
				state = hookCurrent.state,
				startedAt = (Stats.coverStartClock and Stats.coverStartClock > 1e9)
					and Stats.coverStartClock or nil,
			} or nil,
		}))
	end)
end

local function hookGetRecord()
	if not hookRecordLoaded then
		hookRecordLoaded = true
		if filesystemWorks() then
			local ok, raw = pcall(readfile, hookFile)
			if ok and type(raw) == "string" then
				local okDec, decoded = pcall(function()
					return game:GetService("HttpService"):JSONDecode(raw)
				end)
				if okDec and type(decoded) == "table" and type(decoded.message) == "table"
					and type(decoded.message.id) == "string"
					and decoded.url == Global.Webhook.url then
					hookSaved = decoded.message
				end
			end
		end
	end
	return hookSaved
end

Webhook.alert = function(player, role, joinedNow, wasBlatant)
	if not hookEnabled() then return end
	task.spawn(function()
		local avatar = nil
		local okAv, res = hookHttp({
			Url = ("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=150x150&format=Png&isCircular=false"):format(player.UserId),
			Method = "GET",
			Headers = { ["Content-Type"] = "application/json" },
		})
		if okAv and type(res) == "string" and res ~= "" then
			local okJson, data = pcall(function()
				return game:GetService("HttpService"):JSONDecode(res)
			end)
			if okJson and type(data) == "table" and type(data.data) == "table"
				and data.data[1] and type(data.data[1].imageUrl) == "string" then
				avatar = data.data[1].imageUrl
			end
		end
		local display = tostring(player.DisplayName or player.Name)
		local embed = {
			title = "Staff detected",
			color = 15158332,
			thumbnail = avatar and { url = avatar } or nil,
			fields = {
				{
					name = "👤 | Player",
					value = ("**%s**%s\nID: %d\nRole: %s"):format(
						tostring(player.Name),
						display ~= tostring(player.Name) and (" (%s)"):format(display) or "",
						player.UserId,
						tostring(role)),
					inline = true,
				},
				{
					name = "⏱ | Timing",
					value = ("Detected: %s\nJoined server: %s"):format(
						os.date("%H:%M:%S"),
						joinedNow and "just now" or "was already here"),
					inline = true,
				},
				{
					name = "🔘 | Blatant mode",
					value = wasBlatant and "🟢 was ON (disabled automatically)" or "🔴 was off",
				},
				{
					name = "🔌 | Server",
					value = ("Job ID: `%s`\n👥 | Players: %d"):format(
						game.JobId ~= "" and game.JobId or "unknown",
						#Players:GetPlayers()),
				},
			},
			footer = { text = "session started: " .. hookSessionStart },
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
		}
		hookPost(embed)
	end)
end

function Webhook.onBuilt()
	if not hookEnabled() then return end
	if Coop.active and not Coop.amLeader() then
		hookStatus("coop active - embed owned by party host")
		return
	end
	local id = hookIdentity()
	if not id then return end
	local cur = hookCurrent
	if cur and cur.state == "active" and cur.title == id.title and cur.difficulty == id.difficulty then
		return
	end
	local saved = hookGetRecord()
	if not cur and saved and saved.title == id.title and saved.difficulty == id.difficulty then
		hookCurrent = {
			id = saved.id,
			title = saved.title,
			difficulty = saved.difficulty,
			thumb = id.thumb,
			url = id.url,
			state = "active",
			lastEditAt = os.clock(),
			lastMilestone = hookPct() // 10 * 10,
		}
		if type(saved.startedAt) == "number" and saved.startedAt > 1e9 then
			Stats.coverStartClock = saved.startedAt
		end
		hookSaved = nil
		hookStatus("reconnected to previous message " .. os.date("%H:%M:%S"))
		return
	end
	local messageId = hookPost(hookEmbed("active"))
	if messageId then
		hookCurrent = {
			id = messageId,
			title = id.title,
			difficulty = id.difficulty,
			thumb = id.thumb,
			url = id.url,
			state = "active",
			lastEditAt = os.clock(),
			lastMilestone = hookPct() // 10 * 10,
		}
		hookSaveRecord()
		hookStatus("cover message sent " .. os.date("%H:%M:%S"))
	end
end

function Webhook.onCompleted()
	local cur = hookCurrent
	if not cur or cur.state ~= "active" or not hookEnabled() then return end
	if hookPatch(cur.id, hookEmbed("completed")) then
		cur.state = "completed"
		cur.lastEditAt = os.clock()
		cur.lastMilestone = 100
		hookSaveRecord()
		hookStatus("cover completed " .. os.date("%H:%M:%S"))
	end
end

function Webhook.onStopped(reason)
	local cur = hookCurrent
	if not cur or cur.state ~= "active" or not hookEnabled() then return end
	if hookPatch(cur.id, hookEmbed("stopped", tostring(reason or "unknown error"))) then
		cur.state = "stopped"
		hookSaveRecord()
	end
end

function Webhook.onPaused()
	local cur = hookCurrent
	if not cur or cur.state ~= "active" or not hookEnabled() then return end
	if hookPatch(cur.id, hookEmbed("paused")) then
		cur.state = "paused"
		hookSaveRecord()
	end
end

function Webhook.sessionEnd()
	local cur = hookCurrent
	if not cur or (cur.state ~= "active" and cur.state ~= "paused") then return end
	if (Global.Webhook.url or "") == "" then return end
	local embed = hookEmbed("ended")
	local messageId = cur.id
	cur.state = "ended"
	hookSaveRecord()
	task.spawn(function()
		if hookPatch(messageId, embed) then
			hookStatus("session ended " .. os.date("%H:%M:%S"))
		end
	end)
end

function Webhook.loop()
	while Global.Alive do
		task.wait(5)
		if not hookEnabled() then continue end
		local cur = hookCurrent
		if not cur then
			if Global.Toggles.AutoPaint and hookIdentity() then
				Webhook.onBuilt()
			end
			continue
		end
		if cur.state ~= "active" or not Global.Toggles.AutoPaint then continue end
		local now = os.clock()
		local pct = hookPct()
		if now - cur.lastEditAt >= 60 or pct >= cur.lastMilestone + 10 then
			if hookPatch(cur.id, hookEmbed("active")) then
				cur.lastEditAt = now
				cur.lastMilestone = math.floor(pct / 10) * 10
				hookStatus("edited " .. os.date("%H:%M:%S"))
			end
		end
	end
end

Webhook.status = hookStatus
Webhook.post = hookPost
Webhook.embed = hookEmbed
Webhook.Template = HOOK_DEFAULT_TEMPLATE

end

Features = {}

runExclusive = function(name, body)
	return function()
		Global.Gens = Global.Gens or {}
		Global.Gens[name] = (Global.Gens[name] or 0) + 1
		local gen = Global.Gens[name]
		if Global.Running[name] then
			local t0 = os.clock()
			while Global.Running[name] and os.clock() - t0 < 5 do
				task.wait(0.1)
			end
			if Global.Running[name] then return end
		end
		Global.Running[name] = true
		local ok, err = pcall(body, gen)
		Global.Running[name] = false
		if not ok then error(err) end
	end
end
end

--//// Auto Paint
Features.AutoPaint = function()
	Global.Gens = Global.Gens or {}
	Global.Gens.AutoPaint = (Global.Gens.AutoPaint or 0) + 1
	local gen = Global.Gens.AutoPaint
	Global.PaintGen = gen
	if Global.Running.AutoPaint then
		local t0 = os.clock()
		while Global.Running.AutoPaint and os.clock() - t0 < 5 do
			task.wait(0.1)
		end
	end
	Global.Running.AutoPaint = true

	local ok, err = pcall(function()
		pcall(function() Remotes.requestRemote:InvokeServer() end)

		Stats.baselineFilled = Stats.filled or 0
		Stats.activeSeconds = 0
		applyWalkSpeed()
		setPhase("starting")

		while on() do
			local s = activePlot()
			if not s then
				setPhase("waiting for cover")
				if #Global.Values.Queue > 0 then
					loadNextFromQueue()
				end
				task.wait(1)
				continue
			end
			if not s.part then
				s.part = plotPartOf(s.Name)
				if not s.part then
					task.wait(1)
					continue
				end
			end

			if not s.Layer or s.Layer == 0 then
				local firstL = nextLayerWithRemaining(s, 0)
				if firstL then
					Remotes.setActiveEvent:FireServer(firstL)
				end
				task.wait(1)
				continue
			end

			if allLayersDone(s) then
				if auditSweep(s) then
					local confirmed = Global.LastCompletedAt
						and Global.CoverBuiltAt
						and Global.LastCompletedAt > Global.CoverBuiltAt
					if not confirmed then
						auditSweep(s, true)
						confirmed = Global.LastCompletedAt
							and Global.CoverBuiltAt
							and Global.LastCompletedAt > Global.CoverBuiltAt
					end
					if confirmed then
						Global.CoverUnconfirmedSince = nil
						setPhase("cover finished! load another one")
					elseif not Global.CoverUnconfirmedSince then
						Global.CoverUnconfirmedSince = os.clock()
						setPhase("cover looks done. waiting for the server to confirm")
					elseif os.clock() - Global.CoverUnconfirmedSince > 90 then
						Global.CoverUnconfirmedSince = nil
						warn("[Volaris] cover complete but the server never confirmed. loading the next cover anyway")
						setPhase("cover finished (unconfirmed)")
						if #Global.Values.Queue > 0 then
							loadNextFromQueue()
						end
					end
				end
				task.wait(2)
				continue
			end

			local rateT0, rateF0 = os.clock(), Stats.filled or 0
			paintLayer(s)
			local dtR = os.clock() - rateT0
			if dtR >= 5 and (Stats.filled or 0) > rateF0 then
				local r = (Stats.filled - rateF0) / dtR
				Global.MyPaintRate = Global.MyPaintRate and (Global.MyPaintRate * 0.6 + r * 0.4) or r
			end

			local cur = plots[s.Name]
			local gaveUp = cur ~= nil and cur.GaveUp == cur.Layer
			local abandoned = cur ~= nil and cur.Abandoned ~= nil and cur.Abandoned[cur.Layer] == true
			if on() and cur and cur.Layer == s.Layer
				and (layerRemainingOf(cur, cur.Layer) or 0) > 0
				and not gaveUp and not abandoned then
				task.wait(0.8)
			end
			if on() and cur and not allLayersDone(cur)
				and (layerRemainingOf(cur, cur.Layer) == 0
					or gaveUp or abandoned) then
				cur.GaveUp = nil
				advanceLayer(cur, cur.Layer)
			end

			task.wait(0.2)
		end
	end)

	local _, hum, root = getChar()
	if hum and root then pcall(function() hum:MoveTo(root.Position) end) end
	pcall(function() if hum then hum.WalkSpeed = 16 end end)
	setPhase(Global.Alive and "paused" or "stopped")

	if ok and Global.Alive and not Global.Toggles.AutoPaint then
		task.spawn(Webhook.onPaused)
	end

	if not ok then
		warn("[Volaris] engine error: " .. tostring(err))
		task.spawn(Webhook.onStopped, tostring(err))
		pcall(function()
			Starlight:Notification({
				Title = "Volaris Hub",
				Content = "Engine error (see console). Auto Paint was stopped.",
				Icon = NebulaIcons:GetIcon("circle-alert", "Lucide"),
				Duration = 8,
			}, "PM_ENGINE_ERROR")
		end)
		Global.Toggles.AutoPaint = false
	end
	if Global.PaintGen == gen then
		Global.Running.AutoPaint = false
	end
end

--//// Statistics
Features.StatLoop = function()
	if Global.Running.StatLoop then return end
	Global.Running.StatLoop = true

	local samples = {}
	local statText = {}
	local lastTick = os.clock()

	while Global.Alive do
		local now = os.clock()
		local s = activePlot()
		if s then refreshStatsFrom(s) end

		if Global.Toggles.AutoPaint then
			applyWalkSpeed()
			if s and s.part then
				Stats.activeSeconds += now - lastTick
				samples[#samples + 1] = {t = now, f = Stats.filled}
				if #samples > 240 then
					table.remove(samples, 1)
				end
			end
		elseif #samples > 0 then
			table.clear(samples)
		end
		lastTick = now

		local ratePerMin = 0
		local a, b = samples[1], samples[#samples]
		if a and b and b.t - a.t > 8 then
			ratePerMin = (b.f - a.f) / (b.t - a.t) * 60
		elseif Stats.activeSeconds > 2 then
			ratePerMin = math.max(0, Stats.filled - Stats.baselineFilled)
				/ Stats.activeSeconds * 60
		end

		local coverLeft = math.max(0, Stats.total - Stats.filled)
		local layerEta = (ratePerMin > 1 and Stats.layerLeft > 0)
			and (Stats.layerLeft / ratePerMin * 60) or nil
		local coverEta = (ratePerMin > 1 and coverLeft > 0)
			and (coverLeft / ratePerMin * 60) or nil
		local pct = (Stats.total > 0) and (Stats.filled / Stats.total * 100) or 0
		Stats.ratePerMin = ratePerMin
		Stats.layerEta = layerEta
		Stats.coverEta = coverEta

		pcall(function()
			local shown = {
				Phase = "Status: " .. tostring(Stats.phase),
				Color = ("Colour: %d / %d  (%d done)")
					:format(Stats.layer, Stats.layerCount, Stats.colorsDone),
				Left = ("In Colour: %d studs | Cover left: %d")
					:format(Stats.layerLeft, coverLeft),
				Overall = ("Overall: %.1f%%  (%d / %d studs)")
					:format(pct, Stats.filled, Stats.total),
				Speed = "Speed: " .. (ratePerMin > 0 and (("%.0f studs/min"):format(ratePerMin)) or "--"),
				Eta = ("ETA: Colour %s | cover %s")
					:format(layerEta and fmtDuration(layerEta) or "--",
						coverEta and fmtDuration(coverEta) or "--"),
				Session = ("Session: %s active | Covers finished: %d")
					:format(fmtDuration(Stats.activeSeconds), Stats.coversDone),
				Last = "Last cover: " .. (Stats.lastCover or "--"),
			}
			if Coop.active then
				local names = Coop.partnerNames and Coop.partnerNames() or {}
				shown.Coop = "Coop: " .. table.concat(names, ", ")
					.. (Coop.amLeader() and " · embed owner" or " · host owns embed")
			else
				shown.Coop = "Coop: off (no party)"
			end

			for key, txt in pairs(shown) do
				if statText[key] ~= txt and Labels[key] then
					statText[key] = txt
					Labels[key]:Set({Name = txt})
				end
			end
		end)
		task.wait(0.25)
	end
	Global.Running.StatLoop = false
end

--//// General Speed
Features.GeneralSpeed = runExclusive("GeneralSpeed", function(gen)

	while Global.Alive and Global.Toggles.GeneralSpeed and Global.Gens.GeneralSpeed == gen do
		if not Global.Toggles.AutoPaint then
			local _, hum = getChar()
			if hum then
				hum.WalkSpeed = math.clamp(Global.Values.GeneralWalkSpeed or 16, 16, 150)
			end
		end
		task.wait(0.25)
	end

	local _, hum = getChar()
	if hum and not Global.Toggles.AutoPaint then
		hum.WalkSpeed = 16
	end
end)

--//// Anti AFK
Features.AntiAFK = function()
	Global.Gens = Global.Gens or {}
	Global.Gens.AntiAFK = (Global.Gens.AntiAFK or 0) + 1
	local gen = Global.Gens.AntiAFK
	if Global.Running.AntiAFK then
		local t0 = os.clock()
		while Global.Running.AntiAFK and os.clock() - t0 < 5 do
			task.wait(0.1)
		end
		if Global.Running.AntiAFK then return end
	end
	Global.Running.AntiAFK = true
	local disabled = 0
	if typeof(getconnections) == "function" then
		local okConns, conns = pcall(getconnections, LP.Idled)
		if okConns and type(conns) == "table" and #conns > 0 then
			for _, conn in ipairs(conns) do
				pcall(function()
					if conn.Disable then
						conn:Disable()
					elseif conn.Disconnect then
						conn:Disconnect()
					end
				end)
				disabled += 1
			end
		end
	end
	if disabled == 0 then
		Global.Connections.AntiAFK = LP.Idled:Connect(function()
			if not Global.Toggles.AntiAFK then return end
			local VirtualUser = game:GetService("VirtualUser")
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end

	task.spawn(function()
		while Global.Alive and Global.Toggles.AntiAFK and Global.Gens.AntiAFK == gen do
			task.wait(0.5)
		end
		Global.Running.AntiAFK = false
	end)
end

--//// Staff Hop
local hopAway
do
local staffGroup = 33388672
local staffRoleNames = {
	["content creator"] = true,
	["moderator"] = true,
	["administrator"] = true,
	["management"] = true,
	["modeller"] = true,
	["shareholder"] = true,
	["holder"] = true,
}
local staffRoles = {}
local hopBusy = false

local function roleInStaffGroup(player)
	local cached = staffRoles[player.UserId]
	if cached ~= nil then return cached end
	local ok, role = pcall(function()
		return player:GetRoleInGroup(staffGroup)
	end)
	if not ok or type(role) ~= "string" then return nil end
	staffRoles[player.UserId] = role
	return role
end

local function pickServerJob()
	local ok, res = pcall(function()
		return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(Config.placeId))
	end)
	if not ok or type(res) ~= "string" then
		warn("[Volaris] server hop: server list request failed: " .. tostring(res))
		return nil
	end
	local okDecode, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(res)
	end)
	if not okDecode or type(data) ~= "table" or type(data.data) ~= "table" then
		warn("[Volaris] server hop: could not decode the server list")
		return nil
	end
	local jobs = {}
	for _, server in ipairs(data.data) do
		if type(server.id) == "string" and server.id ~= game.JobId
			and type(server.playing) == "number" and type(server.maxPlayers) == "number"
			and server.playing < server.maxPlayers then
			jobs[#jobs + 1] = { id = server.id, playing = server.playing }
		end
	end
	if #jobs == 0 then
		warn("[Volaris] server hop: no other public server with space")
		return nil
	end
	table.sort(jobs, function(a, b)
		return a.playing < b.playing
	end)
	return jobs[math.random(1, math.min(10, #jobs))].id
end

hopAway = function(reason)
	if hopBusy then return end
	hopBusy = true
	setPhase("server hop: " .. reason)
	pcall(function()
		Starlight:Notification({
			Title = "Staff detected",
			Content = reason .. ". hopping to another server.",
			Icon = NebulaIcons:GetIcon("circle-alert", "Lucide"),
			Duration = 8,
		}, "PM_HOP_NOTE")
	end)
	local jobId = pickServerJob()
	if jobId then
		Global.Toggles.AutoPaint = false
		sessionSave()
		local queueTp = queue_on_teleport or queueonteleport
		if typeof(queueTp) == "function" then
			pcall(queueTp, "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/flyrbo/Volaris/refs/heads/main/Loader.luau\"))()")
		end
		local okTeleport, err = pcall(function()
			game:GetService("TeleportService"):TeleportToPlaceInstance(Config.placeId, jobId, LP)
		end)
		if not okTeleport then
			warn("[Volaris] server hop: teleport failed: " .. tostring(err))
			setPhase("hop failed! teleport error")
		end
	else
		setPhase("hop failed. no server picked")
	end
	hopBusy = false
end

local function disableBlatantAuto()
	if not Global.Toggles.Blatant then return end
	if BlatantToggle and BlatantToggle.Values then
		Global.BlatantAutoRequest = true
		pcall(function()
			BlatantToggle:Set({ CurrentValue = false })
		end)
		Global.BlatantAutoRequest = nil
	else
		Global.Toggles.Blatant = false
		Global.BlatantGen = (Global.BlatantGen or 0) + 1
	end
end

Features.StaffWatch = function()
	if Global.Running.StaffWatch then return end
	Global.Running.StaffWatch = true

	local function check(player, joinedNow)
		if player == LP then return end
		task.spawn(function()
			local role = roleInStaffGroup(player)
			if not role or not staffRoleNames[role:lower()] then return end
			local wasBlatant = Global.Toggles.Blatant == true
			if wasBlatant then
				disableBlatantAuto()
			end
			task.spawn(Webhook.alert, player, role, joinedNow, wasBlatant)
			if Global.Toggles.StaffHop then
				hopAway(("%s - %s"):format(player.Name, role))
			elseif joinedNow then
				setPhase(("staff joined: %s"):format(player.Name))
			else
				setPhase(("staff in server: %s"):format(player.Name))
			end
		end)
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if Global.Toggles.StaffHop then
			check(player, false)
		end
	end
	Global.Connections.StaffWatch = Players.PlayerAdded:Connect(function(player)
		check(player, true)
	end)
end

Features.StaffHop = function()
	if Global.Running.StaffHop then return end
	Global.Running.StaffHop = true
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LP and Global.Toggles.StaffHop then
			task.spawn(function()
				local role = roleInStaffGroup(player)
				if Global.Toggles.StaffHop and role and staffRoleNames[role:lower()] then
					hopAway(("%s - %s"):format(player.Name, role))
				end
			end)
		end
	end
	Global.Running.StaffHop = false
end

Features.Smart = function()
	if Global.Running.Smart then return end
	Global.Running.Smart = true
	while Global.Toggles.Smart and Global.Alive do
		local alone = #Players:GetPlayers() <= 1
		if (alone and not Global.Toggles.Blatant)
			or (not alone and Global.Toggles.Blatant) then
			Global.BlatantAutoRequest = true
			pcall(function()
				BlatantToggle:Set({ CurrentValue = alone })
			end)
			Global.BlatantAutoRequest = nil
		end
		task.wait(2)
	end
	Global.Running.Smart = false
end
end

--//// Canvas Render Throttle
Features.CanvasFix = function()
	if Global.Connections.CanvasFix then return end
	local okCR, CanvasRender = pcall(require,
		ReplicatedStorage:WaitForChild("Client"):WaitForChild("Systems"):WaitForChild("CanvasRender"))
	if not okCR or type(CanvasRender) ~= "table"
		or type(CanvasRender.Flush) ~= "function" or type(CanvasRender.Sweep) ~= "function" then
		warn("[Volaris] canvas lag fix unavailable (renderer module not found)")
		return
	end
	local flushOrig: any = CanvasRender.Flush
	local sweepOrig: any = CanvasRender.Sweep
	local hook = {
		module = CanvasRender,
		flush = flushOrig,
		sweep = sweepOrig,
		lastFlush = 0,
		lastSweep = 0,
	}
	CanvasRender.Flush = function(self, ...)
		local now = os.clock()
		if now - hook.lastFlush >= 0.1 then
			hook.lastFlush = now
			return flushOrig(self, ...)
		end
		return nil
	end
	CanvasRender.Sweep = function(self, ...)
		local now = os.clock()
		if now - hook.lastSweep >= 0.25 then
			hook.lastSweep = now
			return sweepOrig(self, ...)
		end
		return nil
	end
	local setActive = CanvasRender.SetActive
	if type(setActive) == "function" then
		CanvasRender.SetActive = function(self, plotName, layer, second)
			if Visuals.upvalueRegistry == nil then
				Visuals.tryUpvalueRegistry()
			end
			local reg = Visuals.upvalueRegistry
			local st = nil
			if type(reg) == "table" then
				st = reg[plotName]
				if not (type(st) == "table" and typeof(st.Pixels) == "buffer") then
					for _, v in pairs(reg) do
						if type(v) == "table" and v.Plot == plotName and typeof(v.Pixels) == "buffer" then
							st = v
							break
						end
					end
				end
			end
			if not (type(st) == "table" and type(st.Total) == "number" and type(CanvasRender.WriteCell) == "function") then
				return setActive(self, plotName, layer, second)
			end
			second = second or 0
			if st.ActiveLayer == layer and st.SecondLayer == second then
				return
			end
			st.ActiveLayer = layer
			st.SecondLayer = second
			local chunk = 0
			for i = 1, st.Total do
				CanvasRender.WriteCell(CanvasRender, st, i)
				chunk += 1
				if chunk >= 65536 then
					chunk = 0
					task.wait()
				end
			end
			st.Dirty = true
		end
	end
	Global.Connections.CanvasFix = hook
	return
end

--//// Visuals Engine
local RunService = game:GetService("RunService")
local AssetService = game:GetService("AssetService")

local upvalueGetter = (typeof(getupvalue) == "function" and getupvalue)
	or (typeof(getupvalues) == "function" and function(f, i)
		return getupvalues(f)[i]
	end)
	or (type(debug) == "table" and type(debug.getupvalue) == "function" and debug.getupvalue)
	or nil

local pillarCap = 250
local rainbowSpeed = 0.35
local okVisPaint, VisPaint = pcall(require,
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configs"):WaitForChild("Paint"))
local pillarHeight = (okVisPaint and type(VisPaint.HintMarkerStuds) == "number") and VisPaint.HintMarkerStuds or 7
Global.Values.PillarColor = Global.Values.PillarColor
	or (okVisPaint and VisPaint.PaintMeColor)
	or Color3.fromRGB(60, 220, 90)
Global.Values.PillarThreshold = Global.Values.PillarThreshold or { frac = 0.01 }
Global.Values.ArrowThreshold = Global.Values.ArrowThreshold or { frac = 0.01 }
Global.Values.TracerThreshold = Global.Values.TracerThreshold or { frac = 0.01 }

function Visuals.ensureModule()
	if Visuals.renderModule then
		return Visuals.renderModule
	end
	local ok, mod = pcall(require,
		ReplicatedStorage:WaitForChild("Client"):WaitForChild("Systems"):WaitForChild("CanvasRender"))
	if ok and type(mod) == "table" then
		Visuals.renderModule = mod
		return mod
	end
	return nil
end

function Visuals.tryUpvalueRegistry()
	local CR = Visuals.ensureModule()
	if not (CR and type(CR.SetColors) == "function" and upvalueGetter) then
		Visuals.upvalueRegistry = false
		return
	end
	for i = 1, 16 do
		local ok, v = pcall(upvalueGetter, CR.SetColors, i)
		if not ok or v == nil then break end
		if type(v) == "table" then
			local valid = next(v) == nil
			for _, st in pairs(v) do
				if type(st) == "table" and typeof(st.Pixels) == "buffer" then
					valid = true
					break
				end
			end
			if valid then
				Visuals.upvalueRegistry = v
				return
			end
		end
	end
	Visuals.upvalueRegistry = false
end

function Visuals.attach()
	if Visuals.upvalueRegistry == nil then
		Visuals.tryUpvalueRegistry()
	end
	if Visuals.upvalueRegistry then
		return
	end
	if Visuals.writeHook then return end
	local CR = Visuals.renderModule
	if not CR then
		local ok, mod = pcall(require,
			ReplicatedStorage:WaitForChild("Client"):WaitForChild("Systems"):WaitForChild("CanvasRender"))
		if not ok or type(mod) ~= "table" or type(mod.WriteCell) ~= "function" then
			warn("[Volaris] visuals unavailable (renderer module not found)")
			return
		end
		Visuals.renderModule = mod
		CR = mod
	end
	Visuals.writeHook = CR.WriteCell
	CR.WriteCell = function(self, state, idx)
		if type(state) == "table" and type(state.Plot) == "string" then
			Visuals.plots[state.Plot] = state
		end
		return Visuals.writeHook(self, state, idx)
	end
end

function Visuals.detach()
	if Visuals.writeHook and Visuals.renderModule then
		Visuals.renderModule.WriteCell = Visuals.writeHook
	end
	Visuals.writeHook = nil
end

--//// Actor Workers
local actorSource = plannerChunk .. [==[
local chanId = ...
local chan = type(get_comm_channel) == "function" and get_comm_channel(chanId)
if not chan then return end
chan:Fire({
	cmd = "helloResult",
	env = {
		channel = true,
		bufferLib = typeof(buffer) == "table",
	},
})
chan.Event:Connect(function(job)
	if type(job) ~= "table" then return end
	if job.cmd == "ping" then
		chan:Fire({ cmd = "pong", seq = job.seq })
		return
	end
	if job.cmd == "scan" then
		local out = { cmd = "scanResult", seq = job.seq, plot = job.plot }
		local okL, layers = pcall(buffer.fromstring, job.layers)
		local okF, filled = pcall(buffer.fromstring, job.filled)
		if okL and okF and type(job.w) == "number" and type(job.h) == "number" then
			local rowC, colC = {}, {}
			local count, layerTotal = 0, 0
			for i = 0, (job.w * job.h) - 1 do
				if buffer.readu8(layers, i) == job.layer then
					layerTotal += 1
					if buffer.readu8(filled, i) ~= 1 then
						count += 1
						local x = i % job.w
						local z = i // job.w
						rowC[z + 1] = (rowC[z + 1] or 0) + 1
						colC[x + 1] = (colC[x + 1] or 0) + 1
					end
				end
			end
			out.count = count
			out.layerTotal = layerTotal
			out.rowC = rowC
			out.colC = colC
		else
			out.error = "scan buffers missing"
		end
		chan:Fire(out)
		return
	end
	if job.cmd == "plan" then
		local out = { cmd = "planResult", seq = job.seq }
		if type(job.cells) == "table" and type(job.w) == "number" and type(job.h) == "number"
			and type(job.cfg) == "table" then
			local ay = function()
				if typeof(task) == "table" and type(task.wait) == "function" then
					pcall(task.wait)
				else
					pcall(wait)
				end
			end
			local deadline = os.clock() + math.min(math.clamp(tonumber(job.budget) or 10, 4, 150), 2.5)
			local variants = {
				{ "boxes", planBoxes, nil },
				{ "boxes-B24", planBoxes, function(c) c.boxCells = 24 end },
				{ "boxes-B96", planBoxes, function(c) c.boxCells = 96 end },
				{ "boxes-B160", planBoxes, function(c) c.boxCells = 160 end },
				{ "boxes-2opt4", planBoxes, function(c) c.twoOptPasses = 4 end },
				{ "strokes", planStrokes, nil },
				{ "strokes-dense", planStrokes, function(c) c.bandDense = (c.bandDense or 0.5) * 0.6 end },
				{ "fromCells", planFromCells, nil },
			}
			local best, bestScore, bestName = nil, nil, nil
			for _, v in ipairs(variants) do
				if best and os.clock() > deadline then break end
				local cfg2 = {}
				for k, val in pairs(job.cfg) do cfg2[k] = val end
				if v[3] then v[3](cfg2) end
				local okF, frags = pcall(v[2], job.cells, job.w, job.h, cfg2, ay)
				if okF and type(frags) == "table" and #frags > 0 then
					local sc = scoreFrags(frags, job.cfg.pixel or (1 / 3), job.cfg.speed or 16, job.cfg.bandTurn or 0.5)
					if not bestScore or sc < bestScore then
						best, bestScore, bestName = frags, sc, v[1]
					end
				end
			end
			if best and #best > 0 then
				local order = {}
				for fi, f in ipairs(best) do
					if f.kind == "box" or f.kind == "tour" then
						order[#order + 1] = { fi = fi, n = #f.stops }
					end
				end
				table.sort(order, function(a, b) return a.n > b.n end)
				for _, o in ipairs(order) do
					if os.clock() > deadline - 0.4 then break end
					local stops = best[o.fi].stops
					polish2Opt(stops, stops[1].x, stops[1].y, math.min(deadline - 0.2, os.clock() + 1.5))
				end
			end
			if best then
				out.fragments = best
				out.strategy = bestName
			else
				out.error = "all plan strategies failed"
			end
		else
			out.error = ("plan payload invalid: cells=%s w=%s h=%s cfg=%s"):format(
				type(job.cells), type(job.w), type(job.h), type(job.cfg))
		end
		chan:Fire(out)
	end
end)
]==]


ActorBridge = {
	ok = nil, chan = nil, actor = nil,
	seq = 0, pendingSeq = nil, pendingAt = 0, lastRequest = 0,
}

local function actorAvailable()
	if ActorBridge.ok ~= nil then return ActorBridge.ok end
	ActorBridge.ok = false
	local function fail(reason)
		ActorBridge.failReason = reason
		Global.ActorWorkers = false
		Global.ActorFail = reason
		return false
	end
	if type(run_on_actor) ~= "function" or type(create_comm_channel) ~= "function"
		or type(get_comm_channel) ~= "function" then
		return fail("missing functions")
	end
	local actor = nil
	if type(getactors) == "function" then
		local ok, list = pcall(getactors)
		if ok and type(list) == "table" and #list > 0 then
			local idx = (tonumber(getgenv().VolarisActorIdx) or 0) + 1
			getgenv().VolarisActorIdx = idx
			actor = list[((idx - 1) % #list) + 1]
		end
	end
	if not actor then
		local okA, created = pcall(function()
			local a = Instance.new("Actor")
			a.Name = "VolarisWorker"
			a.Parent = game:GetService("CoreGui")
			return a
		end)
		if not okA then return fail("no actor available") end
		actor = created
	end
	local okChan, chanId, chan = pcall(create_comm_channel)
	if not okChan or type(chanId) ~= "number" or typeof(chan) ~= "Instance" then
		return fail("comm channel creation failed")
	end
	local done = false
	local conn = chan.Event:Connect(function(msg)
		if type(msg) == "table" and msg.cmd == "helloResult" and type(msg.env) == "table" then
			done = true
			ActorBridge.env = msg.env
		end
	end)
	if not pcall(run_on_actor, actor, actorSource, chanId) then
		conn:Disconnect()
		return fail("run_on_actor errored")
	end
	local t0 = os.clock()
	while not done and os.clock() - t0 < 5 do
		task.wait(0.1)
	end
	conn:Disconnect()
	if not done then
		return fail("no hello from actor")
	end
	local env = ActorBridge.env
	if not (env.channel and env.bufferLib) then
		return fail(("actor env incomplete (channel=%s buffer=%s)")
			:format(tostring(env.channel), tostring(env.bufferLib)))
	end
	ActorBridge.actor = actor
	ActorBridge.chanId = chanId
	ActorBridge.chan = chan
	ActorBridge.chanConn = chan.Event:Connect(function(msg)
		if type(msg) ~= "table" then return end
		if msg.cmd == "scanResult" and msg.seq == ActorBridge.pendingSeq then
			ActorBridge.pendingSeq = nil
			if msg.rowC and msg.plot == Visuals.greenPlot and msg.layer == Visuals.greenLayer then
				Visuals.applyActorCounts(msg.rowC, msg.colC, msg.count or 0, msg.layerTotal or 0)
			end
		elseif msg.cmd == "planResult" and msg.seq == ActorBridge.planPendingSeq then
			ActorBridge.planPendingSeq = nil
			ActorBridge.lastStrategy = msg.strategy
			if type(msg.fragments) == "table" then
				local valid = {}
				for _, f in ipairs(msg.fragments) do
					if type(f) == "table" and type(f.stops) == "table" and #f.stops > 0
						and type(f.stops[1]) == "table" and type(f.bbox) == "table" and #f.bbox == 4 then
						valid[#valid + 1] = f
					end
				end
				ActorBridge.planResult = (#valid > 0) and valid or nil
				if #valid == 0 then
					ActorBridge.planError = ("all %s returned fragments invalid"):format(tostring(#msg.fragments))
				end
			elseif not msg.error then
				ActorBridge.planError = "response had no fragments"
			end
			if msg.error then
				ActorBridge.planError = msg.error
			end
		elseif msg.cmd == "planResult" and ActorBridge.prefetch and msg.seq == ActorBridge.prefetch.seq
			and ActorBridge.prefetch.frags == nil then
			ActorBridge.lastStrategy = msg.strategy
			if type(msg.fragments) == "table" then
				local valid = {}
				for _, f in ipairs(msg.fragments) do
					if type(f) == "table" and type(f.stops) == "table" and #f.stops > 0
						and type(f.stops[1]) == "table" and type(f.bbox) == "table" and #f.bbox == 4 then
						valid[#valid + 1] = f
					end
				end
				ActorBridge.prefetch = (#valid > 0)
					and { seq = ActorBridge.prefetch.seq, frags = valid,
						plot = ActorBridge.prefetch.plot, layer = ActorBridge.prefetch.layer }
					or nil
			else
				ActorBridge.prefetch = nil
			end
		end
	end)
	ActorBridge.ok = true
	Global.ActorWorkers = true
	Global.ActorFail = nil
	return true
end

requestActorScan = function(state)
	if not actorAvailable() then return false end
	local now = os.clock()
	if ActorBridge.pendingSeq and now - ActorBridge.pendingAt < 5 then
		return true
	end
	if now - ActorBridge.lastRequest < 0.75 then
		return true
	end
	if typeof(state.Layers) ~= "buffer" or typeof(state.Filled) ~= "buffer"
		or not state.W or not state.H then
		return false
	end
	ActorBridge.lastRequest = now
	ActorBridge.seq += 1
	ActorBridge.pendingSeq = ActorBridge.seq
	ActorBridge.pendingAt = now
	pcall(function()
		ActorBridge.chan:Fire({
			cmd = "scan",
			seq = ActorBridge.seq,
			plot = state.Name,
			layers = buffer.tostring(state.Layers),
			filled = buffer.tostring(state.Filled),
			w = state.W,
			h = state.H,
			layer = state.Layer,
		})
	end)
	return true
end

requestActorPlan = function(cur, radius, brushR, scx, scy, mode, windowOverride, cellsOverride, budget)
	if not actorAvailable() then return nil end
	local now = os.clock()
	if ActorBridge.planBroken and now - ActorBridge.planBrokenAt < 10 then
		return nil
	end
	if ActorBridge.planPendingSeq then
		local deadline = ActorBridge.planPendingAt + 5
		while ActorBridge.planPendingSeq and os.clock() < deadline do
			task.wait(0.05)
		end
		return ActorBridge.planResult
	end
	local cells = cellsOverride or collectGreenCells()
	if #cells == 0 then return nil end
	ActorBridge.planError = nil
	ActorBridge.seq += 1
	ActorBridge.planPendingSeq = ActorBridge.seq
	ActorBridge.planPendingAt = now
	ActorBridge.planResult = nil
	local cfgP = planConfig(radius, brushR, scx, scy, true)
	if nextLayerWithRemaining(cur, cur.Layer) then
		local c = nextLayerCentroid(cur, cur.Layer)
		if c then
			cfgP.exitCx, cfgP.exitCy = worldToCell(cur, c)
		end
	end
	pcall(function()
		ActorBridge.chan:Fire({
			cmd = "plan",
			seq = ActorBridge.seq,
			mode = mode,
			w = cur.W,
			h = cur.H,
			cells = cells,
			cfg = cfgP,
			budget = budget or 8,
		})
	end)
	local t0 = os.clock()
	local window = windowOverride or (0.4 + #cells / 30000)
	while ActorBridge.planPendingSeq and os.clock() - t0 < window do
		task.wait(0.05)
	end
	if ActorBridge.planPendingSeq then
		ActorBridge.planPendingSeq = nil
		ActorBridge.planBroken = true
		ActorBridge.planBrokenAt = os.clock()

	end
	return ActorBridge.planResult
end

ActorBridge.firePrefetch = function(cur, radius, brushR, scx, scy, targetLayer, cellList, budget)
	if not actorAvailable() then return false end
	if ActorBridge.prefetch and not ActorBridge.prefetch.frags then return false end
	if ActorBridge.planPendingSeq then return false end
	if ActorBridge.planBroken and os.clock() - ActorBridge.planBrokenAt < 10 then return false end
	if type(cur) ~= "table" or typeof(cur.Layers) ~= "buffer" then return false end
	brushR = brushR or brushRadiusCells()
	radius = radius or brushR * 0.85
	if not scx then
		scx, scy = charCell(cur)
	end
	local cells = cellList
	if not cells then
		cells = collectGreenCells()
	end
	if #cells == 0 then return false end
	ActorBridge.seq += 1
	ActorBridge.prefetch = {
		seq = ActorBridge.seq,
		plot = cur.Name,
		layer = targetLayer or cur.Layer,
	}
	local cfgP = planConfig(radius, brushR, scx, scy, true)
	local baseLayer = targetLayer or cur.Layer
	if nextLayerWithRemaining(cur, baseLayer) then
		local c = nextLayerCentroid(cur, baseLayer)
		if c then
			cfgP.exitCx, cfgP.exitCy = worldToCell(cur, c)
		end
	end
	pcall(function()
		ActorBridge.chan:Fire({
			cmd = "plan",
			seq = ActorBridge.seq,
			mode = "boxes",
			w = cur.W,
			h = cur.H,
			cells = cells,
			cfg = cfgP,
			budget = budget or 10,
		})
	end)
	return true
end

function Visuals.activeState()
	if Visuals.upvalueRegistry == nil then
		Visuals.tryUpvalueRegistry()
	elseif Visuals.upvalueRegistry == false and next(Visuals.plots) == nil then
		local now = os.clock()
		if now - (Visuals.upvalRetryAt or 0) > 5 then
			Visuals.upvalRetryAt = now
			Visuals.tryUpvalueRegistry()
		end
	end
	local reg = Visuals.upvalueRegistry
	if reg then
		local found = nil
		for _, s in pairs(reg) do
			if s.Active == true then
				found = s
				break
			end
		end
		if not found then
			for _, s in pairs(reg) do
				found = s
				break
			end
		end
		if found then
			return found
		end
	end
	local best = nil
	for _, s in pairs(Visuals.plots) do
		if s.Active == true then
			best = s
			break
		end
	end
	if not best then
		for _, s in pairs(Visuals.plots) do
			best = s
			break
		end
	end
	return best
end

local function ensureCapture()
	local state = Visuals.activeState()
	if not state and os.clock() - Visuals.captureAt > 5 then
		Visuals.captureAt = os.clock()
		task.spawn(function()
			pcall(function() Remotes.requestRemote:InvokeServer() end)
		end)
	end
	return state
end

local function hueRGB(offset)
	local c = Color3.fromHSV((os.clock() * rainbowSpeed + offset) % 1, 1, 1)
	return math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)
end

local function visualColor()
	if Global.Toggles.RainbowPillars then
		local r, g, b = hueRGB(0)
		return Color3.fromRGB(r, g, b)
	end
	return Global.Values.PillarColor or Color3.fromRGB(60, 220, 90)
end

local function parseThreshold(text)
	text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if text == "" then return nil end
	local pct = text:match("^(%d+%.?%d*)%%%s*$")
	if pct then
		return { frac = math.clamp((tonumber(pct) or 0) / 100, 0, 1) }
	end
	local num = tonumber(text)
	if num then
		if text:find("%.") then
			return { frac = math.clamp(num, 0, 1) }
		end
		return { count = math.max(0, math.floor(num)) }
	end
	return nil
end

local function thresholdMet(th, left, total)
	if not th then return true end
	if th.frac then return left <= total * th.frac end
	return left <= th.count
end

local function plotSurfaceOf(state)
	local part = plotPartOf(state.Plot)
	if not part then return nil end
	return part.Position.X - part.Size.X * 0.5,
		part.Position.Z - part.Size.Z * 0.5,
		part.Position.Y + part.Size.Y * 0.5
end

--//// Rainbow Studs
Features.RainbowStuds = runExclusive("RainbowStuds", function(gen)
	Visuals.attach()

	while Global.Alive and Global.Toggles.RainbowStuds and Global.Gens.RainbowStuds == gen do
		local state = ensureCapture()
		if state then
			Visuals.greensFor(state)
			if Visuals.greenCount > 0 then
				local r, g, b = hueRGB(0)
				local L, F = state.Layers, state.Filled
				local Pixels = state.Pixels
				local W, H = state.Width, state.Height
				local layer = state.ActiveLayer
				local chunk = 0
				for idx in pairs(Visuals.green) do
					local i = idx - 1
					if buffer.readu8(F, i) ~= 1 and buffer.readu8(L, i) == layer then
						local off = ((i % W) * H + (H - 1 - (i // W))) * 4
						buffer.writeu8(Pixels, off, r)
						buffer.writeu8(Pixels, off + 1, g)
						buffer.writeu8(Pixels, off + 2, b)
						buffer.writeu8(Pixels, off + 3, 255)
					end
					chunk += 1
					if chunk >= 65536 then
						chunk = 0
						task.wait()
					end
				end
				state.Dirty = true
				task.wait(math.clamp(0.3 + Visuals.greenCount / 400000, 0.3, 1.2))
			else
				task.wait(0.5)
			end
		else
			task.wait(1)
		end
	end

	pcall(function()
		local CR = Visuals.renderModule
		if CR and CR.SetColors then
			CR:SetColors()
		end
	end)
end)

--//// Stud Pillars
Features.Pillars = runExclusive("Pillars", function(gen)
	Visuals.attach()

	local folder = Instance.new("Folder")
	folder.Name = "VolarisPillars"
	folder.Parent = workspace
	local pool = {}

	while Global.Alive and Global.Toggles.Pillars and Global.Gens.Pillars == gen do
		local cam = workspace.CurrentCamera
		if cam then
			if not folder:IsDescendantOf(game) then
				folder = Instance.new("Folder")
				folder.Name = "VolarisPillars"
				table.clear(pool)
			end
			if folder.Parent ~= cam then
				folder.Parent = cam
			end
		end
		local state = ensureCapture()
		local targets = nil
		if state and cam then
			Visuals.greensFor(state)
			if thresholdMet(Global.Values.PillarThreshold, Visuals.greenCount, Visuals.greenTotal)
				and plotPartOf(state.Plot) then
				local n = Visuals.greenCount
				if n <= pillarCap then
					targets = {}
					for idx in pairs(Visuals.green) do
						targets[#targets + 1] = idx
					end
				else
					local stride = math.ceil(n / pillarCap)
					targets = {}
					for idx = stride, state.Total, stride do
						if Visuals.green[idx] then
							targets[#targets + 1] = idx
							if #targets >= pillarCap then break end
						end
					end
				end
			end
		end

		local color = visualColor()
		local k = targets and #targets or 0
		local minX, minZ, topY
		if k > 0 then
			minX, minZ, topY = plotSurfaceOf(state)
		end
		for i = 1, k do
			local p = pool[i]
			if not p then
				p = Instance.new("Part")
				p.Name = "VolarisPillar"
				p.Anchored = true
				p.CanCollide = false
				p.CanQuery = false
				p.CanTouch = false
				p.CastShadow = false
				p.Locked = true
				p.Material = Enum.Material.Neon
				p.Size = Vector3.new(Config.pixelSize, pillarHeight, Config.pixelSize)
				pool[i] = p
			end
			if p.Parent ~= folder then p.Parent = folder end
			p.Color = color
			local idx = targets[i]
			local x = (idx - 1) % state.Width
			local z = (idx - 1) // state.Width
			p.CFrame = CFrame.new(
				minX + (x + 0.5) * Config.pixelSize,
				topY + pillarHeight * 0.5,
				minZ + (z + 0.5) * Config.pixelSize
			)
		end
		for i = k + 1, #pool do
			if pool[i].Parent then pool[i].Parent = nil end
		end

		task.wait(0.5)
	end

	folder:Destroy()
end)

--//// Arrow Pointer
do
local function findNearestCell(state)
	local _, _, root = getChar()
	if not root then return nil end
	local minX, minZ = plotSurfaceOf(state)
	if not minX then return nil end
	local W, H = state.Width, state.Height
	local cx = math.floor((root.Position.X - minX) / Config.pixelSize)
	local cz = math.floor((root.Position.Z - minZ) / Config.pixelSize)
	local L, F = state.Layers, state.Filled
	local layer = state.ActiveLayer
	local function isGreen(x, z)
		if x < 0 or x >= W or z < 0 or z >= H then return false end
		local i = z * W + x
		return buffer.readu8(F, i) ~= 1 and buffer.readu8(L, i) == layer
	end
	for r = 1, 60 do
		for dx = -r, r do
			if isGreen(cx + dx, cz - r) then return { x = cx + dx, z = cz - r } end
			if isGreen(cx + dx, cz + r) then return { x = cx + dx, z = cz + r } end
		end
		for dz = -r + 1, r - 1 do
			if isGreen(cx - r, cz + dz) then return { x = cx - r, z = cz + dz } end
			if isGreen(cx + r, cz + dz) then return { x = cx + r, z = cz + dz } end
		end
	end
	local bd, best = math.huge, nil

	local total = Visuals.greenCount or 0
	local stride = (total > 4000) and math.ceil(total / 4000) or 1
	local k = 0
	for idx in pairs(Visuals.green) do
		k += 1
		if stride > 1 and k % stride ~= 0 then continue end
		local x = (idx - 1) % W
		local z = (idx - 1) // W
		local d = (x - cx) * (x - cx) + (z - cz) * (z - cz)
		if d > 0 and d < bd then
			bd = d
			best = { x = x, z = z }
		end
	end
	return best
end

local arrowSprite = nil

local function getArrowSprite()
	if arrowSprite ~= nil then
		return arrowSprite or nil
	end
	arrowSprite = false
	pcall(function()
		local ei = AssetService:CreateEditableImage({ Size = Vector2.new(64, 64) })
		local buf = buffer.create(64 * 64 * 4)
		for x = 36, 58 do
			local half = (58 - x) * 18 // 22
			for y = 32 - half, 32 + half do
				local off = (y * 64 + x) * 4
				buffer.writeu8(buf, off, 255)
				buffer.writeu8(buf, off + 1, 255)
				buffer.writeu8(buf, off + 2, 255)
				buffer.writeu8(buf, off + 3, 255)
			end
		end
		for x = 6, 36 do
			for y = 26, 38 do
				local off = (y * 64 + x) * 4
				buffer.writeu8(buf, off, 255)
				buffer.writeu8(buf, off + 1, 255)
				buffer.writeu8(buf, off + 2, 255)
				buffer.writeu8(buf, off + 3, 255)
			end
		end
		ei:WritePixelsBuffer(Vector2.zero, Vector2.new(64, 64), buf)
		arrowSprite = ei
	end)
	return arrowSprite or nil
end

local function buildArrowPart()
	local part = Instance.new("Part")
	part.Name = "VolarisArrow"
	part.Size = Vector3.new(3.4, 0.04, 3.4)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Locked = true
	local gui = Instance.new("SurfaceGui")
	gui.Name = "ArrowGui"
	gui.Face = Enum.NormalId.Top
	gui.LightInfluence = 0
	gui.Brightness = 2
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 24
	gui.Parent = part
	local img = Instance.new("ImageLabel")
	img.Name = "Arrow"
	img.Size = UDim2.fromScale(1, 1)
	img.BackgroundTransparency = 1
	local sprite = getArrowSprite()
	if sprite then
		img.ImageContent = Content.fromObject(sprite)
	end
	img.Parent = gui
	return part, img
end

Features.ArrowPointer = function()
	if Global.Running.ArrowPointer then return end
	Global.Running.ArrowPointer = true
	Visuals.attach()

	local part, img = buildArrowPart()

	local state, target = nil, nil
	local stepConn = RunService.RenderStepped:Connect(function()
		local cam = workspace.CurrentCamera
		if not cam then return end
		if not part:IsDescendantOf(game) then
			part, img = buildArrowPart()
		end
		local st = state
		local t = target
		local _, _, root = getChar()
		if not (st and t and root) then
			if part.Parent then part.Parent = nil end
			return
		end
		local plotPart = plotPartOf(st.Plot)
		if not plotPart then
			if part.Parent then part.Parent = nil end
			return
		end
		local rel = plotPart.CFrame:PointToObjectSpace(root.Position)
		if math.abs(rel.X) > plotPart.Size.X * 0.5 or math.abs(rel.Z) > plotPart.Size.Z * 0.5 then
			if part.Parent then part.Parent = nil end
			return
		end
		local minX, minZ = plotSurfaceOf(st)
		if not minX then
			if part.Parent then part.Parent = nil end
			return
		end
		local tx = minX + (t.x + 0.5) * Config.pixelSize
		local tz = minZ + (t.z + 0.5) * Config.pixelSize
		local pos = Vector3.new(root.Position.X, root.Position.Y + 2.4, root.Position.Z)
		local dx, dz = tx - pos.X, tz - pos.Z
		if dx * dx + dz * dz >= 0.0025 then
			if part.Parent ~= cam then
				part.Parent = cam
			end
			img.ImageColor3 = visualColor()
			part.CFrame = CFrame.lookAt(pos, Vector3.new(tx, pos.Y, tz))
		end
	end)
	Global.Connections.ArrowStep = stepConn

	while Global.Toggles.ArrowPointer do
		local st = ensureCapture()
		if st then
			Visuals.greensFor(st)
			if thresholdMet(Global.Values.ArrowThreshold, Visuals.greenCount, Visuals.greenTotal) then
				state = st
				target = findNearestCell(st)
			else
				state, target = nil, nil
			end
		else
			state, target = nil, nil
		end
		task.wait(0.2)
	end

	stepConn:Disconnect()
	Global.Connections.ArrowStep = nil
	part:Destroy()
	Global.Running.ArrowPointer = false
end
end

--//// Tracers
local shutdown, unload
do
local tracerCap = 250

Features.Tracers = runExclusive("Tracers", function(gen)
	Visuals.attach()

	local lines = {}
	local current = nil
	local targets, targetCount, targetBuild = nil, nil, 0

	local stepConn = RunService.RenderStepped:Connect(function()
		local cam = workspace.CurrentCamera
		if not cam then return end
		local cur = current
		if not (cur and cur.state and cur.targets) then
			for _, l in ipairs(lines) do
				l.Visible = false
			end
			return
		end
		local _, _, root = getChar()
		if not root then
			for _, l in ipairs(lines) do
				l.Visible = false
			end
			return
		end
		local minX, minZ, topY = plotSurfaceOf(cur.state)
		if not minX then
			for _, l in ipairs(lines) do
				l.Visible = false
			end
			return
		end
		local color = visualColor()
		local from = cam:WorldToViewportPoint(root.Position)
		for i, l in ipairs(lines) do
			local idx = cur.targets[i]
			if not idx or from.Z <= 0 then
				l.Visible = false
			else
				local x = (idx - 1) % cur.state.Width
				local z = (idx - 1) // cur.state.Width
				local sp = cam:WorldToViewportPoint(Vector3.new(
					minX + (x + 0.5) * Config.pixelSize,
					topY,
					minZ + (z + 0.5) * Config.pixelSize
				))
				if sp.Z <= 0 then
					l.Visible = false
				else
					l.From = Vector2.new(from.X, from.Y)
					l.To = Vector2.new(sp.X, sp.Y)
					l.Color = color
					l.Visible = true
				end
			end
		end
	end)
	Global.Connections.TracerStep = stepConn

	while Global.Alive and Global.Toggles.Tracers and Global.Gens.Tracers == gen do
		local st = ensureCapture()
		local show = false
		if st then
			Visuals.greensFor(st)
			show = thresholdMet(Global.Values.TracerThreshold, Visuals.greenCount, Visuals.greenTotal)
				and plotPartOf(st.Plot) ~= nil
		end
		if show then
			if targets == nil
				or (targetCount ~= Visuals.greenCount and os.clock() - targetBuild > 0.5)
				or os.clock() - targetBuild > 2 then
				local t = {}
				local n = Visuals.greenCount
				if n <= tracerCap then
					for idx in pairs(Visuals.green) do
						t[#t + 1] = idx
					end
				else
					local stride = math.ceil(n / tracerCap)
					for idx = stride, st.Total, stride do
						if Visuals.green[idx] then
							t[#t + 1] = idx
							if #t >= tracerCap then break end
						end
					end
				end
				targets = t
				targetCount = n
				targetBuild = os.clock()
			end
			current = { state = st, targets = targets }
			while #lines < #targets do
				local created = false
				pcall(function()
					local d = Drawing.new("Line")
					d.Thickness = 1
					d.Visible = false
					lines[#lines + 1] = d
					created = true
				end)
				if not created then break end
			end
		else
			current = nil
		end
		task.wait(0.2)
	end

	stepConn:Disconnect()
	Global.Connections.TracerStep = nil
	for _, l in ipairs(lines) do
		pcall(function() l:Remove() end)
	end
	table.clear(lines)
end)

Global.Start = function()
	Global.Toggles.AutoPaint = true
	task.spawn(Features.AutoPaint)
end

--// Teardown
local function stopConnections()
	for key, conn in pairs(Global.Connections) do
		if type(conn) == "table" then
			for _, c in ipairs(conn) do pcall(function() c:Disconnect() end) end
		elseif typeof(conn) == "RBXScriptConnection" then
			pcall(function() conn:Disconnect() end)
		end
		Global.Connections[key] = nil
	end
end

shutdown = function()
	pcall(function()
		local host = (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui")
		if host then
			for _, old in ipairs(host:GetChildren()) do
				if old.Name == "VolarisCoverPreview" then
					old:Destroy()
				end
			end
		end
	end)
	if not Global.Restarting then
		pcall(Webhook.sessionEnd)
	end
	Global.Alive = false
	for key in pairs(Global.Toggles) do
		Global.Toggles[key] = false
	end
	local hook = Global.Connections.CanvasFix
	if hook then
		hook.module.Flush = hook.flush
		hook.module.Sweep = hook.sweep
		Global.Connections.CanvasFix = nil
	end
	Visuals.detach()
	stopConnections()
	plots = {}
	table.clear(Global.Running)
	genv.Volaris.PaintMangaHub = nil
end

unload = function()
	shutdown()
	pcall(function()
		local _, hum, root = getChar()
		if hum and root then
			hum:MoveTo(root.Position)
			hum.WalkSpeed = 16
		end
	end)
	pcall(function()
		if typeof(Starlight.DestroyFunction) == "function" then
			Starlight.DestroyFunction()
		end
	end)
	pcall(function()
		local container = gethui and gethui() or game:GetService("CoreGui")
		local gui = container:FindFirstChild("PaintMangaHub")
		if not gui then return end
		local getter = getupvalue or (debug and debug.getupvalue)
		local cleaned = false
		if typeof(getconnections) == "function" and getter then
			for _, c in ipairs(getconnections(gui.Destroying)) do
				local fn = c.Function or c["function"]
				if type(fn) == "function" then
					for i = 1, 20 do
						local ok, upv = pcall(getter, fn, i)
						if not ok then break end
						if type(upv) == "table" and (upv.__homeTabTime or upv.__fpscheck) then
							for _, conn in pairs(upv) do
								if typeof(conn) == "RBXScriptConnection" then
									pcall(function() conn:Disconnect() end)
								end
							end
							cleaned = true
						end
					end
				end
			end
		end
		if cleaned then
			for _, c in ipairs(getconnections(gui.Destroying)) do
				pcall(function() c:Disconnect() end)
			end
		end
	end)
	pcall(function() Starlight:Destroy() end)
end

Global.Unload = unload

sessionRestore()

--// Interface

Global.NotifySilent = true
end

--//// Window
pcall(function()
	Starlight.FileSystem.Folder = Global.AccountDir or "VolarisHub"
end)

Starlight:SetTheme("Orca")

local Window = Starlight:CreateWindow({
	Name = "Volaris Hub",
	Subtitle = "Paint a Manga!",
	Icon = NebulaIcons:GetIcon("brush", "Material"),
	LoadingEnabled = true,
	LoadingSettings = { Title = "Volaris Hub", Subtitle = "loading engine..." },
	FileSettings = {
		RootFolder = ".",
		ConfigFolder = "Paint a Manga",
		ThemesInRoot = true,
	},
})

Starlight:OnDestroy(function()
	shutdown()
end)

task.wait()
--//// Home Tab
Window:CreateHomeTab({
	SupportedExecutors = {},
	UnsupportedExecutors = {},
	Changelog = {
		{
			Title = "v1.2.0: Massive update!",
			Date = "14th September 2026",
			Description = "(+) COOP mode: Now youre able to efficiently play with multiple instances of botted clients "
				.. "without either one interfering with each other!\n"
				.. "(-+) Planner REVAMP: Completely changed how routes are planned. Now it plans an entire route from the "
				.. "start and thinks ahead.\n"
				.. "(+) NEW Blatant mode walker: Added a faster walking method to blatant mode.\n"
				.. "(-+) Queue REVAMP: Completely redesigned queue system for user friendliness. Built in menu and more.\n"
				.. "(+) a TON more bug fixes!"
		}
	},
})

task.wait()
--//// Painter Tab
local Main
do
Main = Window:CreateTabSection("Main")

local PainterTab = Main:CreateTab({
	Name = "Main",
	Icon = NebulaIcons:GetIcon("brush", "Material"),
	Columns = 2,
}, "PM_TAB_PAINTER")

local ControlBox = PainterTab:CreateGroupbox({ Name = "Auto Paint", Column = 1 }, "PM_BOX_CONTROL")
local AutoPaintToggle = ControlBox:CreateToggle({
	Name = "Auto Paint",
	Tooltip = "Walks to every green stud of every Colour until the cover is done.",
	CurrentValue = false,
	Style = 2,
	Callback = function(value)
		Global.Toggles.AutoPaint = value
		if value then
			task.spawn(Features.AutoPaint)
		end
	end,
}, "PM_TOGGLE_AUTOPAINT")
AutoPaintToggle:AddBind({
	HoldToInteract = false,
	SyncToggleState = true,
	Callback = function(value)
	end,
}, "PM_BIND_AUTOPAINT")

task.wait()
local MoveBox = PainterTab:CreateGroupbox({ Name = "Movement", Column = 1 }, "PM_BOX_MOVE")
MoveBox:CreateSlider({
	Name = "WalkSpeed",
	Tooltip = "Character walkspeed while painting.",
	Range = { 16, 150 },
	Increment = 1,
	Suffix = "",
	CurrentValue = Global.Values.WalkSpeed,
	Callback = function(value)
		Global.Values.WalkSpeed = value
		if Global.Toggles.AutoPaint then applyWalkSpeed() end
	end,
}, "PM_SLIDER_WALKSPEED")

task.wait()
local BlatantBox = PainterTab:CreateGroupbox({ Name = "Blatant", Column = 1 }, "PM_BOX_BLATANT")
BlatantToggle = BlatantBox:CreateToggle({
	Name = "Blatant Mode (adaptive teleport)",
	Tooltip = "USE AT YOUR OWN RISK. Teleports between stud clusters instead of walking.\n"
		.. "The server accepts it today, but it is obvious to anyone watching and "
		.. "far more likely to be flagged if the game ever adds position validation.",
	CurrentValue = false,
	Style = 1,
	IgnoreConfig = true,
	Callback = function(value)
		if Global.BlatantAutoRequest then
			Global.BlatantAutoRequest = nil
			Global.Toggles.Blatant = value
			Global.BlatantGen = (Global.BlatantGen or 0) + 1
			return
		end
		if Global.Toggles.Smart then
			task.defer(function()
				Global.BlatantAutoRequest = true
				pcall(function()
					BlatantToggle:Set({ CurrentValue = Global.Toggles.Blatant })
				end)
				Global.BlatantAutoRequest = nil
			end)
			pcall(function()
				Starlight:Notification({
					Title = "Volaris Hub",
					Content = "Blatant mode is managed by Smart mode.",
					Icon = NebulaIcons:GetIcon("circle-alert", "Lucide"),
					Duration = 5,
				}, "PM_SMART_NOTE")
			end)
			return
		end
		if value then
			pcall(function()
				Window:PromptDialog({
					Name = "Enable blatant mode?",
					Content = "Blatant mode teleports between stud clusters. "
						.. "The server accepts it today, but it is obvious to "
						.. "anyone watching and far more likely to be flagged "
						.. "if the game ever adds position validation.\n\n"
						.. "Enable it anyway?",
					Type = 1,
					Actions = {
						Primary = {
							Name = "Enable",
							Icon = NebulaIcons:GetIcon("circle-alert", "Lucide"),
							Callback = function()
								Global.Toggles.Blatant = true
								Global.BlatantGen = (Global.BlatantGen or 0) + 1
							end,
						},
						{
							Name = "Cancel",
							Callback = function()
								if BlatantToggle and BlatantToggle.Values
									and BlatantToggle.Values.CurrentValue then
									pcall(function()
										BlatantToggle:Set({ CurrentValue = false })
									end)
								end
							end,
						},
					},
				})
			end)
		else
			Global.Toggles.Blatant = false
			Global.BlatantGen = (Global.BlatantGen or 0) + 1
		end
	end,
}, "PM_TOGGLE_BLATANT")
BlatantBox:CreateToggle({
	Name = "Smart mode",
	Tooltip = "Turns Blatant mode on automatically while you are alone in the server and off the moment someone joins.\n"
		.. "While enabled, the Blatant toggle is managed automatically and locked.",
	CurrentValue = false,
	Style = 2,
	Callback = function(value)
		Global.Toggles.Smart = value
		if value then
			task.spawn(Features.Smart)
		end
	end,
}, "PM_TOGGLE_SMART")

local StatsBox = PainterTab:CreateGroupbox({
	Name = "Statistics",
	Icon = NebulaIcons:GetIcon("insights", "Material"),
	Column = 2,
}, "PM_BOX_STATS")
Labels.Phase = StatsBox:CreateLabel({ Name = "Status: idle" }, "PM_LBL_PHASE")
Labels.Color = StatsBox:CreateLabel({ Name = "Colour: --" }, "PM_LBL_COLOR")
Labels.Left = StatsBox:CreateLabel({ Name = "In Colour: --" }, "PM_LBL_LEFT")
Labels.Overall = StatsBox:CreateLabel({ Name = "Overall: --" }, "PM_LBL_OVERALL")
Labels.Speed = StatsBox:CreateLabel({ Name = "Speed: --" }, "PM_LBL_SPEED")
Labels.Eta = StatsBox:CreateLabel({ Name = "ETA: --" }, "PM_LBL_ETA")
Labels.Session = StatsBox:CreateLabel({ Name = "Session: --" }, "PM_LBL_SESSION")
Labels.Last = StatsBox:CreateLabel({ Name = "Last cover: --" }, "PM_LBL_LAST")
Labels.Coop = StatsBox:CreateLabel({ Name = "Coop: --" }, "PM_LBL_COOP")
end

task.wait()
--//// Queue Tab
local QueueTab = Main:CreateTab({
	Name = "Queue",
	Icon = NebulaIcons:GetIcon("playlist_play", "Material"),
	Columns = 2,
}, "PM_TAB_QUEUE")

	do
		local queueAddAll
		local ResultsLabel, ResultsPrev, ResultsNext
		local QueuePageLabel, QueuePrev, QueueNext

		local AboutBox = QueueTab:CreateGroupbox({ Name = "How Queueing Works", Column = 1 }, "PM_BOX_QHOW")
		AboutBox:CreateParagraph({
		Name = "How it works",
		Content = "Type in a manga title into the search input.\n"
			.. "Clicking search will give you a list of all available covers.\n"
			.. "Add them to the queue by clicking on them.\n"
			.. "Clicking on queue'd entries gives you actions that you can do with them."
	}, "PM_PARA_QHOW")

	local SearchBox = QueueTab:CreateGroupbox({ Name = "Search Covers", Column = 1 }, "PM_BOX_QSEARCH")
	local SearchState = { page = 1, results = nil, busy = false, lastPicked = nil }
	local RESULT_SLOTS, QUEUE_SLOTS = 8, 10
	local ResultSlots, QueueSlots = {}, {}
	local function searchPages()
		local n = SearchState.results and #SearchState.results or 0
		return math.max(1, math.ceil(n / RESULT_SLOTS))
	end

	local function statusMark(coverUrl, diff)
		local prior = fetchGallery()[coverUrl .. "\0" .. diff]
		if not prior then return "" end
		if prior.InProgress then
			return ("  ⏳%d%%"):format(tonumber(prior.Percent) or 0)
		end
		local times = tonumber(prior.Count) or 1
		return times > 1 and ("  ✓×%d"):format(times) or "  ✓"
	end

	local function queueWholeSeriesLabel()
		local anchor = SearchState.lastPicked
			or (SearchState.results and SearchState.results[1]) or nil
		if anchor and type(anchor.Series) == "string" and anchor.Series ~= "" then
			local ed = tostring(anchor.Edition or "")
			local lang = ed:match("%((%a[%w%-]*)%)%s*$")
			return anchor.Series, lang
		end
		return nil, nil
	end

	function renderSearchResults()
		local results = SearchState.results
		local offset = (SearchState.page - 1) * RESULT_SLOTS
		for k = 1, RESULT_SLOTS do
			local btn = ResultSlots[k]
			if btn then
				local item = results and results[offset + k] or nil
				if item then
					local diff = Global.Dropdowns.QueueDifficulty[1] or "Normal"
					btn:Set({ Name = ("%d. %s%s"):format(
						offset + k, entryDisplay(item), statusMark(item.CoverUrl, diff)) })
				else
					btn:Set({ Name = "-" })
				end
			end
		end
		local count = results and #results or 0
		local pages = searchPages()
		if ResultsLabel then
			if SearchState.busy then
				ResultsLabel:Set({ Name = "Results: searching..." })
			elseif not results then
				ResultsLabel:Set({ Name = "Results: type a query and search" })
			elseif count == 0 then
				ResultsLabel:Set({ Name = "Results: nothing found" })
			else
				ResultsLabel:Set({ Name = ("Results: %d-%d of %d · page %d/%d"):format(
					math.min(offset + 1, count), math.min(offset + RESULT_SLOTS, count),
					count, SearchState.page, pages) })
			end
		end
		if ResultsPrev then
			ResultsPrev:Set({ Name = SearchState.page > 1 and "◀ Prev page" or "◀ Prev (none)" })
		end
		if ResultsNext then
			ResultsNext:Set({ Name = SearchState.page < pages and "Next page ▶" or "Next (none) ▶" })
		end
	end

	local function doSearch()
		if SearchState.busy then return end
		local query = tostring(Global.Values.QTitle or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if query == "" then
			queueNotify("Queue", "Type a search query first.")
			return
		end
		SearchState.busy = true
		SearchState.results = nil
		SearchState.page = 1
		renderSearchResults()
		task.spawn(function()
			local ok, res = pcall(function()
				return Remotes.searchRemote:InvokeServer({ Query = query, Page = 1 })
			end)
			SearchState.busy = false
			if ok and type(res) == "table" and res.Ok == true and type(res.Results) == "table" then
				SearchState.results = res.Results
			else
				SearchState.results = {}
				queueNotify("Queue", ("Search failed%s."):format(
					type(res) == "table" and res.Error and (" (%s)"):format(tostring(res.Error)) or ""))
			end
			renderSearchResults()
		end)
	end

	local DiffLabel = SearchBox:CreateLabel({ Name = "Difficulty" }, "PM_LBL_QDIFF")
	DiffLabel:AddDropdown({
		Options = { "Easy", "Normal", "Hard", "Extreme", "Insane" },
		CurrentOptions = Global.Dropdowns.QueueDifficulty,
		Callback = function(options)
			Global.Dropdowns.QueueDifficulty = options
			renderSearchResults()
		end,
	}, "PM_DD_QDIFF")

	SearchBox:CreateInput({
		Name = "Search",
		Tooltip = "Same search the game uses",
		PlaceholderText = "e.g. Naruto",
		CurrentValue = Global.Values.QTitle,
		RemoveTextAfterFocusLost = false,
		MaxCharacters = 80,
		IgnoreConfig = true,
		Enter = true,
		Callback = function(text)
			Global.Values.QTitle = text
			doSearch()
		end,
	}, "PM_INPUT_QSEARCH")

	SearchBox:CreateButton({
		Name = "Search",
		IndicatorStyle = 1,
		Callback = doSearch,
	}, "PM_BTN_QSEARCH")

	ResultsLabel = SearchBox:CreateLabel({ Name = "Results: type a query and search" }, "PM_LBL_QRESULTS")
	for k = 1, RESULT_SLOTS do
		ResultSlots[k] = SearchBox:CreateButton({
			Name = "--",
			Tooltip = "Click to queue this cover with the selected difficulty.",
			IndicatorStyle = 1,
			Callback = function()
				local item = SearchState.results
					and SearchState.results[(SearchState.page - 1) * RESULT_SLOTS + k] or nil
				if item then
					SearchState.lastPicked = item
					task.spawn(function()
						queueInsertItem(item, Global.Dropdowns.QueueDifficulty[1] or "Normal")
						pcall(renderSearchResults)
					end)
				end
			end,
		}, "PM_QRES_" .. k)
	end
	ResultsPrev = SearchBox:CreateButton({
		Name = "◀ Prev (none)",
		Callback = function()
			if SearchState.page > 1 then
				SearchState.page -= 1
				renderSearchResults()
			end
		end,
	}, "PM_BTN_QRES_PREV")
	ResultsNext = SearchBox:CreateButton({
		Name = "Next (none) ▶",
		Callback = function()
			if SearchState.page < searchPages() then
				SearchState.page += 1
				renderSearchResults()
			end
		end,
	}, "PM_BTN_QRES_NEXT")
	SearchBox:CreateButton({
		Name = "Add All Covers",
		Tooltip = "Queues every volume of the series and translation."
			.. "Already painted / in-progress / queued "
			.. "volumes are skipped after a confirmation.",
		IndicatorStyle = 1,
		Callback = function()
			local series, lang = queueWholeSeriesLabel()
			if not series then
				queueNotify("Queue", "Search for the series first.")
				return
			end
			task.spawn(queueAddAll, series, Global.Dropdowns.QueueDifficulty[1] or "Normal", lang)
		end,
	}, "PM_BTN_QSERIES")

	function queueAddAll(series, difficulty, lang)
		series = tostring(series or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if series == "" then
		queueNotify("Queue", "Search for the series first.")
		return false
	end
	local diff = difficulty or "Normal"
	queueNotify("Queue", ("Searching every volume of \"%s\"..."):format(series))
	local list, allCount, winner = collectVolumes(series, lang)
	if #list == 0 then
		queueNotify("Queue", lang
			and ("No volumes with a (%s) edition found for \"%s\"."):format(lang, series)
			or ("No volumes found for \"%s\"."):format(series))
		return false
	end

	local gallery = fetchGallery()
	local queued = {}
	for _, e in ipairs(Global.Values.Queue) do
		if e.Difficulty == diff then
			queued[e.CoverUrl] = true
		end
	end
	local fresh, skippedPainted, skippedQueued, skippedPainting = {}, 0, 0, 0
	for _, v in ipairs(list) do
		local r = v.result
		local prior = gallery[r.CoverUrl .. "\0" .. diff]
		if prior then
			if prior.InProgress then
				skippedPainting += 1
			else
				skippedPainted += 1
			end
		elseif queued[r.CoverUrl] then
			skippedQueued += 1
		else
			fresh[#fresh + 1] = r
		end
	end
	if #fresh == 0 then
		queueNotify("Queue", ("Every volume of \"%s\" is already queued, painted, or in progress (%s).")
			:format(series, diff))
		return false
	end

	local missing = math.max(0, allCount - #list)
	local plural = #fresh == 1 and "volume" or "volumes"
	local langTag
	if lang then
		langTag = (" (%s)"):format(lang)
	elseif winner then
		langTag = (" (%s: most volumes)"):format(winner)
	else
		langTag = " (default: most volumes)"
	end
	local okDlg = pcall(function()
		Window:PromptDialog({
			Name = "Add all volumes",
			Content = ("Queue %d %s of \"%s\"%s as %s?\n"
				.. "Skipped automatically: %d painted, %d in progress, %d already queued%s.\n"
				.. "They load one after another automatically.")
				:format(#fresh, plural, series, langTag, diff,
					skippedPainted, skippedPainting, skippedQueued,
					missing > 0
						and (", %d volumes only exist in other translations"):format(missing)
						or ""),
			Type = 1,
			Actions = {
				Primary = {
					Name = "Add " .. #fresh .. " " .. plural,
					Icon = NebulaIcons:GetIcon("playlist_add", "Material"),
					Callback = function()
						for _, r in ipairs(fresh) do
							table.insert(Global.Values.Queue, {
								Title = r.Title,
								Series = r.Series,
								CoverUrl = r.CoverUrl,
								ThumbUrl = r.ThumbUrl,
								Difficulty = diff,
							})
						end
						refreshQueueDisplay()
						local extra = ""
						if skippedPainted > 0 then
							extra = extra .. (", %d already painted"):format(skippedPainted)
						end
						if skippedPainting > 0 then
							extra = extra .. (", %d in progress"):format(skippedPainting)
						end
						if skippedQueued > 0 then
							extra = extra .. (", %d already queued"):format(skippedQueued)
						end
						queueNotify("Queue", ("Queued %d %s of \"%s\"%s as %s%s.")
							:format(#fresh, plural, series, langTag, diff, extra))
					end,
				},
				{
					Name = "Cancel",
					Callback = function() end,
				},
			},
		})
	end)
	if not okDlg then
		queueNotify("Queue", "Confirmation dialog failed: nothing added.")
	end
	return okDlg
end
Global.QueueAddAll = queueAddAll

	local QueueBox = QueueTab:CreateGroupbox({ Name = "Queue", Column = 2 }, "PM_BOX_QUEUE")
	QueueParagraph = QueueBox:CreateParagraph({
		Name = "Up Next",
		Content = "(empty! queued covers load automatically when the current one finishes)",
	}, "PM_PARA_QUEUE")

	local QueuePage = 1

	local function manageEntry(i)
		local q = Global.Values.Queue
		local e = q[i]
		if not e then return end
		local okDlg = pcall(function()
			Window:PromptDialog({
				Name = "Queued entry",
				Content = ("%s\n\nDifficulty: %s\nPosition: #%d of %d%s"):format(
					entryDisplay(e, 60), tostring(e.Difficulty or "Normal"), i, #q,
					i == 1 and "\nThis is the next cover to load." or ""),
				Type = 1,
				Actions = {
					{
						Name = "Preview",
						Callback = function()
							CoverPreview.show(e)
						end,
					},
					{
						Name = "Move Up",
						Callback = function()
							if i > 1 then
								q[i], q[i - 1] = q[i - 1], q[i]
								refreshQueueDisplay()
							end
						end,
					},
					{
						Name = "Move Down",
						Callback = function()
							if i < #q then
								q[i], q[i + 1] = q[i + 1], q[i]
								refreshQueueDisplay()
							end
						end,
					},
					{
						Name = "Load Now",
						Callback = function()
							if Coop.active and not Coop.amLeader() then
								queueNotify("Queue", "Coop: only the party owner's queue can load covers right now.")
								return
							end
							table.remove(q, i)
							table.insert(q, 1, e)
							refreshQueueDisplay()
							loadNextFromQueue(true)
						end,
					},
					{
						Name = "Remove",
						Callback = function()
							table.remove(q, i)
							refreshQueueDisplay()
							queueNotify("Queue", ("Removed \"%s\" from the queue."):format(entryDisplay(e, 60)))
						end,
					}
				},
			})
		end)
		if not okDlg then
			queueNotify("Queue", "Could not open the entry dialog.")
		end
	end

	function renderQueueEditor()
		local q = Global.Values.Queue
		local pages = math.max(1, math.ceil(#q / QUEUE_SLOTS))
		if QueuePage > pages then QueuePage = pages end
		local offset = (QueuePage - 1) * QUEUE_SLOTS
		for k = 1, QUEUE_SLOTS do
			local btn = QueueSlots[k]
			if btn then
				local i = offset + k
				local e = q[i]
				if e then
					btn:Set({ Name = ("%d. %s - %s"):format(
						i, entryDisplay(e), tostring(e.Difficulty or "Normal")) })
				else
					btn:Set({ Name = "-" })
				end
			end
		end
		if QueuePageLabel then
			QueuePageLabel:Set({ Name = #q > 0
				and ("%d queued · page %d/%d"):format(#q, QueuePage, pages)
				or "Queue is empty! search and click a cover to add it" })
		end
		if QueuePrev then
			QueuePrev:Set({ Name = QueuePage > 1 and "◀ Prev" or "◀ Prev (none)" })
		end
		if QueueNext then
			QueueNext:Set({ Name = QueuePage < pages and "Next ▶" or "Next (none) ▶" })
		end
	end

	QueuePageLabel = QueueBox:CreateLabel({ Name = "Queue is empty" }, "PM_LBL_QPAGE")
	for k = 1, QUEUE_SLOTS do
		QueueSlots[k] = QueueBox:CreateButton({
			Name = "--",
			Tooltip = "Click to manage this queued cover: move it, load it now, or remove it.",
			IndicatorStyle = 1,
			Callback = function()
				local i = (QueuePage - 1) * QUEUE_SLOTS + k
				if Global.Values.Queue[i] then
					manageEntry(i)
				end
			end,
		}, "PM_QENT_" .. k)
	end
	QueuePrev = QueueBox:CreateButton({
		Name = "◀ Prev (none)",
		Callback = function()
			if QueuePage > 1 then
				QueuePage -= 1
				renderQueueEditor()
			end
		end,
	}, "PM_BTN_QENT_PREV")
	QueueNext = QueueBox:CreateButton({
		Name = "Next (none) ▶",
		Callback = function()
			local pages = math.max(1, math.ceil(#Global.Values.Queue / QUEUE_SLOTS))
			if QueuePage < pages then
				QueuePage += 1
				renderQueueEditor()
			end
		end,
	}, "PM_BTN_QENT_NEXT")
	QueueBox:CreateButton({
		Name = "Clear Queue",
		Tooltip = "Removes every queued cover after a confirmation.",
		IndicatorStyle = 1,
		Callback = function()
			if #Global.Values.Queue == 0 then return end
			pcall(function()
				Window:PromptDialog({
					Name = "Clear queue",
					Content = ("Remove all %d queued covers?"):format(#Global.Values.Queue),
					Type = 1,
					Actions = {
						Primary = {
							Name = "Clear all",
							Icon = NebulaIcons:GetIcon("delete", "Material"),
							Callback = function()
								table.clear(Global.Values.Queue)
								refreshQueueDisplay()
								queueNotify("Queue", "Queue cleared.")
							end,
						},
						{
							Name = "Cancel",
							Callback = function() end,
						},
					},
				})
			end)
		end,
	}, "PM_BTN_QCLEAR")
	refreshQueueDisplay()
end

task.wait()
--//// Visuals Tab
do
local VisualsTab = Main:CreateTab({
	Name = "Visuals",
	Icon = NebulaIcons:GetIcon("palette", "Material"),
	Columns = 2,
}, "PM_TAB_VISUALS")

local StudBox = VisualsTab:CreateGroupbox({ Name = "Studs", Column = 1 }, "PM_BOX_VSTUDS")
StudBox:CreateToggle({
	Name = "Rainbow studs",
	Tooltip = "Cycles the unpainted studs through the colour wheel",
	CurrentValue = false,
	Style = 2,
	Callback = function(value)
		Global.Toggles.RainbowStuds = value
		if value then
			task.spawn(Features.RainbowStuds)
		end
	end,
}, "PM_TOGGLE_RAINBOW")

local PillarBox = VisualsTab:CreateGroupbox({ Name = "Stud Pillars", Column = 1 }, "PM_BOX_VPILLAR")
PillarBox:CreateParagraph({
	Name = "About",
	Content = "Pillars indicating location of studs on canvas.\n"
		.. "Threshold: 50 = when 50 studs are left, 0.2 or 20% = when 20% of the "
		.. "Colour is left, empty = always while enabled.",
}, "PM_PARA_VPILLAR")
local PillarToggle = PillarBox:CreateToggle({
	Name = "Show pillars",
	Tooltip = "Spawns neon pillars over remaining studs.",
	CurrentValue = false,
	Style = 2,
	Callback = function(value)
		Global.Toggles.Pillars = value
		if value then
			task.spawn(Features.Pillars)
		end
	end,
}, "PM_TOGGLE_PILLARS")
local PillarPicker = PillarToggle:AddColorPicker({
	CurrentValue = Global.Values.PillarColor,
	Callback = function(Colour)
		Global.Values.PillarColor = Colour
	end,
}, "PM_CP_PILLARC")
PillarBox:CreateToggle({
	Name = "Rainbow pillars",
	Tooltip = "Pillars follow the same Colour wheel as rainbow studs.",
	CurrentValue = false,
	Style = 2,
	Callback = function(value)
		Global.Toggles.RainbowPillars = value
		if value then
			pcall(function() PillarPicker:Lock("Rainbow pillars is on") end)
		else
			pcall(function() PillarPicker:Unlock() end)
		end
	end,
}, "PM_TOGGLE_PRBOW")
PillarBox:CreateInput({
	Name = "Show when studs left <=",
	Tooltip = "50 = when 50 studs remain.\n0.2 or 20% = when 20% of the Colour remains.\nEmpty = always while enabled.\nDefaults to 1%.",
	PlaceholderText = "e.g. 50, 0.2 or 20%",
	CurrentValue = "1%",
	RemoveTextAfterFocusLost = false,
	MaxCharacters = 12,
	Callback = function(text)
		Global.Values.PillarThreshold = parseThreshold(text)
	end,
}, "PM_INPUT_PTHR")

local ArrowBox = VisualsTab:CreateGroupbox({ Name = "Stud Compass", Column = 2 }, "PM_BOX_VARROW")
ArrowBox:CreateParagraph({
	Name = "About",
	Content = "Arrow/compass above your head pointing at the nearest remaining stud.\n"
		.. "Threshold: 50 = when 50 studs are left, 0.2 or 20% = when 20% of the "
		.. "Colour is left, empty = always while enabled.",
}, "PM_PARA_VARROW")
ArrowBox:CreateToggle({
	Name = "Show arrow",
	Tooltip = "Arrow above your head pointing at the nearest remaining stud.",
	CurrentValue = false,
	Style = 2,
	Callback = function(value)
		Global.Toggles.ArrowPointer = value
		if value then
			task.spawn(Features.ArrowPointer)
		end
	end,
}, "PM_TOGGLE_ARROW")
ArrowBox:CreateInput({
	Name = "Show when studs left <=",
	Tooltip = "Same formats as the pillar threshold. Defaults to 1%.",
	PlaceholderText = "e.g. 50, 0.2 or 20%",
	CurrentValue = "1%",
	RemoveTextAfterFocusLost = false,
	MaxCharacters = 12,
	Callback = function(text)
		Global.Values.ArrowThreshold = parseThreshold(text)
	end,
}, "PM_INPUT_ATHR")

local TracerBox = VisualsTab:CreateGroupbox({ Name = "Stud Tracers", Column = 2 }, "PM_BOX_VTRACE")
TracerBox:CreateParagraph({
	Name = "About",
	Content = "Draws a line from your character to every remaining stud (capped at 250).\n"
		.. "Threshold: 50 = when 50 studs are left, 0.2 or 20% = when 20% of the "
		.. "Colour is left, empty = always while enabled.\nDefaults to 1%.",
}, "PM_PARA_VTRACE")
TracerBox:CreateToggle({
	Name = "Show tracers",
	Tooltip = "Lines from your character to every remaining stud (capped at 250).",
	CurrentValue = false,
	Style = 2,
	Callback = function(value)
		Global.Toggles.Tracers = value
		if value then
			task.spawn(Features.Tracers)
		end
	end,
}, "PM_TOGGLE_TRACERS")
TracerBox:CreateInput({
	Name = "Show when studs left <=",
	Tooltip = "Same formats as the pillar threshold. Defaults to 1%.",
	PlaceholderText = "e.g. 50, 0.2 or 20%",
	CurrentValue = "1%",
	RemoveTextAfterFocusLost = false,
	MaxCharacters = 12,
	Callback = function(text)
		Global.Values.TracerThreshold = parseThreshold(text)
	end,
}, "PM_INPUT_TTHR")


end


task.wait()
--//// Misc Tab
do
local MiscTab = Main:CreateTab({
	Name = "Misc",
	Icon = NebulaIcons:GetIcon("puzzle", "Lucide"),
	Columns = 2,
}, "PM_TAB_MISC")

local GenMoveBox = MiscTab:CreateGroupbox({ Name = "Movement", Column = 1 }, "PM_BOX_GENMOVE")
GenMoveBox:CreateSlider({
	Name = "WalkSpeed",
	Tooltip = "General character speed outside of painting.\nThe painting speed is separate (Main tab).",
	Range = { 16, 150 },
	Increment = 1,
	Suffix = "",
	CurrentValue = Global.Values.GeneralWalkSpeed,
	Callback = function(value)
		Global.Values.GeneralWalkSpeed = value
		if Global.Toggles.GeneralSpeed and not Global.Toggles.AutoPaint then
			local _, hum = getChar()
			if hum then hum.WalkSpeed = value end
		end
	end,
}, "PM_SLIDER_GENWALK")
GenMoveBox:CreateToggle({
	Name = "Apply Always",
	Tooltip = "Keeps the general WalkSpeed applied while you walk around.\nPainting speed takes over automatically while Auto Paint runs.",
	CurrentValue = false,
	Style = 2,
	Callback = function(value)
		Global.Toggles.GeneralSpeed = value
		if value then
			task.spawn(Features.GeneralSpeed)
		end
	end,
}, "PM_TOGGLE_GENSPEED")

local AfkBox = MiscTab:CreateGroupbox({ Name = "Anti-AFK", Column = 1 }, "PM_BOX_AFK")
AfkBox:CreateToggle({
	Name = "Anti-AFK",
	Tooltip = "Prevents the game's idle disconnect.",
	CurrentValue = false,
	Style = 2,
	Callback = function(value)
		Global.Toggles.AntiAFK = value
		if value then
			task.spawn(Features.AntiAFK)
		end
	end,
}, "PM_TOGGLE_ANTIAFK")

local HopBox = MiscTab:CreateGroupbox({ Name = "Server Hop", Column = 2 }, "PM_BOX_HOP")
HopBox:CreateParagraph({
	Name = "Staff watch",
	Content = "Looks out for staff/important members and hops server upon detection.",
}, "PM_PARA_HOPINFO")
HopBox:CreateToggle({
	Name = "Hop on staff presence",
	Tooltip = "Enabling also scans the players already in this server, not just joins.",
	CurrentValue = false,
	Style = 2,
	Callback = function(value)
		Global.Toggles.StaffHop = value
		if value then
			task.spawn(Features.StaffHop)
		end
	end,
}, "PM_TOGGLE_STAFFHOP")
HopBox:CreateButton({
	Name = "Hop now",
	Tooltip = "Immediately hops to another public server (manual escape / test).",
	IndicatorStyle = 2,
	Callback = function()
		hopAway("manual hop")
	end,
}, "PM_BTN_HOPNOW")
end

task.wait()
--//// Coop Tab
do
do
	local CoopTab = Main:CreateTab({
		Name = "Coop",
	Icon = NebulaIcons:GetIcon("groups", "Material"),
	Columns = 2,
}, "PM_TAB_COOP")

local CoopPartyBox = CoopTab:CreateGroupbox({ Name = "Party", Column = 1 }, "PM_BOX_COOPPARTY")
local CoopPartyPara = CoopPartyBox:CreateParagraph({
	Name = "Members",
	Content = "(not in a party)",
}, "PM_PARA_COOPPARTY")
CoopPartyBox:CreateButton({
	Name = "Refresh party",
	Tooltip = "Re-reads the coop party state from the server.",
	IndicatorStyle = 1,
	Callback = function()
		task.spawn(function()
			Coop.refresh()
			if Coop.updateTab then
				Coop.updateTab()
			end
		end)
	end,
}, "PM_BTN_COOPREFRESH")

local CoopSessionBox = CoopTab:CreateGroupbox({ Name = "Session", Column = 2 }, "PM_BOX_COOPSESSION")
local CoopSessionPara = CoopSessionBox:CreateParagraph({
	Name = "Status",
	Content = "--",
}, "PM_PARA_COOPSESSION")

local CoopAboutBox = CoopTab:CreateGroupbox({ Name = "How Coop Works", Column = 2 }, "PM_BOX_COOPABOUT")
CoopAboutBox:CreateParagraph({
	Name = "About",
	Content = "Painting in a coop party will plan the painter in a more efficient way "
		.. "by splitting the workload among other botted instances.\n"
		.. "Same-PC instances are far more efficient and more robust in forming plans/routes."
}, "PM_PARA_COOPABOUT")

Coop.motion = Coop.motion or {}
task.spawn(function()
	while Global.Alive do
		task.wait(0.5)
		pcall(function()
			if not Coop.active then return end
			local plots = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Plots")
			if not plots then return end
			for _, m in ipairs(Coop.members) do
				if m.userId ~= Players.LocalPlayer.UserId then
					local plr = Players:GetPlayerByUserId(m.userId)
					local root = plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
					if root then
						local ring = Coop.motion[m.userId]
						if not ring then
							ring = { samples = {} }
							Coop.motion[m.userId] = ring
						end
						local r = ring.samples
						r[#r + 1] = { pos = root.Position, t = os.clock() }
						if #r > 10 then
							table.remove(r, 1)
						end
						local ps = activePlot()
						if ps and ps.Layer and Coop.plot == ps.Name then
							local strip = Coop.stripFor(ps, ps.Layer)
							if strip and strip.cuts then
								local pIdx = nil
								for i, mm in ipairs(Coop.members) do
									if mm.userId == m.userId then
										pIdx = i
										break
									end
								end
								if pIdx then
									local a0 = strip.cuts[pIdx]
									local a1 = strip.cuts[pIdx + 1] - 1
									local cx, cy = worldToCell(ps, root.Position)
									local inBand = (strip.axis == "x" and cx >= a0 and cx <= a1)
										or (strip.axis == "y" and cy >= a0 and cy <= a1)
									if inBand then
										Coop.stripSeen = Coop.stripSeen or {}
										Coop.stripSeen[m.userId] = os.clock()
									end
								end
							end
						end
					end
				end
			end
		end)
	end
end)

local function coopScriptTag(m)
	if CoopMesh.seen[m.userId] and os.clock() - CoopMesh.seen[m.userId] < 25 then
		return "  · linked (same PC)"
	end
	if Coop.stripSeen and Coop.stripSeen[m.userId]
		and os.clock() - Coop.stripSeen[m.userId] < 30 then
		return "  · linked (strip behaviour)"
	end
	local ring = Coop.motion[m.userId]
	local s = ring and ring.samples or nil
	if not s or #s < 4 then
		return "  · human?"
	end
	local straight, total = 0, 0
	local lastUnit
	for i = 2, #s do
		local v = s[i].pos - s[i - 1].pos
		local flat = Vector3.new(v.X, 0, v.Z)
		local mag = flat.Magnitude
		if mag > 1 then
			total += 1
			local unit = flat / mag
			if lastUnit and unit:Dot(lastUnit) > 0.985 then
				straight += 1
			end
			lastUnit = unit
		end
	end
	if total >= 3 and straight / total >= 0.8 then
		return "  · likely script"
	end
	return "  · human?"
end

local function coopUpdateTab()
	local lines = {}
	if Coop.active then
		local myId = Players.LocalPlayer.UserId
		local names = {}
		for _, m in ipairs(Coop.members) do
			names[#names + 1] = m.name
		end
		lines[#lines + 1] = ("Shared plot: %s · embed owner: %s"):format(
			Coop.plot ~= "" and Coop.plot or "?",
			Coop.amLeader() and "you" or "party host")
		for _, m in ipairs(Coop.members) do
			local tag = m.userId == myId and " (you)" or coopScriptTag(m)
			lines[#lines + 1] = ("• %s%s%s"):format(
				m.name, m.owner and " 👑" or "", tag)
		end
	else
		lines[#lines + 1] = "(not in a party. coop activates when 2+ players form one)"
	end
	pcall(function()
		CoopPartyPara:Set({ Content = table.concat(lines, "\n") })
	end)
	pcall(function()
		local meshState = "probing…"
		if CoopMesh.available == true then
			meshState = "linked"
		elseif CoopMesh.available == false then
			meshState = "unavailable (cross-PC partners use strip behaviour)"
		end
		CoopSessionPara:Set({ Content = table.concat({
			"Coop mode: " .. (Coop.active and "ACTIVE" or "off"),
			"Area strips: " .. (Coop.active
				and "on"
				or "--"),
			"Same-PC mesh: " .. meshState,
			"Webhook embed: " .. (Coop.active
				and (Coop.amLeader() and "owned by you" or "owned by party host")
				or "per-account (solo mode)"),
		}, "\n") })
	end)
end
Coop.updateTab = coopUpdateTab
end
end

task.wait()
--//// Webhook Tab
do
local HookTab = Main:CreateTab({
	Name = "Webhook",
	Icon = NebulaIcons:GetIcon("webhook", "Lucide"),
	Columns = 2,
}, "PM_TAB_WEBHOOK")

local HookBox = HookTab:CreateGroupbox({ Name = "Webhook", Column = 1 }, "PM_BOX_HOOK")

HookBox:CreateInput({
	Name = "Webhook URL",
	Tooltip = "Paste a Discord webhook URL.",
	PlaceholderText = "https://discord.com/api/webhooks/...",
	CurrentValue = Global.Webhook.url,
	RemoveTextAfterFocusLost = false,
	MaxCharacters = 200,
	Callback = function(text)
		Global.Webhook.url = text
	end,
}, "PM_INPUT_HOOKURL")

HookBox:CreateToggle({
	Name = "Enable Webhook",
	Tooltip = "Posts a message during events like cover loads, server hops, etc.",
	CurrentValue = false,
	Callback = function(value)
		Global.Toggles.Webhook = value
		if value and (Global.Webhook.url or "") == "" then
			Webhook.status("no webhook URL set")
			if not Global.NotifySilent then
				pcall(function()
					Starlight:Notification({
						Title = "Volaris Hub",
						Content = "Paste a webhook URL to start posting.",
						Icon = NebulaIcons:GetIcon("circle-alert", "Lucide"),
						Duration = 6,
					}, "PM_HOOK_NOTE")
				end)
			end
		end
	end,
}, "PM_TOGGLE_HOOK")

Labels.Hook = HookBox:CreateLabel({ Name = "Status: idle" }, "PM_LBL_HOOK")

local TemplateBox = HookTab:CreateGroupbox({ Name = "Embed Template", Column = 2 }, "PM_BOX_HOOKTPL")

TemplateBox:CreateParagraph({
	Name = "Tokens",
	Content = "Tokens:\n"
		.. "{COVER_NAME} + {DIFFICULTY} - loaded cover\n"
		.. "{PLAYER} - the account running this embed\n"
		.. "{PARTNERS} - coop partners (or \"solo\")\n"
		.. "{MANGADEX_URL} - manga page link\n"
		.. "{COVER_IMAGE_URL} - cover image\n"
		.. "{STATE} - status line, flips per state\n"
		.. "{COLOR} - embed colour per state (raw)\n"
		.. "{PROGRESS} - overall percent\n"
		.. "{STUDS_PROGRESS} / {STUDS_REMAINING}\n"
		.. "{COLOUR_PROGRESS} - current colour\n"
		.. "{OVERALL_COVER_ETA} / {INCOLOR_ETA}\n"
		.. "{STUDS_PER_MINUTE} - painting speed\n"
		.. "{COVER_TIME} - official completion time (only shown once the cover is done)\n"
		.. "{SESSION_TIME} / {SESSION_STARTED}\n"
		.. "{COVERS_FINISHED} - this session\n"
		.. "{PLANNER} - strokes or zone planner\n"
		.. "{QUEUE} - queued covers\n"
		.. "{PLAYERS_ON_SERVER_COUNT}\n"
		.. "{BLATANT_MODE} - ON/OFF state\n"
		.. "{TIMESTAMP} - edit time (raw)\n"
		.. "{ERROR} - error reason when stopped\n"
		.. "Empty template = built-in default.",
}, "PM_PARA_HOOKTOKENS")

TemplateBox:CreateButton({
	Name = "Copy Template",
	Tooltip = "Copies your embed template (or the built-in default) to the clipboard as minified JSON. "
		.. "Edit it in any text editor and paste it back into Embed Template.",
	IndicatorStyle = 1,
	Callback = function()
		local tpl = Global.Webhook.template
		if type(tpl) ~= "string" or tpl == "" then
			tpl = Webhook.Template
		end
		if typeof(setclipboard) == "function" then
			pcall(setclipboard, tpl)
			Webhook.status("template copied " .. os.date("%H:%M:%S"))
		else
			Webhook.status("clipboard unavailable on this executor")
		end
	end,
}, "PM_BTN_HOOKCOPY")

TemplateBox:CreateInput({
	Name = "Embed Template",
	Tooltip = "Optional. Minified embed JSON with tokens like {COVER_NAME}, {QUEUE}, {STATE}, {COLOR}. "
		.. "Leave empty to use the built-in default.",
	PlaceholderText = "minified embed JSON (empty = default)",
	CurrentValue = Global.Webhook.template,
	RemoveTextAfterFocusLost = false,
	MaxCharacters = 4000,
	Callback = function(text)
		Global.Webhook.template = text
	end,
}, "PM_INPUT_HOOKTEMPLATE")

TemplateBox:CreateButton({
	Name = "Send Test",
	Tooltip = "Posts the current embed as a one-off preview without linking it to this session.",
	IndicatorStyle = 1,
	Callback = function()
		task.spawn(function()
			if (Global.Webhook.url or "") == "" then
				Webhook.status("no webhook URL set")
				return
			end
			if Webhook.post(Webhook.embed("active")) then
				Webhook.status("test sent " .. os.date("%H:%M:%S"))
			end
		end)
	end,
}, "PM_BTN_HOOKTEST")
end

task.wait()
--//// Settings Tab
do
local SettingsTab = Main:CreateTab({
	Name = "Settings",
	Icon = NebulaIcons:GetIcon("settings", "Material"),
	Columns = 2,
}, "PM_TAB_SETTINGS")
SettingsTab:BuildThemeGroupbox(1)
SettingsTab:BuildConfigGroupbox(2)

local AccountBox = SettingsTab:CreateGroupbox({ Name = "Per-Account Config", Column = 1 }, "PM_BOX_PACCT")
AccountBox:CreateParagraph({
	Name = "About",
	Content = "Multi-instance support: each Roblox account gets its own configs, queue and session "
		.. "so several instances can run side by side without clobbering each other.\n"
		.. "Accounts without a binding use the default config. Applies on the next script start.",
}, "PM_PARA_PACCT")
AccountBox:CreateToggle({
	Name = "Enable per-account storage",
	CurrentValue = Global.AccountSettings.perAccountConfigs == true,
	Style = 2,
	Callback = function(value)
		local changed = (Global.AccountSettings.perAccountConfigs == true) ~= (value == true)
		Global.AccountSettings.perAccountConfigs = value
		Global.AccountSettingsWrite()
		if changed then
			queueNotify("Per-account storage", value
				and "Enabled. Re-execute the script to move this account's data."
				or "Disabled. Re-execute to return to shared storage.")
		end
	end,
}, "PM_TOGGLE_PACCT")
local pacctSelected = Global.AccountSettings.defaultConfig
local function pacctConfigOptions()
	local names = {}
	pcall(function()
		for _, path in ipairs(listfiles((Global.AccountDir or "VolarisHub") .. "/Paint a Manga/configs")) do
			local base = string.match(path:gsub("[/\\]+$", ""), "[^/\\]+$")
			base = base:match("^(.-)%.starlight$") or base:match("^(.-)%.txt$") or base
			if base ~= "autoload" and base ~= "" then
				names[#names + 1] = base
			end
		end
	end)
	table.sort(names)
	return names
end
local PacctCfgLabel = AccountBox:CreateLabel({ Name = "Config" }, "PM_LBL_PACCTCFG")
PacctCfgLabel:AddDropdown({
	Options = pacctConfigOptions(),
	CurrentOption = (Global.AccountSettings.defaultConfig ~= ""
		and { Global.AccountSettings.defaultConfig } or {}),
	Callback = function(options)
		pacctSelected = tostring(options[1] or "")
	end,
}, "PM_DD_PACCT")
AccountBox:CreateButton({
	Name = "Set as default for all accounts",
	IndicatorStyle = 1,
	Callback = function()
		if pacctSelected == "" then
			queueNotify("Per-account storage", "Pick a config in the dropdown first.")
			return
		end
		Global.AccountSettings.defaultConfig = pacctSelected
		Global.AccountSettingsWrite()
		queueNotify("Per-account storage", ("Default config set to \"%s\"."):format(pacctSelected))
	end,
}, "PM_BTN_PACCTDEF")
AccountBox:CreateButton({
	Name = "Bind config to this account",
	IndicatorStyle = 1,
	Callback = function()
		if pacctSelected == "" then
			queueNotify("Per-account storage", "Pick a config in the dropdown first.")
			return
		end
		Global.AccountSettings.accounts[tostring(Players.LocalPlayer.UserId)] = pacctSelected
		Global.AccountSettingsWrite()
		queueNotify("Per-account storage",
			("This account will autoload \"%s\". Re-execute to apply."):format(pacctSelected))
	end,
}, "PM_BTN_PACCTBIND")
AccountBox:CreateButton({
	Name = "Clear this account's binding",
	IndicatorStyle = 1,
	Callback = function()
		Global.AccountSettings.accounts[tostring(Players.LocalPlayer.UserId)] = nil
		Global.AccountSettingsWrite()
		queueNotify("Per-account storage", "Binding cleared. The default config applies again.")
	end,
}, "PM_BTN_PACCTCLEAR")
AccountBox:CreateLabel({
	Name = "Account: " .. Players.LocalPlayer.Name .. " (" .. Players.LocalPlayer.UserId .. ")",
}, "PM_LBL_PACCT")
SettingsTab:CreateGroupbox({ Name = "Control", Column = 1 }, "PM_BOX_CONTROL2"):CreateButton({
	Name = "Unload",
	Tooltip = "Completely removes the script, engine and UI.",
	IndicatorStyle = 2,
	Callback = function()
		task.delay(0.1, unload)
	end,
}, "PM_BTN_UNLOAD")

--// Autoloads
local oldSuite = "Starlight Interface Suite/VolarisHub"
if typeof(isfolder) == "function" and typeof(listfiles) == "function" and isfolder(oldSuite) then
	pcall(copyTree, oldSuite, "VolarisHub")
end

Starlight:LoadAutoloadTheme()

task.spawn(Features.StatLoop)

Starlight:LoadAutoloadConfig()

task.delay(3, function()
	Global.NotifySilent = nil
end)

task.spawn(Features.CanvasFix)

task.spawn(Features.StaffWatch)

task.spawn(Webhook.loop)

task.spawn(function()
	while Global.Alive do
		task.wait(5)
		pcall(function()
			if Coop.refresh then
				Coop.refresh()
			end
		end)
		pcall(function()
			if Coop.updateTab then
				Coop.updateTab()
			end
		end)
	end
end)

task.spawn(function()
	actorAvailable()
end)

Starlight:Notification({
	Title = "Volaris Hub",
	Content = "Finished loading. Enable Auto Paint on the Painter tab (load a cover via Search first).",
	Icon = NebulaIcons:GetIcon("check_circle", "Material"),
}, "PM_LOAD_COMPLETE")
end

--//// Coop mesh (same-machine instances)
function Coop.meshHeartbeat()
	if CoopMesh.available == false or not Coop.active then return end
	local ok = pcall(function()
		if makefolder then makefolder(meshDir) end
		local payload = game:GetService("HttpService"):JSONEncode({
			userId = Players.LocalPlayer.UserId,
			name = Players.LocalPlayer.Name,
			plot = Coop.plot,
			layer = Stats.layer,
			running = Global.Toggles.AutoPaint == true,
			rate = Global.MyPaintRate or 0,
			t = os.time(),
		})
		writefile(meshDir .. "/handshake_" .. tostring(Coop.plot or "1") .. "_" .. Players.LocalPlayer.UserId .. ".json", payload)
	end)
	CoopMesh.available = ok and true or false
end

function Coop.meshScan()
	if CoopMesh.available == false or not Coop.active then return end
	pcall(function()
		local now = os.time()
		for _, m in ipairs(Coop.members) do
			if m.userId ~= Players.LocalPlayer.UserId then
				local path = meshDir .. "/handshake_" .. tostring(Coop.plot or "1") .. "_" .. m.userId .. ".json"
				if isfile and isfile(path) then
					local okRead, data = pcall(function()
						return game:GetService("HttpService"):JSONDecode(readfile(path))
					end)
					if okRead and type(data) == "table"
						and data.userId == m.userId and now - (tonumber(data.t) or 0) < 15 then
						CoopMesh.rates[m.userId] = tonumber(data.rate) or 0
						CoopMesh.seen[m.userId] = os.clock()
					end
				end
			end
		end
	end)
end

task.spawn(function()
	while Global.Alive do
		task.wait(3)
		local okBeat, errBeat = pcall(Coop.meshHeartbeat)
		if not okBeat then
			warn("[Volaris] mesh heartbeat error: " .. tostring(errBeat))
		end
		local okScan, errScan = pcall(Coop.meshScan)
		if not okScan then
			warn("[Volaris] mesh scan error: " .. tostring(errScan))
		end
	end
end)