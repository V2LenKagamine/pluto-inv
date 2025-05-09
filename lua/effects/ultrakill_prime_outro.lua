-- Localize Libaries & Functions --


local CurTime = CurTime
local Vector = Vector
local Angle = Angle
local IsValid = IsValid
local ClientsideModel = ClientsideModel
local ParticleEmitter = ParticleEmitter
local RealFrameTime = RealFrameTime
local MSin = math.sin
local MRand = math.Rand
local MCos = math.cos
local InCubic = math.ease.InCubic
local InSine = math.ease.InSine
local CLuaEffect = UltrakillBase.CLuaEffect
local LockEmitterToTransform = CLuaEffect.LockEmitterToTransform


-- Localized Vars --


local EmissionRate = 60
local RandomAngle = Angle()


function EFFECT:Init( CEffectData )

	self.Ent = CEffectData:GetEntity()
	self.ModelScale = CEffectData:GetRadius() * 0.01
	self.Attachment = CEffectData:GetFlags() or 2
	self.InitTime = CurTime()

	if not IsValid( self.Ent ) then return end

	RandomAngle:Random( -145, 145 )

	self:SetPos( self.Ent:GetPos() )
	self:SetAngles( self.Ent:GetAngles() + RandomAngle )
	self:SetParent( self.Ent, self.Attachment )

	self.OutroLight = ClientsideModel( "models/ultrakill/mesh/effects/vol_lights/Outro_Light.mdl", RENDERGROUP_TRANSLUCENT )

		self.OutroLight:SetPos( self:GetPos() )
		self.OutroLight:SetAngles( self:GetAngles() )
		self.OutroLight:SetModelScale( 1.35 * self.ModelScale )
		self.OutroLight:SetParent( self )
		self.OutroLight:SetNoDraw( true )

	self.Emitter2D = ParticleEmitter( self:GetPos(), false )
	self.Emitter2D:SetNoDraw( true )

	self:SetRenderBounds( self.OutroLight:GetRenderBounds() )

	self.LastEmissionTime = 0

	CLuaEffect.AddToGarbageCollector( self, self.OutroLight, self.Emitter2D )

end


function EFFECT:Think()

	if CurTime() - self.InitTime > 30 then -- Fallback

		return false

	end

   	return IsValid( self.Ent )

end


local RandomRotation = Vector()
local MaxDegrees = 1


local function DrawLight( self )

	if not IsValid( self.OutroLight ) or CurTime() - self.InitTime < RealFrameTime() then return end

	self.OutroLight:DrawModel()

end


function EFFECT:Render()

	-- Get Current Transform --

	local CurrentPos = self:GetPos()
	local CurrentAngle = self:GetAngles()

	-- Model --

	DrawLight( self )

	-- Particles --

	CurrentAngle:RotateAroundAxis( CurrentAngle:Right(), -90 )

	LockEmitterToTransform( self.Emitter2D, CurrentPos, CurrentAngle )

	if IsValid( self.Emitter2D ) and CurTime() - self.LastEmissionTime > 1 / EmissionRate then

		-- Spread --

		RandomRotation.x = 1
		RandomRotation.y = MSin( MRand( 0, 360 ) * MRand( -1, 1 ) ) * 0.05 * self.ModelScale
		RandomRotation.z = MCos( MRand( 0, 360 ) * MRand( -1, 1 ) ) * 0.05 * self.ModelScale

		-- CLuaParticle --

		local CLuaParticle = self.Emitter2D:Add( "particles/ultrakill/MuzzleFlash_White_Additive", vector_origin )

		if CLuaParticle then

			CLuaParticle:SetDieTime( 2 * self.ModelScale )
			CLuaParticle:SetStartAlpha( 255 )
			CLuaParticle:SetEndAlpha( 0 )

			CLuaParticle:SetColor( 64, 190, 255 )

			CLuaParticle:SetStartSize( 4 * self.ModelScale )
			CLuaParticle:SetEndSize( 2 )

			CLuaParticle:SetVelocity( RandomRotation * MRand( 620, 800 ) * self.ModelScale )

		end

		self.LastEmissionTime = CurTime()

	end

end