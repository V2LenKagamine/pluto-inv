--/***********************************************************************************************\--
--|-- CODE BY DEADALUS3010 - PORTED BY MEGADETH9811 - MODELS/SOUNDS FROM INFITY WARD/ACTIVISION --|--
--\***********************************************************************************************/--

-- Sound Settings
-------------------
sound.Add({
	name = 			"Weapon_BO2_T95.Magout",
	channel = 		CHAN_ITEM,
	volume = 		1.0,
	sound = 			"weapons/m27/magout.ogg"
})

sound.Add({
	name = 			"Weapon_BO2_T95.Magin",
	channel = 		CHAN_ITEM,
	volume = 		1.0,
	sound = 			"weapons/m27/magin.ogg"
})

sound.Add({
	name = 			"Weapon_BO2_T95.Bolt",
	channel = 		CHAN_ITEM,
	volume = 		1.0,
	sound = 			"weapons/m27/charge.ogg"
})

-- Main Settings
-------------------
SWEP.PrintName					= "Type 95"			
SWEP.Spawnable					= false
SWEP.AdminSpawnable 			= false
SWEP.DrawAmmo					= false									
SWEP.DrawCrosshair				= false	
SWEP.ViewModelFOV 				= 65
SWEP.ViewModel					= "models/weapons/v_bo2_type95.mdl"	
SWEP.WorldModel					= "models/weapons/w_rif_famas.mdl"
SWEP.ShowWorldModel			 	= true
SWEP.MuzzleAttachment			= "1"
SWEP.ShellEjectAttachment		= "2" 
SWEP.HoldType					= "ar2"	
SWEP.BounceWeaponIcon			= true	

-- Other Settings
-------------------
SWEP.Weight						= 30							
SWEP.AutoSwitchTo				= false					
SWEP.AutoSwitchFrom				= false
SWEP.UseHands					= true
SWEP.ViewModelFlip				= false

-- TTT settings
-------------------
SWEP.Slot         				= 2							
SWEP.SlotPos					= 2	
SWEP.AutoSpawnable				= false
SWEP.AllowDrop 					= true
SWEP.IsSilent 					= false
SWEP.NoSights 					= false
SWEP.Base 						= "weapon_tttbase"

-- Primary fire settings
-------------------
SWEP.Primary.Sound 				= "weapons/type95/fire.ogg" 
SWEP.Primary.Damage				= 15
SWEP.Primary.NumShots			= 1
SWEP.Primary.Spread				= 0.05
SWEP.Primary.RPM				= 937
SWEP.Primary.KickUp				= 0.35	
SWEP.Primary.KickDown			= 0.2	
SWEP.Primary.KickHorizontal		= 0.2	
SWEP.Primary.ClipSize			= 30		
SWEP.Primary.DefaultClip  	  	= 30
SWEP.Primary.ClipMax 			= 60	
SWEP.Primary.Tracer				= 1			
SWEP.Primary.Force				= 10
SWEP.Primary.Automatic			= true
SWEP.Primary.Ammo				= "smg1"	
SWEP.HeadshotMultiplier 		= 2.5
SWEP.Primary.IronAccuracy 		= 0.1

-- Secundary fire settings
-------------------
SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= 1
SWEP.Secondary.Ammo				= "none"
SWEP.Secondary.IronFOV			= 65

-- Other fire settings
-------------------
SWEP.CrouchModifier				= 0.2
SWEP.IronSightModifier 			= 0.001
SWEP.RunModifier 				= 0.5
SWEP.JumpModifier 				= 1.6
SWEP.Zoom1Cone					= 0.001
SWEP.ConeSpray					= 0.001
SWEP.ConeIncrement				= 0.001		
SWEP.ConeMax					= 0.001		
SWEP.ConeDecrement				= 0.001			

-- Sights
-------------------
SWEP.IronSightsPos = Vector(-6.761, -5.84, 1.96)
SWEP.IronSightsAng = Vector(0, 0, 0)
