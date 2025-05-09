local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local DrGBase = DrGBase
local UltrakillBase = UltrakillBase
local Vector = Vector
local tonumber = tonumber
local EffectData = EffectData
local UEffect = util.Effect
local UTraceHull = util.TraceHull
local IsValid = IsValid
local CurTime = CurTime
local DamageInfo = DamageInfo
local UScreenShake = util.ScreenShake
local tobool = tobool
local Color = Color
local ipairs = ipairs
local EFindInSphere = ents.FindInSphere
local SFind = string.find
local MMin = math.min
local MRandom = math.random
local Material = Material
local RSetMaterial = CLIENT and render.SetMaterial
local RStartBeam = CLIENT and render.StartBeam
local LerpVector = LerpVector
local RAddBeam = CLIENT and render.AddBeam
local REndBeam = CLIENT and render.EndBeam
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_nextbot"

-- Misc --

ENT.PrintName = "Malicious Face"
ENT.Category = "ULTRAKILL - Bosses"
ENT.Models = { "models/ultrakill/characters/enemies/boss/maliciousface.mdl" }
ENT.Skins = { 0 }
ENT.ModelScale = 1
ENT.CollisionBounds = Vector( 10, 10, 18 ) * 3.25
ENT.SurroundingBounds = Vector( 15, 15, 25 ) * 3.25
ENT.RagdollOnDeath = false

-- Stats --

ENT.SpawnHealth = 2500
ENT.UltrakillBase_Phase = 1
ENT.UltrakillBase_PhaseMax = 2

-- Weight --

ENT.UltrakillBase_WeightClass = "Superheavy"

-- AI --

ENT.AISight = true
ENT.SightFOV = 180
ENT.MeleeAttackRange = 3000
ENT.RangeAttackRange = 10000
ENT.ReachEnemyRange = 1000
ENT.AvoidEnemyRange = 0

-- Detection --

ENT.EyeBone = ""

-- Locomotion --

ENT.Flying = true
ENT.Acceleration = 5500
ENT.Deceleration = 5500
ENT.JumpHeight = 150
ENT.StepHeight = 0
ENT.FlyingHeight = 100
ENT.MaxYawRate = 400
ENT.DeathDropHeight = nil

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
ENT.WalkSpeed = 75
ENT.RunSpeed = 75

-- FullTracking --

ENT.UltrakillBase_FullTrackingBone = "Root"
ENT.UltrakillBase_FullTracking = true

-- Variables --

ENT.MaliciousFaceCracked = false
ENT.MaliciousFaceChargeTime = 0
ENT.MaliciousFaceBarrageAmount = 0

local MaliciousFaceSizeVec = Vector( 10, 10, 10 )
local MaliciousFaceLegRange = 200

-- Tables --

ENT.UltrakillBase_WeaknessTable = {

  [ DMG_BLAST ] = 0,
  [ DMG_BLAST_SURFACE ] = 0
  
}

ENT.UltrakillBase_EnragedRate = 1.5
ENT.UltrakillBase_AnimRateInfo = 1

