local UltrakillBase = UltrakillBase
local DrGBase = DrGBase
local ipairs = ipairs
local pairs = pairs
local istable = istable
local isstring = isstring
local isvector = isvector
local Vector = Vector
local CurTime = CurTime
local MRandom = math.random
local TIsEmpty = table.IsEmpty
local IsValid = IsValid
local isnumber = isnumber
local GSinglePlayer = game.SinglePlayer
local SExplode = string.Explode
local isfunction = isfunction
local Material = Material
local RMaterialOverride = CLIENT and render.MaterialOverride
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot"

-- Misc --

ENT.PrintName = "Ultrakill_Base"
ENT.Category = "ULTRAKILL"
ENT.Models = { "" }
ENT.ModelScale = 1
ENT.CollisionBounds = vector_origin
ENT.IsUltrakillNextbot = true

ENT.MinPhysDamage = 0


-- Blood --

ENT.BloodColor = DONT_BLEED

-- Detection --

ENT.SightFOV = 90
ENT.SightRange = 15000
ENT.MinLuminosity = 0
ENT.MaxLuminosity = 1
ENT.HearingCoefficient = 1

-- AI --

ENT.Omniscient = true
ENT.AISight = true
ENT.MeleeAttackRange = math.huge
ENT.ReachEnemyRange = math.huge
ENT.AvoidEnemyRange = math.huge

ENT.BehaviourType = AI_BEHAV_CUSTOM
ENT.BehaviourStrafe = false
ENT.BehaviourStrafeUpdate = 2
ENT.BehaviourStrafeDirection = 1

-- Relationships --

ENT.DefaultRelationship = D_HT
ENT.PlayerRelationship = D_HT
ENT.AllyDamageTolerance = 0
ENT.Factions = { "FACTION_ULTRAKILL_ENEMIES" }


-- UltrakillBase --


-- Sounds --

ENT.UltrakillBase_RestartVoiceLine = nil
ENT.UltrakillBase_RestartVoiceLineDelay = 2
ENT.UltrakillBase_HurtSoundDelay = 0.1
ENT.UltrakillBase_HurtSound = nil

-- Phases --

ENT.UltrakillBase_PhaseMax = 1
ENT.UltrakillBase_Phase = 1


-- FullTracking --

ENT.UltrakillBase_FullTrackingBone = ""
ENT.UltrakillBase_FullTracking = false

-- Weight --

ENT.UltrakillBase_WeightClass = "Light"

-- Tables --

ENT.UltrakillBase_ParticleTable = {}
ENT.UltrakillBase_ContinuousAttacksTable = {}
ENT.UltrakillBase_EventTable = {}
ENT.UltrakillBase_OnEventTable = {}
ENT.UltrakillBase_AttackTable = {}
ENT.UltrakillBase_PreviouslyKilled = {}
ENT.UltrakillBase_InterruptionTable = {}

ENT.UltrakillBase_HitGroupMultipliers = {

  [ HITGROUP_HEAD ] = { 2, "Ultrakill_HeadBreak" },
  [ HITGROUP_RIGHTARM ] = { 1.25, "Ultrakill_LimbBreak" },
  [ HITGROUP_LEFTARM ] = { 1.25, "Ultrakill_LimbBreak" },
  [ HITGROUP_RIGHTLEG ] = { 1.25, "Ultrakill_LimbBreak" },
  [ HITGROUP_LEFTLEG ] = { 1.25, "Ultrakill_LimbBreak" },
  [ HITGROUP_GEAR ] = { 0, "Ultrakill_Bullet_Ricochet" },

}

ENT.UltrakillBase_WeaknessTable = {} -- Key = Type, Value = Percentage.
ENT.UltrakillBase_Difficulty = ENT.UltrakillBase_Difficulty or 0

DrGBase.IncludeFolder( "ultrakillbase/Nextbot" )
DrGBase.IncludeFolder( "ultrakillbase/Shared" )


if SERVER then


