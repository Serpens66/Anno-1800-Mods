if g_LTL_Serp==nil then
  console.startScript("data/scripts_serp/lighttools.lua")
end
local ModID = "shared_LuaUltimateHelpers_Serp ticksavecache.lua"
if g_SaveLuaStuff_Serp~=nil then
  g_LTL_Serp.start_thread("SaveCache",ModID,g_SaveLuaStuff_Serp.SyncAndSaveSharedCache) -- the function itself makes sure only the correct peer finally executes the save
end