-- No problem that this may be executed multiple times for the same player. We will leave the game anyways
ts.Conditions.RegisterTriggerForCurrentParticipant(1500005529) -- show a notification that you will leave the game shortly (does not matter that its executed for every coop)
if g_LTL_Serp==nil then
  console.startScript("data/scripts_serp/lighttools.lua")
end
system.start(function()
  g_LTL_Serp.waitForTimeDelta(10000)
  GameManager.OnlineManager.leaveSession()
end,"leavegame_wronganswer.lua")