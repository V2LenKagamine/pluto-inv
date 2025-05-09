local Vector = Vector
local CurTime = CurTime
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local Lerp = Lerp
local EFindInSphere = ents.FindInSphere
local UltrakillBase = UltrakillBase
local UIsOBBIntersectingOBB = util.IsOBBIntersectingOBB
local Material = Material
local Color = Color
local Matrix = Matrix
local RSetMaterial = CLIENT and render.SetMaterial
local RDrawBox = CLIENT and render.DrawBox
local AddCSLuaFile = AddCSLuaFile


if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_projectile"

-- Misc --

ENT.PrintName = "Shockwave_Projectile"
ENT.Category = "UltrakillBase"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Models = { "models/ultrakill/mesh/effects/shockwave/Shockwave.mdl" }
ENT.ModelScale = 0
ENT.Spawnable = false

-- Parry --

ENT.UltrakillBase_Parryable = false


local fSphereRadius = 2400
local vForceVector = Vector( 0, 0, 400 )


if SERVER then


function ENT:CustomInitialize()

  self.mInitTime = CurTime()
  self.mShockwaveBounds = Vector()
  self.mShockwaveTolerance = 0.1
  self.mDamage = self.mDamage or 300

  self:PhysicsDestroy()
  self:SetTime( self:GetTime() / self:CalculateRate() )

  SafeRemoveEntityDelayed( self, self:GetTime() )

end


function ENT:CustomThink()

  local fDeltaTime = CurTime() - self.mInitTime
  local fModelSize = Lerp( fDeltaTime / self:GetTime(), 0, self:GetRadius() )
  local fRadius = fModelSize * 22
  local fRange = fRadius * 0.75

  local vPos = self:GetPos()
  local aAngles = self:GetAngles()
  local vShockwaveBounds = self.mShockwaveBounds
  local fShockwaveTolerance = self.mShockwaveTolerance

  vShockwaveBounds.x = fRadius
  vShockwaveBounds.y = fRadius
  vShockwaveBounds.z = ( 8 * self:GetScaleZ() ) * 50

  for K, mEntity in ipairs( EFindInSphere( vPos, fSphereRadius * fModelSize * 0.01 * 1.5 ) ) do 

    if not UltrakillBase.CanAttack( mEntity ) or not self:DamageFilter( mEntity ) or self.UltrakillBase_IgnoreFilter[ mEntity:EntIndex() ] then continue end

    local vEntPos = mEntity:GetPos()
    local aEntAngles = mEntity:GetAngles()
    local vEntBoundsMin, vEntBoundsMax = mEntity:GetCollisionBounds()

    local bIsWithin = UIsOBBIntersectingOBB( vPos, aAngles, -vShockwaveBounds, vShockwaveBounds, vEntPos, aEntAngles, vEntBoundsMin, vEntBoundsMax, fShockwaveTolerance )
    if not bIsWithin or vEntPos:DistToSqr( vPos ) < fRange * fRange then continue end

    self:DealDamage( mEntity, self.mDamage, vForceVector, DMG_BLAST )

    self.UltrakillBase_IgnoreFilter[ mEntity:EntIndex() ] = true

  end

  return 0.05

end


else


local mShockwaveMaterial = Material( "particles/ultrakill/Shockwave" )
local vScaleVector = Vector( 1, 1, 1 )
local cShockwaveColor = Color( 255, 255, 255, 100 )
local vRenderBounds = Vector( 1000, 1000, 100 )


function ENT:CustomInitialize()

  self.mInitTime = CurTime()

  local fRadius = self:GetRadius() * 22

  vRenderBounds.x = fRadius
  vRenderBounds.y = fRadius
  vRenderBounds.z = 100

  self:SetRenderBounds( -vRenderBounds, vRenderBounds )

end


function ENT:CustomDraw()

  local mMatrix = Matrix()
  local fDeltaTime = CurTime() - self.mInitTime
  local fModelSize = Lerp( fDeltaTime / self:GetTime(), 0, self:GetRadius() )
  local fScaleZ = ( 1 / ( fModelSize / self:GetRadius() ) ) * self:GetScaleZ()

  self:SetModelScale( fModelSize )

  vScaleVector.x = 1
  vScaleVector.y = 1
  vScaleVector.z = fScaleZ

  mMatrix:SetScale( vScaleVector )
  
  self:EnableMatrix( "RenderMultiply", mMatrix )

  vScaleVector.x = fModelSize * 25
  vScaleVector.y = fModelSize * 25
  vScaleVector.z = 0

  RSetMaterial( mShockwaveMaterial )
  RDrawBox( self:GetPos() + self:GetUp() * 120 * self:GetScaleZ(), self:GetAngles(), -vScaleVector, vScaleVector, cShockwaveColor )

end


end

-- Network Vars --

function ENT:SetupDataTables()

  self:NetworkVar( "Float", 0, "Time" )
  self:NetworkVar( "Int", 1, "Radius" )
  self:NetworkVar( "Float", 1, "ScaleZ" )

end


AddCSLuaFile()