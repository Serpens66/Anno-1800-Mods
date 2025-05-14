
print("luatools.lua registered")


-- usage:

-- if g_LuaTools==nil then
  -- console.startScript("data/scripts_serp/luatools.lua")
-- end
-- then you can use eg. g_LuaTools.modlog(text) or g_LuaTools.table_len(t) and so on in your script

-- ####################################################################################
-- ####################################################################################



-- \Ubisoft\Ubisoft Game Launcher\games\Anno 1800\logs\modlog.txt
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
  local file = io.open("logs/modlog.txt", "a")
  io.output(file)
  io.write(text,"\n")
  io.close(file)
end
-- empty the file on every game start
local file = io.open("logs/modlog.txt", "w")
io.output(file)
io.write("")
io.close(file)


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
local function table_contains_value(tbl, x)
  for _,v in pairs(tbl) do
    if v == x then 
      return true
    end
  end
  return false
end
local function table_contains_key(tbl, x)
  for k,v in pairs(tbl) do
    if k == x then 
      return true
    end
  end
  return false
end

-- #################
-- 1.01

console.startScript("data/scripts_serp/bint.lua")
local to_bint = g_bint_Library051(256)

local function mysplit(source, delimiters)
    local elements = {}
    local pattern = '([^'..delimiters..']+)'
    -- string.gsub(source, pattern, function(value) elements[table_len(elements) + 1] =     value;  end);   
    string.gsub(source, pattern, function(value) table.insert(elements,value);  end);   
    return elements
end

local function myreplace(source,repl,with) -- repl has to be at least 2 characters long
    result = string.gsub(source,"%b"..repl, with) -- to use it for one character, leave out the %b .   To replace a non-alphanumeric character like a dot, use %. for a dot
    return result
end

-- rounding of numbers
local function myround(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

-- to unpack an array as single arguments in a function (eg. good for msgboxes with a variable number of arguments)
local function myunpack(t, i)
    i = i or 1
    if t[i] ~= nil then
        return t[i], myunpack(t, i + 1)
    end
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

-- #########################################################################################

-- 1.02

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
            ret[k] = MergeMapsDeep(myunpack(subtables))
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
function tables_equal(o1, o2, ignore_mt)
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

-- wait realtime (system.waitForGameTimeDelta waits for ingame time, so is faster on fast-forward. While we want to wait for syncing stuff to happen, which usually takes the same real time)
-- called from within a thread
local function waitForTimeDelta(waittime)
  local startime = os.clock()*1000
  while os.clock()*1000-waittime < startime do
    coroutine.yield()
  end
end



g_LuaTools = {
  modlog = modlog,
  replace_chars_for_Name = replace_chars_for_Name,
  TableToString = TableToString,
  deepcopy = deepcopy,
  table_len = table_len,
  table_contains_value = table_contains_value,
  table_contains_key = table_contains_key,
  mysplit = mysplit,
  myreplace = myreplace,
  myround = myround,
  myunpack = myunpack,
  my_to_type = my_to_type,
  to_bint = to_bint,
  MergeMapsDeep = MergeMapsDeep,
  weighted_random_choices = weighted_random_choices,
  tables_equal = tables_equal,
  waitForTimeDelta = waitForTimeDelta,
}
