local Pirate_PID = 17 -- Harlow
local easyQuests = 1500003824
local mediumQuests = 1500003825
local hardQuests = 1500003828
local Human_PID = 0 -- Human0

-- we wont include the shared mod with g_Im_CoopLeader_LuaCoopHelper (shared_LuaCoopLeader, because PopUp sucks), so most of the time it will be nil.
 -- but if the user has it enabled somehow, of course do not allow a value of false.
  -- It is not a big deal if the code is executed for each Coop-Teammate , since unlocking/relocking sth does not hurt to do it multiple times within a second.

if ts.Participants.GetGetCurrentParticipantID()==Human_PID and g_Im_CoopLeader_LuaCoopHelper ~= false then
  local PirateMilitaryShipScore = ts.Participants.GetParticipant(Pirate_PID).Highscore.HighscoreData.GetMilitaryShipScore()
  local HumanMilitaryShipScore = ts.Participants.Current.Highscore.HighscoreData.GetMilitaryShipScore()
  
  if PirateMilitaryShipScore > HumanMilitaryShipScore then
    ts.Unlock.SetUnlockNet(easyQuests)
    if PirateMilitaryShipScore > HumanMilitaryShipScore*1.5 then -- has more than 1.5 times of military ships than player, also enable medium quests
      ts.Unlock.SetUnlockNet(mediumQuests)
    else
      ts.Unlock.SetRelockNet(mediumQuests)
    end
    if PirateMilitaryShipScore > HumanMilitaryShipScore*2 then -- has more than 2 times of military ships than player, also enable hard quests
      ts.Unlock.SetUnlockNet(hardQuests)
    else
      ts.Unlock.SetRelockNet(hardQuests)
    end
  else -- player has more military ships than pirate
    if HumanMilitaryShipScore > PirateMilitaryShipScore*2 then -- if player has twice as much ships than pirate, no demand quests anymore
      ts.Unlock.SetRelockNet(easyQuests)
    else
      ts.Unlock.SetUnlockNet(easyQuests)
    end
    ts.Unlock.SetRelockNet(mediumQuests)
    ts.Unlock.SetRelockNet(hardQuests)
  end
end