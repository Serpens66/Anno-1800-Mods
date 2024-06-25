print("register_cooppeers_ongameloaded.lua called (will register if not already done)")


if CoopPeers_Serp==nil then
  console.startScript("data/scripts_serp/cooppeers.lua")
end


-- source: https://stackoverflow.com/questions/65482605/how-to-print-all-values-in-a-lua-table
local sort, rep, concat = table.sort, string.rep, table.concat
local function TableToPrettyString(var, sorted, indent)
    
    if type (var) == 'string' then
        return "'" .. var .. "'"
    elseif type (var) == 'table' then
        local keys = {}
        for key, _ in pairs (var) do
            keys[#keys + 1] = key
        end
        if sorted then
            sort (keys, function (a, b)
                if type (a) == type (b) and (type (a) == 'number' or type (a) == 'string') then
                    return a < b
                elseif type (a) == 'number' and type (b) ~= 'number' then
                    return true
                else
                    return false
                end
            end)
        end
        local strings = {}
        local indent = indent or 0
        for _, key in ipairs (keys) do
            strings [#strings + 1]
                = rep ('\t', indent + 1)
               .. TableToPrettyString(key, sorted, indent + 1)
               .. ' = '
               .. TableToPrettyString(var [key], sorted, indent + 1)
        end
        return 'table (\n' .. concat (strings, '\n') .. '\n' .. rep ('\t', indent) .. ')'
    else
        return tostring (var)
    end
end


-- GetActiveSessionGUIDOfPeerInt returns 0 for all NEVER-active peer slots. 0,4,8 and 12 belong to Human0 and so on
 -- it returns a session guid also for coop slots that were filled at anytime (also if they are currently not active anymore, because the game was loaded without them!)

-- CoopCount dann über Marker? 

-- local function GetActiveCoopCount(HumanID)
  -- HumanID = HumanID or ts.Participants.GetGetCurrentParticipantID()
  -- local count = 0
  -- local maxpeerindexes = {[0]=12,[1]=13,[2]=14,[3]=15}
  -- for i=HumanID,maxpeerindexes[HumanID],4 do
    -- if ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i)~=0 then
      -- count = count + 1
    -- end
  -- end
  -- return count
-- end

-- includes coop slots that were filled at anytime (also if they are currently not active anymore, because the game was loaded without them!)
local function GetEverCoopCount(HumanID)
  HumanID = HumanID or ts.Participants.GetGetCurrentParticipantID()
  local count = 0
  local maxpeerindexes = {[0]=12,[1]=13,[2]=14,[3]=15}
  for i=HumanID,maxpeerindexes[HumanID],4 do
    if ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i)~=0 then
      count = count + 1
    end
  end
  return count
end

local function GetFirstSessionFromCoop(HumanID)
  HumanID = HumanID or ts.Participants.GetGetCurrentParticipantID()
  local FirstSession -- find first valid session we all can enter
  local maxpeerindexes = {[0]=12,[1]=13,[2]=14,[3]=15}
  for i=HumanID,maxpeerindexes[HumanID],4 do
    SessionOfPeer = ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i)
    if SessionOfPeer~=0 then
      FirstSession = SessionOfPeer
      break
    end
  end
  return FirstSession
end

local function IsEveryCoopSameSession(checksession,HumanID)
  checksession = checksession or CoopCount_Serp.GetFirstSessionFromCoop()
  HumanID = HumanID or ts.Participants.GetGetCurrentParticipantID()
  local everyonesamesession = true
  local activesessionofpeer
  local maxpeerindexes = {[0]=12,[1]=13,[2]=14,[3]=15}
  for i=HumanID,maxpeerindexes[HumanID],4 do
    activesessionofpeer = ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i) -- returns 0 for not-active playerslots
    if activesessionofpeer~=0 and checksession~=activesessionofpeer then
      everyonesamesession = false
      break
    end
  end
  return everyonesamesession
end

-- checks for every human player, not only coop. because some commands cause desync if not executed from all players the same time (and often in the same session)

