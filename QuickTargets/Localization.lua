local L = {}

-- English (default)
L["Quick Targets"] = "Quick Targets"
L["Made for Isengard WotLK 3.3.5a"] = "Made for Isengard WotLK 3.3.5a"
L["Website"] = "https://ezwow.org/"
L["Scale"] = "Scale"
L["Width"] = "Width"
L["Height"] = "Height"
L["Lock Frame"] = "Lock Frame"
L["Star"] = "Star"
L["Circle"] = "Circle"
L["Diamond"] = "Diamond"
L["Triangle"] = "Triangle"
L["Moon"] = "Moon"
L["Square"] = "Square"
L["Cross"] = "Cross"
L["Skull"] = "Skull"
L["Hide"] = "Hide"
L["Options"] = "Options"
L["Show/Hide Panel"] = "Show/Hide Panel"
L["Toggle Frame"] = "Toggle Frame"
L["CTRL_WHEEL_WIDTH"] = "Ctrl + Mouse Wheel - change width"
L["CTRL_SHIFT_WHEEL_HEIGHT"] = "Ctrl + Shift + Mouse Wheel - change height"
L["CTRL_SHIFT_ALT_WHEEL_SCALE"] = "Ctrl + Shift + Alt + Mouse Wheel - scale"

-- Russian
if GetLocale() == "ruRU" then
    L["Quick Targets"] = "Quick Targets"
    L["Made for Isengard WotLK 3.3.5a"] = "Сделано для Isengard WotLK 3.3.5a"
    L["Website"] = "https://ezwow.org/"
    L["Scale"] = "Масштаб"
    L["Width"] = "Ширина"
    L["Height"] = "Высота"
    L["Lock Frame"] = "Зафиксировать панель"
    L["Star"] = "Звезда"
    L["Circle"] = "Круг"
    L["Diamond"] = "Алмаз"
    L["Triangle"] = "Треугольник"
    L["Moon"] = "Луна"
    L["Square"] = "Квадрат"
    L["Cross"] = "Крест"
    L["Skull"] = "Череп"
    L["Hide"] = "Скрыть"
    L["Options"] = "Настройки"
    L["Show/Hide Panel"] = "Показать/Скрыть панель"
    L["Toggle Frame"] = "Показать/Скрыть"
    L["CTRL_WHEEL_WIDTH"] = "Ctrl + Колёсико мыши - изменить ширину"
    L["CTRL_SHIFT_WHEEL_HEIGHT"] = "Ctrl + Shift + Колёсико мыши - изменить высоту"
    L["CTRL_SHIFT_ALT_WHEEL_SCALE"] = "Ctrl + Shift + Alt + Колёсико мыши - масштаб"
end

-- Global binding variables (MUST be global, not local)
BINDING_HEADER_QUICKTARGETS = L["Quick Targets"]
BINDING_NAME_QUICKTARGETS_TOGGLE = L["Toggle Frame"]

QuickTargetsL = L