local PID = 3

if g_LTL_Serp==nil then
  console.startScript("data/scripts_serp/lighttools.lua")
end

if g_Spy_Serp~=nil then
  g_LTL_Serp.ChangeGUIStateIf(PID,nil,{1500001547},"ObjectMenuKontor")
end
