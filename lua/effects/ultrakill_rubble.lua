-- Localize Libaries & Functions --


local Vector = Vector
local Angle = Angle
local MRand = math.Rand
local ClientsideModel = ClientsideModel
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local ParticleEmitter = ParticleEmitter
local CLuaEffect = UltrakillBase.CLuaEffect


local Offset = Vector( 0, 0, 1 )
local RandomRotation = Angle()
local DieTime = 4


function EFFECT:Init( CEffectData )

	local Pos = CEffectData:GetOrigin()
	local Ang = CEffectData:GetAngles()
	local ModelScale = CEffectData:GetRadius() * 0.01

	ModelScale = ModelScale or 1

	self.DieTime = MRand( 3, 5 )

	self:SetPos( Pos )
	self:SetAngles( Ang )

	RandomRotation.y = MRand( -360, 360 )

	local Rubble = ClientsideModel( "models/ultrakill/mesh/effects/rubble/Rubble.mdl", RENDERGROUP_TRANSLUCENT )

	Rubble:SetPos( Pos )
	Rubble:SetAngles( Ang + RandomRotation )
	Rubble:SetModelScale( 1.1 * ModelScale )

	SafeRemoveEntityDelayed( Rubble, self.DieTime )

	-- Particles --

	local Emitter2D = ParticleEmitter( Pos, false )

	-- Smoke --

	local RubbleSmoke = Emitter2D:Add( "particles/ultrakill/Smoke_Additive", Pos - Offset * 160 )

	if RubbleSmoke then

		RubbleSmoke:SetDieTime( 0.4 )
		RubbleSmoke:SetStartSize( 0 )
		RubbleSmoke:SetEndSize( 70 * ModelScale )
		RubbleSmoke:SetStartAlpha( 255 )
		RubbleSmoke:SetEndAlpha( 0 )

		RubbleSmoke:SetStartLength( 0 )
		RubbleSmoke:SetEndLength( 800 * ModelScale )

		RubbleSmoke:SetVelocity( Offset * 0.01 )
		RubbleSmoke:SetAirResistance( 0 )

		RubbleSmoke:SetCollide( false )

	end

	local RubbleSmoke = Emitter2D:Add( "particles/ultrakill/Smoke_Additive", Pos - Offset * 160 )

	if RubbleSmoke then

		RubbleSmoke:SetDieTime( 0.4 )
		RubbleSmoke:SetStartSize( 0 )
		RubbleSmoke:SetEndSize( 100 * ModelScale )
		RubbleSmoke:SetStartAlpha( 255 )
		RubbleSmoke:SetEndAlpha( 0 )

		RubbleSmoke:SetStartLength( 0 )
		RubbleSmoke:SetEndLength( 800 * ModelScale )

		RubbleSmoke:SetVelocity( Offset * 0.01 )
		RubbleSmoke:SetAirResistance( 0 )

		RubbleSmoke:SetCollide( false )

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
		}

	} )

end


function EFFECT:Think()

	return false

end


function EFFECT:Render() end
