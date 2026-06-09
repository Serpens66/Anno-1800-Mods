ts.GameClock.SetSetGameSpeed(1)
ts.Conditions.RegisterTriggerForCurrentParticipant(1999003464) -- notification


-- game will freeze on leaving the MP game if speed is slower than normal (3)
if event.OnLeaveUIState["ChangeGameSpeedMP"] == nil then -- only add it once (per anno game start)
  
  local GameLeft_ID = 63 -- or 170/171, but 63 fits more and they all 3 are shown at the same moments
  -- also when just going to main menu and then back to the game

  local function Do_OnLeaveUIState(UILeft_ID)
    if UILeft_ID == GameLeft_ID then
      if ts.GameSetup.GetIsMultiPlayerGame() then -- singleplayer uses a different system (ts.Pause.DecreaseGameSpeed) and the buttons in menu we dont have any access to.
        ts.GameClock.SetSetGameSpeed(3) -- game will freeze on leaving the MP game if speed is slower
      end
    end
  end
  
  event.OnLeaveUIState[ModID] = function(UILeft_ID)
    local status, err = pcall(Do_OnLeaveUIState,UILeft_ID) -- use seperate function with pcall, because game crashes without lua error, if any error happens in an function called by event. !
    if status==false then -- error
      print(ModID,"ERROR ChangeGameSpeedMP: Function Do_OnLeaveUIState had an error: "..tostring(err))
    end
  end
  
end