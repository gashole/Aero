local _G = getfenv()

--[[
Aero:RegisterFrames(...)
Use it to register show/hide animation to frames
Arguments can be either frame names or hook functions, separated by commas
]]

Aero:RegisterFrames(
    "GameMenuFrame",
    "OptionsFrame",
    "SoundOptionsFrame",
    "UIOptionsFrame",
    "HelpFrame",
    "OpacityFrame",
    "ColorPickerFrame",
    "CharacterFrame",
    "ReputationDetailFrame",
    "TabardFrame",
    "DressUpFrame",
    "GuildRegistrarFrame",
    "PetitionFrame",
    "PetStableFrame",
    "ItemTextFrame",
    "SpellBookFrame",
    "LootFrame",
    "StackSplitFrame",
    "MerchantFrame",
    "TradeFrame",
    "BankFrame",
    "FriendsFrame",
    "GossipFrame",
    "MailFrame",
    "OpenMailFrame",
    "QuestFrame",
    "QuestLogFrame",
    "TaxiFrame",
    "BattlefieldFrame",
    "WorldStateScoreFrame"
)

local function moveFrame(frame, point, x, y)
    frame:ClearAllPoints()
    frame:SetPoint(point, x, y)
end

local function delayRun(delay, callback)
    local elapsed = 0
    local frame = CreateFrame("Frame")

    frame:SetScript("OnUpdate", function()
        elapsed = elapsed + arg1
        if elapsed >= delay then
            callback()
            frame:SetScript("OnUpdate", nil)
        end
    end)
end

local origShowUIPanel = ShowUIPanel
function ShowUIPanel(frame, force)
    if frame and frame.aero and frame.aero.finished then
        local duration = Aero:GetDuration()
        frame.aero.elapsed = duration
        if frame == MerchantFrame and ContainerFrame1.aero then ContainerFrame1.aero.elapsed = duration end
        delayRun(0, function() origShowUIPanel(frame, force) end)
        return
    end
    origShowUIPanel(frame, force)
end

local origGossipFrameUpdate = GossipFrameUpdate
function GossipFrameUpdate()
    if GossipFrame.aero and GossipFrame.aero.finished then ShowUIPanel(GossipFrame) end
    origGossipFrameUpdate()
end

local origTaxiNodeOnButtonEnter = TaxiNodeOnButtonEnter
function TaxiNodeOnButtonEnter(button)
    if TaxiFrame.aero and TaxiFrame.aero.animating then return end
    origTaxiNodeOnButtonEnter(button)
end

-- Backpack and bags
for i = 1, NUM_CONTAINER_FRAMES do
    Aero:RegisterFrames("ContainerFrame" .. i)
end

local function updateChecked(buttonID)
    local translatedID = 0
    if buttonID ~= 0 then translatedID = buttonID - CharacterBag0Slot:GetID() + 1 end

    local isVisible = 0
    for i = 1, NUM_CONTAINER_FRAMES do
        local frame = _G["ContainerFrame" .. i]
        if frame:GetID() == translatedID and frame:IsVisible() and frame.aero and not frame.aero.finished then
            isVisible = 1
            break
        end
    end
    this:SetChecked(isVisible)
end

local origBagSlotButton_OnClick = BagSlotButton_OnClick
function BagSlotButton_OnClick()
    origBagSlotButton_OnClick()
    updateChecked(this:GetID())
end

local origBagSlotButton_OnDrag = BagSlotButton_OnDrag
function BagSlotButton_OnDrag()
    origBagSlotButton_OnDrag()
    updateChecked(this:GetID())
end

local origBagSlotButton_OnShiftClick = BagSlotButton_OnShiftClick
function BagSlotButton_OnShiftClick()
    origBagSlotButton_OnShiftClick()
    updateChecked(this:GetID())
end

local origBackpackButton_OnClick = BackpackButton_OnClick
function BackpackButton_OnClick()
    origBackpackButton_OnClick()
    updateChecked(0)
end

local origUpdateContainerFrameAnchors = updateContainerFrameAnchors
function updateContainerFrameAnchors() delayRun(0, origUpdateContainerFrameAnchors) end

local origOpenAllBags = OpenAllBags
function OpenAllBags(forceOpen)
    if not UIParent:IsVisible() then return end

    local bagsOpen, totalBags = 0, 1

    for i = 1, NUM_CONTAINER_FRAMES do
        local frame = _G["ContainerFrame" .. i]
        local button = _G["CharacterBag" .. (i - 1) .. "Slot"]

        if button then
            local bagID = button:GetID() - _G["CharacterBag0Slot"]:GetID() + 1
            if i <= NUM_BAG_FRAMES and GetContainerNumSlots(bagID) > 0 then totalBags = totalBags + 1 end
        end

        if frame:IsShown() then
            if frame.aero then frame.aero.animating = true end
            if frame:GetID() ~= KEYRING_CONTAINER then bagsOpen = bagsOpen + 1 end
        end
    end

    if bagsOpen >= totalBags and not forceOpen then
        for i = 1, NUM_CONTAINER_FRAMES do
            local frame = _G["ContainerFrame" .. i]
            if frame.aero then frame.aero.animating = false end
        end
    end

    origOpenAllBags(forceOpen)
end

local origToggleBag = ToggleBag
function ToggleBag(id)
    local frame = _G["ContainerFrame" .. id]
    if frame and frame:IsShown() and frame.aero and frame.aero.animating then frame.aero.animating = false end
    origToggleBag(id)
end

local origContainerFrameItemButton_OnEnter = ContainerFrameItemButton_OnEnter
function ContainerFrameItemButton_OnEnter(button)
    button = button or this
    if not button:GetRight() then return end
    origContainerFrameItemButton_OnEnter(button)
