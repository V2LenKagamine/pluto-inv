local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local DrGBase = DrGBase
local UltrakillBase = UltrakillBase
local Vector = Vector
local USpriteTrail = SERVER and util.SpriteTrail
local Color = Color
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local EffectData = EffectData
local UEffect = util.Effect
local istable = istable
local ipairs = ipairs
local tobool = tobool
local MMax = math.max
local MRad = math.rad
local MCos = math.cos
local MSin = math.sin
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_nextbot"

-- Misc --

ENT.PrintName = "Soldier"
ENT.Category = "ULTRAKILL - Enemies"
ENT.Models = {"models/ultrakill/characters/enemies/greater/soldier.mdl"}
ENT.Skins = {0}
ENT.ModelScale = 1
ENT.CollisionBounds = Vector( 6, 6, 70 ) * 1.15
ENT.SurroundingBounds = Vector( 40, 40, 95 ) * 1.15
ENT.RagdollOnDeath = true

-- Stats --

ENT.SpawnHealth = 250

-- Sounds --

ENT.UltrakillBase_HurtSoundDelay = 0.1
ENT.UltrakillBase_HurtSound = "Ultrakill_Husk_Hurt"

-- AI --

ENT.MeleeAttackRange = 150
ENT.RangeAttackRange = 2000
ENT.ReachEnemyRange = 750
ENT.AvoidEnemyRange = 255

-- Detection --

ENT.EyeBone = "spine.004"



-- Locomotion --

ENT.Acceleration = 2500
ENT.Deceleration = 1500
ENT.JumpHeight = 150
ENT.StepHeight = 20
ENT.MaxYawRate = 400
ENT.DeathDropHeight = 30

-- Animations --

ENT.WalkAnimation = "Running"
ENT.WalkAnimRate = 0.5
ENT.RunAnimation = "Running"
ENT.RunAnimRate = 1
ENT.IdleAnimation = "Idle"
ENT.IdleAnimRate = 1
ENT.JumpAnimation = "Falling"
ENT.JumpAnimRate = 1

-- Movements --

ENT.UseWalkframes = false
ENT.WalkSpeed = 150
ENT.RunSpeed = 200


-- Variables --


ENT.SoldierBlocking = false
ENT.SoldierShotgunAmount = 5

ENT.UltrakillBase_AnimRateInfo = {

  [ "Melee" ] = 1.75,
  [ "Shoot" ] = 1.15

}

ENT.UltrakillBase_DamageInfo = {

  [ "Melee" ] = { 400, 90, DMG_CLUB, 20, Vector( 400, 0, 0 ) }

}

