local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local DrGBase = DrGBase
local UltrakillBase = UltrakillBase
local Vector = Vector
local tobool = tobool
local EFindInCone = ents.FindInCone
local MCos = math.cos
local ipairs = ipairs
local IsValid = IsValid
local SFind = string.find
local SLower = string.lower
local Angle = Angle
local MMin = math.min
local MRandom = math.random
local CurTime = CurTime
local MMax = math.max
local Color = Color
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_nextbot"

-- Misc --

ENT.PrintName = "Street Cleaner"
ENT.Category = "ULTRAKILL - Enemies"
ENT.Models = { "models/ultrakill/characters/enemies/lesser/streetcleaner.mdl" }
ENT.Skins = { 0 }
ENT.ModelScale = 1
ENT.CollisionBounds = Vector( 6, 6, 70 )
ENT.SurroundingBounds = Vector( 40, 40, 95 )

ENT.RagdollOnDeath = true
ENT.RagdollReplacement = "models/ultrakill/characters/enemies/lesser/streetcleaner_ragdoll.mdl"

-- Stats --

ENT.SpawnHealth = 450

-- Sounds --

ENT.IdleSoundDelay = 2
ENT.UltrakillBase_HurtSoundDelay = 0.1
ENT.UltrakillBase_HurtSound = "Ultrakill_StreetCleaner_Hurt"

-- AI --

ENT.MeleeAttackRange = 250
ENT.RangeAttackRange = 0
ENT.ReachEnemyRange = 100
ENT.AvoidEnemyRange = 55

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
ENT.JumpAnimation = "Fall"
ENT.JumpAnimRate = 1

-- Movements --

ENT.UseWalkframes = false
ENT.WalkSpeed = 125
ENT.RunSpeed = 250
ENT.WalkRange = 250

-- Variables --

ENT.DetectProjectileRange = 100

ENT.UltrakillBase_AnimRateInfo = {

  [ "Run" ] = 1.5,
  [ "Walk" ] = 1.45,
  [ "Idle" ] = 0.5

}

ENT.UltrakillBase_WeaknessTable = {

  [ DMG_BLAST ] = 0.5,
  [ DMG_BLAST_SURFACE ] = 0.5

}

ENT.UltrakillBase_DamageInfo = {

  [ "Flames" ] = { 200, 250, DMG_BURN, 35, Vector( 0, 0, 0 ) }

}

ENT.UltrakillBase_OnEventTable = {

  [ "Step" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_StreetCleaner_Footstep", self:GetPos() )

  end,


  [ "Flag" ] = function( self, Event, Seq )

    self:SetTurning( tobool( Event[ 3 ] ) )

  end

}

ENT.UltrakillBase_EventTable = {

  [ "Walk" ] = {

    { 0, "Step" },

    { 30.099009, "Step" }

  },

  [ "Run" ] = {

    { 0, "Step" },

    { 22.653465, "Step" }

  },

  [ "Dodge" ] = {

    { 0, "Flag Turning 0" }

  }

}


-- Possession --

ENT.PossessionCrosshair = true
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.PossessionViews = {

  {

    offset = Vector( 0, 11.5, 34.5 ),
    distance = 125,
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

    self:StreetCleanerAttackFlameThrowerPossessionVer()

  end } },

  [ IN_RELOAD ] = { { coroutine = true, onkeydown = function( self )

    self:StreetCleanerDodge()

  end } },

}


if SERVER then


function ENT:CustomInitialize()

  self.StreetCleanerFlameThrower = false
 
end


function ENT:CustomThink()

  if self:GetCooldown( "StreetCleaner_Breath" ) <= 0 then

    UltrakillBase.SoundScript( "Ultrakill_StreetCleaner_Breath", self:GetPos(), self )

    self:SetCooldown( "StreetCleaner_Breath", self.IdleSoundDelay )

  end

  self:StreetCleanerProjectilePerception()
 
