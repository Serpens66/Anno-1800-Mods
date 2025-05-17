-- This is in MP also already executed while still being in the loading screen (the game starts already then in MP -.-)

-- It should be ok to simply wait for g_ObjectFinderSerp to be finished
 -- Because even if the player goes back to main menu and loads another game and then sits in loading screen,
  -- (then g_ObjectFinderSerp is alreedy defined although being in loading screen), the game is already started then
   -- so it should already be possible to update SessionsParticipants

local PID = 0



if g_LTL_Serp==nil then
  console.startScript("data/scripts_serp/lighttools.lua")
end

g_LTL_Serp.start_thread("lu_loaded_entered.lua","shared_LuaUltimateHelpers_Serp",function()
  while g_LTM_Serp==nil do
    coroutine.yield()
  end
  g_LTM_Serp.CallGlobalFnBlocked("g_ObjectFinderSerp._OnSessionLoaded",nil,1000,PID)
end)