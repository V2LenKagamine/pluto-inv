local ParticleEffectAttach = ParticleEffectAttach
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local ParticleEffect = ParticleEffect
local UltrakillBase = UltrakillBase
local Vector = Vector
local Matrix = Matrix
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_projectile"


-- Misc --

ENT.PrintName = "Shotgun - Pellet"
ENT.Category = "UltrakillBase"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Models = { "models/ultrakill/mesh/effects/sphere/Sphere_8.mdl" }
ENT.ModelScale = 0.5
ENT.Spawnable = false

-- Collision --

ENT.UltrakillBase_CustomCollisionEnabled = true


if SERVER then


function ENT:CustomInitialize()

  ParticleEffectAttach( "Ultrakill_Shotgun_Trail", PATTACH_POINT_FOLLOW, self, 0 )

  self:SetMaterial( "models/ultrakill/vfx/Shotgun/Shotgun_Proj" )

  SafeRemoveEntityDelayed( self, 5 )

end


function ENT:OnTakeDamage( Dmg ) 
  
  self:CheckParry( Dmg )

end


function ENT:OnContact( Ent )

  if self:GetParried() then return self:ParryCollide( 300 ) end

  UltrakillBase.SoundScript( "Ultrakill_Impact_S_03", self:GetPos() )
  ParticleEffect( "Ultrakill_Shotgun_Sparks", self:GetPos(), self:GetAngles() )

  self:DealDamage( Ent, 300, nil, DMG_BUCKSHOT )

end


else


function ENT:CustomThink()

  self:AngleFollowVelocity()

end


local ScaleVector = Vector( 2.5, 0.6, 0.6 )
local ScaleMatrix = Matrix()


function ENT:CustomDraw()

  ScaleMatrix:SetScale( ScaleVector )

  self:EnableMatrix( "RenderMultiply", ScaleMatrix )

end 


end


AddCSLuaFile()