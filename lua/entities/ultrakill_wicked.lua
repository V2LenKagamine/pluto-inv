local Vector = Vector
local UltrakillBase = UltrakillBase
local isentity = isentity
local ipairs = ipairs
local EFindInSphere = ents.FindInSphere
local IsValid = IsValid
local AddCSLuaFile = AddCSLuaFile
local DrGBase = DrGBase

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_nextbot"

-- Misc --

ENT.PrintName = "Something Wicked"
ENT.Category = "ULTRAKILL - Secrets"
ENT.Models = { "models/ultrakill/characters/enemies/special/wicked.mdl" }
ENT.Skins = { 0 }
ENT.ModelScale = 1
ENT.CollisionBounds = Vector( 2, 2, 64 ) * 1.75
ENT.SurroundingBounds = Vector( 35, 35, 85 ) * 1.75
ENT.RagdollOnDeath = false

-- Stats --

ENT.SpawnHealth = 1

-- AI --

ENT.MeleeAttackRange = 75
ENT.ReachEnemyRange = 45
ENT.AvoidEnemyRange = 35

-- Detection --

ENT.EyeBone = "Head"

-- Relationships --

ENT.Factions = { "" }

-- Locomotion --

ENT.Acceleration = 5000
ENT.Deceleration = 10000
ENT.JumpHeight = 150
ENT.StepHeight = 20
ENT.MaxYawRate = 400
ENT.DeathDropHeight = 100

-- Animations --

ENT.WalkAnimation = "Run"
ENT.WalkAnimRate = 1
ENT.RunAnimation = "Run"
ENT.RunAnimRate = 1
ENT.IdleAnimation = "Run"
ENT.IdleAnimRate = 1
ENT.JumpAnimation = "Run"
ENT.JumpAnimRate = 1

-- Movements --

ENT.UseWalkframes = false
ENT.WalkSpeed = 350
ENT.RunSpeed = 525


-- Possession --

ENT.PossessionCrosshair = true

ENT.PossessionEnabled = true

ENT.PossessionViews = {

  {

    offset = Vector( 0, 15, 45 ),
    distance = 150,
    eyepos = false

  },

  {

    offset = Vector( 7.5, 0, 0 ),
    distance = 0,
    eyepos = true

  }

}

ENT.PossessionBinds = {

  [ IN_ATTACK ] = { { coroutine = true, onkeydown = function( self )

    self:OnMeleeAttack()

  end } },

}


if SERVER then


function ENT:CustomInitialize()

  self:SetSandable( false )

  UltrakillBase.SoundScript( "Ultrakill_WickedAmbiance", self:GetPos(), self )
 
end


function ENT:WickedRelocate( Ent )

  if not isentity( Ent ) then return end

  local Pos = self:RandomPos( -15000, 15000 )

  if Ent:GetPos():DistToSqr( Pos ) <= 2250000 then return self:WickedRelocate( Ent ) end

  self:SetPos( Pos )

end


function ENT:OnMeleeAttack()

  self:Attack( {

    Damage = 100000,
    Range = 50,
    Type = DMG_DISSOLVE,
    Angle = 90,
    Force = Vector( 300, 0, 300 ),
    Push = true,
    
  } )

end


function ENT:OnSpawn()

  UltrakillBase.SoundScript( "Ultrakill_WickedSpawn", self:GetPos(), self )

  self:Timer( 2, function( self )

    UltrakillBase.Subtitle( "Something wicked this way comes...", 4, true )

  end )

end


function ENT:OnTakeDamage( CDamageInfo, HitGroup )

  CDamageInfo:SetDamage( 0 )

  self:WickedRelocate( CDamageInfo:GetAttacker() )

  UltrakillBase.SoundScript( "Ultrakill_WickedHurt", self:GetPos(), self )

  return false

end


end


AddCSLuaFile()
DrGBase.AddNextbot( ENT )