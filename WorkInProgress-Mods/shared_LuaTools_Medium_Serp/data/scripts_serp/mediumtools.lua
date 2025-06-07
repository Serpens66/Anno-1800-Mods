-- Uses Nameable from:
-- Scenario_Item_Trader  GUID: 4387 , PID: 139
-- (I think the only Participant with Queen Template where I do not use the Nameable yet (besides Void Trader and Queen) is Scenario02_Actuary)


-- Only this script gets loaded via ActionExecuteScript on GameLoaded and it starts all other lua scripts
-- (ok, event_savegame_loaded.lua is called first via ActionExecuteScript and then starts this here via Unlock 1500004636)



-- general infor for lua and multiplayer:
  -- Code with ActionExecuteScript is started for all humans, regardless who executed this Action.
  -- If you only want to execute code for a specific human, you can use my WhichPlayerCondition mod (included as shared mod)
   -- to check within the Trigger where you do ActionExecuteScript which human the executing player is and then start
    -- a different script for each of them, eg called myscript_0.lua for Human0 and so on.
   -- In that script you know its ment to be only executed for Human0, you can check "GetGetCurrentParticipantID" to make
    -- sure only the correct participant is executing the code.
  -- But your code still will be executed for all human peers in that Coop team, so if 2 people are in the team, lua commands
   -- which are synced will still be executed 2 times.
   -- To complete solve the coop problem, you will need my UltraTools shared mod. But even without it there are several workarounds
    -- for specific situations. The MediumTools includes a few more workarounds.
   -- But eg. instead of using "RegisterTriggerForCurrentParticipant", which will register the trigger 2 times with 2 coop players,
    -- you can instead make your Trigger a FeatureUnlock (AutoSelfUnlock=0, AutoRegister=1), which has the main Condition UnlockNeeded of itself.
    -- Then you can use ts.Unlock.SetUnlockNet(YOUR_FEATUREUNLOCK) instead, to make this Trigger start. It does not matter if the unlocking is executed 
     -- multiple times in coop, because unlock is unlock.
   -- IMPORTANT:
    -- But by using Condition UnlockNeeded we get another problem:
     -- Registered Triggers are saved to the samegame and Assets which do not exist are always counted as unlocked.
     -- That means if a user deactivates your mod, the Trigger Code will still be there, but the asset he checks for being unlocked
      -- does not exist anymore, which defaults to "unlocked" and make your Trigger execute its actions.
     -- Depending on the actions this might cause problems, since the mod is no longer active.
    -- Therefore its best to reverse the unlock for Triggers/FeatureUnlocks like this:
     -- Use DefaultLockedState=0 for it and use NegateCondition in your UnlockNeeded Condition, to check if it is "locked".
      -- And in lua you use instead ts.Unlock.SetRelockNet(YOUR_FEATUREUNLOCK)
    -- I think for Quests PreConditionList this problem does not exist, at least not if Quest and Pool is removed (maybe if pool stays)
      -- (so not needed for SpawnHelpers.include.xml from mediumtools)



-- info:
  -- this is how we can properly add our code to the functions of another mod:
      -- local Orig_UpdateOfferedDiploButtons = g_DiploActions_Serp.UpdateOfferedDiploButtons
      -- g_DiploActions_Serp.UpdateOfferedDiploButtons = function(TargetPID,topdiplostate,...)
        
        -- return Orig_UpdateOfferedDiploButtons(TargetPID,topdiplostate,...)
      -- end
  -- or executing orig first:
      -- local Orig_UpdateOfferedDiploButtons = g_DiploActions_Serp.UpdateOfferedDiploButtons
      -- g_DiploActions_Serp.UpdateOfferedDiploButtons = function(TargetPID,topdiplostate,...)
        -- local ret = Orig_UpdateOfferedDiploButtons(TargetPID,topdiplostate,...) -- execute original first (so it locks everything first)
        -- ..mycode..
        -- return ret
      -- end
      
      
