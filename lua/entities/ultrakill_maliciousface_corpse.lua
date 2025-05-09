local IsValid = IsValid
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local UltrakillBase = UltrakillBase
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_projectile"

-- Misc --

ENT.PrintName = "Malicious Face Dead"
ENT.Category = "UltrakillBase"
ENT.Models = { "models/ultrakill/characters/enemies/boss/maliciousface.mdl" }
ENT.ModelScale = 1
ENT.OnContactDelete = -1
ENT.Spawnable = false

-- Physics --

ENT.Gravity = true


-- Parry --

ENT.UltrakillBase_Parryable = false


if SERVER then


function ENT:CustomInitialize()

  local Owner = self:GetOwner()

  if IsValid( Owner ) and Owner and Owner.IsUltrakillNextbot then

    self:SetModelScale( Owner:GetModelScale() )

  end

  self.Collided = false

  self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
  SafeRemoveEntityDelayed( self, 12 )

end


function ENT:OnContact( Ent )

  if self.Collided then return end

  self.Collided = true

  UltrakillBase.SoundScript( "Ultrakill_BigRockBreak", self:GetPos(), self )

  local Phys = self:GetPhysicsObject()

  if IsValid( Phys ) then

    Phys:EnableMotion(false)
    Phys:Sleep()

  end

  self:Activate()

  UltrakillBase.CreateGibs( {

		{ 
			Position = self:GetPos(),
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk1.mdl",
			Velocity = 600,
			ModelScale = 1,
			Trail = "Ultrakill_White_Trail"
		},

		{ 
			Position = self:GetPos(),
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk2.mdl",
			Velocity = 600,
			ModelScale = 1,
			Trail = "Ultrakill_White_Trail"
		},

		{ 
			Position = self:GetPos(),
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk1.mdl",
			Velocity = 600,
			ModelScale = 1,
			Trail = "Ultrakill_White_Trail"
		},

		{ 
			Position = self:GetPos(),
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk2.mdl",
			Velocity = 600,
			ModelScale = 1,
			Trail = "Ultrakill_White_Trail"
		},

		{ 
			Position = self:GetPos(),
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk1.mdl",
			Velocity = 600,
			ModelScale = 1,
			Trail = "Ultrakill_White_Trail"
		},

		{ 
			Position = self:GetPos(),
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk2.mdl",
			Velocity = 600,
			ModelScale = 1,
			Trail = "Ultrakill_White_Trail"
		}

	} )

  self:Shockwave( false, self:GetPos(), angle_zero, 0, 3, 100, 0.1 )

  self:SetCollisionGroup( COLLISION_GROUP_NPC )

end


end


AddCSLuaFile()