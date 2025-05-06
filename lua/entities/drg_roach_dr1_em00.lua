if not DrGBase then return end
ENT.Base = "drgbase_nextbot"

ENT.BloodColor = BLOOD_COLOR_RED ENT.RagdollOnDeath = false ENT.Omniscient = false ENT.SpotDuration = 60 ENT.RangeAttackRange = 128 ENT.ReachEnemyRange = 30 ENT.UseWalkframes = true ENT.ClimbLedges = false ENT.ClimbProps = false ENT.ClimbLadders = false ENT.ClimbLaddersUp = false ENT.ClimbLaddersDown = false ENT.PossessionEnabled = true ENT.PossessionPrompt = true ENT.PossessionCrosshair = true ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.EyeBone = "10:10"

-- Editables --
ENT.PrintName = "Zombie"
ENT.Category = "Dead Rising (PC)"
ENT.Models = {"models/roach/dr1/em00.mdl"}
ENT.CollisionBounds = Vector(15, 15, 70)
ENT.SpawnHealth = 100
ENT.MeleeAttackRange = 50
ENT.Factions = {"DR1_ZOMBIE"}
ENT.PossessionViews = {{offset = Vector(0, 30, 10),distance = 100,eyepos=true}}
ENT.PossessionBinds = {
	[IN_ATTACK] = {{coroutine = true,onkeydown = function(self)
		if math.random(2)==1 then
			self:EmitSound("roach/dr1/zombie/v1/att"..math.random(8)..".mp3",100,100,1,CHAN_VOICE)
		else
			self:EmitSound("roach/dr1/zombie/v"..math.random(2,3).."/att"..math.random(8)..".mp3",100,100,1,CHAN_VOICE)
		end
		self:PlaySequenceAndMove("att"..math.random(13),1,self.FaceEnemy)
	end}},
	[IN_ATTACK2] = {{coroutine = true,onkeydown = function(self)
		if math.random(2)==1 then
			self:EmitSound("roach/dr1/zombie/v1/att"..math.random(8)..".mp3",100,100,1,CHAN_VOICE)
		else
			self:EmitSound("roach/dr1/zombie/v"..math.random(2,3).."/att"..math.random(8)..".mp3",100,100,1,CHAN_VOICE)
		end
		if self:GetBodygroup(0)==7 then
			self:PlaySequenceAndMove("att_shoot_1",1,self.PossessionFaceForward)
			self:PlaySequenceAndMove("att_shoot_2",1,self.PossessionFaceForward)
			self:PlaySequenceAndMove("att_shoot_3",1,self.PossessionFaceForward)
		else
			self:PlaySequenceAndMove("att_ranged",1,self.PossessionFaceForward)
		end
	end}},
	[IN_JUMP] = {{coroutine = true,onkeydown = function(self)self:Jump(350)end}},
	[IN_USE] = {{coroutine = true,onkeydown = function(self)if self:GetCooldown(self:GetClass().."_Use") <= 0 then for k,door in pairs(ents.FindInSphere(self:LocalToWorld(Vector(0,0,70)), 50)) do if IsValid(door) and door:GetClass() == "prop_door_rotating" then door:Fire("openawayfrom",self:GetName()) elseif IsValid(door) and string.find(door:GetClass(),"door")  and door:GetClass() != "prop_door_rotating" then door:Fire("open")end if IsValid(door) and string.find(door:GetClass(),"button") then door:Fire("press") end end self:SetCooldown(self:GetClass().."_Use",0.5)end end}},
	[IN_ATTACK3] = {{coroutine = true,onkeydown = function(self)self:Suicide()end}},
}
ENT.OnIdleSounds = {
	"roach/dr1/zombie/v1/idle1.mp3",
	"roach/dr1/zombie/v1/idle2.mp3",
	"roach/dr1/zombie/v1/idle3.mp3",
	"roach/dr1/zombie/v1/idle4.mp3",
	"roach/dr1/zombie/v1/idle5.mp3",
	"roach/dr1/zombie/v1/idle6.mp3",
	"roach/dr1/zombie/v1/idle7.mp3",
	"roach/dr1/zombie/v1/idle8.mp3",
}
ENT.IdleSoundDelay = 10
ENT.SightDistance = 512

