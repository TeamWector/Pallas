local commonWarrior = {}

commonWarrior.spells = {
  -- interrupts
  Pummel = WoWSpell("Pummel"),
  ShieldBash = WoWSpell("Shield Bash"),

  -- shouts
  BattleShout = WoWSpell("Battle Shout"),
  CommandingShout = WoWSpell("Commanding Shout"),
  DemoralizingShout = WoWSpell("Demoralizing Shout"),

  -- shared
  HeroicStrike = WoWSpell("Heroic Strike"),
  Cleave = WoWSpell("Cleave"),
  Whirlwind = WoWSpell("Whirlwind"),
  Execute = WoWSpell("Execute"),
  VictoryRush = WoWSpell("Victory Rush"),
  Hamstring = WoWSpell("Hamstring"),
  Overpower = WoWSpell("Overpower"),
  Rend = WoWSpell("Rend"),
  Bladestorm = WoWSpell("Bladestorm"),

  -- arms
  MortalStrike = WoWSpell("Mortal Strike"),

  -- fury
  BloodThirst = WoWSpell("Bloodthirst"),
  SweepingStrikes = WoWSpell("Sweeping Strikes"),
  Rampage = WoWSpell("Rampage"),

  -- protection
  ConcussionBlow = WoWSpell("Concussion Blow"),
  Devastate = WoWSpell("Devastate"),
  ShieldSlam = WoWSpell("Shield Slam"),
  SpellReflection = WoWSpell("Spell Reflection"),
  ShieldBlock = WoWSpell("Shield Block"),
  Revenge = WoWSpell("Revenge"),
  ThunderClap = WoWSpell("Thunder Clap"),

  -- racial
  Berserking = WoWSpell("Berserking")
}

commonWarrior.widgets = {
  {
    type = "checkbox",
    uid = "WarriorCommonDemo",
    text = "Use Demoralizing Shout",
    default = false
  },
  {
    type = "combobox",
    uid = "WarriorCommonShout",
    text = "Select shout",
    default = 0,
    options = { "Battle Shout", "Commanding Shout" }
  },
}

function commonWarrior:DoShout()
  local target = Combat.BestTarget
  if not target then return false end

  -- Battle Shout
  local shoutType = Settings.WarriorCommonShout
  local shoutAura = shoutType == 0 and Me:GetAura("Battle Shout") or Me:GetAura("Commanding Shout")
  local shoutSpell = shoutType == 0 and self.spells.BattleShout or self.spells.CommandingShout
  -- Manual Cast here because CastEx gets fucked range.
  if not Me:HasAura("Greater Blessing of Might") and not Me:HasAura("Blessing of Might") and (not shoutAura or shoutAura.Remaining < 15 * 1000) and shoutSpell.IsReady and shoutSpell:IsUsable() then
    shoutSpell:Cast(target)
  end

  local demo = self.spells.DemoralizingShout
  if Settings.WarriorCommonDemo and
      target:InMeleeRange(Me.ToUnit) and
      not target:HasVisibleAura("Demoralizing Shout") and
      demo.IsReady and
      demo:IsUsable() then
    demo:Cast(target)
  end
end

---
--- Interrupts melee attackers spell casting if possible, returns true if there is a spell casting on us we cannot interrupt.
---@return boolean doSpellReflect
function commonWarrior:DoInterrupt()
  local target = Combat.BestTarget
  if not target then return false end

  for _, u in pairs(Combat.Targets) do
    local castorchan = u.IsCastingOrChanneling
    local spell = u.CurrentSpell

    if castorchan and spell and Me:InMeleeRange(u) and Me:IsFacing(u) then
      -- Shield Bash
      if self.spells.ShieldBash:CastEx(target) then return false end

      -- Concussion Blow
      if self.spells.ConcussionBlow:CastEx(target) then return false end

      -- Pummel
      if self.spells.Pummel:CastEx(u) then return false end
    end

    local ut = u.Target
    if u.IsCasting and spell and ut and ut == Me.Guid then
      return true
    end
  end

  return false
end

return commonWarrior
