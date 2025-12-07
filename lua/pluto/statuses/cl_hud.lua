local ourPanel
hook.Add("DrawOverlay","pluto_effect_hud_prototype", function()
    if(not IsValid(ourPanel)) then
        ourPanel = vgui.Create("pluto_effect_hud_box") 
    end
    ourPanel:SetPos(ScrW() * 0.015,ScrH()* 0.825)
    ourPanel:SetTall(ScrH() * 0.015)
    ourPanel:SetWide(ScrW() * 0.825)
end)