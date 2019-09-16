--[[
                print(LoggingCombat())
        print(LoggingCombat(true))
        - getinstanceinfo()
--]]

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
    [719] = "Blackfathom Deeps",
    [1584] = "Blackrock Depths",
    [1583] = "Blackrock Spire",
    [2557] = "Dire Maul",
    [721] = "Gnomeregan",
    [2100] = "Maraudon",
    [2437] = "Ragefire Chasm",
    [722] = "Razorfen Downs",
    [491] = "Razorfen Kraul",
    [796] = "Scarlet Monastery",
    [2057] = "Scholomance",
    [209] = "Shadowfang Keep",
    [2017] = "Stratholme",
    [1477] = "Temple of Atal'Hakkar",
    [1581] = "The Deadmines",
    [717] = "The Stockade",
    [1337] = "Uldaman",
    [718] = "Wailing Caverns",
    [1176] = "Zul'Farrak"
}
local raids = {
    [2677] = "Blackwing Lair",
    [2717] = "Molten Core",
    [3456] = "Naxxramas",
    [2159] = "Onyxia's Lair",
    [3429] = "AQ20",
    [3428] = "AQ40",
    [1977] = "Zul'Gurub"
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

-- Called when player clicks a checkbutton.
function AutoCombatLoggerCheckButton_OnClick(self)
    ACLOptions.instances[self.instance] = not ACLOptions.instances[self.instance]
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
                [719] = true,
                [1584] = true,
                [1583] = true,
                [2557] = true,
                [721] = true,
                [2100] = true,
                [2437] = true,
                [722] = true,
                [491] = true,
                [796] = true,
                [2057] = true,
                [209] = true,
                [2017] = true,
                [1477] = true,
                [1581] = true,
                [717] = true,
                [1337] = true,
                [718] = true,
                [1176] = true,
                [2677] = true,
                [2717] = true,
                [3456] = true,
                [2159] = true,
                [3429] = true,
                [3428] = true,
                [1977] = true
            }
        end
        -- ACLOptions.instances = ACLOptions.instances or {}
        print("|cFFFFFF00AutoCombatLogger|r loaded! Type /acl to toggle options. Remember to enable advanced combat logging in Interface > Network.")
    elseif event == "PLAYER_ENTERING_WORLD" then
        init()
        AutoCombatLoggerFrame:Hide()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end