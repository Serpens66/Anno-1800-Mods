-- Big thanks also to Taube and nyk for helping and finding out important information about how ObjectIDs and so on work.


-- USAGE:
-- use the functions forwarded at end of file in global ObjectFinderSerp by using this code in your script:
-- if ObjectFinderSerp==nil then
  -- console.startScript("data/scripts_serp/objectfinder/objectfinder.lua")
-- end
-- and then you can use eg. ObjectFinderSerp.GetCurrentSessionObjectsFromLocaleByProperty(367)


-- before starting an expensive search for a specific GUID, you might want to check with ProfileCounter in lua (see below for example) or PlayerCounter in xml
 -- if the player owns an object with that GUID 



print("objectfinder.lua called")
  
local function modlog(t)
  if type(t)~="string" then
    t = tostring(t)
  end
  file = io.open("logs/modlog.txt", "a")
  io.output(file)
  io.write(t,"\n")
  io.close(file)
end
-- source: https://stackoverflow.com/questions/65482605/how-to-print-all-values-in-a-lua-table
local sort, rep, concat = table.sort, string.rep, table.concat
local function TableToString(var, sorted, indent)
    
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
               .. TableToString(key, sorted, indent + 1)
               .. ' = '
               .. TableToString(var [key], sorted, indent + 1)
        end
        return 'table (\n' .. concat (strings, '\n') .. '\n' .. rep ('\t', indent) .. ')'
    else
        return tostring (var)
    end
end

local function deepcopy(orig, copies)
  copies = copies or {}
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      if copies[orig] then
          copy = copies[orig]
      else
          copy = {}
          copies[orig] = copy
          for orig_key, orig_value in next, orig, nil do
              copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
          end
          setmetatable(copy, deepcopy(getmetatable(orig), copies))
      end
  else -- number, string, boolean, etc
      copy = orig
  end
  return copy
end



-- useful info:
-- the GameObject variable you get by:
-- GameObject = ts.Objects.GetObject(OID) or also GameObject = ts.GetGameObject(OID)
-- is broken after one usage, eg. getting the GUID with GameObject.GUID.
-- If you then try to get other info on the same variable like GameObject.SessionGuid, you will always just get the value you got first, in this case objects GUID.
-- So you have to renew the object everytime before using by doing again "GameObject = ..."
-- Sometimes his problem is also there for "Area = ts.Area.GetAreaFromID(AreaID)", so better also only use it once...

-- ts.Objects.GetObject(OID) is a little bit faster than ts.GetGameObject(OID), but ts.GetGameObject(OID) can also find OIDs from other sessions.
-- since getObjectGroupByProperty can only find objects in current session (from the local player), there is no need to use GetGameObject there.

-- There is no currently known way to get userdata representation of objects in other sessions than the current one.
-- You can save the userdata you fetched while in the session a tiny number of things will work in other sessions eg. getName(), getOID() works.
 -- But commands like userdata.moveTo or addDamagePercent and also isMoving and so on won't work while in another session (but works again as soon as you are in correct session).

-- Every time a ship changes the session, it gets a new increasing ObjectID. That is the major reason why on very big/old savegames the ObjectID may be in range of 100k or higher


-- ###################################################################################################
-- ###################################################################################################



local function SaveCache()
  
  -- TODO:
   -- die LeereObIDs aufbereiten.
   -- Wir können nicht zigmillionen IDs abspeichern,
    -- stattdessen nehmen wir {min=2324,max=34834} einträge usw um eine Spanne leerer ObjectIDs zu kennzeichnen.
     -- dabei nehmen wir nur Lücken auf, die größer als x tausend( zb 10k) sind, um Platz zu sparen.
   -- das evlt hier oder auch direkt beim eintragen der LeereObIDs machen
  SaveLuaStuff_Serp.SaveTableToHelper("ObjectFinderSerp",ObjectFinderSerp.ObjectFinderCacheSerp)
end

-- ObjectFinderCacheSerp
-- structure will be: { [SessionID]={[AreaID]={LowObID=1,HighObID=100,KontorObjectID=1}} }

-- TODO: OnLuaGameLoaded eine fkt ausführen lassen,
 -- die den cache aus save-helper ausliest (bzw. darin warten, bis cache gefüllt wurde)

-- evlt auch reinpacken:
-- - welche Sessions/AreaIDs invalid sind, also garnicht existieren (wobei invalide SessionIDs gibts nicht direkt, denn es könnten ja noch Sessions geladen werden. da reicht also unser IsLoadedSessionByID-check aus)
   -- das könnte man machen indem man zb [SessionID]={[AreaID]=false} setzt

-- - welche ObjectIDs zwischen gefüllten ids leer sind, also zb 1 ist Kontor und dann ist bis 10k erstmal nichts, weil soviel abgerissen wurde
 -- dann sich merken, dass man 2 bis 10k erstmal skippen kann
 -- LeereObIDs={[2000]=true,[3000]=true}} ObjectID als key damit check ob enthalten sehr schnell ist.
  -- wie ich sinnvoll ein "von 2000 bis 3000" eintrage weiß ich noch nicht...
   -- und selbst wenn ichs weiß, dann sollte man das nachträglich, nach einem gesamten durchlauf machen indem man direkt über LeereObIDs looped
    -- und das dann zusammenfasst. Wobei man diese Zusammenfassung evlt auch direkt vor einem save to save-helper
     -- machen könnte, geht dabei ja nur ums Platz sparen in dem save-string
      -- und beim Laden dann wieder zurück in jede einzelne ObjectID

-- falls der höchstwert hilfreich ist, dann evlt auch alle 5 minuten oderso die nächsten 1000 prüfen, ob höchstwert höher geworden ist,
  -- ist allerdings nicht 100% sicher, wenn aufeinmal sehr viel gebaut wurde
  
-- ConditionEvent IslandSettled um KontorID zu updaten (dabei einfach einmal AreasCurrentSessionLooper ausführen, der aktualisiert dann die current session)

 -- und evlt mit OncePerSession Hilfsmod einmal für jedes sessionenter die KontorIDs zu Spielbeginn abfragen und im cache speichern

