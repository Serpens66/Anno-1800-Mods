-- unfortunately GetStorageAmount always returns the very same within the same ActionExecuteScript-call, even if the amounts should have changed meanwhile.
-- Therefore we need to do another ActionExecuteScript-call shortly after to restore the researchpoints to the previous amounts (since SetResearchRecipes consumes researchpoints even with ToggleIgnoreBuildingCosts active)
-- thanks to the user "Taubenangriff" for pointing to this problem.
CheatIdentifyItems.RestoreRSPoints()