function ENT:_BaseInitialize()

  self:DrawShadow( false )

  self:AddEFlags( EFL_NO_DISSOLVE )

  self:CalculateUpdateInterval()

  self:SetSpawnEffect( false )

  self.UltrakillBase_Difficulty = UltrakillBase.GetDifficulty()

  self.UltrakillBase_UpdatePhaseDelay = 0
  self.UltrakillBase_StrafeUpdateDelay = 0
  self.UltrakillBase_ContinuousAttackDelay = 0

  self.UltrakillBase_CollisionUpdate = 0
  self.UltrakillBase_CollisionDelay = 0
  self.UltrakillBase_CollisionReCheck = 0

  for K, Seq in ipairs( self.UltrakillBase_AttackTable or {} ) do

    self:SetAttack( Seq, true )

  end

  for K, Seq in ipairs( self.UltrakillBase_IntroInfo or {} ) do

    self:SetIntro( Seq, true )

  end

  for Seq, Events in pairs( self.UltrakillBase_EventTable or {} ) do

    if not istable( Events ) or not isstring( Seq ) then continue end

    for K, Event in ipairs( Events or {} ) do

      self:AddAnimEvent( Seq, Event[ 1 ], Event[ 2 ] )

    end

  end

  self:SetFullTracking( self.UltrakillBase_FullTracking )

  self:SetSandable( true )
  self:SetSand( false )

  self:SetPhase( self.UltrakillBase_Phase or 1 )
  self:SetTotalPhases( self.UltrakillBase_PhaseMax or 1 )

  UltrakillBase.SetWeightClass( self, self.UltrakillBase_WeightClass )

  self.loco:SetGravity( UltrakillBase.GetWeightData( self ).Gravity )

  if isvector( self.SurroundingBounds ) then

    self:SetSurroundingBounds( -Vector( self.SurroundingBounds.x, self.SurroundingBounds.y, 0 ), self.SurroundingBounds )

  else

    local Min, Max = self:GetCollisionBounds()

    self:SetSurroundingBounds( Min * 3, Max * 3 )
    
  end

  self:InitializeFlying()
  self:InitializeAiming()

  self:AddEFlags( EFL_IN_SKYBOX )

end


function ENT:_BaseThink()

  if CurTime() > self.UltrakillBase_UpdatePhaseDelay and self:GetTotalPhases() > 1 and self:GetPhase() ~= self:GetTotalPhases() then

    self.UltrakillBase_UpdatePhaseDelay = CurTime() + 0.05
    self:UpdatePhase()

  end

  if CurTime() > self.UltrakillBase_StrafeUpdateDelay then

    self.UltrakillBase_StrafeUpdateDelay = CurTime() + self.BehaviourStrafeUpdate

    local Random = MRandom( 1, 2 )

    if Random == 1 then

      self.BehaviourStrafeDirection = 1

    else

      self.BehaviourStrafeDirection = -1

    end

  end

  if CurTime() > self.UltrakillBase_ContinuousAttackDelay and self:GetContinuousAttack() and self:IsAttacking() then

    self.UltrakillBase_ContinuousAttackDelay = CurTime() + 0.05

    if not istable( self.UltrakillBase_ContinuousAttacksTable ) or TIsEmpty( self.UltrakillBase_ContinuousAttacksTable ) then return end

    self:Attack( self.UltrakillBase_ContinuousAttacksTable )

  end

  self:CalculateFullTracking( self.UltrakillBase_FullTrackingBone )

  if self:GetFlying() then self:UpdateFlying() end

end


function ENT:OnSpawn()

  self:RemoveEFlags( EFL_IN_SKYBOX )

end


function ENT:OnChaseEnemy( Enemy )

  self:AimTowards( Enemy )

end


function ENT:OnIdle() end


function ENT:OnCombineBall( mEntity )

  return mEntity:Fire( "Explode", 0 )

end


