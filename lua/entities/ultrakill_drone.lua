local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local DrGBase = DrGBase
local UltrakillBase = UltrakillBase
local Vector = Vector
local MRandom = math.random
local CurTime = CurTime
local IsValid = IsValid
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_nextbot"

-- Misc --

ENT.PrintName = "Drone"
ENT.Category = "ULTRAKILL - Enemies"
ENT.Models = { "models/ultrakill/characters/enemies/lesser/drone.mdl" }
ENT.ModelScale = 1
ENT.CollisionBounds = Vector( 10, 10, 25 )
ENT.SurroundingBounds = Vector( 100, 100, 185 )

-- Stats --

ENT.SpawnHealth = 125

-- Sounds --

ENT.UltrakillBase_HurtSoundDelay = 0.1
ENT.UltrakillBase_HurtSound = "Ultrakill_Drone_Hurt"

-- AI --

ENT.AISight = false
ENT.MeleeAttackRange = 10000
ENT.ReachEnemyRange = 800
ENT.AvoidEnemyRange = 0

-- Detection --

ENT.EyeBone = "root"

-- Locomotion --

ENT.Flying = true
ENT.Acceleration = 5500
ENT.Deceleration = 2500
ENT.JumpHeight = 500
ENT.StepHeight = 20
ENT.MaxYawRate = 400
ENT.DeathDropHeight = math.huge

-- Animations --

ENT.WalkAnimation = "Reference"
ENT.WalkAnimRate = 1
ENT.RunAnimation = "Reference"
ENT.RunAnimRate = 1
ENT.IdleAnimation = "Reference"
ENT.IdleAnimRate = 1
ENT.JumpAnimation = "Reference"
ENT.JumpAnimRate = 1

-- Movements --

ENT.UseWalkframes = false
ENT.WalkSpeed = 500
ENT.RunSpeed = 500

-- FullTracking --

ENT.UltrakillBase_FullTrackingBone = "root"
ENT.UltrakillBase_FullTracking = true

-- Variables --

local DroneSpread = {

  Vector( 0, 1, 0 ),
  Vector( 0, 0, 0 ),
  Vector( 0, -1, 0 )

}

local DronePosSpread = {

  Vector( 0, 0, 1 ),
  Vector( 0, 0, 0 ),
  Vector( 0, 0, -1 )

}


-- Possession --

ENT.PossessionCrosshair = true
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_CUSTOM
ENT.PossessionViews = {

  {

    offset = Vector( 0, 10, 30 ),
    distance = 150,
    eyepos = false

  },

  {

    offset = Vector( 6.75, 0, 0 ),
    distance = 0,
    eyepos = true

  }
  
}

ENT.PossessionBinds = {

  [ IN_ATTACK ] = { { coroutine = false, onkeydown = function( self, Possessor )

    local LockedOn = self:PossessionGetLockedOn()

    self:OnMeleeAttack( LockedOn )

  end } },

}


if SERVER then


function ENT:CustomInitialize()

  self:SetFullTracking( true )
  self:SetTurning( true )

end


function ENT:CustomThink()

  if not self:HasEnemy() or not self.CanDodge or self:IsAIDisabled() then return end

  local Enemy = self:GetEnemy()

  if self:IsInRange( Enemy, self.ReachEnemyRange ) and not self:IsInRange( Enemy, 200 ) and self:GetCooldown( "Dodge" ) <= 0 then

    self:CallInCoroutine( self.DroneDodge, Enemy, "Side" )

  elseif self:IsInRange( Enemy, 200 ) and self:GetCooldown( "Back" ) <= 0 then

    self:CallOverCoroutine( self.DroneDodge, false, Enemy, "Back", true )

  end

end


