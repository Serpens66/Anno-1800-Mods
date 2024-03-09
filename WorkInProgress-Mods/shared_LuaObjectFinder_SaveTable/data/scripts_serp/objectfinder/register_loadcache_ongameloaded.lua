print("register_loadcache_ongameloaded.lua called (will register if not already done)")
if ObjectFinderSerp==nil then
  console.startScript("data/scripts_serp/objectfinder/objectfinder.lua")
end
if SaveLuaStuff_Serp==nil then
  console.startScript("data/scripts_serp/saveload/savetablestuff.lua")
end

-- source: https://stackoverflow.com/questions/65482605/how-to-print-all-values-in-a-lua-table
local sort, rep, concat = table.sort, string.rep, table.concat
local function TableToPrettyString(var, sorted, indent)
    
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
               .. TableToPrettyString(key, sorted, indent + 1)
               .. ' = '
               .. TableToPrettyString(var [key], sorted, indent + 1)
        end
        return 'table (\n' .. concat (strings, '\n') .. '\n' .. rep ('\t', indent) .. ')'
    else
        return tostring (var)
    end
end


-- OnLuaGameLoaded
-- wait until SaveLuaStuff_Serp found its helper object and then load our objectfinder cache data, to make searching more efficient
local ModID = "ObjectFinderSerp"
local function OnSaveGameLoad_RESET()
  ObjectFinderSerp.ObjectFinderCacheSerp = {ObIDs={},Nameable_Helper_OIDs={}} -- make empty again, because it might be another savegame and we have to find it again
end
local function OnSaveGameLoad()
  print("OnSaveGameLoad ObjectFinderSerp")
  system.start(function()
    local notstop = 0
    while true do
      if SaveLuaStuff_Serp.Helper_OID~=nil and SaveLuaStuff_Serp.Inited then
        break
      end
      coroutine.yield()
      notstop = notstop + 1
      if notstop > 100 then
        break
      end
    end
    if notstop < 100 then
      local finder_SavedTable = SaveLuaStuff_Serp.GetTableFromHelper("ObjectFinderSerp")
      if finder_SavedTable~=nil then
        ObjectFinderSerp.ObjectFinderCacheSerp = finder_SavedTable
      end
    end
  end)
end
g_saveloaded_events_serp = g_saveloaded_events_serp or {} -- global table where mods can add their functions to (define it if it does not exist yet)
if g_saveloaded_events_serp[ModID]==nil then
  g_saveloaded_events_serp[ModID] = OnSaveGameLoad
end
g_saveloaded_events_reset_serp = g_saveloaded_events_reset_serp or {} -- global table where mods can add their functions to (define it if it does not exist yet)
if g_saveloaded_events_reset_serp[ModID]==nil then
  g_saveloaded_events_reset_serp[ModID] = OnSaveGameLoad_RESET
end