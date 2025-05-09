local isstring = isstring
local CurTime = CurTime
local Lerp = Lerp
local IsValid = IsValid
local istable = istable
local isnumber = isnumber
local SoundDuration = SoundDuration
local isbool = isbool
local ipairs = ipairs
local isentity = isentity
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local DrGBase = DrGBase
local UltrakillBase = UltrakillBase
local InQuad = math.ease.InQuad
local USharedRandom = util.SharedRandom
local MMin = math.min
local MClamp = math.Clamp
local MRandom = math.random
local MRound = math.Round
local TSimple = timer.Simple
local ECreate = SERVER and ents.Create
local TCopy = table.Copy


local mSoundScripts = { }
local mVoiceSoundScripts = { }


local mSisyphus_Prison_Subtitles = {

	{ "This prison...", 0 },
	{ "To hold", 1.5 },
	{ "ME?", 2.8 },

}


local mSisyphus_Outro_Subtitles = {

	{ "Ahh...", 0 },
	{ "So concludes the life and times of King Sisyphus", 1.6 },
	{ "A fitting end to an existence defined by futile struggle,", 6.3 },
	{ "Doomed from the very start...", 12.1 },
	{ "And I don't regret a SECOND of it!", 15.3 },

}

  
local mSisyphus_Intro_Subtitles = {

	{ "A visitor?", 0 },
	{ "Hmm... Indeed, I have slept long enough.", 1.7 },
	{ "The kingdom of heaven has long since forgotten my name", 6.6 },
	{ "And I am EAGER to make them remember", 10.3 },
	{ "However", 15.8 },
	{ "The blood of Minos stains your hands, and I must admit...", 17.2 },
	{ "I'm curious about your skills, Weapon.", 22 },
	{ "And so, before I tear down the cities and CRUSH the armies of heaven...", 25.9 },
	{ "You shall do as an appetizer.", 31.4 },
	{ "Come forth, Child of Man...", 35 },
	{ "And DIE.", 37.4 },

}


local mMinos_Outro_Subtitles = {

	{ "Aagh!", 0 },
	{ "Forgive me my children", 4.25 },
	{ "for I have failed to bring you salvation", 7.3 },
	{ "from this cold, dark world", 11.3 },

}


local mMinos_Intro_Subtitles = {

	{ "Aah...", 0 },
	{ "Free at last", 2.4 },
	{ "O Gabriel", 7 },
	{ "Now dawns thy reckoning", 10 },
	{ "and thy gore shall glisten before the temples of man", 13.8 },
	{ "Creature of steel...", 22 },
	{ "My gratitude upon thee for my freedom", 25.5 },
	{ "but the crimes thy kind have committed against humanity", 30.5 },
	{ "are NOT forgotten", 37 },
	{ "And thy punishment...", 40.7 },
	{ "is DEATH", 44 },

}


local mGabriel_Outro_Subtitles = {

	{ "What..?", 0.1 },
	{ "How can this be?", 1.4 },
	{ "Bested by this...", 4.15 },
	{ "this thing..?", 6.4 },
	{ "You insignificant FUCK!", 9.2 },
	{ "THIS IS NOT OVER!", 13 },

}


local mGabriel_Woes_Subtitles = {

	{ "May your woes be many", 0.3 },
	{ "and your days few", 3.3 },

}


-- Sound Scripts --


function UltrakillBase.AddSoundScript( sID, sPath, fRadius, fPitch, fVolume, fDieTime, bLooping, fDopplerFactor, bTimeScale, mCallback )

	if not isstring( sID ) then return end

	fRadius = fRadius > 0 and fRadius / 0.01905 or fRadius
	fDopplerFactor = fDopplerFactor > 0 and 1 / fDopplerFactor or fDopplerFactor
	bAutoDieTime = not fDieTime and true or false

	mSoundScripts[ sID ] = {

		mPath = sPath,
  		mRadius = fRadius,
  		mVolume = fVolume,
  		mPitch = fPitch,
  		mDieTime = fDieTime,
  		mLooping = bLooping,
  		mDopplerFactor = fDopplerFactor,
  		mTimeScale = bTimeScale,
		mAutoDieTime = bAutoDieTime,
  		mCallback = mCallback

	}

end


function UltrakillBase.RemoveSoundScript( sID )

	if not isstring( sID ) then return end

	mSoundScripts[ sID ] = nil

end


function UltrakillBase.AddVoiceSoundScript( sID, fPriority, sSubtitles, bOverrideHoldTime )

	if not isstring( sID ) then return end

	mVoiceSoundScripts[ sID ] = {

		mPriority = fPriority or 0,
		mSubtitle = sSubtitles,
		mOverrideHoldTime = bOverrideHoldTime

	}

end


function UltrakillBase.SOUND_SnakeFadeFunction( self )

	local fDelta = ( CurTime() - ( self.mInitTime + 0.2 ) ) / self.mDieTime

	self.mVolume = Lerp( fDelta, self.mInitData.mVolume, 0 )

end


function UltrakillBase.SOUND_RollOffFunction( self )

	local fDelay = MMin( self.mDieTime * 0.33, 0.33 )
	local fDelta = MClamp( ( CurTime() - ( self.mInitTime + fDelay ) ) / ( self.mDieTime - fDelay ), 0, 1 )

	self.mVolume = Lerp( InQuad( fDelta ), self.mInitData.mVolume, 0 )

end


