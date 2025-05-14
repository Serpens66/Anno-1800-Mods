-- skript to credit the spy his spy items.
-- called on SessionEnter and when the item to water/land was fired (500sm after SpawnImpactObject detected)

-- We always search for the Spy in the current Session. If we do not find it, we do nothing and wait for the next call of this script.
-- If we find it, we check for his current Item Count. If he has 0, we will spawn items. Otherwise nothing happens


-- wenns um spy wassern/landen geht, gibts für einen kurzen zeitpunkt 2 spies, land und wasser.
 -- also am besten skript 1 sek danach aufrufen um items zu verteilen
 
-- Am besten vermutlich Spy nach wassern/landen so finden:
 -- Warten bis ein Besitzer-Peer (wieder) in der Session ist, wo der Spy ist und dann die Property Search nehmen.
  -- Alles andere ist zu ineffizient fürs ständige Spy-Suchen.
 -- Ist nicht schlimm, wenn Items dann erst spawnen, wenn Spieler in Session ist, weil er die eh nicht nutzen könnte, wenn er nicht in Session ist.
 
 -- zb. SessionEnter 1500005530 skript nutzen um zu erfahren, wann spieler session wechselt?
 
-- funzt im MP ohne desync
 
 
local PID = 0


 
local ModID = "Sabotage_Serp"

if g_LuaTools==nil then
  console.startScript("data/scripts_serp/luatools.lua")
end

g_LuaTools.modlog("spy_items_human"..tostring(PID).." called ",ModID)
  
if g_ObjectFinderSerp==nil or g_PeersInfo_Serp==nil then
  g_LuaTools.modlog("ERROR requires g_ObjectFinderSerp (shared_LuaUltimateHelpers_Serp)",ModID)
  error("ERROR requires g_ObjectFinderSerp (shared_LuaUltimateHelpers_Serp)")
end

if g_PeersInfo_Serp.CoopFinished and PID==g_PeersInfo_Serp.PID then
    
    local SessionGuid = session.getSessionGUID()
    local LandSpyGuid = 1500001173
    local WaterSpyGuid = 1500001478
    local TestItem = 1500001535 -- an item which the spy always gets spawned. So if it does not have it, we need to spawn items.
    local has_spy = ts.Participants.GetParticipant(g_PeersInfo_Serp.PID).ProfileCounter.Stats.GetCounter(0,0,LandSpyGuid,1,SessionGuid) or ts.Participants.GetParticipant(g_PeersInfo_Serp.PID).ProfileCounter.Stats.GetCounter(0,0,WaterSpyGuid,1,SessionGuid)
    if has_spy then -- cheap check if the player owns a spy in current session
        
        if g_PeersInfo_Serp.AmIFirstActiveCoopPeerInSession(SessionGuid) then -- only one coop peer should execute the item spawn
            
          local MetaRes_to_ItemGUID_Land = {}
          local MetaRes_to_ItemGUID_Water = {}
          local seamineproperty = 356

          local spy_OID = nil
          local sessioninfos = g_ObjectFinderSerp.GetCurrentSessionObjectsFromLocaleByProperty(seamineproperty)
          for OID,objinfo in pairs(sessioninfos.Objects) do
            if LandSpyGuid==objinfo["GUID"] or WaterSpyGuid==objinfo["GUID"] then -- every human only ever owns a single spy unit because of code/trigger limitations
              spy_OID = OID -- do not use spy_object = ts.GetGameObject(spy_OID) because Object gets broken after every use. So we neeed to call GetGameObject every time we want to use it!
              break
            end
          end
          
          if spy_OID~=nil and ts.GetGameObject(spy_OID).GUID~=0 then
            if not ts.GetGameObject(spy_OID).ItemContainer.GetItemAlreadyEquipped(TestItem) then -- only checks sockets, but storage was already checked in xml trigger who called this script
              
              
              ts.GetGameObject(spy_OID).ItemContainer.SetCheatItemInSlot(TestItem, 1)
              
              
              
              -- print("gave item")
              -- local resamount = 0
              -- for meta_res,itemguid in pairs(MetaRes_to_ItemGUID_Land) do
                -- resamount = ts.Economy.MetaStorage.GetStorageAmount(meta_res) or 0
                -- if resamount and resamount > 0 then 
                  -- ts.GetGameObject(spy_OID).ItemContainer.SetCheatItemInSlot(itemguid, resamount) -- automatically adds up the the next available slot
                -- end
              -- end
              
            end
          end
        end
    end

end