local PANEL = {}

function PANEL:Init()
    self:SetSize(20,350)
    self:DockMargin(2,2,2,2)
    self.Stati = {}
    hook.Add("pluto_status_added",self,self.AddEffect)
end

function PANEL:Paint(w,h)
    surface.SetDrawColor(128,128,128,120)
    surface.DrawTexturedRect(self:GetX(),self:GetY(),self:GetWide(),self:GetTall())
end

function PANEL:AddEffect(basestat,status)
    if(status:GetParent() ~= LocalPlayer()) then return end
    if(not status.Data) then return end
    local newStat = self:Add("pluto_effect_hud")

    newStat:AddEffect(basestat,status)
    newStat:Dock(LEFT)
    self.Stati:Insert(newStat)
end

vgui.Register("pluto_effect_hud_box", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
    self.Image = self:Add("DImage")
end

AccessorFunc(PANEL,"Time","Time")
AccessorFunc(PANEL,"Level","Level")

function PANEL:AddEffect(basestat,status)
    if(status:GetParent() ~= LocalPlayer()) then return end
    if(not status.Data) then return end
    if(not self.BaseStatus) then
        self:SetEffect(basestat,status)
    end
end

function PANEL:SetEffect(basestat,effect)
    self.BaseStatus = basestat
    if(basestat) then
        self.Image:SetImage("pluto/stathud/" .. basestat.Icon .. ".png" or "pluto/stathud/unknown.png")
        self:SetTime(status.Data.TicksLeft/(status.Data.ThinkDelay or 1))
        self:SetLevel(status.Data.Stax or 1)
    else
        SetImage(nil)
    end
end

vgui.Register("pluto_effect_hud",PANEL,"ttt_curved_panel")