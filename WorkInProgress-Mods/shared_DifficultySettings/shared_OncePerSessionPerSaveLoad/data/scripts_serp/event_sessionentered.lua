-- This script is called via xml everytime a savegame was loaded (or back from main menu into game)


g_SessionEnter_Done_serp = {} -- empty this on every savegame load, because we don't know anything about the loaded savegame

-- should also work fine in multiplayer/coop because unlock is not a problem and even if the players are in different sessions, reappling a buff works on all sessions loaded.
 -- but in multiplayer the unlock will be done once per session and per human player (but again: still better than on every SessionEnter)

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
if event.OnSessionEnter["shared_OncePerSession_Serp"] == nil then -- only add it once
  event.OnSessionEnter["shared_OncePerSession_Serp"] = OnSessionEnter_serp
end
-- first time executing we already entered a session without having the event OnSessionEnter registered, so execute it once here
-- info: OnSessionEnter is NOT executed on loading a savegame and thus jumping into the current session.
 -- so we need to execute OnSessionEnter_serp once per game loaded (whenever this script gets called), so adding a call outside of the event.OnSessionEnter-if-condition:
OnSessionEnter_serp()
