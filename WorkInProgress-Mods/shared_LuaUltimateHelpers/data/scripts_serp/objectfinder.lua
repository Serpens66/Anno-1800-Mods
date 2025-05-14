-- Big thanks also to Taube and nyk for helping and finding out important information about how ObjectIDs and so on work.

  -- Uses CompanyName from Scenario3_Challenger3 for DoForSessionGameObject (they exist in every vanilla game in every session)
   -- And adds+uses Nameable for these Participants (for sharing info and saving info)
   -- CompanyName Scenario3_Challenger1 and Scenario3_Challenger2 used in shared_PopUp mod.
    -- Nameable from Scenario3_Challenger1+Scenario3_Challenger2 used here
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
   
   -- Scenario3_Queen  GUID: 101523 , PID: 130          this is used in savetablestuff.lua to save information into the savegame (others are used for sharing)
   
   -- Solche Participants sind besonders in dem Sinne, dass sie haben (im queen template):
    -- <CreateModeMeta>AutoCreate_Always</CreateModeMeta> und <CreateModeSession>AutoCreate_Always</CreateModeSession>
-- (wichtige infos für neue mod participants: SessionParticipants wird nicht automaitsch zu einem savegame zugefügt, deswegen hierfür nur vanilla participants nehmen)


-- TODO/INFO:
 -- Es scheint als wäre Spielgeschwindigkeit der Totfeind von lua Threads...
  -- Einfacher Testcode geht irgendwie (solange nicht auf superslow mow aka Pause)
 -- aber mein ganzen lua construct schläft ein, wenn man im MP oder auch Singpleplayer auf halben Speed macht,
 -- obwohl ein test mit waitForTimeDelta mit halber geschw. eigentlich funzt
  -- das ganze sessionswitch system. Aber sogar auch Spiel verlassen (MP) dauert bei halber geschw. hundert jahre
 -- und geht sofort weiter sobald man ts.GameClock.SetSetGameSpeed(3) macht


-- TODO 
-- Am ende nochmal richtige Ladereihenfolge der ganzen lua mods aufstellen und sicherstellen, dass LoadAfterIds 
-- überall korrekt ist
-- zb LuaPeers und Objectfinder brauchen sich gegenseitig. Ladereihenfolge sollte theoretisch egal sein, aber wenns in beiden mods steht gibts bestimmt n fehler


-- TODO:
 -- für SessionLoaded und SessionEnter die lua events nehmen, statt xml trigger.
  -- das spart scripts und ist denke ich besser, weil wir auch direkt wissen welche session loaded wurde
   -- (und da meine helper session 1500005538 ausschließen)


-- TODO:
 -- lu_session_loaded_h0 und lu_session_entered scripte basierend auf h0 für alle humans anpassen



-- TODO:
 -- funktionen die aus einem thread heraus aufgerufen werden müssen mit t_ am namen kennzeichnen


-- Offtopic:
-- Mod machen der Anarchie Zeituntsartikel bzw. Zeitungsbuffs ohne DLC erlaubt?
 -- Soll da wohl andere Buffs geben, die stark aber auch n Nachteil haben.


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
-- also ist irgendwie im savegame drin das problem... 
-- vllt nochmal n coop game ohne hilftssession und ohne das session template starten.
 -- und gucken ob das auch iwann crashed




 

-- TODO:
 -- evlt. g_ObjectFinderSerp umbenennen in g_UltLuaHelp oderso. oder alle g_ in ult zusammenfassen


-- TODO:
 -- nochmal LEaveUI testen, ob es ein event gibt, was kommt wenn man das Spiel verlässt, sowohl SP als auch MP.
  -- dann müsste man optimalerweise schon alle lua Dinge resetten,
   -- damit im MP nicht Alte Daten verwendet werden, während man noch im Ladebildschirm wartet (und erst danach die lua skripte neu gestartet werden)


-- TODO:
 -- überlegen wie wir in SaveCache sicherstellen können,
  -- dass alle infos geteilt wurden, bevor wir SaveTableToNameable als FirstActivePeer aufrufen




    -- ObjectFinderCacheSerp
    -- structure will be: { ObIDs = [SessionID]={[AreaID]={LowObID=1,HighObID=100,valid=false}} }
      -- KontorObjectID ist aktuell nicht drin, weils meist/immer? die LowObID ist.  
      -- LeereObIDs ist noch drin, aber es wäre vermutlich weniger inhalt, wenn wir vergebene (und nicht leer) abspeichern würden.
        -- aber beides keine gute Idee... Idee war sonst Spannen, statt einzelne IDS anzugeben.. aber auch doof...
       
              


    -- - welche ObjectIDs zwischen gefüllten ids leer sind, also zb 1 ist Kontor und dann ist bis 10k erstmal nichts, weil soviel abgerissen wurde
     -- dann sich merken, dass man 2 bis 10k erstmal skippen kann
     -- LeereObIDs={[2000]=true,[3000]=true}} ObjectID als key damit check ob enthalten sehr schnell ist.
      -- wie ich sinnvoll ein "von 2000 bis 3000" eintrage weiß ich noch nicht...
       -- und selbst wenn ichs weiß, dann sollte man das nachträglich, nach einem gesamten durchlauf machen indem man direkt über LeereObIDs looped
        -- und das dann zusammenfasst. Wobei man diese Zusammenfassung evlt auch direkt vor einem save to save-helper
         -- machen könnte, geht dabei ja nur ums Platz sparen in dem save-string
          -- und beim Laden dann wieder zurück in jede einzelne ObjectID


    -- TODO:
     -- evlt direkt in eine find funktion einbinden, dass sie nen trigger startet, der ein einzigartiges objekt spawned
      -- und dann solange gelooped wird, bis die GUID des einzigartigen objekt gefunden wurde, weil dann sicher ist, dass es maximal bis da ging zum zieptunkt des spawnens




-- #######################################
-- Wenn sonst alles fertig:

