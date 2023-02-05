local gatherables = require("data.gatherables")
local herbs, ores, treasures = gatherables.herb, gatherables.ore, gatherables.treasure
local colors = require("data.colors")

local objectTypes = {
    herb = colors.green,
    vein = colors.orange,
    treasure = colors.silver
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
            uid = "ExtraRadarTrackHerbs",
            text = "Track Herbs",
            default = false
        },
        {
            type = "checkbox",
            uid = "ExtraRadarTrackOres",
            text = "Track Ores",
            default = false
        },
        {
            type = "checkbox",
            uid = "ExtraRadarTrackTreasures",
            text = "Track Treasures",
            default = false
        },
        {
            type = "checkbox",
            uid = "ExtraRadarTrackAll",
            text = "Track All Quests",
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
    if manuallytracked[name] then
        manuallytracked[name] = nil
        wector.Console:Log("UNTRACKING: " .. name)
    else
        manuallytracked[name] = true
        wector.Console:Log("TRACKING: " .. name)
    end
end

local function IsTracked(name)
    return manuallytracked[name] ~= nil
end

RadarListener = wector.FrameScript:CreateListener()
RadarListener:RegisterEvent('CONSOLE_MESSAGE')

-- Easy way of manually adding target i guess..
function RadarListener:CONSOLE_MESSAGE(msg)
    local isTrackMessage = string.find(msg, "track")
    local isClearTrackedMessage = string.find(msg, "cleartracked")

    if isTrackMessage then
        if Me.Target then
            ManualTrack(Me.Target.Name)
        end
    end

    if isClearTrackedMessage then
        wector.Console:Log("Cleared tracked list")
        manuallytracked = {}
    end
end

local onscreen = {}
local offscreen = {}

local function IsOffscreen(object)
    local pos = object.Position
    local finish = World2Screen(Vec3(pos.x, pos.y, pos.z + object.DisplayHeight))
    return finish.x == -1.0 or finish.y == 1.0
end

local function CollectVisuals()
    local objects = wector.Game.GameObjects
    local units = wector.Game.Units
    local track_herbs = Settings.ExtraRadarTrackHerbs
    local track_ores = Settings.ExtraRadarTrackOres
    local track_treasures = Settings.ExtraRadarTrackTreasures

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

    for _, unit in pairs(units) do
        local distance = unit.Position:DistanceSq(Me.Position)
        local israre = unit.Classification == Classification.Rare
        if distance < 200 and not unit.Dead then
            if IsTracked(unit.Name) or (israre and Settings.ExtraRadarTrackRares) then
                AddToScreenList(unit)
            end
        end
    end

    for _, object in pairs(objects) do
        local distance = object.Position:DistanceSq(Me.Position)
        local interactable = object.DynamicFlags & 0x04 > 1

        if distance > 200 then goto continue end

        if Settings.ExtraRadarTrackAll and interactable then
            AddToScreenList(object)
        end

        local gatherables_list = { herbs, ores, treasures }
        local track_gatherables = { track_herbs, track_ores, track_treasures }

        for index, gatherable in pairs(gatherables_list) do
            if track_gatherables[index] and gatherable[object.EntryId] then
                AddToScreenList(object)
            end
        end
        ::continue::
    end
end

local function DrawColoredLine(object, thick)
    if not Settings.ExtraRadarDrawLines then return end

    local pos = object.Position
    local start = World2Screen(Me.Position)
    local finish = World2Screen(Vec3(pos.x, pos.y, pos.z + object.DisplayHeight))
    local color = colors.white
    local isRare = object.IsUnit and object.Classification == Classification.Rare

    local gatherablesTables = { herbs, ores, treasures }

    for _, gatherables in ipairs(gatherablesTables) do
        local objectType = gatherables[object.EntryId]
        if objectType then
            color = objectTypes[objectType]
        end
    end

    if isRare then
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
        israre = o.IsUnit and o.Classification == Classification.Rare
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