ENT.UltrakillBase_OnEventTable = {

  [ "Alert" ] = function( self, Event, Seq )

    self:CreateAlertFollow( self, 3, 1.25, 1 )

  end,


  [ "Turn" ] = function( self, Event, Seq )

    self:FaceEnemyInstant( tonumber( Event[ 2 ] or 0 ) / self:CalculateAnimRate( Seq ) )

  end,


  [ "Charge" ] = function( self, Event, Seq )

    self.Charging = true

    local Time = ( Event[ 2 ] or 3 ) / self:CalculateAnimRate( Seq )

    UltrakillBase.SoundScript( "Ultrakill_MaliciousFace_Charge", self:GetPos(), self, Time )

    local CEffectData = EffectData()

      CEffectData:SetEntity( self )
      CEffectData:SetMagnitude( Time * 100 )

    UEffect( "Ultrakill_MaliciousFace_Charge", CEffectData, true, true )

  end,


  [ "Explosion" ] = function( self, Event, Seq )

    if not self.Charging then return end

    local AimVec = self:HasEnemy() and self:GetEnemy():GetPos() or self:GetAimVector() * 9999999

    local Direction = ( AimVec - self:GetPos() ):GetNormalized()

    local TraceResult = UTraceHull( {

      start = self:GetPos(),
      endpos = self:GetPos() + Direction * 99999999,
      filter = { self, self:GetEnemy() },
      min = -MaliciousFaceSizeVec,
      max = MaliciousFaceSizeVec,
      mask = MASK_SHOT

    } )

    local Pos = TraceResult.HitPos
    local Ang = TraceResult.HitNormal:Angle()
    local HitEntity = TraceResult.Entity


    local CEffectData = EffectData()

      CEffectData:SetOrigin( self:GetPos() )
      CEffectData:SetStart( Pos )

    UEffect( "Ultrakill_MaliciousFace_Beam", CEffectData, true, true )


    if IsValid( HitEntity ) and HitEntity:GetClass() == "ultrakill_coin" and not HitEntity:GetDead() and CurTime() - HitEntity.SpawnTime > 0.1 then

      local Dmg = DamageInfo()

      Dmg:SetDamage( 5000 )
      Dmg:SetDamageType( DMG_BULLET )
      Dmg:SetAttacker( HitEntity.CoinOwner or self:GetEnemy() or self )
      Dmg:SetInflictor( HitEntity.CoinOwner or self:GetEnemy() or self )

      HitEntity:TakeDamageInfo( Dmg )

      return 

    end

    UltrakillBase.SoundScript( "Ultrakill_Explosion_1", TraceResult.HitPos )

    self:CreateExplosion( Pos, angle_zero, 1.5 )

    self:Explosion( Pos, 500, Vector( 850, 0, 300 ), 350, 0.2 )

    UScreenShake( Pos, 2500, 10, 1.5, 6500 )

  end,


  [ "Flag" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Parry" then

      self:SetParryable( tobool( Event[ 3 ] ) )

    elseif Event[ 2 ] == "Turning" then

      self:SetTurning( tobool( Event[ 3 ] ) )

    end

  end


}


-- Possession --

ENT.PossessionCrosshair = true
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_CUSTOM
ENT.PossessionViews = {

  {

    offset = Vector( 0, 14.25, 42.75 ),
    distance = 250,
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

    if self:GetCooldown( "Attack" ) > 0 then return end

    self:OnMeleeAttack()

  end } },

  [ IN_ATTACK2 ] = { { coroutine = true, onkeydown = function( self, Possessor )

    if self:GetCooldown( "Attack" ) > 0 then return end

    self:MaliciousBeam()

  end } },

}


if SERVER then


function ENT:CustomInitialize()
  
  if self.UltrakillBase_Difficulty <= 2 then

    self.MaliciousFaceChargeTime = self.UltrakillBase_Difficulty >= 1 and 3.5 or 5
    self.MaliciousFaceBarrageAmount = self.UltrakillBase_Difficulty <= 1 and 3 + self.UltrakillBase_Difficulty or 6

  else

    self.MaliciousFaceChargeTime = 2
    self.MaliciousFaceBarrageAmount = 6

  end

  self:SetFullTracking( true )
  self:SetTurning( true )

end


function ENT:Enrage()

  self:SetEnraged( true )

  UltrakillBase.SoundScript( "Ultrakill_Enrage_Loop", self:GetPos(), self )
  UltrakillBase.SoundScript( "Ultrakill_Enrage", self:GetPos(), self )

  self:CreateLight( 0, Color( 255, 0, 0 ), 450, 6, 0, 2 )

  self:SetSkin( self.MaliciousFaceCracked and 3 or 2 )

  self:CreateEnrage( 2, 1.65 )

  self.MeleeAttackRange = 600

end


function ENT:CustomThink()

  for K, Rocket in ipairs( EFindInSphere( self:WorldSpaceCenter(), self:GetModelRadius() * 1.5 ) ) do

    if not IsValid( Rocket ) or not SFind( Rocket:GetClass(), "missile" ) then continue end

    self:RepelRockets( Rocket )

  end

end


function ENT:OnPhaseChange( Phase )

  if Phase ~= 2 or self:IsDead() then return end

  self.MaliciousFaceCracked = true

  self:SetSkin( self:GetEnraged() and 3 or 1 )

  UltrakillBase.SoundScript( "Ultrakill_RockBreak", self:GetPos(), self )

  UltrakillBase.CreateGibs( {

		{ 
			Position = self:WorldSpaceCenter(),
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk1.mdl",
			Velocity = 350,
			ModelScale = 1.5,
			Trail = "Ultrakill_White_Trail"
		},

		{ 
			Position = self:WorldSpaceCenter(),
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk2.mdl",
			Velocity = 350,
			ModelScale = 1.5,
			Trail = "Ultrakill_White_Trail"
		}

	} )

  if self.UltrakillBase_Difficulty >= 3 then

    self:Enrage()

  end

end


function ENT:OnParry( Ply, Dmg )

  if not Dmg:IsDamageType( DMG_DIRECT ) then
    
    Dmg:SetDamage( Dmg:GetDamage() + 5000 )
    Dmg:SetDamageType( Dmg:GetDamageType() + DMG_DIRECT )

  end

  UltrakillBase.SoundScript( "Ultrakill_Parry", self:GetPos() )

  UltrakillBase.HitStop( 0.25 )

  self:SetParryable( false )

  local Pos = self:WorldSpaceCenter() + self:GetAimVector() * 75
  local Ang = self:GetAimAngles()

  UltrakillBase.SoundScript( "Ultrakill_Explosion_1", Pos )

  self:CreateExplosion( Pos, Ang, 1.5 )

  self.Charging = false

  UltrakillBase.OnParryPlayer( Ply )

