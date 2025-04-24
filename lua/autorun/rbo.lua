AddCSLuaFile("rbo/sounds.lua")
AddCSLuaFile("rbo/supports.lua")

include("rbo/sounds.lua")

local support={}

if CLIENT then
    function RBOEmitSound(s,pos,level,pitch,volume)
	    local dir=pos-GetViewEntity():EyePos()
	    dir:Normalize()
	    sound.Play(s,GetViewEntity():EyePos()+dir*32,level,pitch,volume)
    end

    function RBOPlayRifle762Generic(distance,position)
		local rnd=math.random()
	    if distance<256 then
		    if rnd<=0.3 then
		    	RBOEmitSound("rbo_passby_hiss_close",position)
		    else
		    	RBOEmitSound("rbo_passby_762_close",position)
		    end
	    elseif distance<768 then
		    if rnd<=0.2 then
		    	RBOEmitSound("rbo_passby_762_wizz",position)
		    else
		    	RBOEmitSound("rbo_passby_hiss_close",position)
		    end
	    elseif distance<2000 then
		    if rnd<=0.2 then
		    	RBOEmitSound("rbo_passby_762_medium",position)
		    else
		    	RBOEmitSound("rbo_passby_hiss_far",position)
		    end
	    else
		    RBOEmitSound("rbo_passby_762_far",position)
	    end
    end

    function RBOPlayRifle556Generic(distance,position)
        local rnd=math.random()
	    if distance<256 then
	    	if rnd<=0.3 then
	    		RBOEmitSound("rbo_passby_hiss_close",position)
	    	else
	    		RBOEmitSound("rbo_passby_556_close",position)
	    	end
	    elseif distance<768 then
	    	if rnd<=0.2 then
	    		RBOEmitSound("rbo_passby_556_wizz",position)
	    	else
	    		RBOEmitSound("rbo_passby_hiss_close",position)
	    	end
	    elseif distance<2000 then
	    	if rnd<=0.2 then
	    		RBOEmitSound("rbo_passby_556_medium",position)
	    	else
	    		RBOEmitSound("rbo_passby_hiss_far",position)
	    	end
	    else
	    	RBOEmitSound("rbo_passby_556_far",position)
	    end
    end

    function RBOPlayPistolGeneric(distance,position)
        local rnd=math.random()
	    if distance<1024 then
		    if rnd<=0.5 then
		    	RBOEmitSound("rbo_passby_9mm",position)
		    else
		    	RBOEmitSound("rbo_passby_9mm_2",position)
		    end
	    end
    end
    function RBOPlay50CalGeneric(distance,position)
        local rnd=math.random()
	    if distance<256 then
	    	RBOEmitSound("rbo_passby_50_close",position)
	    elseif distance<768 then
	    	if rnd<=0.5 then
	    		RBOEmitSound("rbo_passby_50_medium_2",position)
	    	else
	    		RBOEmitSound("rbo_passby_50_medium",position)
	    	end
	    elseif distance<2500 then
	    	RBOEmitSound("rbo_passby_hiss_far",position)
	    else
	    	RBOEmitSound("rbo_passby_50_far_2",position)
	    end
    end
end

local rbo_fallback_support={
	ammo="AR2",
	use_tracer=false,
	velocity=48000,
	Passby=RBOPlayRifle762Generic	
}

function RBOAddSupport(info)
	assert(type(info.ammo)=="string")
	if game.GetAmmoID(info.ammo)<0 and SERVER then
		MsgC("RBO Tried to add unknown ammo type "..info.ammo.." doesn't exist\n")
		return
	end
	assert(type(info.velocity)=="number")
	support[info.ammo]={tracers=use_tracer,velocity=info.velocity}
	if CLIENT then
		assert(info.Passby~=nil and type(info.Passby)=="function")
		support[info.ammo].Passby=info.Passby or rbo_fallback_support.Passby
	end
end

function RBOGetSupported(ammotype)
	return support[ammotype] or rbo_fallback_support
end

include("rbo/supports.lua")

