-- print("cheatkeybinds_serp.lua: called")


CheatKeybinds_Serp = {
  voice_every_x_ms = 300000, -- set this to false to disable the voice messages about cheating
  translations = {
    [0] = { -- "english"
      [1] = "<b>Console</b>\nConsole to execute lua commands.",
      [2] = "<b>Fast Ships On/Off</b>\nUnits of all players worldwide get super fast",
      [3] = "<b>Buffed Ships</b>\nAll your ships get much stronger and loading faster",
      [4] = "<b>Add Coins</b>\nCredits you 100k coins",
      [5] = "<b>Specific Good</b>\nAdds 1000 of the good you last hovered over -if it was a good- to the current island",
      [6] = "<b>All Goods</b>\nAdds 1000 of all unlocked goods to the current island",
      [7] = "<b>Move In</b>\nFills all residences of current island to the maximum",
      [8] = "<b>Ignore Build Costs On/Off</b>\nYou can build everything without material. But costs are still substracted and you can go bankrupt",
      [9] = "<b>Enable All Upgrades On/Off</b>\nAllows you to upgrade everything without meeting the requirements",
      [10] = "<b>Free Electricity On/Off</b>\nAll factories/shipyards have electricity",
      [11] = "<b>Add Fertility</b>\nAdds the fertility needed for the currently selected building to the island of that building",
      [12] = "<b>Attractivity</b>\nAdds +100 attractivity to the current island",
      [13] = "<b>Complete Ship</b>\nCompletes instantly the production of the current ship in the selected shipyard",
      [14] = "<b>Complete Monument</b>\nCompletes a portion of buildig phase of selected monument. May execute multiple times to finish the current building phase",
      [15] = "<b>Complete Expedition</b>\nCompletes all current active Expeditions instantly",
      [16] = "<b>Add researchpoints</b>\nCredits you 10k researchpoints",
      [17] = "<b>Complete Research</b>\nCompletes the current research instantly",
      [18] = "<b>Major Discoveries</b>\nCredits you 1 of every major discovery",
      [19] = "<b>Random Items</b>\nAdds a number of random items to the current island",
      [20] = "<b>Specific Item</b>\nAdds the Item you last hovered over -if it was an item- to the current island.\nAlso works in statistic menu!",
      [21] = "<b>Add Reputation</b>\nGet +10 reputation from the owner -AI- of the currently selected object\n-DESYNC in multiplayer-",
      [22] = "<b>Change Owner Object</b>\nTake over control of the currently selected object\n-DESYNC in multiplayer-",
      [23] = "<b>Control AI</b>\nTake control over another player, the owner of the currently selected object\n-Multiplayer unknown-",
      [24] = "<b></b>\n",
      [25] = "<b></b>\n",
      [26] = "<b></b>\n",
      [27] = "<b></b>\n",
      [28] = "<b></b>\n",
      [29] = "<b></b>\n",
      [30] = "<b></b>\n",
    },
    [1] = { -- "french"
      -- [1] = "<b></b>\n",
      -- [2] = "<b></b>\n",
      -- [3] = "<b></b>\n",
      -- [4] = "<b></b>\n",
      -- [5] = "<b></b>\n",
      -- [6] = "<b></b>\n",
      -- [7] = "<b></b>\n",
      -- [8] = "<b></b>\n",
      -- [9] = "<b></b>\n",
      -- [10] = "<b></b>\n",
      -- [11] = "<b></b>\n",
      -- [12] = "<b></b>\n",
      -- [13] = "<b></b>\n",
      -- [14] = "<b></b>\n",
      -- [15] = "<b></b>\n",
      -- [16] = "<b></b>\n",
      -- [17] = "<b></b>\n",
      -- [18] = "<b></b>\n",
      -- [19] = "<b></b>\n",
      -- [20] = "<b></b>\n",
      -- [21] = "<b></b>\n",
      -- [22] = "<b></b>\n",
      -- [23] = "<b></b>\n",
      -- [24] = "<b></b>\n",
      -- [25] = "<b></b>\n",
      -- [26] = "<b></b>\n",
      -- [27] = "<b></b>\n",
      -- [28] = "<b></b>\n",
      -- [29] = "<b></b>\n",
      -- [30] = "<b></b>\n",
    },
    [2] = { -- "polish"
      -- [1] = "<b></b>\n",
      -- [2] = "<b></b>\n",
      -- [3] = "<b></b>\n",
      -- [4] = "<b></b>\n",
      -- [5] = "<b></b>\n",
      -- [6] = "<b></b>\n",
      -- [7] = "<b></b>\n",
      -- [8] = "<b></b>\n",
      -- [9] = "<b></b>\n",
      -- [10] = "<b></b>\n",
      -- [11] = "<b></b>\n",
      -- [12] = "<b></b>\n",
      -- [13] = "<b></b>\n",
      -- [14] = "<b></b>\n",
      -- [15] = "<b></b>\n",
      -- [16] = "<b></b>\n",
      -- [17] = "<b></b>\n",
      -- [18] = "<b></b>\n",
      -- [19] = "<b></b>\n",
      -- [20] = "<b></b>\n",
      -- [21] = "<b></b>\n",
      -- [22] = "<b></b>\n",
      -- [23] = "<b></b>\n",
      -- [24] = "<b></b>\n",
      -- [25] = "<b></b>\n",
      -- [26] = "<b></b>\n",
      -- [27] = "<b></b>\n",
      -- [28] = "<b></b>\n",
      -- [29] = "<b></b>\n",
      -- [30] = "<b></b>\n",
    },
    [3] = { -- "russian"
      -- [1] = "<b></b>\n",
      -- [2] = "<b></b>\n",
      -- [3] = "<b></b>\n",
      -- [4] = "<b></b>\n",
      -- [5] = "<b></b>\n",
      -- [6] = "<b></b>\n",
      -- [7] = "<b></b>\n",
      -- [8] = "<b></b>\n",
      -- [9] = "<b></b>\n",
      -- [10] = "<b></b>\n",
      -- [11] = "<b></b>\n",
      -- [12] = "<b></b>\n",
      -- [13] = "<b></b>\n",
      -- [14] = "<b></b>\n",
      -- [15] = "<b></b>\n",
      -- [16] = "<b></b>\n",
      -- [17] = "<b></b>\n",
      -- [18] = "<b></b>\n",
      -- [19] = "<b></b>\n",
      -- [20] = "<b></b>\n",
      -- [21] = "<b></b>\n",
      -- [22] = "<b></b>\n",
      -- [23] = "<b></b>\n",
      -- [24] = "<b></b>\n",
      -- [25] = "<b></b>\n",
      -- [26] = "<b></b>\n",
      -- [27] = "<b></b>\n",
      -- [28] = "<b></b>\n",
      -- [29] = "<b></b>\n",
      -- [30] = "<b></b>\n",
    },
    [4] = { -- "spanish"
      -- [1] = "<b></b>\n",
      -- [2] = "<b></b>\n",
      -- [3] = "<b></b>\n",
      -- [4] = "<b></b>\n",
      -- [5] = "<b></b>\n",
      -- [6] = "<b></b>\n",
      -- [7] = "<b></b>\n",
      -- [8] = "<b></b>\n",
      -- [9] = "<b></b>\n",
      -- [10] = "<b></b>\n",
      -- [11] = "<b></b>\n",
      -- [12] = "<b></b>\n",
      -- [13] = "<b></b>\n",
      -- [14] = "<b></b>\n",
      -- [15] = "<b></b>\n",
      -- [16] = "<b></b>\n",
      -- [17] = "<b></b>\n",
      -- [18] = "<b></b>\n",
      -- [19] = "<b></b>\n",
      -- [20] = "<b></b>\n",
      -- [21] = "<b></b>\n",
      -- [22] = "<b></b>\n",
      -- [23] = "<b></b>\n",
      -- [24] = "<b></b>\n",
      -- [25] = "<b></b>\n",
      -- [26] = "<b></b>\n",
      -- [27] = "<b></b>\n",
      -- [28] = "<b></b>\n",
      -- [29] = "<b></b>\n",
      -- [30] = "<b></b>\n",
    },
    [5] = { -- "german
      [1] = "<b>Konsole</b>\nKonsole für diverse lua Befehle",
      [2] = "<b>Schnelle Schiffe Ein/Aus</b>\nWeltweilt werden Einheiten aller Spieler sehr schnell",
      [3] = "<b>Schiffs Buff Ein/Aus</b>\nAll Eure Schiffe werden deutlich stärker und entladen schneller",
      [4] = "<b>Münzen zufügen</b>\nSchreibt Euch 100k Münzen gut",
      [5] = "<b>Bestimmtes Gut</b>\nFügt 1000 eines Gutes über das Ihr zuletzt mit der Maus gefahren seid -falls es ein Gut war- der aktuellen Insel hinzu",
      [6] = "<b>Alle Güter</b>\nFügt 1000 von allen freigeschalteten Gütern der aktuellen Insel hinzu",
      [7] = "<b>Einziehen</b>\nFüllt alle Wohnhäuser der aktuellen Insel bis zum Maximum",
      [8] = "<b>Ignoriere Baukosten Ein/Aus</b>\nIhr könnt alles ohne Material bauen. Aber die Kosten werden weiterhin abgezogen und Ihr könnt banktrott gehen",
      [9] = "<b>Erlaube Ausbauen Ein/Aus</b>\nErlaubt es alles auszubauen ohne die Bedinungen zu erfüllen",
      [10] = "<b>Elektrizität Ein/Aus</b>\nAlle Fabriken/Werften haben Elektrizität",
      [11] = "<b>Fruchtbarkeit</b>\nFügt die Fruchtbarkeit, die für das aktuell angewählte Gebäude nötig ist, der Insel des Gebäudes hinzu",
      [12] = "<b>Attraktivität</b>\nFügt der aktuellen Insel +100 Attraktivität hinzu",
      [13] = "<b>Schiff fertigstellen</b>\nStellt das aktuell zu bauende Schiff in der angewählten Werft sofort fertig",
      [14] = "<b>Monument fertigstellen</b>\nStellt einen Teil der Bauphase des angewählten Monumentes fertig. Evtl. mehrfach Aktivieren nötig",
      [15] = "<b>Expedition beenden</b>\nBeendet alle aktiven Expeditionen sofort erfolgreich",
      [16] = "<b>Forschungspunkte zufügen</b>\nSchreibt Euch 10k Forschungspunkte gut",
      [17] = "<b>Forschung fertigstellen</b>\nBeendet die aktuelle Forschung sofort erfolgreich",
      [18] = "<b>Bahnbrechende Entdeckungen</b>\nSchreibt Euch 1 von jeder bahnbrechender Entdeckung gut",
      [19] = "<b>Zufällige Items zufügen</b>\nFügt der aktuellen Insel einige zufällige Items hinzu",
      [20] = "<b>Bestimmtes Item</b>\nFügt der aktuellen Insel das Item hinzu über das Ihr zuletzt mit der Maus gefahren seid -falls es ein Item war-.\nFunktioniert auch im Statistikmenü",
      [21] = "<b>Ruf verbessern</b>\nBekomme +10 Ruf bei dem Besitzer -KI- des aktuell angewählten Objektes\n-DESNYC im Multiplayer-",
      [22] = "<b>Ändere Besitzer</b>\nÜbernimm die Kontrolle über das aktuell angewählte Objekt\n-DESNYC im Multiplayer-",
      [23] = "<b>Kontrolliere KI</b>\nÜbernimmt die Kontrolle über einen anderen Spieler, den Besitzer des aktuell angewählten Objektes\n-Multiplayer unbekannt",
      [24] = "<b></b>\n",
      [25] = "<b></b>\n",
      [26] = "<b></b>\n",
      [27] = "<b></b>\n",
      [28] = "<b></b>\n",
      [29] = "<b></b>\n",
      [30] = "<b></b>\n",
    },
    [6] = { -- "chinese"
      -- [1] = "<b></b>\n",
      -- [2] = "<b></b>\n",
      -- [3] = "<b></b>\n",
      -- [4] = "<b></b>\n",
      -- [5] = "<b></b>\n",
      -- [6] = "<b></b>\n",
      -- [7] = "<b></b>\n",
      -- [8] = "<b></b>\n",
      -- [9] = "<b></b>\n",
      -- [10] = "<b></b>\n",
      -- [11] = "<b></b>\n",
      -- [12] = "<b></b>\n",
      -- [13] = "<b></b>\n",
      -- [14] = "<b></b>\n",
      -- [15] = "<b></b>\n",
      -- [16] = "<b></b>\n",
      -- [17] = "<b></b>\n",
      -- [18] = "<b></b>\n",
      -- [19] = "<b></b>\n",
      -- [20] = "<b></b>\n",
      -- [21] = "<b></b>\n",
      -- [22] = "<b></b>\n",
      -- [23] = "<b></b>\n",
      -- [24] = "<b></b>\n",
      -- [25] = "<b></b>\n",
      -- [26] = "<b></b>\n",
      -- [27] = "<b></b>\n",
      -- [28] = "<b></b>\n",
      -- [29] = "<b></b>\n",
      -- [30] = "<b></b>\n",
    },
    [7] = { -- "taiwanese"
      -- [1] = "<b></b>\n",
      -- [2] = "<b></b>\n",
      -- [3] = "<b></b>\n",
      -- [4] = "<b></b>\n",
      -- [5] = "<b></b>\n",
      -- [6] = "<b></b>\n",
      -- [7] = "<b></b>\n",
      -- [8] = "<b></b>\n",
      -- [9] = "<b></b>\n",
      -- [10] = "<b></b>\n",
      -- [11] = "<b></b>\n",
      -- [12] = "<b></b>\n",
      -- [13] = "<b></b>\n",
      -- [14] = "<b></b>\n",
      -- [15] = "<b></b>\n",
      -- [16] = "<b></b>\n",
      -- [17] = "<b></b>\n",
      -- [18] = "<b></b>\n",
      -- [19] = "<b></b>\n",
      -- [20] = "<b></b>\n",
      -- [21] = "<b></b>\n",
      -- [22] = "<b></b>\n",
      -- [23] = "<b></b>\n",
      -- [24] = "<b></b>\n",
      -- [25] = "<b></b>\n",
      -- [26] = "<b></b>\n",
      -- [27] = "<b></b>\n",
      -- [28] = "<b></b>\n",
      -- [29] = "<b></b>\n",
      -- [30] = "<b></b>\n",
    },
    [8] = { -- "japanese"
      -- [1] = "<b></b>\n",
      -- [2] = "<b></b>\n",
      -- [3] = "<b></b>\n",
      -- [4] = "<b></b>\n",
      -- [5] = "<b></b>\n",
      -- [6] = "<b></b>\n",
      -- [7] = "<b></b>\n",
      -- [8] = "<b></b>\n",
      -- [9] = "<b></b>\n",
      -- [10] = "<b></b>\n",
      -- [11] = "<b></b>\n",
      -- [12] = "<b></b>\n",
      -- [13] = "<b></b>\n",
      -- [14] = "<b></b>\n",
      -- [15] = "<b></b>\n",
      -- [16] = "<b></b>\n",
      -- [17] = "<b></b>\n",
      -- [18] = "<b></b>\n",
      -- [19] = "<b></b>\n",
      -- [20] = "<b></b>\n",
      -- [21] = "<b></b>\n",
      -- [22] = "<b></b>\n",
      -- [23] = "<b></b>\n",
      -- [24] = "<b></b>\n",
      -- [25] = "<b></b>\n",
      -- [26] = "<b></b>\n",
      -- [27] = "<b></b>\n",
      -- [28] = "<b></b>\n",
      -- [29] = "<b></b>\n",
      -- [30] = "<b></b>\n",
    },
    [9] = { -- "korean"
      -- [1] = "<b></b>\n",
      -- [2] = "<b></b>\n",
      -- [3] = "<b></b>\n",
      -- [4] = "<b></b>\n",
      -- [5] = "<b></b>\n",
      -- [6] = "<b></b>\n",
      -- [7] = "<b></b>\n",
      -- [8] = "<b></b>\n",
      -- [9] = "<b></b>\n",
      -- [10] = "<b></b>\n",
      -- [11] = "<b></b>\n",
      -- [12] = "<b></b>\n",
      -- [13] = "<b></b>\n",
      -- [14] = "<b></b>\n",
      -- [15] = "<b></b>\n",
      -- [16] = "<b></b>\n",
      -- [17] = "<b></b>\n",
      -- [18] = "<b></b>\n",
      -- [19] = "<b></b>\n",
      -- [20] = "<b></b>\n",
      -- [21] = "<b></b>\n",
      -- [22] = "<b></b>\n",
      -- [23] = "<b></b>\n",
      -- [24] = "<b></b>\n",
      -- [25] = "<b></b>\n",
      -- [26] = "<b></b>\n",
      -- [27] = "<b></b>\n",
      -- [28] = "<b></b>\n",
      -- [29] = "<b></b>\n",
      -- [30] = "<b></b>\n",
    },
    [10] = { -- "italian"
      -- [1] = "<b></b>\n",
      -- [2] = "<b></b>\n",
      -- [3] = "<b></b>\n",
      -- [4] = "<b></b>\n",
      -- [5] = "<b></b>\n",
      -- [6] = "<b></b>\n",
      -- [7] = "<b></b>\n",
      -- [8] = "<b></b>\n",
      -- [9] = "<b></b>\n",
      -- [10] = "<b></b>\n",
      -- [11] = "<b></b>\n",
      -- [12] = "<b></b>\n",
      -- [13] = "<b></b>\n",
      -- [14] = "<b></b>\n",
      -- [15] = "<b></b>\n",
      -- [16] = "<b></b>\n",
      -- [17] = "<b></b>\n",
      -- [18] = "<b></b>\n",
      -- [19] = "<b></b>\n",
      -- [20] = "<b></b>\n",
      -- [21] = "<b></b>\n",
      -- [22] = "<b></b>\n",
      -- [23] = "<b></b>\n",
      -- [24] = "<b></b>\n",
      -- [25] = "<b></b>\n",
      -- [26] = "<b></b>\n",
      -- [27] = "<b></b>\n",
      -- [28] = "<b></b>\n",
      -- [29] = "<b></b>\n",
      -- [30] = "<b></b>\n",
    },
  },
  ActiveCheat = 1,
  lasttimecheatvoice = 0,
}