end


function ENT:MaliciousShoot()

  local Delay = 0.1 / self:CalculateAnimRate( "Barrage" )

  for X = 1, self.MaliciousFaceBarrageAmount do

    self:Timer( ( X - 1 ) * Delay, function()

      UltrakillBase.SoundScript( "Ultrakill_MaliciousProjectile_Shoot", self:GetPos(), self )

      local Proj = self:CreateProjectile( "Ultrakill_MaliciousFace_Projectile", true )
      Proj:SetPos( self:GetPos() )
      self:AimProjectile( Proj, 2000 )

    end )

  end

  local Now = CurTime()

  while true do

    local Enemy = self:GetEnemy()

    if self:GetTurning() then

      self:FaceEnemy()

    end

    self:SetVelocity( vector_origin )

    if CurTime() - Now > Delay * self.MaliciousFaceBarrageAmount then

      break

    end

    self:YieldCoroutine( false )

  end

  self.CurrentBarrageTracker = MMin( self.CurrentBarrageTracker + 1, 10 )

  self:SetCooldown( "Attack", 0.7 / self:CalculateRate() )

end


function ENT:MaliciousBeam()

  self:OnAnimEvent( "Charge " .. self.MaliciousFaceChargeTime )
  self:OnAnimEvent( "Flag Parry 0" )

  self:SetTurning( true )

  local Now = CurTime()
  local HasAlerted = false

  while true do

    local Enemy = self:GetEnemy()

    if self:GetTurning() then

      self:FaceEnemy()

    end

    self:SetVelocity( vector_origin )

    if CurTime() - Now > self.MaliciousFaceChargeTime / self:CalculateAnimRate() and not HasAlerted then

      self:SetTurning( false )

      self:OnAnimEvent( "Flag Parry 1" )
      self:OnAnimEvent( "Flag Turning 0" )
      self:OnAnimEvent( "Alert Parry" )
      self:OnAnimEvent( "Turn 0.5" )

      HasAlerted = true

    end

    if CurTime() - Now > ( self.MaliciousFaceChargeTime + 0.5 ) / self:CalculateAnimRate() then

      self:OnAnimEvent( "Flag Parry 0" )
      self:OnAnimEvent( "Flag Turning 1" )
      self:OnAnimEvent( "Explosion" )

      break

    end

    self:YieldCoroutine( false )

  end

  if self:GetEnraged() then

    local Now = CurTime()
    local HasAlerted = false

    self:OnAnimEvent( "Charge " .. 1 )

    while true do

      local Enemy = self:GetEnemy()
  
      if self:GetTurning() then

        self:FaceEnemy()
  
      end

      self:SetVelocity( vector_origin )

      if CurTime() - Now > 1 / self:CalculateAnimRate() and not HasAlerted then

        self:SetTurning( false )

        self:OnAnimEvent( "Flag Parry 1" )
        self:OnAnimEvent( "Flag Turning 0" )
        self:OnAnimEvent( "Alert Parry" )
        self:OnAnimEvent( "Turn 0.5" )
  
        HasAlerted = true
  
      end
  
      if CurTime() - Now > 1.5 / self:CalculateAnimRate() then
  
        self:OnAnimEvent( "Flag Parry 0" )
        self:OnAnimEvent( "Flag Turning 1" )
        self:OnAnimEvent( "Explosion" )
  
        break
  
      end

      self:YieldCoroutine( false )
  
    end

  end

  self:SetCooldown( "Attack", 1 / self:CalculateRate() )

end


function ENT:OnMeleeAttack( Enemy )

  if self:GetCooldown( "Attack" ) > 0 then return end
  if self:GetEnraged() then return self:MaliciousBeam( Enemy ) end

  local Random = MRandom( 2 )

  if Random == 1 and self.CurrentBarrageTracker >= 2 then

    return self:MaliciousBeam( Enemy )

  else

    return self:MaliciousShoot( Enemy )

  end

end


function ENT:OnRangeAttack( Enemy )

  if self:GetCooldown( "Attack" ) > 0 then return end

  self:MaliciousShoot( Enemy )

end


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  UltrakillBase.TraceSetPos( self, self:GetPos() + Vector( 0, 0, 100 ) )

  self:CreatePortal( self:WorldSpaceCenter(), self:GetAngles(), 3, Vector( 64, 64, 100 ) )

  self:ParticleEffectTimed( 2, "Ultrakill_Portal_SwordsMachine", { pos = self:WorldSpaceCenter(), ang = self:GetAngles() } )
  UltrakillBase.SoundScript( "Ultrakill_Portal_Superheavy", self:GetPos() )

  UltrakillBase.AddBoss( self, "#ultrakill.maliciousface.boss" )

  UltrakillBase.PlayMusic( self, "0-1" )

  self:SetCooldown( "Attack", 1 )

  self.CurrentBarrageTracker = 0
  self.HasSpawned = true

