local Human_PID = 1

if g_LimitedPrefered_Serp==nil then
  console.startScript("data/scripts_serp/limitedpreferred_main.lua")
end

g_LimitedPrefered_Serp._UpdateNames(Human_PID)
