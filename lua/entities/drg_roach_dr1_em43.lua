if not DrGBase then return end
ENT.Base = "drgbase_nextbot"

ENT.BloodColor = BLOOD_COLOR_RED ENT.RagdollOnDeath = false ENT.Omniscient = false ENT.SpotDuration = 60 ENT.RangeAttackRange = 128 ENT.ReachEnemyRange = 30 ENT.UseWalkframes = true ENT.ClimbLedges = false ENT.ClimbProps = false ENT.ClimbLadders = false ENT.ClimbLaddersUp = false ENT.ClimbLaddersDown = false ENT.PossessionEnabled = true ENT.PossessionPrompt = true ENT.PossessionCrosshair = true ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.EyeBone = "10:10"

-- Editables --
ENT.PrintName = "Cultist"
ENT.Category = "Dead Rising (PC)"
ENT.Models = {"models/roach/dr1/em43.mdl"}
ENT.CollisionBounds = Vector(15, 15, 70)
ENT.SpawnHealth = 100
ENT.MeleeAttackRange = 50
ENT.Factions = {"DR1_PSYCHO_SEAN"}
ENT.PossessionViews = {{offset = Vector(0, 30, 10),distance = 100,eyepos=true}}
ENT.PossessionBinds = {
	[IN_ATTACK] = {{coroutine = true,onkeydown = function(self)
		if self.IsIdle or not self.Ready then 
			self:SetBodygroup(1,(self.Suicidal and 2 or 1))
			self.Ready = true
			self.IsIdle = false
			self.OnIdleSounds = {}
		end
		if self.Suicidal then 
			self:PlaySequenceAndMove("suicide_1",{multiply=Vector(3,3,3)},self.PossessionFaceForward)
			self:PlaySequenceAndMove("suicide_2",{multiply=Vector(3,3,3)},self.PossessionFaceForward)
			self:PlaySequenceAndMove("suicide_3",{multiply=Vector(3,3,3)},self.PossessionFaceForward)
		else
			if math.random(3)==3 then
				if self:GetBodygroup(1)==0 then self:Timer(math.random()/5,self.EmitSound,"roach/dr1/cultist/vm_att"..math.random(5)..".mp3",100,100,1,CHAN_VOICE) end
			end
			self:PlaySequenceAndMove("att"..math.random(3),1,self.FaceEnemy)
		end
	end}},
	[IN_ATTACK2] = {{coroutine = true,onkeydown = function(self)
		if self.IsIdle or not self.Ready then 
			self:SetBodygroup(1,(self.Suicidal and 2 or 1))
			self.Ready = true
			self.IsIdle = false
			self.OnIdleSounds = {}
		end
		if self.Suicidal then return end
		if self:GetBodygroup(1)==0 then self:Timer(math.random()/5,self.EmitSound,"roach/dr1/cultist/vm_att"..math.random(5)..".mp3",100,100,1,CHAN_VOICE) end
		self:PlaySequenceAndMove("att_charge_1",1,self.PossessionFaceForward)
		repeat
			self:PlaySequenceAndMove("att_charge_2",1.25,self.PossessionFaceForward)
		until not self:GetPossessor():KeyDown(IN_ATTACK2)
		self:PlaySequenceAndMove("att_charge_3",1,self.PossessionFaceForward)
	end}},
	[IN_JUMP] = {{coroutine = true,onkeydown = function(self)self:Jump(350)end}},
	[IN_USE] = {{coroutine = true,onkeydown = function(self)if self:GetCooldown(self:GetClass().."_Use") <= 0 then for k,door in pairs(ents.FindInSphere(self:LocalToWorld(Vector(0,0,70)), 50)) do if IsValid(door) and door:GetClass() == "prop_door_rotating" then door:Fire("openawayfrom",self:GetName()) elseif IsValid(door) and string.find(door:GetClass(),"door")  and door:GetClass() != "prop_door_rotating" then door:Fire("open")end if IsValid(door) and string.find(door:GetClass(),"button") then door:Fire("press") end end self:SetCooldown(self:GetClass().."_Use",0.5)end end}},
	[IN_ATTACK3] = {{coroutine = true,onkeydown = function(self)self:Suicide()end}},
	[IN_RELOAD] = {{coroutine = true, onkeydown = function(self)
		if self.Suicidal then return end
		if self.IsIdle then
			self.IsIdle = false
			self:EmitSound("roach/dr1/cultist/v"..(self:GetBodygroup(1)==0 and "m" or "f").."_alert"..math.random(4)..".mp3",100,100,1,CHAN_VOICE)
			self:PlaySequenceAndMove("knife_equip",1,self.FaceEnemy)
			self.Ready = true
			return
		end
		self:SetBodygroup(0,0)
		self.IsIdle = true
		self.Ready = false
		self:PauseCoroutine(0.2)
	end}}
}
ENT.AllyDamageTolerance = 0 -- this variable is so poorly named, having 0 tolerance makes you *not* become hostile to allies due to friendly fire???

