local options = {
  Name = "Fisherman",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "ExtraFisherman",
      text = "Enable Fisherman",
      default = true
    },
  }
}

local spells = {
  Fishing = WoWSpell("Fishing"),
}
wector.Console:Log('Fisherman: Using spell ' .. spells.Fishing.Id)

FishermanState = {
  Idle = 1,
  Fishing = 2,
  Bobbing = 3,
  LootStarted = 3,
  LootComplete = 4,
}
FishingState = FishermanState.Idle
local fishTime = 0
local fishRnd = 0
local fishStats = {
  Throws = 0,
  Reels = 0,
  StartTime = 0
}

FishermanEvents = wector.FrameScript:CreateListener()

FishermanEvents:RegisterEvent('LOOT_CLOSED')
function FishermanEvents:LOOT_CLOSED()
  if FishingState == FishermanState.LootStarted then
    FishingState = FishermanState.LootComplete
    fishTime = wector.Game.Time
    fishRnd = math.random(200, 500)
    fishStats.Reels = fishStats.Reels + 1
    wector.Console:Log('Fisherman: Loot completed, waiting ' .. fishRnd .. 'ms before recasting')
  end
end

FishermanEvents:RegisterEvent('LOOT_BIND_CONFIRM')
function FishermanEvents:LOOT_BIND_CONFIRM(_)
  if FishingState == FishermanState.LootStarted then
    wector.Console:Log('Fisherman: Waiting for user input before continuing (max 30 minutes)')
    fishTime = wector.Game.Time
    fishRnd = (60 * 1000) * 30
  end
end

local function Fisherman()
  if fishTime + fishRnd > wector.Game.Time then
    return
  end

  local bobber = nil
  local spell = Me.CurrentChannel
  if spell and spell.Name == "Fishing" then
    local objects = wector.Game.GameObjects
    for _, obj in pairs(objects) do
      -- using distance to find out if this is our bobber, because there is no 'owner' field yet :)
      if obj.Name == "Fishing Bobber" and Me.Position:DistanceSq(obj.Position) < 30 then
        bobber = obj
      end
    end
  end

  if FishingState == FishermanState.Idle and bobber then
    wector.Console:Log('Fisherman: Detected bobber, fishing session started')
    FishingState = FishermanState.Fishing
    fishStats.StartTime = wector.Game.Time
  elseif FishingState ~= FishermanState.Idle and Me:IsMoving() then
    wector.Console:Log('Fisherman: Player moved, canceling fishing session')
    wector.Console:Log('Fisherman statistics:')
    wector.Console:Log('\t' .. fishStats.Throws .. ' throws')
    wector.Console:Log('\t' .. fishStats.Reels .. ' reels')
    wector.Console:Log('\t' .. (wector.Game.Time - fishStats.StartTime) / 1000 .. ' seconds')
    FishingState = FishermanState.Idle
    -- This is so it doesn't spam start/end when moving because bobber still exists
    fishTime = wector.Game.Time + 2000
  elseif FishingState == FishermanState.Fishing and bobber and (bobber.Flags & 1) == 1 then
    FishingState = FishermanState.Bobbing
    fishTime = wector.Game.Time
    fishRnd = math.random(200, 500)
    wector.Console:Log('Fisherman: Bobber is bobbing, waiting ' .. fishRnd .. 'ms before interacting')
  elseif FishingState == FishermanState.Bobbing and bobber then
    wector.Console:Log('Fisherman: Interacting with bobber')
    bobber:Interact()
    FishingState = FishermanState.LootStarted
    fishTime = wector.Game.Time
    fishRnd = math.random(200, 500)
  elseif FishingState == FishermanState.LootStarted and fishTime + 3000 < wector.Game.Time then
    wector.Console:Log('Fisherman: Waited 3 second for loot, recasting')
    spells.Fishing:Cast(Me.ToUnit)
    fishStats.Throws = fishStats.Throws + 1
    FishingState = FishermanState.Fishing
  elseif FishingState == FishermanState.LootComplete then
    wector.Console:Log('Fisherman: Recasting fishing')
    spells.Fishing:Cast(Me.ToUnit)
    fishStats.Throws = fishStats.Throws + 1
    FishingState = FishermanState.Fishing
  end
end

local behaviors = {
  [BehaviorType.Extra] = Fisherman
}

return { Options = options, Behaviors = behaviors }
