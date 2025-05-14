
-- ###################################################
-- ###################################################

-- Unfortunately there is no xml event (which works) to fire on every savegame load. So most mods execute their stuff on SessionEnter, but this fires quite often.
-- Use xml Unlock to use this mod as savegameloaded event.
-- use lua to use the on game left event.

-- My Execute_SavegameLoadedEvent unlocks a FeatureUnlock ~1 second after a savegame was loaded (and locks it directly again). 
-- (It may be the very same game though, eg. go to main menu and back into game).
-- it is for sure better to execute your possibly expensive code with help of this event, instead on every single SessionEnter, if it is enough to call it once per savegame load
 -- If your code is not expensive, you can of course simply call it on your own once per SessionEnter, if that is no problem.

-- ###################


-- Important info for "event." from the game:
   -- If a function you call within that event causes an error, the game will crash without printing this error to the lua log!
   -- So better always use pcall in them

-- This script will be called on every SessionEnter. Keep this in mind when changing code, you might want to add it within the if statement instead for one time per Anno start execution


local LoadingScreenLeft_ID = 60
-- this integer is passed with the games OnLeaveUIState event whenever we leave the loading screen.
-- It also happens when we went from within a SP game to the main menu and then again back into the same game, so its not a 100% "load game"!

local GameLeft_ID = 63 -- or 170/171, but 63 fits more and they all 3 are shown at the same moments

local SessionViewLeft_ID = 151 -- entering ingame menus or also going back to main menu. Use it for SetSetGameSpeed to prevent problems with coroutines


local ModID = "shared_LuaOnGameLoaded_Serp"


-- TODO:
 -- testen multiplayer mit gamespeed 2, laden, verlassen und menü öffnen
  -- ob zb verlassen ohne t_ExecuteFnWithArgsForPeers zu problemem führt




local function t_OnGameLoaded(withwait)
  if ts.GameSetup.GetIsMultiPlayerGame() then -- singleplayer uses a different system (ts.Pause.DecreaseGameSpeed) and the buttons in menu we dont have any access to. If we use SetSetGameSpeed in SP, the gamespeeed will be different from what the buttons show... for multiplayer its more important anyways, since this has issues leaving the game on slow speed
    ts.GameClock.SetSetGameSpeed(3) -- normal gamespeed, coroutines can have trouble on slower speed in some menues
  end
  if withwait then -- very first execution needs no wait, because the first execution is after SessionEnter, so players are already ingame
    -- use a delay (at least 0.7 second), because multiplayer needs this for the code to be executed already ingame (because LeaveUIState fires too fast there)
    system.waitForGameTimeDelta(700)
  end
  g_LuaScriptBlockers = {} -- also reset these tables on game load
  g_OnGameLeave_serp = {}
  ts.Unlock.SetUnlockNet(1500004636) -- Execute_SavegameLoadedEvent, unlock this FeatureUnlock to notify other mods
end


local function Do_OnLeaveUIState(UILeft_ID)

  if UILeft_ID == LoadingScreenLeft_ID then
    g_LuaTools.modlog("LoadingScreenLeft",ModID)
    g_LuaTools.start_thread("LoadingScreenLeft Execute_SavegameLoadedEvent",ModID,t_OnGameLoaded,true)
  elseif UILeft_ID == GameLeft_ID then -- also when just going to main menu and then back to the game (just like LoadingScreenLeft_ID)
    g_LuaTools.modlog("GameLeft",ModID)
    -- we can not use Triggers/Unlocks here, because game gets closed. So we will use global table g_OnGameLeave_serp
    if ts.GameSetup.GetIsMultiPlayerGame() then -- singleplayer uses a different system (ts.Pause.DecreaseGameSpeed) and the buttons in menu we dont have any access to. If we use SetSetGameSpeed in SP, the gamespeeed will be different from what the buttons show... for multiplayer its more important anyways, since this has issues leaving the game on slow speed
      ts.GameClock.SetSetGameSpeed(3) -- normal gamespeed, coroutines can have trouble on slower speed in some menues
    end
    for id,fn in pairs(g_OnGameLeave_serp) do
      if fn~=nil and type(fn)=="function" then
        local status, err = pcall(fn)
        if status==false then -- error
          print("ERROR OnGameLeave: Function from mod "..tostring(id).." had an error: "..tostring(err))
          g_LuaTools.modlog("ERROR OnGameLeave: Function from mod "..tostring(id).." had an error: "..tostring(err),ModID)
        end
      else
        print("ERROR OnGameLeave: Function from mod "..tostring(id).." is no function: "..tostring(fn))
        g_LuaTools.modlog("ERROR OnGameLeave: Function from mod "..tostring(id).." is no function: "..tostring(fn),ModID)
      end
    end
    
    g_LuaTools.StopAllThreads()
  elseif UILeft_ID == SessionViewLeft_ID then
    if ts.GameSetup.GetIsMultiPlayerGame() and g_CurrentClock_GameSpeed_Serp < 3 and g_ObjectFinderSerp~=nil then -- singleplayer uses a different system (ts.Pause.DecreaseGameSpeed) and the buttons in menu we dont have any access to. If we use SetSetGameSpeed in SP, the gamespeeed will be different from what the buttons show... for multiplayer its more important anyways, since this has issues leaving the game on slow speed
      g_LuaTools.start_thread("SessionViewLeft SetSetGameSpeed",ModID,g_ObjectFinderSerp.t_ExecuteFnWithArgsForPeers,"ts.GameClock.SetSetGameSpeed",nil,nil,"Everyone",3)
      ts.GameClock.SetSetGameSpeed(3) -- also call it directly for local, to minimize Menu problems, since t_ExecuteFnWithArgsForPeers takes some seconds and is a thread itself which gets problems on low speed
      ts.Unlock.SetUnlockNet(1500004525) -- notification that speed was changed by mod
    end
  end

