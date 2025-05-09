local UltrakillBase = UltrakillBase
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local CurTime = CurTime
local Lerp = Lerp
local ParticleEffect = ParticleEffect
local Vector = Vector
local Material = Material
local Color = Color
local MAbs = math.abs
local MSin = math.sin
local MRand = math.Rand
local RSetMaterial = CLIENT and render.SetMaterial
local RDrawSprite = CLIENT and render.DrawSprite
local RDrawBox = CLIENT and render.DrawBox
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_projectile"


-- Misc --

ENT.PrintName = "HomingSkull_Projectile"
ENT.Category = "UltrakillBase"
ENT.Models = { "models/ultrakill/mesh/effects/sphere/Sphere_16.mdl" }
ENT.ModelScale = 0.6
ENT.Spawnable = false

-- Homing --

ENT.UltrakillBase_HomingType = 0
ENT.UltrakillBase_HomingSpeed = 10
ENT.UltrakillBase_HomingTurningMultiplier = 1.5

-- Collision --

ENT.UltrakillBase_CustomCollisionEnabled = true


if SERVER then


function ENT:CustomInitialize()

  self:ParticleEffectSlot( "Projectile_Trail", "Ultrakill_HomingOrb", { parent = self } )

  self:SetMaterial( "models/ultrakill/vfx/Skulls/Skull2_4" )

  UltrakillBase.SoundScript( "Ultrakill_MindFlayer_Projectile_Loop", self:GetPos(), self )

  SafeRemoveEntityDelayed( self, 5 )

end


function ENT:OnTakeDamage( CDamageInfo ) 

  self:CheckReflect( CDamageInfo )
  self:CheckParry( CDamageInfo )

end


function ENT:OnContact( mEntity )

  if self:GetParried() then return self:ParryCollide( 300 ) end

  UltrakillBase.SoundScript( "Ultrakill_MindFlayer_Projectile_Impact", self:GetPos() )
  ParticleEffect( "Ultrakill_HomingOrb_Impact", self:GetPos(), self:GetAngles() )

  self:DealDamage( mEntity, 300, nil, DMG_BURN )

end


else


function ENT:CustomThink()

  self:AngleFollowVelocity()

end


local SpriteMaterial = Material( "particles/ultrakill/RageEffect_White" )
local SpriteColor = Color( 0, 255, 216, 255 )
local Sprite3DVector = Vector( 0, 16, 16 )
local Sprite3DRandomOffset = MRand( -1000, 1000 )
local Sprite3DSpeed = 4


function ENT:CustomDraw()
  
  local InnerSize = 12 + MAbs( MSin( Sprite3DSpeed * CurTime() + Sprite3DRandomOffset ) * 4 )

  Sprite3DVector.y = InnerSize
  Sprite3DVector.z = InnerSize

  RSetMaterial( SpriteMaterial )

  RDrawSprite( self:GetPos(), 44, 44, SpriteColor )
  RDrawBox( self:GetPos(), self:GetAngles(), -Sprite3DVector, Sprite3DVector, SpriteColor )


end 


end


AddCSLuaFile()