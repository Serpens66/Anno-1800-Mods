if CheatKeybinds_Serp then
  local currenttime = os.time()*1000
  if currenttime - CheatKeybinds_Serp.lasttimecheatvoice > 5000 then -- dont play it if you cheated yourself recently (lua variables are locally per human)
    game.playSound(234167) -- Someone's cheating.
  end
end