-- info:
 -- doing a mods.reload() while a lua coroutine (thread) is running very often crashes the game.
 -- Assumption: It happens when new world was loaded (by AI), but never visited by the player yet?
 -- yes seems like this is true.. (at least chance very high and chance for crash very low when session visited)
  -- TODO test if this also happens without any lua scripts. and then which lua scripts are problematic
 -- auch ohne session crashed oft währedn schnellvorlauf
 -- und vermutlich medium grund .. wobei es mit ultra schon häufiger zu sein scheint...
-- hm.. ist absolut beschissen reproduzierbar ... keine ahnung worans liegt...
 -- aber ich würde schon sagen ohne lua ists sehr viel seltener, bzw. garnicht (kann auch an supportfleet lua liegen)
 -- aber auch mit lua ists ab und zu ständig und ab und zu nur jedes 5te mal n crash..
-- oder es liegt wirklich doch dran, wenn man reload macht während threads laufen...
  -- hm ne, wenn ich im testscript einfach n thread mit waitForTimeDelta oder waitForGameTimeDelta oder nur coroutine.yield im while loop laufen lasse
    -- und dann mod reloade, dann crasht es nicht...




-- TODO:
 -- g_LTL_Serp.GetActiveQuestInstances evlt noch ab und zu, zb. alle 10 minuten,
  -- callen und in Shared_Cache speichern, was die aktuell höchste ID ist (zsm mit GameTime abspeichern).
  -- Das kann man dann als startfromID nutzen, wenn man schneller Quests finden will die nach diesem Zeitpunkt gestartet wurden

local ModID = "shared_LuaTools_Medium_Serp mediumtools.lua" -- used for logging

