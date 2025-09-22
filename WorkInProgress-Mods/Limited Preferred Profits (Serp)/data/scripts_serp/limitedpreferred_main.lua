local Preferred_AmountLimit = 60 -- the max amount where this script will give extra money
local Preferred_IntervallReduce = 60000 -- in ms, every x time the current amount is reduced by one to achieve a rolling max limit. time is hardcoded in text file currently, so also change there if you change it here
local Preferred_ProfitMultiplier = 2 -- multiply the money you got for the preferred goods with this



local TradeProductBought = 1
local TradeProductSold = 2
local PassiveTradeBalance = 35 -- is most likely the sum from earnings and payings from passive trading and can only be checked globally for everything at once
local TradeMoneyEarned = 76
local TradeMoneyPayed = 77

-- ne anzeige bei den preferred goods im infotip wird am schwierigsten.
 -- geht denke ich nur wenn wir jedem preferred good hardcoded ein anzeoge-produkt zuordnen, was bedeutet dass wir keine
  -- goods von anderen mods supporten können
-- Ansonsten haben wir bei der Anzeige der goods ja die infos:
 -- welche Insel, welcher Trader und welches Good zur Verfügung.
  -- also vllt kann ich ja auch infos in der Insel oder dem Trader zwischenspeichern und anzeigen?
  -- Inselnamen ändern geht nicht per lua, also bleibt nur Name vom Trader ändern.
 -- aber wir müssten den Namen live ändern während spieler über untersch. goods hovered und dabei können wir kein lua
  -- auslösen um ihn zu ändern, also geht nicht wirklich


local ModID = "LimitedPreferredProfit_Serp" -- used for logging