-- PROBLEM/Vorteil?:
 -- coop/multiplayer:
  -- Die Spieler können in untersch. Sessions sein und dadurch auch untersch. infos im Cache gespeichert haben,
   -- wenn dieser vorallem für die aktuelle Session besonders genau ist.
  -- Als Vorteil könnte man das nutzen, indem solche infos nach einem Durchlauf in nameable Save-Helper geschrieben werden
   -- das erleichtert den Ausstausch des lua-Kenntnisstandes zwischen den Spielern 
    -- (evlt dafür nochmal nen eigenes nameable spawnen?)
    -- Vorallem könnte man threoretisch wenn man ein Objekt sucht auch erstmal nur eine Current-Session Suche anschmeißen,
     -- und jeder ders findet, schreibt die OID ins Nameable, die dann von dem relevanten Spieler ders vllt nicht gefunden hat, weil in anderer session, genutzt werden kann.
    -- schwierig wird da nur der zeitgleiche Zugriff aufs selbe nameable...
     -- vllt also sogar ein  Nameable Objekt pro human splayer slot spawnen, also bis zu 16 stück?
      -- problem dabei ist nur, dass die coop spieler nicht wissen, welcher coop-slot sie sind...
  -- Problem wäre es, wenn dadurch vorhandene infos mit leeren infos überschrieben werden...

-- ##################################################################################################################################
-- ##################################################################################################################################

-- text embed helper for using MetaObjects.SessionGameObject, which is otherwise unavailable in lua...

    -- TODO: auch hier gucken dass die infos geteilt werden und letzlich das richtige bei allen gespeichert wird...
-- function for internal use
-- used once per game directly after spawning the helper objects with onlysavehelper=false
 -- and with onlysavehelper=true on every savegame load, because pther helper OIDs are saved there already
local function FindHelperOIDs(onlysavehelper)
  print("FindHelperOIDs", onlysavehelper)
  if next(ObjectFinderSerp.ObjectFinderCacheSerp["Nameable_Helper_OIDs"])==nil or (SaveLuaStuff_Serp.Helper_OID==nil and onlysavehelper) then
    local HelperOwner = 15 -- Third_party_01_Queen
    local HelperGUIDs = {[1500004625]="SaveHelper",[1500004620]="EmbedHelper",[1500004621]="Human0Share",[1500004622]="Human1Share",[1500004623]="Human2Share",[1500004624]="Human3Share"}
    if onlysavehelper then
      HelperGUIDs = {[1500004625]="SaveHelper"}
    end
    if ts.Participants.GetParticipant(HelperOwner).ProfileCounter.Stats.GetCounter(0,0,next(HelperGUIDs),3)>0 then -- if 1500004625 exists, all others must exist too, because they are spawned in the very same xml code
      local found = {} -- remember here which ones we already found
      local function myObjectFilter(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID)
        if HelperGUIDs[GUID]~=nil and ParticipantID==HelperOwner then
          found[GUID] = true
          local done = true
          for HelperGUID,v in pairs(HelperGUIDs) do
            if found[HelperGUID]==nil then
              done = false
            end
          end
          return {addthis=true,done=done,next_AreaID=false,next_SessionID=false} -- important to return addthis and done, to stop the expensive search
        end
      end
      local function mySessionFilterOldWorld(SessionID,CheckingSessionGuid) -- first search in old world, because it is most likely to be here
        if CheckingSessionGuid==180023 then
          return true
        end
      end
      local function mySessionFilterNotOldWorld(SessionID,CheckingSessionGuid)
        if CheckingSessionGuid~=180023 then
          return true
        end
      end
      system.start(function()
        local results = {}
        if ts.Participants.GetParticipant(HelperOwner).ProfileCounter.Stats.GetCounter(0,0,next(HelperGUIDs),1,180023)>0 then -- if it is in old world
          results = ObjectFinderSerp.GetAnyObjectsFromAnyone({ObjectFilter=myObjectFilter,SessionFilter=mySessionFilterOldWorld,FromSessionID=1,ToSessionID=nil,
            FromIslandID=0,ToIslandID=0,FromAreaIndex=0,ToAreaIndex=0,FromObjectID=nil,ToObjectID=10000,withyield=false,nosave=true})
          if next(results)==nil then -- then search up to 1m ObjectIDs, should be enough even on very big savegames
            results = ObjectFinderSerp.GetAnyObjectsFromAnyone({ObjectFilter=myObjectFilter,SessionFilter=mySessionFilterOldWorld,FromSessionID=1,ToSessionID=nil,
              FromIslandID=0,ToIslandID=0,FromAreaIndex=0,ToAreaIndex=0,FromObjectID=10000,ToObjectID=1000000,withyield=true,nosave=true})
          end
          if next(results)==nil then -- then search up to 10m ObjectIDs, should be enough for biggest savegame in the world ?!
            results = ObjectFinderSerp.GetAnyObjectsFromAnyone({ObjectFilter=myObjectFilter,SessionFilter=mySessionFilterOldWorld,FromSessionID=1,ToSessionID=nil,
              FromIslandID=0,ToIslandID=0,FromAreaIndex=0,ToAreaIndex=0,FromObjectID=1000000,ToObjectID=10000000,withyield=true,nosave=true})
          end
        end
        if next(results)==nil then -- then search again in the other sessions
          results = ObjectFinderSerp.GetAnyObjectsFromAnyone({ObjectFilter=myObjectFilter,SessionFilter=mySessionFilterNotOldWorld,FromSessionID=1,ToSessionID=nil,
            FromIslandID=0,ToIslandID=0,FromAreaIndex=0,ToAreaIndex=0,FromObjectID=nil,ToObjectID=10000,withyield=false,nosave=true})
          if next(results)==nil then -- then search up to 1m ObjectIDs, should be enough even on very big savegames
            results = ObjectFinderSerp.GetAnyObjectsFromAnyone({ObjectFilter=myObjectFilter,SessionFilter=mySessionFilterNotOldWorld,FromSessionID=1,ToSessionID=nil,
              FromIslandID=0,ToIslandID=0,FromAreaIndex=0,ToAreaIndex=0,FromObjectID=10000,ToObjectID=1000000,withyield=true,nosave=true})
          end
        end
        if next(results)==nil then
          print("Did not find helper objects")
        else
          SaveLuaStuff_Serp.Helper_OID = FoundObject_OID
          for Found_OID,info in pairs(results) do 
            if HelperGUIDs[info["GUID"]]=="SaveHelper" then
              SaveLuaStuff_Serp.Helper_OID = Found_OID
            else
              ObjectFinderSerp.ObjectFinderCacheSerp["Nameable_Helper_OIDs"][HelperGUIDs[info["GUID"]]] = Found_OID
            end
          end
        end
        if not onlysavehelper then -- we just spawned the helpers. then wait until we inited everything and then save cache
          local notstop = 0
          while true do
            if SaveLuaStuff_Serp.Inited then
              break
            end
            coroutine.yield()
            notstop = notstop + 1
            if notstop > 100 then
              break
            end
          end
          if notstop < 100 then
            SaveCache() -- save the cache we filled while searching for the helper objects the first time
          end
        end
      end)
    else
      print("FindHelperOIDs: spawn von helper objects hat nicht geklappt?!")
    end
  else
    print("FindHelperOIDs: called although ObjectFinderCacheSerp Nameable_Helper_OIDs is already filled!?")
  end
