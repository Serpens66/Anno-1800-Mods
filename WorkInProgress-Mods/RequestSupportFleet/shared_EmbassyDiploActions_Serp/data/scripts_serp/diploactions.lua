-- Only this script gets loaded via ActionExecuteScript on GameLoaded and it starts all other lua scripts
-- (ok, event_savegame_loaded.lua is called first via ActionExecuteScript and then starts this here via Unlock 1500004636)


-- TODO:
 -- test if it works in MP and does not desync


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
    
    
  -- no need to call from within a thread, starts a thread on its own (to be able to call t_ChangeOwnerOIDToPID)
   -- note to self: do not change this function to a thread-only function, because it will be used in CharacterNotification via FnViaTextEmbed 
  local function ChangeOwnerOfSelectionToPID(To_PID,ignoreowner)
    g_LTL_Serp.start_thread("ChangeOwnerOfSelectionToPID",ModID,function()
      g_LTL_Serp.modlog("ChangeOwnerOfSelectionToPID "..tostring(To_PID).." , "..tostring(ignoreowner),ModID)
      local OID = g_LTL_Serp.get_OID(session.getSelectedFactory())
      if OID~=nil and OID~=0 then
        local success = g_LTM_Serp.t_ChangeOwnerOIDToPID(OID,To_PID,ignoreowner) -- must be called from within a thread
        -- if success then -- reaction notification and Reputation? 
          -- TODO Kann ich eventuell einen Shared Reactions mod machen, 
           -- ne braucht man nicht, ist eig ziemlich straight forward.
            -- Aber am besten mal eine Schablone/Beispielmod dazu machen
             -- den ich copy pasten und nur GUIDs und werte austauschen muss
              -- kann dann auch github code snippets hochgeladen werden
             -- bzw. vllt auch mit lua kombinieren. victim in current session spawnen
              -- und mit lua in currentsession bis zu der guid loopen und AddDamagePercent machen.
             -- Vorteil: Kein Risiko dass falsche schiffe beschossen werden.
        -- end
      end
    end)
  end
  
  
  local function GetJoinWarCandidatesTargetPID(TargetPID)
    local PID = ts.Participants.GetGetCurrentParticipantID()
    local DiplomacyState = g_DiploActions_Serp.DiplomacyState
    local TargetPIDs = {}
    if PID~=TargetPID and g_LTL_Serp.table_contains_value(g_DiploActions_Serp.SupportedPIDs_War,TargetPID) and ts.Participants.GetTopLevelDiplomacyStateTo(PID,TargetPID)==DiplomacyState.Alliance then
      for _,CheckPID in pairs(g_DiploActions_Serp.SupportedPIDs_War) do
        if CheckPID~=PID and CheckPID~=TargetPID then
          if ts.Participants.GetTopLevelDiplomacyStateTo(PID,CheckPID)==DiplomacyState.War then -- if we have war with one
            if ts.Participants.GetTopLevelDiplomacyStateTo(TargetPID,CheckPID)~=DiplomacyState.War then -- and Target does not have already war with this
              if ts.Participants.GetTopLevelDiplomacyStateTo(TargetPID,CheckPID)~=DiplomacyState.Alliance then -- and target not allied with this
                if (not g_LTL_Serp.IsHuman(TargetPID) and not g_LTL_Serp.IsHuman(CheckPID)) or not ts.Participants.GetCheckDiplomacyStateTo(TargetPID,CheckPID,DiplomacyState.NonAttack) then -- if both are AI, we ignoe NonAttack. If one is human, we only declare war on no-NonAttack (we ignore CeaseFire, since then there is already war anyways)
                  table.insert(TargetPIDs,CheckPID)
                end
              end
            end
          end
        end
      end
    end
    return TargetPIDs
  end
  
  
  -- TODO:
   -- im Coop hab ich 2 Meldungen bekommen "es herrscht nun Krieg zwischen"
    -- im sp gabs glaub ich nur eine, oder?
    -- lässt sich ohne Ultra Mod aber denke ich nicht ändern
  
  -- should not hurt if executed multiple times in coop ...
  local function DeclareWarToAllMyEnemies(TargetPID)
    local PID = ts.Participants.GetGetCurrentParticipantID()
    g_LTL_Serp.modlog("DeclareWarToAllMyEnemies "..tostring(PID).." , "..tostring(TargetPID),ModID)
    local DiplomacyState = g_DiploActions_Serp.DiplomacyState
    local success = false
    local JoinWarCandidates = g_DiploActions_Serp.GetJoinWarCandidatesTargetPID(TargetPID)
    for _,CheckPID in ipairs(JoinWarCandidates) do -- no exception for humans, also they can be forced into war, if in alliance with another human
      g_LTL_Serp.modlog("DeclareWarToAllMyEnemies, War Declared to "..tostring(CheckPID),ModID)
      ts.Participants.SetDeclareWar(TargetPID,CheckPID) -- declare war
      success = true -- at least one
    end
    if success then
      g_DiploActions_Serp.UpdateOfferedDiploButtons(TargetPID) -- update buttons
    end
    -- if not success then
      -- credit costs back or so. if we dont use LuaTools_Ultra, we have to do it via an FeatureUnlock in xml, do to it only once, even if coop
    -- end
    return success
  end
  
  local function IsGiftShipAllowed(TargetPID)
    local PID = ts.Participants.GetGetCurrentParticipantID()
    local DiplomacyState = g_DiploActions_Serp.DiplomacyState
    -- return PID~=TargetPID and ts.Participants.GetCheckDiplomacyStateTo(PID,TargetPID,DiplomacyState.TradeRights)
    return PID~=TargetPID and ts.Participants.GetCheckDiplomacyStateTo(PID,TargetPID,DiplomacyState.Peace)
  end
  
  
  local function LockAllDiploButtons()
    for name,unlock in pairs(g_DiploActions_Serp.DiploButtonsUnlocks) do
      ts.Unlock.SetRelockNet(unlock)
    end
  end
  
  
  -- TODO:
   -- im Multiplayer klappt das unhide nach dem LockAllDiploButtons noch nicht so richtig,
    -- vermutlich racecondition.
    -- Irgendwie sicherer aufbauen, zb. nach LockAllDiploButtons FeatureUnlock starten, welches alles unhided
  
  -- locking/unlocking offered diplo buttons based in selection and based on relation towards it
  local function UpdateOfferedDiploButtons(TargetPID,topdiplostate)
    local PID = ts.Participants.GetGetCurrentParticipantID()
    g_LTL_Serp.modlog("UpdateOfferedDiploButtons: "..tostring(PID).." towards "..tostring(TargetPID)..", topdiplostate "..tostring(topdiplostate),ModID)
    g_DiploActions_Serp.LockAllDiploButtons()
    if PID~=TargetPID and TargetPID~=nil then
      topdiplostate = topdiplostate or ts.Participants.GetTopLevelDiplomacyStateTo(PID,TargetPID)
      local DiplomacyState = g_DiploActions_Serp.DiplomacyState
      
      local JoinWarCandidates = g_DiploActions_Serp.GetJoinWarCandidatesTargetPID(TargetPID)
      if next(JoinWarCandidates) then
        ts.Unlock.SetUnlockNet(g_DiploActions_Serp.DiploButtonsUnlocks.JoinWar)
      end
      if g_DiploActions_Serp.IsGiftShipAllowed(TargetPID) then
        ts.Unlock.SetUnlockNet(g_DiploActions_Serp.DiploButtonsUnlocks.GiftShip)
      end
      -- if g_LTL_Serp.IsHuman(TargetPID) then -- exceptions for humans?
        
      -- end
    elseif TargetPID==nil then -- back button was hit, so no PID is now selected
      
    end
  end
  
  local function OnPIDDiploSelection(PID)
    if PID == ts.Participants.GetGetCurrentParticipantID() then -- functions called via ActionExecuteScript need this check
      local CheckPID = g_DiploActions_Serp.GetDiploSelectedPID()
      g_DiploActions_Serp.UpdateOfferedDiploButtons(CheckPID)
    end
  end
  
  -- todo? wenn ich jemanden anderen den krieg erkläre, dann kann sich JoinWar natürlich auch updaten..
   -- ist aber denke ich nicht so super wichtig, dann einfach zurück drücken und wieder rein...
  local function OnRelationChanged(CheckPID,oldtopstate,newtopstate)
    local PID = ts.Participants.GetGetCurrentParticipantID()
    g_LTL_Serp.modlog("OnRelationChanged: "..tostring(PID).." towards "..tostring(CheckPID).." changed from "..tostring(oldtopstate).." to "..tostring(newtopstate),ModID)
    local DiplomacyState = g_DiploActions_Serp.DiplomacyState
    local IsSelected = not ts.Unlock.GetIsUnlocked(g_DiploActions_Serp.SelectionUnlocks[CheckPID]) -- locked means selected. 
    if IsSelected then
      g_DiploActions_Serp.UpdateOfferedDiploButtons(CheckPID,newtopstate)
    end
    g_DiploActions_Serp.CachedTopRelations[CheckPID] = newtopstate -- update cache
  end
  
  local function _OnAnyRelationChanged(PID)
    if PID == ts.Participants.GetGetCurrentParticipantID() then -- functions called via ActionExecuteScript need this check
      -- g_LTL_Serp.modlog("_OnAnyRelationChanged to anyone for "..tostring(PID),ModID)
      for _,CheckPID in pairs(g_DiploActions_Serp.SupportedPIDs_War) do
        if CheckPID~=PID then
          local oldtopstate = g_DiploActions_Serp.CachedTopRelations[CheckPID]
          local newtopstate = ts.Participants.GetTopLevelDiplomacyStateTo(PID,CheckPID)
          if oldtopstate~=nil and newtopstate~=nil and oldtopstate ~= newtopstate then
            g_DiploActions_Serp.OnRelationChanged(CheckPID,oldtopstate,newtopstate) -- updating cache is also done there
          end
        end
      end
    end
  end
  
  local function GetDiploSelectedPID()
    local selectedPID = nil
    local PID = ts.Participants.GetGetCurrentParticipantID()
    for _,CheckPID in pairs(g_DiploActions_Serp.SupportedPIDs_All) do
      if not ts.Unlock.GetIsUnlocked(g_DiploActions_Serp.SelectionUnlocks[CheckPID]) then -- locked means selected. 
        selectedPID = CheckPID
        break -- only one can be selected at the same time (if triggers are working as intended)
      end
    end
    return selectedPID -- can be nil, if nothing is selected
  end
  
  local function UpdateCachedRelations()
    local PID = ts.Participants.GetGetCurrentParticipantID()
    for _,CheckPID in pairs(g_DiploActions_Serp.SupportedPIDs_War) do
      if CheckPID~=PID then
        g_DiploActions_Serp.CachedTopRelations[CheckPID] = ts.Participants.GetTopLevelDiplomacyStateTo(PID,CheckPID)
      end
    end
  end
    
    -- #####################################################################################################
    -- #####################################################################################################

    
    -- Lua Tools Medium
    g_DiploActions_Serp = {
      ChangeOwnerOfSelectionToPID = ChangeOwnerOfSelectionToPID,
      GetJoinWarCandidates = GetJoinWarCandidates,
      DeclareWarToAllMyEnemies = DeclareWarToAllMyEnemies,
      GetJoinWarCandidatesTargetPID = GetJoinWarCandidatesTargetPID,
      SupportedPIDs_War = {0,1,2,3,25,26,27,28,29,30,31,32,33,34,64,17,18}, --  all humans, second party and pirates. should match the participants which are shown in the embassy mod for War related purpose (so no third party traders, except pirates)
      SupportedPIDs_All = {0,1,2,3,25,26,27,28,29,30,31,32,33,34,64,17,18,16,19,22,23,24,80,72,15}, --  should match all participants shown in embassy diplo mod
      DiplomacyState = {War=0,Peace=1,TradeRights=2,Alliance=3,CeaseFire=4,NonAttack=5}, -- from datasets.xml
      _OnAnyRelationChanged = _OnAnyRelationChanged, -- internal use, called by onrelationchanged_0.lua lua script if Trigger detects DiplomaticRelationChanged.
      OnRelationChanged = OnRelationChanged, --called via _OnAnyRelationChanged
      OnPIDDiploSelection = OnPIDDiploSelection, -- called via events script.
      DiploButtonsUnlocks = {JoinWar=1500005259,GiftShip=1500005300},
      GetDiploSelectedPID = GetDiploSelectedPID, -- currently selected PID in embassy diplo menu (if any)
      UpdateOfferedDiploButtons = UpdateOfferedDiploButtons, -- if you need to attach your code to this, simply save the original function, overwrite this one do you stuff in it and at the end return the original function
      IsGiftShipAllowed = IsGiftShipAllowed,
      LockAllDiploButtons = LockAllDiploButtons,
      UpdateCachedRelations = UpdateCachedRelations,
      SelectionUnlocks = { -- PID=Unlock. if locked, it is selected
        [0]=1500005244,[1]=1500005245,[2]=1500005246,[3]=1500005247, -- Humans
        [25]=1500005223,[26]=1500005224,[27]=1500005225,[28]=1500005226,[29]=1500005227,[30]=1500005228,[31]=1500005229,[32]=1500005230,[33]=1500005231,[34]=1500005232,[64]=1500005233, -- second Party
        [17]=1500005234,[18]=1500005235,[16]=1500005236,[19]=1500005237,[22]=1500005238,[23]=1500005239,[24]=1500005240,[80]=1500005241,[72]=1500005242,[15]=1500005243,  -- pirates and thirdparty
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