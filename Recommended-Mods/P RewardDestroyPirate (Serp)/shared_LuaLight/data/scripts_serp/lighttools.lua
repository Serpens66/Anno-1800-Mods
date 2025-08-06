-- Uses CompanyName from Scenario3_Challenger3 for DoForSessionGameObject (they exist in every vanilla game in every session)
-- Uses CompanyName from Scenario3_Challenger4 for t_FnViaTextEmbed functionality
-- Scenario3_Challenger3  GUID: 100939 , PID: 120
-- Scenario3_Challenger4  GUID: 101507 , PID: 121
-- Scenario3_Challenger5  GUID: 101508 , PID: 122
-- (I think the only Participant with Queen Template where I do not use the Nameable yet (besides Void Trader and Queen) is Scenario02_Actuary)

local ModID = "shared_LuaTools_Light_Serp"


-- usage:

-- if g_LTL_Serp==nil then
  -- console.startScript("data/scripts_serp/lighttools.lua")
-- end
-- then you can use eg. g_LTL_Serp.modlog(text) or g_LTL_Serp.table_len(t) and so on in your script

-- Scroll to bottom for a list of functions you can use.



-- general infor for lua and multiplayer:
  -- Code with ActionExecuteScript is started for all humans, regardless who executed this Action.
  -- If you only want to execute code for a specific human, you can use my WhichPlayerCondition mod (included as shared mod)
   -- to check within the Trigger where you do ActionExecuteScript which human the executing player is and then start
    -- a different script for each of them, eg called myscript_0.lua for Human0 and so on.
   -- In that script you know its ment to be only executed for Human0, you can check "GetGetCurrentParticipantID" to make
    -- sure only the correct participant is executing the code.
  -- But your code still will be executed for all human peers in that Coop team, so if 2 people are in the team, lua commands
   -- which are synced will still be executed 2 times.
   -- To complete solve the coop problem, you will need my UltraTools shared mod. But even without it there are several workarounds
    -- for specific situations. The MediumTools includes a few more workarounds.
   -- But eg. instead of using "RegisterTriggerForCurrentParticipant", which will register the trigger 2 times with 2 coop players,
    -- you can instead make your Trigger a FeatureUnlock (AutoSelfUnlock=0, AutoRegister=1), which has the main Condition UnlockNeeded of itself.
    -- Then you can use ts.Unlock.SetUnlockNet(YOUR_FEATUREUNLOCK) instead, to make this Trigger start. It does not matter if the unlocking is executed 
     -- multiple times in coop, because unlock is unlock.
   -- IMPORTANT:
    -- But by using Condition UnlockNeeded we get another problem:
     -- Registered Triggers are saved to the samegame and Assets which do not exist are always counted as unlocked.
     -- That means if a user deactivates your mod, the Trigger Code will still be there, but the asset he checks for being unlocked
      -- does not exist anymore, which defaults to "unlocked" and make your Trigger execute its actions.
     -- Depending on the actions this might cause problems, since the mod is no longer active.
    -- Therefore its best to reverse the unlock for Triggers/FeatureUnlocks like this:
     -- Use DefaultLockedState=0 for it and use NegateCondition in your UnlockNeeded Condition, to check if it is "locked".
      -- And in lua you use instead ts.Unlock.SetRelockNet(YOUR_FEATUREUNLOCK)
    -- I think for Quests PreConditionList this problem does not exist, at least not if Quest and Pool is removed (maybe if pool stays)



-- TODO:
-- Testlauf für ID Converter machen:
-- in testscript current areaid abfragen
 -- und dann diese für GetAny aufruf nutzen um in rekord spielstand alle objekte einer GUID (zb Haus) zählen.
  -- dies dann mit ProfilCounter Ergebnis vergleich
   -- um zu sehen ob selbes Ergebnis.
  -- Am besten für mehrere Inseln und auch schiffe machen.


-- TODO:
-- hilfskonstrukt/anleitung für GetPosition eines Objekts machen.
-- Das Spiel hat kein GetPosition oder ähnliches in lua -.-
-- Einzige Idee die ich habe: SetDebugGoto(x,y) eine Hilfsobjekts nutzen und mithilfe von ConditionObjectPosition in xml
 -- checken ob das Hilfsobjekt in der Nähe des gesuchten Objektes ist. Sobald es in der Nähe ist, wissen wir dass das gesuchte objekt
  -- an der x,y Position steht. Einschränkung dabei ist natürlihc, dass das gesuchte Objekt in der Session/von dem Owner einmalig sein muss.
   -- und wir die GUID des gesuchten Objekts in xml hardcoden müssen, also kein allgemeingültiger code möglich.
 -- Vermutlich ist es mathematisch irgenwie möglich relativ schnell auf die koordinaten zu kommen. 
 -- Wir machen FeatureUnlocks mit ConditionObjectPosition in 100-er abstand radius oderso (bis 4000) und schicken hilfsobjekt
  -- dann zb auf pos 100/100. dann sehen wir welche der Unlocks true sind und erkennen dadurch, dass zb 2000er radius in nhähe ist, aber 1900 nicht.
   -- dann schieben wir helper nach 200/200 und werten die unlocks wieder aus und kommen dadurch vllt auch die richtige richtung

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
local function TableToFormattedString(var, sorted, indent)
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
               .. TableToFormattedString(key, sorted, indent + 1)
               .. ' = '
               .. TableToFormattedString(var [key], sorted, indent + 1)
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
    elseif to_type=="integer" then -- attention: returns nil for eg 4.1 or "4.1", so "number" and/or myround may be what you want
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
  local status,ret = xpcall(load("return "..str),g_LTL_Serp.log_error)
  if status==false then -- err
    ret = str -- then maybe its meant to be a string
  end
  return ret,last_key
end

-- small to big number is default
local function SortFnBigToSmall(a,b) return a>b end

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

