print("gift_ship_init")

-- one yield is 100 ingame miliseconds
-- eg. usage with your custom "CheckRessourceAmount"-fn: WaitForChange(CheckRessourceAmount,20,1010017,(currentMoney+MoneyCost)/2,"WaitForSellableMoneyCost")
function WaitForChange(fn,maxyields,...)
  print("bbbb",...)
  maxyields = maxyields or 100
  notstop = 0
  while true do
    if fn(...) then
      return true
    end
    coroutine.yield()
    notstop = notstop + 1
    if notstop > maxyields then
      print("WaitForChange failed, args: ",...)
      return false
    end
  end
end

-- keep in mind the bilance of the player that also changes the money he owns (positive and negative)
function CheckRessourceAmount(ResGUID,atleast)
  ResGUID = ResGUID or 1010017
  atleast = atleast or 0
  print(ts.Economy.MetaStorage.GetStorageAmount(ResGUID))
  return ts.Economy.MetaStorage.GetStorageAmount(ResGUID) >= atleast
end

function CheckRessourceAmountOfPID(ResGUID,PID,atleast)
  ResGUID = ResGUID or 1010017
  atleast = atleast or 0
  print(ResGUID,atleast)
  ts.Participants.GetParticipant(PID).ProfileCounter.Stats.GetCounter(0,6,ResGUID,3)
  print("zzzz")
  return ts.Participants.GetParticipant(PID).ProfileCounter.Stats.GetCounter(0,6,ResGUID,3) >= atleast
end

-- only humans can execute lua
function IsHuman(PID)
  return (PID==0 or PID==1 or PID==2 or PID==3)
end

-- mercier ist PID 64
-- Arctic_Inuit ist 72
-- Africa_Ketema ist 80
-- Void_Trader ist 95
-- Mod1 ist 149
-- Mod10 ist 158



-- TODO:
 -- LÖSUNG für das TradeRights Problem für hijack, also "schenken" ohne TradeRights:
  -- da wir keine traderights kurzfristig erzwingen können, ohne alles kaputt zu machen,
  -- lassen wir den ownerchange über einen Mittelsmann laufen, welcher immer mit allen einen Handelsvertrag hat und in allen Sessions aktiv ist!
 -- Hierzu bietet sich an sich assets mit <Template>Profile_3rdParty_Queen</Template> an, da diese in jeder session sind, und beim buy der owner nicht automatisch neutral wird.
 -- man könnte die Queen direkt nehmen, aber ich bin mir nicht sicher obs nicht mal nen mod geben wird, wo man gegen die Queen kämpft... (optimalerweise wären das ja dennoch general_enemy schiffe, aber wer weiß)
-- Und für meinen disasters mod brauch ich ja ebenfalls einen Hilfs-Owner der nicht angegriffen werden kann (aktuell Test_Doedel)
-- -> Am besten ein Mod Enum dafür verwenden in shared mod, der dann in beiden mods zur hilfe genommen werden kann.
-- evlt noch mehr mods die queen nutzen: <ModOp Type="merge" GUID='75' Path="/Values">
  -- (bei disasters muss ich nochmal durchsteigen, warum ich doedel und queen nutze, also warum nicht eins reicht..)


-- within system.start() thread, any errors will simply stop the script and not throw any error into th scripts.
 -- so if it does not complete, add tons of prints to fetch the problem..

-- TODO: coopcount/ccopleader einbauen bei Gutschrift von Ressourcen, damit Geld nicht mehrfach zugefügt wird


-- TODO:
 -- ne fkt schreiben, der man OID übergibt, statt mit seleciton zu arbeiten (OID kann man über selection bekommen)
 -- und auch funktionieren, wenn From_PID kein Human ist
 -- und optional mit Mittelsmann


