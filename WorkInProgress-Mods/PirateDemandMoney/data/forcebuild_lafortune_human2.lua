
-- if Human2 is executing the script, then make LaFortune (participantid 18) instantly build the next ships of her warfleet
if ts.Unlock.GetIsUnlocked(1500001615) then
  ts.SessionParticipants.GetParticipant(18).Trader.ForceBuild()
end