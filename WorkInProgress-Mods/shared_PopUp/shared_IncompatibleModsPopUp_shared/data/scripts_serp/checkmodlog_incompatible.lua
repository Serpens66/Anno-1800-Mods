
local ModID = "shared_IncompatibleModsPopUp"

if g_LuaScriptBlockers[ModID]==nil then
  
    -- block it directly at start of the script (to prevent ActionExecuteScript to call this multiple times per local player)
    g_LuaScriptBlockers[ModID] = true
    
    
    print("checkmodlog_incompatible.lua registered")


    if g_LTL_Serp==nil then
      console.startScript("data/scripts_serp/lighttools.lua")
    end
    g_LTL_Serp.modlog("checkmodlog_incompatible.lua registered",ModID)

    -- #######################################################################################

    -- Read out modlog to see if there are any incompatible mods loaded and save it into incompatible_string

    console.startScript("data/scripts/search_modlog_pnski.lua") -- listIncompatible_Pnski

    local incompatible_string = ""
    -- in mod-loader.log eg. "[2024-08-15 22:35:39.877] [error] [Gameplay] testmod is incompatible with: shared_IncompatibleModsPopUp"
    -- mod1 is a ModName, while mod2 is a ModID
    local inc_mods_list = listIncompatible_Pnski()
    local inc_mods_count = #inc_mods_list
    for _,modpair in pairs(inc_mods_list) do
      if inc_mods_count<=8 then -- we can only display roughly 33 rows in the popoup (~40 in total, but we already use some lines)
        incompatible_string = incompatible_string..modpair[1].."\n!/!\n"..modpair[2].."\n\n"
      elseif inc_mods_count<=15 then
        incompatible_string = incompatible_string..modpair[1].."  !/!  "..modpair[2].."\n\n"
      else
        incompatible_string = incompatible_string.."- "..modpair[1].."  !/!  "..modpair[2].."\n"
      end
    end

    -- #######################################################################################
    -- #######################################################################################
    -- shared PopUp part

    -- start the script if not already done by another mod
    if g_shared_PopUp_Serp==nil then
      print("checkmodlog_incompatible.lua ERROR: g_shared_PopUp_Serp is missing!")
      g_LTL_Serp.modlog("checkmodlog_incompatible.lua ERROR: g_shared_PopUp_Serp is missing!",ModID)
    end

    -- button can be integer 1,2 or 3
    local function sharedPopUp_ButtonHit_IncompatibleMods(button,CurrentlyUsedBy)
      if CurrentlyUsedBy == "IncompatibleMods" then -- only if used by our mod. this check is not needed anymore, since we forward this function only for this popup
        if button==1 then -- other buttons do nothing
          GameManager.OnlineManager.leaveSession()
        end
      end
      -- print(button)
    end

    if incompatible_string ~="" then
      print("incompatible mods detected, showing PopUp now")
      g_LTL_Serp.modlog("incompatible mods detected, showing PopUp now",ModID)
      local header = ts.GetAssetData(1500005500).Text
      local body = ts.GetAssetData(1500005501).Text
      body = body..incompatible_string..tostring(ts.GetAssetData(1500005502).Text) -- add more to the body string
      local ButtonFunc = sharedPopUp_ButtonHit_IncompatibleMods
      local Identifier = "IncompatibleMods"
      local Unlock = 1500005501 -- every mod needs their own FeatureUnlock to show the PopUp
      
      g_shared_PopUp_Serp.ShowPopup(header,body,ButtonFunc,Identifier,Unlock)
    end

    g_LTL_Serp.start_thread("g_LuaScriptBlockers",ModID,function()
      g_LTL_Serp.waitForTimeDelta(1000) -- unblock it again, so it can be executed the next time we load a game
      g_LuaScriptBlockers[ModID] = nil
    end)
    
end