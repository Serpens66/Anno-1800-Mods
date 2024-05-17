print("execute hijack script ..",ts.GameClock.CorporationTime)



-- WICHTIG:
-- TODO:
-- CoopPeers mod macht Quatsch wenn ich Multiplayer Spiel von jan und amrtin lade?!
-- 1) wird diplo menü geöffnet, geschlossen und wieder geöffnet (muss man also evlt länger warten damits erkannt wird?)
-- 2) sollte sich das eigenltich garnicht öffnen, wenn ich der einzige aktive coop spieler bin ?!

-- SCHEIßE !
-- Das liegt daran, dass ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i)
 -- auch für Spieler die gerade nicht aktiv sind eine session returned!! 
  -- Wieso ?! ich dachte das wäre save -.- Shit...

-- Damit ist mein CoopCounter Rework und wohl auch Peers im Arsch...
  
  -- ObjectFinderSerp.GetCoopPeersAtMarker(29,0) returned aber weiterhin korrekt, also wenn ich alleine bin, 
   -- dann nur eine leere Liste
  -- dh wir können weiterhin rausfinden, wer wir sind...
   -- aber über GetActiveSessionGUIDOfPeerInt nicht, wer gerade aktiv ist.
  -- -> Dafür dann wohl auch GetCoopPeersAtMarker nutzen, wenn es leer returned, wissen wir
   -- dass wir der einzige sind.
 -- Aber wenn es zb 1 PeerInt returned, wie wissen wir dann eindeutig, welcher von beiden nun der "first" ist?
 -- Das kriegen wir weiterhin raus, weil wir ja PeerInt kennen, also 0 ist halt first, wenn aktiv, also wenn sein PeerInt in GetCoopPeersAtMarker enthalten war
   
-- Aber dass GetActiveSessionGUIDOfPeerInt auch für inaktive returned machts nötig diverse Funktionen neu zu schreiben
 -- und darin dann auch nur aktive peers abzufragen.
  
-- DUMMERWEISE:
 -- ist mein code um auf CoopPeers_Serp.PeerInt zu kommen auch murks..
-- wenn wir über marker Peerint=4 returned bekommen,
 -- heißt das nicht zwangsweise, dass wir selbst peerint 0 sind.
  -- Es kann auch heißen, dass 0 nicht aktiv im spiel ist und wir sind 8 -.-
  
  -- [GameSetup GetParticipantPeers(0) Count]
  -- returned auch nur welche Peers jemals im Spiel waren (also bei Spielstart) (wobei bestimmt auch welche hinzukommen können, also ists eher "wer jjemals mind einaml aktiv war")
   -- oderso. also im 3er spiel returned es 3 und die peerints 0, 4 und 8.
  
