local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local DrGBase = DrGBase
local UltrakillBase = UltrakillBase
local Vector = Vector
local isstring = isstring
local EffectData = EffectData
local UEffect = util.Effect
local tonumber = tonumber
local istable = istable
local tobool = tobool
local CurTime = CurTime
local Color = Color
local MRandom = math.random
local Angle = Angle
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_nextbot"

-- Misc --

ENT.PrintName = "Mindflayer"
ENT.Category = "ULTRAKILL - Enemies"
ENT.Models = { "models/ultrakill/characters/enemies/greater/mindflayer.mdl" }
ENT.ModelScale = 1
ENT.CollisionBounds = Vector( 6, 6, 70 ) * 1.425
ENT.SurroundingBounds = Vector( 100, 100, 185 ) * 1.425

-- Stats --

ENT.SpawnHealth = 3000
ENT.UltrakillBase_Phase = 1
ENT.UltrakillBase_PhaseMax = 2

-- Weight --

ENT.UltrakillBase_WeightClass = "Heavy"

-- Sounds --

ENT.UltrakillBase_HurtSoundDelay = 0.1
ENT.UltrakillBase_HurtSound = "Ultrakill_MindFlayer_Hurt"

-- AI --

ENT.AISight = false
ENT.MeleeAttackRange = 75
ENT.RangeAttackRange = 10000
ENT.ReachEnemyRange = 405
ENT.AvoidEnemyRange = 35
ENT.BehaviourStrafe = true
ENT.BehaviourStrafeUpdate = 2

-- Detection --

ENT.EyeBone = "spine.002"

-- Locomotion --

ENT.Flying = true
ENT.Acceleration = 5000
ENT.Deceleration = 5000
ENT.JumpHeight = 500
ENT.StepHeight = 20
ENT.MaxYawRate = 400
ENT.DeathDropHeight = math.huge

-- Animations --

ENT.WalkAnimation = "Idle"
ENT.WalkAnimRate = 1
ENT.RunAnimation = "Idle"
ENT.RunAnimRate = 1
ENT.IdleAnimation = "Idle"
ENT.IdleAnimRate = 1
ENT.JumpAnimation = "Idle"
ENT.JumpAnimRate = 1

-- Movements --

ENT.UseWalkframes = false
ENT.WalkSpeed = 200
ENT.RunSpeed = 200


-- FullTracking --


ENT.UltrakillBase_FullTrackingBone = "root"
ENT.UltrakillBase_FullTracking = true

-- Tables --


local MindFlayerBounds = Vector( 2, 2, 2 )


ENT.UltrakillBase_AnimRateInfo = {

  [ "Idle" ] = 1.25,
  [ "MeleeAttack" ] = 1.5,
  [ "HomingAttack" ] = 1.75,
  [ "BeamStart" ] = 1,
  [ "BeamEnd" ] = 1,
  [ "BeamHold" ] = 1,
  [ "Death" ] = 1

}

ENT.UltrakillBase_EnragedRate = 1.15


ENT.UltrakillBase_DamageInfo = {

  [ "MeleeAttack" ] = { 300, 180, DMG_SLASH, 35, Vector( 400, 0, 300 ) },
  [ "Beam" ] = { 350, 2000, DMG_SHOCK, 8 }

}


