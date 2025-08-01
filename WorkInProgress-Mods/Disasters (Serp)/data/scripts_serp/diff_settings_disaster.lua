-- This script gets called with ActionExecuteScript everytime a human hits a "Mod-Settings-Details" Button.
 -- ActionExecuteScript makes the code be executed for all humans, regardless who it the button.
  -- So this is our method to sync the button-hit between all humans (for global settings)
   -- (I tested alot of different methods, and this is by far the best and with the simplest code)

-- (if you dont want to sync a chosen setting to all humans, you dont need lua, simply use xml ConditoinEvent/ObjectBuilt Trigger for each
 -- setting (use subtriggers to safe GUIDs) and do the lock/unlock/unhide in there for the executing human only.
  -- If you still want to use lua without syncing the same setting to all humans, you can use my WhichPlayerCondition mod 
   -- and make one lua script per human, so start Human0-script if it has the human0-unlock and so on and in the script you check
    -- ts.Participants.GetGetCurrentParticipantID()==0 to make sure its only executed for Human0)


-- print("lua script diff_settings_disasters executed")

-- important: lock the chosen asset before unlocking others (because of the default-setting trigger, that chooses default if non is locked)

Setting_GUIDs = {1500005036,1500005037,1500005038,1500005039,1500005040,1500005041,1500005042}
for PID=0,3 do
  for _,Setting_GUID in ipairs(Setting_GUIDs) do
    -- if PID==0 and Setting_GUID==1500005036 then -- testing: we noticed that PlayerCounter (xml and lua) needs ~200ms before being updated after ConditionEvent/ObjectBuilt was fired. So we call this lua script instead on xml-PlayerCounter
      -- print(ts.Participants.GetParticipant(PID).ProfileCounter.Stats.GetCounter(0,0,Setting_GUID,3))
    -- end
    if ts.Participants.GetParticipant(PID).ProfileCounter.Stats.GetCounter(0,0,Setting_GUID,3) > 0 then
      if Setting_GUID==1500005036 then
        ts.Unlock.SetRelockNet(Setting_GUID)
        ts.Unlock.SetUnlockNet(1500005037)
        ts.Unlock.SetUnlockNet(1500005038)
        ts.Unlock.SetUnlockNet(1500005042)
      elseif Setting_GUID==1500005037 then
        ts.Unlock.SetRelockNet(Setting_GUID)
        ts.Unlock.SetUnlockNet(1500005036)
        ts.Unlock.SetUnlockNet(1500005038)
        ts.Unlock.SetUnlockNet(1500005042)
      elseif Setting_GUID==1500005038 then
        ts.Unlock.SetRelockNet(Setting_GUID)
        ts.Unlock.SetUnlockNet(1500005037)
        ts.Unlock.SetUnlockNet(1500005036)
        ts.Unlock.SetUnlockNet(1500005042)
      elseif Setting_GUID==1500005039 then
        ts.Unlock.SetRelockNet(Setting_GUID)
        ts.Unlock.SetUnlockNet(1500005040)
        ts.Unlock.SetUnlockNet(1500005041)
        ts.Unlock.SetUnlockNet(1500005042)
      elseif Setting_GUID==1500005040 then
        ts.Unlock.SetRelockNet(Setting_GUID)
        ts.Unlock.SetUnlockNet(1500005039)
        ts.Unlock.SetUnlockNet(1500005041)
        ts.Unlock.SetUnlockNet(1500005042)
      elseif Setting_GUID==1500005041 then
        ts.Unlock.SetRelockNet(Setting_GUID)
        ts.Unlock.SetUnlockNet(1500005040)
        ts.Unlock.SetUnlockNet(1500005039)
        ts.Unlock.SetUnlockNet(1500005042)
      elseif Setting_GUID==1500005042 then
        ts.Unlock.SetRelockNet(Setting_GUID)
        ts.Unlock.SetUnlockNet(1500005036)
        ts.Unlock.SetUnlockNet(1500005037)
        ts.Unlock.SetUnlockNet(1500005038)
        ts.Unlock.SetUnlockNet(1500005039)
        ts.Unlock.SetUnlockNet(1500005040)
        ts.Unlock.SetUnlockNet(1500005041)
      end
    end
  end
end

-- there is no unhide in lua -.- so register a trigger that unhides everything (does not hurt if sth is already unhidden or unlocked, and we want to show every setting all the time)
ts.Conditions.RegisterTriggerForCurrentParticipant(1500005208)
