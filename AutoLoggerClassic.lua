local _, AutoLoggerClassic = ...

local GetInstanceInfo, LoggingCombat = GetInstanceInfo, LoggingCombat

-- UI variables.
local X_START = 16
local X_SPACING = 220
local Y_SPACING = -25
local BUTTONS_PER_ROW = 3

-- Variables.
local hasInitialized = false -- true if init has been called.
local minimapIcon = LibStub("LibDBIcon-1.0")
local buttons = {}
local classicRaids = {
    [409] = "Molten Core",
    [309] = "Zul'Gurub",
    [469] = "Blackwing Lair",
    [509] = "AQ20",
    [531] = "AQ40",
}
local tbcRaids = {
    [532] = "Karazhan",
    [544] = "Magtheridon's Lair",
    [565] = "Gruul's Lair",
    [548] = "Serpentshrine Cavern",
    [550] = "Tempest Keep",
    [534] = "Battle for Mount Hyjal",
    [564] = "Black Temple",
    [568] = "Zul'Aman",
    [580] = "Sunwell Plateau"
}
local tbcDungeons = {
    [269] = "The Black Morass",
    [540] = "The Shattered Halls",
    [542] = "The Blood Furnace",
    [543] = "Hellfire Ramparts",
    [545] = "The Steamvault",
    [546] = "The Underbog",
    [547] = "The Slave Pens",
    [552] = "The Arcatraz",
    [553] = "The Botanica",
    [554] = "The Mechanar",
    [555] = "Shadow Labyrinth",
    [556] = "Sethekk Halls",
    [557] = "Mana-Tombs",
    [558] = "Auchenai Crypts",
    [560] = "Old Hillsbrad Foothills",
    [585] = "Magisters' Terrace"
}
local wotlkRaids = {
	[631] = "Icecrown Citadel",
	[533] = "Naxxramas",
	[249] = "Onyxia's Lair",
	[724] = "Ruby Sanctum",
	[616] = "The Eye of Eternity",
	[615] = "The Obsidian Sanctum",
	[649] = "Trial of the Crusader",
	[603] = "Ulduar",
	[624] = "Vault of Archavon",
}
local wotlkDungeons = {
	[619] = "Ahn'kahet: The Old Kingdom",
	[601] = "Azjol-Nerub",
	[600] = "Drak'Tharon Keep",
	[604] = "Gundrak",
	[602] = "Halls of Lightning",
	[668] = "Halls of Reflection",
	[599] = "Halls of Stone",
	[658] = "Pit of Saron",
	[595] = "The Culling of Stratholme",
	[632] = "The Forge of Souls",
	[576] = "The Nexus",
	[578] = "The Oculus",
	[650] = "Trial of the Champion",
	[574] = "Utgarde Keep",
	[575] = "Utgarde Pinnacle",
	[608] = "Violet Hold",
}

-- Shows or hides the addon.
local function toggleFrame()
    if AutoLoggerClassicFrame:IsVisible() then
        AutoLoggerClassicFrame:Hide()
    else
        AutoLoggerClassicFrame:Show()
    end
end

-- Shows or hides the minimap button.
local function toggleMinimapButton()
    ALCOptions.minimapTable.hide = not ALCOptions.minimapTable.hide
    if ALCOptions.minimapTable.hide then
        minimapIcon:Hide("AutoLoggerClassic")
        print("|cFFFFFF00AutoLoggerClassic:|r Minimap button hidden. Type /alc minimap to show it again.")
    else
        minimapIcon:Show("AutoLoggerClassic")
    end
end