-- TODO:
 -- IDConverter und auch simple loop um OID zu finden evtl. so auslagern, dass es auch ohne Save/Cache verwendet werden kann?
  -- Damit Mods zumindest leichtere Loops wie AreaLoop oder GetCurrentSessionObjectsFromLocaleByProperty nutzen können,
   -- ohne das MP PopUp zu brauchen?

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
-- g_LuaTools.start_thread("g_OnGameLeave_serp",ModID,function()
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
-- g_LuaTools.start_thread("g_LuaScriptBlockers",ModID,function()
  -- g_LuaTools.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
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
-- Anstatt system.start() nutze lieber meine Funktion g_LuaTools.start_thread(threadname,ModID,fn,...). Denn diese hat 
 -- noch Fehler-Logging integriert, was extremst hilfreich beim coden/debuggen/testen ist, weil sonst threads einfach ohne irgendeine Fehlermeldung abbrechen

-- AreaID (und damit auch SessionID,IslandIndex,AreaIndex) bleiben nach Spiel Generierung/Session Load, dann immer dieselben, egal wem was gehört. 

local ModID = "shared_LuaUltimateHelpers_Serp objectfinder.lua" -- used for logging

if g_LuaScriptBlockers[ModID]==nil then
  
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    

    if g_LuaTools==nil then
      console.startScript("data/scripts_serp/luatools.lua")
    end


    print("shared_LuaUltimateHelpers_Serp objectfinder.lua called")
    g_LuaTools.modlog("objectfinder.lua called",ModID)

    
    if g_StringTableConvertSerpNyk==nil then
      console.startScript("data/scripts_serp/savestuff_tableconvert.lua")
    end

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


    -- only call this function directly if you have really important info to save, that should not be get lost.
     -- Otherwise rely on the "every x minutes autosave" savecache.lua called via Trigger 
    local function t_SaveCache()

        while g_SaveLuaStuff_Serp==nil or g_PeersInfo_Serp==nil or g_PeersInfo_Serp.CoopFinished~=true or g_CoopCountRes==nil or g_CoopCountRes.Finished~=true do
          coroutine.yield()
        end
        g_LuaTools.modlog("SaveCache called ",ModID)

        
        -- TODO:
         -- überlegen wie wir in SaveCache sicherstellen können,
          -- dass alle infos geteilt wurden, bevor wir SaveTableToNameable als FirstActivePeer aufrufen
          -- eigentlich nur möglich, indem wir für jeden Spieler t_SyncCacheToEveryone machen, auch welche die keine Änderungen hatten.
           -- Nur dann können wir zählen, ob wir von jedem etwas empfangen haben
        
        if g_ObjectFinderSerp.ObjectFinderCacheSerp.Changed or g_PeersInfo_Serp.AmIFirstActivePeer()==true then -- do it always for the FirstActivePeer, because he needs to know the current average waiting time of t_ExecuteFnWithArgsForPeers , since he will be the one to save it to Nameable and it should be save that everyone completed t_ExecuteFnWithArgsForPeers
          local status,err = pcall(g_ObjectFinderSerp.t_SyncCacheToEveryone)
          if status==false then
            g_LuaTools.modlog("ERROR : "..tostring(err),ModID)
            error(err) 
          end
          g_LuaTools.waitForTimeDelta(1000) -- little extra time to make sure everything was shared before we call SaveTableToNameable
        else -- we had no change. But someone else maybe had and is currently sending it to us. So also wait a short time to see if ObjectFinderCacheSerp.SyncChanged updates
          g_LuaTools.waitForTimeDelta(6000) -- problem is depending on usage t_ExecuteFnWithArgsForPeers can take between 4 and endless seconds..
        end
        if g_ObjectFinderSerp.ObjectFinderCacheSerp.Changed or g_ObjectFinderSerp.ObjectFinderCacheSerp.SyncChanged then
          g_SaveLuaStuff_Serp.SaveTableToNameable("g_ObjectFinderSerp",g_ObjectFinderSerp.ObjectFinderCacheSerp) -- will only be executed for first peer, but this is checked within savetabestuff.lua
          g_ObjectFinderSerp.ObjectFinderCacheSerp.Changed = nil
          g_ObjectFinderSerp.ObjectFinderCacheSerp.SyncChanged = nil
        end

    end
    
    local function t_LoadCache()
        while g_SaveLuaStuff_Serp==nil do
          coroutine.yield()
        end
        -- Load Cache from Savegame
        local ObjectFinderCacheSerp = g_SaveLuaStuff_Serp.LoadTableFromNameable("g_ObjectFinderSerp",true)
        if ObjectFinderCacheSerp~=nil and type(ObjectFinderCacheSerp)=="table" and ObjectFinderCacheSerp.LoadedSessionsParticipants~=nil then
          g_ObjectFinderSerp.ObjectFinderCacheSerp = ObjectFinderCacheSerp
        end
        g_ObjectFinderSerp.ObjectFinderCacheSerp.Loaded = true
    end
    
    -- call to sync the ObjectFinderCacheSerp for every human peer
    -- called from within a thread
    local function t_SyncCacheToEveryone(skip_equalcheck)
      if ts.GameSetup.GetIsMultiPlayerGame() then
        g_ObjectFinderSerp.t_ExecuteFnWithArgsForPeers("g_ObjectFinderSerp.SyncCache",3000,true,"Everyone",g_ObjectFinderSerp.ObjectFinderCacheSerp,skip_equalcheck) -- waits for it to finish
      end
    end
    -- Called via t_SyncCacheToEveryone to sync the caches between all peers
     -- skip_equalcheck=true might be better for really huge lists and we want to save time
    local function SyncCache(Other_ObjectFinderCacheSerp,skip_equalcheck)
      if Other_ObjectFinderCacheSerp~=nil and type(Other_ObjectFinderCacheSerp)=="table" then
        local Merged = g_LuaTools.MergeMapsDeep(g_ObjectFinderSerp.ObjectFinderCacheSerp,Other_ObjectFinderCacheSerp)
        if skip_equalcheck or not g_LuaTools.tables_equal(g_ObjectFinderSerp.ObjectFinderCacheSerp,Merged) then
          g_ObjectFinderSerp.ObjectFinderCacheSerp = Merged
          g_ObjectFinderSerp.ObjectFinderCacheSerp.SyncChanged = true
        end
      end
    end
    
    
    


    -- ##################################################################################################################################
    -- ##################################################################################################################################




      -- text embed helper for using MetaObjects.SessionGameObject, which is otherwise unavailable in lua...
     -- ts_embed_string should be eg: "[MetaObjects SessionGameObject("..tostring(OID)..") Area CityName]"
     -- so always inlucding "[MetaObjects SessionGameObject("..tostring(OID)..") ...]" and your wanted command for the OID you enter
     local function DoForSessionGameObject(ts_embed_string,doreturnstring)
      if doreturnstring then -- we want to get what the textembed returns, but game.TextSourceManager.setDebugTextSource does not return anything. I only know a workarkund to get it, by setting and reading out the name of a namable helper object
          game.TextSourceManager.setDebugTextSource("[Participants Participant(120) Profile SetCompanyName( "..tostring(ts_embed_string).." )]")
          local returnstring = ts.Participants.GetParticipant(120).Profile.CompanyName
          local oldtext = ts.GetAssetData(100939).Text -- does not work to call this directly in SetCompanyName
          ts.Participants.GetParticipant(120).Profile.SetCompanyName(oldtext) -- set it to nil again, so you can notice if sth did not work
          return returnstring
      else -- only an action that needs no return, then simply execute it
        game.TextSourceManager.setDebugTextSource(ts_embed_string)
      end
    end

    -- INFO:
    -- with game.TextSourceManager.setDebugTextSource(string) we can also execute commands for too high OIDs if they keep them a string when getting it from userdata:getName() (higher than the max allowed integer in lua -.- which is true for all "EditorFlag" objects, so placed on the islands directly)
    -- (ts.GetGameObject(OID) akzeptiert keinen string, deswegen der Weg über debug)
    -- session.getObjectByID(OID) um an userdata zu kommen akzeptiert auch einen string
    -- aber wir können unsere OIDtableToOID usw funktionen nicht nutzen, weil die alles in Zahlen umwandelt.
     -- und selbst wenn wir da EditorFlag einbauen, würden wir anstatt 9308976176787619987 : 9.3089761767876e+18 returned bekommen, was wir jetzt nicht mehr 
      -- nachträglich in einen string umwandeln können, ohne dass wir Zeichen verloren haben...
    -- Sollte gehen mit:
    -- local x = g_LuaTools_to_bint(1)
    -- x = x << 128
    -- print(x) -- outputs: 340282366920938463463374607431768211456
    -- print(tostring(x) == '340282366920938463463374607431768211456')




    -- helpers to access "Vector" return values you find in textsourcelist.json, which are not accessable in lua directly -.-
    -- we can only access AreaFromID from the current active session of the local player
    -- set FertilitiesOrLodesString to "Fertilities" or "Lodes" (ores), depending of what you want to get returned
    local function GetFertilitiesOrLodesFromArea_CurrentSession(AreaID,FertilitiesOrLodesString)
      local count = g_ObjectFinderSerp.DoForSessionGameObject("[Area AreaFromID("..tostring(AreaID)..") "..tostring(FertilitiesOrLodesString).." Count]",true)
      local results = {}
      if count~=nil and count~="nil" then
        count = tonumber(count)
        if count~=nil and count>0 then
          local GUID
          for i=0,count-1 do
            GUID = g_ObjectFinderSerp.DoForSessionGameObject("[Area AreaFromID("..tostring(AreaID)..") "..tostring(FertilitiesOrLodesString).." At("..tostring(i)..") Guid]",true)
            if GUID~=nil and GUID~="nil" then
              results[tonumber(GUID)] = true -- use it as key, so you can easily check for a specific fertility without looping over the list
            end
          end
        end
      end
      return results
    end

    -- Works regardless who is in which session, as long as you know the correct OID of the object
    -- eg use as ts_embed_string: "[MetaObjects SessionGameObject("..tostring(OID)..") ItemContainer Cargo Count]"
      -- to get the Cargo of an Object with ImteContainer (the stuff in the Slots. usually from ships)
    -- ts_embed_string: "[MetaObjects SessionGameObject("..tostring(OID)..") ItemContainer Sockets Count]"  == Sockets content
    -- ts_embed_string: "[MetaObjects SessionGameObject("..tostring(OID)..") Factory ProductivityUpgradeList Count]"  == Buffs on Objects with Factory (or also Monument) property
        -- it really ONLY returns Buffs which provide ProductivityUpgrade buff ... (mit ts.GetItemAssetData(BuffGUID) kommen wir an infos zu buffs/items, aber nicht ob etwas davon betroffen ist)
    -- you use "Count" in your ts_embed_string. the function will also automatically call At() for it (to get the actual content)
    local function GetVectorGuidsFromSessionObject(ts_embed_string)
      local ts_embed_string_guid,ts_embed_string_value
      local count = g_ObjectFinderSerp.DoForSessionGameObject(ts_embed_string,true)
      local results = {}
      if count~=nil and count~="nil" then
        count = tonumber(count)
        if count~=nil and count>0 then
          local GUID,Value
          for i=0,count-1 do
            ts_embed_string_guid = string.gsub(ts_embed_string, "Count", "At("..tostring(i)..") Guid")
            GUID = g_ObjectFinderSerp.DoForSessionGameObject(ts_embed_string_guid,true)
            GUID = tonumber(GUID)
            if GUID~=nil and GUID~=0 then
              ts_embed_string_value = string.gsub(ts_embed_string, "Count", "At("..tostring(i)..") Value")
              Value = g_ObjectFinderSerp.DoForSessionGameObject(ts_embed_string_value,true)
              Value = tonumber(Value) or 1
              results[i] = {GUID=GUID,Value=Value} -- i starts at 0 (so use pairs() when looping), just like the slots when doing eg EquipSlot
            end
          end
        end
      end
      return results
    end

    -- only returns active coop players viewing the same object like you, not yourself! (so yourself and inactive peers are not shown)
    -- to get username use: ts.Online.GetUsername(peerint)
    -- for StatisticsMenu UIState = 176, for ships it is 119 (it is called RefGuid in infotips for whatever reason), get them eg with adding your log function to table event.OnLeaveUIState and log the one paramater of this function
    -- CompynaMenu (hitting on your profile) is UIState = 0, diplomenu=29, TradeRoutemenu is 165 or 177, ESC Menü 132, Optionsmenü 129, Annopedia 174, EinflussFenster ist 52, Stadt Attraktivität ist 3, 
      -- 116 Bauernhaus, 103 Marktplatz, 102 Kontor/Lagerhaus,97 handelskammer UI, 113 Kirche, 120 Werft, 192/193 oder 194 ist Movie beenden
    -- RefOid = 0 for whole menus , for ships/buildings: g_ObjectFinderSerp.IDConverter.get_OID(session.getSelectedFactory()) 
    local function GetCoopPeersAtMarker(UIState,RefOid)
      local count = g_ObjectFinderSerp.DoForSessionGameObject("[Online GetCoopPeersAtMarker("..tostring(UIState)..","..tostring(RefOid)..") Count]",true)
      local peerints = {}
      if count~=nil and count~="nil" then
        count = tonumber(count)
        if count~=nil and count>0 then
          local peerint
          for i=0,count-1 do
            peerint = g_ObjectFinderSerp.DoForSessionGameObject("[Online GetCoopPeersAtMarker("..tostring(UIState)..","..tostring(RefOid)..") At("..tostring(i)..")]",true)
            if peerint~=nil and peerint~="nil" then
              peerints[tonumber(peerint)] = true -- use it as key, so you can easily check for a specific without looping over the list
            end
          end
        end
      else
        return nil
      end
      return peerints
    end


    -- ###########################################

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

     
     
     -- ###################################################################################
     -- ###################################################################################

    -- t_ShareLuaInfo / t_ExecuteFnWithArgsForPeers can also be used to get an OID more efficient from another human peer who is in the correct session.
     -- Because he can use the fast GetCurrentSessionObjectsFromLocaleByProperty (note that he must own it) function or at least GetCurrentSessionObjectsFromAnyone
      -- which is still faster/efficient than the everywhere function.
    
    
    local function StartShareThread()
      g_LuaTools.start_thread("StartShareThread",ModID,function()
        -- g_LuaTools.modlog("StartShareThread "..tostring(ts.GameClock.CorporationTime),ModID)
        local task = table.remove(g_ObjectFinderSerp.ShareQueue,1)
        while task~=nil do
          if type(task)=="table" and task.infostring~=nil then
            local infostring = task.infostring
            local SharePID = task.SharePID
            local waittime = task.waittime
            
            -- g_LuaTools.modlog("StartShareThread before DoneVariableString "..tostring(ts.GameClock.CorporationTime),ModID)
            local DoneVariable,last_key = g_LuaTools.getGlobalWithString(task.DoneVariableString,true)

            -- g_LuaTools.modlog("StartShareThread after DoneVariableString "..tostring(ts.GameClock.CorporationTime),ModID)
            local PID_OID = nil
            local status,sessionparticipants = pcall(g_ObjectFinderSerp.GetAllLoadedSessionsParticipants,{SharePID},"First") -- only first found loaded session
            if status==false then
              g_LuaTools.modlog("ERROR : "..tostring(sessionparticipants),ModID)
              error(sessionparticipants) 
            end
            
            -- g_LuaTools.modlog("StartShareThread after GetAllLoadedSessionsParticipants "..tostring(ts.GameClock.CorporationTime),ModID)
            for SessionID,session_pids in pairs(sessionparticipants) do
              PID_OID = session_pids[SharePID].OID
              local status,err = pcall(g_ObjectFinderSerp.DoForSessionGameObject,"[MetaObjects SessionGameObject("..tostring(PID_OID)..") Nameable Name("..tostring(infostring)..")]")
              if status==false then
                g_LuaTools.modlog("ERROR : "..tostring(err),ModID)
                error(err) 
              end
            end
            -- g_LuaTools.modlog("StartShareThread after DoForSessionGameObject "..tostring(ts.GameClock.CorporationTime),ModID)
            g_LuaTools.waitForTimeDelta(waittime) -- wait before we return, so after we return the caller can directly continue to GetSharedLuaInfo
            if DoneVariable[last_key]~=nil then
              DoneVariable[last_key] = infostring -- signal that we are finished setting up the Nameable
            end
            g_LuaTools.waitForTimeDelta(1000) -- wait another second before reusing the Nameable, so clients can do GetSharedLuaInfo
            DoneVariable[last_key] = false
            -- g_LuaTools.modlog("StartShareThread task done "..tostring(ts.GameClock.CorporationTime),ModID)
          end
          task = table.remove(g_ObjectFinderSerp.ShareQueue,1)
        end
        -- g_LuaTools.modlog("StartShareThread Stop "..tostring(ts.GameClock.CorporationTime),ModID)
        g_ObjectFinderSerp.ShareLoopIsRunning = false
      end)
    end
       
    
    
    -- call this function from within a thread (system.start()) so it can execute coroutine.yield()
    -- make sure the code that calls this only runs for the one peer you want it to run (by checking g_PeersInfo_Serp.PeerInt and other info from g_PeersInfo_Serp.)
    
    -- DoneVariableString eg: "g_ObjectFinderSerp.ExecutionDone" . The variable you provide will be set to infostring
     -- after sharing is done and waittime waited. This way the called can find out when it was processed
    local function t_ShareLuaInfo(infostring,waittime,DoneVariableString)
        if g_PeersInfo_Serp==nil or g_CoopCountRes==nil then
          return false
        end
        waittime = waittime or 3000  -- at least 1 second, better 3 to make sure even slower PCs synced
        -- g_LuaTools.modlog("t_ShareLuaInfo before yield "..tostring(ts.GameClock.CorporationTime),ModID)
        while g_PeersInfo_Serp.CoopFinished~=true or g_CoopCountRes.Finished~=true do
          coroutine.yield()
        end
        SharePID = g_ObjectFinderSerp.PIDsToShareData[g_PeersInfo_Serp.PeerInt+1]
        -- g_LuaTools.modlog("t_ShareLuaInfo after yield "..tostring(ts.GameClock.CorporationTime),ModID)
        table.insert(g_ObjectFinderSerp.ShareQueue,{SharePID=SharePID,waittime=waittime,infostring=infostring,DoneVariableString=DoneVariableString})
        -- g_LuaTools.modlog("t_ShareLuaInfo table.insert "..tostring(ts.GameClock.CorporationTime),ModID)
        if not g_ObjectFinderSerp.ShareLoopIsRunning then
          g_ObjectFinderSerp.ShareLoopIsRunning = true
          -- g_LuaTools.modlog("t_ShareLuaInfo ShareLoopIsRunning false, now true "..tostring(ts.GameClock.CorporationTime),ModID)
          g_ObjectFinderSerp.StartShareThread()
        end
        -- g_LuaTools.modlog("t_ShareLuaInfo nach thread starten "..tostring(ts.GameClock.CorporationTime),ModID)
        return true
    end
    
    local function GetSharedLuaInfo(FromPeerInt)
        SharePID = g_ObjectFinderSerp.PIDsToShareData[FromPeerInt+1]
        local status,sessionparticipants = pcall(g_ObjectFinderSerp.GetAllLoadedSessionsParticipants,{SharePID},"First") -- only first found loaded session
        if status==false then
          g_LuaTools.modlog("ERROR : "..tostring(sessionparticipants),ModID)
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
        g_LuaTools.modlog("t_ExecuteFnWithArgsForPeers start "..tostring(funcname).." "..tostring(ts.GameClock.CorporationTime),ModID)
        local args = {...} -- does put the "..." arguments into a table
        local intable = {funcname=funcname,args=args,ForPeers=ForPeers}
        local inhex = g_StringTableConvertSerpNyk.TableToHex(intable)
        
        local function DoExecuteFnWithArgsForPeers(inhex,waittime)
            -- g_LuaTools.modlog("DoExecuteFnWithArgsForPeers before share "..tostring(ts.GameClock.CorporationTime),ModID)
            local status,err = pcall(g_ObjectFinderSerp.t_ShareLuaInfo,inhex,waittime,"g_ObjectFinderSerp.ExecuteDone")
            if status==false then
              g_LuaTools.modlog("ERROR : "..tostring(err),ModID)
              error(err) 
            end
            -- g_LuaTools.modlog("DoExecuteFnWithArgsForPeers shared "..tostring(ts.GameClock.CorporationTime),ModID)
            while g_ObjectFinderSerp.ExecuteDone~=inhex do -- wait for it to finish (after that we have 1 sec to fetch the info)
              coroutine.yield()
            end
            -- g_LuaTools.modlog("DoExecuteFnWithArgsForPeers ExecuteDone "..tostring(ts.GameClock.CorporationTime),ModID)
            local Unlock = g_ObjectFinderSerp.ExForEveryUnlocks[g_PeersInfo_Serp.PeerInt+1]
            ts.Unlock.SetUnlockNet(Unlock) -- starting another script via xml ActionExecuteScript roughly takes 200 ms in EarlyGame
            -- g_LuaTools.modlog("DoExecuteFnWithArgsForPeers unlocked "..tostring(ts.GameClock.CorporationTime),ModID)
            g_LuaTools.waitForTimeDelta(500) -- wait shortly to make sure all coop players executed this
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
    local function DoTheExecutionFor(FromPeerInt)
      g_LuaTools.modlog("DoTheExecutionFor FromPeerInt "..tostring(FromPeerInt).." "..tostring(ts.GameClock.CorporationTime),ModID)
      local inhex = g_ObjectFinderSerp.GetSharedLuaInfo(FromPeerInt)
      local intable = g_StringTableConvertSerpNyk.HexToTable(inhex)
      if type(intable) =="table" then
        -- g_LuaTools.modlog(intable.funcname,ModID)
        local ShouldIExecute = false
        local ForPeers = intable.ForPeers
        if ForPeers==nil then
          ShouldIExecute = true
        elseif type(ForPeers)=="string" then
          local ForPeersSplit = g_LuaTools.mysplit(ForPeers, "_Session_") -- "Human0_Session_180023" or "Everyone_Session_180023"
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
            g_LuaTools.modlog("ERROR DoTheExecutionFor (t_ExecuteFnWithArgsForPeers): invalid -ForPeers- was provided: "..tostring(ForPeers).." . Will execute for everyone now",ModID)
            ShouldIExecute = true
          end
        elseif type(ForPeers)=="table" then
          ShouldIExecute = g_LuaTools.table_contains_value(ForPeers,g_PeersInfo_Serp.PeerInt)
        else
          g_LuaTools.modlog("ERROR DoTheExecutionFor (t_ExecuteFnWithArgsForPeers): invalid -ForPeers- was provided: "..tostring(ForPeers).." . Will execute for everyone now",ModID)
          ShouldIExecute = true
        end
        -- g_LuaTools.modlog("DoTheExecutionFor before ShouldIExecute",ModID)
        if ShouldIExecute then
          -- g_LuaTools.modlog("DoTheExecutionFor yes ShouldIExecute",ModID)
          func = g_LuaTools.getGlobalWithString(intable.funcname)
          -- g_LuaTools.modlog("func call "..tostring(ts.GameClock.CorporationTime),ModID)
          local success, err = pcall(func,table.unpack(intable.args))
          if success==false then
            g_LuaTools.modlog("ERROR while trying to call funcname "..tostring(intable.funcname).." error: "..tostring(err),ModID)
          end
            -- g_LuaTools.modlog("DoTheExecutionFor after call",ModID)
        end
      end
    end

    -- ###################################################################################################
    -- ###################################################################################################


    local PropertiesStringToID = {AudioTextPool=0,DevTestProp=1,Position=2,Standard=3,Text=4,TextPool=5,ObjectFilter=6,ObjectiveScaling=7,ObjectList=8,ObjectTargetFilter=9,ParticipantRelation=10,SessionFilter=11,SpawnArea=12,TradingStation=13,ConditionObjectAnywhere=14,ConditionObjectClientQuestObject=15,ConditionObjectiveSignsAndFeedback=16,ConditionObjectPlayerKontor=17,ConditionObjectPrebuiltObject=18,ConditionObjectSpawnedObject=19,ConditionObjectStarterObject=20,
      ConditionObjectUseDefaultSettings=21,ConditionScanner=22,ConditionActiveRegion=23,ConditionActiveSession=24,ConditionAlwaysFalse=25,ConditionAlwaysTrue=26,ConditionAreaClaimed=27,ConditionAttractiveness=28,ConditionBuildingsInBlueprintmode=29,ConditionBurningObject=30,ConditionBusActivationNeedSaturation=31,ConditionCameraMovement=32,ConditionCorporationDifficulty=33,ConditionDecision=34,ConditionDecisionOption=35,ConditionDiplomaticState=36,ConditionDiplomaticStateChanged=37,
      ConditionEvaluateTextSource=38,ConditionEvent=39,ConditionExpeditionFinished=40,ConditionExportGoodsLeveled=41,ConditionFactoryProductivity=42,ConditionFestival=43,ConditionFiniteResource=44,ConditionFirstTimeEventHappened=45,ConditionGameEnded=46,ConditionGamePadAction=47,ConditionGoodsInRange=48,ConditionGUIEvent=49,ConditionHaciendaDecreesActive=50,ConditionHaciendaModuleCount=51,ConditionHappinessMood=52,ConditionInPalaceRange=53,ConditionInStorage=54,ConditionIrrigatedModules=55,
      ConditionIrrigationCapacityExceeded=56,ConditionIsBuffed=57,ConditionIsCampaign=58,ConditionIsCraftingInProgress=59,ConditionIsCreativeMode=60,ConditionIsDiscovered=61,ConditionIsDLCActive=62,ConditionIsDocklandsExportPyramidFull=63,ConditionIsGamepadMode=64,ConditionIsIndustrialized=65,ConditionIslandsDiscovered=66,ConditionIslandsWithFertility=67,ConditionIsMultiplayer=68,ConditionIsParticipantInGame=69,ConditionIsPaused=70,ConditionIsTutorial=71,ConditionItemActionCompleted=72,
      ConditionItemUsed=73,ConditionMetagameLoaded=74,ConditionModuleBuildingEfficiency=75,ConditionModuleCount=76,ConditionMonoCulture=77,ConditionMonumentEventsActive=78,ConditionMonumentProgress=79,ConditionMutualAreaInSubconditions=80,ConditionNewspaperPossible=81,ConditionNewspaperPublished=82,ConditionObjectPosition=83,ConditionObjectSelected=84,ConditionObjHPCheck=85,ConditionOverlapsAABB=86,ConditionPalaceItemEquipBonusActive=87,ConditionPalaceUnlocks=88,ConditionPhotographObject=89,
      ConditionPlayerCounter=90,ConditionProductCapacityReached=91,ConditionProductivity=92,ConditionQuestPoolQuestRunning=93,ConditionQuestState=94,ConditionRecipeResearchCompleted=95,ConditionReminderMessage=96,ConditionReputation=97,ConditionResearchPointLimitReached=98,ConditionResidentsInBuilding=99,ConditionSeason=100,ConditionSelectionHappinessDebuffActive=101,ConditionSessionLoading=102,ConditionShipsInRange=103,ConditionShipsOwnedInSession=104,ConditionShipyardState=105,ConditionStaticResult=106,
      ConditionTextPopupClosed=107,ConditionTextPopupPagesViewed=108,ConditionThreshold=109,ConditionTimePassed=110,ConditionTimer=111,ConditionTradeRouteCount=112,ConditionTutorialInteraction=113,ConditionUnlocked=114,ConditionUnlockList=115,Condition=116,ConditionPropsExecutionPlaceSettings=117,ConditionPropsNegatable=118,ConditionPropsSessionSettings=119,PreConditionList=120,Trigger=121,TriggerSequence=122,TriggerSetup=123,TriggerProgress=124,ConditionMoveVehicle=125,ConditionQuestBringVehicleToObject=126,
      ConditionQuestBusActivationNeedSaturation=127,ConditionQuestCameraMovement=128,ConditionQuestDecision=129,ConditionQuestDelivery=130,ConditionQuestDestroy=131,ConditionQuestDivingBell=132,ConditionQuestEscort=133,ConditionQuestExpedition=134,ConditionQuestFactoryProductivity=135,ConditionQuestFakeObjective=136,ConditionQuestFollowShip=137,ConditionQuestGamePadAction=138,ConditionQuestHitMovingTarget=139,ConditionQuestIslandsWithFertility=140,ConditionQuestItemUsed=141,ConditionQuestModuleBuildingEfficiency=142,
      ConditionQuestMonumentDestroyed=143,ConditionQuestPhotography=144,ConditionQuestPickup=145,ConditionQuestPicturePuzzle=146,ConditionQuestRecipeResearchCompleted=147,ConditionQuestResolveConfirmation=148,ConditionQuestSelectObject=149,ConditionQuestSellObjectToParticipant=150,ConditionQuestSmuggler=151,ConditionQuestStatusQuo=152,ConditionQuestSubQuest=153,ConditionQuestSustain=154,ConditionQuestTutorial=155,ConditionQuestUseItemInArea=156,ConditionStarterObject=157,ConditionQuestAirdrop=158,ConditionQuestObjective=159,
      ActionAddGoodsToItemContainer=160,ActionAddReputation=161,ActionAddResource=162,ActionApplyMemorization=163,ActionBankrupt=164,ActionBindItemToQuest=165,ActionBuff=166,ActionBuildObject=167,ActionChangeIncident=168,ActionChangeParticipant=169,ActionChangeSkin=170,ActionDelayedActions=171,ActionDeleteItem=172,ActionDeleteObjects=173,ActionDeleteStreets=174,ActionDiscoverIsland=175,ActionDiscoverParticipant=176,ActionEmptyFiniteResource=177,ActionEnableQuest=178,ActionEnableTicks=179,ActionEndQuest=180,ActionEnterSession=181,
      ActionExecuteActionByChance=182,ActionExecuteDiplomaticAction=183,ActionExecuteScript=184,ActionFinishMemorization=185,ActionForceDiplomaticRelation=186,ActionForceNewspaper=187,ActionHostileTakeover=188,ActionLoadSession=189,ActionLockAsset=190,ActionLoseGame=191,ActionMenuVisibility=192,ActionModifyVariable=193,ActionMoveObject=194,ActionMoveRiverLevel=195,ActionNotification=196,ActionPauseBuilding=197,ActionPlayCameraSequence=198,ActionPlayMovie=199,ActionPlaySound=200,ActionQueueNewspaperArticle=201,ActionRegisterTrigger=202,
      ActionRemoveFertility=203,ActionRemoveTrees=204,ActionReplaceItem=205,ActionResetBasin=206,ActionResetTrigger=207,ActionSetAudioState=208,ActionSetCamera=209,ActionSetIslandName=210,ActionSetIslandReservation=211,ActionSetObjectGUID=212,ActionSetObjectHitpoints=213,ActionSetObjectPosition=214,ActionSetObjectVariation=215,ActionSetObjectVisibility=216,ActionSetObjectVisualDamage=217,ActionSetQuestPoolEnablement=218,ActionSetSelection=219,ActionSetWeather=220,ActionSpawnObjects=221,ActionSpeechBubble=222,ActionStartFestival=223,
      ActionStartIncident=224,ActionStartObjectSequence=225,ActionStartQuest=226,ActionStartTreasureMapQuest=227,ActionStopIncident=228,ActionStopObjectMovement=229,ActionTimerAddTime=230,ActionTimerPause=231,ActionTriggerMinimapPing=232,ActionTriggerPopup=233,ActionTriggerTextBook=234,ActionTriggerTextPopup=235,ActionUnloadSession=236,ActionUnlockAsset=237,ActionUnlockIrrigationTypeForIsland=238,ActionWinGame=239,ActionSendUbisoftEvent=240,ActionOverwriteSeason=241,ActionSetNewSeasonPool=242,ActionMoveCameraSequence=243,Action=244,
      ActionLink=245,ActionList=246,OptionAudioSlider=247,OptionCombobox=248,OptionGrid=249,OptionSeparator=250,OptionSlider=251,OptionToggle=252,OptionHeadline=253,OptionGamepadButtonMapping=254,Matcher=255,MatcherCriterion=256,MatcherCriterionAnd=257,MatcherCriterionDiplomacyState=258,MatcherCriterionDropTarget=259,MatcherCriterionGuardable=260,MatcherCriterionGUID=261,MatcherCriterionHappinessMood=262,MatcherCriterionInteractable=263,MatcherCriterionIsland=264,MatcherCriterionMoveable=265,MatcherCriterionObjectState=266,
      MatcherCriterionObjectType=267,MatcherCriterionOr=268,MatcherCriterionOwner=269,MatcherCriterionProperty=270,CorporationScalingValue=271,CustomizableButtonConfig=272,EmptyAutoCreateValue=273,Blocking=274,Bridge=275,Building=276,BuildingModule=277,BuildingUnique=278,BusActivation=279,BusStop=280,Constructable=281,Culture=282,DistributionCenter=283,Dockland=284,FloorStackOwner=285,Hacienda=286,InfluenceSource=287,ItemCrafterBuilding=288,LoadingPier=289,MetaItemStorageAccess=290,ModuleOwner=291,Monument=292,Ornament=293,
      PalaceMonumentTracker=294,RepairCrane=295,Shipyard=296,Slot=297,StreetActivation=298,ThirdPartyObject=299,Upgradable=300,VisitorHarbor=301,WorkforceConnector=302,AnimalBase=303,AnimalFlock=304,FishShoal=305,Herd=306,ChannelTarget=307,DivingBellObject=308,FollowSpline=309,QuestObject=310,QuestTracker=311,Scanner=312,VisibilityRange=313,AssetPool=314,Attackable=315,Attacker=316,Bombarder=317,CampaignBehaviour=318,Collectable=319,Collector=320,CommandQueue=321,Craftable=322,DayNightReaction=323,DelayedConstruction=324,DivingBell=325,
      Draggable=326,Drifting=327,Dying=328,EcoSystemProvider=329,Exploder=330,FeedbackController=331,IceFloe=332,IceFloeDestroyer=333,Infolayer=334,InfotipObject=335,ItemReplacer=336,Lifetime=337,Mesh=338,MetaGameObjectReference=339,MetaPersistent=340,MinimapToken=341,MinimapTokenReplacement=342,MinimapTokenSettings=343,Nameable=344,Object=345,Painter=346,Pausable=347,PositionMarker=348,Projectile=349,ProjectileIncident=350,Prop=351,RandomDummySpawner=352,RandomMapObject=353,Rentable=354,ResearchCenter=355,Seamine=356,Selection=357,
      Sellable=358,ShipIncident=359,ShipMaintenance=360,Skin=361,Stance=362,Street=363,TradeRouteVehicle=364,Trailer=365,Tree=366,Walking=367,MusicInfluencer=368,Notes=369,CriticalError=370,DynamicVariation=371,NonCriticalError=372,Target=373,TargetGroup=374,ValueAssetMap=375,VariableValue=376,AmbientArea=377,BezierPath=378,Coastline=379,CommentBox=380,DistributionCenterMarker=381,FogBank=382,IslandUndiscover=383,Lake=384,MusicArea=385,River=386,WorkAreaPath=387,FeedbackBuildingGroup=388,FeedbackParametersGlobal=389,FeedbackSessionDescription=390,
      FeedbackSessionDescriptionOverwritable=391,TrafficFeedbackClass=392,TrafficFeedbackUnit=393,AnimalParametersGlobal=394,AnimalSessionDescription=395,RiverFeature=396,ActiveTradeFeature=397,AttractivenessFeature=398,BlacklistFeature=399,BuildModeFeature=400,ConstructionAIFeature=401,CoopFeature=402,DayNightFeature=403,DiscoveryFeature=404,EconomyStatisticFeature=405,EcoSystemFeature=406,ElectricityFeature=407,FirstPersonFeature=408,GameSpeedFeature=409,GameUpdateFeature=410,HappinessFeature=411,HarborPropFeature=412,HardFarmsFeature=413,HeatFeature=414,
      HighscoreFeature=415,HostileTakeoverFeature=416,InfluenceFeature=417,IrrigationConfig=418,ItemTransferFeature=419,KontorFeature=420,MilitaryFeature=421,MovementFeature=422,ParticipantRepresentationFeature=423,PassiveTradeFeature=424,PlayerCounterConfig=425,RailwayFeature=426,RealWindFeature=427,ResearchFeature=428,RiverSlotFeature=429,RuinNotificationFeature=430,SelectionFeature=431,SessionTransferFeature=432,SettlementRights=433,SkinDescriptionFeature=434,StreetFeature=435,StreetOverlayFeature=436,TourismFeature=437,TrackingFeature=438,TradeContractFeature=439,
      TradeRouteFeature=440,WeatherFeature=441,WinLoseFeature=442,WorkforceTransferFeature=443,WorldMarketFeature=444,ScenarioItemTradeFeature=445,FlotsamFeature=446,PlaystationActivitiesFeature=447,SeasonFeature=448,Season=449,SeasonPool=450,FertilitySet=451,MapGeneratorInput=452,MapTemplate=453,MineSlotResourceSet=454,RandomIsland=455,ResourceSetCondition=456,CharacterInteractionConfig=457,DiplomacyConfig=458,CityAttractivenessNewsTracker=459,DiplomacyNewsTracker=460,HostileTakeoverNewsTracker=461,IncidentNewsTracker=462,IncomeBalanceNewsTracker=463,
      IslandSettledNewsTracker=464,MilitaryNewsTracker=465,MonumentNewsTracker=466,NeedsSatisfactionNews=467,NeedsSatisfactionNewsTracker=468,NewsTrackerBase=469,ObjectBuildNewsTracker=470,OverallSatisfactionNewsTracker=471,QuestNewsTracker=472,ShipBuiltNewsTracker=473,UnlockNewsTracker=474,WorkforceNewsTracker=475,WorkforceSliderNewsTracker=476,NewsArticleList=477,NewspaperArticle=478,NewspaperBalancing=479,NewspaperImage=480,NewspaperSpecialEditionArticle=481,OnlineMarketBalancing=482,OnlineMarketVisual=483,FirstPartyConfig=484,OnlineConfig=485,PlatformServicesConfig=486,
      Available=487,Computer=488,DifficultySetup=489,GameSetup=490,Human=491,Map=492,RandomMap=493,BannerConfig=494,CampaignSetupUnlocks=495,Chat=496,Quickmatch=497,MultiplayerConfig=498,Godlike=499,ResearchSubcategory=500,BuildingBaseTiles=501,BuildPermit=502,BuildPermitGroup=503,CameraSettings=504,ColorConfig=505,Cost=506,DifficultySettings=507,GlobalConfig=508,GoodValueBalancing=509,GUIConfig=510,InputConfig=511,ItemInfotipTextFeature=512,Locked=513,ObjectPool=514,ProgressBalancing=515,ProgressLevel=516,QuestConfig=517,RewardConfig=518,CreativeModeBalancing=519,
      AttractivenessNotification=520,AudioNotification=521,BaseNotification=522,CampaignNotification=523,CharacterNotification=524,MainNotification=525,NotificationSubtitle=526,OnScreenNotification=527,PalaceNotification=528,SideNotification=529,Notification=530,NotificationConfiguration=531,IncidentBuffConfig=532,IncidentOverlayConfig=533,MaintenanceBarConfig=534,ObjectMenuBlueprintScene=535,ObjectmenuCityInstitutionScene=536,ObjectmenuCommuterHarbourScene=537,ObjectMenuGuildHouseScene=538,ObjectmenuHeader=539,ObjectmenuKontorScene=540,ObjectmenuPalace=541,
      ObjectmenuPierScene=542,ObjectmenuProductionScene=543,ObjectmenuResearchCentreScene=544,ObjectMenuResidenceHappinessSceneConfig=545,ObjectmenuResidenceScene=546,ObjectMenuScenarioRuinScene=547,ObjectmenuShipScene=548,ObjectMenuShipYardScene=549,ObjectmenuVisitorHarborScene=550,DropGoodPopup=551,ObjectMenuCoalOilHarbour=552,ConstructionMenu=553,ShipListConfig=554,ItemCategory=555,ItemFilter=556,ItemKeywords=557,ItemSearchConfig=558,KeywordFilter=559,ProductFilter=560,ProductList=561,ScenarioGameOverScene=562,ScenarioLoadingScene=563,RightClickMenu=564,
      ActiveTradeScene=565,AttractivenessPopup=566,CharacterNotificationScene=567,ChatNotificationScene=568,ConstructionRadialScene=569,CraftingPopup=570,CreateGameScene=571,CreditsScene=572,CursorScene=573,DecisionQuestNarrativeBook=574,DLCPromotionScene=575,DifficultySettingsScene=576,DiplomacyScene=577,DocklandsScene=578,ExpeditionOverviewScene=579,IconInfolayerScene=580,InfluencePopup=581,IslandBarPollutionScene=582,IslandBarScene=583,IslandStorage=584,ItemFiltersScene=585,LoadingScene=586,MinimapScene=587,MonumentScene=588,MPLobbyScene=589,MPQuickMatchLobbyScene=590,
      NavigationMenuScene=591,NewspaperScene=592,OnlineMarketScene=593,OnScreenNotificationScene=594,OptionsScene=595,PauseMenuScene=596,ProfileSelectionScene=597,QuestBookScene=598,QuestTrackerScene=599,RecipeBuildingScene=600,ResearchCentreScene=601,ResourceBarScene=602,SessionScene=603,SessionTradeRouteOverviewScene=604,SessionTradeRoutesScene=605,SessionTradeTransfer=606,ShipMenuRadial=607,SideNotificationsArchive=608,SideNotificationScene=609,StatisticMenu=610,StrategicMapScene=611,TreasureMapScene=612,WorkforceMenu=613,OnScreenIconScene=614,ItemTransferScene=615,
      RubberDotsIcon=616,ScenarioWorkshopScene=617,MonumentEventScene=618,HostileTakeoverScene=619,ScreenCaptureScene=620,CustomizeModeScene=621,TitleScene=622,DesyncScene=623,FilteredSelectionPopup=624,GenericPopup=625,NegotiationPopup=626,TextPopup=627,TextPopupLayoutData=628,ModPopup=629,SettingsMenu=630,StaticHelpConfig=631,StaticHelpTopic=632,TutorialUiElement=633,TutorialUiBalancing=634,ConstructionCategory=635,FontRendering=636,GamepadCursor=637,InfolayerConfig=638,InfoLayerIcon=639,InfoTip=640,InfoTipBalancing=641,InteractionFeedback=642,MainMenuNavigationConfig=643,
      MouseCursor=644,NewspaperEffectIcon=645,PassiveTradeWindow=646,ProductionChain=647,ShipList=648,Startup=649,WorldMapCardConfig=650,WorldMapConfig=651,AmbientMoodProvider=652,Audio=653,AudioLink=654,AudioText=655,GameParameter=656,GlobalSoundEventConfig=657,MetaSoundConfig=658,MusicSoundConfig=659,RequiredSoundBanks=660,RFX=661,RFXList=662,SessionSoundConfig=663,SoundBank=664,SoundEmitter=665,SoundEmitterCommandBarks=666,StateChoice=667,StateGroup=668,SwitchChoice=669,SwitchGroup=670,UISoundConfig=671,WorldMapDynamicSoundEmitter=672,WorldMapSound=673,WwiseStandard=674,
      WwiseTrigger=675,Expedition=676,ExpeditionAttribute=677,ExpeditionDecision=678,ExpeditionEvent=679,ExpeditionEventPool=680,ExpeditionFeature=681,ExpeditionMapOption=682,ExpeditionOption=683,ExpeditionSlot=684,ExpeditionThreat=685,ExpeditionTrade=686,QPCDMultiplerHappiness=687,QPCDMultiplierBase=688,DecisionQuestFixer=689,Objectives=690,PlayerCounterContextPool=691,Quest=692,QuestDynamicPriority=693,QuestLine=694,QuestMain=695,QuestOptional=696,QuestPool=697,RegionRewardPool=698,ResourceRewardPool=699,Reward=700,RewardPool=701,Island=702,Region=703,Session=704,
      TransitionConfig=705,WorldMap=706,Video=707,VideoSubtitle=708,CorporationProfile=709,PlayerLogo=710,Portrait=711,ConstructionAI=712,EventTrader=713,ItemCrafter=714,MilitaryAI=715,Pirate=716,ThirdParty=717,Trader=718,BuyShares=719,Diplomacy=720,ExpeditionUser=721,Highscore=722,Interaction=723,ItemTransferHandler=724,KontorOwner=725,MetaBuffHandler=726,MetaBuildPermits=727,MetaInfluence=728,ParticipantMessageObject=729,ParticipantMessages=730,Profile=731,ProfileCounter=732,UniqueBuildingHandler=733,CraftableItem=734,EffectContainer=735,EffectForward=736,Item=737,
      ItemAction=738,ItemConfig=739,ItemContainer=740,ItemEffect=741,ItemEffectTargetPool=742,ItemReplacementPool=743,ItemSocketSet=744,ItemStartExpedition=745,ItemWithUI=746,SpecialAction=747,VisualEffectWhenActive=748,CameraSequence=749,Achievement=750,AchievementBalancing=751,AchievementReward=752,UplayAction=753,UbisoftChallenge=754,DlcController=755,UplayProduct=756,UplayProductPromotion=757,UplayReward=758,MapGenerator=759,JiraManager=760,Recipe=761,RecipeBuilding=762,RecipeList=763,BombardmentAmmo=764,BuffFactory=765,Distribution=766,EconomyFeature7=767,
      Electrifiable=768,Factory7=769,FactoryBase=770,Fertility=771,FreeAreaProductivity=772,Heated=773,HeatProvider=774,Industrializable=775,IrrigationSource=776,ItemTransfer=777,LogisticNode=778,Maintenance=779,Market=780,ModuleIrrigation=781,MonoCulture=782,Motorizable=783,Palace=784,PalaceMinistry=785,PopulationGroup7=786,PopulationLevel7=787,Postbox=788,Powerplant=789,Product=790,ProductStorageList=791,PublicService=792,Residence7=793,StorageBase=794,TrainStation=795,Transporter7=796,Warehouse=797,Watered=798,GeneralIncidentConfiguration=799,Incident=800,
      IncidentArcticIllness=801,IncidentCommunication=802,IncidentEffectConfiguration=803,IncidentExplosion=804,IncidentFestival=805,IncidentFire=806,IncidentIllness=807,IncidentInfectable=808,IncidentInfluencer=809,IncidentResolver=810,IncidentResolverUnit=811,IncidentResolverUpkeep=812,IncidentRiot=813,AttackableUpgrade=814,AttackerUpgrade=815,Buff=816,BuildingUpgrade=817,CultureSet=818,CultureUpgrade=819,DistributionUpgrade=820,DivingBellUpgrade=821,EcoSystemProviderUpgrade=822,EcoSystemUpgrade=823,FactoryUpgrade=824,HeaterUpgrade=825,IncidentInfectableUpgrade=826,
      IncidentInfluencerUpgrade=827,IndustrializableUpgrade=828,InfluenceSourceUpgrade=829,IrrigationUpgrade=830,ItemContainerUpgrade=831,KontorUpgrade=832,ModuleOwnerUpgrade=833,MonumentUpgrade=834,NewspaperUpgrade=835,PassiveTradeGoodGenUpgrade=836,PierUpgrade=837,PopulationUpgrade=838,PowerplantUpgrade=839,ProjectileUpgrade=840,RepairCraneUpgrade=841,ResidenceUpgrade=842,ResourceUpgrade=843,ShipyardUpgrade=844,TradeShipUpgrade=845,UpgradeList=846,VehicleUpgrade=847,VisitorHarborUpgrade=848,VisitorUpgrade=849,WarehouseUpgrade=850,TextSourceFormatting=851,RatingAdjacentBlocks=852,
      RatingBlockRegularity=853,RatingBuildableWithinRadius=854,RatingCityBlockOverride=855,RatingCompactness=856,RatingConnectorDistanceToPipe=857,RatingDistance=858,RatingFragmentation=859,RatingFreeformInnerRatio=860,RatingFreeStanding=861,RatingHarborConnected=862,RatingHarborDefense=863,RatingHarborOffice=864,RatingHindersBlockExpansions=865,RatingInsideTiles=866,RatingNearestBuilding=867,RatingNeighborTiles=868,RatingNotIrrigatedTiles=869,RatingOverwrittenBlocks=870,RatingProductionChainProximity=871,RatingProvideBoosterCoverage=872,RatingProvideLogisticCoverage=873,
      RatingProvidePublicCoverage=874,RatingPublicCoverage=875,RatingPublicOverlap=876,RatingStreetPointsToWarehouse=877,RatingSubRect=878,GlobalConstructionAIBalancing=879,PlacementScore=880,OnlineEvent=881,MonumentEvent=882,MonumentEventCategory=883,Test234=884,Test345=885,Test456=886,TestVisibility=887,TestVisibilityACA=888,AttractivenessConsoleScene=889,NewspaperConsoleScene=890,SessionTradeRouteConsoleScene=891,StrategicMapConsoleScene=892,SystemPopupConsoleScene=893,MonumentConsoleScene=894,RuinedStateBalancing=895,TransferGoodsConsoleScene=896,IslandDetailConsoleScene=897,
      GamepadButtonPromptScene=898,WorkforceConsoleScene=899,CulturalBuildingPopupConsoleScene=900,ObjectMenuShipYardConsoleScene=901,ConsoleOptionScene=902,AdvancedDifficultiesConsoleScene=903,MPLobbyConsoleScene=904,DLCOverviewConsoleScene=905,DLCPromotionPopupConsoleScene=906,ResidenceUpgradeFeature=907,BuildModeBalancing=908,ErrorMessageBalancing=909,SelectionsBalancing=910,TargetBalancing=911,GamepadWorldmapConfig=912,VirtualKeyboardBalancing=913,PlatformBalancing=914,ButtonPromptAppearanceConfig=915,GamepadButtonMapping=916,GamepadConfig=917,GamepadVibrationEffect=918,
      ScenarioBalancing=919,ScenarioMetaInfo=920,ScenarioMetaInfoInternal=921,ScenarioSelectionMarker=922,ScenarioCurrencyFixer=923,ScenarioWorkshopItem=924,ScenarioWorkshopPackage=925}


    -- ###################################################################################################
    -- ###################################################################################################
    -- ###################################################################################################

    -- Converter Functions between IDs as number and IDs as table
    -- logic found out by Taubenangriff, technical code written by nyk/pnski, code structure by Serp 

    -- ###################################################################################################

    -- An Area is for the game most of the time identical to the term island (exception eg. the ketema island, which has 2 Areas).

    -- Areatable is a table (eg returned from Object.Area.ID/ts.Area.Current.ID eg. AreaID={SessionID=2,IslandID=1,AreaIndex=1})
    local function AreatableToAreaID(Areatable,to_type)
      if type(Areatable)=="table" then
        local AreaIndex,IslandID,SessionID = Areatable["AreaIndex"],Areatable["IslandID"],Areatable["SessionID"]
        if type(AreaIndex)=="number" and type(IslandID)=="number" and type(SessionID)=="number" then
          local AreaID = ((AreaIndex << 13)+(IslandID << 6)+SessionID)
          return AreaID
        end
      end
    end
    local function AreaIDToAreatable(AreaID)
      if type(AreaID)=="number" then
        local AreaIndex = ((AreaID & 0xE000) >> 13)
        local IslandID = ((AreaID & 0x1FC0) >> 6)
        local SessionID = (AreaID & 0xF)
        return {AreaIndex=AreaIndex, IslandID=IslandID, SessionID=SessionID}
      end
    end
    -- info:
     -- wenn in textsourcelist.json zb bei AreaFromID steht es will ein "int", dann meint es eben diese AreaID-zahl.
     -- Wenn da steht es will "Type" : "AreaID", dann meint es die Tabellenform.
     -- oder hier wieder Zahl bei GetGameObject: "gameObjectID" : "Type" : "rduint64"

    -- OIDtable = {ObjectID=33,AreaID={SessionID=2,IslandID=0,AreaIndex=0}}
    -- you get such table eg from userdata:getOID() or you build it yourself.
    -- AreaID within OIDtable is a table (eg returned from Object.Area.ID/ts.Area.Current.ID) or AreaID is already converted to a number. (beware ts.Area.Current.ID returns rubbish while user is over water or on worldmap: {SessionID=16,IslandID=122,AreaIndex=6})
    -- Ships (walkables) always have AreaIndex and IslandID of 0
    -- ObjectID is in increasing number for every newly created object. It starts from 1 for every Areatable-combination (so for each session for each IslandID and each AreaIndex it starts from 1) 
    -- Objects leaving the session and then come back, will get a new ObjectID (it seems the old one is abandoned)
    -- ts.GetGameObject and other functions expect the integer OID, not the table
    local function OIDtableToOID(OIDtable,to_type)
      local AreaID, ObjectID,EditorFlag,EditorChunkID
      if type(OIDtable)=="table" then 
        ObjectID = OIDtable["ObjectID"]
        EditorFlag = OIDtable["EditorFlag"] or 0
        EditorChunkID = OIDtable["EditorChunkID"] or 0
        if type(OIDtable["AreaID"])=="table" then
          AreaID = AreatableToAreaID(OIDtable["AreaID"])
        elseif type(OIDtable["AreaID"])=="number" then
          AreaID = OIDtable["AreaID"]
        end
      end
      if type(ObjectID)=="number" and type(AreaID)=="number" then
        local OID = ((AreaID << 32) + (ObjectID) + (EditorFlag << 63) + (EditorChunkID << 50))
        return g_LuaTools.my_to_type(OID,to_type)
      end
    end

    -- TODO:  noch berechnen wie hier die Editordinge rauskommen , keine ahnuhn wie
    -- Dannach überlegen wie wir das hier umändern, ob wir immer mit bint rechnen und immer string/bint returnen
     -- oder nur wennse zu groß sind? ts.GetGameObject kann nicht mit string arbeiten, weshalb man da dann zu DoForSessionGameObject greifen muss
     -- -> immer number returnen, außer wenn Editorkram übergeben wird, dann string
      -- und die aufrufende Fkt muss dann selbst prüfen was sie zurückbekommen hat?
    -- und mal testweise dann durch alle editorobjecte loopen und rausfinden warum deren ObjectID so hoch ist,
     -- zb der Kontor von den thirdparties ist eben oft nicht 1. sind dann die objecte auf der insel alle höher oder gibts auch niedrigere
      -- (dann für editor objekte eben nicht die KontorObjectID als startpunkt für suche nehmen)
    local function OIDToOIDtable(OID)
      if type(OID)=="number" then
        local AreaID = ((OID) >> 32)
        local ObjectID = (OID & 0xFFFFFFFF)
        local Areatable = AreaIDToAreatable(AreaID)
        return {ObjectID=ObjectID,AreaID=Areatable} -- named AreaID although its a table, because this is what the game expects as OIDtable format
      end
    end

    -- alternative function to get_oid_int (instead of :getOID + OIDtableToOID)
    -- it also works for EditorFlag and other special objects we don't have the formula yet
    local function get_OID(userdata,to_type)
      local oid,Namestring
      to_type = to_type or "number" -- for editor objects string/bint might be better, because number is too high for lua
      Namestring = userdata:getName() -- returns eg. "GameObject, oid 8589934647", while :getOID returns a OIDtable.
      if Namestring~=nil and type(Namestring)=="string" then
        oid = string.match(Namestring, "oid (.*)")
        if oid~=nil and type(oid)=="string" then
          oid = g_LuaTools.my_to_type(oid,to_type)
        end
      end
      return oid
    end

    -- ###################################################################################################
    -- ###################################################################################################
    -- ###################################################################################################

    -- Find Objects functions

    -- ###################################################################################################
    
    -- updates ObjectFinderCacheSerp.ObIDs LowObID and HighObID for objects owned by local player in current session 
     -- This is just the current situation is active session. Especially HighObID increases every time a new object is built/sent between sessions.
     -- Als also LowObID can increase, eg. on island takeover (but for that we already do arealoop to get all Kontor_OID)
     -- So at best only call this yourself directly before calling GetCurrentSessionObjectsFromAnyone and provide HighObID as ToObjectID to make it more efficient
    -- use Walkable for everything with AreaIndex/IslandIndex=0 (ships/airships/units)
    -- use Building for everything tied to an Island
    -- ... An sich braucht man die Fkt eigentlich selten... denn wenn man einen Peer als Owner und in der Session hat,
        -- wovon man ein Objekt sucht, dann kann man gleich GetCurrentSessionObjectsFromLocaleByProperty nach einem passenden Property
         -- durchsuchen und findet das Objekt direkt, was man dann teilt.
      -- Performance ist aber gut, selbst in giga spielstand in größter Session dauert Building+Walking nur klitzekleinen Ruckler
    -- Wenns nicht um eigenes in eigener session geht, dann am besten SpawnMaxObjIdHelpers nutzen
    local function GetHighestObIDsLocalPlayerCurrentSessionByProperty(Property)
      local ret = g_ObjectFinderSerp.GetCurrentSessionObjectsFromLocaleByProperty(Property)
      for OID,objinfo in pairs(ret.Objects) do
        local OIDtable = g_ObjectFinderSerp.IDConverter.OIDToOIDtable(OID)
        local ObjectID = OIDtable.ObjectID
        local AreaID = g_ObjectFinderSerp.IDConverter.AreatableToAreaID(OIDtable.AreaID)
        local SessionID = OIDtable.AreaID.SessionID
        -- local IslandID = OIDtable.AreaID.IslandID
        -- local AreaIndex = OIDtable.AreaID.AreaIndex
        if g_ObjectFinderSerp.ObjectFinderCacheSerp.ObIDs[SessionID]==nil then
          g_ObjectFinderSerp.ObjectFinderCacheSerp.ObIDs[SessionID] = {}
        end
        local CacheObIDsSessionID = g_ObjectFinderSerp.ObjectFinderCacheSerp.ObIDs[SessionID]
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
      g_LuaTools.start_thread("reset HighObID",ModID,function()
        g_LuaTools.waitForTimeDelta(10000)
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
    local function GetCurrentSessionObjectsFromLocaleByProperty(Property)
      local PropertyID
      if type(Property)=="number" then
        PropertyID = Property
      elseif type(Property)=="string" then
        PropertyID = PropertiesStringToID[Property]
      end
      local GUID,OID
      local Objects = {}
      local SessionGuid = session.getSessionGUID() -- only current session is found by getObjectGroupByProperty
      local ParticipantID = ts.Participants.GetGetCurrentParticipantID() -- finds only objects from local player
      if PropertyID~=nil then
        local userdatas = session.getObjectGroupByProperty(PropertyID) -- game.MetaGameManager finds the same like session...
        if type(userdatas)=="table" and #userdatas>0 then
          for k,userdata in ipairs(userdatas) do
            if userdata~=nil then -- is never nil, but nullpointer if not assigned. but here it should always be assigned
              OID = g_ObjectFinderSerp.IDConverter.get_OID(userdata)
              GUID =  ts.Objects.GetObject(OID).GUID
              if GUID~=0 then -- is not the case here, but just to be save
                Objects[OID] = {GUID=GUID, userdata=userdata,OID=OID}
              end
            end
          end
        end
      end
      return {SessionGuid=SessionGuid, ParticipantID=ParticipantID, Objects=Objects}
    end

    -- ###################################################################################################
    -- ###################################################################################################

    -- this function searches for the Neutral (GUID 34)SessionParticipant GameObject in the given SessionID, to find out if the session is already loaded and valid and check what SessionGuid it is
    -- (we use Neutral instead of local player, because neutral is created first and also exists in loaded sessions the player was not yet into, while locale SessionParticipant does not exist in this case yet)
     -- dontusecache ist eig nur sinnvoll, wenn wir davon ausgehen, dass jemand eine Session unloaded, was wohl eher nie passiert
    local function IsLoadedSessionByID(SessionID,dontusecache)
      if not dontusecache then
        if g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessions[SessionID]~=nil then
          return g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessions[SessionID]
        elseif g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessionsParticipants[SessionID]~=nil and g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessionsParticipants[SessionID][g_ObjectFinderSerp.PID_Neutral]~=nil then
          return g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessionsParticipants[SessionID][g_ObjectFinderSerp.PID_Neutral].SessionGuid
        end
      end
      local IslandID,AreaIndex = 0,0
      local SessionGuid
      local AreaID = g_ObjectFinderSerp.IDConverter.AreatableToAreaID({SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex})
      for ObjectID=1,10 do -- to find  Neutral SessionParticipant checking the first 10 ObjectIDs should be enough
        OID = OIDtableToOID({ObjectID=ObjectID,AreaID=AreaID})
        local GUID = ts.GetGameObject(OID).GUID
        local sGUID = ts.Participants.GetParticipant(g_ObjectFinderSerp.PID_Neutral).Guid -- Meta and SessionParticipant have the same GUID. using Meta here because they always exist, while Session may only exist in a specific one (although we only use P who exist everywhere)
        -- if SessionID==6 and GUID~=0 then
          -- print(GUID)
        -- end
        if GUID==sGUID then
          SessionGuid = ts.GetGameObject(OID).SessionGuid
          if SessionGuid~=1500005538 then -- is my empty fake session. worldmap 180039 has not Neutral participant I think
            if g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessionsParticipants[SessionID]==nil then
              g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessionsParticipants[SessionID] = {}
            end
            g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessionsParticipants[SessionID][g_ObjectFinderSerp.PID_Neutral] = {OID=OID,PID=g_ObjectFinderSerp.PID_Neutral,GUID=GUID,SessionGuid=SessionGuid,ObjectID=ObjectID,AreaID=AreaID,SessionID=SessionID}
            if g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[SessionID]==nil then
              g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[SessionID] = {}
            end
            g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessions[SessionID] = SessionGuid
            return SessionGuid
          end
        end
      end
    end
    
    -- could also use instead game.isSessionLoadingDone(CheckingSessionGuid) ? But we would need a complete list of all ever exsiting session guids, which we dont have.
    local function GetLoadedSessions(FromSessionID,ToSessionID,dontusecache)
      local Sessions = {}
      FromSessionID = FromSessionID or 1
      ToSessionID = ToSessionID or g_ObjectFinderSerp.l_MaxSessionID
      for SessionID=FromSessionID,ToSessionID do
        CheckingSessionGuid = (not dontusecache and g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessions[SessionID]) or g_ObjectFinderSerp.IsLoadedSessionByID(SessionID,dontusecache)
        if CheckingSessionGuid~=nil then
          Sessions[SessionID] = CheckingSessionGuid
          g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessions[SessionID] = CheckingSessionGuid
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
          local AreaID = g_ObjectFinderSerp.IDConverter.AreatableToAreaID({SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex})
          for ObjectID=1,100 do
            OID = OIDtableToOID({ObjectID=ObjectID,AreaID=AreaID})
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

    -- eg. sGUID=34 -> Neutral
    -- SessionParticipants alawys gets the instance in the current session from the local player
    -- so to check/change the Nameable from the SParticipants in the current active session we can always use this.
     -- But if we want also to access the ones in the other sessions, we need their OID (and then use GetGameObject to access Name and DoForSessionGameObject to change name)
    -- Give this function a list of PIDs and it will find all seperate GameObjects in each loaded session (SessionParticipants). SessionGuid can be nil to get all loaded sessions
    local function GetAllLoadedSessionsParticipants(PIDs,sSessionGuid,sSessionID)
      -- g_LuaTools.modlog("GetAllLoadedSessionsParticipants called",ModID) -- testing if it loads in savegame correctly
      local PIDs_GUIDs = {}
      for i,PID in ipairs(PIDs) do
        PIDs_GUIDs[PID] = ts.Participants.GetParticipant(PID).Guid -- Meta and SessionParticipant have the same GUID. using Meta here because they always exist, while Session may only exist in a specific one (although we only use P who exist everywhere)
      end
      
      local FromSessionID = sSessionID or 1
      local ToSessionID = sSessionID or g_ObjectFinderSerp.l_MaxSessionID
      local sessionparticipants = {}
      local update_done = false
      for SessionID=FromSessionID,ToSessionID do
        local SessionGuid = g_ObjectFinderSerp.IsLoadedSessionByID(SessionID)
        if SessionGuid~=nil and (sSessionGuid==nil or sSessionGuid=="First" or sSessionGuid==SessionGuid) then
          sessionparticipants[SessionID] = {}
          
          -- g_LuaTools.modlog("GetAllLoadedSessionsParticipants before dothesearch?",ModID) -- testing if it loads in savegame correctly

          local dothesearch = false -- check if we already have it in cache (SessionParticipants do not change ever (except for newly loaded sessions))
          if g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessionsParticipants[SessionID]==nil then
            g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessionsParticipants[SessionID] = {}
            g_ObjectFinderSerp.ObjectFinderCacheSerp.Changed = true
            dothesearch = true
          else -- already have it in cache?
            for i,PID in ipairs(PIDs) do
              if g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessionsParticipants[SessionID][PID]==nil then
                dothesearch = true  -- at least one is missing. and we need to loop over all objects anyway to find it, so fine to do all others again too
              end
            end
          end
          -- g_LuaTools.modlog("GetAllLoadedSessionsParticipants after dothesearch?",ModID) -- testing if it loads in savegame correctly
          if dothesearch then
            -- g_LuaTools.modlog("GetAllLoadedSessionsParticipants NOT used Cache :(",ModID) -- testing if it loads in savegame correctly
            update_done = true
            local IslandID,AreaIndex = 0,0
            local AreaID = g_ObjectFinderSerp.IDConverter.AreatableToAreaID({SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex})
            for ObjectID=1,100 do
              OID = OIDtableToOID({ObjectID=ObjectID,AreaID=AreaID})
              local GUID = ts.GetGameObject(OID).GUID
              if GUID~=0 and g_LuaTools.table_contains_value(PIDs_GUIDs,GUID) then
                local PID = ts.GetGameObject(OID).Owner -- will be the original PID in PIDs
                sessionparticipants[SessionID][PID] = {OID=OID,PID=PID,GUID=GUID,SessionGuid=SessionGuid,ObjectID=ObjectID,AreaID=AreaID,SessionID=SessionID}
                g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessionsParticipants[SessionID][PID] = {OID=OID,PID=PID,GUID=GUID,SessionGuid=SessionGuid,ObjectID=ObjectID,AreaID=AreaID,SessionID=SessionID}
                g_ObjectFinderSerp.ObjectFinderCacheSerp.Changed = true
              end
            end
          else -- use cache
            -- g_LuaTools.modlog("GetAllLoadedSessionsParticipants used Cache :)",ModID) -- testing if it loads in savegame correctly
            sessionparticipants[SessionID] = g_LuaTools.deepcopy(g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessionsParticipants[SessionID])
          end
          if sSessionGuid=="First" then -- only the first found loaded session needed?
            return sessionparticipants
          end
        end
      end
      return sessionparticipants
    end




    -- ###################################################################################################

    
      

     -- GetCurrentSessionObjectsFromAnyone
    -- Objects from session the locale player is in curently, but from anyone.
    -- Similar code like GetAnyObjectsFromAnyone, but much simpler and used if you only need current session (other sessions only work very limited)

    -- Does not work for objects with EditorFlag, which are mostly objects at the map from beginning, like Pirate/Archibald harbor/objects. (because their OID is higher than lua can handle eg archibald harbor 9223413826886612345)
    -- see also my comments below for GetAnyObjectsFromAnyone
    -- function GetCurrentSessionObjectsFromAnyone(myargs)
      -- local ObjectFilter,FromSessionID,ToSessionID,FromIslandID,ToIslandID,FromAreaIndex,ToAreaIndex,FromObjectID,ToObjectID,withyield,nosave = myargs["ObjectFilter"],myargs["FromSessionID"],myargs["ToSessionID"],myargs["FromIslandID"],myargs["ToIslandID"],myargs["FromAreaIndex"],myargs["ToAreaIndex"],myargs["FromObjectID"],myargs["ToObjectID"],myargs["withyield"],myargs["nosave"]
      -- local Objects = {}
      -- local AreaID,OID,CheckingSessionGuid
      -- local filterresult,AreaOwnerName,AreaOwner,Kontor_OIDtable,Kontor_OID,objectcount,HighestObjectID,LowestObjectID,GUID,SessionGuid,ParticipantID,userdata,sessionisloaded,CheckingSessionGuid
      -- local ExecutingSessionGUID = session:getSessionGUID()
      -- FromSessionID = FromSessionID or 1
      -- ToSessionID = ToSessionID or g_ObjectFinderSerp.l_MaxSessionID
      -- FromIslandID = FromIslandID or 0 -- is 0 for eg. ships and other things not bound to islands
      -- ToIslandID = ToIslandID or g_ObjectFinderSerp.l_MaxIslandID
      -- FromAreaIndex = FromAreaIndex or 0 -- is 0 for eg. ships and other things not bound to islands
      -- ToAreaIndex = ToAreaIndex or 1 -- can be 2 for islands sharing two owners , like ketema island. but unlikely that we need it, so default to only 1
      -- FromObjectID_ = FromObjectID or 1 -- removed objects/ships leaving session leave empty OBjectIDs, so sometimes, especially on takeover of islands, the first valid ObjectID might be in the tenthousands.
      -- ToObjectID_ = ToObjectID or 1000000 -- on very big/old savegames you should check up to 1 million or even more ... better try to save/check your current lowest/highest OID and enter lower number here
      -- for SessionID=FromSessionID,ToSessionID do
        -- CheckingSessionGuid = g_ObjectFinderSerp.IsLoadedSessionByID(SessionID)
        -- if ExecutingSessionGUID == CheckingSessionGuid then -- here we only chek the current session
          -- if g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[SessionID]==nil then
            -- g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[SessionID] = {}
          -- end
          -- if g_ObjectFinderSerp.ObjectFinderCacheSerp.ObIDs[SessionID]== nil then
            -- g_ObjectFinderSerp.ObjectFinderCacheSerp.ObIDs[SessionID] = {}
            -- g_ObjectFinderSerp.ObjectFinderCacheSerp.Changed = true
          -- end
          -- for IslandID=FromIslandID,ToIslandID do
            -- for AreaIndex=FromAreaIndex,ToAreaIndex do
              -- if not ((IslandID==0 and AreaIndex~=0) or (IslandID~=0 and AreaIndex==0)) then -- on water both are 0. on islands none of them is 0, so do not allow only one of them being 0.
                -- AreaID = AreatableToAreaID({SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex})
                -- local CacheObIDsSessionID = g_ObjectFinderSerp.ObjectFinderCacheSerp.ObIDs[SessionID] -- I think its better for performance to save it in a variable
                -- if CacheObIDsSessionID[AreaID]== nil then
                  -- CacheObIDsSessionID[AreaID] = {}
                -- end
                -- if not CacheObIDsSessionID[AreaID]["invalid"] then
                  -- AreaOwnerName = ts.Area.GetAreaFromID(AreaID).OwnerName -- check if the Area is valid
                  -- AreaOwner = ts.Area.GetAreaFromID(AreaID).Owner
                  -- if IslandID~=0 and (AreaOwnerName=="" and AreaOwner==0) then -- invalid area. while for unsettled area owner will be -1. (OwnerName is better than Owner here, because invalid areas are nullpointer and would return 0 for Owner, which also might be Human0 on valid areas)
                    -- CacheObIDsSessionID[AreaID]["invalid"] = true -- remember this Area as invalid, so we don't have to check it ever again.
                    -- g_ObjectFinderSerp.ObjectFinderCacheSerp.Changed = true
                  -- end

                  -- if not CacheObIDsSessionID[AreaID]["invalid"] then
                    -- if withyield then
                      -- coroutine.yield()
                    -- end
                    -- FromObjectID_ = FromObjectID or 1 -- we changed it below based on Cache potentially for the previous Area. so change it to default here again.
                    -- ToObjectID_ = ToObjectID or 1000000
                    
                    -- Kontor_OIDtable = ts.Area.GetAreaFromID(AreaID).KontorID
                    -- Kontor_OID = OIDtableToOID(Kontor_OIDtable)
                    
                    -- g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[SessionID][AreaID] = {OID=Kontor_OID,AreaOwner=AreaOwner,Owner=ts.Objects.GetObject(Kontor_OID).Owner}-- filling it like this makes sure that outdated information is automatically overwritten
                    
                    -- if IslandID==0 or AreaOwnerName~="" then -- if not Water (IslandID==0), make sure Area is owned by someone
                      
                      -- if IslandID~=0 and Kontor_OIDtable["ObjectID"]~=nil and Kontor_OIDtable["ObjectID"]~=0 then -- assuming the KontorObjectID is always the lowest on an island, it makes sense to set LowObID to this value. If we assume that there may be exceptions to this, then we can not use it at all...
                        -- if CacheObIDsSessionID[AreaID].LowObID~=nil and Kontor_OIDtable["ObjectID"]~=CacheObIDsSessionID[AreaID].LowObID then
                          -- g_LuaTools.modlog("GetCurrentSessionObjectsFromAnyone KontorObjectID "..tostring(Kontor_OIDtable["ObjectID"]).." is unequal LowObID "..tostring(CacheObIDsSessionID[AreaID].LowObID).." ?! (may only happen on island takeover?)",ModID)
                        -- end
                        -- CacheObIDsSessionID[AreaID].LowObID = Kontor_OIDtable["ObjectID"] -- Kontor should be the first building on every owned island, so it is enough to start there with counting
                      -- end
                      -- if FromObjectID==nil and CacheObIDsSessionID[AreaID].LowObID~=nil then
                        -- FromObjectID_ = CacheObIDsSessionID[AreaID].LowObID
                      -- end -- dont use HighObID Cache here, because its possible that this changed meanwhile by unknown amount. Instead eg. use GetHighestObIDsLocalPlayerCurrentSessionByProperty to update the cache and provide the HighObID as ToObjectID to this function
                      -- objectcount = 0
                      -- LowestObjectID = nil
                      -- for ObjectID=FromObjectID_,ToObjectID_ do
                        -- filterresult = nil
                        -- OID = OIDtableToOID({ObjectID=ObjectID,AreaID=AreaID})
                        -- if withyield then
                          -- objectcount = objectcount + 1
                          -- if objectcount % 10000 == 0 then
                            -- coroutine.yield()
                          -- end
                        -- end
                        -- GUID = ts.Objects.GetObject(OID).GUID
                        -- if GUID~=0 then -- GUID==0 means nullpointer, does not have an object
                          -- SessionGuid = ts.Objects.GetObject(OID).SessionGuid -- should be the same as CheckingSessionGuid, but just to be sure
                          -- ParticipantID = ts.Objects.GetObject(OID).Owner
                          -- userdata = session.getObjectByID(OID)
                          -- if LowestObjectID==nil then
                            -- LowestObjectID = ObjectID
                          -- end
                          -- if type(ObjectFilter)=="function" then
                            -- filterresult = ObjectFilter(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID,AreaOwner,Kontor_OID)
                          -- end
                          -- if filterresult~=nil and type(filterresult)=="table" and filterresult["addthis"] then
                            -- Objects[OID] = {GUID=GUID,ParticipantID=ParticipantID,userdata=userdata,SessionGuid=SessionGuid,SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex,ObjectID=ObjectID,AreaOwner=AreaOwner,Kontor_OID=Kontor_OID}
                          -- end
                          -- if filterresult~=nil and type(filterresult)=="table" and (filterresult["next_AreaID"] or filterresult["done"]) then
                            -- break
                          -- end
                        -- elseif Kontor_OIDtable["ObjectID"]==ObjectID then -- if it claims to have a kontor, but its GUID is 0, then just skip this area
                          -- CacheObIDsSessionID[AreaID]["invalid"] = "ThirdParty" -- remember this Area as invalid, so we don't have to check it ever again.
                          -- break -- this happens for Editor Objects, eg. Kontor from third parties. They have in fact OID 9223413826886612345 and EditorFlag=1 which makes the number much higher. But lua can not handle this high number (bint?) anyways, trying to get GUID from 9223413826886612345 just results in an error.  -- so no suport for Editor Objects.
                        -- end
                      -- end
                      -- if LowestObjectID~=nil and (CacheObIDsSessionID[AreaID].LowObID==nil or LowestObjectID > CacheObIDsSessionID[AreaID].LowObID) then -- checking > here is correct, because the obj only can get bigger, never lower, eg. when taking over an island
                        -- CacheObIDsSessionID[AreaID].LowObID = LowestObjectID
                      -- end
                      -- if filterresult~=nil and type(filterresult)=="table" and (filterresult["next_SessionID"] or filterresult["done"]) then
                        -- break
                      -- end
                    -- end
                  -- end
                -- end
              -- end
            -- end
            -- if filterresult~=nil and type(filterresult)=="table" and (filterresult["next_SessionID"] or filterresult["done"]) then
              -- break
            -- end
          -- end
        -- end
        -- if filterresult~=nil and type(filterresult)=="table" and (filterresult["next_SessionID"] or filterresult["done"]) then
          -- break
        -- end
      -- end
      -- return Objects
    -- end


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
    
    
    
    -- kind="Area" for Area helper. anything else for Walkable Helper
    local function SpawnMaxObjIdHelpers(kind)
      local unlockguid = kind=="Area" and g_ObjectFinderSerp.MaxObjIdAreaHelper.Unlock or g_ObjectFinderSerp.MaxObjIdWalkableHelper.Unlock
      if not ts.Unlock.GetIsUnlocked(unlockguid) then
        ts.Unlock.SetUnlockNet(unlockguid)
        return true
      end
      return false -- if already unlocked, wait few seconds 10/30 to try again
    end
    
    -- Area/Building IslandID~=0 or Walkable IslandID==0)
    -- does check if on the Area / in the session the MaxObjIdAreaHelper.Guid/MaxObjIdWalkableHelper.Guid exists. 
     -- AreaOwner nil for Walkable (IslandID=0)
    local function DoesMaxObjIdHelperExists(AreaID,AreaOwner,MaxObjIdWalkableHelperGuid,MaxObjIdAreaHelperGuid)
      MaxObjIdWalkableHelperGuid = MaxObjIdWalkableHelperGuid or g_ObjectFinderSerp.MaxObjIdWalkableHelper.Guid
      MaxObjIdAreaHelperGuid = MaxObjIdAreaHelperGuid or g_ObjectFinderSerp.MaxObjIdAreaHelper.Guid
      local Areatable = g_LuaTools.AreaIDToAreatable(AreaID)
      local SessionID = Areatable.SessionID
      local IslandID = Areatable.IslandID
      local PIDs = AreaOwner~=nil and and IslandID~=0 and {AreaOwner} or {0,1,2,3} -- for an island, only the owner matters. For water the owner does not matter, so check every player
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
    
    -- To limit it to only the current Session, use a SessionFilter function that returns false if the SessionGUID is not the current one
    -- scroll down for "EXAMPLE ObjectFilter"
    local function GetAnyObjectsFromAnyone(myargs)
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
        local CheckingSessionGuid = g_ObjectFinderSerp.IsLoadedSessionByID(SessionID)
        if CheckingSessionGuid~=nil then
          local session_ok = true
          if type(SessionFilter)=="function" then
            session_ok = SessionFilter(SessionID,CheckingSessionGuid) 
          end
          if session_ok then
            local SessionIsCurrent = ExecutingSessionGUID == CheckingSessionGuid
            if g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[SessionID]==nil then
              g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[SessionID] = {}
            end
            if g_ObjectFinderSerp.ObjectFinderCacheSerp.ObIDs[SessionID]== nil then
              g_ObjectFinderSerp.ObjectFinderCacheSerp.ObIDs[SessionID] = {}
              g_ObjectFinderSerp.ObjectFinderCacheSerp.Changed = true
            end
            for IslandID=FromIslandID,ToIslandID do
              for AreaIndex=FromAreaIndex,ToAreaIndex do
                if not ((IslandID==0 and AreaIndex~=0) or (IslandID~=0 and AreaIndex==0)) then -- on water both are 0. on islands none of them is 0, so do not allow only one of them being 0.
                  local AreaID = AreatableToAreaID({SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex})
                  local CacheObIDsSessionID = g_ObjectFinderSerp.ObjectFinderCacheSerp.ObIDs[SessionID] -- I think its better for performance to save it in a variable
                  if CacheObIDsSessionID[AreaID]== nil then
                    CacheObIDsSessionID[AreaID] = {}
                  end
                  if not CacheObIDsSessionID[AreaID]["invalid"] then
                    if IslandID~=0 then
                      local AreaOwnerName,AreaOwner,Kontor_OIDtable,Kontor_OID
                      if not SessionIsCurrent then -- we can not check Area in other sessions, except we know any building OID on the Area already
                        if g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[SessionID]~=nil and g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[SessionID][AreaID]~=nil then
                          AreaOwner = g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[SessionID][AreaID].AreaOwner
                          AreaOwnerName = g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[SessionID][AreaID].AreaOwnerName
                          Kontor_OIDtable = g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[SessionID][AreaID].Kontor_OIDtable
                          Kontor_OID = g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[SessionID][AreaID].Kontor_OID
                        end
                      else
                        AreaOwnerName = ts.Area.GetAreaFromID(AreaID).OwnerName -- check if the Area is valid
                        AreaOwner = ts.Area.GetAreaFromID(AreaID).Owner
                      end
                      if AreaOwner==nil and AreaOwnerName==nil then
                        break -- then we can not check this Area, so skip it (we are unable to check if empty/invalid or owned. So it would mean searching long time invalid IDs)
                      end
                      if (AreaOwnerName=="" and AreaOwner==0) then -- invalid area. while for unsettled area owner will be -1. (OwnerName is better than Owner here, because invalid areas are nullpointer and would return 0 for Owner, which also might be Human0 on valid areas)
                        CacheObIDsSessionID[AreaID]["invalid"] = true -- remember this Area as invalid, so we don't have to check it ever again.
                        g_ObjectFinderSerp.ObjectFinderCacheSerp.Changed = true
                      end
                    end
                    if not CacheObIDsSessionID[AreaID]["invalid"] then
                      if withyield then
                        coroutine.yield()
                      end
                      if IslandID==0 or AreaOwnerName~="" then -- if not Water (IslandID==0), make sure Area is owned by someone
                        local MaxObjIdHelperExists = g_ObjectFinderSerp.DoesMaxObjIdHelperExists(AreaID,AreaOwner)
                        
                        while waitforhelper and not MaxObjIdHelperExists do
                          coroutine.yield()
                          MaxObjIdHelperExists = g_ObjectFinderSerp.DoesMaxObjIdHelperExists(AreaID,AreaOwner)
                        end
                        if SessionIsCurrent then
                          Kontor_OIDtable = ts.Area.GetAreaFromID(AreaID).KontorID
                          Kontor_OID = OIDtableToOID(Kontor_OIDtable)
                          -- filling it like this makes sure that outdated information is automatically overwritten
                          g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[SessionID][AreaID] = {Kontor_OID=Kontor_OID,Kontor_OIDtable=Kontor_OIDtable,AreaOwner=AreaOwner,AreaOwnerName=AreaOwnerName,Owner=ts.GetGameObject(Kontor_OID).Owner}
                          
                          if IslandID~=0 and Kontor_OIDtable["ObjectID"]~=nil and Kontor_OIDtable["ObjectID"]~=0 then -- assuming the KontorObjectID is always the lowest on an island, it makes sense to set LowObID to this value. If we assume that there may be exceptions to this, then we can not use it at all...
                            if CacheObIDsSessionID[AreaID].LowObID~=nil and Kontor_OIDtable["ObjectID"]~=CacheObIDsSessionID[AreaID].LowObID then
                              g_LuaTools.modlog("WARNING GetAnyObjectsFromAnyone KontorObjectID "..tostring(Kontor_OIDtable["ObjectID"]).." is unequal LowObID "..tostring(CacheObIDsSessionID[AreaID].LowObID).." ?! (may only happen on island takeover?)",ModID)
                            end
                            CacheObIDsSessionID[AreaID].LowObID = Kontor_OIDtable["ObjectID"] -- Kontor should be the first building on every owned island, so it is enough to start there with counting
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
                        
                        local objectcount = 0
                        local LowestObjectID = nil
                        for ObjectID=FromObjectID_,ToObjectID_ do
                          filterresult = nil
                          local OID = OIDtableToOID({ObjectID=ObjectID,AreaID=AreaID})
                          if withyield then
                            objectcount = objectcount + 1
                            if objectcount % 10000 == 0 then
                              coroutine.yield()
                            end
                          end
                          local GUID = ts.GetGameObject(OID).GUID -- using GetGameObject to also fetch objects from other sessions. if it does not exist, it will be nullpointer
                          if GUID~=0 then -- GUID==0 means nullpointer, does not have an object
                            local SessionGuid = CheckingSessionGuid
                            local ParticipantID = ts.GetGameObject(OID).Owner
                            local userdata = SessionIsCurrent and session.getObjectByID(OID) or nil -- no way to get userdata in foreign session... But you can use t_ExecuteFnWithArgsForPeers for a peer who is in that session and give him the OID to do what you want on that userdata (most operations on userdata desync though if not all peers do it at the same time)
                            if LowestObjectID==nil then -- we increase, so the first is the lowest
                              LowestObjectID = ObjectID
                            end
                            if type(ObjectFilter)=="function" then
                              filterresult = ObjectFilter(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID,AreaOwner,Kontor_OID)
                            end
                            if filterresult~=nil and type(filterresult)=="table" and filterresult["addthis"] then
                              Objects[OID] = {GUID=GUID,ParticipantID=ParticipantID,userdata=userdata,SessionGuid=SessionGuid,SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex,ObjectID=ObjectID,AreaOwner=AreaOwner,Kontor_OID=Kontor_OID}
                            end
                            if (IslandID==0 and GUID == g_ObjectFinderSerp.MaxObjIdWalkableHelper.Guid) or (IslandID~=0 and GUID == g_ObjectFinderSerp.MaxObjIdAreaHelper.Guid) then
                              break -- reached the max ObjectID for this IslandID (if island/session is settled) (they only exist for 10 / 30 seconds after we made them spawn with unlock 1500005552 / 1500005549 )
                            end
                            if filterresult~=nil and type(filterresult)=="table" and (filterresult["next_AreaID"] or filterresult["done"]) then
                              break
                            end
                          elseif Kontor_OIDtable["ObjectID"]==ObjectID then -- if it claims to have a kontor, but its GUID is 0, then just skip this area
                            CacheObIDsSessionID[AreaID]["invalid"] = "EditorObject" -- remember this Area as invalid, so we don't have to check it ever again.
                            break -- this happens for Editor Objects, eg. Kontor from third parties. They have in fact OID 9223413826886612345 and EditorFlag=1 which makes the number much higher. But lua can not handle this high number (bint?) anyways, trying to get GUID from 9223413826886612345 just results in an error.  -- so no suport for Editor Objects.
                          end
                        end
                        if LowestObjectID~=nil and (CacheObIDsSessionID[AreaID].LowObID==nil or LowestObjectID > CacheObIDsSessionID[AreaID].LowObID) then -- checking > here is correct, because the obj only can get bigger, never lower, eg. when taking over an island
                          CacheObIDsSessionID[AreaID].LowObID = LowestObjectID
                        end
                        if filterresult~=nil and type(filterresult)=="table" and (filterresult["next_SessionID"] or filterresult["done"]) then
                          break
                        end
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
      return Objects
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
     -- info: the first ObjectID found will be in most cases the Harbor and GetCurrentSessionObjectsFromAnyone is optimzied to start with that if it is known and FromObjectID==nil (only known in current active session)
    local function AreasCurrentSessionLooper(executionfunc,withyield)
      local function Area_filterfunc(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID,AreaOwner,Kontor_OID)
        done = executionfunc(SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,AreaOwner,Kontor_OID)
        return {addthis=false,done=done,next_AreaID=true,next_SessionID=false}
      end
      g_ObjectFinderSerp.GetCurrentSessionObjectsFromAnyone({ObjectFilter=Area_filterfunc,FromSessionID=nil,ToSessionID=nil,
        FromIslandID=1,ToIslandID=nil,FromAreaIndex=1,ToAreaIndex=nil,FromObjectID=nil,ToObjectID=nil,withyield=withyield})
    end

    -- example usage:
    -- g_ObjectFinderSerp.AreasCurrentSessionLooper(function(SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,AreaOwner,Kontor_OID)
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
      local AreaOwner = AreaOwner or g_ObjectFinderSerp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(OID)..") Area Owner]",true) -- using DoForSessionGameObject, because Area is not known if local player is not in the same session
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
        -- TODO: beispiel ohne found_count machen sondern mit local außerhalb
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


    -- How to check for properties of your found objects:


    -- general info:
    -- If userdata is available, you can check what property the object has with:
    -- userdata:getProperty(PropertyID) (https://github.com/anno-mods/modding-guide/blob/main/Scripting/ENUMs.md#propertyids)
    -- BEWARE:
    -- getProperty does not seem to work for all proeprties. You should test first if the property you want to check works. 
    -- Eg. from a flagship the following properties are NOT found (the others are)!
    -- Standard,Object,Text,Drifting,MinimapToken,Cost,Craftable,Locked,ExpeditionAttribute,Stance,WorldMapSound and SoundEmitterCommandBarks
    -- TradeRouteVehicle is called PropertyTradeRouteVehicle in the getProperty return for whatever reason.
    -- Working Properties with getProperty:
    -- tested with flagship (with other objects there may be more working ones)
    -- 310 : QuestObject,315 : Attackable,316 : Attacker,320 : Collector,321 : CommandQueue,326 : Draggable,331 : FeedbackController,334 : Infolayer,338 : Mesh,340 : MetaPersistent,344 : Nameable,347 : Pausable,354 : Rentable,357 : Selection,358 : Sellable,359 : ShipIncident,360 : ShipMaintenance,364 : PropertyTradeRouteVehicle,367 : Walking,665 : SoundEmitter,740 : ItemContainer,846 : UpgradeList
    -- if you try it on invalid userdata (or userdata from other session) getProperty retruns: "Invalid gameObject id 8589934625!" (id number can be different in your case of course)



    -- provide this function with either userdata or OID.
     -- and Property you want to check, can be a string or the PropertyID
    -- returns true if userdata has the property.
    -- returns nil if:
       -- userdata/Property is invalid (eg. object is not from current session)
    -- returns false if: 
      --- it does not has the property
      -- getProperty simply does not work for this property  
    local function HasProperty(userdata,Property,OID)
      local PropertyID
      if type(Property)=="number" then
        PropertyID = Property
      elseif type(Property)=="string" then
        PropertyID = PropertiesStringToID[Property]
      end
      if PropertyID~=nil then
        if userdata==nil and OID~=nil then
          userdata = game.MetaGameManager.getObjectByID(OID)
        end
        if userdata~=nil then
          
          local function savecallproperty(userdata,PropertyID)
            return userdata:getProperty(PropertyID)
          end
          local success, PropertyName = pcall(savecallproperty,userdata,PropertyID) -- getProperty raises an error if it does not have the property. preventing this with pcall.
          if success then
            if not PropertyName:find("Invalid gameObject id") then -- invalid userdata eg. because no longer filled, was never valid or called in wrong session
              return true
            else
              return nil
            end
          end
          return false
          
        end
      end
      return nil
    end

    -- code to test what properties are found for your selected object:
    -- local userdata = session.getSelectedFactory()
    -- for i=0,1000 do
      -- local success = g_ObjectFinderSerp.CheckObjectHelpers.HasProperty(userdata,i)
      -- if success then
        -- print(tostring(i).." : "..tostring(propname))
      -- end
    -- end

    -- ################################################

    -- if userdata is not available (eg for usage in HasProperty, because object is from another session): 
     -- unfortunately you can not check if a GameObject has specific properties directly
     -- because every GameObject, even nullpointer will have Object.Walkable...  and also objects which dont have that property and
     -- will return always 0/nil for get-requests. you can eg check in walkable what the speed is or in attackable what the basedamage is. 
     -- if it is 0, it is likely the object does not have this property
     -- So these are no guarantee! just very likely!
    -- providing userdata to the following funtions is optional
    local function HasWalking(OID,userdata)
      local hasproperty = HasProperty(userdata,"Walking",OID)
      if hasproperty then
        return true
      elseif hasproperty==nil then -- then try the less secure way via GetGameObject, which also works if object is in another session
        return ts.GetGameObject(OID).Walking.BaseSpeedWithUpgrades ~= 0
      end
    end
    local function HasCommandQueue(OID,userdata)
      local hasproperty = HasProperty(userdata,"CommandQueue",OID)
      if hasproperty then
        return true
      elseif hasproperty==nil then -- then try the less secure way via GetGameObject, which also works if object is in another session
        return ts.GetGameObject(OID).CommandQueue.UI_IsNonMoving or ts.GetGameObject(OID).CommandQueue.UI_IsMoving -- scheint immer eins von beiden wahr zu sein, auch zb auf patroullie/traderoute
      end
    end
    local function HasAttacker(OID,userdata)
      local hasproperty = HasProperty(userdata,"Attacker",OID)
      if hasproperty then
        return true
      elseif hasproperty==nil then -- then try the less secure way via GetGameObject, which also works if object is in another session
        return ts.GetGameObject(OID).Attacker.DPS ~= 0
      end
    end
    local function HasAttackable(OID,userdata) -- we can not check if and by what it can be attacked though
      local hasproperty = HasProperty(userdata,"Attackable",OID)
      if hasproperty then
        return true
      elseif hasproperty==nil then -- then try the less secure way via GetGameObject, which also works if object is in another session
        return ts.GetGameObject(OID).Attackable.MaxHitPoints ~= 0
      end
    end
    local function HasBombarder(OID,userdata) -- most likely also means it is an airship
      local hasproperty = HasProperty(userdata,"Bombarder",OID)
      if hasproperty then
        return true
      elseif hasproperty==nil then -- then try the less secure way via GetGameObject, which also works if object is in another session
        return ts.GetGameObject(OID).Bombarder.ShaftCount ~= 0
      end
    end
    local function NeedsBuildPermit(OID,GUID)
      if GUID~=nil then
        return ts.BuildPermits.GetNeedsBuildPermit(GUID)
      elseif OID~=nil then
        return ts.BuildPermits.GetNeedsBuildPermit(ts.GetGameObject(OID).GUID)
      end
    end

    -- ###################################################################################################

    -- other checks for your found objects

    local function AffectedByStatusEffect(OID,StatusEffectGUID) -- eg StatusEffect dealt by projectiles. this way you can easily filter for objects hit with your custom projectile
      return ts.GetGameObject(OID).Attackable.GetIsPartOfActiveStatusEffectChain(StatusEffectGUID) -- unfortunately does not work with buffs provided in a different way
    end
    -- for Productivity Buffs for Factory/Monument see GetVectorGuidsFromSessionObject ProductivityUpgradeList
    -- And you can check ItemContainer for "GetItemAlreadyEquipped" to check if a ship/guildhouse has an item euqipped
    -- I fear checking other buffs is not possible in lua...

    -- ###################################################################################################
    -- ###################################################################################################
    -- you can call this function to find out if a game was just newly started (by checking ts.GameClock.CorporationTime)
    local function WasNewGameJustStarted() -- call it within the first 30 seconds of a new game for it to work
      return ts.GameClock.CorporationTime < 30000 -- if the game is not older than 30 seconds, we consider it new
    end
    
    -- update Kontor_OIDs Cache
    local function OnIslandSettledSessionEnter(PID)
      
      if ts.Participants.GetGetCurrentParticipantID() == PID then -- just to make sure its not 4 times for the same local player executed if there are 4 humans (for coop it does not matter because the trigger is only executed once per coop-team, so its fine)
        local SessionGuid = session.getSessionGUID()
          
          
          g_LuaTools.modlog("OnIslandSettledSessionEnter "..tostring(SessionGuid).." Update Areas Cache",ModID)
          
          
          g_LuaTools.start_thread("OnIslandSettledSessionEnter",ModID,function()
            -- wait for everything to initial finish
            while g_ObjectFinderSerp==nil or g_SaveLuaStuff_Serp==nil or g_PeersInfo_Serp==nil or g_PeersInfo_Serp.CoopFinished~=true or g_CoopCountRes==nil or g_CoopCountRes.Finished~=true do
              coroutine.yield()
            end
            
            local curSessionGUID = session.getSessionGUID()
            local curSessionID = nil
            for SID,SGUID in pairs(g_ObjectFinderSerp.ObjectFinderCacheSerp.LoadedSessions) do
              if curSessionGUID==SGUID then
                curSessionID = SID
                break
              end
            end
            g_LuaTools.modlog("OnIslandSettledSessionEnter "..tostring(SessionGuid).." before Kontor_OIDs_before",ModID)
            local Kontor_OIDs_before
            if curSessionID~=nil then
              Kontor_OIDs_before = g_LuaTools.deepcopy(g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[curSessionID])
            end
            g_LuaTools.modlog("OnIslandSettledSessionEnter "..tostring(SessionGuid).." after Kontor_OIDs_before",ModID)
          -- loop through Areas of current session and save owner+Kontor OID to cache
            g_ObjectFinderSerp.AreasCurrentSessionLooper(function(SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,AreaOwner,Kontor_OID)
              -- its enough to only call this and run it to the end. This makes sure that Cache Kontor_OIDs is updated within GetCurrentSessionObjectsFromAnyone
            end)
            g_LuaTools.modlog("OnIslandSettledSessionEnter "..tostring(SessionGuid).." after AreasCurrentSessionLooper",ModID)
               
            if Kontor_OIDs_before~=nil and not g_LuaTools.tables_equal(Kontor_OIDs_before,g_ObjectFinderSerp.ObjectFinderCacheSerp.Kontor_OIDs[curSessionID]) then
                g_LuaTools.modlog("OnIslandSettledSessionEnter "..tostring(SessionGuid).." before t_SyncCacheToEveryone",ModID)
              g_ObjectFinderSerp.t_SyncCacheToEveryone()
            end
            
            g_LuaTools.modlog("OnIslandSettledSessionEnter "..tostring(SessionGuid).." Updated Areas Cache Done",ModID)
            
          end)
          
      end
    end
    -- update SessionParticipants Cache
    local function OnSessionLoaded(PID)
      if ts.Participants.GetGetCurrentParticipantID() == PID then -- just to make sure its not 4 times for the same local player executed if there are 4 humans (for coop it does not matter because the trigger is only executed once per coop-team, so its fine)
        g_LuaTools.modlog("OnSessionLoaded Update SessionParticipants Cache",ModID)
        g_LuaTools.start_thread("OnSessionLoaded",ModID,function()
          g_LuaTools.waitForTimeDelta(2000) -- small delay to give the game time to finish everything, like spawning SessionParticipants
          -- wait for everything to initial finish
          while g_ObjectFinderSerp==nil or g_SaveLuaStuff_Serp==nil or g_PeersInfo_Serp==nil or g_PeersInfo_Serp.CoopFinished~=true or g_CoopCountRes==nil or g_CoopCountRes.Finished~=true do
            coroutine.yield()
          end
          -- Script to update Cache with SessionsParticipants from the new session.
          local All_PIDS = g_LuaTools.deepcopy(g_ObjectFinderSerp.PIDsToShareData)
          table.insert(All_PIDS,g_ObjectFinderSerp.PIDToSaveData)
          table.insert(All_PIDS,g_ObjectFinderSerp.PID_Neutral) -- and Neutral
          g_ObjectFinderSerp.GetAllLoadedSessionsParticipants(All_PIDS) -- this updates also the LoadedSessions Cache
        end)
      end
    end
    
    
    local function RegisterEvents() -- not called anymore, since event. does crash too often. using triggers again
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
        g_LuaTools.modlog("Register OnSessionLoaded",ModID)
        was_already_registered = false
        event.OnSessionLoaded[ModID] = function(SessionContext)
          system.start(function()
            while g_ObjectFinderSerp==nil do
              coroutine.yield()
            end
            local status, err = pcall(g_ObjectFinderSerp.OnSessionLoaded,ts.Participants.GetGetCurrentParticipantID()) -- use seperate function with pcall, because game crashes without lua error, if any error happens in an function called by event. !
            if status==false then -- error
              print(ModID,"ERROR OnSessionLoaded: Function OnSessionLoaded had an error: "..tostring(err))
              g_LuaTools.modlog("ERROR OnSessionLoaded: Function OnSessionLoaded had an error: "..tostring(err),ModID)
            end
          end,ModID.." OnSessionLoaded")
        end
      end
      if event.OnSessionEnter[ModID] == nil then -- only add it once
        g_LuaTools.modlog("Register OnSessionEnter",ModID)
        was_already_registered = false
        event.OnSessionEnter[ModID] = function(SessionContext)
          system.start(function()
            while g_ObjectFinderSerp==nil do
              coroutine.yield()
            end
            local status, err = pcall(g_ObjectFinderSerp.OnIslandSettledSessionEnter,ts.Participants.GetGetCurrentParticipantID()) -- use seperate function with pcall, because game crashes without lua error, if any error happens in an function called by event. !
            if status==false then -- error
              print(ModID,"ERROR OnSessionEnter: Function OnIslandSettledSessionEnter had an error: "..tostring(err))
              g_LuaTools.modlog("ERROR OnSessionEnter: Function OnIslandSettledSessionEnter had an error: "..tostring(err),ModID)
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
          while not g_ObjectFinderSerp.ObjectFinderCacheSerp.Loaded do -- wait for cache to load
            coroutine.yield()
          end
          local status, err = pcall(g_ObjectFinderSerp.OnSessionLoaded,ts.Participants.GetGetCurrentParticipantID()) -- use seperate function with pcall, because game crashes without lua error, if any error happens in an function called by event. !
          if status==false then -- error
            print(ModID,"ERROR OnSessionLoaded: Function OnSessionLoaded had an error: "..tostring(err))
            g_LuaTools.modlog("ERROR OnSessionLoaded: Function OnSessionLoaded had an error: "..tostring(err),ModID)
          end
          local status, err = pcall(g_ObjectFinderSerp.OnIslandSettledSessionEnter,ts.Participants.GetGetCurrentParticipantID()) -- use seperate function with pcall, because game crashes without lua error, if any error happens in an function called by event. !
          if status==false then -- error
            print(ModID,"ERROR OnSessionEnter: Function OnIslandSettledSessionEnter had an error: "..tostring(err))
            g_LuaTools.modlog("ERROR OnSessionEnter: Function OnIslandSettledSessionEnter had an error: "..tostring(err),ModID)
          end
        end,ModID.." Call initial OnSessionEnter/OnSessionLoaded")
      end
      
      
    end



    -- ###################################################################################################
    -- ###################################################################################################
    -- ###################################################################################################


    -- here the functions you can use with help of this script
    -- search the function names in this file to get short explanation

    -- 
    g_ObjectFinderSerp = {
      -- stuff for internal use
      ObjectFinderCacheSerp = {ObIDs={},LoadedSessionsParticipants={},LoadedSessions={},Kontor_OIDs={},Loaded=nil,Changed=nil,SyncChanged=nil},
      DoTheExecutionFor = DoTheExecutionFor, -- internal use!
      StartShareThread = StartShareThread, -- internal use!
      OnIslandSettledSessionEnter = OnIslandSettledSessionEnter, -- internal use!
      OnSessionLoaded = OnSessionLoaded, -- internal use!
      t_SaveCache = t_SaveCache, -- internal use!
      ShareQueue = {},
      ShareLoopIsRunning = false,
      ExecuteDone = false,
      SyncCache = SyncCache,
      -- ..
      IsLoadedSessionByID = IsLoadedSessionByID,
      IDConverter = {
        AreatableToAreaID = AreatableToAreaID,
        AreaIDToAreatable = AreaIDToAreatable,
        OIDtableToOID = OIDtableToOID,
        OIDToOIDtable = OIDToOIDtable,
        get_OID = get_OID,
      },
      CheckObjectHelpers = { -- use userdata:getProperty(PropertyID) if you have userdata (see above for more info)
        HasProperty = HasProperty,
        PropertiesStringToID = PropertiesStringToID,
        HasWalking = HasWalking,
        HasCommandQueue = HasCommandQueue,
        HasAttacker = HasAttacker,
        HasAttackable = HasAttackable,
        HasBombarder = HasBombarder,
        NeedsBuildPermit = NeedsBuildPermit,
        AffectedByStatusEffect = AffectedByStatusEffect,
      },
      -- helper constructs you can use
      t_SyncCacheToEveryone = t_SyncCacheToEveryone, -- syncs ObjectFinderCacheSerp to all peers
      DoForSessionGameObject = DoForSessionGameObject,
      t_ShareLuaInfo = t_ShareLuaInfo,
      GetSharedLuaInfo = GetSharedLuaInfo,
      t_ExecuteFnWithArgsForPeers = t_ExecuteFnWithArgsForPeers,
      GetFertilitiesOrLodesFromArea_CurrentSession = GetFertilitiesOrLodesFromArea_CurrentSession,
      GetVectorGuidsFromSessionObject = GetVectorGuidsFromSessionObject,
      GetCoopPeersAtMarker = GetCoopPeersAtMarker,
      -- object loopers
      GetCurrentSessionObjectsFromLocaleByProperty = GetCurrentSessionObjectsFromLocaleByProperty,
      GetCurrentSessionObjectsFromAnyone = GetCurrentSessionObjectsFromAnyone,
      GetAnyObjectsFromAnyone = GetAnyObjectsFromAnyone,
      AreasCurrentSessionLooper = AreasCurrentSessionLooper,
      GetLoadedSessions = GetLoadedSessions,
      GetFirst100LoadedSessionsGameObjects = GetFirst100LoadedSessionsGameObjects,
      GetAllLoadedSessionsParticipants = GetAllLoadedSessionsParticipants,
      GetHighestObIDsLocalPlayerCurrentSessionByProperty = GetHighestObIDsLocalPlayerCurrentSessionByProperty,
      WasNewGameJustStarted = WasNewGameJustStarted,
      PIDsToShareData = {117,118,119,120,121,122,123,124,125,126,127,128,129,136,137,138},
      ExForEveryUnlocks = {1500004620,1500004621,1500004622,1500004623,1500004624,1500004625,1500004626,1500004627,1500004628,
        1500004629,1500004630,1500004631,1500004632,1500004633,1500004634,1500004635}, -- GUIDs for FeatureUnlock to start peer scripts
      PIDToSaveData = 130,
      PID_Neutral = 8,
      l_MaxSessionID = 20, -- used as default max SessionID when looping through all sessions. In vanilla we have ~8 sessions, so I think 20 should be fine even with alot of session mods installed
      l_MaxIslandID = 80, -- per Session
      MaxObjIdAreaHelper = {Guid=1500005548,Unlock=1500005549}, -- IslandID ~= 0
      MaxObjIdWalkableHelper = {Guid=1500005550,Unlock=1500005552}, -- IslandID = 0
      DoesMaxObjIdHelperExists = DoesMaxObjIdHelperExists,
      SpawnMaxObjIdHelpers = SpawnMaxObjIdHelpers,
    }
    
    g_LuaTools.start_thread("t_LoadCache",ModID,t_LoadCache) -- this already updates on game start the Cache SessionParticipants and also LoadedSessions, while OnSessionEnter updates Kontor_OIDs
    
    -- RegisterEvents() -- not called anymore, since event. does crash too often. using triggers again
    
    
    g_LuaTools.start_thread("g_OnGameLeave_serp",ModID,function()
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
    g_LuaTools.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LuaTools.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)

end