-- ##############################################################################################################
-- ##############################################################################################################
-- ##############################################################################################################
-- ##############################################################################################################
-- ##############################################################################################################
-- ##############################################################################################################
-- ##############################################################################################################
-- ##############################################################################################################
-- ##############################################################################################################
-- ##############################################################################################################


function CheatKeybinds_Serp.ControlSelectedAI()
  local OwnerID = ts.Selection.Object.Owner
  ts.Participants.SetCurrentParticipant(OwnerID)
end
function CheatKeybinds_Serp.AddGodlikes()
  ts.Unlock.SetUnlockNet(120244) -- unlock the reaserch feature
  local godlikes = {124839,124840,124841,124842,124843,124844,124845,124846,124849,124850,125340}
  for _,godlike in ipairs(godlikes) do
    ts.Research.SetAddGodlikeCheat(godlike)
  end
end
-- add item we last hovered over to current island 
function CheatKeybinds_Serp.AddHoveredItemToIsland()
  local refguid=tonumber(ts.RefGuid)
  if ts.Area.Current.IsOwnedByCurrentParticipant then -- does not work in statistic menu, for that menu we need to have a building selected
    if ts.ToolOneHelper.GetItemRarity(refguid)~="" then 
      ts.Area.Current.Economy.SetCheatItem(refguid)
    end 
  elseif ts.Area.CurrentSelectedArea.IsOwnedByCurrentParticipant then -- (building of island selected)
    if ts.ToolOneHelper.GetItemRarity(refguid)~="" then 
      ts.Area.CurrentSelectedArea.Economy.SetCheatItem(refguid)
    end 
  end
