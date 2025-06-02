
-- TODO Wchtig:
 -- alle start_thread Aufrufe in allen lua mods durchgehen und evtl. 
  -- die identifier strings einzigartiger machen!
  -- Also zb PID/TargetPID mit reinnehmen, falls dieser Thread auch für untersch Zeiel zeitgleich laufen können soll!!
  -- (hab dazu Warning in modlog aufgenommen, da ab und zu mal reingucken)


-- TODO:
 -- beim laden eines savegames kommt es noch vor das lua die Quest nicht findet...
  -- ich mach mal mehr wartezeit rein 
 
 

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
    
    local function AdjustSkin(OID,GUID,TargetPID)
      if TargetPID==g_LTL_Serp.PIDs.Third_party_01_Queen.PID then
        if GUID==100442 then -- queen usually index 1, but its 2 for battlecruiser
          ts.Objects.GetObject(OID).SetChangeSkin(2,true,true)
        else
          ts.Objects.GetObject(OID).SetChangeSkin(1,true,true)
        end
        
      -- dont need the pirate skin anymore, because we instead spawn the pirate-sale-version of the ships
      -- elseif TargetPID==g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID or TargetPID==g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID then
        -- if GUID==100440 then -- pirates usually index 3, but its 10 for Liner
          -- ts.Objects.GetObject(OID).SetChangeSkin(10,true,true)
        -- else
          -- ts.Objects.GetObject(OID).SetChangeSkin(3,true,true)
        -- end
        
      end
    end
    
    
    -- called via ActionExecuteScript when the player build the helper object to request fleet
     -- we can get the TargetPID by checking which one is currently locked
      -- is executed for all coop peers!
      -- using helper g_CoopCountResSerp.ContinueWithTotalChanceCoop(totalchance) to unlock with a total chance, regardless how many coop peers are executing this function
    local function _OnFleetRequested(PID,fleetname)
      if ts.Participants.GetGetCurrentParticipantID() == PID then
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
          if g_SupportFleet_Serp.IsRequestFleetAllowed(TargetPID,nil,fleetname,IsThirdParty) then -- just in case we did not properly lock an option
            if continue=="IsFirst" then -- only executed for first coop peer
              if math.random() < totalchance then -- should not use ContinueWithTotalChanceCoop here
                requestsuccess = true
              end
            else -- executed for all coop peers
              if g_CoopCountResSerp.ContinueWithTotalChanceCoop(totalchance) then
                requestsuccess = true
              end
            end
          end
          -- make Quest either visible or abort it after the quest started
          g_LTL_Serp.start_thread("WaitForSupportQuest "..tostring(PID)..tostring(TargetPID)..tostring(fleetname),ModID,function()
            system.waitForGameTimeDelta(500) -- wait for the Quest to start. it is started without waittime and after ~1 second it shows the "request success" message. So waittime between 500 and 900 ms should be good. Do not wait too short, because the quest must be started completely. Do not wait too long, because in MP we dont know for sure which Quest belong to which player. So within that time no other player should start a request
            local QuestDescriptionTextGUID = g_SupportFleet_Serp.SupportFleetQuestGuids[fleetname][TargetPID]
            local QuestIndices = g_LTL_Serp.GetActiveQuestInstances(QuestDescriptionTextGUID)
            local last_QID = table.remove(QuestIndices) -- last entry is the newest running instance of this quest (normally its only one, but just in case we want to allow multiple at once)
            if last_QID~=nil then -- only when we found the quest, everything is fine
              if requestsuccess then
                g_LTL_Serp.start_thread("t_DoSupportFleet wait for owner change "..tostring(PID)..tostring(TargetPID)..tostring(fleetname),ModID,g_SupportFleet_Serp.t_DoSupportFleet,PID,TargetPID,IsThirdParty,last_QID,fleetname)
                g_LTL_Serp.modlog("_OnFleetRequested keep quest active "..tostring(QuestDescriptionTextGUID),ModID)
              else
                ts.Quests.GetQuest(last_QID).SetAbortedNet(false,1) -- SetAbortedNet(bool_isManually,int_QuestAbortReason)
                g_LTL_Serp.modlog("_OnFleetRequested abort newest quest "..tostring(QuestDescriptionTextGUID),ModID)
              end
              
              ts.Unlock.SetUnlockNet(g_SupportFleet_Serp._OnCooldownunlocks.All)
              ts.Unlock.SetUnlockNet(g_SupportFleet_Serp._OnCooldownunlocks[TargetPID])
              
              for fleetname,unlock in pairs(g_SupportFleet_Serp.RequestButtonUnlock) do
                ts.Unlock.SetRelockNet(unlock)  -- update buttons
              end
              g_DiploActions_Serp.UnhideAllDiploButtons()
              
            else
              g_LTL_Serp.modlog("ERROR: Failed to find ActiveQuestInstances of Quest "..tostring(QuestDescriptionTextGUID).." (This is fine if the QuestGiver does not have a lighthouse in the current session. make sure the GUID is set as DescriptionText in the Quest!)",ModID)
            end
          end)
        end
      end
    end
    
    -- TODO: noch prüfen ob die Quest dazu bereits läuft
     -- bzw. evtl. ein FeatureUnlock machen, was das Object wieder unlocked
      -- nach einem Timer und dieses locken wenn quest gestartet wird
       -- (testen ob dieser timer als unlockcondition in tooltip gezeigt wird)
    
    
    
    local function _IsShipAllowed(PID,TargetPID,shipguid,IsThirdParty,info)
      -- g_LTL_Serp.modlog("_IsShipAllowed: "..tostring(PID).." towards "..tostring(TargetPID)..", IsThirdParty "..tostring(IsThirdParty)..", shipguid "..tostring(shipguid),ModID)
      -- g_LTL_Serp.modlog("_IsShipAllowed: info "..(type(info)=="table" and g_LTL_Serp.TableToString(info) or "nil"),ModID)
      if info~=nil and type(info)=="table" then
        if info.OnlyFor~=nil and not g_LTL_Serp.table_contains_value(info.OnlyFor,TargetPID) then
          -- g_LTL_Serp.modlog("_IsShipAllowed: OnlyFor false",ModID)
          return false
        end
        if info.NotFor~=nil and g_LTL_Serp.table_contains_value(info.NotFor,TargetPID) then
          -- g_LTL_Serp.modlog("_IsShipAllowed: NotFor false",ModID)
          return false
        end
        if info.playerneedsunlock~=nil then -- overwrites the general unlock rules below
          if ts.Unlock.GetIsUnlocked(info.playerneedsunlock) then
            -- g_LTL_Serp.modlog("_IsShipAllowed: playerneedsunlock true",ModID)
            return true
          else
            -- g_LTL_Serp.modlog("_IsShipAllowed: playerneedsunlock false",ModID)
            return false
          end
        end
      end
      IsThirdParty = IsThirdParty or TargetPID==g_LTL_Serp.PIDs.Third_party_01_Queen.PID or g_LTM_Serp.IsThirdPartyTrader(TargetPID)
      if IsThirdParty or IsThirdParty==nil then -- then based on the local player, if we have unlocked the ship
        if ts.Unlock.GetIsUnlocked(shipguid) then
          -- g_LTL_Serp.modlog("_IsShipAllowed: local player unlock true",ModID)
          return true
        end
      else -- 2nd party, then based on the progress of them (cant check unlocks, so check CounterValueType=Max amount of this ship)
        if ts.Participants.GetParticipant(TargetPID).ProfileCounter.Stats.GetCounter(2,0,shipguid,3)>0 then
          -- g_LTL_Serp.modlog("_IsShipAllowed: TargetPID unlock true",ModID)
          return true
        end
      end
      -- g_LTL_Serp.modlog("_IsShipAllowed: nothing false",ModID)
      return false
    end
    
    

    local function IsRequestFleetAllowed(TargetPID,topdiplostate,fleetname,IsThirdParty)
      local PID = ts.Participants.GetGetCurrentParticipantID()
      if ts.Unlock.GetIsUnlocked(g_SupportFleet_Serp._OnCooldownunlocks.All) or ts.Unlock.GetIsUnlocked(g_SupportFleet_Serp._OnCooldownunlocks[TargetPID]) then -- as long as it is unlocked, dont allow it
        return false
      end
      local IsThirdParty = IsThirdParty or (TargetPID==g_LTL_Serp.PIDs.Third_party_01_Queen.PID or g_LTM_Serp.IsThirdPartyTrader(TargetPID))
      local anyshipallowed = false
      for shipguid,info in pairs(g_SupportFleet_Serp.ShipsToSpawn) do
        if g_SupportFleet_Serp._IsShipAllowed(PID,TargetPID,shipguid,IsThirdParty,info) then
          anyshipallowed = true
        end
      end
      if not anyshipallowed then
        return false
      end
       -- TODO einkommentieren
      -- if not ts.GameSetup.IsMultiPlayerGame then -- in MP coop peers can be in different sessions... but quest will fail before even starting if no lighthouse
        -- local CurrentSession = session.getSessionGUID()
        -- if not IsThirdParty  and ts.Participants.GetParticipant(TargetPID).ProfileCounter.Stats.GetCounter(0,14,0,1,CurrentSession) <= 0 then -- only if the TargetPID owns at least on island in our current session (also works for Blake after adding ProfileCounter in xml to them)
          -- return false
        -- end
      -- end
      local DiplomacyState = g_LTL_Serp.DiplomacyState
      topdiplostate = topdiplostate or ts.Participants.GetTopLevelDiplomacyStateTo(PID,TargetPID)
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
    
    -- unless Ultra Tools are active, we dont know how many coop peers are executing this,because of ContinueWithTotalChanceCoop
    local function t_DoSupportFleet(PID,TargetPID,IsThirdParty,last_QID,fleetname)
      g_LTL_Serp.modlog("t_DoSupportFleet (g_SupportFleet_Serp): "..tostring(PID).." towards "..tostring(TargetPID)..", IsThirdParty "..tostring(IsThirdParty)..", last_QID "..tostring(last_QID),ModID)
      local CurrentSession = session.getSessionGUID()
      local chosen = g_SupportFleet_Serp._CheckWhichShips(PID,TargetPID,IsThirdParty)
      local notstop = 0
      local fakeshipcount = ts.Participants.GetParticipant(PID).ProfileCounter.Stats.GetCounter(0,0,1500001330,1,CurrentSession)
      while fakeshipcount == 0 do
        coroutine.yield()-- one yield is 100 ms
        fakeshipcount = ts.Participants.GetParticipant(PID).ProfileCounter.Stats.GetCounter(0,0,1500001330,1,CurrentSession)
        notstop = notstop + 1
        if notstop > 50 then -- 100ms*50 = 5 seconds
          break
        end
      end
      if notstop > 50 then -- most likely we are a peer who is not in the correct session. But there must be another one who is who initiated the request
        g_LTL_Serp.modlog("t_DoSupportFleet (g_SupportFleet_Serp): Did not find Fakeships in Session "..tostring(CurrentSession).." (global fakeship count is: "..tostring(ts.Participants.GetParticipant(PID).ProfileCounter.Stats.GetCounter(0,0,1500001330,3))..") , so most likely we are not the peer who requested the Supportfleet so stop code execution",ModID)
        return
      end
      g_LTL_Serp.modlog("t_DoSupportFleet found fakeships by human",ModID)
      local ships = g_LTM_Serp.ObjectFinder.GetCurrentSessionObjectsFromLocaleByProperty("ShipMaintenance")
      local fakeships = {}
      local starterobject
      for OID,objinfo in pairs(ships) do
        if g_LTL_Serp.table_contains_value(g_SupportFleet_Serp._FakeShips,objinfo.GUID) then
          fakeships[OID] = objinfo
          ts.Objects.GetObject(OID).Mesh.SetVisible(false)
        elseif starterobject==nil and (objinfo.GUID==1500001291 or objinfo.GUID==1500001292) then
          local name = ts.Objects.GetObject(OID).Nameable.Name
          if (objinfo.GUID==1500001291 and name == ts.GetAssetData(1500003901).Text) or (objinfo.GUID==1500001292 and name == ts.GetAssetData(1500003902).Text) then -- not used yet
            starterobject = objinfo
            local TargetName = ts.Participants.GetParticipantName(TargetPID) -- cant put it directly in SetName()
            ts.Objects.GetObject(OID).Nameable.SetName(TargetName)
            g_SupportFleet_Serp.AdjustSkin(OID,100440,TargetPID) -- starter uses graphic from Liner, so use this as GUID
          end
        end
      end
      if next(fakeships)==nil then
        g_LTL_Serp.modlog("t_DoSupportFleet (g_SupportFleet_Serp): ERROR Did not find Fakeships with GetCurrentSessionObjectsFromLocaleByProperty in Session "..tostring(CurrentSession),ModID)
        return
      end
      g_LTL_Serp.modlog("t_DoSupportFleet found OID fakeships by human",ModID)
      
      local CurrentSession = session.getSessionGUID()
      local i = 1
      for OID,objinfo in pairs(fakeships) do
        if CurrentSession~=objinfo.SessionGuid then
          g_LTL_Serp.modlog("t_DoSupportFleet (g_SupportFleet_Serp): ERROR Player changed Session before we changed the GUID of fakeships...",ModID)
          return
        end
        local userdata = session.getObjectByID(OID) -- better request userdata again and not use the one stored in objinfo
        local newGUID = chosen[i]
        userdata:changeGUID(newGUID)
        -- falls wir irgendwann wissen wie QuestObjectives MainObjectives funktioniert und wir darüber
         -- ans TimeLimit (aktuelle Wartezeit) kommen sollten, können wir das in lua alle 1 sec oderso ins Nameable schreiben...
        g_SupportFleet_Serp.AdjustSkin(OID,newGUID,TargetPID)
        -- todo test. SetOnSale ändert das UI und infolayer entsprechend, aber öffnet nicht die kauf-notification.
         -- die müssten wir also noch selbst zufügen, aber nur für denjenigen, der die Quest hat.
          -- dazu mal testen: dummyquest nach dem spawnen aus Quest heraus starten mit InheritObjects
           -- darin irgendwie condition selection vom questobjects checken (wincondtion und quest started sich am Ende selbst erneut? doch wie beenden wir das?
            -- ne wir können in xml nur auf GUID Basis Quests starten/beenden und status prüfen, was dann nicht funzt wenns mehrere request quests zeitgleich geben kann)
             -- vllt doch mit PreCondition QuestObjects die Neutral gehören. und sobalds keine neutral mehr gibt, beendet sich loop?
             -- Idee: 2 wins die mutuallyexclusive sind. eine ist anklicken des starters und bestätigen. Andere ist subcondition mit linear 100 mal questobject anklicken und notification
              -- auf diese weise kannst du alle schiffe kaufen oder wenn du keins mehr willst/alle hast das starter anklciekn
           -- und dann wenn selected ActionNotification zum Kaufen starten mit ThirdPartyButton
        ts.Objects.GetObject(OID).Sellable.SetOnSale(true) -- no relevant effect besides visuals. shows that they are buyable and the ship-UI from it, but does not start the buy-notification (this is done in Quest ourself, so only the QuestOwner can buy them)
        
        
        -- xml makes them invisible. here we make them visible one after the other, so other players also see the progress of it
        g_LTL_Serp.start_thread("t_DoSupportFleet make visible"..tostring(PID)..tostring(TargetPID)..tostring(fleetname)..tostring(OID),ModID,function(OID,i)
          system.waitForGameTimeDelta(10000*i) -- TODO Zeit auf 60000 anpassen sobald fertig (bzw. die Zeit wie in SustainQuest durch anzahl der Schiffe)
          ts.GetGameObject(OID).Mesh.SetVisible(true) -- make visibile again. using GetGameObject here, because it works regardless of our session. In OnQuestEnd we will add xml code to make all visible, just in case lua was aborted
        end,OID,i)
        
        g_LTL_Serp.start_thread("t_DoSupportFleet moneycost into name "..tostring(PID)..tostring(TargetPID)..tostring(fleetname)..tostring(OID),ModID,function(OID,i)
          g_LTL_Serp.waitForTimeDelta(2000) -- wait for changeGUID to complete, otherwise we get wrong price, needs more than 1 second
          local moneycost = ts.Objects.GetObject(OID).Sellable.CurrentParticipantBuyPrice.MoneyCost
          local topdiplostate = ts.Participants.GetTopLevelDiplomacyStateTo(PID,TargetPID)
          if topdiplostate == g_LTL_Serp.DiplomacyState.Alliance then -- writing the money cost into name instead of factor, because we also want to use it in text of notification
            ts.Objects.GetObject(OID).Nameable.SetName(tostring(g_LTL_Serp.myround( moneycost / 4)))
          else
            ts.Objects.GetObject(OID).Nameable.SetName(tostring(g_LTL_Serp.myround( moneycost / 2)))
          end
        end,OID,i)
        
        
        i = i + 1 -- TODO: sobald mehr als eine fakeship guid, muss ich hier code anpassen, dass die korrekten fake schiffe umgewandelt werden 
        -- und sie evtl. auch nacheinander mit delay sichtbar machen...
         -- wobei wir changeGUID sofort machen müssen
      end
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
        for shipguid,info in pairs(g_SupportFleet_Serp.ShipsToSpawn) do
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
        return chosen
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
          g_DiploActions_Serp.UnhideAllDiploButtons()
          return ret
        end
    end
    

    -- #####################################################################################################

    g_SupportFleet_Serp = {
      RequestButtonUnlock = {SmallFleet=1500003901,BigFleet=1500003902},
      _FakeShips = {Warship=1500001330,Tradeship=1500001331},
      IsRequestFleetAllowed = IsRequestFleetAllowed,
      _OnFleetRequested = _OnFleetRequested,
      _Start = _Start,
      t_DoSupportFleet = t_DoSupportFleet,
      _CheckWhichShips = _CheckWhichShips,
      _IsShipAllowed = _IsShipAllowed,
      AdjustSkin = AdjustSkin,
      _OnCooldownunlocks = { -- block request as long as this is unlocked
        All = 1500003903,
        [g_LTL_Serp.PIDs.Second_ai_01_Jorgensen.PID] = 1500003870,
        [g_LTL_Serp.PIDs.Second_ai_02_Qing.PID] = 1500003871,
        [g_LTL_Serp.PIDs.Second_ai_03_Wibblesock.PID] = 1500003872,
        [g_LTL_Serp.PIDs.Second_ai_04_Smith.PID] = 1500003873,
        [g_LTL_Serp.PIDs.Second_ai_05_OMara.PID] = 1500003874,
        [g_LTL_Serp.PIDs.Second_ai_06_Gasparov.PID] = 1500003875,
        [g_LTL_Serp.PIDs.Second_ai_07_von_Malching.PID] = 1500003876,
        [g_LTL_Serp.PIDs.Second_ai_08_Gravez.PID] = 1500003877,
        [g_LTL_Serp.PIDs.Second_ai_09_Silva.PID] = 1500003878,
        [g_LTL_Serp.PIDs.Second_ai_10_Hunt.PID] = 1500003879,
        [g_LTL_Serp.PIDs.Second_ai_11_Mercier.PID] = 1500003880,
        [g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID] = 1500003881,
        [g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID] = 1500003882,
        [g_LTL_Serp.PIDs.Third_party_02_Blake.PID] = 1500003883,
        [g_LTL_Serp.PIDs.Third_party_06_Nate.PID] = 1500003884,
        [g_LTL_Serp.PIDs.Third_party_01_Queen.PID] = 1500003885,
      },
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
      -- when adding ships here, also add them to the pool 1500001290
      ShipsToSpawn = {
        [100437]={fake="warship",w_chance=10,NotFor={g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID,g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID}},
        [100439]={fake="warship",w_chance=10,NotFor={g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID,g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID}},
        [100440]={fake="warship",w_chance=10,NotFor={g_LTL_Serp.PIDs.Third_party_01_Queen.PID,g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID,g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID}},
        [100442]={fake="warship",w_chance=10},
        [100443]={fake="warship",w_chance=10,NotFor={g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID,g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID}},
        [720]={fake="warship",w_chance=2},
        [968]={fake="warship",w_chance=6},
        [102427]={fake="warship",w_chance=10,OnlyFor={g_LTL_Serp.PIDs.Third_party_01_Queen.PID},playerneedsunlock=100440}, -- Royal SOTL
        [102420]={fake="warship",w_chance=10,OnlyFor={g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID,g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID},playerneedsunlock=100437}, -- pirate gunboat sale
        [102421]={fake="warship",w_chance=10,OnlyFor={g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID,g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID},playerneedsunlock=100439}, -- pirate frigate sale
        [102419]={fake="warship",w_chance=10,OnlyFor={g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID,g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID},playerneedsunlock=100440}, -- pirate liner sale
        [102422]={fake="warship",w_chance=10,OnlyFor={g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID,g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID},playerneedsunlock=100443}, -- pirate monitor sale
      },
      ModsActiveUnlocks = {shared_pirate_ships=1500003906,}, -- active if locked
    }
    -- TODO
    -- if not ts.Unlock.GetIsUnlocked(g_SupportFleet_Serp.ModsActiveUnlocks.shared_pirate_ships) then -- if locked, the mod is active
      -- g_SupportFleet_Serp.ShipsToSpawn[100442].NotFor = {g_LTL_Serp.PIDs.Third_party_01_Queen.PID,g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID,g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID}
      -- g_SupportFleet_Serp.ShipsToSpawn[720].NotFor = {g_LTL_Serp.PIDs.Third_party_01_Queen.PID,g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID,g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID}
      -- g_SupportFleet_Serp.ShipsToSpawn[968].NotFor = {g_LTL_Serp.PIDs.Third_party_01_Queen.PID,g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID,g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID}
      -- g_SupportFleet_Serp.ShipsToSpawn[111111] = {fake="warship",w_chance=10,OnlyFor={g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID,g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID},playerneedsunlock=100443}, -- pirate monitor sale
    -- end
    
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