-- aber wie finden wir raus, dass diese aber gerade nicht mehr aktiv im spiel sind ?!?!  
  
 
 -- ok folgende notlösung:
 -- Wenn wir bei Marker nur 4 returned bekommen, prüfen wir dennoch GetActiveSessionGUIDOfPeerInt. 
  -- Und wenn dann für 8 die 0 returned wird, weil dieser slot nie gefüllt war, dann ist alles gut, wir müssen also selbst die 0 sein
 -- Aber wenn halt auch die 8 mal im spiel war, jetzt aber entweder die 0 oder die 8 es offenbar nicht mehr ist,
  -- dann können wir nicht drauf kommen wer wir selbst sind
   -- und in dem Fall würde ich dann wieder das PopUp starten, welches die User fragt wer sie sind...
  -- (die aktuelle Session vom local kann man natürlich auch nochmal mit den anderen möglichen Positionen vergleichen, selten löst man das dann darüber
   -- bevor wir dann das popup brauchen)
 -- Allerdings: ein Ja/Nein Popup reicht nicht, wenn wir sowas wie ImFirstCoopPeerInSession (nur aktive prüfen) testen wollen...
  -- kriegen maximal 3 button angezeit, wobei das schon scheiße aussieht.
   -- hm wie könnte man diese dann nutzen, um von jedem die position am ende zu haben?
  -- im worst case spielt man halt zu zweit während es mal 4 im coop waren.
   -- Dann weiß man, dass man einer der 3 peers ist, die nicht mit marker angezeigt werden.
  -- Also könnte man theoretisch diese 3 peers zur auswahhl stellen im Popup, nur den Text vom popup bekommen wir nicht so leicht
   -- variabel und schon garicht den command der dazu gehört...
  -- für zur wahl stehende peerint zur not ein nameable helerp spawnen, oder auch nochmal gucken obs nicht mehr dinge wie SetRandomSeed gibt,
   -- wo man keinen einfluss aufs spiel hat, aber dennoch ne zahl local abspeichert (wobei wenn ich randomseed nutzen will, eblt doch mal testen obs einfluss im spiel hat
    -- also ob die geladenen eneue welt session dadurch ne andere wird)
     -- den korrekten Peerint dann in der NAchricht mit UserName(peerint) versehen, damit die Nutzer quasi nur auf ihren eigenen usernamen klicken müssen
  
  
  -- Und bevor wir das Diplo Menü öffnen, 
   -- vllt mal checken ob alle (aktive oder inaktive, kann man ja nicht unterscheiden) Spieler in derselben Session sind.
   -- Wenn sie es sich, dann mal session.selectNextObject() oder session.selectNextObjectInWorld probieren,
    -- ob sie dabei immer dasselbe objekt anwählen? bzw. wenn ja, muss es dann immer ein eigenes sein, damit marker funzt?
     -- ja session.selectNextObject() selected be beiden dasselbe, sofern sie noch nichts selected haben, was nach laden eines spielstandes der fall sein sollte (und sie in selber session sind)
      -- (keine ahnung was unterschied zu selectNextObjectInWorld ist)
  -- geht darum, dass wir in diesem Fall das öffnen eines UIs vermeiden könnten..
  -- zuallerserst gucken ob alle in untersch  seession sind, dann gehts auch
  
  
  
  

 
-- TODO:
-- ts.Selection.Object.Attackable.SetAddDamagePercent(100,0)
-- im MP testen obs desynced / mehrfach ausgeführt wird
-- SetAddDamagePercent(100,Dealer)
-- könnte man das Attacker/Victim System nochmal verbessern!
 -- Braucht nur noch Victim spawnen und evlt könnte man sogar AttackableType=None setzen
-- wodurch das sicher garnicht mehr interagiert mit anderen objekten!
-- wäre dann Victim Spawn via Trigger und starten von lua script
 -- nur doof dass objectfinder das dann erst finden muss..
-- victim immer in currentsession spawnen, erleichtert das finden, dauert aber trtz theoretisch n bisschen
-- ..


-- Folgendes spricht GEGEN unendlich viele erlaubte hijacking items:
-- - sie dürfen nicht zurselben Zeit eingesetzt werden, weil lua sonst nicht eindeutig identifierien kann wer wen hijacked
-- - vorallem ist das erkennen des Kapernden Schiffs bisher unmöglich, wenn mehrere Schiffe mit demselben Item rumfahren,
   -- weil anhand des gesockelten Items es zu erkennen ist bisher unsere einzige zuverlässige Option (alle anderen Ideen können zu leicht schief gehen)
-- -> maximal ein Hijack Item mit selber GUID pro Session und maximal ein "wird gekapert"-StatusEffect-Asset pro Spieler und Session
-- Da wir das "pro Session" nicht wirklich kontrollieren können, also nur eins pro Spieler, bzw. wir könnten bis zu 3 machen, aber eben alle mit untersch. GUID

-- Das kapernde Schiff könnten wir relativ schnell über die Suche nach Property finden, wenn wir nur als owner suchen
 -- Dann merken wir uns dieses schiff, damits nicht für andere kaperversuche mehr überlegt wird.
 -- und erst danach suchen wir das zu kapernde schiff.
-- An sich können wir beide Suchen tatsächlich auch nur für den owner machen, der zu diesem Zeitpunkt sehr sicher noch in derselben Session ist.
-- Und da Kapervorgang danach ja eh ein wenig dauern soll, hätte man dann genug Zeit die OID über das ShareLua System an die anderen Spieler
 -- weiterzuleiten, damit die dann in dieselbe Session gezwungen werden können
-- LOHNT NICHT, weil wir ja eh einzigartige Items verwenden, da ists egal ob wir kaperndes schneller finden oder nicht