end

function CheatKeybinds_Serp.AddRep(RepAmount)
  local RepAmount = RepAmount or 10
  local ProcessingID = ts.Participants.GetGetCurrentParticipantID()
  local OwnerID = ts.Selection.Object.Owner
  if OwnerID~="" and OwnerID~=nil then
    ts.Participants.SetChangeParticipantReputationTo(OwnerID, ProcessingID, RepAmount)
  end
end

function CheatKeybinds_Serp.AddFertility()
  if ts.Selection.Object.GUID~=0 and ts.Selection.Object.IsOwnedByCurrentParticipant then
    if ts.Selection.Object.Factory.NeededFertility.Guid~=0 then
      ts.Selection.Object.Factory.ToggleCheatFertility()
    elseif ts.Selection.Object.HeatProvider.NeededFertility.Guid~=0 then
      ts.Selection.Object.HeatProvider.ToggleCheatFertility()
    elseif ts.Selection.Object.Monument.NeededFertility.Guid~=0 then
      ts.Selection.Object.Monument.ToggleCheatFertility()
    end
  end
end

-- ts.RefGuid is the GUID of the object you last hovered over and showed a tooltip
-- only support island, not ships, because ships ItemContainer only have SetCheatItemInSlot/SetCheatItemInSocket which replaces the object in taht slot/socket
function CheatKeybinds_Serp.AddHoveredGoodToIsland()
  local refguid = tonumber(ts.RefGuid) -- can not use tr.RefGuid within function ,so we have to save it to variable
  if ts.Area.Current.IsOwnedByCurrentParticipant then
    if ts.ToolOneHelper.GetProductCategory(refguid).Guid ~= 0 then
      ts.Area.Current.Economy.AddAmount(refguid, 1000)
    end
  elseif ts.Area.CurrentSelectedArea.IsOwnedByCurrentParticipant then -- can not save area in variable, so we have to use this double condition
    if ts.ToolOneHelper.GetProductCategory(refguid).Guid ~= 0 then
      ts.Area.CurrentSelectedArea.Economy.AddAmount(refguid, 1000)
    end
  end
