-- Uses CompanyName from Scenario3_Challenger3 for DoForSessionGameObject (they exist in every vanilla game in every session)
-- Uses CompanyName from Scenario3_Challenger4 for FnViaTextEmbed functionality
-- Scenario3_Challenger3  GUID: 100939 , PID: 120
-- Scenario3_Challenger4  GUID: 101507 , PID: 121

local tools_ModID = "shared_LuaTools_Light_Serp"


-- usage:

-- if g_LTL_Serp==nil then
  -- console.startScript("data/scripts_serp/lighttools.lua")
-- end
-- then you can use eg. g_LTL_Serp.modlog(text) or g_LTL_Serp.table_len(t) and so on in your script

-- Scroll to bottom for a list of functions you can use.



-- info:
 -- doing a mods.reload() while a lua coroutine (thread) is running very often crashes the game.



-- #########################################################################################
-- General Lua helper functions
-- #########################################################################################

-- invalid signs/zeichen in strings (to save it into nameable): " \ , [ ] and () if both used. and better do not use - because it might hurt gsub?
local function replace_chars_for_Name(str) -- string should not contain these characters
  str = tostring(str)
  -- str = str:gsub("%,", "-")
  str = str:gsub("%,", "") -- removing , might fit better
  str = str:gsub("%=", "-")
  str = str:gsub("%[", "*")
  str = str:gsub("%]", "*")
  str = str:gsub("%{", "*")
  str = str:gsub("%}", "*")
  str = str:gsub("%(", "*")
  str = str:gsub("%)", "*") -- as soon as this bracket closes, the rest is not shown anymore for whatever reason
  str = str:gsub("%\\", "/")
  return str
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

local function table_len(t)
  local c = 0
  for k,v in pairs(t) do
    c = c + 1
  end
  return c
end
-- returns the first key from table with value x
local function table_contains_value(tbl, x)
  for k,v in pairs(tbl) do
    if v == x then 
      return k -- also 0 is considered true in lua. and false/nil wont be used as key for sure. so its fine to return k here
    end
  end
  return false
end

if g_bint_Library051==nil then
  console.startScript("data/scripts_serp/h/bint.lua")
  -- Combine bint with strings. So numbers which are too big for number in lua: to_bint("9223413826886570355")
   -- and to compare bint numbers, you have to compare the string of it tostring(bint_number)
end
local to_bint = g_bint_Library051(256)

-- special cases not all split functions on the net can handle: seperator = "." and seperator = "Session" in Human0_Session_1234. Now this hopefully can handle both...
local function mysplit(pString, pPattern)
   if pPattern=="." then
     pPattern = "%"..pPattern
   end
   local Table = {}
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(Table,cap)
      end
      last_end = e+1
      s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
      cap = pString:sub(last_end)
      table.insert(Table, cap)
   end
   return Table
end

local function myreplace(source,repl,with) -- repl has to be at least 2 characters long
    if repl=="." then
      repl = "%"..repl
    end
    return string.gsub(source,repl, with)
end

