--[[
Aero:RegisterFrames(...)
Use it to register show/hide animation to frames
Arguments can be either frame names or hook functions, seperated by commas
]]

Aero:RegisterFrames(
	"GameMenuFrame",
	"SoundOptionsFrame",
	"OptionsFrame",
	"UIOptionsFrame",
	"OpacityFrame",
	"ItemRefTooltip",
	"OpenMailFrame",
	"StackSplitFrame",
	"ColorPickerFrame",
	"GuildInfoFrame",
	"ReputationDetailFrame",
	"LootFrame",
	"HelpFrame",
	"MailFrame",
	"TradeFrame",
	"GossipFrame",
	"TabardFrame",
	"FriendsFrame",
	"MerchantFrame",
	"QuestLogFrame",
	"PetStableFrame",
	"BattlefieldFrame",
	"CharacterFrame",
	"BankFrame"
)

local orig = {}

Aero:RegisterFrames"SpellBookFrame"
orig.ToggleSpellBook = ToggleSpellBook
function ToggleSpellBook(bookType)
	local bt = SpellBookFrame.bookType
	if not this then this = SpellBookFrame end
	orig.ToggleSpellBook(bookType)
	if SpellBookFrame.hiding and bt ~= SpellBookFrame.bookType then
		HideUIPanel(SpellBookFrame)
		ShowUIPanel(SpellBookFrame)
		SpellBookFrame_OnShow()
		SpellBookFrame.onfinishhide = nil
		SpellBookFrame.hiding = nil
	end
end

Aero:RegisterFrames"WorldMapFrame"
orig.WorldMapButton_OnUpdate = WorldMapButton_OnUpdate
function WorldMapButton_OnUpdate(elapsed)
	if not this:GetCenter() then return end
	orig.WorldMapButton_OnUpdate(elapsed)
end
BlackoutWorld:SetAllPoints(WorldMapFrame)

--[[
Aero:RegisterAddon(addon, ...)
Use it to register frames that are created after addon loaded or on demand
Arguments:
	addon - addon's name
	... - either frame names or hook functions, seperated by commas
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