end
-- ##################

 -- ts_embed_string should be eg: "[MetaObjects SessionGameObject("..tostring(OID)..") Area CityName]"
 -- so always inlucding "[MetaObjects SessionGameObject("..tostring(OID)..") ...]" and your wanted command for the OID you enter
 local function DoForSessionGameObject(ts_embed_string,doreturnstring)
  if doreturnstring then -- we want to get what the textembed returns, but game.TextSourceManager.setDebugTextSource does not return anything. I only know a workarkund to get it, by setting and reading out the name of a namable helper object
    local helper_OID = ObjectFinderSerp.ObjectFinderCacheSerp["Nameable_Helper_OIDs"]["EmbedHelper"]
    if helper_OID~=nil then
      game.TextSourceManager.setDebugTextSource("[MetaObjects SessionGameObject("..tostring(helper_OID)..") Nameable Name( "..tostring(ts_embed_string).." )]")
      local returnstring = ts.GetGameObject(helper_OID).Nameable.GetName()
      game.TextSourceManager.setDebugTextSource("[MetaObjects SessionGameObject("..tostring(helper_OID)..") Nameable Name(nil)]") -- set it to nil again, so you can notice if sth did not work
      return returnstring
    else
      print("DoForSessionGameObject: Nameable_Helper_OIDs EmbedHelper for helper object GUID 1500004620 is empty. Call FindHelperOIDs first and check the prints if it correctly spawned")
    end
  else -- only an action that needs no return, then simply execute it
    game.TextSourceManager.setDebugTextSource(ts_embed_string)
  end
end

-- helpers to access "Vector" return values you find in textsourcelist.json, which are not accessable in lua directly -.-
-- we can only access AreaFromID from the current active session of the local player
-- set FertilitiesOrLodesString to "Fertilities" or "Lodes" (ores), depending of what you want to get returned
local function GetFertilitiesOrLodesFromArea_CurrentSession(AreaID,FertilitiesOrLodesString)
  local count = ObjectFinderSerp.DoForSessionGameObject("[Area AreaFromID("..tostring(AreaID)..") "..tostring(FertilitiesOrLodesString).." Count]",true)
  local results = {}
  if count~=nil and count~="nil" then
    count = tonumber(count)
    if count~=nil and count>0 then
      local GUID
      for i=0,count-1 do
        GUID = ObjectFinderSerp.DoForSessionGameObject("[Area AreaFromID("..tostring(AreaID)..") "..tostring(FertilitiesOrLodesString).." At("..tostring(i)..") Guid]",true)
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
local function GetVectorGuidsFromSessionObject(OID,ts_embed_string)
  local ts_embed_string_guid
  local count = ObjectFinderSerp.DoForSessionGameObject(ts_embed_string,true)
  local results = {}
  if count~=nil and count~="nil" then
    count = tonumber(count)
    if count~=nil and count>0 then
      local GUID
      for i=0,count-1 do
        ts_embed_string_guid = string.gsub(ts_embed_string, "Count", "At("..tostring(i)..") Guid")
        GUID = ObjectFinderSerp.DoForSessionGameObject(ts_embed_string_guid,true)
        if GUID~=nil and GUID~="nil" then
          results[tonumber(GUID)] = true -- use it as key, so you can easily check for a specific one without looping over the list
        end
      end
    end
  end
  return results
end

-- only returns coop players viewing the same object like you, not yourself!
-- to get username use: ts.Online.GetUsername(peerint)
-- for StatisticsMenu UIState = 176, for ships it is 119 (it is called RefGuid in infotips for whatever reason), get them eg with adding your log function to table event.OnLeaveUIState and log the one paramater of this function
-- CompynaMenu (hitting on your profile) is UIState = 0, diplomenu=29, TradeRoutemenu is 165 or 177, 
-- RefOid = 0 for whole menus , for ships/buildings: ObjectFinderSerp.IDConverter.get_OID(session.getSelectedFactory()) 
local function GetCoopPeersAtMarker(UIState,RefOid)
  local count = ObjectFinderSerp.DoForSessionGameObject("[Online GetCoopPeersAtMarker("..tostring(UIState)..","..tostring(RefOid)..") Count]",true)
  local peerints = {}
  if count~=nil and count~="nil" then
    count = tonumber(count)
    if count~=nil and count>0 then
      local peerint
      for i=0,count-1 do
        peerint = ObjectFinderSerp.DoForSessionGameObject("[Online GetCoopPeersAtMarker("..tostring(UIState)..","..tostring(RefOid)..") At("..tostring(i)..")]",true)
        if peerint~=nil and peerint~="nil" then
          peerints[tonumber(peerint)] = true -- use it as key, so you can easily check for a specific without looping over the list
        end
      end
    end
  end
  return peerints
end


-- ###########################################

-- eg to share in lua with other humans: info what the human has unlocked (since in lua we can only check what we ourself have unlocked, but not what others have -.-)
-- invalid signs in strings (to save it into nameable): " \ , [ ] and () if both used
  
-- WICHTIGE INFO zu Nameable:

-- 1) Bei SetName("string") wird lokal für den ausführenden Spieler sofort dieser String als Name hinterlegt und kann
 -- auch sofort imselben Tick wieder mit GetName() zurückerhalten werden.
 -- Das ist besonders hilfreich, wenn wir dadrin zb. bei DoForSessionGameObject lokal andere Informationen drin speichern müssen
  -- dh. selbst wenn die Skripte quasi zeitgleich für jeden lokalen Spieler ausgeführt werden, bekommen sie mit GetName imselben Tick nur das zurück, was sie selbst reingeschrieben haben.
