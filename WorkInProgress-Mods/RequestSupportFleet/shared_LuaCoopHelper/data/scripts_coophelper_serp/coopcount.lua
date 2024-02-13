-- unfortunately we don't know a way to find out who the leading player of a coop-team is, to eg. only execute the script once only for this player.
 -- (but one can load a MP game without being the leader, so this would also not really solve it)


-- in coop when executing a script via ActionExecuteScript, the script gets executed for all players and all coop-slots on their own and the result is synced.
 -- that means if you eg. credit an amount of 100 in coop with 2 slots the executing participant will get 2 in total, instead of just one.
-- The purpose of this count function is that you can divide the amount to credit by the number of coop players to roughly get the same amount in total regardless of number of coop players

-- this script is executed via trigger ActionExecuteScript on every SessionEnter (to be sure to catch a savegame loaded, we don't know a better way for this)

-- use the variable 
-- global_CoopCount_Serp
-- in your script (check that it is not nil)

-- checking ts.Online.GetUsername(4) and so on to count the coop players does not work, because it also returns their names even if the game is loaded without them.

-- a function that returns how many coop human players are sharing the local player slot
-- this is achieved by using the coop weakness: every local player, even in the same playerslot is executing the script once (with ActionExecuteScript)
-- and the result is for most script actions synced. So if we credit 1 Ressource in the script, the Human0 will get 3 if it is shared between 3 human players
global_CoopCount_Serp = nil
function GetCoopPlayerCount_Serp()
  local coopcount = nil
  if ts.GameSetup.GetIsMultiPlayerGame() then
    local oldAmount = ts.Economy.MetaStorage.GetStorageAmount(1500004521) -- in theory it would be best to set the amount each time to 0, but there is no SetAmount and AddAmount is executed multiple times
    -- print(oldAmount)
    ts.Economy.MetaStorage.AddAmount(1500004521, 1) -- add 1
    system.waitForGameTimeDelta(1000) -- 100 is too short
    local newAmount = ts.Economy.MetaStorage.GetStorageAmount(1500004521)
    -- print(newAmount)
    coopcount = newAmount - oldAmount
    ts.Economy.MetaStorage.AddAmount(1500004521, -100) -- our product can not get negative, so does not matter how often this is called afterwards, to get it to 0 again (not really needed, just to not have it overflow in really long games)
  else -- singleplayer, no need to check
    coopcount = 1
  end
  -- print(coopcount)
  global_CoopCount_Serp = coopcount
  return coopcount
end

system.start(GetCoopPlayerCount_Serp)
