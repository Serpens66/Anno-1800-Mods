local PID = 2
local GUIDs = {1500001051,1500001054}

if g_LTL_Serp==nil then
  console.startScript("data/scripts_serp/lighttools.lua")
end

for i,GUID in ipairs(GUIDs) do
  g_LTL_Serp.DestroyGUIDByLocal(PID,GUID)
end