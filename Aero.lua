local Aero = CreateFrame("Frame")
local running = {}
local next = next
local _G = getfenv(0)

local duration = 0.1

local dummy = function() end

local function print(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end

local function Anim(frame)
	local aero = frame.aero
	local percent = aero.total / duration
	local value = aero.start + aero.diff * percent
	if value <= 0 then value = 0.01 end
	frame:SetAlpha(value)
	frame:SetScale(value)
end

local function OnFinish(frame)
	local aero = frame.aero
	frame:SetScale(aero.scale)
	frame:SetAlpha(aero.alpha)
	if frame.onfinishhide then
		frame.onfinishhide = nil
		HideUIPanel(frame)
		frame.hiding = nil
	end
end

local function OnUpdate()
	for i, frame in next, running do
		local aero = frame.aero
		aero.total = aero.total + arg1
		if aero.total >= duration then
			aero.total = 0
			running[i] = nil
			OnFinish(frame)
		else
			Anim(frame)
		end
	end
end
Aero:SetScript("OnUpdate", OnUpdate)

local function OnShow()
	local frame = this:GetParent()
	if frame.hiding or running[frame] then return end
	tinsert(running, frame)
	if not frame.onshow then
		frame.onshow = frame:GetScript("OnShow") or dummy
		frame:SetScript("OnShow", function()
			frame.onshow()
			local aero = frame.aero
			aero.scale = frame:GetScale()
			aero.alpha = frame:GetAlpha()
			aero.diff = 0.5
			aero.start = aero.scale - aero.diff
		end)
	end
end

local function OnHide()
	local frame = this:GetParent()
	if frame.hiding or running[frame] then return end
	tinsert(running, frame)
	if not frame.onhide then
		frame.onhide = frame:GetScript("OnHide") or dummy
		frame:SetScript("OnHide", function()
			frame.onhide()
			local aero = frame.aero
			aero.start = aero.scale
			aero.diff = -0.5
		end)
	end
	frame.onfinishhide = true
	frame.hiding = true
	frame:Show()
end

function Aero:RegisterFrames(...)
	for i = 1, arg.n do
		local arg = arg[i]
		if type(arg) == "string" then
			local frame = _G[arg]
			if not frame then return print("Aero:|cff98F5FF "..arg.."|r not found.") end
			frame.aero = frame.aero or {}
			frame.aero.total = 0
			local hook = CreateFrame("Frame", nil, frame)
			hook:SetScript("OnShow", OnShow)
			hook:SetScript("OnHide", OnHide)
		else
			arg()
		end
	end
end

local addons = {}
local function OnEvent()
	if addons[arg1] then
		Aero:RegisterFrames(unpack(addons[arg1]))
		addons[arg1] = nil
	end
end
Aero:RegisterEvent("ADDON_LOADED")
Aero:SetScript("OnEvent", OnEvent)

function Aero:RegisterAddon(addon, ...)
	if IsAddOnLoaded(addon) then
		for i = 1, arg.n do
			Aero:RegisterFrames(arg[i])
		end
	else
		local _, _, _, enabled = GetAddOnInfo(addon)
		if enabled then
			addons[addon] = {}
			for i = 1, arg.n do
				tinsert(addons[addon], arg[i])
			end
		end
	end
end

_G.Aero = Aero
