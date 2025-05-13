if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drg_kfmod_base" -- DO NOT TOUCH (obviously)

local name = "Husk"
ENT.PrintName = name
ENT.Category = "Killing Floor Nextbots"
ENT.Models = {"models/Tripwire/Killing Floor/Zeds/KF"..name..".mdl"}

ENT.Gore = {
	Head="models/Tripwire/Killing Floor/Zeds/KF"..name.."GoreHead.mdl",
	RArm="models/Tripwire/Killing Floor/Zeds/KF"..name.."GoreRHand.mdl",
	LArm="models/Tripwire/Killing Floor/Zeds/KF"..name.."GoreLHand.mdl",
	RLeg="models/Tripwire/Killing Floor/Zeds/KF"..name.."GoreRLeg.mdl",
	LLeg="models/Tripwire/Killing Floor/Zeds/KF"..name.."GoreLLeg.mdl",
}

ENT.CollisionBounds = Vector(18,18,75)

ENT.IdleSounds = {"KFMod."..name..".Chase",26}
ENT.AttackSounds = {"KFMod."..name..".Attack",4}
ENT.PainSounds = {"KFMod."..name..".Pain",16}
ENT.DeathSounds = {"KFMod."..name..".Die",7}

ENT.IdleAnimation="s_idle"
ENT.WalkAnimation="s_walk"
ENT.RunAnimation="s_run"
ENT.SpawnHealth = 200

ENT.MeleeAttackRange = 80
ENT.ReachEnemyRange = 50
ENT.AvoidEnemyRange = 0
ENT.FollowPlayers = true

ENT.PossessionBinds = {
	[IN_ATTACK] = {{coroutine = true,onkeydown = function(self)
		if self:GetCooldown("KFNextAttack"..self.PrintName) >0 or self.Attacking then return end
		self.Attacking = true

			self:EmitSound(table.Random(self.OnAttackSounds))
			local m = math.random(#self.MeleeAttacks)
			local t = self.MeleeAttacks[m]
			local vp = Angle(20, math.random(-10, 10), 0)
			
			local seq,dur = self:LookupSequence(t.anim)
			self:SetCooldown("KFNextAttack"..self.PrintName, dur/1.5)
			
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
	end}},
	[IN_ATTACK3] = {{coroutine = false,onkeydown = function(self)self:Suicide()end}},
	
	[IN_ATTACK2] = {{coroutine = true,onkeydown = function(self)self:KFRange()end}},
}

-- Climbing --
ENT.ClimbLedges = false
ENT.ClimbLaddersUp = false

ENT.UseWalkframes = true

if SERVER then
function ENT:KFInit()
	self:HitSound("KFMod.StrongHit",6)
	self:MissSound("KFMod.Gorefast.SwordMiss",4)
	self:KFCreateMelee({
		anim="s_melee1",
		damage=25,
		dmgtype=DMG_CLUB,
		time=1,
		reps=1,
		gesture=false
	})
	self:SetGestureUse(false)
	self.RangeAttackRange = math.huge
end
function ENT:KFRange()
	if self:GetCooldown("KFNextRAttack"..self.PrintName) >0 then return end
	local seq,dur = self:LookupSequence("s_rangedhuskgun_npc")
	self:SetCooldown("KFNextAttack"..self.PrintName, dur)
	
	self:EmitSound("KFMod.Husk.RAttack"..math.random(6))
	local TEMP_ShootPos = self:GetAttachment( self:LookupAttachment("HuskgunShoot") )
	sound.Play("KFMod.HuskGun.Charge",TEMP_ShootPos.Pos)
	
	self:Timer(1.1,function()
		local TEMP_BDamage = 50
		local TEMP_FireBallSpeed =	1350

		local TEMP_WeaponPos = self:GetAttachment( self:LookupAttachment("Huskgunshoot") )
		sound.Play("KFMod.HuskGun.Shoot",TEMP_WeaponPos.Pos)
		
		local TEMP_FireBall = ents.Create("ent_huskfireball")
		TEMP_FireBall:SetPos(TEMP_WeaponPos.Pos)
		--TEMP_FireBall:SetAngles(self:GetForward():Angle())
		TEMP_FireBall:Spawn()
		TEMP_FireBall:SetOwner(self)
		TEMP_FireBall.Damage = 50 --self.DMGMult*20
		
		if !self:IsPossessed() and IsValid(self:GetEnemy()) then
			self:FaceInstant(self:GetEnemy():GetPos())
			TEMP_FireBall:DrG_AimAt(self:GetEnemy(), TEMP_FireBallSpeed)
		elseif self:IsPossessed() then
			local lockedOn = self:PossessionGetLockedOn()
			if IsValid(lockedOn) then 
				self:FaceInstant(lockedOn:GetPos())
				TEMP_FireBall:DrG_AimAt(lockedOn,TEMP_FireBallSpeed)
			else
				TEMP_FireBall:DrG_AimAt(self:PossessorTrace().HitPos,TEMP_FireBallSpeed)
			end
		end

		local TEMP_GrenPhys = TEMP_FireBall:GetPhysicsObject()
		TEMP_GrenPhys:EnableGravity(false)
		
		local TEMP_CEffectData = EffectData()
		TEMP_CEffectData:SetOrigin(TEMP_WeaponPos.Pos)
		TEMP_CEffectData:SetColor(0)
		TEMP_CEffectData:SetEntity(self)
		TEMP_CEffectData:SetAngles(TEMP_WeaponPos.Ang)
		util.Effect( "MuzzleFlash", TEMP_CEffectData, false )
		
		self:Timer(0.5,self.EmitSound,"KFMod.HuskGun.Uncharge")
	end)
	self:PlaySequenceAndMove("s_rangedhuskgun_npc",1,self.FaceEnemy)
	self:SetCooldown("KFNextRAttack"..self.PrintName,(math.random(5)*2)*(self:IsPossessed() and 0 or 1))
end
function ENT:KFRun()return false end
function ENT:CustomThink()
	if(IsValid(self:GetEnemy())&&self:GetEnemy()!=NULL) and self:GetSequenceName(self:GetSequence())=="s_rangedhuskgun_npc" then
		local TEMP_Dif = (self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter())-(self:GetPos()+Vector(0,0,30))
		local TEMP_AngP = TEMP_Dif:Angle().Pitch
		local TEMP_AngY = TEMP_Dif:Angle().Yaw-self:GetAngles().Yaw
		local TEMP_AngP = math.NormalizeAngle(TEMP_AngP)*2.1
		
		self:SetPoseParameter("aim_pitch_npc",TEMP_AngP)
		self:SetPoseParameter("aim_yaw",math.Clamp(TEMP_AngY,-30,30))
	end
end
end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