end


function ENT:OnTakeDamage( CDamageInfo, HitGroup )

  BaseClass.OnTakeDamage( self, CDamageInfo, HitGroup )

end


function ENT:OnRemove()

  if self:GetEnraged() then UltrakillBase.SoundScript( "Ultrakill_Enrage_End", self:GetPos() ) end

  UltrakillBase.StopCurrentMusic( self )

end


function ENT:OnDeath( Dmg, HitGroup )

  local Proj = self:CreateProjectile( "Ultrakill_MaliciousFace_Corpse" )
  Proj:SetOwner( self )
  Proj:SetPos( self:GetPos() )
  Proj:SetAngles( self:GetAimAngles() )

end


else


local LegOffsetZ = Vector( 0, 0, ENT.IKRange )
local MaliciousFaceLegs = Material( "particles/ultrakill/black_trail.vmt" )
local MaliciousFaceLegsColor = Color( 0, 0, 0, 20 )


local function RenderLine( StartPos, EndPos )

  RSetMaterial( MaliciousFaceLegs )
	RStartBeam( 2 )

		for I = 0, 1 do

			local Vec = LerpVector( I, StartPos, EndPos )

			RAddBeam( Vec, 4, I, MaliciousFaceLegsColor )

		end

	REndBeam()

end


local function GetAttachmentByName( self, AttachName )

  return self:GetAttachment( self:LookupAttachment( AttachName ) )

end


function ENT:CustomInitialize()

  if self.UltrakillBase_Difficulty <= 2 then

    self.MaliciousFaceChargeTime = self.UltrakillBase_Difficulty >= 1 and 3.5 or 5
    self.MaliciousFaceBarrageAmount = self.UltrakillBase_Difficulty <= 1 and 3 + self.UltrakillBase_Difficulty or 6

  else

    self.MaliciousFaceChargeTime = 2
    self.MaliciousFaceBarrageAmount = 6

  end

  local WorldCenterPos = self:WorldSpaceCenter()

  local LegOffset = {

    self:GetRight() * -600 + self:GetForward() * 600,
    self:GetRight() * -600 + self:GetForward() * -600,
    self:GetRight() * 600 + self:GetForward() * 600,
    self:GetRight() * 600 + self:GetForward() * -600
  
  }

  LegOffsetZ.z = MaliciousFaceLegRange

  for X = 1, 4 do

    local OffsetPos = LegOffset[ X ]

    local Trace = self:TraceLine( nil, {

      start = WorldCenterPos,
      endpos = WorldCenterPos + OffsetPos - LegOffsetZ,
      collisiongroup = COLLISION_GROUP_WORLD

    } )

    self[ "MaliciousFace_Leg_" .. X .. "_Pos" ] = Trace.HitPos

  end

end


function ENT:CustomDraw()

  -- Base Limbs --

  local CenterPos = self:GetAttachment( 3 ).Pos

  for X = 1, 4 do

    local AttachmentPos = GetAttachmentByName( self, "Legs_" .. X ).Pos

    RenderLine( CenterPos, AttachmentPos )

  end

  -- Moving Limbs --

  local WorldCenterPos = self:WorldSpaceCenter()

  local LegOffset = {

    self:GetRight() * -200 + self:GetForward() * 200,
    self:GetRight() * -200 + self:GetForward() * -200,
    self:GetRight() * 200 + self:GetForward() * 200,
    self:GetRight() * 200 + self:GetForward() * -200
  
  }

  LegOffsetZ.z = MaliciousFaceLegRange

  for X = 1, 4 do

    local AttachmentPos = GetAttachmentByName( self, "Legs_" .. X ).Pos
    local OffsetPos = LegOffset[ X ]
    local LegPos = self[ "MaliciousFace_Leg_" .. X .. "_Pos" ]

    if LegPos and self:IsInRange( LegPos, 200 ) then

      RenderLine( AttachmentPos, LegPos )

      continue

    end

    local Trace = self:TraceLine( nil, {

      start = WorldCenterPos,
      endpos = WorldCenterPos + OffsetPos - LegOffsetZ,
      collisiongroup = COLLISION_GROUP_WORLD

    } )

    self[ "MaliciousFace_Leg_" .. X .. "_Pos" ] = Trace.HitPos
    RenderLine( AttachmentPos, Trace.HitPos )

  end

end


end


AddCSLuaFile()
DrGBase.AddNextbot( ENT )