-- Binding header localization
-- BINDING_HEADER_QUICKTARGETS = "Quick Targets"
-- BINDING_NAME_QUICKTARGETS_TOGGLE = "Toggle Frame"

QuickTargetsDB = QuickTargetsDB or {}
QuickTargetsDB.locked = QuickTargetsDB.locked or false
QuickTargetsDB.hidden = QuickTargetsDB.hidden or false
QuickTargetsDB.position = QuickTargetsDB.position or nil
QuickTargetsDB.scale = QuickTargetsDB.scale or 1.0
QuickTargetsDB.width = QuickTargetsDB.width or 300
QuickTargetsDB.height = QuickTargetsDB.height or 35

local ICON_SIZE = 28
local ICON_SPACING = 4
local BASE_WIDTH = 300
local BASE_HEIGHT = 35
local buttons = {}
local L = QuickTargetsL

local QT = CreateFrame("Frame", "QuickTargetsFrame", UIParent)
QT:SetMovable(true)
QT:RegisterForDrag("LeftButton")
QT:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
QT:SetBackdropColor(0, 0, 0, 0.75)

if QuickTargetsDB.position then
    QT:SetPoint(QuickTargetsDB.position.point, UIParent, QuickTargetsDB.position.relativePoint, QuickTargetsDB.position.x, QuickTargetsDB.position.y)
else
    QT:SetPoint("CENTER")
end

local function SavePosition()
    local point, _, relativePoint, x, y = QT:GetPoint()
    QuickTargetsDB.position = { point = point, relativePoint = relativePoint, x = x, y = y }
end

local function UpdateLayout()
    QT:SetScale(QuickTargetsDB.scale)
    QT:SetWidth(QuickTargetsDB.width)
    QT:SetHeight(QuickTargetsDB.height)
    
    local widthScaleRatio = QuickTargetsDB.width / BASE_WIDTH
    local heightScaleRatio = QuickTargetsDB.height / BASE_HEIGHT
    local scaleRatio = math.min(widthScaleRatio, heightScaleRatio)
    
    local scaledIconSize = ICON_SIZE * scaleRatio
    local scaledIconSpacing = ICON_SPACING * scaleRatio
    
    local numIcons = #buttons
    local totalWidth = (numIcons * scaledIconSize) + ((numIcons - 1) * scaledIconSpacing)
    local startX = (QuickTargetsDB.width - totalWidth) / 2
    
    for i, btn in ipairs(buttons) do
        btn:SetSize(scaledIconSize, scaledIconSize)
        btn:ClearAllPoints()
        btn:SetPoint("LEFT", QT, "LEFT", startX + (i - 1) * (scaledIconSize + scaledIconSpacing), 0)
    end
    
    if LockBtn then
        local lockBtnSize = 16 * scaleRatio
        LockBtn:SetSize(lockBtnSize, lockBtnSize)
        LockBtn:ClearAllPoints()
        LockBtn:SetPoint("RIGHT", QT, "RIGHT", -6 * scaleRatio, 0)
    end
end

local function UpdateMouseInteractions()
    if QuickTargetsDB.locked then
        QT:EnableMouse(false)
        QT:EnableMouseWheel(false)
    else
        QT:EnableMouse(true)
        QT:EnableMouseWheel(true)
    end
end

-- Global toggle function for binding
function QuickTargets_ToggleVisibility()
    if QT:IsShown() then
        QT:Hide()
        QuickTargetsDB.hidden = true
    else
        QT:Show()
        QuickTargetsDB.hidden = false
    end
end

QT:SetScript("OnDragStart", function(self)
    if not QuickTargetsDB.locked then
        self:StartMoving()
    end
end)

QT:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SavePosition()
end)

