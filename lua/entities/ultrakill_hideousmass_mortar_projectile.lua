local UltrakillBase = UltrakillBase
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local Vector = Vector
local AddCSLuaFile = AddCSLuaFile
local MMin = math.min

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_projectile"


-- Misc --

ENT.PrintName = "Mortar_Projectile"
ENT.Category = "UltrakillBase"
ENT.Models = { "models/ultrakill/mesh/effects/projectiles/Mortar.mdl" }
ENT.ModelScale = 0.65
ENT.Spawnable = false
ENT.Gravity = true

-- Collision --

ENT.UltrakillBase_CustomCollisionEnabled = true

-- Homing --

ENT.UltrakillBase_HomingType = 3
ENT.UltrakillBase_HomingTurningMultiplier = 1
ENT.UltrakillBase_HomingTurningSpeed = 1000


if SERVER then


function ENT:CustomInitialize()

  self:ParticleEffectSlot( "Projectile_Trail", "Ultrakill_MortarTrail", { parent = self } )
  UltrakillBase.SoundScript( "Ultrakill_HideousMass_Mortar_Loop", self:GetPos(), self )

  SafeRemoveEntityDelayed( self, 10 )

end


function ENT:OnTakeDamage( CDamageInfo ) 

  self:CheckParry( CDamageInfo )

end


local vForce = Vector( 350, 0, 300 )


function ENT:OnContact()

  if self:GetParried() then return self:ParryCollide( 600 ) end

  UltrakillBase.SoundScript( "Ultrakill_Explosion_1", self:GetPos() )

  self:Explosion( self:GetPos(), 600, vForce, 150, 0.2, self:GetOwner() )
  self:ScreenShake( 2500, 10, 1.5, 6500 )
  self:CreateExplosion( self:GetPos(), self:GetAngles(), 1.25 )

end


else


function ENT:CustomThink() 

  self:AngleFollowVelocity()

end


end


AddCSLuaFile()