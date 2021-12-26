-- lib/client/groups.lua

function BSU.PopulateTeams(teams)
  for k, v in ipairs(teams) do
    team.SetUp(k, v.name, v.color)
  end
end