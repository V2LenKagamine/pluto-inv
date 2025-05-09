local UltrakillBase = UltrakillBase
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local ParticleEffect = ParticleEffect
local Vector = Vector
local Material = Material
local Color = Color
local RSetMaterial = CLIENT and render.SetMaterial
local RDrawSprite = CLIENT and render.DrawSprite
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_projectile"

-- Misc --

ENT.PrintName = "Hell_Projectile"
ENT.Category = "UltrakillBase"
ENT.Models = { "models/ultrakill/mesh/effects/sphere/Sphere_16.mdl" }
ENT.ModelScale = 0.65
ENT.Spawnable = false

-- Collisions --

ENT.UltrakillBase_CustomCollisionEnabled = true


if SERVER then


function ENT:CustomInitialize()

  self:ParticleEffectSlot( "Projectile_Trail", "Ultrakill_HellOrb", { parent = self } )

  self:SetMaterial( "models/ultrakill/vfx/Skulls/Skull2" )

  UltrakillBase.SoundScript( "Ultrakill_Projectile_Loop", self:GetPos(), self )

  SafeRemoveEntityDelayed( self, 5 )

end


function ENT:OnTakeDamage( CDamageInfo ) 
  
  self:CheckReflect( CDamageInfo )
  self:CheckParry( CDamageInfo )

end


function ENT:OnContact( mEntity )

  if self:GetParried() then return self:ParryCollide( 250 ) end

  UltrakillBase.SoundScript( "Ultrakill_Projectile_Impact", self:GetPos() )
  ParticleEffect( "Ultrakill_HellOrb_Impact", self:GetPos(), self:GetAngles() )

  self:DealDamage( mEntity, 250, nil, DMG_BURN )

end


else


function ENT:CustomThink() 

  self:AngleFollowVelocity()

end


local SpriteMaterial = Material( "particles/ultrakill/Charge" )
local SpriteColor = Color( 225, 0, 0, 255 )


function ENT:CustomDraw()

  RSetMaterial( SpriteMaterial )

  RDrawSprite( self:GetPos(), 34, 34, SpriteColor )

end


end


AddCSLuaFile()