AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:SetSolid(SOLID_NONE)
	self:DrawShadow(false)
	
	self.curtime=CurTime()
	self.delta_time=0
	self.velocity=self:GetDTVector(RBO_BULLET_VEC_VELOCITY)
	self.acceleration=self:GetDTVector(RBO_BULLET_VEC_ACCELERATION)
	self.position=self:GetDTVector(RBO_BULLET_VEC_POSITION)
	self.source=self:GetDTEntity(RBO_BULLET_ENT_SHOOTER)
    
	self:NextThink(CurTime())
end

function ENT:RBOAddVelocity(v)
	assert(type(v)=="vector")
	self.velocity=self.velocity+v
end

function ENT:RBOAddAcceleration(a)
	assert(type(a)=="vector")
	self.acceleration=self.acceleration+a
	self:SetDTVector(RBO_BULLET_VEC_ACCELERATION,self.acceleration)
end

function ENT:RBOSetVelocity(v)
	assert(type(v)=="vector")
	self.velocity=v
end

function ENT:RBOSetAcceleration(a)
	assert(type(a)=="vector")
	self.acceleration=a
	self:SetDTVector(RBO_BULLET_VEC_ACCELERATION,self.acceleration)
end