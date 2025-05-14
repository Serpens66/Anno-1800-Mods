

  -- This uses Nameable from this SessionParticipant to save information into the savegame
   -- g_ObjectFinderSerp.PIDToSaveData
  -- Scenario3_Queen  GUID: 101523 , PID: 129

-- requires g_ObjectFinderSerp from objectfinder.lua




local ModID = "shared_LuaUltimateHelpers_Serp savetablestuff.lua" -- used for logging
    
if g_LuaScriptBlockers[ModID]==nil then
  
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true


    if g_LuaTools==nil then
      console.startScript("data/scripts_serp/luatools.lua")
    end

    g_LuaTools.modlog("savetablestuff.lua registered",ModID)


    if g_StringTableConvertSerpNyk==nil then
      console.startScript("data/scripts_serp/savestuff_tableconvert.lua")
    end


    local function StartSaveThread()
      system.start(function()
        local task = table.remove(g_SaveLuaStuff_Serp.SaveQueue,1)
        while task~=nil do
          if type(task)=="table" and task.namestring~=nil then
            local namestring = task.namestring
            -- sessionparticipants[PID][CheckingSessionGuid] = {OID=OID,PID=PID,ObjectID=ObjectID,AreaID=AreaID,SessionID=SessionID}
            -- local sessionparticipants = g_ObjectFinderSerp.GetAllLoadedSessionsParticipants({g_ObjectFinderSerp.PIDToSaveData})  -- save it in every SessionParticipant GameObject, so it does not matter from which we load it (which means we can use ts.SessionParticipants on loading)
            
            local status,sessionparticipants = pcall(g_ObjectFinderSerp.GetAllLoadedSessionsParticipants,{g_ObjectFinderSerp.PIDToSaveData},"First") -- saving it in first-found is enough, because this will alawys be the same for everyone (assuming we all start in the same session).
            if status==false then
              g_LuaTools.modlog("ERROR : "..tostring(sessionparticipants),ModID)
              error(sessionparticipants) 
            end
            
            for SessionID,session_pids in pairs(sessionparticipants) do
              g_ObjectFinderSerp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(session_pids[g_ObjectFinderSerp.PIDToSaveData].OID)..") Nameable Name("..tostring(namestring)..")]")
            end
            g_LuaTools.waitForTimeDelta(5000) -- wait at least 2-3 seconds for the Nameable to be synced for all Peers
            
          end
          task = table.remove(g_SaveLuaStuff_Serp.SaveQueue,1)
        end
        g_SaveLuaStuff_Serp.LoopIsRunning = false
      end)
    end
    
    

    local function LoadTableFromNameable(sModID,fetchnameagain)
      if fetchnameagain or not next(g_SaveLuaStuff_Serp.SavedTable) or (sModID~=nil and g_SaveLuaStuff_Serp.SavedTable[sModID]==nil) then
        
        -- local namestring = ts.SessionParticipants.GetParticipant(g_ObjectFinderSerp.PIDToSaveData).Nameable.Name -- only works if we changed the name of all SessionParticipants in all Sessions
        -- this already updates the Cache SessionParticipants and also LoadedSessions
        local status,sessionparticipants = pcall(g_ObjectFinderSerp.GetAllLoadedSessionsParticipants,{g_ObjectFinderSerp.PIDToSaveData},"First")
        if status==false then
          g_LuaTools.modlog("ERROR : "..tostring(sessionparticipants),ModID)
          error(sessionparticipants) 
        end
        
        local namestring = nil
        for SessionID,session_pids in pairs(sessionparticipants) do
          namestring = ts.GetGameObject(session_pids[g_ObjectFinderSerp.PIDToSaveData].OID).Nameable.Name -- if Name was changed with DoForSessionGameObject, then GetGameObject works to get the name regardless of player and session
        end
        
        if type(namestring)=="string" then
          local mytable = g_StringTableConvertSerpNyk.HexToTable(namestring)
          if type(mytable)=="table" then
            g_SaveLuaStuff_Serp.SavedTable = g_LuaTools.deepcopy(mytable)
            if sModID~=nil then
              return mytable[sModID]
            else
              return mytable
            end
          end
        end
      else
        if sModID~=nil then
          return g_LuaTools.deepcopy(g_SaveLuaStuff_Serp.SavedTable[sModID])
        else
          return g_LuaTools.deepcopy(g_SaveLuaStuff_Serp.SavedTable)
        end
      end
    end

    -- only fully executed by AmIFirstActivePeer (before calling this, sync data between all players, so this is fine)
    local function SaveTableToNameable(sModID,mytable)
      
      g_SaveLuaStuff_Serp.SavedTable[sModID] = mytable
      
      system.start(function()
        
        while g_PeersInfo_Serp==nil or g_PeersInfo_Serp.CoopFinished~=true or g_CoopCountRes==nil or g_CoopCountRes.Finished~=true do
          coroutine.yield()
        end
        
        if g_PeersInfo_Serp.AmIFirstActivePeer()==true then -- only first peer is allowed to save into Nameable. sync data before if you want to include data from other peers.
          local namestring = g_StringTableConvertSerpNyk.TableToHex(g_SaveLuaStuff_Serp.SavedTable)
          if type(namestring)=="string" then
            table.insert(g_SaveLuaStuff_Serp.SaveQueue,{namestring=namestring})
            if not g_SaveLuaStuff_Serp.LoopIsRunning then
              g_SaveLuaStuff_Serp.LoopIsRunning = true
              g_SaveLuaStuff_Serp.StartSaveThread()
            end
          end
        end
        
      end,ModID.." SaveTableToNameable")
    end

    -- script only called on savegame load and then resetted
    g_SaveLuaStuff_Serp = {
      LoadTableFromNameable = LoadTableFromNameable,
      SaveTableToNameable = SaveTableToNameable,
      SavedTable = {},
      SaveQueue = {}, -- internal usage
      StartSaveThread = StartSaveThread, -- internal usage
      LoopIsRunning = false, -- internal usage
    }
    
    g_LuaTools.start_thread("g_OnGameLeave_serp",ModID,function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_SaveLuaStuff_Serp = nil -- stop everything (might crash some currently running functions, but I think its ok)
        end
      end
    end)
    g_LuaTools.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LuaTools.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)
    
end
