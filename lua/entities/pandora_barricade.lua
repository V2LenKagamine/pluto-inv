AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Pandora Barricade"
ENT.Category		= "None"

ENT.Spawnable		= false
ENT.AdminSpawnable	= true


function ENT:Initialize()
	self:SetModel("models/pandora/barricade.mdl")
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	if ( SERVER ) then self:PhysicsInit( SOLID_VPHYSICS ) end
	self:PhysWake()
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
    self:SetHealth(200)
end

function ENT:OnTakeDamage(dmginfo)
    self:SetHealth(self:Health() - dmginfo:GetDamage())     
    if self:Health() <=0 then
        self:Remove()
    end                                                    
end