end

if event.OnLeaveUIState[ModID] == nil then -- only add it once
  
  g_OnGameLeave_serp = {} -- global table where other mods can add their functions to.
  if g_LuaTools==nil then
    console.startScript("data/scripts_serp/luatools.lua")
  end
  
  g_LuaTools.modlog("Register OnLeaveUIState",ModID)
  
  -- define a global variable early (before other scripts are executed with help of this mod)
  -- This can be used by other mods to be used like g_LuaScriptBlockers[ModID] = true/nil
  -- When you add your script with ActionExecuteScript to the xml 1500004636 FeatureUnlock, then it will be executed for every Human Participant in Multiplayer,
   -- causing your script to be executed multiple times also for the local player.
    -- To make sure your script is only executed once per load per local player, you can check and define g_LuaScriptBlockers.MyMod = true
     -- and set it to nil again within a thread after eg. 5000 ms, to be unblocked for the next game loading. 
  g_LuaScriptBlockers = {}
  
  event.OnLeaveUIState[ModID] = function(UILeft_ID)
    local status, err = pcall(Do_OnLeaveUIState,UILeft_ID) -- use seperate function with pcall, because game crashes without lua error, if any error happens in an function called by event. !
    if status==false then -- error
      print(ModID,"ERROR OnLeaveUIState: Function Do_OnLeaveUIState had an error: "..tostring(err))
      g_LuaTools.modlog("ERROR OnLeaveUIState: Function Do_OnLeaveUIState had an error: "..tostring(err),ModID)
    end
  end
  
  g_CurrentClock_GameSpeed_Serp = 3 -- only useable in Multiplayer (SP uses an unaccesable system with its buttons...) and only relevant if using the Gamespeed mod for Multiplayer
  local SetSetGameSpeed_old = ts.GameClock.SetSetGameSpeed -- overwriting this to be notified whenever it is called anywhere, even other mods
  ts.GameClock.SetSetGameSpeed = function(new) -- no need to do it for IncreaseGameSpeed/DecreaseGameSpeed because they dont work well anyways (once slowest is reached, you can not increase anymore, so no modder should use them anyways)
    print("SetSetGameSpeed called with:",new)
    g_CurrentClock_GameSpeed_Serp = new
    return SetSetGameSpeed_old(new)
  end
  
  -- The first time this script is called with help of SessionEnter, it will already be too late for the very first OnLeaveUIState,
   -- because right now we can only execute lua with help of xml, while xml is not yet available when we first enter the main menu or are in the first loading screen
    -- that means if Do_OnLeaveUIState was not yet added, Anno was just recently started, so the first SessionEnter for sure means a savegame was loaded.
    -- after that, the lua event.OnLeaveUIState will continue to work outside of a savegame, so also in main menu, so checking for LoadingScreenLeft_ID is enough then, to catch another savegame load without restarting the whole game
  g_LuaTools.start_thread("LoadingScreenLeft Execute_SavegameLoadedEvent",ModID,t_OnGameLoaded)
  
