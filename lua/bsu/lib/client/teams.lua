-- lib/client/teams.lua

function BSU.SetupTeams(teams)
  for k, v in ipairs(teams) do
    team.SetUp(k, v.name, v.color)
  end
end