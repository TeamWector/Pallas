local function BalanceHeal()

end

local function BalanceCombat()

end

return {
  [BehaviorType.Heal] = BalanceHeal,
  [BehaviorType.Combat] = BalanceCombat
}
