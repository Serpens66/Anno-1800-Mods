print("register_cooppeers_ongameloaded.lua called (will register if not already done)")


if CoopPeers_Serp==nil then
  console.startScript("data/scripts_serp/cooppeers.lua")
end


-- OnLuaGameLoaded
local ModID = "shared_LuaCoopPeers_Serp"
local function OnSaveGameLoad_RESET()
  CoopPeers_Serp.PeerInt = nil
  CoopPeers_Serp.ImFirstActiveCoopPeer = nil
end
local function OnSaveGameLoad()
  -- OnSaveGameLoad is already called with 0.7 second delay, so all players should already arrive in their session and completed sessionenter animation hopefully
  if ts.GameSetup.IsMultiPlayerGame then
    if ObjectFinderSerp==nil then
      console.startScript("data/scripts_serp/objectfinder/objectfinder.lua")
    end
    
    if CoopCount_Serp==nil then
      console.startScript("data/scripts_coophelper_serp/coopcount.lua")
    end
    local HumanID = ts.Participants.GetGetCurrentParticipantID()
    if CoopCount_Serp.GetCoopCount(HumanID)>1 then
      system.start(function()
        ts.Interface.ToggleDiplomacyMenu()
        ts.Unlock.SetUnlockNet(1500004630) -- show a small notification to tell the user what is going on
        system.waitForGameTimeDelta(600) -- wait for entering the menu
        local peerints = ObjectFinderSerp.GetCoopPeersAtMarker(29,0) -- these will be all existing coop peers, except of my own
        if not next(peerints) then -- failsafe, try again
          system.waitForGameTimeDelta(600) -- wait for entering the menu
          peerints = ObjectFinderSerp.GetCoopPeersAtMarker(29,0) -- these will be all existing coop peers, except of my own
          if not next(peerints) then
            ts.Interface.ToggleDiplomacyMenu()
            system.waitForGameTimeDelta(600) -- wait for entering the menu
            peerints = ObjectFinderSerp.GetCoopPeersAtMarker(29,0) -- these will be all existing coop peers, except of my own
          end
        end
        if next(peerints) then
          local maxpeerindexes = {[0]=12,[1]=13,[2]=14,[3]=15}
          for i=HumanID,maxpeerindexes[HumanID],4 do
            if not peerints[i] then
              CoopPeers_Serp.PeerInt = i
              break
            end
          end
          if CoopPeers_Serp.PeerInt~=nil then
            for i=HumanID,maxpeerindexes[HumanID],4 do
              if ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i)~=0 then
                if i==CoopPeers_Serp.PeerInt then
                  CoopPeers_Serp.ImFirstActiveCoopPeer = true
                else
                  CoopPeers_Serp.ImFirstActiveCoopPeer = false
                end
                break -- we only have to check the first active coop peer with help of GetActiveSessionGUIDOfPeerInt. if you are it your are first, if not, not
              end
            end
          end
        else
          print("CoopPeers: Attention! code to fetch PeerInt and ImFirstActiveCoopPeer failed ...")
        end
        ts.Interface.ToggleDiplomacyMenu()  
        print("CoopPeers: you are PeerInt: ", tostring(CoopPeers_Serp.PeerInt),", ImFirstActiveCoopPeer: ",tostring(CoopPeers_Serp.ImFirstActiveCoopPeer))
      end)
    else -- MP but the local player has no coop mates
      CoopPeers_Serp.ImFirstActiveCoopPeer = true
      CoopPeers_Serp.PeerInt = 0
    end
  else -- singleplayer
    CoopPeers_Serp.ImFirstActiveCoopPeer = true
    CoopPeers_Serp.PeerInt = 0
  end
end

g_saveloaded_events_serp = g_saveloaded_events_serp or {} -- global table where mods can add their functions to (define it if it does not exist yet)
if g_saveloaded_events_serp[ModID]==nil then
  g_saveloaded_events_serp[ModID] = OnSaveGameLoad
end
g_saveloaded_events_reset_serp = g_saveloaded_events_reset_serp or {} -- global table where mods can add their functions to (define it if it does not exist yet)
if g_saveloaded_events_reset_serp[ModID]==nil then
  g_saveloaded_events_reset_serp[ModID] = OnSaveGameLoad_RESET
end