end

-- wait realtime (system.waitForGameTimeDelta waits for ingame time, so is faster on fast-forward. While we want to wait for syncing stuff to happen, which usually takes the same real time)
-- called from within a thread (coroutine)
-- best only use to ~ max of 6 seconds (6000), because its not saved to savegame. And may continue to be executed in another savegame (wehn going to main menu and load another game)
-- Attention: the coroutines started with system.start() in Anno1800 are resumed on GameTick (~ one per 100ms on default gamespeed). So on Pause/in Main Menu these coroutines are pausing, so it also does not help to wait for realtime.
function CheatKeybinds_Serp.waitForTimeDelta(waittime)
  local startime = os.clock()*1000
  while os.clock()*1000-waittime < startime do
    coroutine.yield()
  end
end

-- special cases not all split functions on the net can handle: seperator = "." and seperator = "Session" in Human0_Session_1234. Now this hopefully can handle both...
function CheatKeybinds_Serp.mysplit(pString, pPattern)
   if pPattern=="." or pPattern=="(" or pPattern==")" then
     pPattern = "%"..pPattern
   end
   local Table = {}
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(Table,cap)
      end
      last_end = e+1
      s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
      cap = pString:sub(last_end)
      table.insert(Table, cap)
   end
   return Table
end

function CheatKeybinds_Serp.myeval(str,as_table_pointer)
  local last_key
  if as_table_pointer then
    local name_parts = CheatKeybinds_Serp.mysplit(str, ".")
    last_key = table.remove(name_parts) -- remove the last part of it to get a pointer
    str = table.concat(name_parts,".")
  end
  local status,ret = xpcall(load("return "..str),CheatKeybinds_Serp.print_error)
  if status==false then -- err
    ret = str -- then maybe its meant to be a string
  end
  return ret,last_key
