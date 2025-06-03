local PID = 3


if g_LTL_Serp==nil then
  console.startScript("data/scripts_serp/lighttools.lua")
end

g_LTL_Serp.start_thread("fnviatext_.lua","shared_LuaTools_Light_Serp",function()
  g_LTL_Serp.t_FnViaTextEmbed(PID)
end)

