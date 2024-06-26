

-- wenns um spy wassern/landen geht, gibts für einen kurzen zeitpunkt 2 spies, land und wasser.
 -- also am besten skript 1 sek danach aufrufen um items zu verteilen
 
 -- doch besser mit Trigger in xml machen, da gibts weder die MP/coop probleme von lua, noch das problem, dass wir nur auf objekte der aktiven Session zugreifen können.
-- (items ercheaten macht auch desync im MP)
 -- Der einzige Haken bei xml ist halt, dass wir eine condition für jede ressource und eine condition für jede menge die gepürft werden soll
  -- machen müssen, also "hast du 1 ressource, dann fürge 1 item zu. Hast du 2 ressourcen, dann fürge 2 items zu" usw.
  -- Aber die Anzahl kann durchaus auf 3 pro Item oderso limitiert sein, dann ufert das ohnehin nicht aus.
 

local g_MetaRes_to_ItemGUID = {}
local g_Spy_GUIDs = {1500001173,1500001478} -- the 2 human spy units land and water
local g_seamineproperty = 356

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
local function modlog(t)
  if type(t)~="string" then
    t = tostring(t)
  end
  file = io.open("logs/modlog.txt", "a")
  io.output(file)
  io.write(t,"\n")
  io.close(file)
end
local function GetSessionObjectsFromHuman(propertyID)
  
  local function get_oid(userdata)
    local oid,Namestring
    Namestring = userdata:getName() -- returns eg. "GameObject, oid 8589934647", while getOID returns an local ObjectID, not usuable in ts.Objects.GetObject.
    if Namestring~=nil and type(Namestring)=="string" then
      oid = string.match(Namestring, "oid (.*)")
      if oid~=nil and type(oid)=="string" then
        oid = tonumber(oid)
      end
    end
    return oid
  end

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

local function get_spy()
  local sessioninfos = GetSessionObjectsFromHuman(g_seamineproperty)
  for _,entry in pairs(sessioninfos["Objects"]) do
    if table_contains_value(g_Spy_GUIDs,entry["GUID"]) then -- every human only ever owns a single spy unit because of code/trigger limitations
      return entry
    end
  end
end

-- ts.Selection.Object.ItemContainer.SetEquipSlot(0, -1)
-- ts.Selection.Object.ItemContainer.SetClearSlot(0)
-- ts.Selection.Object.ItemContainer.SetCheatItemInSlot({GUID}, {QTY})

-- 



-- testen welche mengen von meta ressourcen der user hat und dann seinem spy basierend darauf eine anzahl an items geben

local spy_object = get_spy() -- can only get the spy if it is in the active session from the executing local player, so might fail. But not a big deal, the user should just water/land again, to trigger this mechanic again. then he is for sure in the same session
-- crediting items in lua also does not work well in coop, because they get credited multiple times, even when using SetClearSlot before, because the scripts are executed simultaneous
if spy_object~=nil then
  local resamount = 0
  for islot=0,50,1 do -- empty all slots, because in coop code is executed multiple times, to make sure we still have the correct number of items
    spy_object.ItemContainer.SetClearSlot(islot)
  end
  for meta_res,itemguid in pairs(g_MetaRes_to_ItemGUID) do
    resamount = ts.Economy.MetaStorage.GetStorageAmount(meta_res) or 0
    if resamount and resamount > 0 then 
      spy_object.ItemContainer.SetCheatItemInSlot(itemguid, resamount) -- automatically adds up the the next available slot
    end
  end
end