function GiftShip_Serp(From_PID,To_PID)
  if ts.Participants.GetCheckDiplomacyStateTo(From_PID,To_PID,2) then -- BuyNet only works with traderights
    
    local Locale_PID = ts.Participants.GetGetCurrentParticipantID()
    if Locale_PID==From_PID and From_PID~=To_PID and ts.Selection.Object.Owner==Locale_PID and ts.Selection.Object.Sellable.CanBeSoldToTrader then
      system.start(function() -- we can use variables defined outside here, but not if I saved eg a GameObject or function into it. only numbers/strings/bool
        
        local SellPrice = ts.Selection.Object.Sellable.SellPrice.MoneyCost -- after the Buy it is no longer selected, but we need to remove the money the seller got after the ownerchange (to not make balance negative)

        if IsHuman(To_PID) then -- only if human, we will credit him the money back
           -- we can not credit the "buyer" his money back directly here, since we can only change ressources of the processing player here...
           -- so instead we credit the processing a new helper ressource, which is watched by all humans and triggers another script for them, which then changes the money amount based on this
           -- only works for humans, since only they can execute lua, but not a big problem, AI can always pay it and can never go bankrupt, so not important to credit them the money back.. (and I have no clue how anyways)
          local BuyPrice = ts.Selection.Object.Sellable.CurrentParticipantBuyPrice.MoneyCost
          -- we will divide it by 1000, because for whatever reason all products have a max amount limit of 100.000, even if they are a copy of money, which has a higher max amount...
           -- we have to use math.floor because the game does not accept floats, only integers
          ts.Economy.MetaStorage.AddAmount(1500005306,math.floor(BuyPrice/1000))
          
          -- wait until it is visible via ProfileCounter and hope at this time also the To_PID saw it, so we can make it zero again
          local success = WaitForChange(CheckRessourceAmountOfPID,10,1500005306,From_PID,1,"GiftShip_WaitForHelperRes")
          print("Time: ",ts.GameClock.CorporationTime)
          coroutine.yield() -- to be extra sure (not sure yet if computers can credit it with different speed..)
          if success then
            ts.Economy.MetaStorage.AddAmount(1500005306, math.floor(BuyPrice*(-1))) -- make it zero again, for next usage
            -- wait unti the buyer got the ByuPrice credited
            local money_To_PID = ts.Participants.GetParticipant(To_PID).ProfileCounter.Stats.GetCounter(0,6,1010017,3)
            local atleast = math.floor((money_To_PID+BuyPrice)*0.9)
            WaitForChange(CheckRessourceAmountOfPID,10,1010017,To_PID,atleast,"GiftShip_WaitForMoneyBuyer")
            
          end
        end
        ts.Selection.Object.Walking.DebugStop() -- revoke all current commands, especially traderoutes
        ts.Selection.Object.Sellable.BuyNet(To_PID) -- hopefully the money was successfully credited to the buyer meanwhile (if human)
        
        -- remove the ressources the "seller" got from the buyer again, since it should be a gift
        -- but before removing, wait until the SellPrice was credited to the seller
        local money_From_PID = ts.Economy.MetaStorage.GetStorageAmount(1010017)
        local atleast = math.floor((money_From_PID+SellPrice)*0.9)
        WaitForChange(CheckRessourceAmountOfPID,10,1010017,From_PID,atleast,"GiftShip_WaitForMoneySeller")
        print("SellPrice",SellPrice)
        ts.Economy.MetaStorage.AddAmount(1010017, SellPrice)
        
        -- Info: Falls ich mods supporten will, die mehr Kosten zufügen, sollte ich diesen code auskommentieren UND für jede noch ne helper ressource zufügen, damit der "buyer" diese ressource auch zurück bekommt
          -- das selected_obj problem können wir evlt lösen indem wir die OID abfragen und diese dann als string in setDebugTextSource einfügen
        -- in lua haben wir keinen Zugriff auf Costs, daher über textsource, damit wir alle kosten treffen (falls es nen index nicht gibt, passiert einfach nichts, aber so decken wir auch mods ab die kosten zufügen. 
         -- wobei dies dann an buyer zu übertragen mitsamt product guid wird super schwer..
        -- (index 0 ist Money und der letzte belegte index (vanilla 1) ist Einfluss. Wenn man ne neue ressource zufügt, dann landet diese vor Einfluss))
        -- game.TextSourceManager.setDebugTextSource("[Economy MetaStorage AddAmount([Selection Object Sellable SellPrice Costs AT(0) ProductGUID], [Selection Object Sellable SellPrice Costs AT(0) Amount])]")
        -- game.TextSourceManager.setDebugTextSource("[Economy MetaStorage AddAmount([Selection Object Sellable SellPrice Costs AT(1) ProductGUID], [Selection Object Sellable SellPrice Costs AT(1) Amount])]")
        -- game.TextSourceManager.setDebugTextSource("[Economy MetaStorage AddAmount([Selection Object Sellable SellPrice Costs AT(2) ProductGUID], [Selection Object Sellable SellPrice Costs AT(2) Amount])]")
        -- game.TextSourceManager.setDebugTextSource("[Economy MetaStorage AddAmount([Selection Object Sellable SellPrice Costs AT(3) ProductGUID], [Selection Object Sellable SellPrice Costs AT(3) Amount])]")
        print("GiftShip: thread From_PID completed")
      end)
    end
    -- (if the selected object can not be sold/is not owned by local player, then WaitForChange will fail, which is expected)
    if Locale_PID==To_PID then -- add costs back to the "buyer"
      system.start(function() -- we can use variables defined outside here, but not if I saved eg a GameObject or function into it. only numbers/strings/bool
        local success = WaitForChange(CheckRessourceAmountOfPID,10,1500005306,From_PID,1,"GiftShip_WaitForHelperRes")
        print("Time: ",ts.GameClock.CorporationTime)
        coroutine.yield() -- to be extra sure (not sure yet if computers can credit it with different speed..)
        if success then
          local helper_res_amount = ts.Participants.GetParticipant(From_PID).ProfileCounter.Stats.GetCounter(0,6,1500005306,3)
          print("helper_res_amount",helper_res_amount)
          ts.Economy.MetaStorage.AddAmount(1010017, math.floor(helper_res_amount*1000))
        end
        print("GiftShip: thread To_PID completed")
      end)
    end
  else
    print("GiftShip: No TradeRights")
  end
  print("GiftShip_Serp outside thread completed")
