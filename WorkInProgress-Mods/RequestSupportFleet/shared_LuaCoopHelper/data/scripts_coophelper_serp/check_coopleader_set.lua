
-- using ts.Online.GetUsername(peer int) to find out if coop slots are used (0 to 3 are normal slots, all others are coop slots. should be enough to check 4 to 7, because these will be for sure occupied if higher slots are occupied too)
-- is not occupied it returns an empty string
function IsCoopTeam_serp()
  local PID = ts.Participants.GetGetCurrentParticipantID()
  if PID == 0 then -- first coop team
    if ts.Online.GetUsername(4)~="" or ts.Online.GetUsername(8)~="" or ts.Online.GetUsername(12)~="" then
      return true
    end
  elseif PID == 1 then
    if or ts.Online.GetUsername(5)~="" or ts.Online.GetUsername(9)~="" or ts.Online.GetUsername(13)~="" then
      return true
    end
  elseif PID == 2 then
    if ts.Online.GetUsername(6)~="" or ts.Online.GetUsername(10)~="" or ts.Online.GetUsername(14)~="" then
      return true
    end
  elseif PID == 3 then
    if ts.Online.GetUsername(7)~="" or ts.Online.GetUsername(11)~="" or ts.Online.GetUsername(15)~="" then
      return true
    end
  end
  return false
  -- return true -- testing
end

if g_Im_CoopLeader_LuaCoopHelper==nil then
  if IsCoopTeam_serp() then
    -- print("is Coop")
    ts.Conditions.RegisterTriggerForCurrentParticipant(1500004529) -- start the PopUp
  else
    -- print("not Coop")
    console.startScript("data/scripts_coophelper_serp/yes_im_coopleader.lua")
  end
end

-- print(g_Im_CoopLeader_LuaCoopHelper)

