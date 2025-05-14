-- called via Trigger 1500005600
local PID = 0


if g_LuaTools==nil then
  console.startScript("data/scripts_serp/luatools.lua")
end

g_AnnoTools.start_thread("fnviatext_.lua","shared_LuaUltimateHelpers_Serp",function()
  -- wait for everything to initial finish
  while g_ObjectFinderSerp==nil or g_SaveLuaStuff_Serp==nil or g_PeersInfo_Serp==nil or g_PeersInfo_Serp.CoopFinished~=true or g_CoopCountRes==nil or g_CoopCountRes.Finished~=true do
    coroutine.yield()
  end
  g_ObjectFinderSerp.FnViaTextEmbed(PID)
end)

