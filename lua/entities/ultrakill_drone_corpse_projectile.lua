local UltrakillBase = UltrakillBase
local SafeRemoveEntity = SafeRemoveEntity
local Angle = Angle
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_projectile"

-- Misc --

ENT.PrintName = "Drone_Projectile"
ENT.Category = "UltrakillBase"
ENT.Models = { "models/ultrakill/characters/enemies/lesser/drone.mdl" }
ENT.ModelScale = 1
ENT.Spawnable = false

-- Collision --

ENT.UltrakillBase_CustomCollisionEnabled = true

-- Locomotion --

ENT.Acceleration = 5000
ENT.Deceleration = 3000


if SERVER then


function ENT:CustomInitialize()

  UltrakillBase.SoundScript( "Ultrakill_Drone_Death", self:GetPos(), self )

end


function ENT:CustomThink()

  self:Approach( self:GetPos() + self:GetForward(), 2500 )

end


function ENT:OnTakeDamage( Dmg )

  self:CheckParry( Dmg )

  if not self:GetParried() and not self.HasExploded then

    self:OnContact()

  end

end


function ENT:OnContact( Ent )

  if self.HasExploded then return end

  self.HasExploded = true

  self:ParryCollide( 350 )

  SafeRemoveEntity( self )

end


else

  
function ENT:CustomInitialize()

  self.SpinRate = 1500

  self.SpinAngle = Angle()

end


function ENT:CustomThink()

  self.SpinAngle:RotateAroundAxis( self.SpinAngle:Up(), self.SpinRate * self:GetUpdateInterval() )

  self:ManipulateBoneAngles( 1, self.SpinAngle, false )

  self:AngleFollowVelocity()

end


end


AddCSLuaFile()