function ENT:DroneDodge( Enemy, Direction, Skip )

  if self:GetCooldown( "Dodge" ) > 0 and not Skip or self:GetCooldown( "Back" ) > 0 then return end

  if Direction == "Back" then

    Direction = -self:GetAimVector()

    self:SetCooldown( "Back", 0.33333 / self:CalculateAnimRate() )

  elseif Direction == "Side" then

    Direction = self:GetAimAngles():Right() * ( MRandom( 1 ) > 0 and -1 or 1 )

    self:SetCooldown( "Dodge", ( MRandom( 1, 2 ) / self:CalculateAnimRate() ) + 1 )

  end

  local Old_Speed = self:GetDesiredSpeed()

  local Now = CurTime() + 0.2

  self:SetDesiredSpeed( 2000 )

  while true do

    local Enemy = self:GetEnemy()

    if CurTime() > Now or not IsValid( Enemy ) then break end

    self:LookTowards( Enemy )
    self:ApproachFlying( self:GetPos() + Direction )

    self:YieldCoroutine( false )

  end

  self:SetDesiredSpeed( Old_Speed )

end


function ENT:DroneProjectile( Enemy )

  if self:GetCooldown( "Projectile" ) > 0 then return end

  UltrakillBase.SoundScript( "Ultrakill_Drone_Windup", self:GetPos(), self )

  self:SetSkin( 1 )

  local Delay = 0.5 / self:CalculateAnimRate()

  self:ParticleEffectTimed( Delay, "Ultrakill_Drone_Charge", { parent = self, attachment = "Eye_Attach" } )

  self:Timer( Delay, function( self )

    UltrakillBase.SoundScript( "Ultrakill_Projectile_Shoot", self:GetPos(), self )

    local PosSpread = Vector()

    for X = 1, 3 do

      local Proj = self:CreateProjectile( "Ultrakill_Drone_Projectile", true )

      local Spread = DroneSpread[ X ]

      PosSpread:Set( DronePosSpread[ X ] )

      PosSpread:Rotate( self:GetAimAngles() )

      Proj:SetPos( self:WorldSpaceCenter() + PosSpread * 15 )

      self:AimProjectile( Proj, 1000, Spread * 50 )

    end

    self:SetSkin( 0 )

  end )

  self:SetCooldown( "Projectile", Delay + 2 / self:CalculateAnimRate() )

end


function ENT:OnMeleeAttack( Enemy )

  if self:GetCooldown( "Attack" ) > 0 then return end

  return self:DroneProjectile( Enemy )

end


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  UltrakillBase.TraceSetPos( self, self:GetPos() + Vector( 0, 0, 50 ) )

  self:CreatePortal( self:WorldSpaceCenter(), self:GetAngles(), 2, Vector( 45, 45, 60 ) )

  self:ParticleEffectTimed( 2, "Ultrakill_Portal_Heavy", { pos = self:WorldSpaceCenter(), ang = self:GetAngles() } )
  UltrakillBase.SoundScript( "Ultrakill_Portal_Heavy", self:GetPos() )

  self.CanDodge = true

  self:SetCooldown( "Attack", 1 )

end


function ENT:OnTakeDamage( CDamageInfo, HitGroup )

  BaseClass.OnTakeDamage( self, CDamageInfo, HitGroup )

end


function ENT:OnDeath( Dmg, HitGroup )

  if Dmg:IsDamageType( DMG_BLAST + DMG_BLAST_SURFACE ) then

    self:Explosion( self:GetPos(), 350, Vector( 450, 0, 150 ), 150, 0.1 )

    UltrakillBase.SoundScript( "Ultrakill_Explosion_1", self:GetPos() )

    self:CreateExplosion( self:WorldSpaceCenter(), self:GetAngles() )

  else

    local CorpseProj = self:CreateProjectile( "Ultrakill_Drone_Corpse_Projectile" )

    CorpseProj:SetPos( self:GetPos() )
    CorpseProj:SetAngles( self:GetAimAngles() )

  end

end


end


AddCSLuaFile()
DrGBase.AddNextbot( ENT )