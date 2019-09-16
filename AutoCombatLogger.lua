-- TODO
-- DISABLE LOGGING WHEN GOING OUTSIDE DUNGEON ONLY IF PLAYER WASNT LOGGING BEFORE AND ONLY IF PLAYER ISNT A GHOST

local _, AutoCombatLogger = ...

-- UI variables.
local X_START = 16
local X_SPACING = 200
local Y_SPACING = -25
local BUTTONS_PER_ROW = 3

-- Variables.
local minimapIcon = LibStub("LibDBIcon-1.0")
local buttons = {}
local dungeons = {
    [48] = "Blackfathom Deeps",
    [230] = "Blackrock Depths",
    [229] = "Blackrock Spire",
    [36] = "Deadmines",
    [429] = "Dire Maul",
    [90] = "Gnomeregan",
    [349] = "Maraudon",
    [389] = "Ragefire Chasm",
    [129] = "Razorfen Downs",
    [47] = "Razorfen Kraul",
    [189] = "Scarlet Monastery",
    [289] = "Scholomance",
    [33] = "Shadowfang Keep",
    [34] = "Stormwind Stockade",
    [329] = "Stratholme",
    [109] = "Sunken Temple",
    [70] = "Uldaman",
    [43] = "Wailing Caverns",
    [209] = "Zul'Farrak"
}
local raids = {
    [509] = "AQ20",
    [531] = "AQ40",
    [469] = "Blackwing Lair",
    [409] = "Molten Core",
    [533] = "Naxxramas",
    [249] = "Onyxia's Lair",
    [309] = "Zul'Gurub"
}

-- Shows or hides the addon.
local function toggleFrame()
    if AutoCombatLoggerFrame:IsVisible() then
        AutoCombatLoggerFrame:Hide()
    else
        AutoCombatLoggerFrame:Show()
    end
end

-- Shows or hides the minimap button.
local function toggleMinimapButton()
    ACLOptions.minimapTable.hide = not ACLOptions.minimapTable.hide
    if ACLOptions.minimapTable.hide then
        minimapIcon:Hide("AutoCombatLogger")
        print("|cFFFFFF00AutoCombatLogger:|r Minimap button hidden. Type /acl minimap to show it again.")
    else
        minimapIcon:Show("AutoCombatLogger")
    end
end

-- Initializes the minimap button.
local function initMinimapButton()
    local obj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("AutoCombatLogger", {
        type = "launcher",
        text = "AutoCombatLogger",
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
            GameTooltip:AddLine("|cFFFFFFFFAutoCombatLogger|r")
            GameTooltip:AddLine("Left click to open options.")
            GameTooltip:AddLine("Right click to hide this minimap button.")
            GameTooltip:Show()
        end,
        OnLeave = function(self)
            GameTooltip:Hide()
        end
    })
    minimapIcon:Register("AutoCombatLogger", obj, ACLOptions.minimapTable)
end

-- Sets slash commands.
local function initSlash()
    SLASH_AUTOCOMBATLOGGER1 = "/autocombatlogger"
    SLASH_AUTOCOMBATLOGGER2 = "/acl"
    SlashCmdList["AUTOCOMBATLOGGER"] = function(msg)
        msg = msg:lower()
        if msg == "minimap" then
            toggleMinimapButton()
            return
        end
        toggleFrame()
    end
end

