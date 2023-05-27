local commonWarrior = {}

--[[ !TODO
  - Better shout logic. We are smart enough to do commanding shout if we have blessing of might even if battle shout is selected!
    Could also do commanding/battle depending on if another warrior is buffing.
]]

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
  {
    type = "checkbox",
    uid = "WarriorCommonTrinket1",
    text = "Use Trinket 1",
    default = false
  },
  {
    type = "checkbox",
    uid = "WarriorCommonTrinket2",
    text = "Use Trinket 2",
    default = false
  },
}

function commonWarrior:DoShout()
  local t1 = Combat.BestTarget
  local t2 = Tank.BestTarget
  local target = t1 and t1 or t2
  if not target then return false end

  -- Battle Shout
  local shoutType = Settings.WarriorCommonShout
  local shoutAura = shoutType == 0 and Me:GetAura("Battle Shout") or Me:GetAura("Commanding Shout")
  local shoutSpell = shoutType == 0 and Spell.BattleShout or Spell.CommandingShout
  if (Me:HasAura("Greater Blessing of Might") or Me:HasAura("Blessing of Might")) and
      not Me:HasAura("Commanding Shout") and Spell.CommandingShout.IsReady and Spell.CommandingShout:IsUsable() then
    Spell.CommandingShout:Cast(target)
    return
  end
  -- Manual Cast here because CastEx gets fucked range.
  if not Me:HasAura("Greater Blessing of Might") and not Me:HasAura("Blessing of Might") and
      (not shoutAura or shoutAura.Remaining < 15 * 1000) and shoutSpell.IsReady and shoutSpell:IsUsable() then
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
  local t1 = Combat.BestTarget
  local t2 = Tank.BestTarget
  local target = t1 and t1 or t2
  if not target then return false end

  -- TODO: Merge these two loops, lazy!

  for _, u in pairs(Combat.Targets) do
    local castorchan = u.IsCastingOrChanneling
    local spell = u.CurrentSpell

    if not u.IsInterruptible then goto continue end

    if castorchan and spell and spell.CastStart + 500 < wector.Game.Time and Me:InMeleeRange(u) and Me:IsFacing(u) then
      -- Concussion Blow
      if Spell.StormBolt:CastEx(u) then return false end

      -- Pummel
      if Spell.Pummel:CastEx(u) then return false end
    end

    ::continue::
    local ut = u.Target
    if u.IsCasting and spell and ut and ut.Guid == Me.Guid then
      return true
    end
  end

  for _, u in pairs(Tank.Targets) do
    local castorchan = u.IsCastingOrChanneling
    local spell = u.CurrentSpell

    if not u.IsInterruptible then goto continue end

    if castorchan and spell and spell.CastStart + 500 < wector.Game.Time and Me:InMeleeRange(u) and Me:IsFacing(u) then
      -- Concussion Blow
      if Spell.StormBolt:CastEx(u) then return false end

      -- Pummel
      if Spell.Pummel:CastEx(u) then return false end
    end

    ::continue::
    local ut = u.Target
    if u.IsCasting and spell and ut and ut.Guid == Me.Guid then
      return true
    end
  end

  return false
end

function commonWarrior:UseTrinkets()
  local items = Me.Equipment

  local trinket1 = items[EquipSlot.Trinket1]
  if Settings.WarriorCommonTrinket1 and trinket1:UseX() then return end

  local trinket2 = items[EquipSlot.Trinket2]
  if Settings.WarriorCommonTrinket2 and trinket2:UseX() then return end
end

return commonWarrior
