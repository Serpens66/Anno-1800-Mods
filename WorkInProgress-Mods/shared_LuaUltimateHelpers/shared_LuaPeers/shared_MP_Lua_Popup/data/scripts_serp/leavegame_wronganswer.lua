-- No problem that this may be executed multiple times for the same player. We will leave the game anyways
ts.Conditions.RegisterTriggerForCurrentParticipant(1500005529) -- show a notification that you will leave the game shortly (does not matter that its executed for every coop)
if g_LuaTools==nil then
  console.startScript("data/scripts_serp/luatools.lua")
end
system.start(function()
  g_LuaTools.waitForTimeDelta(10000)
  GameManager.OnlineManager.leaveSession()
end,"leavegame_wronganswer.lua")