-- Initializes all checkboxes.
local function initCheckButtons()
    -- Dungeons.
    local index = 1
    for k, v in pairs(dungeons) do
        -- Checkbuttons.
        local checkButton = CreateFrame("CheckButton", nil, AutoCombatLoggerFrame, "UICheckButtonTemplate")
        local x = X_START + X_SPACING * ((index - 1) % BUTTONS_PER_ROW)
        local y = Y_SPACING * math.ceil(index / BUTTONS_PER_ROW) - 10
        checkButton:SetPoint("TOPLEFT", x, y)
        checkButton:SetScript("OnClick", AutoCombatLoggerCheckButton_OnClick)
        checkButton.instance = k
        checkButton:SetChecked(ACLOptions.instances[k])
        buttons[#buttons + 1] = checkButton
        -- Strings.
        local string = AutoCombatLoggerFrame:CreateFontString(nil, "ARTWORK", "AutoCombatLoggerStringTemplate")
        string:SetPoint("LEFT", checkButton, "RIGHT", 5, 0)
        string:SetText(v)
        index = index + 1
    end
    -- Raids.
    index = 1
    for k, v in pairs(raids) do
        -- Checkbuttons.
        local checkButton = CreateFrame("CheckButton", nil, AutoCombatLoggerFrame, "UICheckButtonTemplate")
        local x = X_START + X_SPACING * ((index - 1) % BUTTONS_PER_ROW)
        local y = Y_SPACING * math.ceil(index / BUTTONS_PER_ROW) - 240
        checkButton:SetPoint("TOPLEFT", x, y)
        checkButton:SetScript("OnClick", AutoCombatLoggerCheckButton_OnClick)
        checkButton.instance = k
        checkButton:SetChecked(ACLOptions.instances[k])
        buttons[#buttons + 1] = checkButton
        -- Strings.
        local string = AutoCombatLoggerFrame:CreateFontString(nil, "ARTWORK", "AutoCombatLoggerStringTemplate")
        string:SetPoint("LEFT", checkButton, "RIGHT", 5, 0)
        string:SetText(v)
        index = index + 1
    end
end

-- Initializes everything.
local function init()
    initMinimapButton()
    initSlash()
    initCheckButtons()
    tinsert(UISpecialFrames, AutoCombatLoggerFrame:GetName())
end

-- Toggles logging if player is not logging and is in the right instance.
local function toggleLogging()
    if not LoggingCombat() and ACLOptions.instances[select(8, GetInstanceInfo())] then
        LoggingCombat(true)
        print("|cFFFFFF00AutoCombatLogger|r: Combat logging enabled.")
    elseif LoggingCombat() and not ACLOptions.instances[select(8, GetInstanceInfo())] then
        LoggingCombat(false)
        print("|cFFFFFF00AutoCombatLogger|r: Combat logging disabled.")
    end
end

-- Called when player clicks a checkbutton.
function AutoCombatLoggerCheckButton_OnClick(self)
    ACLOptions.instances[self.instance] = not ACLOptions.instances[self.instance]
    toggleLogging()
end

-- Called when addon has been loaded.
function AutoCombatLogger_OnLoad(self)
    self:RegisterForDrag("LeftButton")
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

-- Handles all events.
function AutoCombatLogger_OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == "AutoCombatLogger" then
        ACLOptions = ACLOptions or {}
        ACLOptions.minimapTable = ACLOptions.minimapTable or {}
        if not ACLOptions.instances then
            ACLOptions.instances = {
                    [48] = true,
                    [230] = true,
                    [229] = true,
                    [36] = true,
                    [429] = true,
                    [90] = true,
                    [349] = true,
                    [389] = true,
                    [129] = true,
                    [47] = true,
                    [189] = true,
                    [289] = true,
                    [33] = true,
                    [34] = true,
                    [329] = true,
                    [109] = true,
                    [70] = true,
                    [43] = true,
                    [209] = true,
                    [509] = true,
                    [531] = true,
                    [469] = true,
                    [409] = true,
                    [533] = true,
                    [249] = true,
                    [309] = true
            }
        end
        print("|cFFFFFF00AutoCombatLogger|r loaded! Type /acl to toggle options. Remember to enable advanced combat logging in Interface > Network and clear your combat log often.")
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        toggleLogging()
    elseif event == "PLAYER_ENTERING_WORLD" then
        init()
        AutoCombatLoggerFrame:Hide()
        toggleLogging()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end
