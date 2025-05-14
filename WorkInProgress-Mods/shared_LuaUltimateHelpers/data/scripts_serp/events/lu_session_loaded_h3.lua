-- This is in MP also already executed while still being in the loading screen (the game starts already then in MP -.-)

-- It should be ok to simply wait for g_ObjectFinderSerp to be finished
 -- Because even if the player goes back to main menu and loads another game and then sits in loading screen,
  -- (then g_ObjectFinderSerp is alreedy defined although being in loading screen), the game is already started then
   -- so it should already be possible to update SessionsParticipants

local PID = 3


system.start(function()
  -- wait for everything to initial finish
  while g_ObjectFinderSerp==nil or g_SaveLuaStuff_Serp==nil or g_PeersInfo_Serp==nil or g_PeersInfo_Serp.CoopFinished~=true or g_CoopCountRes==nil or g_CoopCountRes.Finished~=true do
    coroutine.yield()
  end
  g_ObjectFinderSerp.OnSessionLoaded(PID)
end,"lu_loaded_entered.lua")
