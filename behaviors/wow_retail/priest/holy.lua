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
  instantflashheal = 114255
}

local function Dispel()
  local spell = Spell.Purify
  if spell:CooldownRemaining() > 0 then return false end

  if Me:GetAura(auras.improvedpurify) then
    spell:Dispel(true, WoWDispelType.Magic, WoWDispelType.Disease)
  else
    spell:Dispel(true, WoWDispelType.Magic)
  end
end

local function Smite(enemy)
  local spell = Spell.Smite

  return spell:CastEx(enemy)
end

local function Shadowfiend(enemy)
  local spell = Spell.Shadowfiend
  if spell:CooldownRemaining() > 0 then return false end

  local TTD = Combat:TargetsAverageDeathTime()

  return TTD ~= 9999 and TTD > 20 and Me.PowerPct < 85 and spell:CastEx(enemy)
end

local function HolyFire(enemy)
  local spellData = WoWSpell(14914)
  local spell = Spell.HolyFire

  if spellData:CooldownRemaining() > 0 then return false end

  if spell:Apply(enemy) then return true end

  for _, e in pairs(Combat.Targets) do
    if spell:Apply(e) then return true end
  end
end

local function ShadowWordPain(enemy)
  local spell = Spell.ShadowWordPain

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
      spell:CastEx(friend)
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

  if instant and friend.HealthPct < Settings.HolyInstantFlashHealPct then
    if spell:CastEx(friend) then return true end
  end

  if instant and instant.Remaining < 3000 then
    if spell:CastEx(friend) then return true end
  end

  return friend.HealthPct < Settings.HolyFlashHealPct and spell:CastEx(friend)
end

local function HealSpell(friend)
  local spell = Spell.Heal
  return friend.HealthPct < Settings.HolyHealPct and spell:CastEx(friend)
end

local function Renew(friend)
  local spell = Spell.Renew
  return friend.HealthPct < Settings.HolyRenewPct and spell:Apply(friend)
end

local function HolyWordSerenity(friend)
  local spell = Spell.HolyWordSerenity
  if spell:CooldownRemaining() > 0 then return false end

  return friend.HealthPct < Settings.HolySerenityPct and spell:CastEx(friend)
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
  local GCD = wector.SpellBook.GCD
  local lowest = Heal:GetLowestMember()
  local shouldDPS = not lowest or
      lowest.HealthPct >= Settings.HolyFlashHealPct and lowest.HealthPct >= Settings.HolyHealPct

  if GCD:CooldownRemaining() > 0 or not shouldDPS then return false end

  if Shadowfiend(target) then return true end
  if DivineStar() then return true end
  if HolyFire(target) then return true end
  if ShadowWordPain(target) then return true end
  if Smite(target) then return true end
end

local function PriestHoly()
  if Me:IsSitting() or Me.IsMounted or Me:IsStunned() then return end

  common:MovementUpdate()

  if Me.IsCastingOrChanneling then return end

  if common:Fade() then return end
  if common:PowerWordFortitude() then return end
  if common:DesperatePrayer() then return end
  if DivineHymn() then return end
  if HolyWordSanctify() then return end
  if CircleOfHealing() then return end
  if PrayerOfHealing() then return end

  for _, v in pairs(Heal.PriorityList) do
    local f = v.Unit

    if GuardianSpirit(f) then return end
    if HolyWordSerenity(f) then return end
    if FlashHeal(f) then return end
    if HealSpell(f) then return end
    if Renew(f) then return end
    if PrayerOfMending(f) then return end
  end

  if PrayerOfMending() then return end
  if Dispel() then return end
  if common:AngelicFeather() then return end
  if PriestHolyDamage() then return end
end

local behaviors = {
  [BehaviorType.Heal] = PriestHoly,
  [BehaviorType.Combat] = PriestHoly
}

return { Options = options, Behaviors = behaviors }
