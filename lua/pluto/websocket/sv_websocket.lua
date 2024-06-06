--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
require "gwsockets"

local cross_id = CreateConVar("pluto_cross_id", "unknown", FCVAR_ARCHIVE)

local config = util.JSONToTable(file.Read("cfg/pluto.json", "GAME")).nix
local apikey = util.JSONToTable(file.Read("cfg/pluto.json", "GAME")).steam.apikey

if (pluto.WS) then
	pluto.WS:close()
end

pluto.WS = GWSockets.createWebSocket("ws://" .. config.host .. ":" .. config.port)
local WS = pluto.WS

function WS:onMessage(msg)
	local json = util.JSONToTable(msg)
	if (not json) then
		return
	end

	if (json.type == "msg") then
		local h, s, v = ColorToHSV(ttt.roles.Innocent.Color)
		s = s - 0.5

		local col = HSVToColor(h, s, v)
		col = Color(col.r, col.g, col.b, col.a)

		local data = {"#", col, "[" .. json.from .. "] ", json.author, white_text, ": " .. json.content}
		pluto.inv.message(player.GetAll())
			:write("chatmessage", data, "Cross", false)
			:send()
	else
		hook.Run("PlutoWebsocketMessage", json)
	end
end

function WS:onError(err)
	pluto.WS = nil
end

function WS:onConnected()
	print "connectado"
	pluto.WS = WS
end

function WS:onDisconnected()
	print "disconnectado"
	pluto.WS = nil
end

WS:open()
WS:write(util.TableToJSON {
	client_name = cross_id:GetString(),
	client_type = "gmod",
	client_secret = config.secret
})

hook.Add("DoPlutoCrossChat", "pluto_cross_chat", function(ply, content)
	if (not pluto.WS) then
		return
	end
	print(ply, content)

	local texts = {}
	for i = 2, #content do
		local data = content[i]

		if (isstring(data)) then
			table.insert(texts, data)
		elseif (data.GetPrintName) then
			table.insert(texts, data:GetPrintName())
		else
			table.insert(texts, "<unknown>")
		end
	end

	local text = table.concat(texts, "")

	if (not text or text == "") then
		return
	end

	pluto.WS:write(util.TableToJSON {
		type = "msg",
		author = ply:Nick(),
		content = text,
		from = cross_id:GetString(),
		avatar = ply.AvatarURL,
	})

	pluto.inv.message(player.GetAll())
		:write("chatmessage", {"#", ply, ": ", text}, "Cross", false)
		:send()
	return ""
end)

local function get_for_player(ply)
	if (ply.AvatarURL or ply:IsBot()) then
		return
	end

	http.Fetch("http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. apikey .. "&steamids=" .. ply:SteamID64(), function(dat)
		if (not dat) then
			return
		end

		local json = util.JSONToTable(dat)
		if (not json or not json.response or not json.response.players) then
			return
		end

		ply.AvatarURL = json.response.players[1].avatarfull
	end)
end
for _, ply in pairs(player.GetAll()) do
	get_for_player(ply)
end

hook.Add("PlayerAuthed", "pluto_data", get_for_player)