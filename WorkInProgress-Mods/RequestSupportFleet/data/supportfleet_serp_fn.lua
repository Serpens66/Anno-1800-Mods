
-- TODO airships copy machen und zugüen

-- condition.changeOwnerOfSelected(ParticicantID) changed nur owner von einem der selected objects UND DESYNC !
-- da ts.Selection.ChangeParticipantOfSelected() keine ParticicantID akzeptiert und es beim Object/userdata kein ownerchange zu geben scheint, bleibt dann nur die Lösung es über Trigger ActionChangeParticipant
 -- zu machen... dummerweise kann man dort auf keine bestimmten objekte zielen ..
 -- deshalb machen wir im skript nun nur changeGUID zu einer einzigartigen guid, und im trigger zielen wir auf diese GUID dann mit ActionChangeParticipant


-- TODO:
 -- nochmal MetaGameLoaded testen, erstens mit quest siehe ModsTodo und auch was passiert wenn 2 mods conditionevent MetaGameLoaded nutzen
  -- und nacheinander aktiviert werden, ob dann tatäshclich nur einer triggert.
   -- wenn dem so ist, dann muss in whichplayer mod was andres genutzt werden, zb. sessionloaded

-- TODO
-- ist system.waitForGameTimeDelta savegame kompatible? also was passiert wenn spiel gespeichert wird, während countdown läuft und dann das läd?
 -- ja funktioniert an sich, zumindest wenn Spiel nicht neu gestartet wird. wenn doch dann funzt es nicht.
 -- also eher unter 10 sekunden machen, wenn mehr delay gewünscht, dann in trigger

-- ich denke es ist besser den Code für spawnsupportfleet doch rein in Trigger zu packen (itemspawn über initslot/socket),
 -- lua ist vorallem im MP zu unberechenbar, auch desync usw...


-- outcommented EnableLightCodeSupport because we can not change owner in lua, so makes no sense and is dangerous anyways
-- local EnableLightCodeSupport = false -- set this to "true" if you want the code to also transform ships which GUIDs are not hardcoded here. It should work as long as the ships use the normal vanilla templates and no additional properties. but if a mod added new properties, the game might crash on transform, that it is way it is disabled by default

local SpawnSupportFleet_DELAY = 5000 -- after how many ms the supportfleet will spawn after the AI accepted to send some




-- ##################################################################################################################
-- helper functions 
-- ##################################################################################################################

local function weighted_random_choice(choices)
    local function weighted_total(choices)
        local total = 0
        for choice, weight in pairs(choices) do
            total = total + weight
        end
        return total
    end
    local threshold = math.random() * weighted_total(choices)
    local last_choice
    for choice, weight in pairs(choices) do
        threshold = threshold - weight
        if threshold <= 0 then return choice end
        last_choice = choice
    end
    return last_choice
end
local function modlog(t)
  if type(t)~="string" then
    t = tostring(t)
  end
  file = io.open("logs/modlog.txt", "a")
  io.output(file)
  io.write(t,"\n")
  io.close(file)
end
local function table_contains_value(tbl, x)
  found = false
  for _, v in pairs(tbl) do
      if v == x then 
          found = true 
      end
  end
  return found
end
local function table_contains_key(tbl, x)
  found = false
  for k, v in pairs(tbl) do
      if k == x then 
          found = true 
      end
  end
  return found
end
function RemoveByValueOnce(t, value)
  if t ~= nil then
    for i,v in ipairs(t) do
      if v == value then
        return table.remove(t, i)
      end
    end
  end
end


local function get_oid(userdata)
  local oid,Namestring,success
  success,Namestring = pcall(function() -- may crash te game, eg on a session userdata object, so we use pcall
    return userdata:getName() -- returns eg. "GameObject, oid 8589934647", while getOID returns an local ObjectID, not usuable in ts.Objects.GetObject.
  end)
  if success and Namestring~=nil and type(Namestring)=="string" then
    oid = string.match(Namestring, "oid (.*)")
    if oid~=nil and type(oid)=="string" then
      oid = tonumber(oid)
    end
  end
  return oid
