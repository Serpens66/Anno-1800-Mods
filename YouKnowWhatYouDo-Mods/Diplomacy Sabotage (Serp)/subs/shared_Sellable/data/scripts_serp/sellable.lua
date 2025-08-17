
local ModID = "shared_Sellable_Serp"

if g_LuaScriptBlockers[ModID]==nil then
    
    
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    

    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end
    

    g_LTL_Serp.modlog("sellable.lua registered",ModID)
    
-- #####################################################################################################

  -- also supports if new Meta Ressources are added to Sellable/Baseprice

  -- you can overwrte this function (same for BuySelectedAllowed) in your mod like this to add more "false" conditions
  -- local Orig_SellSelectedAllowed = g_sellable_serp.SellSelectedAllowed
  -- g_sellable_serp.SellSelectedAllowed = function(PID,Owner,buyerPID,Name,ignorecanbesold,...)
    -- local ret = Orig_SellSelectedAllowed(PID,Owner,buyerPID,Name,ignorecanbesold,...) -- execute original first (so it locks everything first)
    -- if ret==true then
      -- ret = IsMyCondition()
    -- end
    -- return ret
  -- end
  local function SellSelectedAllowed(PID,Owner,buyerPID,Name,ignorecanbesold)
    if not string.find(Name,"NOSELL") and Owner==PID and Owner~=buyerPID and not g_LTL_Serp.IsHuman(buyerPID) and (ignorecanbesold or ts.Selection.Object.Sellable.CanBeSoldToTrader) then
      return true
    end
    return false
  end
  -- Only call it for the one coop peer which should sell object he has currently selected!
  -- Its ment to sell objects from human to AI (for other way round use t_SimpleBuySelected), so it does not check if anyone has enough money, since AI does not care for money
  -- pricefactor multiplies CurrentParticipantBuyPrice MoneyCost (usually double of the SellPrice)
    -- To also display the new price as text ingame, set the name of the ship as the new price (and display that) und set pricefactor=true
  -- BuyNet only works if participants have at least TradeRights
  
  local function t_SimpleSellSelected(buyerPID,usepricefactor,ignorecanbesold)
    local PID = ts.Participants.GetGetCurrentParticipantID()
    local Owner = ts.Selection.Object.Owner
    local Name = ts.Selection.Object.Nameable.Name
    g_LTL_Serp.modlog("t_SimpleSellSelected: PID:"..tostring(PID)..", buyerPID:"..tostring(buyerPID)..", ignorecanbesold:"..tostring(ignorecanbesold)..", usepricefactor:"..tostring(usepricefactor),ModID)
    if g_sellable_serp.SellSelectedAllowed(PID,Owner,buyerPID,Name,ignorecanbesold) then
      local OID = g_LTL_Serp.get_OID(session.getSelectedFactory())
      local pricefactor
      if usepricefactor then
        pricefactor = ts.Economy.MetaStorage.GetStorageAmount(g_sellable_serp.FactorMetaProduct) / 100
      end
      if pricefactor~=nil and pricefactor~=1 then -- credit more money/reduce more money
        local InfluenceProduct = 1010190 -- we dont care for Influence costs
        local SellPrices = g_LTL_Serp.GetVectorGuidsFromSessionObject("[MetaObjects SessionGameObject("..tostring(OID)..") Sellable SellPrice Costs Count]",{ProductGUID="number",Amount="number"})
        for i,Sellinfo in pairs(SellPrices) do
          local Price = Sellinfo.Amount
          local Product = Sellinfo.ProductGUID
          -- g_LTL_Serp.modlog("SellPrice: Product:"..Product..", Price:"..Price,ModID)
          if Price~=nil and Price~=0 and Product~=nil and Product~=0 and Product~=InfluenceProduct then
            local changeamount = g_LTL_Serp.myround((1 - pricefactor) * Price) -- SellPrice is negative
            if changeamount~=0 then
              ts.Economy.MetaStorage.AddAmount(Product, changeamount)
            end
          end
        end
      end
      ts.Selection.Object.Sellable.BuyNet(buyerPID)
    else
      ts.Unlock.SetRelockNet(1500005611) -- send sidenotification  <GUID>17511</GUID> <Text>Dieser Schiffstyp kann nicht verkauft werden.</Text>
    end
  end
  
  
  local function BuySelectedAllowed(PID,Owner,ignorecanbesold,onlyfromownerPID)
    if Owner~=PID and (ignorecanbesold or ts.Selection.Object.Sellable.CanBeSoldToTrader) and (onlyfromownerPID==nil or Owner==onlyfromownerPID) then
      return true
    end
    return false
  end
  -- Only call it for the one coop peer which should buy object he has currently selected!
  -- pricefactor multiplies CurrentParticipantBuyPrice MoneyCost (usually double of the SellPrice)
    -- To also display the new price as text ingame, set the name of the ship as the new price (and display that) und set pricefactor=true
  -- currently only supports money costs
  -- BuyNet only works if participants have at least TradeRights
  local function t_SimpleBuySelected(pricefactor,ignorecanbesold,allownegative,onlyfromownerPID)
    local PID = ts.Participants.GetGetCurrentParticipantID()
    local Owner = ts.Selection.Object.Owner
    g_LTL_Serp.modlog("t_SimpleBuySelected: PID:"..tostring(PID)..", pricefactor:"..tostring(pricefactor)..", ignorecanbesold:"..tostring(ignorecanbesold)..", allownegative:"..tostring(allownegative),ModID)
    if g_sellable_serp.BuySelectedAllowed(PID,Owner,ignorecanbesold,onlyfromownerPID) then
      local OID = g_LTL_Serp.get_OID(session.getSelectedFactory())
      if type(pricefactor)=="boolean" then -- use Name , (not using string "Name" as pricefactor because not sure how to forward this with t_FnViaTextEmbed)
        local restname,namevalue = g_LTL_Serp.SplitNumberFromName(ts.Selection.Object.Nameable.Name)
        if restname==nil or restname=="" then
          restname = g_LTL_Serp.weighted_random_choices(g_LTL_Serp.ShipNameGUIDs, 1)[1] -- get a random name
          restname = ts.GetAssetData(restname).Text
        end
        if pricefactor==true then -- if true we want to pay the sum in the name (moneycost)
          pricefactor = 1
          if namevalue~=nil then
            pricefactor = namevalue / ts.Selection.Object.Sellable.CurrentParticipantBuyPrice.MoneyCost
          end
        else -- if false, the name is the pricefactor
          pricefactor = namevalue or 1
        end
        ts.Selection.Object.Nameable.SetName(tostring(restname))
      elseif pricefactor==g_sellable_serp.FactorMetaProduct then
        pricefactor = ts.Economy.MetaStorage.GetStorageAmount(g_sellable_serp.FactorMetaProduct) / 100
      end
      
      local BuyPrices = g_LTL_Serp.GetVectorGuidsFromSessionObject("[MetaObjects SessionGameObject("..tostring(OID)..") Sellable CurrentParticipantBuyPrice Costs Count]",{ProductGUID="number",Amount="number"}) -- this way we support mods adding more costs to buy/sell ships
      local InfluenceProduct = 1010190 -- we dont care for Influence costs
      if pricefactor~=nil and pricefactor~=1 then -- credit money back/reduce more money, do this first, because it might already change if we can afford the object
        for i,Buyinfo in pairs(BuyPrices) do -- using this instead of MoneyCost, because in theory modders could add more costs than just money
          local Price = Buyinfo.Amount
          local Product = Buyinfo.ProductGUID
          -- g_LTL_Serp.modlog("BuyPrice: Product:"..Product..", Price:"..Price,ModID)
          if Price~=nil and Price~=0 and Product~=nil and Product~=0 and Product~=InfluenceProduct then
            local changeamount = g_LTL_Serp.myround((1 - pricefactor) * Price)
            if changeamount~=0 then
              ts.Economy.MetaStorage.AddAmount(Product, changeamount)
            end
          end
        end
        if not ts.Selection.Object.Sellable.AffordableByCurrentParticipant then
          g_LTL_Serp.waitForTimeDelta(1000) -- wait for changeamount to be credited
        end
      end
      local loan = false
      if not ts.Selection.Object.Sellable.AffordableByCurrentParticipant then
        if allownegative then
          loan = true
          coroutine.yield()
          for i,Buyinfo in pairs(BuyPrices) do -- using this instead of MoneyCost, because in theory modders could add more costs than just money
            local Price = Buyinfo.Amount
            local Product = Buyinfo.ProductGUID
            if Price~=nil and Price~=0 and Product~=nil and Product~=0 and Product~=InfluenceProduct then
              ts.Economy.MetaStorage.AddAmount(Product, Price * 2)
            end
          end
          g_LTL_Serp.waitForTimeDelta(1000) -- wait for loan to be credited
        end
      end
      if ts.Selection.Object.Sellable.AffordableByCurrentParticipant then
        ts.Selection.Object.Sellable.BuyNet(PID) -- owner and PID need traderights for this to do anything and PID needs to have enough money (and possibly also influence)
      else
        ts.Unlock.SetRelockNet(1500005610) -- send sidenotification <GUID>11013</GUID> <Text>Sie können sich dieses Schiff nicht leisten.</Text>
      end
      if loan then
        coroutine.yield()
        for i,Buyinfo in pairs(BuyPrices) do -- using this instead of MoneyCost, because in theory modders could add more costs than just money
          local Price = Buyinfo.Amount
          local Product = Buyinfo.ProductGUID
          if Price~=nil and Price~=0 and Product~=nil and Product~=0 and Product~=InfluenceProduct then
            ts.Economy.MetaStorage.AddAmount(Product, -Price * 2)
          end
        end
      end
    end
  end


-- #####################################################################################################

    
  -- Lua Tools Medium
  g_sellable_serp = {
    SellSelectedAllowed = SellSelectedAllowed,
    t_SimpleSellSelected = t_SimpleSellSelected,
    BuySelectedAllowed = BuySelectedAllowed,
    t_SimpleBuySelected = t_SimpleBuySelected,
    FactorMetaProduct = 1500005608, -- for multiplying the price
  }
  
  
  g_LTL_Serp.start_thread("g_OnGameLeave_serp",ModID,function()
    while g_OnGameLeave_serp==nil do
      coroutine.yield()
    end
    if g_OnGameLeave_serp[ModID]==nil then
      g_OnGameLeave_serp[ModID] = function()
        g_sellable_serp = nil
      end
    end
  end)
  g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
    g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
    g_LuaScriptBlockers[ModID] = nil
  end)

end