if SERVER then
ENT.JumpAnimation = "glide"

ENT.ClimbLedges = true
ENT.ClimbLedgesMaxHeight = 1000
ENT.LedgeDetectionDistance = 30
ENT.ClimbProps = true
ENT.ClimbLadders = true
ENT.LaddersUpDistance = 10
ENT.ClimbSpeed = 600
ENT.ClimbUpAnimation = "glide"
ENT.ClimbAnimRate = 1
ENT.ClimbOffset = Vector(-10, 0, 10)
function ENT:WhileClimbing(ladder, left)
	self:ResetSequence("glide")
	if left <=75 then return true end 
end
function ENT:OnStopClimbing()
    self:PlaySequenceAndMoveAbsolute("climb")
end
function ENT:OnSpawn()
	self.Ready = true
	self.IsIdle = true
end
function ENT:OnLandOnGround()
	if self.Flinching and not self.Ready then
		self:CICO(function(self)
			if self.Ready then return end
			self.Ready = true
			self.FellBackwards = true
			local m = math.random(2)
			self:PlaySequenceAndMove("flinch_dead_"..(m==1 and "b" or "f").."5",math.Rand(0.5,1.2))
			if not self:IsDead() then
				self.JumpAnimation = "glide"
				self:PlaySequenceAndMove("getup_"..(m==1 and "b" or "f")..""..math.random(3),math.Rand(0.5,0.9))
				self:PlaySequenceAndMove("getup_2"..math.random(2),math.Rand(0.5,0.9))
				if self.OldCollisionGroup then
					self:SetCollisionGroup(self.OldCollisionGroup)
				end
			end
			self.Flinching = false
		end)
	else
		local enemy = self:GetClosestEnemy()if self:IsInRange(enemy,120) then return end --[[ stupid fucking vj base workaround ]] 
		self:ReactInCoroutine(self.PlaySequenceAndMove,"land")
	end
end
function ENT:CustomInitialize()
	for k,v in pairs(self:GetSequenceList()) do if string.find(v,"att") and not string.find(v,"grab") then self:SetAttack(v,true)end end
	self:SetDefaultRelationship(D_HT)
	
	local hp = self.SpawnHealth
	self:SetHealth(hp)
	self:SetHP(hp)

	local outfitrng = math.random(11)
	if outfitrng==11 then -- cop
		self:SetBodygroup(0,7)
		self:SetBodygroup(1,10)
		self:SetBodygroup(2,9)
		self:SetBodygroup(4,7)
	elseif outfitrng==10 then -- thug
		self:SetBodygroup(1,11)
		self:SetBodygroup(2,10)
		self:SetBodygroup(4,8)
	elseif outfitrng>4 and outfitrng<10 then -- fat
		self:SetBodygroup(0,6)
		self:SetBodygroup(1,math.random(5,9))
		self:SetBodygroup(2,math.random(5,8))
		self:SetBodygroup(4,math.random(4,6))
	else
		if math.random(3)==2 then self:SetBodygroup(0,math.random(5)) end
		self:SetBodygroup(1,math.random(0,4))
		self:SetBodygroup(2,math.random(0,4))
		self:SetBodygroup(4,math.random(0,3))
	end
	
	self.IdleAnimation = "idle"..math.random(19)
	self.WalkAnimation = "walk"..math.random(37)
	self.RunAnimation = "run"..math.random(9)

	self:SetCooldown("CHRangedAtk",10)
	self.BulletAttachment = ents.Create("drg_roach_specops_bulletpos")
	self.BulletAttachment:Spawn()
	self.BulletAttachment:SetNoDraw(true)
	self.BulletAttachment:SetNotSolid(true)
	self.BulletAttachment:SetParent(self)
	self.BulletAttachment:Fire("setparentattachment","muzzle")
