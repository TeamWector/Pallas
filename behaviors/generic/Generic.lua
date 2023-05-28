local antiafk = require('behaviors.generic.antiafk.antiafk')
local autoloot = require('behaviors.generic.autoloot.autoloot')
local radar = require('behaviors.generic.radar.radar')

local genericBehaviors = {
  Name = "Generic Behaviors",
  Callbacks = {
    ["antiafk"] = antiafk,
    ["autoloot"] = autoloot,
    ["radar"] = radar,
  }

}

return genericBehaviors