end

local function GetSessionObjectsFromHuman(propertyID)
  
  local userdatas,userdata,ParticipantID,GameObject,GUID
  local Objects = {}
  userdatas = session.getObjectGroupByProperty(propertyID)
  local SessionGUID = session.getSessionGUID()
  
  if userdatas~=nil and #userdatas>0 then
    userdata = nil
    for k,userdata in pairs(userdatas) do
      if userdata~=nil then
        GameObject,GUID = nil
        local OID = get_oid(userdata)
        -- it is important to do GameObject = ts.Objects.GetObject(OID) several times, because it is broken after we do eg. GameObject.GetGUID() !!
        GameObject = ts.Objects.GetObject(OID)
        GUID = GameObject.GetGUID()
        if ParticipantID==nil then -- will be the same for all objects, so no need to get it multiple times
          GameObject = ts.Objects.GetObject(OID)
          ParticipantID = GameObject.GetOwner() -- ParticipantID
        end
        GameObject = ts.Objects.GetObject(OID)
        Objects[OID] = {GUID=GUID,userdata=userdata,GameObject=GameObject}
      end
    end
  end
  return {SessionGUID=SessionGUID, ParticipantID=ParticipantID, Objects=Objects}
end

-- ##################################################################################################################
--  
-- ##################################################################################################################

local GiftShipsLockTriggerGUID = 1500001341

-- TODO luftschiffe zufügen und dann auch unten im else zweig
local GUID_Transforms = {
  -- schiffe
  [100437]=1500001298,[100439]=1500001291,[100440]=1500001292,[100443]=1500001293,[100442]=1500001294,[100438]=1500001295,[100441]=1500001296,[1010062]=1500001297,[968]=1500001299,[720]=1500001300,
  -- luftschiffe
  
}
-- TODO items zufügen mit denen die schiffe spawnen können. am besten via python rewardpools der kis die items auslesen, sind mega verschachtelt
local ShipItems = {[25]={[190447] = 10,[191060] = 10,},
  [26]={[190447] = 10,[191060] = 10,},
}

local ParticipantIDs = {human0 = 0,human1 = 1,human2 = 2,human3 = 3,queen = 15,jorgensen = 25,qing = 26,wibblesock = 27,smith = 28,omara = 29,gasparov = 30,malching = 31,gravez = 32,silva = 33,hunt = 34,mercier = 64,nate = 22,harlow = 17,fortune = 18,blake = 16,sarmento = 19,bleakworth = 23,kahina = 24,inuit = 72,ketema = 80}

local CurrentSpawnProcess = CurrentSpawnProcess or {[0]={},[1]={},[2]={},[3]={}}

