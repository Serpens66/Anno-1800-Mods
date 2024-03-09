
-- ###################################################

-- HOW TO USE: lua code for register_onsavegameload.lua, copy paste it into your script (see example xml code in assets.xml):
-- Note: you can not call local variables/functions within OnSaveGameLoad function

 -- enter your ModID here for unqiue identifier. Change the content of "OnSaveGameLoad" to your liking.
-- local ModID = "My_ModID"
-- local function OnSaveGameLoad()
  -- ts.Economy.MetaStorage.AddAmount(1010017, 100000)
-- end

-- g_saveloaded_events_serp = g_saveloaded_events_serp or {} -- global table where mods can add their functions to (define it if it does not exist yet)
-- if g_saveloaded_events_serp[ModID]==nil then
  -- g_saveloaded_events_serp[ModID] = OnSaveGameLoad
-- end

-- Add functions to 
-- g_saveloaded_events_reset_serp
-- which should be called as soon as possible (without 1 second delay) that should only be used to reset your lua variables, not to interact with the game

-- ###################################################
-- ###################################################

-- Unfortunately there is no xml event (which works) to fire on every savegame load. So most mods execute their stuff on SessionEnter, but this fires quite often.

-- My Execute_SavegameLoadedEvent function calls all event-functions added by other mods, 1 second after a savegame was loaded. 
-- (It may be the very same game though, eg. go to main menu and back into game).
-- it is for sure better to execute your possibly expensive code with help of this event, instead on every single SessionEnter, if it is enough to call it once per savegame load
 -- If your code is not expensive, you can of course simply call it on your own once per SessionEnter, if that is no problem.

-- My major usecase would be my shared_LuaCoopLeader mod, where I want to show a PopUp on every game load to ask the player who is the CoopLeader
-- it sucks if this PopUp appears on every SessionEnter, so I use this shared_LuaOnGameLoaded as helper

-- In theory it also works fine if mods wanting to use this, directly use the event.LeaveUIState instead of this g_saveloaded_events_serp construct.
-- but: the 1 second delay which is needed here, is also needed when directly using it, at least for multiplayer where the LeaveUIState==60 fires a bit too early for code to take effect in the game.
-- advantage of using event. would be of course to being able to call local functions/variables (although I wonder why this is possible here, but not in other mods using my event)


g_saveloaded_events_serp = g_saveloaded_events_serp or {} -- global table where other mods can add their functions to
g_saveloaded_events_reset_serp = g_saveloaded_events_reset_serp or {}

local LoadingScreenLeft_ID = 60
-- this integer is passed with the games OnLeaveUIState event whenever we leave the loading screen.
-- It also happens when we went from within a SP game to the main menu and then again back into the same game.



local function Execute_SavegameLoadedEvent()
  -- modlog("Execute_SavegameLoadedEvent")
  -- wait 1 second, to make sure other mods added their functions to g_saveloaded_events_serp already. And also on every call from g_OnLeaveUIState_serp use a delay (at least 1 second), because multiplayer needs this for the code to be executed already ingame (because LeaveUIState fires too fast there)
  system.waitForGameTimeDelta(1000)
  for id,fn in pairs(g_saveloaded_events_serp) do
    if fn~=nil and type(fn)=="function" then
      local status, err = pcall(fn)
      if status==false then -- error
        print("Mod Lua Error SavegameLoadedEvent: Function from mod "..tostring(id).." had an error: "..tostring(err))
        -- pcall(modlog,"Mod Lua Error SavegameLoadedEvent: Function from mod "..tostring(id).." had an error: "..tostring(err))
      end
    else
      print("Mod Lua Error SavegameLoadedEvent: Function from mod "..tostring(id).." has no function: "..tostring(fn))
    end
  end
end

-- this calls functions as soon as possible without delay, where you should reset your lua variables for the new savegame. do not interact with the game here, it might be too early
-- is only called if another savegame is loaded without starting the anno game new (on starting anno game everything is nil already automatically)
-- this way it is also called before a SessionEnter Trigger fires (but not before an AlwaysTrue Trigger, so better dont use AlwaysTrue to start your scripts)
local function Execute_SavegameLoadedEvent_RESET()
  for id,fn in pairs(g_saveloaded_events_reset_serp) do
    if fn~=nil and type(fn)=="function" then
      local status, err = pcall(fn)
      if status==false then -- error
        print("Mod Lua Error SavegameLoadedEvent_RESET: Function from mod "..tostring(id).." had an error: "..tostring(err))
        -- pcall(modlog,"Mod Lua Error SavegameLoadedEvent: Function from mod "..tostring(id).." had an error: "..tostring(err))
      end
    else
      print("Mod Lua Error SavegameLoadedEvent_RESET: Function from mod "..tostring(id).." has no function: "..tostring(fn))
    end
  end
end



local function g_OnLeaveUIState_serp(UILeft_ID)
  if UILeft_ID == LoadingScreenLeft_ID then
    -- modlog("g_OnLeaveUIState_serp")
    if next(g_saveloaded_events_reset_serp) then
      system.start(Execute_SavegameLoadedEvent_RESET)
    end
    if next(g_saveloaded_events_serp) then
      system.start(Execute_SavegameLoadedEvent)
    end
  end
end

if event.OnLeaveUIState["shared_LuaOnGameLoaded_Serp"] == nil then -- only add it once
  event.OnLeaveUIState["shared_LuaOnGameLoaded_Serp"] = g_OnLeaveUIState_serp
  
  -- The first time this script is called with help of SessionEnter, it will already be too late for the very first OnLeaveUIState,
   -- because right now we can only execute lua with help of xml, while xml is not yet available when we first enter the main menu or are in the first loading screen
    -- that means if g_OnLeaveUIState_serp was not yet added, Anno was just recently started, so the first SessionEnter for sure means a savegame was loaded.
    -- after that, the lua event.OnLeaveUIState will continue to work outside of a savegame, so also in main menu, so checking for LoadingScreenLeft_ID is enough then, to catch another savegame load without restarting the whole game
  -- modlog("register OnLeaveUIState")
  if next(g_saveloaded_events_serp) then
    system.start(Execute_SavegameLoadedEvent)
  end
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

-- spielstand laden (Ladebildschirm):
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

-- von SP spiel ins hauptmenü
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