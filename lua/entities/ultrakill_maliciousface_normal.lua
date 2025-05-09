local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local DrGBase = DrGBase
local UltrakillBase = UltrakillBase
local Vector = Vector
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakill_maliciousface"

-- Misc --

ENT.PrintName = "Malicious Face"
ENT.Category = "ULTRAKILL - Enemies"
ENT.Models = { "models/ultrakill/characters/enemies/boss/maliciousface.mdl" }

-- Stats --

ENT.SpawnHealth = 15000

if SERVER then


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  UltrakillBase.TraceSetPos( self, self:GetPos() + Vector( 0, 0, 100 ) )

  self:CreatePortal( self:WorldSpaceCenter(), self:GetAngles(), 3, Vector( 64, 64, 100 ) )

  self:ParticleEffectTimed( 2, "Ultrakill_Portal_SwordsMachine", { pos = self:WorldSpaceCenter(), ang = self:GetAngles() } )
  UltrakillBase.SoundScript( "Ultrakill_Portal_Superheavy", self:GetPos() )

  self:SetCooldown( "Attack", 1 )

  self.CurrentBarrageTracker = 0

end


end


AddCSLuaFile()
DrGBase.AddNextbot( ENT )