if SERVER then
ENT.IdleAnimation = "idle"
ENT.WalkAnimation = "walk"
ENT.RunAnimation = "run"
ENT.JumpAnimation = "glide"

ENT.ClimbLedges = true
ENT.ClimbLedgesMaxHeight = 1000
ENT.LedgeDetectionDistance = 30
ENT.ClimbProps = true
ENT.ClimbLadders = true
ENT.LaddersUpDistance = 10
ENT.ClimbSpeed = 600
ENT.ClimbUpAnimation = "climb_1"
ENT.ClimbAnimRate = 1
ENT.ClimbOffset = Vector(-10, 0, 10)
function ENT:OnContact(ent)
	if string.find( ent:GetClass():lower(), "prop_*" ) or (ent:GetClass() == "func_physbox") or (ent:GetClass() == "func_breakable") or (ent:GetClass() == "func_breakable_surf") then
		if IsValid(ent) then
			local velocity = math.Round(self:GetVelocity():Length())*2
			local forwardvel = Vector(self:GetForward().x,self:GetForward().y,self:GetForward().z)*velocity
				
			if IsValid(ent:GetPhysicsObject()) then
				ent:GetPhysicsObject():EnableMotion( true )
				ent:GetPhysicsObject():SetVelocity(forwardvel)
				ent:TakeDamage( 100, self,self )
			end
		end
	end
	if ent:GetClass() == "prop_door_rotating" or ent:GetClass() == "func_door_rotating" or ent:GetClass() == "func_door" then
		if IsValid(ent) then
			ent:Fire('Open')
		end
	end
end
function ENT:WhileClimbing(ladder, left)
	self:ResetSequence("climb_1")
	if left <=75 then return true end 
end
function ENT:OnStopClimbing()
    self:PlaySequenceAndMoveAbsolute("climb_2")
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
			self:PlaySequenceAndMove("flinch_blast_2",math.Rand(0.5,1.2))
			self.JumpAnimation = "glide"
			if not self:IsDead() then
				self:PlaySequenceAndMove("getup2",math.Rand(0.5,0.9))
				self:PlaySequenceAndMove("getup_2",math.Rand(0.5,0.9))
			end
			if self.OldCollisionGroup then
				self:SetCollisionGroup(self.OldCollisionGroup)
			end
			self.Flinching = false
		end)
	else
		if self.Suicidal then
			self:Suicide()
			return
		end
		local enemy = self:GetClosestEnemy()if self:IsInRange(enemy,120) then return end --[[ stupid fucking vj base workaround ]] 
		self:ReactInCoroutine(self.PlaySequenceAndMove,"land")
	end
end
function ENT:CustomInitialize()
	for k,v in pairs(self:GetSequenceList()) do if string.find(v,"att") and not string.find(v,"grab") then self:SetAttack(v,true)end end
	self:SetDefaultRelationship(D_HT)
	
	self:SetHP(self.SpawnHealth)
	self:SetBodygroup(1,math.random(0,1))
