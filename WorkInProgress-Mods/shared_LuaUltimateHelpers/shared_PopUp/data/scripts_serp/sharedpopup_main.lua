-- TODO wichtig:
-- Wenn savegame in Worldmap gemacht wurde
 -- und man gerade beim Laden dann in die Session springen drückt und genau dann das popup kommt,
  -- wird das popup scheinbar abgebrochen?! 
  -- (doofes timing, sobald popup da geht nichts anderes klicken mehr, was sinnvoll ist
   -- aber wenn popup in der transition kommt, gehts weg...
 -- das schließt leider das PopUp ohne dass ButtonHit aufgerufen wurde...
 -- Leave UI: any PopUp left: 181 ... aber ob das hilft, wir können ja nicht sicher sein, dass es unser popup ist
-- ts.Popup.RefGUID hilft nicht, weil das einfach nur die aktuell angeklickte GUID ist während irgendein PopUp angezeigt wird.

-- wir könnten PopUps Left zählen und das mit ButtonHit abgleichen... kommt aber halt auch für alle anderen popups..

-- TODO:
 -- testen ob nur eines oder auch mehrere aufeinmal getriggerede popups entfertn werden.
  -- LeaveUIState für 181 printen und gucken was normal zuerst kommt: ButtonHit oder leave.
 -- Dann damit einen zähler basteln und chekcen


local ModID = "shared_PopUp_Serp" -- used for logging

if g_LuaScriptBlockers[ModID]==nil then
  
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    
    
    print("sharedpopup_main.lua registered")
    if g_LuaTools==nil then
      console.startScript("data/scripts_serp/luatools.lua")
    end
    g_LuaTools.modlog("sharedpopup_main.lua registered",ModID)


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
      -- print("StartPopUpThread")
      system.start(function()
        local task = table.remove(g_shared_PopUp_Serp.PopUp_Queue,1)
        while task~=nil do
          local notstop = 0
          while g_shared_PopUp_Serp.CurrentlyUsedBy~=nil do -- wait until PopUp is free to use
            coroutine.yield() -- roughly 100ms
            -- outcommented because we dont want to force close it if player is AFK.. we added a acceptable check below with PopUpsStatus_NToShow if the PopUp is shown or not
            -- if notstop >= 6000 then -- if player did not confirm PopUp within the past 10 minutes, then stop the thread and fail.. (or if some code in a mod using this went wrong, eg. the Unlock was wrong or did not include ActionTriggerPopup... unfortunately we are unable to check if a popup is currently displayed or if it failed (ts.Popup.RefGUID does not help)...)
              -- print("Shared PopUpThread Error notstop "..task.header)
              -- g_LuaTools.modlog("Shared PopUpThread Error notstop "..task.header,ModID)
              -- ts.Popup.ClosePopup(0)
              -- ResetPopUp() -- show that it can be used again
            -- end
          end
          -- print("PopUpThread execute "..task.header)
          g_shared_PopUp_Serp.CurrentlyUsedBy = task.CurrentlyUsedBy -- block and mark it
          g_shared_PopUp_Serp.CurrentButtonFunc = task.ButtonFunc
          ts.Participants.GetParticipant(118).Profile.SetCompanyName(task.header)
          ts.Participants.GetParticipant(119).Profile.SetCompanyName(task.body)
          task = table.remove(g_shared_PopUp_Serp.PopUp_Queue,1)
        end
        g_shared_PopUp_Serp.LoopIsRunning = false
      end)
    end

    -- only this function is meant to be called in your mod
    local function ShowPopup(header,body,ButtonFunc,CurrentlyUsedBy,Unlock)
        header = replace_chars(header or "")
        body = replace_chars(body or "")
        -- print("Shared ShowPopup: "..header.."  "..tostring(CurrentlyUsedBy))
        g_LuaTools.modlog("Shared ShowPopup: "..header.."  "..tostring(CurrentlyUsedBy),ModID)
        -- direclty call ActionTriggerPopup via the unlock for all coop players at once (to make sure the unlock prevents multiple execution per coop player)
         -- it automatically queues the display of popup. The text change will be made within StartPopUpThread instead while waiting for the player to hit a button
        g_shared_PopUp_Serp.PopUpsStatus_NToShow = g_shared_PopUp_Serp.PopUpsStatus_NToShow + 1 -- to check if all wanted popups were triggered like intended
        ts.Unlock.SetUnlockNet(Unlock) -- using Unlock instead of RegisterTriggerForCurrentParticipant, because RegisterTriggerForCurrentParticipant is executed multiple times if you have coop players in the game
        table.insert(g_shared_PopUp_Serp.PopUp_Queue,{header=header,body=body,ButtonFunc=ButtonFunc,CurrentlyUsedBy=CurrentlyUsedBy,Unlock=Unlock})
        if not g_shared_PopUp_Serp.LoopIsRunning then
          g_shared_PopUp_Serp.LoopIsRunning = true
          StartPopUpThread()
        end
        system.start(function()
          g_LuaTools.waitForTimeDelta(500) -- important to have this value between 500 and 900 ms (because we reset the Trigger 1500005505 after 1000ms in assets.xml ) -- wait shortly to make sure all coop players executed this
          ts.Unlock.SetRelockNet(Unlock) -- lock it again shortly after so it might be used again (not done in xml because we want it to be used as BaseAssetGUID without caring for the TriggerActions)
          -- security check if FeatureUnlock was properly executed (user MUST use my 1500005505 as BaseAssetGUID without overwriting TriggerActions!)
          g_LuaTools.waitForTimeDelta(3000) -- wait for the res from the Unlock to be internally credited (roughly 1 sec, but does not hurt to wait a bit longer, we are not in a hurry)
          local NShown = ts.Economy.MetaStorage.GetStorageAmount(1500005506)
          if g_shared_PopUp_Serp.PopUpsStatus_NToShow ~= NShown then -- then sth went wrong, most likely the FeatureUnlock is wrong or so
            print("Shared ShowPopup ERROR FeatureUnlock did not show PopUp? "..header.."  "..tostring(CurrentlyUsedBy))
            g_LuaTools.modlog("Shared ShowPopup ERROR FeatureUnlock did not show PopUp? "..header.."  "..tostring(CurrentlyUsedBy),ModID)
            ResetPopUp() -- show that it can be used again
          end
        end)
    end


    local function ButtonHit(button)
      
      g_LuaTools.modlog("Shared ButtonHit: "..button.."  "..tostring(g_shared_PopUp_Serp.CurrentlyUsedBy),ModID)
      if g_shared_PopUp_Serp.CurrentButtonFunc~=nil and type(g_shared_PopUp_Serp.CurrentButtonFunc)=="function" then
        local status, err = pcall(g_shared_PopUp_Serp.CurrentButtonFunc,button,g_shared_PopUp_Serp.CurrentlyUsedBy)
        if status==false then -- error
          print("Mod Lua ERROR sharedPopUp: CurrentButtonFunc "..tostring(CurrentlyUsedBy).." had an error: "..tostring(err))
          g_LuaTools.modlog("Mod Lua ERROR sharedPopUp: CurrentButtonFunc "..tostring(CurrentlyUsedBy).." had an error: "..tostring(err),ModID)
        end
      else
        print("Mod Lua ERROR sharedPopUp: CurrentButtonFunc "..tostring(CurrentlyUsedBy).." is has no function: "..tostring(fn))
        g_LuaTools.modlog("Mod Lua ERROR sharedPopUp: CurrentButtonFunc "..tostring(CurrentlyUsedBy).." is has no function: "..tostring(fn),ModID)
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
      LoopIsRunning = false,
      PopUp_Queue = {},
      PopUpsStatus_NToShow = 0, -- internal use to find out if all popups are registered
    }

    
    system.start(function()
      while g_OnGameLeave_serp==nil do
        coroutine.yield()
      end
      if g_OnGameLeave_serp[ModID]==nil then
        g_OnGameLeave_serp[ModID] = function()
          g_shared_PopUp_Serp = nil -- stop everything (might crash some currently running functions, but I think its ok)
        end
      end
    end)
    
    system.start(function()
      g_LuaTools.waitForTimeDelta(5000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)

end