local colors = {
    white = 0xFFFFFFFF,
    red = 0xFF0000FF,
    black = 0xFF000000,
    green = 0xFF80FF80,
    purple = 0xFF5A0080,
    blue = 0xFFFF0000,
    pink = 0xFFFF00FF,
    yellow = 0xFF00FFFF,
    teal = 0xFFFFFF00,
    gray = 0xFFA0A0A0,
    orange = 0xFF008CFF,
    lightblue = 0xFFFFA07A,
    maroon = 0xFF800000,
    navy = 0xFF000080,
    olive = 0xFF808000,
    silver = 0xFFC0C0C0,
    lime = 0xFF00FF00,
    fuchsia = 0xFFFF00FF,
    aqua = 0xFF00FFFF,
    skyblue = 0xFF87CEEB,
    indigo = 0xFF4B0082,
    turquoise = 0xFF40E0D0,
    coral = 0xFFFF7F50,
    tan = 0xFFD2B48C,
    lavender = 0xFFE6E6FA,
    plum = 0xFFDDA0DD,
    periwinkle = 0xFFCCCCFF,
    khaki = 0xFFF0E68C,
    hotpink = 0xFFFF69B4,
    beige = 0xFFF5F5DC,
    sienna = 0xFFA0522D,
    rosybrown = 0xFFBC8F8F,
    lightgreen = 0xFF90EE90,
    midnightblue = 0xFF191970,
    darkred = 0xFF8B0000,
    darkblue = 0xFF00008B,
    darkgreen = 0xFF006400,
    darkpurple = 0xFF800080,
    darkorange = 0xFFFF8C00,
    lightgrey = 0xFFD3D3D3,
    darkgrey = 0xFFA9A9A9,
    brown = 0xFFA52A2A,
    darkkhaki = 0xFFBDB76B,
    seashell = 0xFFFFF5EE,
    peachpuff = 0xFFFFDAB9,
    deeppink = 0xFFFF1493,
    lightcoral = 0xFFF08080,
    lightyellow = 0xFFFFFFE0,
    lavenderblush = 0xFFFFF0F5,
    mistyrose = 0xFFFFE4E1,
    lightcyan = 0xFFE0FFFF,
    lightpink = 0xFFFFB6C1,
    aliceblue = 0xFFF0F8FF,
    bisque = 0xFFFFE4C4,
    blanchedalmond = 0xFFFFEBCD,
    chartreuse = 0xFF7FFF00,
    dimgray = 0xFF696969,
    lightslategray = 0xFF778899,
    powderblue = 0xFFB0E0E6
}

local trackedObjects = {
    -- Herbs
    { name = "Silverleaf", type = "herb" },
    { name = "Peacebloom", type = "herb" },
    { name = "Earthroot", type = "herb" },
    { name = "Mageroyal", type = "herb" },
    { name = "Briarthorn", type = "herb" },
    { name = "Bruiseweed", type = "herb" },
    { name = "Wild Steelbloom", type = "herb" },
    { name = "Grave Moss", type = "herb" },
    { name = "Kingsblood", type = "herb" },
    { name = "Liferoot", type = "herb" },
    { name = "Fadeleaf", type = "herb" },
    { name = "Goldthorn", type = "herb" },
    { name = "Khadgar's Whisker", type = "herb" },
    { name = "Wintersbite", type = "herb" },
    { name = "Firebloom", type = "herb" },
    { name = "Purple Lotus", type = "herb" },
    { name = "Arthas' Tears", type = "herb" },
    { name = "Sungrass", type = "herb" },
    { name = "Blindweed", type = "herb" },
    { name = "Ghost Mushroom", type = "herb" },
    { name = "Gromsblood", type = "herb" },
    { name = "Dreamfoil", type = "herb" },
    { name = "Golden Sansam", type = "herb" },
    { name = "Mountain Silversage", type = "herb" },
    { name = "Plaguebloom", type = "herb" },
    { name = "Icecap", type = "herb" },
    { name = "Black Lotus", type = "herb" },
    -- Ores
    { name = "Copper Vein", type = "vein" },
    { name = "Tin Vein", type = "vein" },
    { name = "Iron Vein", type = "vein" },
    { name = "Gold Vein", type = "vein" },
    { name = "Mithril Vein", type = "vein" },
    { name = "Truesilver Vein", type = "vein" },
    { name = "Thorium Vein", type = "vein" },
    { name = "Silver Vein", type = "vein" },
    { name = "Ooze Covered Silver Vein", type = "vein" },
    { name = "Ooze Covered Gold Vein", type = "vein" },
    { name = "Ooze Covered Truesilver Vein", type = "vein" },
    { name = "Ooze Covered Mithril Vein", type = "vein" },
    { name = "Ooze Covered Thorium Vein", type = "vein" },
}

