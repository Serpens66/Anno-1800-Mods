
local ModID = "shared_LuaPeers" -- used for logging

-- if IsUsingPopUp is true, we will show PopUp at start of the game to ask who is who
 -- problem of this: The game sucks in error-prevention. Especially if you eg. change session shortly before PopUp is displayed,
  -- they all get aborted without any sign and its hell to implement craziest workarounds to fix all the things that could go wrong.
   -- this is why I implement 2 options, so I can choose the lesser evil anytime with this variable...
-- If IsUsingPopUp is false, we will instead use the workaround to open the diplo menu for all players and make them switch sessions.
 -- this way we can also find out who is which peer. Problem was that user input could break everything while it is happening.
  -- that is why we now also will display a short unskippable movie (currently started in xml), while the stuff happens in the background.
   -- the only downside left is that if the game only has 1 session loaded yet, we need to temporarly load a new small empty session
    -- for the switch to take place and unload it after that. I hope this causes no problems.. if more than 1 session is active we can simply switch between them without loading another.


    
if g_LuaScriptBlockers[ModID]==nil then
  
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true


    print("check_peers.lua registered")
    if g_LuaTools==nil then
      console.startScript("data/scripts_serp/luatools.lua")
    end
    g_AnnoTools.modlog("check_peers.lua registered",ModID)
    
    local function OnlyOnePeer()
      g_AnnoTools.modlog("Singleplayer / OnlyOnePeer, done",ModID)
      g_PeersInfo_Serp.PeerInt , g_PeersInfo_Serp.Username = next(g_PeersInfo_Serp.Everactive_Usernames)
      g_PeersInfo_Serp.ActiveCoopPeers[g_PeersInfo_Serp.PeerInt] = g_PeersInfo_Serp.Username
      g_PeersInfo_Serp.ActivePeers[g_PeersInfo_Serp.PeerInt] = g_PeersInfo_Serp.Username
      g_PeersInfo_Serp.CoopFinished = true
      g_PeersInfo_Serp.FullFinished = true
    end
    

    local function Start()
    
      g_AnnoTools.modlog("Start",ModID)
      local usernames = {}
      for peerint=0,15 do
        usernames[peerint] = ts.Online.GetUsername(peerint)
        peerint = peerint + 1
      end
      for peerint,username in pairs(usernames) do
        if username~="" then -- then this peer at least was and maybe still is active.
          g_PeersInfo_Serp.Everactive_Usernames[peerint] = username
        end
      end
      
      -- TODO test nach test wieder einkommentieren sowie "else"
      -- if ts.GameSetup.GetIsMultiPlayerGame() and not g_LuaTools.table_len(g_PeersInfo_Serp.Everactive_Usernames)==1 then
        
        local PID = g_PeersInfo_Serp.PID -- dont using fn IsCoopTeam_serp here, because we can only use global stuff here and I dont want to make it global. because other mods should use the same fn without needed to wait for lua load of another mod (by using a local version themself)
        
        local everactive_coops = {}
        for lPID=0,3,1 do 
          everactive_coops[lPID] = {}
          for peerint=0+lPID,12+lPID,4 do -- Eg. PID=0 (Human0) the peerint slots from this coop team are: 0,4,8,12. And from Human1 they are 1,5,9,13 and so on.
            if g_PeersInfo_Serp.Everactive_Usernames[peerint] then
              everactive_coops[lPID][peerint] = g_PeersInfo_Serp.Everactive_Usernames[peerint]
            end
          end
        end 
        
        while g_CoopCountRes==nil or g_CoopCountRes.Finished~=true do
          coroutine.yield()
        end
        
        -- TODO nach test wieder einkommentieren und auch testen
        -- if g_LuaTools.table_len(everactive_coops[PID])==1 then -- local player has and never had a coop team, then we already now the following
          -- g_PeersInfo_Serp.PeerInt , g_PeersInfo_Serp.Username = next(everactive_coops[PID])
          -- g_PeersInfo_Serp.ActiveCoopPeers[g_PeersInfo_Serp.PeerInt] = g_PeersInfo_Serp.Username
          -- g_PeersInfo_Serp.ActivePeers[g_PeersInfo_Serp.PeerInt] = g_PeersInfo_Serp.Username
          -- g_PeersInfo_Serp.CoopFinished = true
          -- local EveryHumanSingleCoop = true -- if every human team ever had a single peer and also currently has a single peer, we know who is who already
          -- for lPID,cooppeers in pairs(everactive_coops) do
            -- if g_CoopCountRes.CountPerPID[lPID]~=1 then -- currently active peers in this coop team
              -- EveryHumanSingleCoop = false
            -- elseif g_LuaTools.table_len(cooppeers)~=1 then -- ever active peers in this coop team
              -- EveryHumanSingleCoop = false
            -- end
          -- end
          -- if EveryHumanSingleCoop then
            -- for peerint,username in pairs(g_PeersInfo_Serp.Everactive_Usernames) do
              -- g_PeersInfo_Serp.ActivePeers[peerint] = username
            -- end
            -- g_PeersInfo_Serp.FullFinished = true
            -- g_AnnoTools.modlog("EveryHumanSingleCoop active, done",ModID)
            -- return
          -- end
        -- end
        
        if g_PeersInfo_Serp.IsUsingPopUp and g_MP_PopUps_Serp~=nil then
          g_AnnoTools.start_thread("g_MP_PopUps_Serp Start mp_popup",ModID,g_MP_PopUps_Serp.t_Start,everactive_coops)
        elseif g_Peer_Tricks_Serp~=nil then -- Now do the ui/session thing
          g_AnnoTools.start_thread("g_Peer_Tricks_Serp Start peer_tricks",ModID,g_Peer_Tricks_Serp.t_Start,everactive_coops)
        else
          g_AnnoTools.modlog("ERROR Lua wont work well in multiplayer! Neither g_MP_PopUps_Serp ("..tostring(g_MP_PopUps_Serp)..") nor g_Peer_Tricks_Serp ("..tostring(g_Peer_Tricks_Serp)..") is loaded?!",ModID)
          GameManager.OnlineManager.leaveSession()
          return
        end
        
      -- else -- not multiplayer game
        -- OnlyOnePeer()
        -- return
      -- end
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
      IsUsingPopUp = false, -- change this value to switch between sessiontrick and popups to find out who is which peer
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
      Everactive_Usernames = {},
      PeerToPID = {[0]=0,[4]=0,[8]=0,[12]=0,[1]=1,[5]=1,[9]=1,[13]=1,[2]=2,[6]=2,[10]=2,[14]=2,[3]=3,[7]=3,[11]=3,[15]=3},
    }
    
    if g_PeersInfo_Serp.IsUsingPopUp then
      console.startScript("data/scripts_serp/mp_popup.lua") -- in shared mod shared_MP_Lua_PopUps
    else
      console.startScript("data/scripts_serp/peer_tricks.lua") -- within this mod
    end
    
    g_AnnoTools.start_thread("Start check_peers",ModID,Start) -- TODO test wieder einkommentieren
    
    g_AnnoTools.start_thread("g_OnGameLeave_serp",ModID,function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_PeersInfo_Serp = nil -- stop everything (might crash some currently running functions, but I think its ok)
        end
      end
    end)
    g_AnnoTools.start_thread("g_LuaScriptBlockers",ModID,function()
      g_AnnoTools.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)
end