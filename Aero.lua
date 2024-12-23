local _G = getfenv()

local Aero = CreateFrame("Frame")

local defaultDuration = 0.2
local duration = defaultDuration

local animating = {}
local addons = {}

local function print(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end

Aero:RegisterEvent("VARIABLES_LOADED")
Aero:RegisterEvent("ADDON_LOADED")
Aero:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        AeroDB = AeroDB or {}
        AeroDB.duration = AeroDB.duration or defaultDuration
        duration = AeroDB.duration
    elseif event == "ADDON_LOADED" then
        if addons[arg1] then
            Aero:RegisterFrames(unpack(addons[arg1]))
            addons[arg1] = nil
        end
    end
end)

local function onShow(frame)
    local aero = frame.aero
    if aero.animating or StaticPopup1:IsShown() then return end
    aero.animating = true

    tinsert(animating, frame)

    aero.scaleDiff = 0.6
    aero.startScale = aero.origScale - aero.scaleDiff
end
Aero:SetScript("OnShow", onShow)

local function onHide(frame)
    local aero = frame.aero
    if aero.animating or StaticPopup1:IsShown() then return end
    aero.animating = true

    tinsert(animating, frame)

    aero.startScale = aero.origScale
    aero.scaleDiff = -0.6
    aero.finished = true

    frame:Show()
end
Aero:SetScript("OnHide", onHide)

Aero:SetScript("OnUpdate", function()
    for i, frame in next, animating do
        local aero = frame.aero
        aero.elapsed = aero.elapsed + arg1

        if aero.elapsed >= duration then
            aero.elapsed = 0
            animating[i] = nil

            frame:SetScale(aero.origScale)
            frame:SetAlpha(aero.origAlpha)

            if aero.finished then
                aero.finished = false
                HideUIPanel(frame)
            end

            aero.animating = false
        else
            local progress = aero.elapsed / duration
            local scale = aero.startScale + aero.scaleDiff * progress
            scale = scale <= 0 and 0.01 or scale

            local scalePct = scale / aero.origScale
            local alpha = (scalePct <= 0.3) and 0 or math.min(1, ((scalePct - 0.3) / 0.7) ^ 4)

            frame:SetAlpha(alpha)
            frame:SetScale(scale)
        end
    end
end)

function Aero:RegisterFrames(...)
    for i = 1, arg.n do
        local currentArg = arg[i]

        if type(currentArg) == "string" then
            local frame = _G[currentArg]
            if not frame then return end

            frame.aero = frame.aero or {}
            frame.aero.elapsed = 0
            frame.aero.origScale = frame:GetScale()
            frame.aero.origAlpha = frame:GetAlpha()

            local origOnShow = frame:GetScript("OnShow")
            frame:SetScript("OnShow", function()
                if origOnShow then origOnShow(frame) end
                onShow(frame)
            end)

            local origOnHide = frame:GetScript("OnHide")
            frame:SetScript("OnHide", function()
                if origOnHide then origOnHide(frame) end
                onHide(frame)
            end)
        else
            currentArg()
        end
    end
end

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

function Aero:SetDuration(newDuration)
    if newDuration and newDuration >= 0 then
        AeroDB.duration = newDuration
        duration = newDuration
        return true
    end
    return false
end

SLASH_AERO1 = "/aero"
SlashCmdList["AERO"] = function(msg)
    local newDuration = tonumber(msg)

    if Aero:SetDuration(newDuration) then
        local secondText = (newDuration == 1) and "second" or "seconds"
        print("Aero duration set to " .. newDuration .. " " .. secondText .. ".")
    else
        print("Usage: /aero <duration in seconds>")
    end
end

_G.Aero = Aero