if g_LuaScriptBlockers[ModID]==nil then
        
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    

    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end

    g_LTL_Serp.modlog("limitedpreferred_main.lua registered",ModID)
    

    -- ###############################

    local function _UpdateNames(PID)
      if PID==nil then
        PID = ts.Participants.GetGetCurrentParticipantID()
      end
      if PID == ts.Participants.GetGetCurrentParticipantID() then
        for TraderEnum, infos in pairs(g_LimitedPrefered_Serp.TraderInfos) do
          g_LimitedPrefered_Serp._UpdateName(PID,TraderEnum)
        end
      end
    end

    -- we add Nameable to the traders and use it to write information in it how much you already sold to them
     -- because we want to limit it to a max amount per time, we need to display how much is reached
     -- and I found no other working way than using a name, to make it work for all preferred goods, even if added by other mods
    -- Can only update Text for Traders in our current session. But _Reduceamout function also calls it frequently
     -- and we check with Trigger if Trader is selected, to update names
    local function _UpdateName(PID,TraderEnum)
      if PID==nil then
        PID = ts.Participants.GetGetCurrentParticipantID()
      end
      if PID == ts.Participants.GetGetCurrentParticipantID() then
        local infos = g_LimitedPrefered_Serp.TraderInfos[TraderEnum]
        local TraderPID = g_LTL_Serp.PIDs[TraderEnum].PID
        if ts.SessionParticipants.GetParticipant(TraderPID).GUID~=0 then -- only works if it exists in current session
          local productstring = ""
          for Product,tradeinfos in pairs(infos.PGoods) do
            local text = ts.GetAssetData(Product).Text
            local icon = ts.GetAssetData(Product).Icon
            icon = '<img height="24" width="24" src="'..tostring(icon)..'"/>'
            -- local timelimit = " / "..tostring(Preferred_AmountLimit*Preferred_IntervallReduce/1000/60).." min"
            local timelimit = "" -- better hardcode to text as kind of header, so change it there if you change values here
            local amountstring = "<b>"..tostring(tradeinfos.BoughtFromLocale).."/"..tostring(Preferred_AmountLimit).." t</b>"
            productstring = productstring..tostring(icon).." "..tostring(text)..": "..tostring(amountstring)..""..tostring(timelimit).."\n"
          end
          local moneyicon = ts.GetAssetData(1010017).Icon
          local language = g_LTL_Serp.Languages[ts.Options.TextLanguage]
          local seperator = "."
          if language=="English" or language=="Chinese" or language=="Taiwanese" or language=="Japanese" or language=="Korean" then
            seperator = " " -- "," is not allowed in Name unfortunately, so we will divide it with space
          end
          local profit = g_LTL_Serp.comma_value(g_LimitedPrefered_Serp.HumanTrades.ExtraProfit,seperator)
          profit = '+ <img height="24" width="24" src="'..tostring(moneyicon)..'"/> '..tostring(profit)
          productstring = productstring..tostring(profit)
          -- productstring = g_LTL_Serp.replace_chars_for_Name(productstring) -- dont use it, it also removes valid formatting signs...
          ts.SessionParticipants.GetParticipant(TraderPID).Nameable.SetName(productstring)
          
          g_LTL_Serp.start_thread("CheckIfTextUpdateWorked"..tostring(TraderPID),ModID,function(TraderPID,productstring)
            g_LTL_Serp.waitForTimeDelta(300)
            if ts.SessionParticipants.GetParticipant(TraderPID).Nameable.Name~=productstring then
              g_LTL_Serp.modlog("_UpdateName: Failed to update the text for: "..tostring(TraderEnum).."\nName: "..tostring(ts.SessionParticipants.GetParticipant(TraderPID).Nameable.Name).."\nproductstring: "..tostring(productstring),ModID)
            end
          end,TraderPID,productstring)
        else
          g_LTL_Serp.modlog("_UpdateName: Can not update text for "..tostring(TraderEnum).." because he does not exist in current session (normally fine, except he does exist) "..tostring(session.getSessionGUID()),ModID)
        end
      end
    end
    
    
    local function _OnProfitMade(PID)
      if PID == ts.Participants.GetGetCurrentParticipantID() then
        
        local status,err = xpcall(g_LimitedPrefered_Serp._UpdateTrades,g_LTL_Serp.log_error,PID,true)
        if status==false then
          g_LTL_Serp.modlog("ERROR in _OnProfitMade while calling _UpdateTrades: "..tostring(err),_ModID)
          error(err)
        end

      end
    end
    
    local function _UpdateTrades(PID,compare_new_old)
      if PID==nil then
        PID = ts.Participants.GetGetCurrentParticipantID()
      end
      breaken = false
      for TraderEnum, infos in pairs(g_LimitedPrefered_Serp.TraderInfos) do
        local TraderPID = g_LTL_Serp.PIDs[TraderEnum].PID
        local Session = infos.Session
        for Product,tradeinfos in pairs(infos.PGoods) do
          
          local Bought = ts.Participants.GetParticipant(TraderPID).ProfileCounter.Stats.GetCounter(0,TradeProductBought,Product,1,Session)
          local Payed = ts.Participants.GetParticipant(TraderPID).ProfileCounter.Stats.GetCounter(0,TradeMoneyPayed,Product,1,Session)
          tradeinfos.Bought = Bought
          tradeinfos.Payed = Payed
          
          local Sold = ts.Participants.GetParticipant(PID).ProfileCounter.Stats.GetCounter(0,TradeProductSold,Product,1,Session)
          local Earned = ts.Participants.GetParticipant(PID).ProfileCounter.Stats.GetCounter(0,TradeMoneyEarned,Product,1,Session)
          local HumanTradePr = g_LimitedPrefered_Serp.HumanTrades[TraderEnum][Product] -- shortcut
          HumanTradePr.Sold = Sold
          HumanTradePr.Earned = Earned
          
          if compare_new_old then
            selldiff = HumanTradePr.Sold - HumanTradePr.old_Sold
            if selldiff > 0 then
              if tradeinfos.Bought - tradeinfos.old_Bought >= selldiff then
                g_LTL_Serp.modlog("Human sold "..tostring(selldiff).."t of Product GUID "..tostring(Product).." to '"..TraderEnum.."' ",ModID)
                local add = math.min((Preferred_AmountLimit-tradeinfos.BoughtFromLocale),selldiff)
                tradeinfos.BoughtFromLocale = tradeinfos.BoughtFromLocale + add
                local gain = math.min(HumanTradePr.Earned-HumanTradePr.old_Earned,tradeinfos.Payed-tradeinfos.old_Payed)
                if add~=selldiff then -- only up to max Preferred_AmountLimit
                  gain = gain / selldiff * add
                end
                gain = gain * (Preferred_ProfitMultiplier-1)
                if g_CoopCountResSerp~=nil and g_CoopCountResSerp.Finished==true then
                  gain = gain / math.max(1,g_CoopCountResSerp.LocalCount)
                end
                gain = math.tointeger(gain)
                ts.Economy.MetaStorage.AddAmount(1010017, gain)
                g_LimitedPrefered_Serp.HumanTrades.ExtraProfit = g_LimitedPrefered_Serp.HumanTrades.ExtraProfit + gain
                g_LimitedPrefered_Serp._UpdateName(PID,TraderEnum)
                breaken = true
                break
              end
            end
          end
        end
        if breaken then
          break
        end
      end
      g_LimitedPrefered_Serp._SetNewOld()
      if g_LTM_Serp~=nil and g_LTM_Serp.Shared_Cache~=nil and g_LTU_Serp~=nil then
        g_LTM_Serp.Shared_Cache[ModID] = {HumanTrades=g_LimitedPrefered_Serp.HumanTrades,TraderInfos=g_LimitedPrefered_Serp.TraderInfos}
        -- g_LTL_Serp.modlog(g_LTL_Serp.TableToFormattedString(g_LTM_Serp.Shared_Cache.LimitedPreferredProfit_Serp),"LimitedPreferredProfit_Serp")
      end
    end
    
    local function _SetNewOld()
      for TraderEnum, infos in pairs(g_LimitedPrefered_Serp.TraderInfos) do
        for Product,tradeinfos in pairs(infos.PGoods) do
          tradeinfos.old_Bought = tradeinfos.Bought
          tradeinfos.old_Payed = tradeinfos.Payed
          g_LimitedPrefered_Serp.HumanTrades[TraderEnum][Product].old_Payed = g_LimitedPrefered_Serp.HumanTrades[TraderEnum][Product].Payed
          g_LimitedPrefered_Serp.HumanTrades[TraderEnum][Product].old_Sold = g_LimitedPrefered_Serp.HumanTrades[TraderEnum][Product].Sold
        end
      end
    end
    
    
    -- We can only check Preferred Goods when we are within a TradeOffer/on an island,
     -- so we saved preferred Goods from Traders instead in a helper asset in ItemEffectTargets, so we are able to loop 
     -- over them in lua (yes we can not loop over eg. an AssetPool in lua...)
    local function _t_Init()
      for TraderEnum, infos in pairs(g_LimitedPrefered_Serp.TraderInfos) do
        local TraderPID = g_LTL_Serp.PIDs[TraderEnum].PID
        local Session = infos.Session
        if g_LimitedPrefered_Serp.HumanTrades[TraderEnum]==nil then
          g_LimitedPrefered_Serp.HumanTrades[TraderEnum] = {}
        end
        local _PreferredGoods = g_LTL_Serp.GetVectorGuidsFromSessionObject("[ToolOneHelper ItemOrBuffEffectTargets("..tostring(infos.HelpAsset)..") Count]",{[""]="integer"})
        for _,PGinfo in pairs(_PreferredGoods) do
          local Product = PGinfo[""] -- ItemOrBuffEffectTargets directly returns a list of integers, so we used empty string as InfoToInclude
          infos.PGoods[Product] = {old_Bought=0,old_Payed=0,Bought=0,Payed=0,BoughtFromLocale=0}
          g_LimitedPrefered_Serp.HumanTrades[TraderEnum][Product] = {old_Earned=0,old_Sold=0,Earned=0,Sold=0}
        end
      end
      
      if g_LTM_Serp~=nil and g_LTU_Serp~=nil then -- in case we have ultratools active, enable saving/loading
        while g_LTM_Serp.Shared_Cache==nil do
          coroutine.yield()
        end
        while g_LTU_Serp.SaveLuaStuff.LoadingDone~=true do
          coroutine.yield()
        end
        -- g_LTL_Serp.modlog(g_LTL_Serp.TableToFormattedString(g_LTM_Serp.Shared_Cache[ModID]),ModID)
        if g_LTM_Serp.Shared_Cache[ModID]~=nil and g_LTM_Serp.Shared_Cache[ModID].HumanTrades~=nil and g_LTM_Serp.Shared_Cache[ModID].HumanTrades.ExtraProfit~=nil then
          g_LimitedPrefered_Serp.HumanTrades = g_LTM_Serp.Shared_Cache[ModID].HumanTrades
          g_LimitedPrefered_Serp.TraderInfos = g_LTM_Serp.Shared_Cache[ModID].TraderInfos
        end
      end
      
      g_LimitedPrefered_Serp._UpdateTrades()
      g_LimitedPrefered_Serp._UpdateNames()
      g_LimitedPrefered_Serp._Reduceamout()
    end
    
    -- endless loop reducing the traded amount by 1 every Preferred_IntervallReduce
    local function _Reduceamout()
      g_LTL_Serp.start_thread("g_LimitedPrefered_Serp Tick",ModID,function()
        while true do
          system.waitForGameTimeDelta(Preferred_IntervallReduce)
          for TraderEnum, infos in pairs(g_LimitedPrefered_Serp.TraderInfos) do
            for Product,tradeinfos in pairs(infos.PGoods) do
              if tradeinfos.BoughtFromLocale > 0 then
                tradeinfos.BoughtFromLocale = tradeinfos.BoughtFromLocale - 1
                g_LimitedPrefered_Serp._UpdateName(nil,TraderEnum)
              end
            end
          end
          if g_LTM_Serp~=nil and g_LTM_Serp.Shared_Cache~=nil and g_LTU_Serp~=nil then
            g_LTM_Serp.Shared_Cache[ModID] = {HumanTrades=g_LimitedPrefered_Serp.HumanTrades,TraderInfos=g_LimitedPrefered_Serp.TraderInfos}
          end
        end
      end)
    end


    -- ##########################################################################################
    -- ##########################################################################################
  

    g_LimitedPrefered_Serp = {
      _t_Init = _t_Init,
      _UpdateName = _UpdateName,
      _UpdateNames = _UpdateNames,
      _Reduceamout = _Reduceamout,
      _OnProfitMade = _OnProfitMade,
      _SetNewOld = _SetNewOld,
      _UpdateTrades = _UpdateTrades,
      HumanTrades = {ExtraProfit=0}, -- local human trades
      TraderInfos = {
        Third_party_03_Pirate_Harlow = {Session=180023,HelpAsset=1500006116,PGoods={}}, -- PGoods={11={Earned=0,Payed=0}}
        Third_party_04_Pirate_LaFortune = {Session=180025,HelpAsset=1500006117,PGoods={}},
        Third_party_02_Blake = {Session=180023,HelpAsset=1500006118,PGoods={}},
        Third_party_06_Nate = {Session=110934,HelpAsset=1500006119,PGoods={}},
        Third_party_05_Sarmento = {Session=180025,HelpAsset=1500006120,PGoods={}},
        Third_party_07_Jailor_Bleakworth = {Session=180023,HelpAsset=1500006121,PGoods={}},
        Third_party_08_Kahina = {Session=180023,HelpAsset=1500006122,PGoods={}},
        Africa_Ketema = {Session=112132,HelpAsset=1500006123,PGoods={}},
        Arctic_Inuit = {Session=180045,HelpAsset=1500006124,PGoods={}},
      }
    }
    
            
    g_LTL_Serp.start_thread("InitLimitPreferredCache",ModID,function()
      while g_LTM_Serp==nil or g_LTM_Serp.Shared_Cache==nil and g_LTU_Serp~=nil do
        coroutine.yield()
      end
      g_LTM_Serp.Shared_Cache[ModID] = {HumanTrades={},TraderInfos={}}
    end)
    
    g_LTL_Serp.start_thread("g_LimitedPrefered_Serp Init",ModID,function()
      g_LTL_Serp.waitForTimeDelta(300)
      g_LimitedPrefered_Serp._t_Init()
    end)
    
    g_LTL_Serp.start_thread("g_OnGameLeave_serp",ModID,function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_LimitedPrefered_Serp = nil
        end
      end
    end)
    g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)
    
end