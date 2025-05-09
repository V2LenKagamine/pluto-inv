

-- Localize Libaries & Functions --


local Angle = Angle
local Vector = Vector
local CurTime = CurTime
local ClientsideModel = ClientsideModel
local ParticleEmitter = ParticleEmitter
local MRand = math.Rand
local ParticleEffect = ParticleEffect
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


local DieTime = 2
local ExplosionAngleOffset = Angle( 45, 45, 0 )
local SparkRandomVector = Vector()
local RenderBounds = Vector( 500, 500, 500 )


function EFFECT:Init( CEffectData )

	local Pos = CEffectData:GetOrigin()
	local Ang = CEffectData:GetAngles()

	self.InitTime = CurTime()

	self:SetPos( Pos )

	self:SetRenderBounds( -RenderBounds, RenderBounds )

	self.Explosion = ClientsideModel( "models/ultrakill/mesh/effects/sphere/Sphere_8.mdl", RENDERGROUP_BOTH )

		ExplosionAngleOffset:Random( -45, 45 )

		self.Explosion:SetPos( Pos )
		self.Explosion:SetAngles( Ang + ExplosionAngleOffset )
		self.Explosion:SetNoDraw( true )

	self.Shockwave = ClientsideModel( "models/ultrakill/mesh/effects/sphere/Sphere_8.mdl", RENDERGROUP_BOTH )

		ExplosionAngleOffset:Random( -45, 45 )

		self.Shockwave:SetPos( Pos )
		self.Shockwave:SetAngles( Ang + ExplosionAngleOffset )
		self.Shockwave:SetNoDraw( true )

	-- Particle Emission --

	local Emitter2D = ParticleEmitter( Pos, false )

	-- Sparks --

	for X = 1, 32 do

		local Spark = Emitter2D:Add( "particles/ultrakill/whitetri_trail_additive", Pos )

			Spark:SetDieTime( 0.5 )
			Spark:SetStartSize( 8 )
			Spark:SetEndSize( 8 )
			Spark:SetStartAlpha( 255 )
			Spark:SetEndAlpha( 0 )
			Spark:SetColor( 0, 225, 255 )

			Spark:SetStartLength( 0 )
			Spark:SetEndLength( 600 )

			SparkRandomVector:SetUnpacked( MRand( -1, 1 ), MRand( -1, 1 ), MRand( -1, 1 ) )

			Spark:SetVelocity( SparkRandomVector * 1 )
			Spark:SetAirResistance( 0 )

			Spark:SetCollide( false )

	end

	Emitter2D:Finish()

	ParticleEffect( "Ultrakill_ExplosionSmoke", self:GetPos(), self:GetAngles() )
    ParticleEffect( "Ultrakill_ExplosionSmokeLinger", self:GetPos(), self:GetAngles() )

	CLuaEffect.AddToGarbageCollector( self, self.Shockwave, self.Explosion )

end


function EFFECT:Think()

	if CurTime() - self.InitTime > DieTime + RealFrameTime() then

		return false

	end

   	return true

end


local ExplosionMaterial = Material( "models/ultrakill/vfx/Explosions/Explosion_2_New" )
local ShockwaveMaterial = Material( "models/ultrakill/vfx/Explosions/Explosion_Shockwave" )

local ExplosionDieTime = 2
local ShockwaveDieTime = 1.2


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

	-- Explosion --

	local ExplosionDelta = CalculateLifeTimeDelta( self, ExplosionDieTime )
	local ExplosionDeltaAlpha = CalculateLifeTimeDelta( self, ExplosionDieTime, 0.5 )

	local ExplosionAlpha = LerpAlpha( ExplosionDeltaAlpha, 1, 0 )
	local ExplosionScale = LerpScale( ExplosionDelta, 0, 32 ) + ContinuousScale( self, ExplosionDieTime, 1.2 )

		RMaterialOverride( ExplosionMaterial )
		RSetBlend( ExplosionAlpha )

		self.Explosion:SetModelScale( ExplosionScale )

		self.Explosion:DrawModel()
		self.Explosion:DrawModel()

	-- Shockwave --

	local ShockwaveDelta = CalculateLifeTimeDelta( self, ShockwaveDieTime )
	local ShockwaveDeltaAlpha = CalculateLifeTimeDelta( self, ShockwaveDieTime, 0.1 )

	local ShockwaveAlpha = LerpAlpha( ShockwaveDeltaAlpha, 1, 0 )
	local ShockwaveScale = LerpScale( ShockwaveDelta, 0, 38 ) + ContinuousScale( self, ShockwaveDieTime, 1.2 )

		RMaterialOverride( ShockwaveMaterial )
		RSetBlend( ShockwaveAlpha )

		self.Shockwave:SetModelScale( ShockwaveScale )

		self.Shockwave:DrawModel()
		self.Shockwave:DrawModel()

	-- Reset --

		RMaterialOverride()
		RSetBlend( 1 )

end