-- TableToHex and HexToTable
-- source: https://github.com/Pnski/Anno1800LuaLibs/blob/main/1800seralize.lua
-- https://www.reddit.com/r/lua/comments/hzi7ff/print_local_variable_as_hex_string/
local function _HexToString(hex)
  return (hex:gsub("%x%x", function(digits) return string.char(tonumber(digits, 16)) end))
end
-- https://www.reddit.com/r/lua/comments/hzi7ff/print_local_variable_as_hex_string/
--string.format(string.rep("%02x", #variable), variable:byte(1, -1)))
local function _StringToHex(str)
  return (str:gsub(".", function(char) return string.format("%02x", char:byte()) end))
end
-- Read as: substitute every character in variable with its byte value formatted as hexadecimal zero-padded to at least 2 digits
--[[
  returns table with pairs
]]
local function getkvtable(_table)
  if _table.__index == nil then
    return _table
  else
    return debug.getmetatable(_table) --using debug library, instead of getmetatable(table:table)
  end
end
--There are eight basic types in Lua: nil, boolean, number, string, userdata, function, thread, and table. 
--[[
  table will be looped, no need to test
  user giving functions or threads is a stupid idea
  userdata is normally from c, no need to test
]]
function _ValueToString(_value)
  if type(_value) == 'number' then
    return _value
  elseif type(_value) == 'string' then
    return "\'".._value.."\'"
  elseif type(_value) == 'boolean' then
    if _value then
      return 'true'
    else
      return 'false'
    end
  else --failsafe
    g_LTL_Serp.modlog("unsupported value type for ValueToString: "..tostring(type(_value)).." "..tostring(_value),ModID)
    return 'nil'
  end
end
function _IndexToString(_index)
  if type(_index) == 'number' then
    return "[".._index.."]"
  elseif type(_index) == 'string' then
    return "[\'".._index.."\']"
  else --failsafe
    g_LTL_Serp.modlog("unsupported index type for IndexToString: "..tostring(type(_index)).." "..tostring(_index),ModID)
    return 'nil'
  end
end
function _TableToString(_table)
  local _string = "{"
  if type(_table) ~= 'table' then
    return ""
  end
  -- convert every array or metatable to array (pairs might fail if C-API call is blocked)
  for k,v in pairs(getkvtable(_table)) do --getkvtable to cycle through
    if #_string > 1 then
      _string = _string ..","
    end
    if type(_table[k]) == 'table' then -- use the original table for direct values
      _string = _string.._IndexToString(k).."=".._TableToString(_table[k])
    else
      _string = _string.._IndexToString(k).."=".._ValueToString(v)
    end
  end
  return _string.."}"
end

local function TableToHex(_table)
  return _StringToHex(_TableToString(_table))
end

local function HexToTable(_string)
  local str = _HexToString(_string)
  local status,_ioTable = xpcall(load("return "..str,nil,"bt",_ioTable),g_LTL_Serp.log_error)
  if status==false then -- err , eg a string, can happen if the name of an helper did not change to a string-table but kept being a normal name string.. (so find out why the name change did not work)
    g_LTL_Serp.modlog("ERROR in HexToTable, str is not table : "..tostring(str),ModID)
    _ioTable = nil -- may cause more errors
  end
  return _ioTable
end

local function argstotext(sep,...)
  local ret = ""
  local sep = sep or " , "
  local args = {...}
  for _,arg in pairs(args) do -- pairs instead of ipairs to also allow a value of nil
    ret = ret..tostring(arg)..tostring(sep)
  end
  return ret
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
 -- _ModID is optional added at begin of text so its easy to tell from which mod the text entry is
local function modlog(text,_ModID)
  if type(text)~="string" then
    text = tostring(text)
  end
  if _ModID~=nil then
    _ModID = tostring(_ModID)
    text = _ModID..": "..text
  end
  local dat = tostring(os.date()) -- add date+time string
  text = dat.." "..text
  local file = io.open("logs/lualog.txt", "a")
  if file~=nil then
    io.output(file)
    io.write(text,"\n")
    io.close(file)
  end
end
-- empty the file on every game start
local file = io.open("logs/lualog.txt", "w")
if file~=nil then
  io.output(file)
  io.write("")
  io.close(file)
end

-- can be used as error_handler for xpcall. only within xpcall error_handler we can access the full traceback
-- xpcall(fn,error_handler,...)
local function log_error(err)
  local traceback = debug.traceback~=nil and debug.traceback() or "nil"
  local fullerr = tostring(err)..", traceback:\n"..traceback
  g_LTL_Serp.modlog("ERROR : "..fullerr,ModID)
  return fullerr
end

-- starts a "thread" with system.start(fn,threadname). But uses pcall to start the function and logs the error if one happens 
 -- (otherwise any lua error is just swallowed without notification)
local function start_thread(threadname,_ModID,fn,...)
  local args = {...}
  _ModID = _ModID or ""
  if string.find(threadname,"_random_") then -- if you added this string into your thread name
    threadname = g_LTL_Serp.myreplace(threadname,"_random_",tostring(math.random())) -- making sure all threads are unique and not replaced
  end
  local final_threadname = tostring(_ModID)..": "..tostring(threadname)
  if system.internal.coroutines[final_threadname]~=nil then -- no need to check status, because done threads are already set nil again
    g_LTL_Serp.modlog("WARNING start_thread: A thread with the name "..tostring(final_threadname).." is currently running. Are you sure you want to overwrite it? Choose a unique threadname if you dont want this (you can include _random_ in the threadname to add random number)",_ModID)
  end
  return system.start(function()
    local status,err = xpcall(fn,g_LTL_Serp.log_error,table.unpack(args))
    if status==false then
      g_LTL_Serp.modlog("ERROR in thread '"..tostring(final_threadname).."': "..tostring(err),_ModID)
      error(err)
    end
  end,final_threadname)
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
        print("stopthreads, stopping thread although its still busy: "..tostring(name),ModID)
        g_LTL_Serp.modlog("stopthreads, stopping thread although its still busy: "..tostring(name),ModID)
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

local function SplitNumberFromName(name)
  local name_parts = g_LTL_Serp.mysplit(name, "_") -- eg. "The Shipname_2300" or simply "0.5"
  local namevalue,restname = nil, ""
  for _,part in ipairs(name_parts) do
    local asnumber = tonumber(part)
    if namevalue==nil and asnumber~=nil then
      namevalue = asnumber
    end
    if asnumber==nil then
      restname = restname..part
    end
  end
  return restname,namevalue
end

local maxdisplayedlength = 16 -- this is the max for Anno1800
local function GetNameInvisible(name)
  local splits = g_LTL_Serp.mysplit(name,"‎")
  local result = {}
  for _,v in ipairs(splits) do
    if v~="" then
      table.insert(result,v)
    end
  end
  return result[2],result[1] -- first the invisible part (expect it containing # as seperator), because this is what we are most liklely interested in
end
-- to support adding multiple invisible strings to the name, it adds "#" as seperator
local function AddToNameInvisible(origname,addstring,onlifnotaddedyet)
  local new_name = origname
  if not onlifnotaddedyet or not string.find(origname,addstring) then
    local invis,name = g_LTL_Serp.GetNameInvisible(origname)
    if invis==nil or invis=="" then
      new_name = name
      for i=name:len() ,maxdisplayedlength-1,2 do -- can not add spaces, because the game handles them very strange...
        new_name = "‎" .. new_name .. "‎" -- -- add spaces front and back until we reached the max displayed length (so the position of the displayed text does not change)
      end
      new_name = new_name .. "‎" -- add one at the end, so even if it is already 16 chars, we have one to use the split on in GetNameInvisible
    else
      new_name = origname
    end
    new_name = new_name .. addstring .. "#" -- # used as seperator
  end
  return new_name
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
  
  -- this t_FnViaTextEmbed is extremly powerful and helpful!
   -- But please READ every comment I write about it, its important that you use it correctly, otherwise it may break for you and other mods using it!
  
  -- t_FnViaTextEmbed is used to execute your custom lua code via ThirdPartyButton on CharacterNotification (which can only execute textembeds, not lua code)
   -- it also makes sure that only the Peer who clicked the Button executes the code (by storing the CompanyName-change only for him and resetting it quite fast (its a delay of ~200 ms before the script is called))
  -- gets called via Trigger 1500005600 , which is Registered eg via CharacterNotification Buttons:
   -- <Command>[Unlock RelockNet(1500005600)];[Participants Participant(121) Profile SetCompanyName(g_ObjectFinderSerp.IsLoadedSessionByID|2|false)];[Conditions RegisterTriggerForCurrentParticipant(1500005600)]</Command>
   -- using unsynced CompanyName from "Scenario3_Challenger4  GUID: 101507 , PID: 121" and "Scenario3_Challenger5  GUID: 101508 , PID: 122" as helper.
    -- several characters are not allowed in Names, so use "|" to seperate functionname from arguments
  -- Executing textembeds this way roughly takes 2 ticks (200ms) or 4 ticks in Multiplayer before the result can be fetched eg from other conditions

  -- Important including textembeds:
    -- textembeds within SetCompanyName in the Command does not work good. It will remove ALL text except this textembed result
   -- so eg. SetCompanyName(hallo[AssetData(11715) Text])]hallo[AssetData(11507) Text])] only becomes "Handelsrouten", nothing more
     -- Thats why DONT use any textembeds in 121. You can use up to 1 textembed in 122 instead (and only this textembed)
      -- and write usetextembed as argument in 121, eg.: 
      -- <Command>[Unlock RelockNet(1500005600)];[Participants Participant(121) Profile SetCompanyName(g_sellable_serp.t_SimpleSellSelected|usetextembed|true|false)];[Participants Participant(122) Profile SetCompanyName([NotificationContext Value(TraderIndex) Int])];[Conditions RegisterTriggerForCurrentParticipant(1500005600)]</Command>
     
    -- ProTip:
    -- by using also CharacterNotification_DummyCommand (ObjectDummies shared mod) instead of ActionExecuteScript it saves from creating a new script per function and especially from creating one script per human and checking which human we are. -->
     -- by using CharacterNotification_DummyCommand together with the t_FnViaTextEmbed system, the function is only executed for the PID who executes the trigger (for coop its still executed multiple times!)
    
    -- Notifications are most likley not executed for AIs processing the Trigger (not tested)
   
   -- IMPORTANT:
   -- Before doing your <Command> in eg a xml trigger, first check if 1500005600 is unlocked ! If it is locked, this fn is currently in use and you need to wait!!
    -- For CharacterNotification with player interaction, use <ActiveCallback>[Unlock IsUnlocked(1500005600)]</ActiveCallback> 
    -- In addition you might want to check if 1500005606 is unlocked, because CharacterNotification do NOT WORK within the first ~3 seconds of a new game.
     -- When waiting for 1500005606 to be unlocked, you can be sure that it will work.
   -- (also see assets.xml 1500005600 for more details)
  local function t_FnViaTextEmbed(PID)
    if PID==nil or PID == ts.Participants.GetGetCurrentParticipantID() then -- only the correct Participant 
      local TaskString =  ts.Participants.GetParticipant(121).Profile.CompanyName -- TaskString eg: "g_ObjectFinderSerp.IsLoadedSessionByID_2_false"
      -- g_LTL_Serp.modlog("t_FnViaTextEmbed called with: "..tostring(TaskString),ModID)
      local oldname1 = ts.GetAssetData(101507).Text
      local oldname2 = ts.GetAssetData(101508).Text
      if TaskString~=oldname then -- only the correct Peer (who hit the button)
        ts.Participants.GetParticipant(121).Profile.SetCompanyName(oldname1) -- name it back to original
        if string.find(TaskString,"usetextembed") then
          local textembed_result = ts.Participants.GetParticipant(122).Profile.CompanyName
          TaskString = g_LTL_Serp.myreplace(TaskString,"usetextembed",textembed_result)
          ts.Participants.GetParticipant(122).Profile.SetCompanyName(oldname2) -- name it back to original
        end
        local tasksplit = g_LTL_Serp.mysplit(TaskString,"|")
        local funcname = table.remove(tasksplit,1)
        local func = g_LTL_Serp.myeval(funcname)
        for i=1,#tasksplit do
          local value = tasksplit[i]
          tasksplit[i] = g_LTL_Serp.myeval(tasksplit[i])
        end
        -- call the func within a new thread, to not longer block this function
        g_LTL_Serp.start_thread("t_FnViaTextEmbed_random_ call "..tostring(funcname),ModID,function(func,funcname,tasksplit,TaskString,ModID)
          local notstop = 0
          while func==nil do -- in case this is executed with AlwaysTrue Trigger or so, give it a second to init all lua scripts
            coroutine.yield() -- 100ms
            notstop = notstop + 1
            if notstop>20 then --2seconds
              break
            end
            func = g_LTL_Serp.myeval(funcname)
          end          
          local success, err
          if func==nil then
            success, err = false,"t_FnViaTextEmbed: func does not exist (nil)" -- its a bit more clear than "attempt to call a nil value"
          else
            success,err = xpcall(func,g_LTL_Serp.log_error,table.unpack(tasksplit))
          end
          if success==false then
            g_LTL_Serp.modlog("ERROR t_FnViaTextEmbed while trying to execute TaskString: "..tostring(TaskString).." , error: "..tostring(err),ModID)
          end
        end,func,funcname,tasksplit,TaskString,ModID)
      end
    end
    g_LTL_Serp.start_thread("t_FnViaTextEmbed release it again",ModID,function()
      coroutine.yield() -- one yield to make sure t_FnViaTextEmbed was ended meanwhile
      ts.Unlock.SetUnlockNet(1500005600)
    end)
  end
  
  
  
  -- text embed helper for using MetaObjects.SessionGameObject, which is otherwise unavailable in lua...
   -- ts_embed_string should be eg: "[MetaObjects SessionGameObject("..tostring(OID)..") Area CityName]"
   -- so always inlucding "[MetaObjects SessionGameObject("..tostring(OID)..") ...]" and your wanted command for the OID you enter
  -- Make sure to test if your call does what it should, because this function does not check if your ts_embed_string is valid!
  -- Also works for things like: "[Quests Quest(QuestID) QuestObjectives MainObjectives AT(0) DeliveryObjects AT(0) Product]"
  local function DoForSessionGameObject(ts_embed_string,doreturnstring,keepasstring)
    if doreturnstring then -- we want to get what the textembed returns, but game.TextSourceManager.setDebugTextSource does not return anything. I only know a workarkund to get it, by setting and reading out the name of a namable helper object
        game.TextSourceManager.setDebugTextSource("[Participants Participant(120) Profile SetCompanyName( "..tostring(ts_embed_string).." )]")
        local returnstring = ts.Participants.GetParticipant(120).Profile.CompanyName
        local oldtext = ts.GetAssetData(100939).Text -- does not work to call this directly in SetCompanyName
        ts.Participants.GetParticipant(120).Profile.SetCompanyName(oldtext) -- set it to nil again, so you can notice if sth did not work
        ret = returnstring
        if returnstring==oldtext then -- were not able to put the returned value into the name. most likely invalid character or invalid type
          ret = nil -- ALSO happens for 0 Pointers. For invalid objects ts.GetGameObject(OID).GUID will be 0. But SessionGameObject does not return 0 here, but sth invalid.
        end
        if not keepasstring and ret~=nil then
          ret = g_LTL_Serp.myeval(returnstring)
          if ret==nil then -- failed to eval, eg. meant to be a string
            ret = returnstring
          end
        end
        return ret
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
    -- buildings (hängt vom GUIType ab): 116 Bauernhaus, 103 Marktplatz, 102 Kontor/Lagerhaus,97 handelskammer UI, 113 Kirche, 120 Werft, 192/193 oder 194 ist Movie beenden
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
        -- g_LTL_Serp.modlog("GetGameObjectPath : [MetaObjects SessionGameObject("..tostring(OID)..")"..path_textemb.."]",ModID)
        ret = g_LTL_Serp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(OID)..")"..path_textemb.."]",true)
        local status,err = xpcall(g_LTL_Serp.myeval,g_LTL_Serp.log_error,ret) -- to make "1" 1 or "true" true
        if status==true then -- otherwise we keep it as string (eg. "Feld Besteller" Name causes an error with myeval)
          ret = err
        end
      end
    end
    return ret
  end
  
  -- Quests:
  -- RunningQuestByGUID gibt es offenbar nicht mehr (dass wir auch echt keine aktuelle textsourcelist.json von ubi bekommen nervt hart...)
    -- auch via setDebugTextSource geht RunningQuestByGUID nicht, wurde also vermutlich wirklich komplett entfernt.
   -- Aber wir können ts.Quests.GetQuest(i) nutzen und da einfach mit Zahlen von 0 bis x drüber loopen
    -- und die Quest suchen die wir behandeln wollen. Gibt nur leider auf die QuestInstance keinen Check ob es eine bestimmte GUID
     -- ist , es geht nur QuestDescriptionText und QuestStoryText, dh am besten DescriptionText gleich GUID setzen, da dies soweit ich sehen kann eh nie ingame angezeigt wird.
   -- QuestInstance.IsActive ist immer true sobald die instance gestartet ist (und HasEnded immer true sobald beendet)
    -- Dh. ich muss wenn ich aktive Quests will, suchen nach IsActive and not HasEnded
  -- Die IDs der Quests scheinen bei 0 anzufangen und werden größer. Die ID wird festegelegt, sobald Quest auf Karte annehmbar ist.
  -- returns a list of IDs. you can get the QuestInstance via ts.Quests.GetQuest(ID)
  -- PROBLEM:
   -- Diese QuestIDs sind natürlich global, also jeder Spieler sieht dieselben IDs und es gibt keine Möglichkeit
    -- rauszufinden, welche Quests für wen aktiv sind -.-
    -- Also ist es am sichersten das lua script direkt nach dem Start der Quest zu starten und dort die neuste (letzte der liste) gefundene passenende Quest zu nehmen (sofern jetzt gerade nur für diesen Spieler gestartet wurde)!
    -- Alternativ jede Quest 4 mal machen, eine pro Human und WhichPlayerCondition Mod nutzen um eine Quest nur für Human0 usw zu starten
  local function GetActiveQuestInstances(DescriptionTextGUID,firstfound,startfromID,logloop) -- we can only search for DescriptionText, not the Quest GUID...  
    local ID = startfromID or 2 -- 0 to 1 are empty it seems. 2 always seems to be  "153179 Writers Quests Trigger"
    local QuestIndices = {} -- returning Indices instead of QuestInstance, because such instances are broken after one use (same for GameObject)
    local abortcount = 0 -- we loop until we reach empty quests. But unfortunately sometimes some quests may appear as empty (eg. A7_QuestSubQuest), so only abort after we hit x empty quests in a row
    while true do
      if logloop then
        g_LTL_Serp.modlog("Quest ID "..tostring(ID)..", active: "..tostring(ts.Quests.GetQuest(ID).IsActive)..", HasEnded: "..tostring(ts.Quests.GetQuest(ID).HasEnded)..", StoryText: "..tostring(ts.Quests.GetQuest(ID).QuestStoryText)..", DescriptionText: "..tostring(ts.Quests.GetQuest(ID).QuestDescriptionText)..", TimeLeft: "..tostring(ts.Quests.GetQuest(ID).TimeLeft)..", StateReachable: "..tostring(ts.Quests.GetQuest(ID).StateReachable),ModID)
      end
      local IsActive = ts.Quests.GetQuest(ID).IsActive
      local HasEnded = ts.Quests.GetQuest(ID).HasEnded
      local StoryText = ts.Quests.GetQuest(ID).QuestStoryText
      local DescriptionText = ts.Quests.GetQuest(ID).QuestDescriptionText
      local TimeLeft = ts.Quests.GetQuest(ID).TimeLeft
      if not IsActive and not HasEnded and StoryText==0 and DescriptionText==0 and TimeLeft==0 then -- most likely reached the end of quests
        abortcount = abortcount + 1
      else
        abortcount = 0
      end
      if abortcount >= 20 then -- only after the last 20 quests were empty we can be sure enough... (ok that much "empty" quests usually only happen on testing much, not sure exactly what causes them... I think A7_QuestSubQuest)
        break
      end
      if IsActive and not HasEnded and (DescriptionTextGUID==nil or DescriptionText==DescriptionTextGUID) then
        table.insert(QuestIndices,ID)
        if firstfound then
          break
        end
      end
      ID = ID + 1
    end
    return QuestIndices
  end