-- Initializes the minimap button.
local function initMinimapButton()
    local obj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("AutoLoggerClassic", {
        type = "launcher",
        text = "AutoLoggerClassic",
        icon = "Interface/ICONS/Trade_Engineering",
        OnClick = function(self, button)
            if button == "LeftButton" then
                toggleFrame()
            elseif button == "RightButton" then
                toggleMinimapButton()
            end
        end,
        OnEnter = function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:AddLine("|cFFFFFFFFAutoLoggerClassic|r")
            GameTooltip:AddLine("Left click to open options.")
            GameTooltip:AddLine("Right click to hide this minimap button.")
            GameTooltip:Show()
        end,
        OnLeave = function(self)
            GameTooltip:Hide()
        end
    })
    minimapIcon:Register("AutoLoggerClassic", obj, ALCOptions.minimapTable)
end

-- Sets slash commands.
local function initSlash()
    SLASH_AutoLoggerClassic1 = "/AutoLoggerClassic"
    SLASH_AutoLoggerClassic2 = "/alc"
    SlashCmdList["AutoLoggerClassic"] = function(msg)
        msg = msg:lower()
        if msg == "minimap" then
            toggleMinimapButton()
            return
        end
        toggleFrame()
    end
end

-- Initializes all checkboxes.
local function initCheckButtons(yStart, raidTable)
    local index = 1
    for k, v in pairs(raidTable) do
        -- Checkbuttons.
        local checkButton = CreateFrame("CheckButton", nil, AutoLoggerClassicFrame, "UICheckButtonTemplate")
        local x = X_START + X_SPACING * ((index - 1) % BUTTONS_PER_ROW)
        local y = yStart + Y_SPACING * math.ceil(index / BUTTONS_PER_ROW) - 10
        checkButton:SetPoint("TOPLEFT", x, y)
        checkButton:SetScript("OnClick", AutoLoggerClassicCheckButton_OnClick)
        checkButton.instance = k
        checkButton:SetChecked(ALCOptions.instances[k])
        buttons[#buttons + 1] = checkButton
        -- Strings.
        local string = AutoLoggerClassicFrame:CreateFontString(nil, "ARTWORK", "AutoLoggerClassicStringTemplate")
        string:SetPoint("LEFT", checkButton, "RIGHT", 5, 0)
        string:SetText(v)
        index = index + 1
    end
end

-- Initializes everything.
local function init()
    initMinimapButton()
    initSlash()
	initCheckButtons(0, wotlkRaids)
    initCheckButtons(-106, wotlkDungeons)
    initCheckButtons(-286, tbcRaids)
    initCheckButtons(-392, tbcDungeons)
    initCheckButtons(-576, classicRaids)
    tinsert(UISpecialFrames, AutoLoggerClassicFrame:GetName())
end

local function shouldLogCurrentInstance()
    local _, instanceType, _, difficulty, _, _, _, id = GetInstanceInfo()
    return ALCOptions.instances[id] and (instanceType == "raid" or (instanceType == "party" and difficulty == "Heroic"))
end

-- Toggles logging if player is not logging and is in the right instance.
local function toggleLogging()
    if not LoggingCombat() and shouldLogCurrentInstance() then
        LoggingCombat(true)
        print("|cFFFFFF00AutoLoggerClassic|r: Combat logging enabled.")
    elseif LoggingCombat() and not shouldLogCurrentInstance() then
        LoggingCombat(false)
        print("|cFFFFFF00AutoLoggerClassic|r: Combat logging disabled.")
    end
end

-- Called when player clicks a checkbutton.
function AutoLoggerClassicCheckButton_OnClick(self)
    ALCOptions.instances[self.instance] = not ALCOptions.instances[self.instance]
    toggleLogging()
end

-- Called when addon has been loaded.
function AutoLoggerClassic_OnLoad(self)
    self:RegisterForDrag("LeftButton")
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("RAID_INSTANCE_WELCOME")
    self:RegisterEvent("UPDATE_INSTANCE_INFO")
end

-- Handles all events.
function AutoLoggerClassic_OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == "AutoLoggerClassic" then
        ALCOptions = ALCOptions or {}
        ALCOptions.minimapTable = ALCOptions.minimapTable or {}
        if not ALCOptions.instances or ALCOptions.instances[269] == nil then -- Check for 269 because if player had addon already all TBC heroic raids will be off by default.
            ALCOptions.instances = {
                -- Classic raids:
                [249] = true, -- Onyxia's Lair
                [409] = true, -- Molten Core
                [309] = true, -- Zul'Gurub
                [469] = true, -- Blackwing Lair
                [509] = true, -- Ruins of Ahn'Qiraj (AQ20)
                [531] = true, -- Temple of Ahn'Qiraj (AQ40)
                [533] = true, -- Naxxramas
                -- The Burning Crusade raids:
                [532] = true, -- Karazhan
                [544] = true, -- Magtheridon's Lair
                [565] = true, -- Gruul's Lair
                [548] = true, -- Serpentshrine Cavern
                [550] = true, -- Tempest Keep
                [534] = true, -- Battle for Mount Hyjal
                [564] = true, -- Black Temple
                [568] = true, -- Zul'Aman
                [580] = true, -- Sunwell Plateau
                -- The Burning Crusade dungeons:
                [269] = true, -- The Black Morass
                [540] = true, -- The Shattered Halls
                [542] = true, -- The Blood Furnace
                [543] = true, -- Hellfire Ramparts
                [545] = true, -- The Steamvault
                [546] = true, -- The Underbog
                [547] = true, -- The Slave Pens
                [552] = true, -- The Arcatraz
                [553] = true, -- The Botanica
                [554] = true, -- The Mechanar
                [555] = true, -- Shadow Labyrinth
                [556] = true, -- Sethekk Halls
                [557] = true, -- Mana-Tombs
                [558] = true, -- Auchenai Crypts
                [560] = true, -- Old Hillsbrad Foothills
                [585] = true, -- Magisters' Terrace
				-- Wrath of the Lich King raids:
				[631] = true, -- Icecrown Citadel
				[533] = true, -- Naxxramas
				[249] = true, -- Onyxia's Lair
				[724] = true, -- Ruby Sanctum
				[616] = true, -- The Eye of Eternity
				[615] = true, -- The Obsidian Sanctum
				[649] = true, -- Trial of the Crusader
				[603] = true, -- Ulduar
				[624] = true, -- Vault of Archavon
				-- Wrath of the Lich King dungeons:
				[619] = true, -- Ahn'kahet: The Old Kingdom
				[601] = true, -- Azjol-Nerub
				[600] = true, -- Drak'Tharon Keep
				[604] = true, -- Gundrak
				[602] = true, -- Halls of Lightning
				[668] = true, -- Halls of Reflection
				[599] = true, -- Halls of Stone
				[658] = true, -- Pit of Saron
				[595] = true, -- The Culling of Stratholme
				[632] = true, -- The Forge of Souls
				[576] = true, -- The Nexus
				[578] = true, -- The Oculus
				[650] = true, -- Trial of the Champion
				[574] = true, -- Utgarde Keep
				[575] = true, -- Utgarde Pinnacle
				[608] = true, -- Violet Hold
            }
        end
        print("|cFFFFFF00AutoLoggerClassic|r loaded! Type /alc to toggle options. Remember to enable advanced combat logging in Interface > Network and clear your combat log often.")
    elseif event == "RAID_INSTANCE_WELCOME" or event == "UPDATE_INSTANCE_INFO" then
        -- PLAYER_ENTERING_WORLD fires on dungeon entry. The difficulty value is
        -- not available until an UPDATE_INSTANCE_INFO event fires.
        -- On dungeon exit combat logging may be automatically disabled and the
        -- message will not display in this case. This is not consistent.
        toggleLogging()
    elseif event == "PLAYER_ENTERING_WORLD" then
        if not hasInitialized then
            init()
            AutoLoggerClassicFrame:Hide()
            hasInitialized = true
        end
        toggleLogging()
    end
end