function ENT:GetDamageMultiplierConVar( mAttacker )

  if not IsValid( mAttacker ) then return 1 end

  if IsValid( mAttacker ) and mAttacker:IsPlayer() then

    return UltrakillBase.ConVar_PlyDmgMult:GetFloat()

  elseif IsValid( mAttacker ) and not mAttacker:IsPlayer() and not mAttacker.IsUltrakillNextbot and not mAttacker.IsUltrakillProjectile then

    return UltrakillBase.ConVar_TakeDmgMult:GetFloat()

  end

  return 20

end


function ENT:DamageMultiplier( CDamageInfo, HitGroup )

  local Attacker = CDamageInfo:GetAttacker()
  local Inflictor = CDamageInfo:GetInflictor()

  UltrakillBase.SoundScript( "Ultrakill_Impact_S_03", self:GetPos() )

  if self:IsSand() then UltrakillBase.SoundScript( "Ultrakill_SandHit", self:GetPos() ) end

  if IsValid( Inflictor ) and Inflictor:GetClass() == "prop_combine_ball" then

    CDamageInfo:ScaleDamage( 0.05 )
    CDamageInfo:SetDamageType( DMG_BLAST )

  end

  -- HitGroup --

  local HitGroupData = self.UltrakillBase_HitGroupMultipliers[ HitGroup ] or {}

  CDamageInfo:ScaleDamage( HitGroupData[ 1 ] or 1 )

  if isstring( HitGroupData[ 2 ] ) then

    UltrakillBase.SoundScript( HitGroupData[ 2 ], self:GetPos() )

  end

  -- Weakness --

  for K, V in pairs( self.UltrakillBase_WeaknessTable ) do

    if not isnumber( K ) or not isnumber( V ) then continue end

    if CDamageInfo:IsDamageType( K ) and not CDamageInfo:IsDamageType( DMG_DIRECT ) then

      CDamageInfo:ScaleDamage( V )

    end

  end

  -- ConVars --

  CDamageInfo:ScaleDamage( self:GetDamageMultiplierConVar( Attacker ) )

  if CDamageInfo:IsDamageType( DMG_DISSOLVE ) then

    CDamageInfo:SetDamageType( DMG_BLAST )

  end

end


function ENT:OnTakeDamage( CDamageInfo, HitGroup )

  self:DamageMultiplier( CDamageInfo, HitGroup )
  self:CheckParry( CDamageInfo )
  self:CreateBlood( CDamageInfo, HitGroup )

end


function ENT:OnTookDamage( CDamageInfo, HitGroup )

  if self:GetCooldown( "UltrakillBase_Hurt" ) > 0 or not isstring( self.UltrakillBase_HurtSound ) then return end

  UltrakillBase.SoundScript( self.UltrakillBase_HurtSound, self:GetPos(), self )

  self:SetCooldown( "UltrakillBase_Hurt", self.UltrakillBase_HurtSoundDelay )

end


function ENT:OnOtherKilled( mVictim, CDamageInfo )

  if not mVictim:IsPlayer() or not IsValid( mVictim ) or ( not GSinglePlayer() and CDamageInfo:GetAttacker() ~= self and CDamageInfo:GetInflictor() ~= self ) then return end

  self.UltrakillBase_PreviouslyKilled[ mVictim:EntIndex() ] = true

end


function ENT:PossessionControls( bForward, bBackward, bRight, bLeft )

  local vDirection = self:GetPos()

  if bForward then

    vDirection = vDirection + self:GetAimVector()

  elseif bBackward then

    vDirection = vDirection - self:GetAimVector()

  end

  if bRight then

    vDirection = vDirection + self:PossessorRight()

  elseif bLeft then

    vDirection = vDirection - self:PossessorRight()

  end

  if vDirection ~= self:GetPos() then

    if not self:GetFlying() then

      self:MoveTowards( vDirection )

    else

      self:ApproachFlying( vDirection )

    end

    self:PossessionFaceForward()

  else

    if self:GetFlying() then

      self:SetVelocity( vector_origin )

    end

    self:PossessionFaceForward()

  end

end


