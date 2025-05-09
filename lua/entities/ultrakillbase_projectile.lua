local UltrakillBase = UltrakillBase
local DrGBase = DrGBase
local isvector = isvector
local CurTime = CurTime
local IsValid = IsValid
local UTraceEntityHull = util.TraceEntityHull
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "proj_drg_default"

-- Misc --

ENT.PrintName = "Ultrakill_Projectiles"
ENT.Category = "UltrakillBase"
ENT.Models = { "" }
ENT.ModelScale = 1

ENT.IsUltrakillProjectile = true

-- Physics --

ENT.Gravity = false
ENT.Physgun = false
ENT.Gravgun = false

-- Contact --

ENT.OnContactDelay = 0
ENT.OnContactDelete = 0
ENT.OnContactDecals = {}

-- Sounds --

ENT.LoopSounds = { "" }
ENT.OnContactSounds = {}
ENT.OnRemoveSounds = {}

-- Parry --

ENT.UltrakillBase_Parryable = true

-- Homing --

ENT.UltrakillBase_HomingType = -1
ENT.UltrakillBase_HomingSpeed = 0
ENT.UltrakillBase_HomingMaxSpeed = 0
ENT.UltrakillBase_HomingPredictiveMultiplier = 0
ENT.UltrakillBase_HomingTurningMultiplier = 0
ENT.UltrakillBase_HomingTurningSpeed = 0

-- Collision --

ENT.UltrakillBase_CustomCollisionEnabled = false
ENT.UltrakillBase_CustomCollisionRelationships = {

  [ D_NU ] = false,
  [ D_FR ] = true,
  [ D_ER ] = true,
  [ D_HT ] = true,
  [ D_LI ] = false

}

ENT.UltrakillBase_CustomCollisionBounds = nil

-- Damage --

ENT.UltrakillBase_DamageRelationships = {

  [ D_NU ] = false,
  [ D_FR ] = true,
  [ D_ER ] = true,
  [ D_HT ] = true,
  [ D_LI ] = false

}

ENT.UltrakillBase_IgnoreFilter = {}
ENT.UltrakillBase_Difficulty = 0

DrGBase.IncludeFolder( "ultrakillbase/Projectile" )
DrGBase.IncludeFolder( "ultrakillbase/Shared" )


if SERVER then


function ENT:_BaseInitialize()

  self:DrawShadow( false )
  self:SetTrigger( false )
  self:SetNotSolid( true )

  self:CalculateUpdateInterval()

  self:SetSpawnEffect( false )

  self.UltrakillBase_LastEnemyUpdate = 0
  self.UltrakillBase_LastCollisionCheck = 0
  self.UltrakillBase_CustomCollisionHasCollided = false

  if self.UltrakillBase_CustomCollisionEnabled then

    self:SetCollisionGroup( COLLISION_GROUP_WORLD )

    self.UltrakillBase_CustomCollisionMin, self.UltrakillBase_CustomCollisionMax = self:GetCollisionBounds()

    if isvector( self.UltrakillBase_CustomCollisionBounds ) then

      self.UltrakillBase_CustomCollisionMin, self.UltrakillBase_CustomCollisionMax = -self.UltrakillBase_CustomCollisionBounds, self.UltrakillBase_CustomCollisionBounds

    end

    self:SetCollisionBounds( self.UltrakillBase_CustomCollisionMin, self.UltrakillBase_CustomCollisionMax )

  end

  self.UltrakillBase_Difficulty = UltrakillBase.GetDifficulty()
  self.UltrakillBase_HomingMaxSpeed = self.UltrakillBase_HomingSpeed

  self:SetParryable( self.UltrakillBase_Parryable )
  self:SetParried( false )

  self:NextThink( CurTime() )

end


local mCollisionInterval = 0.0725
local mTraceCollision = {

  mask = MASK_SHOT,
  collisiongroup = COLLISION_GROUP_PROJECTILE,

}


function ENT:_BaseThink()

  self:CalculateUpdateInterval()

  if CurTime() > self.UltrakillBase_LastEnemyUpdate then

    self.UltrakillBase_LastEnemyUpdate = CurTime() + 0.1
    self:UpdateEnemy()

  end

  if self.UltrakillBase_CustomCollisionEnabled and not self.UltrakillBase_CustomCollisionIsCollidingSoon and CurTime() > self.UltrakillBase_LastCollisionCheck then

    mTraceCollision.start = self:GetPos()
    mTraceCollision.endpos = self:GetPos() + self:GetVelocity() * mCollisionInterval
    mTraceCollision.filter = self
    mTraceCollision.mins = self.UltrakillBase_CustomCollisionMin
    mTraceCollision.maxs = self.UltrakillBase_CustomCollisionMax

    local mCollisionTrace = UTraceEntityHull( mTraceCollision, self )

    if mCollisionTrace.Hit and self:ProjectileShouldCollide( mCollisionTrace.Entity ) then

      self:Timer( mCollisionTrace.Fraction * mCollisionInterval, function( self )
      
        if not self.UltrakillBase_CustomCollisionIsCollidingSoon then return end

        self:Contact( mCollisionTrace.Entity )
        self.UltrakillBase_CustomCollisionIsCollidingSoon = false

      end )

      self.UltrakillBase_CustomCollisionIsCollidingSoon = true

    end

    self.UltrakillBase_LastCollisionCheck = CurTime() + mCollisionInterval

  end

  if self.UltrakillBase_HomingType >= 0 and not self:GetParried() and self:HasEnemy() and not self.UltrakillBase_Reflected then

    if not self.UltrakillBase_ProjectileAngle then

      self.UltrakillBase_ProjectileAngle = self:GetAngles()

    end

    if self.UltrakillBase_HomingType == 0 then

      self:GradualHoming()

    elseif self.UltrakillBase_HomingType == 1 then

      self:InstantHoming()

    elseif self.UltrakillBase_HomingType == 2 then

      self:LooseHoming()

    elseif self.UltrakillBase_HomingType == 3 then

      self:HorizontalOnlyHoming()

    else

      self:DefaultHoming()

    end

  end

end


function ENT:Contact( mEntity )

  if ( not IsValid( mEntity ) and not mEntity:IsWorld() ) or mEntity:GetClass() == "trigger_soundscape" or self:IsMarkedForDeletion() then return end

  if self:OnContact( mEntity ) == false then return end

  if self.OnContactDelete == 0 then

    self:Remove()

  elseif self.OnContactDelete > 0 then

    self:Timer( self.OnContactDelete, self.Remove )

  end

end


else


function ENT:_BaseInitialize()

  self:CalculateUpdateInterval()

end


function ENT:_BaseThink()

  self:CalculateUpdateInterval()

end


function ENT:DrawTranslucent()

  self:Draw()

end


end


AddCSLuaFile()