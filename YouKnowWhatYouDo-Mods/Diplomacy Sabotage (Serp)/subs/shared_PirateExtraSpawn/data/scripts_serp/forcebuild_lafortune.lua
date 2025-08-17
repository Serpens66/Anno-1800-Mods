local Pirate_PID = 18 -- LaFortune

-- ForceBuild() only works once per GameTick. So if one wants to call it multiple times per script, one needs to use a function that uses coroutine.yield() or system.waitForGameTimeDelta(5000)
-- BUT this also means this function is kind of multiplayer compatible! For one ActionExecuteScript only 1 ship will be built (regardless of other human or coop players), if we do not use coroutine.
-- So simply always spawn a single ship within this function and if we want to have multiple, just call this script multiple times with ActionExecuteScript (not sure if a delsy is needed for each action, but it is better anyways, to not stack the ships at same position)

ts.SessionParticipants.GetParticipant(Pirate_PID).Trader.ForceBuild()

