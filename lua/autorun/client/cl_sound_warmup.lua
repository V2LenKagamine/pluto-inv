if (SERVER) then return end

local cv_enabled = CreateClientConVar("pluto_soundwarm", "1", true, false, "Warm weapon sounds into the OS cache to stop first-shot stutter.")
local cv_budget = CreateClientConVar("pluto_soundwarm_budget", "1.5", true, false, "Milliseconds per frame to spend warming sounds.", 0, 8)

-- Directories we load
local ROOTS = {
	"sound/weapons",
	"sound/tfa_cso2",
	"sound/razorswep",
	"sound/physics/flesh",
	"sound/pluto",
}

local EXTENSIONS = {
	ogg = true,
	wav = true,
	mp3 = true,
}

-- Skip anything big enough to be music
local MAX_BYTES = 2 * 1024 * 1024
local MAX_QUEUE = 6000
local START_DELAY = 5

local SOUND_CHARS = {
	["*"] = true, ["#"] = true, ["@"] = true, [">"] = true,
	["<"] = true, ["^"] = true, ["("] = true, [")"] = true,
	["}"] = true, ["$"] = true, ["!"] = true, ["?"] = true,
	["&"] = true, ["~"] = true, ["+"] = true, ["%"] = true,
}

local queue = {}
local qhead = 1
local priority = {}
local dirstack = {}
local seen = {}
local pushed = 0
local warmed = 0

local function Normalize(path)
	while (#path > 0 and SOUND_CHARS[string.sub(path, 1, 1)]) do
		path = string.sub(path, 2)
	end

	path = string.lower(string.gsub(path, "\\", "/"))

	-- Engine sound paths are relative to sound/ but half the tables in this codebase write the prefix in and half dont
	if (string.sub(path, 1, 6) == "sound/") then
		path = string.sub(path, 7)
	end

	return "sound/" .. path
end

local function Push(path, prio)
	if (seen[path]) then
		return
	end

	if (not prio and pushed >= MAX_QUEUE) then
		return
	end

	seen[path] = true
	pushed = pushed + 1

	if (prio) then
		priority[#priority + 1] = path
	else
		queue[#queue + 1] = path
	end
end

--- Pull one file through the cache and immediately discard it
local function Warm(path)
	local f = file.Open(path, "rb", "GAME")

	if (not f) then
		return
	end

	local size = f:Size()

	if (size > 0 and size <= MAX_BYTES) then
		f:Read(size)
		warmed = warmed + 1
	end

	f:Close()
end

local function Scan(dir)
	local files, dirs = file.Find(dir .. "/*", "GAME")

	for _, name in ipairs(files or {}) do
		local ext = string.match(name, "%.(%w+)$")

		if (ext and EXTENSIONS[string.lower(ext)]) then
			Push(string.lower(dir .. "/" .. name), false)
		end
	end

	for _, name in ipairs(dirs or {}) do
		dirstack[#dirstack + 1] = dir .. "/" .. name
	end
end

local function Collect(name, out)
	if (not isstring(name) or name == "") then
		return
	end

	local props = sound.GetProperties(name)

	if (props and props.sound) then
		if (istable(props.sound)) then
			for _, snd in pairs(props.sound) do
				if (isstring(snd)) then
					out[#out + 1] = Normalize(snd)
				end
			end
		elseif (isstring(props.sound)) then
			out[#out + 1] = Normalize(props.sound)
		end

		return
	end

	if (string.find(name, "%.%w%w%w?$")) then
		out[#out + 1] = Normalize(name)
	end
end

--- Sound files a weapon can play
--- SWEP table recursively would drag in entities and cost more than it saves
local function WeaponSounds(wep)
	local out = {}

	if (not IsValid(wep)) then
		return out
	end

	local tbl = wep:GetTable() or {}

	for _, key in ipairs({"Primary", "Secondary"}) do
		if (istable(tbl[key])) then
			Collect(tbl[key].Sound, out)
		end
	end

	if (istable(tbl.Sounds)) then
		for _, v in pairs(tbl.Sounds) do
			if (isstring(v)) then
				Collect(v, out)
			elseif (istable(v)) then
				for _, snd in pairs(v) do
					Collect(snd, out)
				end
			end
		end
	end

	for _, key in ipairs({"ReloadSound", "DrawSound", "HolsterSound"}) do
		Collect(tbl[key], out)
	end

	return out
end

local function Step()
	local prio = table.remove(priority)

	if (prio) then
		Warm(prio)
		return true
	end

	if (queue[qhead]) then
		local path = queue[qhead]
		qhead = qhead + 1
		Warm(path)
		return true
	end

	local dir = table.remove(dirstack)

	if (dir) then
		Scan(dir)
		return true
	end

	return false
end

local started = 0
local active

local function Start()
	if (started ~= 0) then
		return
	end

	started = SysTime() + START_DELAY

	for _, root in ipairs(ROOTS) do
		dirstack[#dirstack + 1] = root
	end
end

hook.Add("InitPostEntity", "pluto_soundwarm_init", Start)
timer.Simple(30, Start) -- in case the hook already fired before we loaded

hook.Add("Think", "pluto_soundwarm", function()
	if (not cv_enabled:GetBool() or started == 0 or SysTime() < started) then
		return
	end

	local ply = LocalPlayer()

	if (IsValid(ply)) then
		local wep = ply:GetActiveWeapon()

		if (wep ~= active) then
			active = wep

			for _, path in ipairs(WeaponSounds(wep)) do
				Push(path, true)
			end
		end
	end

	local deadline = SysTime() + cv_budget:GetFloat() / 1000

	repeat
		if (not Step()) then
			return
		end
	until (SysTime() >= deadline)
end)

concommand.Add("pluto_soundwarm_status", function()
	MsgN(string.format(
		"[soundwarm] queued %d | warmed %d | remaining %d | dirs left %d | priority %d",
		pushed, warmed, math.max(pushed - qhead + 1, 0), #dirstack, #priority
	))
end)