-- 2) ts.GetGameObject(HelperOID).Nameable.SetName(infostring) für fremde sessions funktioniert im Singleplayer unabhängig von der Session.
--  Aber wenn der ausführende Spieler in einer anderen Session als das Objekt ist, dann klappt es nur für ihn selbst! für andere Spieler im MP bleibt der alte Namen bestehen.
--  Lösung: DoForSessionGameObject für die Namensänderung nehmen
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

-- DONT USE THIS Get_Nameable_Helper_OID in your mod! (because this HelperOID is limited and usd for important things you should not block!)
local function Get_Nameable_Helper_OID()
  local HelperOID
  local CPID = ts.Participants.GetGetCurrentParticipantID()
  if CPID==0 then
    HelperOID = ObjectFinderSerp.ObjectFinderCacheSerp["Nameable_Helper_OIDs"]["Human0Share"]
  elseif CPID==1 then
    HelperOID = ObjectFinderSerp.ObjectFinderCacheSerp["Nameable_Helper_OIDs"]["Human1Share"]
  elseif CPID==2 then
    HelperOID = ObjectFinderSerp.ObjectFinderCacheSerp["Nameable_Helper_OIDs"]["Human2Share"]
  elseif CPID==3 then
    HelperOID = ObjectFinderSerp.ObjectFinderCacheSerp["Nameable_Helper_OIDs"]["Human3Share"]
  end
  return HelperOID
end

local function ShareLuaInfo(infostring,HelperOID)
  if ObjectFinderSerp.ShareLuaInfo_BLOCKED then
    return false
  end
  if HelperOID~=nil then
    infostring = tostring(infostring)
    ObjectFinderSerp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(HelperOID)..") Nameable Name("..tostring(infostring)..")]")
    
    ObjectFinderSerp.ShareLuaInfo_BLOCKED = true
    for i=1,10 do -- waiting 20 yields should hopefully be enough to sync the name to all players (in a new game with 2 sessions with few ships/buildings it already takes 4 yields!)
      coroutine.yield()
    end
    if infostring=="nil" then -- only show it unblocked when it was set to nil again, so in tital it will be blocked at least 40 yields
      ObjectFinderSerp.ShareLuaInfo_BLOCKED = false
    end
    
    return ts.GetGameObject(HelperOID).Nameable.GetName()==infostring -- show success -- only shows if string is valid, does not confirm that everyone can see this name now! it takes a few yields for all to see it..
  end
end
-- after usage, please use again ShareLuaInfo to set the string to "nil" again
local function GetSharedLuaInfo(HelperOID)
  if HelperOID~=nil then
    return ts.GetGameObject(HelperOID).Nameable.GetName()
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
local function AreatableToAreaID(Areatable)
  if type(Areatable)=="table" then
    local AreaIndex,IslandID,SessionID = Areatable["AreaIndex"],Areatable["IslandID"],Areatable["SessionID"]
    if type(AreaIndex)=="number" and type(IslandID)=="number" and type(SessionID)=="number" then
      return ((AreaIndex << 13)+(IslandID << 6)+SessionID)
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
local function OIDtableToOID(OIDtable)
  local AreaID, ObjectID
  if type(OIDtable)=="table" then 
    ObjectID = OIDtable["ObjectID"]
    if type(OIDtable["AreaID"])=="table" then
      AreaID = AreatableToAreaID(OIDtable["AreaID"])
    elseif type(OIDtable["AreaID"])=="number" then
      AreaID = OIDtable["AreaID"]
    end
  end
  if type(ObjectID)=="number" and type(AreaID)=="number" then
    return ((AreaID << 32) + (ObjectID))
  end
end

local function OIDToOIDtable(OID)
  if type(OID)=="number" then
    local AreaID = ((OID) >> 32)
    local ObjectID = (OID & 0xFFFFFFFF)
    local Areatable = AreaIDToAreatable(AreaID)
    return {ObjectID=ObjectID,AreaID=Areatable}
  end
end

-- alternative function to get_oid_int (instead of :getOID + OIDtableToOID)
-- it also works for EditorFlag and other special objects we don't have the formula yet
local function get_OID(userdata)
  local oid,Namestring
  Namestring = userdata:getName() -- returns eg. "GameObject, oid 8589934647", while :getOID returns a OIDtable.
  if Namestring~=nil and type(Namestring)=="string" then
    oid = string.match(Namestring, "oid (.*)")
    if oid~=nil and type(oid)=="string" then
      oid = tonumber(oid)
    end
  end
  return oid
end

-- ###################################################################################################
-- ###################################################################################################
-- ###################################################################################################

-- Find Objects functions

-- ###################################################################################################

-- GetCurrentSessionObjectsFromLocaleByProperty
-- lightweight and quite fast function, but can only fetch objects from the local executing player in the session he is currently it.

-- see here for a list of PropertyID : https://github.com/anno-mods/modding-guide/blob/main/Scripting/ENUMs.md#propertyids
-- or see properties-toolone.xml order of properties listed.
-- or use a string as property, the function will convert it for you
local function GetCurrentSessionObjectsFromLocaleByProperty(Property)
  local PropertyID
  if type(Property)=="number" then
    PropertyID = Property
  elseif type(Property)=="string" then
    PropertyID = PropertiesStringToID[Property]
  end
  local GUID,OIDtable,OID
  local Objects = {}
  local userdatas = session.getObjectGroupByProperty(PropertyID) -- game.MetaGameManager finds the same like session...
  local SessionGuid = session.getSessionGUID() -- only current session is found by getObjectGroupByProperty
  local ParticipantID = ts.Participants.GetGetCurrentParticipantID() -- finds only objects from local player
  if PropertyID~=nil and type(userdatas)=="table" and #userdatas>0 then
    for k,userdata in ipairs(userdatas) do
      if userdata~=nil then -- is never nil, but nullpointer if not assigned. but here it should always be assigned
        OID = ObjectFinderSerp.IDConverter.get_OID(userdata)
        GUID =  ts.Objects.GetObject(OID).GUID
        if GUID~=0 then -- is not the case here, but just to be save
          Objects[OID] = {GUID=GUID, userdata=userdata, OIDtable=OIDtable}
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
local function IsLoadedSessionByID(SessionID)
  local IslandID,AreaIndex = 0,0
  local SessionGuid
  local AreaID = AreatableToAreaID({SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex})
  for ObjectID=1,10 do -- to find  Neutral SessionParticipant checking the first 10 ObjectIDs should be enough
    OID = OIDtableToOID({ObjectID=ObjectID,AreaID=AreaID})
    local GUID = ts.GetGameObject(OID).GUID
    if GUID==34 then
      return ts.GetGameObject(OID).SessionGuid
    end
  end