QT:SetScript("OnMouseWheel", function(self, delta)
    if IsControlKeyDown() and IsShiftKeyDown() and IsAltKeyDown() then
        QuickTargetsDB.scale = QuickTargetsDB.scale + (delta * 0.05)
        if QuickTargetsDB.scale < 0.5 then QuickTargetsDB.scale = 0.5 end
        if QuickTargetsDB.scale > 2.0 then QuickTargetsDB.scale = 2.0 end
        if QTScaleSlider then
            QTScaleSlider:SetValue(QuickTargetsDB.scale)
            if QTScaleEdit then
                QTScaleEdit:SetText(string.format("%.1f", QuickTargetsDB.scale))
            end
        end
        UpdateLayout()
    elseif IsControlKeyDown() then
        if IsShiftKeyDown() then
            QuickTargetsDB.height = QuickTargetsDB.height + (delta * 5)
            if QuickTargetsDB.height < 20 then QuickTargetsDB.height = 20 end
            if QuickTargetsDB.height > 100 then QuickTargetsDB.height = 100 end
            if QTHeightSlider then
                QTHeightSlider:SetValue(QuickTargetsDB.height)
                if QTHeightEdit then
                    QTHeightEdit:SetText(tostring(QuickTargetsDB.height))
                end
            end
        else
            QuickTargetsDB.width = QuickTargetsDB.width + (delta * 10)
            if QuickTargetsDB.width < 150 then QuickTargetsDB.width = 150 end
            if QuickTargetsDB.width > 600 then QuickTargetsDB.width = 600 end
            if QTWidthSlider then
                QTWidthSlider:SetValue(QuickTargetsDB.width)
                if QTWidthEdit then
                    QTWidthEdit:SetText(tostring(QuickTargetsDB.width))
                end
            end
        end
        UpdateLayout()
    end
end)

local RAID_TARGETS = {
    { id = 1, name = "Star" },
    { id = 2, name = "Circle" },
    { id = 3, name = "Diamond" },
    { id = 4, name = "Triangle" },
    { id = 5, name = "Moon" },
    { id = 6, name = "Square" },
    { id = 7, name = "Cross" },
    { id = 8, name = "Skull" },
}

for i, marker in ipairs(RAID_TARGETS) do
    local btn = CreateFrame("Button", "QuickTargetsButton"..i, QT)
    btn:SetSize(ICON_SIZE, ICON_SIZE)
    table.insert(buttons, btn)
    
    local tex = btn:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. marker.id)
    
    btn:SetScript("OnClick", function()
        if not UnitExists("target") then return end
        local current = GetRaidTargetIndex("target")
        if current == marker.id then
            SetRaidTarget("target", 0)
        else
            SetRaidTarget("target", marker.id)
        end
    end)
    
    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(btn, "ANCHOR_TOP")
        GameTooltip:AddLine(L[marker.name])
        GameTooltip:Show()
    end)
    
    btn:SetScript("OnLeave", GameTooltip_Hide)
end

local LockBtn = CreateFrame("Button", nil, QT)
LockBtn:SetSize(16, 16)
LockBtn:SetPoint("RIGHT", QT, "RIGHT", -6, 0)
LockBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

LockBtn.icon = LockBtn:CreateTexture(nil, "ARTWORK")
LockBtn.icon:SetAllPoints()

local function UpdateLockButton()
    if QuickTargetsDB.locked then
        LockBtn.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    else
        LockBtn.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
    end
end

LockBtn:SetScript("OnClick", function()
    QuickTargetsDB.locked = not QuickTargetsDB.locked
    UpdateMouseInteractions()
    UpdateLockButton()
    if QTLockCheck then
        QTLockCheck:SetChecked(QuickTargetsDB.locked)
    end
end)

