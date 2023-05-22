---@diagnostic disable: duplicate-set-field

Spell = setmetatable({
        ---@type WoWSpell[]
        Cache = {},
        NullSpell = WoWSpell(0)
    },
        {
            __index = function(tbl, key)
              if tbl.Cache[key] then
                -- fix for cache containing rank 1 spells after relogging
                local spell = tbl.Cache[key]
                local tmp = WoWSpell(spell.Name)
                if tmp.Rank > spell.Rank then
                  -- corrupt cache, update
                  Spell:UpdateCache()
                  wector.Console:Log('Updated corrupt cached')
                end
                return tbl.Cache[key]
              end
              return tbl.NullSpell
            end
        })

local function tchelper(first, rest)
  return first:upper() .. rest:lower()
end

local function fmtSpellKey(name)
  return name:gsub("(%a)([%w_'-]*)", tchelper):gsub("([%s_'%-:(),]+)", "")
end

function Spell:UpdateCache()
  -- reset cache
  Spell.Cache = {}

  -- player spells
  local player_spells = wector.SpellBook.PlayerSpells
  for _, spell in pairs(player_spells) do
    if spell.IsPassive or spell.IsTradeskill then
      goto continue
    end

    local key = fmtSpellKey(spell.Name)
    if not Spell.Cache[key] or Spell.Cache[key].Rank < spell.Rank then
      Spell.Cache[key] = WoWSpell(spell.Id)
    end

    ::continue::
  end

  -- pet spells
  local pet_spells = wector.SpellBook.PetSpells
  for _, spell in pairs(pet_spells) do
    if spell.IsPassive or spell.IsTradeskill then
      goto continue
    end

    local key = fmtSpellKey(spell.Name)
    if not Spell.Cache[key] or Spell.Cache[key].Rank < spell.Rank then
      Spell.Cache[key] = WoWSpell(spell.Id)
    end

    ::continue::
  end

  print(string.format('Cached %d spells', table.length(Spell.Cache)))
end

Spell.EventListener = wector.FrameScript:CreateListener()
Spell.EventListener:RegisterEvent('PLAYER_ENTERING_WORLD')
function Spell.EventListener:LEARNED_SPELL_IN_TAB(_, _, _) Spell:UpdateCache() end

Spell.EventListener:RegisterEvent('LEARNED_SPELL_IN_TAB')
function Spell.EventListener:PLAYER_ENTERING_WORLD(_, _) Spell:UpdateCache() end

RegisterEvent('OnLoad', Spell.UpdateCache)

Spell.EventListener:RegisterEvent('ACTIVE_PLAYER_SPECIALIZATION_CHANGED')
function Spell.EventListener:ACTIVE_PLAYER_SPECIALIZATION_CHANGED() Spell:UpdateCache() end

return Spell
