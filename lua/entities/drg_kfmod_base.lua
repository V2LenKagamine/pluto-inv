if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "KF Base"
ENT.Category = "Killing Floor Nextbots"
ENT.Models = {"models/Tripwire/Killing Floor/Zeds/KFClot.mdl"}
ENT.BloodColor = BLOOD_COLOR_RED
ENT.RagdollOnDeath = true

ENT.Gore = {
	Head="",
	RArm="",
	LArm="",
	RLeg="",
	LLeg="",
}

ENT.CollisionBounds = Vector(16,16,70)

ENT.IdleSounds = {"KFMod.Clot.Idle",9}
ENT.AttackSounds = {"KFMod.Clot.Attack",6}
ENT.PainSounds = {"KFMod.Clot.Pain",6}
ENT.DeathSounds = {"KFMod.Clot.Die",7}

ENT.Factions = {"FACTION_KFZED"}

ENT.SpawnHealth = 10

ENT.Omniscient = true
ENT.MeleeAttackRange = 80
ENT.ReachEnemyRange = 50
ENT.AvoidEnemyRange = 0
ENT.FollowPlayers = true

ENT.EyeBone = "CHR_Head"
ENT.EyeOffset = Vector(7.5, 0, 5)
ENT.EyeAngle = Angle(0, 0, 0)

ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.PossessionViews = {{offset = Vector(0, 30, 20),distance = 100}}
ENT.PossessionBinds = {
	[IN_ATTACK] = {{coroutine = true,onkeydown = function(self)
		if self:GetPossessor():KeyDown(IN_FORWARD) then
			self:PlaySequenceAndMove("att"..math.random(2), 1, self.PossessionFaceForward)
		else
			self:PlaySequenceAndMove("att3", 1, self.PossessionFaceForward)
		end
	end}},
	[IN_ATTACK3] = {{coroutine = true,onkeydown = function(self)self:Suicide()end}},
	[IN_JUMP] = {{coroutine = false,onkeydown = function(self)self:Jump(450)end}},
}

ENT.ClimbLedges = false
ENT.ClimbLaddersUp = false
ENT.UseWalkframes = true

if SERVER then
util.AddNetworkString("KFNPCBloodExplosion")
function ENT:KFInit()end
function ENT:KFOnMelee()end -- Custom code to run when performing a melee attack.
function ENT:KFRange()end
function ENT:KFRun()return self:HasEnemy()end
function ENT:KFDeath(dmg)end
function ENT:KFAttack(tbl)
	self.Attacking = false
	
	local d = tbl.damage
	tbl.damage = function(ent,pos)
		return ent:IsPlayer() and d or (d*(math.Max(ent:GetMaxHealth()/256,1)))
	end
	
	return self:Attack(tbl, function(self,hit)
		if #hit > 0 then
			self:EmitSound(self.HitSnd)
		else
			self:EmitSound(self.MissSnd)
		end
	end)
end
function ENT:MissSound(str,int)
	if int != nil and int != NULL then
		self.MissSnd = str..""..math.random(int)
	else
		self.MissSnd = str
	end
end
function ENT:HitSound(str,int)
	if int != nil and int != NULL then
		self.HitSnd = str..""..math.random(int)
	else
		self.Hitsnd = str
	end
end
function ENT:SetGestureUse(bool)self.ShouldGest = bool end

ENT.MeleeAttacks = {}
function ENT:KFCreateMelee(tbl)table.insert(self.MeleeAttacks,tbl)end
-------------------------------------
function ENT:CustomInitialize()
	self:SetDefaultRelationship(D_HT)
	self.OnAttackSounds = {}
	for i=1,self.IdleSounds[2] do	table.insert(self.OnIdleSounds,self.IdleSounds[1]..""..i)end
	for i=1,self.AttackSounds[2] do	table.insert(self.OnAttackSounds,self.AttackSounds[1]..""..i)end
	for i=1,self.PainSounds[2] do	table.insert(self.OnDamageSounds,self.PainSounds[1]..""..i)end
	for i=1,self.DeathSounds[2] do	table.insert(self.OnDeathSounds,self.DeathSounds[1]..""..i)end
	
	self.HeadHealth = self:Health()/4
	self:SetCooldown("KFNextAttack"..self.PrintName, 0)
	self.Attacking = false
	self.AnimSpeed = 1
	self.ShouldGest = false
	
	self:KFInit()
