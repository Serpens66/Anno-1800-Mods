
-- if Human0 is executing the script, then make Harlow (participantid 17) instantly build the next ships of her warfleet
if ts.Unlock.GetIsUnlocked(1500001613) then
  ts.SessionParticipants.GetParticipant(17).Trader.ForceBuild()
end