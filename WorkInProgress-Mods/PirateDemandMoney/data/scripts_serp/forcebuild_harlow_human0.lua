-- wird doch nicht gebraucht, siehe forcebuild_harlow.lua

local Human_PID = 0 -- Human0
local Pirate_PID = 17 -- Harlow
local numberofships = 4


local function round(number, digit_position) 
  local precision = 10^digit_position
  number = number + (precision / 2)
  return math.floor(number / precision) * precision
end

local function ForceBuildShip()
  for i=1,numberofships,1 do 
    ts.SessionParticipants.GetParticipant(Pirate_PID).Trader.ForceBuild()
    system.waitForGameTimeDelta(5000) -- we can not ForceBuild more than one time per GameTick, so shortly wait between the calls (could use coroutine.yield(), but waiting some seconds is better so ships do not stack)
  end
end

if ts.Participants.GetGetCurrentParticipantID() == Human_PID and g_Im_CoopLeader_LuaCoopHelper ~= false then
  if g_Im_CoopLeader_LuaCoopHelper ~= true and global_CoopCount_Serp ~= nil and global_CoopCount_Serp > 1 then -- reduce number of ships spawned based on amount of coop players in the same team (because each of them is executing the script)
    numberofships = math.max(round(numberofships / global_CoopCount_Serp, 0), 1) -- but at least 1
  end
  system.start(ForceBuildShip)
end

-- we want to spawn x ships per human participant (at least in the spawnshipsifweaker trigger). So in theory we could execute this script in a trigger running for all players and simply
 -- run the cide here just for human0 to have this effect, without the need to differentiate for which human is curenntly executing the script.
  -- but what if Human0 was already defeated and left the game? Then this does not work, so we have to make a script for each Human Participant instead
  
-- we wont include the shared mod with g_Im_CoopLeader_LuaCoopHelper (shared_LuaCoopLeader, because PopUp sucks), so most of the time it will be nil.
 -- but if the user has it enabled somehow, of course do not allow a value of false and no need to round if it is true.
 -- if it is not enabled, we will reduce the number of spawned ships with help of global_CoopCount_Serp from mod shared_LuaCoopCounter