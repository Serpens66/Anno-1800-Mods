
local ModID = "shared_MP_Lua_Popup" -- used for logging


    
if g_LuaScriptBlockers[ModID]==nil then
  
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true


    print("mp_popup.lua registered")
    
    
    -- in assets.xml we will change PlayerLeft and PlayerDisconnected PopUp to only allow leaving the game when any player left.
     -- This way we dont have to write complicated functions to update stuff. The players simply load the game new and this will start all lua scripts new
    

    -- only other way to find out who is which peer and who is active is by combining the UI GetCoopPeersAtMarker (shows all coop except yourself and inactive)
     -- and forcing everyone into another session and back (inactives wont switch session).
    -- But opening the statistic screen, loading a new tiny session and forcing everyone back and forth to find this out
     -- is even more distracting than simply asking via PopUp. So we will use the PopUp solution now
    -- we could also check ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(peerint). if we are alone in a session we can surely say who we are (comapring it with session.getSessionGUID())
       -- but we also need to know who is active/inactive and this also returns a session for the inactive ones.
        -- So we have to ask via PopUp for them anyways... so no need for this Session check, simply always ask via PopUp
        

    -- Da wir leider nur ActionTriggerPopup nutzen können und keinen Befehl zum PopUp anzeigen in lua haben,
     -- wird dadurch immer für alle Coop Spieler das PopUp gestartet.
     -- Dh. selbst wenn wir zb. durch den UI-Marker Trick wissen, dass wir selbst entweder Peer0 oder Peer4 sind und der andere inaktiv ist
      -- reicht es nicht diese beiden dann abzufragen, denn Peer8 muss ja dasselbe für Peer8 und den inaktiven abfragen,
       -- wodurch wir letzlich ActionTriggerPopup für alle 3 Optionen machen müssen, welches für alle Coops gezeigt wird.
      -- -> wir können uns das mit der UI sparen und einfach nur eine PopUp Abfrage für alle Username(peer) machen,
       -- sofern es Coop Spieler in dem eigenen Slot gibt.
     

    -- shared PopUp part

    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end
    g_LTL_Serp.modlog("mp_popup.lua registered",ModID)
    if g_shared_PopUp_Serp==nil then
      print("mp_popup.lua ERROR: g_shared_PopUp_Serp is missing!")
      g_LTL_Serp.modlog("mp_popup.lua ERROR: g_shared_PopUp_Serp is missing!",ModID)
    end
    
    -- we currently only ask for coop teammates, not all players. to save code and also number of popups
     -- to still get full information, we are sharing out information with others
    -- called via t_ExecuteFnWithArgsForPeers and contains the PeersInfo from another human peer
    local function Sync_ActivePeersInfo(Other_ActiveCoopPeers,Other_InactiveCoopPeers)
      for PeerInt,Username in pairs(Other_ActiveCoopPeers) do
        g_PeersInfo_Serp.ActivePeers[PeerInt] = Username
      end
      for PeerInt,Username in pairs(Other_InactiveCoopPeers) do
        g_PeersInfo_Serp.InactivePeers[PeerInt] = Username
      end
      g_MP_PopUps_Serp.CountInfosReceived = g_MP_PopUps_Serp.CountInfosReceived + 1
      if g_MP_PopUps_Serp.CountInfosReceived == g_CoopCountResSerp.TotalCount then -- received every info from all peers (everyone completed PopUps)
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
        g_PeersInfo_Serp.FullFinished = true
      end
    end
    
    -- after the local player answered all PopUps and all g_PeersInfo_Serp infos were filled
     -- called within thread
    local function OnAllPopUpsAnswered()
        if ts.GameSetup.GetIsMultiPlayerGame() then
          -- first security check if g_CoopCountResSerp gets the same result for active coop peers
          if g_CoopCountResSerp~=nil then
            while g_CoopCountResSerp.Finished~=true do
              coroutine.yield()
            end
            local coopcountPopUp = g_PeersInfo_Serp.GetCoopCount()
            if coopcountPopUp ~= g_CoopCountResSerp.CountPerPID[g_PeersInfo_Serp.PID] then
              print("sharedPopUp_ButtonHit_MP_Lua ERROR: PopUp active Peers "..tostring(coopcountPopUp).." does not match Res-Test active peers: "..tostring(g_CoopCountResSerp.CountPerPID[g_PeersInfo_Serp.PID]))
              g_LTL_Serp.modlog("sharedPopUp_ButtonHit_MP_Lua ERROR: PopUp active Peers "..tostring(coopcountPopUp).." does not match Res-Test active peers: "..tostring(g_CoopCountResSerp.CountPerPID[g_PeersInfo_Serp.PID]),ModID)
              ts.Conditions.RegisterTriggerForCurrentParticipant(1500005528) -- show notification and leave game in 15 seconds
              return
            end
            g_PeersInfo_Serp.CoopFinished = true -- then all popups are answered and the info can be used
            g_PeersInfo_Serp.t_ExecuteFnWithArgsForPeers("g_MP_PopUps_Serp.Sync_ActivePeersInfo",nil,false,"Everyone",g_PeersInfo_Serp.ActiveCoopPeers,g_PeersInfo_Serp.InactiveCoopPeers)
          end
        else
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
        end
    end


    -- button can be integer 1,2 or 3
    -- 1: Currently shown name is the local player
    -- 2: Currently shown name is not local player, but active
    -- 3: Currently shown name is not local player and no longer active
    local function sharedPopUp_ButtonHit_MP_Lua(button,PeerInt)
      if button==1 then -- its me
        if g_PeersInfo_Serp.PeerInt~=nil and g_PeersInfo_Serp.PeerInt~=PeerInt then
          print("sharedPopUp_ButtonHit_MP_Lua ERROR: User said at least twice -its me-")
          g_LTL_Serp.modlog("sharedPopUp_ButtonHit_MP_Lua ERROR: User said at least twice -its me-",ModID)
          ts.Conditions.RegisterTriggerForCurrentParticipant(1500005528) -- show notification and leave game in 15 seconds
        end
        g_PeersInfo_Serp.PeerInt = PeerInt
        g_PeersInfo_Serp.Username = ts.Online.GetUsername(PeerInt)
        g_PeersInfo_Serp.ActiveCoopPeers[PeerInt] = g_PeersInfo_Serp.Username
      elseif button==2 then -- is active but not me
        g_PeersInfo_Serp.ActiveCoopPeers[PeerInt] = ts.Online.GetUsername(PeerInt)
        g_PeersInfo_Serp.ActivePeers[PeerInt] = g_PeersInfo_Serp.ActiveCoopPeers[PeerInt]
      elseif button==3 then -- is inactive
        g_PeersInfo_Serp.InactiveCoopPeers[PeerInt] = ts.Online.GetUsername(PeerInt)
        g_PeersInfo_Serp.InactivePeers[PeerInt] = g_PeersInfo_Serp.InactiveCoopPeers[PeerInt]
      end
      
      g_MP_PopUps_Serp.PopUpsStatus.NShown = g_MP_PopUps_Serp.PopUpsStatus.NShown + 1
      if g_MP_PopUps_Serp.PopUpsStatus.NShown == g_MP_PopUps_Serp.PopUpsStatus.NToShow then
        g_LTL_Serp.start_thread("call OnAllPopUpsAnswered after ButtonHit",ModID,g_MP_PopUps_Serp.OnAllPopUpsAnswered)
      end
    end


    local function t_Start(everactive_coops)
      if ts.GameSetup.GetIsMultiPlayerGame() then
        if g_LTL_Serp.table_len(everactive_coops[g_PeersInfo_Serp.PID])>1 then -- if we have at least 2 players in this coop team
          local header = ts.GetAssetData(1500005510).Text
          local ButtonFunc = sharedPopUp_ButtonHit_MP_Lua
          local i = 0
          for peerint,username in pairs(everactive_coops[g_PeersInfo_Serp.PID]) do
            local body = ts.GetAssetData(1500005511).Text
            body = body..username..tostring(ts.GetAssetData(1500005512).Text) -- add more to the body string
            local Identifier = peerint
            local Unlock = 1500005510 + i -- unlocks are 1500005510 to 1500005513 (and everactive_coops[g_PeersInfo_Serp.PID] will have at most 4 entries)
            g_shared_PopUp_Serp.ShowPopup(header,body,ButtonFunc,Identifier,Unlock)
            i = i + 1
          end
          g_MP_PopUps_Serp.PopUpsStatus.NToShow = i
          game.playSound(234152) -- TODO test ob das desynced, wobei wirs hier eig. zeitgleich abspielen sollten
        else -- local player has and never had a coop team. syncing is still required
          g_LTL_Serp.start_thread("call OnAllPopUpsAnswered",ModID,g_MP_PopUps_Serp.OnAllPopUpsAnswered)
        end
      end
    end


    g_MP_PopUps_Serp = {
      t_Start = t_Start, --internal use
      OnAllPopUpsAnswered = OnAllPopUpsAnswered, --internal use
      CountInfosReceived = 0, --internal use
      PopUpsStatus = {NToShow=0,NShown=0}, -- internal use to find out if finished
      Sync_ActivePeersInfo = Sync_ActivePeersInfo, --internal use
    }

    -- t_Start() -- is now called from within check_peers.lua from shared_LuaPeers mod
    
    g_LTL_Serp.start_thread("g_OnGameLeave_serp",ModID,function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_PeersInfo_Serp = nil -- stop everything (might crash some currently running functions, but I think its ok)
        end
      end
    end)
    g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)

end