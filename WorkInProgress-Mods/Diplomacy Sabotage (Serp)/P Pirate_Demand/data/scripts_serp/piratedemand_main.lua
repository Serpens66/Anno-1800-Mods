local easyQuests = {[17]=1500003824,[18]=1500003829}
local mediumQuests = {[17]=1500003825,[18]=1500003830}
local hardQuests = {[17]=1500003828,[18]=1500003831}

local ShipsGiftedMetaRes = {[17]=1500004555,[18]=1500004556}

local ModID = "PirateDemandMoney" -- used for logging

if g_LuaScriptBlockers[ModID]==nil then
        
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    

    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end

    g_LTL_Serp.modlog("piratedemand_main.lua registered",ModID)
    

    -- we wont include the shared mod with g_Im_CoopLeader_LuaCoopHelper (shared_LuaCoopLeader, because PopUp sucks), so most of the time it will be nil.
     -- but if the user has it enabled somehow, of course do not allow a value of false.
      -- It is not a big deal if the code is executed for each Coop-Teammate , since unlocking/relocking sth does not hurt to do it multiple times within a second.

    local function CheckShipStrength(Human_PID,Pirate_PID)
      if ts.Participants.GetGetCurrentParticipantID()==Human_PID and g_Im_CoopLeader_LuaCoopHelper ~= false then
        local PirateMilitaryShipScore = ts.Participants.GetParticipant(Pirate_PID).Highscore.HighscoreData.GetMilitaryShipScore()
        local HumanMilitaryShipScore = ts.Participants.Current.Highscore.HighscoreData.GetMilitaryShipScore()
        
        if PirateMilitaryShipScore > HumanMilitaryShipScore then
          ts.Unlock.SetUnlockNet(easyQuests[Pirate_PID])
          if PirateMilitaryShipScore > HumanMilitaryShipScore*1.5 then -- has more than 1.5 times of military ships than player, also enable medium quests
            ts.Unlock.SetUnlockNet(mediumQuests[Pirate_PID])
          else
            ts.Unlock.SetRelockNet(mediumQuests[Pirate_PID])
          end
          if PirateMilitaryShipScore > HumanMilitaryShipScore*2 then -- has more than 2 times of military ships than player, also enable hard quests
            ts.Unlock.SetUnlockNet(hardQuests[Pirate_PID])
          else
            ts.Unlock.SetRelockNet(hardQuests[Pirate_PID])
          end
        else -- player has more military ships than pirate
          if HumanMilitaryShipScore > PirateMilitaryShipScore*4 then -- if player has 4 times  as much ships than pirate, no demand quests anymore
            ts.Unlock.SetRelockNet(easyQuests[Pirate_PID])
          else
            ts.Unlock.SetUnlockNet(easyQuests[Pirate_PID])
          end
          ts.Unlock.SetRelockNet(mediumQuests[Pirate_PID])
          ts.Unlock.SetRelockNet(hardQuests[Pirate_PID])
        end
      end
    end
    
    -- Called whenever a ship changed owner via my g_LTM_Serp.t_ChangeOwnerOIDToPID function. Eg. also when gifting ships to pirates
      -- t_ChangeOwnerOIDToPID is already called within a thread and only for one peer, so _OnObjectOwnerChanged is too. 
    -- We want to use it for our Quest that pirate asks you to gift him a military ship with at least one item equipped, so this is filtered
    local function _OnObjectOwnerChanged(success,Local_PID,Owner,GUID,OID,To_PID,ignoreowner,notifyonfail,forbidpiratenewowner,with_middleman,CallerModID)
      -- if ship was gifted (gift diplo action is added by shared_EmbassyDiploActions_Serp)
      g_LTL_Serp.modlog("_OnObjectOwnerChanged piratedemand_main: "..g_LTL_Serp.argstotext(" , ",success,Local_PID,Owner,GUID,OID,To_PID,ignoreowner,notifyonfail,forbidpiratenewowner,with_middleman,CallerModID),ModID)
      if success and CallerModID=="shared_EmbassyDiploActions_Serp diploactions.lua" and Owner==Local_PID and Local_PID==ts.Participants.GetGetCurrentParticipantID() then
        -- if it was gifted to a pirate (regardless if piorate can keep it or it changes to neutral (forbidpiratenewowner))
        if To_PID==g_LTL_Serp.PIDs.Third_party_03_Pirate_Harlow.PID or To_PID==g_LTL_Serp.PIDs.Third_party_04_Pirate_LaFortune.PID then
          if g_LTL_Serp.HasAttacker(OID) then -- only count military ships
            -- local EquippedItemCount = g_LTL_Serp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(OID)..") ItemContainer Sockets Count]",true)
            -- if EquippedItemCount > 0 then -- only accept ships with at least one socketed item, does not matter what item
            local EquippedItems = g_LTL_Serp.GetVectorGuidsFromSessionObject("[MetaObjects SessionGameObject("..tostring(OID)..") ItemContainer Sockets Count]",{Guid="number"})
            if g_LTL_Serp.table_len(EquippedItems) then -- only accept ships with at least one socketed item, does not matter which one
              local itemsvalue = 0
              for k,item in pairs(EquippedItems) do
                itemsvalue = itemsvalue + (tonumber(ts.GetItemTradePrice(item["GUID"])) or 0)
              end
              -- local Price = g_LTL_Serp.GetGameObjectPath(OID,"Sellable.SellPrice.MoneyCost") or 5000 -- SellPrice is negative and has SellPriceFactor in it, with is 0.5 for most ships
              local Price = g_LTL_Serp.GetGameObjectPath(OID,"Sellable.CurrentParticipantBuyPrice.MoneyCost") or 5000
              local amount = math.max(g_LTL_Serp.myround( (Price+itemsvalue) / 10000),1)
              g_LTL_Serp.modlog("_OnObjectOwnerChanged piratedemand_main credit amount: "..tostring(amount),ModID)
              ts.Economy.MetaStorage.AddAmount(ShipsGiftedMetaRes[To_PID], amount) -- count it with help of a MetaProduct we can check easily in xml
            end
          end
        end
      end
    end
    
    g_LTL_Serp.start_thread("Register_EventOnObjectOwnerChanged",ModID,function()
      local notstop = 0
      while g_LTM_Serp==nil and notstop<1000 do
        coroutine.yield()
        notstop = notstop + 1
      end
      if g_LTM_Serp==nil then
        g_LTL_Serp.modlog("ERROR requires shared_LuaTools_Medium_Serp",ModID)
      else -- register the event
        g_LTM_Serp.EventOnObjectOwnerChanged[ModID] = _OnObjectOwnerChanged
      end
    end)
    
    

    -- ##########################################################################################
    -- ##########################################################################################


    g_PirateDemand_Serp = {
      CheckShipStrength = CheckShipStrength,
    }
    
    
    
    g_LTL_Serp.start_thread("g_OnGameLeave_serp",ModID,function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_PirateDemand_Serp = nil
        end
      end
    end)
    g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)
    
end