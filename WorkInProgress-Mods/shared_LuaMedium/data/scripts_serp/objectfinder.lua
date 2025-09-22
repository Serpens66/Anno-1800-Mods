


-- TODO 
-- Am ende nochmal richtige Ladereihenfolge der ganzen lua mods aufstellen und sicherstellen, dass LoadAfterIds 
-- überall korrekt ist
-- zb LuaPeers und Objectfinder brauchen sich gegenseitig. Ladereihenfolge sollte theoretisch egal sein, aber wenns in beiden mods steht gibts bestimmt n fehler



-- TODO:
 -- funktionen die aus einem thread heraus aufgerufen werden müssen mit t_ am namen kennzeichnen



-- TODO Crash:
-- Scheint aktuell noch n Crash zu geben in meinem Coop Savegame (alleine gestartet, ohne KI)
 -- wenn ich da ein save lade und ~1-5 minuten im loading screen warte (während spiel schon losgeht)
  -- crasht das Spiel. Passiert auch wenn ich savecache.lua tick abschalten und alle event. bis auf OnLeaveUI in ongameloaded
   -- abschalte. Es wird nichts im modlog/log geschrieben, also meine lua funktionen werden an sich nicht ausgeführt
  -- crashed auch, wenn ich vorher kein anderes spiel starte, also kein lua jemals aktiv war, auch kein event..
   -- Kann also eigentlich nur an Triggern wie ticks liegen, aber warum crashed es nicht, wenn ich im Spiel bin (und savecache ist der einzie aktive tick,  crashed auch wenn ich lua datei umbenenne)
     -- wobei es auch mal schon nach 1min und mal auch erst nach 5 min crashed
 -- Wenn ich n MP Spiel alleine starte und lade, passiert das nicht.
-- evtl. nochmal mit neuem coop spiel testen, ob das dann auch passiert, oder ob das savegame einfach nur iwie kaputt ist.
-- Neues Coop Spiel crasht beim Laden bisher nicht..
-- ok doch , mittlerweile crasht das auch im ladebildschirm (auch wenn beide coops da sind. für client crashed es nicht!)
 -- hilfssession war unloaded
-- crashed auch ohne Ultimate Helpers mod (also das Laden. War natürlich vorher aktiv, kann also n Trigger sein..)
-- crashed auch ohne mods die es verursachen können und das leider komplett random
 -- kommt auch vor dass es garnicht crashed oder bis zu 10 min dauert...
 -- wobei es mit allen mods schon deutlich schneller crashed.. komisch..
  -- aber crashed auch komplett ohne mods
-- also ist irgendwie im savegame drin das problem... 
-- vllt nochmal n coop game ohne hilftssession und ohne das session template starten.
 -- und gucken ob das auch iwann crashed
  -- hab session events über event. erstmal wieder rausgenommen, auch so nochmal coop testen in neuem game
-- TODO ne passiert immernoch (ohne vanilla event. system und ohne ultra mod)
-- ÖHM ... auch ein neues MP Spiel alleine gestartet crashed im Ladebildschirm beim erstmaligen Starten!


-- #######################################
-- Wenn sonst alles fertig:

-- TODO:
 -- auch simple loop um OID zu finden evtl. so auslagern, dass es auch ohne Save/Cache verwendet werden kann?
  -- Damit Mods zumindest leichtere Loops wie AreaLoop oder GetCurrentSessionObjectsFromLocaleByProperty nutzen können,
   -- ohne das MP PopUp zu brauchen?
 -- ja kann man machen, aber hier dennoch mit Cache drinlassen

-- allgemein besser strukturieren und evlt in high/medium/low API unterteilen, 
 -- soll heißen deutlich machen welche Funktionen für die meisten Enduser gedacht sind, welche nur unter bestimmten Umständen und welche eher garnicht

-- auch ne txt datei zupacken in den ich einige infos teile wie zb.
 -- dass Unlock im coop besser als registerTrigger ist und welche lua befehle synced sind und welche nicht (soweit ich weiß)

-- #####################

-- Wichtige Infos:

-- Das Geld gutschreiben dauert bei den peers untersch. lang, bis es durchgeführt wurde.
 -- Dh. wenn ich allen Peers Geld gutschreibe und dann warten will, bis alle peers fertig damit sind,
  -- dann kanns sein, dass Peer0 nur 100ms braucht, peer1 aber 400ms, also kann ich als Peer0 nicht einfach nach 100ms weitermachen.
-- Um als Peer0 rauszufinden, ob Peer1 schon fertig ist, scheint es tatsächlich zu klappen ProfileCounter zu nutzen:
-- ts.Participants.GetParticipant(OtherOID).ProfileCounter.Stats.GetCounter(0,6,1010017,3)
-- (bei Geld-tests beachten, dass man ja auch ein Einkommen hat, also lieber mit etwas testen, was sich nur durch eigenen code ändert)
-- Sobald für Peer0 der ProfileCounter gesagt hat, dass Peer1 das Geld da ist, war es auch erstmalig für Peer1 ersichtlich.
-- -> auf diese Weise könnte man sicherstellen, dass alle Peers gleich lange warten bis etwas fertig ist (wenn das relevant ist, damit alle gleichzeitig etwas ausführen um zb desync zu vermeiden)

-- gute Habits lua:
-- einzigartige Pfade zu den lua skripten.
-- skript name darf keine großen buchstaben enthalten und evlt auch nicht zu lang sein, sonst gibts fehler dass skript nicht gefunden wurde
-- und einzigartige Namen von globalen Variablen

-- load your lua scripts with my shared mod OnGameLoaded. 
-- And use what I use in my scripts at the bottom:
-- g_LTL_Serp.start_thread("g_OnGameLeave_serp",ModID,function()
  -- while g_OnGameLeave_serp==nil do
    -- coroutine.yield()
  -- end
  -- if g_OnGameLeave_serp[ModID]==nil then
    -- g_OnGameLeave_serp[ModID] = function()
      -- g_ObjectFinderSerp = nil -- stop everything (might crash some currently running functions, but I think its ok)
      -- event.OnSessionEnter[ModID] = nil
      -- event.OnSessionLoaded[ModID] = nil
    -- end
  -- end
-- end)
-- g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
  -- g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
  -- g_LuaScriptBlockers[ModID] = nil
-- end)


-- system.start(function()...) threads und vermutlich auch sonstige Funktionen laufen nicht weiter, wenn der Spieler zurücl
 -- im Hauptmenü ist (oder pausiert). Aber sie laufen weiter sobald im Ladebildschirm/zurück im Spiel. Auch die alten Threads laufen weriter
  -- auch wenn das skript mit allen Funktionen neu gestartet wurde!!
  -- ACHTUNG: Menüs, wie zb das ingame Statistikmenü, machen threads probleme (SP und MP) wenn Gamespeed verlangsamt ist, auch bei 0.5.
   -- denn ein yield dauert plötzlich ~10-30 sec statt 100ms (auf höhrerem Gamespeed geht alles)
    -- Im Diplo Menü besteht das Problem nicht.
  -- lieber keine endlosen Threads machen, sondern wenn etwas alle x minuten gemacht werden soll, lieber mit Trigger
-- Und das heißt auch, dass man keine zu langen Wartezeiten in lua einbauen sollte, so maximal 5 sekunden.
 -- damit diese nicht in anderen savegames ausgeführt werden und sie werden ja auch nicht im savegame gespeichert
--  (bzw. mein OnGameLoaded Mod killt beim Wechsel zum Hauptmenü alle Threads, welche kein "NoStopGameLeft" im Namen haben)
-- Anstatt system.start() nutze lieber meine Funktion g_LTL_Serp.start_thread(threadname,ModID,fn,...). Denn diese hat 
 -- noch Fehler-Logging integriert, was extremst hilfreich beim coden/debuggen/testen ist, weil sonst threads einfach ohne irgendeine Fehlermeldung abbrechen

-- AreaID (und damit auch SessionID,IslandIndex,AreaIndex) bleiben nach Spiel Generierung/Session Load, dann immer dieselben, egal wem was gehört. 

local ModID = "shared_LuaTools_Medium_Serp objectfinder.lua" -- used for logging

