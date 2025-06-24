-- Only this script gets loaded via ActionExecuteScript on GameLoaded and it starts all other lua scripts
-- (ok, event_savegame_loaded.lua is called first via ActionExecuteScript and then starts this here via Unlock 1500004636)


-- TODO 
-- ne funktion zufügen, die es erlaubt bei Humans mit TradeRights nachdem diese zugestimmt haben
 -- oder bei Allianz ohne Zustimmung
-- ts.Interface.ToggleStateVisibility("ObjectMenuKontor") aufzurufen (nur bei Kontor)
-- Dort kann man dann frei Waren rein/rausnehmen und auch Items.
-- (Geht nicht bei KI, da geht nichts rein und unendlich raus)

-- Vllt 2 Anfragen einbauen:
-- 1) Völlig frei erlauben (dann kann Human zb. an jedem Kontor Button drücken zum umschalten)
-- 2) Einmalige Anfrage für aktuell angewählten Kontor
  
  
-- <!-- TODO: -->
   -- <!-- die for-sale schiffe die vom spiel spawnen gehören dem Piraten! -->
   -- <!-- dh. wenn mein Trigger die hier umwandelt, dann funktioniert das Sale system nicht mehr! (spawnen keine weiteren mehr) -->
   -- <!-- Daher hier die Sale Version nicht umwandeln. -->
   -- <!-- Stattdessen im eigenen GiftShip lua Code dafür sorgen, dass Schiffe die GUID wechseln! -->
    -- <!-- Dabei könnte ich auch gleich gucken, dass ich nen Trigger einbaue, der die gerade verschenkten schiffe nochmal -->
     -- <!-- an den Piraten vergibt, da diese durch BuyNet an 3rd party ja neutral werden und die karte verlassen. -->
     -- <!-- Also Lösung: Mit lua owner zu Nature wechseln.  -->
      -- <!-- dann xml starten, welches ActionChangeOwner in Trigger auf alle schiffe macht die nature gehören -->
       -- <!-- (oder zu owner challenger oderso wechseln). und dann changeguid -->
  -- ja tatsächlich einfach Scenario3_Challenger1 usw. auch hierfür als Helfer nutzen.
   -- in MediumTools erwähnen, dass ich Scenario3_Challenger1 dafür (ChangeOwner) reserviere
   -- Und im Trigger dann darauf achten, dass nicht ALLE schiffe targete, sondern nur Playership/pirateships
    -- und nicht die scenario schiffe: 104563, 103157 (die sind in keinem vanilla pool, also sind pools save)
  
  

local ModID = "shared_EmbassyDiploActions_Serp diploactions.lua" -- used for logging