function UltrakillBase.SOUND_HPGetFunction( self, mParent )

	if not IsValid( mParent ) then return end

	local fHP, fHPMax = mParent:Health(), mParent:GetMaxHealth()

	self.mPitch = Lerp( fHP / fHPMax, 0.665, 1.1 )

end


function UltrakillBase.SOUND_ScreamFunction( self, mParent )

	if not SERVER or not IsValid( mParent ) or not mParent:IsOnGround() then return end

	self:Remove()

end


function UltrakillBase.SOUND_EnrageFunction( self, mParent )

	if not SERVER or not IsValid( mParent ) or mParent.IsUltrakillNextbot and mParent:IsEnraged() then return end

	self:Remove()

end


local EnrageFunction = UltrakillBase.SOUND_EnrageFunction
local ScreamFunction = UltrakillBase.SOUND_ScreamFunction
local HPGetFunction = UltrakillBase.SOUND_HPGetFunction
local RollOffFunction = UltrakillBase.SOUND_RollOffFunction
local SnakeFadeFunction = UltrakillBase.SOUND_SnakeFadeFunction


-- General SFX --

UltrakillBase.AddSoundScript( "Base", "", 0, 0, 0, nil, false, 0, false )

UltrakillBase.AddSoundScript( "Ultrakill_Dodge2F", "ultrakill/sound/Dodge2_Filtered.wav", 120, { 0.75, 0.8 }, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Dodge2", "ultrakill/sound/Dodge2.wav", 120, 1,  1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Dodge3", "ultrakill/sound/Dodge3.wav", 120, 1,  1, nil, false, 1, true )

UltrakillBase.AddSoundScript( "Ultrakill_BigRockBreak", "ultrakill/sound/bigRockBreak.wav", 77, { 0.7, 0.85 },  1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_RockBreak", "ultrakill/sound/boulder_impact_on_stones_14.wav", 68, { 0.5, 1 }, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_GroundBreak", "ultrakill/sound/Door_2_Close.wav", 68, { 0.85, 1 }, 1, nil, false, 1, true )