local function SelectionToUniqueGUID(Human_ID)

  local local_PID = ts.Participants.GetGetCurrentParticipantID()
  
  if local_PID==Human_ID then
    if session.selection~=nil and type(session.selection)=="table" and #session.selection > 0 then
      for i,userdata in ipairs(session.selection) do
        local GameObject,GUID = nil
        local OID = get_oid(userdata)
        -- it is important to do GameObject = ts.Objects.GetObject(OID) several times, because it is broken after we do eg. GameObject.GetGUID() !!
        GameObject = ts.Objects.GetObject(OID)
        GUID = GameObject.GetGUID()
        -- GUID = tonumber(GUID)
        GameObject = ts.Objects.GetObject(OID)
        -- changeGUID only works if the properties of previous and new GUID are the same, so we check most used properties here first and to only inlcude ships
          -- unfortunately it is not that easy to check if it has a property.. we use workarounds like checking BaseSpeedWithUpgrades/DPS/ShaftCount and so on..
          -- instead we can of course also just hardcode GUIDs to change from and to
        if table_contains_key(GUID_Transforms,GUID) then
          userdata:changeGUID(GUID_Transforms[GUID])
        else
          modlog("Gift Ship code: GUID "..tostring(GUID).." not found in lua GUID_Transforms table, so not gifted. You might add it in lua and a copy of the ship in xml to also support it.")
          -- following disabled because: could crash, could loose items/cargo when targetguid has less AND we have no ChangeOwner within lua, so we need to know from what guid to what guid something should be changed back. if we could change owner in lua, we could simply change guid and owner and back in one step and then we could use general fake guids
          -- if EnableLightCodeSupport then -- then try to find the best fitting object.. might cause crash if properties from previous to new does not fit, so dangerous
            -- local HasWalking = GameObject.Walking.BaseSpeedWithUpgrades ~= 0
            -- if HasWalking then
              -- GameObject = ts.Objects.GetObject(OID)
              -- local HasAttacker = GameObject.Attacker.DPS ~= 0
              -- GameObject = ts.Objects.GetObject(OID)
              -- local HasBombarder = GameObject.Bombarder.ShaftCount ~= 0
              -- if HasBombarder then -- Airships
                -- if HasAttacker then
                  -- userdata:changeGUID(1500001301)
                -- else
                  -- userdata:changeGUID(1500001303)
                -- end
              -- else -- ships , change them to schooner/gunboat copy
                -- if HasAttacker then
                  -- userdata:changeGUID(1500001291)
                -- else
                  -- userdata:changeGUID(1500001295)
                -- end
              -- end
            -- end
          -- end
        end
      end
    end
  end
end

