local Human_PID = 0 -- Human0

if g_LimitedPrefered_Serp==nil then
  console.startScript("data/scripts_serp/limitedpreferred_main.lua")
end

g_LimitedPrefered_Serp._OnProfitMade(Human_PID)
