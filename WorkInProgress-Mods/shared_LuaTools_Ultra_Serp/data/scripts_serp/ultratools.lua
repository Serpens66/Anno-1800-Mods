-- Only this script gets loaded via ActionExecuteScript on GameLoaded and it starts all other lua scripts
-- (ok, event_savegame_loaded.lua is called first via ActionExecuteScript and then starts this here via Unlock 1500004636)


local ModID = "shared_LuaTools_Ultra_Serp ultratools.lua" -- used for logging

if g_LuaScriptBlockers[ModID]==nil then
  
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    

    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end
    
    console.startScript("data/scripts_serp/check_peers.lua")
    console.startScript("data/scripts_serp/savetablestuff.lua")
    
    
    g_LTL_Serp.modlog("ultratools.lua registered",ModID)

    -- Lua Tools Ultra
    g_LTU_Serp = {
      SaveLuaStuff = g_SaveLuaStuff_Serp,
      PeersInfo = g_PeersInfo_Serp,
    }
    
    
    g_LTL_Serp.start_thread("g_OnGameLeave_serp",ModID,function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_ObjectFinderSerp = nil
        end
      end
    end)
    g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)
    
end