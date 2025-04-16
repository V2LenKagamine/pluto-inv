--Add Playermodel
player_manager.AddValidModel( "YYB Kagamine Len (v2.5)", "models/captainbigbutt/vocaloid/len.mdl" )
player_manager.AddValidHands( "YYB Kagamine Len (v2.5)", "models/captainbigbutt/vocaloid/c_arms/len.mdl", 0, "00000000" )

-- Send this to clients automatically so server hosts don't have to
if SERVER then
	resource.AddWorkshop("904219732")
end