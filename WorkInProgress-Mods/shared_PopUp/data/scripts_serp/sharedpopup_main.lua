-- Uses CompanyName Scenario3_Challenger1 and Scenario3_Challenger2 to store Text for the PopUps
-- Scenario3_Challenger1  GUID: 100132 , PID: 118
-- Scenario3_Challenger2  GUID: 100938 , PID: 119
 
-- Ist einfach zu unzuverlässig. Haupproblem, dass popups geschlossen werden, wenn spieler zb garde in dem moment session wechselt.
 -- ohne irgendeine info und ohne möglichkeit es nur für diesen peer erneut anzuzeigen..
 
-- TODO: fürs auto schließen der popusp bei sessionwechsel mal in xml:
 -- ShortcutIdentifier
  -- ausprobieren, ob da irgendein wert dafür sorgt, dass ein button bei diesem schließen ausgeführt wird.
   -- so würde man zumindest darüber informiert (auch wenns dafür eigentlich n extra button geben muss, sonst weiß man nicht obs dieser fail war oder ob button gedrückt wurde)

 
-- TODO:
-- was passiert wenn wir vor popup noch das delete popup starten und erst wegklicken wenn andere popups laufen?
 -- dann gibts doch bestimmt n mismatch?




-- TODO:
 -- im Coop failen einige checks was zu endlosen ACtionTriggerPopUp führt... (vllt auch im 2 humans, aber da klappte zumindest die incompatible meldung)
-- Sat May 10 22:06:23 2025 shared_LuaOnGameLoaded_Serp: LoadingScreenLeft
-- Sat May 10 22:06:24 2025 shared_LuaUltimateHelpers_Serp objectfinder.lua: objectfinder.lua called
-- Sat May 10 22:06:24 2025 shared_LuaUltimateHelpers_Serp savetablestuff.lua: savetablestuff.lua registered
-- Sat May 10 22:06:24 2025 shared_PopUp_Serp: sharedpopup_main.lua registered
-- Sat May 10 22:06:24 2025 shared_IncompatibleModsPopUp: checkmodlog_incompatible.lua registered
-- Sat May 10 22:06:24 2025 shared_IncompatibleModsPopUp: incompatible mods detected, showing PopUp now
-- Sat May 10 22:06:24 2025 shared_PopUp_Serp: Shared ShowPopup: Inkompatible Mods!  IncompatibleMods
-- Sat May 10 22:06:24 2025 shared_PopUp_Serp: StartPopUpThread
-- Sat May 10 22:06:24 2025 shared_LuaCoopCounterRes_Serp: coopcount.lua registered
-- Sat May 10 22:06:24 2025 shared_MP_Lua_Popup: mp_popup.lua registered
-- Sat May 10 22:06:24 2025 shared_PopUp_Serp: Shared ShowPopup: MP Lua Abfrage  0
-- Sat May 10 22:06:24 2025 shared_PopUp_Serp: Shared ShowPopup: MP Lua Abfrage  4
-- Sat May 10 22:06:25 2025 shared_MP_Lua_Popup: PeerInt found: 4
-- Sat May 10 22:06:27 2025 shared_PopUp_Serp: Shared ButtonHit: 2  IncompatibleMods
-- Sat May 10 22:06:27 2025 shared_PopUp_Serp: Shared ShowPopup ERROR FeatureUnlock did not show PopUp?
-- Sat May 10 22:06:27 2025 shared_PopUp_Serp: 3 ~= 7
-- Sat May 10 22:06:30 2025 shared_PopUp_Serp: Shared ButtonHit: 1  0
-- Sat May 10 22:06:32 2025 shared_PopUp_Serp: Shared ButtonHit: 2  4
-- Sat May 10 22:06:32 2025 shared_LuaUltimateHelpers_Serp objectfinder.lua: t_ExecuteFnWithArgsForPeers start g_PeersInfo_Serp.Sync_ActivePeersInfo 18300
-- Sat May 10 22:06:35 2025 shared_LuaUltimateHelpers_Serp objectfinder.lua: DoTheExecutionFor FromPeerInt 0 21700
-- Sat May 10 22:06:40 2025 shared_LuaUltimateHelpers_Serp objectfinder.lua: DoTheExecutionFor FromPeerInt 4 26800