local function IsEveryoneSameSession(checksession,alsoinactivecoop)
  local everyonesamesession = true
  local activesessionofpeer
  for i=0,15 do -- up to 16 playerslots at max (with coop) starting at 0
    activesessionofpeer = ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i) -- returns 0 for not-active playerslots
    if checksession==nil and activesessionofpeer~=0 then
      checksession = activesessionofpeer
    end
    if activesessionofpeer~=0 and checksession~=activesessionofpeer then
      everyonesamesession = false
      break
    end
  end
  return everyonesamesession
end




local function CheckMarkerSameSessionObject()
  session.selectNextObject()
  local OID = ObjectFinderSerp.IDConverter.get_OID(session.getSelectedFactory())
  local peerints = ObjectFinderSerp.GetCoopPeersAtMarker(119,OID) -- these will be all existing coop peers, except of my own
  if peerints~=nil then
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
    else -- Im the only active coop one
      CoopPeers_Serp.ImFirstActiveCoopPeer = true
      -- we can not really say which peerint we are.. could be we loaded a savegame where all other are inactive
    end
  else
    print("CoopPeers: Attention! code to fetch PeerInt and ImFirstActiveCoopPeer failed ...")
  end
end

-- testen ob "jumptoSession" Befehl beim inaktiven spielern funzt.
-- wenn es nicht funzt bekommen wir raus, wer aktiv ist
 -- (evlt auch ActionEnterSession xml testen) 
-- wenn es funzt, dann sind inaktive Spieler zumindest kein Problem wenn wir sessionwechsel erzwingen müssen
-- allgemein also:
-- allen ausführenden spielern in lua einen command ausführen lassen,
 -- von dem andere kontrollieren können, ob sie es gemacht haben
-- dann weiß man wer aktiv ist und wer nicht

-- ActionEnterSession scheint vorallem schneller am ausführen zu sein, also vllt das nutzen, wenns ne bekannte session ist für die ich nen trigger hab
 -- aber wird auch nicht für die inaktiven spieler ausgeführt.

-- Worldmap session wird nicht von GetActiveSessionGUIDOfPeerInt erkannt, muss also ne andere sein.
-- Wenn aber nur eine session geladen ist, geht das nicht, aber in dem fall sind ja dann sicher alle in derselben session (wobei vorsichtshalber dennoch jumpto machen
 -- falls einer in worldmap ist) 

-- vllt auch mal testen ob und wieviel davon ausgelöst von einem alwaystrue trigger funktioniert.
 -- wäre ja cool wenn zb das session hin und herwechseln usw ablaufen könnte, während die spieler noch im ladebildschirm sind

-- 0) mit GetEverCoopCount() gucken ob mehr als 1ter slot "jemals aktiv" war. Wenn nur slot1 aktiv war, dann ists schon erledigt, wir sind und waren immer der einzige coop.
-- 1) ObjectFinderSerp.GetLoadedSessions(1,6)
-- 2) wenns nur eine ist, dann dennoch nochmal alle in diese session befehlen (könnten worldmap sein) und dann mit selectNextObject und Marker stuff machen
-- 3)  falls laut marker alle jemals aktiven coops aktiv sind, ist alles erledigt.
-- 4) wenn angeblich welche in anderer session sind, dann alle sessionswitch in die erste session. Dann den Marker check mit Selection.
 -- und wenn nicht alle aktiv sind, dann checken wer angeblich nicht in korrekter session ist und ob das alle inaktiven sind,
  -- wenn nicht, dann nochmal sessionwitch in die 2te session und gucken wer sich nicht bewegt hat.
  -- -> haben alle inaktivten Spieler und wissen dadurch und durchs marker ergebnis nun wer aktiv ist und wer wir sind




-- Man kann auch share_LuaInfo Tool verwenden um infos auszutauschen:
  -- alle coop spieler schreiben da nach x sekunden das rein, was sie mit marker sehen, wobei x die summe der peerints ist die sie sehen.
  -- auf diese weise schreibt keiner gleichzeitig rein und es kann von anderen auch ausgelesen werden.
  -- Am ende weiß dann jeder welche coop partner tatsächlich aktiv sind und alles ist gut. (wobei man dann auch noch zwischen human0 und Human1 usw austauschen muss)
 -- Problem: Wenn es nur einen aktiven Coop Spieler gibt, es aber mal mehr waren, ist Markers ja leer und das funktioniert nicht. -.-




