function WoWGameObject:Interactable()
  return self.DynamicFlags & 0x10 == 0
end
