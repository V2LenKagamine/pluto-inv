--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
function pluto.ui.rightclickmenu(item, pre)
	local rightclick_menu = DermaMenu()

	if (pre) then
		pre(rightclick_menu, item)
	end

	local is_owner = item.Owner == LocalPlayer():SteamID64()

    local tab = pluto.cl_inv[item.TabID]

    if(tab and tab.Type ~= "buffer") then
        rightclick_menu:AddOption("Equip", function()
            pluto.inv.equip(item)
        end):SetIcon("icon16/add.png")
    end
	rightclick_menu:AddOption("Upload item stats", function()
		local StatsRT = GetRenderTarget("ItemStatsRT" .. ScrW() .. "_" ..  ScrH(), ScrW(), ScrH())
		PLUTO_OVERRIDE_CONTROL_STATUS = true
		local show = pluto.ui.showcase(item)
		pluto.ui.showcasepnl = nil
		show:SetPaintedManually(true)
		local item_name = item:GetPrintName()
		timer.Simple(0, function()
			hook.Add("PostRender", "Upload", function()
				hook.Remove("PostRender", "Upload")
				PLUTO_OVERRIDE_CONTROL_STATUS = false
				cam.Start2D()
				render.PushRenderTarget(StatsRT)
				if (not pcall(show.PaintManual, show)) then
					Derma_Message("Encountered an error while generating the image! Please try again.", "Upload failed", "Thanks")

					render.Clear(0, 0, 0, 0)
					render.PopRenderTarget(StatsRT)
					cam.End2D()
					show:Remove()
				return end
				local data = render.Capture {
					format = "png",
					quality = 100,
					h = show:GetTall(),
					w = show:GetWide(),
					x = 0,
					y = 0,
					alpha = false,
				}
				render.Clear(0, 0, 0, 0)
				render.PopRenderTarget(StatsRT)
				cam.End2D()
				show:Remove()
				
				imgur.image(data, "gun", string.format("%s's %s", LocalPlayer():SteamID64() == item.Owner and LocalPlayer():Nick() or "Unknown", item_name)):next(function(data)
					SetClipboardText(data.data.link)
					chat.AddText("Screenshot link made! Paste from your clipboard.")
				end):catch(function()
				end)
			end)
		end)
	end):SetIcon("icon16/camera.png")

    if (tab and tab.Type ~= "buffer") then
        if (is_owner) then
            if (not item.Locked and item.Nickname) then
                rightclick_menu:AddOption("Remove name (100 hands)", function()
                    item.Nickname = nil
                    pluto.inv.message()
                        :write("unname", item.ID)
                        :send()
                end):SetIcon("icon16/cog_delete.png")
            end

            rightclick_menu:AddOption("Copy Chat Link", function()
                SetClipboardText("{item:" .. item.ID .. "}")
            end):SetIcon("icon16/book.png")

            if (item.Type ~= "Shard") then
                rightclick_menu:AddOption("Toggle locked", function()
                    pluto.inv.message()
                        :write("itemlock", item.ID)
                        :send()
                end):SetIcon("icon16/lock.png")
            end

            if (not item.Untradeable) then
                rightclick_menu:AddOption("List item on Divine Market", function()
                    pluto.ui.listitem(item)
                end):SetIcon "icon16/money_add.png"
            end
        end

        if (not pluto_disable_constellations:GetBool()) then
            local class = baseclass.Get(item.ClassName)
            if(class.Slot == 1 or class.Slot == 2 ) then
                if (item.Type == "Weapon" and (item.Owner == LocalPlayer():SteamID64() or item.constellations)) then
                    rightclick_menu:AddOption("Open Constellations", function()
                        pluto.ui.showconstellations(item)
                    end):SetIcon "icon16/star.png"
                end
                if(item.constellations) then
                    rightclick_menu:AddOption("ReRoll Constellations",function()
                        pluto.ui.rerollconstellations(item)
                    end):SetIcon "icon16/asterisk_yellow.png"
                end
            end
        end
    end

	if (LocalPlayer():GetUserGroup() == "developer" or LocalPlayer():GetUserGroup() == "meepen" or pluto.cancheat(LocalPlayer())) then
		local dev,devop = rightclick_menu:AddSubMenu("Developer")
        devop:SetIcon("icon16/wrench.png")
		dev:AddOption("Duplicate", function()
			RunConsoleCommand("pluto_item_dupe", item.ID)
		end):SetIcon("icon16/cog_add.png")
		dev:AddOption("Copy ID", function()
			SetClipboardText(item.ID)
		end):SetIcon("icon16/cog_edit.png")
		dev:AddOption("Copy Class Name", function()
			SetClipboardText(item.ClassName)
		end):SetIcon("icon16/emoticon_tongue.png")
	    dev:AddOption("Copy item JSON", function()
		    SetClipboardText(util.TableToJSON(item))
	    end):SetIcon("icon16/newspaper_link.png")
	end
    
    if (tab) then
        rightclick_menu:AddOption("Destroy or Shard Item", function()
			pluto.divine.confirm("Destroy " .. item:GetPrintName(), function()
				local tab = pluto.cl_inv[item.TabID]
				tab.Items[item.TabIndex] = nil
				hook.Run("PlutoItemUpdate", nil, item.TabID, item.TabIndex)

				pluto.inv.message()
					:write("itemdelete", item.TabID, item.TabIndex, item.ID)
					:send()
			end)
		end):SetIcon("icon16/bomb.png")
    end

	rightclick_menu:Open()
	rightclick_menu:SetPos(input.GetCursorPos())--s
end