-- call this via Trigger ActionExecuteScript for one player 
-- (this way it is automatically executed for every peer, which is required for it to not desync)

if g_LTL_Serp==nil then
  console.startScript("data/scripts_serp/lighttools.lua")
end

local From = g_LTL_Serp.PIDs.Second_ai_07_von_Malching.PID
local Towards = g_LTL_Serp.PIDs.Second_ai_04_Smith.PID
local Change = -1 -- -1

ts.Participants.SetChangeParticipantReputationTo(From,Towards, Change)
