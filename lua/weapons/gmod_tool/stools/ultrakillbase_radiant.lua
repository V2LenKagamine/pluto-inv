TOOL.Tab = "DrGBase"
TOOL.Category = "Tools - ULTRAKILL"
TOOL.Name = "#tool.ultrakillbase_radiant.name"

TOOL.ClientConVar = {

	[ "tier" ] = 1,
	[ "hpmult" ] = 1,
	[ "speedmult" ] = 1,
	[ "damagemult" ] = 1

}

TOOL.BuildCPanel = function( Panel )

	Panel:Help( "#tool.ultrakillbase_radiant.desc" )

	Panel:NumSlider( "Tier", "ultrakillbase_radiant_tier", 1, 10, 0 )
	Panel:NumSlider( "Health", "ultrakillbase_radiant_hpmult", 0, 10, 0 )
	Panel:NumSlider( "Speed", "ultrakillbase_radiant_speedmult", 0, 10, 0 )
	Panel:NumSlider( "Damage", "ultrakillbase_radiant_damagemult", 0, 10, 0 )

	Panel:Help( "#tool.ultrakillbase_radiant.0" )

end


function TOOL:LeftClick( Tr )

	local Ent = Tr.Entity

	if IsValid( Ent ) and Ent.IsUltrakillNextbot and SERVER then

		Ent:Radiance( self:GetClientNumber( "tier", 1 ), self:GetClientNumber( "hpmult", 1 ), self:GetClientNumber( "speedmult", 1 ), self:GetClientNumber( "damagemult", 1 ) )

	end

	return true

end


function TOOL:RightClick( Tr )

	local Ent = Tr.Entity

	if IsValid( Ent ) and Ent.IsUltrakillNextbot and SERVER then

		Ent:SetRadiant( false )

		local HPToMaxRatio = Ent:Health() / Ent:GetMaxHealth()

		self:SetMaxHealth( Ent.UltrakillBase_RadianceInfo.OldHP )
		self:SetHealth( HPToMaxRatio * Ent:GetMaxHealth() )

		Ent.UltrakillBase_RadianceInfo = {}

	end

	return true

end


if CLIENT then

	language.Add( "tool.ultrakillbase_radiant.name", "Radiance" )
	language.Add( "tool.ultrakillbase_radiant.desc", "Click on an Enemy to Force Radiance on them. ( Must be an ULTRAKILL Nextbot! )" )
	language.Add( "tool.ultrakillbase_radiant.0", "Left click to Apply." )

end