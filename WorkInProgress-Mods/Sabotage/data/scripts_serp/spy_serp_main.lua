
local ModID = "spy_serp_main.lua" -- used for logging
local LandSpyGuid = 1500001173
local WaterSpyGuid = 1500001478
local PunishDelete_Unlock = 1500001894


if g_LuaScriptBlockers[ModID]==nil then
    
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    
    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end

    g_LTL_Serp.modlog("spy_serp_main.lua registered",ModID)
    
    
    -- #####################################################################################################
    
    local function OnObjectDeletionConfirmed(GUID)
      if GUID==LandSpyGuid or GUID==WaterSpyGuid then
        ts.Unlock.SetRelockNet(PunishDelete_Unlock) -- punish the player for deleting their spy unit
      end
    end
    g_LTL_Serp.EventOnObjectDeletionConfirmed[ModID] = OnObjectDeletionConfirmed
    
    
    -- #####################################################################################################
    
    
    -- g_Spy_Serp = {
      -- ObjectFinder = g_ObjectFinderSerp,
    -- }
    
    
    g_LTL_Serp.start_thread("g_OnGameLeave_serp",ModID,function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_Spy_Serp = nil
        end
      end
    end)
    g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)

    
end