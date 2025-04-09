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
    elseif event == "ADDON_LOADED" and addons[arg1] then
        Aero:RegisterFrames(unpack(addons[arg1]))
        addons[arg1] = nil
    end
end)

local function onShow(frame)
    local aero = frame.aero
    aero.animating = true
    aero.finished = false
    aero.scaleDiff = 0.6
    aero.startScale = aero.origScale - aero.scaleDiff
    table.insert(animating, frame)
end
Aero:SetScript("OnShow", onShow)

local function onHide(frame)
    local aero = frame.aero
    aero.animating = true
    aero.finished = true
    aero.scaleDiff = -0.6
    aero.startScale = aero.origScale
    table.insert(animating, frame)
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
            local scale = math.max(aero.startScale + aero.scaleDiff * (aero.elapsed / duration), 0.01)
            local alpha = 0

            if (scale / aero.origScale) > 0.3 then
                alpha = math.min(aero.origAlpha, (((scale / aero.origScale) - 0.3) / 0.7) ^ 4)
            end

            frame:SetAlpha(alpha)
            frame:SetScale(scale)
        end
    end
end)

function Aero:RegisterFrames(...)
    for i = 1, arg.n do
        local currentArg = arg[i]
        if type(currentArg) ~= "string" then return currentArg() end

        local frame = _G[currentArg]
        if not frame or (frame.aero and frame.aero.registered) then return end

        frame.aero = frame.aero or {}
        local aero = frame.aero

        aero.registered = true
        aero.paused = false
        aero.animating = false
        aero.finished = false
        aero.origScale = frame:GetScale()
        aero.origAlpha = frame:GetAlpha()
        aero.startScale = 0
        aero.scaleDiff = 0
        aero.elapsed = 0

        for _, script in pairs({ "OnShow", "OnHide" }) do
            local origScript = frame:GetScript(script)
            local func = (script == "OnHide") and onHide or onShow

            frame:SetScript(script, function()
                if aero.paused or (aero.animating and aero.elapsed == 0) then return end
                if origScript then origScript() end
                if aero.animating then return end
                func(frame)
            end)
        end

        for _, func in pairs({ "IsShown", "IsVisible" }) do
            local origFunc = frame[func]
            frame[func] = function()
                if aero.finished then return false end
                return origFunc(frame)
            end
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
                table.insert(addons[addon], arg[i])
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