if g_LuaScriptBlockers[ModID]==nil then
        
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    

    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end

    g_LTL_Serp.modlog("diploactions.lua registered",ModID)
    
    if g_LTM_Serp==nil then
      g_LTL_Serp.modlog("ERROR requires shared_LuaTools_Medium_Serp",ModID)
      error("ERROR requires shared_LuaTools_Medium_Serp")
    end
    
    
    -- #####################################################################################################
    -- #####################################################################################################
    

  -- TODO:
   -- auch schon bei TradeRights erlauben, aber mit halber/viertel Chance?
  
  local function CanJoinWarAgainstCandidate(PID,TargetPID,WarPID)
    PID = PID or ts.Participants.GetGetCurrentParticipantID()
    local DiplomacyState = g_LTL_Serp.DiplomacyState
    if PID~=TargetPID and g_LTL_Serp.table_contains_value(g_DiploActions_Serp.SupportedPIDs_WarAndGiftShip,TargetPID) and ts.Participants.GetTopLevelDiplomacyStateTo(PID,TargetPID)==DiplomacyState.Alliance then
      if WarPID~=PID and WarPID~=TargetPID and g_LTL_Serp.table_contains_value(g_DiploActions_Serp.SupportedPIDs_WarAndGiftShip,WarPID) then
        if ts.Participants.GetTopLevelDiplomacyStateTo(PID,WarPID)==DiplomacyState.War then -- if we have war with one
          if ts.Participants.GetTopLevelDiplomacyStateTo(TargetPID,WarPID)~=DiplomacyState.War then -- and Target does not have already war with this
            -- if ts.Participants.GetTopLevelDiplomacyStateTo(TargetPID,WarPID)~=DiplomacyState.Alliance then -- and target not allied with this -> outcommented: not preventing this, but chance is high that your request fails
              -- if (not g_LTL_Serp.IsHuman(TargetPID) and not g_LTL_Serp.IsHuman(WarPID)) or not ts.Participants.GetCheckDiplomacyStateTo(TargetPID,WarPID,DiplomacyState.NonAttack) then -- if both are AI, we ignore NonAttack. If one is human, we only declare war on no-NonAttack (we ignore CeaseFire, since then there is already war anyways)
                return true
              -- end
            -- end
          end
        end
      end
    end
  end
  
  local function GetJoinWarCandidatesTargetPID(TargetPID)
    local PID = ts.Participants.GetGetCurrentParticipantID()
    local DiplomacyState = g_LTL_Serp.DiplomacyState
    local WarPIDs = {}
    if PID~=TargetPID and g_LTL_Serp.table_contains_value(g_DiploActions_Serp.SupportedPIDs_WarAndGiftShip,TargetPID) and ts.Participants.GetTopLevelDiplomacyStateTo(PID,TargetPID)==DiplomacyState.Alliance then
      for _,WarPID in pairs(g_DiploActions_Serp.SupportedPIDs_WarAndGiftShip) do
        if WarPID~=PID and WarPID~=TargetPID and g_DiploActions_Serp.CanJoinWarAgainstCandidate(PID,TargetPID,WarPID) then
          table.insert(WarPIDs,WarPID)
        end
      end
    end
    return WarPIDs
  end
  
  -- called via ActionExecuteScript event when the local human starts the action to request someone to join war
  local function CacheSuccessChanceJoinWar(PID)
    if PID == ts.Participants.GetGetCurrentParticipantID() then
      g_LTL_Serp.start_thread("CacheSuccessChanceJoinWar_random_",ModID,function()
        local continue = g_LTM_Serp.ContinueCoopCalled()
        if continue then
          for WarPID,ProductGuid in pairs(g_DiploActions_Serp.JoinWarSuccessHelpProduct) do
            ts.Economy.MetaStorage.AddAmount(ProductGuid, -1000) -- reset all products to 0 (can not be negative)
          end
          for WarPID,ProductGuid in pairs(g_DiploActions_Serp.JoinWarSuccessHelpProduct) do 
            while ts.Economy.MetaStorage.GetStorageAmount(ProductGuid)~=0 do
              coroutine.yield() -- wait until all are reset to 0
            end
          end
          local TargetPID = g_DiploActions_Serp.GetDiploSelectedPID()
          if TargetPID~=nil and not g_LTL_Serp.IsHuman(TargetPID) then
            local WarPIDs = g_DiploActions_Serp.GetJoinWarCandidatesTargetPID(TargetPID)
            for _,WarPID in pairs(WarPIDs) do
              local chance = g_DiploActions_Serp.CalcChanceJoinWarAgainst(PID,TargetPID,WarPID)
              chance = chance * 100
              if continue=="AllCoop" then
                chance = chance / g_CoopCountResSerp.LocalCount
              end
              chance = g_LTL_Serp.myround(chance)
              chance = math.max(0,math.min(100,chance))
              local ProductGuid = g_DiploActions_Serp.JoinWarSuccessHelpProduct[WarPID]
              ts.Economy.MetaStorage.AddAmount(ProductGuid,chance)
              g_LTL_Serp.modlog("CacheSuccessChanceJoinWar setze "..tostring(ProductGuid).." auf "..tostring(chance),ModID)
            end
          end
        end
      end)
    end
  end 
   
  
  -- chance anzeigen, am besten über Meta Ressource Helper, eine pro participant
  local function CalcChanceJoinWarAgainst(PID,TargetPID,WarPID)
    local RepToRequester = ts.Participants.GetParticipantReputationTo(TargetPID,PID)
    local RepToWarCandidate = ts.Participants.GetParticipantReputationTo(TargetPID,WarPID)
    local chanceforwar = ((RepToRequester - RepToWarCandidate) / 100) * 2
    if WarPID==g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID or WarPID==g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID or TargetPID==g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID or TargetPID==g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID then
      chanceforwar = chanceforwar * 1.25 -- if any of them is pirate, increased chance, because pirates like to declare war and everyone like to declare war on pirates
    end -- not need to check Trade/Alliance because this is indirectly within Reputation
    if ts.Participants.GetCheckDiplomacyStateTo(TargetPID,WarPID,g_LTL_Serp.DiplomacyState.NonAttack) then -- but if they have NonAttack
      chanceforwar = chanceforwar * 0.5 -- half the chance (but still allow it, because NonAttack sucks with 5 hours duration)
    end
    chanceforwar = math.min(1,math.max(0,chanceforwar),chanceforwar) -- between 0 and 1
    return chanceforwar
  end
  
  local function CalcSuccessJoinWarAgainst(PID,TargetPID,WarPID,continue)
    if continue==nil then -- can also be false, which is fine
      continue = g_LTM_Serp.ContinueCoopCalled()
    end
    local action = "nothing"
    local chanceforwar = g_DiploActions_Serp.CalcChanceJoinWarAgainst(PID,TargetPID,WarPID)
    if continue=="IsFirst" then -- only executed for first coop peer
      if chanceforwar>=1 or math.random() < chanceforwar then -- should not use ContinueWithTotalChanceCoop here
        action = "war"
      end
    else -- executed for all coop peers
      if g_CoopCountResSerp.ContinueWithTotalChanceCoop(chanceforwar) then
        action = "war"
      end
    end
    if action=="nothing" then -- failed, cancel alliance with Requester, if in alliance with WarPID
      if ts.Participants.GetTopLevelDiplomacyStateTo(TargetPID,WarPID)==g_LTL_Serp.DiplomacyState.Alliance then
        action = "cancelalliance"
      end
    end
    return action
  end
  
  
  -- call this fn with help of g_LTL_Serp.t_FnViaTextEmbed to make sure its only executed for the peer who hits the button
   -- (even if non of the parameters are mandatory , otherwise might be executed for every coop peer, which is a problem in regards to using Selection Owner as WarPID)
  local function RequestJoinWarAgainstSelected(PID,TargetPID,WarPID)
    if PID==nil or PID == ts.Participants.GetGetCurrentParticipantID() then
      local continue = g_LTM_Serp.ContinueCoopCalled()
      if continue then
        PID = PID or ts.Participants.GetGetCurrentParticipantID()
        TargetPID = TargetPID or g_DiploActions_Serp.GetDiploSelectedPID()
        if WarPID==nil and ts.Selection.Object.GUID~=0 then -- checking GUID if sth is selected, because these are NullPointers and Owner=0 is valid, GUID=0 is not valid
          WarPID = ts.Selection.Object.Owner
        end
        g_LTL_Serp.modlog("RequestJoinWarAgainstSelected: PID:" ..tostring(PID).." TargetPID:"..tostring(TargetPID).." WarPID:"..tostring(WarPID),ModID)
        if TargetPID~=nil and WarPID~=nil and WarPID~=PID and WarPID~=TargetPID and PID~=TargetPID and g_DiploActions_Serp.CanJoinWarAgainstCandidate(PID,TargetPID,WarPID) then
          if g_LTL_Serp.IsHuman(TargetPID) then
            ts.Participants.SetDeclareWar(PID,WarPID) -- yes PID declares again War against the one he is already at war. This will Trigger a Vanilla notification for all Humans to join the war or cancel alliance (this notification only happens if the war is declared AFTER the alliance was build).
            ts.Unlock.SetRelockNet(1500005323) -- Join War Notification. vanilla does not send a response
          else -- AI
            local action = g_DiploActions_Serp.CalcSuccessJoinWarAgainst(PID,TargetPID,WarPID,continue)
            if action=="war" then
              g_LTL_Serp.modlog("RequestJoinWarAgainstSelected, War Declared to "..tostring(WarPID),ModID)
              ts.Participants.SetDeclareWar(TargetPID,WarPID) -- declare war
              ts.Unlock.SetRelockNet(g_DiploActions_Serp.DiploButtonsUnlocks.JoinWar) -- update buttons
              g_DiploActions_Serp.UnhideAllDiploButtons()
              ts.Unlock.SetRelockNet(1500005323) -- Join War Notification
            elseif action=="cancelalliance" then
              g_LTL_Serp.modlog("RequestJoinWarAgainstSelected: cancels alliance",ModID)
              ts.Participants.SetCancelAlliance(TargetPID,PID) -- sends itself a notification
            else -- nothing
              g_LTL_Serp.modlog("RequestJoinWarAgainstSelected: will not help",ModID)
              ts.Unlock.SetRelockNet(1500005324) -- send notification "No"
            end
            local repmalus = -3 -- always rep malus, regardless of result
            if continue=="IsFirst" and g_LTU_Serp~=nil then
              g_LTL_Serp.start_thread("ChangeRep-RequestJoinWarAgainstSelected",ModID,g_LTU_Serp.PeersInfo.t_ExecuteFnWithArgsForPeers,"ts.Participants.SetChangeParticipantReputationTo",nil,nil,"Everyone",TargetPID,PID,repmalus)
            elseif continue=="AllCoop" or g_LTU_Serp==nil then
              g_LTM_Serp.SimpleExecuteForEveryone("ts.Participants.SetChangeParticipantReputationTo",TargetPID,PID,repmalus)
            end
          end
        else
          g_LTL_Serp.modlog("RequestJoinWarAgainstSelected: invalid target",ModID)
          ts.Unlock.SetRelockNet(1500005325) -- send general side notification that TargetPID can not declare war on WarPID
        end
      end
    end
  end
  
  -- ####################################################################################################################
  -- ####################################################################################################################
  
  
    
  local function t_ChangeOwnerOfSelectionToPID(To_PID,ignoreowner,withoutRep,forbidpiratenewowner)
    To_PID = To_PID or ts.Participants.GetGetCurrentParticipantID()
    local continue = g_LTM_Serp.ContinueCoopCalled()
    if continue then
      g_LTL_Serp.modlog("t_ChangeOwnerOfSelectionToPID "..tostring(To_PID).." , "..tostring(ignoreowner),ModID)
      local OID = g_LTL_Serp.get_OID(session.getSelectedFactory())
      if OID~=nil and OID~=0 then
        local POwner = g_LTL_Serp.GetGameObjectPath(OID,"Owner")
        local SellPrice = g_LTL_Serp.GetGameObjectPath(OID,"Sellable.SellPrice.MoneyCost")
        local success = g_LTM_Serp.t_ChangeOwnerOIDToPID(OID,To_PID,ignoreowner,true,forbidpiratenewowner) -- must be called from within a thread
        local localPID = ts.Participants.GetGetCurrentParticipantID()
        if success then -- in theory I would credit 1 Rep per ship.. but it desyncs, so we need to register a trigger which starts data/scripts_serp/rep/rep1_gasparov_h0.lua , but we need every possible combination, so tons of scripts if we want to do it like this :D So we only do it if g_LTU_Serp is enabled (not included)
          if POwner~=nil then -- increase opinion from To_PID towards the Previous Owner of the gifted object
            if not withoutRep then
              local rep = 1 -- default price and eg for schoner ist 5000 , but expesinve ships can be over 1 million
              if SellPrice > 10000 then -- if you change the numbers here, also change them in GUID 1500005347
                rep = 2
              elseif SellPrice > 100000 then
                rep = 3
              elseif SellPrice > 500000 then
                rep = 4
              elseif SellPrice > 1000000 then
                rep = 5
              end
              if POwner==localPID then -- we can only check unlock from local, so with ignoreowner the Owner might always get Rep
                if ts.Unlock.GetIsUnlocked(g_DiploActions_Serp._OnCooldownGiftunlocks[To_PID]) then
                  rep = 0
                else -- start cooldown
                  ts.Unlock.SetUnlockNet(g_DiploActions_Serp._OnCooldownGiftunlocks[To_PID]) -- cooldown is active as long as its unlocked
                end
              end
              if rep~=0 then
                if continue=="IsFirst" and g_LTU_Serp~=nil then
                  g_LTL_Serp.start_thread("ChangeRep1ForGiftShip_random_",ModID,g_LTU_Serp.PeersInfo.t_ExecuteFnWithArgsForPeers,"ts.Participants.SetChangeParticipantReputationTo",nil,nil,"Everyone",To_PID,POwner,rep)
                elseif continue=="AllCoop" or g_LTU_Serp==nil then
                  g_LTM_Serp.SimpleExecuteForEveryone("ts.Participants.SetChangeParticipantReputationTo",To_PID,POwner,rep)
                end
              end
            end
          end
        else
          ts.Unlock.SetRelockNet(1500005611) -- sidenotification can not sell this ship
        end
      end
    end
  end
  
  local function IsGiftShipAllowed(TargetPID)
    if g_LTL_Serp.table_contains_value(g_DiploActions_Serp.SupportedPIDs_WarAndGiftShip,TargetPID) then
      local PID = ts.Participants.GetGetCurrentParticipantID()
      local DiplomacyState = g_LTL_Serp.DiplomacyState
      -- return PID~=TargetPID and ts.Participants.GetCheckDiplomacyStateTo(PID,TargetPID,DiplomacyState.TradeRights)
      return PID~=TargetPID and ts.Participants.GetCheckDiplomacyStateTo(PID,TargetPID,DiplomacyState.Peace)
    end
  end
  
  
  local function LockAllDiploButtons()
    for name,unlock in pairs(g_DiploActions_Serp.DiploButtonsUnlocks) do
      ts.Unlock.SetRelockNet(unlock)
    end
  end
  
  local function UnhideAllDiploButtons()
    ts.Conditions.RegisterTriggerForCurrentParticipant(1500005322) -- unhides, not a problem if executed multiple times at once
  end
  
  
  -- locking/unlocking offered diplo buttons based in selection and based on relation towards it
  local function UpdateOfferedDiploButtons(TargetPID,topdiplostate)
    g_LTL_Serp.start_thread("UpdateOfferedDiploButtons",ModID,function() -- mainly to catch any errors for our log..
    
        local PID = ts.Participants.GetGetCurrentParticipantID()
        g_LTL_Serp.modlog("UpdateOfferedDiploButtons: "..tostring(PID).." towards "..tostring(TargetPID)..", topdiplostate "..tostring(topdiplostate),ModID)
        g_DiploActions_Serp.LockAllDiploButtons()
        if PID~=TargetPID and TargetPID~=nil then
          topdiplostate = topdiplostate or ts.Participants.GetTopLevelDiplomacyStateTo(PID,TargetPID)
          local DiplomacyState = g_LTL_Serp.DiplomacyState
          
          local JoinWarCandidates = g_DiploActions_Serp.GetJoinWarCandidatesTargetPID(TargetPID)
          if next(JoinWarCandidates) then
            ts.Unlock.SetUnlockNet(g_DiploActions_Serp.DiploButtonsUnlocks.JoinWar)
          end
          if g_DiploActions_Serp.IsGiftShipAllowed(TargetPID) then
            ts.Unlock.SetUnlockNet(g_DiploActions_Serp.DiploButtonsUnlocks.GiftShip)
          end
        elseif TargetPID==nil then -- back button was hit, so no PID is now selected
          
        end
        g_DiploActions_Serp.UnhideAllDiploButtons()
        
    end)
  end
  
  local function OnPIDDiploSelection(PID)
    if PID == ts.Participants.GetGetCurrentParticipantID() then -- functions called via ActionExecuteScript need this check
      local CheckPID = g_DiploActions_Serp.GetDiploSelectedPID(true)
      g_LTL_Serp.modlog("OnPIDDiploSelection PID:"..tostring(PID).." , CheckPID:"..tostring(CheckPID),ModID)
      if CheckPID~=nil then
        g_DiploActions_Serp.UpdateOfferedDiploButtons(CheckPID)
        ts.Economy.MetaStorage.AddAmount(g_DiploActions_Serp.DiploSelectedHelper, CheckPID)
      else
        ts.Economy.MetaStorage.AddAmount(g_DiploActions_Serp.DiploSelectedHelper, -100000)
      end
    end
  end
  
  local function OnRelationChanged(PID,CheckPID,oldtopstate,newtopstate)
    local PID = PID or ts.Participants.GetGetCurrentParticipantID()
    g_LTL_Serp.modlog("OnRelationChanged: "..tostring(PID).." towards "..tostring(CheckPID).." changed from "..tostring(oldtopstate).." to "..tostring(newtopstate),ModID)
    local DiplomacyState = g_LTL_Serp.DiplomacyState
    local IsSelected = not ts.Unlock.GetIsUnlocked(g_DiploActions_Serp.SelectionUnlocks[CheckPID]) -- locked means selected. 
    if IsSelected then
      g_DiploActions_Serp.UpdateOfferedDiploButtons(CheckPID,newtopstate)
    end
    g_DiploActions_Serp.CachedTopRelations[CheckPID] = newtopstate -- update cache
  end
  local function _OnAnyRelationChanged(PID)
    if PID == ts.Participants.GetGetCurrentParticipantID() then -- functions called via ActionExecuteScript need this check
      -- g_LTL_Serp.modlog("_OnAnyRelationChanged to anyone for "..tostring(PID),ModID)
      for _,CheckPID in pairs(g_DiploActions_Serp.SupportedPIDs_WarAndGiftShip) do
        if CheckPID~=PID then
          local oldtopstate = g_DiploActions_Serp.CachedTopRelations[CheckPID]
          local newtopstate = ts.Participants.GetTopLevelDiplomacyStateTo(PID,CheckPID)
          if oldtopstate~=nil and newtopstate~=nil and oldtopstate ~= newtopstate then
            g_DiploActions_Serp.OnRelationChanged(PID,CheckPID,oldtopstate,newtopstate) -- updating cache is also done there
          end
        end
      end
    end
  end
  
  local function GetDiploSelectedPID(validate)
    local selectedPID = nil
    local PID = ts.Participants.GetGetCurrentParticipantID()
    for _,CheckPID in pairs(g_DiploActions_Serp.SupportedPIDs_All) do
      if not ts.Unlock.GetIsUnlocked(g_DiploActions_Serp.SelectionUnlocks[CheckPID]) then -- locked means selected. 
        if selectedPID==nil then
          selectedPID = CheckPID
          if not validate then
            break
          end
        elseif validate then -- only one can be selected at the same time (if triggers are working as intended), but if player hits the buttons very fast, it can bug...
          ts.Unlock.SetRelockNet(1500003907) -- reset everything
          return nil -- should not happen anylonger, Trigger is now reset faster. But just to be sure
        end
      end
    end
    return selectedPID -- can be nil, if nothing is selected
  end
  
  local function UpdateCachedRelations()
    local PID = ts.Participants.GetGetCurrentParticipantID()
    for _,CheckPID in pairs(g_DiploActions_Serp.SupportedPIDs_WarAndGiftShip) do
      if CheckPID~=PID then
        g_DiploActions_Serp.CachedTopRelations[CheckPID] = ts.Participants.GetTopLevelDiplomacyStateTo(PID,CheckPID)
      end
    end
  end
    
    -- #####################################################################################################
    -- #####################################################################################################

    
    -- Lua Tools Medium
    g_DiploActions_Serp = {
      t_ChangeOwnerOfSelectionToPID = t_ChangeOwnerOfSelectionToPID,
      RequestJoinWarAgainstSelected = RequestJoinWarAgainstSelected,
      CanJoinWarAgainstCandidate = CanJoinWarAgainstCandidate,
      CalcChanceJoinWarAgainst = CalcChanceJoinWarAgainst,
      CalcSuccessJoinWarAgainst = CalcSuccessJoinWarAgainst,
      GetJoinWarCandidates = GetJoinWarCandidates,
      GetJoinWarCandidatesTargetPID = GetJoinWarCandidatesTargetPID,
      SupportedPIDs_WarAndGiftShip = {0,1,2,3,25,26,27,28,29,30,31,32,33,34,64,17,18}, --  all humans, second party and pirates. should match the participants which are shown in the embassy mod for War related purpose (so no third party traders, except pirates)
      SupportedPIDs_All = {0,1,2,3,25,26,27,28,29,30,31,32,33,34,64,17,18,16,19,22,23,24,80,72,15}, --  should match all participants shown in embassy diplo mod
      CacheSuccessChanceJoinWar = CacheSuccessChanceJoinWar, -- internal use, called by event
      _OnAnyRelationChanged = _OnAnyRelationChanged, -- internal use, called by onrelationchanged_0.lua lua script if Trigger detects DiplomaticRelationChanged.
      OnRelationChanged = OnRelationChanged, --called via _OnAnyRelationChanged
      OnPIDDiploSelection = OnPIDDiploSelection, -- called via events script.
      DiploButtonsUnlocks = {JoinWar=1500005259,GiftShip=1500005300},
      GetDiploSelectedPID = GetDiploSelectedPID, -- currently selected PID in embassy diplo menu (if any)
      UpdateOfferedDiploButtons = UpdateOfferedDiploButtons, -- if you need to attach your code to this, simply save the original function, overwrite this one do you stuff in it and at the end return the original function
      IsGiftShipAllowed = IsGiftShipAllowed,
      LockAllDiploButtons = LockAllDiploButtons,
      UnhideAllDiploButtons = UnhideAllDiploButtons,
      UpdateCachedRelations = UpdateCachedRelations,
      DiploSelectedHelper = 1500005349,
      SelectionUnlocks = { -- PID=Unlock. if locked, it is selected
        [0]=1500005244,[1]=1500005245,[2]=1500005246,[3]=1500005247, -- Humans
        [25]=1500005223,[26]=1500005224,[27]=1500005225,[28]=1500005226,[29]=1500005227,[30]=1500005228,[31]=1500005229,[32]=1500005230,[33]=1500005231,[34]=1500005232,[64]=1500005233, -- second Party
        [17]=1500005234,[18]=1500005235,[16]=1500005236,[19]=1500005237,[22]=1500005238,[23]=1500005239,[24]=1500005240,[80]=1500005241,[72]=1500005242,[15]=1500005243,  -- pirates and thirdparty
      },
      JoinWarSuccessHelpProduct = { -- PID=Product
        [0]=1500005339,[1]=1500005340,[2]=1500005341,[3]=1500005342, -- Humans
        [25]=1500005326,[26]=1500005327,[27]=1500005328,[28]=1500005329,[29]=1500005330,[30]=1500005331,[31]=1500005332,[32]=1500005333,[33]=1500005334,[34]=1500005335,[64]=1500005336, -- second Party
        [17]=1500005337,[18]=1500005338, -- pirates
      },
      _OnCooldownGiftunlocks = { -- block request as long as this is unlocked
        [g_LTL_Serp.PIDs.Second_ai_01_Jorgensen.PID] = 1500004000,
        [g_LTL_Serp.PIDs.Second_ai_02_Qing.PID] = 1500004001,
        [g_LTL_Serp.PIDs.Second_ai_03_Wibblesock.PID] = 1500004002,
        [g_LTL_Serp.PIDs.Second_ai_04_Smith.PID] = 1500004003,
        [g_LTL_Serp.PIDs.Second_ai_05_OMara.PID] = 1500004004,
        [g_LTL_Serp.PIDs.Second_ai_06_Gasparov.PID] = 1500004005,
        [g_LTL_Serp.PIDs.Second_ai_07_von_Malching.PID] = 1500004006,
        [g_LTL_Serp.PIDs.Second_ai_08_Gravez.PID] = 1500004007,
        [g_LTL_Serp.PIDs.Second_ai_09_Silva.PID] = 1500004008,
        [g_LTL_Serp.PIDs.Second_ai_10_Hunt.PID] = 1500004009,
        [g_LTL_Serp.PIDs.Second_ai_11_Mercier.PID] = 1500004010,
        [g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID] = 1500004011,
        [g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID] = 1500004012,
      },
      CachedTopRelations = {} -- the local relations (TopLevelDiplomacyStateT) to other PIDs
    }
    
    -- on game load, update our cache
    g_LTL_Serp.start_thread("initial_UpdateCachedRelations",ModID,g_DiploActions_Serp.UpdateCachedRelations)
    
    
    g_LTL_Serp.start_thread("g_OnGameLeave_serp",ModID,function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_DiploActions_Serp = nil
        end
      end
    end)
    g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)
    
end