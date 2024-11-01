--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
pluto.emoji = pluto.emoji or {}
pluto.emoji.unlocks = pluto.emoji.unlocks or setmetatable({}, {
	__index = function(self, k)
		local ret = setmetatable({}, {
			__index = function()
				if (pluto.cancheat(k)) then
					return true
				end
			end
		})
		self[k] = ret
		return ret
	end
})

function pluto.emoji.init(ply)
	return Promise(function(res, rej)
		pluto.db.instance(function(db)
			local emojis = mysql_stmt_run(db, "[[SELECT * FROM pluto_emoji_unlocks WHERE steamid = ? ]]", pluto.db.steamid64(ply))
            if (emojis) then
			    for _, emoji in ipairs(emojis) do
			    	pluto.emoji.unlocks[ply][emoji.name] = true
			    end
            end
			res()
		end)
	end)
end

function pluto.inv.writeemojis(cl)
	local unlocked = {}
	for emoji in pairs(pluto.emoji.byname) do
		if (pluto.emoji.unlocks[cl][emoji]) then
			table.insert(unlocked, emoji)
		end
	end

	net.WriteUInt(#unlocked, 16)
	for _, emoji in ipairs(unlocked) do
		net.WriteString(emoji)
	end
end

concommand.Add("pluto_emoji_unlock", function(ply, cmd, args)
	if (not pluto.cancheat(ply)) then
		return
	end

	local p = args[1]
	local emoji = args[2]

	if (not tonumber(p)) then
		ply:ChatPrint "pls sid64 arg1"
		return
	end

	if (not pluto.emoji.byname[emoji]) then
		ply:ChatPrint "unknown emoji"
		return
	end

	pluto.db.instance(function(db)
		pluto.emoji.unlock(db, p, emoji)
	end)
end)

function pluto.emoji.unlock(db, ply, emoji)
	mysql_cmysql()

	mysql_stmt_run(db, "INSERT INTO pluto_emoji_unlocks (steamid, name) VALUES (?, ?)", pluto.db.steamid64(ply), emoji)

	ply = player.GetBySteamID64(pluto.db.steamid64(ply))
	if (IsValid(ply)) then
		pluto.emoji.unlocks[ply][emoji] = true
		ply:ChatPrint("You have unlocked ", pluto.emoji.byname[emoji], " :" .. emoji .. ":")
	end
end