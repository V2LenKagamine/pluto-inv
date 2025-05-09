-- Localize Libaries & Functions --


local Vector = Vector
local Color = Color
local EyePos = EyePos
local MRandom = math.random
local ParticleEmitter = ParticleEmitter
local BoundsMax = Vector( 15, 15, 15 )
  
local AlertTable = {

	[ 1 ] = {

		String = "particles/ultrakill/muzzleflash",
		DieTime = 1,
		EndSize = 0,
		StartSize = 32,
		OverrideColor = Color( 255, 255, 255, 255 )

	},

	[ 2 ] = {

		String = "particles/ultrakill/muzzleflash_blue",
		DieTime = 1,
		EndSize = 0,
		StartSize = 32,
		OverrideColor = Color( 205, 237, 255, 255 )

	},

	[ 3 ] = {

		String = "particles/ultrakill/muzzleflash_shotgun",
		DieTime = 0.5,
		EndSize = 0,
		StartSize = 32,
		OverrideColor = Color( 255, 255, 255, 255 )

	}

}
  
function EFFECT:Init( CEffectData )

	local Pos = CEffectData:GetOrigin()
	local Radius = CEffectData:GetRadius() * 0.01
	local AlertType = CEffectData:GetFlags()

	local AlertData = AlertTable[ AlertType or 1 ]
  
	local Camera = UltrakillBase.EyePos
	local Angles = ( Camera - Pos ):Angle()

	Pos = Pos + Angles:Forward() * 20

	Angles:RotateAroundAxis( Angles:Forward(), MRandom( -360, 360 ) )

	self:SetPos( Pos )
	self:SetAngles( Angles )
	self:SetRenderBounds( -BoundsMax, BoundsMax )

	local Emitter = ParticleEmitter( Pos, true )

	local AlertParticle = Emitter:Add( AlertData.String, Pos )

	if AlertParticle then

		AlertParticle:SetDieTime( AlertData.DieTime + 0.2 )
		AlertParticle:SetAngles( Angles )
		AlertParticle:SetStartSize( AlertData.StartSize * Radius )
		AlertParticle:SetEndSize( AlertData.EndSize * Radius )
		AlertParticle:SetStartAlpha( 255 )
		AlertParticle:SetEndAlpha( 0 )
		AlertParticle:SetColor( AlertData.OverrideColor:Unpack() )

	end

	Emitter:Finish()

end

function EFFECT:Think()
  
	return false
  
end

function EFFECT:Render() end