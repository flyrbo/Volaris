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


--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Configuration

--//// Game
local placeId = 100248945884133
local pixelSize = 1 / 3
local brushStuds = 2
local flatMask = Vector3.new(1, 0, 1)
local maxRounds = 8
local stallLimit = 4
local jumpDist = 20
local twoOptMax = 1500
local bandDenseFrac = 0.3
local bandMinRows = 3
local bandMinCount = 40
local bandMinRowCount = 4
local bandTurnTime = 0.35

--//// URLs
local libraryUrls = {
	Starlight = "https://raw.nebulasoftworks.xyz/starlight",
	NebulaIcons = "https://raw.nebulasoftworks.xyz/nebula-icon-library-loader",
}

--// Boot

--//// Unload Guard
if typeof(getgenv) == "function" then
	local previous = getgenv().Volaris and getgenv().Volaris.PaintMangaHub
	if previous and previous.Unload then
		previous.Unload()
	end
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
getgenv().InterfaceName = "PaintMangaHub"

local libCache = "VolarisHub/libs"
local canCache = typeof(writefile) == "function" and typeof(readfile) == "function"

local function bootLib(key, urls)
	local cachePath = libCache .. "/" .. key .. ".luau"
	local lastErr = "no source loaded"
	for _, url in ipairs(urls) do
		local okHttp, src = pcall(function()
			return game:HttpGet(url)
		end)
		if okHttp and type(src) == "string" and #src > 512 then
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
							writefile(cachePath, src)
						end)
					end
					return true, lib
				end
				lastErr = "run failed: " .. tostring(lib):sub(1, 120)
			else
				lastErr = "compile failed: " .. tostring(fn):sub(1, 120)
			end
		else
			lastErr = "fetch failed: " .. tostring(src):sub(1, 120)
		end
	end
	if canCache then
		local okCache, cached = pcall(readfile, cachePath)
		if okCache and type(cached) == "string" and #cached > 512 then
			local okFn, fn = pcall(loadstring, cached)
			if okFn and fn then
				local okRun, lib = pcall(fn)
				if okRun and lib ~= nil then
					return true, lib
				end
				lastErr = "cache run failed: " .. tostring(lib):sub(1, 120)
			end
		end
	end
	return false, lastErr
end

