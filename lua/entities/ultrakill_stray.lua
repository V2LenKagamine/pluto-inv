local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local DrGBase = DrGBase
local UltrakillBase = UltrakillBase
local Vector = Vector
local EffectData = EffectData
local UEffect = util.Effect
local tobool = tobool
local MMax = math.max
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_nextbot"

-- Misc --

ENT.PrintName = "Stray"
ENT.Category = "ULTRAKILL - Enemies"
ENT.Models = {"models/ultrakill/characters/enemies/lesser/stray.mdl"}
ENT.Skins = { 0 }
ENT.ModelScale = 1
ENT.CollisionBounds = Vector( 6, 6, 72 ) * 1.3
ENT.SurroundingBounds = Vector( 35, 35, 85 ) * 1.3
ENT.RagdollOnDeath = true

-- Stats --

ENT.SpawnHealth = 150

-- Sounds --

ENT.UltrakillBase_HurtSoundDelay = 0.1
ENT.UltrakillBase_HurtSound = "Ultrakill_Husk_Hurt"

-- AI --

ENT.MeleeAttackRange = 0
ENT.RangeAttackRange = 2000
ENT.ReachEnemyRange = 750
ENT.AvoidEnemyRange = 255

-- Detection --

ENT.EyeBone = "Head"

-- Locomotion --

ENT.Acceleration = 2500
ENT.Deceleration = 1500
ENT.JumpHeight = 150
ENT.StepHeight = 20
ENT.MaxYawRate = 400
ENT.DeathDropHeight = 30

-- Animations --

ENT.WalkAnimation = "Walk"
ENT.WalkAnimRate = 1
ENT.RunAnimation = "Run"
ENT.RunAnimRate = 1
ENT.IdleAnimation = "Idle"
ENT.IdleAnimRate = 1
ENT.JumpAnimation = "Falling"
ENT.JumpAnimRate = 1

-- Movements --

ENT.UseWalkframes = false
ENT.WalkSpeed = 80
ENT.RunSpeed = 200


-- Tables --

ENT.UltrakillBase_AnimRateInfo = {

  [ "ThrowProjectile" ] = 1.5

}

ENT.UltrakillBase_OnEventTable = {

  [ "CreateHellProjectile" ] = function( self, Event, Seq )

    local Time = 0.7333 / self:CalculateAnimRate( "ThrowProjectile" )

    UltrakillBase.SoundScript( "Ultrakill_Projectile_Windup", self:GetPos(), self, Time )

    local CEffectData = EffectData()

      CEffectData:SetEntity( self )
      CEffectData:SetMagnitude( Time * 100 )

    UEffect( "Ultrakill_Stray_Charge", CEffectData, true, true )

  end,


  [ "Step" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_HuskStep", self:GetPos() )

  end,


  [ "HellProjectile" ] = function( self, Event, Seq )

    local Proj = self:CreateProjectile( "Ultrakill_Stray_Projectile", true )
    Proj:SetPos( self:GetAttachment( 2 ).Pos )
    Proj:SetAngles( self:GetAngles() )
    self:AimProjectile( Proj, 2000 )

    UltrakillBase.SoundScript( "Ultrakill_Projectile_Shoot", self:GetPos(), self )

  end,


  [ "Flag" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Parry" then

      self:SetParryable( tobool( Event[ 3 ] ) )

    elseif Event[ 2 ] == "Turning" then

      self:SetTurning( tobool( Event[ 3 ] ) )

    elseif Event[ 2 ] == "Interrupt" then

      self:SetInterruptable( tobool( Event[ 3 ] ) )

    end

  end


}

ENT.UltrakillBase_EventTable = {

  [ "ThrowProjectile" ] = {

    { 0, "Flag Turning 1" },
    { 0, "Flag Interrupt 0" },

    { 30, "CreateHellProjectile" },
    { 30, "Flag Interrupt 1" },

    { 70, "Flag Parry 1" },

    { 74, "Flag Parry 0" },
    { 74, "Flag Interrupt 0" },
    { 74, "HellProjectile" }

  },

  [ "Walk" ] = {

    { 22, "Step" },

    { 35, "Step" }

  },

  [ "Run" ] = {

    { 28, "Step" },

    { 41, "Step" }

  }

}

ENT.UltrakillBase_AttackTable = {

  "ThrowProjectile"

}


-- Possession --

ENT.PossessionCrosshair = true
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.PossessionViews = {

  {

    offset = Vector( 0, 13, 40 ),
    distance = 130,
    eyepos = false

  },

  {

    offset = Vector( 6.5, 0, 0 ),
    distance = 0,
    eyepos = true

  }

}

ENT.PossessionBinds = {

  [ IN_ATTACK ] = { { coroutine = true, onkeydown = function( self )

    self:HuskThrow()

  end } },

}


if SERVER then


function ENT:HuskThrow( Enemy )

  if self:GetCooldown( "ThrowProjectile" ) > 0 or not self:IsOnGround() then

    return

  end

  self:PlaySequenceAndMove( "ThrowProjectile", nil, function( self, Cycle )

    if not self:IsOnGround() then

      return true

    end

  end )

  self:SetCooldown( "ThrowProjectile", 0.5 / self:CalculateAnimRate( "ThrowProjectile" ) )
  self:SetInterruptable( false )

end


function ENT:OnRangeAttack( Enemy )

  if self:IsInRange( Enemy, self.AvoidEnemyRange ) then

    return

  end

  self:HuskThrow( Enemy )

end


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  self:CreatePortal( self:WorldSpaceCenter(), self:GetAngles(), 2, Vector( 40, 40, 100 ) )

  self:ParticleEffectTimed( 2, "Ultrakill_Portal_Stray", { pos = self:WorldSpaceCenter(), ang = self:GetAngles() } )
  UltrakillBase.SoundScript( "Ultrakill_Portal_Heavy", self:GetPos() )

end


function ENT:OnFallDamage( Speed )

  if self:IsClimbing() then

    return 0

  end

  UltrakillBase.SoundScript( "Ultrakill_Landing", self:GetPos(), self )

  return MMax( 0, Speed - 300 ) * 10

end


function ENT:OnLeaveGround( Ent )

  if self:IsClimbing() then

    return
    
  end

  self:Timer( 0.7, function( self )
  
    if self:IsOnGround() then return end

    UltrakillBase.SoundScript( "Ultrakill_Human_Scream", self:GetPos(), self )

  end )
  
end


function ENT:OnTakeDamage( CDamageInfo, HitGroup )

  self:CheckInterrupt( CDamageInfo, 2 )

  BaseClass.OnTakeDamage( self, CDamageInfo, HitGroup )

end


function ENT:OnFatalDamage( Dmg, HitGroup )

  if not Dmg:IsDamageType( DMG_BLAST + DMG_BLAST_SURFACE + DMG_VEHICLE + DMG_SLASH + DMG_FALL ) then return end

  UltrakillBase.SoundScript( "Ultrakill_Death", self:GetPos() )

  self.RagdollOnDeath = false

end


function ENT:OnDeath( Dmg, HitGroup )

  UltrakillBase.SoundScript( "Ultrakill_Husk_Death", self:GetPos() )

  self:CreateBlood( Dmg, HitGroup )

  self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

end


end


AddCSLuaFile()
DrGBase.AddNextbot( ENT )