end

-- invalid signs/zeichen in strings (to save it into nameable): " \ , [ ] and () if both used. and better do not use - because it might hurt gsub?
function CheatKeybinds_Serp.replace_chars_for_Name(str) -- string should not contain these characters
  str = tostring(str)
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

-- ########################################################################################################################

-- ts commands must be string or within another fn, because they stop working when saved into variable...
CheatKeybinds_Serp.Cheats = {
  [1] = console.toggleVisibility, -- console
  [2] = "ts.Cheat.GlobalCheats.ToggleSuperShipSpeed", -- all ships super fast
  [3] = function() ts.Unlock.SetRelockNet(1500006146) end, -- Buffing Ships (needs reapply when new session is entered first)
  [4] = function() ts.Economy.MetaStorage.AddAmount(1010017, 100000) end, -- add money
  [5] = CheatKeybinds_Serp.AddHoveredGoodToIsland, -- add 1000 of last hovered good 
  [6] = function() ts.Area.Current.Economy.AddAmount(1000) end, -- add 1000 of all unlocked goods
  [7] = "ts.AreaManager.AreaPopulation.SetFillAllResidencesOnIsland", -- fill populaiton of all houses of the current island to max
  [8] = "ts.Cheat.GlobalCheats.ToggleIgnoreBuildingCosts", -- no buildcosts for everything (costs are still subsctracted, so you can go bankrupt!)
  [9] = "ts.Cheat.GlobalCheats.ToggleUpgradeCheck", -- allows to upgrade all buildings which have an upgrade
  [10] = "ts.Cheat.GlobalCheats.ToggleElectricity", -- free electricity for everything
  [11] = CheatKeybinds_Serp.AddFertility, -- add the needed fertility from the currently selected building to the island
  [12] = function() ts.AreaManager.Attractivity.SetCheatChangeAttractivityNet(true,false) end, -- increase attractivity of current island by 1000 (false->decrease true->increase,false->100 true->1000)
  [13] = "ts.Selection.Object.Shipyard.SetCheatSkipRemainingTime", -- instant finish ship of current selected shipyard
  [14] = "ts.Selection.Object.Monument.SetCheatUpgradeMicro", -- finish a portion of selected monument building phase, hit multiple times to finish it
  [15] = "ts.Expedition.SetCheatEndExpeditions",
  [16] = function() ts.Economy.MetaStorage.AddAmount(119392, 10000) end, -- add research points
  [17] = "ts.Research.SetSkipCraftingTimeCheat", -- instanty research the current research
  [18] = CheatKeybinds_Serp.AddGodlikes, 
  [19] = "ts.Item.SetCheatAllItems", -- add random items to the current island
  [20] = CheatKeybinds_Serp.AddHoveredItemToIsland, -- add Item you last hovered over
  [21] = CheatKeybinds_Serp.AddRep, -- Change Reputation (default +10) from the Owner of Selection towards you (desyncs multiplayer!)
  [22] = "ts.Selection.ChangeParticipantOfSelected", -- take control of current selected object (desyncs multiplayer!)
  [23] = CheatKeybinds_Serp.ControlSelectedAI, -- control AI of selected object
  -- [24] = , -- 
  -- [25] = , -- 
  -- [26] = , -- 
  -- [27] = , -- 
  -- [28] = , -- 
  -- [29] = , -- 
  -- [30] = , -- 
}

