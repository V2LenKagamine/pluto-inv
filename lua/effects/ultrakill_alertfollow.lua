-- Localize Libaries & Functions --


local Vector = Vector
local IsValid = IsValid
local ParticleEmitter = ParticleEmitter
local Angle = Angle
local MRandom = math.random
local CurTime = CurTime
local CLuaEffect = UltrakillBase.CLuaEffect
local LockEmitterToTransform = CLuaEffect.LockEmitterToTransform

local BoundsMax = Vector( 15, 15, 15 )

local AlertTable = {

	[ 1 ] = {

		String = "particles/ultrakill/muzzleflash",
		DieTime = 1,
		EndSize = 20,
		StartSize = 27

	},

	[ 2 ] = {

		String = "particles/ultrakill/muzzleflash_blue",
		DieTime = 1,
		EndSize = 20,
		StartSize = 27

	},

	[ 3 ] = {

		String = "particles/ultrakill/muzzleflash_shotgun",
		DieTime = 1.5,
		EndSize = 20,
		StartSize = 27

	}

}


function EFFECT:Init( CEffectData )

	self.Ent = CEffectData:GetEntity()
	self.Attach = CEffectData:GetAttachment()
	local Radius = CEffectData:GetRadius() * 0.01
	local AlertType = CEffectData:GetFlags()
	self.AlertData = AlertTable[ AlertType or 1 ]
	self.InitTime = CurTime()

	if not IsValid( self.Ent ) then return end

	self:SetPos( self.Ent:GetPos() )
	self:SetAngles( self.Ent:GetAngles() )
	self:SetParent( self.Ent, self.Attach )
	self:SetRenderBounds( -BoundsMax, BoundsMax )

	self.Emitter = ParticleEmitter( self:GetPos(), true )
	self.Emitter:SetNoDraw( true )

	local AlertParticle = self.Emitter:Add( self.AlertData.String, vector_origin )

	if AlertParticle then

		AlertParticle:SetDieTime( self.AlertData.DieTime + 0.15 )
		AlertParticle:SetAngles( Angle( 90, 0, MRandom( -360, 360 ) ) )
		AlertParticle:SetStartSize( self.AlertData.StartSize * Radius )
		AlertParticle:SetEndSize( self.AlertData.EndSize * Radius )
		AlertParticle:SetStartAlpha( 255 )
		AlertParticle:SetEndAlpha( 0 )

	end

	CLuaEffect.AddToGarbageCollector( self, self.Emitter )

end


function EFFECT:Think()

	if CurTime() > self.InitTime + self.AlertData.DieTime then

		return false

	end

	return IsValid( self.Ent )

end


function EFFECT:Render()

	if not IsValid( self.Emitter ) or not IsValid( self.Ent ) then return end

	local Pos, Ang = self:GetPos(), self:GetAngles()

	-- Transform Lock --

	LockEmitterToTransform( self.Emitter, Pos, Ang )

end