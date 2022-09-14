Spell = setmetatable({
  ---@type WoWSpell[]
  Cache = {},
  NullSpell = WoWSpell(0)
},
{
  __index = function(tbl, key)
    if tbl.Cache[key] then return tbl.Cache[key] end
    return tbl.NullSpell
  end
})

local function tchelper(first, rest)
  return first:upper()..rest:lower()
end

local function fmtSpellKey(name)
  return name:gsub("(%a)([%w_'-]*)", tchelper):gsub("([%s_'%-:()]+)", "")
end

function Spell:UpdateCache()
  -- reset cache
  Spell.Cache = {}

  -- player spells
  for _, spell in pairs(wector.SpellBook.PlayerSpells) do
    local key = fmtSpellKey(spell.Name)
    if not Spell.Cache[key] or Spell.Cache[key].Rank < spell.Rank then
      Spell.Cache[key] = WoWSpell(spell.Id)
    end
  end

  -- pet spells
  for _, spell in pairs(wector.SpellBook.PetSpells) do
    local key = fmtSpellKey(spell.Name)
    if not Spell.Cache[key] or Spell.Cache[key].Rank < spell.Rank then
      Spell.Cache[key] = WoWSpell(spell.Id)
    end
  end

  print(string.format('Cached %d spells', table.length(Spell.Cache)))
end

Spell.EventListener = wector.FrameScript:CreateListener()
Spell.EventListener:RegisterEvent('LEARNED_SPELL_IN_TAB')
Spell.EventListener:RegisterEvent('PLAYER_ENTERING_WORLD')
function Spell.EventListener:LEARNED_SPELL_IN_TAB(_, _, _) Spell:UpdateCache() end
function Spell.EventListener:PLAYER_ENTERING_WORLD(_, _) Spell:UpdateCache() end

RegisterEvent('OnLoad', Spell.UpdateCache)

return Spell
