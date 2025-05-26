  -- TODO: -->
   -- um random item den schiffen mitzugeben, kann ich auch InitSlotItems mit ReardPool nutzen (drauf achten, dass kein EmptyRewardPool verlinkt ist, weil das unsichtbares items spawned) -->
  
-- TODO Wchtig:
 -- alle start_thread Aufrufe in allen lua mods durchgehen und evtl. 
  -- die identifier strings einzigartiger machen!
  -- Also zb PID/TargetPID mit reinnehmen, falls dieser Thread auch für untersch Zeiel zeitgleich laufen können soll!!
  


local ModID = "RequestSupportFleet_Serp" -- used for logging

if g_LuaScriptBlockers[ModID]==nil then
    
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    

    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end
    
    g_LTL_Serp.modlog("supportfleet.lua registered",ModID)
    
    
    
    -- #####################################################################################################
    -- #####################################################################################################
    
    -- called via ActionExecuteScript when the player build the helper object to request fleet
     -- we can get the TargetPID by checking which one is currently locked
      -- is executed for all coop peers!
      -- using helper g_CoopCountResSerp.ContinueWithTotalChanceCoop(totalchance) to unlock with a total chance, regardless how many coop peers are executing this function
    local function _OnFleetRequested(PID,fleetname)
      local continue = g_LTM_Serp.ContinueCoopCalled()
      if continue then
        local TargetPID = g_DiploActions_Serp.GetDiploSelectedPID()
        local totalchance = 0 
        local IsThirdParty = TargetPID==g_LTL_Serp.PIDs.Third_party_01_Queen.PID or g_LTM_Serp.IsThirdPartyTrader(TargetPID)
        if not IsThirdParty or TargetPID == g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID  or TargetPID == g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID then -- 2nd party or pirate
          totalchance = ts.Participants.GetParticipantReputationTo(TargetPID, PID)/100 -- get opinion from TargetPID towards PID
        else -- IsThirdParty like Blake and Nate or Queen. for these we dont have a relevant Reputation
          totalchance = 0.8 -- TODO think about what proper chances might be and what could influence them
        end
        local requestsuccess = false
        if continue=="IsFirst" then -- only executed for first coop peer
          if math.random() < totalchance then -- should not use ContinueWithTotalChanceCoop here
            requestsuccess = true
          end
        else -- executed for all coop peers
          if g_CoopCountResSerp.ContinueWithTotalChanceCoop(totalchance) then
            requestsuccess = true
          end
        end
        if requestsuccess then
          g_SupportFleet_Serp._CheckWhichShips(PID,TargetPID,IsThirdParty)
        end
        g_LTL_Serp.start_thread("WaitForSupportQuest "..tostring(PID)..tostring(TargetPID),ModID,function()
          system.waitForGameTimeDelta(700) -- wait for the Quest to start. it is started without waittime and after ~1 second it shows the "request success" message. So waittime between 500 and 900 ms should be good
          local QuestDescriptionTextGUID = g_SupportFleet_Serp.SupportFleetQuestGuids[fleetname][TargetPID]
          local QuestIndices = g_LTL_Serp.GetActiveQuestInstances(QuestDescriptionTextGUID)
          local last_QID = table.remove(QuestIndices) -- last entry is the newest running instance of this quest (normally its only one, but just in case we want to allow multiple at once)
          if last_QID~=nil then
            if requestsuccess then
              ts.Quests.GetQuest(last_QID).ToggleForceQuestTrackerVisibility()
              g_LTL_Serp.modlog("_OnFleetRequested keep quest active and show it "..tostring(QuestDescriptionTextGUID),ModID)
            else
              ts.Quests.GetQuest(last_QID).SetAbortedNet(false,1) -- SetAbortedNet(bool_isManually,int_QuestAbortReason)
              g_LTL_Serp.modlog("_OnFleetRequested abort newest quest "..tostring(QuestDescriptionTextGUID),ModID)
            end
          else
            g_LTL_Serp.modlog("ERROR: Failed to find ActiveQuestInstances of Quest "..tostring(QuestDescriptionTextGUID).." (make sure the GUID is set as DescriptionText in the Quest!)",ModID)
          end
        end)
        -- ts.Unlock.SetUnlockNet(g_SupportFleet_Serp._OnCooldownunlock) -- is locked in xml OnQuestEnd
        g_DiploActions_Serp.UpdateOfferedDiploButtons(TargetPID)
      end
    end
    
    -- TODO: noch prüfen ob die Quest dazu bereits läuft
     -- bzw. evtl. ein FeatureUnlock machen, was das Object wieder unlocked
      -- nach einem Timer und dieses locken wenn quest gestartet wird
       -- (testen ob dieser timer als unlockcondition in tooltip gezeigt wird)
    
    local function _IsShipAllowed(PID,TargetPID,shipguid,IsThirdParty,info)
      if info~=nil and type(info)=="table" then
        if info.onlyfor~=nil and not g_LTL_Serp.table_contains_value(info.onlyfor,TargetPID) then
          return false
        end
        if info.playerneedsunlock~=nil and ts.Unlock.GetIsUnlocked(playerneedsunlock)  then
          return true -- overwrites the general rules below
        end
      end
      IsThirdParty = IsThirdParty or TargetPID==g_LTL_Serp.PIDs.Third_party_01_Queen.PID or g_LTM_Serp.IsThirdPartyTrader(TargetPID)
      if IsThirdParty or IsThirdParty==nil then -- then based on the local player, if we have unlocked the ship
        if ts.Unlock.GetIsUnlocked(shipguid) then
          return true
        end
      else -- 2nd party, then based on the progress of them (cant check unlocks, so check CounterValueType=Max amount of this ship)
        if ts.Participants.GetParticipant(TargetPID).ProfileCounter.Stats.GetCounter(2,0,shipguid,3)>0 then
          return true
        end
      end
      return false
    end
    
    

    local function IsRequestFleetAllowed(TargetPID,topdiplostate,fleetname)
      local PID = ts.Participants.GetGetCurrentParticipantID()
      if ts.Unlock.GetIsUnlocked(g_SupportFleet_Serp._OnCooldownunlock) then -- as long as it is unlocked, dont allow it
        return false
      end
      if not g_SupportFleet_Serp._IsShipAllowed(PID,TargetPID,100437) then -- if not even gunboat is unlocked, dont allow it
        return false
      end
      local DiplomacyState = g_DiploActions_Serp.DiplomacyState
      if fleetname=="SmallFleet" then
        if topdiplostate == DiplomacyState.TradeRights or topdiplostate == DiplomacyState.Alliance then
          return true
        end
      elseif fleetname=="BigFleet" then
        if topdiplostate == DiplomacyState.Alliance then
          return true
        end
      end
      return false
    end
    
    
    -- a function to check which ships we allow to be spawned by the supportfleet request.
     -- The Quest to spawn the ships was already started, so they will spawn for sure
     -- it is executed for each coop peer!
    local function _CheckWhichShips(PID,TargetPID,IsThirdParty) 
      local continue = g_LTM_Serp.ContinueCoopCalled()
      if continue then
        local num_ships = 8 -- The max ship amount of biggest supportfleet is currently 8. the ingame amount of spawned ships is determined by the number of ActionRegisterTrigger in the Quest.
        g_LTL_Serp.modlog("_CheckWhichShips (g_SupportFleet_Serp): "..tostring(PID).." towards "..tostring(TargetPID)..", IsThirdParty "..tostring(IsThirdParty),ModID)
        local choicetable = {}
        for shipguid,info in pairs(g_SupportFleet_Serp.ShipSpawnUnlocks) do
          if g_SupportFleet_Serp._IsShipAllowed(PID,TargetPID,shipguid,IsThirdParty,info) then -- then based on the local player, if we have unlocked the ship
            choicetable[shipguid] = info.w_chance
          end
        end
        local chosen = {}
        if continue=="IsFirst" then
          chosen = g_LTL_Serp.weighted_random_choices(choicetable, num_ships)
        else -- then we should not do random stuff. instead just fill the list one after the other, so it is the same for every local coop peer
          -- TODO: evlt. zumindest noch so machen, dass nicht immer die erste 8 genommen werden,
           -- sondern wenns mal mehr schiffe sein, dann beim nächsten durchlauf die schiffe 9 bis 16 genommen werden oderso
          local k,i = nil,1
          while i<=num_ships do
            local shipguid,chance = next(choicetable,k)
            if shipguid~=nil then
              table.insert(chosen,shipguid)
              i = i + 1
            end
            k = shipguid
          end
        end
        for i,shipguid in ipairs(chosen) do
          local unlock = g_SupportFleet_Serp.ShipSpawnUnlocks[shipguid].unlocks[i]
          if unlock~=nil then
            ts.Unlock.SetUnlockNet(unlock)
          end
          g_LTL_Serp.modlog("_CheckWhichShips chose: "..tostring(shipguid).." index: "..tostring(i),ModID)
        end

        g_LTL_Serp.start_thread("_CheckWhichShips_lock_again",ModID,function()
          system.waitForGameTimeDelta(1600) -- at least 1500ms, because of buggy quests. We are not allowed to unlock the condition of an registered trigger. Thats why we start this script first to unlock it, wait with a sustain-objective for 1 second for it to happen and be synced, then registering the triggers in the quest. and only after that we should lock them again here in lua
          for shipguid,info in pairs(g_SupportFleet_Serp.ShipSpawnUnlocks) do -- lock them again shortly after
            for _,unlock in ipairs(info.unlocks) do
              ts.Unlock.SetRelockNet(unlock)
            end
          end
        end)
      end
    end
    
    
    local function _Start()
        while g_DiploActions_Serp==nil do
          coroutine.yield()
        end
        -- this is how we can properly add our code to the functions of another mod:
        local Orig_UpdateOfferedDiploButtons = g_DiploActions_Serp.UpdateOfferedDiploButtons
        g_DiploActions_Serp.UpdateOfferedDiploButtons = function(TargetPID,topdiplostate,...)
          local ret = Orig_UpdateOfferedDiploButtons(TargetPID,topdiplostate,...) -- execute original first (so it locks everything first.. but not our fleet, so we will use SetRelockNet also in here)
          local PID = ts.Participants.GetGetCurrentParticipantID()
          g_LTL_Serp.modlog("UpdateOfferedDiploButtons (g_SupportFleet_Serp): "..tostring(PID).." towards "..tostring(TargetPID)..", topdiplostate "..tostring(topdiplostate),ModID)
          if PID~=TargetPID and TargetPID~=nil then
            topdiplostate = topdiplostate or ts.Participants.GetTopLevelDiplomacyStateTo(PID,TargetPID)
            for fleetname,unlock in pairs(g_SupportFleet_Serp.RequestButtonUnlock) do
              if g_SupportFleet_Serp.IsRequestFleetAllowed(TargetPID,topdiplostate,fleetname) then
                ts.Unlock.SetUnlockNet(unlock)
              else
                ts.Unlock.SetRelockNet(unlock)
              end
            end
          end
          return ret
        end
    end
    

    -- #####################################################################################################

    g_SupportFleet_Serp = {
      RequestButtonUnlock = {SmallFleet=1500003901,BigFleet=1500003902},
      IsRequestFleetAllowed = IsRequestFleetAllowed,
      _OnFleetRequested = _OnFleetRequested,
      _Start = _Start,
      _CheckWhichShips = _CheckWhichShips,
      _IsShipAllowed = _IsShipAllowed,
      _OnCooldownunlock = 1500003903, -- block request as long as this is unlocked
      SupportFleetQuestGuids = {
        SmallFleet = {
          [g_LTL_Serp.PIDs.Second_ai_01_Jorgensen.PID] = 1500001246,
          [g_LTL_Serp.PIDs.Second_ai_02_Qing.PID] = 1500001248,
          [g_LTL_Serp.PIDs.Second_ai_03_Wibblesock.PID] = 1500001250,
          [g_LTL_Serp.PIDs.Second_ai_04_Smith.PID] = 1500001252,
          [g_LTL_Serp.PIDs.Second_ai_05_OMara.PID] = 1500001254,
          [g_LTL_Serp.PIDs.Second_ai_06_Gasparov.PID] = 1500001256,
          [g_LTL_Serp.PIDs.Second_ai_07_von_Malching.PID] = 1500001258,
          [g_LTL_Serp.PIDs.Second_ai_08_Gravez.PID] = 1500001260,
          [g_LTL_Serp.PIDs.Second_ai_09_Silva.PID] = 1500001262,
          [g_LTL_Serp.PIDs.Second_ai_10_Hunt.PID] = 1500001264,
          [g_LTL_Serp.PIDs.Second_ai_11_Mercier.PID] = 1500001266,
          [g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID] = 1500001268,
          [g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID] = 1500001270,
          [g_LTL_Serp.PIDs.Third_party_02_Blake.PID] = 1500001272,
          [g_LTL_Serp.PIDs.Third_party_06_Nate.PID] = 1500001273,
          [g_LTL_Serp.PIDs.Third_party_01_Queen.PID] = 1500001274,
        },
        BigFleet = {
          [g_LTL_Serp.PIDs.Second_ai_01_Jorgensen.PID] = 1500001247,
          [g_LTL_Serp.PIDs.Second_ai_02_Qing.PID] = 1500001249,
          [g_LTL_Serp.PIDs.Second_ai_03_Wibblesock.PID] = 1500001251,
          [g_LTL_Serp.PIDs.Second_ai_04_Smith.PID] = 1500001253,
          [g_LTL_Serp.PIDs.Second_ai_05_OMara.PID] = 1500001255,
          [g_LTL_Serp.PIDs.Second_ai_06_Gasparov.PID] = 1500001257,
          [g_LTL_Serp.PIDs.Second_ai_07_von_Malching.PID] = 1500001259,
          [g_LTL_Serp.PIDs.Second_ai_08_Gravez.PID] = 1500001261,
          [g_LTL_Serp.PIDs.Second_ai_09_Silva.PID] = 1500001263,
          [g_LTL_Serp.PIDs.Second_ai_10_Hunt.PID] = 1500001265,
          [g_LTL_Serp.PIDs.Second_ai_11_Mercier.PID] = 1500001267,
          [g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID] = 1500001269,
          [g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID] = 1500001271,
          [g_LTL_Serp.PIDs.Third_party_01_Queen.PID] = 1500001275,
        },
      },
      ShipSpawnUnlocks = {
        [100437]={unlocks={1500001343,1500001344,1500001345,1500001346,1500001347,1500001348,1500001349,1500001350},w_chance=10},
        [100439]={unlocks={1500001351,1500001352,1500001353,1500001354,1500001355,1500001356,1500001357,1500001358},w_chance=10},
        [100440]={unlocks={1500001359,1500001360,1500001361,1500001362,1500001363,1500001364,1500001365,1500001366},w_chance=10},
        [100442]={unlocks={1500001367,1500001368,1500001369,1500001370,1500001371,1500001372,1500001373,1500001374},w_chance=10},
        [100443]={unlocks={1500001375,1500001376,1500001377,1500001378,1500001379,1500001380,1500001381,1500001382},w_chance=10},
        [720]={unlocks={1500001383,1500001384,1500001385,1500001386,1500001387,1500001388,1500001389,1500003920},w_chance=2},
        [968]={unlocks={1500003921,1500003922,1500003923,1500003924,1500003925,1500003926,1500003927,1500003928},w_chance=6},
         -- TODO: anstatt royal SOTL 102427 zuzufügen, machen wir einfach ActionSetObjectGUID in Queen Quests für SOTL 100440
        -- [102427]={unlocks={},w_chance=5,onlyfor={g_LTL_Serp.PIDs.Third_party_01_Queen.PID},playerneedsunlock=100440}, -- Royal SOTL
        -- SpawnTrigger.include.xml noch frei: 1500003929,1500003930,1500003931,1500003932,1500003933,1500003934,1500003935,1500003936,1500003937,1500003938,1500003939,1500003940,1500003941,1500003942,1500003943,1500003944,1500003945,1500003946,1500003947,1500003948,1500003949,1500003950,1500003951,1500003952,1500003953,1500003954,1500003955,1500003956,1500003957,1500003958,1500003959,1500003960,1500003961,1500003962,1500003963,1500003964,1500003965,1500003966,1500003967,1500003968,1500003969,1500003970,1500003971,1500003972,1500003973,1500003974,1500003975,1500003976,1500003977,1500003978,1500003979,1500003980,1500003981,1500003982,1500003983,1500003984,1500003985,1500003986,1500003987,1500003988,1500003989,1500003990,1500003991,1500003992,1500003993,1500003994,1500003995,1500003996,1500003997,1500003998,1500003999,
      },
    }
    
    g_LTL_Serp.start_thread("_Start",ModID,g_SupportFleet_Serp._Start)
    
    
    g_LTL_Serp.start_thread("g_OnGameLeave_serp",ModID,function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_SupportFleet_Serp = nil
        end
      end
    end)
    g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)
    
end