end
function ENT:OnMeleeAttack(enemy)
	if self:GetCooldown("KFNextAttack"..self.PrintName) >0 or self.Attacking then return end
	self.Attacking = true
		if self:KFOnMelee(enemy) then return end
		self:EmitSound(table.Random(self.OnAttackSounds))
		local m = math.random(#self.MeleeAttacks)
		local t = self.MeleeAttacks[m]
		local vp = Angle(20, math.random(-10, 10), 0)
		
		local seq,dur = self:LookupSequence(t.anim)
		-- print(FindMetaTable("NextBot").AnimSpeed)
		self:SetCooldown("KFNextAttack"..self.PrintName, dur/self.AnimSpeed)
		
		if t.reps >1 then
			for i=1,t.reps do
				self:Timer(t.time[i],function()self:KFAttack({damage=t.damage,type=t.dmgtype,viewpunch=vp})end)
			end
		else
			self:Timer(t.time,function()self:KFAttack({damage=t.damage,type=t.dmgtype,viewpunch=vp})end)
		end
		if isfunction(t.callback) then
			t.callback(self,enemy)
		end
		if t.gesture then
			self:PlaySequence(t.anim,self.AnimSpeed)
		else
			self:PlaySequenceAndMove(t.anim,self.AnimSpeed)
		end
end
function ENT:OnRangeAttack(enemy)self:KFRange(enemy)end
function ENT:ShouldRun()return self:KFRun() end
function ENT:OnDeath(dmg,hg)
	self.OnIdleSounds = {}
	local force = dmg:GetDamageForce()
	local d = dmg:GetDamage()
	if dmg:IsExplosionDamage() then 
		hg = math.random(4,7)
	end
	if self:KFDeath(dmg,hg) then return end
	if hg == HITGROUP_RIGHTARM then self:SetBodygroup(3,1) self:KFCreateGib("CHR_RArmForeArm",self.Gore.RArm,force,d,true) end
	if hg == HITGROUP_LEFTARM then self:SetBodygroup(2,1) self:KFCreateGib("CHR_LArmForeArm",self.Gore.LArm,force,d,true) end
	if hg == HITGROUP_RIGHTLEG then self:SetBodygroup(5,1) self:KFCreateGib("CHR_RCalf",self.Gore.RLeg,force,d,true) end
	if hg == HITGROUP_LEFTLEG then self:SetBodygroup(4,1) self:KFCreateGib("CHR_LCalf",self.Gore.LLeg,force,d,true) end
	-- if hg == 8 then self:HandleHead(dmg) end
end
function ENT:OnUpdateAnimation()
	if self:IsDead() then return end
	if not self:IsOnGround() then return self.JumpAnimation, self.JumpAnimRate
	elseif self:IsRunning() then return self.RunAnimation, self.RunAnimRate
	elseif self:IsMoving() then return self.WalkAnimation, self.WalkAnimRate
	else return self.IdleAnimation, self.IdleAnimRate end
end


-- function ENT:OnTraceAttack(dmg,tr,hitgroup)self:HandleDamage(dmg,tr.HitGroup)end
-- function ENT:OnTakeDamage(dmg,hitgroup)self:HandleDamage(dmg,hitgroup)end
function ENT:OnTakeDamage(dmg,hg)
	local d = dmg:GetDamage()
	if dmg:IsExplosionDamage() and d >= (self.SpawnHealth/2) then self:KFTotalGib(dmg) 
	elseif d >= (self.SpawnHealth/10) and not self.Flinching then 
		self.Flinching = true
		self:KFCoroutine(function()
			self.Flinching = false
			self:PlaySequenceAndMove("s_fall",1,function()if self.Flinching then return true end end)
		end) 
	elseif math.random(1,10) == 3 then
		self:PlaySequence("s_flinch",self.AnimSpeed)
	end
	if hg == 8 then
		self:HandleHead(dmg)
	end
end
function ENT:HandleHead(dmginfo)
	local force = dmginfo:GetDamageForce()
	local dmg = dmginfo:GetDamage()

	self.HeadHealth = self.HeadHealth-dmg
	if self.HeadHealth <= -(self.SpawnHealth/4) then
		for G=1,3 do
			self:KFCreateGib("Head","models/Tripwire/Killing Floor/Zeds/KFGoreBrain"..G..".mdl",force,dmg,false)
		end
		
		for G=1,2 do
			self:KFCreateGib("Head","models/Tripwire/Killing Floor/Zeds/KFGoreEye.mdl",force,dmg,false)
		end
	elseif self.HeadHealth <= 0 then
		self:KFCreateGib("Head",self.Gore.Head,force,dmg,true)
	end
	
	if self.HeadHealth <= 0 then
		self:SetBodygroup(1,1)
		local NECK = self:LookupBone("CHR_Neck")
		
		if(NECK) then
			local NeckPos, NeckAng = self:GetBonePosition(NECK)
			
			local CEffectData = EffectData()
			CEffectData:SetOrigin(NeckPos)
			CEffectData:SetFlags(3)
			CEffectData:SetScale(math.random(7,9))
			CEffectData:SetColor(0)
			CEffectData:SetNormal(Vector(0,0,1))
			CEffectData:SetEntity(self)
			CEffectData:SetAngles(NeckAng)
			util.Effect( "bloodspray", CEffectData, false,true )
		end
		self:Kill(dmginfo:GetAttacker(),dmginfo:GetInflictor())
	end
end
function ENT:KFTotalGib(dmginfo)
	local TEMP_BoxMin = self:GetPos()+self:OBBMins()
	local TEMP_BoxMax = self:GetPos()+self:OBBMaxs()
	
	net.Start("KFNPCBloodExplosion")
		net.WriteVector(TEMP_BoxMin)
		net.WriteVector(TEMP_BoxMax)
	net.Broadcast()
		
	for P=1, 8 do
		local TEMP_RandomPos = Vector(math.random(TEMP_BoxMin.x,TEMP_BoxMax.x),math.random(TEMP_BoxMin.y,TEMP_BoxMax.y),math.random(TEMP_BoxMin.z,TEMP_BoxMax.z))
		
		local TEMP_Prop = ents.Create("prop_physics")
		if P<6 then
			TEMP_Prop:SetModel("models/Tripwire/Killing Floor/Zeds/KFGoreChunk"..math.random(1,2)..".mdl")
		else
			if math.random(2)==1 then
				TEMP_Prop:SetModel(self.Gore["RLeg"])
			else
				TEMP_Prop:SetModel(self.Gore["LArm"])
			end
		end
		TEMP_Prop:SetPos(TEMP_RandomPos)
		TEMP_Prop:SetAngles(Angle(math.random(1,360),math.random(1,360),math.random(1,360)))
		TEMP_Prop:Spawn()
		
		TEMP_Prop:GetPhysicsObject():SetVelocity(Vector(math.random(-50,50),math.random(-50,50),math.random(-5,95)):GetNormalized()*((self.SpawnHealth/2)*(math.random(70,130)/100)))
		TEMP_Prop:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		TEMP_Prop:Fire("kill","",30)
		
		TEMP_Prop:TakeDamageInfo(dmginfo)
				
		local CEffectData = EffectData()
		CEffectData:SetOrigin(TEMP_RandomPos)
		CEffectData:SetFlags(3)
		CEffectData:SetScale(math.random(5,7))
		CEffectData:SetColor(0)
		CEffectData:SetNormal(VectorRand())
		CEffectData:SetAngles(AngleRand())
		util.Effect( "bloodspray", CEffectData, false )
	end
	SafeRemoveEntity(self)
end
function ENT:KFCreateGib(bone,model,force,dmg,bleed)
	if not bone then return end
	local Mat = self:GetBoneMatrix(self:DrG_SearchBone(bone))
	local Pos,Ang = Mat:GetTranslation(),Mat:GetAngles()
	
	if(!dmg) then dmg = 100	end
	
	local gib = ents.Create("prop_physics")
	gib:SetModel(model)
	gib:SetPos(Pos)
	gib:SetAngles(Ang)
	gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	gib:Spawn()
	gib:Activate()
	
	gib:SetOwner(self)
	SafeRemoveEntityDelayed(gib,10)
		
	if(!isvector(force)||!isnumber(force.x)||!isnumber(force.y)||!isnumber(force.z)) then
		force = Vector(math.random(-50,50),math.random(-50,50),math.random(-50,50)):GetNormalized()*(dmg*(math.random(70,130)/500))
	else
		force = (force:GetNormalized()+(Vector(math.random(-20,20),math.random(-20,20),math.random(-20,20))/100)):GetNormalized()*(dmg*((math.random(10,15)/1000)*force:Length()))
	end
	
	local gibMINS, gibMAXS = gib:GetCollisionBounds()
	
	local gibTR = util.TraceHull({
		start = gib:GetPos(),
		endpos = gib:GetPos(),
		filter = function(ent) if(!ent) then return true end end,
		mins = gibMINS,
		maxs = gibMAXS,
		mask = MASK_NPCSOLID
	})
	
	if(gibTR.Hit) then
		local CEffectData = EffectData()
		CEffectData:SetOrigin(Pos)
		CEffectData:SetFlags(3)
		CEffectData:SetScale(math.random(5,7))
		CEffectData:SetColor(0)
		CEffectData:SetNormal(-force)
		CEffectData:SetAngles(Ang)
		util.Effect("bloodspray",CEffectData,false,true)
		
		gib:Remove()
		return
	end
	
	
	if(IsValid(gib)&&gib!=nil&&gib!=NULL) then
		local gibPhys = gib:GetPhysicsObject()
		gibPhys:SetVelocity(force)
	end
			
	if(bleed) then
		for T=1, 4 do
			timer.Simple(0.2*T,function()
				if(IsValid(gib)&&gib!=nil&&gib!=NULL) then
					local CEffectData = EffectData()
					CEffectData:SetOrigin(gib:GetPos())
					CEffectData:SetFlags(3)
					CEffectData:SetScale(math.random(5,7))
					CEffectData:SetColor(0)
					CEffectData:SetNormal(-gib:GetVelocity())
					CEffectData:SetEntity(gib)
					CEffectData:SetAngles(gib:GetAngles())
					util.Effect( "bloodspray", CEffectData, false )
				end
			end)
		end
	end
end

function ENT:KFCoroutine(callback,arg)
	local oldThread = self.BehaveThread
	self.BehaveThread = coroutine.create(function()
		callback(self,arg)
		self.BehaveThread = oldThread
	end)
end
else
net.Receive("KFNPCBloodExplosion",function()
	local TEMP_V1 = net.ReadVector()
	local TEMP_V2 = net.ReadVector()
	
	local TEMP_EMITTER = ParticleEmitter(TEMP_V1,false)
	
	for P=1, 10 do
		local TEMP_V = Vector(math.random(TEMP_V1.x,TEMP_V2.x),math.random(TEMP_V1.y,TEMP_V2.y),math.random(TEMP_V1.z,TEMP_V2.z))

		local TEMP_ANGLE = AngleRand()

		
		local TEMP_PARTICLE = TEMP_EMITTER:Add("particle/smokestack", TEMP_V )
		TEMP_PARTICLE:SetDieTime( 0.6 )
		TEMP_PARTICLE:SetStartSize( 15 )
		TEMP_PARTICLE:SetEndSize( 30 )
		TEMP_PARTICLE:SetStartAlpha( 235 )
		TEMP_PARTICLE:SetEndAlpha( 50 )
		TEMP_PARTICLE:SetVelocity( TEMP_ANGLE:Forward() * 55 )
		TEMP_PARTICLE:SetGravity( TEMP_ANGLE:Forward() * -33 )
		TEMP_PARTICLE:SetColor(65,0,0)

		TEMP_PARTICLE:SetRoll( 15 )
		TEMP_PARTICLE:SetRollDelta( 1 )
		
		TEMP_PARTICLE:SetCollide( true )
		TEMP_PARTICLE:SetCollideCallback( function( part, hitpos, hitnormal )
			part:SetDieTime(-1)
		end )

		
		TEMP_V = Vector(math.random(TEMP_V1.x,TEMP_V2.x),math.random(TEMP_V1.y,TEMP_V2.y),math.random(TEMP_V1.z,TEMP_V2.z))

		TEMP_ANGLE = AngleRand()

		
		local TEMP_PARTICLE = TEMP_EMITTER:Add("particle/cloud", TEMP_V )
		TEMP_PARTICLE:SetDieTime( 3 )
		TEMP_PARTICLE:SetStartSize( 1 )
		TEMP_PARTICLE:SetEndSize( 1 )
		TEMP_PARTICLE:SetStartAlpha( 255 )
		TEMP_PARTICLE:SetEndAlpha( 235 )
		TEMP_PARTICLE:SetVelocity( TEMP_ANGLE:Forward() * 355 )
		TEMP_PARTICLE:SetGravity( Vector(0,0,-600) )
		TEMP_PARTICLE:SetColor(65,0,0)
		
		TEMP_PARTICLE:SetRoll( 15 )
		TEMP_PARTICLE:SetRollDelta( 1 )
		
		TEMP_PARTICLE:SetCollide( true )
		TEMP_PARTICLE:SetCollideCallback( function( part, hitpos, hitnormal )
			part:SetDieTime(-1)
		end )
		
		
		TEMP_V = Vector(math.random(TEMP_V1.x,TEMP_V2.x),math.random(TEMP_V1.y,TEMP_V2.y),math.random(TEMP_V1.z,TEMP_V2.z))

		TEMP_ANGLE = AngleRand()

		
		local TEMP_PARTICLE = TEMP_EMITTER:Add( "effects/blooddrop", TEMP_V )
		TEMP_PARTICLE:SetDieTime( 4 )
		TEMP_PARTICLE:SetStartSize( 3 )
		TEMP_PARTICLE:SetEndSize( 3 )
		TEMP_PARTICLE:SetStartAlpha( 255 )
		TEMP_PARTICLE:SetEndAlpha( 255 )
		TEMP_PARTICLE:SetVelocity( TEMP_ANGLE:Forward() * 425 )
		TEMP_PARTICLE:SetGravity( Vector( 0, 0, -600 ) )
		TEMP_PARTICLE:SetColor(65,0,0)
		
		TEMP_PARTICLE:SetRoll( 15 )
		TEMP_PARTICLE:SetRollDelta( 1 )

		TEMP_PARTICLE:SetCollide( true )
		TEMP_PARTICLE:SetCollideCallback( function( part, hitpos, hitnormal )
			part:SetDieTime(-1)
		end )
		
	end

	TEMP_EMITTER:Finish( )
end)
end

-- DO NOT TOUCH --
AddCSLuaFile()