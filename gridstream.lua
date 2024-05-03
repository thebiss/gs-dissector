-- ============================================================================
--
-- DRAFT WireShark Dissector for Landis+Gyr Gridstream protocol
--
-- Reverse engineered from publicly shared dumps of RF traffic.
-- https://wiki.recessim.com/view/Landis%2BGyr_GridStream_Protocol#Data_captures
--
-- Incomplete, and likely wrong in many places.
--
-- ============================================================================
local gs_proto 		= Proto("gridstream",		"GRIDSTREAM Protocol")
local gs_proto_info = Proto("gridstream.mesg",	"Message")

-- Removed, there aren't enough of these packets to test this.
-- local gs_proto_rpu 	= Proto("gridstream.rpu",	"Report Power Usage")


-- ----------------------------------------------------------------------------
-- HEADER ProtocolFields
-- ----------------------------------------------------------------------------
local gs_header_flags = { -- These look more like flags
    -- [0x00] = "Report",
    -- [0x01] = "Report",
    -- [0x02] = "Report",
    -- [0x03] = "Report",
    -- [0x2a] = "Report up-time and unknown" 
}

-- @BUG: These might only apply to packages of type 2a!
local gs_type_classes = {
    [0x55] = "broadcast",
    [0xD5] = "forward"
}

local pf_framestart = ProtoField.new("start",	"gridstream.start",		ftypes.UINT16,	nil,				base.HEX)
local pf_flags		= ProtoField.new("flags",	"gridstream.flags",     ftypes.UINT8,	gs_header_flags,	base.HEX)
local pf_type		= ProtoField.new("type",	"gridstream.type",		ftypes.UINT8,	gs_type_classes,	base.HEX)

gs_proto.fields = {
	pf_framestart,
	pf_flags,
	pf_type
}


-- ----------------------------------------------------------------------------
-- MESSAGE ProtocolFields
-- ----------------------------------------------------------------------------

local gs_subtype_classes = {
	[0x30] = "Report uptime and unknown",
    [0x51] = "Epoch and Uptime"
}

local pf_info_length			= ProtoField.new("len",    					"gridstream.mesg.len",      		ftypes.UINT16,	nil,				base.DEC)
local pf_subtype  				= ProtoField.new("subtype", 				"gridstream.mesg.type",     		ftypes.UINT8,	gs_subtype_classes,	base.HEX)

local pf_dest_device_id1  		= ProtoField.new("dest device ID",			"gridstream.mesg.dest_device_id",	ftypes.BYTES,	nil, 		base.COLON)
local pf_src_device_id1  		= ProtoField.new("src device  ID",			"gridstream.mesg.src_device_id",	ftypes.BYTES,	nil,		base.COLON)
local pf_pkt_count  			= ProtoField.new("packet count",  			"gridstream.mesg.count",    		ftypes.UINT8,	nil, 		base.HEX)

local pf_epoc_sec       		= ProtoField.new("date & time (epoch sec)",	"gridstream.mesg.etime",			ftypes.UINT32, 	nil, 		base.DEC)
local pf_epoc_ts				= ProtoField.new("date & time (parsed)",	"gridstream.mesg.timestamp", 		ftypes.ABSOLUTE_TIME, nil, 	base.UTC)

local pf_uptime     			= ProtoField.new("uptime (0.1s)",			"gridstream.mesg.uptime",			ftypes.UINT32, 	nil, base.DEC)
local pf_payload_raw    		= ProtoField.new("payload raw",  			"gridstream.mesg.payload",			ftypes.BYTES,	nil, base.SPACE)
local pf_payload_len			= ProtoField.new("payload len",	 			"gridstream.mesg.payload_len",		ftypes.UINT16,	nil, base.DEC)
local pf_timing					= ProtoField.new("timing? (0.01s)",			"gridstream.mesg.timing",			ftypes.UINT16,	nil, base.DEC)

