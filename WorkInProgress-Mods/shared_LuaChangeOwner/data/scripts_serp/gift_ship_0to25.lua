print("gift_ship_0_25")


From_PID = 0
To_PID = 25

-- ############

local Local_PID = ts.Participants.GetGetCurrentParticipantID()
if Local_PID==To_PID or Local_PID==From_PID then

  -- gifting the ship currently selected from From_PID to To_PID (only your own ships)

  if GiftShip_Serp==nil then
    console.startScript("data/scripts_serp/gift_ship_init.lua")
  end

  local function get_OID(userdata)
    local oid,Namestring
    Namestring = userdata:getName() -- returns eg. "GameObject, oid 8589934647", while :getOID returns a OIDtable.
    if Namestring~=nil and type(Namestring)=="string" then
      oid = string.match(Namestring, "oid (.*)")
      if oid~=nil and type(oid)=="string" then
        oid = tonumber(oid)
      end
    end
    return oid
  end



  local OID -- CompanyName from Nature Participant is used as identifier for which Peer hit the button to gift a ship
  if Local_PID==From_PID and ts.Participants.GetParticipant(158).Profile.CompanyName=="MySelection" then
    OID = get_OID(session.getSelectedFactory())
  end
  ts.Participants.GetParticipant(158).Profile.SetCompanyName(ts.GetAssetData(11276).Text) -- name it back to original

  GiftShip_Serp(From_PID,To_PID,OID)
end