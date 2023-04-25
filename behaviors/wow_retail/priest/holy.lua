local common = require("behaviors.wow_retail.priest.common")

local options = {
  Name = "Priest (Holy)",
  Widgets = {
    {
      type = "text",
      uid = "PriestHolyTextST",
      text = ">> SINGLE TARGET HEALS <<",
    },
    {
      type = "slider",
      uid = "HolyInstantFlashHealPct",
      text = "Instant Flash Heal (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolyFlashHealPct",
      text = "Flash Heal (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolyHealPct",
      text = "Heal (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolyLightweaveHealPct",
      text = "Lightweave Heal (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolySerenityPct",
      text = "Word: Serenity (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolyRenewPct",
      text = "Renew (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolyMendingPct",
      text = "PoM (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolyGuardianSpiritPct",
      text = "Guardian Spirit (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolyPowerWordShieldPct",
      text = "PW: Shield (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "checkbox",
      uid = "HolyMendingCD",
      text = "Spread Mending on CD",
      default = false
    },
    {
      type = "text",
      uid = "PriestHolyTextAOE",
      text = ">> AOE HEALS <<",
    },
    {
      type = "slider",
      uid = "HolyCircleOfHealingPct",
      text = "CoH (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolyCircleOfHealingCount",
      text = "CoH Count",
      default = 1,
      min = 1,
      max = 6
    },
    {
      type = "slider",
      uid = "HolyPrayerOfHealingPct",
      text = "PoH (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolyPrayerOfHealingCount",
      text = "PoH Count",
      default = 1,
      min = 1,
      max = 5
    },
    {
      type = "slider",
      uid = "HolySanctifyPct",
      text = "HW: Sanctify (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolySanctifyCount",
      text = "HW: Sanctify Count",
      default = 1,
      min = 1,
      max = 6
    },
    {
      type = "slider",
      uid = "HolyDivineHymnPct",
      text = "Divine Hymn (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolyDivineHymnCount",
      text = "Divine Hymn Count",
      default = 1,
      min = 1,
      max = 10
    },
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local auras = {
  improvedpurify = 390632,
  instantflashheal = 114255,
  lightweaver = 390993
}

local function Dispel()
  local spell = Spell.Purify
  if spell:CooldownRemaining() > 0 then return false end

  if Me:GetAura(auras.improvedpurify) then
    spell:Dispel(true, DispelPriority.Low, WoWDispelType.Magic, WoWDispelType.Disease)
  else
    spell:Dispel(true, DispelPriority.Low, WoWDispelType.Magic)
  end
end

local function Smite(enemy)
  local spell = Spell.Smite

  return spell:CastEx(enemy)
end



local function HolyFire(enemy)
  local spellData = WoWSpell(14914)
  local spell = Spell.HolyFire

  if spellData:CooldownRemaining() > 0 then return false end

  if spell:Apply(enemy) then return true end

  for _, e in pairs(Combat.Targets) do
    if Me:IsFacing(e) and spell:Apply(e) then return true end
  end

  return spell:CastEx(enemy)
end

local function EmpyrealBlaze()
  local spell = Spell.EmpyrealBlaze
  local HolyFireData = WoWSpell(14914)
  if spell:CooldownRemaining() > 0 or HolyFireData:CooldownRemaining() == 0 then return false end

  return spell:CastEx(Me)
end

-- Beta Test For Leap Of Faith on Knockbacks
local function LeapOfFaith()
  local spell = Spell.LeapOfFaith
  if spell:CooldownRemaining() > 0 then return false end

  local friends = WoWGroup:GetGroupUnits()
  for _, friend in pairs(friends) do
    local speed = friend.CurrentSpeed
    if not friend.IsMounted and speed > 200 and spell:CastEx(friend) then
      return true
    end
  end
end

local function HolyWordChastise(enemy)
  local spell = Spell.HolyWordChastise
  if spell:CooldownRemaining() > 0 then return false end

  return spell:CastEx(enemy)
end

local function ShadowWordPain(enemy, explosives)
  local spell = Spell.ShadowWordPain

  for _, e in pairs(Combat.Explosives) do
    if spell:Apply(e) then Me:SetTarget(e) Alert("Killed Explosive", 2) return true end
  end

  if explosives then return end
  if not enemy then return end

  if spell:Apply(enemy) then return true end

  for _, e in pairs(Combat.Targets) do
    if spell:Apply(e) then return true end
  end
end

local function HolyWordSanctify()
  local spell = Spell.HolyWordSanctify
  if spell:CooldownRemaining() > 0 then return false end

  for _, v in pairs(Heal.PriorityList) do
    local friend = v.Unit
    local count, below = Heal:GetMembersAround(friend, 10, Settings.HolySanctifyPct)

    if count >= Settings.HolySanctifyCount then
      if spell:IsUsable() then
        Spell.DivineWord:CastEx(Me)
      end
      if spell:CastEx(friend) then return true end
    end
  end

  return false
end

local function DivineHymn()
  local spell = Spell.DivineHymn
  if spell:CooldownRemaining() > 0 or not Me.InCombat then return false end

  local below, count = Heal:GetMembersBelow(Settings.HolyDivineHymnPct)

  return count >= Settings.HolyDivineHymnCount and spell:CastEx(Me)
end

local function CircleOfHealing()
  local spell = Spell.CircleOfHealing
  if spell:CooldownRemaining() > 0 then return false end

  for _, v in pairs(Heal.PriorityList) do
    local friend = v.Unit
    local count, below = Heal:GetMembersAround(friend, 30, Settings.HolyCircleOfHealingPct)

    if count >= Settings.HolyCircleOfHealingCount and spell:CastEx(friend) then return true end
  end
end

local function PrayerOfHealing()
  local spell = Spell.PrayerOfHealing

  for _, v in pairs(Heal.PriorityList) do
    local friend = v.Unit
    local count, below = Heal:GetMembersAround(friend, 40, Settings.HolyPrayerOfHealingPct)

    if count >= Settings.HolyPrayerOfHealingCount and spell:CastEx(friend) then return true end
  end
end

local function PrayerOfMending(friend)
  local spell = Spell.PrayerOfMending
  if spell:CooldownRemaining() > 0 then return false end

  if Settings.HolyMendingCD then
    local tanks = WoWGroup:GetTankUnits()

    for _, tank in pairs(tanks) do
      if spell:Apply(tank) then return true end
    end
  end

  return friend and friend.HealthPct < Settings.HolyMendingPct and spell:CastEx(friend)
end

local function FlashHeal(friend)
  local spell = Spell.FlashHeal
  local instant = Me:GetAura(auras.instantflashheal)
  local lightweaver = Me:GetAura(auras.lightweaver)

  if lightweaver and lightweaver.Stacks == 2 then return false end

  if instant and friend.HealthPct < Settings.HolyInstantFlashHealPct then
    if spell:CastEx(friend) then return true end
  end

  -- Let's do everything to not waste instant free flash of light.
  if instant and instant.Remaining < 3000 then
    if spell:CastEx(friend) then return true end

    local tanks = WoWGroup:GetTankUnits()
    for _, tank in pairs(tanks) do
      if spell:CastEx(tank) then return true end
    end
  end

  return friend.HealthPct < Settings.HolyFlashHealPct and spell:CastEx(friend)
end

local function HealSpell(friend)
  local spell = Spell.Heal
  local lightweave = Me:GetAura(auras.lightweaver)

  if lightweave and lightweave.Stacks > 0 then
    if friend.HealthPct < Settings.HolyLightweaveHealPct and spell:CastEx(friend) then
      return true
    end

    return false
  end

  return friend.HealthPct < Settings.HolyHealPct and spell:CastEx(friend)
end

local function Renew(friend)
  local spell = Spell.Renew
  return friend.HealthPct < Settings.HolyRenewPct and spell:Apply(friend)
end

local function PowerWordShield(friend)
  local spell = Spell.PowerWordShield
  if spell:CooldownRemaining() > 0 then return false end

  return friend.HealthPct < Settings.HolyPowerWordShieldPct and spell:CastEx(friend)
end

local function HolyWordSerenity(friend)
  local spell = Spell.HolyWordSerenity
  if spell:CooldownRemaining() > 0 then return false end

  local shouldUse = friend.HealthPct < Settings.HolySerenityPct

  if shouldUse and spell:IsUsable() then
    Spell.DivineWord:CastEx(Me)
  end

  return shouldUse and spell:CastEx(friend)
end

local function GuardianSpirit(friend)
  local spell = Spell.GuardianSpirit
  if spell:CooldownRemaining() > 0 then return false end

  return friend.HealthPct < Settings.HolyGuardianSpiritPct and spell:CastEx(friend)
end

local function DivineStar()
  local spell = Spell.DivineStar
  if spell:CooldownRemaining() > 0 then return false end

  local hits = 0

  for _, v in pairs(Heal.PriorityList) do
    local friend = v.Unit

    if Me:GetDistance(friend) <= 27 and Me:IsFacing(friend) then
      hits = hits + 1
    end
  end

  for _, enemy in pairs(Combat.Targets) do
    if Me:GetDistance(enemy) <= 27 and Me:IsFacing(enemy) then
      hits = hits + 1
    end
  end

  return hits > 2 and spell:CastEx(Me)
end

local function PriestHolyDamage()
  local target = Combat.BestTarget
  if not target then return false end
  local lowest = Heal:GetLowestMember()
  local shouldDPS = not lowest or
      lowest.HealthPct >= Settings.HolyFlashHealPct and lowest.HealthPct >= Settings.HolyHealPct

  if not shouldDPS then return false end

  if common:Shadowfiend(target) then return true end
  if DivineStar() then return true end

  if not Me:IsFacing(target) then return false end

  if common:ShadowWordDeath() then return true end
  if common:Mindgames(target) then return true end
  if HolyWordChastise(target) then return true end
  if HolyFire(target) then return true end
  if EmpyrealBlaze() then return true end
  if ShadowWordPain(target) then return true end
  if Smite(target) then return true end
end

local function PriestHoly()
  if Me:IsSitting() or Me.IsMounted or Me:IsStunned() then return end

  common:MovementUpdate()

  local GCD = wector.SpellBook.GCD

  if Me.IsCastingOrChanneling or GCD:CooldownRemaining() > 0 then return end

  if ShadowWordPain(nil, true) then return end
  if common:Fade() then return end
  if common:PowerWordFortitude() then return end
  if common:DesperatePrayer() then return end
  if DivineHymn() then return end
  if common:PowerWordLife() then return end
  if HolyWordSanctify() then return end
  if CircleOfHealing() then return end
  if PrayerOfHealing() then return end

  for _, v in pairs(Heal.PriorityList) do
    local f = v.Unit

    if GuardianSpirit(f) then return end
    if HolyWordSerenity(f) then return end
    if HealSpell(f) then return end
    if FlashHeal(f) then return end
    if PowerWordShield(f) then return end
    if Renew(f) then return end
    if PrayerOfMending(f) then return end
  end

  if PrayerOfMending() then return end
  if Dispel() then return end
  if common:AngelicFeather() then return end
  if common:DispelMagic(DispelPriority.Low) then return end
  if PriestHolyDamage() then return end
end

local behaviors = {
  [BehaviorType.Heal] = PriestHoly,
  [BehaviorType.Combat] = PriestHoly
}

return { Options = options, Behaviors = behaviors }
