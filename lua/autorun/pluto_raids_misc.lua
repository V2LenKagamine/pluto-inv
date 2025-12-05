local WeaponHearDist = 70
local VoiceHearDist = 327

local function AddSoundInterval(NAME,IMIN,IMAX,CHAN,VOL,LEV,PITMIN,PITMAX,PATH)
	for S=IMIN, IMAX do
		sound.Add( {
			name = NAME..S,
			channel = CHAN,
			volume = VOL,
			level = LEV,
			pitch = { PITMIN, PITMAX },
			sound = PATH..S..".wav"
		} )
	end
end

local function AddSound(NAME,CHAN,VOL,LEV,PITMIN,PITMAX,PATH)
	sound.Add( {
		name = NAME,
		channel = CHAN,
		volume = VOL,
		level = LEV,
		pitch = { PITMIN, PITMAX },
		sound = PATH
	} )
end

local function AddFootstepSounds(NAME,IMIN,IMAX,PATH)
	for S=IMIN, IMAX do
		sound.Add( {
			name = NAME,
			channel = CHAN_BODY,
			volume = 0.15,
			level = 70,
			pitch = { 95, 105 },
			sound = PATH..S..".wav"
		} )
	end
end

AddSound("KFMod.Flamethrower.Fire",CHAN_WEAPON,1,330,100,100,"Tripwire/Killing Floor/weapons/Flamethrower/FireLoop.wav")

AddSoundInterval("KFMod.Husk.Pain",1,16,CHAN_VOICE,1,VoiceHearDist,98,102,"Tripwire/Killing Floor/Husk/VoicePain/Pain")
AddSoundInterval("KFMod.Husk.Die",1,7,CHAN_VOICE,1,VoiceHearDist,98,102,"Tripwire/Killing Floor/Husk/VoiceDeath/Death")
AddSoundInterval("KFMod.Husk.Attack",1,4,CHAN_VOICE,1,VoiceHearDist,98,102,"Tripwire/Killing Floor/Husk/VoiceMelee/Attack")
AddSoundInterval("KFMod.Husk.RAttack",1,6,CHAN_VOICE,1,VoiceHearDist,98,102,"Tripwire/Killing Floor/Husk/VoiceRanged/Attack")
AddSoundInterval("KFMod.Husk.Idle",1,6,CHAN_VOICE,0.6,VoiceHearDist,88,92,"Tripwire/Killing Floor/Husk/VoiceRanged/Attack")
AddSoundInterval("KFMod.Husk.Chase",1,26,CHAN_VOICE,0.6,VoiceHearDist,88,92,"Tripwire/Killing Floor/Husk/VoiceChase/Chase")

AddSound("KFMod.HuskGun.Shoot",CHAN_WEAPON,1,WeaponHearDist,98,102,"Tripwire/Killing Floor/Husk/HuskGunShoot.wav")
AddSound("KFMod.HuskGun.Charge",CHAN_WEAPON,1,WeaponHearDist,98,102,"Tripwire/Killing Floor/Husk/HuskGunCharge.wav")
AddSound("KFMod.HuskGun.Uncharge",CHAN_WEAPON,1,WeaponHearDist,98,102,"Tripwire/Killing Floor/Husk/HuskGunUncharge.wav")

AddSoundInterval("KFMod.Gorefast.SwordMiss",1,4,CHAN_ITEM,0.8,WeaponHearDist,98,102,"Tripwire/Killing Floor/Gorefast/SwordMiss")

AddSoundInterval("KFMod.FireBall.Explosion",1,3,CHAN_WEAPON,0.8,400,98,102,"Tripwire/Killing Floor/FireBallExplosion")

AddFootstepSounds("KFMod.Zed.FootstepLeft",1,3,"tripwire/killing floor/footsteps/zeds/tile")
AddFootstepSounds("KFMod.Zed.FootstepRight",4,6,"tripwire/killing floor/footsteps/zeds/tile")

game.AddParticles("particles/kf_huskgun.pcf")
PrecacheParticleSystem("huskgun_charge")
PrecacheParticleSystem("huskgun_fireball")
