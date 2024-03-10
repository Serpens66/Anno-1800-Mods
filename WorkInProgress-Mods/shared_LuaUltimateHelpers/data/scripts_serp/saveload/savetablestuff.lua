print("savetablestuff.lua called")


-- DONT execute your scripts using savetablestuff/OnGameLoaded with an AlwaysTrue Trigger.
 -- (because when a other savegame is loaded, lua does not reset. my OnGameLoaded script has to reset it first, otherwise you might use wrong infos)
 -- At least use SessionEnter ConditionEvent and then check SaveLuaStuff_Serp.Inited is true
  -- before using it

-- TODO
-- shared mods die LuaOnGameLoaded verwenden sowohl in _Meine Mods,
-- als auch github updaten.
-- und evlt. in CoopCoutenr CoopLeader und OnceSession 
-- die neue RESET fkt nutzen (OnceSession erstmal löschen und nur im mods ordner habe n, da wir da ja eh einiges ändern
-- )



if StringTableConvertSerpNyk==nil then
  console.startScript("data/scripts_serp/saveload/savestuff_tableconvert.lua")
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


local function GetTableFromHelper(ModID,fetchnameagain)
  if fetchnameagain and SaveLuaStuff_Serp.Helper_OID~=nil then
    local namestring = ts.GetGameObject(SaveLuaStuff_Serp.Helper_OID).Nameable.Name
    if type(namestring)=="string" then
      local mytable = StringTableConvertSerpNyk.HexToTable(namestring)
      if type(mytable)=="table" then
        SaveLuaStuff_Serp.SavedTable = deepcopy(mytable)
        if ModID~=nil then
          return mytable[ModID]
        else
          return mytable
        end
      end
    end
  elseif SaveLuaStuff_Serp.Helper_OID==nil then
    print("GetTableFromHelper failed, because SaveLuaStuff_Serp.Helper_OID is not yet known...")
  elseif not fetchnameagain then
    if ModID~=nil then
      return deepcopy(SaveLuaStuff_Serp.SavedTable[ModID])
    else
      return deepcopy(SaveLuaStuff_Serp.SavedTable)
    end
  end
end

local function SaveTableToHelper(ModID,mytable)
  if SaveLuaStuff_Serp.Helper_OID~=nil then
    SaveLuaStuff_Serp.SavedTable[ModID] = mytable
    local namestring = StringTableConvertSerpNyk.TableToHex(SaveLuaStuff_Serp.SavedTable)
    if type(namestring)=="string" then
      -- ts.GetGameObject(SaveLuaStuff_Serp.Helper_OID).Nameable.SetName(namestring) -- in multiplayer this only works for other players too if we are in the same session like the object... (in SP it also works in differnt session)
      ObjectFinderSerp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(SaveLuaStuff_Serp.Helper_OID)..") Nameable Name("..tostring(namestring)..")]")
    end
  else
    print("SaveTableToHelper failed, because SaveLuaStuff_Serp.Helper_OID is not known...")
  end
end


SaveLuaStuff_Serp = SaveLuaStuff_Serp or {
  Helper_OID = nil,
  GetTableFromHelper = GetTableFromHelper,
  SaveTableToHelper = SaveTableToHelper,
  SavedTable = {},
  Inited = false, -- wait with your mod before using SaveLuaStuff_Serp until this is set to true
}

if ObjectFinderSerp==nil then
  console.startScript("data/scripts_serp/objectfinder/objectfinder.lua")
end