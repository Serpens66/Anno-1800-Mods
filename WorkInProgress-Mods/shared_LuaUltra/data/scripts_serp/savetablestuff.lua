  -- This uses Nameable (not CompanyName) from this SessionParticipant to save information into the savegame
   -- g_SaveLuaStuff_Serp.PIDToSaveData.PID
  -- Scenario3_Queen  GUID: 101523 , PID: 130

-- nur für den local peer etwas zu speichern sollte auch ohne ultra tools gehen (denn das brauchen wir ja nur zum Teilen der Infos zwischen den Peers)
 -- evtl. dazu noch was schreiben


local ModID = "shared_LuaTools_Ultra_Serp savetablestuff.lua" -- used for logging
    
if g_LuaScriptBlockers[ModID]==nil then
  
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true


    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end

    g_LTL_Serp.modlog("savetablestuff.lua registered",ModID)



    -- call to sync the Shared_Cache for every human peer
    -- called from within a thread
    local function t_SyncSharedCacheToEveryone(sModID,waitforfinish,skip_equalcheck)
      if ts.GameSetup.GetIsMultiPlayerGame() then
        while g_LTM_Serp==nil or g_PeersInfo_Serp==nil or g_PeersInfo_Serp.CoopFinished~=true do
          coroutine.yield()
        end
        local Cache = sModID and g_LTM_Serp.Shared_Cache[sModID] or g_LTM_Serp.Shared_Cache
        g_PeersInfo_Serp.t_ExecuteFnWithArgsForPeers("g_SaveLuaStuff_Serp._ExecutingSyncSharedCache",3000,waitforfinish,"Everyone",sModID,Cache,skip_equalcheck) -- waits for it to finish
      end
    end
    
    -- internal use
    local function _ExecutingSyncSharedCache(sModID,OtherCache,skip_equalcheck)
      if OtherCache~=nil and type(OtherCache)=="table" then
        local Cache = sModID and g_LTM_Serp.Shared_Cache[sModID] or g_LTM_Serp.Shared_Cache
        local Merged = g_LTL_Serp.MergeMapsDeep(Cache,OtherCache)
        if skip_equalcheck or not g_LTL_Serp.tables_equal(Cache,Merged) then
          Cache = Merged
        end
      end
    end

    -- we sync the cache between all peers first. this way we only need 1 Nameable helper object, isntead of up to 16.
    local function SyncAndSaveSharedCache()
      if not g_SaveLuaStuff_Serp._CurrentlySaving then
        g_LTL_Serp.start_thread("SyncAndSaveSharedCache",ModID,function()
          g_SaveLuaStuff_Serp._CurrentlySaving = true
          g_LTL_Serp.modlog("SyncAndSaveSharedCache called",ModID)
          while g_LTM_Serp==nil or g_PeersInfo_Serp==nil or g_PeersInfo_Serp.CoopFinished~=true do
            coroutine.yield()
          end
          g_SaveLuaStuff_Serp.t_SyncSharedCacheToEveryone(nil,true)
          g_LTL_Serp.waitForTimeDelta(6000) -- problem is depending on usage t_ExecuteFnWithArgsForPeers can take between 4 and endless seconds... but we assume its max 6 seconds. and if it takes longer, it will be saved next time
          if g_PeersInfo_Serp.AmIFirstActivePeer()==true then -- only first peer is allowed to save into Nameable. sync data before if you want to include data from other peers.
            local namestring = g_LTL_Serp.TableToHex(g_LTM_Serp.Shared_Cache)
            if type(namestring)=="string" then
              local sessionparticipants = g_ObjectFinderSerp.GetAllLoadedSessionsParticipants({g_SaveLuaStuff_Serp.PIDToSaveData.PID},"First") -- saving it in first-found is enough, because this will alawys be the same for everyone (assuming we all start in the same session).
              for SessionID,session_pids in pairs(sessionparticipants) do
                g_LTL_Serp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(session_pids[g_SaveLuaStuff_Serp.PIDToSaveData.PID].OID)..") Nameable Name("..tostring(namestring)..")]")
              end
              g_LTL_Serp.waitForTimeDelta(5000) -- wait at least 2-3 seconds for the Nameable to be synced for all Peers
            end
          end
          g_LTL_Serp.modlog("SyncAndSaveSharedCache done",ModID)
          g_SaveLuaStuff_Serp._CurrentlySaving = false
        end)
        return true
      end
      return false
    end
    
    
    local function t_LoadSharedCache()
      g_LTL_Serp.modlog("t_LoadSharedCache called",ModID)
      while g_LTM_Serp==nil or g_ObjectFinderSerp==nil or g_PeersInfo_Serp==nil or g_PeersInfo_Serp.CoopFinished~=true or g_LTM_Serp.Shared_Cache[g_ObjectFinderSerp.ModID]==nil do
        coroutine.yield()
      end
      -- this already updates the Cache SessionParticipants and also LoadedSessions
      local sessionparticipants = g_ObjectFinderSerp.GetAllLoadedSessionsParticipants({g_SaveLuaStuff_Serp.PIDToSaveData.PID},"First")
      local namestring = nil
      for SessionID,session_pids in pairs(sessionparticipants) do
        namestring = ts.GetGameObject(session_pids[g_SaveLuaStuff_Serp.PIDToSaveData.PID].OID).Nameable.Name -- if Name was changed with DoForSessionGameObject, then GetGameObject works to get the name regardless of player and session
      end
      local oldtext = ts.GetAssetData(11156).Text -- using OverwriteNameWithTextAsset in lighttools assets.xml for Nameable
      if namestring~=oldtext then -- only then we already saved info in it
        local status,mytable = pcall(g_LTL_Serp.HexToTable,namestring)
        if status~=false and type(mytable)=="table" then -- if fail, then in most cases just the default name, which is not a table and can not be converted
          g_LTM_Serp.Shared_Cache = g_LTL_Serp.MergeMapsDeep(mytable,g_LTM_Serp.Shared_Cache) -- merging this way, because Shared_Cache might have newer info
          -- g_LTL_Serp.modlog("t_LoadSharedCache done "..g_LTL_Serp.TableToFormattedString(g_LTM_Serp.Shared_Cache),ModID)
        end
      end
      g_LTL_Serp.modlog("t_LoadSharedCache done",ModID)
      g_SaveLuaStuff_Serp.LoadingDone = true -- set it true, even if there was an error, because we can not change it and data is lost
    end
    
    

    -- script only called on savegame load and then resetted
    g_SaveLuaStuff_Serp = {
      t_LoadSharedCache = t_LoadSharedCache,
      SyncAndSaveSharedCache = SyncAndSaveSharedCache,
      _CurrentlySaving = false, -- internal usage
      PIDToSaveData = {PID=130,GUID=101523},
      LoadingDone = false, -- you can use g_LTM_Serp.Shared_Cache as soon as this is true
      t_SyncSharedCacheToEveryone = t_SyncSharedCacheToEveryone,
      _ExecutingSyncSharedCache = _ExecutingSyncSharedCache, -- internal use!
    }
    
    
    -- called on GameLoad
    g_LTL_Serp.start_thread("LoadSharedCache",ModID,g_SaveLuaStuff_Serp.t_LoadSharedCache)
    
    
    
    
    g_LTL_Serp.start_thread("g_OnGameLeave_serp",ModID,function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_SaveLuaStuff_Serp = nil -- stop everything (might crash some currently running functions, but I think its ok)
        end
      end
    end)
    g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)
    
end
