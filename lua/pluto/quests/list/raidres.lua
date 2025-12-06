--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
QUEST.Name = "Raid Scorehog"
QUEST.Description = "Reach at least 150 score in Raid mode."
QUEST.Credits = "Len"
QUEST.Color = Color(199, 84, 39)
QUEST.RewardPool = "hourly"

function QUEST:Init(data)
    data:Hook("OnNPCKilled",function (data,npc,atk,inf)
        if(not npc.raidsNPC or not atk:IsPlayer()) then return end
        if(pluto.RAIDS.raidScores[atk] < 150) then return end
        data:UpdateProgress(1)
    end)
end

function QUEST:GetProgressNeeded()
	return 1
end