-- Create styled slider
local function CreateOmenSlider(parent, name, label, minValue, maxValue, defaultValue, step, xPos, yPos, width, onUpdate)
    local frame = CreateFrame("Frame", name, parent)
    frame:SetPoint("TOPLEFT", xPos, yPos)
    frame:SetWidth(width)
    frame:SetHeight(60)
    
    -- Label with gold color
    local labelText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    labelText:SetPoint("TOPLEFT", 0, 0)
    labelText:SetText(label)
    labelText:SetTextColor(1, 0.82, 0, 1)
    
    -- Slider
    local slider = CreateFrame("Slider", name.."Slider", frame, "OptionsSliderTemplate")
    slider:SetPoint("TOP", 0, -18)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetValue(defaultValue)
    slider:SetWidth(width)
    slider:SetHeight(16)
    
    -- Hide default Blizzard text
    getglobal(slider:GetName().."Low"):Hide()
    getglobal(slider:GetName().."High"):Hide()
    getglobal(slider:GetName().."Text"):Hide()
    
    -- Min value - positioned below slider on left
    local minText = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    minText:SetPoint("BOTTOMLEFT", 0, 2)
    minText:SetText(tostring(minValue))
    
    -- Max value - positioned below slider on right
    local maxText = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    maxText:SetPoint("BOTTOMRIGHT", 0, 2)
    maxText:SetText(tostring(maxValue))
    
    -- Edit box for manual input - positioned BELOW min/max values
    local editBox = CreateFrame("EditBox", name.."Edit", frame, "InputBoxTemplate")
    editBox:SetSize(60, 20)
    editBox:SetPoint("TOP", 0, -50)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject("ChatFontNormal")
    editBox:SetText(tostring(defaultValue))
    
    editBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value and value >= minValue and value <= maxValue then
            onUpdate(value)
            slider:SetValue(value)
        else
            self:SetText(tostring(slider:GetValue()))
        end
        self:ClearFocus()
    end)
    
    editBox:SetScript("OnEscapePressed", function(self)
        self:SetText(tostring(slider:GetValue()))
        self:ClearFocus()
    end)
    
    editBox:SetScript("OnEditFocusLost", function(self)
        self:SetText(tostring(slider:GetValue()))
    end)
    
    editBox:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    
    slider:SetScript("OnValueChanged", function(self, value)
        editBox:SetText(tostring(value))
        onUpdate(value)
    end)
    
    return slider, editBox
end

-- Options Panel
local OptionsPanel = CreateFrame("Frame", "QuickTargetsOptionsPanel")
OptionsPanel.name = L["Quick Targets"]

-- Title with gold color
local title = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText(L["Quick Targets"])
title:SetTextColor(1, 0.82, 0, 1)

-- Isengard credit
local isengardLine1 = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
isengardLine1:SetPoint("TOPLEFT", 16, -38)
isengardLine1:SetText(L["Made for Isengard WotLK 3.3.5a"])

local isengardLine2 = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
isengardLine2:SetPoint("TOPLEFT", 16, -52)
isengardLine2:SetText("|cff4a9eff"..L["Website"].."|r")

-- Control hints
local hintTitle = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
hintTitle:SetPoint("TOPLEFT", 16, -72)
hintTitle:SetText("|cffffff00"..L["Scale"].."|r")
hintTitle:SetTextColor(1, 0.82, 0, 1)

local hint1 = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
hint1:SetPoint("TOPLEFT", 16, -88)
hint1:SetText("|cffffff00Ctrl|r + |cffffff00Колёсико мыши|r - изменить ширину")

local hint2 = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
hint2:SetPoint("TOPLEFT", 16, -102)
hint2:SetText("|cffffff00Ctrl|r + |cffffff00Shift|r + |cffffff00Колёсико мыши|r - изменить высоту")

local hint3 = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
hint3:SetPoint("TOPLEFT", 16, -116)
hint3:SetText("|cffffff00Ctrl|r + |cffffff00Shift|r + |cffffff00Alt|r + |cffffff00Колёсико мыши|r - масштаб")

-- Sliders row 1: Scale and Width
local scaleSlider, scaleEdit = CreateOmenSlider(
    OptionsPanel,
    "QTScale",
    L["Scale"],
    0.5, 2.0, QuickTargetsDB.scale, 0.05,
    16, -140, 200,
    function(value)
        QuickTargetsDB.scale = value
        UpdateLayout()
    end
)
QTScaleSlider = scaleSlider
QTScaleEdit = scaleEdit

