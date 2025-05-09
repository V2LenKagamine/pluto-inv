local Vector = Vector
local IsValid = IsValid
local CurTime = CurTime
local UltrakillBase = UltrakillBase
local SafeRemoveEntity = SafeRemoveEntity
local DamageInfo = DamageInfo
local ipairs = ipairs
local EFindInSphere = ents.FindInSphere
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_projectile"

-- Misc --

ENT.PrintName = "SwordsMachine Sword"
ENT.Category = "UltrakillBase"
ENT.Models = { "models/ultrakill/characters/enemies/boss/swordmachine_sword.mdl" }
ENT.ModelScale = 1
ENT.OnContactDelete = -1
ENT.Spawnable = false


local Min, Max = Vector( -52, -4, -52 ), Vector( 52, 4, 52 )


if SERVER then


function ENT:CustomInitialize()

  local Owner = self:GetOwner()

  if not IsValid( Owner ) or not Owner.IsUltrakillNextbot then return end

  self:SetModelScale( Owner:GetModelScale() )
  self:SetSkin( Owner:GetSkin() )

  self.DieTime = self.DieTime or 2.5
  self.InitTime = CurTime()
  self.InitOwner = Owner
  self.SwordRecalled = false
  self.SwordHitWall = false
  self.SwordSpeed = self.SwordSpeed or 1500
  self.SwordDirection = self.SwordDirection or Owner:GetAimVector()

  self:SetNW2Bool( "UltrakillBase_Heat", true )
  self:SwordsMachineSwordDisableCollision()

  UltrakillBase.SoundScript( "Ultrakill_SwordsMachine_ChainsawThrown", self:GetPos(), self )
  self:ParticleEffectSlot( "Trail", "Ultrakill_SwordsMachine_Trail", { pos = self:GetPos(), parent = self, attachment = "Sword_Attach" } )

end


function ENT:SwordsMachineSwordDisableCollision()

  local PhysObj = self:GetPhysicsObject()

  if IsValid( PhysObj ) and not PhysObj:IsCollisionEnabled() then return end
  if IsValid( PhysObj ) then PhysObj:EnableCollisions( false ) end

end


function ENT:SwordsMachineSwordLocomotion()

  if self.SwordHitWall and not self.SwordRecalled then return self:HaltVelocity() end

  self:SetVelocity( self.SwordDirection * self.SwordSpeed )

end


function ENT:SwordsMachineSwordCollision()

  if self.SwordHitWall then return end

  local TraceResult = self:TraceLine( nil, {

    start = self:GetPos() + self:OBBCenter(),
    endpos = self:GetPos() + self:OBBCenter() + self:GetVelocity() * self:GetUpdateInterval(),
    collisiongroup = COLLISION_GROUP_WORLD

  } )

  if TraceResult.Hit then self.SwordHitWall = true end

end


local ForceVelocity = Vector( 700, 0, 300 )


function ENT:SwordsMachineSwordDamage()

  for K, V in ipairs( EFindInSphere( self:GetPos(), self:GetModelRadius() * 0.5 ) ) do

    if not UltrakillBase.CanAttack( V ) or not self:DamageFilter( eEnt ) or self.UltrakillBase_IgnoreFilter[ V:EntIndex() ] then continue end

    self:DealDamage( V, 300, ForceVelocity, DMG_SLASH )
    self.UltrakillBase_IgnoreFilter[ V:EntIndex() ] = true

  end

end


function ENT:CustomThink()

  local Owner = self:GetOwner()

  if not IsValid( Owner ) or not Owner.IsUltrakillNextbot then return end
  if not self.SwordRecalled and self.InitTime + self.DieTime < CurTime() then self.SwordRecalled = true end
  if self.SwordRecalled and self:WorldSpaceCenter():DistToSqr( Owner:WorldSpaceCenter() ) <= Owner:GetModelRadius() * Owner:GetModelRadius() then return SafeRemoveEntity( self ) end 
  if self.SwordRecalled then self.SwordDirection = ( Owner:WorldSpaceCenter() - self:WorldSpaceCenter() ):GetNormalized() end

  self:SwordsMachineSwordDisableCollision()
  self:SwordsMachineSwordLocomotion()
  self:SwordsMachineSwordCollision()
  self:SwordsMachineSwordDamage()

  if self:GetVelocity():IsZero() then self:SetVelocity( self.SwordDirection ) end

end


function ENT:OnRemove()

  local Owner = self:GetOwner()

  if not IsValid( Owner ) or not Owner.IsUltrakillNextbot or Owner:IsMarkedForDeletion() then return end
  if not self:GetParried() then return Owner:SwordMachineCatch() end

  Owner.HasSword = true
  Owner:SetBodygroup( 2, 0 )

  local CDamageInfo = DamageInfo()

  CDamageInfo:SetDamage( 300 )
  CDamageInfo:SetDamageType( DMG_DIRECT )
  CDamageInfo:SetAttacker( self.ParryPlayer )
  CDamageInfo:SetInflictor( self.ParryPlayer )
  CDamageInfo:SetReportedPosition( self:GetPos() )

  Owner:TakeDamageInfo( CDamageInfo )

  UltrakillBase.SoundScript( "Ultrakill_SwordsMachine_BigPain_H", Owner:GetPos(), Owner, 0 )
  Owner:CallOverCoroutine( Owner.Enrage )

end


function ENT:OnParry( Ply, Dmg )

  self:SetParried( true )
  self.SwordRecalled = true
  self.ParryPlayer = Ply

  UltrakillBase.SoundScript( "Ultrakill_Parry", Ply:GetPos() )
  UltrakillBase.HitStop( 0.25 )
  UltrakillBase.OnParryPlayer( Ply )

  local Owner = self:GetOwner()

  self:SetOwner( Owner ~= self.InitOwner and self.InitOwner or Owner )

end


function ENT:OnTakeDamage( Dmg )

  self:CheckParry( Dmg )

end


else


function ENT:CustomInitialize()

  self.SpinRate = 4500
  self.SpinAngle = Angle( 0, 0, 0 )
  
end
  
      
function ENT:CustomThink()
  
  self.SpinAngle:RotateAroundAxis( self.SpinAngle:Forward(), self.SpinRate * self:GetUpdateInterval() )
  self:ManipulateBoneAngles( 0, self.SpinAngle, false )

  local Velocity = self:GetVelocity()

  self:SetAngles( Velocity:Angle() )
  
end


end


AddCSLuaFile()