-- ###########################################################################################

-- unfortunately we can not display text ingame this way:
 -- game.GUIManager.showDebugOnScreenText("TEST") -- ts.Interface.ChatInput("TEST")
-- ts.ToggleDebugInfo();game.GUIManager.showDebugOnScreenText("TEST")


function CheatKeybinds_Serp.ChangeCheat(add)
  local status,err = xpcall(function()
    add = add or 1
    if CheatKeybinds_Serp.ActiveCheat+add<=0 then
      CheatKeybinds_Serp.ActiveCheat = #CheatKeybinds_Serp.Cheats
    elseif CheatKeybinds_Serp.ActiveCheat+add>#CheatKeybinds_Serp.Cheats then
      CheatKeybinds_Serp.ActiveCheat = 1
    else
      CheatKeybinds_Serp.ActiveCheat = CheatKeybinds_Serp.ActiveCheat + add
    end
    local activecheat = CheatKeybinds_Serp.ActiveCheat
    local l_index = ts.Options.TextLanguage
    local cheattext = CheatKeybinds_Serp.translations[l_index][activecheat]
    cheattext = cheattext or CheatKeybinds_Serp.translations[0][activecheat] -- default to english if it does not exist
    cheattext = CheatKeybinds_Serp.replace_chars_for_Name(cheattext)
    print("cheatkeybinds_serp.lua: ChangeCheat to ",activecheat,cheattext)
    local oldtext = ts.GetAssetData(34).Text
    ts.Participants.GetParticipant(8).Profile.SetCompanyName(cheattext) -- abuse the Neutral character name for the cheattext
    ts.Unlock.SetRelockNet(1500006142) -- show current selected cheat
    system.start(function()
      CheatKeybinds_Serp.waitForTimeDelta(7000) -- wait x ms , sync this with the NotificationMinDisplayTime in assets.xml +1000
      ts.Participants.GetParticipant(8).Profile.SetCompanyName(oldtext) -- name it vanilla again
    end,"CheatKeyBindSerp_RevertNeutralName") -- with this named thread, we will overwrite previous ones, which is intended
  end,CheatKeybinds_Serp.print_error)
