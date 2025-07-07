local PID = 0

-- spy post building
local AllowedBuildings = {1500001547}

local ModID = "Sabotage_Serp spybuyshare"

if g_LTL_Serp==nil then
  console.startScript("data/scripts_serp/lighttools.lua")
end

 -- was wenn coop spieler das gleiche objekt aber auf anderer Insel angeklickt haben?
 -- Exploit den wir nicht verhindern können...

if PID == ts.Participants.GetGetCurrentParticipantID() then
  g_LTL_Serp.start_thread("spybuyshare"..tostring(PID).."_random_",ModID,function()
    if g_LTL_Serp.table_contains_value(AllowedBuildings,ts.Selection.Object.GUID) then -- executing it for all peers who have this selected. 
      
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
        -- we want them to cost double the price, so reduce the amounts
        local BuyPrices = g_LTL_Serp.GetVectorGuidsFromSessionObject("[MetaObjects SessionGameObject("..tostring(OID)..") Area ShareCost("..tostring(sharetobuy)..") Costs Count]",{ProductGUID="number",Amount="number"}) -- this way we support mods adding more costs to buy/sell shares
        for i,Buyinfo in pairs(BuyPrices) do
          local InfluenceProduct = 1010190 -- we dont care for Influence costs
          local Price = Buyinfo.Amount
          local Product = Buyinfo.ProductGUID
          -- g_LTL_Serp.modlog("BuyPrice: Product:"..Product..", Price:"..Price,ModID)
          if Price~=nil and Price~=0 and Product~=nil and Product~=0 and Product~=InfluenceProduct then
            Price = g_LTL_Serp.myround( (-1) * (Price/peeramount) )
            ts.Economy.MetaStorage.AddAmount(Product, Price)
          end
        end
        ts.Area.CurrentSelectedArea.SetBuyShare(PID,sharetobuy) -- only executed once, even it done multiple times in the same tick
      end
    end
  end)
end