end
function ENT:FireBullet(damage)
	local shootPos = self.BulletAttachment:GetPos() + self:GetForward()*5
	local ep = shootPos + self:GetAimVector()*99999
	if self:HasEnemy() then ep = self:GetEnemy():WorldSpaceCenter() end
	if self:IsPossessed() then ep = self:PossessorTrace().HitPos end
	local tr = util.DrG_TraceHull({
		start = shootPos, endpos = ep,
		mins = Vector(-1, -1, -1), maxs = Vector(1, 1, 1),
		filter = {self, self.BulletAttachment, self:GetPossessor()}
	})

	local bullet = {}
	bullet.Num = 1
	bullet.Src = shootPos
	bullet.Dir = tr.Normal
	bullet.Spread = Vector(0.05, 0.05, 0)
	bullet.Tracer	= 1
	bullet.Force = damage/10
	bullet.Damage	= damage
	bullet.AmmoType = "AirboatGun"
	bullet.Filter = {self, self.BulletAttachment, self:GetPossessor()}
	bullet.Callback = function(ent,tr,dmg)dmg:SetAttacker(self)dmg:SetInflictor(self)end
	self.BulletAttachment:FireBullets(bullet)

	ParticleEffectAttach("doi_muzzleflash_garand_3p",PATTACH_POINT_FOLLOW,self,2)
	local fx = EffectData()
		fx:SetEntity(self)
		fx:SetAttachment(3)
		fx:SetOrigin(self:GetAttachment(3).Pos)
		fx:SetAngles(self:GetAttachment(3).Ang + Angle(-90,0,0))
	util.Effect("ShellEject",fx,false,true)
end
function ENT:HandleAnimEvent(a,b,c,d,e)
	if e == "down" then 
		if self:GetBodygroup(4)==7 then
			self:EmitSound("roach/dr1/zombie/down_cop"..math.random(3)..".mp3")
		elseif self:GetBodygroup(4)==8 then
			self:EmitSound("roach/dr1/zombie/down_thug"..math.random(3)..".mp3")
		elseif self:GetBodygroup(4)>3 and self:GetBodygroup(4)<7 then
			self:EmitSound("roach/dr1/zombie/down_fat"..math.random(3)..".mp3")
		else
			self:EmitSound("roach/dr1/zombie/down"..math.random(5)..".mp3")
		end
	elseif e == "down_knee" then
		if self:GetBodygroup(4)==8 then
			self:EmitSound("roach/dr1/zombie/down_knee_thug"..math.random(3)..".mp3")
		elseif self:GetBodygroup(4)>3 and self:GetBodygroup(4)<8 then
			self:EmitSound("roach/dr1/zombie/down_knee_fat"..math.random(3)..".mp3")
		else
			self:EmitSound("roach/dr1/zombie/down"..math.random(3)..".mp3")
		end
	elseif e == "down_bulldog" then
		self:EmitSound("roach/dr1/larry/down.wav")
		self:EmitSound("roach/dr1/zombie/gib.mp3")
		self:SetHeadless(true)
		for i=1,5 do self:Timer(0.2*i,function()ParticleEffectAttach("blood_advisor_puncture_withdraw",PATTACH_POINT_FOLLOW,self,4)end)end
	end

	if e == "fire_ranged" then
		self:EmitSound("roach/drdr/em45/Play_OM0079_034_SE_OM_OWN"..math.random(6,7).."_EV.mp3",100)
		self:FireBullet(math.random(2)*5)
	elseif e=="shock_blast" then
		self:EmitSound("ambient/levels/labs/electric_explosion1.wav")
		ParticleEffect("hunter_projectile_explosion_1",self:WorldSpaceCenter(),Angle(0,0,0),nil)
	end

	local evt = string.Explode(" ", e, false)
	if evt[1] == "fire" then
		self:Attack({
			damage = (evt[2]=="8" and 10 or 30),
			type = (evt[2]=="8" and 8 or (math.random(2)==2 and evt[2] or 4)),
			viewpunch = Angle(20, math.random(-10, 10), 0),
		}, 
		function(self, hit)
			if #hit > 0 then 
				if not self:IsPlayingSequence("att_ranged") then
					self:EmitSound("roach/dr1/zombie/att_hit"..math.random(3)..".mp3",100)
				end
			end
		end)
		if evt[2] == "8" then
			self:EmitSound("roach/dr1/zombie/vomit"..math.random(2)..".mp3",100)
			self:EmitSound("roach/dr1/zombie/sizzle.mp3",100)
			ParticleEffectAttach("vomit_barnacle",PATTACH_POINT_FOLLOW,self,4)
		else
			self:EmitSound("roach/dr1/zombie/att_miss"..math.random(3)..".mp3",100)
		end
	end
