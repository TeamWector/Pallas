local commonWarrior = {}

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
  local shoutSpell = shoutType == 0 and Spell.BattleShout or Spell.CommandingShout
  -- Manual Cast here because CastEx gets fucked range.
  if not Me:HasAura("Greater Blessing of Might") and not Me:HasAura("Blessing of Might") and (not shoutAura or shoutAura.Remaining < 15 * 1000) and shoutSpell.IsReady and shoutSpell:IsUsable() then
    shoutSpell:Cast(target)
  end

  local demo = Spell.DemoralizingShout
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

    if castorchan and spell and spell.CastStart + 500 < wector.Game.Time and Me:InMeleeRange(u) and Me:IsFacing(u) then
      -- Shield Bash
      if Spell.ShieldBash:CastEx(target) then return false end

      -- Concussion Blow
      if Spell.ConcussionBlow:CastEx(target) then return false end

      -- Pummel
      if Spell.Pummel:CastEx(u) then return false end
    end

    local ut = u.Target
    if u.IsCasting and spell and ut and ut == Me.Guid then
      return true
    end
  end

  return false
end

return commonWarrior
