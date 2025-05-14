
-- source: https://github.com/Pnski/Anno1800LuaLibs/blob/main/1800seralize.lua



if g_LuaTools==nil then
  console.startScript("data/scripts_serp/luatools.lua")
end
local ModID = "shared_LuaUltimateHelpers_Serp savestuff_tableconverter.lua" -- used for logging


-- https://www.reddit.com/r/lua/comments/hzi7ff/print_local_variable_as_hex_string/
local function HexToString(hex)
  return (hex:gsub("%x%x", function(digits) return string.char(tonumber(digits, 16)) end))
end

-- https://www.reddit.com/r/lua/comments/hzi7ff/print_local_variable_as_hex_string/
--string.format(string.rep("%02x", #variable), variable:byte(1, -1)))
local function StringToHex(str)
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
function ValueToString(_value)
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
    print("unsupported value type for ValueToString:", type(_value), _value)
    g_AnnoTools.modlog("unsupported value type for ValueToString: "..tostring(type(_value)).." "..tostring(_value),ModID)
    return 'nil'
  end
end

function IndexToString(_index)
  if type(_index) == 'number' then
    return "[".._index.."]"
  elseif type(_index) == 'string' then
    return "[\'".._index.."\']"
  else --failsafe
    print("unsupported index type for IndexToString:",type(_index), _index)
    g_AnnoTools.modlog("unsupported index type for IndexToString: "..tostring(type(_index)).." "..tostring(_index),ModID)
    return 'nil'
  end
end

function TableToString(_table)
  local _string = "{"
  if type(_table) ~= 'table' then
    return
  end
  -- convert every array or metatable to array (pairs might fail if C-API call is blocked)
  for k,v in pairs(getkvtable(_table)) do --getkvtable to cycle through
    if #_string > 1 then
      _string = _string ..","
    end
    if type(_table[k]) == 'table' then -- use the original table for direct values
      _string = _string..IndexToString(k).."="..TableToString(_table[k])
    else
      _string = _string..IndexToString(k).."="..ValueToString(v)
    end
  end
  return _string.."}"
end

local function TableToHex(_table)
  return StringToHex(TableToString(_table))
end

local function HexToTable(_string)
  -- print(type(_string)," type string")
  -- print("mystring= ",_string)
  local _ioTable = load("return "..HexToString(_string),nil,"bt",_ioTable)()
  -- print(type(_ioTable)," _ioTable", _ioTable)
  -- print(HexToString(_string))
  -- for k,v in pairs(_ioTable) do print(k,v) end
  return _ioTable
end






-- #############################################################################################################################################
-- #############################################################################################################################################
-- #############################################################################################################################################

-- kopiert aus SaveUtilis.lua von Civ5 mods
 -- funktioniert mit leichten anpassungen, aber immer das risiko dass es invalide Zeichen für Nameable gibt.
  -- und es dauert verflucht lange bei großen listen mit tausenden einträgen... (4 sek bei 5k einträgen, während Hex version da nur 0.09 sek braucht)
  -- Daher nur noch hier zur Referenz, aber nutzen tun wir pnski's code mit hex

--[[
Serializes given data and returns result string.  Invalid data types:
function, userdata, thread.
invalid signs in strings (to save it into nameable): " \ , [ ] and () if both used. and better do not use - because it might hurt gsub?
attention: DONT use numbers as string like "1234". it wont work for multiple reasons (will be converted to number on deserialize, but the " in it will prevent it from saving to Nameable anyways)
]]
local function serialize( p )
  
  local r = ""; local t = type( p );
  if t == "function" or t == "userdata" or t == "thread" then
    print( "serialize(): Invalid type: "..t ); --error.
  elseif p ~= nil then
    if t ~= "table" then
      if p == nil or p == true or p == false
        or t == "number" then r = tostring( p );
      elseif t == "string" then
        if p:lower() == "true" or p:lower() == "false"
            or tonumber( p ) ~= nil then r = '"'..p..'"';
        else r = p;
        end
      end
      r = r:gsub( "{", "#LCB#" );
      r = r:gsub( "}", "#RCB#" );
      r = r:gsub( "=", "#EQL#" );
      r = r:gsub( ",", "#COM#" );
      r = r:gsub( "%[", "#LEB#" );
      r = r:gsub( "%]", "#REB#" );
      r = r:gsub( "%(", "#LRB#" );
      r = r:gsub( "%)", "#RRB#" );
    else
      r = "{"; local b = false;
      for k,v in pairs( p ) do
        -- if b then r = r..","; end
        if b then r = r.."#COMSEP#"; end
        r = r..serialize( k ).."="..serialize( v );
        b = true;
      end
      r = r.."}"
    end
  end
  return r;
end
--===========================================================================
--[[
Deserializes given string and returns result data.
]]
local function deserialize( str )

  local findToken = function( str, int )
    if int == nil then int = 1; end
    local s, e, c = str:find( "({)" ,int);
    if s == int then --table.
      local len = str:len();
      local i = 1; --open brace.
      while i > 0 and s ~= nil and e <= len do --find close.
        s, e, c = str:find( "([{}])" ,e+1);
        if     c == "{" then i = i+1;
        elseif c == "}" then i = i-1;
        end
      end
      if i == 0 then c = str:sub(int,e);
      else print( "deserialize(): Malformed table." ); --error.
      end
    else s, e, c = str:find( "([^=,]*)" ,int); --primitive.
    end
    return s, e, c, str:sub( e+1, e+1 );
  end
  
  str = str:gsub( "#COMSEP#", "," );
  
  local r = nil; local s, c, d;
  if str ~= nil then
    local sT, eT, cT = str:find( "{(.*)}" );
    if sT == 1 then
      r = {}; local len = cT:len(); local e = 1;
      if cT ~= "" then
        repeat
          local t1, t2; local more = false;
          s, e, c, d = findToken( cT, e );
          if s ~= nil then t1 = deserialize( c ); end
          if d == "=" then --key.
            s, e, c, d = findToken( cT, e+2 );
            if s ~= nil then t2 = deserialize( c ); end
          end
          if d == "," then e = e+2; more = true; end --one more.
          if t2 ~= nil then r[t1] = t2;
          else table.insert( r, t1 );
          end
        until e >= len and not more;
      end
    elseif tonumber(str) ~= nil then r = tonumber(str);
    elseif str == "true"  then r = true;
    elseif str == "false" then r = false;
    else
      s, e, c = str:find( '"(.*)"' );
      if s == 1 and e == str:len() then
        if c == "true" or c == "false" or tonumber( c ) ~= nil then
          str = c;
        end
      end
      r = str;
      r = r:gsub( "#LCB#", "{" );
      r = r:gsub( "#RCB#", "}" );
      r = r:gsub( "#EQL#", "=" );
      r = r:gsub( "#COM#", "," );
      r = r:gsub( "#LEB#", "[" );
      r = r:gsub( "#REB#", "]" );
      r = r:gsub( "#LRB#", "(" );
      r = r:gsub( "#RRB#", ")" );
    end
  end
  return r;
end

-- #############################################################################################################################################
-- #############################################################################################################################################
-- #############################################################################################################################################



g_StringTableConvertSerpNyk = {
  HexToTable = HexToTable,
  TableToHex = TableToHex
}