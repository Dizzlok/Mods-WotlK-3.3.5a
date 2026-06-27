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

local QT = CreateFrame("Frame", "QuickTargetsFrame", UIParent)
QT:SetMovable(true)
QT:EnableMouse(true)
QT:EnableMouseWheel(true)
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
    
    local scaleRatio = QuickTargetsDB.width / BASE_WIDTH
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
    if IsControlKeyDown() then
        if IsShiftKeyDown() then
            QuickTargetsDB.height = QuickTargetsDB.height + (delta * 5)
            if QuickTargetsDB.height < 20 then QuickTargetsDB.height = 20 end
            if QuickTargetsDB.height > 100 then QuickTargetsDB.height = 100 end
        else
            QuickTargetsDB.width = QuickTargetsDB.width + (delta * 10)
            if QuickTargetsDB.width < 150 then QuickTargetsDB.width = 150 end
            if QuickTargetsDB.width > 600 then QuickTargetsDB.width = 600 end
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
        GameTooltip:AddLine(marker.name)
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
    QT:EnableMouse(not QuickTargetsDB.locked)
    UpdateLockButton()
end)

local OptionsPanel = CreateFrame("Frame", "QuickTargetsOptionsPanel")
OptionsPanel.name = "Quick Targets"

local title = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Quick Targets")

local scaleLabel = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
scaleLabel:SetPoint("TOPLEFT", 16, -50)
scaleLabel:SetText("Scale:")

local scaleSlider = CreateFrame("Slider", "QuickTargetsScaleSlider", OptionsPanel, "OptionsSliderTemplate")
scaleSlider:SetPoint("TOPLEFT", 16, -70)
scaleSlider:SetOrientation("HORIZONTAL")
scaleSlider:SetMinMaxValues(0.5, 2.0)
scaleSlider:SetValueStep(0.05)
scaleSlider:SetValue(QuickTargetsDB.scale)
scaleSlider:SetWidth(200)
getglobal(scaleSlider:GetName().."Low"):SetText("0.5")
getglobal(scaleSlider:GetName().."High"):SetText("2.0")
scaleSlider:SetScript("OnValueChanged", function(self, value)
    QuickTargetsDB.scale = value
    UpdateLayout()
end)

local widthLabel = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
widthLabel:SetPoint("TOPLEFT", 16, -110)
widthLabel:SetText("Width:")

local widthSlider = CreateFrame("Slider", "QuickTargetsWidthSlider", OptionsPanel, "OptionsSliderTemplate")
widthSlider:SetPoint("TOPLEFT", 16, -130)
widthSlider:SetOrientation("HORIZONTAL")
widthSlider:SetMinMaxValues(150, 600)
widthSlider:SetValueStep(10)
widthSlider:SetValue(QuickTargetsDB.width)
widthSlider:SetWidth(200)
getglobal(widthSlider:GetName().."Low"):SetText("150")
getglobal(widthSlider:GetName().."High"):SetText("600")
widthSlider:SetScript("OnValueChanged", function(self, value)
    QuickTargetsDB.width = value
    UpdateLayout()
end)

local heightLabel = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
heightLabel:SetPoint("TOPLEFT", 16, -170)
heightLabel:SetText("Height:")

local heightSlider = CreateFrame("Slider", "QuickTargetsHeightSlider", OptionsPanel, "OptionsSliderTemplate")
heightSlider:SetPoint("TOPLEFT", 16, -190)
heightSlider:SetOrientation("HORIZONTAL")
heightSlider:SetMinMaxValues(20, 100)
heightSlider:SetValueStep(5)
heightSlider:SetValue(QuickTargetsDB.height)
heightSlider:SetWidth(200)
getglobal(heightSlider:GetName().."Low"):SetText("20")
getglobal(heightSlider:GetName().."High"):SetText("100")
heightSlider:SetScript("OnValueChanged", function(self, value)
    QuickTargetsDB.height = value
    UpdateLayout()
end)

local lockCheck = CreateFrame("CheckButton", "QuickTargetsLockCheck", OptionsPanel, "InterfaceOptionsCheckButtonTemplate")
lockCheck:SetPoint("TOPLEFT", 16, -230)
local lockCheckText = getglobal("QuickTargetsLockCheckText")
if lockCheckText then
    lockCheckText:SetText("Lock Frame")
end
lockCheck:SetScript("OnClick", function(self)
    QuickTargetsDB.locked = self:GetChecked()
    QT:EnableMouse(not QuickTargetsDB.locked)
    UpdateLockButton()
end)

InterfaceOptions_AddCategory(OptionsPanel)

local MenuFrame = CreateFrame("Frame", "QuickTargetsMenu", UIParent, "UIDropDownMenuTemplate")

QT:SetScript("OnMouseDown", function(_, button)
    if button ~= "RightButton" then return end
    EasyMenu({
        { text = "Quick Targets", isTitle = true, notCheckable = true },
        { text = "Hide", notCheckable = true, func = function() QT:Hide() QuickTargetsDB.hidden = true end },
        { text = "Options", notCheckable = true, func = function() 
            InterfaceOptionsFrame_OpenToCategory(OptionsPanel) 
            InterfaceOptionsFrame_OpenToCategory(OptionsPanel) 
        end },
    }, MenuFrame, "cursor", 0, 0, "MENU")
end)

local InitFrame = CreateFrame("Frame")
InitFrame:RegisterEvent("PLAYER_LOGIN")
InitFrame:SetScript("OnEvent", function()
    QT:EnableMouse(not QuickTargetsDB.locked)
    UpdateLockButton()
    lockCheck:SetChecked(QuickTargetsDB.locked)
    UpdateLayout()
    if QuickTargetsDB.hidden then
        QT:Hide()
    end
end)

SLASH_QUICKTARGETS1 = "/qt"
SlashCmdList.QUICKTARGETS = function(msg)
    if not msg or msg == "" then
        if QT:IsShown() then
            QT:Hide()
            QuickTargetsDB.hidden = true
        else
            QT:Show()
            QuickTargetsDB.hidden = false
        end
    elseif msg == "lock" then
        QuickTargetsDB.locked = true
        QT:EnableMouse(false)
        UpdateLockButton()
        lockCheck:SetChecked(true)
    elseif msg == "unlock" then
        QuickTargetsDB.locked = false
        QT:EnableMouse(true)
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
        QT:EnableMouse(true)
        UpdateLockButton()
        lockCheck:SetChecked(false)
        QT:Show()
    end
end