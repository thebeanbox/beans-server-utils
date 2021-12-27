--[[
  Shared file for setting up the prop protection table
]]

BSU.PropProtection = {
  Permissions = {
    ["Physgun"] = {
      realName = "physgun",
      index = 1,
    },
    ["Gravgun"] = {
      realName = "gravgun",
      index = 2,
    },
    ["Toolgun"] = {
      realName = "toolgun",
      index = 3,
    },
    ["Use"] = {
      realName = "use",
      index = 4,
    },
    ["Player Pickup"] = {
      realName = "playerpickup",
      index = 5,
    }
  }
}

if SERVER then
  BSU.PropProtection.Players = {}
  BSU.PropProtection.Props = {}
end