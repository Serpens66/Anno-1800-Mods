-- use this eg by adding this to your script:

-- if CoopCount_Serp==nil then
  -- console.startScript("data/scripts_coophelper_serp/coopcount.lua")
-- end

-- then you can use CoopCount_Serp.GetCoopCount(HumanID) anytime in your script

-- #################################

-- you can use the CoopCount number also to calculate a chance that roughly results in the same chance regardless if code is called once or three times:

-- CoopPlayercount chance logic

-- 1 - ( 1 - partchance)^X = totalchance
-- totalchance = the chance I want to have roughly consistent, regardless of number of players (eg. 80%)
-- X = number of coop players (=total executing count of the total code)
-- partchance = the chance I have to enter into the script so an execution of X times results in the totalchance
-- ->
-- partchance = 1 - (1 - totalchance)^(1/X)
-- eg:
-- partchance = 1 - (1 - 0.8)^(1/2) = 0.5527
-- partchance = 1 - (1 - 0.8)^(1/3) = 0.4152
-- partchance = 1 - (1 - 0.8)^(1/4) = 0.33126
-- partchance = 1 - (1 - 0.95)^(1/2) = 0.776
-- partchance = 1 - (1 - 0.95)^(1/3) = 0.6316
-- partchance = 1 - (1 - 0.95)^(1/4) = 0.5271



-- ##################################################################
-- ##################################################################

-- unfortunately we don't know a way to find out who the leading player of a coop-team is, to eg. only execute the script once only for this player.
 -- (but one can load a MP game without being the leader, so this would also not really solve it)

-- in coop when executing a script via ActionExecuteScript, the script gets executed for all players and all coop-slots on their own and the result is synced (for most commands).
 -- that means if you eg. credit an amount of 100 in coop with 2 slots the executing participant will get 200 in total, instead of just once.
-- The purpose of this count function is that you can divide the amount to credit by the number of coop players to roughly get the same amount in total regardless of number of coop players

-- checking ts.Online.GetUsername(4) and so on to count the coop players does not work, because it also returns their names even if the game is loaded without them.

-- GetActiveSessionGUIDOfPeerInt returns 0 for all not-active peer slots. 0,4,8 and 12 belong to Human0 and so on
local function GetCoopCount(HumanID) -- global function
  local count = 0
  local maxpeerindexes = {[0]=12,[1]=13,[2]=14,[3]=15}
  for i=HumanID,maxpeerindexes[HumanID],4 do
    if ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i)~=0 then
      count = count + 1
    end
  end
  return count
end

local function GetFirstSessionFromCoop()
  local HumanID = ts.Participants.GetGetCurrentParticipantID()
  local FirstSession -- find first valid session we all can enter
  local maxpeerindexes = {[0]=12,[1]=13,[2]=14,[3]=15}
  for i=HumanID,maxpeerindexes[HumanID],4 do
    SessionOfPeer = ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i)
    if SessionOfPeer~=0 then
      FirstSession = SessionOfPeer
      break
    end
  end
  return FirstSession
end

local function IsEveryCoopSameSession(checksession)
  checksession = checksession or CoopCount_Serp.GetFirstSessionFromCoop()
  local HumanID = ts.Participants.GetGetCurrentParticipantID()
  local everyonesamesession = true
  local activesessionofpeer
  local maxpeerindexes = {[0]=12,[1]=13,[2]=14,[3]=15}
  for i=HumanID,maxpeerindexes[HumanID],4 do
    activesessionofpeer = ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i) -- returns 0 for not-active playerslots
    if activesessionofpeer~=0 and checksession~=activesessionofpeer then
      everyonesamesession = false
      break
    end
  end
  return everyonesamesession
end

-- checks for every human player, not only coop. because some commands cause desync if not executed from all players the same time (and often in the same session)
local function IsEveryoneSameSession(checksession)
  local everyonesamesession = true
  local activesessionofpeer
  for i=0,15 do -- up to 16 playerslots at max (with coop) starting at 0
    activesessionofpeer = ts.MetaGameManager.GetActiveSessionGUIDOfPeerInt(i) -- returns 0 for not-active playerslots
    if checksession==nil and activesessionofpeer~=0 then
      checksession = activesessionofpeer
    end
    if activesessionofpeer~=0 and checksession~=activesessionofpeer then
      everyonesamesession = false
      break
    end
  end
  return everyonesamesession
end

CoopCount_Serp = {
  GetCoopCount = GetCoopCount,
  IsEveryoneSameSession = IsEveryoneSameSession,
  IsEveryCoopSameSession = IsEveryCoopSameSession,
  GetFirstSessionFromCoop = GetFirstSessionFromCoop,
}
