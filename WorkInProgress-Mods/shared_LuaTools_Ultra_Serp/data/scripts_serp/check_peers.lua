-- adds+uses Nameable (not CompanyName) of these Participants (for sharing info, one per Peer)
-- Scenario3_Editor  GUID: 100131 , PID: 117
-- Scenario3_Challenger1  GUID: 100132 , PID: 118
-- Scenario3_Challenger2  GUID: 100938 , PID: 119
-- Scenario3_Challenger3  GUID: 100939 , PID: 120
-- Scenario3_Challenger4  GUID: 101507 , PID: 121
-- Scenario3_Challenger5  GUID: 101508 , PID: 122
-- Scenario3_Challenger6  GUID: 101509 , PID: 123
-- Scenario3_Challenger7  GUID: 101517 , PID: 124
-- Scenario3_Challenger8  GUID: 101518 , PID: 125
-- Scenario3_Challenger9  GUID: 101519 , PID: 126
-- Scenario3_Challenger10  GUID: 101520 , PID: 127
-- Scenario3_Challenger11  GUID: 101521 , PID: 128
-- Scenario3_Challenger12  GUID: 101522 , PID: 129
-- Scenario3_Eli  GUID: 103130 , PID: 136
-- Scenario3_Ketema  GUID: 103129 , PID: 137
-- Scenario3_Archie  GUID: 103131 , PID: 138

-- Requires g_ObjectFinderSerp fo sharing data between peers (to find OIDs of these SessionParticiapnts)