end

-- World map
Aero:RegisterFrames("WorldMapFrame")

local mapFrame = CreateFrame("Frame", nil, WorldMapFrame)
mapFrame:SetAllPoints(WorldMapFrame)
mapFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
mapFrame:SetScript("OnEvent", function()
    if WORLDMAP_WINDOWED == 0 then moveFrame(WorldMapFrameTitle, "CENTER", 0, 372) end
end)

local origWorldMapButton_OnUpdate = WorldMapButton_OnUpdate
function WorldMapButton_OnUpdate(elapsed)
    if not this:GetCenter() then return end
    origWorldMapButton_OnUpdate(elapsed)
end

BlackoutWorld:SetAllPoints(WorldMapFrame)
WorldMapFrameAreaLabel:SetText("")

-- Turtle WoW
Aero:RegisterFrames("LFTFrame", "ShopFrame")

function WorldMapFrame_SetMapName() end

local origWorldMapFrame_Minimize = WorldMapFrame_Minimize
function WorldMapFrame_Minimize()
    WorldMapContinentDropDown:Hide()
    WorldMapZoneDropDown:Hide()

    WorldMapFrame.aero = WorldMapFrame.aero or {}
    WorldMapFrame.aero.animating = true
    origWorldMapFrame_Minimize()
    WorldMapFrame.aero.animating = false
    WorldMapFrame.aero.origScale = WorldMapFrame:GetScale()
end

local origWorldMapFrame_Maximize = WorldMapFrame_Maximize
function WorldMapFrame_Maximize()
    if not WorldMapFrame:IsVisible() then return end

    WorldMapContinentDropDown:Show()
    WorldMapZoneDropDown:Show()

    WorldMapFrame.aero = WorldMapFrame.aero or {}
    WorldMapFrame.aero.animating = true
    origWorldMapFrame_Maximize()
    WorldMapFrame.aero.animating = false
    WorldMapFrame.aero.origScale = WorldMapFrame:GetScale()

    moveFrame(WorldMapFrameTitle, "CENTER", 0, 372)
end

--[[
Aero:RegisterAddon(addon, ...)
Use it to register frames that are created after addon loaded or on demand
Arguments:
    addon - addon's name
    ... - either frame names or hook functions, separated by commas
]]

Aero:RegisterAddon("Blizzard_CraftUI", "CraftFrame")
Aero:RegisterAddon("Blizzard_BindingUI", "KeyBindingFrame")
Aero:RegisterAddon("Blizzard_MacroUI", "MacroFrame")
Aero:RegisterAddon("Blizzard_AuctionUI", "AuctionFrame", "AuctionDressUpFrame")
Aero:RegisterAddon("Blizzard_GuildBankUI", "GuildBankFrame")
Aero:RegisterAddon("Blizzard_TalentUI", "TalentFrame")
Aero:RegisterAddon("Blizzard_TradeSkillUI", "TradeSkillFrame")
Aero:RegisterAddon("Blizzard_TrainerUI", "ClassTrainerFrame")
Aero:RegisterAddon("Blizzard_GMSurveyUI", "GMSurveyFrame")
Aero:RegisterAddon("Blizzard_AchievementUI", "AchievementFrame")
Aero:RegisterAddon("Blizzard_BattlefieldMinimap", "BattlefieldMinimap")
Aero:RegisterAddon("Blizzard_ItemSocketingUI", "ItemSocketingFrame")
Aero:RegisterAddon("TimeManager", "TimeManagerFrame")

-- ShaguTweaks, Turtle Dragonflight, and pfUI

local function fixMinimizeMap()
    WorldMapFrame_Minimize()
    delayRun(0, function()
        WorldMapFrame:SetWidth(720)
        WorldMapFrame:SetHeight(521)
    end)
end

local function handleMapScaleAndAlpha()
    if not WorldMapFrame.aero then return end
    delayRun(0, function()
        WorldMapFrame.aero.origScale = WorldMapFrame:GetScale()

        local origOnMouseWheel = WorldMapFrame:GetScript("OnMouseWheel")
        WorldMapFrame:SetScript("OnMouseWheel", function()
            if origOnMouseWheel then origOnMouseWheel() end
            if IsControlKeyDown() then WorldMapFrame.aero.origScale = WorldMapFrame:GetScale() end
            if IsShiftKeyDown() then WorldMapFrame.aero.origAlpha = WorldMapFrame:GetAlpha() end
        end)
    end)
end

local addonFrame = CreateFrame("Frame")
addonFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
addonFrame:SetScript("OnEvent", function()
    for _, addon in pairs({ "ShaguTweaks", "Turtle-Dragonflight" }) do
        if IsAddOnLoaded(addon) then
            Aero:RegisterFrames("AdvancedSettingsGUI")

            local config, T

            if addon == "ShaguTweaks" then
                config, T = ShaguTweaks_config, ShaguTweaks.T
            else
                config, T = tDFUI_config, tDFUI.T
                if config[T["Improved Interface Options"]] == 1 then UIOptionsFrame.aero.origScale = 0.8 end
            end

            if config[T["WorldMap Window"]] == 1 and WORLDMAP_WINDOWED == 1 then fixMinimizeMap() end

            handleMapScaleAndAlpha()
            break
        end
    end

    if IsAddOnLoaded("pfUI") then
        Aero:RegisterFrames("pfConfigGUI", "pfAddons")

        BankFrame.aero.origScale = BankFrame:GetScale()
        BankFrame.aero.origAlpha = BankFrame:GetAlpha()

        if WORLDMAP_WINDOWED == 1 then origWorldMapFrame_Maximize() end

        handleMapScaleAndAlpha()
    end

    addonFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)
