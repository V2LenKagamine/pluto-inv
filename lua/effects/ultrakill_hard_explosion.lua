-- Localize Libaries & Functions --


local CurTime = CurTime
local Lerp = Lerp
local RMaterialOverride = render.MaterialOverride
local RSetBlend = render.SetBlend
local RSetMaterial = render.SetMaterial
local RDrawSprite = render.DrawSprite
local Angle = Angle
local Vector = Vector
local ClientsideModel = ClientsideModel
local ParticleEmitter = ParticleEmitter
local MRand = math.Rand
local ParticleEffect = ParticleEffect
local RealFrameTime = RealFrameTime
local Material = Material
local MMax = math.max
local InOutCirc = math.ease.InOutCirc
local OutCirc = math.ease.OutCirc
local InSine = math.ease.InSine
local CLuaEffect = UltrakillBase.CLuaEffect


-- Localized Vars --


local DieTime = 0.9
local ExplosionAngleOffset = Angle( 45, 45, 0 )

local ShockwaveAngles = {

	Angle( 0, 0, 0 ),
	Angle( 0, 90, 0 ),
	Angle( 90, 0, 0 )

}

local ShockwaveForward = Vector( 1, 0, 0 )
local ShockwaveOffset = Vector( 0, 0, 5 )

local SparkRandomVector = Vector()
local RenderBounds = Vector( 400, 400, 400 )


function EFFECT:Init( CEffectData )

	local Pos = CEffectData:GetOrigin()
	local Ang = CEffectData:GetAngles()
	self.ModelRadius = CEffectData:GetRadius() * 0.01

	self.InitTime = CurTime()

	self:SetPos( Pos )

	self:SetRenderBounds( -RenderBounds * self.ModelRadius, RenderBounds * self.ModelRadius )

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

	local Emitter3D = ParticleEmitter( Pos, true )
	local Emitter2D = ParticleEmitter( Pos, false )

	-- Shockwaves --

	for X = 1, 6 do

		local Shockwave = Emitter3D:Add( "particles/ultrakill/Shockwave_NoCull", Pos + ShockwaveOffset )

			local StartSize = X < 3 and 200 or 0
			local EndSize = X < 3 and 2000 or 1000

			local Angles = ShockwaveAngles[ ( X > 3 and X - 3 or X ) ]

			ShockwaveForward:SetUnpacked( 1, 0, 0 )
			ShockwaveForward:Rotate( Ang + Angles )

			Shockwave:SetDieTime( 0.4 )
			Shockwave:SetAngles( ShockwaveForward:Angle() )
			Shockwave:SetStartSize( StartSize * self.ModelRadius )
			Shockwave:SetEndSize( EndSize * self.ModelRadius )
			Shockwave:SetStartAlpha( 255 )
			Shockwave:SetEndAlpha( 0 )
			Shockwave:SetColor( 188, 188, 185 )

	end

	-- Sparks --

	for X = 1, 24 do

		local Spark = Emitter2D:Add( "particles/ultrakill/whitetri_trail_additive", Pos )

			Spark:SetDieTime( 0.35 )
			Spark:SetStartSize( 9 * self.ModelRadius )
			Spark:SetEndSize( 9 * self.ModelRadius )
			Spark:SetStartAlpha( 255 )
			Spark:SetEndAlpha( 0 )
			Spark:SetColor( 255, 50, 42 )

			Spark:SetStartLength( 100 )
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


local ExplosionMaterial = Material( "models/ultrakill/vfx/Explosions/Explosion_1_New" )
local ShockwaveMaterial = Material( "models/ultrakill/vfx/Explosions/Explosion_Shockwave" )
local GlowMaterial = Material( "particles/ultrakill/Glows/Glow1_Red" )

local GlowColor = Color( 255, 255, 255, 255 )
local ExplosionDieTime = 0.9
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

	local ExplosionDelta = CalculateLifeTimeDelta( self, ExplosionDieTime )
	local ExplosionDeltaAlpha = CalculateLifeTimeDelta( self, ExplosionDieTime, 0.3 )

	local ExplosionAlpha = LerpAlpha( ExplosionDeltaAlpha, 1, 0 )
	local ExplosionScale = LerpScale( ExplosionDelta, 0, 28 * self.ModelRadius ) + ContinuousScale( self, ExplosionDieTime )

	local ShockwaveDelta = CalculateLifeTimeDelta( self, ShockwaveDieTime )
	local ShockwaveDeltaAlpha = CalculateLifeTimeDelta( self, ShockwaveDieTime, 0.1 )

	local ShockwaveAlpha = LerpAlpha( ShockwaveDeltaAlpha, 1, 0 )
	local ShockwaveScale = LerpScale( ShockwaveDelta, 0, 36 * self.ModelRadius ) + ContinuousScale( self, ShockwaveDieTime, 1.2 )
	
	GlowColor.a = LerpAlpha( ExplosionDeltaAlpha ^ 1.1, 255, 0 )

	RSetMaterial( GlowMaterial )
	RDrawSprite( self:GetPos(), ExplosionScale * 46, ExplosionScale * 46, GlowColor )

	RMaterialOverride( ExplosionMaterial )
	RSetBlend( ExplosionAlpha )

	self.Explosion:SetModelScale( ExplosionScale )

	self.Explosion:DrawModel()
	self.Explosion:DrawModel()

	RMaterialOverride( ShockwaveMaterial )
	RSetBlend( ShockwaveAlpha )

	self.Shockwave:SetModelScale( ShockwaveScale )

	self.Shockwave:DrawModel()
	self.Shockwave:DrawModel()

	RMaterialOverride()
	RSetBlend( 1 )

end