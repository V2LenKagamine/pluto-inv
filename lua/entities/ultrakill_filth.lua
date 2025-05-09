local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local DrGBase = DrGBase
local UltrakillBase = UltrakillBase
local Vector = Vector
local USpriteTrail = SERVER and util.SpriteTrail
local Color = Color
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local istable = istable
local tonumber = tonumber
local tobool = tobool
local IsValid = IsValid
local MMax = math.max
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_nextbot"

-- Misc --

ENT.PrintName = "Filth"
ENT.Category = "ULTRAKILL - Enemies"
ENT.Models = { "models/ultrakill/characters/enemies/lesser/filth.mdl" }
ENT.Skins = { 0 }
ENT.ModelScale = 1
ENT.CollisionBounds = Vector( 8, 8, 65 ) * 1.15
ENT.SurroundingBounds = Vector( 25, 25, 85 ) * 1.15
ENT.RagdollOnDeath = true

-- Stats --

ENT.SpawnHealth = 50

-- Sounds --

ENT.UltrakillBase_HurtSoundDelay = 0.1
ENT.UltrakillBase_HurtSound = "Ultrakill_Filth_Hurt"

-- AI --

ENT.MeleeAttackRange = 75
ENT.ReachEnemyRange = 45
ENT.AvoidEnemyRange = 35

-- Detection --

ENT.EyeBone = "Head"

-- Locomotion --

ENT.Acceleration = 2500
ENT.Deceleration = 1500
ENT.JumpHeight = 150
ENT.StepHeight = 20
ENT.MaxYawRate = 400
ENT.DeathDropHeight = 10

-- Animations --

ENT.WalkAnimation = "Run"
ENT.WalkAnimRate = 2
ENT.RunAnimation = "Run"
ENT.RunAnimRate = 2
ENT.IdleAnimation = "Idle"
ENT.IdleAnimRate = 1
ENT.JumpAnimation = "Falling"
ENT.JumpAnimRate = 1

-- Movements --

ENT.UseWalkframes = false
ENT.WalkSpeed = 400
ENT.RunSpeed = 400


-- Tables --


ENT.UltrakillBase_DamageInfo = {

  [ "Bite" ] = { 300, 65, DMG_SLASH, 15, Vector( 400, 0, 0 ) }

}

ENT.UltrakillBase_OnEventTable = {

  [ "BiteTrail" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_FilthBite", self:GetPos(), self )

    local Trail = USpriteTrail( self, 2, Color( 255, 255, 255, 65 ), true, 11, 0, 0.1, 0, "particles/ultrakill/white_trail_additive" )

    SafeRemoveEntityDelayed( Trail, 0.25 / self:CalculateAnimRate( "Bite" ) )

  end,


  [ "Step" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_HuskStep", self:GetPos() )

  end,


  [ "Damage" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Start" and not self:IsParryInterrupted() then

      local DamageData = self.UltrakillBase_DamageInfo[ Seq ]

      if not istable( DamageData ) then return end

      self:ContinuousAttack( {

        Damage = DamageData[ 1 ],
        Range = DamageData[ 2 ],
        Type = DamageData[ 3 ],
        Angle = DamageData[ 4 ],
        Force = DamageData[ 5 ],
        Push = true

      } )

      self:SetContinuousAttack( true )

    else

      self.UltrakillBase_ContinuousAttacksTable = {}

      self:SetContinuousAttack( false )

    end

  end,


  [ "Skin" ] = function( self, Event, Seq )

    self:SetSkin( tonumber( Event[ 2 ] ) )

  end,


  [ "Turn" ] = function( self, Event, Seq )

    if self.UltrakillBase_Difficulty <= 3 then

      self:FaceEnemyInstant( 0 )

    else

      self:FaceEnemyInstant( tonumber( Event[ 2 ] or 0 ) )

    end

  end,


  [ "Flag" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Parry" then

      self:SetParryable( tobool( Event[ 3 ] ) )

    elseif Event[ 2 ] == "Turning" then

      self:SetTurning( tobool( Event[ 3 ] ) )

    end

  end


}

ENT.UltrakillBase_EventTable = {

  [ "Bite" ] = {

    { 0, "Skin 1" },
    { 0, "Turn 0"  },
    { 0, "Flag Parry 0" },

    { 15, "Flag Turning 1" },
    { 15, "Flag Turning 0" },
    { 15, "Flag Parry 1" },

    { 20, "Turn 0.3" },

    { 23, "BiteTrail" },
    { 23, "Damage Start" },

    { 32, "Skin 0" },

    { 35, "Damage Stop" },
    { 35, "Flag Parry 0" }

  },

  [ "Idle" ] = {

    { 0, "Damage Stop" },
    { 0, "Skin 0" },

    { 42, "Skin 1" },

    { 72, "Skin 0" }

  },
  
  [ "Run" ] = {

    { 0, "Damage Stop" },
    { 0, "Skin 0" },

    { 19, "Step" },

    { 39, "Step" }


  },

  [ "Falling" ] = {

    { 0, "Damage Stop" },
    { 0, "Skin 1" }

  }

}

ENT.UltrakillBase_AttackTable = {

  "Bite"

}


-- Possession --

ENT.PossessionCrosshair = true
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.PossessionViews = {

  {

    offset = Vector( 0, 11.5, 34.5 ),
    distance = 115,
    eyepos = false

  },

  {

    offset = Vector( 5.75, 0, 0 ),
    distance = 0,
    eyepos = true

  }

}

ENT.PossessionBinds = {

  [ IN_ATTACK ] = { { coroutine = true, onkeydown = function( self )

    self:FilthBite()

  end } } ,

}


if SERVER then


function ENT:FilthBite( Enemy )

  if not self:IsOnGround() then return end

  self:PlaySequenceAndMove( "Bite", nil, function( self, Cycle )

    if IsValid( Enemy ) and self:IsInRange( Enemy, 50 ) and Cycle > 0.6 or not self:IsOnGround() or Cycle > 0.969543043 then

      return true

    end

  end )

end


function ENT:OnMeleeAttack( Enemy )

  return self:FilthBite( Enemy )

end


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  self:CreatePortal( self:WorldSpaceCenter(), self:GetAngles(), 1, Vector( 30, 30, 70 ) )

  self:ParticleEffectTimed( 1, "Ultrakill_Portal_Filth", { pos = self:WorldSpaceCenter(), ang = self:GetAngles() } )
  UltrakillBase.SoundScript( "Ultrakill_Portal_Light", self:GetPos() )

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

  BaseClass.OnTakeDamage( self, CDamageInfo, HitGroup )

end


function ENT:OnFatalDamage( Dmg, HitGroup )

  if not Dmg:IsDamageType( DMG_BLAST + DMG_BLAST_SURFACE + DMG_VEHICLE + DMG_SLASH + DMG_FALL ) then return end

  UltrakillBase.SoundScript( "Ultrakill_Death", self:GetPos() )

  self.RagdollOnDeath = false

end


function ENT:OnDeath( Dmg, HitGroup )

  UltrakillBase.SoundScript( "Ultrakill_Filth_Death", self:GetPos() )

  self:CreateBlood( Dmg, HitGroup )

  self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

end


end


AddCSLuaFile()
DrGBase.AddNextbot( ENT )