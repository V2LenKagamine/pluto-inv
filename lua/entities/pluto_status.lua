--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "base_point"
ENT.PrintName = "Base_Status"

ENT.Icon = "tttrw/disagree.png"

function ENT:Initialize()
    local baseStat = pluto.statuses.byname[self.PrintName]
    if(not baseStat) then
        pluto.error("Someone tired to spawn a status with no effect!!!")
        self:Remove()
        return false
    end
    self.IsNegative = baseStat.IsNegative or true 
    self.NoCleanse = baseStat.NoCleanse or false 
    local immune = false 
    for _,status in pairs(self:GetParent():GetChildren()) do
        if(status.Data and status.Data.IsImmunity) then
            immune = true 
            break
        end
    end
    if(immune) then
        self:Remove()
        return false
    end
    if(self.PrintName == "Base_Status") then
        pluto.error("Someone tried to spawn a status without NAMING IT!!!")
        self:Remove()
        return false
    end
    if(not self.Data)then
        pluto.error("Something made a status with NOTHING IN IT!!!")
        self:Remove()
        return false
    end
    if(not self:GetParent()) then
        pluto.error("Something made a status, but didnt parent it to anything!!!")
        self:Remove()
        return false
    end
    for k,v in pairs(self.Data) do
        if(string.StartsWith(k,"Hook")) then
            hook.Add(v[1],self.PrintName .. "_" .. self:EntIndex(),v[2])
        end
    end
    hook.Add("Tick",self,self.Tick)
    self:CallOnRemove(self,function(ent,data)
        for k,v in pairs(ent.Data) do
            if(string.StartsWith(k,"Hook")) then
                hook.Remove(v[1],self.PrintName .. "_" ..  self:EntIndex())
            end
        end
    end)
    self.Next = CurTime() + (self.Data.ThinkDelay or 1)
end

function ENT:SetupDataTables()
    self.Data = {}
    self.IsNegative = false 
    self.NoCleanse = false 
    self.Expired = false
end

function ENT:Tick()
    if(not SERVER or (self.Next and self.Next > CurTime())) then return end
    if(not self.Data or not self:GetParent():Alive() or not IsValid(self) or self.Expired) then
        self:Remove()
        return
    end
    if(IsValid(self) and pluto.statuses.byname[self.PrintName].DoThink) then
        pluto.statuses.byname[self.PrintName]:DoThink(self)
    end
    self.Data.TicksLeft = (self.Data.TicksLeft or 0) - 1
    if(IsValid(self) and self.Data.TicksLeft < 1 and not self.Data.DontExpire and not self.Expired) then
        if(pluto.statuses.byname[self.PrintName].OnExpire) then
            pluto.statuses.byname[self.PrintName]:OnExpire(self)
        end
        self.Expired = true
        return 
    end
    self.Next = CurTime() + (self.Data.ThinkDelay or 1)
end

function ENT:NetVar(name, type, default, notify)
	if (not self.NetVarTypes) then
		self.NetVarTypes = {}
	end

	local id = self.NetVarTypes[type] or 0
	self.NetVarTypes[type] = id + 1
	self:NetworkVar(type, id, name)

	if (default ~= nil) then
		self["Set"..name](self, default)
	end

	if (notify) then
		self:NetworkVarNotify(name, self.NetworkVarNotifyCallback)
	end
end