local STEP_SIZE = 4
local penMult = CreateConVar("ubp_penetration_multiplier", 2, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "A multiplier for how hard a bullet penetrates through materials")
local function runCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if not tr.Hit or tr.StartSolid then
		return
	end

	local surf = util.GetSurfaceData(tr.SurfaceProps)
	local mat = surf and surf.density / 1000 or 1
    local wep = attacker:GetActiveWeapon()
    if(not IsValid(wep)) then
        return 
    end
	local dist = ((1 / mat) * wep:GetPenetration()) * penMult:GetFloat()

	local start = tr.HitPos
	local dir = tr.Normal

	local trace
	local hit = false

	for i = STEP_SIZE, dist + STEP_SIZE, STEP_SIZE do
		local endPos = start + dir * i

		local contents = util.PointContents(endPos)

		if bit.band(contents, MASK_SHOT) == 0 or bit.band(contents, CONTENTS_HITBOX) == CONTENTS_HITBOX then
			trace = util.TraceLine({
				start = endPos,
				endpos = endPos - dir * STEP_SIZE,
				mask = bit.bor(MASK_SHOT, CONTENTS_HITBOX),
			})

			if trace.StartSolid and bit.band(trace.SurfaceFlags, SURF_HITBOX) == SURF_HITBOX then
				trace = util.TraceLine({
					start = endPos,
					endpos = endPos - dir * STEP_SIZE,
					mask = MASK_SHOT,
					filter = trace.Entity
				})
			end

			if trace.HitPos == endPos - dir * STEP_SIZE then
				trace = util.TraceLine({
					start = endPos + dir * ent:BoundingRadius(),
					endpos = endPos,
					mask = bit.bor(MASK_SHOT, CONTENTS_HITBOX),
					filter = function(hent)
						return hent == ent
					end,
					ignoreworld = true
				})
			end

			hit = true

			break
		end
	end

	if hit then
		local finalDist = start:Distance(trace.HitPos)
		local ratio = 1 - (finalDist / dist)
        local newdamage = dmginfo:GetDamage() * ratio
		if newdamage <= 0 then
			return
		end

		local effect = EffectData()

		effect:SetEntity(trace.Entity)
		effect:SetOrigin(trace.HitPos)
		effect:SetStart(trace.StartPos)
		effect:SetSurfaceProp(trace.SurfaceProps)
		effect:SetDamageType(dmginfo:GetDamageType())
		effect:SetHitBox(trace.HitBox)

		util.Effect("Impact", effect, false)

		local ignore = ent:IsRagdoll() and ent or NULL
        wep.rbo_no_refire = true
		wep:FireBullets({
            Attacker = attacker,
			Num = 1,
			Src = trace.HitPos + dir,
			Dir = dir,
			Damage = newdamage,
			Spread = vector_origin,
			Tracer = 0,
			IgnoreEntity = ignore
		})
	end
end

if SERVER then
    hook.Add("EntityFireBullets","rbo_efb_ubo",function(ent,info)
	    if ent.rbo_no_refire then
	        ent.rbo_no_refire = false
	    	return true
	    end

	    if ent:IsPlayer() or ent:IsNPC() then
		    local wep=ent:GetActiveWeapon()
		    if IsValid(wep) and wep:IsScripted() then
		    	info.AmmoType=weapons.Get(wep:GetClass()).Primary.Ammo
		    end
	    end
        if info.Callback then
		    local oldCallback = info.Callback

		    info.Callback = function(attacker, tr, dmginfo)
			    oldCallback(attacker, tr, dmginfo)
			    runCallback(attacker, tr, dmginfo)
		    end
	    else
		    info.Callback = runCallback
            
	    end

	    local sup=RBOGetSupported(info.AmmoType)
        local SndVec = Vector(0,0,-514)
	    for i=1,info.Num do
		    local bullet=ents.Create("rbo_bullet")
		    local right=info.Dir:Angle():Right()
		    local up=info.Dir:Angle():Up()
		    local f=0.5
		    local x=(math.Rand(-1,1)*f)+(math.Rand(-1,1)*(1-f))
		    local y=(math.Rand(-1,1)*f)+(math.Rand(-1,1)*(1-f))
		    local dir=info.Dir+(right*x*info.Spread.x)+(up*y*info.Spread.y)

		    bullet:SetDTVector(RBO_BULLET_VEC_VELOCITY,dir*sup.velocity)
		    bullet:SetDTVector(RBO_BULLET_VEC_ACCELERATION,SndVec)
		    bullet:SetDTVector(RBO_BULLET_VEC_POSITION,info.Src)
		    bullet:SetDTEntity(RBO_BULLET_ENT_SHOOTER,ent)
		    bullet:SetDTString(RBO_BULLET_STR_AMMOTYPE,info.AmmoType)
		
		    bullet.source=ent
		    bullet.data=table.Copy(info)
		    bullet:SetPos(info.Src)
		    bullet:Spawn()
	    end
	return false
    end)
end