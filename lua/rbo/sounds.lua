local function FastList(name,ex,num)
	local list={}
	for i=1,num do
		if i<10 then
			table.insert(list,name..'0'..i..'.'..ex)
		else
			table.insert(list,name..i..'.'..ex)
		end
	end
	return list
end

sound.Add({
	name="rbo_passby_762_close",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/762/crack_rifle_762_close_","ogg",34)
})

sound.Add({
	name="rbo_passby_762_medium",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/762/crack_rifle_762_medium_","ogg",13)
})

sound.Add({
	name="rbo_passby_762_far",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch={0,100},
	sound=FastList("rbo_passby/762/crack_rifle_762_far_","ogg",12)
})

sound.Add({
	name="rbo_passby_762_wizz",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/762/wizz_rifle_762_medium_","ogg",16)
})

sound.Add({
	name="rbo_passby_556_close",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/556/crack_rifle_556_close_","ogg",10)
})

sound.Add({
	name="rbo_passby_556_medium",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/556/crack_rifle_556_medium_","ogg",11)
})

sound.Add({
	name="rbo_passby_556_far",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/556/crack_rifle_556_far_","ogg",11)
})

sound.Add({
	name="rbo_passby_556_wizz",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/556/wizz_rifle_556_medium_","ogg",11)
})

sound.Add({
	name="rbo_passby_hiss_close",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/hiss/passby_crack_hiss_","ogg",15)
})

sound.Add({
	name="rbo_passby_9mm",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/wizz/flyby_9mm_medium_","ogg",21)
})

sound.Add({
	name="rbo_passby_9mm_2",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/wizz/wizz_pistol_medium_","ogg",22)
})

sound.Add({
	name="rbo_passby_hiss_far",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/hiss/passby_crack_hiss_far_","ogg",29)
})

sound.Add({
	name="rbo_passby_wizz",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/wizz/flyby_9mm_medium_","ogg",21)
})

sound.Add({
	name="rbo_passby_wizz_2",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/wizz/wizz_pistol_medium_","ogg",22)
})

sound.Add({
	name="rbo_passby_50_close",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/50cal/crack_50cal_close_","ogg",12)
})

sound.Add({
	name="rbo_passby_50_medium",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/50cal/crack_50cal_mid_","ogg",12)
})

sound.Add({
	name="rbo_passby_50_medium_2",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/50cal/crack_50cal_mid_new_","ogg",17)
})

sound.Add({
	name="rbo_passby_50_far",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/50cal/crack_50cal_far_","ogg",8)
})

sound.Add({
	name="rbo_passby_50_far_2",
	channel=CHAN_STATIC,
	volume=1,
	level=80,
	pitch=100,
	sound=FastList("rbo_passby/50cal/crack_50cal_far_new_","ogg",19)
})

--sound caching causes weird framerate hitches

--[[
util.PrecacheSound("rbo_passby_762_close")
util.PrecacheSound("rbo_passby_762_medium")
util.PrecacheSound("rbo_passby_762_far")
util.PrecacheSound("rbo_passby_762_wizz")

util.PrecacheSound("rbo_passby_50_close")
util.PrecacheSound("rbo_passby_50_medium")
util.PrecacheSound("rbo_passby_50_medium_2")
util.PrecacheSound("rbo_passby_50_far")
util.PrecacheSound("rbo_passby_50_far_2")

util.PrecacheSound("rbo_passby_556_close")
util.PrecacheSound("rbo_passby_556_medium")
util.PrecacheSound("rbo_passby_556_far")
util.PrecacheSound("rbo_passby_556_wizz")

util.PrecacheSound("rbo_passby_9mm")
util.PrecacheSound("rbo_passby_9mm_2")

util.PrecacheSound("rbo_passby_hiss_close")
util.PrecacheSound("rbo_passby_hiss_far")

util.PrecacheSound("rbo_passby_wizz")
util.PrecacheSound("rbo_passby_wizz_2")
]]