end

function CheatKeybinds_Serp.StartCheat()
  local status,err = xpcall(function()
    local activecheat = CheatKeybinds_Serp.ActiveCheat
    local fn = CheatKeybinds_Serp.Cheats[activecheat]
    if fn then
      local currenttime = os.time()*1000
      local l_index = ts.Options.TextLanguage
      print("StartCheat: ",activecheat,CheatKeybinds_Serp.translations[l_index][activecheat] or CheatKeybinds_Serp.translations[0][activecheat])
      if activecheat==1 then -- console, show hint how to close
        print("To close console again write: console.toggleVisibility()")
      end
      if type(fn)=="string" then
        CheatKeybinds_Serp.myeval(CheatKeybinds_Serp.Cheats[activecheat])() -- executing after was saved in a new varialbe like fn does not work for ts functions for whatever reason. other functions including console to work
      else
        fn()
      end
      if CheatKeybinds_Serp.voice_every_x_ms and currenttime - CheatKeybinds_Serp.lasttimecheatvoice > CheatKeybinds_Serp.voice_every_x_ms then -- only once per minute
        CheatKeybinds_Serp.lasttimecheatvoice = currenttime
        game.playSound(234157) -- Seriously? You're cheating?
        ts.Unlock.SetRelockNet(1500006143) -- voice for other players: Someone's cheating.
      end
    end
  end,CheatKeybinds_Serp.print_error)
end

-- can be used as error_handler for xpcall. only within xpcall error_handler we can access the full traceback
-- usage: xpcall(fn,print_error,...)
function CheatKeybinds_Serp.print_error(err)
  local traceback = debug.traceback~=nil and debug.traceback() or "nil"
  local fullerr = tostring(err)..", traceback:\n"..traceback
  print("ERROR : "..fullerr)
  return fullerr
end

