local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local DrGBase = DrGBase
local UltrakillBase = UltrakillBase
local Vector = Vector
local istable = istable
local tobool = tobool
local MMin = math.min
local IsValid = IsValid
local MRandom = math.random
local SafeRemoveEntity = SafeRemoveEntity
local CurTime = CurTime
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_nextbot"


ENT.PrintName = "Hideous Mass"
ENT.Category = "ULTRAKILL - Bosses"

ENT.Models = { "models/ultrakill/characters/enemies/boss/hideousmass.mdl" }
ENT.ModelScale = 1

ENT.CollisionBounds = Vector( 125, 125, 200 )
ENT.SurroundingBounds = Vector( 320, 320, 345 )

-- Stats --

ENT.SpawnHealth = 17500

-- Weight --

ENT.UltrakillBase_WeightClass = "Superheavy"

-- AI --

ENT.AISight = false
ENT.MeleeAttackRange = 10000
ENT.ReachEnemyRange = math.huge
ENT.AvoidEnemyRange = math.huge

-- Detection --

ENT.EyeBone = "spine1"

-- Locomotion --

ENT.Acceleration = 50000
ENT.Deceleration = 50000
ENT.JumpHeight = 0
ENT.StepHeight = 20
ENT.MaxYawRate = 100
ENT.DeathDropHeight = math.huge
ENT.CantMove = true

-- Animations --

ENT.IdleAnimation = "ScoutPose"
ENT.IdleAnimRate = 1
ENT.WalkAnimation = ENT.IdleAnimation
ENT.WalkAnimRate = 1
ENT.RunAnimation = ENT.IdleAnimation
ENT.RunAnimRate = 1
ENT.JumpAnimation = ENT.IdleAnimation
ENT.JumpAnimRate = 1
ENT.FallingAnimation = ENT.IdleAnimation
ENT.FallingAnimRate = 1

-- Movements --

ENT.UseWalkframes = false
ENT.WalkSpeed = 1
ENT.RunSpeed = 1

-- Variables --


ENT.CurrentState = 1


ENT.UltrakillBase_DamageInfo = {

  [ "BattleSwing"  ] = { 400, 300, DMG_CLUB, 90 }

}

ENT.UltrakillBase_AnimRateInfo = {

  [ "BattleWalk" ] = 1.25,
  [ "ScoutFakeDeath" ] = 2.5,
  [ "CrazyPose" ] = 1.5,
  [ "Intro" ] = 0.75,
  [ "BattlePose" ] = 1

}

ENT.UltrakillBase_EnragedRate = 1

ENT.UltrakillBase_IntroInfo = {

  "Intro"

}

