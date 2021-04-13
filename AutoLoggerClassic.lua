local _, AutoLoggerClassic = ...

local GetInstanceInfo, LoggingCombat = GetInstanceInfo, LoggingCombat

-- UI variables.
local X_START = 16
local X_SPACING = 200
local Y_SPACING = -25
local BUTTONS_PER_ROW = 3

-- Variables.
local minimapIcon = LibStub("LibDBIcon-1.0")
local buttons = {}
local classicRaids = {
    [249] = "Onyxia's Lair",
    [409] = "Molten Core",
    [309] = "Zul'Gurub",
    [469] = "Blackwing Lair",
    [509] = "AQ20",
    [531] = "AQ40",
    [533] = "Naxxramas",
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
    initCheckButtons(0, tbcRaids)
    initCheckButtons(-106, classicRaids)
    tinsert(UISpecialFrames, AutoLoggerClassicFrame:GetName())
end

-- Toggles logging if player is not logging and is in the right instance.
local function toggleLogging()
    local id = select(8, GetInstanceInfo())
    if not LoggingCombat() and ALCOptions.instances[id] then
        LoggingCombat(true)
        print("|cFFFFFF00AutoLoggerClassic|r: Combat logging enabled.")
    elseif LoggingCombat() and not ALCOptions.instances[id] then
        LoggingCombat(false)
        print("|cFFFFFF00AutoLoggerClassic|r: Combat logging disabled.")
    end
end

-- Called when player clicks a checkbutton.
function AutoLoggerClassicCheckButton_OnClick(self)
    ALCOptions.instances[self.instance] = not ALCOptions.instances[self.instance]
    for k, v in pairs(ALCOptions.instances) do
        print(k, v)
    end
    toggleLogging()
end

-- Called when addon has been loaded.
function AutoLoggerClassic_OnLoad(self)
    self:RegisterForDrag("LeftButton")
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("RAID_INSTANCE_WELCOME")
end

-- Handles all events.
function AutoLoggerClassic_OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == "AutoLoggerClassic" then
        ALCOptions = ALCOptions or {}
        ALCOptions.minimapTable = ALCOptions.minimapTable or {}
        if not ALCOptions.instances then
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
            }
        end
        print("|cFFFFFF00AutoLoggerClassic|r loaded! Type /alc to toggle options. Remember to enable advanced combat logging in Interface > Network and clear your combat log often.")
    elseif event == "RAID_INSTANCE_WELCOME" then
        toggleLogging()
    elseif event == "PLAYER_ENTERING_WORLD" then
        init()
        AutoLoggerClassicFrame:Hide()
        toggleLogging()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end