end
-- GiftShip_Serp(0,25)




-- Some notes in regards to Selleable lua/textsource:

-- ts.Selection.Object.Sellable.SetOnSale(true)
-- This desyncs and needs to be executed for all humans the same time.
-- the ship will get the infolayer and the UI will change (ONLY visible with traderights!)
 -- after that one needs code t detect if it was selected and then trigger a notification with ThirdPartyButton
  -- to make it execute the BuyNet code
  -- Notification dazu senden: 
  -- info: auch wenn ich n handelsroutenschiff von blake SetOnSale mache, dann öffnet sich dennoch nicht
     -- und wenn ich SetOnSale(false) bei einem echten zu verkaufenden schiff mache, dann kommt dennoch vanilla notification
    -- die notification zum kaufen. also werd ich das vanilla system dafür wohl nicht nutzen können  
-- ich denke der Aufwand das zum laufen zu bekommen lohnt nicht, auch wegen desync usw.
-- wenn ein humanseine schiffe verkaufen will, bekommt er denselben Preis auch von der 3rdparty,
 -- dazu brauch ers also nicht an anderen human verkaufen.
  -- Stattdessen versuchen wir ein Verschenken umzusetzen und die Bezahlung in was auch immer sollen die spieler untereinander ausmachen


-- BuyNet really executes a real Buy. So the costs are paid from the buyer to the seller (in vanilla only money)
-- the money to pay is mandatory, will only be executed if buyer has enough money! (mit ToggleIgnoreBuildingCosts kann man zumindest diesen Block umgehen, verliert aber dennoch das Geld)
 -- NUR andere Spieler benötigen die Summe, damit ownerchange klappt. KI braucht das Geld nicht und kann eh nicht bankrupt gehen
  -- der Käufer zahlt CurrentParticipantBuyPrice (positiv!), aber der Verkäufer bekommt nur weniger, nämlich SellPrice (negativ) gutgeschrieben (der rest ist futsch)
 -- influence can get negative, the buy is still executed if not enough (one could check of course if the buyer has enough (IsPayable))
