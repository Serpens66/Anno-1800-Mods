print("register_savestuff_ongameloaded.lua called (will register if not already done)")
if SaveLuaStuff_Serp==nil then
  console.startScript("data/scripts_serp/saveload/savetablestuff.lua")
end
if ObjectFinderSerp==nil then
  console.startScript("data/scripts_serp/objectfinder/objectfinder.lua")
end


-- PROBLEM:
  -- wenn wir n anderes savegame laden,
   -- und mods dann ObjectFinder/SaveStuff Funktionen in ihren Skripten aufrufen, die sie zb über sessionenter oderso, also sehr früh aufrufen nutzen,
 -- dann wurde unser OnSaveGameLoad code noch nicht durchgeführt und ObjectFinder usw haben noch veraltete zum vorherigen Savegame
  -- gehörige Infos gespeichert.
 -- Irgendwie müssen wir also signalisieren, ab wann ObjectFinder usw nutzbar ist,
  -- aber selbst wenn wir da eine Inited=true variable reinpoacken, bleibt sie ja true auch wenn wir n andres savegame laden,
   -- und kann frühstens false gesetzt werden in OnSaveGameLoad...
  -- Wir könnten in im shared mod gameloaded noch früher, ohne die 1 sek delay eine Reset-Funktion ausführen lassen,
   -- doch der delay ist ja da, damit andere mods ihre funktionen zufügen können. ohne delay können wir hier also keinen code zu so einer reset funktion
    -- zufügen, bevor sie ausgeführt wird.   
  -- ... wobei ... wenn das spiel neu gestartet wurde ist ja eh alles nil, hier brauchts also kein reset.
   -- nur innerhalb braucht es das und zu dem zeitpunkt hätten wir dann schon resetfunktionen zugefügt
  -- müsste man nur noch testen ob so eine reset funktion sogar vor einem AlwaysTrue trigger ausgeführt wird 
  

-- OnLuaGameLoaded
-- wait until helper object 1500004625 was spawned (on first time in this savegame) , then find the object itself and read out the name into our SaveLuaStuff_Serp.SavedTable, so other mods can use it
local ModID = "shared_LuaSaveTablestring_Serp"
local function OnSaveGameLoad_RESET()
  SaveLuaStuff_Serp.Helper_OID = nil -- make empty again, because it might be another savegame and we have to find it again
  SaveLuaStuff_Serp.SavedTable = {}
  SaveLuaStuff_Serp.Inited = false
end
local function OnSaveGameLoad()
  print("OnSaveGameLoad shared_LuaSaveTablestring_Serp")
  local SaveHelperOwner = 0 -- Human0 (can not use locals from outside this fn)
  if ts.Participants.GetParticipant(SaveHelperOwner).ProfileCounter.Stats.GetCounter(0,0,1500004625,3)>0 then -- only if it already exist, try to find and load from it. if it does not exist, it will call the finder fn by xml shortly after, so no need to do anything here then
    system.start(function()
      if SaveLuaStuff_Serp.Helper_OID==nil then 
        ObjectFinderSerp.FindHelperOIDs(true) -- onlysavehelper=true because its enough to only find the save helper object
      end
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
      SaveLuaStuff_Serp.GetTableFromHelper(nil,true) -- saved into SaveLuaStuff_Serp.SavedTable
      SaveLuaStuff_Serp.Inited = true
    end)
  end
end
g_saveloaded_events_serp = g_saveloaded_events_serp or {} -- global table where mods can add their functions to (define it if it does not exist yet)
if g_saveloaded_events_serp[ModID]==nil then
  g_saveloaded_events_serp[ModID] = OnSaveGameLoad
end
g_saveloaded_events_reset_serp = g_saveloaded_events_reset_serp or {} -- global table where mods can add their functions to (define it if it does not exist yet)
if g_saveloaded_events_reset_serp[ModID]==nil then
  g_saveloaded_events_reset_serp[ModID] = OnSaveGameLoad_RESET
end