local widthSlider, widthEdit = CreateOmenSlider(
    OptionsPanel,
    "QTWidth",
    L["Width"],
    150, 600, QuickTargetsDB.width, 10,
    240, -140, 200,
    function(value)
        QuickTargetsDB.width = value
        UpdateLayout()
    end
)
QTWidthSlider = widthSlider
QTWidthEdit = widthEdit

-- Slider row 2: Height
local heightSlider, heightEdit = CreateOmenSlider(
    OptionsPanel,
    "QTHeight",
    L["Height"],
    20, 100, QuickTargetsDB.height, 5,
    16, -210, 200,
    function(value)
        QuickTargetsDB.height = value
        UpdateLayout()
    end
)
QTHeightSlider = heightSlider
QTHeightEdit = heightEdit

-- Lock checkbox
local lockCheck = CreateFrame("CheckButton", "QuickTargetsLockCheck", OptionsPanel, "InterfaceOptionsCheckButtonTemplate")
lockCheck:SetPoint("TOPLEFT", 16, -280)
getglobal("QuickTargetsLockCheckText"):SetText(L["Lock Frame"])
lockCheck:SetScript("OnClick", function(self)
    QuickTargetsDB.locked = self:GetChecked()
    UpdateMouseInteractions()
    UpdateLockButton()
end)
QTLockCheck = lockCheck

InterfaceOptions_AddCategory(OptionsPanel)

-- Right-click menu
local MenuFrame = CreateFrame("Frame", "QuickTargetsMenu", UIParent, "UIDropDownMenuTemplate")

QT:SetScript("OnMouseDown", function(_, button)
    if button ~= "RightButton" then return end
    EasyMenu({
        { text = L["Quick Targets"], isTitle = true, notCheckable = true },
        { text = L["Hide"], notCheckable = true, func = function() QuickTargets_ToggleVisibility() end },
        { text = L["Options"], notCheckable = true, func = function() 
            InterfaceOptionsFrame_OpenToCategory(OptionsPanel) 
            InterfaceOptionsFrame_OpenToCategory(OptionsPanel) 
        end },
    }, MenuFrame, "cursor", 0, 0, "MENU")
end)

-- Init
local InitFrame = CreateFrame("Frame")
InitFrame:RegisterEvent("PLAYER_LOGIN")
InitFrame:SetScript("OnEvent", function()
    UpdateMouseInteractions()
    UpdateLockButton()
    lockCheck:SetChecked(QuickTargetsDB.locked)
    UpdateLayout()
    if QuickTargetsDB.hidden then
        QT:Hide()
    end
end)

-- Slash commands
SLASH_QUICKTARGETS1 = "/qt"
SlashCmdList.QUICKTARGETS = function(msg)
    if not msg or msg == "" then
        QuickTargets_ToggleVisibility()
    elseif msg == "lock" then
        QuickTargetsDB.locked = true
        UpdateMouseInteractions()
        UpdateLockButton()
        lockCheck:SetChecked(true)
    elseif msg == "unlock" then
        QuickTargetsDB.locked = false
        UpdateMouseInteractions()
        UpdateLockButton()
        lockCheck:SetChecked(false)
    elseif msg == "options" or msg == "opt" or msg == "config" then
        InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
        InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
    elseif msg == "reset" then
        QuickTargetsDB.scale = 1.0
        QuickTargetsDB.width = 300
        QuickTargetsDB.height = 35
        QuickTargetsDB.locked = false
        QuickTargetsDB.hidden = false
        QT:ClearAllPoints()
        QT:SetPoint("CENTER")
        SavePosition()
        UpdateLayout()
        UpdateMouseInteractions()
        UpdateLockButton()
        lockCheck:SetChecked(false)
        QT:Show()
    end
end