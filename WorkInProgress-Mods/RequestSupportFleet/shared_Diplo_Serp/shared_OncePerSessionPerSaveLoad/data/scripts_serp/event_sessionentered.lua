-- This script is called via xml everytime a savegame was loaded (or back from main menu into game)


g_SessionEnter_Done_serp = {} -- empty this on every savegame load, because we don't know anything about the loaded savegame

-- should also work fine in multiplayer/coop because unlock is not a problem and even if the players are in different sessions, reappling a buff works on all sessions loaded.
 -- but in multiplayer the unlock will be done once per session and per human player (but again: still better than on every SessionEnter)

-- ##############

-- Important info for "event." from the game:
   -- If a function you call within that event causes an error, the game will crash without printing this error to the lua log!
   -- So better always use pcall in them

local ModID = "shared_OncePerSessionPerSaveLoad_Serp"

local OnSessionEnter_serp = OnSessionEnter_serp or function()
  local S_ID = session.getSessionGUID()
  S_ID = tostring(S_ID)
  if S_ID~=nil and S_ID~="" and S_ID~="nil" and S_ID~="180039" then -- 180039 is the worldmap
    if g_SessionEnter_Done_serp[S_ID] == nil then
      g_SessionEnter_Done_serp[S_ID] = true
      ts.Unlock.SetUnlockNet(1500004530)
    end
  end
end
if event.OnSessionEnter[ModID] == nil then -- only add it once
  event.OnSessionEnter[ModID] = function()
    local status, err = pcall(OnSessionEnter_serp) -- use seperate function with pcall, because game crashes without lua error, if any error happens in an function called by event. !
    if status==false then -- error
      print(ModID,"ERROR OnSessionEnter: Function OnSessionEnter_serp had an error: "..tostring(err))
    end
  end
end
-- first time executing we already entered a session without having the event OnSessionEnter registered, so execute it once here
-- info: OnSessionEnter is NOT executed on loading a savegame and thus jumping into the current session.
 -- so we need to execute OnSessionEnter_serp once per game loaded (whenever this script gets called), so adding a call outside of the event.OnSessionEnter-if-condition:
OnSessionEnter_serp()
