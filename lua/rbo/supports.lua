--[[
	Passby is a function that can be overriden, it has 2 parameters,
	distance and position. These parameters describe the closest approach
	of a bullet

	Passby=function(distance,position)
		if distance<512 then
			RBOEmitSound("crack.wav",position)
		else
			RBOEmitSound("crack_far.wav",position)
		end
	end

	You don't need to add support for every ammo type as they will
	assume a default type, these are here because they might change
]]

RBOAddSupport({
	ammo="357",
	velocity=48000,
	Passby=RBOPlay50CalGeneric
})

RBOAddSupport({
	ammo="Pistol",
	velocity=36000,
	Passby=RBOPlayPistolGeneric
})

RBOAddSupport({
	ammo="AlyxGun",
	velocity=28000,
	Passby=RBOPlayPistolGeneric
})

RBOAddSupport({
	ammo="SMG1",
	velocity=48000,
	Passby=RBOPlayRifle556Generic
})

RBOAddSupport({
	ammo="Buckshot",
	velocity=48000,
	Passby=RBOPlayRifle556Generic
})