local okStarlight, Starlight = bootLib("starlight", {
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
local NebulaIcons = nil
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

--//// Game Check
if game.PlaceId ~= placeId then
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
Global.Alive = true

	Global.Values.WalkSpeed = Global.Values.WalkSpeed or 52
Global.Values.GeneralWalkSpeed = Global.Values.GeneralWalkSpeed or 16
Global.Values.Queue = Global.Values.Queue or {}
Global.Values.QTitle = Global.Values.QTitle or ""
Global.Dropdowns.QueueDifficulty = Global.Dropdowns.QueueDifficulty or { "Normal" }
Global.Toggles.Blatant = false
Global.BlatantGen = Global.BlatantGen or 0
Global.Toggles.Sprint = nil

local Stats = Global.Stats
Stats.phase = Stats.phase or "idle"
Stats.plot = Stats.plot or nil
Stats.layer = Stats.layer or 0
Stats.layerCount = Stats.layerCount or 0
Stats.layerLeft = Stats.layerLeft or 0
Stats.total = Stats.total or 0
Stats.filled = Stats.filled or 0
Stats.colorsDone = Stats.colorsDone or 0
Stats.coversDone = Stats.coversDone or 0
Stats.baselineFilled = Stats.baselineFilled or 0
Stats.activeSeconds = Stats.activeSeconds or 0

local Labels = {}
local QueueParagraph = nil

--// Engine

--//// Remotes
local LP = Players.LocalPlayer
local Net = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Net")
local builtEvent = Net:WaitForChild("RE/CanvasBuilt")
local fillsEvent = Net:WaitForChild("RE/CanvasFills")
local clearedEvent = Net:WaitForChild("RE/CanvasCleared")
local activeEvent = Net:WaitForChild("RE/ActiveChanged")
local setActiveEvent = Net:WaitForChild("RE/SetActive")
local completedEvent = Net:WaitForChild("RE/Completed")
local requestRemote = Net:WaitForChild("RF/RequestCanvas")
local searchRemote = Net:WaitForChild("RF/Search")
local loadRemote = Net:WaitForChild("RF/LoadCover")
local galleryRemote = Net:WaitForChild("RF/Gallery")

local plots = {}
local loadNextFromQueue

--//// Visual State
local Visuals = {
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
	local name, layer, W, H = stateKeys(state)
	local L, F = state.Layers, state.Filled
	if not name or not layer or not W or not H
		or typeof(L) ~= "buffer" or typeof(F) ~= "buffer" then
		return
	end
	local g = {}
	local rowC = table.create(H, 0)
	local colC = table.create(W, 0)
	local layerTotal = 0
	local count = 0
	local chunk = 0
	for i = 0, (W * H) - 1 do
		if buffer.readu8(L, i) == layer then
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
end

local requestActorScan = nil
local requestActorPlan = nil
local ActorBridge = nil

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

--//// State Helpers
local function on()
	return Global.Toggles.AutoPaint == true
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
	local left = plotState.LayerRemaining and plotState.LayerRemaining[plotState.Layer or 0]
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
	local _, hum = getChar()
	if hum then
		hum.WalkSpeed = math.clamp(Global.Values.WalkSpeed or 26, 16, 52)
	end
end

--//// Remote Mirror
local function ensureMirror()
	if Global.Connections.Mirror then return end
	local conns = {}
	conns[#conns + 1] = builtEvent.OnClientEvent:Connect(function(d)
		if type(d) ~= "table" or type(d.Plot) ~= "string" then return end
		local total = (d.Width or 0) * (d.Height or 0)
		if total <= 0 or typeof(d.Layers) ~= "buffer" or typeof(d.Filled) ~= "buffer" then return end
		plots[d.Plot] = {
			Name = d.Plot, W = d.Width, H = d.Height, Total = total,
			Layer = d.ActiveLayer, Layers = d.Layers, Filled = d.Filled,
			LayerRemaining = d.LayerRemaining, FilledCount = d.FilledCount or 0,
			Active = d.Active == true, part = plotPartOf(d.Plot),
		}
		Stats.lastBuiltAt = os.clock()
		Visuals.OnBuilt(d.Plot)
		if d.Active == true then refreshStatsFrom(plots[d.Plot]) end
	end)
	conns[#conns + 1] = fillsEvent.OnClientEvent:Connect(function(plotName, fillBuf, filledCount, layerRemaining)
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
		if type(layerRemaining) == "table" then s.LayerRemaining = layerRemaining end
		Visuals.OnFills(plotName, fillBuf)
		if s.Active then refreshStatsFrom(s) end
	end)
	conns[#conns + 1] = activeEvent.OnClientEvent:Connect(function(plotName, layer)
		local s = plots[plotName]
		Visuals.OnLayerChanged(plotName)
		if s then
			s.Layer = layer
			if s.Active then refreshStatsFrom(s) end
		end
	end)
	conns[#conns + 1] = clearedEvent.OnClientEvent:Connect(function(plotName)
		Visuals.OnCleared(plotName)
		if plots[plotName] then
			plots[plotName] = nil
			if Stats.plot == plotName then
				Stats.plot = nil
				setPhase("waiting for cover")
			end
		end
	end)
	conns[#conns + 1] = completedEvent.OnClientEvent:Connect(function(d)
		Stats.coversDone += 1
		if Global.Gallery then Global.Gallery.fetchedAt = 0 end
		setPhase("cover finished")
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
	pcall(function() requestRemote:InvokeServer() end)
end)

--//// Canvas Geometry
local okPasses, Passes = pcall(require, ReplicatedStorage.Client.Systems.Passes)

local function brushRadiusCells()
	local scale = 1
	if okPasses and Passes and type(Passes.GetBrushScale) == "function" then
		local ok, s = pcall(Passes.GetBrushScale, Passes)
		if ok and type(s) == "number" and s >= 1 then scale = s end
	end
	return brushStuds * scale / pixelSize
end

local function cellToWorld(s, x, y)
	local p = s.part
	return Vector3.new(
		p.Position.X - p.Size.X * 0.5 + (x + 0.5) * pixelSize,
		p.Position.Y + p.Size.Y * 0.5,
		p.Position.Z - p.Size.Z * 0.5 + (y + 0.5) * pixelSize
	)
end

local function worldToCell(s, pos)
	local p = s.part
	return (pos.X - (p.Position.X - p.Size.X * 0.5)) / pixelSize,
	       (pos.Z - (p.Position.Z - p.Size.Z * 0.5)) / pixelSize
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
	return s.LayerRemaining[layer]
end

local function allLayersDone(s)
	if type(s.LayerRemaining) ~= "table" or #s.LayerRemaining == 0 then return false end
	for i = 1, #s.LayerRemaining do
		local v = s.LayerRemaining[i]
		if type(v) ~= "number" or v > 0 then return false end
	end
	return true
end

local function nextLayerWithRemaining(s, from)
	if type(s.LayerRemaining) ~= "table" then return nil end
	for i = from + 1, #s.LayerRemaining do
		local v = s.LayerRemaining[i]
		if type(v) == "number" and v > 0 then return i end
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

local function bandCenters(a0, b0, brushR)
	local centers = {}
	if b0 - a0 + 1 <= 2 * brushR then
		centers[1] = math.floor((a0 + b0) / 2)
		return centers
	end
	local yc = a0 + brushR
	while yc - brushR <= b0 do
		centers[#centers + 1] = yc
		yc += 2 * brushR
	end
	centers[#centers] = b0 - brushR
	return centers
end

local function orderTour(points, startCx, startCy, cfg, yield)
	local n = #points
	local used = table.create(n, false)
	local tour = {}
	local cx, cy = startCx, startCy
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
	end
	local passes = cfg.twoOptPasses or 2
	if n >= 4 and n <= (cfg.twoOptMax or 400) then
		local function d2(a, b)
			local dx, dy = a.x - b.x, a.y - b.y
			return dx * dx + dy * dy
		end
		local start = { x = startCx, y = startCy }
		local maxPasses = (n < 300 and passes) or (n < 750 and math.ceil(passes / 2)) or 2
		local improved, round = true, 0
		while improved and round < maxPasses do
			improved = false
			round += 1
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
				if yield and n > 300 and i % 100 == 0 then
					yield()
				end
			end
		end
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

local function planFromCells(cells, W, H, cfg, yield)
	if #cells == 0 then return {} end
	local brushR = cfg.brushR
	local claimR = math.max(0, brushR - 1)
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
	if #leftover > 0 then
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
	return fragments
end
]==]

local planner = loadstring(plannerChunk
	.. "\nreturn { planFromCells = planFromCells, orderTour = orderTour, groupCells = groupCells }")()

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
		twoOptMax = twoOptMax,
		twoOptPasses = 8,
	}, makeYield())
end

local function groupCells(s, cells, radius)
	return planner.groupCells(cells, s.W, s.H, radius)
end

local function mergeRuns(tour)
	local segments = {}
	local n = #tour
	local i = 1
	while i <= n do
		local j = i
		local axis = nil
		while j < n do
			local dx = tour[j + 1].x - tour[j].x
			local dy = tour[j + 1].y - tour[j].y
			local a = (dy == 0 and "x") or (dx == 0 and "y") or nil
			if not a or (axis and a ~= axis) then break end
			axis = axis or a
			j += 1
		end
		segments[#segments + 1] = { i0 = i, i1 = j }
		i = j + 1
	end
	return segments
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

local function buildFragments(cur, radius, brushR, scx, scy)
	local cells = {}
	for idx in pairs(Visuals.green) do
		cells[#cells + 1] = idx - 1
	end
	if #cells == 0 then return {} end
	return planner.planFromCells(cells, cur.W, cur.H, {
		radius = radius,
		brushR = brushR,
		scx = scx,
		scy = scy,
		speed = math.max(16, Global.Values.WalkSpeed or 52),
		pixel = pixelSize,
		bandDense = bandDenseFrac,
		bandMinRows = bandMinRows,
		bandMinCount = bandMinCount,
		bandMinRowCount = bandMinRowCount,
		bandTurn = bandTurnTime,
		twoOptMax = twoOptMax,
		twoOptPasses = 8,
	}, makeYield())
end

local function greensInBox(s, x0, y0, x1, y1, margin)
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
			if buffer.readu8(s.Filled, idx - 1) ~= 1
				and buffer.readu8(s.Layers, idx - 1) == s.Layer then
				cells[#cells + 1] = { x = x, y = y }
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
local function segmentGreen(cur, tour, seg, brushR)
	local i0, i1 = seg.i0, seg.i1
	local span = i1 - i0
	local step = math.max(1, brushR)
	if span > step * 40 then
		step = math.ceil(span / 40)
	end
	for i = i0, i1, step do
		local p = tour[i]
		if greenAround(cur, p.x, p.y, brushR) > 0 then
			return true
		end
	end
	local p = tour[i1]
	return greenAround(cur, p.x, p.y, brushR) > 0
end

local function streamCellTour(s, tour, passDist)
	local layer = s.Layer
	local brushR = brushRadiusCells()
	local lastCheck = os.clock()
	local _, _, root0 = getChar()
	local lastPos = root0 and root0.Position or Vector3.zero
	local visited = 0
	local myGen = Global.BlatantGen or 0
	for _, seg in ipairs(mergeRuns(tour)) do
		if not on() then return visited end
		if (Global.BlatantGen or 0) ~= myGen then return visited, true end
		local cur = plots[s.Name]
		if not cur or cur.Layer ~= layer then break end
		if segmentGreen(cur, tour, seg, brushR) then
			visited += seg.i1 - seg.i0 + 1
			local target = cellToWorld(cur, tour[seg.i1].x, tour[seg.i1].y)
			local _, _, rootAt = getChar()
			local dist = rootAt and ((target - rootAt.Position) * flatMask).Magnitude or 0
			local timeout = 4 + dist / 14
			local t0 = os.clock()
			while on() do
				if (Global.BlatantGen or 0) ~= myGen then return visited, true end
				local _, h, root = getChar()
				if not h or not root then return visited end
				if ((root.Position - target) * flatMask).Magnitude <= passDist then break end
				h:MoveTo(target)
				if os.clock() - t0 > timeout then break end
				if os.clock() - lastCheck >= 1.2 then
					if ((root.Position - lastPos) * flatMask).Magnitude < 0.5 then
						h.Jump = true
					end
					lastPos = root.Position
					lastCheck = os.clock()
				end
				task.wait(0.1)
			end
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
	if h0 and r0 then pcall(function() h0:MoveTo(r0.Position) end) end
	for _, seg in ipairs(mergeRuns(tour)) do
		if not on() then return visited end
		if (Global.BlatantGen or 0) ~= myGen then return visited, true end
		local cur = plots[s.Name]
		if not cur or cur.Layer ~= layer then break end
		if segmentGreen(cur, tour, seg, brushR) then
			visited += seg.i1 - seg.i0 + 1
			local pos = cellToWorld(cur, tour[seg.i0].x, tour[seg.i0].y)
			local target = cellToWorld(cur, tour[seg.i1].x, tour[seg.i1].y)
			local _, _, root = getChar()
			if not root then return visited end
			if ((root.Position - pos) * flatMask).Magnitude > jumpDist then
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
			end
			local dist = ((target - root.Position) * flatMask).Magnitude
			local timeout = 4 + dist / 14
			local t0 = os.clock()
			while on() do
				if (Global.BlatantGen or 0) ~= myGen then return visited, true end
				local _, h2, root2 = getChar()
				if not h2 or not root2 then return visited end
				if ((root2.Position - target) * flatMask).Magnitude <= 2.0 then break end
				h2:MoveTo(target)
				if os.clock() - t0 > timeout then break end
				task.wait(0.1)
			end
		end
	end
	return visited
end

local function executeTour(s, tour, passDist, dwell)
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

--//// Paint Pass
local function paintLayer(s)
	local layer = s.Layer
	local brushR = brushRadiusCells()
	local blatant = Global.Toggles.Blatant == true
	local lastCount = math.huge
	local stalls = 0
	local forcedRescan = false
	for round = 1, maxRounds do
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
			return
		end
		forcedRescan = false

		local radius = (round == 1) and brushR * 0.85 or brushR * 0.7
		local scx, scy = charCell(cur)
		local okFrags, fragments = true, nil
		local actorPlanned = false
		if requestActorPlan then
			fragments = requestActorPlan(cur, radius, brushR, scx, scy)
			actorPlanned = fragments ~= nil
		end
		if not fragments then
			okFrags, fragments = pcall(buildFragments, cur, radius, brushR, scx, scy)
			if not okFrags or not fragments or #fragments == 0 then
				if not okFrags then
					warn("[Volaris] fragment planning failed: " .. tostring(fragments))
				end
				local cells = cellsFromSet(Visuals.green, cur.W)
				fragments = { {
					kind = "tour",
					stops = orderTour(groupCells(cur, cells, radius), scx, scy),
					covered = #cells,
				} }
			end
		end
		setPhase(((round == 1)
				and ((blatant and "teleporting" or "sweeping") .. (" Colour %d (%d studs, %s)"):format(layer, n, fragSummary(fragments)))
				or ("verifying Colour %d, round %d, %d left"):format(layer, round - 1, n))
			.. (actorPlanned and " · parallel" or ""))
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
		local passDist = round == 1 and 1.5 or 0.9
		local dwell = round == 1 and 0.12 or 0.3
		while #fragments > 0 do
			if not on() then return end
			local cur2 = plots[s.Name]
			if not cur2 or cur2.Layer ~= layer then return end
			local ccx, ccy = charCell(cur2)
			local bestI, bestD = nil, math.huge
			for i, frag in ipairs(fragments) do
				local b = frag.bbox
				local dx = math.max(b[1] - ccx, 0, ccx - b[3])
				local dy = math.max(b[2] - ccy, 0, ccy - b[4])
				local d = dx * dx + dy * dy
				if d < bestD then
					bestD = d
					bestI = i
				end
			end
			local frag = table.remove(fragments, bestI)
			local stops = frag.stops
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
			else
				stops = orderTour(stops, ccx, ccy)
			end
			executeTour(cur2, stops, passDist, dwell)

			local bx0, by0, bx1, by1 = frag.bbox[1], frag.bbox[2], frag.bbox[3], frag.bbox[4]
			for sweep = 1, 5 do
				if not on() then return end
				local cur3 = plots[s.Name]
				if not cur3 or cur3.Layer ~= layer then return end
				local cells = greensInBox(cur3, bx0, by0, bx1, by1, brushR + 2)
				if #cells == 0 then break end
				if sweep == 1 then
					task.wait(0.25)
				end
				local sr = radius * (1 - 0.12 * (sweep - 1))
				local ncx, ncy = charCell(cur3)
				executeTour(cur3, orderTour(groupCells(cur3, cells, sr), ncx, ncy), passDist, dwell)
			end
		end

		if not on() then return end
		if n >= lastCount then
			stalls += 1
			if stalls >= stallLimit then
				warn(("[Volaris] Colour %d not clearing (%d left); moving on"):format(layer, n))
				return
			end
			task.wait(0.3)
		else
			stalls = 0
		end
		lastCount = n
	end
end

local function advanceLayer(s, doneLayer)
	setPhase("advancing to next Colour")
	local centroid = nextLayerCentroid(s, doneLayer)
	local waited = 0
	while on() and plots[s.Name] and plots[s.Name].Layer == doneLayer and waited < 2.0 do
		local _, h, root = getChar()
		if h and root and centroid then
			if Global.Toggles.Blatant then
				if ((root.Position - centroid) * flatMask).Magnitude > 8 then
					root.CFrame = CFrame.new(centroid + Vector3.new(0, 2, 0))
				end
			elseif ((root.Position - centroid) * flatMask).Magnitude > 2 then
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
		setActiveEvent:FireServer(nextL)
		waited = 0
		while on() and plots[s.Name] and plots[s.Name].Layer == doneLayer and waited < 2 do
			task.wait(0.2)
			waited += 0.2
		end
	end
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
		return galleryRemote:InvokeServer({ Action = "List", IncludeDraft = true })
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
local function queueNotify(title, content)
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

local function refreshQueueDisplay()
	if not QueueParagraph then return end
	local q = Global.Values.Queue
	if #q == 0 then
		pcall(function()
			QueueParagraph:Set({Content = "(empty! queued covers load automatically when the current one finishes)"})
		end)
		return
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
			lines[#lines + 1] = ("%d-%d. %s Vols. %g-%g%s — %s"):format(
				i, runEnd, base, vol, runVol,
				langTag and (" (%s)"):format(langTag) or "",
				tostring(q[i].Difficulty))
		else
			lines[#lines + 1] = ("%d. %s — %s"):format(i,
				tostring(q[i].Title), tostring(q[i].Difficulty))
		end
		i = runEnd + 1
	end
	pcall(function()
		QueueParagraph:Set({Content = table.concat(lines, "\n")})
	end)
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

local function collectVolumes(series, lang)
	local perSeries, seriesOrder = {}, {}
	local page = 1
	while page <= 10 do
		local ok, res = pcall(function()
			return searchRemote:InvokeServer({ Query = series, Page = page })
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
			return searchRemote:InvokeServer({ Query = query, Page = page })
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
	local diff = difficulty or "Normal"
	local prior = fetchGallery()[item.CoverUrl .. "\0" .. diff]
	if prior and not prior.InProgress then
		local times = tonumber(prior.Count) or 1
		queueNotify("Queue", ("\"%s\" is already in your gallery (%s).")
			:format(item.Title, times > 1 and ("painted %d times"):format(times) or "completed"))
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
		CoverUrl = item.CoverUrl,
		ThumbUrl = item.ThumbUrl,
		Difficulty = diff,
	})
	refreshQueueDisplay()
	queueNotify("Queue", ("Queued \"%s\" (%s)."):format(item.Title, diff))
	return true
end

Global.QueueAdd = queueAdd

--//// Session Persistence
local Session = { fsOk = nil }
local sessionDir = "VolarisHub"
local sessionFile = sessionDir .. "/session.json"

local function filesystemWorks()
	if Session.fsOk ~= nil then return Session.fsOk end
	Session.fsOk = false
	if type(makefolder) == "function" and type(writefile) == "function"
		and type(readfile) == "function" then
		pcall(function()
			makefolder(sessionDir)
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

local function sessionSave()
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

local function sessionRestore()
	if not filesystemWorks() then return end
	local ok, raw = pcall(readfile, sessionFile)
	if not ok or type(raw) ~= "string" then return end
	if type(delfile) == "function" then
		pcall(delfile, sessionFile)
	end
	local decoded
	pcall(function()
		decoded = game:GetService("HttpService"):JSONDecode(raw)
	end)
	if type(decoded) ~= "table" or type(decoded.time) ~= "number"
		or os.time() - decoded.time > 600 then
		return
	end
	if type(decoded.queue) == "table" then
		for _, entry in ipairs(decoded.queue) do
			if type(entry) == "table" and type(entry.CoverUrl) == "string" then
				table.insert(Global.Values.Queue, entry)
			end
		end
	end
	if decoded.resume == true then
		Global.Start()
	end
	pcall(refreshQueueDisplay)
end

--//// Auto Load
local queueLoadLock = 0

loadNextFromQueue = function()
	if os.clock() < queueLoadLock then return end
	queueLoadLock = os.clock() + 6
	local q = Global.Values.Queue
	if #q == 0 then return end
	local entry = table.remove(q, 1)
	refreshQueueDisplay()
	setPhase(("loading next cover: %s"):format(entry.Title))
	local requestedAt = os.clock()
	local ok, res = pcall(function()
		return loadRemote:InvokeServer({
			CoverUrl = entry.CoverUrl,
			ThumbUrl = entry.ThumbUrl,
			Title = entry.Title,
			Difficulty = entry.Difficulty,
		})
	end)
	if not ok then
		warn("[Volaris] queue: load failed: " .. tostring(res))
		queueNotify("Queue", ("Failed to load \"%s\" — skipped."):format(entry.Title))
	elseif type(res) == "table" and res.Ok == false then
		warn("[Volaris] queue: load refused: " .. tostring(res.Error))
		queueNotify("Queue", ("Server refused \"%s\" (%s) — skipped.")
			:format(entry.Title, tostring(res.Error)))
	end
	task.delay(8, function()
		if not Global.Alive or not Global.Toggles.AutoPaint then return end
		if Stats.lastBuiltAt and Stats.lastBuiltAt > requestedAt then return end
		if activePlot() then return end
		if #Global.Values.Queue == 0 then return end
		queueNotify("Queue", "Previous cover didn't load. trying the next.")
		loadNextFromQueue()
	end)
end

--// Features
local function fmtDuration(sec)
	sec = math.max(0, math.floor(sec))
	if sec < 60 then return sec .. "s" end
	if sec < 3600 then return ("%dm %02ds"):format(sec // 60, sec % 60) end
	return ("%dh %02dm"):format(sec // 3600, (sec % 3600) // 60)
end

local Features = {}

--//// Auto Paint
Features.AutoPaint = function()
	if Global.Running.AutoPaint then return end
	Global.Running.AutoPaint = true

	local ok, err = pcall(function()
		pcall(function() requestRemote:InvokeServer() end)

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
					setActiveEvent:FireServer(firstL)
				end
				task.wait(1)
				continue
			end

			if allLayersDone(s) then
				setPhase("cover finished! load another one")
				if #Global.Values.Queue > 0 then
					loadNextFromQueue()
				end
				task.wait(2)
				continue
			end

			paintLayer(s)

			local cur = plots[s.Name]
			if on() and cur and not allLayersDone(cur)
				and layerRemainingOf(cur, cur.Layer) == 0 then
				advanceLayer(cur, cur.Layer)
			end

			task.wait(0.2)
		end
	end)

	local _, hum, root = getChar()
	if hum and root then pcall(function() hum:MoveTo(root.Position) end) end
	pcall(function() if hum then hum.WalkSpeed = 16 end end)
	setPhase(Global.Alive and "paused" or "stopped")

	if not ok then
		warn("[Volaris] engine error: " .. tostring(err))
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
	Global.Running.AutoPaint = false
end

--//// Statistics
Features.StatLoop = function()
	if Global.Running.StatLoop then return end
	Global.Running.StatLoop = true

	local samples = {}
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

		pcall(function()
			if Labels.Phase then Labels.Phase:Set({Name = "Status: " .. tostring(Stats.phase)}) end
			if Labels.Color then
				Labels.Color:Set({Name = ("Colour: %d / %d  (%d done)")
					:format(Stats.layer, Stats.layerCount, Stats.colorsDone)})
			end
			if Labels.Left then
				Labels.Left:Set({Name = ("In Colour: %d studs | Cover left: %d")
					:format(Stats.layerLeft, coverLeft)})
			end
			if Labels.Overall then
				Labels.Overall:Set({Name = ("Overall: %.1f%%  (%d / %d studs)")
					:format(pct, Stats.filled, Stats.total)})
			end
			if Labels.Speed then
				Labels.Speed:Set({Name = ("Speed: %s")
					:format(ratePerMin > 0 and (("%.0f studs/min"):format(ratePerMin)) or "--")})
			end
			if Labels.Eta then
				Labels.Eta:Set({Name = ("ETA: Colour %s | cover %s")
					:format(layerEta and fmtDuration(layerEta) or "--",
						coverEta and fmtDuration(coverEta) or "--")})
			end
			if Labels.Session then
				Labels.Session:Set({Name = ("Session: %s active | Covers finished: %d")
					:format(fmtDuration(Stats.activeSeconds), Stats.coversDone)})
			end
		end)
		task.wait(0.25)
	end
	Global.Running.StatLoop = false
end

--//// General Speed
Features.GeneralSpeed = function()
	if Global.Running.GeneralSpeed then return end
	Global.Running.GeneralSpeed = true

	while Global.Toggles.GeneralSpeed do
		if not Global.Toggles.AutoPaint then
			local _, hum = getChar()
			if hum then
				hum.WalkSpeed = math.clamp(Global.Values.GeneralWalkSpeed or 16, 16, 52)
			end
		end
		task.wait(0.25)
	end

	local _, hum = getChar()
	if hum and not Global.Toggles.AutoPaint then
		hum.WalkSpeed = 16
	end
	Global.Running.GeneralSpeed = false
end

--//// Anti AFK
Features.AntiAFK = function()
	if Global.Running.AntiAFK then return end
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
		while Global.Toggles.AntiAFK do
			task.wait(0.5)
		end
		Global.Running.AntiAFK = false
	end)
end

--//// Staff Hop
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
		return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(placeId))
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

local function hopAway(reason)
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
			pcall(queueTp, "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/flyrbo/Volaris/refs/heads/main/Loader.lua\"))()")
		end
		local okTeleport, err = pcall(function()
			game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, jobId, LP)
		end)
		if not okTeleport then
			warn("[Volaris] server hop: teleport failed: " .. tostring(err))
			setPhase("hop failed — teleport error")
		end
	else
		setPhase("hop failed. no server picked")
	end
	hopBusy = false
end

Features.StaffHop = function()
	if Global.Running.StaffHop then return end
	Global.Running.StaffHop = true

	local function check(player)
		if player == LP or not Global.Toggles.StaffHop then return end
		task.spawn(function()
			local role = roleInStaffGroup(player)
			if not (Global.Toggles.StaffHop and role) then return end
			if staffRoleNames[role:lower()] then
				hopAway(("%s — %s"):format(player.Name, role))
			end
		end)
	end

	for _, player in ipairs(Players:GetPlayers()) do
		check(player)
	end
	Global.Connections.StaffHop = Players.PlayerAdded:Connect(check)

	task.spawn(function()
		while Global.Toggles.StaffHop do
			task.wait(0.5)
		end
		local conn = Global.Connections.StaffHop
		if conn then
			pcall(function() conn:Disconnect() end)
			Global.Connections.StaffHop = nil
		end
		Global.Running.StaffHop = false
	end)
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
	local hook = {
		module = CanvasRender,
		flush = CanvasRender.Flush,
		sweep = CanvasRender.Sweep,
		lastFlush = 0,
		lastSweep = 0,
	}
	CanvasRender.Flush = function(self, ...)
		local now = os.clock()
		if now - hook.lastFlush >= 0.1 then
			hook.lastFlush = now
			return hook.flush(self, ...)
		end
	end
	CanvasRender.Sweep = function(self, ...)
		local now = os.clock()
		if now - hook.lastSweep >= 0.25 then
			hook.lastSweep = now
			return hook.sweep(self, ...)
		end
	end
	Global.Connections.CanvasFix = hook
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
			local okF, frags = pcall(planFromCells, job.cells, job.w, job.h, job.cfg, nil)
			if okF and type(frags) == "table" then
				out.fragments = frags
			else
				out.error = tostring(frags):sub(1, 160)
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
			actor = list[1]
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

requestActorPlan = function(cur, radius, brushR, scx, scy)
	if not actorAvailable() then return nil end
	local now = os.clock()
	if ActorBridge.planBroken and now - ActorBridge.planBrokenAt < 30 then
		return nil
	end
	if ActorBridge.planPendingSeq then
		local deadline = ActorBridge.planPendingAt + 5
		while ActorBridge.planPendingSeq and os.clock() < deadline do
			task.wait(0.05)
		end
		return ActorBridge.planResult
	end
	local cells = {}
	for idx in pairs(Visuals.green) do
		cells[#cells + 1] = idx - 1
	end
	if #cells == 0 then return nil end
	ActorBridge.planError = nil
	ActorBridge.seq += 1
	ActorBridge.planPendingSeq = ActorBridge.seq
	ActorBridge.planPendingAt = now
	ActorBridge.planResult = nil
	pcall(function()
		ActorBridge.chan:Fire({
			cmd = "plan",
			seq = ActorBridge.seq,
			w = cur.W,
			h = cur.H,
			cells = cells,
			cfg = {
				radius = radius,
				brushR = brushR,
				scx = scx,
				scy = scy,
				speed = math.max(16, Global.Values.WalkSpeed or 52),
				pixel = pixelSize,
				bandDense = bandDenseFrac,
				bandMinRows = bandMinRows,
				bandMinCount = bandMinCount,
				bandMinRowCount = bandMinRowCount,
				bandTurn = bandTurnTime,
				twoOptMax = 400,
				twoOptPasses = 2,
			},
		})
	end)
	local t0 = os.clock()
	while ActorBridge.planPendingSeq and os.clock() - t0 < 1.5 do
		task.wait(0.05)
	end
	if ActorBridge.planPendingSeq then
		ActorBridge.planPendingSeq = nil
		ActorBridge.planBroken = true
		ActorBridge.planBrokenAt = os.clock()
		return nil
	end
	return ActorBridge.planResult
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
			pcall(function() requestRemote:InvokeServer() end)
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
		return { frac = math.clamp(tonumber(pct) / 100, 0, 1) }
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
Features.RainbowStuds = function()
	if Global.Running.RainbowStuds then return end
	Global.Running.RainbowStuds = true
	Visuals.attach()

	while Global.Toggles.RainbowStuds do
		local state = ensureCapture()
		if state then
			Visuals.greensFor(state)
			if Visuals.greenCount > 0 then
				local r, g, b = hueRGB(0)
				local L, F = state.Layers, state.Filled
				local Pixels = state.Pixels
				local W, H = state.Width, state.Height
				local layer = state.ActiveLayer
				for idx in pairs(Visuals.green) do
					local i = idx - 1
					if buffer.readu8(F, i) ~= 1 and buffer.readu8(L, i) == layer then
						local off = ((i % W) * H + (H - 1 - (i // W))) * 4
						buffer.writeu8(Pixels, off, r)
						buffer.writeu8(Pixels, off + 1, g)
						buffer.writeu8(Pixels, off + 2, b)
						buffer.writeu8(Pixels, off + 3, 255)
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
	Global.Running.RainbowStuds = false
end

--//// Stud Pillars
Features.Pillars = function()
	if Global.Running.Pillars then return end
	Global.Running.Pillars = true
	Visuals.attach()

	local folder = Instance.new("Folder")
	folder.Name = "VolarisPillars"
	folder.Parent = workspace
	local pool = {}

	while Global.Toggles.Pillars do
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
				p.Size = Vector3.new(pixelSize, pillarHeight, pixelSize)
				pool[i] = p
			end
			if p.Parent ~= folder then p.Parent = folder end
			p.Color = color
			local idx = targets[i]
			local x = (idx - 1) % state.Width
			local z = (idx - 1) // state.Width
			p.CFrame = CFrame.new(
				minX + (x + 0.5) * pixelSize,
				topY + pillarHeight * 0.5,
				minZ + (z + 0.5) * pixelSize
			)
		end
		for i = k + 1, #pool do
			if pool[i].Parent then pool[i].Parent = nil end
		end

		task.wait(0.5)
	end

	folder:Destroy()
	Global.Running.Pillars = false
end

--//// Arrow Pointer
local function findNearestCell(state)
	local _, _, root = getChar()
	if not root then return nil end
	local minX, minZ = plotSurfaceOf(state)
	if not minX then return nil end
	local W, H = state.Width, state.Height
	local cx = math.floor((root.Position.X - minX) / pixelSize)
	local cz = math.floor((root.Position.Z - minZ) / pixelSize)
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
	for idx in pairs(Visuals.green) do
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
		local tx = minX + (t.x + 0.5) * pixelSize
		local tz = minZ + (t.z + 0.5) * pixelSize
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

--//// Tracers
local tracerCap = 250

Features.Tracers = function()
	if Global.Running.Tracers then return end
	Global.Running.Tracers = true
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
					minX + (x + 0.5) * pixelSize,
					topY,
					minZ + (z + 0.5) * pixelSize
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

	while Global.Toggles.Tracers do
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
	Global.Running.Tracers = false
end

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

local function shutdown()
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

local function unload()
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

--// Interface

--//// Window
Starlight:SetTheme("Orca")

local Window = Starlight:CreateWindow({
	Name = "Volaris Hub",
	Subtitle = "Paint a Manga!",
	Icon = NebulaIcons:GetIcon("brush", "Material"),
	LoadingEnabled = true,
	LoadingSettings = { Title = "Volaris Hub", Subtitle = "loading engine..." },
	FileSettings = {
		RootFolder = "VolarisHub",
		ConfigFolder = "Paint a Manga",
		ThemesInRoot = true,
	},
})

Starlight:OnDestroy(function()
	shutdown()
end)

--//// Home Tab
Window:CreateHomeTab({
	SupportedExecutors = {},
	UnsupportedExecutors = {},
	Changelog = {
		{
			Title = "v1.0.0: Release!!!",
			Date = "31st August 2026",
			Description = "After so long its finally out. Not sure what else to add here tho."
		}
	},
})

--//// Painter Tab
local Main = Window:CreateTabSection("Main")

local PainterTab = Main:CreateTab({
	Name = "Painter",
	Icon = NebulaIcons:GetIcon("brush", "Material"),
	Columns = 2,
}, "PM_TAB_PAINTER")

local ControlBox = PainterTab:CreateGroupbox({ Name = "Auto Paint", Column = 1 }, "PM_BOX_CONTROL")
local AutoPaintToggle = ControlBox:CreateToggle({
	Name = "Auto Paint",
	Tooltip = "Walks to every green stud of every Colour until the cover is done.",
	CurrentValue = false,
	Style = 2,
	IgnoreConfig = true,
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
task.delay(1, function()
	pcall(function()
		local inst = AutoPaintToggle.Instance
		if inst and not inst:FindFirstChild("Header") then
			local header = Instance.new("Frame")
			header.Name = "Header"
			header.Size = UDim2.fromOffset(0, 20)
			header.BackgroundTransparency = 1
			header.Parent = inst
		end
	end)
end)

local MoveBox = PainterTab:CreateGroupbox({ Name = "Movement", Column = 1 }, "PM_BOX_MOVE")
MoveBox:CreateSlider({
	Name = "WalkSpeed",
	Tooltip = "Character walkspeed while painting.",
	Range = { 16, 52 },
	Increment = 1,
	Suffix = "",
	CurrentValue = Global.Values.WalkSpeed,
	Callback = function(value)
		Global.Values.WalkSpeed = value
		if Global.Toggles.AutoPaint then applyWalkSpeed() end
	end,
}, "PM_SLIDER_WALKSPEED")

local BlatantBox = PainterTab:CreateGroupbox({ Name = "Blatant", Column = 1 }, "PM_BOX_BLATANT")
local BlatantToggle = BlatantBox:CreateToggle({
	Name = "Blatant Mode (adaptive teleport)",
	Tooltip = "USE AT YOUR OWN RISK. Teleports between stud clusters instead of walking. "
		.. "The server accepts it today, but it is obvious to anyone watching and "
		.. "far more likely to be flagged if the game ever adds position validation.",
	CurrentValue = false,
	Style = 1,
	IgnoreConfig = true,
	Callback = function(value)
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

local StatsBox = PainterTab:CreateGroupbox({
	Name = "Statistics",
	Icon = NebulaIcons:GetIcon("insights", "Material"),
	Column = 2,
}, "PM_BOX_STATS")
Labels.Phase = StatsBox:CreateLabel({ Name = "Status: idle" }, "PM_LBL_PHASE")
Labels.Color = StatsBox:CreateLabel({ Name = "Colour: —" }, "PM_LBL_COLOR")
Labels.Left = StatsBox:CreateLabel({ Name = "In Colour: —" }, "PM_LBL_LEFT")
Labels.Overall = StatsBox:CreateLabel({ Name = "Overall: —" }, "PM_LBL_OVERALL")
Labels.Speed = StatsBox:CreateLabel({ Name = "Speed: —" }, "PM_LBL_SPEED")
Labels.Eta = StatsBox:CreateLabel({ Name = "ETA: —" }, "PM_LBL_ETA")
Labels.Session = StatsBox:CreateLabel({ Name = "Session: —" }, "PM_LBL_SESSION")

--//// Queue Tab
local QueueTab = Main:CreateTab({
	Name = "Queue",
	Icon = NebulaIcons:GetIcon("playlist_play", "Material"),
	Columns = 2,
}, "PM_TAB_QUEUE")

local AboutBox = QueueTab:CreateGroupbox({ Name = "How Queueing Works", Column = 1 }, "PM_BOX_QHOW")
AboutBox:CreateParagraph({
	Name = "Input format",
	Content = "Type in a manga name into the input field, select a difficulty and click one of the add buttons.\n"
		.. "to input a specific volume, type the series name then \"vol N\` or \`vol. N\` or \`volume N\` where N is the volume number.\n"
		.. "to add a specific translation, type the series name then a language code or name in brackets, e.g. \`[en]\` or \`english\`.\n\n"
		.. "should look like this: \`frieren vol 2 [en]\` or \`frieren vol. 2 english\`."
	-- Content = "Titles are MangaDex series names — the same search the game's "
	-- 	.. "own Search screen uses, so anything that works in-game (or on "
	-- 	.. "mangadex.org) works here.\n"
	-- 	.. "The Add Cover box below holds the title input, the difficulty "
	-- 	.. "dropdown and both add buttons — typing never adds anything by "
	-- 	.. "itself.\n"
	-- 	.. "• \"frieren\" queues the first result; \"frieren vol 2\" queues "
	-- 	.. "exactly Vol. 2. The notification always shows the exact pick.\n"
	-- 	.. "• Add a language after the name — \"frieren en\", \"frieren [en]\" "
	-- 	.. "or \"frieren english\" — to queue that translation. With no "
	-- 	.. "language, whichever translation has the most volumes available "
	-- 	.. "is picked automatically — the confirmation shows which won.\n"
	-- 	.. "• \"Add All Volumes\" ignores any volume typed in the input: it "
	-- 	.. "searches every volume of the series and queues them in "
	-- 	.. "numerical order after a confirmation pop-up, skipping volumes "
	-- 	.. "already painted or queued.\n"
	-- 	.. "• Covers already in your gallery are rejected automatically; "
	-- 	.. "in-progress drafts are allowed.",
}, "PM_PARA_QHOW")

local AddBox = QueueTab:CreateGroupbox({ Name = "Add Cover", Column = 1 }, "PM_BOX_QADD")
local TitleInput = AddBox:CreateInput({
	Name = "Title",
	Tooltip = "Add any manga series name available in the game.\n"
		.. "Add \"vol 2\" for a specific volume.\n"
		.. "Add a language (\"en\", \"[en]\" or \"english\") for a specific translation.",
	PlaceholderText = "e.g. frieren, frieren vol 2, frieren en",
	CurrentValue = Global.Values.QTitle,
	RemoveTextAfterFocusLost = false,
	MaxCharacters = 80,
	Callback = function(text)
		Global.Values.QTitle = text
	end,
}, "PM_INPUT_QTITLE")

local DiffLabel = AddBox:CreateLabel({ Name = "Difficulty" }, "PM_LBL_QDIFF")
DiffLabel:AddDropdown({
	Options = { "Easy", "Normal", "Hard", "Extreme", "Insane" },
	CurrentOptions = Global.Dropdowns.QueueDifficulty,
	Callback = function(options)
		Global.Dropdowns.QueueDifficulty = options
	end,
}, "PM_DD_QDIFF")

local function queueAddAll(query, difficulty)
	query = tostring(query or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if query == "" then
		queueNotify("Queue", "Type a series name first.")
		return false
	end
	local series, _volNum, lang = parseQuery(query)
	if series == "" then
		queueNotify("Queue", "Type a series name first.")
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
	local fresh, skippedPainted, skippedQueued = {}, 0, 0
	for _, v in ipairs(list) do
		local r = v.result
		local prior = gallery[r.CoverUrl .. "\0" .. diff]
		if prior and not prior.InProgress then
			skippedPainted += 1
		elseif queued[r.CoverUrl] then
			skippedQueued += 1
		else
			fresh[#fresh + 1] = r
		end
	end
	if #fresh == 0 then
		queueNotify("Queue", ("Every volume of \"%s\" is already queued or painted (%s).")
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
				.. "Skipped automatically: %d painted, %d already queued%s.\n"
				.. "They load one after another automatically.")
				:format(#fresh, plural, series, langTag, diff,
					skippedPainted, skippedQueued,
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

AddBox:CreateButton({
	Name = "Add to Queue",
	Tooltip = "Searches the stored title and queues the pick.",
	IndicatorStyle = 1,
	Callback = function()
		local query = Global.Values.QTitle
			or (TitleInput.Values and TitleInput.Values.CurrentValue) or ""
		local diff = Global.Dropdowns.QueueDifficulty[1] or "Normal"
		queueAdd(query, diff)
	end,
}, "PM_BTN_QADD")

AddBox:CreateButton({
	Name = "Add All Volumes",
	Tooltip = "Searches every volume of the title and adds to the queue.\n"
		.. "Any \"vol N\" in the input is ignored.\n"
		.. "Volumes already painted or queued are skipped.",
	IndicatorStyle = 1,
	Callback = function()
		local query = Global.Values.QTitle
			or (TitleInput.Values and TitleInput.Values.CurrentValue) or ""
		local diff = Global.Dropdowns.QueueDifficulty[1] or "Normal"
		queueAddAll(query, diff)
	end,
}, "PM_BTN_QADDALL")

local QueueBox = QueueTab:CreateGroupbox({ Name = "Queue", Column = 2 }, "PM_BOX_QUEUE")
QueueParagraph = QueueBox:CreateParagraph({
	Name = "Up Next",
	Content = "(empty! queued covers load automatically when the current one finishes)",
}, "PM_PARA_QUEUE")
QueueBox:CreateButton({
	Name = "Remove Last",
	IndicatorStyle = 1,
	Callback = function()
		if #Global.Values.Queue > 0 then
			table.remove(Global.Values.Queue)
			refreshQueueDisplay()
		end
	end,
}, "PM_BTN_QPOP")
QueueBox:CreateButton({
	Name = "Clear Queue",
	IndicatorStyle = 1,
	Callback = function()
		table.clear(Global.Values.Queue)
		refreshQueueDisplay()
	end,
}, "PM_BTN_QCLEAR")
refreshQueueDisplay()

--//// Misc Tab
local MiscTab = Main:CreateTab({
	Name = "Misc",
	Icon = NebulaIcons:GetIcon("puzzle", "Lucide"),
	Columns = 2,
}, "PM_TAB_MISC")

local GenMoveBox = MiscTab:CreateGroupbox({ Name = "Movement", Column = 1 }, "PM_BOX_GENMOVE")
GenMoveBox:CreateSlider({
	Name = "WalkSpeed",
	Tooltip = "General character speed outside of painting.\nThe painting speed is separate (Painter tab).",
	Range = { 16, 52 },
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
	IgnoreConfig = true,
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

--//// Visuals Tab
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

--//// Settings Tab
local SettingsTab = Main:CreateTab({
	Name = "Settings",
	Icon = NebulaIcons:GetIcon("settings", "Material"),
	Columns = 2,
}, "PM_TAB_SETTINGS")
SettingsTab:BuildThemeGroupbox(1)
SettingsTab:BuildConfigGroupbox(2)
SettingsTab:CreateGroupbox({ Name = "Control", Column = 1 }, "PM_BOX_CONTROL2"):CreateButton({
	Name = "Unload",
	Tooltip = "Completely removes the script, engine and UI.",
	IndicatorStyle = 2,
	Callback = unload,
}, "PM_BTN_UNLOAD")

--// Autoloads
Starlight:LoadAutoloadTheme()

task.spawn(Features.StatLoop)

Starlight:LoadAutoloadConfig()

task.spawn(Features.CanvasFix)

task.spawn(function()
	actorAvailable()
end)
sessionRestore()

Starlight:Notification({
	Title = "Volaris Hub",
	Content = "Finished loading. Enable Auto Paint on the Painter tab (load a cover via Search first).",
	Icon = NebulaIcons:GetIcon("check_circle", "Material"),
}, "PM_LOAD_COMPLETE")
