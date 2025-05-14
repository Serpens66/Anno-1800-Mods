-- unused until shared_LuaUltimateHelpers is ready
-- and unused if CheatItemInSot works in MP without desync


-- then the plan was to unequip all items, so xml ConditionInStorage is able to detect all items of the spy.
-- And then uses ActionAddGoodsToItemContainer to add the same amount to the newly spawned spy unit (ship/land)
 -- so you can keep all items. This way we could use buyable one-time items you can buy and use one time without them
  -- getting lost on land/ship transformation

-- Problem:
-- SetUnequipSocket tauscht die übergebenen indexe aus, also bei 1,1 : socket 1 mit slot 1
  -- wenn auf beiden plötzen ein item war, werden sie nur getauscht und es ist damit weiterhin eines gesockelt.
  -- um also zuverlässig alles unzuequippen muss ich vorher wissen welche slots besetzt sind und wieviele das schiff hat...
   -- und das geht vermutlich nur über den Nameable workaround um an ItemContainer.Sockets/Cargo zu kommen
   -- (bei unlimited slots muss man immer den nächsten index nehmen, also wenn 15 items in slots dann index 15 nehmen (fängt bei 0 an)) und dann den frei gewordenen slot index 0 nehmen
        
-- abgesehen davon brauchen wir auch unsere GetAnyObjectsFromAnyone funktion vom UltimateLuaHelper mod, der noch nicht fertig ist.
-- Dh. das hier könnte ich frühstens umsetzen, wenn dabei alles funzt
        
-- ts.Selection.Object.ItemContainer.SetUnequipSocket(0,15,true)

-- local g_Spy_GUIDs = {1500001173,1500001478} -- the 2 human spy units land and water


-- using setDebugTextSource to make it work in every session
-- if ts.Participants.GetGetCurrentParticipantID()==0 then -- Human0
  -- local OID = 
  -- game.TextSourceManager.setDebugTextSource("[MetaObjects SessionGameObject("..tostring(OID)..") ItemContainer UnequipSocket(0,0,true)]")
  -- game.TextSourceManager.setDebugTextSource("[MetaObjects SessionGameObject("..tostring(OID)..") ItemContainer UnequipSocket(1,1,true)]")
  -- game.TextSourceManager.setDebugTextSource("[MetaObjects SessionGameObject("..tostring(OID)..") ItemContainer UnequipSocket(2,2,true)]")
  -- game.TextSourceManager.setDebugTextSource("[MetaObjects SessionGameObject("..tostring(OID)..") ItemContainer UnequipSocket(3,3,true)]")
-- end
