local CurTime = CurTime
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local Lerp = Lerp
local EFindInSphere = ents.FindInSphere
local UltrakillBase = UltrakillBase
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_projectile"

-- Misc --

ENT.PrintName = "Explosion"
ENT.Category = "UltrakillBase"
ENT.Models = { "" }
ENT.ModelScale = 0
ENT.Spawnable = false

-- Physics --

ENT.Gravity = false
ENT.Physgun = false
ENT.Gravgun = false

-- Sounds --

ENT.LoopSounds = { "" }

-- Parry --

ENT.UltrakillBase_Parryable = false


if SERVER then


function ENT:CustomInitialize()

  self.mInitTime = CurTime()
  self.mDamage = self.mDamage or 0
  self.mDieTime = self.mDieTime or 0
  self.mRadius = self.mRadius or 0
  self.mForce = self.mForce or Vector()
  self.mDamageType = self.mDamageType or DMG_BLAST

  self:SetCollisionGroup( COLLISION_GROUP_WORLD )
  self:SetNoDraw( true )

  SafeRemoveEntityDelayed( self, self.mDieTime )

end


function ENT:CustomThink()

  local fLerpRadius = Lerp( ( CurTime() - self.mInitTime ) / ( self.mDieTime * 0.7 ), 0, self.mRadius )

  for K, mEntity in ipairs( EFindInSphere( self:GetPos(), fLerpRadius ) ) do

    if not UltrakillBase.CanAttack( mEntity ) or not self:Visible( mEntity ) or not self:DamageFilter( mEntity ) or self.UltrakillBase_IgnoreFilter[ mEntity:EntIndex() ] then continue end

    self:DealDamage( mEntity, self.mDamage, self.mForce, self.mDamageType )

    self.UltrakillBase_IgnoreFilter[ mEntity:EntIndex() ] = true

  end

  return 0.05

end


end


AddCSLuaFile()