-- AND the buyer/seller needs to have at least traderights! otherwise the Buy wont be executed!
-- Crediting the money back to buyer within the same game-tick does not work (so needs a yield)
-- in general it is difficult or impossible to make the owner change happen without paying money, because we can only change money amount from the processing human player..)
-- (nach dem BuyNet ist objekt nicht mehr selected, falls es das vorher war. Dies beachten falls man damit noch iwas machen will und selected sein muss)

-- wenn man es für "Schiff schenken" verwenden will (was am meisten sinn macht, denn verkaufen kann mans auch an neutral),
 -- dann muss ich das Geld wieder ausgleichen, aber aus Sicht von Human0 kann ich zb Human1 keine Ressourcen abziehen/gutschreiben soweit ich weiß...
  -- das einzige was gehen könnte, wäre annährend das Geld wieder ausgleichen, indem wir 
  -- ts.Participants.GetGiftSmallSize(1) abfragen, um zu wissen wie hoch SmallGift aktuell ist,
   -- und dann SendSmallGift(1) x mal machen, bis wir so nah wie möglich an dem fürs schiff nötigen wert sind...
 -- (dieses Problem gibts nur bei Human nach Human. Beim schenken an KI ists wurscht wieviel Geld die KI danach hat)

-- Weiteres Problem:
 -- Wenn man schiff an 3rd party (also welche mit Trader ShipTrader) verkauft, dann wird schiff Neutral und verlässt Karte
 -- Selbst wenn ich das komplette Trader Property vom Pirat entferne, passiert das...
 -- Bei 2nd party kann sie es behalten. 
 -- TODO: rausfinden was genau den wechsel zu neutral verursacht, vmerutlich ists an GUID/PID gebunden?

-- ob handelsvertrag besteht oder nicht, kann man mit GetCheckDiplomacyStateTo(0,25,2) abfragen (2 ist TradeRights).
 -- (oder TopLevelDiplomacyStateTo)

-- Es gibt noch Sellable.CheatBuy(), wo man kein PID übergeben kann, es geht also ein processing.
 -- ABER natürlich ist nichts daran cheat -.- es benötigt dennoch dieselbe Menge Geld und auch Handelvertrag, genauso wie BuyNet -.-

  





-- todo testen:
 -- kann auch pirat mein schiff bekommen, oder wird das dabei wie beim verkaufen dann neutral? (leider neutral !!
   -- Testen was das aus macht, ob das intern vllt an PID gekoppelt ist oderso (Trader entfernen hilft nicht))
     -- ABER: Bei Queen wechselt es nicht zu neutral, also unterschiede vergleichen!
     -- einzigen unterschied den ich außer Trader gesehen habe wäre
      -- <ModOp Type="merge" GUID='73' Path="/Values/Profile">
        -- <CreateModeMeta>AutoCreate_Always</CreateModeMeta>
        -- <CreateModeSession>AutoCreate_Always</CreateModeSession>
      -- </ModOp>
     -- aber das alleine hilft auch nicht?!
     
  -- zählt buynet dann als SellObjectToParticipantObjective ? (vermutlich nicht)
  -- simpleevent GameObjectSold (vermutlich nicht)
  -- Reaction ShipTradeConfirmation ? ist leider nur die reaction NACH dem trade und nicht die notification zum kaufen. Aber könnte man dennoch zufügen?
    -- zumindest wenn BuyNet mit 3rdparty ne notification in beide richtungen triggert
    
    -- können sowas wie TraderIndex usw nicht in notification nutzen, müssen also alles hardcoden, eine notififaction pro Target
  
  
