-- called via Trigger 1500005600
local PID = 0


if g_LTL_Serp==nil then
  console.startScript("data/scripts_serp/lighttools.lua")
end

g_LTL_Serp.start_thread("fnviatext_.lua","shared_LuaUltimateHelpers_Serp",function()
  g_LTL_Serp.FnViaTextEmbed(PID)
end)

