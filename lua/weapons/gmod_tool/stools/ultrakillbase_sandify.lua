
TOOL.Tab = "DrGBase"
TOOL.Category = "Tools - ULTRAKILL"
TOOL.Name = "#tool.ultrakillbase_sandify.name"

TOOL.BuildCPanel = function( Panel )

	Panel:Help( "#tool.ultrakillbase_sandify.desc" )
	Panel:Help( "#tool.ultrakillbase_sandify.0" )

end

function TOOL:LeftClick( Tr )

	local Ent = Tr.Entity

	if IsValid( Ent ) and Ent.IsUltrakillNextbot and SERVER then

		Ent:Sand()

	end

	return true

end

if CLIENT then

	language.Add( "tool.ultrakillbase_sandify.name", "Sandify" )
	language.Add( "tool.ultrakillbase_sandify.desc", "Click on an Enemy to Sandify them. ( Must be an ULTRAKILL Nextbot! )" )
	language.Add( "tool.ultrakillbase_sandify.0", "Left click to Apply." )

end