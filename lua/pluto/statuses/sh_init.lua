pluto.statuses = pluto.statuses or {}
pluto.statuses.byname = pluto.statuses.byname or {}
pluto.statushooks = pluto.statushooks or {}

for _, filename in pairs {
    "positive/heal",
    "positive/heal_flat",
    "positive/strengthen",
    "positive/immune",
    "positive/xray",

    "negative/bleed",
    "negative/fire",
    "negative/frost",
    "negative/poison",
    "negative/shock",
    "negative/weaken",
} do
	local status = filename:match "[_%w]+$"
    STAT = pluto.statuses.byname[status] or {}
	setmetatable(STAT, pluto.statuses.mt)
	AddCSLuaFile(filename .. ".lua")
	include(filename .. ".lua")
    local stat = STAT
    STAT = nil

    local statname = stat.Name or status

    pluto.statuses.byname[statname] = stat
end
if(SERVER) then
    concommand.Add("pluto_forcereload_statuses",function (ply,cmd,args)
    if (not pluto.cancheat(ply)) then
		return
	end
    pluto.statuses.byname = {}
    AddCSLuaFile("pluto/statuses/sh_init.lua")
    include("pluto/statuses/sh_init.lua")
    ply:ChatPrint("Force-Reloaded Status Effects! Clients cant see the changes!")
    end)
end