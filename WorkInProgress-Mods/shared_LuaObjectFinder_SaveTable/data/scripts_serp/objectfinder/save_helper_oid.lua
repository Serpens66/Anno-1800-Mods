print("save_helper_oid.lua called")
if ObjectFinderSerp==nil then
  console.startScript("data/scripts_serp/objectfinder/objectfinder.lua")
end
ObjectFinderSerp.FindHelperOIDs(false) -- onlysavehelper=false, because we just spawned all helpers and need to find them all
system.start(function()
  local notstop = 0
  while true do
    if SaveLuaStuff_Serp.Helper_OID~=nil then
      break
    end
    coroutine.yield()
    notstop = notstop + 1
    if notstop > 100 then
      break
    end
  end
  if SaveLuaStuff_Serp.Helper_OID~=nil then
    SaveLuaStuff_Serp.Inited = true -- mark it as finished as soon as we found Helper_OID
  else
    print("did not find SaveLuaStuff_Serp.Helper_OID after spawning?!")
  end
end)
