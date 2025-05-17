local PID = 3



if g_LTL_Serp==nil then
  console.startScript("data/scripts_serp/lighttools.lua")
end

g_LTL_Serp.start_thread("lu_loaded_entered.lua","shared_LuaUltimateHelpers_Serp",function()
  while g_LTM_Serp==nil do
    coroutine.yield()
  end
  g_LTM_Serp.CallGlobalFnBlocked("g_ObjectFinderSerp._OnSessionLoaded",nil,1000,PID)
end)