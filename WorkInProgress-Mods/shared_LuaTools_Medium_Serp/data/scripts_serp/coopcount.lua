  -- use variable
   -- g_CoopCountResSerp.LocalCount
  -- to get how many coop players are in the coop-team of the executing local players.
  -- it will be 1 for singleplayer games
   -- Important:
    -- at best start your script with help of shared_EventOnGameLoaded and load after this CoopCounter mod
     -- and before you use it, wait for g_CoopCountResSerp.Finished to be true (not nil/false and also not "running"), takes roughly 2 seconds

-- ########################################################################################

local ModID = "shared_LuaTools_Medium_Serp coopcount.lua"
if g_LTL_Serp==nil then
  console.startScript("data/scripts_serp/lighttools.lua")
end

if g_LuaScriptBlockers[ModID]==nil then
  
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    
    g_LTL_Serp.modlog("coopcount.lua registered",ModID)
    
    
    -- a function that returns how many coop human players are sharing the local player slot
    -- this is achieved by using the coop weakness: every local player, even in the same playerslot is executing the script once (with ActionExecuteScript)
    --  and the result is for most script actions synced. So if we credit 1 Ressource in the script, the Human0 will get 3 if it is shared between 3 human players
    -- make sure to execute this for all humans at once at the same time
    local function t_DoMakeNewCount()
      if ts.GameSetup.GetIsMultiPlayerGame() then     -- also execute it if we are alone in our coop team, because we want other Participants to know how much peers are active per participant
          coroutine.yield()
          local MyPID = ts.Participants.GetGetCurrentParticipantID()
          local oldamounts = {} -- checking old amount, so we dont need to set it back to 0 (which would take time to sync)
          for PID=0,3,1 do -- looping through all 4 Human PIDs
            oldamounts[PID] = ts.Participants.GetParticipant(PID).ProfileCounter.Stats.GetCounter(0,6,1500004521,3)
          end
          ts.Economy.MetaStorage.AddAmount(1500004521, 1) -- add 1
          g_LTL_Serp.waitForTimeDelta(2000) -- 100 is too short, 1000 enough for local, but use 2000 to be sure its also synced to all other players
          for PID=0,3,1 do -- looping through all 4 Human PIDs
            local newamount = ts.Participants.GetParticipant(PID).ProfileCounter.Stats.GetCounter(0,6,1500004521,3)
            g_CoopCountResSerp.CountPerPID[PID] = newamount - oldamounts[PID]
            g_CoopCountResSerp.TotalCount = g_CoopCountResSerp.TotalCount + g_CoopCountResSerp.CountPerPID[PID]
            g_CoopCountResSerp.IsPIDActive[PID] = g_CoopCountResSerp.CountPerPID[PID]>0
            if PID==MyPID then
              g_CoopCountResSerp.LocalCount = g_CoopCountResSerp.CountPerPID[PID]
              if newamount > 99990 then -- (100000 is the max allowed amount)
                ts.Economy.MetaStorage.AddAmount(1500004521, -100000) -- can not get negative
                g_LTL_Serp.waitForTimeDelta(1000)
              end
            end
          end
          g_CoopCountResSerp.Finished = true
      else -- singleplayer, no need to check
        g_CoopCountResSerp.LocalCount = 1
        g_CoopCountResSerp.TotalCount = 1
        for PID=0,3,1 do -- looping through all 4 Human PIDs
          if PID==ts.Participants.GetGetCurrentParticipantID() then
            g_CoopCountResSerp.CountPerPID[PID] = 1
            g_CoopCountResSerp.IsPIDActive[PID] = true
          else
            g_CoopCountResSerp.CountPerPID[PID] = 0
            g_CoopCountResSerp.IsPIDActive[PID] = false
          end
        end
        g_CoopCountResSerp.Finished = true
      end
    end
    
    local function MakeNewCount()
      g_LTL_Serp.modlog("MakeNewCount",ModID)
      g_LTM_Serp.AddToQueue("g_CoopCountResSerp_MakeNewCount",t_DoMakeNewCount) -- making sure to execute the calls one after the other, if called again, while previous was not finished (eg. when calling it on PlayerLeft multiple times in a row)
    end

    -- this resets automatically whenever this script is called (only on savegame load)
    g_CoopCountResSerp = {
      MakeNewCount = MakeNewCount,
      LocalCount = 0,
      TotalCount = 0,
      CountPerPID = {},
      IsPIDActive = {}, -- basically if CountPerPID is bigger 0, just a shortcut with more readable name
      Finished = nil, -- only if true, use any values from here
    }

    -- script is only called on savegame load
    g_LTL_Serp.start_thread("MakeNewCount",ModID,function()
      while g_LTM_Serp==nil do
        coroutine.yield()
      end
      MakeNewCount()
    end)
    
    system.start(function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_SaveLuaStuff_Serp = nil -- stop everything (might crash some currently running functions, but I think its ok)
        end
      end
    end,ModID.." g_OnGameLeave_serp")
    
    system.start(function()
      g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end,ModID.." g_LuaScriptBlockers")
    
end