end
function ENT:HandleAnimEvent(a,b,c,d,e)
	if e == "down" then self:EmitSound("roach/drdr/em43/Play_EMB43_002_SE_DOWN_M_EV"..math.random(2)..".mp3")
	elseif e == "down_knee" then self:EmitSound("roach/drdr/em43/Play_EMB43_002_SE_DOWN_M_EV"..math.random(2)..".mp3")
	end

	if e == "fire_gas" then
		ParticleEffect("drg_smokescreen", self:GetAttachment(2).Pos, self:GetAngles(),self)
		self:EmitSound("roach/drdr/em43/Play_EMB43_062_SE_PL_GIANTSWING_M_EV"..math.random(3)..".mp3",100)
		
		self:Timer(0.25,self.StopParticles)
		self:Timer(1,function()
			self:EmitSound("roach/dr1/cultist/v"..(self:GetBodygroup(1)==0 and "m" or "f").."_mist.mp3",100,100,1,CHAN_VOICE)
			for k,v in pairs(ents.FindInSphere(self:GetPos(),100)) do
				if (not v:IsPlayer() and not v:IsNPC() and not v:IsNextBot()) 
				or v == self or (v:IsPlayer() and v:DrG_IsPossessing()) then continue end
				if self:GetRelationship(v) != D_LI and self:GetRelationship(v) != D_NU then
				local dmg = DamageInfo()
				dmg:SetAttacker(self)
				if util.IsValidRagdoll(v:GetModel()) then
					local rag = v:DrG_RagdollDeath(dmg)
					rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
					rag:Fire("fadeandremove",1,30)
				else
					dmg:SetDamage(99999)
					v:TakeDamageInfo(dmg)
				end
				end
			end
		end)
	elseif e=="combo" then
		self:CICO(function(self)self:PlaySequenceAndMove("att2_1",1,function()self:FaceEnemy()self:PossessionFaceForward()end)end)
	end

	local evt = string.Explode(" ", e, false)
	if evt[1] == "fire" then
		self:Attack({
			damage = 30,
			type = (math.random(5)==2 and evt[2] or 4),
			viewpunch = Angle(20, math.random(-10, 10), 0),
		}, 
		function(self, hit)
			if #hit > 0 then 
				if self:IsPlayingSequence("att1") then
					self:EmitSound("roach/drdr/em53/Play_EMB53_037_SE_EMB53_KCK_HIT_L_EV"..math.random(2)..".mp3",100)
				else
					self:EmitSound("roach/drdr/em44/Play_OM0064_007_SE_OM_WEAPON_HIT_S_EV.mp3",100)
				end
			end
		end)
		self:EmitSound("roach/drdr/em43/Play_EMB43_035_SE_EMB43_PCH_KAZE_L_EV"..math.random(2)..".mp3",100)
	elseif evt[1] == "bodygroup" then
		self:SetBodygroup(0, evt[2])
	end
end
function ENT:OnMeleeAttack(enemy)
	if self.IsIdle or self.Flinching then return end
	if self.Suicidal and not self.Suicided then
		self.Suicided = true
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:PlaySequenceAndMove("suicide_jump",{multiply=Vector(2,2,2)},self.FaceEnemy)
		self.JumpAnimation = "suicide_glide"
		self:Leap(enemy:DrG_RandomPos(100))
		self:SetVelocity(Vector(0,0,250))
	else
		self:SetBodygroup(0,1)
		if math.random(2)==1 then
			if self:GetBodygroup(1)==0 then self:Timer(math.random()/5,self.EmitSound,"roach/dr1/cultist/vm_att"..math.random(5)..".mp3",100,100,1,CHAN_VOICE) end
		end
		
		if math.random(20)<=18 then
			self:PlaySequenceAndMove("att"..math.random(2),1,function()if not self:IsOnGround() then return true end end)
		else
			if self:GetCooldown("Cultist_Mist")<=0 then
				self:PlaySequenceAndMove("att3",1,self.FaceEnemy)
				self:SetCooldown("Cultist_Mist",math.random(2,4)^math.random(2))
			else
				self.Charging = true
				self:PlaySequenceAndMove("att_charge_1",1,function()if not self:IsOnGround() then return true end end)
				for i=0,math.random(5) do
					self:PlaySequenceAndMove("att_charge_2",1,function()
						if i%2 == 1 then self:FaceEnemy() end
						if not self:IsOnGround() then return true end
					end)
				end
				self:PlaySequenceAndMove("att_charge_3",1,function()if not self:IsOnGround() then return true end end)
				self.Charging = false
			end
		end
	end
