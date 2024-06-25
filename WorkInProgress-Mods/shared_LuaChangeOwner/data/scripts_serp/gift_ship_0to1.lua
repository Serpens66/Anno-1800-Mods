print("gift_ship_0_1")

From_PID = 0
To_PID = 1

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



  local OID
  if Local_PID==From_PID then
    OID = get_OID(session.getSelectedFactory())
  end

  GiftShip_Serp(From_PID,To_PID,OID)
end