-- rounding of numbers
local function myround(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end


local function my_to_type(value,to_type)
  if to_type~=nil then
    if to_type=="string" then
      return tostring(value)
    elseif to_type=="number" then
      return tonumber(value)
    elseif to_type=="boolean" then
      if value=="false" then return false end
      if value=="true" then return true end
      return value~=nil and value~=false
    elseif to_type=="integer" then
      return math.tointeger(value)
    elseif to_type=="bint" then
      return to_bint(value)
    end
  end
  return value
end



-- source: util.lua from the the game "Don't Starve Together" (much nice functions)
-- merge two map-style tables, overwriting duplicate keys with the latter map's value
-- subtables are recursed into
local function MergeMapsDeep(...)
    local keys = {}
    for i,map in ipairs({...}) do
        for k,v in pairs(map) do
            if keys[k] == nil then
                keys[k] = type(v)
            else
                assert(keys[k] == type(v), "Attempting to merge incompatible tables.")
            end
        end
    end
    local ret = {}
    for k,t in pairs(keys) do
        if t == "table" then
            local subtables = {}
            for i,map in ipairs({...}) do
                if map[k] ~= nil then
                    table.insert(subtables, map[k])
                end
            end
            ret[k] = MergeMapsDeep(table.unpack(subtables))
        else
            for i,map in ipairs({...}) do
                if map[k] ~= nil then
                    ret[k] = map[k]
                end
            end
        end
    end
    return ret
end

-- choices = {choice1=10,choice2=20} --> choice2 as double chance to be chosen.
-- the same choice can be chosen multiple times
local function weighted_random_choices(choices, num_choices)
  local function weighted_total(choices)
    local total = 0
    for choice, weight in pairs(choices) do
      total = total + weight
    end
    return total
  end
  local picks = {}
  for i = 1, num_choices do
    local pick
    local threshold = math.random() * weighted_total(choices)
    for choice, weight in pairs(choices) do
      threshold = threshold - weight
      pick = choice
      if threshold <= 0 then
        break
      end
    end
    table.insert(picks, pick)
  end
  return picks
end

-- https://stackoverflow.com/a/32660766
---@param o1 any|table First object to compare
---@param o2 any|table Second object to compare
---@param ignore_mt boolean True to ignore metatables (a recursive function to tests tables inside tables)
-- can not handle self references witin the table and maybe also no pointers
local function tables_equal(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end
    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end
    local keySet = {}
    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or tables_equal(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end
    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

-- old version, just for reference how one can use _G
-- local function myeval(str,as_table_pointer)
  -- local name_parts = g_LTL_Serp.mysplit(str, ".")
  -- local last_key
  -- local Var = _G
  -- if as_table_pointer then
    -- last_key = table.remove(name_parts) -- remove the last part of it to get a pointer
  -- end
  -- for i,name_part in ipairs(name_parts) do
    -- Var = Var[name_part]
  -- end
  -- if Var~=_G and Var~=nil then
    -- return Var,last_key
  -- end
  -- return nil,nil
-- end

-- there is for sure a better way, but it works
-- Converting eg "true" to true. and "g_LTL_Serp.modlog" to function (only knows global variables)
-- use as_table_pointer if you dont want the value returned, but the last table pointer and the last key.
 -- so if it is MyTable.MySubTable.MyKey = Value and you dont want only the Value, but reference to the table, then set as_table_pointer=true
  -- and it will return two things: MyTable.MySubTable , MyKey  so you can access it yourself and have the reference
local function myeval(str,as_table_pointer)
  local last_key
  if as_table_pointer then
    local name_parts = g_LTL_Serp.mysplit(str, ".")
    last_key = table.remove(name_parts) -- remove the last part of it to get a pointer
    str = table.concat(name_parts,".")
  end
  return load("return "..str)(),last_key
end

-- https://www.lua.org/pil/19.3.html
-- f is optional sorting function
local function pairsByKeys (t, f)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, f)
  local i = 0      -- iterator variable
  local iter = function ()   -- iterator function
    i = i + 1
    if a[i] == nil then return nil
    else return a[i], t[a[i]]
    end
  end
  return iter
end

-- sort the table by key and then return the key,value pair at postion i (starting with 1)
local function GetPairAtIndSortedKeys(t,i,f)
  local _ = 1
  for k,v in g_LTL_Serp.pairsByKeys(t,f) do
    if _==i then
      return k,v
    end
    _ = _ + 1
  end
end

-- ##################################################################################################################
-- ##################################################################################################################
-- ##################################################################################################################
-- Anno1800 related lightweigth lua helpers
-- ##################################################################################################################


-- #########################################################################################
-- technial Anno functions:
-- #########################################################################################


-- \Ubisoft\Ubisoft Game Launcher\games\Anno 1800\logs\lualog.txt
 -- ModID is optional added at begin of text so its easy to tell from which mod the text entry is
local function modlog(text,ModID)
  if type(text)~="string" then
    text = tostring(text)
  end
  if ModID~=nil then
    ModID = tostring(ModID)
    text = ModID..": "..text
  end
  local dat = tostring(os.date()) -- add date+time string
  text = dat.." "..text
  local file = io.open("logs/lualog.txt", "a")
  io.output(file)
  io.write(text,"\n")
  io.close(file)
end
-- empty the file on every game start
local file = io.open("logs/lualog.txt", "w")
io.output(file)
io.write("")
io.close(file)


-- starts a "thread" with system.start(fn,threadname). But uses pcall to start the function and logs the error if one happens 
 -- (otherwise any lua error is just swallowed without notification)
local function start_thread(threadname,ModID,fn,...)
  local args = {...}
  ModID = ModID or ""
  return system.start(function()
    local status,err = pcall(fn,table.unpack(args))
      if status==false then
        g_LTL_Serp.modlog("ERROR in thread '"..tostring(threadname).."': "..tostring(err),ModID)
        error(err)
      end
  end,tostring(ModID)..": "..tostring(threadname))
end

-- wait realtime (system.waitForGameTimeDelta waits for ingame time, so is faster on fast-forward. While we want to wait for syncing stuff to happen, which usually takes the same real time)
-- called from within a thread (coroutine)
-- best only use to ~ max of 6 seconds (6000), because its not saved to savegame. And may continue to be executed in another savegame (wehn going to main menu and load another game)
-- Attention: the coroutines started with system.start() in Anno1800 are resumed on GameTick (~ one per 100ms on default gamespeed). So on Pause/in Main Menu these coroutines are pausing, so it also does not help to wait for realtime.
local function waitForTimeDelta(waittime)
  local startime = os.clock()*1000
  while os.clock()*1000-waittime < startime do
    coroutine.yield()
  end
end


-- to stop a specific thread just use system.internal.coroutines.threadname = nil
local function StopAllThreads()
  -- stop all current lua threads. Put "NoStopGameLeft" in the unique name of your thread (2nd argument of system.start()), if you dont want it to be stopped on game left.
   -- we cant use a thread to wait for other threads to be suspended, because all threads are paused in main menu, including this one if we make it one.
  local threadstostop = {}
  for name,thread in pairs(system.internal.coroutines) do
    if not string.find(name,"NoStopGameLeft") then
      table.insert(threadstostop,name) -- should not alter the talbe we are currently looping through..
    end
  end
  for _,name in ipairs(threadstostop) do
    if system.internal.coroutines[name]~=nil then
      if coroutine.status(system.internal.coroutines[name])=="suspended" then -- seems to be ok to still close them, but just in case log it
        print("stopthreads, stopping thread although its still busy: "..tostring(name),tools_ModID)
        g_LTL_Serp.modlog("stopthreads, stopping thread although its still busy: "..tostring(name),tools_ModID)
      end
      system.internal.coroutines[name] = nil
    end
  end
  collectgarbage("collect")
end

-- you can call this function to find out if a game was just newly started (by checking ts.GameClock.CorporationTime)
local function WasNewGameJustStarted() -- call it within the first 30 seconds of a new game for it to work
  return ts.GameClock.CorporationTime < 30000 -- if the game is not older than 30 seconds, we consider it new
end

local function IsHuman(PID)
  return (PID<4)
end


-- eg. path="GUID" or "Attacker.DPS" or "Area.Economy.GetStorageAmount(1010017)"
local function ToTextembed(path)
  local path_parts = g_LTL_Serp.mysplit(path,".")
  local path_textemb = ""
  for _,path_part in ipairs(path_parts) do
    if string.sub(path_part,1,3)=="Get" or string.sub(path_part,1,3)=="Set" then
      path_part = string.sub(path_part,4,-1) -- for textembed, remove the first 3 letters if they are Get/Set
    end
    path_textemb = path_textemb.." "..path_part
  end
  return path_textemb
end


-- ###############################################################
-- ID Converter   OID stuff
-- ###############################################################

-- Converter Functions between IDs as number and IDs as table

-- An Area is for the game most of the time identical to the term island (exception eg. the ketema island, which has 2 Areas).

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


-- Objects using EditorFlag/EditorChunkID the OID gets as integer so high, that lua can not use it.
 -- Luckily this only affects prebuild objects, like buildings from ThirdParties, so not super important.
 -- But to still be able to calculate with this, luatools also includes a "bint" library, which can calcualte with such high numbers.
 -- For easier usage just pass "bint" as "to_type" argument to the Converter functions.
-- You will NOT deal with bint directly, instead you are providing and receiving a string!
-- ...
-- ts.GetGameObject(OID) does not accept a string nor a OIDtable as OID. so we can not use it with numbers that are too high.
-- Alternatives are:
--  My DoForSessionGameObject function (which makes use of game.TextSourceManager.setDebugTextSource).
--  or directly game.TextSourceManager.setDebugTextSource(text_embed_string) 
-- session.getObjectByID(OID) does also accept a string as OID and returns the userdata
-- Its important to get and keep the OID as string, if it is too high. So also use get_OID with to_type "string"

-- number examples got from the game (eg. via getName()):
-- AreaID = 2  <-> {AreaIndex = 0,SessionID = 2,IslandID = 0}
-- OID = 8589934626 <-> {ObjectID = 34,EditorChunkID = 0,AreaID = 2,EditorFlag = 0}

-- AreaID = 9730  <-> {AreaIndex = 1,SessionID = 2,IslandID = 24}
-- OID = 9223413826886570355 <-> {ObjectID = 4467,EditorChunkID = 0,AreaID = 9730,EditorFlag = 1}

-- AreaID = 8323  <-> {AreaIndex = 1,SessionID = 3,IslandID = 2}
-- OID = 9308976176787619987 <-> {ObjectID = 147,EditorChunkID = 76,AreaID = 8323,EditorFlag = 1}


-- Areatable is a table (eg returned from Object.Area.ID/ts.Area.Current.ID eg. AreaID={SessionID=2,IslandID=1,AreaIndex=1})
local function AreatableToAreaID(Areatable)
  if type(Areatable)=="table" then
    local AreaIndex,IslandID,SessionID = Areatable["AreaIndex"],Areatable["IslandID"],Areatable["SessionID"]
    if type(AreaIndex)=="number" and type(IslandID)=="number" and type(SessionID)=="number" then
      local AreaID = ((AreaIndex << 13)+(IslandID << 6)+SessionID)
      return AreaID
    end
  end
end
local function AreaIDToAreatable(AreaID)
  if type(AreaID)~="table" then
    local AreaIndex = ((AreaID & 0xE000) >> 13)
    local IslandID = ((AreaID & 0x1FC0) >> 6)
    local SessionID = (AreaID & 0xF)
    return {AreaIndex=AreaIndex, IslandID=IslandID, SessionID=SessionID}
  end
end

-- returns a string if EditorChunkID/EditorFlag is not 0, because these numbers are too high to handle for lua.
 -- if these both are 0 it will return an integer.
local function OIDtableToOID(OIDtable)
  local AreaID, ObjectID,EditorFlag,EditorChunkID
  if type(OIDtable)=="table" then 
    ObjectID = g_LTL_Serp.to_bint(OIDtable["ObjectID"])
    EditorFlag = g_LTL_Serp.to_bint(OIDtable["EditorFlag"] or 0)
    EditorChunkID = g_LTL_Serp.to_bint(OIDtable["EditorChunkID"] or 0)
    if type(OIDtable["AreaID"])=="table" then
      AreaID = g_LTL_Serp.to_bint(AreatableToAreaID(OIDtable["AreaID"]))
    elseif type(OIDtable["AreaID"])=="number" then
      AreaID = g_LTL_Serp.to_bint(OIDtable["AreaID"])
    end
  end
  -- local OID = ((AreaID << 32) + (ObjectID) + (EditorFlag << 63) + (EditorChunkID << 50))
  local OID = ((ObjectID & 0xFFFFFFFF) << 0 | (AreaID & 0xFFFF) << 32 | (EditorChunkID & 0xFF) << 50) | (EditorFlag & 0xF) << 63
  OID = tostring(OID) -- return it as string if Editor Stuff is used
  OID = tostring(EditorFlag)=="0" and tostring(EditorChunkID)=="0" and tonumber(OID) or OID -- to make an bint to number, you first have to do tostring I think
  return OID
end

-- Based on getName examples ingame I was able to find out EditorFlag with code like this (and similar then for EditorChunkID):
-- local AreaID = g_LTL_Serp.to_bint(9730)
-- local ObjectID = g_LTL_Serp.to_bint(4467)
-- local EditorFlag = g_LTL_Serp.to_bint(1)
-- local EditorChunkID = g_LTL_Serp.to_bint(0)
-- local solution = g_LTL_Serp.to_bint("9223413826886570355")
-- for i=1,100 do
  -- local OID = ((AreaID << 32) + (ObjectID) + (EditorFlag << i))
  -- if tostring(OID) == tostring(solution) then
    -- print(i)
    -- break
  -- end
-- end

-- provide OID as string, if it is too high as integer!
local function OIDToOIDtable(OID)
  if type(OID)~="table" then
    OID = g_LTL_Serp.to_bint(OID)
    -- local ObjectID = (OID & 0xFFFFFFFF)
    -- local AreaID = ((OID) >> 32)
    local ObjectID = tonumber((OID >>  0) & 0xFFFFFFFF)
    local AreaID = tonumber((OID >> 32) & 0xFFFF)
    local EditorChunkID = tonumber((OID >> 50) & 0xFF)
    local EditorFlag = tonumber((OID >> 63) & 0xF)
    local Areatable = g_LTL_Serp.AreaIDToAreatable(AreaID)
    return {ObjectID=ObjectID,AreaID=Areatable,EditorFlag=EditorFlag,EditorChunkID=EditorChunkID} -- named AreaID although its a table, because this is what the game expects as OIDtable format
  end
end

-- alternative function to get OID (instead of userdata:getOID + OIDtableToOID)
-- it also works for EditorFlag and other special objects we don't have the formula yet
-- For these too high OIDs to be used by lua, better use to_type "string" 
local function get_OID(userdata,to_type)
  local oid,Namestring
  to_type = to_type or "number" -- for editor objects string/bint might be better, because number is too high for lua
  Namestring = userdata:getName() -- returns eg. "GameObject, oid 8589934647", while :getOID returns a OIDtable.
  if Namestring~=nil and type(Namestring)=="string" then
    oid = string.match(Namestring, "oid (.*)")
    if oid~=nil and type(oid)=="string" then
      oid = g_LTL_Serp.my_to_type(oid,to_type)
    end
  end
  return oid
end


-- ########################################################################################################
-- ########################################################################################################
-- - Trickster Anno Helpers
-- ########################################################################################################

  -- FnViaTextEmbed is used to execute your custom lua code via ThirdPartyButton on CharacterNotification (which can only execute textembeds, not lua code)
   -- it also makes sure that only the Peer who clicked the Button executes the code (by storing the CompanyName-change only for him and resetting it quite fast (its a delay of ~200 ms before the script is called))
  -- gets called via Trigger 1500005600 , which is Registered eg via CharacterNotification Buttons:
   -- <Command>[Participants Participant(121) Profile SetCompanyName(g_ObjectFinderSerp.IsLoadedSessionByID|2|false)];[Conditions RegisterTriggerForCurrentParticipant(1500005600)]</Command>
   -- using unsynced CompanyName from "Scenario3_Challenger4  GUID: 101507 , PID: 121" as helper.
    -- several characters are not allowed in Names, so use "|" to seperate functionname from arguments
    -- ProTip:
    -- by using also CharacterNotification_DummyCommand (ObjectDummies shared mod) instead of ActionExecuteScript it saves from creating a new script and especially from creating one script per human and checking whcih human we are. -->
     -- by using CharacterNotification_DummyCommand together with the FnViaTextEmbed system, the function is only executed for the PID who executes the trigger (for coop its still executed multiple times!)
   -- still dont use this too often, because if more than one is using this within ~200ms all except one might be skipped
      -- so if you can use the typical human0 to human3 scripts, then use them instead. Only use FnViaTextEmbed if you really need to provide arguments, which otherwise would result in tons of scripts
    -- TODO: test if we somehow make this execute linear... we need to start the FnViaTextEmbed scripts within the same tick...
      -- no not really. the execution from the Command alone is done ~200ms after the TriggerAction was done. And doing RegisterTriggerForCurrentParticipant within this command takes another 200ms, so in total 400ms after the CharacterNotification was done, it executes the FnViaTextEmbed function
       -- Doing a ActionRegisterTrigger in the TriggerActions with 200ms delay (instead of doing it within the command) makes them execute at the same tick, but we can not be sure about the execution order and that it is always 200ms -.-
  local function FnViaTextEmbed(PID)
    if PID==nil or PID == ts.Participants.GetGetCurrentParticipantID() then -- only the correct Participant 
      local TaskString =  ts.Participants.GetParticipant(121).Profile.CompanyName -- TaskString eg: "g_ObjectFinderSerp.IsLoadedSessionByID_2_false"
      local oldname = ts.GetAssetData(101507).Text
      if TaskString~=oldname then -- only the correct Peer (who hit the button)
        ts.Participants.GetParticipant(121).Profile.SetCompanyName(oldname) -- name it back to original
        local tasksplit = g_LTL_Serp.mysplit(TaskString,"|")
        local funcname = table.remove(tasksplit,1)
        local func = g_LTL_Serp.myeval(funcname)
        for i=1,#tasksplit do
          local value = tasksplit[i]
          tasksplit[i] = g_LTL_Serp.myeval(tasksplit[i])
        end
        local success, err = pcall(func,table.unpack(tasksplit))
        if success==false then
          g_LTL_Serp.modlog("ERROR FnViaTextEmbed while trying to execute TaskString: "..tostring(TaskString).." , error: "..tostring(err),ModID)
        end
        return success, err
      end
    end
    return nil,nil
  end


  -- text embed helper for using MetaObjects.SessionGameObject, which is otherwise unavailable in lua...
   -- ts_embed_string should be eg: "[MetaObjects SessionGameObject("..tostring(OID)..") Area CityName]"
   -- so always inlucding "[MetaObjects SessionGameObject("..tostring(OID)..") ...]" and your wanted command for the OID you enter
  -- Make sure to test if your call does what it should, because this function does not check if your ts_embed_string is valid!
  local function DoForSessionGameObject(ts_embed_string,doreturnstring)
    if doreturnstring then -- we want to get what the textembed returns, but game.TextSourceManager.setDebugTextSource does not return anything. I only know a workarkund to get it, by setting and reading out the name of a namable helper object
        game.TextSourceManager.setDebugTextSource("[Participants Participant(120) Profile SetCompanyName( "..tostring(ts_embed_string).." )]")
        local returnstring = ts.Participants.GetParticipant(120).Profile.CompanyName
        local oldtext = ts.GetAssetData(100939).Text -- does not work to call this directly in SetCompanyName
        ts.Participants.GetParticipant(120).Profile.SetCompanyName(oldtext) -- set it to nil again, so you can notice if sth did not work
        if returnstring==oldtext then -- were not able to put the returned value into the name. most likely invalid character or invalid type
          return nil -- ALSO happens for 0 Pointers. For invalid objects ts.GetGameObject(OID).GUID will be 0. But SessionGameObject does not return 0 here, but sth invalid.
        end
        return returnstring
    else -- only an action that needs no return, then simply execute it
      game.TextSourceManager.setDebugTextSource(ts_embed_string)
    end
  end

  -- helpers to access "Vector" return values you find in textsourcelist.json, which are not accessable in lua directly -.-
  -- we can only access AreaFromID from the current active session of the local player
  -- set FertilitiesOrLodesString to "Fertilities" or "Lodes" (ores), depending of what you want to get returned
  local function GetFertilitiesOrLodesFromArea_CurrentSession(AreaID,FertilitiesOrLodesString)
    local count = g_LTL_Serp.DoForSessionGameObject("[Area AreaFromID("..tostring(AreaID)..") "..tostring(FertilitiesOrLodesString).." Count]",true)
    local results = {}
    if count~=nil and count~="nil" then
      count = tonumber(count)
      if count~=nil and count>0 then
        local GUID
        for i=0,count-1 do
          GUID = g_LTL_Serp.DoForSessionGameObject("[Area AreaFromID("..tostring(AreaID)..") "..tostring(FertilitiesOrLodesString).." At("..tostring(i)..") Guid]",true)
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
  local function GetVectorGuidsFromSessionObject(ts_embed_string,InfoToInclude)
    InfoToInclude = InfoToInclude or {Guid="string",Value="number"} -- eg for Costs you want eg "ProductGuid" and "Amount". Or only Guid for Sockets (has no Value)
    local ts_embed_string_guid,ts_embed_string_value
    local count = g_LTL_Serp.DoForSessionGameObject(ts_embed_string,true)
    local results = {}
    if count~=nil and count~="nil" then
      count = tonumber(count)
      if count~=nil and count>0 then
        for i=0,count-1 do  -- i starts at 0 (so use pairs() when looping), just like the slots when doing eg EquipSlot
          results[i] = {}
          for info,typ in pairs(InfoToInclude) do
            results[i][info] = g_LTL_Serp.my_to_type(g_LTL_Serp.DoForSessionGameObject(string.gsub(ts_embed_string, "Count", "At("..tostring(i)..") "..info),true),typ)
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
  -- RefOid = 0 for whole menus , for ships/buildings: g_LTL_Serp.get_OID(session.getSelectedFactory()) 
  local function GetCoopPeersAtMarker(UIState,RefOid)
    local count = g_LTL_Serp.DoForSessionGameObject("[Online GetCoopPeersAtMarker("..tostring(UIState)..","..tostring(RefOid)..") Count]",true)
    local peerints = {}
    if count~=nil and count~="nil" then
      count = tonumber(count)
      if count~=nil and count>0 then
        local peerint
        for i=0,count-1 do
          peerint = g_LTL_Serp.DoForSessionGameObject("[Online GetCoopPeersAtMarker("..tostring(UIState)..","..tostring(RefOid)..") At("..tostring(i)..")]",true)
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
  
  
  -- for easy use regardless if OID is number or string (string is used for too high OIDs, happening for Editor objects)
  -- eg. path="GUID" or "Attacker.DPS" or "Area.Economy.GetStorageAmount(1010017)"
  -- For invalid objects this will return 0 for the GetGameObject part and nil for the DoForSessionGameObject part. So check both results!
  local function GetGameObjectPath(OID,path)
    local ret
    if OID~=nil and OID~=0 then
      if type(OID)=="number" then -- GetGameObject can not handle other than number
        local path_parts = g_LTL_Serp.mysplit(path,".")
        ret = ts.GetGameObject(OID) -- every GameObj can only be used once directly. GetGameObject also works for Objects in other Session.
        for _,path_part in ipairs(path_parts) do
          ret = ret[path_part]
        end
      else -- string or bint. we can only return strings, not any tabeles/gameobjects this way
        local path_textemb = g_LTL_Serp.ToTextembed(path)
        -- g_LTL_Serp.modlog("GetGameObjectPath : [MetaObjects SessionGameObject("..tostring(OID)..")"..path_textemb.."]",tools_ModID)
        ret = g_LTL_Serp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(OID)..")"..path_textemb.."]",true)
        local status,err = pcall(g_LTL_Serp.myeval,ret) -- to make "1" 1 or "true" true
        if status==true then -- otherwise we keep it as string (eg. "Feld Besteller" Name causes an error with myeval)
          ret = err
        end
      end
    end
    return ret
  end
  
  
  -- ###################################################################################################
  -- ###################################################################################################
  -- ###################################################################################################

  -- CheckObjectHelpers
  
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
      PropertyID = g_LTL_Serp.PropertiesStringToID[Property]
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
  -- for propid,propname in pairs(g_LTL_Serp.PropertiesStringToID) do
    -- local success = g_LTL_Serp.HasProperty(userdata,propid)
    -- if success then
      -- print(tostring(propid).." : "..tostring(propname))
    -- end
  -- end

  -- ################################################

  -- if userdata is not available (eg for usage in HasProperty, because object is from another session): 
   -- unfortunately you can not check if a GameObject has specific properties directly
   -- because every GameObject, even nullpointer will have Object.Walking...  and also objects which dont have that property and
   -- will return always 0/nil for get-requests. you can eg check in Walking what the speed is or in attackable what the basedamage is. 
   -- if it is 0, it is likely the object does not have this property
    -- (DoForSessionGameObject solution from GetGameObjectPath has a similiar issue. It returns nil instead of 0 for invalid objects, but still returns null-properties for objects which do not have this property)
   -- So these are no guarantee! just very likely!
  -- providing userdata to the following functions is optional
  local function HasWalking(OID,userdata)
    local hasproperty = g_LTL_Serp.HasProperty(userdata,"Walking",OID)
    if hasproperty then
      return true
    elseif hasproperty==nil then -- then try the less secure way via GetGameObject, which also works if object is in another session
      return g_LTL_Serp.GetGameObjectPath(OID,"Walking.BaseSpeedWithUpgrades") ~= 0
    end
  end
  local function HasCommandQueue(OID,userdata)
    local hasproperty = g_LTL_Serp.HasProperty(userdata,"CommandQueue",OID)
    if hasproperty then
      return true
    elseif hasproperty==nil then -- then try the less secure way via GetGameObject, which also works if object is in another session
      return g_LTL_Serp.GetGameObjectPath(OID,"CommandQueue.UI_IsNonMoving") or g_LTL_Serp.GetGameObjectPath(OID,"CommandQueue.UI_IsMoving") -- scheint immer eins von beiden wahr zu sein, auch zb auf patroullie/traderoute
    end
  end
  local function HasAttacker(OID,userdata)
    local hasproperty = g_LTL_Serp.HasProperty(userdata,"Attacker",OID)
    if hasproperty then
      return true
    elseif hasproperty==nil then -- then try the less secure way via GetGameObject, which also works if object is in another session
      return g_LTL_Serp.GetGameObjectPath(OID,"Attacker.DPS") ~= 0
    end
  end
  local function HasAttackable(OID,userdata) -- we can not check if and by what it can be attacked though
    local hasproperty = g_LTL_Serp.HasProperty(userdata,"Attackable",OID)
    if hasproperty then
      return true
    elseif hasproperty==nil then -- then try the less secure way via GetGameObject, which also works if object is in another session
      return g_LTL_Serp.GetGameObjectPath(OID,"Attackable.MaxHitPoints") ~= 0
    end
  end
  local function HasBombarder(OID,userdata) -- most likely also means it is an airship
    local hasproperty = g_LTL_Serp.HasProperty(userdata,"Bombarder",OID)
    if hasproperty then
      return true
    elseif hasproperty==nil then -- then try the less secure way via GetGameObject, which also works if object is in another session
      return g_LTL_Serp.GetGameObjectPath(OID,"Bombarder.ShaftCount") ~= 0
    end
  end
  local function NeedsBuildPermit(OID,GUID)
    GUID = GUID or OID~=nil and g_LTL_Serp.GetGameObjectPath(OID,"GUID")
    return ts.BuildPermits.GetNeedsBuildPermit(GUID)
  end

  -- ###########################

  -- other checks for your found objects

  local function AffectedByStatusEffect(OID,StatusEffectGUID) -- eg StatusEffect dealt by projectiles. this way you can easily filter for objects hit with your custom projectile
    return g_LTL_Serp.GetGameObjectPath(OID,"Attackable.GetIsPartOfActiveStatusEffectChain("..tostring(StatusEffectGUID)..")") -- unfortunately does not work with buffs provided in a different way
  end
  -- for Productivity Buffs for Factory/Monument see GetVectorGuidsFromSessionObject ProductivityUpgradeList
  -- And you can check ItemContainer for "GetItemAlreadyEquipped" to check if a ship/guildhouse has an item euqipped
  -- I fear checking other buffs is not possible in lua...








-- ##################################################################################################################
-- ##################################################################################################################


g_LTL_Serp = {
  -- general lua helpers
  replace_chars_for_Name = replace_chars_for_Name,
  TableToString = TableToString,
  deepcopy = deepcopy,
  table_len = table_len,
  table_contains_value = table_contains_value,
  mysplit = mysplit,
  myreplace = myreplace,
  myround = myround,
  my_to_type = my_to_type,
  to_bint = to_bint,
  MergeMapsDeep = MergeMapsDeep,
  weighted_random_choices = weighted_random_choices,
  tables_equal = tables_equal,
  myeval = myeval,
  pairsByKeys = pairsByKeys,
  GetPairAtIndSortedKeys = GetPairAtIndSortedKeys,
  
  -- ######################################
  -- Anno1800 related lightweigth lua helpers
  
  -- technical Anno1800 helpers
  modlog = modlog,
  start_thread = start_thread,
  waitForTimeDelta = waitForTimeDelta,
  CallGlobalFnBlocked = CallGlobalFnBlocked,
  StopAllThreads = StopAllThreads,
  WasNewGameJustStarted = WasNewGameJustStarted,
  IsHuman = IsHuman,
  ToTextembed = ToTextembed,
  
  -- ID Converter
  AreatableToAreaID = AreatableToAreaID,
  AreaIDToAreatable = AreaIDToAreatable,
  OIDtableToOID = OIDtableToOID,
  OIDToOIDtable= OIDToOIDtable,
  get_OID = get_OID,
  
  -- Trickster Anno Helpers
  FnViaTextEmbed = FnViaTextEmbed,
  DoForSessionGameObject = DoForSessionGameObject,
  GetFertilitiesOrLodesFromArea_CurrentSession = GetFertilitiesOrLodesFromArea_CurrentSession,
  GetVectorGuidsFromSessionObject = GetVectorGuidsFromSessionObject,
  GetCoopPeersAtMarker = GetCoopPeersAtMarker,
  GetGameObjectPath = GetGameObjectPath,
  
  -- CheckObjectHelpers 
  HasProperty = HasProperty,
  PropertiesStringToID = PropertiesStringToID,
  HasWalking = HasWalking,
  HasCommandQueue = HasCommandQueue,
  HasAttacker = HasAttacker,
  HasAttackable = HasAttackable,
  HasBombarder = HasBombarder,
  NeedsBuildPermit = NeedsBuildPermit,
  AffectedByStatusEffect = AffectedByStatusEffect,
  
}