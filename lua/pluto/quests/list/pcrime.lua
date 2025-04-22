--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
QUEST.Name = "Perfect Crime"
QUEST.Description = "Prevent the bodies of your victims from being discovered"
QUEST.Credits = "Froggy & add__123"
QUEST.Color = Color(204, 43, 75)
QUEST.RewardPool = "daily"

function QUEST:Init(data)
	local ragdolls = {}
	data:Hook("PlayerRagdollCreated", function(data, ply, rag, atk)
		if (atk == data.Player and atk:GetRoleTeam() ~= ply:GetRoleTeam()) then
			ragdolls[rag] = true
		end
	end)

	data:Hook("TTTEndRound", function(data)
		data:UpdateProgress(table.Count(ragdolls))
		ragdolls = {}
	end)

	data:Hook("TTTRWPlayerInspectBody", function(data, ply, ent, pos, is_silent)
		if (not is_silent) then
			ragdolls[ent] = nil
		end
	end)
end

function QUEST:GetProgressNeeded()
	return math.random(25, 30)
end