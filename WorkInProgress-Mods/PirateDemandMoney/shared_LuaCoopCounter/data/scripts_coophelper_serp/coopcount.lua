  -- use variable
   -- global_CoopCount_Serp
  -- to get how many coop players are in the coop-team of the executing local players.
  -- it will be 1 for singleplayer games
   -- Important:
    -- if you start your script OnSessionEnter, make sure to add a small delay, at least 2 seconds, to make sure my script ran first to set this variable


-- ######################

-- unfortunately we don't know a way to find out who the leading player of a coop-team is, to eg. only execute the script once only for this player.
 -- (but one can load a MP game without being the leader, so this would also not really solve it)

-- in coop when executing a script via ActionExecuteScript, the script gets executed for all players and all coop-slots on their own and the result is synced.
 -- that means if you eg. credit an amount of 100 in coop with 2 slots the executing participant will get 2 in total, instead of just one.
-- The purpose of this count function is that you can divide the amount to credit by the number of coop players to roughly get the same amount in total regardless of number of coop players

-- this script is executed via trigger ActionExecuteScript on every SessionEnter (to be sure to catch a savegame loaded, we don't know a better way for this)


-- checking ts.Online.GetUsername(4) and so on to count the coop players does not work, because it also returns their names even if the game is loaded without them.

-- a function that returns how many coop human players are sharing the local player slot
-- this is achieved by using the coop weakness: every local player, even in the same playerslot is executing the script once (with ActionExecuteScript)
-- and the result is for most script actions synced. So if we credit 1 Ressource in the script, the Human0 will get 3 if it is shared between 3 human players
function g_CheckCoopPlayerCount_Serp()
  local oldAmount = ts.Economy.MetaStorage.GetStorageAmount(1500004521) -- in theory it would be best to set the amount each time to 0, but there is no SetAmount and AddAmount is executed multiple times
  -- print(oldAmount)
  ts.Economy.MetaStorage.AddAmount(1500004521, 1) -- add 1
  system.waitForGameTimeDelta(1000) -- 100 is too short
  local newAmount = ts.Economy.MetaStorage.GetStorageAmount(1500004521)
  -- print(newAmount)
  global_CoopCount_Serp = newAmount - oldAmount
  ts.Economy.MetaStorage.AddAmount(1500004521, -100) -- our product can not get negative, so does not matter how often this is called afterwards, to get it to 0 again (not really needed, just to not have it overflow in really long games)
end


-- using shared_LuaOnGameLoaded to make sure code only triggers once per loading a savegame, not once every SessionEnter (just bit better performance):
-- enter your ModID here for unqiue identifier. Change the content of "OnSaveGameLoad" to your liking.
local ModID = "shared_LuaCoopCounter_Serp"
local function OnSaveGameLoad()
  if ts.GameSetup.GetIsMultiPlayerGame() then
    local PID = ts.Participants.GetGetCurrentParticipantID() -- dont using fn IsCoopTeam_serp here, because we can only use global stuff here and I dont want to make it global. because other mods should use the same fn without needed to wait for lua load of another mod (by using a local version themself)
    if (PID == 0 and (ts.Online.GetUsername(4)~="" or ts.Online.GetUsername(8)~="" or ts.Online.GetUsername(12)~="")) or -- Checking GetUsername does not help to count the current number of active coop players, because they are also returned if the game is loaded without them!
      (PID == 1 and (ts.Online.GetUsername(5)~="" or ts.Online.GetUsername(9)~="" or ts.Online.GetUsername(13)~="")) or
      (PID == 2 and (ts.Online.GetUsername(6)~="" or ts.Online.GetUsername(10)~="" or ts.Online.GetUsername(14)~="")) or 
      (PID == 3 and (ts.Online.GetUsername(7)~="" or ts.Online.GetUsername(11)~="" or ts.Online.GetUsername(15)~="")) then
      system.start(g_CheckCoopPlayerCount_Serp)
    else -- can not be a coop team
      global_CoopCount_Serp = 1
    end
  else -- singleplayer, no need to check
    global_CoopCount_Serp = 1
  end
end
g_saveloaded_events_serp = g_saveloaded_events_serp or {} -- global table where mods can add their functions to (define it if it does not exist yet)
if g_saveloaded_events_serp~=nil and g_saveloaded_events_serp[ModID]==nil then -- do not change these lines, just copy paste
  g_saveloaded_events_serp[ModID] = OnSaveGameLoad
end