-- local function checkSession()
  -- if IsEveryoneSameSession(nil,true) then
    -- CheckMarkerSameSessionObject()
  -- else
  
  -- end
-- end

-- TODO
-- PopUp PlayerLeft
-- lua script ausführen, welches ~15 sekunden in lua wartet (15 sek damits nichts macht, wenn spieler eh spiel beenden wollen und in lua, dmait nicht gespeichert wird)
 -- und dann erneut versucht rauszufinden, welcher coop peer jetzt inaktiv geworden ist, (wer man selbst ist weiß man ja noch)
-- alternativ noch besser eine antwort vom PopUp forcieren ts.Popup.ClosePopup(0/1) um das spiel zu beenden,
 -- damit neu geladen werden muss


local function AtLeastOnePeerAtSession(searchSession)
  for i=0,15 do 
    if ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i)==searchSession then
      return true
    end
  end
end

local function CheckWhichPeerAmI(peerints)
  print("CheckWhichPeerAmI",ts.GameClock.CorporationTime)
  local HumanID = ts.Participants.GetGetCurrentParticipantID()
  -- local peerints = ObjectFinderSerp.GetCoopPeersAtMarker(176,0) -- these will be all existing coop peers, except of me
  if next(peerints) then
    local maxpeerindexes = {[0]=12,[1]=13,[2]=14,[3]=15}
    for i=HumanID,maxpeerindexes[HumanID],4 do
      if CoopPeers_Serp.PeersInfo.ActivePeers[i] and not peerints[i] then
        CoopPeers_Serp.PeerInt = i
        break
      end
    end
    if CoopPeers_Serp.PeerInt~=nil then
      for i=HumanID,maxpeerindexes[HumanID],4 do
        if CoopPeers_Serp.PeersInfo.ActivePeers[i] then
          if i==CoopPeers_Serp.PeerInt then
            CoopPeers_Serp.ImFirstActiveCoopPeer = true
          else
            CoopPeers_Serp.ImFirstActiveCoopPeer = false
          end
          break -- we only have to check the first active coop peer with help of GetActiveSessionGUIDOfPeerInt. if you are it your are first, if not, not
        end
      end
    end
    
    -- TODO:
     -- noch n sicherheitscheck einbauen, der prüft ob die anzahl in CoopPeers_Serp.PeersInfo.ActivePeers[i]
      -- gleich peerints+1 ist. Kann passeiren, wenn einer der Spieler das menu vorzetig schleßt, bevor wir Peerints abgefragt haben..
    
  else
    print("CoopPeers: Attention! code to fetch PeerInt and ImFirstActiveCoopPeer failed ...")
  end
  print("CoopPeers: you are PeerInt: ", tostring(CoopPeers_Serp.PeerInt),", ImFirstActiveCoopPeer: ",tostring(CoopPeers_Serp.ImFirstActiveCoopPeer))
end

-- wie gehen wir damit um, dass sowohl das Laden der Session, als auch das wechseln dahin,
 -- potentiell untersch. lange dauern kann, je nach PC ?