end

-- ###################################################################################################

-- TODO:
-- LeereObIDs entfernen, zu viel um sich da was zu merken,
 -- Und dafür sorgen dass mithilfe von ShareLuaInfo infos zwischen alle Spielern ausgetauscht werden,
  -- vorallem LowObID und invalide AreaIDs
 -- Dazu könnte man die Peers Info vom CoopPeers Mod nutzen (TODO: diesen am besten auch direkt hier includen, anstat als einzelner mod? Denn mal wieder brauchen sich beide gegenseitig)
  -- dazu durch alle besetzten peers loopen, und wenn local der besetzte peer ist, dann ShareLuaInfo ausführen mit einem delay von 2000*(peerint+1) oderso
   -- wodurch alle peers nacheinander ihre infos reinschreiben. und die nicht der peer sind, sie rauslesen und ihren infos zufügen.
  
  -- LowObID auch für Area nutzen! 
   -- Wenn LowObID bekannt und auch noch valid ist, dann in GetAnyObjectsFromAnyone DoForSessionGameObject nutzen
    -- um an Area des Objects zu kommen und auf diese Weise AreaOwnerName zu prüfen!
  -- wobei ... wenn wir ein LowObID haben, dann heißt das automatisch bereits, dass das Area valid ist.
    -- und die valid-Prüfung ist ja erstmal das einzige was uns in GetAnyObjectsFromAnyone fehlt.  
   -- und nur weil ein Area garkein Objekt hat, heißt es halt leider nicht, dass es invalid ist,
    -- sondern kann auch einfach noch unbesiedelt sein... und solange es in fremder session ist, können wir das nicht prüfen...
  -- Aber:
   -- man könnte on IslandSettled jedesmal den AreaLooper anstoßen, welcher sich dabei jedesmal den Kontor als LowObID merkt,
    -- da mindestens einer der Spieler beim settlen ja wohl offensichtlich in der session ist (Inselübernahme testen)
     -- (bei islandsettle von KI klappt das natürlich nicht unbedingt)
   -- und dann könnte man bei GetAnyObjectsFromAnyone dann allgemein nur Areas prüfen, die bekannt sind...
    -- (bzw. dieses "nur islands prüfen die bekannt sind" könnte man evlt noch als Argument übergeben?)
     
     -- Und als Tipp zufügen, dass man next_AreaID returnen soll, wenns der falsche Participant ist
  

 -- GetCurrentSessionObjectsFromAnyone
-- Objects from session the locale player is in curently, but from anyone.
-- Similar code like GetAnyObjectsFromAnyone, but much simpler and used if you only need current session (other sessions only work very limited)