end
function ENT:OnTakeDamage(dmg, hg)
    self:ScaleHitDamage(dmg,hg)
	if self:IsDead() and not self.Flinching then
		self.Flinching = true
		self:CICO(function(self)
			self:PlaySequenceAndMove("flinch_dead"..(not self.FellBackwards and 1 or 2))
			self.Flinching = false
		end)
	else
		if self.IsIdle then self.IsIdle = false self.Ready = true end
		self:SpotEntity(dmg:GetAttacker())
		if self:Health() < 100/4 and not self.Flinching then
			if not self.Suicidal then
				self.Flinching = true
				self:CICO(function(self)
					self:EmitSound("roach/dr1/cultist/v"..(self:GetBodygroup(1)==0 and "m" or "f").."_suicide"..(self:GetBodygroup(1)==0 and math.random(2) or "")..".mp3",100,100,1,CHAN_VOICE)
					self:SetBodygroup(0,2)
					self.RunAnimation = "suicide_run"
					self.MeleeAttackRange = 300
					self:PlaySequenceAndMove("suicide_start")
					self.Suicidal = true
					self.Flinching = false
				end)
			else
				dmg:ScaleDamage(1000)
			end
		end

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
				self:EmitSound("roach/dr1/cultist/v"..(self:GetBodygroup(1)==0 and "m" or "f").."_pain"..math.random((self:GetBodygroup(1)==0 and 3 or 2))..".mp3",65,100,1,CHAN_VOICE)
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
					self:EmitSound("roach/dr1/cultist/v"..(self:GetBodygroup(1)==0 and "m" or "f").."_pain"..math.random((self:GetBodygroup(1)==0 and 3 or 2))..".mp3",65,100,1,CHAN_VOICE)
					local bool = false
					self:PlaySequenceAndMove("flinch_blast_1",{multiply=Vector(1.2,1.2,1.2),rate=math.Rand(1,1.3)},function(self)
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
						self:TakeDamage(self.SpawnHealth/20,att)
						self:PlaySequenceAndMove("flinch_blast_2_hitwall",math.Rand(1,1.3))
						self:PlaySequenceAndMove("getup1",math.Rand(1,1.3))
					else
						self:PlaySequenceAndMove("flinch_blast_2",math.Rand(1,1.3))
						self:PlaySequenceAndMove("getup2",math.Rand(1,1.3))
					end
					self.Flinching = false
					self:PlaySequenceAndMove("getup_2",math.Rand(1,1.3))
				end)
			end
		elseif dmg:IsDamageType(DMG_CRUSH) then
			self.Flinching = true
			self:CICO(function(self)
				local m = math.random(2)
				self:EmitSound("roach/dr1/cultist/v"..(self:GetBodygroup(1)==0 and "m" or "f").."_pain"..math.random((self:GetBodygroup(1)==0 and 3 or 2))..".mp3",65,100,1,CHAN_VOICE)
				self:PlaySequenceAndMove("flinch_crush"..m,math.Rand(0.7,1),function()if not self:IsOnGround() then return true end end)
				self:PlaySequenceAndMove("getup"..m,math.Rand(0.7,1),function()if not self:IsOnGround() then return true end end)
				self:PlaySequenceAndMove("getup_2",function()if not self:IsOnGround() then return true end end)
				self.Flinching = false
			end)			
		elseif (dmg:GetDamage() >= 4 and math.random(10) == 3) then
			self.Flinching = true
			self:Timer(0.1,self.CICO,function(self)
				self:EmitSound("roach/dr1/cultist/v"..(self:GetBodygroup(1)==0 and "m" or "f").."_pain"..math.random((self:GetBodygroup(1)==0 and 3 or 2))..".mp3",65,100,1,CHAN_VOICE)
				self.Flinching = false
				self:PlaySequenceAndMove("flinch",1,function()if not self:IsOnGround() then return true end end)
			end)
		end
		self:SpotEntity(att)
	end
