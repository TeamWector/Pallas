Pallas = {}
Pallas.EventListener = wector.FrameScript:CreateListener()
Pallas.EventListener:RegisterEvent('PLAYER_ENTERING_WORLD')
Pallas.EventListener:RegisterEvent('PLAYER_LEAVING_WORLD')

---@type WoWActivePlayer
Me = {}

function Pallas.EventListener:PLAYER_ENTERING_WORLD(_, isReloadingUi)
  Me = wector.Game.ActivePlayer
  Behavior:Initialize(isReloadingUi)
end

function Pallas.EventListener:PLAYER_LEAVING_WORLD()
  Me = {}
end

function Pallas:Initialize()
  Menu:Initialize()

  Me = wector.Game.ActivePlayer
  if not wector.Game.InWorld or not Me then return end

  print('Initialize Pallas')
  Behavior:Initialize()
end

function Pallas:Shutdown()
  if not Pallas.initialized then return end

  print('Shutdown Pallas')
end

function Pallas:OnUpdate()
  if not wector.Game.InWorld or not Me then return end

  local objects = wector.Game.GameObjects
  for _, o in pairs(objects) do
    if o.Name == "Netherwing Egg" then
      wector.Console:Log("EGG!!!!")
    end
  end

  Combat:Update()
  Heal:Update()
  Tank:Update()

  Behavior:Update()
end

RegisterEvent('OnLoad', Pallas.Initialize)
RegisterEvent('OnUnload', Pallas.Shutdown)
RegisterEvent('OnUpdate', Pallas.OnUpdate)