end


function ENT:StreetCleanerProjectilePerception()

  local FovCone = EFindInCone( self:GetPos() + self:GetForward() * 25, self:GetForward(), self.DetectProjectileRange, MCos( 90 ) )

  for K, Ent in ipairs( FovCone ) do

    if not self:IsOnGround() or self:GetCurrentSequenceName() == "Dodge" then break end

    if Ent.IsUltrakillProjectile and Ent:IsHostile( self ) and Ent:GetParryable() then

      if self:GetCooldown( "Dodge" ) > 0 then -- All Parryable Projectiles can be Deflected. For the most part.

        self:StreetCleanerDeflect( Ent )

        break

      else

        self:CallOverCoroutine( self.StreetCleanerDodge )

        break

      end

    end

    if not Ent.IsUltrakillProjectile and Ent.IsDrGProjectile and ( not IsValid( Ent:GetOwner() ) or IsValid( Ent:GetOwner() ) and self:IsHostile( Ent:GetOwner() ) ) then

      if self:GetCooldown( "Dodge" ) <= 0 then

        self:CallOverCoroutine( self.StreetCleanerDodge )

        break

      else

        self:StreetCleanerDeflect( Ent )

        break

      end

    end

    if SFind( SLower( Ent:GetClass() ), "missile" ) or SFind( SLower( Ent:GetClass() ), "grenade" ) or SFind( SLower( Ent:GetClass() ), "combine_ball" ) then

      if SFind( SLower( Ent:GetClass() ), "combine_ball" ) then

        self:CallOverCoroutine( self.StreetCleanerDodge )

        break

      else

        self:StreetCleanerDeflect( Ent )

        break

      end

    end

  end

end


function ENT:StreetCleanerDeflect( Ent )

  if not IsValid( Ent ) or Ent.Deflected then return end

  Ent.Deflected = true

  self.StreetCleanerFlameThrower = false

  self:SetCooldown( "Attack", self:SequenceDuration( self:LookupSequence( "Deflect" ) ) / self:CalculateAnimRate( "Deflect" ) )

  self:ClearParticleEffectSlot( "Flamethrower" )

  UltrakillBase.SoundScript( "Ultrakill_Deflect", self:GetPos(), self )

  if Ent.IsDrGProjectile then

    local Direction = ( self:GetPos() - Ent:GetPos() ):GetNormalized()
    local Velocity = Ent:GetVelocity():Length()

    Direction:Rotate( Angle( 0, MMin( MRandom( -90, 90 ) * 2, 90 ), 0 ) )
  
    Ent:SetAngles( Direction:Angle() )
    Ent:SetVelocity( Direction * Velocity * 0.9 )

    if Ent.IsUltrakillProjectile then Ent.HomingEnabled = false end

  else

    self:RepelRockets( Ent )

  end

  self:PlaySequence( "Deflect", self:CalculateAnimRate( "Deflect" ), function( self, Cycle, LayerID)

    if Cycle > 0.928592221 then

      self:SetLayerWeight( LayerID, 0 )

      self:RemoveGesture( self:GetSequenceActivity( self:GetLayerSequence( LayerID ) ) )

      return true

    end

  end )

end


function ENT:StreetCleanerDodge()

  if self:GetCooldown( "Dodge" ) > 0 then return end

  if self.StreetCleanerFlameThrower then

    UltrakillBase.SoundScript( "Ultrakill_StreetCleaner_Gas", self:GetPos(), self )

  end

  self:ClearParticleEffectSlot( "Flamethrower" )

  self.StreetCleanerFlameThrower = false

  self:SetGodMode( true )
  self:SetTurning( false )
  self:SetCooldown( "Dodge", 3 )

  local Random = MRandom( 1 ) > 0 and 1 or -1
  local FaceTo = self:GetRight() * Random

  self:LookInstant( self:GetPos() + FaceTo )

  self:PlaySequenceAndMove( "Dodge", 1, function( self, Cycle ) 

    if Cycle > 0.9207921 then
      
      return true

    end

  end )

  self:SetTurning( true )
  self:SetGodMode( false )
  self:SetCooldown( "Dodge", 3 )

