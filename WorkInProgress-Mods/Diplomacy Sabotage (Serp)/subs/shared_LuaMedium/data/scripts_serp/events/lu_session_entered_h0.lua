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

local PID = 0


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