-- emptysessionpart1
local function FindOutInactivePlayersViaSessionTrick()
  print("FindOutInactivePlayersViaSessionTrick",ts.GameClock.CorporationTime)
  local SessionToCheck = 1500004631
  CoopPeers_Serp.previousSession = session.getSessionGUID()
  -- system.start(function()
    print("3333",ts.GameClock.CorporationTime)
    
    -- TODO: notification zeigen funzt iwie beim laden eines savegames nie.. nur beim ersten spielstart, kann aber über console problemlos gezeigt werden..
    
    system.waitForGameTimeDelta(1000) -- TODO test hilft delay damit nachricht angezeigt wird?
    ts.Unlock.SetUnlockNet(1500004630) -- show a small notification to tell the user what is going on
    
    -- game.GUIManager.showNotification(501378)
    
    -- ts.Interface.ToggleUI()
    -- game.GUIManager.toggleMinimap()
    -- ts.Interface.ToggleCompanyMenu()
    -- ts.Interface.ToggleDiplomacyMenu()
    
    ts.Interface.OpenStatisticsShipList()
    
    ts.GameClock.SetSetGameSpeed(1) -- slow gamespeed
    print("4444",ts.GameClock.CorporationTime)
    ts.Unlock.SetUnlockNet(1500004634) -- load empty session
    
    print("5555",ts.GameClock.CorporationTime)
    local peerints = {}
    local notstop = 0
    while true do
      if game.isSessionLoadingDone(SessionToCheck) then
        break
      end
      coroutine.yield()
      if notstop==5 then -- fetch it after small delay, but still as soon as possible, just in case user closes the menu...
        peerints = ObjectFinderSerp.GetCoopPeersAtMarker(176,0) -- these will be all existing coop peers, except of me
      end
      notstop = notstop + 1
      if notstop > 100 then
        print("NOTSTOP session loaded",ts.GameClock.CorporationTime)
        break
      end
    end
    if notstop>100 then
      return
    end
    print("loaded",ts.GameClock.CorporationTime)
    if not next(peerints) then
      peerints = ObjectFinderSerp.GetCoopPeersAtMarker(176,0) -- these will be all existing coop peers, except of me
    end
    
    -- hier könnte es tricky werden, wenn manche PCS deutlich länger die session laden als andere,
     -- weil dann der ActionEnterSession befehl vom Trigger zu schnell kommt...
     -- Ja, die Session werden definitiv untersch. schnell geladen... also hier noch ein paar yields machen, damit sicher alle fertig sind...
    coroutine.yield()
    coroutine.yield()
    coroutine.yield()
    coroutine.yield()
    
    if not next(peerints) then
      peerints = ObjectFinderSerp.GetCoopPeersAtMarker(176,0) -- these will be all existing coop peers, except of me
    end
    
    ts.Unlock.SetUnlockNet(1500004633) -- enter empty session (with triggeraction is much faster than JumpToSession...)
    -- rest will be done in emptysessionpart2 code which is started by trigger 1500004633, because this way we have less problems
     -- with invisble terrein/objects when jumping back to previousSession
     -- we need a delay before jumping back to previous session, otherwise graphic might not be loaded correctly.
     -- but we already waited long enough for GetActiveSessionGUIDOfPeerInt to update, so it is fine to just continue here
     -- (before that delay was added, it also worked well to start a "part2" script in the trigger that does ActionEnterSession, to make sure enough time passed, without using yield)
    
    
    -- ########################################
    
    print("emptysessionpart2 start",ts.GameClock.CorporationTime)
    local SessionToCheck = 1500004631
    -- GetActiveSessionGUIDOfPeerInt does takes a looong time to actually show the correct session, while session.getSessionGUID() already has the correct one..
    local notstop = 0
    while true do
      if AtLeastOnePeerAtSession(SessionToCheck) then
        break
      end
      coroutine.yield()
      notstop = notstop + 1
      if notstop > 100 then
        print("NOTSTOP session enter",ts.GameClock.CorporationTime)
        break
      end
    end
    if notstop <= 100 then
      coroutine.yield() -- one extra to be extra sure
      local SGUID
      for i=0,15 do 
        SGUID = ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i)
        if SGUID==0 then
          CoopPeers_Serp.PeersInfo.NeverActivePeers[i] = true
        elseif SGUID==SessionToCheck then
          CoopPeers_Serp.PeersInfo.ActivePeers[i] = true
        elseif SGUID~=SessionToCheck then
          CoopPeers_Serp.PeersInfo.InactivePeers[i] = true
        end
      end
    end
    
    print(TableToPrettyString(CoopPeers_Serp.PeersInfo))
    CheckWhichPeerAmI(peerints) -- check it after we found out who is active/inactive and before we close the statistic menu by calling JumpToSession
    
    -- seems a yield here is still needed? crashed without it...
    coroutine.yield()
    
    ts.Interface.JumpToSession(CoopPeers_Serp.previousSession) -- jump to previous session again, closes Menus automatically
    
    ts.GameClock.SetSetGameSpeed(3) -- normal gamespeed
    
    -- a good delay before unloading the empty session, because it may crash otherwise...
    system.waitForGameTimeDelta(1000)
    ts.Unlock.SetUnlockNet(1500004634) -- unload empty session
    print("done FindOutInactivePlayersViaSessionTrick",ts.GameClock.CorporationTime)
    
  -- end)
