local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local DrGBase = DrGBase
local UltrakillBase = UltrakillBase
local Color = Color
local Vector = Vector
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakill_cerberus"

-- Misc --

ENT.PrintName = "Cerberus"
ENT.Category = "ULTRAKILL - Enemies"
ENT.Skins = { 0 }
ENT.ModelScale = 1

-- Stats --

ENT.SpawnHealth = 250

if SERVER then


function ENT:OnPhaseChange( Phase )

  if Phase ~= 2 or self:IsDead() then return end

  self.Cracked = true

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

end


function ENT:Enrage()

  if self:GetEnraged() then return end

  self:SetEnraged( true )

  UltrakillBase.SoundScript( "Ultrakill_CerberusEnrage", self:GetPos(), self )
  UltrakillBase.SoundScript( "Ultrakill_Enrage_Loop", self:GetPos(), self )
  UltrakillBase.SoundScript( "Ultrakill_Enrage", self:GetPos(), self )

  self:CreateLight( 0, Color( 255, 0, 0 ), 450, 6, 0, 1 )

  self:ScreenShake( 150, 10, 1, 1550 )

  self:SetSkin( self.Cracked and 3 or 2 )

  self:CreateEnrage( 1, 1.32 )

  self.WalkSpeed = 270
  self.RunSpeed = 270

end


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  self:CreatePortal( self:WorldSpaceCenter(), self:GetAngles(), 3, Vector( 75, 75, 180 ) )

  self:ParticleEffectTimed( 2, "Ultrakill_Portal_Cerberus", { pos = self:WorldSpaceCenter(), ang = self:GetAngles() } )
  UltrakillBase.SoundScript( "Ultrakill_Portal_Superheavy", self:GetPos() )

  self.CerberusAwake = true

  self:SetCooldown( "Attack", 0.5 )

end


function ENT:OnRemove()

  if self:GetEnraged() then UltrakillBase.SoundScript( "Ultrakill_Enrage_End", self:GetPos() ) end

end


end


AddCSLuaFile()
DrGBase.AddNextbot( ENT )