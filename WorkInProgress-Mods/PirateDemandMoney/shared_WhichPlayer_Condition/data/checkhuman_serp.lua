-- since we save the result in the unlocks, it is enough to call this once per game (but code is lightweight, so not big problem if called on every SessionLoaded)
local PID = ts.Participants.GetGetCurrentParticipantID() -- yes GetGet...
if PID==0 and not ts.Unlock.GetIsUnlocked(1500001613) then
  ts.Unlock.SetUnlockNet(1500001613)
elseif PID==1 and not ts.Unlock.GetIsUnlocked(1500001614) then
  ts.Unlock.SetUnlockNet(1500001614)
elseif PID==2 and not ts.Unlock.GetIsUnlocked(1500001615) then
  ts.Unlock.SetUnlockNet(1500001615)
elseif PID==3 and not ts.Unlock.GetIsUnlocked(1500001616) then
  ts.Unlock.SetUnlockNet(1500001616)
end