end





-- OnLuaGameLoaded
local ModID = "shared_LuaCoopPeers_Serp"
local function OnSaveGameLoad_RESET()
  CoopPeers_Serp.PeerInt = nil
  CoopPeers_Serp.ImFirstActiveCoopPeer = nil
  CoopPeers_Serp.previousSession = nil -- internal helper
  CoopPeers_Serp.PeersInfo = {ActivePeers={},InactivePeers={},NeverActivePeers={}}
end
local function OnSaveGameLoad()
  -- OnSaveGameLoad is already called with 0.7 second delay, so all players should already arrive in their session and completed sessionenter animation hopefully
  print("1111")
  if ts.GameSetup.IsMultiPlayerGame then
    if ObjectFinderSerp==nil then
      console.startScript("data/scripts_serp/objectfinder/objectfinder.lua")
    end
    print("2222")
    -- if CoopCount_Serp==nil then
      -- console.startScript("data/scripts_coophelper_serp/coopcount.lua")
    -- end
    local HumanID = ts.Participants.GetGetCurrentParticipantID()
    -- if CoopCount_Serp.GetCoopCount(HumanID)>1 then
      print("3333")
      system.start(function()
        FindOutInactivePlayersViaSessionTrick()
        print("after FindOutInactivePlayersViaSessionTrick",ts.GameClock.CorporationTime)
        
        
      end)
      
      -- system.start(function()
        -- ts.Interface.ToggleDiplomacyMenu()
        -- system.waitForGameTimeDelta(200) -- short wait here, because notification is not shown on loading currently (only on gamestart which has 200ms more delay)
        -- ts.Unlock.SetUnlockNet(1500004630) -- show a small notification to tell the user what is going on
        -- system.waitForGameTimeDelta(400) -- wait for entering the menu
        -- local peerints = ObjectFinderSerp.GetCoopPeersAtMarker(29,0) -- these will be all existing coop peers, except of my own
        -- if not next(peerints) then -- failsafe, try again
          -- system.waitForGameTimeDelta(600) -- wait for entering the menu
          -- peerints = ObjectFinderSerp.GetCoopPeersAtMarker(29,0) -- these will be all existing coop peers, except of my own
          -- if not next(peerints) then
            -- ts.Interface.ToggleDiplomacyMenu()
            -- system.waitForGameTimeDelta(600) -- wait for entering the menu
            -- peerints = ObjectFinderSerp.GetCoopPeersAtMarker(29,0) -- these will be all existing coop peers, except of my own
          -- end
        -- end
        -- if next(peerints) then
          -- local maxpeerindexes = {[0]=12,[1]=13,[2]=14,[3]=15}
          -- for i=HumanID,maxpeerindexes[HumanID],4 do
            -- if not peerints[i] then
              -- CoopPeers_Serp.PeerInt = i
              -- break
            -- end
          -- end
          -- if CoopPeers_Serp.PeerInt~=nil then
            -- for i=HumanID,maxpeerindexes[HumanID],4 do
              -- if ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i)~=0 then
                -- if i==CoopPeers_Serp.PeerInt then
                  -- CoopPeers_Serp.ImFirstActiveCoopPeer = true
                -- else
                  -- CoopPeers_Serp.ImFirstActiveCoopPeer = false
                -- end
                -- break -- we only have to check the first active coop peer with help of GetActiveSessionGUIDOfPeerInt. if you are it your are first, if not, not
              -- end
            -- end
          -- end
        -- else
          -- print("CoopPeers: Attention! code to fetch PeerInt and ImFirstActiveCoopPeer failed ...")
        -- end
        -- ts.Interface.ToggleDiplomacyMenu()  
        -- print("CoopPeers: you are PeerInt: ", tostring(CoopPeers_Serp.PeerInt),", ImFirstActiveCoopPeer: ",tostring(CoopPeers_Serp.ImFirstActiveCoopPeer))
      -- end)
      
      
    -- else -- MP but the local player has no coop mates
      -- CoopPeers_Serp.ImFirstActiveCoopPeer = true
      -- CoopPeers_Serp.PeerInt = 0
    -- end
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
