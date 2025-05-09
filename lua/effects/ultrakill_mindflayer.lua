-- Localize Libaries & Functions --


local Color = Color
local CurTime = CurTime
local IsValid = IsValid
local ParticleEmitter = ParticleEmitter
local ECreateClientSide = ents.CreateClientside
local CreateParticleSystem = CreateParticleSystem
local CLuaEffect = UltrakillBase.CLuaEffect
local LockEmitterToTransform = CLuaEffect.LockEmitterToTransform

local NormalColor = Color( 0, 255, 200 )
local EnragedColor = Color( 255, 0, 50 )


function EFFECT:Init( CEffectData )

	self.Ent = CEffectData:GetEntity()
	self.InitTime = CurTime()
	self.LastEmissionTime = 0
	self.Enraged = false

	if not IsValid( self.Ent ) then return end

	local Pos, Ang = self.Ent:WorldSpaceCenter(), self:GetAngles()

	self:SetPos( self.Ent:GetPos() )
	self:SetAngles( self.Ent:GetAngles() )
	self:SetParent( self.Ent, 1 )
	self:SetRenderBounds( self.Ent:GetRenderBounds() )

	self.Emitter2D = ParticleEmitter( self:GetPos() )
	self.Emitter2D:SetNoDraw( true )

	-- Trails --

	self.CPoint = ECreateClientSide( "base_anim" )

	self.CPoint:SetPos( NormalColor:ToVector() )
	self.CPoint:SetNoDraw( true )

	for I = 3, 7 do

		CNewParticleEffect = CreateParticleSystem( self.Ent, "Ultrakill_Mindflayer_Trail", PATTACH_POINT_FOLLOW, I )
		CNewParticleEffect:AddControlPoint( 1, self.CPoint, PATTACH_POINT_FOLLOW )

		CLuaEffect.AddToGarbageCollector( self, CNewParticleEffect )

	end

	CLuaEffect.AddToGarbageCollector( self, self.Emitter2D, self.CPoint )

	self.Initialized = true

end


function EFFECT:Think()

	self.Enraged = IsValid( self.Ent ) and self.Ent:IsEnraged() or false

	if not IsValid( self:GetParent() ) and IsValid( self.Ent ) then self:SetParent( self.Ent ) end

   	return self.Initialized and IsValid( self.Ent )

end


local GlowMaterial = "particles/ultrakill/JumpPadEffect_Additive.vmt"
local GlowEmissionRate = 0.2


function EFFECT:CreateGlowParticle()

	if CurTime() - self.LastEmissionTime < GlowEmissionRate or not IsValid( self.Emitter2D ) then return end

	local GlowParticle = self.Emitter2D:Add( GlowMaterial, vector_origin )

	if not GlowParticle then return end

	GlowParticle:SetDieTime( 1.2 )
	GlowParticle:SetColor( ( self.Enraged and EnragedColor or NormalColor ):Unpack() )
	GlowParticle:SetStartAlpha( 125 )
	GlowParticle:SetEndAlpha( 0 )
	GlowParticle:SetStartSize( 0 )
	GlowParticle:SetEndSize( 80 )

	self.LastEmissionTime = CurTime()

end


function EFFECT:Render()

	if not IsValid( self.Ent ) then return end

	local Pos, Ang = self:GetPos(), self:GetAngles()

	LockEmitterToTransform( self.Emitter2D, Pos, Ang )

	self:CreateGlowParticle()

	if self.Enraged and self.CPoint:GetPos() ~= EnragedColor:ToVector() then

		self.CPoint:SetPos( EnragedColor:ToVector() )

	elseif not self.Enraged and self.CPoint:GetPos() ~= NormalColor:ToVector() then

		self.CPoint:SetPos( NormalColor:ToVector() )

	end

end