local pf_unk1       			= ProtoField.new("flags?",					"gridstream.mesg.unk1",				ftypes.BYTES, 	nil, base.SPACE)
local pf_unk2       			= ProtoField.new("unknown",					"gridstream.mesg.unk2",				ftypes.BYTES, 	nil, base.SPACE)
local pf_unk3					= ProtoField.new("unknown",					"gridstream.mesg.unk3",				ftypes.BYTES,	nil, base.SPACE)
local pf_unk4					= ProtoField.new("unknown",					"gridstream.mesg.unk4",				ftypes.BYTES,	nil, base.SPACE)
local pf_unk5					= ProtoField.new("unknown",					"gridstream.mesg.unk5",				ftypes.BYTES,	nil, base.SPACE)
local pf_unk6					= ProtoField.new("unknown",					"gridstream.mesg.unk6",				ftypes.BYTES,	nil, base.SPACE)
local pf_unk7					= ProtoField.new("unknown",					"gridstream.mesg.unk7",				ftypes.BYTES,	nil, base.SPACE)

local pf_dest_wan_mac 			= ProtoField.new("dest device wan mac",	"gridstream.mesg.dest_device_wan_mac",	ftypes.BYTES,	nil, base.COLON)
local pf_dest_device_id2		= ProtoField.new("dest device ID2",		"gridstream.mesg.dest_device_id2",		ftypes.BYTES,	nil, base.COLON)

local pf_src_wan_mac 			= ProtoField.new("src device wan mac",	"gridstream.mesg.src_device_wan_mac",	ftypes.BYTES,	nil, base.COLON)
local pf_src_device_id2    		= ProtoField.new("src device ID2", 		"gridstream.mesg.src_device_id2",		ftypes.BYTES,	nil, base.COLON)

local pf_checksum				= ProtoField.new("checksum",			"gridstream.mesg.checksum",				ftypes.UINT16,	nil, base.HEX)

local pf_subflag				= ProtoField.new("subtype flags?",		"gridstream.mesg.subtype_flags",		ftypes.BYTES,	nil, base.SPACE)


gs_proto_info.fields ={
	pf_info_length,
	pf_subtype,
	pf_dest_device_id1,
	pf_src_device_id1,
	pf_pkt_count,
	pf_epoc_sec,
	pf_epoc_ts,
	pf_uptime,
	pf_payload_raw,
	pf_payload_len,
	pf_timing,
	
	pf_unk1,
	pf_unk2,
	pf_unk3,
	pf_unk4,
	pf_unk5,
	pf_unk6,
	pf_unk7,
	pf_subflag,
	
	pf_checksum,
	
	pf_src_wan_mac,
	pf_src_device_id2,
	pf_dest_wan_mac,
	pf_dest_device_id2
}


-- ==================================================================================
--
-- DISSECTORS
--
-- ==================================================================================


-- ----------------------------------------------------------------------------
-- Utility function - puts the rest of the buffer into raw payload
--
-- ----------------------------------------------------------------------------
local function util_remainder_as_payload(buffer,subtree,start)
	local cursor = start
	local payloadLen 	= buffer:len() - cursor
	if (payloadLen) <= 0 then return end

	subtree:add(pf_payload_len,		payloadLen)
	subtree:add(pf_payload_raw,		buffer(cursor,payloadLen))
end


-- ----------------------------------------------------------------------------
-- Dissect a payload that includes CRC suffix
--
-- ----------------------------------------------------------------------------
local function gs_payload_with_crc_dissector(buffer,subtree,start)

	-- Last 6 octets are the footer
	local payloadFooter = 6
	local payloadLen 	= buffer:len() - start - payloadFooter

	if (payloadLen) <= 0 then return end

	-- payload body
	subtree:add(pf_payload_len,		payloadLen)
	local payloadtree = subtree:add(pf_payload_raw,		buffer(start,payloadLen))

	-- footer fields
	subtree:add(pf_timing,		buffer(start+payloadLen,2))
	subtree:add(pf_unk3,		buffer(start+payloadLen+2,2))
	subtree:add(pf_checksum,	buffer(start+payloadLen+4,2))

	return start,payloadtree
end


-- ----------------------------------------------------------------------------
-- Dissects packets of 0x29 or 0x21 subtype
-- Assumes these end with the CRC footer.
--
-- STUB
-- ----------------------------------------------------------------------------
local function gs_subsubtype_2921_dissector(buffer, pinfo, subtree, start)
	subtree:add(pf_dest_device_id1,  buffer(start,4))
	subtree:add(pf_src_device_id1,   buffer(start+4,4))
	subtree:add(pf_pkt_count,   	buffer(start+8,1))

	gs_payload_with_crc_dissector(buffer,subtree,start+9)
end