end
function ENT:OnMeleeAttack(enemy)
	if math.random(2)==1 then
		self:EmitSound("roach/dr1/zombie/v1/att"..math.random(8)..".mp3",100,100,1,CHAN_VOICE)
	else
		self:EmitSound("roach/dr1/zombie/v"..math.random(2,3).."/att"..math.random(8)..".mp3",100,100,1,CHAN_VOICE)
	end
	
	if math.random(8)==3 then
		self:PlaySequenceAndMove("att_ranged",1,function()self:FaceEnemy()if not self:IsOnGround() then return true end end)
		return
	end
	self:PlaySequenceAndMove("att"..math.random(13),1,function()self:FaceEnemy()if not self:IsOnGround() then return true end end)
end
function ENT:OnRangeAttack(enemy)
	if self:GetBodygroup(0)<7 then return end -- only shoot if we're holding a pistol
	if self:GetCooldown("CHRangedAtk")>0 then return end
	self:SetCooldown("CHRangedAtk",math.random(5,15))

	self:PlaySequenceAndMove("att_shoot_1",1,self.FaceEnemy)
	local mrand = math.random(4)
	self:PlaySequenceAndMove("att_shoot_2",1,function(self,cycle)
		self:FaceEnemy()
		if mrand==1 and cycle>0.2 then return true end
	end)
	if mrand==1 then
		self:PlaySequenceAndMove("flinch_blast_b"..math.random(3))
		self:PlaySequenceAndMove("getup_b"..math.random(3))
		self:PlaySequenceAndMove("getup_2"..math.random(2))
	else
		self:PlaySequenceAndMove("att_shoot_3",1,self.PossessionFaceForward)
	end