-- Does not work for objects with EditorFlag, which are mostly objects at the map from beginning, like Pirate/Archibald harbor/objects. (because their OID is higher than lua can handle eg archibald harbor 9223413826886612345)
-- see also my comments below for GetAnyObjectsFromAnyone
function GetCurrentSessionObjectsFromAnyone(args)
  local ObjectFilter,FromSessionID,ToSessionID,FromIslandID,ToIslandID,FromAreaIndex,ToAreaIndex,FromObjectID,ToObjectID,withyield,nosave = args["ObjectFilter"],args["FromSessionID"],args["ToSessionID"],args["FromIslandID"],args["ToIslandID"],args["FromAreaIndex"],args["ToAreaIndex"],args["FromObjectID"],args["ToObjectID"],args["withyield"],args["nosave"]
  local Objects = {}
  local AreaID,OID,CheckingSessionGuid
  local filterresult,AreaOwnerName,Kontor_OIDtable,Kontor_OID,objectcount,HighestObjectID,LowestObjectID,GUID,SessionGuid,ParticipantID,userdata,sessionisloaded,CheckingSessionGuid
  local ExecutingSessionGUID = session:getSessionGUID()
  FromSessionID = FromSessionID or 1
  ToSessionID = ToSessionID or 12
  FromIslandID = FromIslandID or 0 -- is 0 for eg. ships and other things not bound to islands
  ToIslandID = ToIslandID or 80
  FromAreaIndex = FromAreaIndex or 0 -- is 0 for eg. ships and other things not bound to islands
  ToAreaIndex = ToAreaIndex or 1 -- can be 2 for islands sharing two owners , like ketema island. but unlikely that we need it, so default to only 1
  FromObjectID_ = FromObjectID or 1 -- removed objects/ships leaving session leave empty OBjectIDs, so sometimes, especially on takeover of islands, the first valid ObjectID might be in the tenthousands.
  ToObjectID_ = ToObjectID or 1000000 -- on very big/old savegames you should check up to 1 million or even more ... better try to save/check your current lowest/highest OID and enter lower number here
  for SessionID=FromSessionID,ToSessionID do
    CheckingSessionGuid = IsLoadedSessionByID(SessionID)
    if ExecutingSessionGUID == CheckingSessionGuid then -- here we only chek the current session
      if ObjectFinderSerp.ObjectFinderCacheSerp["ObIDs"][SessionID]== nil then
        ObjectFinderSerp.ObjectFinderCacheSerp["ObIDs"][SessionID] = {}
      end
      for IslandID=FromIslandID,ToIslandID do
        for AreaIndex=FromAreaIndex,ToAreaIndex do
          if not ((IslandID==0 and AreaIndex~=0) or (IslandID~=0 and AreaIndex==0)) then -- on water both are 0. on islands none of them is 0, so do not allow only one of them being 0.
            AreaID = AreatableToAreaID({SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex})
            local CacheObIDsSessionID = ObjectFinderSerp.ObjectFinderCacheSerp["ObIDs"][SessionID] -- I think its better for performance to save it in a variable
            if CacheObIDsSessionID[AreaID]~=false then
              if CacheObIDsSessionID[AreaID]==nil or CacheObIDsSessionID[AreaID]["valid"]~=true then
                AreaOwnerName = ts.Area.GetAreaFromID(AreaID).OwnerName -- check if the Area is valid
                if IslandID~=0 and (AreaOwnerName=="" and ts.Area.GetAreaFromID(AreaID).Owner==0) then -- invalid area. while for unsettled area owner will be -1. (OwnerName ist better than Owner here, because invalid areas are nullpointer and would return 0 for Owner, which also might be Human0 on valid areas)
                  CacheObIDsSessionID[AreaID] = false -- remember this Area as invalid, so we don't have to check it ever again.
                end
              end
              if CacheObIDsSessionID[AreaID]~=false then
                if withyield then
                  coroutine.yield()
                end
                FromObjectID_ = FromObjectID or 1
                ToObjectID_ = ToObjectID or 1000000
                
                -- Area = ts.Area.GetAreaFromID(AreaID) -- also corrupts on multi use, so we have to call this everytime again!
                
                Kontor_OIDtable = ts.Area.GetAreaFromID(AreaID).KontorID
                Kontor_OID = OIDtableToOID(Kontor_OIDtable)
                if CacheObIDsSessionID[AreaID]== nil then
                  CacheObIDsSessionID[AreaID] = {LeereObIDs={},LowObID=nil,HighObID=nil}
                end
                CacheObIDsSessionID[AreaID]["valid"] = true -- if we reach here, below the AreaOwnerName+Owner check, we know for sure the area is valid, so we dont have to check that again in the future
                if IslandID==0 or AreaOwnerName~="" then -- if not Water (IslandID==0), make sure Area is owned by someone
                  if IslandID~=0 then
                    CacheObIDsSessionID[AreaID]["LowObID"] = Kontor_OIDtable["ObjectID"] -- Kontor should be the first building on every owned island, so it is enough to start there with counting
                  end
                  if FromObjectID==nil and CacheObIDsSessionID[AreaID]["LowObID"]~=nil then
                    FromObjectID_ = CacheObIDsSessionID[AreaID]["LowObID"]
                  end
                  -- if ToObjectID==nil and CacheObIDsSessionID[AreaID]["HighObID"]~=nil then
                    -- ToObjectID_ = CacheObIDsSessionID[AreaID]["HighObID"] + 10000 -- wenn gesetzt, MUSS HighObID natürlich regelmäßig abgefragt werden, müssten wir also zb. selbst alle 5 min oderso hier anstoßen... 
                  -- end
                  objectcount = 0
                  -- HighestObjectID = 0 -- können wir hier nicht immer messen, weil wir ja evlt vorher breaken. lieber außerhalb in einer ObjectFilter fkt testen
                  LowestObjectID = nil
                  for ObjectID=FromObjectID_,ToObjectID_ do
                    if not CacheObIDsSessionID[AreaID]["LeereObIDs"][ObjectID] then
                      filterresult = nil
                      OID = OIDtableToOID({ObjectID=ObjectID,AreaID=AreaID})
                      if withyield then
                        objectcount = objectcount + 1
                        if objectcount % 10000 == 0 then
                          coroutine.yield()
                        end
                      end
                      GUID = ts.Objects.GetObject(OID).GUID
                      if GUID~=0 then -- GUID==0 means nullpointer, does not have an object
                        SessionGuid = ts.Objects.GetObject(OID).SessionGuid -- should be the same as CheckingSessionGuid, but just to be sure
                        ParticipantID = ts.Objects.GetObject(OID).Owner
                        userdata = session.getObjectByID(OID)
                        if LowestObjectID==nil then
                          LowestObjectID = ObjectID
                        end
                        if type(ObjectFilter)=="function" then
                          filterresult = ObjectFilter(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID)
                        end
                        if filterresult~=nil and type(filterresult)=="table" and filterresult["addthis"] then
                          Objects[OID] = {GUID=GUID,ParticipantID=ParticipantID,userdata=userdata,SessionGuid=SessionGuid,SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex,ObjectID=ObjectID}
                        end
                        if filterresult~=nil and type(filterresult)=="table" and (filterresult["next_AreaID"] or filterresult["done"]) then
                          break
                        end
                      elseif Kontor_OID==OID then -- if it claims to have a kontor, but its GUID is 0, then just skip this area
                        CacheObIDsSessionID[AreaID] = false -- remember this Area as invalid, so we don't have to check it ever again.
                        break -- this happens for Editor Objects, eg. Kontor from third parties. They have in fact OID 9223413826886612345 and EditorFlag=1 which makes the number much higher. But lua can not handle this high number anyways, trying to get GUID from 9223413826886612345 just results in an error.  -- so no suport for Editor Objects.
                      -- else -- just empty meanwhile. wont be used by the game anymore, so save this in our cache...  too inefficient to save every single on. need to find a better way...
                        -- CacheObIDsSessionID[AreaID]["LeereObIDs"][ObjectID]=true
                      end
                    end
                  end
                  if LowestObjectID~=nil and (CacheObIDsSessionID[AreaID]["LowObID"]==nil or LowestObjectID > CacheObIDsSessionID[AreaID]["LowObID"]) then  
                    CacheObIDsSessionID[AreaID]["LowObID"] = LowestObjectID
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
    if filterresult~=nil and type(filterresult)=="table" and (filterresult["next_SessionID"] or filterresult["done"]) then
      break
    end
  end
  if not nosave then -- eg when searching for the save helper object, we can not save already
    SaveCache()
  end
  return Objects
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
-- And eg. ts.Area.GetAreaFromID(AreaID).CityName will NOT WORK for other session than the current one! (therefore the "Area" provided to the ObjectFilter function will be nil in this case)
  -- (also ts.GetGameObject(OID).Area does not work for objects from other sessions)
  -- this also means my function is far more inefficient in other sessions than the currently active one (since it can not properly check for invalid Areas and KontoObjectID)
 -- if you want to check Area Stuff on Sessions that are not the current one, use function "DoForSessionGameObject" on a found valid OID.

-- Does not work for objects with EditorFlag, which are mostly objects at the map from beginning, like Pirate/Archibald harbor/objects. (because their OID is higher than lua can handle eg archibald harbor 9223413826886612345)

-- BEWARE: using too high ToObjectID, this can take VERY LONG, like hours. By default I will use ToObjectID = 100.000, this only takes few seconds, but may not be enough on very big/old savegames
  -- So reduce the search-work by using the ObjectFilter and return in a table "done=true" (called "filterresult" here), as soon as you found the object you are searching for (to stop the search-loop)
  -- Or change FromObjectID/ToObjectID to match the expected currently used ObjectIDs-range. Eg. spawn a new object for local player and get his ObjectID somehow (eg with GetCurrentSessionObjectsFromLocaleByProperty) to find out the current highest ObjectID used (within the spawned AreaID!) 
