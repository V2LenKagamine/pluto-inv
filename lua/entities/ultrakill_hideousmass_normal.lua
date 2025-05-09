local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local DrGBase = DrGBase
local UltrakillBase = UltrakillBase
local Vector = Vector
local CurTime = CurTime
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakill_hideousmass"

ENT.PrintName = "Hideous Mass"
ENT.Category = "ULTRAKILL - Enemies"

ENT.SpawnHealth = 60000

if SERVER then


function ENT:CustomThink()

  if self:IsEnraged() and self.CurrentState ~= 3 and not self:IsDead() then

    self.CurrentState = 3

    self.IdleAnimation = "CrazyPose"
    self.WalkAnimation = self.IdleAnimation
    self.RunAnimation = self.IdleAnimation
    self.JumpAnimation = self.IdleAnimation
    self.FallingAnimation = self.IdleAnimation

  end

  if self:Health() <= self:GetMaxHealth() * 0.333333 and self:GetPhase() < 2 and not self:IsDead() and not self:IsAttacking() then

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


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  self:CreatePortal( self:WorldSpaceCenter(), self:GetAngles(), 3, Vector( 200, 200, 260 ) )

  self:ParticleEffectTimed( 2, "Ultrakill_Portal_HideousMass", { pos = self:WorldSpaceCenter(), ang = self:GetAngles() } )

  UltrakillBase.SoundScript( "Ultrakill_Portal_Superheavy", self:GetPos() )

  self.CurrentMortarTracker = 0

  self:SetCooldown( "Attack", 2 / self:CalculateAnimRate() )

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

  UltrakillBase.SoundScript( "Ultrakill_Death_Explode", self:GetPos() )

  UltrakillBase.SlowMotion( 2 )

end


end

AddCSLuaFile()
DrGBase.AddNextbot( ENT )