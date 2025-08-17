local Pirate_PID = 17 -- Harlow
local Human_PID = 2 -- Human2

if g_PirateDemand_Serp==nil then
  console.startScript("data/scripts_serp/piratedemand_main.lua")
end

g_PirateDemand_Serp.CheckShipStrength(Human_PID,Pirate_PID)