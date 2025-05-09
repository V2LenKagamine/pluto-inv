local BaseClass = baseclass.Get( "ultrakill_swordsmachine" )
local UltrakillBase = UltrakillBase
local Vector = Vector
local ipairs = ipairs
local AddCSLuaFile = AddCSLuaFile
local DrGBase = DrGBase
local MApproach = math.Approach

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakill_swordsmachine"

-- Misc --

ENT.PrintName = "Tundra"
ENT.Category = "ULTRAKILL - Secrets"
ENT.Models = { "models/ultrakill/characters/enemies/boss/swordmachine.mdl" }
ENT.Skins = { 2 }

-- Stats --

ENT.SpawnHealth = 5000
ENT.Phase = 1
ENT.Phases = 1

ENT.UltrakillBase_WeaknessTable = {

  [ DMG_BUCKSHOT ] = 1.5,
  [ DMG_BLAST ] = 1.75,

}


ENT.Symbiote = NULL


if SERVER then


function ENT:OnSpawn()

  self:SetTurning( true )
  self:SetPhase( 2 )

  self:CreatePortal( self:WorldSpaceCenter(), self:GetAngles(), 3, Vector( 45, 45, 160 ) )

  self:ParticleEffectTimed( 2, "Ultrakill_Portal_SwordsMachine", { pos = self:WorldSpaceCenter(), ang = self:GetAngles() } )
  UltrakillBase.SoundScript( "Ultrakill_Portal_Superheavy", self:GetPos(), self )

  UltrakillBase.AddBoss( self, "#ultrakill.swordsmachine.tundra.boss", 1  )

  self:SetCooldown( "Attack", 0.5 ) -- Attack Delay of 0.5s

  for K, V in ipairs( self:GetAllies() ) do

    if V:GetClass() ~= "ultrakill_swordsmachine_agony" or IsValid( V.Symbiote ) then continue end

    self.Symbiote = V
    V.Symbiote = self
    break

  end

end


function ENT:OnDowned()

  if not IsValid( self.Symbiote ) then return end

  UltrakillBase.SoundScript( "Ultrakill_SwordsMachine_BigPain", self:GetPos(), self )
  UltrakillBase.SoundScript( "Ultrakill_SwordsMachine_BigPain_H", self:GetPos(), self )

  self.SwordsMachineIsDowned = true

  local fHealth = self:Health()
  local fDuration = self:SequenceDuration( self:LookupSequence( "Knockdown" ) )
  local fTarget = self.Symbiote:Health()
  local fChange = ( fTarget * self:GetUpdateInterval() * self:CalculateAnimRate( "Knockdown" ) ) / ( 0.886356176 * fDuration )

  self:PlaySequenceAndMove( "Knockdown", 1, function( self, Cycle )

    if not IsValid( self.Symbiote ) or self.Symbiote.SwordsMachineIsDowned then return true end

    fHealth = MApproach( fHealth, fTarget, fChange )

    self:SetHealth( fHealth )

    if Cycle > 0.886356176 then

      return true

    end

  end )

  self.SwordsMachineIsDowned = false

end


function ENT:OnTakeDamage( CDamageInfo, HitGroup )

  BaseClass.OnTakeDamage( self, CDamageInfo, HitGroup )

  if self.SwordsMachineIsDowned then CDamageInfo:ScaleDamage( 0 ) end
  if self:Health() - CDamageInfo:GetDamage() <= 0 and IsValid( self.Symbiote ) and not self.Symbiote.SwordsMachineIsDowned then

    CDamageInfo:ScaleDamage( 0 )
    self:SetHealth( 1 )
    self:CallOverCoroutine( self.OnDowned )

  end

end


function ENT:OnPhaseChange( Phase )
end


function ENT:Enrage()
  
  self:PlaySequenceAndMove( "Knockdown", 2, function( self, Cycle )
  
    if Cycle > 0.886356176 then
      
      return true

    end
  
  end )
  
end


function ENT:OnDeath( Dmg, HitGroup )

  if self:GetEnraged() then

    UltrakillBase.SoundScript( "Ultrakill_Enrage_End", self:GetPos() )

  end

  self:SetSkin( self.Skins[ #self.Skins ] )

  UltrakillBase.SoundScript( "Ultrakill_Machine_Death", self:GetPos() )

end


end


AddCSLuaFile()
DrGBase.AddNextbot( ENT )