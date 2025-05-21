  -- TODO: -->
   -- um random item den schiffen mitzugeben, kann ich auch InitSlotItems mit ReardPool nutzen (drauf achten, dass kein EmptyRewardPool verlinkt ist, weil das unsichtbares items spawned) -->
  


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
    
    -- TODO: noch prüfen ob die Quest dazu bereits läuft
     -- bzw. evtl. ein FeatureUnlock machen, was das Object wieder unlocked
      -- nach einem Timer und dieses locken wenn quest gestartet wird
       -- (testen ob dieser timer als unlockcondition in tooltip gezeigt wird)
    
    local function _IsShipAllowed(PID,TargetPID,shipguid,IsThirdParty)
      IsThirdParty = IsThirdParty or TargetPID==15 or g_LTM_Serp.IsThirdPartyTrader(TargetPID)
      if IsThirdParty then -- then based on the local player, if we have unlocked the ship
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
    
    
    local function IsRequestFleetAllowed(TargetPID,topdiplostate,name)
      local PID = ts.Participants.GetGetCurrentParticipantID()
      if not g_SupportFleet_Serp._IsShipAllowed(PID,TargetPID,100437) then -- if not even gunboat is unlocked, dont allow it
        return false
      end
      local DiplomacyState = g_DiploActions_Serp.DiplomacyState
      if name=="SmallFleet" then
        if topdiplostate == DiplomacyState.TradeRights or topdiplostate == DiplomacyState.Alliance then
          return true
        end
      elseif name=="BigFleet" then
        if topdiplostate == DiplomacyState.Alliance then
          return true
        end
      end
      return false
    end
    
    -- a function to check which ships we allow to be spawned by the supportfleet request
    local function _CheckWhichShips(PID) 
      local num_ships = 8 -- The max ship amount of biggest supportfleet is currently 8. the ingame amount of spawned ships is determined by the number of ActionRegisterTrigger in the Quest.
      local TargetPID = g_DiploActions_Serp.GetDiploSelectedPID()
      local IsThirdParty = TargetPID==15 or g_LTM_Serp.IsThirdPartyTrader(TargetPID)
      g_LTL_Serp.modlog("_CheckWhichShips (g_SupportFleet_Serp): "..tostring(PID).." towards "..tostring(TargetPID)..", IsThirdParty "..tostring(IsThirdParty),ModID)
      local choicetable = {}
      for shipguid,info in pairs(g_SupportFleet_Serp.ShipSpawnUnlocks) do
        if g_SupportFleet_Serp._IsShipAllowed(PID,TargetPID,shipguid,IsThirdParty) then -- then based on the local player, if we have unlocked the ship
          choicetable[shipguid] = info.w_chance
        end
      end
      local chosen = g_LTL_Serp.weighted_random_choices(choicetable, num_ships)
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
            for name,unlock in pairs(g_SupportFleet_Serp.RequestButtonUnlock) do
              if g_SupportFleet_Serp.IsRequestFleetAllowed(TargetPID,topdiplostate,name) then
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

    
    -- Lua Tools Medium
    g_SupportFleet_Serp = {
      RequestButtonUnlock = {SmallFleet=1500003901,BigFleet=1500003902},
      IsRequestFleetAllowed = IsRequestFleetAllowed,
      _Start = _Start,
      _CheckWhichShips = _CheckWhichShips,
      _IsShipAllowed = _IsShipAllowed,
      ShipSpawnUnlocks = {
        [100437]={unlocks={1500001343,1500001344,1500001345,1500001346,1500001347,1500001348,1500001349,1500001350},w_chance=10},
        [100439]={unlocks={1500001351,1500001352,1500001353,1500001354,1500001355,1500001356,1500001357,1500001358},w_chance=10},
        [100440]={unlocks={1500001359,1500001360,1500001361,1500001362,1500001363,1500001364,1500001365,1500001366},w_chance=10},
        [100442]={unlocks={1500001367,1500001368,1500001369,1500001370,1500001371,1500001372,1500001373,1500001374},w_chance=10},
        [100443]={unlocks={1500001375,1500001376,1500001377,1500001378,1500001379,1500001380,1500001381,1500001382},w_chance=10},
        [720]={unlocks={1500001383,1500001384,1500001385,1500001386,1500001387,1500001388,1500001389,1500003920},w_chance=2},
        [968]={unlocks={1500003921,1500003922,1500003923,1500003924,1500003925,1500003926,1500003927,1500003928},w_chance=6},
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