if g_LuaScriptBlockers[ModID]==nil then
    
    math.randomseed(os.time()) -- randomize math.random()
    
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    

    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end
    
    console.startScript("data/scripts_serp/objectfinder.lua")
    console.startScript("data/scripts_serp/coopcount.lua")

    g_LTL_Serp.modlog("mediumtools.lua registered",ModID)
    
    
    
    -- #####################################################################################################
    -- #####################################################################################################
    
    
    local Fn_Blocker = {}
    -- fn_name is a string, eg. "g_LTL_Serp.modlog"
    -- use this to block the call to your function for blocktime. 
     -- Useful if something causes multiple calls in short time to your function, but you also want it to execute once.
      -- blocktime still should be less than ~6 seconds (6000), because coroutines should not be used too long (not preserved over savegames)
    local function CallGlobalFnBlocked(fn_name,blocknameadd,blocktime,...)
      blocknameadd = blocknameadd and tostring(blocknameadd) or ""
      local blockername = "Fn_Blocker_"..fn_name..blocknameadd
      if Fn_Blocker[blockername] then
        return
      end
      Fn_Blocker[blockername] = true
      blocktime = blocktime or 1000
      g_LTL_Serp.start_thread(blockername,tools_ModID,function()
        g_LTL_Serp.waitForTimeDelta(blocktime) -- unblock it again, so it can be executed the next time we load a game
        Fn_Blocker[blockername] = nil
      end)
      fn = g_LTL_Serp.myeval(fn_name)
      return fn(...)
    end
    
    -- #####################################################################################################
    
    -- AddToQueue: Call this if you want tasks you put in here completed one after the other
    -- ID your unique identifier string. 
    local LoopIsRunning = {} -- does it work with local like this? or should it be global?
    local ThreadQueue = {}
    local function AddToQueue(ID,fn,...)
      LoopIsRunning[ID] = LoopIsRunning[ID] or false
      ThreadQueue[ID] = ThreadQueue[ID] or {}
      local task = {fn=fn,args={...}}
      table.insert(ThreadQueue[ID],task)
      if not LoopIsRunning[ID] then
        LoopIsRunning[ID] = true
        g_LTL_Serp.start_thread("AddToQueue "..ID,ModID,function(ID)
          local task = table.remove(ThreadQueue[ID],1)
          while task~=nil do
            status,err = xpcall(task.fn,g_LTL_Serp.log_error,table.unpack(task.args))
            if status==false then
              g_LTL_Serp.modlog("ERROR calling AddToQueue function from "..ID..", err: "..tostring(err),ModID)
            end
            task = table.remove(ThreadQueue[ID],1)
          end
          LoopIsRunning[ID] = false
        end,ID)
      end
    end
    
    -- #####################################################################################################
    -- checks if the PID has the Trader Property
    -- provide either PID or PID_OID if you already have it (OID of SessionParticipant)
    -- returns nil if it does not know (not found). returns false, if it is not. true if it is.
    local function IsThirdPartyTrader(PID,PID_OID)              
      -- g_LTL_Serp.modlog("IsThirdPartyTrader called with: PID: "..tostring(PID)..", PID_OID: "..tostring(PID_OID),ModID)
      local ret_IsThirdPartyTrader = nil
      if (PID~=nil and PID~=0) or (PID_OID~=nil and PID_OID~=0) then
        if PID_OID==nil or PID_OID==0 then -- first search local session (because then we can check userdata within g_LTL_Serp.HasProperty)
          local sessionparticipants = g_ObjectFinderSerp.GetAllLoadedSessionsParticipants({PID},session.getSessionGUID())
          for SessionID,session_pids in pairs(sessionparticipants) do
            if session_pids[PID]~=nil then
              PID_OID = session_pids[PID].OID
              -- g_LTL_Serp.modlog("IsThirdPartyTrader found PID_OID in current session PID_OID: "..tostring(PID_OID),ModID)
            end
          end
        end
        if PID_OID==nil or PID_OID==0 then -- if not found, use first session we found it
          local sessionparticipants = g_ObjectFinderSerp.GetAllLoadedSessionsParticipants({PID},"First")
          for SessionID,session_pids in pairs(sessionparticipants) do
            if session_pids[PID]~=nil then
              PID_OID = session_pids[PID].OID
              -- g_LTL_Serp.modlog("IsThirdPartyTrader found PID_OID in First session PID_OID: "..tostring(PID_OID),ModID)
            end
          end
        end
        if PID_OID~=nil and PID_OID~=0 then
          local HasTraderProp = g_LTL_Serp.HasProperty(nil,"Trader",PID_OID)
          if HasTraderProp==nil then -- we dont know, because we are not in the same session (cant get userdata). so we need a workaround
            -- g_LTL_Serp.modlog("IsThirdPartyTrader HasProperty does not work, checking RerollCosts instead... ",ModID)
            local RerollCosts = g_LTL_Serp.GetVectorGuidsFromSessionObject("[MetaObjects SessionGameObject("..tostring(PID_OID)..") Trader RerollCosts Costs Count]",{ProductGUID="number",Amount="number"})
            ret_IsThirdPartyTrader = false
            for i,RerollCost in pairs(RerollCosts) do
              ret_IsThirdPartyTrader = true
              -- g_LTL_Serp.modlog("IsThirdPartyTrader found RerollCost",ModID)
              -- g_LTL_Serp.modlog("RerollCost: Product:"..tostring(RerollCost.ProductGUID)..", Amount:"..tostring(RerollCost.Amount),ModID)
              break
            end
          else
            -- g_LTL_Serp.modlog("IsThirdPartyTrader HasProperty Trader is not nil",ModID)
            ret_IsThirdPartyTrader = HasTraderProp
          end
        end
      -- g_LTL_Serp.modlog("IsThirdPartyTrader returns "..tostring(ret_IsThirdPartyTrader),ModID)
      return ret_IsThirdPartyTrader
      end
    end
    
    
    -- #####################################################################################################
    
    
    
  -- Multiplayer Compatible ChangeOwner Function (automatically synced), called from within a thread

  -- Minor Problem: No Lua command I tried, neither on GameObject Walking nor on userdata (DebugStop/SetDebugGoto/SetMove/MoveTo) does abort the current task/command of the ship (traderoute/escort)
  -- Luckily the AI does give the ships a new command after receiving it. But the humans should make sure to manually stop doing what they did before.
    -- maybe ActionStopObjectMovement? but we can not properly target there, only all ships owned by eg. Nature... at least using a Pool of ships owned by 1st/2nd party, so no Quest/helper ships are hit
     -- not that important. AI gives them new task and human can simply give it new command manually
    
    
  -- only works for Sellable Objects! (because we use the BuyNet Feature, which is the only way to change owner without desync/forcing everyone in the same session)
  -- When changing the owner to ThirdParty, the ship will leave map (this is what BuyNet does, so normal behaviour when selling a ship to a shiptrader). I think it is ok, since we dont want Pirates and so on to use the same ship GUID like players. So if we really want gifting ship to Pirate, we should also use changeGUID .. in rare cases it does not leave map! (and it seems the owner is not Neutral, but the pirate. maybe thats why they sometimes do not leave, because they get another command..)
   -- I will add xml Trigger to make sure Pirates never own Playerships (will either changeGUID or change to Neutral and leave map) and player never owns pirate ships (same)
  -- We assume whichever Peer is calling this, is the owner of OID (will be checked again) and want to gift it to To_PID
   -- So make sure before calling it, only one peer is calling it (either by using UltLuaHelpers or Notification Trick or whatever. if all coop peers execute it, then the buy/sell cost compensation is credited multiple times)
  -- use CallGlobalFnBlocked with "ChangeOwnerOIDToPID_"..OID as blocknameadd with ~2 seconds blocktime when calling this to prevent the same peer from executing it multiple times for the same object (eg if done via CharacterNotification Button and the player hits the button multiple times)
   -- set ignoreowner to true if you want to allow gifting the ship, even if Local Player is not the Owner from it
   -- if notifyonfail is true, it will send a notification to the Local_PID if a ship owner change failed
    -- sth like "can not change owner of ships which are not sellable"
  local function t_ChangeOwnerOIDToPID(OID,To_PID,ignoreowner,notifyonfail)
    local GUID = g_LTL_Serp.GetGameObjectPath(OID,"GUID")
    g_LTL_Serp.modlog("ChangeOwnerOIDToPID called. OID:"..tostring(OID).." GUID: "..tostring(GUID).." To_PID: "..tostring(To_PID),ModID)
    local InfluenceProduct = 1010190 -- we dont care for Influence costs. Other costs are refunded
    if GUID~=nil and GUID~=0 then
      local Local_PID = ts.Participants.GetGetCurrentParticipantID()
      To_PID = To_PID or Local_PID
      local Owner = g_LTL_Serp.GetGameObjectPath(OID,"Owner")
      local with_middleman = g_LTM_Serp.NatureParticipantPID -- if they have no traderights, we will make use of a middleman (PID=158) who has traderights with everyone
      if ts.Participants.GetCheckDiplomacyStateTo(Owner,To_PID,2) then -- BuyNet only works with traderights
        with_middleman = false
      elseif not (ts.Participants.GetCheckDiplomacyStateTo(with_middleman,To_PID,2) and ts.Participants.GetCheckDiplomacyStateTo(Owner,with_middleman,2)) then
        g_LTL_Serp.modlog("ChangeOwnerOIDToPID FAILED, because either To_PID or Owner does not even have traderights with my Nature-Helper-Participant (most likely a mod participant with DefaultTreaties War ... it will work if my submod_NatureParticipant mod loads after that mod)",ModID)
        return false
      end
      local To_IsHuman = g_LTL_Serp.IsHuman(To_PID) -- AI does cheat anyway, cant go bancrupt and AddAmount does not do anything for them anyways (also BuyNet does not change their money). So we can skip this for them
      local Owner_IsHuman = g_LTL_Serp.IsHuman(Owner)
      if (ignoreowner or Owner==Local_PID) and To_PID~=Owner then
        if g_LTL_Serp.GetGameObjectPath(OID,"Sellable.CanBeSoldToTrader") then
          -- we can credit other PIDs the money without calling code for them, by having at least one valid OID of any building.
          local To_Kontor_OID = To_IsHuman and To_PID~=Local_PID and g_ObjectFinderSerp.GetAnyValidKontorOIDFrom(To_PID) or true
          local Owner_KontorOID = Owner_IsHuman and Owner~=Local_PID and g_ObjectFinderSerp.GetAnyValidKontorOIDFrom(Owner) or true
          local To_IsThirdPartyTrader = g_LTM_Serp.IsThirdPartyTrader(To_PID)
          if To_Kontor_OID~=nil and To_Kontor_OID~=0 and Owner_KontorOID~=nil and Owner_KontorOID~=0 then
            
              if To_IsHuman then
                local BuyPrices = g_LTL_Serp.GetVectorGuidsFromSessionObject("[MetaObjects SessionGameObject("..tostring(OID)..") Sellable CurrentParticipantBuyPrice Costs Count]",{ProductGUID="number",Amount="number"}) -- this way we support mods adding more costs to buy/sell ships
                for i,Buyinfo in pairs(BuyPrices) do -- using this instead of MoneyCost, because in theory modders could add more costs than just money
                  local Price = Buyinfo.Amount
                  local Product = Buyinfo.ProductGUID
                  -- g_LTL_Serp.modlog("BuyPrice: Product:"..Product..", Price:"..Price,ModID)
                  if Price~=nil and Price~=0 and Product~=nil and Product~=0 and Product~=InfluenceProduct then
                    if To_PID==Local_PID then
                      ts.Economy.MetaStorage.AddAmount(Product, Price)
                    else
                      g_LTL_Serp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(To_Kontor_OID)..") Area Economy AddAmount("..tostring(Product)..","..tostring(Price)..")]")
                    end
                  end
                end
                g_LTL_Serp.waitForTimeDelta(1000) -- keep it simple, 1s should be enough (eg buyer could have negative money and stuff like this we dont want to deal with code..)
              end
              
              if not To_IsThirdPartyTrader then -- if it is trader, we dont want to stop, because it gets the command to leave map (and if we do DebugStop it instantly disappears instead)
                g_LTL_Serp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(OID)..") Walking DebugStop()]") -- revoke all current commands, especially traderoutes
              end
              if with_middleman~=false then
                g_LTL_Serp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(OID)..") Sellable BuyNet("..tostring(with_middleman)..")]")
              end -- no yield needed it seems
              g_LTL_Serp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(OID)..") Sellable BuyNet("..tostring(To_PID)..")]")
             
              g_LTL_Serp.waitForTimeDelta(1000) -- wait for the money reach the Owner before to substract it again, keep it simple
              if not To_IsThirdPartyTrader then
                g_LTL_Serp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(OID)..") Walking DebugStop()]") -- revoke all current commands, especially traderoutes
              end
              if Owner_IsHuman then
                local SellPrices = g_LTL_Serp.GetVectorGuidsFromSessionObject("[MetaObjects SessionGameObject("..tostring(OID)..") Sellable SellPrice Costs Count]",{ProductGUID="number",Amount="number"})
                for i,Sellinfo in pairs(SellPrices) do
                  local Price = Sellinfo.Amount
                  local Product = Sellinfo.ProductGUID
                  -- g_LTL_Serp.modlog("SellPrice: Product:"..Product..", Price:"..Price,ModID)
                  if Price~=nil and Price~=0 and Product~=nil and Product~=0 and Product~=InfluenceProduct then
                    if Owner~=Local_PID then
                      g_LTL_Serp.DoForSessionGameObject("[MetaObjects SessionGameObject("..tostring(Owner_KontorOID)..") Area Economy AddAmount("..tostring(Product)..","..tostring(Price)..")]")
                    else
                      ts.Economy.MetaStorage.AddAmount(Product, Price) -- reduce the money (is negative amount)
                    end
                  end
                end
              end
          else 
            g_LTL_Serp.modlog("ChangeOwnerOIDToPID FAILED, because GetAnyValidKontorOIDFrom did not succeed to find a valid Kontor from owner/receiver.",ModID)
            if notifyonfail then
              -- TODO: evtl eine notification senden, dass man zum verschenken eine insel des spielers in diesem savegame-run gesehen haben muss (also zb einmal session wechel durchfüren)
            end
            return false
          end
        else 
          g_LTL_Serp.modlog("ChangeOwnerOIDToPID FAILED, because this Object can not be sold, GUID "..tostring(GUID),ModID)
          if notifyonfail then
            -- -- can not be sold. TODO Notification machen
          end
          return false
        end
      end
    end
    return true
  end

  
  -- Use this if you are not using UltraTools, but still want to make code executed for everyone
   -- (UltraTools has t_ExecuteFnWithArgsForPeers)
  -- Only call this if every peer who is calling this provides the exact same arguments (it will be written into a nameable, so overwriting each other if different information)
    -- info will be written into a nameable and then a trigger with ActionExecuteScript will be started
     -- the script started this way will read out the nameable and execute the content of it for everyone
      -- (we also can make a ExecuteForPID function this way, just no ForPeer, which is done in UltraTools instead)
   -- So all the args must be convertable to a string!
  -- making use of Nameable from Scenario_Item_Trader  GUID: 4387 , PID: 139 to share info with other peers
   -- we do not change the Name back to vanilla 4387 because everytime we change the name it takes ~3 seconds, and we want to save this time
  local function SimpleExecuteForEveryone(funcname,...)
    if not ts.GameSetup.GetIsMultiPlayerGame() then
      local func = g_LTL_Serp.myeval(funcname)
      return func(...)
    end
    local args = {...} -- does put the "..." arguments into a table
    local intable = {funcname=funcname,args=args}
    local inhex = g_LTL_Serp.TableToHex(intable)
    g_LTM_Serp.AddToQueue(ModID.."_SimpleExecuteForEveryone",function(inhex) -- make every call execute one after the other
      local SharePID = 139
      local PID_OID = nil
      local status,sessionparticipants = xpcall(g_ObjectFinderSerp.GetAllLoadedSessionsParticipants,g_LTL_Serp.log_error,{SharePID},"First") -- only first found loaded session. this way we make sure everyone is using the same OID (at least as long everyone started in the same session)
      if status==false then
        g_LTL_Serp.modlog("SimpleExecuteForEveryone ERROR : "..tostring(sessionparticipants),ModID)
        error(sessionparticipants) 
      end
      g_LTL_Serp.modlog("SimpleExecuteForEveryone after GetAllLoadedSessionsParticipants "..tostring(ts.GameClock.CorporationTime),ModID)
      for SessionID,session_pids in pairs(sessionparticipants) do
        PID_OID = session_pids[SharePID].OID
        local status,err = xpcall(g_LTL_Serp.DoForSessionGameObject,g_LTL_Serp.log_error,"[MetaObjects SessionGameObject("..tostring(PID_OID)..") Nameable Name("..tostring(infostring)..")]")
        if status==false then
          g_LTL_Serp.modlog("SimpleExecuteForEveryone2 ERROR : "..tostring(err),ModID)
          error(err) 
        end
      end
      g_LTL_Serp.waitForTimeDelta(3000) -- wait at least 3 seconds to make sure Nameable is synced between all players 
      ts.Conditions.RegisterTriggerForCurrentParticipant(1500005607) -- make everyone call _DoExectionForEveryone
      g_LTL_Serp.waitForTimeDelta(1500) -- wait a bit more until everyone read out the nameable, before releasing this Queue
    end,inhex)
  end
  
  local function _DoExectionForEveryone()
    local SharePID = 139
    local status,sessionparticipants = xpcall(g_ObjectFinderSerp.GetAllLoadedSessionsParticipants,g_LTL_Serp.log_error,{SharePID},"First") -- only first found loaded session
    if status==false then
      g_LTL_Serp.modlog("_DoExectionForEveryone ERROR : "..tostring(sessionparticipants),ModID)
      error(sessionparticipants) 
    end
    local inhex = nil
    for SessionID,session_pids in pairs(sessionparticipants) do
      inhex = ts.GetGameObject(session_pids[SharePID].OID).Nameable.Name -- if Name was changed with DoForSessionGameObject, then GetGameObject works to get the name regardless of player and session
    end
    if inhex~=nil and inhex~="" and inhex~=ts.GetAssetData(4387).Text then
      local intable = g_LTL_Serp.HexToTable(inhex)
      if type(intable) =="table" then
        local func = g_LTL_Serp.myeval(intable.funcname)
        local success, err
        if func==nil then
          success, err = false,"_DoExectionForEveryone: func does not exist (nil)" -- its a bit more clear than "attempt to call a nil value"
        else
          success, err = xpcall(func,g_LTL_Serp.log_error,table.unpack(intable.args))
        end
        if success==false then
          g_LTL_Serp.modlog("_DoExectionForEveryone ERROR while trying to call funcname "..tostring(intable.funcname).." error: "..tostring(err),ModID)
        end
      end
      g_LTL_Serp.modlog("_DoExectionForEveryone ERROR info in Nameable helper is wrong",ModID)
    end
  end
  
  
  -- function you can call within code that is executed for one Human player, but for all coop peers from it.
  -- if it returns "AllCoop", you can continue your code, but still have in mind that it gets executed multiple times (once per coop)
   -- if it returns "IsFirst" you can savely call code and be sure its only executed once
    -- if it returns false, dont execute your code (if you want it to only be executed for the first coop peer)
  local function ContinueCoopCalled()
    local continue = "AllCoop"
    if g_LTU_Serp~=nil and g_LTU_Serp.PeersInfo~=nil and g_LTU_Serp.PeersInfo.CoopFinished~=nil then -- only if we also have ultra tools installed we have PeersInfo and therefore can make sure code is only executed for one peer
      continue = g_LTU_Serp.PeersInfo.AmIFirstActiveCoopPeer() and "IsFirst" or false
    end
    if continue=="AllCoop" and g_CoopCountResSerp~=nil and g_CoopCountResSerp.Finished~=nil and g_CoopCountResSerp.LocalCount==1 then
      continue = "IsFirst" -- we are alone in this coop team
    end
    return continue
  end

    -- #####################################################################################################
    -- #####################################################################################################

    
    -- Lua Tools Medium
    g_LTM_Serp = {
      ObjectFinder = g_ObjectFinderSerp,
      CoopCountRes = g_CoopCountResSerpSerp,
      CallGlobalFnBlocked = CallGlobalFnBlocked,
      AddToQueue = AddToQueue,
      IsThirdPartyTrader = IsThirdPartyTrader,
      ContinueCoopCalled = ContinueCoopCalled,
      t_ChangeOwnerOIDToPID = t_ChangeOwnerOIDToPID,
      SimpleExecuteForEveryone = SimpleExecuteForEveryone,
      _DoExectionForEveryone = _DoExectionForEveryone,
      NatureParticipantPID = 158, -- has traderights with everyone (Enum: Mod10, GUID: 1500004528)
      -- Shared_Cache use your ModID or other unique identifier as key. If the UltraTools mod is enabled, this Shared_Cache 
      -- will be saved to Nameable helper to save it to a savegame and will be loaded on loading a game 
          -- (so at best only put important information in here)
        -- Will also be used by several Tools features. Eg. the objectfinder script will put this useful infos into it:
         -- ObIDs={},LoadedSessionsParticipants={},LoadedSessions={},Kontor_OIDs={},Loaded=nil,Changed=nil,SyncChanged=nil
      Shared_Cache = {},
    }
    
    
    g_LTL_Serp.start_thread("g_OnGameLeave_serp",ModID,function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_LTM_Serp = nil
        end
      end
    end)
    g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)

    
end