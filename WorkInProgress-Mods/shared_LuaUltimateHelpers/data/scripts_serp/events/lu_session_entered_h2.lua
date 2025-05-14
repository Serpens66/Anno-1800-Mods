-- IslandSettled wird auch bei Übernahme einer Insel getriggert. Übernahme einer Insel geht auch, wenn Spieler gerade in anderer Session ist.. was bei lua schwierig ist ..(aber dennoch besser als nichts) -->
-- und auch bei Spielstart mit startinseln wirds einmal getriggert -->
-- regardless who settles, we want the script to be executed for every human, because every human should save eg. the kontor OID from every settled island, regardless who owns it -->
-- Problem:
-- the local player can only loop through areas in his currently active session.
 -- so if another player/AI settles in another session, we wont find any new areas in our session...
-- So at least for human players it makes sense to share the information (Kontor OID)
 -- but it may take a while until a human player gets the AI islands

-- In addition to IslandSettled we will also use SessionEnter Event.
-- This is fired quite often, but the function we use is very efficient for the current active Session, so it is fine I think.

local PID = 2

system.start(function()
  -- wait for everything to initial finish
  while g_ObjectFinderSerp==nil or g_SaveLuaStuff_Serp==nil or g_PeersInfo_Serp==nil or g_PeersInfo_Serp.CoopFinished~=true or g_CoopCountRes==nil or g_CoopCountRes.Finished~=true do
    coroutine.yield()
  end
  g_ObjectFinderSerp.OnIslandSettledSessionEnter(PID)
end,"lu_session_entered.lua")
