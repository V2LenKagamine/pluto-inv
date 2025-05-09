local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local DrGBase = DrGBase
local UltrakillBase = UltrakillBase
local Vector = Vector
local EffectData = EffectData
local UEffect = util.Effect
local Angle = Angle
local tonumber = tonumber
local tobool = tobool
local MRandom = math.random
local MMax = math.max
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_nextbot"

-- Misc --

ENT.PrintName = "Schism"
ENT.Category = "ULTRAKILL - Enemies"
ENT.Models = {"models/ultrakill/characters/enemies/greater/schism.mdl"}
ENT.Skins = { 0 }
ENT.ModelScale = 1
ENT.CollisionBounds = Vector( 8, 8, 70 ) * 1.1
ENT.SurroundingBounds = Vector( 35, 35, 85 ) * 1.1
ENT.RagdollOnDeath = true

-- Stats --

ENT.SpawnHealth = 500

-- Sounds -- 

ENT.UltrakillBase_HurtSoundDelay = 0.1
ENT.UltrakillBase_HurtSound = "Ultrakill_Husk_Hurt"

-- AI --

ENT.MeleeAttackRange = 0
ENT.RangeAttackRange = 1200
ENT.ReachEnemyRange = 250
ENT.AvoidEnemyRange = 0

-- Detection --

ENT.EyeBone = "Shoulder.R"

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
ENT.WalkSpeed = 100
ENT.RunSpeed = 200


-- Tables --

ENT.UltrakillBase_AnimRateInfo = {

  [ "ShootVertical" ] = 1.5,
  [ "ShootHorizontal" ] = 1.5

}

ENT.UltrakillBase_OnEventTable = {

  [ "CreateHellProjectile" ] = function( self, Event, Seq )

    local Time = 0.8 / self:CalculateAnimRate( Seq )

    UltrakillBase.SoundScript( "Ultrakill_Projectile_Windup", self:GetPos(), self, Time )

    local CEffectData = EffectData()

      CEffectData:SetEntity( self )
      CEffectData:SetMagnitude( Time * 100 )

    UEffect( "Ultrakill_Schism_Charge", CEffectData, true, true )

  end,


  [ "Step" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_HuskStep", self:GetPos() )

  end,


  [ "HellProjectile" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_Projectile_Shoot", self:GetPos(), self )

    local Proj = self:CreateProjectile( "Ultrakill_Schism_Projectile", true )

    local Attach = self:GetAttachment( 2 )
    local Ang = Angle( 0, 0, 0 )

    local Offset

    if Event[ 2 ] == "Right" then

      Ang:RotateAroundAxis( Ang:Up(), ( -tonumber(Event[ 3 ]) ) / 3 )

    elseif Event[ 2 ] == "Up" then

      Ang:RotateAroundAxis( Ang:Right(), ( tonumber(Event[ 3 ]) ) / 3 )

    end

    Proj:SetPos( Attach.Pos )

    self:AimProjectile( Proj, 2000, Ang:Forward() * 1000 )

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

  [ "ShootHorizontal" ] = {

    { 0, "Flag Parry 0" },
    { 0, "Flag Turning 1" },

    { 17, "CreateHellProjectile" },
    { 17, "Flag Interrupt 1" },

    { 57, "Flag Parry 1" },

    { 69, "Flag Interrupt 0" },
    { 69, "HellProjectile Right 110" },

    { 80, "Flag Turning 1" },

    { 79, "HellProjectile Right 75" },

    { 89, "HellProjectile Right 0" },

    { 99, "HellProjectile Right -15" },

    { 109, "HellProjectile Right -75" },

    { 119, "HellProjectile Right -110" },

    { 121, "Flag Parry 0" }

  },

  [ "ShootVertical" ] = {

    { 0, "Flag Parry 0" },
    { 0, "Flag Turning 1"},

    { 25, "CreateHellProjectile"},

    { 30, "Flag Interrupt 1"},

    { 57, "Flag Parry 1"},

    { 70, "Flag Interrupt 0"},
    { 70, "HellProjectile Up 180"},

    { 80, "Flag Turning 1"},
    { 80, "HellProjectile Up 90"},

    { 90, "HellProjectile Up 25"},

    { 100, "HellProjectile Up 0"},

    { 110, "HellProjectile Up -45"},

    { 120, "HellProjectile Up -75"},

    { 124, "Flag Parry 0"},

    { 142, "Flag Turning 1"}

  },

  [ "Walk" ] = {

    { 23, "Step" },

    { 39, "Step" }

  },

  [ "Run" ] = {

    { 23, "Step" },

    { 39, "Step" }

  }
  
}

ENT.UltrakillBase_AttackTable = {

  "ShootVertical",
  "ShootHorizontal"

}


-- Possession --

ENT.PossessionCrosshair = true
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.PossessionViews = {

  {

    offset = Vector( 0, 11, 33 ),
    distance = 110,
    eyepos = false

  },

  {

    offset = Vector( 5.5, 0, 0 ),
    distance = 0,
    eyepos = true

  }

}

ENT.PossessionBinds = {

  [ IN_ATTACK ] = { { coroutine = true, onkeydown = function( self )

    self:SchismShoot( nil, "Horizontal" )

  end } },

  [ IN_ATTACK2 ] = { { coroutine = true, onkeydown = function( self )

    self:SchismShoot( nil, "Vertical" )

  end } },

}


if SERVER then


function ENT:SchismShoot( Enemy, Variant )

  if Variant ~= "Vertical" and Variant ~= "Horizontal" then Variant = "Horizontal" end

  if self:GetCooldown( "Shoot" ) > 0 or not self:IsOnGround() then

    return

  end

  self:PlaySequenceAndMove( "Shoot" .. Variant, nil, function( self, Cycle )

    if not self:IsOnGround() then

      return true

    end

  end )

  self:SetCooldown( "Shoot", 0.5 )
  self:SetInterruptable( false )

end


function ENT:OnRangeAttack( Enemy )

  if self:IsInRange( Enemy, self.AvoidEnemyRange ) then

    return

  end

  local Random = MRandom( 2 )

  if Random == 1 then

    self:SchismShoot( "Vertical" )

  elseif Random == 2 then

    self:SchismShoot( "Horizontal" )
    
  end

end


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  self:CreatePortal( self:WorldSpaceCenter(), self:GetAngles(), 2, Vector( 45, 45, 75 ) )

  self:ParticleEffectTimed( 2, "Ultrakill_Portal_Heavy", { pos = self:WorldSpaceCenter(), ang = self:GetAngles() } )
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