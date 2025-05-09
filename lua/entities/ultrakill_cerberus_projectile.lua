local IsValid = IsValid
local USpriteTrail = SERVER and util.SpriteTrail
local Color = Color
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local UltrakillBase = UltrakillBase
local Vector = Vector
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_projectile"

-- Misc --

ENT.PrintName = "Cerberus_Projectile"
ENT.Category = "UltrakillBase"
ENT.Models = { "models/ultrakill/characters/enemies/boss/cerberus_apple.mdl" }
ENT.ModelScale = 1
ENT.Spawnable = false

-- Damage --

ENT.Damage = 200

ENT.UltrakillBase_DamageRelationships = {

  [ D_NU ] = true,
  [ D_FR ] = true,
  [ D_ER ] = true,
  [ D_HT ] = true,
  [ D_LI ] = true

}

-- Collisions --

ENT.UltrakillBase_CustomCollisionEnabled = true


if SERVER then


function ENT:CustomInitialize()

  local Owner = self:GetOwner()

  if IsValid( Owner ) and Owner.IsUltrakillNextbot then self:SetModelScale( Owner:GetModelScale() ) end

  USpriteTrail( self, 0, Color( 255, 78, 0, 255 ), true, 25, 0, 0.2, 0, "particles/ultrakill/white_trail" )
  SafeRemoveEntityDelayed( self, 5 )

end


function ENT:OnTakeDamage( Dmg ) 
  
  self:CheckParry( Dmg )

end


local vForce = Vector( 350, 0, 300 )


function ENT:OnContact()

  if self:GetParried() then return self:ParryCollide( 200 ) end

  UltrakillBase.SoundScript( "Ultrakill_Explosion_1", self:GetPos() )

  self:ScreenShake( 2500, 10, 1.5, 6500 )
  self:Explosion( self:GetPos(), 200, vForce, 130, 0.25 )
  self:CreateExplosion( self:GetPos(), self:GetAngles(), 1.25 )

end


else


function ENT:CustomThink() 

  self:AngleFollowVelocity()

end


end


AddCSLuaFile()