end


function ENT:StreetCleanerAttackFlameThrower()

  if self.StreetCleanerFlameThrower or not self:IsOnGround() or self:GetCooldown( "Attack" ) > 0 then return end

  self.StreetCleanerFlameThrower = true

  local DamageDataInfo = self.UltrakillBase_DamageInfo[ "Flames" ]

  local DamageTable = {

    Damage = DamageDataInfo[ 1 ],
    Range = DamageDataInfo[ 2 ],
    Type = DamageDataInfo[ 3 ],
    Angle = DamageDataInfo[ 4 ]

  }

  self:CreateAlertFollow( self, 2, 1.5, 2 )

  local AttackDelay = 0
  local CancelDelay = CurTime() + ( 0.5 / self:CalculateAnimRate( "" ) )

  while self:IsOnGround() do

    local Enemy = self:GetEnemy()

    if CurTime() > CancelDelay and ( not IsValid( Enemy ) or not DrGBase.CanAttack( Enemy ) or not self:IsInRange( Enemy, self.MeleeAttackRange * 1.5 ) or not self.StreetCleanerFlameThrower or not self:Visible( Enemy ) ) then break end

    if IsValid( Enemy ) and not self:IsInRange( Enemy, self.ReachEnemyRange ) then

      self:FollowPath( Enemy )

    elseif IsValid( Enemy ) then

      self:LookTowards( Enemy )

    end

    if CurTime() > AttackDelay and CurTime() > CancelDelay then

      if not self:GetParticleEffectSlot( "Flamethrower" ) then

        UltrakillBase.SoundScript( "Ultrakill_StreetCleaner_Flamethrower", self:GetPos(), self )

        self:ParticleEffectSlot( "Flamethrower", "Ultrakill_StreetCleaner_Flames", { parent = self, attachment = "Muzzle_Attach" } )      

      end

      AttackDelay = CurTime() + 0.1

      self:Attack( DamageTable )

    end

    self:YieldCoroutine( false )

  end

  if self.StreetCleanerFlameThrower then

    UltrakillBase.SoundScript( "Ultrakill_StreetCleaner_Gas", self:GetPos(), self )

    self:ClearParticleEffectSlot( "Flamethrower" )

    self.StreetCleanerFlameThrower = false

  end

end


function ENT:StreetCleanerAttackFlameThrowerPossessionVer()

  if self.StreetCleanerFlameThrower or not self:IsOnGround() or self:GetCooldown( "Attack" ) > 0 then return end

  self.StreetCleanerFlameThrower = true

  local DamageDataInfo = self.UltrakillBase_DamageInfo[ "Flames" ]

  local DamageTable = {

    Damage = DamageDataInfo[ 1 ],
    Range = DamageDataInfo[ 2 ],
    Type = DamageDataInfo[ 3 ],
    Angle = DamageDataInfo[ 4 ]

  }

  self:CreateAlertFollow( self, 2, 1.5, 2 )

  local AttackDelay = 0
  local CancelDelay = CurTime() + ( 0.5 / self:CalculateAnimRate( "" ) )

  while self:IsOnGround() do

    local Enemy = self:GetEnemy()

    if CurTime() > CancelDelay and self:IsPossessed() and not self:GetPossessor():KeyDown( IN_ATTACK ) then break end

    self:_HandlePossession( true )

    if CurTime() > AttackDelay and CurTime() > CancelDelay then

      if not self:GetParticleEffectSlot( "Flamethrower" ) then

        UltrakillBase.SoundScript( "Ultrakill_StreetCleaner_Flamethrower", self:GetPos(), self )

        self:ParticleEffectSlot( "Flamethrower", "Ultrakill_StreetCleaner_Flames", { parent = self, attachment = "Muzzle_Attach" } )      

      end

      AttackDelay = CurTime() + 0.1

      self:Attack( DamageTable )

    end

    self:YieldCoroutine( false )

  end

  if self.StreetCleanerFlameThrower then

    UltrakillBase.SoundScript( "Ultrakill_StreetCleaner_Gas", self:GetPos(), self )

    self:ClearParticleEffectSlot( "Flamethrower" )

    self.StreetCleanerFlameThrower = false

  end