-- see "my_ObjectFilter" below for examples how to use it
-- set withyield to true and start the function within a coroutine to yield on every new areaand every 10k objects, to prevent game-blocking on big searches (search takes longer then, but does not block. so use this if time does not matter much)
function GetAnyObjectsFromAnyone(args)
  local ObjectFilter,SessionFilter,FromSessionID,ToSessionID,FromIslandID,ToIslandID,FromAreaIndex,ToAreaIndex,FromObjectID,ToObjectID,withyield,nosave = args["ObjectFilter"],args["SessionFilter"],args["FromSessionID"],args["ToSessionID"],args["FromIslandID"],args["ToIslandID"],args["FromAreaIndex"],args["ToAreaIndex"],args["FromObjectID"],args["ToObjectID"],args["withyield"],args["nosave"]
  local Objects = {}
  local AreaID,OID,SessionIsCurrent,CheckingSessionGuid
  local filterresult,AreaOwnerName,Kontor_OIDtable,Kontor_OID,objectcount,HighestObjectID,LowestObjectID,GUID,SessionGuid,ParticipantID,userdata,sessionisloaded,CheckingSessionGuid,CurrentSessionObjects
  local ExecutingSessionGUID = session:getSessionGUID()
  FromSessionID = FromSessionID or 1
  ToSessionID = ToSessionID or 12 -- TODO test wieder auf 12 oderso setzen
  FromIslandID = FromIslandID or 0 -- is 0 for eg. ships and other things not bound to islands
  ToIslandID = ToIslandID or 80 -- todo auf 80 erhöhen sobald optimiert
  FromAreaIndex = FromAreaIndex or 0 -- is 0 for eg. ships and other things not bound to islands
  ToAreaIndex = ToAreaIndex or 1 -- can be 2 for islands sharing two owners , like ketema island. but unlikely that we need it, so default to only 1
  FromObjectID_ = FromObjectID or 1
  ToObjectID_ = ToObjectID or 10000 -- TODO wieder auf 100k erhöhen -- could be something in billion (milliarden) range on very big/old savegames... better try to save/check your current highest OID and enter lower number here
  for SessionID=FromSessionID,ToSessionID do
    CheckingSessionGuid = IsLoadedSessionByID(SessionID)
    SessionIsCurrent = ExecutingSessionGUID == CheckingSessionGuid
    if CheckingSessionGuid~=nil then
      if ObjectFinderSerp.ObjectFinderCacheSerp["ObIDs"][SessionID]==nil then
        ObjectFinderSerp.ObjectFinderCacheSerp["ObIDs"][SessionID] = {}
      end
      session_ok = type(SessionFilter)=="function" and SessionFilter(SessionID,CheckingSessionGuid) or true
      if session_ok then -- not really needed if we find objects and reach the ObjectFilter call (then use next_SessionID), but eg. if we want to only check Areas then we wont find Neutral object and reach ObjectFilter quite late. So use SessionFilter to sort out unwanted session early to save performance
        if SessionIsCurrent then
          sessionargs = deepcopy(args)
          sessionargs["FromSessionID"] = SessionID
          sessionargs["ToSessionID"] = SessionID
          CurrentSessionObjects = GetCurrentSessionObjectsFromAnyone(sessionargs)
          for CS_OID,CS_objectinfo in pairs(CurrentSessionObjects) do
            Objects[CS_OID] = CS_objectinfo
          end
          -- TODO: testen ob das so problemlos funzt
           -- wenn man in GetCurrentSessionObjectsFromAnyone ein "done" returned, kommt das hier in dieser FKT nicht an...
            -- entweder ändern was fkt returned..
             -- oder uns bei Anwendung außerhalb vom ObjectFilter merken, dass wir einmal schon bei "done=true" waren und das dann bei folgenden
              -- Aufrufen immer wieder returnen
        else
          for IslandID=FromIslandID,ToIslandID do
            for AreaIndex=FromAreaIndex,ToAreaIndex do
              if not ((IslandID==0 and AreaIndex~=0) or (IslandID~=0 and AreaIndex==0)) then -- on water both are 0. on islands none of them is 0, so do not allow only one of them being 0.
                AreaID = AreatableToAreaID({SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex})
                local CacheObIDsSessionID = ObjectFinderSerp.ObjectFinderCacheSerp["ObIDs"][SessionID] -- I think its better for performance to save it in a variable
                if CacheObIDsSessionID[AreaID]~=false then -- dont check Areas we already marked as invalid
                  if withyield then
                    coroutine.yield()
                  end
                  FromObjectID_ = FromObjectID or 1
                  ToObjectID_ = ToObjectID or 1000000
                  -- we have no way to check if the Area is valid/settled (checking Area only works in correct session),
                    -- if we did not mark it already as invalid in ObjectFinderCacheSerp, so it will be quite inefficient at first
                    -- if we find an not-null object here, we can get info about Area via SessionGameObject text-embed. But this does not help
                     -- to to filter invalid/unsettled Areas, because this way we only now the current is valid and settled, but other might get settled in the future, so we should not skip them the next times
                    if CacheObIDsSessionID[AreaID]==nil then
                      CacheObIDsSessionID[AreaID] = {LeereObIDs={},LowObID=nil,HighObID=nil}
                    end
                    if FromObjectID==nil and CacheObIDsSessionID[AreaID]["LowObID"]~=nil then
                      FromObjectID_ = CacheObIDsSessionID[AreaID]["LowObID"]
                    end
                    -- if ToObjectID==nil and CacheObIDsSessionID[AreaID]["HighObID"]~=nil then
                      -- ToObjectID_ = CacheObIDsSessionID[AreaID]["HighObID"] + 10000 -- wenn gesetzt, MUSS HighObID natürlich regelmäßig abgefragt werden, müssten wir also zb. selbst alle 5 min oderso hier anstoßen... 
                    -- end
                    
                    objectcount = 0
                    -- HighestObjectID = 0 -- können wir hier nicht immer messen, weil wir ja evlt vorher breaken. lieber außerhalb in einer ObjectFilter fkt testen
                    LowestObjectID = nil
                    for ObjectID=FromObjectID_,ToObjectID_ do
                      if not CacheObIDsSessionID[AreaID]["LeereObIDs"][ObjectID] then
                        filterresult = nil
                        OID = OIDtableToOID({ObjectID=ObjectID,AreaID=AreaID})
                        if withyield then
                          objectcount = objectcount + 1
                          if objectcount % 10000 == 0 then
                            coroutine.yield()
                          end
                        end
                        GUID = ts.GetGameObject(OID).GUID -- using GetGameObject to also fetch objects from other sessions. if it does not exist, it will be nullpointer
                        if GUID~=0 then -- GUID==0 means nullpointer, does not have an object
                          -- modlog(tostring(OID)..","..tostring(AreaID)..","..tostring(GUID)..","..tostring(ts.Area.GetAreaFromID(AreaID).Owner)..", KontorObjectID :"..tostring(Kontor_OIDtable["ObjectID"]))
                          SessionGuid = ts.GetGameObject(OID).SessionGuid -- should be the same as CheckingSessionGuid but just to be sure
                          ParticipantID = ts.GetGameObject(OID).Owner
                          userdata = nil -- game.MetaGameManager.getObjectByID(OID)  -- only accessable in same session
                          if LowestObjectID==nil then
                            LowestObjectID = ObjectID
                          end
                          if type(ObjectFilter)=="function" then
                            filterresult = ObjectFilter(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID)
                          end
                          if filterresult~=nil and type(filterresult)=="table" and filterresult["addthis"] then
                            Objects[OID] = {GUID=GUID,ParticipantID=ParticipantID,userdata=userdata,SessionGuid=SessionGuid,SessionID=SessionID,IslandID=IslandID,AreaIndex=AreaIndex,ObjectID=ObjectID}
                          end
                          if filterresult~=nil and type(filterresult)=="table" and (filterresult["next_SessionID"] or filterresult["next_AreaID"] or filterresult["done"]) then
                            break
                          end
                        -- else -- just empty meanwhile. wont be used by the game anymore, so save this in our cache...  too inefficient to save every single on. need to find a better way...
                          -- CacheObIDsSessionID[AreaID]["LeereObIDs"][ObjectID]=true
                        end
                      end
                    end
                    if LowestObjectID~=nil and (CacheObIDsSessionID[AreaID]["LowObID"]==nil or LowestObjectID > CacheObIDsSessionID[AreaID]["LowObID"]) then  
                      CacheObIDsSessionID[AreaID]["LowObID"] = LowestObjectID
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
        end
      end
    end
    if filterresult~=nil and type(filterresult)=="table" and filterresult["done"] then
      break
    end
  end
  if not nosave then -- eg when searching for the save helper object, we can not save already
    SaveCache()
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
  local function Area_filterfunc(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID)
    done = executionfunc(SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex)
    return {addthis=false,done=done,next_AreaID=true,next_SessionID=false}
  end
  GetCurrentSessionObjectsFromAnyone({ObjectFilter=Area_filterfunc,FromSessionID=nil,ToSessionID=nil,
    FromIslandID=1,ToIslandID=nil,FromAreaIndex=1,ToAreaIndex=nil,FromObjectID=nil,ToObjectID=nil,withyield=withyield})