-- liegt sicherlich daran, dass die PopUps bei einem Coop abgebrochen werden,
 -- aber dann mit ActionTriggerPopup für beide erneut gestartet werden -.-
  -- ich fürchte da gibts keine sinnvolle Lösung für, als einfach spiel neustarten,
   -- wenn einer popup abbricht...
 -- vllt bei ShowPopup noch einen Wert übergeben, ob ein PopUp extrem wichtig ist (sodass es Abbruch rechtfertigt.)
  -- wenn das gesetzt ist, dann leavegame und ansonsten scheiß drauf..

-- auch beim laden mit 2 humans (wo nur inc. gezeigt werden muss) wird bei human0, welcher währenddessen die Session wechselt, folgendes gemacht:
-- Sat May 10 22:12:00 2025 shared_LuaOnGameLoaded_Serp: LoadingScreenLeft
-- Sat May 10 22:12:01 2025 shared_LuaUltimateHelpers_Serp objectfinder.lua: objectfinder.lua called
-- Sat May 10 22:12:01 2025 shared_LuaUltimateHelpers_Serp savetablestuff.lua: savetablestuff.lua registered
-- Sat May 10 22:12:01 2025 shared_PopUp_Serp: sharedpopup_main.lua registered
-- Sat May 10 22:12:01 2025 shared_IncompatibleModsPopUp: checkmodlog_incompatible.lua registered
-- Sat May 10 22:12:01 2025 shared_IncompatibleModsPopUp: incompatible mods detected, showing PopUp now
-- Sat May 10 22:12:01 2025 shared_PopUp_Serp: Shared ShowPopup: Inkompatible Mods!  IncompatibleMods
-- Sat May 10 22:12:01 2025 shared_PopUp_Serp: StartPopUpThread
-- Sat May 10 22:12:01 2025 shared_LuaCoopCounterRes_Serp: coopcount.lua registered
-- Sat May 10 22:12:01 2025 shared_MP_Lua_Popup: mp_popup.lua registered
-- Sat May 10 22:12:04 2025 shared_LuaUltimateHelpers_Serp objectfinder.lua: t_ExecuteFnWithArgsForPeers start g_PeersInfo_Serp.Sync_ActivePeersInfo 78400
-- Sat May 10 22:12:05 2025 shared_PopUp_Serp: PopUp Left: ERROR PopUps_UILeft ~= ButtonsHit ! Restarting recent PopUps!
-- Sat May 10 22:12:05 2025 shared_PopUp_Serp: PopUp Left: Restart Popup: IncompatibleMods
-- Sat May 10 22:12:05 2025 shared_PopUp_Serp: Shared ShowPopup ERROR FeatureUnlock did not show PopUp?
-- Sat May 10 22:12:05 2025 shared_PopUp_Serp: 2 ~= 1
-- Sat May 10 22:12:07 2025 shared_LuaUltimateHelpers_Serp objectfinder.lua: DoTheExecutionFor FromPeerInt 0 81800
-- Sat May 10 22:12:07 2025 shared_LuaUltimateHelpers_Serp objectfinder.lua: DoTheExecutionFor FromPeerInt 1 82200
-- Sat May 10 22:12:29 2025 shared_PopUp_Serp: Shared ButtonHit: 2  nil
-- Sat May 10 22:12:29 2025 shared_PopUp_Serp: Mod Lua ERROR sharedPopUp: CurrentButtonFunc nil is has no function: nil
-- Ist an sich richtig, das PopUp neu anzuzeigen, doch dann kam : Shared ShowPopup ERROR FeatureUnlock did not show PopUp





local ModID = "shared_PopUp_Serp" -- used for logging