-- falls wir doch mal ein lua- SpawnObject finden sollten und wir damit etwas bei einem anderen objekt spawnen können,
 -- kann man den FakeShip xml Teil rausschmeißen und vorallem auch das ganze changeguid kram, weil wir dann einfach direkt das richtige schiff an der richtigen stelle
  -- spawnen können. changeguid ist nur nötig, damit xml das einzigartige objekt finden kann und etwas "variables" spawnen kann.




local Attacker_PID = 0 -- Human0

local function table_len(t)
  local c = 0
  for k,v in pairs(t) do
    c = c + 1
  end
  return c
end

local function ChangeOwnerObjectCurrentSession(Victim_OID,Victim_info,PID)
  local previous_selection = session.selection  -- session.getSelectedFactory()
  Victim_info["userdata"]:select()
  condition.changeOwnerOfSelected(PID)
  for i,selected_userdata in ipairs(previous_selection) do
    if i==1 then
      selected_userdata:select()
    else
      selected_userdata:addToSelection()
    end
  end
  ts.Objects.GetObject(Victim_OID).Walking.DebugStop() -- stop movement command (eg commands from previous owner) .. does only make them stop once, but not remove their command eg to escort...
end



 
if ObjectFinderSerp==nil then
  console.startScript("data/scripts_serp/objectfinder/objectfinder.lua")
end
if CoopCount_Serp==nil then
  console.startScript("data/scripts_coophelper_serp/coopcount.lua")
end
if CoopPeers_Serp==nil then
  console.startScript("data/scripts_serp/cooppeers.lua")
end
 
 -- queen = 15
local allowed_ParticipantIDs = {[0]="human0",[1]="human1",[2]="human2",[3]="human3",[9]="enemy",[25]="jorgensen",[26]="qing",[27]="wibblesock",[28]="smith",[29]="omara",[30]="gasparov",[31]="malching",[32]="gravez",[33]="silva",[34]="hunt",[64]="mercier",[17]="harlow",[18]="fortune"}
local Pirate_ParticipantIDs = {[17]="harlow",[18]="fortune"}
local HijackSuccess,HijackFail,HijackFailShipType,HijackFailOwner,YourShipHijacked,YourShipTryHijacked,YourShipHijackedPrevented = 1500004581,1500004580,1500004582,1500004583,1500004584,1500004577,1500004585





-- evtl. während der wartezeit alle 5 sek den Namen des Kapernden schiffes abändern um darin die Chance für Kapererfolg anzuzeigen?
 -- (vorherigen namen merken und danach zurücksetzen)
-- Wobei natürlich die Frage ist, was einem die Chance nachdem man es gestartet hat hilft, wenn sie schlecht ist kann man kaum noch was dran ändern...
-- und vorher anzeigen geht auch nicht, ohne dass wir wissen wer beteiligt ist.
 -- (infotip ginge, aber da können wir keine chance ausrechnen)

-- Dann nameable für hijacking mod machen (für jeden spieler und evlt auch für jedes item, wenn spieler zb 3 hat)
 -- welcher chance anzeigt. Also wir ändern den namen davon zb während hijacking alle x sekunden
 -- und lassen den namen dann über infotip anzeigen (owner und equipped item sollten wir in infotip rausfinden
 -- können um den namen des richtigen nameables anzuzigen)
-- Evtl. auch eine "vorher" Anzeige versuchen, muss nur irgendwie von Spieler ausgelöst werden,
 -- vermutlich durh keybind, dann berechnet lua die chance für selection und hover objekt
 -- und aktualisiert den namen
  -- (speichern+laden muesste man deren OID dann auch noch..)
-- oder wir schreibens einfach in namen von kaperndem schiff, sollte auch reichen :D

print("00",ts.GameClock.CorporationTime)
-- one SpawnImpactObjects per Item should be enough, not needed to have one per player, since we can identify player based on owner
-- In theory also one item for everyone would be enough to identify the Attacker_OID, but the StatusEffect must be unique. And the only way to change the status effect is
 -- to change the projectil that is shot and this only works if we have another item
local H_GUIDs = {SpawnImpactObjects={[0]=1500004574},StatusEffects={[0]={[0]=1500004573}},Item={[0]={[0]=1500004570}}}


