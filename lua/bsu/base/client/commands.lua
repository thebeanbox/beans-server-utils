-- base/client/commands.lua

-- create the concommand
concommand.Add("bsu",
  function(_, _, args, argStr)
    local name = args[1]
    if not name then return end
    local cmd = BSU.GetCommandByName(name)

    if cmd and not cmd.sv then
      BSU.RunCommand(name, string.sub(argStr, #name + 2))
    else
      LocalPlayer():ConCommand("_bsu " .. argStr)
    end
  end,
  function(_, args)
    --[[local name = args[1]
    if not name then return end
    local cmd = BSU.GetCommandByName(name)
    
    if cmd then
      return {}
    else
      local autocomplete = {}
      local names = {}
      -- this don't work, pls fix
      for _, v in ipairs(table.GetKeys(BSU._cmds)) do
        if v == string.sub(name, 0, #v) then
          table.insert(names, v)
        end
      end
      table.sort(names, function(a, b) return #a <= #b end)
      for _, v in ipairs(names) do
        table.insert("bsu " .. v)
      end
      return autocomplete
    end]]
  end
)