local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local IsValid = IsValid
local UltrakillBase = UltrakillBase
local MMax = math.max
local ETickInterval = engine.TickInterval
local Vector = Vector
local Material = Material
local RSetMaterial = CLIENT and render.SetMaterial
local RStartBeam = CLIENT and render.StartBeam
local LerpVector = LerpVector
local RAddBeam = CLIENT and render.AddBeam
local REndBeam = CLIENT and render.EndBeam
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_projectile"


-- Misc --

ENT.PrintName = "HomingSkull_Projectile"
ENT.Category = "UltrakillBase"
ENT.Models = { "models/ultrakill/mesh/effects/hideousmass/Spear.mdl" }
ENT.ModelScale = 1
ENT.Spawnable = false

-- Contact --

ENT.OnContactDelete = -1

-- Collision --

ENT.UltrakillBase_CustomCollisionEnabled = true

ENT.mBaseHealth = 20


if SERVER then


function ENT:CustomInitialize()

  self.mInitOwner = self:GetOwner()

  SafeRemoveEntityDelayed( self, 8 )

end


function ENT:CustomThink()

  local mOwner = self:GetOwner()

  if mOwner ~= self.mInitOwner and IsValid( self.mInitOwner ) then -- Fix for Ultrakill Arms.

    self:SetOwner( self.mInitOwner )

    mOwner = self.mInitOwner

  end

end


function ENT:OnTakeDamage( CDamageInfo )

  UltrakillBase.SoundScript( "Ultrakill_HideousMass_Spear_Break", self:GetPos() )

  self.mBaseHealth = self.mBaseHealth - MMax( CDamageInfo:GetDamage(), 10 )

  self:CheckParry( CDamageInfo )

  if self.mBaseHealth <= 0 then

    SafeRemoveEntityDelayed( self, ETickInterval() )

  end

end


function ENT:OnParry( mPlayer, CDamageInfo )

  local mOwner = self:GetOwner()

  self:SetOwner( mOwner ~= self.mInitOwner and self.mInitOwner or mOwner )
  mOwner = self.mInitOwner

  mOwner:CallOverCoroutine( mOwner.MassSpearParried )

  CDamageInfo:SetDamage( 250 )
  CDamageInfo:SetDamageType( CDamageInfo:GetDamageType() + DMG_DIRECT )

  UltrakillBase.SoundScript( "Ultrakill_Parry", mPlayer:GetPos() )
  UltrakillBase.HitStop( 0.25 )

  UltrakillBase.OnParryPlayer( mPlayer )

  mOwner:TakeDamageInfo( CDamageInfo )

  SafeRemoveEntityDelayed( self, ETickInterval() )

end


function ENT:OnContact( mEntity )

  if self.mImpaled then return end

  if not UltrakillBase.CanAttack( mEntity ) then

    UltrakillBase.SoundScript( "Ultrakill_HideousMass_Spear_Break", self:GetPos() )

    SafeRemoveEntityDelayed( self, ETickInterval() )

  end

  UltrakillBase.SoundScript( "Ultrakill_HideousMass_Spear_Pierce", self:GetPos() )

  self:SetParryable( false )

  self.mImpaled = true

  local mOwner = self:GetOwner()
  local aRotation = ( mEntity:WorldSpaceCenter() - mOwner:GetAttachment( 2 ).Pos ):Angle()

  self:SetPos( mEntity:WorldSpaceCenter() )
  self:SetAngles( aRotation )
  self:SetParent( mEntity )

  self:DealDamage( mEntity, 250, nil, DMG_BULLET )

end


else


function ENT:CustomInitialize()

  self:SetRenderBounds( self:GetRenderBounds(), Vector( 10000, 10000, 100 ) )

end


local mSpearMaterial = Material( "models/ultrakill/characters/enemies/boss/hideousmass/HideousMass_Spear" )


function ENT:CustomDraw()

  local mOwner = self:GetOwner()
  local vOrigin = mOwner:GetAttachment( 2 ).Pos
  local vPos = self:GetAttachment( 1 ).Pos

  RSetMaterial( mSpearMaterial )
	RStartBeam( 2 )

		for I = 0, 1 do

			RAddBeam( LerpVector( I, vOrigin, vPos ), 7, I, color_white )

		end

	REndBeam()

end 


end


AddCSLuaFile()