end




-- ######################################################################
-- ######################################################################
-- ######################################################################

-- below my tests what UILeft_ID the game uses:


-- Testwerte von LeaveUIState:
-- Problem ist an sich nur, dass für das erstmalige registern ein tirgger notwendig ist, welcher erst im spiel, nach dem Laden verfügbar ist
 -- Aber nachdem event einmal registered wurde, funzt es auch weiterhin und auch im hautpmenü, solange spiel nicht neu gestartet wird
 -- dh wir können evtl. erkennen, wenn ein spieler schon im spiel ist und ein weiteres/anderes savegame läd und in so einem Fall
  -- alle lua Werte resetten, die in einem potentiell anderem savegame nochmal geprüft werden sollen

-- On Leave UIState Test mit Singleplayer Spielstand

-- registered OnLeaveUIState


-- 151 kommt wenn man von Session in Statistikmenü/handelsrouten/Diplo wechselt (und auch bei zurück zum Hauptmenü)-> SessionView left oderso? (wobei es nicht bei worldmap kommt)
-- 176 wenn man statistikmenü wieder verlässt
-- Handelsroutenmenü ist 165 oder 177
-- EinflussFenster ist 52
-- Errungenschaften UI ist 0
-- Stadt Attraktivität ist 3
-- Diplo menü ist 29, 142 Spielstand-Laden-Menü im Spiel
-- Schiff angeklickt GUI: 119
-- Annopedia 174 , Optionsmenü 129, ESC Menü 132
-- 116 Bauernhaus, 103 Marktplatz, 102 Kontor/Lagerhaus,97 handelskammer UI, 113 Kirche, 120 Werft
-- close any PopUp (delete and so on): 181

-- SP zu Main Menü, nur unterschied was nichts anderes Bekanntes ist:
-- OnLeaveUIState: 63
-- OnLeaveUIState: 171
-- OnLeaveUIState: 170
-- Da 174/177/165 eher so Handelsroute/Annopedia usw ist, und 60 LeaveLoadingScreen, 
 -- würde es von der Größenordnung eher passen, dass 63 dann leavegame ist..



-- von session in worldmap
-- OnLeaveUIState: 50
-- OnLeaveUIState: 54
-- OnLeaveUIState: 66
-- OnLeaveUIState: 128
-- OnLeaveUIState: 125
-- OnLeaveUIState: 127
-- OnLeaveUIState: 126
-- OnLeaveUIState: 164
-- OnLeaveUIState: 13
-- OnLeaveUIState: 45
-- OnLeaveUIState: 39

-- wieder in session
-- OnLeaveUIState: 197
-- OnLeaveUIState: 39

-- von SP Spiel zum hauptmenü
-- OnLeaveUIState: 63
-- OnLeaveUIState: 171
-- OnLeaveUIState: 170
-- OnLeaveUIState: 45
-- OnLeaveUIState: 50
-- OnLeaveUIState: 54
-- OnLeaveUIState: 66
-- OnLeaveUIState: 128
-- OnLeaveUIState: 125
-- OnLeaveUIState: 127
-- OnLeaveUIState: 126
-- OnLeaveUIState: 164
-- OnLeaveUIState: 151
-- OnLeaveUIState: 13
-- OnLeaveUIState: 132
-- OnLeaveUIState: 41

-- wieder ins spiel
-- OnLeaveUIState: 82
-- OnLeaveUIState: 184
-- OnLeaveUIState: 173
-- OnLeaveUIState: 59
-- OnLeaveUIState: 60
-- OnLeaveUIState: 191

-- zum "Spiel laden" screen direkt ohne hauptmenü
-- OnLeaveUIState: 151

-- spielstand laden aus spiel heraus (Ladebildschirm):
-- OnLeaveUIState: 142
-- OnLeaveUIState: 59
-- OnLeaveUIState: 63
-- OnLeaveUIState: 171
-- OnLeaveUIState: 170
-- OnLeaveUIState: 45
-- OnLeaveUIState: 50
-- OnLeaveUIState: 54
-- OnLeaveUIState: 66
-- OnLeaveUIState: 128
-- OnLeaveUIState: 125
-- OnLeaveUIState: 127
-- OnLeaveUIState: 126
-- OnLeaveUIState: 164
-- OnLeaveUIState: 68
-- OnLeaveUIState: 180
-- OnLeaveUIState: 41
-- OnLeaveUIState: 13
-- OnLeaveUIState: 132
-- OnLeaveUIState: 151

