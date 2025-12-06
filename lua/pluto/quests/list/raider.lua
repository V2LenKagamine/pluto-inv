--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
QUEST.Name = "Raider"
QUEST.Description = "Get kills in Raids mode."
QUEST.Credits = "Len"
QUEST.Color = Color(199, 84, 39)
QUEST.RewardPool = "hourly"

function QUEST:Init(data)
    data:Hook("OnNPCKilled",function (data,npc,atk,inf)
        if(not npc.raidsNPC or not atk:IsPlayer()) then return end
        data:UpdateProgress(1)
    end)
end

function QUEST:GetProgressNeeded()
	return math.random(75,125)
end