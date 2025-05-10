AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:AddEFlags(EFL_NO_DAMAGE_FORCES)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	
	self:SetTrigger(false)
	self:DrawShadow(false)
	
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

	self:Fire("kill","",10)
end


function ENT:PhysicsCollide(data)
end