-- ----------------------------------------------------------------------------
-- Dissects packets of 22 subtype
--
-- STUB
--
-- ----------------------------------------------------------------------------
local function gs_subsubtype_22_dissector(buffer, pinfo, subtree, start)
	local cursor = start

	subtree:add(pf_dest_device_id1,	buffer(cursor,4))
	cursor=cursor+4

	subtree:add(pf_src_device_id1,   buffer(cursor,4))
	cursor = cursor+4

	subtree:add(pf_pkt_count,   	buffer(cursor,1)) -- filtering by src device ID, this consistently counts up then wraps.
	cursor = cursor+1

	util_remainder_as_payload(buffer,subtree,cursor)
end



-- ----------------------------------------------------------------------------
-- Dissects packets of the C0 subtype
--
-- These appear to all be broadcasts, sent in repeating blocks.
-- The final bytes vary if any part of the payload varies, so maybe it's a CRC?
--
-- Observations
--  payload [len-4] == 0x7e in every packet in the Oncor dataset.
--
-- ----------------------------------------------------------------------------
local function gs_subsubtype_c0_dissector(buffer, pinfo, subtree, start)
	local cursor = start
	
	subtree:add(pf_dest_device_id1,   buffer(cursor,4))
	cursor=cursor+4

	subtree:add(pf_src_device_id1,   buffer(cursor,4))
	cursor = cursor+4

	subtree:add(pf_pkt_count,   buffer(cursor,1))
	cursor = cursor+1

	-- unk
	subtree:add(pf_unk2,	buffer(cursor,4))
	cursor = cursor+4

	-- always 32bit FF:FF:FF:FF
	subtree:add(pf_dest_device_id2, buffer(cursor,4))
	cursor = cursor+4

	-- maybe a flag bit? always 0 / 1
	subtree:add(pf_subflag, buffer(cursor,1))
	cursor = cursor+1
	
	-- unk byte
	subtree:add(pf_unk3, buffer(cursor,1))
	cursor = cursor+1

	-- This is a guess. Most times, it's 48-bit FF:FF:FF.... like a broadcast
	-- but sometimes, it starts with 00:08:FF... which may be a different packet type
	subtree:add(pf_dest_wan_mac, buffer(cursor,6))
	pinfo.dst = Address.ether(buffer(cursor,6):raw())
	cursor = cursor+6


	subtree:add(pf_unk4, buffer(cursor,4))
	cursor = cursor + 4

	subtree:add(pf_unk5, buffer(cursor,2))
	cursor = cursor + 2
	
	-- Flag/indicator?  Toggles between 2 values.
	subtree:add(pf_unk6, buffer(cursor,1))
	cursor = cursor + 1
	
	-- Unknown, appears to count up ONLY when the whole set changes 
	subtree:add(pf_unk7, buffer(cursor,4))
	cursor = cursor + 4
		
	-- rest as raw payload body
	-- most then start with 0xc1 0x80 0x00 0x00
	util_remainder_as_payload(buffer,subtree,cursor)


end




-- ----------------------------------------------------------------------------
-- Dissector for device header d2
-- ----------------------------------------------------------------------------
local function gs_type_d2_dissector(buffer, pinfo, tree, start)

	local length = buffer:len()
	local cursor = start
	if (length-cursor) <= 0 then return end

	pinfo.cols.protocol = "gridstream.mesg"
	local subtree = tree:add(gs_proto_info,buffer)

	subtree:add(pf_info_length,		buffer(cursor,1))
	cursor = cursor+1


	-- Rest as raw payload
	util_remainder_as_payload(buffer,subtree,cursor)
end



-- ----------------------------------------------------------------------------
-- DISSECT body of Epoch Uptime packages
-- ----------------------------------------------------------------------------
local function gs_subsubtype_epoch_uptime_dissector(buffer, pinfo, subtree, start)
	local length = buffer:len()
	if (length-start) <= 0 then return end
	
	subtree:add(pf_dest_device_id1,   	buffer(start,	4))
	subtree:add(pf_src_device_id1,   	buffer(start+4,	4))

	subtree:add(pf_pkt_count,   		buffer(start+8,	1))
	-- As second
	subtree:add(pf_epoc_sec,        	buffer(start+9,	4))
	-- As timestamp
	subtree:add(pf_epoc_ts, 			buffer(start+9,4))
	subtree:add(pf_unk2,        		buffer(start+13,4))
	subtree:add(pf_uptime,      		buffer(start+17,4))
	subtree:add(pf_unk4,				buffer(start+21,2))
	subtree:add(pf_unk5,				buffer(start+23,2))
	subtree:add(pf_src_wan_mac,			buffer(start+25,6))
	pinfo.src = Address.ether(buffer(start+25,6):raw())

	subtree:add(pf_src_device_id2,		buffer(start+31,4))

	gs_payload_with_crc_dissector(buffer,subtree,start+35) -- BUG, was raw 35