end
function ENT:OnDeath(dmg, hitgroup) 
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	if self.Flinching and not self.Ready then self:PauseCoroutine(false) return end -- don't bother running other death animation code as it is handled elsewhere
	local m = math.random(4)
	self.FellBackwards = (m==2)
	if math.random(2)==1 then
		self:EmitSound("roach/dr1/cultist/v"..(self:GetBodygroup(1)==0 and "m" or "f").."_pain"..math.random((self:GetBodygroup(1)==0 and 3 or 2))..".mp3",100,100,1,CHAN_VOICE)
	else
		self:EmitSound("roach/dr1/cultist/v"..(self:GetBodygroup(1)==0 and "m" or "f").."_death.mp3",100,100,1,CHAN_VOICE)
	end

	if self.Suicided then 
		self.FellBackwards = false 
		self:PlaySequenceAndMove("suicide_land")
	elseif dmg:IsDamageType(DMG_BLAST) or dmg:IsDamageType(DMG_CRUSH) then
		self.Flinching = false
		self:FaceInstant(dmg:GetDamagePosition())
		local bool = false
		self:PlaySequenceAndMove("flinch_blast_1",{multiply=Vector(1.2,1.2,1.2),rate=math.Rand(1,1.3)},function(self)
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
			self:PlaySequenceAndMove("flinch_blast_2_hitwall",math.Rand(1,1.3))
		else
			self.FellBackwards = true
			self:PlaySequenceAndMove("flinch_blast_2",math.Rand(1,1.3))
		end
	else
		self:PlaySequenceAndMove("death"..m,math.Rand(1,1.3)) 
	end
	if self:GetBodygroup(0) ==2 then
		self:SetBodygroup(0,0)
		self:EmitSound("roach/drdr/em43/Play_OM00A7_005_SE_OM_WEAPON_HIT_L_EV"..math.random(3)..".mp3",511)
		self:EmitSound("roach/drdr/em43/Play_OM00A7_007_SE_OM_WEAPON_HIT_S_EV.mp3",511)
		local ent = ents.Create("env_explosion")
			ent:SetPos(self:GetPos() + Vector(0,0,10))
			ent:SetAngles(Angle(0,0,0))
			ent:Spawn()
			ent:SetKeyValue("imagnitude", "250")
			ent:Fire("explode")
	end

	self:PauseCoroutine(false)
end
function ENT:OnUpdateAnimation()
	if !self:IsOnGround() and string.find(self.JumpAnimation,"drill") then return self.JumpAnimation, 0.75 end
	if !self.Ready or self:IsDead() or self:IsDown() then return end
	if !self:IsOnGround() then return self.JumpAnimation, 0.75
	elseif self:IsRunning() then return self.RunAnimation, self.RunAnimRate
	elseif self:IsMoving() then return self.WalkAnimation, self.WalkAnimRate
	else return self.IdleAnimation, self.IdleAnimRate end
end
function ENT:CICO(callback)
	local oldThread = self.BehaveThread
	self.BehaveThread = coroutine.create(function()
		callback(self)
		self.BehaveThread = oldThread
	end)
end
-- things from the original cultist npcs --
function ENT:OnPossession()
	if not self.IsIdle or self.Suicidal then return end
	if self:GetCooldown("Cultist_Taunt") <= 0 then
		self:Timer(math.random(),self.EmitSound,"roach/dr1/cultist/v"..(self:GetBodygroup(1)==0 and "m" or "f").."_laugh"..math.random(2)..".mp3",90,100,1,CHAN_VOICE)
		self:PlaySequenceAndMove("idle_pray_random"..math.random(2),0.7,function()
			if self:GetPossessor():KeyDown(IN_RELOAD) then return true end
			if not self.IsIdle then return true end
		end)
		self:SetCooldown("Cultist_Taunt",math.random(6,15))
	else
		if math.random(2)==1 then self:EmitSound("roach/dr1/cultist/v"..(self:GetBodygroup(1)==0 and "m" or "f").."_pray"..math.random(3)..".mp3",75,100,1,CHAN_VOICE) end
		self:PlaySequenceAndMove("idle_pray",0.5,function()
			if self:GetPossessor():KeyDown(IN_RELOAD) then return true end
			if not self.IsIdle then return true end
		end)
	end
end
function ENT:OnIdle()
	return self:OnChaseEnemy(self:GetClosestEnemy())
end
function ENT:OnChaseEnemy(enemy)
	if not self.IsIdle or self.Suicidal then return end
	self:SetBodygroup(0,0)
	self.Ready = false
	if self:IsInRange(enemy,200) then
		self.IsIdle = false
		self:EmitSound("roach/dr1/cultist/v"..(self:GetBodygroup(1)==0 and "m" or "f").."_alert"..math.random(4)..".mp3",100,100,1,CHAN_VOICE)
		self:PlaySequenceAndMove("knife_equip",1,self.FaceEnemy)
		self:SetCooldown("Cultist_Mist",15)
		self.Ready = true
	else
		if self:GetCooldown("Cultist_Taunt") <= 0 then
			self:Timer(math.random(),self.EmitSound,"roach/dr1/cultist/v"..(self:GetBodygroup(1)==0 and "m" or "f").."_laugh"..math.random(2)..".mp3",90,100,1,CHAN_VOICE)
			self:PlaySequenceAndMove("idle_pray_random"..math.random(2),0.7,function()
				if self:IsInRange(enemy,200) or not self.IsIdle then return true end
			end)
			self:SetCooldown("Cultist_Taunt",math.random(6,15))
		else
			if math.random(2)==1 then self:EmitSound("roach/dr1/cultist/v"..(self:GetBodygroup(1)==0 and "m" or "f").."_pray"..math.random(3)..".mp3",75,100,1,CHAN_VOICE) end
			self:PlaySequenceAndMove("idle_pray",0.5,function()
				if self:IsInRange(enemy,200) or not self.IsIdle then return true end
			end)
		end
	end
end
function ENT:ShouldRun()
	if self.Strafing or self.IsIdle then return false end
	if self.Suicidal then return true end
	if self:HasEnemy() and not self:IsInRange(self:GetEnemy(),300) then return true end
	return false
end
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
end

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "HP")
end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)
------------------------------------------------------------------------
local ENT3 = {}
local sillyvar = string.sub(ENT.Folder,10)
ENT3.Base = sillyvar
ENT3.Factions = {ENT.Factions[1],FACTION_REBELS}

if SERVER then
function ENT3:_BaseInitialize() self:SetPlayersRelationship(D_LI, 99)end
end

scripted_ents.Register(ENT3, sillyvar.."f")

local nextbot2 = {
	Name = ENT.PrintName,
	Class = (sillyvar.."f"),
	Category = "Dead Rising (PC) Allies"
}
list.Set("NPC", sillyvar.."f", nextbot2)
list.Set("DrGBaseNextbots", sillyvar.."f", nextbot2)
 