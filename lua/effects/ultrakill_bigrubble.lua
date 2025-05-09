-- Localize Libaries & Functions --


local Vector = Vector
local MRand = math.Rand
local ClientsideModel = ClientsideModel
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local ParticleEmitter = ParticleEmitter
local MSin = math.sin
local MCos = math.cos
local CLuaEffect = UltrakillBase.CLuaEffect

local DieTime = 4
local Offset = Vector( 0, 0, 1 )
local RandomRotation = Vector()
local MaxDegrees = 10 / 360


function EFFECT:Init( CEffectData )

	local Pos = CEffectData:GetOrigin()
	local Ang = CEffectData:GetAngles()
	local ModelScale = CEffectData:GetRadius() * 0.01 -- Workaround bad float precision.

	ModelScale = ModelScale or 1

	self.DieTime = MRand( 3, 5 )

	self:SetPos( Pos )
	self:SetAngles( Ang )

	local Rubble = ClientsideModel( "models/ultrakill/mesh/effects/rubble/BigRubble.mdl", RENDERGROUP_TRANSLUCENT )

	Rubble:SetPos( Pos )
	Rubble:SetAngles( Ang )
	Rubble:SetModelScale( 1.35 * ModelScale )

	SafeRemoveEntityDelayed( Rubble, self.DieTime )

	-- Particles --

	local Emitter2D = ParticleEmitter( Pos, false )

	-- Smoke --

	for I = 1, 12 do

		-- Spread --

		RandomRotation.x = MSin( MRand( 0, 360 ) * MRand( -MaxDegrees, MaxDegrees ) )
		RandomRotation.y = MCos( MRand( 0, 360 ) * MRand( -MaxDegrees, MaxDegrees ) )
		RandomRotation.z = 1

		local RubbleSmoke = Emitter2D:Add( "particles/ultrakill/Smoke_Additive", Pos - Offset * 40 )

		if RubbleSmoke then

			RubbleSmoke:SetDieTime( 0.4 )
			RubbleSmoke:SetStartSize( 0 )
			RubbleSmoke:SetEndSize( MRand( 45, 75 ) * ModelScale )
			RubbleSmoke:SetStartAlpha( 255 )
			RubbleSmoke:SetEndAlpha( 0 )

			RubbleSmoke:SetStartLength( 0 )
			RubbleSmoke:SetEndLength( 700 * ModelScale )

			RubbleSmoke:SetVelocity( RandomRotation * 0.01 )
			RubbleSmoke:SetAirResistance( 0 )

			RubbleSmoke:SetCollide( false )

		end

	end

	Emitter2D:Finish()

	UltrakillBase.CreateGibs( {

		{ 
			Position = Pos,
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk1.mdl",
			Velocity = 600,
			ModelScale = 1.1 * ModelScale,
			Trail = "Ultrakill_White_Trail"
		},

		{ 
			Position = Pos,
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk2.mdl",
			Velocity = 600,
			ModelScale = 1.1 * ModelScale,
			Trail = "Ultrakill_White_Trail"
		},

		{ 
			Position = Pos,
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk1.mdl",
			Velocity = 600,
			ModelScale = 1.1 * ModelScale,
			Trail = "Ultrakill_White_Trail"
		},

		{ 
			Position = Pos,
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk2.mdl",
			Velocity = 600,
			ModelScale = 1.1 * ModelScale,
			Trail = "Ultrakill_White_Trail"
		},

		{ 
			Position = Pos,
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk1.mdl",
			Velocity = 600,
			ModelScale = 1.1 * ModelScale,
			Trail = "Ultrakill_White_Trail"
		},

		{ 
			Position = Pos,
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk2.mdl",
			Velocity = 600,
			ModelScale = 1.1 * ModelScale,
			Trail = "Ultrakill_White_Trail"
		}

	} )

end


function EFFECT:Think()

	return false

end


function EFFECT:Render() end
