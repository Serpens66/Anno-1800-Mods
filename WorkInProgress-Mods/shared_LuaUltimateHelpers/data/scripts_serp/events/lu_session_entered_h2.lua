local PID = 2


if g_LuaTools==nil then
  console.startScript("data/scripts_serp/luatools.lua")
end

g_AnnoTools.start_thread("lu_session_entered.lua","shared_LuaUltimateHelpers_Serp",function()
  while g_ObjectFinderSerp==nil or g_SaveLuaStuff_Serp==nil or g_PeersInfo_Serp==nil or g_PeersInfo_Serp.CoopFinished~=true or g_CoopCountRes==nil or g_CoopCountRes.Finished~=true do
    coroutine.yield()
  end
  local SessionGuid = session.getSessionGUID()
  g_AnnoTools.CallGlobalFnBlocked("g_ObjectFinderSerp.OnIslandSettledSessionEnter",SessionGuid,5000,PID)
end)

