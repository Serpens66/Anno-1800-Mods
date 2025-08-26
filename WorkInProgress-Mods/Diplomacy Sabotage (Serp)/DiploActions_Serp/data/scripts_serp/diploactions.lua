-- Only this script gets loaded via ActionExecuteScript on GameLoaded and it starts all other lua scripts
-- (ok, event_savegame_loaded.lua is called first via ActionExecuteScript and then starts this here via Unlock 1500004636)



  
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
  
  -- TODO:
  -- in den Piratenschiffe-Pool 700138 dürfen nur schiffe rein, die der pirat aktiv nutzt.
   -- aber da dem pirat auch die sale version gehört, darf ich diese schiffe natürlich nicht vom pirat entfernen.
   -- evlt diese in einen eigenen neuen pool packen?
  -- sale version kommt in playerships





local ModID = "shared_EmbassyDiploActions_Serp diploactions.lua" -- used for logging

if g_LuaScriptBlockers[ModID]==nil then
        
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    

    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end

    g_LTL_Serp.modlog("diploactions.lua registered",ModID)
    
    
    g_LTL_Serp.start_thread("check_g_LTM_Serp",ModID,function()
      local notstop = 0
      while g_LTM_Serp==nil and notstop<1000 do
        coroutine.yield()
        notstop = notstop + 1
      end
      if g_LTM_Serp==nil then
        g_LTL_Serp.modlog("ERROR requires shared_LuaTools_Medium_Serp",ModID)
      end
    end)
    
    
    -- #####################################################################################################
    -- #####################################################################################################
    
  -- JOIN WAR
  
  local function ShouldShowJoinWar(PID,TargetPID,topdiplostate,isfrequentcheck,actionname)
    local JoinWarCandidates = g_DiploActions_Serp.GetJoinWarCandidatesTargetPID(PID,TargetPID,true)
    if next(JoinWarCandidates) then
      return true
    end
  end
  
  local function CanJoinWarAgainstCandidate(PID,TargetPID,WarPID)
    PID = PID or ts.Participants.GetGetCurrentParticipantID()
    local DiplomacyState = g_LTL_Serp.DiplomacyState
    if PID~=TargetPID and g_LTL_Serp.table_contains_value(g_DiploActions_Serp.DiploButtonsUnlocks.JoinWar.AllowedFor,TargetPID) and ts.Participants.GetTopLevelDiplomacyStateTo(PID,TargetPID)==DiplomacyState.Alliance then
      if WarPID~=PID and WarPID~=TargetPID and g_LTL_Serp.table_contains_value(g_DiploActions_Serp.DiploButtonsUnlocks.JoinWar.AllowedFor,WarPID) then
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
  
  local function GetJoinWarCandidatesTargetPID(PID,TargetPID,checkany)
    PID = PID or ts.Participants.GetGetCurrentParticipantID()
    local DiplomacyState = g_LTL_Serp.DiplomacyState
    local WarPIDs = {}
    if PID~=TargetPID and g_LTL_Serp.table_contains_value(g_DiploActions_Serp.DiploButtonsUnlocks.JoinWar.AllowedFor,TargetPID) and ts.Participants.GetTopLevelDiplomacyStateTo(PID,TargetPID)==DiplomacyState.Alliance then
      for _,WarPID in pairs(g_DiploActions_Serp.DiploButtonsUnlocks.JoinWar.AllowedFor) do
        if WarPID~=PID and WarPID~=TargetPID and g_DiploActions_Serp.CanJoinWarAgainstCandidate(PID,TargetPID,WarPID) then
          table.insert(WarPIDs,WarPID)
          if checkany then -- just to check if there is any, so we should unlock the action or not
            break
          end
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
            local WarPIDs = g_DiploActions_Serp.GetJoinWarCandidatesTargetPID(PID,TargetPID)
            for _,WarPID in pairs(WarPIDs) do
              local chance = g_DiploActions_Serp.CalcChanceJoinWarAgainst(PID,TargetPID,WarPID)
              chance = chance * 100
              g_LTL_Serp.modlog("CacheSuccessChanceJoinWar chance vor coop: "..tostring(chance),ModID)
              if continue=="AllCoop" then
                chance = chance / g_CoopCountResSerp.LocalCount
              end
              -- TODO:
               -- aus inem Grund wird AddAmount hier auch im Coop nur einmal ausgeführt?!
                -- zumindest wird bei Chance von 25 es durch LocalCount auf 13 gerundet
                 -- und beide peers führen laut lua log AddAmount 13 aus. und am Ende ist es auch nach x sekunden
                  -- insg. 13. Warum?!
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
    -- g_LTL_Serp.modlog(tostring(RepToRequester).." vs "..tostring(RepToWarCandidate),ModID)
    local chanceforwar = ((RepToRequester - RepToWarCandidate) / 100) * 2
    g_LTL_Serp.modlog("CalcChanceJoinWarAgainst chance before multiplicator: "..tostring(chanceforwar),ModID)
    if WarPID==g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID or WarPID==g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID or TargetPID==g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID or TargetPID==g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID then
      chanceforwar = chanceforwar * 1.25 -- if any of them is pirate, increased chance, because pirates like to declare war and everyone like to declare war on pirates
    end -- not need to check Trade/Alliance because this is indirectly within Reputation
    if ts.Participants.GetCheckDiplomacyStateTo(TargetPID,WarPID,g_LTL_Serp.DiplomacyState.NonAttack) then -- but if they have NonAttack
      chanceforwar = chanceforwar * 0.5 -- half the chance (but still allow it, because NonAttack sucks with 5 hours duration)
    end
    -- g_LTL_Serp.modlog(tostring(chanceforwar),ModID)
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
              ts.Unlock.SetRelockNet(g_DiploActions_Serp.DiploButtonsUnlocks.JoinWar.unlock) -- update buttons
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
              g_LTM_Serp.SimpleExecuteForEveryone(PID,"ts.Participants.SetChangeParticipantReputationTo",TargetPID,PID,repmalus)
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
  
  -- GIFT SHIP
  

  local function IsGiftShipAllowed(PID,TargetPID,topdiplostate,isfrequentcheck,actionname)
    if g_LTL_Serp.table_contains_value(g_DiploActions_Serp.DiploButtonsUnlocks[actionname].AllowedFor,TargetPID) then
      PID = PID or ts.Participants.GetGetCurrentParticipantID()
      topdiplostate = topdiplostate or ts.Participants.GetTopLevelDiplomacyStateTo(PID,TargetPID)
      local DiplomacyState = g_LTL_Serp.DiplomacyState
      -- return PID~=TargetPID and ts.Participants.GetCheckDiplomacyStateTo(PID,TargetPID,DiplomacyState.TradeRights)
      return PID~=TargetPID and ts.Participants.GetCheckDiplomacyStateTo(PID,TargetPID,DiplomacyState.Peace)
    end
  end
  
  -- only call it from perspective of one human, not all.
   -- multiple coop peers executing this should be ok, but will change owner of selection!
  local function t_ChangeOwnerOfSelectionToPID(To_PID,ignoreowner,withoutRep,forbidpiratenewowner)
    To_PID = To_PID or ts.Participants.GetGetCurrentParticipantID()
    local continue = g_LTM_Serp.ContinueCoopCalled()
    if continue then
      g_LTL_Serp.modlog("t_ChangeOwnerOfSelectionToPID "..tostring(To_PID).." , "..tostring(ignoreowner),ModID)
      local OID = g_LTL_Serp.get_OID(session.getSelectedFactory())
      if OID~=nil and OID~=0 then
        local POwner = g_LTL_Serp.GetGameObjectPath(OID,"Owner")
        -- local Price = g_LTL_Serp.GetGameObjectPath(OID,"Sellable.SellPrice.MoneyCost") -- SellPrice is negative and has SellPriceFactor in it, with is 0.5 for most ships
        local Price = g_LTL_Serp.GetGameObjectPath(OID,"Sellable.CurrentParticipantBuyPrice.MoneyCost")
        local success = g_LTM_Serp.t_ChangeOwnerOIDToPID(OID,To_PID,ignoreowner,true,forbidpiratenewowner,ModID) -- must be called from within a thread
        local localPID = ts.Participants.GetGetCurrentParticipantID()
        if success then -- in theory I would credit 1 Rep per ship.. but it desyncs, so we need to register a trigger which starts data/scripts_serp/rep/rep1_gasparov_h0.lua , but we need every possible combination, so tons of scripts if we want to do it like this :D So we only do it if g_LTU_Serp is enabled (not included)
          if POwner~=nil then -- increase opinion from To_PID towards the Previous Owner of the gifted object
            if not withoutRep then
              local rep = 1 -- default price and eg for schoner ist 5000 , but expesinve ships can be over 1 million
              if Price > 10000 then -- if you change the numbers here, also change them in GUID 1500005347
                rep = 2
              elseif Price > 100000 then
                rep = 3
              elseif Price > 500000 then
                rep = 4
              elseif Price > 1000000 then
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
                  g_LTM_Serp.SimpleExecuteForEveryone(PID,"ts.Participants.SetChangeParticipantReputationTo",To_PID,POwner,rep)
                end
              end
            end
          end
        -- else -- notification is already done in g_LTM_Serp.t_ChangeOwnerOIDToPID
          -- ts.Unlock.SetRelockNet(1500005611) -- sidenotification can not sell this ship
        end
      end
    end
  end
  
  -- ####################################################################################################################
  -- ####################################################################################################################
  
  -- Share Goods Access.
   -- we could use xml ActionMenuVisibility instead, but this also hits coop (and for whatever reason also the first time all humans? or is my trigger wrong?)
   -- so we use lua and check if the executing player has a Kontor from another human selected
  
  local function ShouldShowShareGoods(PID,TargetPID,topdiplostate,isfrequentcheck,actionname)
    return g_LTL_Serp.IsHuman(TargetPID)
  end
  
  local function IsKontorSelectedFrom(PID,TargetPID)
    if ts.Selection.Object.GUID~=0 and ts.Selection.Object.IsKontor and (TargetPID==nil or ts.Selection.Object.Owner==TargetPID) then
      return true
    end
    return false
  end

  local function AccessKontorView(PID,TargetPID)
    if PID == ts.Participants.GetGetCurrentParticipantID() then -- functions called via ActionExecuteScript need this check
      if g_DiploActions_Serp.IsKontorSelectedFrom(PID,TargetPID) then
        ts.Interface.ToggleStateVisibility("ObjectMenuKontor")
      end
    end
  end

  -- ####################################################################################################################
  -- ####################################################################################################################
  
  local function CommandAllowedForSelection()
    local function ExecuteCommandAllowedForSelection()
      local PID = ts.Participants.GetGetCurrentParticipantID()
      local onlyallowedowner_selected = true
      for i,userdata in ipairs(session.selection) do
        if g_LTL_Serp.IsUserdataValid(userdata) then
          local OID = g_LTL_Serp.get_OID(userdata)
          if OID~=nil then
            local Owner = g_LTL_Serp.GetGameObjectPath(OID,"Owner")
            if not g_DiploActions_Serp.CommandAllyAllowed(PID,Owner,nil,nil,"CommandAlly",OID) then
              onlyallowedowner_selected = false
            end
          end
        end
      end
      return onlyallowedowner_selected
    end
    status,result = xpcall(ExecuteCommandAllowedForSelection,g_LTL_Serp.log_error) -- for error reporting in lua log
    if status==true then
      return result
    end
    return false
  end
  
  
  local function CommandAllyAllowed(PID,TargetPID,topdiplostate,isfrequentcheck,actionname,OID,Owner)
    local ShipInfiltratedBuff = 1500002744 -- from Sabotage mod, made as StatusEffect via Projectile on ships
    Owner = Owner or TargetPID
    if g_LTL_Serp.table_contains_value(g_DiploActions_Serp.DiploButtonsUnlocks[actionname].AllowedFor,TargetPID) then
      if PID==Owner then 
        return true
      elseif TargetPID==Owner then
        if g_LTL_Serp.GetGameObjectPath(OID,"Attackable.GetIsPartOfActiveStatusEffectChain("..tostring(ShipInfiltratedBuff)..")") then
          return true
        end
        if g_LTL_Serp.IsHuman(TargetPID) then
          if ts.Participants.GetParticipant(TargetPID).ProfileCounter.Stats.GetCounter(0,6,g_DiploActions_Serp.SharedAccessProducts[PID],3) then -- if the TargetPID has our helper product in stock, he allows it to us
            return true
          end
        else -- AI/Pirate
          topdiplostate = topdiplostate or ts.Participants.GetTopLevelDiplomacyStateTo(PID,TargetPID)
          if topdiplostate==g_LTL_Serp.DiplomacyState.Alliance then
            return true
          end
        end
      end
    end
    return false
  end
  
  -- Command Ally
  -- create/select a group of ships from an ally (since normal multi selection of ships not owned by self does not work)
  -- it is called via t_FnViaTextEmbed in CharacterNotification, so only the Peer who hits the button executes this
  local function CreateSelectGroup(action,TargetPID)
    local PID = ts.Participants.GetGetCurrentParticipantID()
    local SessionGUID = session.getSessionGUID()
    if SessionGUID~=0 and SessionGUID~=180039 and TargetPID~=nil then -- 180039 is worldmap
      if action==1 then -- addtogroup / delete group
        local onlyallowedornothing = true
        if next(session.selection) then -- if nothing is selected, group is overwritten with empty,so deleted
          local userdatas = {}
          for i,userdata in ipairs(session.selection) do
            if g_LTL_Serp.IsUserdataValid(userdata) then
              local OID = g_LTL_Serp.get_OID(userdata)
              if OID~=nil then
                local Owner = g_LTL_Serp.GetGameObjectPath(OID,"Owner")
                if g_DiploActions_Serp.CommandAllyAllowed(PID,TargetPID,nil,nil,"CommandAlly",OID,Owner) then
                  table.insert(userdatas,userdata)
                else
                  onlyallowedornothing = false
                end
              end
            end
          end
          ts.Selection.SelectionGroup.SetRestore(tonumber(tostring(SessionGUID)..tostring(TargetPID)))
          for i,userdata in ipairs(userdatas) do
            userdata:addToSelection()
          end
        end
        if onlyallowedornothing then
          ts.Selection.SelectionGroup.SetStore(tonumber(tostring(SessionGUID)..tostring(TargetPID))) -- save into group to also save it to savegame and fast selection
        end
      elseif action==2 then -- selectgroup
        ts.Selection.SelectionGroup.SetRestore(tonumber(tostring(SessionGUID)..tostring(TargetPID))) -- eg 18002325 (tested and works also with high number like 1500004017125)
        ts.Selection.SelectionGroup.SetRestore(tonumber(tostring(SessionGUID)..tostring(TargetPID))) -- calling it 2 times, so camera jumps to it
      end
    end
  end

  -- ####################################################################################################################

  local function ShouldShowNoSpies(PID,TargetPID,topdiplostate,isfrequentcheck,actionname)
    return (not g_LTL_Serp.IsHuman(TargetPID) and g_LTL_Serp.table_contains_value(g_DiploActions_Serp.DiploButtonsUnlocks[actionname].AllowedFor,TargetPID) )
  end

  -- ####################################################################################################################

  

  -- ####################################################################################################################
  -- ####################################################################################################################

  -- GENERAL Diplo Buttons Management
  
  local function LockAllDiploButtons()
    for name,info in pairs(g_DiploActions_Serp.DiploButtonsUnlocks) do
      -- g_LTL_Serp.modlog("LockAllDiploButtons: "..tostring(name),ModID)
      ts.Unlock.SetRelockNet(info.unlock)
    end
  end
  
  local function UnhideAllDiploButtons()
    ts.Conditions.RegisterTriggerForCurrentParticipant(1500005322) -- unhides, not a problem if executed multiple times at once
  end
  
  
  -- locking/unlocking offered diplo buttons based in selection and based on relation towards it
  local function OnSelectUpdateOfferedDiploButtons(PID,TargetPID)
    g_LTL_Serp.start_thread("OnSelectUpdateOfferedDiploButtons"..tostring(TargetPID),ModID,function() -- mainly to catch any errors for our log..
      local continue = g_LTM_Serp.ContinueCoopCalled()
      if continue then
        PID = PID or ts.Participants.GetGetCurrentParticipantID()
        g_LTL_Serp.modlog("OnSelectUpdateOfferedDiploButtons: "..tostring(PID).." towards "..tostring(TargetPID)..", topdiplostate "..tostring(topdiplostate),ModID)
        g_DiploActions_Serp.LockAllDiploButtons()
        local topdiplostate = ts.Participants.GetTopLevelDiplomacyStateTo(PID,TargetPID)
        for name,info in pairs(g_DiploActions_Serp.DiploButtonsUnlocks) do
          if g_LTL_Serp.table_contains_value(info.AllowedFor,TargetPID) and info.AllowedFn(PID,TargetPID,topdiplostate,nil,name) then
            ts.Unlock.SetUnlockNet(info.unlock)
          end
        end
        g_DiploActions_Serp.UnhideAllDiploButtons()
        g_LTL_Serp.waitForTimeDelta(10000)
        g_DiploActions_Serp.t_FrequentUpdateOfferedDiploButtons(PID,TargetPID)
      end
    end)
  end
  
  -- gets called from OnSelectUpdateOfferedDiploButtons and updates the buttons every 10 seconds as long as a TargetPID is selected
  local function t_FrequentUpdateOfferedDiploButtons(PID,TargetPID)
    local continue = g_LTM_Serp.ContinueCoopCalled()
    if continue then
      PID = PID ts.Participants.GetGetCurrentParticipantID()
      if TargetPID~=PID and TargetPID~=nil and TargetPID==g_DiploActions_Serp.GetDiploSelectedPID(true) then
        local topdiplostate = ts.Participants.GetTopLevelDiplomacyStateTo(PID,TargetPID)
        for name,info in pairs(g_DiploActions_Serp.DiploButtonsUnlocks) do
          if g_LTL_Serp.table_contains_value(info.AllowedFor,TargetPID) and info.AllowedFn(PID,TargetPID,topdiplostate,true,name) then
            if not ts.Unlock.GetIsUnlocked(info.unlock) then
              ts.Unlock.SetUnlockNet(info.unlock)
            end
          else
            if ts.Unlock.GetIsUnlocked(info.unlock) then
              ts.Unlock.SetRelockNet(info.unlock)
            end
          end
        end
        g_DiploActions_Serp.UnhideAllDiploButtons()
        g_LTL_Serp.waitForTimeDelta(10000)
        g_DiploActions_Serp.t_FrequentUpdateOfferedDiploButtons(PID,TargetPID)
      end
    end
  end
  
  -- called on Selection Change
  local function OnPIDDiploSelection(PID)
    if PID == ts.Participants.GetGetCurrentParticipantID() then -- functions called via ActionExecuteScript need this check
      local TargetPID = g_DiploActions_Serp.GetDiploSelectedPID(true)
      g_LTM_Serp.CallFnBlocked(function(PID,TargetPID) -- make sure its not executed too often within a second for the same PID
        local continue = g_LTM_Serp.ContinueCoopCalled()
        if continue then
          g_LTL_Serp.modlog("OnPIDDiploSelection PID:"..tostring(PID).." , TargetPID:"..tostring(TargetPID),ModID)
          if TargetPID~=nil then
            if ts.Economy.MetaStorage.GetStorageAmount(g_DiploActions_Serp.DiploSelectedHelper)==0 then
              local amount = TargetPID*100 -- we want to store PPID as amount to access it in texts. for Coop compatibility we have to divide it by coopcount, which only works after we multiplied it eg. with 100, since it only accepts integers
              if continue=="AllCoop" and amount~=0 then
                amount = g_LTL_Serp.myround( amount / g_CoopCountResSerp.LocalCount )
              end
              ts.Economy.MetaStorage.AddAmount(g_DiploActions_Serp.DiploSelectedHelper, amount)
            end
          else -- its not a problem that amount will be 0 for nil and Human0, since its just for text and if it is nil there is no relevant text
            ts.Economy.MetaStorage.AddAmount(g_DiploActions_Serp.DiploSelectedHelper, -100000)
          end
          if TargetPID~=nil then
            g_DiploActions_Serp.OnSelectUpdateOfferedDiploButtons(PID,TargetPID)
          -- else -- eg back button was hit
            --  then hide Targets which do not have any action
             -- ah wait, locking shows which one we have selected.
              -- So to hide the particiapnts, we have to remove their Buff... TODO
            -- for CheckPID,selectionunlock in pairs(g_DiploActions_Serp.SelectionUnlocks) do
              -- local anyactionallowed = false
              -- for name,info in pairs(g_DiploActions_Serp.DiploButtonsUnlocks) do
                -- if g_LTL_Serp.table_contains_value(info.AllowedFor,CheckPID) then -- only checking AllowedFor, not AllowedFn here, to decide if we even want to show a participant
                  -- anyactionallowed = true
                  -- break
                -- end
              -- end
              -- if not anyactionallowed then
                -- ts.Unlock.SetRelockNet(selectionunlock)
              -- end
            -- end
          end
        end
      end,"OnPIDDiploSelection_"..tostring(TargetPID),1000,PID,TargetPID)
    end
  end
  
  -- AI Shipyard mod support
  if AISpawner~=nil and AISpawner.SetCheatSpawnParticipant~=nil then
    local Orig_SetCheatSpawnParticipant = AISpawner.SetCheatSpawnParticipant
    AISpawner.SetCheatSpawnParticipant = function(ParticipantName,...)
      ts.Unlock.SetRelockNet(1500003907) -- reset to participant selection to show the new participant
      return Orig_SetCheatSpawnParticipant(ParticipantName,...)
    end
  end
  
  local function GetDiploSelectedPID(validate)
    local selectedPID = nil
    local PID = ts.Participants.GetGetCurrentParticipantID()
    for _,TargetPID in pairs(g_DiploActions_Serp.SupportedPIDs_All) do
      if not ts.Unlock.GetIsUnlocked(g_DiploActions_Serp.SelectionUnlocks[TargetPID]) then -- locked means selected. 
        if selectedPID==nil then
          selectedPID = TargetPID
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
      SupportedPIDs_All = {0,1,2,3,25,26,27,28,29,30,31,32,33,34,64,17,18,16,19,22,23,24,80,72,15}, --  should match all participants shown in embassy diplo mod
      CacheSuccessChanceJoinWar = CacheSuccessChanceJoinWar, -- internal use, called by event
      OnPIDDiploSelection = OnPIDDiploSelection, -- called via events script.
      DiploButtonsUnlocks = { -- also add your mod actions here. AllowedFn is called with: (PID,TargetPID,topdiplostate,isfrequentcheck,actionname). isfrequentcheck is true for the check every 10 seconds as long as a target is selected, so TargetPID does not change here, which may make your check fn faster to execute.
        JoinWar={unlock=1500005259,AllowedFn=ShouldShowJoinWar,AllowedFor={0,1,2,3,25,26,27,28,29,30,31,32,33,34,64,17,18}},
        GiftShip={unlock=1500005300,AllowedFn=IsGiftShipAllowed,AllowedFor={0,1,2,3,25,26,27,28,29,30,31,32,33,34,64,17,18}},
        ShareGoods={unlock=1500005356,AllowedFn=ShouldShowShareGoods,AllowedFor={0,1,2,3}},
        CommandAlly={unlock=1500004014,AllowedFn=CommandAllyAllowed,AllowedFor={0,1,2,3,25,26,27,28,29,30,31,32,33,34,64,17,18}},
        NoSpies={unlock=1500004020,AllowedFn=ShouldShowNoSpies,AllowedFor={25,26,27,28,29,30,31,32,33,34,64,17,18}},
      },
      GetDiploSelectedPID = GetDiploSelectedPID, -- currently selected PID in embassy diplo menu (if any)
      OnSelectUpdateOfferedDiploButtons = OnSelectUpdateOfferedDiploButtons, -- if you need to attach your code to this, simply save the original function, overwrite this one do you stuff in it and at the end return the original function
      t_FrequentUpdateOfferedDiploButtons = t_FrequentUpdateOfferedDiploButtons, -- if you need to attach your code to this, simply save the original function, overwrite this one do you stuff in it and at the end return the original function
      IsGiftShipAllowed = IsGiftShipAllowed,
      LockAllDiploButtons = LockAllDiploButtons,
      UnhideAllDiploButtons = UnhideAllDiploButtons,
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
      _OnCooldownNoSpiesProducts = { -- TimeLimit, if processing owns it, AI sends no spy. And as long it is > 10 Min , you can not request it again
        [g_LTL_Serp.PIDs.Second_ai_01_Jorgensen.PID] = 1500004024,
        [g_LTL_Serp.PIDs.Second_ai_02_Qing.PID] = 1500004025,
        [g_LTL_Serp.PIDs.Second_ai_03_Wibblesock.PID] = 1500004026,
        [g_LTL_Serp.PIDs.Second_ai_04_Smith.PID] = 1500004027,
        [g_LTL_Serp.PIDs.Second_ai_05_OMara.PID] = 1500004028,
        [g_LTL_Serp.PIDs.Second_ai_06_Gasparov.PID] = 1500004029,
        [g_LTL_Serp.PIDs.Second_ai_07_von_Malching.PID] = 1500004030,
        [g_LTL_Serp.PIDs.Second_ai_08_Gravez.PID] = 1500004031,
        [g_LTL_Serp.PIDs.Second_ai_09_Silva.PID] = 1500004032,
        [g_LTL_Serp.PIDs.Second_ai_10_Hunt.PID] = 1500004033,
        [g_LTL_Serp.PIDs.Second_ai_11_Mercier.PID] = 1500004034,
      },
      AccessKontorView = AccessKontorView,
      SharedAccessProducts = { -- if a human owns the Human0 product, it means Human0 is allowed to access his stuff
        [g_LTL_Serp.PIDs.Human0.PID] = 1500005350,
        [g_LTL_Serp.PIDs.Human1.PID] = 1500005351,
        [g_LTL_Serp.PIDs.Human2.PID] = 1500005352,
        [g_LTL_Serp.PIDs.Human3.PID] = 1500005353,
      },
      IsKontorSelectedFrom = IsKontorSelectedFrom,
      CommandAllyAllowed = CommandAllyAllowed,
      CommandAllowedForSelection = CommandAllowedForSelection,
      CreateSelectGroup = CreateSelectGroup,
    }
        
    
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