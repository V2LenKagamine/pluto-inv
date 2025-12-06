--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
function pluto.inv.writequest(ply, quest)
	net.WriteUInt(quest.RowID, 32)

	local QUEST = quest:GetQuestData()

	net.WriteString(QUEST.Name)
	net.WriteString(QUEST.Description)
	net.WriteColor(QUEST.Color)
	net.WriteString(quest.Type)

	net.WriteBool(QUEST.Credits)
	if (QUEST.Credits) then
		net.WriteString(QUEST.Credits)
	end

	net.WriteString(pluto.quests.poolrewardtext(quest.RewardData, quest))

	net.WriteInt(quest.EndTime - os.time(), 32)
	net.WriteUInt(quest.ProgressLeft, 32)
	net.WriteUInt(quest.TotalProgress, 32)
end

function pluto.inv.writequests(ply)
	local quests = pluto.quests.players(ply)

	if (not quests) then
		net.WriteBool(false)
		return
	end

	for _, quest in ipairs(quests) do
		if (quest.Dead) then
			continue
		end

		net.WriteBool(true)
		pluto.inv.writequest(ply, quest)
	end
	net.WriteBool(false)
end

function pluto.inv.readrerollquest()
    local qid = tonumber(net.ReadUInt(32))
    local pid = net.ReadString()
    local ply = player.GetBySteamID64(pid)
    if(ply) then
        pluto.db.transact(function (db)
            if(not pluto.inv.addcurrency(db,pid,"dice",-25)) then
                mysql_rollback(db)
                ply:ChatPrint("You need 25 dice to re-roll a quest...")
                return
            end
            mysql_stmt_run(db, "SELECT idx from pluto_quests_new WHERE owner = ? FOR UPDATE", pid)
	        mysql_stmt_run(db, "DELETE FROM pluto_quests_new WHERE owner = ? AND idx = ?", pid,qid)
            local quests = pluto.quests.players(ply)
            for idx,quest in ipairs(quests) do 
                if(quest.RowID == qid) then
                    table.remove(pluto.quests.players(ply),idx)
                end 
            end
            pluto.quests.repopulatequests(db,ply)
            mysql_commit(db)
        end)
    end
    pluto.inv.message(ply)
		:write "quests"
		:send()
end



-- DEV SERVER RELOAD
-- also geralt gay
for _, ply in pairs(player.GetHumans()) do
	pluto.inv.message(ply)
		:write "quests"
		:send()
end