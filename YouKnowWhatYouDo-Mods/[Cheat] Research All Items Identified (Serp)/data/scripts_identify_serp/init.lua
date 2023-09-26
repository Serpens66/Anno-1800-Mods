-- console commands like this are most likely not multiplayer compatible?

-- "User gets instantly all recipes of the given pool"
-- need a int poolGuid as argument
-- no clue which poolGuid is needed, all the below ones do not work
-- ts.Research.SetCheatAllRecipes(123212)
-- ts.Research.SetCheatAllRecipes(123214)
-- ts.Research.SetCheatAllRecipes(123215)
-- ts.Research.SetCheatAllRecipes(123676)
-- ts.Research.SetCheatAllRecipes(123677)
-- ts.Research.SetCheatAllRecipes(123678)
-- ts.Research.SetCheatAllRecipes(123672)
-- ts.Research.SetCheatAllRecipes(123681)
-- ts.Research.SetCheatAllRecipes(193979)
-- ts.Research.SetCheatAllRecipes(192701)
-- ts.Research.SetCheatAllRecipes(193033)

-- "Selects randomly some recipes from a configured amount of subcategories of the given researchfield"
-- SetSelectRecipes needs the researchField ID, found in datasets: Culture=0, Technology=1,Talent=2
-- it will select 1 (changing MaxSubCategoriesToSelect in assets.xml value has no effect unfortunately, so no clue how to define the amount)
-- ts.Research.SetSelectRecipes(1)
-- "Researches the selected recipes of the given subcategory." needs a subcategory GUID, found in ResearchFeature <GUID>120244</GUID>
-- it consumes researchpoints! so better use command to remove costs first, see below
-- ts.Research.SetResearchRecipes(123205)

-- skips remaining crafting time of current research 
-- ts.Research.SetSkipCraftingTimeCheat()
-- but for a mod it is better to simply edit assets.xml MinimumWorkforceTime and MaximumWorkforceTime eg with:
-- <ModOp Type="replace" Path="//MinimumWorkforceTime">
    -- <MinimumWorkforceTime>1000</MinimumWorkforceTime>
-- </ModOp>
-- <ModOp Type="replace" Path="//MaximumWorkforceTime">
    -- <MaximumWorkforceTime>6000</MaximumWorkforceTime>
-- </ModOp>

-- give one ChangeMine Godlike for free
-- ts.Research.SetAddGodlikeCheat(124841)

CheatIdentifyItems = {
    PreviousPointAmount = 0
}

-- since SetCheatAllRecipes does not work, we will unlock all recipes with a loop instead
-- execute this script with ActionExecuteScript
local function UnlockAllRecipes()
    CheatIdentifyItems.PreviousPointAmount = ts.Economy.MetaStorage.GetStorageAmount(119392)
    local researchfields = {[0]={120301,123204,123202},[1]={123205,123209,123210},[2]={123212,123214,123215}}
    for researchfield,subcategories in pairs(researchfields) do
        local leftamount = ts.Research.GetAmountOfRecipesInTotal(researchfield)
        local notstop = 0 -- just in case there is a problem to not have an endless loop
        while leftamount~=nil and leftamount>0 do
            for i,subcategory in ipairs(subcategories) do -- we can not check how many are left in each subcategory, but as long some are left at least in one of them it will research more until all are done
                ts.Research.SetSelectRecipes(researchfield)
                ts.Research.SetResearchRecipes(subcategory)
            end
            leftamount = ts.Research.GetAmountOfRecipesInTotal(researchfield)
            notstop = notstop + 1
            if notstop > 2000 then -- it unlocks 3 per subcategory per iteration and in vanilla a subcategory has at most 500 items, so stopping at 3*2000 should be enough even with many mod items
                break
            end
        end
    end
end

-- unfortunately GetStorageAmount always returns the very same within the same ActionExecuteScript-call, even if the amounts should have changed meanwhile.
-- Therefore we need to do another ActionExecuteScript-call shortly after to restore the researchpoints to the previous amounts (since SetResearchRecipes consumes researchpoints even with ToggleIgnoreBuildingCosts active)
-- thanks to the user "Taubenangriff" for pointing to this problem.
local function RestoreRSPoints()
    local NewPointAmount = ts.Economy.MetaStorage.GetStorageAmount(119392)
    local diff = CheatIdentifyItems.PreviousPointAmount-NewPointAmount
    ts.Economy.MetaStorage.AddAmount(119392, diff)
end


CheatIdentifyItems.UnlockAllRecipes = UnlockAllRecipes
CheatIdentifyItems.RestoreRSPoints = RestoreRSPoints