end


function ENT:OnMeleeAttack( Enemy )

  return self:StreetCleanerAttackFlameThrower()

end


function ENT:ShouldRun()

  if self:HasEnemy() and self:IsInRange( self:GetEnemy(), self.WalkRange ) or self.StreetCleanerFlameThrower then 

    return false

  end

  return true

end


function ENT:IsRunning()

  if self:IsMoving() then

    return self:ShouldRun()

  end

  return false
  
end


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  self:CreatePortal( self:WorldSpaceCenter(), self:GetAngles(), 5, Vector( 45, 45, 125 ) )

  self:ParticleEffectTimed( 2, "Ultrakill_Portal_Red", { pos = self:WorldSpaceCenter(), ang = self:GetAngles() } )
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

    UltrakillBase.SoundScript( "Ultrakill_Machine_Scream", self:GetPos(), self )

  end )
  
end


function ENT:OnTakeDamage( CDamageInfo, HitGroup )

  self:DamageMultiplier( CDamageInfo, HitGroup )
  self:CheckParry( CDamageInfo )

  -- Instakill --

  local Pos = CDamageInfo:GetDamagePosition()
  local Ply = CDamageInfo:GetAttacker()
  local Attachment = self:GetAttachment( 3 )

  if IsValid( Ply ) and Ply:IsPlayer() and CDamageInfo:IsBulletDamage() and not CDamageInfo:IsDamageType( DMG_BUCKSHOT ) and HitGroup == HITGROUP_HEAD and Attachment.Pos:DistToSqr( Pos ) <= 100 then

    self.InstaKilled = true

    self:Explosion( self:GetPos(), 500, Vector( 450, 0, 150 ), 150, 0.25, Ply, true )

    UltrakillBase.SoundScript( "Ultrakill_Ricochet", self:GetPos() )
    UltrakillBase.SoundScript( "Ultrakill_Explosion_1", self:GetPos() )

    UltrakillBase.HitStop( 0.25 )

    Ply:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255, 40 ), 0.1, 0.25 )

    self:CreateExplosion( Attachment.Pos, Attachment.Ang )

    self.RagdollOnDeath = false

    self:Kill( Ply, Ply, DMG_BLAST )

  end

  self:CreateBlood( CDamageInfo, HitGroup )

end


function ENT:OnFatalDamage( Dmg, HitGroup )

  if self.InstaKilled then

    Dmg:SetDamagePosition( self:WorldSpaceCenter() )

    UltrakillBase.SoundScript( "Ultrakill_Death", self:GetPos() )

    self.RagdollOnDeath = false

  elseif Dmg:IsDamageType( DMG_FALL ) then

    self:Explosion( self:GetPos(), 500, Vector( 450, 0, 150 ), 150, 0.25 )

    UltrakillBase.SoundScript( "Ultrakill_Explosion_1", self:GetPos() )

    self:CreateExplosion( self:WorldSpaceCenter(), self:GetAngles() )

    UltrakillBase.SoundScript( "Ultrakill_Death", self:GetPos() )

    self.RagdollOnDeath = false

  end

end


function ENT:OnDeath( Dmg, HitGroup )

  UltrakillBase.SoundScript( "Ultrakill_Machine_Death", self:GetPos() )

  self:CreateBlood( Dmg, HitGroup )

  self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

end


end


AddCSLuaFile()
DrGBase.AddNextbot( ENT )