-- Quest ID 0, active: false, HasEnded: false, StoryText: 0, DescriptionText: 0, TimeLeft: 0, StateReachable: false
-- Quest ID 1, active: false, HasEnded: false, StoryText: 0, DescriptionText: 0, TimeLeft: 0, StateReachable: false
-- Quest ID 2, active: true, HasEnded: false, StoryText: 0, DescriptionText: 0, TimeLeft: 0, StateReachable: false
-- Quest ID 3, active: true, HasEnded: true, StoryText: 1500001291, DescriptionText: 3965, TimeLeft: 5671600, StateReachable: false
-- Quest ID 4, active: true, HasEnded: true, StoryText: 9814, DescriptionText: 3809, TimeLeft: -91900, StateReachable: false
-- Quest ID 5, active: true, HasEnded: true, StoryText: 18355, DescriptionText: 3809, TimeLeft: -485000, StateReachable: false
-- Quest ID 6, active: true, HasEnded: true, StoryText: 18139, DescriptionText: 3965, TimeLeft: 118400, StateReachable: false
-- Quest ID 7, active: true, HasEnded: true, StoryText: 17300, DescriptionText: 3809, TimeLeft: 579200, StateReachable: false
-- Quest ID 8, active: false, HasEnded: false, StoryText: 18444, DescriptionText: 3965, TimeLeft: 1800000, StateReachable: false
-- Quest ID 9, active: true, HasEnded: false, StoryText: 1500001291, DescriptionText: 3965, TimeLeft: 6343700, StateReachable: false
-- Quest ID 10, active: false, HasEnded: false, StoryText: 0, DescriptionText: 0, TimeLeft: 0, StateReachable: false
-- Quest ID 11, active: false, HasEnded: false, StoryText: 0, DescriptionText: 0, TimeLeft: 0, StateReachable: false
-- Quest ID 12, active: false, HasEnded: false, StoryText: 0, DescriptionText: 0, TimeLeft: 0, StateReachable: false
-- Quest ID 13, active: false, HasEnded: false, StoryText: 0, DescriptionText: 0, TimeLeft: 0, StateReachable: false
  
  -- ts.Quests.GetQuest(8).SetAbortedNet(bool_isManually,int_QuestAbortReason)
  