end
ENT.DamageMultiplier = 3
function ENT:OnTakeDamage(dmg, dir, tr)
	dmg:ScaleDamage(self.DamageMultiplier*(self.DamageMultiplier+math.random()))
	if self:IsDead() and not self.Flinching and not self:GetHeadless() then
		self.Flinching = true
		self:CICO(function(self)
			self:PlaySequenceAndMove("flinch_dead"..(not self.FellBackwards and "f" or "b")..""..math.random(2,5))
			self.Flinching = false
		end)
	elseif not self:IsDead() then
		self:SpotEntity(dmg:GetAttacker())
		self:SetHP(math.max(self:Health()-dmg:GetDamage(),0))
		if self.Flinching then return end
		local att = dmg:GetAttacker()
		if dmg:IsDamageType(DMG_BLAST) then
			if ((dmg:GetDamage()>50) or (math.random(4)==3)) and not dmg:IsDamageType(DMG_CRUSH) and not self.Suicidal then
				self.Flinching = true
				self.Ready = false
				self.OldCollisionGroup = self:GetCollisionGroup()
				self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				self:FaceInstant(dmg:GetDamagePosition() + Vector(math.random(-45,45),math.random(-45,45),0))
				if math.random(2)==1 then
					self:EmitSound("roach/dr1/zombie/v2/pain"..math.random(7)..".mp3",100,100,1,CHAN_VOICE)
				else
					self:EmitSound("roach/dr1/zombie/v"..(math.random(2)==1 and 1 or 3).."/pain"..math.random(4)..".mp3",100,100,1,CHAN_VOICE)
				end
				local mr = math.random(2)
				self.JumpAnimation = "flinch_drill"..mr
				local dir = dmg:GetDamageForce()
				if dir:Length() < 150 then
					dir = dir:GetNormalized() * 150
					dir = dir + Vector(0,0,600)
				elseif dir:Length() > 900 then
					dir = dir:GetNormalized() * 900
				end
				
				self:Jump(10)
				self:SetVelocity(dir+Vector(math.random(-2,2)*250,math.random(-2,2)*250,0))
			else
				self:FaceInstant(dmg:GetDamagePosition())
				self.Flinching = true
				self:CICO(function(self)
					if math.random(2)==1 then
						self:EmitSound("roach/dr1/zombie/v2/pain"..math.random(7)..".mp3",100,100,1,CHAN_VOICE)
					else
						self:EmitSound("roach/dr1/zombie/v"..(math.random(2)==1 and 1 or 3).."/pain"..math.random(4)..".mp3",100,100,1,CHAN_VOICE)
					end
					local bool = false
					self:PlaySequenceAndMove("flinch_blast_b"..math.random(8,9),{multiply=Vector(1.2,1.2,1.2),rate=math.Rand(1,1.3)},function(self)
						local tr = util.DrG_TraceHull({
							start = self:WorldSpaceCenter(),
							endpos = self:WorldSpaceCenter() + self:GetForward()*-64,
							mins = Vector(-12, -12, -12),
							maxs = Vector(12, 12, 12),
							filter = self
						})
						if tr.Hit then bool=true return true end
					end)
					if bool then
						self:TakeDamage(self.SpawnHealth/10,att)
						self:PlaySequenceAndMove("flinch_blast_f"..math.random(2),math.Rand(0.7,1))
						self:PlaySequenceAndMove("getup_f"..math.random(3),math.Rand(0.7,1))
					else
						self:PlaySequenceAndMove("getup_b"..math.random(3),math.Rand(0.7,1))
					end
					self.Flinching = false
					self:PlaySequenceAndMove("getup_2"..math.random(2),math.Rand(0.7,1))
				end)
			end
		elseif dmg:IsDamageType(DMG_CRUSH) then
			self.Flinching = true
			self:CICO(function(self)
				local m = math.random(4)
				if math.random(2)==1 then
					self:EmitSound("roach/dr1/zombie/v2/pain"..math.random(7)..".mp3",100,100,1,CHAN_VOICE)
				else
					self:EmitSound("roach/dr1/zombie/v"..(math.random(2)==1 and 1 or 3).."/pain"..math.random(4)..".mp3",100,100,1,CHAN_VOICE)
				end
				self:PlaySequenceAndMove("flinch_crush"..m,math.Rand(0.7,1),function()if not self:IsOnGround() then return true end end)
				self:PlaySequenceAndMove("getup_f"..math.min(m,3),math.Rand(0.7,1),function()if not self:IsOnGround() then return true end end)
				self:PlaySequenceAndMove("getup_2"..math.random(2),function()if not self:IsOnGround() then return true end end)
				self.Flinching = false
			end)
		elseif dmg:IsDamageType(DMG_CLUB) then
			self.Flinching = true
			self:CICO(function(self)
				local m = math.random(3)
				if math.random(2)==1 then
					self:EmitSound("roach/dr1/zombie/v2/pain"..math.random(7)..".mp3",100,100,1,CHAN_VOICE)
				else
					self:EmitSound("roach/dr1/zombie/v"..(math.random(2)==1 and 1 or 3).."/pain"..math.random(4)..".mp3",100,100,1,CHAN_VOICE)
				end
				self:PlaySequenceAndMove("flinch_club"..m.."_1",math.Rand(0.7,1),function()if not self:IsOnGround() then return true end end)
				self:PlaySequenceAndMove("flinch_club"..(m==1 and 3 or m).."_2",math.Rand(0.7,1),function()if not self:IsOnGround() then return true end end)
				self.Flinching = false
			end)
		elseif (dmg:GetDamage() >= 4 and math.random(5) == 3) then
			self.Flinching = true
			self:CICO(function(self)
				if math.random(2)==1 then
					self:EmitSound("roach/dr1/zombie/v2/pain"..math.random(7)..".mp3",100,100,1,CHAN_VOICE)
				else
					self:EmitSound("roach/dr1/zombie/v"..(math.random(2)==1 and 1 or 3).."/pain"..math.random(4)..".mp3",100,100,1,CHAN_VOICE)
				end
				self.Flinching = false
				self:PlaySequenceAndMove("flinch"..math.random(4),math.Rand(0.7,1),function()if not self:IsOnGround() then return true end end)
			end)
		end
		self:SpotEntity(att)
	end