function ENT:OnNewEnemy( Enemy )

  if self.UltrakillBase_PreviouslyKilled[ Enemy:EntIndex() ] ~= true or ( not isstring( self.UltrakillBase_RestartVoiceLine ) and not istable( self.UltrakillBase_RestartVoiceLine ) ) then return end

  local LineID = istable( self.UltrakillBase_RestartVoiceLine ) and self.UltrakillBase_RestartVoiceLine[ MRandom( #self.UltrakillBase_RestartVoiceLine ) ] or self.UltrakillBase_RestartVoiceLine
  local SinglePlayer = GSinglePlayer()

  UltrakillBase.SoundScript( LineID, self:GetPos(), self )

  if SinglePlayer then

    self.UltrakillBase_RestartVoiceLineDelay = self.UltrakillBase_RestartVoiceLineDelay <= 0 and 0.9 * UltrakillBase.PullSoundScript( LineID, true ).mDieTime or self.UltrakillBase_RestartVoiceLineDelay

    self:SetCooldown( "Attack", self.UltrakillBase_RestartVoiceLineDelay )

  end

  self.UltrakillBase_PreviouslyKilled = {}

end


function ENT:OnAnimEvent( Options )

  local Event = SExplode( " ", Options )
  local Function = self.UltrakillBase_OnEventTable[ Event[ 1 ] ]

  if not isfunction( Function ) then return end

  Function( self, Event, self:GetCurrentSequenceName() )

end


function ENT:OnUpdateAnimation()

  if self:IsDown() or self:IsDead() then return end

  if self:IsClimbingUp() then return self.ClimbUpAnimation, self.ClimbAnimRate * self:CalculateRate()

  elseif self:IsClimbingDown() then return self.ClimbDownAnimation, self.ClimbAnimRate * self:CalculateRate()

  elseif self:IsJumping() or self:IsLeaping() or self:IsGliding() or ( not self:IsOnGround() and self.FallingAnimation == nil ) then return self.JumpAnimation, self.JumpAnimRate * self:CalculateRate()

  elseif not self:IsOnGround() and self.FallingAnimation ~= nil then return self.FallingAnimation, self.FallingAnimRate * self:CalculateRate()

  elseif self:IsRunning() then return self.RunAnimation, self.RunAnimRate * self:CalculateRate()

  elseif self:IsMoving() then return self.WalkAnimation, self.WalkAnimRate * self:CalculateRate()

  else return self.IdleAnimation, self.IdleAnimRate * self:CalculateRate() end

end


function ENT:OnUpdateSpeed()

  if self:IsClimbing() then return self.ClimbSpeed * self:CalculateRate()

  elseif self.UseWalkframes then return -1

  elseif self:IsRunning() then return self.RunSpeed * self:CalculateRate()

  else return self.WalkSpeed * self:CalculateRate() end

end


else


function ENT:_BaseInitialize()

  self.UltrakillBase_Difficulty = UltrakillBase.GetDifficulty()

  self:CalculateUpdateInterval()

end


function ENT:_BaseThink()

  self:CalculateUpdateInterval()

  self:CalculateFullTracking( self.UltrakillBase_FullTrackingBone )

  self:RenderLight()

end


local mSandMaterial = Material( "models/ultrakill/vfx/Sand" )


function ENT:_BaseDraw()

  if self:IsSand() then

    RMaterialOverride( mSandMaterial )
    self:DrawModel()

  end

  if self:IsRadiant() then self:DrawRadiant() end
  if self.UltrakillBase_Enraged_Draw then self:DrawEnraged() end

  RMaterialOverride()

  self:RenderShake()

end


function ENT:DrawTranslucent()

  self:Draw()

end


local mDefaultColor = UltrakillBase.DefaultSecondaryBarYellowColor


function ENT:GetSecondaryBarValues()

  local fStaminaValue = self:GetStamina() / self:GetStaminaMax()
  if self:IsDead() then fStaminaValue = 0 end

  return fStaminaValue, mDefaultColor

end


end


AddCSLuaFile()