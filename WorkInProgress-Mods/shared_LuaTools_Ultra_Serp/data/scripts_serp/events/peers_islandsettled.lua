-- check for every human peer on every IslandSettled if now all peers have an alternative session to switch to
-- so we dont need the help session anymore. Then the help session is unloaded (not earlier, because loading/unloading all the time is increasing the max SessionID)
local ModID = "shared_LuaTools_Ultra_Serp"
if g_LTL_Serp==nil then
  console.startScript("data/scripts_serp/lighttools.lua")
end

g_LTL_Serp.start_thread("peers_islandsettled.lua Unload_EmptySession",ModID,function()
  while _Peer_Tricks_Serp==nil do
    coroutine.yield()
  end
  local status, err = pcall(_Peer_Tricks_Serp.t_Unload_EmptySession) 
  if status==false then -- error
    g_LTL_Serp.modlog("ERROR : "..tostring(err),ModID)
    error(err)
  end
end)

