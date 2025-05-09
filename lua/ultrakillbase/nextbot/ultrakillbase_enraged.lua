if not ENT then return end


function ENT:CreateEnrage( ... )

  if CLIENT then return end

  return self:CallOnClient( "CreateEnrage", ... )

end


if SERVER then return end


local Vector = Vector
local ParticleEmitter = ParticleEmitter
local CurTime = CurTime
local IsValid = IsValid
local Material = Material
local Color = Color
local MRand = math.Rand
local MRad = math.rad
local RSetMaterial = CLIENT and render.SetMaterial
local RDrawSprite = CLIENT and render.DrawSprite
local LockEmitterToTransform = UltrakillBase.CLuaEffect.LockEmitterToTransform


local vEnragedRandomVector = Vector()
local sEnragedDotTexture = "particles/ultrakill/BloodDrop"
local sEnragedLightningTexture = "particles/ultrakill/LightningDark"
local mEnragedMaterial = Material( "particles/ultrakill/RageEffect" )
local mEnragedWhiteMaterial = Material( "particles/ultrakill/RageEffect_White" )
local cEnragedColor = Color( 255, 255, 255, 255 )
local cEnragedLightningColor = Color( 255, 0, 0, 255 )
local fEnragedLightingEmissionRate = 1


local function CreateActivateParticles( self )

	local mEmitter2D = ParticleEmitter( self:WorldSpaceCenter() )

	local cParticleColor = self.UltrakillBase_Enraged_SecondaryColor

	for I = 1, 64 do

		local mParticle2D = mEmitter2D:Add( sEnragedDotTexture, self:WorldSpaceCenter() )
		local fRandomColor = MRand( 0.267, 0.62 )

		mParticle2D:SetDieTime( 0.5 )
		mParticle2D:SetStartSize( 14 )
		mParticle2D:SetEndSize( 0 )
		mParticle2D:SetStartAlpha( 200 )
		mParticle2D:SetEndAlpha( 200 )
		mParticle2D:SetColor( cParticleColor.r * fRandomColor, cParticleColor.g * fRandomColor, cParticleColor.b * fRandomColor )

		vEnragedRandomVector.x = MRand( -1, 1 )
		vEnragedRandomVector.y = MRand( -1, 1 )
		vEnragedRandomVector.z = MRand( -1, 1 )

		mParticle2D:SetVelocity( vEnragedRandomVector * MRand( 228, 428 ) )
		mParticle2D:SetAirResistance( 0 )
		mParticle2D:SetCollide( false )

	end

	mEmitter2D:Finish()

end


local function CreateDeactivateParticles( self )

	local mEmitter2D = ParticleEmitter( self:WorldSpaceCenter() )

	local cParticleColor = self.UltrakillBase_Enraged_SecondaryColor

	for I = 1, 64 do

		local mParticle2D = mEmitter2D:Add( sEnragedDotTexture, self:WorldSpaceCenter() )
		local fRandomColor = MRand( 0.267, 0.62 )

		mParticle2D:SetDieTime( 0.7 )
		mParticle2D:SetStartSize( 14 )
		mParticle2D:SetEndSize( 0 )
		mParticle2D:SetStartAlpha( 200 )
		mParticle2D:SetEndAlpha( 200 )
		mParticle2D:SetColor( cParticleColor.r * fRandomColor, cParticleColor.g * fRandomColor, cParticleColor.b * fRandomColor )

		vEnragedRandomVector.x = MRand( -1, 1 )
		vEnragedRandomVector.y = MRand( -1, 1 )
		vEnragedRandomVector.z = MRand( -1, 1 )

		mParticle2D:SetVelocity( vEnragedRandomVector * MRand( 128, 228 ) )
		mParticle2D:SetAirResistance( 0 )
		mParticle2D:SetCollide( false )

	end

	mEmitter2D:Finish()

end


function CreateEnragedParticles( self )

	if CurTime() - self.UltrakillBase_Enraged_EmissionTime < fEnragedLightingEmissionRate or not IsValid( self.UltrakillBase_Enraged_Emitter ) then return end

	local cParticleColor = self.UltrakillBase_Enraged_SecondaryColor

	for I = 1, 4 do

		local mEnragedParticle = self.UltrakillBase_Enraged_Emitter:Add( sEnragedLightningTexture, vector_origin )
		if not mEnragedParticle then return end

		local fRandomRoll = MRad( MRand( -360, 360 ) )

		mEnragedParticle:SetDieTime( 1 )
		mEnragedParticle:SetColor( cParticleColor.r, cParticleColor.g, cParticleColor.b )
		mEnragedParticle:SetStartAlpha( 200 )
		mEnragedParticle:SetEndAlpha( 0 )
		mEnragedParticle:SetStartSize( 90 * self.UltrakillBase_Enraged_Radius )
		mEnragedParticle:SetEndSize( 100 * self.UltrakillBase_Enraged_Radius )
		mEnragedParticle:SetRoll( fRandomRoll )

	end

	self.UltrakillBase_Enraged_EmissionTime = CurTime()

end


function ENT:CreateEnrage( iAttachment, fRadius, cMainColor, cSecondaryColor )

  	self.UltrakillBase_Enraged_Attachment = iAttachment or 1
  	self.UltrakillBase_Enraged_Radius = fRadius or 1
  	self.UltrakillBase_Enraged_Draw = true
  	self.UltrakillBase_Enraged_Emitter = ParticleEmitter( self:WorldSpaceCenter() )
  	self.UltrakillBase_Enraged_Emitter:SetNoDraw( true )
  	self.UltrakillBase_Enraged_EmissionTime = 0
	self.UltrakillBase_Enraged_MainColor = cMainColor or cEnragedColor
	self.UltrakillBase_Enraged_UseWhite = IsColor( cMainColor )
	self.UltrakillBase_Enraged_SecondaryColor = cSecondaryColor or cEnragedLightningColor
	self.UltrakillBase_Enraged_NoMain = cMainColor == false

  	CreateActivateParticles( self )

end


function ENT:DrawEnraged()

  	if self.UltrakillBase_Enraged_Draw and not self:IsEnraged() then

    	CreateDeactivateParticles( self )
    	self.UltrakillBase_Enraged_Draw = false

		return

  	end

  	local mAttach = self:GetAttachment( self.UltrakillBase_Enraged_Attachment )
  	local vPos = mAttach.Pos

	LockEmitterToTransform( self.UltrakillBase_Enraged_Emitter, vPos, mAttach.Ang )

	if self.UltrakillBase_Enraged_NoMain then return CreateEnragedParticles( self ) end

	RSetMaterial( mEnragedMaterial )
	RDrawSprite( vPos, 100 * self.UltrakillBase_Enraged_Radius, 100 * self.UltrakillBase_Enraged_Radius, self.UltrakillBase_Enraged_MainColor )

	CreateEnragedParticles( self )

end