local PID = 1


if g_LTL_Serp==nil then
  console.startScript("data/scripts_serp/lighttools.lua")
end

g_LTL_Serp.start_thread("lu_session_entered.lua","shared_LuaTools_Medium_Serp",function()
  while g_LTM_Serp==nil do
    coroutine.yield()
  end
  local SessionGuid = session.getSessionGUID()
  g_LTM_Serp.CallGlobalFnBlocked("g_ObjectFinderSerp._OnIslandSettledSessionEnter",SessionGuid,5000,PID)
end)

