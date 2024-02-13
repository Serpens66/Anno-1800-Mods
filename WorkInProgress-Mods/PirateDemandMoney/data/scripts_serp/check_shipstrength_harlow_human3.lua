local Pirate_PID = 17 -- Harlow
local easyQuests = 1500003824
local mediumQuests = 1500003825
local hardQuests = 1500003828
local Human_PID = 3 -- Human3

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