-- von Ladebildschirm in Session (Segel setzen)
-- OnLeaveUIState: 60
-- OnLeaveUIState: 59

-- vom Hauptmenü zum "spiel laden"
-- OnLeaveUIState: 184
-- OnLeaveUIState: 191

-- spielstand laden (Ladebildschirm) aus Hauptmenü:
-- OnLeaveUIState: 142
-- OnLeaveUIState: 82
-- OnLeaveUIState: 173
-- OnLeaveUIState: 59
-- OnLeaveUIState: 68
-- OnLeaveUIState: 180
-- OnLeaveUIState: 41

-- von Ladebildschirm in Session (Segel setzen)
-- OnLeaveUIState: 60
-- OnLeaveUIState: 59

-- #####

-- Multiplayer (ist etwas anders, weil man da das spiel komplett verlässt, wenn man aus dem spiel ins hjauptmenü oder zu den savegames geht)

-- Vom Hauptmenü-Ladebildschrim auswählen eines Multiplayer-Savegames und dadurch öffnen der MP-Lobby
-- OnLeaveUIState: 142
-- OnLeaveUIState: 68
-- OnLeaveUIState: 180
-- OnLeaveUIState: 41

-- MP spielstand laden (Ladebildschirm) aus Hauptmenü:
-- OnLeaveUIState: 82
-- OnLeaveUIState: 72
-- OnLeaveUIState: 173
-- OnLeaveUIState: 59

-- von Ladebildschirm in Session (Segel setzen)
-- OnLeaveUIState: 60
-- OnLeaveUIState: 59

-- von MP Spiel in ESC-Menü auswählen von "Spiel laden", was einen aus dem Spiel wirft und in den Bildschirm zum auswählen der savegames schickt
-- OnLeaveUIState: 181
-- OnLeaveUIState: 180
-- OnLeaveUIState: 41
-- OnLeaveUIState: 63
-- OnLeaveUIState: 171
-- OnLeaveUIState: 170
-- OnLeaveUIState: 45
-- OnLeaveUIState: 50
-- OnLeaveUIState: 54
-- OnLeaveUIState: 66
-- OnLeaveUIState: 128
-- OnLeaveUIState: 125
-- OnLeaveUIState: 127
-- OnLeaveUIState: 126
-- OnLeaveUIState: 9
-- OnLeaveUIState: 82
-- OnLeaveUIState: 184
-- OnLeaveUIState: 173
-- OnLeaveUIState: 59
-- OnLeaveUIState: 164
-- OnLeaveUIState: 191
-- OnLeaveUIState: 151
-- OnLeaveUIState: 13
-- OnLeaveUIState: 132
-- OnLeaveUIState: 190

-- MP savegame auswählen und in MP Lobby
-- OnLeaveUIState: 142
-- OnLeaveUIState: 68
-- OnLeaveUIState: 180
-- OnLeaveUIState: 41

-- MP spielstand laden (Ladebildschirm):
-- OnLeaveUIState: 82
-- OnLeaveUIState: 72
-- OnLeaveUIState: 173
-- OnLeaveUIState: 59

-- von Ladebildschirm in Session (Segel setzen)
-- OnLeaveUIState: 60
-- OnLeaveUIState: 59

-- Von MP Spiel zurück ins Hauptmenü
-- OnLeaveUIState: 181
-- OnLeaveUIState: 180
-- OnLeaveUIState: 41
-- OnLeaveUIState: 63
-- OnLeaveUIState: 171
-- OnLeaveUIState: 170
-- OnLeaveUIState: 45
-- OnLeaveUIState: 50
-- OnLeaveUIState: 54
-- OnLeaveUIState: 66
-- OnLeaveUIState: 128
-- OnLeaveUIState: 125
-- OnLeaveUIState: 127
-- OnLeaveUIState: 126
-- OnLeaveUIState: 9
-- OnLeaveUIState: 82
-- OnLeaveUIState: 184
-- OnLeaveUIState: 173
-- OnLeaveUIState: 59
-- OnLeaveUIState: 164
-- OnLeaveUIState: 191
-- OnLeaveUIState: 151
-- OnLeaveUIState: 13
-- OnLeaveUIState: 132
-- OnLeaveUIState: 190
-- OnLeaveUIState: 59


-- ###############################