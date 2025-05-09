-- Localize Libaries & Functions --


local Angle = Angle
local Vector = Vector
local CurTime = CurTime
local ClientsideModel = ClientsideModel
local ParticleEmitter = ParticleEmitter
local ParticleEffect = ParticleEffect
local RealFrameTime = RealFrameTime
local Material = Material
local Lerp = Lerp
local MMax = math.max
local MRand = math.Rand
local RMaterialOverride = render.MaterialOverride
local RSetBlend = render.SetBlend
local RSetMaterial = render.SetMaterial
local RDrawSprite = render.DrawSprite
local InOutCirc = math.ease.InOutCirc
local OutCirc = math.ease.OutCirc
local InSine = math.ease.InSine
local CLuaEffect = UltrakillBase.CLuaEffect


-- Localized Vars --


local DieTime = 1
local ExplosionAngleOffset = Angle( -90, 0, 90 )

local ShockwaveAngle = Angle( 90, 0, 0 )
local ShockwaveForward = Vector( 1, 0, 0 )
local ShockwaveOffset = Vector( 0, 0, 5 )

local SparkRandomVector = Vector()
local RenderBounds = Vector( 200, 200, 200 )


function EFFECT:Init( CEffectData )

	local Pos = CEffectData:GetOrigin()
	local Ang = CEffectData:GetAngles()
	self.ModelRadius = CEffectData:GetRadius() * 0.01

	self.InitTime = CurTime()

	self:SetPos( Pos )

	self:SetRenderBounds( -RenderBounds * self.ModelRadius, RenderBounds * self.ModelRadius )

	self.Explosion = ClientsideModel( "models/ultrakill/mesh/effects/sphere/Sphere_8.mdl", RENDERGROUP_BOTH )

		self.Explosion:SetPos( Pos )
		self.Explosion:SetAngles( Ang + ExplosionAngleOffset )
		self.Explosion:SetNoDraw( true )

	self.Shockwave = ClientsideModel( "models/ultrakill/mesh/effects/sphere/Sphere_8.mdl", RENDERGROUP_BOTH )

		self.Shockwave:SetPos( Pos )
		self.Shockwave:SetAngles( Ang + ExplosionAngleOffset )
		self.Shockwave:SetNoDraw( true )

	-- Particle Emission --

	local Emitter3D = ParticleEmitter( Pos, true )
	local Emitter2D = ParticleEmitter( Pos, false )

	-- Shockwave --

	local Shockwave = Emitter3D:Add( "particles/ultrakill/Shockwave_NoCull", Pos + ShockwaveOffset )

		ShockwaveForward:SetUnpacked( 1, 0, 0 )
		ShockwaveForward:Rotate( Ang + ShockwaveAngle )

		Shockwave:SetDieTime( 0.4 )
		Shockwave:SetAngles( ShockwaveForward:Angle() )
		Shockwave:SetStartSize( 0 )
		Shockwave:SetEndSize( 600 * self.ModelRadius )
		Shockwave:SetStartAlpha( 225 )
		Shockwave:SetEndAlpha( 0 )

	
	-- Sparks --

	for X = 1, 24 do

		local Spark = Emitter2D:Add( "particles/ultrakill/whitetri_trail_additive", Pos )

			Spark:SetDieTime( 0.5 )
			Spark:SetStartSize( 18 * self.ModelRadius )
			Spark:SetEndSize( 18 * self.ModelRadius )
			Spark:SetStartAlpha( 200 )
			Spark:SetEndAlpha( 0 )
			Spark:SetColor( 255, 255, 255 )

			Spark:SetStartLength( 0 )
			Spark:SetEndLength( 1000 * self.ModelRadius )

			SparkRandomVector:SetUnpacked( MRand( -1, 1 ), MRand( -1, 1 ), MRand( -1, 1 ) )

			Spark:SetVelocity( SparkRandomVector * 1 )
			Spark:SetAirResistance( 0 )
			Spark:SetCollide( false )

	end

	Emitter3D:Finish()
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


local ExplosionMaterial = Material( "models/ultrakill/vfx/Explosions/Explosion_New" )
local ShockwaveMaterial = Material( "models/ultrakill/vfx/Explosions/Explosion_Shockwave" )
local WhiteMaterial = Material( "models/ultrakill/shared/White" )
local GlowMaterial = Material( "particles/ultrakill/Glows/Glow1" )

local GlowColor = Color( 255, 255, 255, 255 )
local ExplosionDieTime = 0.7
local ShockwaveDieTime = 0.5


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
	local ExplosionDeltaAlpha = CalculateLifeTimeDelta( self, ExplosionDieTime, 0.25 )

	local ExplosionAlpha = LerpAlpha( ExplosionDeltaAlpha ^ 0.75, 1, 0 )
	local ExplosionScale = LerpScale( ExplosionDelta, 3, 12 * self.ModelRadius ) + ContinuousScale( self, ExplosionDieTime )

	local ShockwaveDelta = CalculateLifeTimeDelta( self, ShockwaveDieTime )
	local ShockwaveDeltaAlpha = CalculateLifeTimeDelta( self, ShockwaveDieTime, 0.1 )

	local ShockwaveAlpha = LerpAlpha( ShockwaveDeltaAlpha, 1, 0 )
	local ShockwaveScale = LerpScale( ShockwaveDelta, 4, 16 * self.ModelRadius ) + ContinuousScale( self, ShockwaveDieTime, 1.2 )
	local LifeTime = CurTime() - self.InitTime

	GlowColor.a = LerpAlpha( ExplosionDeltaAlpha ^ 1.1, 255, 0 )

	RSetMaterial( GlowMaterial )
	RDrawSprite( self:GetPos(), ExplosionScale * 46, ExplosionScale * 46, GlowColor )

		RMaterialOverride( ExplosionMaterial )
		RSetBlend( ExplosionAlpha )

		self.Explosion:SetModelScale( ExplosionScale )

		self.Explosion:DrawModel()
		self.Explosion:DrawModel()

		RMaterialOverride( LifeTime >= 0.1 and ShockwaveMaterial or WhiteMaterial )
		RSetBlend( ShockwaveAlpha )

		self.Shockwave:SetModelScale( ShockwaveScale )

		self.Shockwave:DrawModel()
		self.Shockwave:DrawModel()

		RMaterialOverride()
		RSetBlend( 1 )

end