if g_LuaScriptBlockers[ModID]==nil then
  
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    

    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end


    print("shared_LuaTools_Medium_Serp objectfinder.lua called")
    g_LTL_Serp.modlog("objectfinder.lua called",ModID)


    -- useful info:
    -- the GameObject variable you get by:
    -- GameObject = ts.Objects.GetObject(OID) or also GameObject = ts.GetGameObject(OID)
    -- is broken after one usage, eg. getting the GUID with GameObject.GUID
    -- If you then try to get other info on the same variable like GameObject.SessionGuid, you will always just get the value you got first, in this case objects GUID.
    -- So you have to renew the object everytime before using by doing again "GameObject = ..."
    -- Sometimes his problem is also there for "Area = ts.Area.GetAreaFromID(AreaID)", so better also only use it once...

    -- ts.Objects.GetObject(OID) is a little bit faster than ts.GetGameObject(OID), but ts.GetGameObject(OID) can also find OIDs from other sessions.
    -- since getObjectGroupByProperty can only find objects in current session (from the local player), there is no need to use GetGameObject there.

    -- There is no currently known way to get userdata representation of objects in other sessions than the current one: eg.: userdata = session.getObjectByID(OID) or userdata = session.getSelectedFactory() or session.getObjectGroupByProperty(PropertyID)
    -- You can save the userdata you fetched while in the session a tiny number of things will work in other sessions eg. getName(), getOID() works.
     -- But commands like userdata.moveTo or addDamagePercent and also isMoving and so on won't work while in another session (but works again as soon as you are in correct session).

    -- keine Ahnung was session.getObject() übergeben werden muss (wenn was ungültiges oder unvollständiges übergeben wurde, gibts nen fehler im lua log)
     -- scheint weder userdata noch Object noch number noch string noch noch bool leer zu akzeptieren (1 argument versucht)

    -- Ob man session. oder game.MetaGameManager. verwendet, scheint egal. beides kann nur auf Objekte in der aktuellen Session zugreifen

    -- Every time a ship changes the session, it gets a new increasing ObjectID. That is the major reason why on very big/old savegames the ObjectID may be in range of 100k or higher


    -- ###################################################################################################
    -- ###################################################################################################



    -- eg to share in lua with other humans: info what the human has unlocked (since in lua we can only check what we ourself have unlocked, but not what others have -.-)
    -- invalid signs in strings (to save it into nameable): " \ , [ ] and () if both used. and better do not use - because it might hurt gsub?
      
    -- WICHTIGE INFO zu Nameable:

    -- 1) Bei SetName("string") wird lokal für den ausführenden Spieler sofort dieser String als Name hinterlegt und kann
     -- auch sofort imselben Tick wieder mit GetName() zurückerhalten werden.
     -- Das ist besonders hilfreich, wenn wir dadrin zb. bei DoForSessionGameObject lokal andere Informationen drin speichern müssen
      -- dh. selbst wenn die Skripte quasi zeitgleich für jeden lokalen Spieler ausgeführt werden, bekommen sie mit GetName imselben Tick nur das zurück, was sie selbst reingeschrieben haben.
    -- 2) ts.GetGameObject(HelperOID).Nameable.SetName(infostring) für fremde sessions funktioniert im Singleplayer unabhängig von der Session.
    --  Aber wenn der ausführende Spieler in einer anderen Session als das Objekt ist, dann klappt es nur für ihn selbst! für andere Spieler im MP bleibt der alte Namen bestehen.
    --  Lösung: DoForSessionGameObject für die Namensänderung nehmen
     -- wenn ich DoForSessionGameObject für die Änderung des Namens verwende, dann klappt ts.GetGameObject(OID).Nameable.Name
      -- auch für jeden Spieler in jeder Session um diese Namensänderung auszulesen! :)
    -- 3) WICHTIG: wenn es darum geht Informationen über SetName mit anderen Spielern zu teilen, wie hier in den ShareLuaInfo Funktionen,
     -- dann muss man wissen, dass erst ~3-10 gameticks NACH SetName() dieser Name auch für andere Spieler über GetName bekommbar ist (zeit schwankt stark von PC Leistung und Spielfortschritt!)
      -- und da es lokal sofort hinterlegt ist, kann man dann auch nicht einfach ein while true coroutine.yield() machen und warten, weil das lokal gesetzte ja sofort da ist
      -- und einfach 10 yields zu machen dauert und ist nicht 100% sicher.
       -- (das ist dann ein problem, wenn alle Spieler exakt gleich lange warten müssen, damit desyncende-Commands gleichzeitig ausgeführt werden)
      -- Selbst im Singleplayer gibt es dieses "synchronisieren" nach SetName, wodurch das passiert: SetName(1), yield, SetName(2) Name==2 , yield, Name==1 yield,yield Name==2
    -- Das bedeudet, dass ShareLuaInfo mindestens 2-4 Sekunden pro Verwendung geblockt sein wird, um sicher zu gehen, dass Name ziwschen allen korrekt gesynced wurde.
     -- womit es nicht für die allgemeine Verwendung von Jedem genutzt werden kann, zumindest nicht mit derselben HelperOID.
     -- ich werde es hier also erstmal exklusiv für savestuff verwenden um lokale Infos zwischen den Spielern abzugleichen
      -- und dann eine Kombination aus allen Infos abzuspeichern

    -- CompanyName wird NICHT GESYNCED! Dh. Wenn ich lokal Peer0 SetCompanyName ausführe, dann kommt das garnicht bei Peer1 usw an.
    -- daher nur für DoForSessionGameObject return hilfreich, nicht zum speichern/teilen von infos. Dafür nehmen wir dann Nameable
     
    -- Was passiert wenn 2 humans zurselben Zeit SetName ausführen?
      -- Welches Ergebnis setzt sich nach der Synchronisation durch? Sind es lokal dann untersch. namen?
      -- Oder wird mit Glück vllt sogar der Host bevorzugt oderso und dadurch kann man die peers rausfinden?
    -- Test mit 2 Spielern: Der Client setzt sich am ende durch (vermutlich einfach weil sein umbenennungsbefehl langsamer ist und der letzte blebit halt erhalten)
     -- Jetzt müsste man das noch mit 3 peers testen, um zu sehen welcher der Clients sich durchsetzt. Ob es immer dieselbe PeerInt
      -- ist, oder einfach die langsamste Verbindung/schwächster PC...
    -- hilft eh nicht allein (zb ohne UI), da man ja nicht weiß wer inaktiv ist. Nur weil einer am langsamten ist,w weiß man nicht ob er peer 4 oder peer 3 ist (und peer 4 inaktiv)

     
     
     

    


    -- ###################################################################################################
    -- ###################################################################################################
    -- ###################################################################################################

    -- Find Objects functions

    
    -- updates Shared_Cache[ModID].ObIDs LowObID and HighObID for objects owned by local player in current session 
     -- This is just the current situation is active session. Especially HighObID increases every time a new object is built/sent between sessions.
     -- Als also LowObID can increase, eg. on island takeover (but for that we already do arealoop to get all Kontor_OID)
     -- So at best only call this yourself directly before calling GetAnyObjectsFromAnyone and provide HighObID as ToObjectID to make it more efficient
    -- use Walkable for everything with AreaIndex/IslandIndex=0 (ships/airships/units)
    -- use Building for everything tied to an Island
    -- ... An sich braucht man die Fkt eigentlich selten... denn wenn man einen Peer als Owner und in der Session hat,
        -- wovon man ein Objekt sucht, dann kann man gleich GetCurrentSessionObjectsFromLocaleByProperty nach einem passenden Property
         -- durchsuchen und findet das Objekt direkt, was man dann teilt.
      -- Performance ist aber gut, selbst in giga spielstand in größter Session dauert Building+Walking nur klitzekleinen Ruckler
    -- Wenns nicht um eigenes in eigener session geht, dann am besten SpawnMaxObjIdHelpers nutzen
    local function GetHighestObIDsLocalPlayerCurrentSessionByProperty(Property)
      local ret = g_ObjectFinderSerp.GetCurrentSessionObjectsFromLocaleByProperty(Property)
      for OID,objinfo in pairs(ret) do
        local OIDtable = g_LTL_Serp.OIDToOIDtable(OID)
        local ObjectID = OIDtable.ObjectID
        local AreaID = g_LTL_Serp.AreatableToAreaID(OIDtable.AreaID)
        local SessionID = OIDtable.AreaID.SessionID
        -- local IslandID = OIDtable.AreaID.IslandID
        -- local AreaIndex = OIDtable.AreaID.AreaIndex 
        if g_LTM_Serp.Shared_Cache[ModID].ObIDs[SessionID]==nil then
          g_LTM_Serp.Shared_Cache[ModID].ObIDs[SessionID] = {}
        end
        local CacheObIDsSessionID = g_LTM_Serp.Shared_Cache[ModID].ObIDs[SessionID]
        if CacheObIDsSessionID[AreaID]==nil then
          CacheObIDsSessionID[AreaID] = {valid=true}
        end
        if ObjectID~=nil then
          if (CacheObIDsSessionID[AreaID].LowObID==nil or ObjectID < CacheObIDsSessionID[AreaID].LowObID) then  
            CacheObIDsSessionID[AreaID].LowObID = ObjectID
          end
          if (CacheObIDsSessionID[AreaID].HighObID==nil or ObjectID > CacheObIDsSessionID[AreaID].HighObID) then  
            CacheObIDsSessionID[AreaID].HighObID = ObjectID
          end
        end
      end
      -- reset HighObID after 10 seconds, because it gets outdated fast
      g_LTL_Serp.start_thread("reset HighObID",ModID,function()
        g_LTL_Serp.waitForTimeDelta(10000)
        for areaid,info in pairs(CacheObIDsSessionID) do
          info.HighObID = nil
        end
      end)
    end
    
    -- GetCurrentSessionObjectsFromLocaleByProperty
    -- lightweight and quite fast function, but can only fetch objects from the local executing player in the session he is currently in.

    -- see here for a list of PropertyID : https://github.com/anno-mods/modding-guide/blob/main/Scripting/ENUMs.md#propertyids
    -- or see properties-toolone.xml order of properties listed.
    -- or use a string as property, the function will convert it for you
    -- It only finds buildings on your own islands! (eg if buildings are spawned via trigger at unowned/foreign islands, they wont be found with this nor with ConditionPlayerCounter)
        -- (ProfileCounter can find buildings on foreign islands)
    local function GetCurrentSessionObjectsFromLocaleByProperty(Property,...)
      return g_LTL_Serp.GetCurrentSessionObjectsFromLocaleByProperty(Property,...)
    end

    -- ###################################################################################################
    -- ###################################################################################################

    -- this function searches for the Neutral (GUID 34)SessionParticipant GameObject in the given SessionID, to find out if the session is already loaded and valid and check what SessionGuid it is
    -- (we use Neutral instead of local player, because neutral is created first and also exists in loaded sessions the player was not yet into, while locale SessionParticipant does not exist in this case yet)
     -- dontusecache ist eig nur sinnvoll, wenn wir davon ausgehen, dass jemand eine Session unloaded, was wohl eher nie passiert
    local function IsLoadedSessionByID(SessionID,dontusecache)
      if not dontusecache then
        if g_LTM_Serp.Shared_Cache[ModID].LoadedSessions[SessionID]~=nil then
          return g_LTM_Serp.Shared_Cache[ModID].LoadedSessions[SessionID]
        elseif g_LTM_Serp.Shared_Cache[ModID].LoadedSessionsParticipants[SessionID]~=nil and g_LTM_Serp.Shared_Cache[ModID].LoadedSessionsParticipants[SessionID][g_ObjectFinderSerp.PID_Neutral]~=nil then
          return g_LTM_Serp.Shared_Cache[ModID].LoadedSessionsParticipants[SessionID][g_ObjectFinderSerp.PID_Neutral].SessionGuid
        end
      end
      local IslandID,AreaIndex = 0,0
      local SessionGuid
      local AreaID = g_LTL_Serp.AreatableToAreaID({SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex})
      for ObjectID=1,10 do -- to find  Neutral SessionParticipant checking the first 10 ObjectIDs should be enough
        OID = g_LTL_Serp.OIDtableToOID({ObjectID=ObjectID,AreaID=AreaID,EditorFlag=0,EditorChunkID=0})
        -- g_LTL_Serp.modlog("IsLoadedSessionByID before GetGameObject ObjectID "..ObjectID,ModID)
        local GUID = ts.GetGameObject(OID).GUID
        -- g_LTL_Serp.modlog("IsLoadedSessionByID after GetGameObject ObjectID "..ObjectID,ModID)
        local sGUID = ts.Participants.GetParticipant(g_ObjectFinderSerp.PID_Neutral).Guid -- Meta and SessionParticipant have the same GUID. using Meta here because they always exist, while Session may only exist in a specific one (although we only use P who exist everywhere)
        -- if SessionID==6 and GUID~=0 then
          -- print(GUID)
        -- end
        if GUID==sGUID then
          SessionGuid = ts.GetGameObject(OID).SessionGuid
          if SessionGuid~=1500005538 then -- is my empty fake session. worldmap 180039 has not Neutral participant I think
            if g_LTM_Serp.Shared_Cache[ModID].LoadedSessionsParticipants[SessionID]==nil then
              g_LTM_Serp.Shared_Cache[ModID].LoadedSessionsParticipants[SessionID] = {}
            end
            g_LTM_Serp.Shared_Cache[ModID].LoadedSessionsParticipants[SessionID][g_ObjectFinderSerp.PID_Neutral] = {OID=OID,PID=g_ObjectFinderSerp.PID_Neutral,GUID=GUID,SessionGuid=SessionGuid,ObjectID=ObjectID,AreaID=AreaID,SessionID=SessionID}
            if g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs[SessionID]==nil then
              g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs[SessionID] = {}
            end
            g_LTM_Serp.Shared_Cache[ModID].LoadedSessions[SessionID] = SessionGuid
            return SessionGuid
          end
        end
      end
    end
    
    -- using cache (we only could get it new from the current active session while the cache is updated on IslandSettled and SessionEnter, so it is up to date for the current session)
    local function GetAnyValidKontorOIDFrom(PID)
      for SessionID,info in pairs(g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs) do
        for AreaID,Kontorinfo in pairs(info) do
          local GUID = g_LTL_Serp.GetGameObjectPath(Kontorinfo.Kontor_OID,"GUID") -- check it again, instead of using cache, just to be sure it did not change meanwhile
          if GUID~=0 and GUID~=nil then
            local Owner = g_LTL_Serp.GetGameObjectPath(Kontorinfo.Kontor_OID,"Owner") -- check it again, instead of using cache, just to be sure it did not change meanwhile
            if Owner==PID then
              return Kontorinfo.Kontor_OID
            end
          end
        end
      end
      return nil
    end
    
    
    -- could also use instead game.isSessionLoadingDone(CheckingSessionGuid) ? But we would need a complete list of all ever exsiting session guids, which we dont have.
    local function GetLoadedSessions(FromSessionID,ToSessionID,dontusecache)
      local Sessions = {}
      FromSessionID = FromSessionID or 1
      ToSessionID = ToSessionID or g_ObjectFinderSerp.l_MaxSessionID
      for SessionID=FromSessionID,ToSessionID do
        CheckingSessionGuid = (not dontusecache and g_LTM_Serp.Shared_Cache[ModID].LoadedSessions[SessionID]) or g_ObjectFinderSerp.IsLoadedSessionByID(SessionID,dontusecache)
        if CheckingSessionGuid~=nil then
          Sessions[SessionID] = CheckingSessionGuid
          g_LTM_Serp.Shared_Cache[ModID].LoadedSessions[SessionID] = CheckingSessionGuid
        end
      end
      return Sessions  -- eg {[SessionID] = SessionGUID}
    end


    -- not useful other than for testing
    local function GetFirst100LoadedSessionsGameObjects(sSessionGuid,sSessionID)
      local FromSessionID = sSessionID or 1
      local ToSessionID = sSessionID or g_ObjectFinderSerp.l_MaxSessionID
      local session100gameobjects = {}
      for SessionID=FromSessionID,ToSessionID do
        local SessionGuid = g_ObjectFinderSerp.IsLoadedSessionByID(SessionID)
        if SessionGuid~=nil and (sSessionGuid==nil or sSessionGuid=="First" or sSessionGuid==SessionGuid) then
          session100gameobjects[SessionID] = {}
          local IslandID,AreaIndex = 0,0
          local AreaID = g_LTL_Serp.AreatableToAreaID({SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex})
          for ObjectID=1,100 do
            OID = g_LTL_Serp.OIDtableToOID({ObjectID=ObjectID,AreaID=AreaID,EditorFlag=0,EditorChunkID=0})
            local GUID = ts.GetGameObject(OID).GUID
            if GUID~=0 then
              local PID = ts.GetGameObject(OID).Owner
              session100gameobjects[SessionID][OID] = {OID=OID,PID=PID,GUID=GUID,SessionGuid=SessionGuid,ObjectID=ObjectID,AreaID=AreaID,SessionID=SessionID}
            end
          end
          if sSessionGuid=="First" then -- only the first found loaded session needed?
            return session100gameobjects
          end
        end
      end
      return session100gameobjects
    end

    -- TODO WICHTIG:
      -- Aus irgendeinem Grund findet das hier die 2nd AIs nicht, auch wenn sie bereits in der Session sind.
       -- nur alte Welt geht, neue welt nicht.
      -- testen woran das liegt, ob evlt ID Converter falsch sind?
      -- Oder können wir 2nd participants so garnicht finden?
       -- (wird in IsThirdPartyTrader genutzt)

    -- eg. sGUID=34 -> Neutral
    -- SessionParticipants alawys gets the instance in the current session from the local player
    -- so to check/change the Nameable from the SParticipants in the current active session we can always use this.
     -- But if we want also to access the ones in the other sessions, we need their OID (and then use GetGameObject to access Name and DoForSessionGameObject to change name)
    -- Give this function a list of PIDs and it will find all seperate GameObjects in each loaded session (SessionParticipants). SessionGuid can be nil to get all loaded sessions
    -- sSessionGuid and sSessionID are optional. sSessionGuid can also be "First", which returns it for the first found Session
    local function GetAllLoadedSessionsParticipants(PIDs,sSessionGuid,sSessionID)
      -- g_LTL_Serp.modlog("GetAllLoadedSessionsParticipants called",ModID) -- testing if it loads in savegame correctly
      local PIDs_GUIDs = {}
      for i,PID in ipairs(PIDs) do
        PIDs_GUIDs[PID] = ts.Participants.GetParticipant(PID).Guid -- Meta and SessionParticipant have the same GUID. using Meta here because they always exist, while Session may only exist in a specific one (although we only use P who exist everywhere)
      end
      
      local FromSessionID = sSessionID or 1
      local ToSessionID = sSessionID or g_ObjectFinderSerp.l_MaxSessionID
      local sessionparticipants = {}
      local update_done = false
      -- g_LTL_Serp.modlog("GetAllLoadedSessionsParticipants befire IsLoadedSessionByID",ModID)
      for SessionID=FromSessionID,ToSessionID do
        local SessionGuid = g_ObjectFinderSerp.IsLoadedSessionByID(SessionID)
        if SessionGuid~=nil and (sSessionGuid==nil or sSessionGuid=="First" or sSessionGuid==SessionGuid) then
          sessionparticipants[SessionID] = {}
          
          -- g_LTL_Serp.modlog("GetAllLoadedSessionsParticipants before dothesearch?",ModID) -- testing if it loads in savegame correctly

          local dothesearch = false -- check if we already have it in cache (SessionParticipants do not change ever (except for newly loaded sessions))
          if g_LTM_Serp.Shared_Cache[ModID].LoadedSessionsParticipants[SessionID]==nil then
            g_LTM_Serp.Shared_Cache[ModID].LoadedSessionsParticipants[SessionID] = {}
            g_LTM_Serp.Shared_Cache[ModID].Changed = true
            dothesearch = true
          else -- already have it in cache?
            for i,PID in ipairs(PIDs) do
              if g_LTM_Serp.Shared_Cache[ModID].LoadedSessionsParticipants[SessionID][PID]==nil then
                dothesearch = true  -- at least one is missing. and we need to loop over all objects anyway to find it, so fine to do all others again too
              end
            end
          end
          -- g_LTL_Serp.modlog("GetAllLoadedSessionsParticipants after dothesearch?",ModID) -- testing if it loads in savegame correctly
          if dothesearch then
            -- g_LTL_Serp.modlog("GetAllLoadedSessionsParticipants NOT used Cache :(",ModID) -- testing if it loads in savegame correctly
            update_done = true
            local IslandID,AreaIndex = 0,0
            local AreaID = g_LTL_Serp.AreatableToAreaID({SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex})
            for ObjectID=1,100 do
              OID = g_LTL_Serp.OIDtableToOID({ObjectID=ObjectID,AreaID=AreaID,EditorFlag=0,EditorChunkID=0})
              local GUID = ts.GetGameObject(OID).GUID
              if GUID~=0 and g_LTL_Serp.table_contains_value(PIDs_GUIDs,GUID) then
                local PID = ts.GetGameObject(OID).Owner -- will be the original PID in PIDs
                sessionparticipants[SessionID][PID] = {OID=OID,PID=PID,GUID=GUID,SessionGuid=SessionGuid,ObjectID=ObjectID,AreaID=AreaID,SessionID=SessionID}
                g_LTM_Serp.Shared_Cache[ModID].LoadedSessionsParticipants[SessionID][PID] = {OID=OID,PID=PID,GUID=GUID,SessionGuid=SessionGuid,ObjectID=ObjectID,AreaID=AreaID,SessionID=SessionID}
                g_LTM_Serp.Shared_Cache[ModID].Changed = true
              end
            end
          else -- use cache
            -- g_LTL_Serp.modlog("GetAllLoadedSessionsParticipants used Cache :)",ModID) -- testing if it loads in savegame correctly
            sessionparticipants[SessionID] = g_LTL_Serp.deepcopy(g_LTM_Serp.Shared_Cache[ModID].LoadedSessionsParticipants[SessionID])
          end
          if sSessionGuid=="First" then -- only the first found loaded session needed?
            return sessionparticipants
          end
        end
      end
      return sessionparticipants
    end




    -- ###################################################################################################
    -- ###################################################################################################

    -- special function to retrive information/execute commands from GameObjects in other sessions than the current.
    -- ts.GetGameObject(OID) also works for many things with objects in other sessions, but unfortunately not all of them.
    -- So first test if this is working for the thing you want to do. If not then you can use the following workaround.

    -- info:
    -- textsourcelist.json shows that there is a ts.MetaObjects.SessionGameObject(OID) command to retrive GameObjects from other sessions.
     -- But for whatever reason this is not available in lua directly -.-
     -- As far as I know it can only be used in "text embeds" also used in infotips.
       -- See here https://github.com/anno-mods/modding-guide/blob/main/Scripting/textembeds.md 
       -- and here https://github.com/anno-mods/modding-guide/blob/main/documentation/infotips.md for more information.
     -- Eg instead of using 
     -- ts.MetaObjects.SessionGameObject(OID).ItemContainer.CheatItemInSlot(193195,1)
     -- we need to convert this to a text-embed string first:
     -- "[MetaObjects SessionGameObject("..tostring(OID)..") ItemContainer CheatItemInSlot(193195,1)]"
     -- (note that lua often needs "Set" and "Get" in front of the commands, while textembeds mostly don't (they use the exact wording you find in textsourcelist))
     -- To call this in lua we can use the function game.TextSourceManager.setDebugTextSource(String).
      -- So in total: game.TextSourceManager.setDebugTextSource("[MetaObjects SessionGameObject("..tostring(OID)..") ItemContainer CheatItemInSlot(193195,1)]")
      -- Unfortunately this setDebugTextSource function does not return the result of the text-embed ...
       -- to still get return values I only found the workaround to have an invisible Nameable-helper-object ingame,
        -- from which we will change the name to the result of this string within the textembed. 
         -- This way we can retrieve everything that can be saved as a string in a Name.
         



    -- GetAnyObjectsFromAnyone
    -- this finds also objects from other players  also from other sessions.

    -- LIMITATIONS:
    -- BUT: objects of other sessions (where the executing player is not in currently), only work in a limited way!
    -- eg. you can no get the userdata and some ts commands also don't work (Name/SetName works, but CheatItemInSlot does not, you have to test what works and what not)
     -- if you saved userdata on a previous visit of the player in that session, it can also be used in very limited way from within other sessions. But most likely only getName() and getOID() works, not more..
    -- And eg. ts.Area.GetAreaFromID(AreaID).CityName will NOT WORK for other session than the current one!
      -- (also ts.GetGameObject(OID).Area does not work for objects from other sessions)
      -- this also means my function is far more inefficient in other sessions than the currently active one (since it can not properly check for invalid Areas and KontorObjectID)
     -- if you want to check Area Stuff on Sessions that are not the current one, use function "DoForSessionGameObject" on a found valid OID: "[MetaObjects SessionGameObject("..tostring(OID)..") Area CityName]"

    -- Does not work for objects with EditorFlag, which are mostly objects at the map from beginning, like Pirate/Archibald harbor/objects. (because their OID is higher than lua can handle eg archibald harbor 9223413826886612345)

    -- BEWARE: using too high ToObjectID, this can take VERY LONG, like hours. By default I will use ToObjectID = 100.000, this only takes few seconds, but may not be enough on very big/old savegames
      -- So reduce the search-work by using the ObjectFilter and return in a table "done=true" (called "filterresult" here), as soon as you found the object you are searching for (to stop the search-loop)
      -- Or change FromObjectID/ToObjectID to match the expected currently used ObjectIDs-range. Eg. spawn a new object for local player and get his ObjectID somehow (eg with GetCurrentSessionObjectsFromLocaleByProperty) to find out the current highest ObjectID used (within the spawned AreaID!) 
    -- see "my_ObjectFilter" below for examples how to use it
    -- set withyield to true and start the function within a coroutine to yield on every new areaand every 10k objects, to prevent game-blocking on big searches (search takes longer then, but does not block. so use this if time does not matter much)
    
    
    
    -- use "SpawnMaxObjIdHelpers" first before callig this, for maximum efficiency
    -- To limit it to only the current Session, use a SessionFilter function that returns false if the SessionGUID is not the current one
    -- scroll down for "EXAMPLE ObjectFilter"
    local function GetAnyObjectsFromAnyone(myargs)
      g_LTL_Serp.modlog("Start GetAnyObjectsFromAnyone",ModID)
      local ObjectFilter,SessionFilter,FromSessionID,ToSessionID,FromIslandID,ToIslandID,FromAreaIndex,ToAreaIndex,FromObjectID,ToObjectID,withyield,waitforhelper = myargs["ObjectFilter"],myargs["SessionFilter"],myargs["FromSessionID"],myargs["ToSessionID"],myargs["FromIslandID"],myargs["ToIslandID"],myargs["FromAreaIndex"],myargs["ToAreaIndex"],myargs["FromObjectID"],myargs["ToObjectID"],myargs["withyield"],myargs["waitforhelper"]
      local Objects = {}
      local ExecutingSessionGUID = session:getSessionGUID()
      local filterresult
      FromSessionID = FromSessionID or 1
      ToSessionID = ToSessionID or g_ObjectFinderSerp.l_MaxSessionID
      FromIslandID = FromIslandID or 0 -- is 0 for eg. ships and other things not bound to islands
      ToIslandID = ToIslandID or g_ObjectFinderSerp.l_MaxIslandID
      FromAreaIndex = FromAreaIndex or 0 -- is 0 for eg. ships and other things not bound to islands
      ToAreaIndex = ToAreaIndex or 1 -- can be 2 for islands sharing two owners , like ketema island. but unlikely that we need it, so default to only 1
      local FromObjectID_ = FromObjectID or 1 -- removed objects/ships leaving session leave empty OBjectIDs, so sometimes, especially on takeover of islands, the first valid ObjectID might be in the tenthousands.
      local ToObjectID_ = ToObjectID or 1000000 -- on very big/old savegames you should check up to 1 million or even more ... better try to save/check your current lowest/highest OID and enter lower number here
      for SessionID=FromSessionID,ToSessionID do
        -- g_LTL_Serp.modlog("GetAnyObjectsFromAnyone vor IsLoadedSessionByID SessionID "..SessionID,ModID)
        local CheckingSessionGuid = g_ObjectFinderSerp.IsLoadedSessionByID(SessionID)
        if CheckingSessionGuid~=nil then
          -- g_LTL_Serp.modlog("GetAnyObjectsFromAnyone nach IsLoadedSessionByID CheckingSessionGuid "..CheckingSessionGuid,ModID)
          local session_ok = true
          if SessionFilter~=nil and type(SessionFilter)=="function" then
            session_ok = SessionFilter(SessionID,CheckingSessionGuid) 
          end
          -- g_LTL_Serp.modlog("GetAnyObjectsFromAnyone nach SessionFilter SessionID "..SessionID.." session_ok: "..tostring(session_ok),ModID)
          if session_ok then
            local SessionIsCurrent = ExecutingSessionGUID == CheckingSessionGuid
            if g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs[SessionID]==nil then
              g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs[SessionID] = {}
            end
            if g_LTM_Serp.Shared_Cache[ModID].ObIDs[SessionID]== nil then
              g_LTM_Serp.Shared_Cache[ModID].ObIDs[SessionID] = {}
              g_LTM_Serp.Shared_Cache[ModID].Changed = true
            end
            for IslandID=FromIslandID,ToIslandID do
              for AreaIndex=FromAreaIndex,ToAreaIndex do
                if not ((IslandID==0 and AreaIndex~=0) or (IslandID~=0 and AreaIndex==0)) then -- on water both are 0. on islands none of them is 0, so do not allow only one of them being 0.
                  local IsIsland = IslandID~=0 -- opposite is open water (ships/walkables (also on land))
                  local AreaID = g_LTL_Serp.AreatableToAreaID({SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex})
                  local CacheObIDsSessionID = g_LTM_Serp.Shared_Cache[ModID].ObIDs[SessionID] -- I think its better for performance to save it in a variable
                  if CacheObIDsSessionID[AreaID]== nil then
                    CacheObIDsSessionID[AreaID] = {}
                  end
                  if not CacheObIDsSessionID[AreaID]["invalid"] then
                    local AreaOwnerName,AreaOwner,Kontor_OIDtable,Kontor_OID
                    if IsIsland then
                      if not SessionIsCurrent then -- we can not check Area in other sessions, except we know any building OID on the Area already
                        if g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs[SessionID]~=nil and g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs[SessionID][AreaID]~=nil then
                          AreaOwner = g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs[SessionID][AreaID].AreaOwner
                          AreaOwnerName = g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs[SessionID][AreaID].AreaOwnerName
                          Kontor_OIDtable = g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs[SessionID][AreaID].Kontor_OIDtable
                          Kontor_OID = g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs[SessionID][AreaID].Kontor_OID
                        end
                      else
                        AreaOwnerName = ts.Area.GetAreaFromID(AreaID).OwnerName -- check if the Area is valid
                        AreaOwner = ts.Area.GetAreaFromID(AreaID).Owner -- for unsettled area owner will be -1
                      end
                      if AreaOwner==nil or AreaOwnerName==nil then
                        break -- then we can not check this Area, so skip it (we are unable to check if empty/invalid or owned. So it would mean searching long time invalid IDs)
                      end
                      if (AreaOwnerName=="" and AreaOwner==0) then -- invalid area. while for unsettled area owner will be -1. (OwnerName is better than Owner here, because invalid areas are nullpointer and would return 0 for Owner, which also might be Human0 on valid areas)
                        CacheObIDsSessionID[AreaID]["invalid"] = true -- remember this Area as invalid, so we don't have to check it ever again.
                        g_LTM_Serp.Shared_Cache[ModID].Changed = true
                      end
                    end
                    -- g_LTL_Serp.modlog("GetAnyObjectsFromAnyone nach AreaOwnerName SessionID "..SessionID.." AreaID: "..tostring(AreaID).." AreaOwnerName: "..tostring(AreaOwnerName),ModID)
                    if not CacheObIDsSessionID[AreaID]["invalid"] then
                      if withyield then
                        coroutine.yield()
                      end
                      if not IsIsland or AreaOwnerName~="" then -- Water or Island with Owner?
                        -- g_LTL_Serp.modlog("GetAnyObjectsFromAnyone valid Area, vor DoesMaxObjIdHelperExists SessionID "..SessionID.." AreaID: "..tostring(AreaID).." AreaOwnerName: "..tostring(AreaOwnerName),ModID)
                        local MaxObjIdHelperExists = g_ObjectFinderSerp.DoesMaxObjIdHelperExists(AreaID,AreaOwner)
                        -- g_LTL_Serp.modlog("GetAnyObjectsFromAnyone valid Area, nach DoesMaxObjIdHelperExists SessionID "..SessionID.." AreaID: "..tostring(AreaID).." AreaOwnerName: "..tostring(AreaOwnerName),ModID)
                        while waitforhelper and not MaxObjIdHelperExists do
                          coroutine.yield()
                          MaxObjIdHelperExists = g_ObjectFinderSerp.DoesMaxObjIdHelperExists(AreaID,AreaOwner)
                        end
                        if SessionIsCurrent then
                          if IsIsland then
                          
                            Kontor_OIDtable = ts.Area.GetAreaFromID(AreaID).KontorID
                            Kontor_OID = g_LTL_Serp.OIDtableToOID(Kontor_OIDtable)
                            -- filling it like this makes sure that outdated information is automatically overwritten
                            g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs[SessionID][AreaID] = {Kontor_OID=Kontor_OID,Kontor_OIDtable=Kontor_OIDtable,AreaOwner=AreaOwner,AreaOwnerName=AreaOwnerName}
                            
                            -- debugging, check if our converter is correct
                            local t_userdata = SessionIsCurrent and session.getObjectByID(Kontor_OID) or nil
                            t_userdata = g_LTL_Serp.IsUserdataValid(t_userdata)
                            if t_userdata~=nil then
                              local u_OID = g_LTL_Serp.get_OID(t_userdata,"string")
                              if tostring(u_OID) ~= tostring(Kontor_OID) then
                                g_LTL_Serp.modlog("ERROR WARNING GetAnyObjectsFromAnyone Kontor_OID "..tostring(Kontor_OID).." is unequal u_OID "..tostring(u_OID).." ?! Guess ID Converter is wrong?",ModID)
                              end
                            end
                            
                            if Kontor_OIDtable["ObjectID"]~=nil and Kontor_OIDtable["ObjectID"]~=0 then -- assuming the KontorObjectID is always the lowest on an island, it makes sense to set LowObID to this value. If we assume that there may be exceptions to this, then we can not use it at all...
                              if CacheObIDsSessionID[AreaID].LowObID~=nil and Kontor_OIDtable["ObjectID"]~=CacheObIDsSessionID[AreaID].LowObID then
                                g_LTL_Serp.modlog("WARNING GetAnyObjectsFromAnyone KontorObjectID "..tostring(Kontor_OIDtable["ObjectID"]).." is unequal LowObID "..tostring(CacheObIDsSessionID[AreaID].LowObID).." ?! (may only happen on island takeover?)",ModID)
                              end
                              CacheObIDsSessionID[AreaID].LowObID = Kontor_OIDtable["ObjectID"] -- Kontor should be the first building on every owned island, so it is enough to start there with counting
                            end
                          end
                        end
                        
                        FromObjectID_ = FromObjectID or 1 -- we changed it below based on Cache potentially for the previous Area. so change it to default here again.
                        ToObjectID_ = ToObjectID or MaxObjIdHelperExists and 100000000 or 1000000 -- do until we find the helper object
                        
                        if FromObjectID==nil and CacheObIDsSessionID[AreaID].LowObID~=nil then
                          FromObjectID_ = CacheObIDsSessionID[AreaID].LowObID
                        end
                        if not MaxObjIdHelperExists and ToObjectID==nil and CacheObIDsSessionID[AreaID].HighObID~=nil then
                          ToObjectID_ = CacheObIDsSessionID[AreaID].HighObID
                        end -- HighObID is set via GetHighestObIDsLocalPlayerCurrentSessionByProperty and gets resetted to nil after 10 seconds time, because it is outdated quite quickly 
                        -- g_LTL_Serp.modlog("GetAnyObjectsFromAnyone vor Objects Loop SessionID "..SessionID.." AreaID: "..tostring(AreaID).." AreaOwnerName: "..tostring(AreaOwnerName),ModID)
                        local objectcount = 0
                        local LowestObjectID = nil
                        for ObjectID=FromObjectID_,ToObjectID_ do
                          filterresult = nil
                          local OID = g_LTL_Serp.OIDtableToOID({ObjectID=ObjectID,AreaID=AreaID,EditorFlag=0,EditorChunkID=0})
                          if withyield then
                            objectcount = objectcount + 1
                            if objectcount % 10000 == 0 then
                              coroutine.yield()
                            end
                          end
                          local GUID = g_LTL_Serp.GetGameObjectPath(OID,"GUID")
                          -- if type(OID)=="number" then
                            -- GUID = ts.GetGameObject(OID).GUID -- using GetGameObject to also fetch objects from other sessions. if it does not exist, it will be nullpointer
                          -- else -- string
                            -- GUID = g_LTL_Serp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(OID)..") GUID]",true)
                          -- end
                          if GUID~=0 and GUID~=nil then -- GUID==0 means nullpointer, does not have an object
                            local SessionGuid = CheckingSessionGuid
                            -- local ParticipantID = type(OID)=="number" and ts.GetGameObject(OID).Owner or g_LTL_Serp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(OID)..") Owner]",true)
                            local ParticipantID = g_LTL_Serp.GetGameObjectPath(OID,"Owner")
                            local userdata = SessionIsCurrent and session.getObjectByID(OID) or nil -- no way to get userdata in foreign session... But you can use t_ExecuteFnWithArgsForPeers for a peer who is in that session and give him the OID to do what you want on that userdata (most operations on userdata desync though if not all peers do it at the same time)
                            userdata = g_LTL_Serp.IsUserdataValid(userdata)
                            if LowestObjectID==nil then -- we increase, so the first is the lowest
                              LowestObjectID = ObjectID
                            end
                            if type(ObjectFilter)=="function" then
                              filterresult = ObjectFilter(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID,AreaOwner,Kontor_OID)
                            end
                            if filterresult~=nil and type(filterresult)=="table" and filterresult["addthis"] then
                              Objects[OID] = {GUID=GUID,ParticipantID=ParticipantID,userdata=userdata,SessionGuid=SessionGuid,SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex,ObjectID=ObjectID,AreaOwner=AreaOwner,Kontor_OID=Kontor_OID}
                            end
                            if (not IsIsland and GUID == g_ObjectFinderSerp.MaxObjIdWalkableHelper.Guid) or (IsIsland and GUID == g_ObjectFinderSerp.MaxObjIdAreaHelper.Guid) then
                              break -- reached the max ObjectID for this IslandID (if island/session is settled) (they only exist for 10 / 30 seconds after we made them spawn with unlock 1500005552 / 1500005549 )
                            end
                            if filterresult~=nil and type(filterresult)=="table" and (filterresult["next_AreaID"] or filterresult["done"]) then
                              break
                            end
                          -- still happening, as long as we dont add EditorFlag/EditorChunkID to the loop
                           -- but its ok, we dont need them. TODO: mal separat in testscript durch die AreaID einer 3rd party
                            -- ich denke EditorChunkID maximaler Wert ist 256, denn ab dann wiederholt sich die OID die mit sonst selben Daten generiert wird
                          elseif Kontor_OIDtable~=nil and Kontor_OIDtable["ObjectID"]==ObjectID then -- if it claims to have a kontor, but its GUID is 0, then just skip this area
                            -- g_LTL_Serp.modlog("GetAnyObjectsFromAnyone Skipping Area, its preplaced Kontor (ThridParty) SessionID "..SessionID.." AreaID: "..tostring(AreaID).." AreaOwnerName: "..tostring(AreaOwnerName),ModID)
                            CacheObIDsSessionID[AreaID]["invalid"] = "EditorObject" -- remember this Area as invalid, so we don't have to check it ever again.
                            break -- this happens for Editor Objects, eg. Kontor from third parties. They have in fact OID 9223413826886612345 and EditorFlag=1 which makes the number much higher. But lua can not handle this high number (bint?) anyways, trying to get GUID from 9223413826886612345 just results in an error.  -- so no suport for Editor Objects.
                          end
                        end
                        -- g_LTL_Serp.modlog("GetAnyObjectsFromAnyone nach Objects Loop SessionID "..SessionID.." AreaID: "..tostring(AreaID).." AreaOwnerName: "..tostring(AreaOwnerName),ModID)
                        if LowestObjectID~=nil and (CacheObIDsSessionID[AreaID].LowObID==nil or LowestObjectID > CacheObIDsSessionID[AreaID].LowObID) then -- checking > here is correct, because the obj only can get bigger, never lower, eg. when taking over an island
                          CacheObIDsSessionID[AreaID].LowObID = LowestObjectID
                        end
                        if filterresult~=nil and type(filterresult)=="table" and (filterresult["next_SessionID"] or filterresult["done"]) then
                          break
                        end
                      elseif IsIsland and AreaOwner==-1 then -- valid but not owned by someone (anymore?)
                        g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs[SessionID][AreaID] = nil -- set it to nil to potentially update it
                      end
                    end
                  end
                end
              end
              if filterresult~=nil and type(filterresult)=="table" and (filterresult["next_SessionID"] or filterresult["done"]) then
                break
              end
            end
          end
        end
        if filterresult~=nil and type(filterresult)=="table" and (filterresult["next_SessionID"] or filterresult["done"]) then
          break
        end
      end
      g_LTL_Serp.modlog("Ende GetAnyObjectsFromAnyone",ModID)
      return Objects
    end


    
    -- kind="Area" for Area helper. anything else for Walkable Helper
    local function SpawnMaxObjIdHelpers(kind)
      local unlockguid = kind=="Area" and g_ObjectFinderSerp.MaxObjIdAreaHelper.Unlock or g_ObjectFinderSerp.MaxObjIdWalkableHelper.Unlock
      if ts.Unlock.GetIsUnlocked(unlockguid) then
        ts.Unlock.SetRelockNet(unlockguid)
        return true
      end
      return false -- if already locked, wait few seconds 10/30 to try again
    end
    
    -- Area/Building IslandID~=0 or Walkable IslandID==0)
    -- does check if on the Area / in the session the MaxObjIdAreaHelper.Guid/MaxObjIdWalkableHelper.Guid exists. 
     -- AreaOwner nil for Walkable (IslandID=0)
    local function DoesMaxObjIdHelperExists(AreaID,AreaOwner,MaxObjIdWalkableHelperGuid,MaxObjIdAreaHelperGuid)
      MaxObjIdWalkableHelperGuid = MaxObjIdWalkableHelperGuid or g_ObjectFinderSerp.MaxObjIdWalkableHelper.Guid
      MaxObjIdAreaHelperGuid = MaxObjIdAreaHelperGuid or g_ObjectFinderSerp.MaxObjIdAreaHelper.Guid
      local Areatable = g_LTL_Serp.AreaIDToAreatable(AreaID)
      local SessionID = Areatable.SessionID
      local IslandID = Areatable.IslandID
      local PIDs = AreaOwner~=nil and IslandID~=0 and {AreaOwner} or {0,1,2,3} -- for an island, only the owner matters. For water the owner does not matter, so check every player
      local CounterScope = IslandID==0 and 1 or 0 -- 1 is Session, 0 is Area
      local ScopeContext = IslandID==0 and g_ObjectFinderSerp.IsLoadedSessionByID(SessionID) or AreaID -- SessionGuid or AreaID
      local helperGUID = IslandID==0 and MaxObjIdWalkableHelperGuid or MaxObjIdAreaHelperGuid
      local found = false
      for _,PID in pairs(PIDs) do
        local count = ts.Participants.GetParticipant(PID).ProfileCounter.Stats.GetCounter(0,0,helperGUID,CounterScope,ScopeContext)
        if count > 0 then -- one per island/per session
          found = true
        end
      end
      return found
    end



    -- ###################################################################################################
    -- ###################################################################################################
    -- ###################################################################################################

    -- Loop over all Areas (islands)

    -- ###################################################################################################

    -- a function that loops over every Area (Island) that contains any kind of Kontor (=owned by someone)
    -- just give it your custom function (executionfunc) that should get called for every Area once. You can filter yourself in that function what Session/Participant and so on you want.
     -- of course you can also check all other values available for Areas and change stuff based on textsourcelist.json, see below this for examples
     -- Area is unfortunately only accessable in the current active session, so only loop areas from current sessions
     -- info: the first ObjectID found will be in most cases the Harbor and GetAnyObjectsFromAnyone is optimzied to start with that if it is known and FromObjectID==nil (only known in current active session or Cache)
    local function AreasCurrentSessionLooper(executionfunc)
      local function Area_filterfunc(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID,AreaOwner,Kontor_OID)
        done = executionfunc(SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,AreaOwner,Kontor_OID,GUID,OID)
        return {addthis=false,done=done,next_AreaID=true,next_SessionID=false}
      end
      local function mySessionFilter(SessionID,SessionGUID)
        return SessionGUID==session.getSessionGUID()
      end
      g_ObjectFinderSerp.GetAnyObjectsFromAnyone({ObjectFilter=Area_filterfunc,SessionFilter=mySessionFilter,FromSessionID=nil,ToSessionID=nil,
        FromIslandID=1,ToIslandID=nil,FromAreaIndex=1,ToAreaIndex=nil,FromObjectID=nil,ToObjectID=nil})
    end

    -- example usage:
    -- g_ObjectFinderSerp.AreasCurrentSessionLooper(function(SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,AreaOwner,Kontor_OID,GUID,OID)
      -- print(ts.Area.GetAreaFromID(AreaID).CityName) 
    -- end)

    -- you can check the Area by all function listed in textsorucelist.json under CConstructionArea (eg. ts.GetAreaFromID(AreaID).CityName)
    -- or also with help of PlayerCounter !
    -- ts.Participants.GetParticipant(ParticipantID).ProfileCounter.Stats.GetCounter(counterValueType,playerCounter,context,counterScope,scopeContext)
      -- "counterValueType" :{  "Type" : "int"},   Defines if the MIN the MAX or the CURRENT value should be returned. 0 ist current.
      -- "playerCounter" :{  "Type" : "int"},      what you want to count, eg ObjectBuilt=0 and so on, see datasets.xml "PlayerCounter" for options (eg 44 for Attractiveness)
      -- "context" :{  "Type" : "int"},            GUID you want to count (0 if none needed). seems this does not Support PlayerCounterPools here -.-
      -- "counterScope" :{  "Type" : "int"},       Area/Session/Region/Global/Account , 3 is Global.
      -- "scopeContext" :{  "Type" : "int"}         used for counterScope Session/Area. Eg the GUID of the Session or Area. Also WORKS with AreaID! eg. AreaID 8706 and so on. (SessionID does not seem to work)
    -- eg:
    -- ts.Participants.GetParticipant(0).ProfileCounter.Stats.GetCounter(0,0,1010343,0,8706) -- count amount of farmer houses built on AreaID 8706 from ParticipantID 0
    -- ts.Participants.GetParticipant(0).ProfileCounter.Stats.GetCounter(0,5,0,0,8706) -- count total amount of population on that Area 

    -- AreaManager...BuildingsWithGameLogicCount(GUID) only works with GUID defined and no clue how to get this for a specific island anyways (only seems to work for current or maybe also for current from a SessionParticipant)
      -- ah, we can use AreaManager on the Area we want, if we already have an object from that area, by using GameObject.AreaManager... this will then check the Area whre GameObject belongs to


    -- ################################################

    

    -- ###################################################################################################
    -- ###################################################################################################
    -- ###################################################################################################
    -- ###################################################################################################


    -- EXAMPLE ObjectFilter for usage with GetAnyObjectsFromAnyone
    -- Unfortunately errors in your filter func will most likely not be logged in the anno logfile.
     -- So if it does not work like expeceted add some prints/modlog to it for debugging

    -- ts.Area.GetAreaFromID(AreaID).CityName will be an empty string for invalid Areas, eg the IslandID=0 water area.
     -- Of course you can still find ships in that AreaID, but no city/buildings

     -- before starting an expensive search for a specific GUID, you might want to check with ProfileCounter in lua (see below for example) or PlayerCounter in xml
     --  if the player owns an object with that GUID 
     -- Also zb. ProfileCounter mit IslandSettled in Session GUID durch die wir gerade loopen (die sessionguid bekommen wir durch IsLoadedSessionByID())
      -- macht zumindest Sinn wenn wir nach Gebäuden eines bestimmten Spielers suchen, dass wir dann auch nur soviele Islands durchgucken (also wissen wieviele besidelt sind)
     -- bzw. man kann auch ProfileCounter mit jedem Human (und evlt. 2nd Party + Mod) durchtesten. Wenn dann keiner was in der Session hat,
      -- kann man sich das loopen sparen.
     -- Genauso kann ProfileCounter Area auch mit AreaID (zb 8708) umgehen. Auf diese Weise kann man eventuell rausfinden, ob eine Area besieldet ist?
       -- hiermit TotalPopulation einer Insel: ts.Participants.GetParticipant(0).ProfileCounter.Stats.GetCounter(0,5,0,0,AreaID)
       -- das klappt in jeder Session/Area! dh damit können wir prüfen ob eine AreaID von irgendeinem Spieler besiedelt ist,
        -- egal in welcher Session wir gerade sind
       -- um Insel zu prüfen die nur ein kontor hat (keine einwohner), könnte man auch zusätzlich noch Attractiveness für alle participants prüfen:
        -- ts.Participants.GetParticipant(0).ProfileCounter.Stats.GetCounter(0,44,0,0,9090)
        -- wenns 0 returend, dann gehörts entweder dem participant nicht oder es ist ungültig.
         -- Wenns also 0 für alle participants returned, ists defintiv unbesiedelt (oder ungültig).
      -- und vllt MoneyBalance (30) der Session prüfen um rauszufinden, ob ein spieler überhaupt etwas in einer session hat (dass es sich exakt auf 0 ausgleicht ist schon recht unwahrscheinlich)
        -- (bzw vllt ist Attractivness hier zuverlässiger oder einfach beides?)




    -- simple example ObjectFilter
    local function my_ObjectFilter(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID,AreaOwner,Kontor_OID)
      if GUID==100438 and ParticipantID==1 and ts.GetGameObject(OID).Nameable.Name=="Hans" then
        return {addthis=true,done=true} -- add it and stop searching, everything found wanted to find
      end
    end
    -- good example filter for searching Area for a specific building (1500004632 no longer used like this)
    -- we differentiate between object-owner and area-owner because in theory mods can add objects to islands not owned by the area-owner.
    local function myObjectFilter(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID,AreaOwner,Kontor_OID)
      local AreaOwner = AreaOwner or g_LTL_Serp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(OID)..") Area Owner]",true) -- using DoForSessionGameObject, because Area is not known if local player is not in the same session
      local Area_onwedbyus = AreaOwner==ts.Participants.GetGetCurrentParticipantID()
      local object_ownedbyus = ParticipantID==ts.Participants.GetGetCurrentParticipantID() 
      if GUID==1500004632 and Area_onwedbyus and object_ownedbyus then
        return {addthis=true,done=true,next_AreaID=false,next_SessionID=false} -- important to return addthis and done, to stop the expensive search
      else
        if not Area_onwedbyus then
          return {addthis=false,done=false,next_AreaID=true,next_SessionID=false}
        elseif ts.Participants.GetParticipant(ParticipantID).ProfileCounter.Stats.GetCounter(0,0,1500004632,0,AreaID)==0 then -- check if this area even has the searched building
          return {addthis=false,done=false,next_AreaID=true,next_SessionID=false}
        end
      end
    end

    -- complex example To find objects with ParticipantID=0 , GUID=100438 and Names Hans/Franz. in total 2 objects to be found in Old world session 180023
    -- you can of course also count yourself in a variable defined outside of my_ObjectFilter in your script how many you already found and if it is enough.
    local function my_ObjectFilter(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID,AreaOwner,Kontor_OID)
      if SessionGuid~=180023 and SessionGuid~=180025 then -- skip to next session
        return {addthis=false,done=false,next_AreaID=false,next_SessionID=true}
      end
      if GUID==100438 and ParticipantID==0 then
        local Name = ts.GetGameObject(OID).Nameable.Name
        local adden = false
        if Name == "Hans" then
          adden = true
        elseif Name == "Peter" then
          adden = true
        end
        -- if adden and SessionGuid==180023 and found_counts["Session"][180023]~=nil and found_counts["Session"][180023]["count"]==1 then -- found_counts only shows what was already added before. If you are going to add this current object, it will be 1 more of course. So if we want 2 objects in total, we check if 1 is already there.
          -- if adden and SessionGuid==180025 and found_counts["Session"][180025]~=nil and found_counts["Session"][180025]["count"]==0  then
            -- return {addthis=adden,done=true} -- add it and stop seraching, everything found
          -- else
            -- return {addthis=adden,done=false,next_AreaID=false,next_SessionID=true}  -- add it and jump to next Session to search
          -- end
        -- else -- add it and continue searching in same location
          -- return {addthis=adden,done=false,next_AreaID=false,next_SessionID=false}
        -- end
      else -- do not add it and continue searching in same location
        return {addthis=false,done=false,next_AreaID=false,next_SessionID=false}
      end
    end
    -- Or even optimzie it further and search the island you are looking for a specific object (not walkable!) by checking first:
    -- ts.Participants.GetParticipant(searchParticipantID).ProfileCounter.Stats.GetCounter(0,0,searchGUID,0,AreaID)

    local function mySessionFilter(SessionID,SessionGUID)
      if SessionGUID~=session.getSessionGUID() then -- eg. only check the current session
        return false
      end
    end

    -- ###################################################################################################
    -- ###################################################################################################
    -- ###################################################################################################

    
    -- update Kontor_OIDs Cache
    local function _OnIslandSettledSessionEnter(PID)
      
      if ts.Participants.GetGetCurrentParticipantID() == PID then -- just to make sure its not 4 times for the same local player executed if there are 4 humans (for coop it does not matter because the trigger is only executed once per coop-team, so its fine)
        local SessionGuid = session.getSessionGUID()
          
          g_LTL_Serp.modlog("OnIslandSettledSessionEnter "..tostring(SessionGuid).." Update Areas Cache",ModID)
          
          g_LTL_Serp.start_thread("OnIslandSettledSessionEnter",ModID,function()
            while g_LTM_Serp==nil or g_ObjectFinderSerp==nil do
              coroutine.yield()
            end
            while g_LTM_Serp.Shared_Cache==nil or g_LTM_Serp.Shared_Cache[ModID]==nil do
              coroutine.yield()
            end
            
            local curSessionGUID = session.getSessionGUID()
            local curSessionID = nil
            for SID,SGUID in pairs(g_LTM_Serp.Shared_Cache[ModID].LoadedSessions) do
              if curSessionGUID==SGUID then
                curSessionID = SID
                break
              end
            end
            -- g_LTL_Serp.modlog("OnIslandSettledSessionEnter "..tostring(SessionGuid).." before Kontor_OIDs_before",ModID)
            local Kontor_OIDs_before
            if curSessionID~=nil then
              Kontor_OIDs_before = g_LTL_Serp.deepcopy(g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs[curSessionID])
            end
            -- g_LTL_Serp.modlog("OnIslandSettledSessionEnter "..tostring(SessionGuid).." after Kontor_OIDs_before",ModID)
          -- loop through Areas of current session and save owner+Kontor OID to cache
            g_ObjectFinderSerp.AreasCurrentSessionLooper(function(SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,AreaOwner,Kontor_OID,GUID)
              -- its enough to only call this and run it to the end. This makes sure that Cache Kontor_OIDs is updated within GetAnyObjectsFromAnyone
              -- g_LTL_Serp.modlog(SessionGuid..","..AreaID..","..Kontor_OID,ModID)
            end)
            -- g_LTL_Serp.modlog("OnIslandSettledSessionEnter "..tostring(SessionGuid).." after AreasCurrentSessionLooper",ModID)
               
            if g_SaveLuaStuff_Serp~=nil and Kontor_OIDs_before~=nil and not g_LTL_Serp.tables_equal(Kontor_OIDs_before,g_LTM_Serp.Shared_Cache[ModID].Kontor_OIDs[curSessionID]) then
                -- g_LTL_Serp.modlog("OnIslandSettledSessionEnter "..tostring(SessionGuid).." before t_SyncSharedCacheToEveryone",ModID)
              g_SaveLuaStuff_Serp.t_SyncSharedCacheToEveryone(ModID)
            end
            
            g_LTL_Serp.modlog("OnIslandSettledSessionEnter "..tostring(SessionGuid).." Updated Areas Cache Done",ModID)
            
          end)
          
      end
    end
    -- update SessionParticipants Cache
    local function _OnSessionLoaded(PID)
      if ts.Participants.GetGetCurrentParticipantID() == PID then -- just to make sure its not 4 times for the same local player executed if there are 4 humans (for coop it does not matter because the trigger is only executed once per coop-team, so its fine)
        g_LTL_Serp.modlog("OnSessionLoaded Update SessionParticipants Cache",ModID)
        g_LTL_Serp.start_thread("OnSessionLoaded",ModID,function()
          if g_LTL_Serp.WasNewGameJustStarted() then
            g_LTL_Serp.waitForTimeDelta(3000) -- small delay (2 sec on game start is not enough?)
          end
          g_LTL_Serp.waitForTimeDelta(2000) -- small delay to give the game time to finish everything, like spawning SessionParticipants
          while g_LTM_Serp==nil or g_ObjectFinderSerp==nil do
            coroutine.yield()
          end
          -- Script to update Cache with SessionsParticipants from the new session.
          local All_PIDS = {}
          if g_PeersInfo_Serp~=nil then
            for PIDToShareData,_ in pairs(g_PeersInfo_Serp.PIDsToShareData) do
              table.insert(All_PIDS,PIDToShareData)
            end
          end
          if g_SaveLuaStuff_Serp~=nil then
            table.insert(All_PIDS,g_SaveLuaStuff_Serp.PIDToSaveData.PID)
          end
          table.insert(All_PIDS,g_ObjectFinderSerp.PID_Neutral) -- and Neutral
          g_ObjectFinderSerp.GetAllLoadedSessionsParticipants(All_PIDS) -- this updates also the LoadedSessions Cache
        end)
      end
    end
    
    
    local function _RegisterEvents() -- not called anymore, since event. does crash too often. using triggers again
      -- Since the events can only call our functions after we added them, which is done in first SessionEnter via Trigger (no way to init out scripts earlier)
       -- the first session loading on new game and the first sessionenter on loading a game will not fire
      
      -- Important info for "event." from the game:
       -- If a function you call within that event causes an error, the game will crash without printing this error to the lua log!
       -- So better always use pcall in them
        -- SessionContext does not seem useful unfortunately...
          -- __type : table: 000001DEE5166718 
          -- __eq : function: 00007FF7CDED4BE0 C
          -- class_cast : userdata: 00007FF7CE89F200 
          -- __newindex : function: 000001DEE4F00098 C
          -- __name : sol.rdgs::SessionEnteredContext 
            -- __index : table: 000001DEE4DEF3B8 
          -- class_check : userdata: 00007FF7CE89F270 
          -- __pairs : function: 00007FF7CDED2980 C
          -- __index : table: 000001DEE51668F8 
          -- __gc : function: 00007FF7CD9E8C20 C
          -- new : function: 000001DEE5181558 C
          -- debug.getmetatable(SessionEnteredContext)
      local was_already_registered = true
      if event.OnSessionLoaded[ModID] == nil then -- only add it once
        g_LTL_Serp.modlog("Register OnSessionLoaded",ModID)
        was_already_registered = false
        event.OnSessionLoaded[ModID] = function(SessionContext)
          system.start(function()
            while g_ObjectFinderSerp==nil do
              coroutine.yield()
            end
            local status, err = xpcall(g_ObjectFinderSerp._OnSessionLoaded,g_LTL_Serp.log_error,ts.Participants.GetGetCurrentParticipantID()) -- use seperate function with pcall, because game crashes without lua error, if any error happens in an function called by event. !
            if status==false then -- error
              print(ModID,"ERROR OnSessionLoaded: Function OnSessionLoaded had an error: "..tostring(err))
              g_LTL_Serp.modlog("ERROR OnSessionLoaded: Function OnSessionLoaded had an error: "..tostring(err),ModID)
            end
          end,ModID.." OnSessionLoaded")
        end
      end
      if event.OnSessionEnter[ModID] == nil then -- only add it once
        g_LTL_Serp.modlog("Register OnSessionEnter",ModID)
        was_already_registered = false
        event.OnSessionEnter[ModID] = function(SessionContext)
          system.start(function()
            while g_ObjectFinderSerp==nil do
              coroutine.yield()
            end
            local status, err = xpcall(g_ObjectFinderSerp._OnIslandSettledSessionEnter,g_LTL_Serp.log_error,ts.Participants.GetGetCurrentParticipantID()) -- use seperate function with pcall, because game crashes without lua error, if any error happens in an function called by event. !
            if status==false then -- error
              print(ModID,"ERROR OnSessionEnter: Function OnIslandSettledSessionEnter had an error: "..tostring(err))
              g_LTL_Serp.modlog("ERROR OnSessionEnter: Function OnIslandSettledSessionEnter had an error: "..tostring(err),ModID)
            end
          end,ModID.." OnSessionEnter")
        end
      end
      
      -- delete lu_session_loaded_h0.lua and the Trigger in xml scripts if this works
       -- and maybe reanme the session enter scripts to islandsettled
       -- oder doch xml, weil event nutzen einfach zu oft crashed, trotz pcall -.-
       
      
      -- on game loaded, call the events sessionloaded and sessionenter once (since they are not called via the event yet)
      if not was_already_registered then
        system.start(function()
          while not g_LTM_Serp.Shared_Cache[ModID].Loaded do -- wait for cache to load
            coroutine.yield()
          end
          local status, err = xpcall(g_ObjectFinderSerp._OnSessionLoaded,g_LTL_Serp.log_error,ts.Participants.GetGetCurrentParticipantID()) -- use seperate function with pcall, because game crashes without lua error, if any error happens in an function called by event. !
          if status==false then -- error
            print(ModID,"ERROR OnSessionLoaded: Function OnSessionLoaded had an error: "..tostring(err))
            g_LTL_Serp.modlog("ERROR OnSessionLoaded: Function OnSessionLoaded had an error: "..tostring(err),ModID)
          end
          local status, err = xpcall(g_ObjectFinderSerp._OnIslandSettledSessionEnter,g_LTL_Serp.log_error,ts.Participants.GetGetCurrentParticipantID()) -- use seperate function with pcall, because game crashes without lua error, if any error happens in an function called by event. !
          if status==false then -- error
            print(ModID,"ERROR OnSessionEnter: Function OnIslandSettledSessionEnter had an error: "..tostring(err))
            g_LTL_Serp.modlog("ERROR OnSessionEnter: Function OnIslandSettledSessionEnter had an error: "..tostring(err),ModID)
          end
        end,ModID.." Call initial OnSessionEnter/OnSessionLoaded")
      end
      
      
    end



    -- ###################################################################################################
    -- ###################################################################################################
    -- ###################################################################################################

    g_LTL_Serp.start_thread("InitObjFindCache",ModID,function()
      while g_LTM_Serp==nil or g_LTM_Serp.Shared_Cache==nil do
        coroutine.yield()
      end
      g_LTM_Serp.Shared_Cache[ModID] = {ObIDs={},LoadedSessionsParticipants={},LoadedSessions={},Kontor_OIDs={},Loaded=nil,Changed=nil,SyncChanged=nil}
    end)
    
    
    -- here the functions you can use with help of this script
    -- search the function names in this file to get short explanation
    g_ObjectFinderSerp = {
      -- stuff for internal use
      _OnIslandSettledSessionEnter = _OnIslandSettledSessionEnter, -- internal use!
      _OnSessionLoaded = _OnSessionLoaded, -- internal use!
      -- ..
      IsLoadedSessionByID = IsLoadedSessionByID,
      -- helper constructs you can use
      -- object loopers
      GetCurrentSessionObjectsFromLocaleByProperty = GetCurrentSessionObjectsFromLocaleByProperty,
      GetAnyObjectsFromAnyone = GetAnyObjectsFromAnyone,
      AreasCurrentSessionLooper = AreasCurrentSessionLooper,
      GetLoadedSessions = GetLoadedSessions,
      GetAnyValidKontorOIDFrom = GetAnyValidKontorOIDFrom,
      GetFirst100LoadedSessionsGameObjects = GetFirst100LoadedSessionsGameObjects,
      GetAllLoadedSessionsParticipants = GetAllLoadedSessionsParticipants,
      GetHighestObIDsLocalPlayerCurrentSessionByProperty = GetHighestObIDsLocalPlayerCurrentSessionByProperty,
      PID_Neutral = 8,
      l_MaxSessionID = 20, -- used as default max SessionID when looping through all sessions. In vanilla we have ~8 sessions, so I think 20 should be fine even with alot of session mods installed
      l_MaxIslandID = 80, -- per Session
      MaxObjIdAreaHelper = {Guid=1500005548,Unlock=1500005549}, -- IslandID ~= 0
      MaxObjIdWalkableHelper = {Guid=1500005550,Unlock=1500005552}, -- IslandID = 0
      DoesMaxObjIdHelperExists = DoesMaxObjIdHelperExists,
      SpawnMaxObjIdHelpers = SpawnMaxObjIdHelpers,
      ModID = ModID,
    }
        
    -- _RegisterEvents() -- not called anymore, since event. does crash too often. using triggers again
    
    
    g_LTL_Serp.start_thread("g_OnGameLeave_serp",ModID,function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_ObjectFinderSerp = nil -- stop everything (might crash some currently running functions, but I think its ok)
          event.OnSessionEnter[ModID] = nil
          event.OnSessionLoaded[ModID] = nil
        end
      end
    end)
    g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)

end