end

-- example usage:
-- ObjectFinderSerp.AreasCurrentSessionLooper(function(SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex)
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

local function GetLoadedSessions(FromSessionID,ToSessionID)
  local Sessions = {}
  FromSessionID = FromSessionID or 1
  ToSessionID = ToSessionID or 30
  for SessionID=FromSessionID,ToSessionID do
    CheckingSessionGuid = IsLoadedSessionByID(SessionID)
    if CheckingSessionGuid~=nil then
      Sessions[SessionID] = CheckingSessionGuid
    end
  end
  return Sessions  -- eg {[SessionID] = SessionGUID}
end

-- ###################################################################################################
-- ###################################################################################################
-- ###################################################################################################
-- ###################################################################################################


-- EXAMPLE ObjectFilter for usage with GetAnyObjectsFromAnyone
-- Unfortunately errors in your filter func will most likely not be logged in the anno logfile.
 -- So if it does not work like expeceted add some prints/modlog to it for debugging

-- ts.Area.GetAreaFromID(AreaID).CityName will be an empty string for invalid Areas, eg the IslandID=0 water area.
 -- Of course you can still find ships in that AreaID, but no city/buildings

-- simply example ObjectFilter
local function my_ObjectFilter(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID)
  if GUID==100438 and ParticipantID==1 and ts.GetGameObject(OID).Nameable.Name=="Hans" then
    return {addthis=true,done=true} -- add it and stop searching, everything found wanted to find
  end
end 
-- complex example To find objects with ParticipantID=0 , GUID=100438 and Names Hans/Franz. in total 2 objects to be found in Old world session 180023
-- you can of course also count yourself in a variable defined outside of my_ObjectFilter in your script how many you already found and if it is enough.
local function my_ObjectFilter(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID)
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
  -- local success = ObjectFinderSerp.CheckObjectHelpers.HasProperty(userdata,i)
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


-- ###################################################################################################
-- ###################################################################################################
-- ###################################################################################################
-- ###################################################################################################



-- here the functions you can use with help of this script
-- search the function names in this file to get short explanation

-- 
ObjectFinderSerp = ObjectFinderSerp or {
  -- stuff for internal use
  FindHelperOIDs = FindHelperOIDs,
  ObjectFinderCacheSerp = {ObIDs={},Nameable_Helper_OIDs={}},
  Get_Nameable_Helper_OID = Get_Nameable_Helper_OID, -- DONT USE THIS in your mod!
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
  DoForSessionGameObject = DoForSessionGameObject,
  -- only use ShareLuaInfo/GetSharedLuaInfo with your own HelperOID !!!!
  ShareLuaInfo = ShareLuaInfo,
  GetSharedLuaInfo = GetSharedLuaInfo,
  GetFertilitiesOrLodesFromArea_CurrentSession = GetFertilitiesOrLodesFromArea_CurrentSession,
  GetVectorGuidsFromSessionObject = GetVectorGuidsFromSessionObject,
  GetCoopPeersAtMarker = GetCoopPeersAtMarker,
  -- object loopers
  GetCurrentSessionObjectsFromLocaleByProperty = GetCurrentSessionObjectsFromLocaleByProperty,
  GetCurrentSessionObjectsFromAnyone = GetCurrentSessionObjectsFromAnyone,
  GetAnyObjectsFromAnyone = GetAnyObjectsFromAnyone,
  AreasCurrentSessionLooper = AreasCurrentSessionLooper,
  GetLoadedSessions = GetLoadedSessions,
}



-- call it AFTER ObjectFinderSerp was defined, because otherwise it can happen that they call eachother endless times, because both need the other
if SaveLuaStuff_Serp==nil then
  console.startScript("data/scripts_serp/saveload/savetablestuff.lua")
end