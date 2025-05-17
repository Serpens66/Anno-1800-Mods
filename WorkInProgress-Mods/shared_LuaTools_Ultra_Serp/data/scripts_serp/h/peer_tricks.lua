-- called via check_peers.lua


local ModID = "shared_LuaTools_Ultra_Serp peer_tricks.lua" -- used for logging

local DoHideUI = false -- hides the UI while we do our stuff. But also does not show notifications. So will be false for now to show a notification what we are doing

local HelpSessionGuid = 1500005538


-- TODO:
 -- Hinweis in Mod Description die diesen shared Mod nutzen:
  -- Bevor Mod in Savegame deaktiviert werden kann, muss dummysession unloaded werden. zb. console: session.unload(1500005538)
 -- Im Multiplayer besser über TriggerAction machen, siehe als Beispiel meinen xml code in No SunkenTreasure Session (Serp)
-- (wir unloaden selbst erst wenn nicht mehr gebraucht, um SessionID nicht in die Höhe zu treiben)


-- info:
-- ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(0) returned im Multiplayer nicht die worldmap 180039 (sondern dann session wo man vorher drin war)
 -- im SP schon ... deswegen brauchen wir hier ne Hilfssession, sonst könnte man auch einfach in die worldmap wechseln...

    
if g_LuaScriptBlockers[ModID]==nil then
  
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true


    print("peer_tricks.lua registered")
    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end
    g_LTL_Serp.modlog("peer_tricks.lua registered",ModID)
    
    
    local function t_Unload_EmptySession(GoToSession)
      g_LTL_Serp.modlog("t_Unload_EmptySession: Checking if we still need it...",ModID)
      while g_ObjectFinderSerp==nil or g_PeersInfo_Serp.CoopFinished~=true do
        coroutine.yield()
      end
      GoToSession = GoToSession or 180023
      if not DoWeNeedHelpSession() then
        g_LTL_Serp.modlog("t_Unload_EmptySession: Dont need it anymore, UNLOADING the session now...",ModID)
        ts.Unlock.SetRelockNet(1500005544) -- relock the IslandSettled check, we dont need it anymore
        local peers_in_empty_session = 16 -- only unload after everyone left again
        local notstop = 0
        while peers_in_empty_session ~= 0 do
          peers_in_empty_session = 0
          for peerint,username in pairs(g_PeersInfo_Serp.Everactive_Usernames) do
            if ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(peerint) == HelpSessionGuid then
              peers_in_empty_session = peers_in_empty_session + 1
            end
          end
          notstop = notstop + 1
          if notstop > 5 then -- wait max of 5 seconds
            g_LTL_Serp.modlog("ERROR Unload_EmptySession not all peers left the session within 5 seconds?! May crash now... "..tostring(ts.GameClock.CorporationTime),ModID)
            break
          end
          if peers_in_empty_session~=0 then
            g_LTL_Serp.waitForTimeDelta(1000)
            if session.getSessionGUID() == HelpSessionGuid then
              ts.Interface.JumpToSession(GoToSession)
            end
          end
        end
        ts.Unlock.SetRelockNet(HelpSessionGuid) -- lock session again
        while g_PeersInfo_Serp.CoopFinished~=true do
          coroutine.yield()
        end
        g_PeersInfo_Serp.t_ExecuteFnWithArgsForPeers("session.unloadSession",3000,nil,"Everyone",HelpSessionGuid) -- unload session for everyone calling it at the same time, to not desync
      end
      g_LTL_Serp.modlog("t_Unload_EmptySession: Function finisehd",ModID)
    end
    
    local function DoWeNeedHelpSession()
      local LoadedSessions = g_ObjectFinderSerp.GetLoadedSessions()
      local WeNeedHelpSession = false
      local PreviousSessions = {} -- remember the current session from all peers. So we can notice: only the ones who switched session are active
      for peerint,username in pairs(g_PeersInfo_Serp.Everactive_Usernames) do
        PreviousSessions[peerint] = ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(peerint) -- returns 0 for "never active" peers. But a session for active and inactive peers
      end
      local HasPossibleSession = {} -- same HasPossibleSession logic like when deciding if we load the session
      for peerint,username in pairs(g_PeersInfo_Serp.Everactive_Usernames) do
        for SessionID,SessionGuid in pairs(LoadedSessions) do
          if SessionGuid~=PreviousSessions[peerint] and SessionGuid~=180039 then
            if ts.Participants.GetParticipant(g_PeersInfo_Serp.PeerToPID[peerint]).ProfileCounter.Stats.GetCounter(2,14,0,1,SessionGuid) > 0 then -- only sessions we already visited (tested by Max IslandSettled in that session)
              HasPossibleSession[peerint] = true
              break
            end
          end
        end
      end
      for peerint,username in pairs(g_PeersInfo_Serp.Everactive_Usernames) do
        if not HasPossibleSession[peerint] then -- if any peer lacks a destination session, we need to load the helper session and can use it for everyone
          WeNeedHelpSession = true
          break
        end
      end
      return WeNeedHelpSession
    end
    
     
    local function t_Do_GetCoopPeersAtMarker(needs_CoopPeersAtMarker_UI,everactive_coops)
      g_LTL_Serp.modlog("Do_GetCoopPeersAtMarker started ",ModID)
      local coops_at_marker = {}
      if needs_CoopPeersAtMarker_UI then -- only if we have active coop players, we need to check GetCoopPeersAtMarker then
        local UI_ID = 176 -- 29:ToggleDiplomacyMenu(), 176=OpenStatisticsShipList
        -- local UI_ID = 29 -- 29:ToggleDiplomacyMenu(), 176=OpenStatisticsShipList
        ts.Interface.OpenStatisticsShipList() -- using OpenStatisticsShipList now instead, because we can call this multiple times if needed without it being closed again. And JumpToSession closes the menu anyways
        -- ts.Interface.ToggleDiplomacyMenu()
        -- g_LTL_Serp.modlog("Do_GetCoopPeersAtMarker vor waitForTimeDelta ",ModID)
        g_LTL_Serp.waitForTimeDelta(500)
        -- g_LTL_Serp.modlog("Do_GetCoopPeersAtMarker nach waitForTimeDelta ",ModID)
        local notstop = 0
        coops_at_marker = g_LTL_Serp.GetCoopPeersAtMarker(UI_ID,0) -- these will be all existing coop peers, except of me
        -- g_LTL_Serp.modlog("Do_GetCoopPeersAtMarker nach GetCoopPeersAtMarker ",ModID)
        while g_LTL_Serp.table_len(coops_at_marker) ~= g_CoopCountResSerp.LocalCount-1 do
          -- g_LTL_Serp.modlog("Do_GetCoopPeersAtMarker loop... "..tostring(notstop),ModID)
          g_LTL_Serp.waitForTimeDelta(500)
          -- g_LTL_Serp.modlog("Do_GetCoopPeersAtMarker nach wait loop... "..tostring(notstop),ModID)
          coops_at_marker = g_LTL_Serp.GetCoopPeersAtMarker(UI_ID,0) -- peerint as key and true as value
          -- g_LTL_Serp.modlog("Do_GetCoopPeersAtMarker nach GetCoopPeersAtMarker... "..tostring(notstop),ModID)
          notstop = notstop + 1
          if notstop > 10 then -- wait max of 5 seconds
            g_LTL_Serp.modlog("ERROR Lua wont work well in multiplayer! Do_GetCoopPeersAtMarker failed to get all coop peers into the same UI...",ModID)
            GameManager.OnlineManager.leaveSession()
            return
          end
          -- g_LTL_Serp.modlog("Do_GetCoopPeersAtMarker nach notstop... "..tostring(notstop),ModID)
          if UI_ID==176 and g_LTL_Serp.table_len(coops_at_marker) ~= g_CoopCountResSerp.LocalCount-1 then
            ts.Interface.OpenStatisticsShipList()
          end
        end
      else
        g_LTL_Serp.modlog("Skip GetCoopPeersAtMarker "..tostring(ts.GameClock.CorporationTime),ModID)
      end
      -- g_LTL_Serp.modlog("Do_GetCoopPeersAtMarker nach maybe_coop... ",ModID)
      for peerint,value in pairs(coops_at_marker) do
        g_PeersInfo_Serp.ActiveCoopPeers[peerint] = everactive_coops[g_PeersInfo_Serp.PID][peerint]
        g_PeersInfo_Serp.ActivePeers[peerint] = g_PeersInfo_Serp.ActiveCoopPeers[peerint]
      end
      _Peer_Tricks_Serp.CoopsNotAtMarker = {}
      for peerint,username in pairs(everactive_coops[g_PeersInfo_Serp.PID]) do -- all ever active coop peers
        _Peer_Tricks_Serp.CoopsNotAtMarker[peerint] = coops_at_marker[peerint]==nil and username or nil -- this includes myself and inactive coop peers
      end
      
      _Peer_Tricks_Serp.CoopPeersAtMarker_Done = true
      -- for the final result we need to wait and use this info after the session trick is done
      g_LTL_Serp.modlog("Do_GetCoopPeersAtMarker done ",ModID)
    end
    
    
    -- started via check_peers!
    local function t_Start(everactive_coops)
      g_LTL_Serp.modlog("Start "..tostring(ts.GameClock.CorporationTime),ModID)
      
      -- normal gamespeed, coroutines can have trouble on slower speed in some menues (eg statistic menu. diplo menu is fine, but we have no "Open" command, just toggle)
      ts.GameClock.SetSetGameSpeed(3) -- it will not update the speed button in singleplayer, but this code is used for MP only anyways
          
      while g_ObjectFinderSerp==nil do
        coroutine.yield()
      end
      
      if DoHideUI then -- also wont show notification, so we decided against this
        ts.Interface.ToggleUI()
      else
        if g_LTL_Serp.WasNewGameJustStarted() then -- we need at least 1 second delay for new game when showing the notification for unknown reason.
          g_LTL_Serp.waitForTimeDelta(1500)
        end
        ts.Conditions.RegisterTriggerForCurrentParticipant(1500005543) -- notification warning to tell users to not click anything
        g_LTL_Serp.waitForTimeDelta(2000) -- give player time to start reading and stop doing stuff
      end
      
      
      
      local CurrentSessionGuid,LoadedSessions,PreviousSessions,OtherSessionGuid,WeLoadEmptySession,num_activepeers
      
      local SkipSessionTrick = false -- only if this gets true for every peer, we shold skip session switch (so choose conditions that every peer can check)
      -- TODO: nach test wieder einkommentieren und testen
      -- if g_LTL_Serp.table_len(g_PeersInfo_Serp.Everactive_Usernames)==g_CoopCountResSerp.TotalCount then -- if all ever active peer are still active, the we can skip the session
        -- SkipSessionTrick = true -- we already know all inactive peers (none)
        -- for peerint,username in pairs(g_PeersInfo_Serp.Everactive_Usernames) do
          -- g_PeersInfo_Serp.ActivePeers[peerint] = username
        -- end
        -- g_LTL_Serp.modlog("SkipSessionTrick "..tostring(ts.GameClock.CorporationTime),ModID)
      -- end
      
      
      g_LTL_Serp.modlog("FindOutInactivePlayersViaSessionTrick "..tostring(ts.GameClock.CorporationTime),ModID)
      
      if not SkipSessionTrick then
      
        CurrentSessionGuid = session.getSessionGUID()
        LoadedSessions = g_ObjectFinderSerp.GetLoadedSessions(nil,nil,true)
        
        PreviousSessions = {} -- remember the current session from all peers. So we can notice: only the ones who switched session are active
        for peerint,username in pairs(g_PeersInfo_Serp.Everactive_Usernames) do
          PreviousSessions[peerint] = ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(peerint) -- returns 0 for "never active" peers. But a session for active and inactive peers
        end
        
        OtherSessionGuid = nil
        WeLoadEmptySession = DoWeNeedHelpSession()
        if not WeLoadEmptySession then
          for SessionID,SessionGuid in pairs(LoadedSessions) do -- we dont know which PeerInt we are yet, so loop again to find our personal destination session
            if SessionGuid~=CurrentSessionGuid and SessionGuid~=180039 then
              if ts.Participants.GetParticipant(g_PeersInfo_Serp.PID).ProfileCounter.Stats.GetCounter(2,14,0,1,SessionGuid) > 0 then -- only sessions we already visited (tested by Max IslandSettled in that session)
                OtherSessionGuid = SessionGuid  -- may be different per local player. The goal is just switching sessions to anywhere. Only who switches is active
                break
              end
            end
          end
        end
      end
      
      local needs_CoopPeersAtMarker_UI = true -- g_CoopCountResSerp.LocalCount>1 -- TODO test change back to normal
      g_LTL_Serp.start_thread("Do_GetCoopPeersAtMarker",ModID,t_Do_GetCoopPeersAtMarker,needs_CoopPeersAtMarker_UI,everactive_coops)
      
      if not SkipSessionTrick then
        if WeLoadEmptySession then -- then we need to load our small helper session...
          OtherSessionGuid = HelpSessionGuid
          if not game.isSessionLoadingDone(OtherSessionGuid) then
            g_LTL_Serp.modlog("Start Loading empty Helper Session "..tostring(ts.GameClock.CorporationTime),ModID)
            ts.Unlock.SetUnlockNet(1500005541) -- load empty session
            local notstop = 0
            while true do
              g_LTL_Serp.waitForTimeDelta(500)
              if game.isSessionLoadingDone(OtherSessionGuid) then
                break
              end
              notstop = notstop + 1
              if notstop > 30 then -- 15 seconds
                g_LTL_Serp.modlog("ERROR Lua wont work well in multiplayer! shared_LuaPeers_peer_tricks failed to load the helper session...",ModID)
                GameManager.OnlineManager.leaveSession()
                return
              end
            end
            ts.Unlock.SetUnlockNet(1500005544) -- unlock the IslandSettled check, which checks on IslandSettled if we meanwhile can unload the helper session again
            g_LTL_Serp.modlog("Loading empty Helper Session DONE "..tostring(ts.GameClock.CorporationTime),ModID)
          else
            g_LTL_Serp.modlog("Helper Session is already loaded "..tostring(ts.GameClock.CorporationTime),ModID)
          end
        end
      end
      
      while not _Peer_Tricks_Serp.CoopPeersAtMarker_Done do -- wait for the Marker UI thing to be finished, because switching sessions closes the UI again...
        coroutine.yield()
      end
      
      if not SkipSessionTrick then
        num_activepeers = g_CoopCountResSerp.TotalCount -- so this number of peers has to switch sessions. use it to find out if everyone who can, already switched sessions
        local notstop = 0
        g_LTL_Serp.modlog("Now switching Session to "..(WeLoadEmptySession and tostring(HelpSessionGuid) or tostring(OtherSessionGuid)).." ... "..tostring(ts.GameClock.CorporationTime),ModID)
        local peers_switched = {}
        while num_activepeers ~= #peers_switched do
          if WeLoadEmptySession then
            ts.Conditions.RegisterTriggerForCurrentParticipant(1500005540) -- enter empty session (ActionEnterSession is faster than lua command. And in this case we dont care for multiple registering for coop players, because we want everyone to enter the session anyways)
          else -- cant use ActionEnterSession, because in xml we have to hardcode the SessionGuid
            ts.Interface.JumpToSession(OtherSessionGuid) -- might be different for everyone  -- this also closes menus statistics and popups
          end
          g_LTL_Serp.waitForTimeDelta(1000)
          for peerint,username in pairs(g_PeersInfo_Serp.Everactive_Usernames) do
            if ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(peerint) ~= PreviousSessions[peerint] then -- GetActiveSessionGUIDOfPeerInt takes longer to update than getSessionGUID, but we need to know a success for everyone
              if not g_LTL_Serp.table_contains_value(peers_switched,peerint) then
                table.insert(peers_switched,peerint) -- es müssen nicht alle zeitgleich in anderer session sein, es reicht wenn jeder es einmal war
              end
              g_PeersInfo_Serp.ActivePeers[peerint] = username
            end
          end
          notstop = notstop + 1
          if notstop > 10 then -- 10 seconds
            g_LTL_Serp.modlog("ERROR Lua wont work well in multiplayer! shared_LuaPeers_peer_tricks failed to make every active player switch session. num_activepeers: "..tostring(num_activepeers).." numpeers_switchdone:"..tostring(#peers_switched),ModID)
            GameManager.OnlineManager.leaveSession()
            return
          end
        end
        
        g_LTL_Serp.modlog("switching Session done, now switch back to "..tostring(CurrentSessionGuid).." ... "..tostring(ts.GameClock.CorporationTime),ModID)
        g_LTL_Serp.waitForTimeDelta(250) -- short extra delay, because jumping too fast there and back causes graphic issues
        
        ts.Interface.JumpToSession(CurrentSessionGuid) -- jump back to original session -- this also closes menus statistics and popups
        
        if WeLoadEmptySession then
          ts.Unlock.SetRelockNet(HelpSessionGuid) -- lock session again. 
          -- g_LTL_Serp.start_thread("t_Unload_EmptySession",ModID,t_Unload_EmptySession,CurrentSessionGuid)
          -- t_Unload_EmptySession is called from in xml on IslandSettled event. This then checks if every peer has 
          -- HasPossibleSession , so the helper session is no longer neeeded.
          -- We dont unload and load it everytime again and again, because this increases the max SessionID everytime we do it.
           -- And this massivly hurts code that loops over all sessions, eg. g_ObjectFinderSerp.
        end
        
      end
      
      for peerint,username in pairs(g_PeersInfo_Serp.Everactive_Usernames) do
        g_PeersInfo_Serp.InactivePeers[peerint] = g_PeersInfo_Serp.ActivePeers[peerint]==nil and username or nil
      end
      for peerint,username in pairs(everactive_coops[g_PeersInfo_Serp.PID]) do
        g_PeersInfo_Serp.InactiveCoopPeers[peerint] = g_PeersInfo_Serp.InactivePeers[peerint]
      end
      
      for peerint,username in pairs(_Peer_Tricks_Serp.CoopsNotAtMarker) do -- its me and inactive peers. lets find out who is me
        if not g_PeersInfo_Serp.InactivePeers[peerint] then
          g_PeersInfo_Serp.PeerInt = peerint
          g_PeersInfo_Serp.Username = username
          g_PeersInfo_Serp.ActiveCoopPeers[peerint] = username
          break -- I can only be one of them, all others are inactive (or failed to open the UI...)
        end
      end
      
      if DoHideUI then
        if not needs_CoopPeersAtMarker_UI then -- opening the statistic menu after ToggleUI brings the UI back already
          ts.Interface.ToggleUI() -- enable UI again -- ToggleUI also disables movies and notifications .. so not really what we want
        end
        if needs_CoopPeersAtMarker_UI and SkipSessionTrick then -- then the statistic menu is still open and we need to close it (sesion switch also closes it)
          ts.Interface.ToggleUI()
          ts.Interface.ToggleUI()
        end
      end
      for i=1,15 do
        if not g_PeersInfo_Serp.ActivePeers[i] and not g_PeersInfo_Serp.InactivePeers[i] then
          g_PeersInfo_Serp.NeverActivePeers[i] = true
        end
      end
      local i = 1
      for k,v in g_LTL_Serp.pairsByKeys(g_PeersInfo_Serp.PIDsToShareData) do
        if g_PeersInfo_Serp.NeverActivePeers[i]==true then
          g_PeersInfo_Serp.PIDsToShareData[k] = false -- mark them as not used, so other mods can use them
        end
      end
      g_PeersInfo_Serp.CoopFinished = true
      g_PeersInfo_Serp.FullFinished = true

      g_LTL_Serp.modlog("DONE FindOutInactivePlayersViaSessionTrick "..tostring(ts.GameClock.CorporationTime),ModID)
      
      -- theoretisch sollte man hier warten, bis sicher alle fertig sind (weil wird für alle angezeigt)
       -- aber an sich ist das session loaden der Teil der am längsten dauert und da wird ja bereits gewartet, dass
        -- alle einmal die session gewchselt haben. Dh. es sollte jetzt schon bei allen innerhalb der nächsten 500ms fertig sein
      coroutine.yield() -- for whatever reason we need a yield here before the notification, otherweise its not displayed
      ts.Conditions.RegisterTriggerForCurrentParticipant(1500005542) -- show Done notification (fine as trigger, because Unique and we want to show it for everyone)
    
    end

    -- everything for internal use only
    _Peer_Tricks_Serp = { -- always create new, because this script is only called on loading new savegame and in this case we need to find out the info new
      t_Start = t_Start,
      CoopPeersAtMarker_Done = nil,
      t_Unload_EmptySession = t_Unload_EmptySession,
    }
    
    
        
    g_LTL_Serp.start_thread("g_OnGameLeave_serp",ModID,function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          _Peer_Tricks_Serp = nil -- stop everything (might crash some currently running functions, but I think its ok)
        end
      end
    end)
    g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)
    
end