end
function ENT:OnDeath(dmg, hitgroup) 
	self.OnIdleSounds = {}
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	if string.find(self.JumpAnimation,"flinch_drill") then self:PauseCoroutine(false) return end -- don't bother running other death animation code as it is handled elsewhere
	self.FellBackwards = true
	if math.random(2)==1 then
		self:EmitSound("roach/dr1/zombie/v2/death"..math.random(9)..".mp3",100,100,1,CHAN_VOICE)
	else
		self:EmitSound("roach/dr1/zombie/v"..(math.random(2)==1 and 1 or 3).."/death"..math.random(3)..".mp3",100,100,1,CHAN_VOICE)
	end

	if (dmg:IsDamageType(DMG_BLAST) or dmg:IsDamageType(DMG_CRUSH)) and not dmg:IsDamageType(DMG_SHOCK) then
		self.Flinching = false
		self:FaceInstant(dmg:GetDamagePosition())
		if dmg:IsDamageType(DMG_BULLET) or dmg:IsDamageType(DMG_AIRBOAT) or dmg:IsDamageType(DMG_SLASH) then 
			self:EmitSound("roach/dr1/zombie/gib.mp3",90)
			self:EmitSound("roach/dr1/brad/att_decapitate.mp3",80)
			self:SetHeadless(true)
			for i=1,5 do self:Timer(0.2*i,function()ParticleEffectAttach("blood_advisor_puncture_withdraw",PATTACH_POINT_FOLLOW,self,4)end)end
		end
		local bool = false
		self:PlaySequenceAndMove("flinch_blast_b"..math.random(10),{multiply=Vector(1.2,1.2,1.2),rate=math.Rand(0.7,1)},function(self)
			local tr = util.DrG_TraceHull({
				start = self:WorldSpaceCenter(),
				endpos = self:WorldSpaceCenter() + self:GetForward()*-64,
				mins = Vector(-12, -12, -12),
				maxs = Vector(12, 12, 12),
				filter = self
			})
			if tr.Hit then bool=true return true end
		end)
		if bool then
			self.FellBackwards = false
			self:PlaySequenceAndMove("flinch_blast_f"..math.random(2),math.Rand(0.7,1))
		end
	elseif dmg:IsDamageType(DMG_SHOCK) then
		local fx = EffectData()
		fx:SetEntity(self)
		fx:SetOrigin(self:LocalToWorld(Vector(0,0,50)))
		fx:SetStart(self:LocalToWorld(Vector(0,0,50)))
		fx:SetScale(1)
		fx:SetMagnitude(10)
		for i=0,29 do
			self:Timer(0.2*i,function()
				if !IsValid(self) then return end
				self:EmitSound("ambient/energy/spark"..math.random(1,6)..".wav")
				util.Effect("teslahitboxes",fx)
			end)
		end
		self:PlaySequenceAndMove("death_shock"..math.random(4),math.Rand(1,1.3))
	elseif dmg:IsDamageType(DMG_SLASH) and math.random(2)==1 then
		self:EmitSound("roach/dr1/zombie/gib.mp3",90)
		self:EmitSound("roach/dr1/brad/att_decapitate.mp3",80)
		self:SetHeadless(true)
		for i=1,5 do self:Timer(0.2*i,function()ParticleEffectAttach("blood_advisor_puncture_withdraw",PATTACH_POINT_FOLLOW,self,4)end)end
		self:PlaySequenceAndMove("death_headshot"..math.random(4),math.Rand(0.7,1))
	else
		self:PlaySequenceAndMove("flinch_blast_b"..math.random(7),math.Rand(0.7,1)) 
	end
	self:PauseCoroutine(false)
end
function ENT:OnUpdateAnimation()
	if !self:IsOnGround() and string.find(self.JumpAnimation,"drill") then return self.JumpAnimation, 0.75 end
	if !self.Ready or self:IsDead() or self:IsDown() then
		if #self.OnIdleSounds>0 then 
			self.OnIdleSounds = {}
		end
	return end
	if !self:IsOnGround() then return self.JumpAnimation, 0.75
	elseif self:IsRunning() then return self.RunAnimation, 1.25
	elseif self:IsMoving() then return self.WalkAnimation, 1
	else return self.IdleAnimation, self.IdleAnimRate end
end
function ENT:CICO(callback)
	local oldThread = self.BehaveThread
	self.BehaveThread = coroutine.create(function()
		callback(self)
		self.BehaveThread = oldThread
	end)