ENT.UltrakillBase_OnEventTable = {

  [ "Teleport" ] = function( self, Event, Seq )

    if isstring( Event[ 2 ] ) and Event[ 2 ] == "Enraged" and not self:IsEnraged() then return end

    local Origin = self:HasEnemy() and self:GetEnemy():WorldSpaceCenter() or self:WorldSpaceCenter()

    local RandomVec = Origin + UltrakillBase.RandomInSphere( self, Origin, 250 )

    local StartAngles = self:GetAngles()

    UltrakillBase.Teleport( self, RandomVec, function( self, StartPos, EndPos )

      UltrakillBase.SoundScript( "Ultrakill_Teleport", self:GetPos(), self )

      local CEffectData = EffectData()

        CEffectData:SetOrigin( StartPos )
        CEffectData:SetAngles( StartAngles )
        CEffectData:SetStart( self:IsEnraged() and Vector( 0.95, 0, 0.15 ) * 10 or Vector( 0, 0.95, 0.7 ) * 10 )
        CEffectData:SetEntity( self )
        CEffectData:SetMagnitude( 1 )

      UEffect( "Ultrakill_AfterImage", CEffectData, true, true )

      self:ScreenShake( 5, 0.2, 0.35, 750 )

    end )

    self:FaceEnemyInstant( self:IsEnraged() and ( tonumber( Event[ 3 ] or 0 ) / self:CalculateAnimRate( Seq ) ) or 0 )

  end,


  [ "Alert" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Parry" then

      self:CreateAlertFollow( self, 1, 1.25, 2 )

    else

      self:CreateAlertFollow( self, 2, 1.25, 2 )

    end
    
  end,


  [ "Damage" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Start" then

      local DamageData = self.UltrakillBase_DamageInfo[ Seq ]

      if not istable( DamageData ) then return end

      UltrakillBase.SoundScript( "Ultrakill_MindFlayer_Melee", self:GetPos() )

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


  [ "HomingProjectile" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_MindFlayer_Projectile", self:GetPos(), self )

    for X = 3, 7 do

      local Proj = self:CreateProjectile( "Ultrakill_Mindflayer_Projectile", true )
      Proj:SetPos( self:GetAttachment( X ).Pos )

      if not self:HasEnemy() then

        self:AimProjectile( Proj, 2500 )

      end

    end
    
  end,


  [ "Charging" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Spawn" then

      self:ParticleEffectSlot( "Mindflayer_Charging", "Ultrakill_Mindflayer_Charging", { parent = self, attachment = "Spine2_Attach" } )

    elseif Event[ 2 ] == "Destroy" then

      self:ClearParticleEffectSlot( "Mindflayer_Charging" )

    end
    
  end,


  [ "Flag" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Parry" then

      if self:GetPhase() ~= 1 then return end

      self:SetParryable( tobool( Event[ 3 ] ) )

    elseif Event[ 2 ] == "Turning" then

      self:SetTurning( tobool( Event[ 3 ] ) )

    end
    
  end

}


ENT.UltrakillBase_EventTable = {

  [ "MeleeAttack" ] = {

    { 0, "Damage Stop" },
    { 0, "Stamina 1" },
    { 0, "Flag Turning 1" },
    { 0, "Flag Parry 0" },

    { 4, "Teleport Enraged" },

    { 11, "Teleport" },

    { 19, "Alert Parry" },
    { 19, "Flag Parry 1" },
    { 19, "Flag Turning 0" },

    { 31, "Damage Start" },

    { 37, "Damage Stop" },
    { 37, "Flag Parry 0" },

    { 40, "Flag Turning 1"  }
  
  },

  [ "HomingAttack" ] = {

    { 0, "Damage Stop" },
    { 0, "Flag Parry 0" },
    { 0, "Charging Spawn" },

    { 51, "Teleport" },

    { 67, "Charging Destroy" },
    { 67, "HomingProjectile" }

  },

  [ "BeamEnd" ] = {

    { 0, "Damage Stop" },
    { 0, "Flag Parry 0" },
    { 0, "Charging Destroy" },

    { 10, "Flag Turning 1" }

  },

  [ "BeamHold" ] = {

    { 0, "Flag Parry 0" },
    { 0, "Damage Stop" },
    { 0, "Flag Turning 0" }

  },

  [ "BeamStart" ] = {

    { 0, "Flag Parry 0" },
    { 0, "Damage Stop" },
    { 0, "Charging Spawn" },
    { 0, "Teleport 0 0.75" },

    { 20, "Alert UnParry" },
    { 20, "LockOn"  }

  },

  [ "Idle" ] = {

    { 0, "Damage Stop" }

  },

  [ "Death" ] = {
  
    { 0, "Flag Parry 0" },
    { 0, "Damage Stop" },
    { 0, "Charging Spawn" },
    { 0, "Flag Turning 0" }

  }

}


ENT.UltrakillBase_AttackTable = {

  "BeamHold",
  "BeamStart",
  "BeamEnd",
  "HomingAttack",
  "MeleeAttack"

}


-- Possession --

ENT.PossessionCrosshair = true

ENT.PossessionEnabled = true

ENT.PossessionMovement = POSSESSION_MOVE_CUSTOM

ENT.PossessionViews = {

  {

    offset = Vector( 0, 14.25, 42.75 ),
    distance = 142.5,
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

    self:MindflayerMelee()

  end } },

  [ IN_ATTACK2 ] = { { coroutine = true, onkeydown = function( self, Possessor )

    if Possessor:KeyDown( IN_BACK ) then

      self:MindflayerHoming()

    elseif not Possessor:KeyDown( IN_BACK ) then

      self:MindflayerBeam()

    end

  end } },

}


if SERVER then


function ENT:CustomInitialize()

  self.EnragedTeleportDelay = CurTime() + 2.5

  self:CreateLight( 0, Color( 0, 205, 255 ), 450, 6, 0, 1 )

  self:SetFullTracking( true )
  self:SetTurning( true )

  local CEffectData = EffectData()

    CEffectData:SetEntity( self )

  UEffect( "Ultrakill_MindFlayer", CEffectData, true, true )
 
end


function ENT:Enrage()

  self:SetEnraged( true )

  self.EnragedTeleportDelay = CurTime() + 2

  UltrakillBase.SoundScript( "Ultrakill_Enrage", self:GetPos(), self )
  UltrakillBase.SoundScript( "Ultrakill_Enrage_Loop", self:GetPos(), self )

  self:CreateLight( 0, Color( 255, 0, 0 ), 450, 6, 0, 1 )

  self:SetSkin( 1 )

  self:ScreenShake( 150, 10, 1, 2550 )

  self:CreateEnrage( 1, 0.9 )

end


function ENT:OnPhaseChange( Phase )

  if Phase ~= 2 or self:IsDead() or self.Enraged then return end

  self:Enrage()

end


function ENT:CustomThink()

  if CurTime() > self.EnragedTeleportDelay and not self:IsAIDisabled() and self:IsEnraged() and self:HasEnemy() then

    self:ReactInCoroutine( function( self )

      self.EnragedTeleportDelay = CurTime() + MRandom( 2, 4 ) 
      self:OnAnimEvent( "Teleport" )

    end )

  end

end


function ENT:MindflayerMelee( Enemy )

  if self:GetCooldown( "Melee" ) > 0 then return end

  UltrakillBase.SoundScript( "Ultrakill_MindFlayer_WindUp_Quick", self:GetPos(), self )

  self:PlaySequenceAndFly( "MeleeAttack", { gravity = false, rotate = true }, function( self, Cycle )

    if Cycle > 0.962616797 then

      return true

    end

  end )

  self:SetCooldown( "Attack", 1 / self:CalculateAnimRate() )
  self:SetCooldown( "Melee", 1.5 / self:CalculateAnimRate( "MeleeAttack" ) )

end


function ENT:MindflayerHoming( Enemy )

  if self:GetCooldown( "Homing" ) > 0 then return end

  UltrakillBase.SoundScript( "Ultrakill_MindFlayer_WindUp", self:GetPos(), self )

  self:PlaySequenceAndFly( "HomingAttack", { gravity = false }, function( self, Cycle ) 

    if Cycle > 0.967289697 then

      return true

    end

  end )

  self:SetCooldown( "Attack", 1 / self:CalculateAnimRate() )
  self:SetCooldown( "Homing", 5 / self:CalculateAnimRate( "HomingAttack" ) )

end


local function MindflayerBeamCallback( self, Hit )

  for K, V in ipairs( Hit ) do

    self.BeamIgnoreTable[ V:EntIndex() ] = true

  end

end


function ENT:MindflayerBeam( Enemy )


  if self:GetCooldown( "Beam" ) > 0 then return end


  UltrakillBase.SoundScript( "Ultrakill_MindFlayer_WindUp", self:GetPos(), self )

  self:SetTurning( false )


  self:PlaySequenceAndFly( "BeamStart" )


  local OldYawRate = self:GetMaxYawRate()
  local NewRate = self:IsEnraged() and 255 or 175
  local Pos = self:WorldSpaceCenter() + self:GetAimVector()

  local YawDirection = 1
  local Pitch = 0

  self:SetMaxYawRate( NewRate )


  if self:HasEnemy() then


    local Enemy = self:GetEnemy()
    local EnemyAim = ( Enemy:WorldSpaceCenter() - self:WorldSpaceCenter() ):GetNormalized()
    local AimRight = self:GetAimAngles():Right()
    local AimUp = self:GetAimAngles():Up()

    Pos = Enemy:WorldSpaceCenter()

    YawDirection = -EnemyAim:Dot( AimRight )
    Pitch = EnemyAim.z


  end

  self.BeamIgnoreTable = {}

  local AttackDelay = 0
  local DamageDataInfo = self.UltrakillBase_DamageInfo[ "Beam" ]
  local DamageTable = {

    Damage = DamageDataInfo[ 1 ],
    Range = DamageDataInfo[ 2 ],
    Type = DamageDataInfo[ 3 ],
    Ignore = self.BeamIgnoreTable,
    Min = -MindFlayerBounds,
    Max = MindFlayerBounds,
    Callback = MindflayerBeamCallback

  }


  local RotationAngle = Angle( 0, 0, 0 )
  local RotationRate = 250


  local CEffectData = EffectData()

    CEffectData:SetEntity( self )

  UEffect( "Ultrakill_MindFlayer_Beam", CEffectData, true, true )


  local BeamSystem = UltrakillBase.SoundScript( "Ultrakill_MindFlayer_Beam", self:GetPos(), self )
  local BeamSystemB = UltrakillBase.SoundScript( "Ultrakill_MindFlayer_Beam_Electric", self:GetPos(), self )

  self:PlaySequenceAndFly( "BeamHold", 1, function( self, Cycle )

    local AimAngles = self:GetAimAngles()
    local WSCenter = self:WorldSpaceCenter()

    if not self:IsPossessed() then

      AimAngles:RotateAroundAxis( AimAngles:Up(), RotationRate * self:GetUpdateInterval() * YawDirection )
      AimAngles = AimAngles:Forward()
      AimAngles.z = Pitch

      self:LookTowards( WSCenter + AimAngles )

    else

      self:FaceEnemy()

    end

    if CurTime() > AttackDelay then

      local WSCenter = self:WorldSpaceCenter()
      local AimVector = self:GetAimVector()

      DamageTable.Origin = WSCenter
      DamageTable.Pos = WSCenter + AimVector * DamageTable.Range,

      self:RayAttack( DamageTable )

      AttackDelay = CurTime() + 0.01

    end


  end )


  BeamSystem:Remove()
  BeamSystemB:Remove()


  self:SetMaxYawRate( OldYawRate )


  self:PlaySequenceAndFly( "BeamEnd", 1, function( self, Cycle )

    if Cycle > 0.745370417 then

      return true

    end

  end )


  self:SetCooldown( "Attack", 1 / self:CalculateAnimRate() )
  self:SetCooldown( "Beam", 2 / self:CalculateAnimRate() )


end


function ENT:OnMeleeAttack( Enemy )

  if self:GetCooldown( "Attack" ) > 0 then return end

  return self:MindflayerMelee( Enemy )

end


function ENT:OnRangeAttack( Enemy )

  if self:GetCooldown( "Attack" ) > 0 then return end

  if self.FirstAttackHoming then

    self.FirstAttackHoming = false

    self:MindflayerHoming( Enemy )

  end

  local Random = MRandom( 3 )

  if Random == 1 then

    self:MindflayerMelee( Enemy )

  elseif Random == 2 then  

    self:MindflayerHoming( Enemy )

  elseif Random == 3 then

    self:MindflayerBeam( Enemy )

  end

end


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  UltrakillBase.TraceSetPos( self, self:GetPos() + Vector( 0, 0, 75 ) )

  self:CreatePortal( self:WorldSpaceCenter(), self:GetAngles(), 4, Vector( 45, 45, 100 ) )

  self:ParticleEffectTimed( 2, "Ultrakill_Portal_Mindflayer", { pos = self:WorldSpaceCenter(), ang = self:GetAngles() } )
  UltrakillBase.SoundScript( "Ultrakill_Portal_MindFlayer", self:GetPos() )

  self.FirstAttackHoming = true

  self:SetCooldown( "Attack", 2 )

end


function ENT:OnTakeDamage( CDamageInfo, HitGroup )

  BaseClass.OnTakeDamage( self, CDamageInfo, HitGroup )

end


function ENT:OnRemove()

  if self:GetEnraged() then UltrakillBase.SoundScript( "Ultrakill_Enrage_End", self:GetPos() ) end

end


function ENT:OnDeath( Dmg, HitGroup )

  self:SetSkin( 0 )

  self:SetEnraged( false )

  self:SetSand( false )
  self:SetSandable( false )

  UltrakillBase.SoundScript( "Ultrakill_MindFlayer_Scream", self:GetPos(), self )

  self:Shake( 1.5, 6 )

  self:PlaySequenceAndLoop( 2, "Death", 1, function( self )

    self:SetVelocity( vector_origin )

  end )

  UltrakillBase.SoundScript( "Ultrakill_MindFlayer_Explosion", self:GetPos() )
  UltrakillBase.SoundScript( "Ultrakill_MindFlayer_Explosion_Large", self:GetPos() )

  local CEffectData = EffectData()

    CEffectData:SetOrigin( self:WorldSpaceCenter() )
    CEffectData:SetAngles( self:GetAngles() )

  UEffect( "Ultrakill_MindFlayer_Explosion", CEffectData, true, true )

  self:ScreenShake( 250, 35, 1.25, 2200 )

  self:Explosion( self:WorldSpaceCenter(), 500, Vector( 2000, 0, 300 ), 300, 0.4 )

end


end


AddCSLuaFile()
DrGBase.AddNextbot( ENT )