local ModID = "shared_LuaTools_Ultra_Serp check_peers.lua" -- used for logging


    
if g_LuaScriptBlockers[ModID]==nil then
  
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true

    if g_StringTableConvertSerpNyk==nil then
      console.startScript("data/scripts_serp/h/savestuff_tableconvert.lua")
    end

    print("check_peers.lua registered")
    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end
    g_LTL_Serp.modlog("check_peers.lua registered",ModID)
    
    local function OnlyOnePeer()
      g_LTL_Serp.modlog("Singleplayer / OnlyOnePeer, done",ModID)
      g_PeersInfo_Serp.PeerInt , g_PeersInfo_Serp.Username = next(g_PeersInfo_Serp.Everactive_Usernames)
      g_PeersInfo_Serp.ActiveCoopPeers[g_PeersInfo_Serp.PeerInt] = g_PeersInfo_Serp.Username
      g_PeersInfo_Serp.ActivePeers[g_PeersInfo_Serp.PeerInt] = g_PeersInfo_Serp.Username
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
    

    local function _Start()
    
      g_LTL_Serp.modlog("Start",ModID)
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
      
      -- for testing: outcomment this if statement (and else)
      if ts.GameSetup.GetIsMultiPlayerGame() and not g_LTL_Serp.table_len(g_PeersInfo_Serp.Everactive_Usernames)==1 then
        
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
        
        while g_LTM_Serp==nil or g_LTU_Serp==nil or g_CoopCountResSerp==nil or g_CoopCountResSerp.Finished~=true do
          coroutine.yield()
        end
        
        -- for testing: outcomment this block 
        if g_LTL_Serp.table_len(everactive_coops[PID])==1 then -- local player has and never had a coop team, then we already now the following
          g_PeersInfo_Serp.PeerInt , g_PeersInfo_Serp.Username = next(everactive_coops[PID])
          g_PeersInfo_Serp.ActiveCoopPeers[g_PeersInfo_Serp.PeerInt] = g_PeersInfo_Serp.Username
          g_PeersInfo_Serp.ActivePeers[g_PeersInfo_Serp.PeerInt] = g_PeersInfo_Serp.Username
          g_PeersInfo_Serp.CoopFinished = true
          local EveryHumanSingleCoop = true -- if every human team ever had a single peer and also currently has a single peer, we know who is who already
          for lPID,cooppeers in pairs(everactive_coops) do
            if g_CoopCountResSerp.CountPerPID[lPID]~=1 then -- currently active peers in this coop team
              EveryHumanSingleCoop = false
            elseif g_LTL_Serp.table_len(cooppeers)~=1 then -- ever active peers in this coop team
              EveryHumanSingleCoop = false
            end
          end
          if EveryHumanSingleCoop then
            for peerint,username in pairs(g_PeersInfo_Serp.Everactive_Usernames) do
              g_PeersInfo_Serp.ActivePeers[peerint] = username
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
            g_PeersInfo_Serp.FullFinished = true
            g_LTL_Serp.modlog("EveryHumanSingleCoop active, done",ModID)
            return
          end
        end
        
        if g_PeersInfo_Serp.IsUsingPopUp and g_MP_PopUps_Serp~=nil then
          g_LTL_Serp.start_thread("g_MP_PopUps_Serp Start mp_popup",ModID,g_MP_PopUps_Serp.t_Start,everactive_coops)
        elseif _Peer_Tricks_Serp~=nil then -- Now do the ui/session thing
          g_LTL_Serp.start_thread("_Peer_Tricks_Serp Start peer_tricks",ModID,_Peer_Tricks_Serp.t_Start,everactive_coops)
        else
          g_LTL_Serp.modlog("ERROR Lua wont work well in multiplayer! Neither g_MP_PopUps_Serp ("..tostring(g_MP_PopUps_Serp)..") nor _Peer_Tricks_Serp ("..tostring(_Peer_Tricks_Serp)..") is loaded?!",ModID)
          GameManager.OnlineManager.leaveSession()
          return
        end
        
      else -- not multiplayer game
        OnlyOnePeer()
        return
      end
    end

    -- ##################################################################################
    -- functions to use in your mod

    -- based in the info we got with the PopUp we can create these functions:
    local function GetCoopCount() -- returns the number of total active coop players from the coop team from the local player
      return g_LTL_Serp.table_len(g_PeersInfo_Serp.ActiveCoopPeers) -- returns the same as g_CoopCountResSerp.CountPerPID[g_PeersInfo_Serp.PID] , because we make a check that this is the same after all PopUps are answered
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
    local function AmIFirstActivePeer() -- also works without ActivePeers/InactivePeers by using g_CoopCountResSerp which should be ready to use while player still answers PopUps
      if g_PeersInfo_Serp.PID==0 then
        if g_PeersInfo_Serp.AmIFirstActiveCoopPeer() then
         return true
        end
      else
        if g_CoopCountResSerp~=nil and g_CoopCountResSerp.Finished==true then
          if g_PeersInfo_Serp.PID==1 then
            if g_CoopCountResSerp.CountPerPID[0] == 0 and g_PeersInfo_Serp.AmIFirstActiveCoopPeer() then
              return true
            end
          elseif g_PeersInfo_Serp.PID==2 then
            if g_CoopCountResSerp.CountPerPID[0] == 0 and g_CoopCountResSerp.CountPerPID[1] == 0 and g_PeersInfo_Serp.AmIFirstActiveCoopPeer() then
              return true
            end
          elseif g_PeersInfo_Serp.PID==3 then
            if g_CoopCountResSerp.CountPerPID[0] == 0 and g_CoopCountResSerp.CountPerPID[1] == 0 and g_CoopCountResSerp.CountPerPID[2] == 0 and g_PeersInfo_Serp.AmIFirstActiveCoopPeer() then
              return true
            end
          end
        elseif g_PeersInfo_Serp.FullFinished then -- wird vermutlich nie genutzt, denn ohne g_CoopCountResSerp gibts auch kein FullFinished :D
          for i,PeerInt in ipairs(0,4,8,12,1,5,9,13,2,6,10,14,3,7,11,15) do -- same order like with the g_CoopCountResSerp workaround
            if g_LTL_Serp.table_contains_value(g_PeersInfo_Serp.ActivePeers,PeerInt) then
              return PeerInt==g_PeersInfo_Serp.PeerInt
            end
          end
        else
          return "error" -- g_CoopCountResSerp not ready (should be ready after 2 seconds ingame or 2 seconds after g_CoopCountResSerp.MakeNewCount was called again to refresh)
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
    
    
    
    
  -- ######################################################################################################################################################################
  -- ######################################################################################################################################################################

    -- t_ShareLuaInfo / t_ExecuteFnWithArgsForPeers can also be used to get an OID more efficient from another human peer who is in the correct session.
     -- Because he can use the fast GetCurrentSessionObjectsFromLocaleByProperty (note that he must own it) function or at least mySessionFilter with current session filter
      -- which is still faster/efficient than the everywhere function.
    
    
    -- local function StartShareThread()
      -- g_LTL_Serp.start_thread("StartShareThread",ModID,function()
        -- local task = table.remove(g_PeersInfo_Serp.ShareQueue,1)
        -- while task~=nil do
          -- if type(task)=="table" and task.infostring~=nil then
            -- local infostring = task.infostring
            -- local SharePID = g_LTL_Serp.GetPairAtIndSortedKeys(g_PeersInfo_Serp.PIDsToShareData,g_PeersInfo_Serp.PeerInt+1) -- g_PeersInfo_Serp.PIDsToShareData[g_PeersInfo_Serp.PeerInt+1]
            -- local waittime = task.waittime
            -- local DoneVariable,last_key = g_LTL_Serp.myeval(task.DoneVariableString,true)
            -- local PID_OID = nil
            -- local status,sessionparticipants = pcall(g_ObjectFinderSerp.GetAllLoadedSessionsParticipants,{SharePID},"First") -- only first found loaded session
            -- if status==false then
              -- g_LTL_Serp.modlog("ERROR : "..tostring(sessionparticipants),ModID)
              -- error(sessionparticipants) 
            -- end
            -- for SessionID,session_pids in pairs(sessionparticipants) do
              -- PID_OID = session_pids[SharePID].OID
              -- local status,err = pcall(g_LTL_Serp.DoForSessionGameObject,"[MetaObjects SessionGameObject("..tostring(PID_OID)..") Nameable Name("..tostring(infostring)..")]")
              -- if status==false then
                -- g_LTL_Serp.modlog("ERROR : "..tostring(err),ModID)
                -- error(err) 
              -- end
            -- end
            -- g_LTL_Serp.waitForTimeDelta(waittime) -- wait before we return, so after we return the caller can directly continue to GetSharedLuaInfo
            -- if DoneVariable[last_key]~=nil then
              -- DoneVariable[last_key] = infostring -- signal that we are finished setting up the Nameable
            -- end
            -- g_LTL_Serp.waitForTimeDelta(1000) -- wait another second before reusing the Nameable, so clients can do GetSharedLuaInfo
            -- DoneVariable[last_key] = false
          -- end
          -- task = table.remove(g_PeersInfo_Serp.ShareQueue,1)
        -- end
        -- g_PeersInfo_Serp.ShareLoopIsRunning = false
      -- end)
    -- end
    
    local function DoTheSharing(waittime,infostring,DoneVariableString)
      local SharePID = g_LTL_Serp.GetPairAtIndSortedKeys(g_PeersInfo_Serp.PIDsToShareData,g_PeersInfo_Serp.PeerInt+1) -- g_PeersInfo_Serp.PIDsToShareData[g_PeersInfo_Serp.PeerInt+1]
      
      g_LTL_Serp.modlog("DoTheSharing before DoneVariableString "..tostring(ts.GameClock.CorporationTime),ModID)
      local DoneVariable,last_key = g_LTL_Serp.myeval(DoneVariableString,true)

      g_LTL_Serp.modlog("DoTheSharing after DoneVariableString "..tostring(ts.GameClock.CorporationTime),ModID)
      local PID_OID = nil
      local status,sessionparticipants = pcall(g_ObjectFinderSerp.GetAllLoadedSessionsParticipants,{SharePID},"First") -- only first found loaded session
      if status==false then
        g_LTL_Serp.modlog("ERROR : "..tostring(sessionparticipants),ModID)
        error(sessionparticipants) 
      end
      
      g_LTL_Serp.modlog("DoTheSharing after GetAllLoadedSessionsParticipants "..tostring(ts.GameClock.CorporationTime),ModID)
      for SessionID,session_pids in pairs(sessionparticipants) do
        PID_OID = session_pids[SharePID].OID
        local status,err = pcall(g_LTL_Serp.DoForSessionGameObject,"[MetaObjects SessionGameObject("..tostring(PID_OID)..") Nameable Name("..tostring(infostring)..")]")
        if status==false then
          g_LTL_Serp.modlog("ERROR : "..tostring(err),ModID)
          error(err) 
        end
      end
      g_LTL_Serp.modlog("DoTheSharing after DoForSessionGameObject "..tostring(ts.GameClock.CorporationTime),ModID)
      g_LTL_Serp.waitForTimeDelta(waittime) -- wait before we return, so after we return the caller can directly continue to GetSharedLuaInfo
      if DoneVariable[last_key]~=nil then
        DoneVariable[last_key] = infostring -- signal that we are finished setting up the Nameable
      end
      g_LTL_Serp.waitForTimeDelta(1000) -- wait another second before reusing the Nameable, so clients can do GetSharedLuaInfo
      DoneVariable[last_key] = false
      g_LTL_Serp.modlog("DoTheSharing task done "..tostring(ts.GameClock.CorporationTime),ModID)
    end
    
    -- Better dont use t_ShareLuaInfo directly. use t_ExecuteFnWithArgsForPeers instead
    -- make sure the code that calls this only runs for the one peer you want it to run (by checking g_PeersInfo_Serp.PeerInt and other info from g_PeersInfo_Serp.)
    -- DoneVariableString eg: "g_PeersInfo_Serp._ExecuteDone" . The variable you provide will be set to infostring
     -- after sharing is done and waittime waited. This way the called can find out when it was processed
    local function t_ShareLuaInfo(infostring,waittime,DoneVariableString)
        if g_PeersInfo_Serp==nil or g_CoopCountResSerp==nil then
          return false
        end
        waittime = waittime or 3000  -- at least 1 second, better 3 to make sure even slower PCs synced
        -- g_LTL_Serp.modlog("t_ShareLuaInfo before yield "..tostring(ts.GameClock.CorporationTime),ModID)
        while g_PeersInfo_Serp.CoopFinished~=true or g_CoopCountResSerp.Finished~=true do
          coroutine.yield()
        end
        
        -- TODO test if this works, if yes, remove the global ShareLoopIsRunning and so on
        g_LTM_Serp.AddToQueue(ModID.."_ShareLuaInfo",DoTheSharing,waittime,infostring,DoneVariableString) -- blocking our personal PIDsToShareData object, so we need to do it one after the other
        
        -- table.insert(g_PeersInfo_Serp.ShareQueue,{waittime=waittime,infostring=infostring,DoneVariableString=DoneVariableString})
        -- if not g_PeersInfo_Serp.ShareLoopIsRunning then
          -- g_PeersInfo_Serp.ShareLoopIsRunning = true
          -- g_PeersInfo_Serp.StartShareThread()
        -- end
        -- g_LTL_Serp.modlog("t_ShareLuaInfo nach thread starten "..tostring(ts.GameClock.CorporationTime),ModID)
        return true
    end
    
    local function GetSharedLuaInfo(FromPeerInt)
        local SharePID = g_LTL_Serp.GetPairAtIndSortedKeys(g_PeersInfo_Serp.PIDsToShareData,FromPeerInt+1) -- g_PeersInfo_Serp.PIDsToShareData[FromPeerInt+1]
        local status,sessionparticipants = pcall(g_ObjectFinderSerp.GetAllLoadedSessionsParticipants,{SharePID},"First") -- only first found loaded session
        if status==false then
          g_LTL_Serp.modlog("ERROR : "..tostring(sessionparticipants),ModID)
          error(sessionparticipants) 
        end
        local text = nil
        for SessionID,session_pids in pairs(sessionparticipants) do
          text = ts.GetGameObject(session_pids[SharePID].OID).Nameable.Name -- if Name was changed with DoForSessionGameObject, then GetGameObject works to get the name regardless of player and session
        end
        return text
    end



    -- call it from within a thread
    -- this function is called from one peer and shares the information with all other peers and makes
     -- them execute the command all at the same time. (only needed if other peers dont have the required information, eg. an OID. IF everyone has all info, then simply start a trigger with ActionExecuteScript)
    -- funcname (string) must either directly exist as global variable. or be included in a global table. Then use eg. "g_ObjectFinderSerp.MyFunc" as string
    -- args is a table. only strings, numbers and bools are allowed as content
    --  nice for commands that are not synced (cause desync) and do not require everyone to be in the relevant session. Eg. CheatItemInSlot (hm, suddenly this does not desync anymore and is synced automatically?!)
    -- and also very nice for ts.Economy.MetaStorage.AddAmount(1010017, amount) and other things only hitting the local player, while we want another player to execute it
     -- (einfach eine funktiuon aufrufen lassen, die dann zb anhand der arguments prüft welcher peer man ist)
      -- returnafterfinish=true wenn erst returned werden soll wenns fertig ist (da t_ShareLuaInfo evtl. Queue voll)
        -- Nur möglich wenn bereits aus einem thread heraus aufgerufen wird!
      -- ForPeers = list of peers, or string like: 
        -- "Everyone", "FirstActivePeer", "FirstActiveCoopPeer", "Human0", "Human0_FirstPeer"
         -- and any of these combination with Session like this: Human0_Session_180023
    -- Since this function uses the Nameable Share feature, it blocks it for roughly ~4 seconds.
     -- So it should not be used too often in short time.
     -- In case you want Peers to execute a static function without the need to sync special arguments,
      -- it might be better to do the old bit more code intensive way:
       -- Start a Trigger/FeatureUnlock that does ActionExecuteScript (executed for everyone) and start a script with your custom static code.
    local function t_ExecuteFnWithArgsForPeers(funcname,waittime,returnafterfinish,ForPeers,...)
        g_LTL_Serp.modlog("t_ExecuteFnWithArgsForPeers start "..tostring(funcname).." "..tostring(ts.GameClock.CorporationTime),ModID)
        local args = {...} -- does put the "..." arguments into a table
        local intable = {funcname=funcname,args=args,ForPeers=ForPeers}
        local inhex = g_StringTableConvertSerpNyk.TableToHex(intable)
        
        while g_PeersInfo_Serp.CoopFinished~=true do
          coroutine.yield()
        end
        
        local function DoExecuteFnWithArgsForPeers(inhex,waittime)
            -- g_LTL_Serp.modlog("DoExecuteFnWithArgsForPeers before share "..tostring(ts.GameClock.CorporationTime),ModID)
            local status,err = pcall(g_PeersInfo_Serp.t_ShareLuaInfo,inhex,waittime,"g_PeersInfo_Serp._ExecuteDone")
            if status==false then
              g_LTL_Serp.modlog("ERROR : "..tostring(err),ModID)
              error(err) 
            end
            -- g_LTL_Serp.modlog("DoExecuteFnWithArgsForPeers shared "..tostring(ts.GameClock.CorporationTime),ModID)
            while g_PeersInfo_Serp._ExecuteDone~=inhex do -- wait for it to finish (after that we have 1 sec to fetch the info)
              coroutine.yield()
            end
            -- g_LTL_Serp.modlog("DoExecuteFnWithArgsForPeers ExecuteDone "..tostring(ts.GameClock.CorporationTime),ModID)
            local Unlock = g_PeersInfo_Serp.ExForEveryUnlocks[g_PeersInfo_Serp.PeerInt+1]
            ts.Unlock.SetUnlockNet(Unlock) -- starting another script via xml ActionExecuteScript roughly takes 200 ms in EarlyGame
            -- g_LTL_Serp.modlog("DoExecuteFnWithArgsForPeers unlocked "..tostring(ts.GameClock.CorporationTime),ModID)
            g_LTL_Serp.waitForTimeDelta(500) -- wait shortly to make sure all coop players executed this
        end
        
        if returnafterfinish then -- execute in current thread and block it (return after finished)
          DoExecuteFnWithArgsForPeers(inhex,waittime)
        else -- execute in new thread (and return before it is finished)
          system.start(function()
            DoExecuteFnWithArgsForPeers(inhex,waittime)
          end,ModID.." DoExecuteFnWithArgsForPeers")
        end
    end
    
    
    -- internal use only (used by t_ExecuteFnWithArgsForPeers process (exforevery_peer0.lua). use t_ExecuteFnWithArgsForPeers directly)
    local function _DoTheExecutionFor(FromPeerInt)
      g_LTL_Serp.modlog("DoTheExecutionFor FromPeerInt "..tostring(FromPeerInt).." "..tostring(ts.GameClock.CorporationTime),ModID)
      local inhex = g_PeersInfo_Serp.GetSharedLuaInfo(FromPeerInt)
      local intable = g_StringTableConvertSerpNyk.HexToTable(inhex)
      if type(intable) =="table" then
        -- g_LTL_Serp.modlog(intable.funcname,ModID)
        local ShouldIExecute = false
        local ForPeers = intable.ForPeers
        if ForPeers==nil then
          ShouldIExecute = true
        elseif type(ForPeers)=="string" then
          local ForPeersSplit = g_LTL_Serp.mysplit(ForPeers, "_Session_") -- "Human0_Session_180023" or "Everyone_Session_180023"
          local SessionGuid = tonumber(ForPeersSplit[#ForPeersSplit]) -- SessionGuid or nil
          ForPeers = ForPeersSplit[1]
          if ForPeers=="Everyone" then
            ShouldIExecute = (SessionGuid==nil or session.getSessionGUID()==SessionGuid)
          elseif ForPeers=="FirstActiveCoopPeer" then -- FirstActiveCoopPeer + Session = finds the first active coop peer who is in that session (not only checking the first active peer, but all of my coop-team)
            if SessionGUID~=nil then
              ShouldIExecute = g_PeersInfo_Serp.AmIFirstActiveCoopPeerInSession(SessionGuid)
            else
              ShouldIExecute = g_PeersInfo_Serp.AmIFirstActiveCoopPeer()
            end
          elseif ForPeers=="FirstActivePeer" then -- FirstActivePeer + Session = finds the first active peer who is in that session (not only checking the first active peer, but all peers)
            if SessionGUID~=nil then
              ShouldIExecute = g_PeersInfo_Serp.AmIFirstActivePeerInSession(SessionGuid)
            else
              ShouldIExecute = g_PeersInfo_Serp.AmIFirstActivePeer()
            end
          elseif ForPeers=="Human0" then -- Human0 + Session = Every Peer who belongs to Human0 and is in that session
            ShouldIExecute = g_PeersInfo_Serp.PID==0 and (SessionGuid==nil or session.getSessionGUID()==SessionGuid)
          elseif ForPeers=="Human1" then
            ShouldIExecute = g_PeersInfo_Serp.PID==1 and (SessionGuid==nil or session.getSessionGUID()==SessionGuid)
          elseif ForPeers=="Human2" then
            ShouldIExecute = g_PeersInfo_Serp.PID==2 and (SessionGuid==nil or session.getSessionGUID()==SessionGuid)
          elseif ForPeers=="Human3" then
            ShouldIExecute = g_PeersInfo_Serp.PID==3 and (SessionGuid==nil or session.getSessionGUID()==SessionGuid)
          elseif ForPeers=="Human0_FirstPeer" then -- Human0_FirstPeer + Session = Finding a peer from Human0 who is in that session, choosing the first one we find
            if SessionGUID~=nil then
              ShouldIExecute = g_PeersInfo_Serp.PID==0 and g_PeersInfo_Serp.AmIFirstActiveCoopPeerInSession(SessionGuid) -- enough to check CoopPeer here, because its enough to only compare with our own coop-team
            else
              ShouldIExecute = g_PeersInfo_Serp.PID==0 and g_PeersInfo_Serp.AmIFirstActiveCoopPeer() -- enough to check CoopPeer here, because its enough to only compare with our own coop-team
            end
          elseif ForPeers=="Human1_FirstPeer" then
            if SessionGUID~=nil then
              ShouldIExecute = g_PeersInfo_Serp.PID==1 and g_PeersInfo_Serp.AmIFirstActiveCoopPeerInSession(SessionGuid)
            else
              ShouldIExecute = g_PeersInfo_Serp.PID==1 and g_PeersInfo_Serp.AmIFirstActiveCoopPeer()
            end
          elseif ForPeers=="Human2_FirstPeer" then
            if SessionGUID~=nil then
              ShouldIExecute = g_PeersInfo_Serp.PID==2 and g_PeersInfo_Serp.AmIFirstActiveCoopPeerInSession(SessionGuid)
            else
              ShouldIExecute = g_PeersInfo_Serp.PID==2 and g_PeersInfo_Serp.AmIFirstActiveCoopPeer()
            end
          elseif ForPeers=="Human3_FirstPeer" then
            if SessionGUID~=nil then
              ShouldIExecute = g_PeersInfo_Serp.PID==3 and g_PeersInfo_Serp.AmIFirstActiveCoopPeerInSession(SessionGuid)
            else
              ShouldIExecute = g_PeersInfo_Serp.PID==3 and g_PeersInfo_Serp.AmIFirstActiveCoopPeer()
            end
          else
            g_LTL_Serp.modlog("ERROR DoTheExecutionFor (t_ExecuteFnWithArgsForPeers): invalid -ForPeers- was provided: "..tostring(ForPeers).." . Will execute for everyone now",ModID)
            ShouldIExecute = true
          end
        elseif type(ForPeers)=="table" then
          ShouldIExecute = g_LTL_Serp.table_contains_value(ForPeers,g_PeersInfo_Serp.PeerInt)
        else
          g_LTL_Serp.modlog("ERROR DoTheExecutionFor (t_ExecuteFnWithArgsForPeers): invalid -ForPeers- was provided: "..tostring(ForPeers).." . Will execute for everyone now",ModID)
          ShouldIExecute = true
        end
        -- g_LTL_Serp.modlog("DoTheExecutionFor before ShouldIExecute",ModID)
        if ShouldIExecute then
          -- g_LTL_Serp.modlog("DoTheExecutionFor yes ShouldIExecute",ModID)
          func = g_LTL_Serp.myeval(intable.funcname)
          -- g_LTL_Serp.modlog("func call "..tostring(ts.GameClock.CorporationTime),ModID)
          local success, err = pcall(func,table.unpack(intable.args))
          if success==false then
            g_LTL_Serp.modlog("ERROR while trying to call funcname "..tostring(intable.funcname).." error: "..tostring(err),ModID)
          end
            -- g_LTL_Serp.modlog("DoTheExecutionFor after call",ModID)
        end
      end
    end
    
    
    
    
    -- ######################################################################################################################################################################
    -- ######################################################################################################################################################################
    
    
    

    -- also useful:
    -- g_CoopCountResSerp.CountPerPID[PID] to find out how many active peers another Participant has
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
      NeverActivePeers = {},
      Everactive_Usernames = {},
      PeerToPID = {[0]=0,[4]=0,[8]=0,[12]=0,[1]=1,[5]=1,[9]=1,[13]=1,[2]=2,[6]=2,[10]=2,[14]=2,[3]=3,[7]=3,[11]=3,[15]=3},
      -- Share Infos between peers or make them exeucte code
      t_ExecuteFnWithArgsForPeers = t_ExecuteFnWithArgsForPeers, -- at best only use this
      t_ShareLuaInfo = t_ShareLuaInfo, -- only use if you know what you are doing, use t_ExecuteFnWithArgsForPeers instead
      GetSharedLuaInfo = GetSharedLuaInfo, -- only use if you know what you are doing, use t_ExecuteFnWithArgsForPeers instead
      PIDsToShareData = {[117]=true,[118]=true,[119]=true,[120]=true,[121]=true,[122]=true,[123]=true,[124]=true,[125]=true,[126]=true,[127]=true,[128]=true,[129]=true,[136]=true,[137]=true,[138]=true}, -- use g_LTL_Serp.pairsByKeys() to iterate sorted by keys or g_LTL_Serp.GetPairAtIndSortedKeys to get k,v at a specific index
      ExForEveryUnlocks = {1500004620,1500004621,1500004622,1500004623,1500004624,1500004625,1500004626,1500004627,1500004628,
        1500004629,1500004630,1500004631,1500004632,1500004633,1500004634,1500004635}, -- GUIDs for FeatureUnlock to start peer scripts
      _DoTheExecutionFor = _DoTheExecutionFor, -- internal use!
      -- StartShareThread = StartShareThread, -- internal use!
      -- ShareQueue = {}, -- internal use!
      -- ShareLoopIsRunning = false, -- internal use!
      _ExecuteDone = false, -- internal use!
      IsUsingPopUp = false, -- Will be forever false now, popup is not reliable enough.... (change this value to switch between sessiontrick and popups to find out who is which peer)
    }
    
    -- ###################################################################################
    
    if g_PeersInfo_Serp.IsUsingPopUp then
      console.startScript("data/scripts_serp/mp_popup.lua") -- in shared mod shared_MP_Lua_PopUps
    else
      console.startScript("data/scripts_serp/h/peer_tricks.lua") -- within this mod
    end
    
    g_LTL_Serp.start_thread("Start check_peers",ModID,_Start)
    
    
    
    -- ###################################################################################
    -- ###################################################################################
    
    
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