if g_LTL_Serp==nil then
  console.startScript("data/scripts_serp/lighttools.lua")
end

g_LTL_Serp.start_thread("executeforeveryone.lua","shared_LuaTools_Medium_Serp",function()
  while g_LTM_Serp==nil do
    coroutine.yield()
  end
  g_LTM_Serp.CallGlobalFnBlocked("g_LTM_Serp._DoExectionForEveryone",nil,3000)
end)