local function SendEndMessage(HijackResult,LocalParticipantID,Attacker_PID,Victim_PID,ImFirstCoopPeer)
  if ImFirstCoopPeer then -- enough if only one executes this
    if LocalParticipantID==Attacker_PID then
      ts.Unlock.SetUnlockNet(HijackResult) -- notification has to be done via trigger, because with game.GUIManager.showNotification its always desync if we dont want to sent the same for everyone -.-
    elseif Victim_PID==LocalParticipantID then
      if HijackResult==HijackSuccess then
        ts.Unlock.SetUnlockNet(YourShipHijacked)
      elseif HijackResult~=HijackSuccess then
        ts.Unlock.SetUnlockNet(YourShipHijackedPrevented)
      end
    end
  end
end

local function DoHijack(Attacker_PID,Itemnumber)

  system.start(function()
    print("11",ts.GameClock.CorporationTime)
    
    local LocalIsInSessionGUID = session.getSessionGUID()
    local LocalParticipantID = ts.Participants.GetGetCurrentParticipantID()
    local HijackResult = HijackFail -- by default the "failed" notification
    local Victim_OID,Victim_info,Attacker_OID,Attacker_info,Victim_PID
    
    local ImFirstCoopPeer = CoopPeers_Serp.GetWait_ImFirstActiveCoopPeer(LocalParticipantID)
    
    local loadedSessions = ObjectFinderSerp.GetLoadedSessions()
    local SpawnImpactObject = H_GUIDs.SpawnImpactObjects[Itemnumber] -- the object that spawns when using the hijack projectile to start the trigger that executes this script. Where this is also the hijacking is taking place
    local HijackSession
    for lSessionID,lSessionGUID in pairs(loadedSessions) do
      if ts.Participants.GetParticipant(Attacker_PID).ProfileCounter.Stats.GetCounter(0,0,SpawnImpactObject,1,lSessionGUID)>0 then
        HijackSession = lSessionGUID
        break
      end
    end
    if HijackSession==nil then
      print("ATTENTION HijackSession is nil ?!")
      SendEndMessage(HijackResult,LocalParticipantID,Attacker_PID,Victim_PID,ImFirstCoopPeer)
      return
    end
    
    local ImFirstCoopPeerInSession
    if Attacker_PID==LocalParticipantID then -- session only relevant for attacker
      ImFirstCoopPeerInSession = CoopPeers_Serp.GetWait_ImFirstCoopPeerInSession(HijackSession,LocalParticipantID)
    end

    local function myObjectFilter(OID,GUID,userdata,SessionGuid,ParticipantID,AreaID,SessionID,IslandID,AreaIndex,ObjectID)
      local done,addthis
      if Attacker_PID~=ParticipantID and ObjectFinderSerp.CheckObjectHelpers.AffectedByStatusEffect(OID,H_GUIDs.StatusEffects[Attacker_PID][Itemnumber]) then
        Victim_OID = OID
        addthis = true
      elseif Attacker_PID==ParticipantID and ts.GetGameObject(OID).ItemContainer.GetItemAlreadyEquipped(H_GUIDs.Item[Attacker_PID][Itemnumber]) then
        Attacker_OID = OID
        addthis = true
      end
      if Attacker_OID~=nil and Victim_OID~=nil then
        done = true
      end
      return {addthis=addthis,done=done,next_AreaID=false,next_SessionID=false} -- important to return addthis and done, to stop the expensive search
    end
    local function mySessionFilter(SessionID,CheckingSessionGuid) -- needs to be defined it after HijackSession
      if HijackSession==CheckingSessionGuid then
        return true
      end
    end

    local notstop = 0
    print("12",ts.GameClock.CorporationTime)
    local results = {}
    results = ObjectFinderSerp.GetAnyObjectsFromAnyone({ObjectFilter=myObjectFilter,SessionFilter=mySessionFilter,FromSessionID=1,ToSessionID=nil,
      FromIslandID=0,ToIslandID=0,FromAreaIndex=0,ToAreaIndex=0,FromObjectID=nil,ToObjectID=10000,withyield=false})
      
    print("13",ts.GameClock.CorporationTime)
    
    if table_len(results)~=2 then -- then search up to 100k ObjectIDs, should be enough even on big savegames
      results = ObjectFinderSerp.GetAnyObjectsFromAnyone({ObjectFilter=myObjectFilter,SessionFilter=mySessionFilter,FromSessionID=1,ToSessionID=nil,
        FromIslandID=0,ToIslandID=0,FromAreaIndex=0,ToAreaIndex=0,FromObjectID=10000,ToObjectID=100000,withyield=true})
      if table_len(results)~=2 then -- then search up to 1m ObjectIDs, should be enough even on very big savegames
        results = ObjectFinderSerp.GetAnyObjectsFromAnyone({ObjectFilter=myObjectFilter,SessionFilter=mySessionFilter,FromSessionID=1,ToSessionID=nil,
          FromIslandID=0,ToIslandID=0,FromAreaIndex=0,ToAreaIndex=0,FromObjectID=100000,ToObjectID=1000000,withyield=true})
      end
      if table_len(results)~=2 then
        print("ATTENTION Did not find ships involved in hijacking!",Attacker_OID,Victim_OID)
        SendEndMessage(HijackResult,LocalParticipantID,Attacker_PID,Victim_PID,ImFirstCoopPeer)
        return
      end
    end
    for OID,info in pairs(results) do
      if OID==Attacker_OID then
        Attacker_info = info
        print("Attacker_info found")
      elseif OID==Victim_OID then
        Victim_info = info
        print("Victim_info found")
      end
    end
    print("22",ts.GameClock.CorporationTime,Victim_OID,Attacker_OID)
    -- system.waitForGameTimeDelta(2000)
    if Victim_OID~=nil and Attacker_OID~=nil then
      print("0",ts.GameClock.CorporationTime)
      if Victim_info~=nil and Victim_info["ParticipantID"]~=Attacker_PID then
        Victim_PID = Victim_info["ParticipantID"]
        if allowed_ParticipantIDs[Victim_PID]~=nil then
          if Pirate_ParticipantIDs[Victim_PID]==nil then -- it is not-pirate, so human or 2nd party
          -- if true then -- todo test
          
            if Victim_PID==LocalParticipantID and ImFirstCoopPeer then
              ts.Unlock.SetUnlockNet(YourShipTryHijacked) -- send message to victim
            end
          
            print("1",ts.GameClock.CorporationTime)
            -- coroutine.yield()
            
            local SuccessChance = 100
            local previous_AttackerShipName = ts.GetGameObject(Attacker_OID).Nameable.Name
            local previous_VictimShipName = ts.GetGameObject(Victim_OID).Nameable.Name
            
            local Victim_CurHitPoints,Attacker_CurHitPoints,Attacker_DPS,Victim_DPS
            Attacker_DPS = ts.GetGameObject(Attacker_OID).Attacker.DPS -- buffs/debuffs might change it, so also check it everytime? hm no, we dont want that chance changes too randomly, so fix this value at start of hijacking
            Victim_DPS = ts.GetGameObject(Victim_OID).Attacker.DPS -- can be 0 for tradeships of course
            
            -- Now we could calcuate SuccessChance based on CurHitPoints and DPS, but having a % chance is maybe not the best idea..
             -- 1) changeowner is not synced so we have to share the result of math.random(chance) with all other players via a nameable helper.
               -- it is possible with a roughly 2 seconds delay, but adds quite alot of complexity on top
             -- 2) having a chance of eg. 80% means it still can quite often fail, although your ship is clearly the stronger one
            -- Instead of a chance we could simply only calculate the facts and say (for this example only taking Hitpoints into account):
             -- - if attacker has 110% of the hitpoints from victim, the attacker succeeds. 
               -- - if victim has 120% hitpoints of attacker, the victim will get attackers ship instead
               -- if hitpoints are in between nothing happens.
                -- (victim must be stronger than attacker, because he does not "waste" an item for this, so the item basically increases your strenght)
            
            local Attacker_Hijack_Strength = 10 -- does not start at 0, because he is the one that uses the item
             -- TODO: if the item is not consumed after use, we could also check if the victim has such an item equipped, which makes it stronger
               
            
            for i=1,10 do
              ts.GetGameObject(Victim_OID).Walking.DebugStop() -- make it stop moving (debuff can only make it slow...)
              ts.GetGameObject(Attacker_OID).Walking.DebugStop() -- is also synced
              
              system.waitForGameTimeDelta(1000) -- hijacking takes a while
              
              -- if i % 2 == 0 then -- enough to do it every 2 seconds
                
              -- end
              if i % 5 == 0 then -- enough to do it every 5 seconds
                Victim_CurHitPoints = ts.GetGameObject(Victim_OID).Attackable.CurHitPoints
                Attacker_CurHitPoints = ts.GetGameObject(Attacker_OID).Attackable.CurHitPoints
                if Victim_CurHitPoints <= 0 or Attacker_CurHitPoints <= 0 then
                  SendEndMessage(HijackResult,LocalParticipantID,Attacker_PID,Victim_PID,ImFirstCoopPeer)
                  ts.GetGameObject(Attacker_OID).Nameable.SetName(previous_AttackerShipName)
                  ts.GetGameObject(Victim_OID).Nameable.SetName(previous_VictimShipName)
                  return
                end
                
                SuccessChance = Attacker_CurHitPoints / Victim_CurHitPoints
                ts.GetGameObject(Attacker_OID).Nameable.SetName(tostring(SuccessChance).."% "..previous_AttackerShipName) -- show the success chance in the name of ships. this is easiest way to display it somehow :D
                ts.GetGameObject(Victim_OID).Nameable.SetName(tostring(SuccessChance).."% "..previous_VictimShipName)
              end
              
            end
            
            ts.GetGameObject(Attacker_OID).Nameable.SetName(previous_AttackerShipName)
            ts.GetGameObject(Victim_OID).Nameable.SetName(previous_VictimShipName)
            ts.GetGameObject(Victim_OID).Attackable.SetDebugInvincible(true) -- hijacking will take place now, prevent destroy of ship now (is synced)
            
            
            -- bzgl chance:
             -- vllt können wir iwie die Infecatble (haben schiffe nicht) von einem helper building setzen?
             -- wobei wir dann auch einfach den namen eines helpers setzen können um das auszutauschen
            
            if ts.GameSetup.IsMultiPlayerGame then
              print("2",ts.GameClock.CorporationTime)
              local everyonesamesession = CoopCount_Serp.IsEveryoneSameSession(HijackSession)
              if everyonesamesession then --everyone in same session, good. hopefully they are still in same gametick otherweise it will desync (if not withyield=true should be set to false, but then it might lag on heavy search)
                print("everyonesamesession 1")
                ChangeOwnerObjectCurrentSession(Victim_OID,Victim_info,Attacker_PID)
                HijackResult = HijackSuccess
              else
                print("differentsession 1")
                if LocalIsInSessionGUID~=HijackSession then
                  ts.MetaObjects.CheatLookAtObject(Victim_OID)
                  system.waitForGameTimeDelta(500) -- wait for the session switch to take place
                  ts.MetaObjects.CheatLookAtObject(Victim_OID) -- repeat the command, because it is ignored if the user was still in the session switch animationby by chance
                else
                  system.waitForGameTimeDelta(500)  -- make sure everyone waited the same amount of game-ticks, so they execute the change-owner all at once
                end
                system.waitForGameTimeDelta(500)
                everyonesamesession = CoopCount_Serp.IsEveryoneSameSession(HijackSession)
                if everyonesamesession then -- if all are in correct session now
                  print("everyonesamesession 2")
                  if Victim_info["userdata"]==nil then -- if we were at wrong session, then it is nil currently, check again now that we are in correct session
                    Victim_info["userdata"] = session.getObjectByID(Victim_OID)
                  end
                  ChangeOwnerObjectCurrentSession(Victim_OID,Victim_info,Attacker_PID)
                  HijackResult = HijackSuccess
                else
                  print("ship hijack code MP: still not everyone in same session -.-")
                end
              end
            else -- singleplayer is easier
              if LocalIsInSessionGUID~=HijackSession then
                ts.MetaObjects.CheatLookAtObject(Victim_OID)
                system.waitForGameTimeDelta(500) -- wait for the session switch to take place
                ts.MetaObjects.CheatLookAtObject(Victim_OID) -- repeat the command, because it is ignored if the user was still in the session switch animationby by chance
                system.waitForGameTimeDelta(500)
              end
              ChangeOwnerObjectCurrentSession(Victim_OID,Victim_info,Attacker_PID)
              HijackResult = HijackSuccess
            end
          elseif LocalParticipantID==Attacker_PID and ImFirstCoopPeerInSession and Victim_info["userdata"]~=nil then -- for pirates. then the code will be MUCH more complicated, because if we just change owner, the pirates will not spawn new ships. We have to destroy the original ship with original owner for the pirate to spawn new ships -.- and for spawning we have just xml with terrible aiming...
            -- luckily this pirate code is enough if one local player in the same session executes it, everyhting here is synced automatically. (so no need to force other players into the same session here)
            -- userdata will be nil for everyone in the wrong session
            
            local PirateShip_Transforms = { -- exchange pirates guid with the one "for sale"
              [102429]=102420,[102430]=102421,[102431]=102419,[102432]=102422, -- vanilla pirate ships
              -- pirate mod ships
            }
            local supported_pirate_ships = {[102429]=1500004600,[102430]=1500004601,[102431]=1500004602,[102432]=1500004603, -- vanilla pirate ships
                -- mod pirate ships
              }
            local FakeShipSpawnTriggers = {[180023]={[1500004600]=1500004592,[1500004601]=1500004586,[1500004602]=1500004588,[1500004603]=1500004590,},  -- old world session
                                            [180025]={[1500004600]=1500004593,[1500004601]=1500004587,[1500004602]=1500004589,[1500004603]=1500004591,}}  -- new world session
            if HijackSession == 180023 or HijackSession == 180025 then -- we only support these two sessions, because spawning new pirate ships is much easier this way
              
              for i=1,10 do
                system.waitForGameTimeDelta(1000) -- hijacking takes a while
                ts.Objects.GetObject(Attacker_OID).Walking.DebugStop()
                ts.Objects.GetObject(Victim_OID).Walking.DebugStop()
              end
              
              Victim_info["userdata"]:setDebugInvincible(true)
              local maxhitpoints = ts.Objects.GetObject(Victim_OID).Attackable.MaxHitPoints
              local currenthitpoints = ts.Objects.GetObject(Victim_OID).Attackable.CurHitPoints
              local hitpoints_percentage = currenthitpoints / maxhitpoints
              if hitpoints_percentage <= 1.0 then -- ship needs to be damaged first. todo test, final dneke ich auf 0.5 setzen
                local FakeShipHelper = supported_pirate_ships[Victim_info["GUID"]]
                local function FoundShipBackToOriginal(Victim_OID,Victim_info)
                  -- original zurückverwandeln, was es vorher war
                   -- auch wenn wir unser schiff nun stattdessen gespawned haben (anstatt owner zu wechseln), muss das original zurückverwandelt werden, bevor wir es löschen, damit die KI/Piraten das korrekt bemerkt
                  Victim_info["userdata"]:changeGUID(Victim_info["GUID"])
                  notstop = 0
                  while true do
                    coroutine.yield() -- wait changeGUID
                    if ts.Objects.GetObject(Victim_OID).GetGUID()==Victim_info["GUID"] then
                      break
                    end
                    notstop = notstop + 1
                    if notstop > 100 then
                      print("notstop FoundObject back to Victim_info GUID")
                      break
                    end
                  end
                  return notstop
                end
                
                if FakeShipHelper~=nil then
                  Victim_info["userdata"]:changeGUID(FakeShipHelper)
                  notstop = 0
                  while true do
                    coroutine.yield() -- wait changeGUID
                    if ts.Objects.GetObject(Victim_OID).GetGUID()==FakeShipHelper then
                      break
                    end
                    notstop = notstop + 1
                    if notstop > 100 then
                      print("notstop Victim_info to FakeShipHelper")
                      break
                    end
                  end
                  
                  local TriggerHelper = FakeShipSpawnTriggers[HijackSession][FakeShipHelper]
                  ts.Unlock.SetUnlockNet(TriggerHelper)
                  
                  notstop = 0
                  while ts.Participants.GetParticipant(Attacker_PID).ProfileCounter.Stats.GetCounter(0,0,FakeShipHelper,1,HijackSession)==0 do -- checking ts.Unlock.GetIsUnlocked(TriggerHelper) here is not enough, because we need to wait until the ships are actually finsihed spawning
                    coroutine.yield() -- wait for the trigger
                    notstop = notstop + 1
                    if notstop > 20 then
                      print("notstop TriggerHelper, no help ship spawned")
                      break
                    end
                  end
                  -- system.waitForGameTimeDelta(500)  -- todo test
                  if ts.Participants.GetParticipant(Attacker_PID).ProfileCounter.Stats.GetCounter(0,0,FakeShipHelper,3)~=0 then -- if we spawned the FakeShipHelper sucessfully
                    -- search for our spawned ship
                    local sessioninfos = ObjectFinderSerp.GetCurrentSessionObjectsFromLocaleByProperty("Walking") -- search for all Walking in current session
                    local SpawnedObject_OID,SpawnedObject_info
                    for OID,objectinfo in pairs(sessioninfos["Objects"]) do
                      -- print(objectinfo["GUID"],FakeShipHelper)
                      if objectinfo["GUID"]==FakeShipHelper then
                        SpawnedObject_OID = OID
                        SpawnedObject_info = objectinfo
                        break
                      end
                    end

                    -- original zurückverwandeln, was es vorher war
                     -- auch wenn wir unser schiff nun stattdessen gespawned haben (anstatt owner zu wechseln), muss das original zurückverwandelt werden, bevor wir es löschen, damit die KI/Piraten das korrekt bemerkt
                    FoundShipBackToOriginal(Victim_OID,Victim_info)
                    -- unser gespawndes objekt muss noch umgewandelt werden
                    if SpawnedObject_OID~=nil then
                      local changeto = Victim_info["GUID"]
                      if Pirate_ParticipantIDs[Victim_PID]~=nil then
                        changeto = PirateShip_Transforms[Victim_info["GUID"]]
                      end
                      if changeto~=nil then
                        SpawnedObject_info["userdata"]:changeGUID(changeto)
                        notstop = 0
                        while true do
                          coroutine.yield() -- wait changeGUID
                          if ts.Objects.GetObject(SpawnedObject_OID).GUID==changeto then
                            break
                          end
                          notstop = notstop + 1
                          if notstop > 100 then
                            print("notstop SpawnedObject back to changeto")
                            break
                          end
                        end
                        ts.Objects.GetObject(SpawnedObject_OID).Attackable.SetAddDamagePercent(100-hitpoints_percentage*100,Attacker_PID) -- give it the same damage like original
                        -- und jetzt löschen des originals
                        ts.Objects.GetObject(Victim_OID).Mesh.SetVisible(false)
                        Victim_info["userdata"]:setDebugInvincible(false) -- make vincible again, otherwise they get no damage
                        ts.Objects.GetObject(Victim_OID).Attackable.SetAddDamagePercent(100,Attacker_PID)
                        -- ObjectFinderSerp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(Victim_OID)..") Attackable AddDamagePercent(100,"..tostring(Attacker_PID)..")]")
                        HijackResult = HijackSuccess
                      else -- fail. löschen des gespawnden
                        ts.Objects.GetObject(SpawnedObject_OID).Attackable.SetAddDamagePercent(100,9)
                        -- ObjectFinderSerp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(SpawnedObject_OID)..") Attackable AddDamagePercent(100,9)]")
                      end
                    else -- fail
                      
                    end
                  else -- fail
                    FoundShipBackToOriginal(Victim_OID,Victim_info)
                  end
                else -- not supported ship guid
                  HijackResult = HijackFailShipType
                end
              end
            else
              HijackResult = HijackFailOwner -- send the "owner not supported" message, if it is a pirate ship in another session, not being old/new world
            end
            -- an sich nur noetig, falls abgebrochen wurde, aber schadet scheinbar auch nicht, wenns nicht mehr existiert
            Victim_info["userdata"]:setDebugInvincible(false)
          else
            print("pirate ship not hijacked because there is no player in the correct session?!")
          end
        else
          HijackResult = HijackFailOwner  -- not supported owner
        end
      end
    end
    SendEndMessage(HijackResult,LocalParticipantID,Attacker_PID,Victim_PID,ImFirstCoopPeer)
    
    print("ship hijack code done",HijackResult)
  end)
end


ShipHijackCode_Serp = ShipHijackCode_Serp or {
  DoHijack = DoHijack,
  }
  
-- todo test
DoHijack(0,0)