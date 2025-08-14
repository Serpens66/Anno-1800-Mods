
local ModID = "Sabotage_Serp" -- used for logging
local LandSpyGuid = 1500001173
local WaterSpyGuid = 1500001478
local PunishDelete_Unlock = 1500001894
local AllowedBuildings_BuyShareForDoublePrice = {1500001547}
local CanNotAffordNotification = 1500005610 -- can not afford this ship - maybe make a new notification text, but we have to translate in all languages...


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
    
    
     -- was wenn coop spieler das gleiche objekt aber auf anderer Insel angeklickt haben?
      -- Exploit den wir nicht verhindern können...
      -- braucht nur lua light tools (nicht medium/ultra)
    local function BuyShareForDoublePrice(PID)
      if PID == ts.Participants.GetGetCurrentParticipantID() then
        g_LTL_Serp.start_thread("spybuyshare"..tostring(PID).."_random_",ModID,function()
          if g_LTL_Serp.table_contains_value(AllowedBuildings_BuyShareForDoublePrice,ts.Selection.Object.GUID) then -- executing it for all peers who have this selected. 
            
            local userdata = session.getSelectedFactory()
            local OID = g_LTL_Serp.get_OID(userdata)
            local peerints = g_LTL_Serp.GetCoopPeersAtMarker(g_LTL_Serp.UITypeState.Shipyard,OID) -- get all other coop peers who also have this building selected (and therefore also executing this code)
            local peeramount = g_LTL_Serp.table_len(peerints) + 1 -- the number of times this code will be executed this tick (so divide numbers by this amount)
            local AreaOwnerName = ts.Area.CurrentSelectedArea.OwnerName
            local PIDName = ts.Participants.GetParticipantName(PID)
            local prefer = "islandowner" -- foreign island, then we want to buy shares from the island owner and if there are none, then from anyone else
            local sharetobuy = false
            if ts.Area.CurrentSelectedArea.Owner == PID then -- if we are island owner, we want to buy shares owned by anyone else
              prefer = "other"
            end
            local i = 0
            local ShareOwnerName = ts.Area.CurrentSelectedArea.GetOwnerProfile(i)
            while ShareOwnerName~="" and sharetobuy==false do -- empty string means no owner (queen can be owner and has name)
              if ShareOwnerName==AreaOwnerName then
                if prefer=="islandowner" then
                  sharetobuy = i
                end
              elseif ShareOwnerName~=PIDName then -- not AreaOwnerName and not ourself
                if prefer=="other" then
                  sharetobuy = i
                end
              end
              i = i + 1
              ShareOwnerName = ts.Area.CurrentSelectedArea.GetOwnerProfile(i)
            end
            if not bought and prefer=="islandowner" then -- if no share from islandowner is left then any other
              i = 0
              ShareOwnerName = ts.Area.CurrentSelectedArea.GetOwnerProfile(i)
              while ShareOwnerName~="" and sharetobuy==false do
                if ShareOwnerName~=PIDName then
                  sharetobuy = i
                end
                i = i + 1
                ShareOwnerName = ts.Area.CurrentSelectedArea.GetOwnerProfile(i)
              end
            end
            if sharetobuy~=false then
              local finalprices = {}
              local canafford = true
              -- we want them to cost double the price, so reduce the amounts
              local BuyPrices = g_LTL_Serp.GetVectorGuidsFromSessionObject("[MetaObjects SessionGameObject("..tostring(OID)..") Area ShareCost("..tostring(sharetobuy)..") Costs Count]",{ProductGUID="number",Amount="number"}) -- this way we support mods adding more costs to buy/sell shares
              for i,Buyinfo in pairs(BuyPrices) do
                local InfluenceProduct = 1010190 -- we dont care for Influence costs
                local Price = Buyinfo.Amount
                local Product = Buyinfo.ProductGUID
                -- g_LTL_Serp.modlog("BuyPrice: Product:"..Product..", Price:"..Price,ModID)
                if Price~=nil and Price~=0 and Product~=nil and Product~=0 and Product~=InfluenceProduct then
                  Price = g_LTL_Serp.myround( (-1) * (Price/peeramount) ) -- negative amount!
                  -- g_LTL_Serp.modlog("BuyShareForDoublePrice: "..g_LTL_Serp.argstotext(nil,ts.Economy.MetaStorage.GetStorageAmount(Product),Product,Price*2),ModID)
                  if ts.Economy.MetaStorage.GetStorageAmount(Product) < Price * 2 * -1 then -- check th double amount, because SetBuyShare will substract it again!
                    canafford = false
                    break
                  end
                  finalprices[Product] = Price
                end
              end
              if canafford then
                for Product,Price in pairs(finalprices) do
                  ts.Economy.MetaStorage.AddAmount(Product, Price)
                end
                ts.Area.CurrentSelectedArea.SetBuyShare(PID,sharetobuy) -- only executed once, even it done multiple times in the same tick
              else
                ts.Unlock.SetRelockNet(CanNotAffordNotification) -- can not afford notification
              end
            end
          end
        end)
      end
    end
    -- #####################################################################################################
    
    
    g_Spy_Serp = {
      BuyShareForDoublePrice = BuyShareForDoublePrice,
    }
    
    
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