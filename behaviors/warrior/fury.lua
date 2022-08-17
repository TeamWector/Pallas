local options = {
  -- The sub menu name
  Name = "Warrior (Fury)",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "WarriorFurySweeping",
      text = "Use Sweeping Strikes",
      default = true
    },
    {
      type = "checkbox",
      uid = "WarriorFuryExecute",
      text = "Use Execute",
      default = false
    },
    {
      type = "combobox",
      uid = "WarriorFuryShout",
      text = "Select shout",
      default = 0,
      options = { "Battle Shout", "Commanding Shout" }
    },
    {
      type = "slider",
      uid = "WarriorFuryFiller",
      text = "Use filler (HS/Cleave) Rage%",
      default = 65,
      min = 0,
      max = 100
    },
  }
}

local spells = {
  BattleShout = WoWSpell("Battle Shout"),
  CommandingShout = WoWSpell("Commanding Shout"),
  DemoralizingShout = WoWSpell("Demoralizing Shout"),

  BloodThirst = WoWSpell("Bloodthirst"),
  Whirlwind = WoWSpell("Whirlwind"),
  Execute = WoWSpell("Execute"),
  Rampage = WoWSpell("Rampage"),
  HeroicStrike = WoWSpell("Heroic Strike"),
  Cleave = WoWSpell("Cleave"),
  VictoryRush = WoWSpell("Victory Rush"),
  SweepingStrikes = WoWSpell("Sweeping Strikes"),

  Pummel = WoWSpell("Pummel"),

  -- racial
  Berserking = WoWSpell("Berserking")
}

local function WarriorFuryCombat()
  local target = Combat.BestTarget
  if not target then return end

  local aoe = Combat.EnemiesInMeleeRange > 1

  -- interrupt
  for _, u in pairs(Combat.Targets) do
    local castorchan = u.IsCastingOrChanneling
    local spell = u.CurrentSpell

    -- Pummel
    if castorchan and spell and Me:InMeleeRange(u) and spells.Pummel:CastEx(u) then return end
  end

  -- Battle Shout
  local shoutType = Settings.WarriorFuryShout
  if shoutType == 0 then
    local bs = Me:GetAura("Battle Shout")
    -- Manual Cast here because CastEx gets fucked range.
    if not bs or bs.Remaining < 15 * 1000 and spells.BattleShout.IsReady and spells.BattleShout:IsUsable() then
      spells.BattleShout:Cast(target)
    end
  elseif shoutType == 1 then
    local cs = Me:GetAura("Commanding Shout")
    -- Manual Cast here because CastEx gets fucked range.
    if not cs or cs.Remaining < 15 * 1000 and spells.CommandingShout.IsReady and spells.CommandingShout:IsUsable() then
      spells.CommandingShout:Cast(target)
    end
  end

  -- only melee spells from here on
  if not Me:InMeleeRange(target) then return end

  -- Victory Rush
  if spells.VictoryRush:CastEx(target) then return end

  -- pool rage
  if Me.PowerPct < 30 then return end

  -- Rampage
  if not Me:HasBuff("Rampage") and spells.Rampage:CastEx(target) then return end

  -- Sweeping Strikes
  if aoe and Settings.WarriorFurySweeping and spells.SweepingStrikes:CastEx(target) then return end

  -- Blood Thirst, make sure we cast blood thirst if ready before continuing
  if spells.BloodThirst:CastEx(target) then return end

  -- Whirlwind
  if spells.Whirlwind:CastEx(target) then return end

  -- Execute
  if Settings.WarriorFuryExecute and spells.Execute:CastEx(target) then return end

  local hs_or_cleave = aoe and spells.Cleave or spells.HeroicStrike
  if Me.PowerPct > Settings.WarriorFuryFiller and hs_or_cleave:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = WarriorFuryCombat
}

return { Options = options, Behaviors = behaviors }
