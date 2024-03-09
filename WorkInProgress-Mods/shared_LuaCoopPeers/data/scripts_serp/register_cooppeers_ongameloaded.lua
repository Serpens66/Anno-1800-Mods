print("register_cooppeers_ongameloaded.lua called (will register if not already done)")


-- TODO:
 -- testen ob zb Statiskmenü uabhängig von der Session funzt!
  -- dann bräuchte man keine session wechseln und auch keine OID

-- OnLuaGameLoaded
local ModID = "shared_LuaCoopPeers_Serp"
local function OnSaveGameLoad_RESET()
  PeerInt_local = nil
end
local function OnSaveGameLoad()
  -- OnSaveGameLoad is already called with 1 second delay, so all players should already arrive in their session and completed sessionenter animation hopefully
  -- if ts.GameSetup.IsMultiPlayerGame then
    if ObjectFinderSerp==nil then
      console.startScript("data/scripts_serp/objectfinder/objectfinder.lua")
    end
    
    ts.Interface.OpenStatisticsShipList() -- keine ahnung wie mans wieder schließt, aber denke ich egal
    
    -- testen ob ToggleDiplomacyMenu oder ToggleCompanyMenu oder ToggleTraderouteMenu auch für coop-anzeige funzt,
     -- wenn ja, dann die nehmen,weil man die auch wieder schließen kann
    
    -- test if a delay is needed to enter the menu

    local peerints = ObjectFinderSerp.GetCoopPeersAtMarker_StatisticsMenu() -- these will be all existing coop peers, except of my own
    if next(peerints) then
      local maxpeerindexes = {[0]=12,[1]=13,[2]=14,[3]=15}
      local HumanID = ts.Participants.GetGetCurrentParticipantID()
      for i=HumanID,maxpeerindexes[HumanID],4 do
        if not peerints[i] then
          CoopPeers_Serp.PeerInt_local = i
          break
        end
      end
    end
    print("CoopPeers you are PeerInt: ", CoopPeers_Serp.PeerInt_local)
  -- end
  
  -- system.start(function()
    -- local SessionToEnter = CoopCount_Serp.GetFirstSessionFromCoop()
    -- if not CoopCount_Serp.IsEveryCoopSameSession(SessionToEnter) then
      -- ts.Interface.JumpToSession(SessionToEnter)
      -- system.waitForGameTimeDelta(500) -- wait for all players enter the session
      -- local notstop = 0
      -- while true do
        -- if CoopCount_Serp.IsEveryCoopSameSession(SessionToEnter) then
          -- break
        -- end
        -- ts.Interface.JumpToSession(SessionToEnter) -- repeat command, because it is ignored if player was currently in transition to a session
        -- notstop = notstop + 1
        -- if notstop > 50 then
          -- print("notstop CoopPeers JumpToSession")
          -- break
        -- end
      -- end
      -- if notstop <= 50 then
        -- local previous_selection = session.selection  -- session.getSelectedFactory()
        
        -- FoundObject_info["userdata"]:select()
        
        -- local peerints = ObjectFinderSerp.GetCoopPeersAtMarker_CurrentSessionCurrentShipSelection() -- these will be all existing coop peers, except of my own
        -- local maxpeerindexes = {[0]=12,[1]=13,[2]=14,[3]=15}
        -- local HumanID = ts.Participants.GetGetCurrentParticipantID()
        -- for i=HumanID,maxpeerindexes[HumanID],4 do
          -- if not peerints[i] then
            -- CoopPeers_Serp.PeerInt_local = i
            -- break
          -- end
        -- end
        -- for i,selected_userdata in ipairs(previous_selection) do -- select previous selection if there was any
          -- if i==1 then
            -- selected_userdata:select()
          -- else
            -- selected_userdata:addToSelection()
          -- end
        -- end
        -- print("CoopPeers you are PeerInt: ", CoopPeers_Serp.PeerInt_local)
      -- end
    -- end
  -- end)
end
g_saveloaded_events_serp = g_saveloaded_events_serp or {} -- global table where mods can add their functions to (define it if it does not exist yet)
if g_saveloaded_events_serp[ModID]==nil then
  g_saveloaded_events_serp[ModID] = OnSaveGameLoad
end
g_saveloaded_events_reset_serp = g_saveloaded_events_reset_serp or {} -- global table where mods can add their functions to (define it if it does not exist yet)
if g_saveloaded_events_reset_serp[ModID]==nil then
  g_saveloaded_events_reset_serp[ModID] = OnSaveGameLoad_RESET
end


CoopPeers_Serp = CoopPeers_Serp or {
  PeerInt_local = nil, -- to get username use: ts.Online.GetUsername(PeerInt_local)
}