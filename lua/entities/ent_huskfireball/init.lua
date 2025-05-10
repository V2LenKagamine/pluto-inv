util.AddNetworkString("ExplodeHuskFireball")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")


ENT.Exploding = false
ENT.Damage = 20

function ENT:Initialize()
	self:SetModel( "models/props_phx/misc/smallcannonball.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:AddEFlags(EFL_NO_DAMAGE_FORCES)
	self:AddFlags(FL_GRENADE)
	self:SetCollisionGroup(COLLISION_GROUP_DISSOLVING)
	
	self:SetTrigger(true)
	
	self:SetHealth(100)
	
	self:SetModelScale(0.15)
	
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0)
		phys:SetDamping(1,1)
	end
	
	local TEMP_TrailStartSize = 35
	local TEMP_TrailEndSize = 1
		
	util.SpriteTrail( self, 0, Color(255,255,255,255), true, TEMP_TrailStartSize, TEMP_TrailEndSize, 0.2, 
	1/(TEMP_TrailStartSize/TEMP_TrailEndSize)*0.5, "trails/HuskgunFire.vmt" )
	
	ParticleEffectAttach("huskgun_fireball", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	
	self.Exploding = false
	self.Damage = 20
end

function ENT:Detonate()
	self.Exploding = true
	local TEMP_Radius = 100
	
	local Explosion = ents.Create( "env_explosion" )
	Explosion:SetPos( self:GetPos() )
	Explosion:Spawn()
	Explosion:SetOwner(self)
	Explosion:SetKeyValue( "iMagnitude", "1000" )
	Explosion:SetKeyValue( "iRadiusOverride", "120" )
	Explosion:SetKeyValue("spawnflags","65")
	Explosion:Fire("Explode", 0, 0 )
	Explosion:Fire("Kill","",0.01)
	
	local TEMP_FireExplosion = DamageInfo()
	if(IsValid(self:GetOwner())&&self:GetOwner()!=nil&&self:GetOwner()!=NULL) then
		TEMP_FireExplosion:SetAttacker(self:GetOwner())
	else
		TEMP_FireExplosion:SetAttacker(self)
	end
	
	TEMP_FireExplosion:SetInflictor(self)
	TEMP_FireExplosion:SetDamageType(bit.bor(DMG_BURN, DMG_BLAST, DMG_SLOWBURN))
	TEMP_FireExplosion:SetDamagePosition(self:GetPos())
	
	local TEMP_MyNearbyTargets = ents.FindInSphere(self:GetPos(),TEMP_Radius)
		
	if (#TEMP_MyNearbyTargets>0) then 
		for T=1, #TEMP_MyNearbyTargets do
			local TEMP_ENT = TEMP_MyNearbyTargets[T]
			
			if(((TEMP_ENT:IsPlayer()&&TEMP_ENT:Alive())||TEMP_ENT:IsNPC())&&TEMP_ENT!=self:GetOwner()&&TEMP_ENT!=self) then
				local TEMP_Point1 = TEMP_ENT:NearestPoint(self:GetPos())
				local TEMP_Point2 = self:NearestPoint(TEMP_ENT:GetPos())
				
				
				local TEMP_DistanceForce = (TEMP_Radius-(TEMP_Point1:Distance(TEMP_Point2)))
				
				local TEMP_BurnDamage = math.Clamp(self.Damage*(TEMP_DistanceForce/TEMP_Radius),1,35)
				TEMP_FireExplosion:SetDamage(TEMP_BurnDamage)
				TEMP_FireExplosion:SetDamageForce((TEMP_ENT:GetPos()-self:GetPos()):GetNormalized()*TEMP_DistanceForce)
				TEMP_ENT:TakeDamageInfo(TEMP_FireExplosion)
				TEMP_ENT:Ignite(TEMP_DistanceForce*0.04)
			end
		end
	end
	
	sound.Play("KFMod.FireBall.Explosion"..math.random(1,3),self:GetPos())
	
	timer.Create("StopProjectile"..tostring(self),0.01,1,function()
		if(IsValid(self)&&self!=nil&&self!=NULL) then
			self:SetNoDraw(true)
			self:DrawShadow(false)
			self:SetVelocity(Vector(0,0,0))
			self:SetMoveType(MOVETYPE_NONE)
		end
	end)
	
	self:StopParticles()
	self:Fire("kill","",1)
	
	net.Start("ExplodeHuskFireball")
	net.WriteEntity(self)
	net.WriteVector(self:GetPos())
	net.Broadcast()
end

function ENT:PhysicsCollide(data)
	local ent = data.HitEntity
	
	if(self.Exploding==false) then
		if(IsValid(ent)&&ent!=self:GetOwner()&&IsValid(self:GetOwner())&&ent:IsNPC()&&self:GetOwner():IsNPC()&&
		ent:Disposition(self:GetOwner())>D_HT&&self:GetOwner():Disposition(ent)>D_HT) then
			constraint.NoCollide(self,ent)
			
			local TEMP_Side = self:GetRight()
			
			
			local TEMP_Diff = (ent:GetPos()-self:GetPos()):Angle().Yaw-self:GetAngles().Yaw
			
			local TEMP_AngDiff = math.NormalizeAngle(TEMP_Diff)
			
			if(math.abs(TEMP_AngDiff)<0) then
				TEMP_Side = -self:GetRight()
			end
			
			ent:SetVelocity((TEMP_Side*500)+Vector(0,0,200))
			
			self:SetVelocity(data.OurOldVelocity)
		else
			self:Detonate()
		end
	end
end

function ENT:StartTouch(ent)
	if(self.Exploding==false) then
		if(IsValid(ent)&&ent!=self:GetOwner()&&IsValid(self:GetOwner())&&ent:IsNPC()&&self:GetOwner():IsNPC()&&
		ent:Disposition(self:GetOwner())>D_HT&&self:GetOwner():Disposition(ent)>D_HT) then
			local TEMP_Side = self:GetRight()
			
			
			local TEMP_Diff = (ent:GetPos()-self:GetPos()):Angle().Yaw-self:GetAngles().Yaw
			
			local TEMP_AngDiff = math.NormalizeAngle(TEMP_Diff)
			
			if(math.abs(TEMP_AngDiff)<0) then
				TEMP_Side = -self:GetRight()
			end
			
			ent:SetVelocity((TEMP_Side*500)+Vector(0,0,200))
		else
			self:Detonate()
		end
	end
end
		
	
	

