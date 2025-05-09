
local ModID = "shared_MP_Lua_Popup" -- used for logging

-- TODO:
 -- und variablen mergen:
 -- Statt Active und Inactive nur ne liste von PeerInts und als value dann true/false ob sie active oder inactive sind
  -- und welche die nie aktiv waren bleiben draußen (bzw. wert nil) ?
-- Und evtl. sogar CoopPeers und Peers mergen? 
 -- dann muss aber mehr info rein zb. PeerInt={Finished=true,Active=true,EverActive=true,MyCoop=true}
  -- und wenn wirs so machen, können wir alle PeerInts reinpacken {Finished=true,Active=false,EverActive=false,MyCoop=true}
 -- und für die Peers wo wirs noch nicht wissen (weil nicht unser Coop und vor sync): {Finished=false,Active=false,EverActive=false,MyCoop=false}
    

    
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

    if g_LuaTools==nil then
      console.startScript("data/scripts_serp/luatools.lua")
    end
    g_LuaTools.modlog("mp_popup.lua registered",ModID)
    if g_shared_PopUp_Serp==nil then
      print("mp_popup.lua ERROR: g_shared_PopUp_Serp is missing!")
      g_LuaTools.modlog("mp_popup.lua ERROR: g_shared_PopUp_Serp is missing!",ModID)
    end
    
    -- called via ExecuteFnWithArgsForPeers and contains the PeersInfo from another human peer
    local function Sync_ActivePeersInfo(Other_ActiveCoopPeers,Other_InactiveCoopPeers)
      for PeerInt,Username in pairs(Other_ActiveCoopPeers) do
        g_PeersInfo_Serp.ActivePeers[PeerInt] = Username
      end
      for PeerInt,Username in pairs(Other_InactiveCoopPeers) do
        g_PeersInfo_Serp.InactivePeers[PeerInt] = Username
      end
      g_PeersInfo_Serp.CountInfosReceived = g_PeersInfo_Serp.CountInfosReceived + 1
      if g_PeersInfo_Serp.CountInfosReceived == g_CoopCountRes.TotalCount then -- received every info from all peers (everyone completed PopUps)
        g_PeersInfo_Serp.FullFinished = true
      end
    end
    
    -- after the local player answered all PopUps and all g_PeersInfo_Serp infos were filled
     -- called within thread
    local function OnAllPopUpsAnswered()
        if ts.GameSetup.GetIsMultiPlayerGame() then
          -- first security check if g_CoopCountRes gets the same result for active coop peers
          if g_CoopCountRes~=nil then
            while g_CoopCountRes.Finished~=true do
              coroutine.yield()
            end
            local coopcountPopUp = g_PeersInfo_Serp.GetCoopCount()
            if coopcountPopUp ~= g_CoopCountRes.CountPerPID[g_PeersInfo_Serp.PID] then
              print("sharedPopUp_ButtonHit_MP_Lua ERROR: PopUp active Peers "..tostring(coopcountPopUp).." does not match Res-Test active peers: "..tostring(g_CoopCountRes.CountPerPID[g_PeersInfo_Serp.PID]))
              g_LuaTools.modlog("sharedPopUp_ButtonHit_MP_Lua ERROR: PopUp active Peers "..tostring(coopcountPopUp).." does not match Res-Test active peers: "..tostring(g_CoopCountRes.CountPerPID[g_PeersInfo_Serp.PID]),ModID)
              ts.Conditions.RegisterTriggerForCurrentParticipant(1500005528) -- show notification and leave game in 15 seconds
              return
            end
            g_PeersInfo_Serp.CoopFinished = true -- then all popups are answered and the info can be used
            if g_ObjectFinderSerp~=nil then  -- ExecuteFnWithArgsForPeers need to use "Everyone" here, because the receivers might not know yet which PeerInt they are (if not finished PopUps yet).
              g_ObjectFinderSerp.ExecuteFnWithArgsForPeers("g_PeersInfo_Serp.Sync_ActivePeersInfo",nil,false,"Everyone",g_PeersInfo_Serp.ActiveCoopPeers,g_PeersInfo_Serp.InactiveCoopPeers)
            end
          end
        else
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
          g_LuaTools.modlog("sharedPopUp_ButtonHit_MP_Lua ERROR: User said at least twice -its me-",ModID)
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
      
      g_PeersInfo_Serp.PopUpsStatus.NShown = g_PeersInfo_Serp.PopUpsStatus.NShown + 1
      if g_PeersInfo_Serp.PopUpsStatus.NShown == g_PeersInfo_Serp.PopUpsStatus.NToShow then
        system.start(function()
          local status,err = pcall(g_PeersInfo_Serp.OnAllPopUpsAnswered)
          if status==false then
            error(err) 
          end
        end)
      end
    end


    local function Start()
      if ts.GameSetup.GetIsMultiPlayerGame() then

        local PID = g_PeersInfo_Serp.PID -- dont using fn IsCoopTeam_serp here, because we can only use global stuff here and I dont want to make it global. because other mods should use the same fn without needed to wait for lua load of another mod (by using a local version themself)
        local usernames = {}
        local peerint = 0
        while peerint <= 15 do
          usernames[peerint] = ts.Online.GetUsername(peerint)
          peerint = peerint + 1
        end
        local everactive_usernames = {}
        for peerint,username in pairs(usernames) do
          if username~="" then -- then this peer at least was and maybe still is active. So we should ask about it in PopUp
            everactive_usernames[peerint] = username
          end
        end
        
        local MyCoop_usernames = {}
        for peerint=0+PID,12+PID,4 do -- Eg. PID=0 (Human0) the peerint slots from this coop team are: 0,4,8,12. And from Human1 they are 1,5,9,13 and so on.
          if everactive_usernames[peerint] then
            MyCoop_usernames[peerint] = everactive_usernames[peerint]
          end
        end
        if g_LuaTools.table_len(MyCoop_usernames)>1 then -- if we have at least 2 players in this coop team
          local header = ts.GetAssetData(1500005510).Text
          local ButtonFunc = sharedPopUp_ButtonHit_MP_Lua
          local i = 0
          for peerint,username in pairs(MyCoop_usernames) do
            local body = ts.GetAssetData(1500005511).Text
            body = body..username..tostring(ts.GetAssetData(1500005512).Text) -- add more to the body string
            local Identifier = peerint
            local Unlock = 1500005510 + i -- unlocks are 1500005510 to 1500005513 (and MyCoop_usernames will have at most 4 entries)
            g_shared_PopUp_Serp.ShowPopup(header,body,ButtonFunc,Identifier,Unlock)
            i = i + 1
          end
          g_PeersInfo_Serp.PopUpsStatus.NToShow = i
        else -- local player has and never had a coop team
          g_PeersInfo_Serp.PeerInt , g_PeersInfo_Serp.Username = next(MyCoop_usernames)
          g_PeersInfo_Serp.ActiveCoopPeers[g_PeersInfo_Serp.PeerInt] = g_PeersInfo_Serp.Username
          g_PeersInfo_Serp.ActivePeers[g_PeersInfo_Serp.PeerInt] = g_PeersInfo_Serp.Username
          system.start(function()
            local status,err = pcall(g_PeersInfo_Serp.OnAllPopUpsAnswered)
            if status==false then
              error(err) 
            end
          end)
        end
      else -- not multiplayer game
        g_PeersInfo_Serp.PeerInt = 0
        g_PeersInfo_Serp.Username = ts.Online.GetUsername(0)
        g_PeersInfo_Serp.ActiveCoopPeers[0] = g_PeersInfo_Serp.Username
        g_PeersInfo_Serp.ActivePeers[0] = g_PeersInfo_Serp.Username
        system.start(function()
          local status,err = pcall(g_PeersInfo_Serp.OnAllPopUpsAnswered)
          if status==false then
            error(err) 
          end
        end)
      end
    end

    -- ##################################################################################
    -- functions to use in your mod

    -- based in the info we got with the PopUp we can create these functions:
    local function GetCoopCount() -- returns the number of total active coop players from the coop team from the local player
      return g_LuaTools.table_len(g_PeersInfo_Serp.ActiveCoopPeers) -- returns the same as g_CoopCountRes.CountPerPID[g_PeersInfo_Serp.PID] , because we make a check that this is the same after all PopUps are answered
    end

    local function AmIFirstActiveCoopPeer() -- returns true only for the first active peer from the local coop team (starts checking at 0)
      local PID = g_PeersInfo_Serp.PID
      for peerint,username in pairs(g_PeersInfo_Serp.ActiveCoopPeers) do
        if peerint==g_PeersInfo_Serp.PeerInt then -- if it is me
          return true
        else
          return false
        end
      end
      return false
    end
    -- returns the first coop peer in that session, if any (otherwise false)
    -- to check if you are yourself the first, just check: g_PeersInfo_Serp.PeerInt == g_PeersInfo_Serp.IsAnyActiveCoopInSession(session)
    -- this check is eg. needed to get userdata of an object or check Areas, since this only works while local player is in that session.
     -- and in coop we can make the one coop player execute the script that is in the correct session
    local function IsAnyActiveCoopInSession(checksession) 
      for peerint,username in pairs(g_PeersInfo_Serp.ActiveCoopPeers) do
        if ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(peerint)==checksession then
          return peerint
        end
      end
      return false
    end
    
    -- finds the first active coop peer who is in that session (not only checking the first active peer, but all of my coop-team)
    local function AmIFirstActiveCoopPeerInSession(checksession)
      return g_PeersInfo_Serp.IsAnyActiveCoopInSession(checksession)==g_PeersInfo_Serp.PeerInt
    end
    
    
    -- returns true only for the first active peer from any team (starts checking at Human0 and Peer0 and then checks peers from Human0 first. So peer0,peer4,peer8,peer12, peer1 and so on)
    local function AmIFirstActivePeer() -- also works without ActivePeers/InactivePeers by using g_CoopCountRes which should be ready to use while player still answers PopUps
      if g_PeersInfo_Serp.PID==0 then
        if g_PeersInfo_Serp.AmIFirstActiveCoopPeer() then
         return true
        end
      else
        if g_CoopCountRes~=nil and g_CoopCountRes.Finished==true then
          if g_PeersInfo_Serp.PID==1 then
            if g_CoopCountRes.CountPerPID[0] == 0 and g_PeersInfo_Serp.AmIFirstActiveCoopPeer() then
              return true
            end
          elseif g_PeersInfo_Serp.PID==2 then
            if g_CoopCountRes.CountPerPID[0] == 0 and g_CoopCountRes.CountPerPID[1] == 0 and g_PeersInfo_Serp.AmIFirstActiveCoopPeer() then
              return true
            end
          elseif g_PeersInfo_Serp.PID==3 then
            if g_CoopCountRes.CountPerPID[0] == 0 and g_CoopCountRes.CountPerPID[1] == 0 and g_CoopCountRes.CountPerPID[2] == 0 and g_PeersInfo_Serp.AmIFirstActiveCoopPeer() then
              return true
            end
          end
        elseif g_PeersInfo_Serp.FullFinished then -- wird vermutlich nie genutzt, denn ohne g_CoopCountRes gibts auch kein FullFinished :D
          for i,PeerInt in ipairs(0,4,8,12,1,5,9,13,2,6,10,14,3,7,11,15) do -- same order like with the g_CoopCountRes workaround
            if g_LuaTools.table_contains_value(g_PeersInfo_Serp.ActivePeers,PeerInt) then
              return PeerInt==g_PeersInfo_Serp.PeerInt
            end
          end
        else
          return "error" -- g_CoopCountRes not ready (should be ready after 2 seconds ingame or 2 seconds after g_CoopCountRes.MakeNewCount was called again to refresh)
        end
      end
      return false
    end

    local function IsAnyActiveInSession(checksession) 
      for peerint,username in pairs(g_PeersInfo_Serp.ActivePeers) do
        if ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(peerint)==checksession then
          return peerint
        end
      end
      return false
    end
    -- finds the first active peer who is in that session (not only checking the first active peer, but all peers)
    local function AmIFirstActivePeerInSession(checksession)
      return g_PeersInfo_Serp.IsAnyActiveInSession(checksession)==g_PeersInfo_Serp.PeerInt
    end

    -- also useful:
    -- g_CoopCountRes.CountPerPID[PID] to find out how many active peers another Participant has
    g_PeersInfo_Serp = { -- always create new, because this script is only called on loading new savegame and in this case we need to find out the info new
      PID = ts.Participants.GetGetCurrentParticipantID(),
      PeerInt = nil,
      Username = nil,
      CoopFinished = nil, -- if true, everything except ActivePeers/InactivePeers/IsAnyActiveInSession is ready to use (for most cases already enough)
      FullFinished = nil, -- if true, everything from g_PeersInfo_Serp is ready to use
      GetCoopCount = GetCoopCount,
      AmIFirstActiveCoopPeer = AmIFirstActiveCoopPeer,
      AmIFirstActiveCoopPeerInSession = AmIFirstActiveCoopPeerInSession,
      IsAnyActiveCoopInSession = IsAnyActiveCoopInSession,
      AmIFirstActivePeer = AmIFirstActivePeer,
      IsAnyActiveInSession = IsAnyActiveInSession,
      AmIFirstActivePeerInSession = AmIFirstActivePeerInSession,
      ActiveCoopPeers = {},  -- ActiveCoopPeers[PeerInt] = Username
      InactiveCoopPeers = {},
      InactivePeers = {},
      ActivePeers = {},
      OnAllPopUpsAnswered = OnAllPopUpsAnswered, --internal use
      Sync_ActivePeersInfo = Sync_ActivePeersInfo, --internal use
      CountInfosReceived = 0, --internal use
      PopUpsStatus = {NToShow=0,NShown=0}, -- internal use to find out if finished
    }

    Start() -- call the code after we inited g_PeersInfo_Serp, so it can be used inside of it
    
    
    system.start(function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_PeersInfo_Serp = nil -- stop everything (might crash some currently running functions, but I think its ok)
        end
      end
    end)
    
    system.start(function()
      g_LuaTools.waitForTimeDelta(5000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)
end