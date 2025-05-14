
print("luatools.lua registered")
local tools_ModID = "shared_LuaTools_Serp"


-- usage:

-- if g_LuaTools==nil then
  -- console.startScript("data/scripts_serp/luatools.lua")
-- end
-- then you can use eg. g_LuaTools.modlog(text) or g_LuaTools.table_len(t) and so on in your script

-- ####################################################################################
-- ####################################################################################


math.randomseed(os.time()) -- randomize math.random(

-- #########################################################################################
-- Anno related functions:
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
        g_LuaTools.modlog("ERROR in thread '"..tostring(threadname).."': "..tostring(err),ModID)
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

local Fn_Blocker = {}
-- fn_name is a string, eg. "g_LuaTools.modlog"
-- use this to block the call to your function for blocktime. 
 -- Useful if something causes multiple calls in short time to your function, but you also want it to execute once.
  -- blocktime still should be less than ~6 seconds (6000), because coroutines should not be used too long (not preserved over savegames)
local function CallGlobalFnBlocked(fn_name,blocknameadd,blocktime,...)
  blocknameadd = blocknameadd and tostring(blocknameadd) or ""
  local blockername = "Fn_Blocker_"..fn_name..blocknameadd
  if Fn_Blocker[blockername] then
    return
  end
  Fn_Blocker[blockername] = true
  blocktime = blocktime or 1000
  g_LuaTools.start_thread(blockername,tools_ModID,function()
    g_LuaTools.waitForTimeDelta(blocktime) -- unblock it again, so it can be executed the next time we load a game
    Fn_Blocker[blockername] = nil
  end)
  fn = g_LuaTools.getGlobalWithString(fn_name)
  return fn(...)
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
        print("stopthreads, stopping thread although its still busy: "..tostring(name),ModID)
        g_LuaTools.modlog("stopthreads, stopping thread although its still busy: "..tostring(name),ModID)
      end
      system.internal.coroutines[name] = nil
    
      -- alternative code to only stop suspended threads. But I think its quite important to stop all, so as long as its no problem, we will close all threads
      -- if coroutine.status(system.internal.coroutines[name])=="suspended" then
        -- system.internal.coroutines[name] = nil
      -- else
        -- print("stopthreads, not stopping thread because its still busy: "..tostring(name),ModID)
        -- g_LuaTools.modlog("stopthreads, not stopping thread because its still busy: "..tostring(name),ModID)
      -- end
    end
  end
  collectgarbage("collect")
end

-- #########
-- OID stuff
-- #########

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

-- alternative function to get_oid_int (instead of userdata:getOID + OIDtableToOID)
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



console.startScript("data/scripts_serp/bint.lua")
local to_bint = g_bint_Library051(256)

-- special cases not all split functions on the net can handle: seperator = "." and seperator = "Session" in Human0_Session_1234. Now this hopefully can handle both...
function mysplit(pString, pPattern)
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
-- I think every choice can only be chosen once
function weighted_random_choices(choices, num_choices)
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

-- eg. getGlobalWithString("g_LuaTools.modlog")
-- use as_table_pointer if you dont want the value returned, but the last table pointer and the last key.
 -- so if it is MyTable.MySubTable.MyKey = Value and you dont want only the Value, but reference to the table, then set as_table_pointer=true
  -- and it will return two things: MyTable.MySubTable , MyKey  so you can access it yourself and have the reference
local function getGlobalWithString(str,as_table_pointer)
  local name_parts = g_LuaTools.mysplit(str, ".")
  local t_len = #name_parts
  local last_key
  local Var = _G
  for i,name_part in ipairs(name_parts) do
    if as_table_pointer and i==t_len then
      last_key = name_part -- for a table we need to use the last_key to preserve the pointer nature of tables, to be able to change that variable value
      break
    end
    Var = Var[name_part]
  end
  if Var~=_G and Var~=nil then
    return Var,last_key
  end
  return nil,nil
end



g_LuaTools = {
  modlog = modlog,
  start_thread = start_thread,
  waitForTimeDelta = waitForTimeDelta,
  CallGlobalFnBlocked = CallGlobalFnBlocked,
  StopAllThreads = StopAllThreads,
  
  AreatableToAreaID = AreatableToAreaID,
  AreaIDToAreatable = AreaIDToAreatable,
  OIDtableToOID = OIDtableToOID,
  OIDToOIDtable= OIDToOIDtable,
  get_OID = get_OID,
  
  replace_chars_for_Name = replace_chars_for_Name,
  TableToString = TableToString,
  deepcopy = deepcopy,
  table_len = table_len,
  table_contains_value = table_contains_value,
  table_contains_key = table_contains_key,
  mysplit = mysplit,
  myreplace = myreplace,
  myround = myround,
  my_to_type = my_to_type,
  to_bint = to_bint,
  MergeMapsDeep = MergeMapsDeep,
  weighted_random_choices = weighted_random_choices,
  tables_equal = tables_equal,
  getGlobalWithString = getGlobalWithString,
}