UltrakillBase.AddSoundScript( "Ultrakill_Shockwave", "ultrakill/sound/Impacts_PROCESSED_001.wav", 77, 0.75, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Shockwave_Short", "ultrakill/sound/Impacts_PROCESSED_001.wav", 77, 1.5, 1, nil, false, 1, true )

UltrakillBase.AddSoundScript( "Ultrakill_Hit", "ultrakill/sound/Impacts_PROCESSED_002.wav", 10, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Hit_Low", "ultrakill/sound/Impacts_PROCESSED_002.wav", 10, 0.75, 1, nil, false, 1, true )

UltrakillBase.AddSoundScript( "Ultrakill_Metal_Break", "ultrakill/sound/Metal_Hit_Crash_199.wav", 10, 1, 0.45, nil, false, 1, true )

UltrakillBase.AddSoundScript( "Ultrakill_Landing", "ultrakill/sound/Landing.wav", 7, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Explosion_1", "ultrakill/sound/Explosion 1.wav", 85, 1, 1, nil, false, 1, true, RollOffFunction )
UltrakillBase.AddSoundScript( "Ultrakill_Explosion_2", "ultrakill/sound/Explosion 2.wav", 85, 1, 1, nil, false, 1, true, RollOffFunction )

UltrakillBase.AddSoundScript( "Ultrakill_Explosion_Wave", "ultrakill/sound/Explosion Wave.wav", 85, 0.8, 1, nil, false, 1, true )

UltrakillBase.AddSoundScript( "Ultrakill_AlertParryable", "ultrakill/sound/ComputerSFX_alerts-004.wav", 200, 2.5, 1, nil, false, 2.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_AlertParryable_Projectile", "ultrakill/sound/ComputerSFX_alerts-004.wav", 200, 1.5, 1, nil, false, 2.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_AlertUnParryable", "ultrakill/sound/ComputerSFX_alerts-004 2.wav", 200, 1, 1, nil, false, 2.5, true )

UltrakillBase.AddSoundScript( "Ultrakill_Spotlight", "ultrakill/sound/spotlight.wav", 100, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Spotlight_Mid", "ultrakill/sound/spotlight.wav", 100, 0.8, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Spotlight_Low", "ultrakill/sound/spotlight.wav", 100, 0.4, 1, nil, false, 1, true )

UltrakillBase.AddSoundScript( "Ultrakill_HP", "ultrakill/sound/HpGet.wav", 8, 1, 1, nil, false, 1, true, HPGetFunction )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_HP", 1 )

UltrakillBase.AddSoundScript( "Ultrakill_HP_Low", "ultrakill/sound/HpGet.wav", 100, 0.75, 1, nil, false, 1, true )

UltrakillBase.AddSoundScript( "Ultrakill_Whoosh", "ultrakill/sound/Whoosh,Organic,Styrofoam,Plank,Airy,Smooth,Texture,1.wav", 40, { 0.85, 1.05 }, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Punch_Whoosh_Low", "ultrakill/sound/PunchSwooshHeavy.wav", 60, { 0.65, 0.8 }, 1.2, nil, false, 1, true )

UltrakillBase.AddSoundScript( "Ultrakill_KnuckleCrack", "ultrakill/sound/knucklescrack.wav", 30, { 0.8, 1 }, 0.8, nil, false, 1, true )

UltrakillBase.AddSoundScript( "Ultrakill_VirtueShatter", "ultrakill/sound/Bonus Break 3.wav", 68, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Checkpoint_Ambiance", "ultrakill/sound/CheckpointAmbiance.wav", 20, 1, 1, -1, true, 1, true )

UltrakillBase.AddSoundScript( "Ultrakill_Parry", "ultrakill/sound/punch_projectile.wav", 0, 1, 1, nil, false, 0, false )
UltrakillBase.AddSoundScript( "Ultrakill_Ricochet", "ultrakill/sound/Ricochet.wav", 0, 1, 1, nil, false, 0, false )
UltrakillBase.AddSoundScript( "Ultrakill_Bullet_Ricochet", "ultrakill/sound/Ricochet.wav", 38, 1, 0.5, nil, false, 0, true )
UltrakillBase.AddSoundScript( "Ultrakill_Deflect", "ultrakill/sound/RicochetLong.wav", 38, 1, 0.7, nil, false, 1, true )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Deflect", 1 )

UltrakillBase.AddSoundScript( "Ultrakill_Projectile_Shoot", "ultrakill/sound/AnimeSlash.wav", 25, { 1.85, 2 },  0.7, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Projectile_Impact", "ultrakill/sound/SkullImpact.wav", 10, 0.85, 0.25, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Projectile_Loop", "ultrakill/sound/Twirling.wav", 10, 3, 0.65, -1, true, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Projectile_Windup", "ultrakill/sound/AnimeSlashLoop2.wav", 40, 1.5, 0.5, -1, true, 1, true, function( self ) 

	self.mPitch = Lerp( ( CurTime() - self.mInitTime ) / 0.5, 0, 2 )

end )

UltrakillBase.AddSoundScript( "Ultrakill_Enrage", "ultrakill/sound/enrage.wav", 28, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Enrage_End", "ultrakill/sound/EnrageEnd.wav", 28, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Enrage_Loop", "ultrakill/sound/rageloop.wav", 12, 1, 0.7, -1, true, 1, true, EnrageFunction )

UltrakillBase.AddSoundScript( "Ultrakill_Teleport", "ultrakill/sound/Future Weapons 2 - Energy Gun - shot_single_2.wav", 40, { 0.95, 1.1 },  1, nil, false, 1, true )

UltrakillBase.AddSoundScript( "Ultrakill_Machine_Footsteps", "ultrakill/sound/Bluezone-Autobots-footstep-013.wav", 15, { 0.85, 1.05 },  1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Machine_Scream", "ultrakill/sound/StreetcleanerFall2.wav", 28, { 0.85, 1.05 },  1, nil, false, 1, true, ScreamFunction )
UltrakillBase.AddSoundScript( "Ultrakill_Machine_Death", "ultrakill/sound/Negative_Notification_25.wav", 28, 1.25, 0.65, nil, false, 1, true )

UltrakillBase.AddSoundScript( "Ultrakill_Radiance", "ultrakill/sound/BlackHoleLaunch.wav", 250, 2, 0.5, 1, false, 1, true, function( self )

	self.mPitch = Lerp( ( CurTime() - self.mInitTime ) / self.mDieTime, 2, 0 )

end )


-- General SFX --

UltrakillBase.AddSoundScript( "Ultrakill_Impact_S_03", "ultrakill/sound/Impacts_SIMPLE_003.wav", 10, { 0.9, 1.15 },  0.5, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SandHit", "ultrakill/sound/SandHit.wav", 10, { 0.9, 1.15 },  0.5, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_HeadBreak", "ultrakill/sound/HeadBreak.wav", 28, { 0.9, 1.15 }, 0.4, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_LimbBreak", "ultrakill/sound/LimbBreak.wav", 28, { 0.9, 1.15 }, 0.4, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Death", "ultrakill/sound/HeadBreak2.wav", 45, { 0.8, 1.2 }, 0.75, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Death_Explode", "ultrakill/sound/HeadBreak2.wav", 45, { 0.8, 1.2 }, 1.3, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gushing_Blood", "ultrakill/sound/PM_BB_DESIGNED_CINEMATIC_TEXTURE_FLESH_GUSH_1.wav", 45, 1, 1, nil, false, 1, true )


-- Weapons --

UltrakillBase.AddSoundScript( "Ultrakill_Shotgun_Fire", "ultrakill/sound/Steampunk Weapons - Shotgun 2 - Shot - 03.wav", 20, { 0.90, 1.05 },  1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Shotgun_Reload", "ultrakill/sound/Mechanism_Designed_Mega_Steam_Lever-005b.wav", 45, { 0.90, 1.05 },  1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Shotgun_Steam", 	"ultrakill/sound/Mechanism_Designed_Mega_Steam_Lever-002.wav", 45, 2, 0.65, nil, false, 1, true )


-- Portals --

UltrakillBase.AddSoundScript( "Ultrakill_Portal_Superheavy", "ultrakill/sound/PortalHeavy.wav", 85, { 0.45, 0.55 },  0.6, 5, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Portal_Heavy", "ultrakill/sound/PortalHeavy.wav", 85, { 0.9, 1.1 },  0.6, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Portal_Light", "ultrakill/sound/Portal3.wav", 85, { 0.9, 1.1 },  0.6, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Portal_MindFlayer", "ultrakill/sound/PortalMindflayer.wav", 85, { 0.9, 1.1 },  0.75, nil, false, 1, true )


-- Husks -- 

UltrakillBase.AddSoundScript( "Ultrakill_Human_Scream", "ultrakill/sound/Screams&Shouts_human_male_093.wav", 28, { 0.85, 1.05 },  1, nil, false, 1, true, ScreamFunction )
UltrakillBase.AddSoundScript( "Ultrakill_HuskStep", "ultrakill/sound/heavyHuskStep1.wav", 15, { 0.85, 1.05 },  1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Husk_Hurt", "ultrakill/sound/heavyHuskHurt.wav", 5, { 0.95, 1 },  1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Husk_Death", "ultrakill/sound/heavyHuskDeath2.wav", 7, { 0.95, 1 },  1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_HuskMelee", "ultrakill/sound/heavyHuskMelee.wav", 45, { 0.85, 1.05 },  1, nil, false, 1, true )


-- Filth --

UltrakillBase.AddSoundScript( "Ultrakill_FilthBite", "ultrakill/sound/Zombie Weak Death Reverse.wav", 32, { 0.85, 1.05 },  1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Filth_Hurt", { "ultrakill/sound/Zombie Damage 1.wav", "ultrakill/sound/Zombie Damage 2.wav", "ultrakill/sound/Zombie Damage 3.wav" }, 5, { 0.95, 1 },  1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Filth_Death", "ultrakill/sound/Zombie Death.wav", 7, { 0.95, 1 },  1, nil, false, 1, true )


-- Malicious Face --

UltrakillBase.AddSoundScript( "Ultrakill_MaliciousProjectile_Shoot", "ultrakill/sound/AnimeSlash.wav", 20, { 2.18, 2.5 },  0.7, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MaliciousFace_Charge", "ultrakill/sound/Throat Drone High Frequency2.wav", 50, 0, 1, 2, true, 1, true, function( self, mParent )

	if not IsValid( mParent ) then return end

	if self.mChargeTime == nil then

		self.mChargeTime = mParent.MaliciousFaceChargeTime
		self.mDieTime = self.mChargeTime
		self.mLifeTime = 0

	end

	self.mPitch = Lerp( ( CurTime() - self.mInitTime ) / ( self.mChargeTime * 0.7 ), 0, 3 )

end )


-- Cerberus --

UltrakillBase.AddSoundScript( "Ultrakill_CerberusCharge", "ultrakill/sound/statuecharge.wav", 40, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_CerberusCharge2", "ultrakill/sound/statuecharge2.wav", 40, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_CerberusCharge3", "ultrakill/sound/statuecharge3.wav", 40, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_CerberusEnrage", "ultrakill/sound/Statuedeath.wav", 0, 0.3, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_CerberusDeath", "ultrakill/sound/Statuedeath.wav", 28, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_CerberusStep", "ultrakill/sound/stonestep.wav", 15, { 0.85, 1.05 },  1, nil, false, 1, true )


-- SwordsMachine -- 

UltrakillBase.AddSoundScript( "Ultrakill_SwordsMachine_BigPain_H", "ultrakill/sound/SwordsmachineBigPain.wav", 30, 2, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SwordsMachine_BigPain", "ultrakill/sound/SwordsmachineBigPain.wav", 30, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SwordsMachine_ChainsawSwing", "ultrakill/sound/chainsawSwing2.wav", 45, { 0.9, 1.05 },  1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SwordsMachine_ChainsawThrown", "ultrakill/sound/chainsawThrown.wav", 28, 1, 1, -1, true, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SwordsMachine_ChainsawLoop", "ultrakill/sound/chainsaw_gas_big_engine_idle_mono.wav", 10, 1, 0.7, -1, true, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SwordsMachine_Hurt", "ultrakill/sound/8bitAhh.wav", 5, { 0.95, 1 },  1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SwordsMachine_Enrage_Loop", "ultrakill/sound/rageloop.wav", 15, 1, 0.7, 12, true, 1, true, function( self, mParent )

	local fTime = self.mInitTime + self.mDieTime * 0.9
	local fLerpTime = self.mDieTime - self.mDieTime * 0.9

	self.mPitch = Lerp( ( CurTime() - fTime ) / fLerpTime, 1, 0 )

	EnrageFunction( self, mParent )

end )


-- MindFlayer --


UltrakillBase.AddSoundScript( "Ultrakill_MindFlayer_Projectile", "ultrakill/sound/AnimeSlash.wav", 25, 1.5, 0.5, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MindFlayer_Projectile_Loop", "ultrakill/sound/AnimeSlashLoop.wav", 10, 3, 0.35, -1, true, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MindFlayer_Projectile_Impact", "ultrakill/sound/SkullImpact.wav", 5, 1.5, 0.25, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MindFlayer_Explosion", "ultrakill/sound/Black Hole Explosion.wav", 60, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MindFlayer_Explosion_Large", "ultrakill/sound/Mindflayer Beam Explosion.wav", 60, 0.5, 0.35, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MindFlayer_WindUp", "ultrakill/sound/MindflayerWindup.wav", 60, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MindFlayer_WindUp_Quick", "ultrakill/sound/MindflayerWindupQuick.wav", 60, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MindFlayer_Scream", "ultrakill/sound/MindflayerScream.wav", 60, { 1.05, 1.2 },  1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MindFlayer_Beam", "ultrakill/sound/MindflayerBeam.wav", 28, 1, 0.5, 10, true, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MindFlayer_Beam_Electric", "ultrakill/sound/ElectricityContinuous3.wav", 28, 1, 0.5, 10, true, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MindFlayer_Hurt", { "ultrakill/sound/MindflayerHurt.wav", "ultrakill/sound/MindflayerHurtSmall.wav" }, 5, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MindFlayer_Melee", "ultrakill/sound/Whoosh,Organic,Styrofoam,Plank,Airy,Smooth,Texture,1.wav", 60, 3, 1, nil, false, 1, true )


-- Soldier --


UltrakillBase.AddSoundScript( "Ultrakill_Soldier_ShotgunPump", "ultrakill/sound/171624__pjkasinski3__rem870-pump3.wav", 45, 3, 0.5, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Soldier_Shoot", "ultrakill/sound/AnimeSlash.wav", 32, 1.35, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Soldier_Windup", "ultrakill/sound/AnimeSlashLoop2.wav", 40, 1.5,  0.5, -1, false, 1, true, function( self )

	self.mPitch = Lerp( ( CurTime() - self.mInitTime ) / 0.85, 0, 2 )

end )


-- Drone --

	
UltrakillBase.AddSoundScript( "Ultrakill_Drone_Windup", "ultrakill/sound/DroneCharge.wav", 150, 1, 1, 1, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Drone_Death", "ultrakill/sound/DroneDeath.wav", 150, 1, 1, 1, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Drone_Hurt", "ultrakill/sound/DroneHurt.wav", 35, 1, 1, 1, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Drone_Loop", "ultrakill/sound/DroneScan.wav", 25, 1, 1, 1, false, 1, true )


-- StreetCleaner --


UltrakillBase.AddSoundScript( "Ultrakill_StreetCleaner_Hurt", "ultrakill/sound/StreetcleanerHurt2.wav", 28, { 0.9, 1.1 }, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_StreetCleaner_Footstep", "ultrakill/sound/StreetcleanerWalk.wav", 22, { 0.85, 1.05 }, 0.85, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_StreetCleaner_Breath", "ultrakill/sound/Streetcleaner Breath.wav", 10, { 0.85, 1.05 }, 0.2, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_StreetCleaner_Gas", "ultrakill/sound/enemyShotgunReady.wav", 25, 2, 0.75, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_StreetCleaner_Flamethrower", "ultrakill/sound/flamethrowerloop.wav", 10, 1, 0.85, -1, true, 1, true, function( self, mParent )

	if not SERVER or not IsValid( mParent ) or mParent.StreetCleanerFlameThrower then return end

	self:Remove()

end )

-- Hideous Mass --

UltrakillBase.AddSoundScript( "Ultrakill_HideousMass_Windup", "ultrakill/sound/MassWindup.wav", 150, 1, 1, 1.3, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_HideousMass_Windup_High", "ultrakill/sound/MassWindup.wav", 150, 2.5, 1, 1.3, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_HideousMass_Death", "ultrakill/sound/MassDeath.wav", 150, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_HideousMass_BigPain", "ultrakill/sound/MassBigPain.wav", 150, 1, 0.65, 2, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_HideousMass_Spear_WindUp", "ultrakill/sound/MassRegurgitate.wav", 150, 1, 0.65, 2, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_HideousMass_Spear_Fire", "ultrakill/sound/harpoonShoot.wav", 100, 1, 0.5, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_HideousMass_Spear_Pierce", "ultrakill/sound/harpoonPierce.wav", 35, 1, 0.75, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_HideousMass_Spear_Break", "ultrakill/sound/harpoonStop.wav", 35, 1, 0.75, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_HideousMass_Mortar_Loop", "ultrakill/sound/Twirling.wav", 85, 3, 0.65, -1, true, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_HideousMass_Mortar", "ultrakill/sound/Door_2_Close.wav", 85, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_HideousMass_Loop", "ultrakill/sound/MassLoop.wav", 85, 1, 1, -1, true, 1, true, function( self, mParent )

	if not SERVER or not IsValid( mParent ) or mParent.IsUltrakillNextbot and not mParent:IsDead() then return end

	self:Remove()

end )


-- Something Wicked -- 


UltrakillBase.AddSoundScript( "Ultrakill_WickedSpawn", "ultrakill/sound/SomethingEvil3.wav", 0, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_WickedHurt", "ultrakill/sound/SomethingEvil3.wav", 0, 2, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_WickedAmbiance", "ultrakill/sound/BlackHoleLoop.wav", 25, 1, 1, -1, true, 1, true )


-- Stalker --


UltrakillBase.AddSoundScript( "Ultrakill_Stalker_Explosion", "ultrakill/sound/Explosion Sand.wav", 45, { 1, 1.15 },  1, nil, false, 1, true )


-- Prime Shared --


UltrakillBase.AddSoundScript( "Ultrakill_Prime_OutroRay", "ultrakill/sound/nailZap.wav", 50, 0.5, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Prime_OutroAmbiance", "ultrakill/sound/CheckpointAmbiance.wav", 45, 2, 0.4, -1, true, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Prime_Death", "ultrakill/sound/Prime Death.wav", 0, 1, 0.85, nil, false, 1, false )


-- Minos Prime --


-- Voice --


UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_ThyEnd", { "ultrakill/voice/Minos/mp_thyend.wav", "ultrakill/voice/Minos/mp_thyend2.wav" }, 0, { 0.95, 1 }, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_Prepare", { "ultrakill/voice/Minos/mp_prepare.wav", "ultrakill/voice/Minos/mp_prepare2.wav" }, 0, { 0.95, 1 }, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_Judgement", { "ultrakill/voice/Minos/mp_judgement.wav", "ultrakill/voice/Minos/mp_judgement2.wav" }, 0, { 0.95, 1 }, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_Die", { "ultrakill/voice/Minos/mp_die.wav", "ultrakill/voice/Minos/mp_die2.wav" }, 0, { 0.95, 1 }, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_Crush", "ultrakill/voice/Minos/mp_crush.wav", 0, { 0.95, 1 }, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_Weak", "ultrakill/voice/Minos/mp_weak.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_Outro", "ultrakill/voice/Minos/mp_outro.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_Intro", "ultrakill/voice/Minos/mp_intro2.wav", 0, 1, 1, nil, false, 0, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_Hurt", "ultrakill/voice/Minos/mp_hurt.wav", 5, { 0.95, 1 },  1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_Scream", "ultrakill/voice/Minos/mp_deathscream.wav", 0, 1, 0.85, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_Useless", "ultrakill/voice/Minos/mp_useless.wav", 0, { 0.95, 1 }, 1, nil, false, 0.5, true )

UltrakillBase.AddVoiceSoundScript( "Ultrakill_MinosPrime_ThyEnd", 1, "Thy end is now!" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_MinosPrime_Prepare", 1, "Prepare thyself!" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_MinosPrime_Judgement", 1, "Judgement!" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_MinosPrime_Die", 1, "Die!" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_MinosPrime_Crush", 1, "Crush!" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_MinosPrime_Weak", 2, "WEAK!" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_MinosPrime_Outro", 3, mMinos_Outro_Subtitles )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_MinosPrime_Intro", 3, mMinos_Intro_Subtitles )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_MinosPrime_Hurt", 1 )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_MinosPrime_Scream", 3, "Aagh!", 7 )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_MinosPrime_Useless", 1, "Useless!" )


-- SFX --


UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_SnakeSwing", "ultrakill/sound/enemyShotgunReady.wav", 45, 0.25, 1, 0.75, false, 1, true, RollOffFunction )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_SwingLoop", "ultrakill/sound/SnakeLoop.wav", 5, 1, 0.5, 0.75, true, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_SnakeLoop", "ultrakill/sound/SnakeLoop.wav", 35, 1, 0.5, 5, true, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_SnakeCharge", "ultrakill/sound/AnimeSlashReverse.wav", 100, 1.5, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_SnakeSpawn", "ultrakill/sound/AnimeSlash.wav", 35, 1.5, 0.65, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Minos_Prime_Explosion", "ultrakill/sound/Minos Prime Explosion.wav", 85, { 0.55, 0.8 }, 1, 1.2, false, 1, true, RollOffFunction )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_Launch", "ultrakill/sound/BlackHoleLaunch.wav", 180, 1.5, 0.85, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_Phase", "ultrakill/sound/BlackHoleLaunch.wav", 150, 1.75, 0.5, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_SnakeShatter", "ultrakill/sound/Bonus Break 3.wav", 68, 1.2, 1, nil, false, 1, true, function( self )

	self.mPitch = Lerp( ( CurTime() - self.mInitTime ) / 0.4, 0.75, 1.2 )

end )


-- Sisyphus Prime --


-- Voice --


UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Escape", { "ultrakill/voice/Sisyphus/sp_youcantescape.wav", "ultrakill/voice/Sisyphus/sp_youcantescape2.wav" }, 0, { 0.95, 1 }, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Begone", { "ultrakill/voice/Sisyphus/sp_begone.wav", "ultrakill/voice/Sisyphus/sp_begone2.wav" }, 0, { 0.95, 1 }, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Nicetry", { "ultrakill/voice/Sisyphus/sp_nicetry.wav", "ultrakill/voice/Sisyphus/sp_nicetry2.wav" }, 0, { 0.95, 1 }, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Destroy", { "ultrakill/voice/Sisyphus/sp_destroy.wav", "ultrakill/voice/Sisyphus/sp_destroy2.wav" }, 0, { 0.95, 1 }, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Thiswillhurt", "ultrakill/voice/Sisyphus/sp_thiswillhurt.wav", 0, { 0.95, 1 }, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Yes", "ultrakill/voice/Sisyphus/sp_yesthatsit.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Outro", "ultrakill/voice/Sisyphus/sp_outro.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Intro", "ultrakill/voice/Sisyphus/sp_intro.wav", 0, 1, 1, nil, false, 0, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Hurt", "ultrakill/voice/Sisyphus/sp_grunt.wav", 15, { 0.95, 1 },  1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Prison", "ultrakill/voice/Sisyphus/sp_thisprison.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Keepthemcoming", "ultrakill/voice/Sisyphus/sp_keepthemcoming.wav", 0, { 0.95, 1 }, 1, nil, false, 0.5, true )

UltrakillBase.AddVoiceSoundScript( "Ultrakill_SisyphusPrime_Escape", 1, "You can't escape!" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_SisyphusPrime_Begone", 1, "BE GONE!" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_SisyphusPrime_Nicetry", 1, "Nice try!" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_SisyphusPrime_Destroy", 1, "DESTROY!" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_SisyphusPrime_Thiswillhurt", 1, "This will hurt." )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_SisyphusPrime_Yes", 2, "YES That's it!" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_SisyphusPrime_Outro", 3, mSisyphus_Outro_Subtitles )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_SisyphusPrime_Intro", 3, mSisyphus_Intro_Subtitles )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_SisyphusPrime_Hurt", 1 )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_SisyphusPrime_Prison", 3, mSisyphus_Prison_Subtitles )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_SisyphusPrime_Keepthemcoming", 1, "Keep them comin'!" )


-- SFX --


UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Swing", "ultrakill/sound/GORE - Head_Explode_6.wav", 65, { 1.6, 2.4 }, 1, 1, false, 1, true, RollOffFunction )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_SwingLoop", "ultrakill/sound/SnakeLoop.wav", 5, 1, 0.5, 0.75, true, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Launch", "ultrakill/sound/BlackHoleLaunch.wav", 150, 1.5, 0.25, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Phase", "ultrakill/sound/BlackHoleLaunch.wav", 250, 1.75, 0.5, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Explosion", "ultrakill/sound/Explosion 2.wav", 150, { 0.55, 0.75 }, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Explosion2", "ultrakill/sound/Explosion 2.wav", 150, { 0.25, 0.5 }, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_SparkleExplosionCharge", "ultrakill/sound/AnimeSlashReverse.wav", 100, 2, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_Sparkle", "ultrakill/sound/sparkles.wav", 100, { 1.15, 1.25 }, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_SparkleExplosion", "ultrakill/sound/Explosion 2.wav", 75, { 0.75, 1.25 }, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_SisyphusPrime_ExplosionCharge", "ultrakill/sound/AnimeSlashLoop2.wav", 500, 2, 1, 0.9, true, 0, true, function( self )

	self.mPitch = Lerp( ( CurTime() - self.mInitTime ) / self.mDieTime, 2, 0 )

end )


-- Flesh Panopticon --

	
UltrakillBase.AddSoundScript( "Ultrakill_FleshPanopticon_Hurt", "ultrakill/sound/MassBigPain.wav", 150, 0.65, 0.65, 1, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_FleshPanopticon_Idle", "ultrakill/sound/Throat Drone Heavy.wav", 150, 1, 1, -1, true, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_FleshPanopticon_WindUp", "ultrakill/sound/saw.wav", 150, 0.5, 1, nil, false, 1, true )


-- Gabriel Act 1 --


-- Voice  --


UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Behold", "ultrakill/voice/Gabriel/gab_Behold.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Enough", "ultrakill/voice/Gabriel/gab_Enough.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_BigHurt", "ultrakill/voice/Gabriel/gab_BigHurt1.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Hurt", { "ultrakill/voice/Gabriel/gab_Hurt1.wav", "ultrakill/voice/Gabriel/gab_Hurt2.wav", "ultrakill/voice/Gabriel/gab_Hurt3.wav", "ultrakill/voice/Gabriel/gab_Hurt4.wav" }, 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Insignificant", "ultrakill/voice/Gabriel/gab_Insignificant2b.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Woes", "ultrakill/voice/Gabriel/gab_Woes.wav", 0, 1, 1, nil, false, 0.5, true )

UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Behold", 3, "BEHOLD! THE POWER OF AN ANGEL!" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Enough", 2, "Enough!" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Hurt", 1 )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_BigHurt", 2 )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Insignificant", 3, mGabriel_Outro_Subtitles )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Woes", 3, mGabriel_Woes_Subtitles )


-- Taunts --


UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Taunt1", "ultrakill/voice/Gabriel/gab_Taunt1.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Taunt2", "ultrakill/voice/Gabriel/gab_Taunt2.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Taunt3", "ultrakill/voice/Gabriel/gab_Taunt3.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Taunt4", "ultrakill/voice/Gabriel/gab_Taunt4.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Taunt5", "ultrakill/voice/Gabriel/gab_Taunt5.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Taunt6", "ultrakill/voice/Gabriel/gab_Taunt6.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Taunt7", "ultrakill/voice/Gabriel/gab_Taunt7.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Taunt8", "ultrakill/voice/Gabriel/gab_Taunt8.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Taunt9", "ultrakill/voice/Gabriel/gab_Taunt9.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Taunt10", "ultrakill/voice/Gabriel/gab_Taunt10.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Taunt11", "ultrakill/voice/Gabriel/gab_Taunt11.wav", 0, 1, 1, nil, false, 0.5, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Taunt12", "ultrakill/voice/Gabriel/gab_Taunt12.wav", 0, 1, 1, nil, false, 0.5, true )


UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Taunt1", 1, "You defy the light" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Taunt2", 1, "A mere object" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Taunt3", 1, "There can be only light" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Taunt4", 1, "Foolishness, machine. Foolishness." )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Taunt5", 1, "An imperfection to be cleansed" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Taunt6", 1, "Not. Even. Mortal." )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Taunt7", 1, "You are less than nothing" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Taunt8", 1, "You're an error to be corrected" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Taunt9", 1, "The light is perfection" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Taunt10", 1, "You are outclassed" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Taunt11", 1, "Your crime is existence" )
UltrakillBase.AddVoiceSoundScript( "Ultrakill_Gabriel_Taunt12", 1, "You make even the devil cry" )