-- ########################################################################################
  
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
      PropertyID = g_LTL_Serp.PropertiesStringToID[Property]
    end
    local GUID,OID
    local Objects = {}
    local SessionGuid = session.getSessionGUID() -- only current session is found by getObjectGroupByProperty
    local ParticipantID = ts.Participants.GetGetCurrentParticipantID() -- finds only objects from local player
    if PropertyID~=nil then
      local userdatas = session.getObjectGroupByProperty(PropertyID) -- game.MetaGameManager finds the same like session...
      if type(userdatas)=="table" and #userdatas>0 then
        for k,userdata in ipairs(userdatas) do
          if userdata~=nil and g_LTL_Serp.IsUserdataValid(userdata) then -- is never nil, but nullpointer if not assigned. but here it should always be assigned
            OID = g_LTL_Serp.get_OID(userdata)
            GUID =  ts.Objects.GetObject(OID).GUID
            if GUID~=0 then -- is not the case here, but just to be save
              Objects[OID] = {GUID=GUID, userdata=userdata,OID=OID,ParticipantID=ParticipantID,SessionGuid=SessionGuid}
            end
          end
        end
      end
    end
    return Objects
  end
  
  -- #####################################################################################################

  -- a function to make PID destroy all objects with GUID in the current active session
   -- it is used for my Reputation/Reaction system, which uses ShipDestroyed Pamsy.
    -- in xml: spawn the victim GUID with Trigger as owner of processing player in current session (this way we can easily find it in lua)
     -- start a lua script (one per human) that calls this function with your spawned GUID
      -- change the owner with a delay of ~1 second to the participant you want to participate in the reaction
    -- The Attacker will always be the processing human, because a human is always part of all reactions,
     -- since if it is not, no notifaction needs to be send and you can instead directly change the reputation.
     -- And if it would be victim you would get a "ship destroyed" notification, since this was hardcoded by the devs and can not be disabled (except with OmitPamsyUponDestruction, but this also disables other reactions)
      -- For the reaction system it does not matter if we are Attacker=Initiator or Victim=Target
  local function DestroyGUIDByLocal(PID,GUID,Property)
    if PID == ts.Participants.GetGetCurrentParticipantID() then -- functions called via ActionExecuteScript need this check
      g_LTL_Serp.modlog("DestroyGUIDByLocal: GUID "..tostring(GUID).." called",ModID)
      g_LTL_Serp.start_thread("DestroyGUIDByLocal_random_",ModID,function()
        local Property = Property or "ShipMaintenance" -- best for finding ships
        local objects = g_LTL_Serp.GetCurrentSessionObjectsFromLocaleByProperty(Property)
        local victims = {}
        for OID,objectinfo in pairs(objects) do
          if objectinfo.GUID == GUID then
            table.insert(victims,OID)
          end
        end
        if next(victims)~=nil then
          for i,OID in ipairs(victims) do
            local owner = ts.GetGameObject(OID).Owner -- while we wait the session might change, so using GetGameObject is good
            local notstop = 0
            while owner==PID do -- wait for owner to change
              coroutine.yield() -- 100ms
              owner = ts.GetGameObject(OID).Owner
              notstop = notstop + 1
              if notstop > 100 then -- 100 times 100ms, so 10 seconds
                break
              end
            end
            if notstop > 100 then
              g_LTL_Serp.modlog("DestroyGUIDByLocal: GUID "..tostring(GUID).." did not change owner within 10 seconds.. abort",ModID)
            else
              coroutine.yield() -- just to be sure owner change was completely done
              ts.GetGameObject(OID).Attackable.SetAddDamagePercent(100,PID)
              g_LTL_Serp.modlog("DestroyGUIDByLocal: GUID "..tostring(GUID).." success, should be destroyed now",ModID)
            end
          end
        else
          g_LTL_Serp.modlog("DestroyGUIDByLocal: did not find GUID "..tostring(GUID).." owned by local player in current session (normal in coop, but at least one from the coop team should find it, unless you called this fn with an GUID you did not spawn just to save scripts)",ModID)
        end
      end)
    end
  end
  
  -- is called whenever the local peer hits the "Confirm" Button on a "Do you really want to delete the object" PopUp (xml)
  -- (only for the peer who hits the confirm popup button, so not for all coop peers)
   -- (we could also overwrite "ts.Selection.DestructSelected" which would affect the "Del" keybind, but there is no way to check if it will directly delete or show a popup. and I think it does not catch the Delete-Tool)
  local EventOnObjectDeletionConfirmed = {}
  -- add your function which should be called to the list EventOnObjectDeletionConfirmed with ModID of your mod as key.
  local function _OnObjectDeletionConfirmed(GUID)
    for modname,fn in pairs(EventOnObjectDeletionConfirmed) do
      if type(fn)=="function" then
        local status,err = xpcall(fn,g_LTL_Serp.log_error,GUID)
        if status==false then
          g_LTL_Serp.modlog("ERROR in _OnObjectDeletionConfirmed for mod '"..tostring(modname).."': "..tostring(err),ModID)
        end
      end
    end
  end
  -- ###################################################################################################
  -- ###################################################################################################
  -- ###################################################################################################

  -- CheckObjectHelpers
  
  
  -- userdata is only valid if the object still exists and if the local player is in the same session like the object
  -- this function will return userdata if valid, and nil if invalid
  local function IsUserdataValid(userdata,OID)
    userdata = userdata or game.MetaGameManager.getObjectByID(OID)
    local name = userdata:getName() -- expected sth like: "GameObject, oid 8589934647"
    if not name:find("oid") then -- eg "GameObject unassigned" or "Invalid gameObject id"
      return nil
    end
    return userdata
    
    -- old code
    -- local function savecallproperty(userdata,PropertyID)
      -- return userdata:getProperty(PropertyID) -- for valid userdata it throws an error if it does not have the property (caught (...) exception), thats why the savecallproperty fn
    -- end
    -- local success, PropertyName = pcall(savecallproperty,userdata,123456789) -- a random invalid PropertyID number.
    -- if success then -- since this property does not exist, it can not be a success for valid objects
      -- return nil -- PropertyName will contain sth like: "GameObject unassigned" or "Invalid gameObject id"
    -- end
    -- return userdata
  end
  
  
  
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
    -- or also with other session OID to get userdata: unassigned

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
        local success, PropertyName = pcall(savecallproperty,userdata,PropertyID) -- getProperty raises an error if it does not have the property. preventing this with pcall. you will still see an error in the documents logfile from anno: LUA error occurred: caught (...) exception
        if success then
          if PropertyName==nil then
            return nil
          elseif not PropertyName:find("Invalid") and not PropertyName:find("unassigned") then -- "Invalid gameObject id" userdata eg. because no longer filled, was never valid or called in wrong session. "GameObject, unassigned" if we using an OID from another session
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
    -- (mit ts.GetItemAssetData(BuffGUID) kommen wir an infos zu buffs/items, aber nicht ob etwas davon betroffen ist)
  -- I fear checking other buffs is not possible in lua...