end


-- ----------------------------------------------------------------------------
-- DISSECTOR - Info broadcasts
-- ----------------------------------------------------------------------------
local function gs_type_broadcast_dissector(buffer, pinfo, tree, start)
	local length = buffer:len()
	if (length-start) <= 0 then return end

	pinfo.cols.protocol = "gridstream.mesg"
	local subtree = tree:add(gs_proto_info,buffer)

	local cursor = start
	
	-- Unknown, maybe flags
	subtree:add(pf_unk1, buffer(cursor,1))
	cursor = cursor+1
	
	-- length
	subtree:add(pf_info_length, buffer(cursor,1))
	cursor = cursor + 1
	
	-- maybe a subsubtype?
	local subtype_val = buffer(cursor,1):uint()
	subtree:add(pf_subtype, buffer(cursor,1))
	cursor = cursor + 1

	if subtype_val == 0x30 then
		
		-- Looks like a MAC address, so set in packet for WireShark Conversation analysis
		pinfo.dst = Address.ether(buffer(cursor,6):raw())
		subtree:add(pf_dest_wan_mac, buffer(cursor,6))
		cursor = cursor + 6
		
		-- Looks like a MAC address, so set in packet for WireShark Conversation analysis
		pinfo.src = Address.ether(buffer(cursor,6):raw())
		subtree:add(pf_src_wan_mac, buffer(cursor,6))
		cursor = cursor + 6
	
		-- Appears to be sequence number
		subtree:add(pf_pkt_count, 	buffer(cursor,1))
		cursor = cursor + 1
		
		-- For the 0x30 type, For a specific source  device, 
		-- this counts up continuously across the ONCOR sample set.
		if subtype_val == 0x30 then
			subtree:add(pf_uptime, buffer(cursor,4))
		else
			subtree:add(pf_unk2, 	buffer(cursor,4))
		end
		cursor = cursor + 4
	
		subtree:add(pf_unk3, buffer(cursor,2))
		cursor = cursor + 2
	
		-- maybe a device ID?
		subtree:add(pf_src_device_id2, buffer(cursor,4))
		cursor = cursor + 4	
	end
	
	-- This subtype MIGHT be the same as seen with FORWARDs
	if (subtype_val == 0xc0 ) then
		gs_subsubtype_c0_dissector(buffer,pinfo,subtree,cursor)
		return
	end

	-- rest is unknown, dump into the raw payload
	-- Rest as raw payload
	util_remainder_as_payload(buffer,subtree,cursor)
end


-- ----------------------------------------------------------------------------
-- MAP OF SUB-DISSECTORS on FORWARDS
-- ----------------------------------------------------------------------------
local gs_fwdsubtype_dissector_map = {
	[0x21] = gs_subsubtype_2921_dissector,
	[0x29] = gs_subsubtype_2921_dissector,
	[0x51] = gs_subsubtype_epoch_uptime_dissector,
	[0x55] = gs_subsubtype_epoch_uptime_dissector,
	[0xC0] = gs_subsubtype_c0_dissector,
	[0x22] = gs_subsubtype_22_dissector
}


-- ----------------------------------------------------------------------------
-- DISSECTOR for "FOWARDED" packets with the header type of 0xD5
--
-- Decodes a few fields, then looks up the subtype of the packet from the table
-- above, and calls that dissector.
--
-- ----------------------------------------------------------------------------
local fwdsubtype_field	= Field.new("gridstream.mesg.type")

