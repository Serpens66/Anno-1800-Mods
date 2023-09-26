-- ignore buildcosts (because it still consumes researchpoints)
local cheatModeWasActive = ts.Cheat.GlobalCheats.IgnoreBuildingCosts

if not cheatModeWasActive then
  ts.Cheat.GlobalCheats.ToggleIgnoreBuildingCosts()
end

CheatIdentifyItems.UnlockAllRecipes()

if not cheatModeWasActive then
  -- restore buildcosts when done
  ts.Cheat.GlobalCheats.ToggleIgnoreBuildingCosts()
end