-- ##################################################################################################################
-- ##################################################################################################################


g_LTL_Serp = {
  -- general lua helpers
  replace_chars_for_Name = replace_chars_for_Name,
  TableToFormattedString = TableToFormattedString,
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
  SortFnBigToSmall = SortFnBigToSmall,
  pairsByKeys = pairsByKeys,
  GetPairAtIndSortedKeys = GetPairAtIndSortedKeys,
  TableToHex = TableToHex,
  HexToTable = HexToTable,
  argstotext = argstotext,
  
  -- ######################################
  -- Anno1800 related lightweigth lua helpers
  
  -- technical Anno1800 helpers
  modlog = modlog,
  log_error = log_error,
  start_thread = start_thread,
  waitForTimeDelta = waitForTimeDelta,
  CallGlobalFnBlocked = CallGlobalFnBlocked,
  StopAllThreads = StopAllThreads,
  WasNewGameJustStarted = WasNewGameJustStarted,
  IsHuman = IsHuman,
  ToTextembed = ToTextembed,
  SplitNumberFromName = SplitNumberFromName,
  AddToNameInvisible = AddToNameInvisible,
  GetNameInvisible = GetNameInvisible,
  
  -- ID Converter
  AreatableToAreaID = AreatableToAreaID,
  AreaIDToAreatable = AreaIDToAreatable,
  OIDtableToOID = OIDtableToOID,
  OIDToOIDtable= OIDToOIDtable,
  get_OID = get_OID,
  
  -- Some constants
  PIDs = {
    Human0={PID=0,GUID=41},Human1={PID=1,GUID=600069},Human2={PID=2,GUID=600070},Human3={PID=3,GUID=42},
    General_Enemy={PID=9,GUID=44},Neutral={PID=8,GUID=34},Third_party_01_Queen={PID=15,GUID=75},
    Second_ai_01_Jorgensen={PID=25,GUID=47},Second_ai_02_Qing={PID=26,GUID=79},Second_ai_03_Wibblesock={PID=27,GUID=80},
    Second_ai_04_Smith={PID=28,GUID=81},Second_ai_05_OMara={PID=29,GUID=82},Second_ai_06_Gasparov={PID=30,GUID=83},
    Second_ai_07_von_Malching={PID=31,GUID=11},Second_ai_08_Gravez={PID=32,GUID=48},Second_ai_09_Silva={PID=33,GUID=84},
    Second_ai_10_Hunt={PID=34,GUID=85},Second_ai_11_Mercier={PID=64,GUID=220},
    Third_party_03_Pirate_Harlow={PID=17,GUID=73},Third_party_04_Pirate_LaFortune={PID=18,GUID=76},
    Third_party_02_Blake={PID=16,GUID=45},Third_party_06_Nate={PID=22,GUID=77},Third_party_05_Sarmento={PID=19,GUID=29},
    Third_party_07_Jailor_Bleakworth={PID=23,GUID=46},Third_party_08_Kahina={PID=24,GUID=78},Africa_Ketema={PID=80,GUID=119051},Arctic_Inuit={PID=72,GUID=237},
    Scenario3_Editor={GUID=100131,PID=117},Scenario3_Challenger1={GUID=100132,PID=118},Scenario3_Challenger2={GUID=100938,PID=119},
    Scenario3_Challenger3={GUID=100939,PID=120},Scenario3_Challenger4={GUID=101507,PID=121},Scenario3_Challenger5={GUID=101508,PID=122},
    Scenario3_Challenger6={GUID=101509,PID=123},Scenario3_Challenger7={GUID=101517,PID=124},Scenario3_Challenger8={GUID=101518,PID=125},
    Scenario3_Challenger9={GUID=101519,PID=126},Scenario3_Challenger10={GUID=101520,PID=127},Scenario3_Challenger11={GUID=101521,PID=128},
    Scenario3_Challenger12={GUID=101522,PID=129},Scenario3_Eli={GUID=103130,PID=136},Scenario3_Ketema={GUID=103129,PID=137},
    Scenario3_Archie={GUID=103131,PID=138},Scenario_Item_Trader={GUID=4387,PID=139},Scenario3_Queen={GUID=101523,PID=130},
    
    -- ={PID=,GUID=},={PID=,GUID=},={PID=,GUID=},
  },
  ShipNameGUIDs = { -- eg to choose a random name via lua g_LTL_Serp.weighted_random_choices(g_LTL_Serp.ShipNameGUIDs, 1)[1] (SetName("") does not work, although it should generate a random name...)
    [2302]=1,[2303]=1,[2304]=1,[2305]=1,[2306]=1,[2307]=1,[2308]=1,[2309]=1,[2310]=1,[2311]=1,[2312]=1,[2313]=1,[2314]=1,
    [2315]=1,[2316]=1,[2317]=1,[2318]=1,[2319]=1,[10715]=1,[10716]=1,[10717]=1,[10718]=1,[10719]=1,[10720]=1,[10721]=1,
    [10722]=1,[10723]=1,[10724]=1,[10725]=1,[10726]=1,[10727]=1,[10728]=1,[10729]=1,[10730]=1,[10731]=1,[10732]=1,[10733]=1,
    [10734]=1,[10735]=1,[10736]=1,[10737]=1,[10738]=1,[10739]=1,[10740]=1,[10741]=1,[10742]=1,[10743]=1,[10744]=1,[10745]=1,
    [10746]=1,[10747]=1,[10748]=1,[10749]=1,[10750]=1,[10751]=1,[10752]=1,[10753]=1,[10754]=1,[10755]=1,[10756]=1,[10757]=1,
    [10758]=1,[10759]=1,[10760]=1,[10761]=1,[10762]=1,[10763]=1,[10764]=1,[10765]=1,[10766]=1,[10767]=1,[10768]=1,[10769]=1,
    [10770]=1,[10771]=1,[10772]=1,[10773]=1,[10774]=1,[10775]=1,[10776]=1,[10777]=1,[10778]=1,[10779]=1,[10780]=1,[10781]=1,
    [10782]=1,[10783]=1,[10784]=1,[10785]=1,[10786]=1,[10787]=1,[10788]=1,[10789]=1,[10790]=1,[10791]=1,[10792]=1,[10793]=1,
    [10794]=1,[10795]=1,[10796]=1,[10797]=1,[10798]=1,[10799]=1,[10800]=1,[10801]=1,[10802]=1,[10803]=1,[10804]=1,[10805]=1,
    [10806]=1,[10807]=1,[10808]=1,[10809]=1,[10810]=1,[10811]=1,[10812]=1,[10813]=1,[10814]=1,[20495]=1,[20496]=1,[20497]=1,
    [20498]=1,[20499]=1,[20500]=1,[20501]=1,[20502]=1,[20503]=1,[20504]=1,[20505]=1,[20506]=1,[20507]=1,[20508]=1,[20509]=1,
    [20510]=1,[20511]=1,[20512]=1,[20513]=1,[20514]=1,[20515]=1,[20516]=1,[20517]=1,[20518]=1,[20519]=1,[20520]=1,[20521]=1,
    [20522]=1,[20523]=1,[20524]=1,[20525]=1,[20526]=1,[20527]=1,[20528]=1,[20529]=1,[20530]=1,[20531]=1,[20532]=1,[20533]=1,
    [20534]=1,[20535]=1,[20536]=1,[20537]=1,[20538]=1,[20539]=1,[20540]=1,[20541]=1,[20542]=1,[20543]=1,[20544]=1,[20545]=1,
    [20546]=1,[20547]=1,[20548]=1,[20549]=1,[20550]=1,[20551]=1,[20552]=1,[20553]=1,[20554]=1,[20555]=1,[20556]=1,[20557]=1,
    [20558]=1,[20559]=1,[20560]=1,[20561]=1,[20562]=1,[20563]=1,[20564]=1,[20565]=1,[20566]=1,[20567]=1,[20568]=1,[20569]=1,
    [20570]=1,[20571]=1,[20572]=1,[20573]=1,[20574]=1,[20575]=1,[20576]=1,[20577]=1,[20578]=1,[20579]=1,[20580]=1,[20581]=1,
    [20582]=1,[20583]=1,[20584]=1,[20585]=1,[20586]=1,[20587]=1,
  },
  -- GetTopLevelDiplomacyStateTo only returns 0 to 3. to check CeaseFire/NonAttack use GetCheckDiplomacyStateTo
  DiplomacyState = {War=0,Peace=1,TradeRights=2,Alliance=3,CeaseFire=4,NonAttack=5}, -- from datasets.xml
   -- for StatisticsMenu UIState = 176, for ships it is 119 (it is called RefGuid in infotips for whatever reason), get them eg with adding your log function to table event.OnLeaveUIState and log the one paramater of this function
  -- CompynaMenu (hitting on your profile) is UIState = 0, diplomenu=29, TradeRoutemenu is 165 or 177, ESC Menü 132, Optionsmenü 129, Annopedia 174, EinflussFenster ist 52, Stadt Attraktivität ist 3, 
    -- buildings (hängt vom GUIType ab): 116 Bauernhaus, 103 Marktplatz, 102 Kontor/Lagerhaus,97 handelskammer UI, 113 Kirche, 120 Werft, 192/193 oder 194 ist Movie beenden
  -- RefOid = 0 for whole menus , for ships/buildings: g_LTL_Serp.get_OID(session.getSelectedFactory()) 
  
  -- related to GUIType , but not the same like UIState from datasets.xml. There is no datasets.xml for this
   -- but it is the thing returned from event.OnLeaveUIState and used eg for GetCoopPeersAtMarker
  -- TODO vervollständigen
  UITypeState = {Statistics=176,Shipyard=120},
  
  -- Trickster Anno Helpers
  t_FnViaTextEmbed = t_FnViaTextEmbed,
  DoForSessionGameObject = DoForSessionGameObject,
  GetFertilitiesOrLodesFromArea_CurrentSession = GetFertilitiesOrLodesFromArea_CurrentSession,
  GetVectorGuidsFromSessionObject = GetVectorGuidsFromSessionObject,
  GetCoopPeersAtMarker = GetCoopPeersAtMarker,
  GetGameObjectPath = GetGameObjectPath,
  GetActiveQuestInstances = GetActiveQuestInstances,
  GetCurrentSessionObjectsFromLocaleByProperty = GetCurrentSessionObjectsFromLocaleByProperty,
  DestroyGUIDByLocal = DestroyGUIDByLocal,
  EventOnObjectDeletionConfirmed = EventOnObjectDeletionConfirmed,
  _OnObjectDeletionConfirmed = _OnObjectDeletionConfirmed,
  
  -- CheckObjectHelpers 
  IsUserdataValid = IsUserdataValid,
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

