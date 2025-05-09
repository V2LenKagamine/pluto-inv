-- Localize Libaries & Functions --


local Angle = Angle
local Vector = Vector
local CurTime = CurTime
local ClientsideModel = ClientsideModel
local ParticleEmitter = ParticleEmitter
local MRand = math.Rand
local RealFrameTime = RealFrameTime
local Material = Material
local MMax = math.max
local Lerp = Lerp
local RMaterialOverride = CLIENT and render.MaterialOverride
local RSetBlend = CLIENT and render.SetBlend
local InOutCirc = math.ease.InOutCirc
local OutCirc = math.ease.OutCirc
local InSine = math.ease.InSine
local CLuaEffect = UltrakillBase.CLuaEffect


-- Localized Vars --


local DieTime = 0.5
local ExplosionAngleOffset = Angle( 90, 0, 0 )
local ShockwaveAngle = Angle( 90, 0, 0 )

local ShockwaveForward = Vector( 1, 0, 0 )
local ShockwaveOffset = Vector( 0, 0, 5 )
local SparkRandomVector = Vector()
local RenderBounds = Vector( 300, 300, 300 )


function EFFECT:Init( CEffectData )

	local Pos = CEffectData:GetOrigin()
	local Ang = CEffectData:GetAngles()
	self.ModelRadius = CEffectData:GetRadius() * 0.01

	self.InitTime = CurTime()

	self:SetPos( Pos )

	self:SetRenderBounds( -RenderBounds * self.ModelRadius, RenderBounds * self.ModelRadius )

	self.Shockwave = ClientsideModel( "models/ultrakill/mesh/effects/sphere/Sphere_8.mdl", RENDERGROUP_BOTH )

		ExplosionAngleOffset:Random( -45, 45 )

		self.Shockwave:SetPos( Pos )
		self.Shockwave:SetAngles( Ang + ExplosionAngleOffset )
		self.Shockwave:SetNoDraw( true )

	-- Particle Emission --

	local Emitter3D = ParticleEmitter( Pos, true )
	local Emitter2D = ParticleEmitter( Pos, false )

	-- Shockwaves --

	local Shockwave = Emitter3D:Add( "particles/ultrakill/Shockwave_NoCull", Pos + ShockwaveOffset )

		ShockwaveForward:SetUnpacked( 1, 0, 0 )
		ShockwaveForward:Rotate( Ang + ShockwaveAngle )

		Shockwave:SetDieTime( 0.6 )
		Shockwave:SetAngles( ShockwaveForward:Angle() )
		Shockwave:SetStartSize( 0 )
		Shockwave:SetEndSize( 700 * self.ModelRadius )
		Shockwave:SetStartAlpha( 225 )
		Shockwave:SetEndAlpha( 0 )

	-- Sparks --

	for X = 1, 32 do

		local Spark = Emitter2D:Add( "particles/ultrakill/whitetri_trail_additive", Pos )

			Spark:SetDieTime( 0.2 )
			Spark:SetStartSize( 3 * self.ModelRadius )
			Spark:SetEndSize( 3 * self.ModelRadius )
			Spark:SetStartAlpha( 255 )
			Spark:SetEndAlpha( 0 )

			Spark:SetStartLength( 0 )
			Spark:SetEndLength( 600 * self.ModelRadius )

			SparkRandomVector:SetUnpacked( MRand( -1, 1 ), MRand( -1, 1 ), MRand( -1, 1 ) )

			Spark:SetVelocity( SparkRandomVector * 100 )
			Spark:SetAirResistance( 0 )
			Spark:SetCollide( false )

	end

	Emitter3D:Finish()
	Emitter2D:Finish()

	UltrakillBase.CreateGibs( {

		{ 
			Position = Pos,
			Models = "models/ultrakill/mesh/effects/virtue/Virtue_Gib.mdl",
			Velocity = 1000,
			ModelScale = 3.5,
			Trail = "Ultrakill_VirtueShatter_Trail"
		},

		{ 
			Position = Pos,
			Models = "models/ultrakill/mesh/effects/virtue/Virtue_Gib.mdl",
			Velocity = 1000,
			ModelScale = 3.5,
			Trail = "Ultrakill_VirtueShatter_Trail"
		},

		{ 
			Position = Pos,
			Models = "models/ultrakill/mesh/effects/virtue/Virtue_Gib.mdl",
			Velocity = 1000,
			ModelScale = 3.5,
			Trail = "Ultrakill_VirtueShatter_Trail"
		},

		{ 
			Position = Pos,
			Models = "models/ultrakill/mesh/effects/virtue/Virtue_Gib.mdl",
			Velocity = 1000,
			ModelScale = 3.5,
			Trail = "Ultrakill_VirtueShatter_Trail"
		},

		{ 
			Position = Pos,
			Models = "models/ultrakill/mesh/effects/virtue/Virtue_Gib.mdl",
			Velocity = 1000,
			ModelScale = 3.5,
			Trail = "Ultrakill_VirtueShatter_Trail"
		}

	} )

	CLuaEffect.AddToGarbageCollector( self, self.Shockwave )

end


function EFFECT:Think()

	if CurTime() - self.InitTime > DieTime + RealFrameTime() then

		return false

	end

   	return true

end


local ShockwaveMaterial = Material( "models/ultrakill/vfx/Explosions/Explosion_Shockwave" )
local ShockwaveDieTime = 0.55


local function CalculateLifeTimeDelta( self, DieTime, HoldTime )

	if HoldTime == nil then HoldTime = 0 end

	if HoldTime > 0 then

		DieTime = DieTime - HoldTime

	end

	local LifeTime = CurTime() - self.InitTime

	LifeTime = MMax( LifeTime - HoldTime, 0 )

	return LifeTime / DieTime

end


local function LerpScale( Delta, From, To )

	Delta = Delta > 1 and 1 or Delta < 0 and 0 or Delta

	return Lerp( OutCirc( Delta ), From, To )

end


local function LerpAlpha( Delta, From, To )

	Delta = Delta > 1 and 1 or Delta < 0 and 0 or Delta

	return Lerp( InOutCirc( Delta ), From, To )

end


local function ContinuousScale( self, DieTime, SizeMult )

	local Delta = CalculateLifeTimeDelta( self, DieTime )

	Delta = Delta > 1 and 1 or Delta < 0 and 0 or Delta

	local LerpSin = Lerp( InSine( Delta * 0.4 ), 0, 12 * ( SizeMult or 1 ) )

	return LerpSin

end


function EFFECT:Render()

	-- Shockwave --

	local ShockwaveDelta = CalculateLifeTimeDelta( self, ShockwaveDieTime )
	local ShockwaveDeltaAlpha = CalculateLifeTimeDelta( self, ShockwaveDieTime, 0.1 )

	local ShockwaveAlpha = LerpAlpha( ShockwaveDeltaAlpha, 1, 0 )
	local ShockwaveScale = LerpScale( ShockwaveDelta, 0, 24 * self.ModelRadius ) + ContinuousScale( self, ShockwaveDieTime )

		RMaterialOverride( ShockwaveMaterial )
		RSetBlend( ShockwaveAlpha )

		self.Shockwave:SetModelScale( ShockwaveScale )

		self.Shockwave:DrawModel()
		self.Shockwave:DrawModel()

	-- Reset --

		RMaterialOverride()
		RSetBlend( 1 )

end