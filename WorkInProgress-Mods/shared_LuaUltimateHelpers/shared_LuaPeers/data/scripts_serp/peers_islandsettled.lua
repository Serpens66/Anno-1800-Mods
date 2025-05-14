-- check for every human peer on every IslandSettled if now all peers have an alternative session to switch to
-- so we dont need the help session anymore. Then the help session is unloaded (not earlier, because loading/unloading all the time is increasing the max SessionID)

if g_LuaTools==nil then
  console.startScript("data/scripts_serp/luatools.lua")
end

system.start(function()
  -- wait for everything to initial finish
  while g_ObjectFinderSerp==nil or g_Peer_Tricks_Serp==nil or g_SaveLuaStuff_Serp==nil or g_PeersInfo_Serp==nil or g_PeersInfo_Serp.CoopFinished~=true or g_CoopCountRes==nil or g_CoopCountRes.Finished~=true do
    coroutine.yield()
  end
  local status, err = pcall(g_Peer_Tricks_Serp.t_Unload_EmptySession) 
  if status==false then -- error
    g_LuaTools.modlog("ERROR : "..tostring(err),ModID)
    error(err)
  end
end,"peers_islandsettled.lua Unload_EmptySession")

