local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local UltrakillBase = UltrakillBase
local DrGBase = DrGBase
local pairs = pairs
local Vector = Vector
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakill_swordsmachine"

-- Misc --

ENT.PrintName = "SwordsMachine"
ENT.Category = "ULTRAKILL - Enemies"
ENT.Models = {"models/ultrakill/characters/enemies/boss/swordmachine.mdl"}
ENT.Skins = {0}

-- Stats --

ENT.SpawnHealth = 3000


if SERVER then


function ENT:OnPhaseChange( Phase )

  if Phase ~= 2 or self:IsDead() then return end

  if self:GetEnraged() then self:Derage() end

  self:SetBodygroup( 1, 1 )
  self:SetBodygroup( 3, 1 )

  self.UltrakillBase_RateMult = 1.2

  UltrakillBase.SoundScript( "Ultrakill_SwordsMachine_BigPain", self:GetPos(), self )
  UltrakillBase.SoundScript( "Ultrakill_SwordsMachine_BigPain_H", self:GetPos(), self )

  self:CallOverCoroutine( self.PlaySequenceAndMove, false, "Knockdown", 1.5, function( self, Cycle )

    if Cycle > 0.886356176 then

      return true

    end

  end )

end


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  self:CreatePortal( self:WorldSpaceCenter(), self:GetAngles(), 3, Vector( 45, 45, 160 ) )

  self:ParticleEffectTimed( 2, "Ultrakill_Portal_SwordsMachine", { pos = self:WorldSpaceCenter(), ang = self:GetAngles() } )
  UltrakillBase.SoundScript( "Ultrakill_Portal_Superheavy", self:GetPos() )

  self:SetCooldown( "Attack", 0.5 )

end


function ENT:OnDeath( Dmg, HitGroup )

  self:SetSkin( self.InitSkin )

  UltrakillBase.SoundScript( "Ultrakill_Machine_Death", self:GetPos() )

end


end


AddCSLuaFile()
DrGBase.AddNextbot( ENT )