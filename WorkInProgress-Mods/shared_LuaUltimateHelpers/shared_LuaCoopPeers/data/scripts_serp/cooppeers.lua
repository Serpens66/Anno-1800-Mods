
-- You can use :

-- if CoopPeers_Serp==nil then
  -- console.startScript("data/scripts_serp/cooppeers.lua")
-- end

-- CoopPeers_Serp.ImFirstActiveCoopPeer
-- CoopPeers_Serp.PeerInt
-- in your mod as soon as they are no longer nil (takes roughly 1.5 seconds after first SessionEnter)
 -- Do NOT start your code with an AlwaysTrue Trigger, but with an SessionEnter Trigger at the earliest (otherwise the variables might be ~=nil from the previous savegame)

-- use code like this to wait for it (or GetWait_ImFirstActiveCoopPeer):
-- system.start(function()
  -- local notstop = 0
  -- while true do
    -- if CoopPeers_Serp.ImFirstActiveCoopPeer~=nil then
      -- break
    -- end
    -- coroutine.yield()
    -- notstop = notstop + 1
    -- if notstop > 100 then
      -- break
    -- end
  -- end
  -- if notstop <= 100 then
    -------- now your code that uses the CoopPeers_Serp variables
  -- end
-- end)

-- ########################################################################################################
-- ########################################################################################################

if CoopCount_Serp==nil then
  console.startScript("data/scripts_coophelper_serp/coopcount.lua")
end

-- call this function within a coroutine, eg. system.start(function()...end) code
 -- if CoopPeers_Serp.ImFirstActiveCoopPeer is still nil. to wait for it to be initialized before continuing
local function GetWait_ImFirstActiveCoopPeer()
  local notstop = 0
  while true do
    if CoopPeers_Serp.ImFirstActiveCoopPeer~=nil then
      break
    end
    coroutine.yield()
    notstop = notstop + 1
    if notstop > 100 then
      break
    end
  end
  return CoopPeers_Serp.ImFirstActiveCoopPeer
end

-- use this instead of ImFirstActiveCoopPeer/GetWait_ImFirstActiveCoopPeer if you are looking for the first coop peer that currently is in a specific session
local function GetWait_ImFirstCoopPeerInSession(checksession,HumanID)
  local notstop = 0
  while true do
    if CoopPeers_Serp.PeerInt~=nil then
      break
    end
    coroutine.yield()
    notstop = notstop + 1
    if notstop > 100 then
      break
    end
  end
  if CoopPeers_Serp.PeerInt~=nil then
    if ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(CoopPeers_Serp.PeerInt)~=checksession then
      return false
    end
    HumanID = HumanID or ts.Participants.GetGetCurrentParticipantID()
    local ImFirstCoopPeerInSession = false
    local maxpeerindexes = {[0]=12,[1]=13,[2]=14,[3]=15}
    for i=HumanID,maxpeerindexes[HumanID],4 do
      SessionOfPeer = ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i)
      if SessionOfPeer~=0 then
        if SessionOfPeer==checksession and CoopPeers_Serp.PeerInt==i then
          ImFirstCoopPeerInSession = true
          break
        elseif SessionOfPeer==checksession and CoopPeers_Serp.PeerInt~=i then
          ImFirstCoopPeerInSession = false
          break
        end
      end
    end
    return ImFirstCoopPeerInSession
  end
end


CoopPeers_Serp = CoopPeers_Serp or {
  GetWait_ImFirstActiveCoopPeer = GetWait_ImFirstActiveCoopPeer,
  GetWait_ImFirstCoopPeerInSession = GetWait_ImFirstCoopPeerInSession,
  PeerInt = nil, -- to get username use: ts.Online.GetUsername(CoopPeers_Serp.PeerInt)
  ImFirstActiveCoopPeer = nil
}