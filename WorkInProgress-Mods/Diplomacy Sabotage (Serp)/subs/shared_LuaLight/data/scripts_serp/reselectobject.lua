-- Is started by ActionExecuteScript and therefore executed for every player, regardless who did this action!
-- But I think simply re selecting what you have currently select is no problem for everyone.

-- Reselect the currently selected object for UI update for UnlockSecondGUI

system.start(function() coroutine.yield()  coroutine.yield() session.getSelectedFactory():select()  end)