if g_LuaScriptBlockers[ModID]==nil then
  
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    
    
    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end
    g_LTL_Serp.modlog("sharedpopup_main.lua registered",ModID)


    -- usage example see my mods: 
    -- shared_IncompatibleModsPopUp (starting version 1.022) and shared_MP_Lua_Popup

    -- but in short explained To show your Popup you call:
    -- g_shared_PopUp_Serp.ShowPopup(header,body,ButtonFunc,Identifier,Unlock)
    -- and before you do you define the header/body text. your custom function to be called after button was hit, an custom Identifier (whatever you want)
     -- and the GUID of an FeatureUnlock you created in your assets.xml 
    -- The ButtonFunc will be called from the shared mod like this: ButtonHit(button,Identifier)

    -- ####################################################################################
    -- ####################################################################################




    -- invalid signs/zeichen in strings (to save it into nameable): " \ , [ ] and () if both used. and better do not use - because it might hurt gsub?
    local function replace_chars(str) -- string should not contain these characters
      str = tostring(str)
      -- str = str:gsub("%,", "-")
      str = str:gsub("%,", "") -- removing , might fit better
      str = str:gsub("%=", "-")
      str = str:gsub("%[", "*")
      str = str:gsub("%]", "*")
      str = str:gsub("%{", "*")
      str = str:gsub("%}", "*")
      str = str:gsub("%(", "*")
      str = str:gsub("%)", "*") -- as soon as this bracket closes, the rest is not shown anymore for whatever reason
      str = str:gsub("%\\", "/")
      return str
    end

    -- RefGuid RefOid sind im PopUp beide 0
    -- LeaveUIState zeigt beim verlassen (jedes) PopUps zwar 181/180/41 aber ich hab diese mit RefOID 0 bis 1000 ausprobiert im Coop (während beide popup offen haben)
     -- und GetCoopPeersAtMarker ist nie erfüllt, also geht das für PopUps wohl leider nicht.
      -- (das hätte beim Coop-PopUp erspart dass wir auch inaktiv abfragen müssen)

    -- Problem (und Lösung schon umgesetzt):
    -- RegisterTriggerForCurrentParticipant führts wie erwartet mehrfach aus (einmal pro coop)
     -- und ActionTriggerPopup queued das popup dadurch dann hintendran, zeigt also direkt das nächste nachdem man button gedrückt hat.
      -- doch wenn wir erst nach buttonhit erneut ActionTriggerPopup ausführen, führt das zu problemen, weil jeder coop zu untersch. Zeitpunkt den button drückt und dann meine unlock Sicherung nicht mehr verhindert dass ActionTriggerPopup öfter als geplant ausgeführt wird
    -- Aber auch Unlock macht ActionTriggerPopup welches eben für alle coops das popup startet.
    -- Dh. das System funktioniert weder mit Trigger noch mit Unlock.
    -- Stattdessen müssen alle  ActionTriggerPopup hintereinander für alle coop spieler zeitgleich einmal gemacht werden.
    --  wie lösen wir das bzgl. shared mod?
     -- Wenn wir also zb. erst 1 inkomp PopUp zeigen wollen und danach die bis zu 4 coop popups ?
     -- am besten wäre es immer sofort ActionTriggerPopup in ShowPopup zu machen (weils intern ja eh hintenan gestellt wird).
      -- Nur die Änderung des Textes wird dann über ButtonHit (CurrentlyUsedBy~=nil) gesteuert

    local function ResetPopUp()
      -- change CompanyName back to vanilla
      local oldtext = ts.GetAssetData(100132).Text -- does not work directly in SetCompanyName for whatever reason
      ts.Participants.GetParticipant(118).Profile.SetCompanyName(oldtext)
      oldtext = ts.GetAssetData(100938).Text
      ts.Participants.GetParticipant(119).Profile.SetCompanyName(oldtext)
      g_shared_PopUp_Serp.CurrentButtonFunc = nil -- show that it can be used again
      g_shared_PopUp_Serp.CurrentlyUsedBy = nil -- show that it can be used again
    end

    -- using a single worker to show the popoups one after the other
    local function StartPopUpThread()
      g_LTL_Serp.modlog("StartPopUpThread",ModID)
      
      system.start(function()
        -- security check if FeatureUnlock was properly executed (user MUST use my 1500005505 as BaseAssetGUID without overwriting TriggerActions!)
          -- we can not really fix it, the mod with the wrong unlock has to fix it.
         -- but we at least try to not fuck up everything...
        g_LTL_Serp.waitForTimeDelta(3000) -- wait for the res from the Unlock to be internally credited (roughly 1 sec, but does not hurt to wait a bit longer, we are not in a hurry)
        local NShown = ts.Economy.MetaStorage.GetStorageAmount(1500005506)
        if g_shared_PopUp_Serp.PopUpsStatus_NToShow ~= NShown then -- then sth went wrong, most likely the FeatureUnlock is wrong or so
          g_LTL_Serp.modlog("Shared ShowPopup ERROR FeatureUnlock did not show PopUp?",ModID)
          g_LTL_Serp.modlog(tostring(g_shared_PopUp_Serp.PopUpsStatus_NToShow).." ~= "..tostring(NShown),ModID)
          for i=1,g_shared_PopUp_Serp.PopUpsStatus_NToShow-NShown do -- for every missing popup, do one reset.
            ResetPopUp() -- show that it can be used again
            g_LTL_Serp.waitForTimeDelta(500) -- wait until the loop catches up
          end
          ts.Economy.MetaStorage.AddAmount(1500005506, -100000)
          g_shared_PopUp_Serp.PopUpsStatus_NToShow = 0
          g_shared_PopUp_Serp.ButtonsHit = 0
          g_shared_PopUp_Serp.PopUps_UILeft = 0
        end
      end,ModID.." StartPopUpThread NShown Check")
      
      system.start(function()
        local task = true
        while task~=nil do
          local notstop = 0
          while task~=nil and g_shared_PopUp_Serp.CurrentlyUsedBy~=nil do -- wait until PopUp is free to use
            coroutine.yield() -- roughly 100ms
            -- outcommented because we dont want to force close it if player is AFK.. we added a acceptable check below with PopUpsStatus_NToShow if the PopUp is shown or not
            -- if notstop >= 6000 then -- if player did not confirm PopUp within the past 10 minutes, then stop the thread and fail.. (or if some code in a mod using this went wrong, eg. the Unlock was wrong or did not include ActionTriggerPopup... unfortunately we are unable to check if a popup is currently displayed or if it failed (ts.Popup.RefGUID does not help)...)
              -- ts.Popup.ClosePopup(0)
              -- ResetPopUp() -- show that it can be used again
            -- end
          end
          task = table.remove(g_shared_PopUp_Serp.PopUp_Queue,1) -- putting it here, so the task remains in queue while waiting for CurrentlyUsedBy. it also means the Loop runs until all ButtonHit are done
          if task~=nil then
            g_shared_PopUp_Serp.CurrentlyUsedBy = task.CurrentlyUsedBy -- block and mark it
            g_shared_PopUp_Serp.CurrentButtonFunc = task.ButtonFunc
            g_shared_PopUp_Serp.CurrentUnlock = task.Unlock
            ts.Participants.GetParticipant(118).Profile.SetCompanyName(task.header)
            ts.Participants.GetParticipant(119).Profile.SetCompanyName(task.body)
          end
        end
        g_shared_PopUp_Serp.LoopIsRunning = false
        g_shared_PopUp_Serp.DoCountPopUpsLeft = false
        g_shared_PopUp_Serp.ButtonsHit = 0
        g_shared_PopUp_Serp.PopUps_UILeft = 0
      end,ModID.." PopUpThread")
    end
    

    -- only this function is meant to be called in your mod
    local function ShowPopup(header,body,ButtonFunc,CurrentlyUsedBy,Unlock)
        
      local function t_DoShowPopUp(header,body,ButtonFunc,CurrentlyUsedBy,Unlock)
        if g_PeersInfo_Serp~=nil and not g_PeersInfo_Serp.IsUsingPopUp then -- then it will switch sessions, which aborts popups ..
          while not g_PeersInfo_Serp.FullFinished do -- so wait for it to finish
            coroutine.yield()
          end
          g_LTL_Serp.waitForTimeDelta(2000) -- time to read the "Lua stuff finished" notification. so the user knows he is allowed to click again
        end
        header = replace_chars(header or "")
        body = replace_chars(body or "")
        g_LTL_Serp.modlog("Shared ShowPopup: "..header.."  "..tostring(CurrentlyUsedBy),ModID)
        -- direclty call ActionTriggerPopup via the unlock for all coop players at once (to make sure the unlock prevents multiple execution per coop player)
         -- it automatically queues the display of popup. The text change will be made within StartPopUpThread instead while waiting for the player to hit a button
        g_shared_PopUp_Serp.PopUpsStatus_NToShow = g_shared_PopUp_Serp.PopUpsStatus_NToShow + 1 -- to check if all wanted popups were triggered like intended
        g_shared_PopUp_Serp.DoCountPopUpsLeft = true
        ts.Unlock.SetUnlockNet(Unlock) -- using Unlock instead of RegisterTriggerForCurrentParticipant, because RegisterTriggerForCurrentParticipant is executed multiple times if you have coop players in the game
        
        table.insert(g_shared_PopUp_Serp.PopUp_Queue,{header=header,body=body,ButtonFunc=ButtonFunc,CurrentlyUsedBy=CurrentlyUsedBy,Unlock=Unlock})
        if not g_shared_PopUp_Serp.LoopIsRunning then
          g_shared_PopUp_Serp.LoopIsRunning = true
          local status, err = pcall(g_shared_PopUp_Serp.StartPopUpThread)
          if status==false then -- error
            g_LTL_Serp.modlog("Mod Lua ERROR sharedPopUp: StartPopUpThread had an error: "..tostring(err),ModID)
          end
        end
        
        system.start(function()
          g_LTL_Serp.waitForTimeDelta(500) -- important to have this value between 500 and 900 ms (because we reset the Trigger 1500005505 after 1000ms in assets.xml ) -- wait shortly to make sure all coop players executed this
          ts.Unlock.SetRelockNet(Unlock) -- lock it again shortly after so it might be used again (not done in xml because we want it to be used as BaseAssetGUID without caring for the TriggerActions)
        end,ModID.." ShowPopup relock again")
      end
      
      g_LTL_Serp.start_thread("call t_DoShowPopUp",ModID,t_DoShowPopUp,header,body,ButtonFunc,CurrentlyUsedBy,Unlock)
        
    end


    local function ButtonHit(button)
      g_shared_PopUp_Serp.ButtonsHit = g_shared_PopUp_Serp.ButtonsHit + 1
      
      g_LTL_Serp.modlog("Shared ButtonHit: "..button.."  "..tostring(g_shared_PopUp_Serp.CurrentlyUsedBy),ModID)
      
      if g_shared_PopUp_Serp.CurrentButtonFunc~=nil and type(g_shared_PopUp_Serp.CurrentButtonFunc)=="function" then
        local status, err = pcall(g_shared_PopUp_Serp.CurrentButtonFunc,button,g_shared_PopUp_Serp.CurrentlyUsedBy)
        if status==false then -- error
          g_LTL_Serp.modlog("Mod Lua ERROR sharedPopUp: CurrentButtonFunc "..tostring(CurrentlyUsedBy).." had an error: "..tostring(err),ModID)
        end
      else
        g_LTL_Serp.modlog("Mod Lua ERROR sharedPopUp: CurrentButtonFunc "..tostring(CurrentlyUsedBy).." is has no function: "..tostring(fn),ModID)
      end

      ResetPopUp() -- show that it can be used again
      
    end

    -- DONT do ts.Economy.MetaStorage.AddAmount 1500005506 to reduce the helper amount again, because this lua command is synced, which takes a second,
     -- and then it will be synced after we added amount for the popup.
      -- instead reduction is done in xml Trigger which works fine 


    g_shared_PopUp_Serp = { -- is reset on call (in case player left to main menu while popup was shown)
      ShowPopup = ShowPopup, -- only this function is meant to call in your mod
      ButtonHit = ButtonHit,
      CurrentlyUsedBy = nil,
      CurrentButtonFunc = nil,
      CurrentUnlock = nil,
      LoopIsRunning = false,
      PopUp_Queue = {},
      PopUpsStatus_NToShow = 0, -- internal use to find out if all popups are registered. 
      PopUps_UILeft = 0, -- internal use, also counts other popups, thats why we set DoCountPopUpsLeft to hopefully only count ours
      ButtonsHit = 0, -- internal use
      StartPopUpThread = StartPopUpThread, -- internal use
      DoCountPopUpsLeft = false, -- internal use
    }

    -- Problem: when starting a transition, eg to worldmap shortly before a PopUp is shown, this transition closes this popup again (and all popups in the queue which already did ActionTriggerPopup)
     -- without any response and without ButtonHit. We only get one OnLeaveUIState event if multiple queued popups were aborted.
      -- therefore we try to catch this case: If we are currently showing our popups and a Left happens, but shortly after is no ButtonHit,
       -- then sth went wrong and we need to restart popups
    local function Do_OnLeaveUIState(UILeft_ID)
      if g_shared_PopUp_Serp~=nil and UILeft_ID==181 then -- any PopUp left. g_shared_PopUp_Serp can be nil when we are in main menu (there are also popups)
        -- g_LTL_Serp.modlog("PopUp Left")
        if g_shared_PopUp_Serp.DoCountPopUpsLeft then
          -- g_LTL_Serp.modlog("PopUp Left DoCountPopUpsLeft")
          g_shared_PopUp_Serp.PopUps_UILeft = g_shared_PopUp_Serp.PopUps_UILeft + 1
          system.start(function()
            g_LTL_Serp.waitForTimeDelta(550) -- at least wait 500ms (that the unlock was locked again)
          
            if g_shared_PopUp_Serp.PopUps_UILeft ~= g_shared_PopUp_Serp.ButtonsHit then
              g_LTL_Serp.modlog("PopUp Left: ERROR PopUps_UILeft ~= ButtonsHit ! Restarting recent PopUps!",ModID)
              g_shared_PopUp_Serp.ButtonsHit = 0
              g_shared_PopUp_Serp.PopUps_UILeft = 0
              local unlocks = {g_shared_PopUp_Serp.CurrentUnlock}
              g_LTL_Serp.modlog("PopUp Left: Restart Popup: "..tostring(g_shared_PopUp_Serp.CurrentlyUsedBy),ModID)
              for _,task in pairs(g_shared_PopUp_Serp.PopUp_Queue) do
                table.insert(unlocks,task.Unlock)
                g_LTL_Serp.modlog("PopUp Left: Restart Popup: "..task.header.."  "..tostring(task.CurrentlyUsedBy),ModID)
              end
              for _,unlock in ipairs(unlocks) do
                g_shared_PopUp_Serp.PopUpsStatus_NToShow = g_shared_PopUp_Serp.PopUpsStatus_NToShow + 1
                ts.Unlock.SetUnlockNet(unlock)
              end
              g_LTL_Serp.waitForTimeDelta(500) -- important to have this value between 500 and 900 ms (because we reset the Trigger 1500005505 after 1000ms in assets.xml ) -- wait shortly to make sure all coop players executed this
              for _,unlock in ipairs(unlocks) do
                ts.Unlock.SetRelockNet(unlock) -- lock it again shortly after so it might be used again (not done in xml because we want it to be used as BaseAssetGUID without caring for the TriggerActions)
              end
            end
          end,ModID.." OnLeaveUIState PopUp Left Check")
        end
      end
    end
    -- Important info for "event." from the game:
     -- If a function you call within that event causes an error, the game will crash without printing this error to the lua log!
     -- So better always use pcall in them
    if event.OnLeaveUIState[ModID] == nil then -- only add it once
      g_LTL_Serp.modlog("Register OnLeaveUIState",ModID)
      event.OnLeaveUIState[ModID] = function(UILeft_ID) -- Left kommt zuerst vor ButtonHit
        system.start(function()
          while g_shared_PopUp_Serp==nil do
            coroutine.yield()
          end
          local status, err = pcall(Do_OnLeaveUIState,UILeft_ID) -- use seperate function with pcall, because game crashes without lua error, if any error happens in an function called by event. !
          if status==false then -- error
            print(ModID,"ERROR OnLeaveUIState: Function Do_OnLeaveUIState had an error: "..tostring(err))
            g_LTL_Serp.modlog("ERROR OnLeaveUIState: Function Do_OnLeaveUIState had an error: "..tostring(err),ModID)
          end
        end,ModID.." OnLeaveUIState")
      end
    end
    
    
    g_LTL_Serp.start_thread("g_OnGameLeave_serp",ModID,function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_shared_PopUp_Serp = nil -- stop everything (might crash some currently running functions, but I think its ok)
          event.OnLeaveUIState[ModID] = nil
        end
      end
    end)
    g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)

end