-- SFX --

UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Swing", "ultrakill/sound/GabrielSwing2.wav", 100, { 0.8, 1 }, 0.5, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Throw", "ultrakill/sound/GabrielSwing2.wav", 100, 1, 1, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_WeaponSpawn", "ultrakill/sound/GabrielWeaponSpawn.wav", 50, 1, 0.75, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_WeaponBreak", "ultrakill/sound/GabrielWeaponBreak.wav", 50, 1, 0.75, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_WeaponExplode", "ultrakill/sound/Bonus Break 3.wav", 35, 1, 0.5, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Light", "ultrakill/sound/RailcannonFire5.wav", 200, 0.75, 0.35, nil, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Break", "ultrakill/sound/Bonus Break 3.wav", 100, 1, 1, 1, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Dash", "ultrakill/sound/Dodge3.wav", 120, 1,  1, 1, false, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Whoosh", "ultrakill/sound/Whoosh.wav", 25, 1, 0.5, -1, true, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Whoosh_Small", "ultrakill/sound/Whoosh.wav", 25, 1, 0.15, -1, true, 1, true )
UltrakillBase.AddSoundScript( "Ultrakill_Gabriel_Enrage_Loop", "ultrakill/sound/rageloop.wav", 15, 1, 0.7, 3, true, 1, true, function( self )

	self.mVolume = Lerp( ( CurTime() - self.mInitTime ) / self.mDieTime, 1, 0 )

end )