ENT.UltrakillBase_OnEventTable = {

  [ "KickTrail" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_HuskMelee", self:GetPos() )
    UltrakillBase.SoundScript( "Ultrakill_Whoosh", self:GetPos() )

    local Trail = USpriteTrail( self, 2, Color( 255, 138, 0, 125 ), true, 11, 0, 0.1, 0, "particles/ultrakill/white_trail_additive" )

    SafeRemoveEntityDelayed( Trail, 0.5 / self:CalculateAnimRate( "Melee" ) )

  end,


  [ "Step" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_HuskStep", self:GetPos() )

  end,


  [ "ShotgunPump" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_Soldier_ShotgunPump", self:GetPos() )

  end,


  [ "CreateHellProjectile" ] = function( self, Event, Seq )

    local Time = 0.98333 / self:CalculateAnimRate( "Shoot" )

    UltrakillBase.SoundScript( "Ultrakill_Projectile_Windup", self:GetPos(), self, Time )

    local CEffectData = EffectData()

      CEffectData:SetEntity( self )
      CEffectData:SetMagnitude( Time * 100 )

    UEffect( "Ultrakill_Soldier_Charge", CEffectData, true, true )

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


  [ "HellProjectile" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_Soldier_Shoot", self:GetPos() )

    local vOffset = Vector()
    local fDegM = 1 / self.SoldierShotgunAmount
    local vPos = self:GetAttachment( 4 ).Pos
    local aRotation = self:GetAngles()

    local mProjectile = self:CreateProjectile( "Ultrakill_Soldier_Projectile", true )

    mProjectile:SetPos( vPos )
    mProjectile:SetAngles( aRotation )

    self:AimProjectile( mProjectile, 2000, vOffset * 100 )
    
    for I = 1, self.SoldierShotgunAmount do

      local fRad = MRad( ( 360 * fDegM ) * I )
      vOffset.x = 0
      vOffset.y = MCos( fRad )
      vOffset.z = MSin( fRad )

      local mProjectile = self:CreateProjectile( "Ultrakill_Soldier_Projectile", true )

      mProjectile:SetPos( vPos )
      mProjectile:SetAngles( aRotation )

      self:AimProjectile( mProjectile, 2000, vOffset * 100 )


    end

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

  [ "Melee" ] = {

    { 0, "Flag Parry 0" },
    { 0, "Flag Turning 1" },

    { 32, "KickTrail" },
    { 32, "Flag Parry 1" },

    { 42, "Flag Turning 0" },
    { 42, "Damage Start" },

    { 46, "Damage Stop" },
    { 46, "Flag Parry 0" },

    { 88, "Flag Turning 1" },

  },

  [ "Block" ] = {

    { 0, "Flag Parry 0" },
    { 0, "Flag Turning 0" },

    { 35, "Flag Turning 1" },

  },

  [ "Shoot" ] = {

    { 0, "Flag Parry 0" },
    { 0, "Flag Turning 1" },

    { 21, "ShotgunPump" },
    { 21, "CreateHellProjectile" },
    { 21, "Flag Interrupt 1" },

    { 69, "Flag Parry 1" },

    { 73, "Flag Turning 0" },

    { 80, "Flag Interrupt 0" },
    { 80, "HellProjectile" },

    { 91, "Flag Parry 0" },

    { 100, "Flag Turning 1" },

  },

  [ "Running" ] = {

    {25, "Step"},

    {40, "Step"}

  }

}

ENT.UltrakillBase_AttackTable = {

  "Melee",
  "Shoot"

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

    self:SoldierKick()

  end } },

  [ IN_ATTACK2 ] = { { coroutine = true, onkeydown = function( self )

    self:SoldierShoot()

  end } },

}


if SERVER then


function ENT:CustomInitialize()

  if self.UltrakillBase_Difficulty <= 2 then

    self.SoldierShotgunAmount = 5

  elseif self.UltrakillBase_Difficulty == 3 then

    self.SoldierShotgunAmount = 6

  else

    self.SoldierShotgunAmount = 9

  end

  self:SetTurning( true )
 
end


function ENT:SoldierKick( Enemy )

  if not self:IsOnGround() then return end

  self:PlaySequenceAndMove( "Melee", nil, function( self, Cycle )

    if not self:IsOnGround() or Cycle > 0.92156865 then

      return true

    end

  end )

end


function ENT:SoldierBlock()

  if not self:IsOnGround() then return end

  self:PlaySequenceAndMove( "Block", 1, function( self, Cycle )

    if Cycle > 0.2 then

      self.SoldierBlocking = false

    end

    if not self:IsOnGround() then 
    
      return true 
  
    end

  end )

end


function ENT:SoldierShoot( Enemy )

  if self:GetCooldown( "Shoot" ) > 0 or not self:IsOnGround() then

    return

  end

  self:PlaySequenceAndMove( "Shoot", nil, function( self, Cycle )

    if not self:IsOnGround() or Cycle > 0.9439776 then

      return true

    end

  end )

  self:SetCooldown( "Shoot", 0.5 / self:CalculateAnimRate( "Shoot" ) )
  self:SetInterruptable( false )

end


function ENT:OnMeleeAttack( Enemy )

  return self:SoldierKick( Enemy )

end


function ENT:OnRangeAttack( Enemy )

  if self:IsInRange( Enemy, self.AvoidEnemyRange ) then

    return

  end

  self:SoldierShoot( Enemy )

end


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  self:CreatePortal( self:WorldSpaceCenter(), self:GetAngles(), 2, Vector( 35, 35, 95 ) )

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


local function CheckForBlock( self, CDamageInfo )

  if not self:IsOnGround() or not CDamageInfo:IsDamageType( DMG_BLAST + DMG_BLAST_SURFACE ) or CDamageInfo:IsDamageType( DMG_DIRECT ) then return end

  CDamageInfo:ScaleDamage( 0.05 )

  UltrakillBase.SoundScript( "Ultrakill_Deflect", self:GetPos(), self )

  if not self.SoldierBlocking then

    self.SoldierBlocking = true
    self:FaceInstant( CDamageInfo:GetDamagePosition() )

    self:CallOverCoroutine( self.SoldierBlock )

  end

end


function ENT:OnTakeDamage( CDamageInfo, HitGroup )

  self:DamageMultiplier( CDamageInfo, HitGroup )
  CheckForBlock( self, CDamageInfo )
  self:CheckParry( CDamageInfo )
  self:CheckInterrupt( CDamageInfo, 4 )
  self:CreateBlood( CDamageInfo, HitGroup )

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