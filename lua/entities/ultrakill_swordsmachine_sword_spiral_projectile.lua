local Vector = Vector
local UltrakillBase = UltrakillBase
local IsValid = IsValid
local CurTime = CurTime
local MSin = math.sin
local MCos = math.cos
local MApproach = math.Approach
local Lerp = Lerp
local SafeRemoveEntity = SafeRemoveEntity
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


if SERVER then


function ENT:CustomInitialize()

  local Owner = self:GetOwner()

  if not IsValid( Owner ) or not Owner.IsUltrakillNextbot then return end

  self:SetModelScale( Owner:GetModelScale() )
  self:SetSkin( Owner:GetSkin() )

  self.DieTime = self.DieTime or 1
  self.InitTime = CurTime()
  self.InitOwner = Owner
  self.SwordDistance = 0
  self.SwordLocalVector = Vector()

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

  local TimeDelta = self:GetUpdateInterval()
  local Delta = ( CurTime() - self.InitTime ) * 1500 * TimeDelta
  local Owner = self:GetOwner()
  
  self.SwordLocalVector.x = MSin( Delta )
  self.SwordLocalVector.y = MCos( Delta )
  self.SwordDistance = MApproach( self.SwordDistance, 450, 450 * 1.4 * TimeDelta )

  local WorldVec = Owner:LocalToWorld( self.SwordLocalVector * self.SwordDistance ) + Owner:OBBCenter()
  local Velocity = WorldVec - self:GetPos()

  self:SetVelocity( Velocity * 10 )

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
  if self.InitTime + self.DieTime < CurTime() then return SafeRemoveEntity( self ) end

  self:SwordsMachineSwordDisableCollision()
  self:SwordsMachineSwordLocomotion()
  self:SwordsMachineSwordDamage()

end


function ENT:OnRemove()

  local Owner = self:GetOwner()

  if not IsValid( Owner ) or not Owner.IsUltrakillNextbot or Owner:IsMarkedForDeletion() then return end

  Owner:SwordMachineCatch()

end


function ENT:OnParry( Ply, Dmg )

  self:SetParried( true )

  self.ParryPlayer = Ply

  UltrakillBase.SoundScript( "Ultrakill_Parry", Ply:GetPos() )
  UltrakillBase.HitStop( 0.25 )
  UltrakillBase.OnParryPlayer( Ply )

  local Owner = self:GetOwner()

  self:SetOwner( Owner ~= self.InitOwner and self.InitOwner or Owner )
  Owner = self.InitOwner

  if not IsValid( Owner ) or not Owner.IsUltrakillNextbot or Owner:IsMarkedForDeletion() then return end

  Owner.HasSword = true
  Owner:SetBodygroup( 2, 0 )

  local Dmg = DamageInfo()

  Dmg:SetDamage( 300 )
  Dmg:SetDamageType( DMG_DIRECT )
  Dmg:SetAttacker( self.ParryPlayer )
  Dmg:SetInflictor( self.ParryPlayer )
  Dmg:SetReportedPosition( self:GetPos() )

  Owner:TakeDamageInfo( Dmg )
  Owner:CallOverCoroutine( Owner.Enrage )

  UltrakillBase.SoundScript( "Ultrakill_SwordsMachine_BigPain_H", Owner:GetPos(), Owner, 0 )

  SafeRemoveEntityDelayed( self, 0.1 )

end


function ENT:OnTakeDamage( Dmg )

  self:CheckParry( Dmg )

end


else


function ENT:CustomInitialize()

  self.SpinRate = 2500

  self.SpinAngle = Angle( 90, 0, 90 )

end

    
function ENT:CustomThink()

  self.SpinAngle:RotateAroundAxis( self.SpinAngle:Forward(), self.SpinRate * self:GetUpdateInterval() )

  self:ManipulateBoneAngles( 0, self.SpinAngle, false )

end


end


AddCSLuaFile()