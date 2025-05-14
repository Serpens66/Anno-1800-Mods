if g_LuaTools==nil then
  console.startScript("data/scripts_serp/luatools.lua")
end
local ModID = "shared_LuaUltimateHelpers_Serp ticksavecache.lua"
if g_ObjectFinderSerp~=nil then
  g_LuaTools.start_thread("SaveCache",ModID,g_ObjectFinderSerp.t_SaveCache) -- the function itself makes sure only the correct peer finally executes the save
end