-- Functions -


local function SharedRandom( sID, fMin, fMax, iSeed, bInteger )

	local fRandom = USharedRandom( sID, fMin, fMax, iSeed )
	return bInteger and MRound( fRandom ) or fRandom

end


local function SortPullScript( mScript, fRandomSeed )

	mScript.mPath = istable( mScript.mPath ) and mScript.mPath[ SharedRandom( "UltrakillBase_SoundSystem_Path", 1, #mScript.mPath, fRandomSeed, true ) ] or mScript.mPath
	mScript.mVolume = istable( mScript.mVolume ) and SharedRandom( "UltrakillBase_SoundSystem_Volume", mScript.mVolume[ 1 ], mScript.mVolume[ 2 ], fRandomSeed ) or mScript.mVolume
	mScript.mPitch = istable( mScript.mPitch ) and SharedRandom( "UltrakillBase_SoundSystem_Pitch", mScript.mPitch[ 1 ], mScript.mPitch[ 2 ], fRandomSeed ) or mScript.mPitch
	mScript.mDieTime = mScript.mDieTime or SoundDuration( mScript.mPath )

end


local function ProcessSubtitles( mSystem, mSubtitle, fHoldTime )

	if not istable( mSubtitle ) and not isstring( mSubtitle ) then return false end

	if not istable( mSubtitle ) then
		
		UltrakillBase.Subtitle( mSubtitle, fHoldTime )

		return true
	
	end

	for K, V in ipairs( mSubtitle ) do

		TSimple( V[ 2 ] or 0, function()

			if not IsValid( mSystem ) then return end

			UltrakillBase.Subtitle( V[ 1 ], V[ 3 ] )

		end )

	end

	return true

end


local function ProcessVoiceScripts( mSystem, mParent, mScript )

	if not IsValid( mParent ) then return ProcessSubtitles( mSystem, mScript.mSubtitle, mScript.mOverrideHoldTime ) end

	local mPrevSystem = mParent.UltrakillBase_VoiceSystem

	if not IsValid( mPrevSystem ) then

		mParent.UltrakillBase_VoiceSystem = mSystem
		ProcessSubtitles( mSystem, mScript.mSubtitle, mScript.mOverrideHoldTime )

		return true

	end

	local fPrevPriority = mVoiceSoundScripts[ mPrevSystem:GetScriptName() ].mPriority
	local fPriority = mScript.mPriority

	if fPriority < fPrevPriority then

		mSystem:Remove()

		return false

	end

	mPrevSystem:Remove()

	mParent.UltrakillBase_VoiceSystem = mSystem
	ProcessSubtitles( mSystem, mScript.mSubtitle, mScript.mOverrideHoldTime )

	return true

end


function UltrakillBase.SoundScript( sID, vPos, eParent, fLifeTime )

	if not isstring( sID ) or not istable( mSoundScripts[ sID ] ) or not SERVER then return false end

	local sClass = ( not UltrakillBase.CompatibilityMode ) and "UltrakillBase_SoundSystem" or "UltrakillBase_SoundSystem_CSoundPatch"
	local mSystem = ECreate( sClass )
	local mVoiceScript = mVoiceSoundScripts[ sID ]

	if not IsValid( mSystem ) then return end
	if mVoiceScript then ProcessVoiceScripts( mSystem, eParent, mVoiceScript ) end

	mSystem:SetPos( vPos )
	mSystem:SetName( "UltrakillBase_SoundSystem_" .. mSystem:EntIndex() .. "_Script: " .. sID )

	if isentity( eParent ) and IsValid( eParent ) then

		mSystem:SetParent( eParent )
		eParent:DeleteOnRemove( mSystem )

	end

	mSystem:SetScriptName( sID )
	mSystem:SetRandomSeed( MRandom( -8192, 8192 ) )
	mSystem:Spawn()

	if fLifeTime and fLifeTime > 0 then SafeRemoveEntityDelayed( mSystem, fLifeTime ) end

	return mSystem

end


function UltrakillBase.PullSoundScript( sID, bSortPull, fRandomSeed )

	if not mSoundScripts[ sID ] then return end

	local mScript = TCopy( mSoundScripts[ sID ] )

	if bSortPull then SortPullScript( mScript, fRandomSeed ) end

	return mScript

end


function UltrakillBase.GetSoundScriptData( ... )

	return UltrakillBase.PullSoundScript( ... )

end


-- Custom SoundScripts -- As of 2023-05-19, You can now add your own custom sounds via a single lua file.
-- Import All Lua files under lua/ultrakillbase/Includes/CustomSounds --

DrGBase.IncludeFolder( "ultrakillbase/Includes/CustomSounds" )