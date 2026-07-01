function pluto.inv.readstatuseffect()
    local tname = net.ReadString()
    local hudname = net.ReadString()
    local ticks = net.ReadInt(8)
    if(tname == "RESET") then pluto.SHT = {} else 
    table.Merge(pluto.SHT or {},{[tname] = { ["HName"] = hudname,["Time"] = ticks}})
    end
end
pluto.SHT = pluto.SHT or {}
hook.Add("HUDPaint", "Pluto_Status_Hud", function()
    if(table.Count(pluto.SHT)>0) then
        local scrW,scrH = ScrW(),ScrH()
        draw.RoundedBox(10,0,scrH*0.4,scrW*0.05,scrH*0.2,Color(65,65,65,5))
        local offset = 5
        for _,data in pairs(pluto.SHT) do
            if(data.Time ~= 0 ) then
                draw.SimpleText(string.format("%s : %i",data.HName,data.Time),"pluto_test_font",1,(scrH*0.4) + offset,Color(255,255,255,170),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
                offset = offset + 15
            end
        end
    end
end)
--Todo: Do we actually need to message this? I mean it should be client sided...
hook.Add("DoPlayerDeath", "Pluto_StatusHud_Reset",function(play,atk,dmg) 
    pluto.inv.message(player.GetBySteamID64(LocalPlayer():SteamID64())):write("statuseffect","RESET","idclol",-1):send()
end)
concommand.Add("pluto_dothud_clear",function()
    pluto.SHT = {} 
end,nil,"Clear the DoT Hud, incase it broke.")