local Vector = Vector
local CurTime = CurTime
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local Lerp = Lerp
local MClamp = math.Clamp
local InSine = math.ease.InSine
local EFindAlongRay = ents.FindAlongRay
local RSetMaterial = CLIENT and render.SetMaterial
local RDrawBox = CLIENT and render.DrawBox
local RMaterialOverride = CLIENT and render.MaterialOverride
local UltrakillBase = UltrakillBase
local Material = Material
local Matrix = Matrix
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_projectile"

-- Misc --

ENT.PrintName = "Virtue Beam"
ENT.Category = "UltrakillBase"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Models = { "" }
ENT.ModelScale = 1
ENT.Spawnable = false

-- Parry --

ENT.UltrakillBase_Parryable = false


-- Variables --


local fVirtueBeamCastDelay = 1
local fVirtueBeamDelay = 0.5
local fVirtueBeamDieTime = 2
local fVirtueBeamHeightMax = 250
local vForceVector = Vector( 0, 0, 400 )
local vBeamBounds = Vector()


if SERVER then


function ENT:CustomInitialize()

  self.mInitTime = CurTime()
  self.mDamage = self.mDamage or 0
  self.mPredictive = self.mPredictive or false
  self.mTracking = self.mTracking or true
  self.mHasVirtueBeamExploded = false
  self.mWindUpMultiplier = self.mWindUpMultiplier or 1
  self.mWindUpMultiplier = fVirtueBeamCastDelay * self.mWindUpMultiplier
  SafeRemoveEntityDelayed( self, fVirtueBeamDieTime + fVirtueBeamDelay + self.mWindUpMultiplier )

end


function ENT:CustomThink()

  if not self.mHasVirtueBeamExploded and CurTime() >= self.mInitTime + self.mWindUpMultiplier then

    self.mHasVirtueBeamExploded = true
    self:CallOnClient( "VirtueBeamExplode" )

  end

  if self.mHasVirtueBeamExploded and CurTime() < self.mInitTime + fVirtueBeamDelay + self.mWindUpMultiplier then

    self:VirtueBeamDamage()

  end

end


function ENT:VirtueBeamDamage()

  local fRadius = self:GetRadius()
  local vOrigin = self:GetPos()
  local aAngles = self:GetAngles()
  local vOffset = aAngles:Up() * fRadius * 140

  vBeamBounds.x = fRadius
  vBeamBounds.y = fRadius
  vBeamBounds.z = fRadius * 0.1
  
  for K, mEntity in ipairs( EFindAlongRay( vOrigin - vOffset, vOrigin + vOffset, -vBeamBounds, vBeamBounds ) ) do

    if not UltrakillBase.CanAttack( mEntity ) or not self:DamageFilter( mEntity ) or self.UltrakillBase_IgnoreFilter[ mEntity:EntIndex() ] then continue end

    self:DealDamage( mEntity, self.mDamage, vForceVector, DMG_BLAST )

    self.UltrakillBase_IgnoreFilter[ mEntity:EntIndex() ] = true

  end

end


else


local aInsigniaRotation = Angle()
local fInsigniaTurnRate = 100
local vInsigniaScale = Vector()
local mInsigniaMaterial = Material( "particles/ultrakill/RageEffect_White" )

local mBeamMaterial = Material( "models/ultrakill/vfx/LightPillars/LightPillar_White" )
local vScaleVector = Vector( 1, 1, 1 )
local vRenderBounds = Vector( 10000, 10000, 100 )
local fHoldTime = 1
local fDieTime = 0.7


function ENT:CustomInitialize()

  self.mBeamCSENT = ClientsideModel( "models/ultrakill/mesh/effects/sphere/Sphere_16.mdl", RENDERGROUP_TRANSLUCENT )
	self.mBeamCSENT:SetPos( self:GetPos() )
	self.mBeamCSENT:SetModelScale( 1 )
	self.mBeamCSENT:SetAngles( self:GetAngles() )
	self.mBeamCSENT:SetNoDraw( true )

  self.mInitTime = CurTime()

  local fRadius = self:GetRadius() * 14

  vRenderBounds.x = fRadius
  vRenderBounds.y = fRadius
  vRenderBounds.z = fRadius * 10

  self:SetRenderBounds( -vRenderBounds, vRenderBounds )

end


function ENT:VirtueBeamExplode()

  self.mHasVirtueBeamExploded = true
  self.mExplodedInitTime = CurTime()

end


function ENT:VirtueBeamExplodeDraw()

  local mMatrix = Matrix()

  local fDelay = 0.5
  local fDeltaTime = CurTime() - ( self.mExplodedInitTime + fVirtueBeamDelay )

  local fRadius = self:GetRadius()
  local fLerpRadius = Lerp( MClamp( fDeltaTime / fVirtueBeamDieTime, 0, 1 ), fRadius, 0 )

  RMaterialOverride( mBeamMaterial )

  vScaleVector:SetUnpacked( fLerpRadius, fLerpRadius, fRadius * 10 )
  mMatrix:SetScale( vScaleVector )

  self.mBeamCSENT:EnableMatrix( "RenderMultiply", mMatrix )
  self.mBeamCSENT:DrawModel()

  RMaterialOverride()

end


function ENT:VirtueBeamDraw()

  aInsigniaRotation:RotateAroundAxis( aInsigniaRotation:Up(), fInsigniaTurnRate * FrameTime() )

  local fRadius = self:GetRadius() * 14
  vInsigniaScale.x = fRadius
  vInsigniaScale.y = fRadius
  vInsigniaScale.z = 0

	RSetMaterial( mInsigniaMaterial )
	RDrawBox( self:GetPos(), self:GetAngles() + aInsigniaRotation, -vInsigniaScale, vInsigniaScale, color_white )

end


function ENT:Draw()

  if self.mHasVirtueBeamExploded then return self:VirtueBeamExplodeDraw() end

  self:VirtueBeamDraw()

end


function ENT:OnRemove()

  SafeRemoveEntity( self.mBeamCSENT )

end


end


function ENT:SetupDataTables()

  self:NetworkVar( "Int", 1, "Radius" )

end


AddCSLuaFile()