end
function ENT:ShouldRun()return false end
elseif CLIENT then
	ENT.HUDMat_Main = Material("hud/dr1/hud_main_hp.png", "smooth unlitgeneric")
	ENT.HUDMat_Block = Material("hud/dr1/hud_hp_block.png", "smooth unlitgeneric")
	ENT.HUDMat_Percent = Material("hud/dr1/hud_hp_percent.png", "smooth unlitgeneric")
	function ENT:PossessionHUD()
		local hp = math.Round(self:GetHP())
		local hpmax = self.SpawnHealth
		render.SetMaterial(self.HUDMat_Main)
		render.DrawScreenQuadEx(
			0,0,
			self.HUDMat_Main:Width()*1.5,
			self.HUDMat_Main:Height()*1.5
		)
		
		render.SetMaterial(self.HUDMat_Block)
		for i=0,math.ceil((hp/(100))-1) do
			render.DrawScreenQuadEx(
				200+(42*i),
				50,
				self.HUDMat_Block:Width()*1.5,
				self.HUDMat_Block:Height()*1.5
			)
		end
		render.SetMaterial(self.HUDMat_Percent)
		local widthscale = (hp==hpmax and 10 or ((hp%(100))/100))
		render.DrawScreenQuadEx(
			190,
			113,
			((self.HUDMat_Percent:Width()*0.6)*widthscale),
			self.HUDMat_Percent:Height()*0.6
		)
	end
	function ENT:CustomDraw()
		if self:GetHeadless() then
			self:SetBodygroup(3,1)
			self:ManipulateBoneScale(self:LookupBone("10:10"),Vector(0.01,0.01,0.01))
			self:ManipulateBoneScale(self:LookupBone("10:10_s"),Vector(0.01,0.01,0.01))
			self:ManipulateBoneScale(self:LookupBone("19:19"),Vector(0.01,0.01,0.01))
			self:ManipulateBoneScale(self:LookupBone("21:21"),Vector(0.01,0.01,0.01))
			self:ManipulateBoneScale(self:LookupBone("22:22"),Vector(0.01,0.01,0.01))

			self:ManipulateBoneScale(self:LookupBone("bone0"),Vector(1.05,1.85,1.05))
			self:ManipulateBoneAngles(self:LookupBone("bone0"),Angle(180,0,170))
			self:ManipulateBonePosition(self:LookupBone("bone0"),Vector(0,-3,-3))
		end
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "HP")
	self:NetworkVar("Bool", 1, "Headless")
end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)
------------------------------------------------------------------------
local ENT3 = {}
local sillyvar = string.sub(ENT.Folder,10)
ENT3.Base = sillyvar
-- ENT3.Omniscient = true
ENT3.OnIdleSounds = {
	"roach/dr1/zombie/v2/idle1.mp3",
	"roach/dr1/zombie/v2/idle2.mp3",
	"roach/dr1/zombie/v2/idle3.mp3",
	"roach/dr1/zombie/v2/idle5.mp3",
}
ENT3.IdleSoundDelay = 2
ENT.SightDistance = 8192

if SERVER then
ENT3.DamageMultiplier = 0.5
function ENT3:ShouldRun()return true end
function ENT3:OnMeleeAttack(enemy)
	if math.random(2)==1 then
		self:EmitSound("roach/dr1/zombie/v1/att"..math.random(8)..".mp3",100,100,1,CHAN_VOICE)
	else
		self:EmitSound("roach/dr1/zombie/v"..math.random(2,3).."/att"..math.random(8)..".mp3",100,100,1,CHAN_VOICE)
	end

	self:PlaySequenceAndMove("att"..math.random(13),1.5,function()self:FaceEnemy()if not self:IsOnGround() then return true end end)
end
end

scripted_ents.Register(ENT3, sillyvar.."f")

local nextbot2 = {
	Name = "Nightmare Zombie",
	Class = (sillyvar.."f"),
	Category = "Dead Rising (PC)"
}
list.Set("NPC", sillyvar.."f", nextbot2)
list.Set("DrGBaseNextbots", sillyvar.."f", nextbot2)
 