ENT.UltrakillBase_OnEventTable = {

  [ "Shockwave" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Stomp" then
  
      self:Shockwave( true, self:GetPos() + self:GetForward() * 350, angle_zero, 300, 4, 100, 0.2 )
  
    else

      local Angles = self:GetAngles()

      Angles:RotateAroundAxis( Angles:Forward(), 90 )

      self:Shockwave( true, self:WorldSpaceCenter() + self:GetForward() * 350, Angles, 200, 1, 100, 0.2 )

    end

  end,


  [ "Mortar" ] = function( self, Event, Seq )

    local Mortar = self:CreateProjectile( "Ultrakill_HideousMass_Mortar_Projectile", true )

    local AttachPos = Event[ 2 ] == "L" and self:GetAttachment( 3 ).Pos or self:GetAttachment( 4 ).Pos

    Mortar:SetOwner( self )
    Mortar:SetPos( AttachPos )
    Mortar:SetAngles( self:GetAimAngles() )
    Mortar:SetVelocity( self:GetUp() * 800 )

    Mortar.Origin = AttachPos

    UltrakillBase.SoundScript( "Ultrakill_HideousMass_Mortar", self:GetPos() )
    
  end,


  [ "Spear" ] = function( self, Event, Seq )

    if self:IsEnraged() then return end

    local Spear = self:CreateProjectile( "Ultrakill_HideousMass_Spear_Projectile", true )

    local AttachPos = self:GetAttachment( 2 ).Pos

    Spear:SetPos( AttachPos )
    Spear:SetOwner( self )

    self:AimProjectile( Spear, 4500 )

    Spear:SetAngles( Spear:GetVelocity():Angle() )

    UltrakillBase.SoundScript( "Ultrakill_HideousMass_Spear_Fire", Spear:GetPos() )

    self.HideousMassSpear = Spear
    
  end,


  [ "GroundBreak" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_RockBreak", self:GetPos() )

    UltrakillBase.CreateGibs( {

      { 
        Position = self:GetPos(),
        Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk1.mdl",
        Velocity = 600,
        ModelScale = 1.5,
        Trail = "Ultrakill_White_Trail"
      },
  
      { 
        Position = self:GetPos(),
        Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk2.mdl",
        Velocity = 600,
        ModelScale = 1.5,
        Trail = "Ultrakill_White_Trail"
      },

      { 
        Position = self:GetPos(),
        Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk1.mdl",
        Velocity = 600,
        ModelScale = 1.5,
        Trail = "Ultrakill_White_Trail"
      },

      { 
        Position = self:GetPos(),
        Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk2.mdl",
        Velocity = 600,
        ModelScale = 1.5,
        Trail = "Ultrakill_White_Trail"
      },
  
    } )
    
  end,


  [ "Damage" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Start" then

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


  [ "Flag" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Parry" then
  
      self:SetParryable( tobool( Event[ 3 ] ) )
  
    elseif Event[ 2 ] == "Turning" then
  
      self:SetTurning( tobool( Event[ 3 ] ) )
  
    end
    
  end

}

ENT.UltrakillBase_EventTable = {

  [ "BattleSlam" ] = {

    { 0, "Damage Stop" },
    { 0, "Flag Parry 0" },
    { 0, "Flag Turning 0" },

    { 78.356412, "Shockwave Stomp" }

  },

  [ "BattleSwing" ] = {

    { 0, "Damage Stop" },
    { 0, "Flag Turning 1" },
    { 0, "Flag Parry 0" },

    { 42.909088, "Flag Turning 0" },

    { 62.909088, "Damage Start" },

    { 69.090906, "Shockwave" },
    { 69.090906, "Damage Stop" }

  },

  [ "ScoutExplosiveFire" ] = {

    { 0, "Damage Stop" },
    { 0, "Flag Parry 0" },
    { 0, "Flag Turning 0" },

    { 69.818184, "Mortar R" },

    { 80.000004, "Mortar L" }

  },

  [ "ScoutSlam" ] = {

    { 0, "Damage Stop" },
    { 0, "Flag Parry 0" },
    { 0, "Flag Turning 0" },

    { 78.798894, "Shockwave Stomp" }

  },

  [ "SpearParried" ] = {

    { 0, "Damage Stop" }

  },

  [ "SpearShoot" ] = {

    { 0, "Damage Stop" },
    { 0, "Flag Turning 1" },

    { 47.636364, "Spear" }

  },

  [ "BattlePose" ] = {

    { 0, "Damage Stop" }

  },

  [ "CrazyPose" ] = {

    { 0, "Damage Stop" }

  },

  [ "BattleWalk" ] = {

    { 0, "Damage Stop" },
    
    { 8.3636364, "Footstep" },

    { 10.0000002, "Footstep" },

    { 33.8181816, "Footstep" },

    { 35.818182, "Footstep" }

  },

  [ "ScoutPose" ] = {

    { 0, "Damage Stop" }

  },

  [ "Intro" ] = {

    { 15.6931062, "GroundBreak" },

    { 63.858042, "GroundBreak" },

    { 121.62762, "GroundBreak" }

  }

}


ENT.UltrakillBase_AttackTable = {

  "BattleSlam",
  "BattleSwing",
  "ScoutSlam",
  "ScoutExplosiveFire",
  "SpearShoot",
  "CrazyPose",

}


-- Possession --

ENT.PossessionCrosshair = true
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_CUSTOM
ENT.PossessionViews = {

  {

    offset = Vector( 0, 14.25, 42.75 ),
    distance = 542.5,
    eyepos = false

  },

  {

    offset = Vector( 7.125, 0, 0 ),
    distance = 0,
    eyepos = true

  }

}


ENT.PossessionBinds = {

  [ IN_ATTACK ] = { { coroutine = true, onkeydown = function( self, Possessor )

    if self.CurrentState == 1 then

      self:MassScoutSlam()

    elseif self.CurrentState == 2 then

      self:MassBattleSlam()

    end

  end } },

  [ IN_ATTACK2 ] = { { coroutine = true, onkeydown = function( self, Possessor )

    if self.CurrentState == 1 then

      self:MassScoutExplosiveFire()

    elseif self.CurrentState == 2 then

      self:MassBattleSlam()

    end

  end } },

  [ IN_RELOAD ] = { { coroutine = true, onkeydown = function( self, Possessor )

    self:MassBattleToScout()

  end } }

}


if SERVER then


function ENT:CustomInitialize()

  self.IdleAnimUpdate = 0

end


function ENT:CustomThink()

  if self:IsEnraged() and self.CurrentState ~= 3 and not self:IsDead() then

    self.CurrentState = 3

    self.IdleAnimation = "CrazyPose"
    self.WalkAnimation = self.IdleAnimation
    self.RunAnimation = self.IdleAnimation
    self.JumpAnimation = self.IdleAnimation
    self.FallingAnimation = self.IdleAnimation

  end

  if self:Health() <= self:GetMaxHealth() * 0.2 and self:GetPhase() < 2 and not self:IsDead() and not self:IsAttacking() then

    self:SetPhase( 2 )
    self:OnPhaseChange( 2 )

  end

  if self:IsEnraged() and self:GetCooldown( "CrazyMortar" ) <= 0 and not self:IsDead() then

    if not self.CurrentMortarCycle then

      self.CurrentMortarCycle = true

    elseif self.CurrentMortarCycle then

      self.CurrentMortarCycle = false

    end

    self:OnAnimEvent( "Mortar " .. ( self.CurrentMortarCycle and "L" or "R" ) )
    self:SetCooldown( "CrazyMortar", 2 / self:CalculateAnimRate( "CrazyPose" ) )

  end

end


function ENT:MassScoutSlam( Enemy )

  if self:GetCooldown( "ScoutSlam" ) > 0 or ( self.CurrentMortarTracker < 2 and not self:IsPossessed() ) then return end

  UltrakillBase.SoundScript( "Ultrakill_HideousMass_Windup", self:GetPos() )

  self:PlaySequenceAndMove( "ScoutSlam", 1, function( self, Cycle )

    if Cycle > 0.97164936 or self:IsEnraged() then

      return true

    end

  end )

  self.CurrentState = 2

  self.IdleAnimation = "BattlePose"
  self.WalkAnimation = self.IdleAnimation
  self.RunAnimation = self.IdleAnimation
  self.JumpAnimation = self.IdleAnimation
  self.FallingAnimation = self.IdleAnimation

  self:SetCooldown( "Attack", 2 / self:CalculateAnimRate() )
  self:SetCooldown( "BattleToScout", 4 )

  self:MassBattleSwing( Enemy )

end


function ENT:MassScoutExplosiveFire( Enemy )

  if self:GetCooldown( "Mortar" ) > 0 then return end

  self.CurrentMortarTracker = MMin( self.CurrentMortarTracker + 1, 10 )

  self:PlaySequenceAndMove( "ScoutExplosiveFire", 1, function( self, Cycle )

    if Cycle > 0.972727312 or self:IsEnraged() then

      return true

    end

  end )

  self:SetCooldown( "Attack", 2 / self:CalculateAnimRate() )

end


function ENT:MassBattleSlam( Enemy )

  if IsValid( self.HideousMassSpear ) then return self:MassBattleSwing( Enemy ) end

  UltrakillBase.SoundScript( "Ultrakill_HideousMass_Windup", self:GetPos() )

  self:PlaySequenceAndMove( "BattleSlam", 1, function( self, Cycle )

    if Cycle > 0.97164936 or self:IsEnraged() then

      return true

    end

  end )

  self:MassBattleSwing( Enemy )

  self:SetCooldown( "Attack", 2.5 / self:CalculateAnimRate() )

end


function ENT:MassBattleSwing( Enemy )

  UltrakillBase.SoundScript( "Ultrakill_HideousMass_Windup_High", self:GetPos() )

  self:FaceEnemyInstant()

  self:PlaySequenceAndMove( "BattleSwing", 1, function( self, Cycle )

    if Cycle > 0.969697 or self:IsEnraged() then

      return true

    end

  end )

  self:MassSpearShoot( Enemy )

  self:SetCooldown( "Attack", 2.5 / self:CalculateAnimRate() )

end


function ENT:MassSpearShoot( Enemy )

  if self:GetCooldown( "Spear" ) > 0 then return end

  UltrakillBase.SoundScript( "Ultrakill_HideousMass_Spear_Windup", self:GetPos() )

  self:CreateAlert( self:GetAttachment( 2 ).Pos, 3, 2 )

  self:PlaySequenceAndMove( "SpearShoot", 1, function( self, Cycle )

    if self:IsEnraged() then

      return true

    end

  end )

  self.SlamCombo = false

  self:SetCooldown( "Attack", 2 / self:CalculateAnimRate() )
  self:SetCooldown( "Spear", 14 / self:CalculateAnimRate() )

end


function ENT:MassSpearParried( Enemy )

  UltrakillBase.SoundScript( "Ultrakill_HideousMass_BigPain", self:GetPos() )

  self:PlaySequenceAndMove( "SpearParried", 1, function( self, Cycle )

    if self:IsEnraged() then

      return true

    end

  end )

end


function ENT:MassBattleToScout( Enemy )

  if self:GetCooldown( "BattleToScout" ) > 0 or IsValid( self.HideousMassSpear ) then return end

  self:PlaySequenceAndMove( "BattleToScout", 1, function( self, Cycle )

    if Cycle > 0.830303 or self:IsEnraged() then

      return true

    end

  end )

  self.CurrentState = 1

  self.IdleAnimation = "ScoutPose"
  self.WalkAnimation = self.IdleAnimation
  self.RunAnimation = self.IdleAnimation
  self.JumpAnimation = self.IdleAnimation
  self.FallingAnimation = self.IdleAnimation

  self:SetCooldown( "Attack", 2 / self:CalculateAnimRate() )
  self:SetCooldown( "ScoutSlam", 3 )

end


function ENT:OnMeleeAttack( Enemy )

  if self:GetCooldown( "Attack" ) > 0 then return end

  if self.CurrentState == 1 then

    local Random = MRandom( 2 )

    if Random == 1 then

      return self:MassScoutSlam()

    else

      return self:MassScoutExplosiveFire()

    end

  elseif self.CurrentState == 2 then

    local Random = MRandom( 2 )

    if Random == 1 then

      return self:MassBattleSlam()

    else

      return self:MassBattleToScout()

    end

  else

    return

  end
  
end


function ENT:OnPhaseChange( Phase )

  if Phase ~= 2 or self:IsDead() then return end

  self:SetEnraged( true )

  self:SetSkin( 1 )

  self:ScreenShake( 150, 10, 1, 2550 )

  UltrakillBase.SoundScript( "Ultrakill_Enrage", self:GetPos(), self )
  UltrakillBase.SoundScript( "Ultrakill_Enrage_Loop", self:GetPos(), self )
  UltrakillBase.SoundScript( "Ultrakill_HideousMass_Loop", self:GetPos(), self )

  self:CreateEnrage( 1, 3.5 )

  SafeRemoveEntity( self.HideousMassSpear )

  self:SetCooldown( "CrazyMortar", 1 )

  self.CurrentState = 3

  self.IdleAnimation = "CrazyPose"
  self.WalkAnimation = self.IdleAnimation
  self.RunAnimation = self.IdleAnimation
  self.JumpAnimation = self.IdleAnimation
  self.FallingAnimation = self.IdleAnimation

end


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  self:SetNoTarget( true )
  self:SetGodMode( true )
  self:SetSandable( false )
  self:SetTurning( false )

  self:Timer( 1, UltrakillBase.PlayMusic, "1-3" )

  self:PlaySequenceAndMove( "Intro", 1, function( self, Cycle )

    if Cycle > 0.957575718 then return true end

  end )

  self:SetNoTarget( false )
  self:SetGodMode( false )
  self:SetSandable( true )

  UltrakillBase.AddBoss( self, "#ultrakill.mass.boss" )

  self:SetCooldown( "Attack", 2 / self:CalculateAnimRate() )

  self.CurrentMortarTracker = 0

end


ENT.UltrakillBase_HitGroupMultipliers = {

  [ HITGROUP_HEAD ] = { 3, "Ultrakill_HeadBreak" },
  [ HITGROUP_GEAR ] = { 0, "Ultrakill_Bullet_Ricochet" },

}

function ENT:OnTakeDamage( CDamageInfo, Hitgroup )

  self:DamageMultiplier( CDamageInfo, Hitgroup )
  self:CreateBlood( CDamageInfo, Hitgroup )

end


function ENT:OnRemove()

  if self:GetEnraged() then UltrakillBase.SoundScript( "Ultrakill_Enrage_End", self:GetPos() ) end

  UltrakillBase.StopCurrentMusic( self )

end


function ENT:OnDeath( Dmg, HitGroup )

  UltrakillBase.SoundScript( "Ultrakill_HideousMass_Death", self:GetPos(), self )

  UltrakillBase.StopCurrentMusic( self, false, true )

  self:SetEnraged( false )

  self:SetSkin( 0 )

  self:Shake( 6, 8 )

  local Now = CurTime() + 3
  local Cycle = self:GetCycle()
  local Seq = self:GetSequence()

  local RandomVec = Vector()

  while Now > CurTime() do

    self:SetPlaybackRate( 0 )
    self:SetCycle( Cycle )
    self:SetSequence( Seq )

    if self:GetCooldown( "BloodSplatter" ) <= 0 then

      RandomVec:Random( -60, 60 )

      UltrakillBase.CreateBlood( self:WorldSpaceCenter() + RandomVec, 24 )
      UltrakillBase.SoundScript( "Ultrakill_Death", self:GetPos() )

      self:SetCooldown( "BloodSplatter", 0.3333 )

    end

    self:YieldCoroutine()

  end

  for X = 1, 6 do

    RandomVec:Random( -60, 60 )

    UltrakillBase.CreateBlood( self:WorldSpaceCenter() + RandomVec, 32 )

  end

  UltrakillBase.RemoveBoss( self ) 

  UltrakillBase.SoundScript( "Ultrakill_Death_Explode", self:GetPos() )

  UltrakillBase.SlowMotion( 2 )

end


end



AddCSLuaFile()
DrGBase.AddNextbot( ENT )