local function gs_type_forward_dissector(buffer, pinfo, tree, start)
	local length = buffer:len()
	if (length-start) <= 0 then return end

	pinfo.cols.protocol = "gridstream.mesg"
	local subtree = tree:add(gs_proto_info,buffer)

	-- Unknown
	subtree:add(pf_unk1, 			buffer(start,1))

	-- Length field
	-- In the sample data, lengths don't roll-over into the unk field above.
	subtree:add(pf_info_length,		buffer(start+1,1))
    local subsubtree = subtree:add(pf_subtype,    	buffer(start+2,1))

	local fwdsubtype_val 		= fwdsubtype_field()();
	local fwdsubtype_dissector 	= gs_fwdsubtype_dissector_map[fwdsubtype_val]

	-- exit if no match
	if fwdsubtype_dissector ~= nil then
		fwdsubtype_dissector(buffer, pinfo, subsubtree, start+3)
	end

end

--
-- Setting it to
-- https://seclists.org/wireshark/2021/Aug/53
--


-- ----------------------------------------------------------------------------
--
-- GRIDSTREAM DISSECTOR - STARTS from the FRAME TYPE
--
-- ----------------------------------------------------------------------------

local type_field = Field.new("gridstream.type")

local gs_type_to_dissector_map = {
	[0xD2] = gs_type_d2_dissector,
	[0xD5] = gs_type_forward_dissector,
	[0x55] = gs_type_broadcast_dissector
}


-- ----------------------------------------------------------------------------
-- Dissector
--
-- Retrieves the header fields.  Based upon the type field, looks up the next
-- dissector call for that message variant.
--
-- ----------------------------------------------------------------------------
function gs_proto.dissector(buffer,pinfo,tree)
	local length = buffer:len()
	if length == 0 then return end

	pinfo.cols.protocol = gs_proto.name

    local subtree = tree:add(gs_proto,buffer)

    subtree:add(pf_framestart, 	buffer(0,2))
    subtree:add(pf_flags,	    buffer(2,1))
    subtree:add(pf_type,	    buffer(3,1))

	-- local type_field_val = type_field()()

	-- Lookup the dissector for the subtype
	local type_field_val = type_field()()
	local type_specific_dissector = gs_type_to_dissector_map[type_field_val]

	-- exit if no match
	if type_specific_dissector == nil then return end

	type_specific_dissector(buffer, pinfo, subtree, 4)

end


-- ----------------------------------------------------------------------------
-- de facto "main"
--
-- Since the protocol is unknown to wireshark, register as type USER0 (147)
-- Type USER0 must also be set in pcap files to match
-- ----------------------------------------------------------------------------
local udlt = DissectorTable.get("wtap_encap")
udlt:add(wtap.USER0,gs_proto)



-- -- ================================================================================================
-- -- This program will register a menu that will open a window with a count of occurrences
-- -- of every address in the capture
-- --
-- -- https://www.wireshark.org/docs/wsdg_html_chunked/wslua_tap_example.html
-- --

-- local function menuable_tap()
-- 	-- Declare the window we will use
-- 	local tw = TextWindow.new("Address Counter")

-- 	-- This will contain a hash of counters of appearances of a certain address
-- 	local ips = {}

-- 	-- this is our tap
-- 	local tap = Listener.new();

-- 	local function remove()
-- 		-- this way we remove the listener that otherwise will remain running indefinitely
-- 		tap:remove();
-- 	end

-- 	-- we tell the window to call the remove() function when closed
-- 	tw:set_atclose(remove)

-- 	-- this function will be called once for each packet
-- 	function tap.packet(pinfo,tvb)
-- 		local src = ips[tostring(pinfo.src)] or 0
-- 		local dst = ips[tostring(pinfo.dst)] or 0

-- 		ips[tostring(pinfo.src)] = src + 1
-- 		ips[tostring(pinfo.dst)] = dst + 1
-- 	end

-- 	-- this function will be called once every few seconds to update our window
-- 	function tap.draw(t)
-- 		tw:clear()
-- 		for ip,num in pairs(ips) do
-- 			tw:append(ip .. "\t" .. num .. "\n");
-- 		end
-- 	end

-- 	-- this function will be called whenever a reset is needed
-- 	-- e.g. when reloading the capture file
-- 	function tap.reset()
-- 		tw:clear()
-- 		ips = {}
-- 	end

-- 	-- Ensure that all existing packets are processed.
-- 	retap_packets()
-- end

-- -- using this function we register our function
-- -- to be called when the user selects the Tools->Test->Packets menu
-- register_menu("Test/Packets", menuable_tap, MENU_TOOLS_UNSORTED)