-- spawn some AI specific items for on the ships and change their guid back to the real ones
local function FinishSpawnSupportFleet(SessionGUID,Human_ID,AI_ID)

  -- SessionGUID von event.OnSessionEnter ist ein userdata type object, aber crashed wenn man userdata:getName() oder getOID macht.. also keine ahnung wie man da an mehr infos, wie zb guid kommt. aber egal wir können ja session.getSessionGUID() machen
  
  SessionGUID = (type(SessionGUID)=="number" and SessionGUID) or session.getSessionGUID()
  if SessionGUID==180023 then
    
    if (Human_ID==nil or AI_ID==nil) then
      -- the event does not support to forward arguments, so we save AI_ID in CurrentSpawnProcess
      Human_ID = ts.Participants.GetGetCurrentParticipantID()
      if #CurrentSpawnProcess[Human_ID]>0 then
        AI_ID = table.remove(CurrentSpawnProcess[Human_ID],1) -- get them in same order they were put into it
      end
    end
    
    system.start(function ()
      local Ships = GetSessionObjectsFromHuman(367)
      -- modlog(Ships,#Ships)
      local GameObject
      for OID,ship in pairs(Ships["Objects"]) do
        -- modlog(ship["GUID"])
        if table_contains_value(GUID_Transforms,ship["GUID"]) then
          if AI_ID~=nil then -- spawn some ai specific items in the ship (if not enough slots, no item will be spawned automatically)
            -- modlog(weighted_random_choice(ShipItems[AI_ID]))
            GameObject = ts.Objects.GetObject(OID) -- GameObject must be renewed as usual.., so dont use the one in Ships
            GameObject.ItemContainer.SetCheatItemInSlot(weighted_random_choice(ShipItems[AI_ID]),1)
            GameObject = ts.Objects.GetObject(OID) -- GameObject must be renewed as usual.., so dont use the one in Ships
            GameObject.ItemContainer.SetCheatItemInSlot(weighted_random_choice(ShipItems[AI_ID]),1)
          end
          for realGUID,fakeGUID in pairs(GUID_Transforms) do -- transform it back to the real guid
            if ship["GUID"]==fakeGUID then
              ship["userdata"]:changeGUID(realGUID)
            end
          end
        end
      end
      ts.Unlock.SetUnlockNet(GiftShipsLockTriggerGUID) -- unlock the gift ships option again
    end)
    RemoveByValueOnce(event.OnSessionEnter,FinishSpawnSupportFleet) -- potentially remove the function from the events again
  end
end

-- do some chance-check based on reputation and check if AI has a shipyard in old world session. if success start the trigger to spawn the ships after a Delay and start the FinishSpawnSupportFleet fn as soon as the player in in old world session
local function PrepareSupportFleet(Human_ID,AI_ID,SpawnShipsTrigger)
  
  local local_PID = ts.Participants.GetGetCurrentParticipantID()
  
  if local_PID==Human_ID then
    local success = false
    -- we want to spawn the ships near an AI shipyard. unfortunately ActionSpawnObjects is terrible regarding automatic session, so we have to hardcode it to old world. and we check here already if AI owns a shipyard in old world
    local AIHasShipyardInOldWorld = ts.Participants.GetParticipant(AI_ID).GetProfileCounter().GetStats().GetCounter(0,0,1010520,1,180023)
    if AIHasShipyardInOldWorld==nil or AIHasShipyardInOldWorld < 1 then 
      AIHasShipyardInOldWorld = ts.Participants.GetParticipant(AI_ID).GetProfileCounter().GetStats().GetCounter(0,0,1010521,1,180023)
    end
    AIHasShipyardInOldWorld = 1 -- TODO test value
    if AIHasShipyardInOldWorld and AIHasShipyardInOldWorld >= 1 then
      local reputation = ts.Participants.GetParticipantReputation(AI_ID)
      local randonnumber = math.random(0,100)
      reputation = 100 -- todo test
      if reputation >= randonnumber then -- the higher the opinion from AI towards you is, the higher the chance for success
        -- costs reputation? TODO if we keep it this way, add it somehow to the tooltip of decisionquest, so you know it costs rep
        -- ts.Participants.SetChangeParticipantReputationTo(AI_ID, Human_ID, -5) -- todo test
        success = true
      end
    else
      modlog("SupportFleet: AI does not own a shipyard in old world, so dont spawn supportfleet ships")
    end
    if not success then
      -- credit payed money/honor back if no success
      ts.Economy.MetaStorage.AddAmount(1010017, 5000)
      ts.Economy.MetaStorage.AddAmount(1500000240, 20)
    else -- success
      system.start(function ()
        system.waitForGameTimeDelta(SpawnSupportFleet_DELAY) -- some delay simulating the AI kind of building the ships, todo test value
        ts.Unlock.SetRelockNet(GiftShipsLockTriggerGUID) -- lock the gift ships option because it uses same helper ships
        ts.Conditions.RegisterTriggerForCurrentParticipant(SpawnShipsTrigger)
        system.waitForGameTimeDelta(1000) -- wait for the trigger to spawn the ships
        local SessionGUID = session.getSessionGUID()
        if SessionGUID == 180023 then -- we only spawn them in old world, because spawn action sucks. and also lua code can only check a single session (the player is in)
          FinishSpawnSupportFleet(SessionGUID,Human_ID,AI_ID)
        else -- then register an event
          table.insert(CurrentSpawnProcess[Human_ID],AI_ID)
          table.insert(event.OnSessionEnter, FinishSpawnSupportFleet)
        end
      end)
    end
  end
end

Serp_SupportFleet_Mod = {
  SelectionToUniqueGUID = SelectionToUniqueGUID,
  PrepareSupportFleet = PrepareSupportFleet,
  GetSessionObjectsFromHuman = GetSessionObjectsFromHuman,
  modlog = modlog,
  table_contains_value = table_contains_value,
  table_contains_key = table_contains_key,
  get_oid = get_oid,
  GUID_Transforms = GUID_Transforms,
  ParticipantIDs = ParticipantIDs,
  weighted_random_choice = weighted_random_choice,
  ShipItems = ShipItems,
}