local options = {
    Name = "Radar",

    -- widgets
    Widgets = {
        {
            type = "checkbox",
            uid = "ExtraRadar",
            text = "Enable Radar",
            default = false
        },
        {
            type = "checkbox",
            uid = "ExtraRadarTrackGatherable",
            text = "Track Gatherables",
            default = false
        },
        {
            type = "checkbox",
            uid = "ExtraRadarTrackAll",
            text = "Track All Interactables",
            default = false
        },
        {
            type = "checkbox",
            uid = "ExtraRadarTrackRares",
            text = "Track Rares",
            default = false
        },
        {
            type = "checkbox",
            uid = "ExtraRadarDrawLines",
            text = "Draw Lines",
            default = true
        },
        {
            type = "checkbox",
            uid = "ExtraRadarDrawDistance",
            text = "Draw Distance",
            default = false
        }
    }
}

local manuallytracked = {}
local function ManualTrack(name)
    for i, n in pairs(manuallytracked) do
        if n == name then
            table.remove(manuallytracked, i)
            wector.Console:Log("UNTRACKING: " .. name)
            return
        end
    end

    table.insert(manuallytracked, name)
    wector.Console:Log("TRACKING: " .. name)
end

local function IsTracked(name)
    for i, n in pairs(manuallytracked) do
        if n == name then
            return true
        end
    end

    return false
end

RadarListener = wector.FrameScript:CreateListener()
RadarListener:RegisterEvent('CONSOLE_MESSAGE')

-- Easy way of manually adding target i guess..
function RadarListener:CONSOLE_MESSAGE(msg)
    if string.find(msg, "track") then
        if Me.Target then
            ManualTrack(Me.Target.Name)
        end
    end

    if string.find(msg, "cleartracked") then
        wector.Console:Log("Cleared tracked list")
        manuallytracked = {}
    end
end

local function TableContains(value)
    for _, v in pairs(trackedObjects) do
        if string.find(v.name, value) then
            return true, v.type
        end
    end

    return false
end

local onscreen = {}
local offscreen = {}

local function IsOffscreen(object)
    local pos = object.Position
    local finish = World2Screen(Vec3(pos.x, pos.y, pos.z + object.DisplayHeight))
    return finish.x == -1.0 or finish.y == 1.0
end

local function CollectVisuals()
    local objects = wector.Game:GetObjectsByFlag(ObjectTypeFlag.Object)
    local units = wector.Game.Units

    onscreen = {}
    offscreen = {}

    local function AddToScreenList(object)
        local isoffscreen = IsOffscreen(object)
        if isoffscreen then
            table.insert(offscreen, object)
        else
            table.insert(onscreen, object)
        end
    end

    for _, u in pairs(units) do
        local distance = u.Position:DistanceSq(Me.Position)
        local israre = u.Classification == 4
        if distance < 200 and not u.Dead then
            if IsTracked(u.Name) or (israre and Settings.ExtraRadarTrackRares) then
                AddToScreenList(u)
            end
        end
    end

    for _, o in pairs(objects) do
        local distance = o.Position:DistanceSq(Me.Position)
        local interactable = o.DynamicFlags & 0x04 > 1
        if Settings.ExtraRadarTrackGatherable and TableContains(o.Name) and distance < 200 then
            AddToScreenList(o)
        end
        if Settings.ExtraRadarTrackAll and interactable then
            AddToScreenList(o)
        end
    end
end

local function DrawColoredLine(object, thick)
    if not Settings.ExtraRadarDrawLines then return end

    local pos = object.Position
    local start = World2Screen(Me.Position)
    local finish = World2Screen(Vec3(pos.x, pos.y, pos.z + object.DisplayHeight))
    local color = colors.white
    local _, type = TableContains(object.Name)
    local israre = object.IsUnit and object.Classification == 4

    if type == "herb" then
        color = colors.green
    elseif type == "vein" then
        color = colors.orange
    end

    if israre then
        color = colors.purple
    end

    DrawLine(start, finish, color, thick)
end

local function Radar()
    if not Settings.ExtraRadar then return end

    CollectVisuals()

    local add = 1
    local max = 4
    local count = 0
    local mepos = Me.Position
    local text, color, tracked, interactable, israre, textpos

    for _, o in pairs(onscreen) do
        israre = o.IsUnit and o.Classification == 4
        interactable = o.DynamicFlags & 0x04 > 1
        tracked = IsTracked(o.Name)

        if israre then
            text = "[R] " .. o.Name
        elseif interactable then
            text = "[Q] " .. o.Name
        elseif tracked then
            text = "[T] " .. o.Name
        else
            text = o.Name
        end

        if Settings.ExtraRadarDrawDistance then
            text = text .. " [" .. math.floor(Me:GetDistance(o)) .. "yd]"
        end

        textpos = World2Screen(Vec3(o.Position.x, o.Position.y, o.Position.z + o.DisplayHeight + 1))
        color = colors.yellow

        DrawColoredLine(o, 2.0)
        DrawText(textpos, color, text)
    end

    for _, o in pairs(offscreen) do
        if count >= max then break end

        textpos = World2Screen(Vec3(mepos.x, mepos.y, mepos.z + add))
        color = colors.teal
        text = "Not On Screen: " .. o.Name .. ", Distance: " .. math.floor(Me:GetDistance(o)) .. " yards"

        DrawText(textpos, color, text)
        add = add + 0.4
        count = count + 1
    end
end

local behaviors = {
    [BehaviorType.Extra] = Radar
}

wector.Console:Log("Radar Loaded")

return { Options = options, Behaviors = behaviors }
