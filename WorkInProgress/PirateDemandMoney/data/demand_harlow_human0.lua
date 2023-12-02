
if ts.Unlock.GetIsUnlocked(1500001613) then
  local PirateMilitaryShipScore = ts.Participants.GetParticipant(17).Highscore.HighscoreData.GetMilitaryShipScore()
  local HumanMilitaryShipScore = ts.Participants.Current.Highscore.HighscoreData.GetMilitaryShipScore()
  
  if PirateMilitaryShipScore > HumanMilitaryShipScore then
    math.randomseed( os.time() )
    local randomnumber = math.random()
    -- if PirateMilitaryShipScore <= HumanMilitaryShipScore * 2 then
      -- local relation = (PirateMilitaryShipScore / HumanMilitaryShipScore) - 1 -- number between 0 and 1
      -- if randomnumber <= relation then -- example PirateMilitaryShipScore=200 and HumanMilitaryShipScore=100 then is relation=1 , so if is true
      
    
  end
  ts.Quests.StartQuestForCurrentPlayerNet(1500003826)
  -- console.toggleVisibîlity()
  
end