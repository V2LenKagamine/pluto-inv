--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local PANEL = {}

PANEL.ResultRow = 6
PANEL.ResultColumn = 6
PANEL.Padding = 3

function PANEL:Init()
	self.ResultArea = self:Add "EditablePanel"
	self.ResultArea:Dock(RIGHT)
	self.ResultArea:SetWide(self.ResultColumn * pluto.ui.sizings "ItemSize" + (self.ResultColumn - 1) * self.Padding)

	self.ItemArea = self.ResultArea:Add "EditablePanel"
	self.ItemArea:SetTall(self.ResultRow * pluto.ui.sizings "ItemSize" + (self.ResultRow + 1) * self.Padding)
	self.ItemArea:SetZPos(1)
	self.ItemArea:Dock(TOP)

	self.Results = {}
	self.ResultPrices = {}

	for y = 1, self.ResultRow do
		local row = self.ItemArea:Add "EditablePanel"
		row:Dock(TOP)
		row:DockMargin(0, y == 1 and self.Padding or 0, 0, self.Padding)
		row:SetTall(pluto.ui.sizings "ItemSize")

		for x = 1, self.ResultColumn do
			local itempnl = row:Add "pluto_inventory_item"
			itempnl:Dock(LEFT)
			itempnl:SetWide(pluto.ui.sizings "ItemSize")
			itempnl:DockMargin(x == 1 and 0 or self.Padding, 0, 0, 0)
			table.insert(self.Results, itempnl)

			function itempnl:OnRightClick()
				if (not self.Item) then
					return
				end

				pluto.ui.rightclickmenu(self.Item, function(menu, item)
					menu:AddOption("Buy for " .. self.Item.Price .. " droplets", function()
						pluto.divine.confirm("Buy " .. self.Item:GetPrintName(), function()
							RunConsoleCommand("pluto_auction_buy", self.Item.ID)
						end)
					end):SetIcon "icon16/money_delete.png"
				end)
			end
			itempnl.OnLeftClick = itempnl.OnRightClick

			local container = itempnl.ItemPanel:Add "ttt_curved_panel_outline"
			container:SetCurve(4)
			container:SetColor(pluto.ui.theme "InnerColorSeperator")
			container:Dock(BOTTOM)

			local container_fill = container:Add "ttt_curved_panel"
			container_fill:SetCurve(4)
			container_fill:Dock(FILL)
			container_fill:SetColor(Color(52, 51, 52))

			local price = container_fill:Add "pluto_label"
			price:Dock(FILL)
			price:SetText "0"
			price:SetContentAlignment(6)
			price:SetFont "pluto_inventory_font"
			price:SetTextColor(pluto.ui.theme "TextActive")
			price:SetRenderSystem(pluto.fonts.systems.shadow)
			price:SizeToContentsY()
			price:SetVisible(false)

			container:SetTall(price:GetTall())

			local img = container_fill:Add "DImage"
			img:SetImage(pluto.currency.byname.droplet.Icon)
			img:Dock(RIGHT)
			function img.PerformLayout(s, w, h)
				img:SetWide(h)
			end

			table.insert(self.ResultPrices, price)
		end
	end

	self.Pagination = self.ResultArea:Add "EditablePanel"
	self.Pagination:Dock(FILL)
	self.Pagination:DockMargin(0, 0, 0, self.Padding)

	self.PaginationLabel = self.Pagination:Add "pluto_label"
	self.PaginationLabel:SetFont "pluto_inventory_font"
	self.PaginationLabel:SetRenderSystem(pluto.fonts.systems.shadow)
	self.PaginationLabel:SetText "hi"
	self.PaginationLabel:SetTextColor(pluto.ui.theme "TextActive")
	self.PaginationLabel:SetContentAlignment(5)

	self.StardustLabel = self:Add "pluto_label"
	self.StardustLabel:SetFont "pluto_inventory_font"
	self.StardustLabel:SetRenderSystem(pluto.fonts.systems.shadow)
	self.StardustLabel:SetText "hi"
	self.StardustLabel:SetTextColor(pluto.ui.theme "TextActive")
	self.StardustLabel:SetContentAlignment(5)
	self.StardustImage = self:Add "DImage"
	self.StardustImage:SetImage(pluto.currency.byname.droplet.Icon)

	self.PageDown = self.Pagination:Add "pluto_label"
	self.PageDown:SetCursor "hand"
	self.PageDown:SetMouseInputEnabled(true)
	self.PageDown:SetFont "pluto_inventory_font"
	self.PageDown:SetRenderSystem(pluto.fonts.systems.shadow)
	self.PageDown:SetText "<<"
	self.PageDown:SetTextColor(pluto.ui.theme "TextActive")
	self.PageDown:SetContentAlignment(5)
	function self.PageDown.OnMousePressed()
		local page = self:GetPage() - 1
		if (page < 1) then
			return
		end
		self:SearchPage(page)
	end


	self.PageUp = self.Pagination:Add "pluto_label"
	self.PageUp:SetCursor "hand"
	self.PageUp:SetMouseInputEnabled(true)
	self.PageUp:SetFont "pluto_inventory_font"
	self.PageUp:SetRenderSystem(pluto.fonts.systems.shadow)
	self.PageUp:SetText ">>"
	self.PageUp:SetTextColor(pluto.ui.theme "TextActive")
	self.PageUp:SetContentAlignment(5)

	function self.PageUp.OnMousePressed()
		local page = self:GetPage() + 1
		if (page > self:GetPageMax()) then
			return
		end
		self:SearchPage(page)
	end

	function self.Pagination.PerformLayout()
		self.PaginationLabel:Center()
		self.PageDown:SetTall(self.PaginationLabel:GetTall())
		self.PageUp:SetTall(self.PaginationLabel:GetTall())
		local x, y = self.PaginationLabel:GetPos()
		self.PageDown:SetPos(x - self.PageDown:GetWide() - self.Padding, y)
		self.PageUp:SetPos(x + self.PaginationLabel:GetWide() + self.Padding, y)
		self.SearchAreaContainer:DockMargin(self.Padding * 1, self.Padding, self.Padding * 2, self.Pagination:GetTall() + self.Padding * 2)
	end

	self.SearchAreaContainer = self:Add "ttt_curved_panel_outline"
	self.SearchAreaContainer:Dock(FILL)
	self.SearchAreaContainer:SetColor(pluto.ui.theme "InnerColorSeperator")
	self.SearchAreaContainer:SetCurve(4)
	self.SearchAreaContainer:DockPadding(self.Padding + 1, self.Padding + 1, self.Padding + 1, self.Padding + 1)

	self.SearchArea = self.SearchAreaContainer:Add "pluto_inventory_auction_search"
	self.SearchArea:Dock(FILL)
	function self.SearchArea.StartNewSearch()
		self:StartNewSearch()
	end
	self.WeaponSearchArea = self.SearchArea:AddTab "Weapon"

	local type = self.WeaponSearchArea:Add "pluto_inventory_auction_search_dropdown"
	type:SetText "Weapon Slot:"
	type:AddOption "Any"
	type:AddOption "Primary"
	type:AddOption "Secondary"
	type:AddOption "Melee"
	type:AddOption "Grenade"
	--type:AddOption "Tool"
	--type:AddOption "Hands"
	type:Dock(TOP)
	
	--[[local ammotype = self.WeaponSearchArea:Add "pluto_inventory_auction_search_dropdown"
	ammotype:SetText "Choose ammo type:"
	ammotype:AddOption "Any"
	ammotype:AddOption "Sniper"
	ammotype:AddOption "Pistol"
	ammotype:AddOption "SMG"
	ammotype:AddOption "None"
	ammotype:Dock(TOP)--]]

	local mod_count = self.WeaponSearchArea:Add "pluto_inventory_auction_search_input_two"
	mod_count:Dock(TOP)
	mod_count:SetText "Mod Count:"

	--[[local current_mods = self.WeaponSearchArea:Add "pluto_inventory_auction_search_input_two"
	current_mods:Dock(TOP)
	current_mods:SetText "Current mods:"

	local current_suffixes = self.WeaponSearchArea:Add "pluto_inventory_auction_search_input_two"
	current_suffixes:Dock(TOP)
	current_suffixes:SetText "Current suffixes:"

	local current_prefixes = self.WeaponSearchArea:Add "pluto_inventory_auction_search_input_two"
	current_prefixes:Dock(TOP)
	current_prefixes:SetText "Current prefixes:"--]]

	self.WeaponSearchArea:InvalidateChildren(true)
	self.WeaponSearchArea:SizeToChildren(false, true)

	self.SearchArea:AddTab "Model"

	self.ShardSearch = self.SearchArea:AddTab "Shard"

	local mod_count = self.ShardSearch:Add "pluto_inventory_auction_search_input_two"
	mod_count:Dock(TOP)
	mod_count:SetText "Mod Count:"
	self.ShardSearch:InvalidateChildren(true)
	self.ShardSearch:SizeToChildren(false, true)

	self:SetPageMax(0)
	self:SetPage(0)

	hook.Add("PlutoReceiveAuctionData", self, self.PlutoReceiveAuctionData)
	self:StartNewSearch()
end

local print_updated = false -- Confirmation message for when a player updates the search filters

function PANEL:PlutoReceiveAuctionData(items, pages)
	if (print_updated) then
		print_updated = false
		chat.AddText "Marketplace filters updated!"
	end

	self:SetPageMax(pages)

	for i = 1, 36 do
		local item = items[i]
		self.Results[i]:SetItem(item)
		local price = self.ResultPrices[i]

		price:SetVisible(item)
		if (item) then
			price:SetText(item.Price)
		end
	end
end

function PANEL:UpdatePages()
	if (not self.Page or not self.PageMax) then
		return
	end

	self.PaginationLabel:SetText(string.format("Page %i / %i", self.Page, self.PageMax))
	self.PaginationLabel:SizeToContents()
	self.PaginationLabel:Center()

	self.PageDown:SetVisible(self.Page > 1)
	self.PageUp:SetVisible(self.Page < self.PageMax)
end

function PANEL:SetPageMax(max)
	self.PageMax = max
	self:UpdatePages()
end

function PANEL:GetPageMax()
	return self.PageMax
end

function PANEL:SearchPage(page)
	self:SetPage(page)
	self:SendSearch()
end

function PANEL:SetPage(num)
	self.Page = num
	self:UpdatePages()
end

function PANEL:GetPage()
	return self.Page
end

function PANEL:StartNewSearch()
	self.Parameters = self.SearchArea:GetCurrentSearchParameters()

	self:SearchPage(1)
end

function PANEL:SendSearch()
	pluto.inv.message()
		:write("auctionsearch", self:GetPage(), self.Parameters)
		:send()
end

function PANEL:Think()
	local text = tostring(pluto.cl_currency.droplet or 0)
	if (text ~= self.StardustLabel:GetText()) then
		self.StardustLabel:SetText(text)
		self.StardustLabel:SizeToContents()
		self.StardustImage:SetSize(self.StardustLabel:GetTall(), self.StardustLabel:GetTall())
		self.StardustLabel:CenterHorizontal()
		self.StardustImage:SetPos(self.StardustLabel:GetPos())
		self.StardustImage:MoveRightOf(self.StardustLabel, self.Padding)
	end
end

function PANEL:PerformLayout(w, h)
	self.StardustLabel:SetPos(0, h - self.StardustLabel:GetTall() - 2)
	self.StardustLabel:CenterHorizontal()
	self.StardustImage:SetPos(self.StardustLabel:GetPos())
	self.StardustImage:MoveRightOf(self.StardustLabel, self.Padding)
end

vgui.Register("pluto_inventory_auction", PANEL, "EditablePanel")

local PANEL = {}

PANEL.Padding = 3
PANEL.InactiveColor = Color(55, 54, 55)
PANEL.ActiveColor = Color(50, 168, 82)

function PANEL:Init()
	self.Tabs = {}
	self.Labels = {}
	self.Cache = vgui.Create "EditablePanel"
	self.Cache:SetVisible(false)

	self.ButtonArea = self:Add "EditablePanel"
	self.ButtonArea:Dock(TOP)
	self.ButtonArea:DockMargin(0, 0, 0, self.Padding)

	self.TabArea = self:Add "DScrollPanel"
	self.TabArea:Dock(FILL)
	self.TabArea:DockMargin(self.Padding, self.Padding * 2, self.Padding, self.Padding)

	self.SearchButtonContainer = self:Add "EditablePanel"
	self.SearchButtonContainer:Dock(BOTTOM)
	self.SearchButtonContainer:SetTall(22)
	self.SearchButtonContainer:DockMargin(0, 0, 0, 20)

	self.SearchButton = self.SearchButtonContainer:Add "pluto_inventory_button"
	self.SearchButton:SetColor(pluto.ui.theme "InnerColorSeperator", pluto.ui.theme "InnerColorSeperator")
	self.SearchButton:SetCurve(4)
	self.SearchButton:SetWide(120)
	self.SearchLabel = self.SearchButton:Add "pluto_label"
	self.SearchLabel:SetRenderSystem(pluto.fonts.systems.shadow)
	self.SearchLabel:SetText "Update Search"
	self.SearchLabel:SetTextColor(pluto.ui.theme "TextActive")
	self.SearchLabel:SetContentAlignment(5)
	self.SearchLabel:SetFont "pluto_inventory_font"
	self.SearchLabel:Dock(FILL)
	function self.SearchButtonContainer.PerformLayout(s, w, h)
		self.SearchButton:SetTall(h)
		self.SearchButton:Center()
	end
	function self.SearchButton.DoClick()
		chat.AddText("Updating marketplace filters...")
		print_updated = true
		self:StartNewSearch()
	end
	
	self.SortBy = self.TabArea:Add "pluto_inventory_auction_search_dropdown"
	self.SortBy:Dock(TOP)
	self.SortBy:SetText "See First:"
	self.SortBy:AddOption "Newest Offers"
	self.SortBy:AddOption "Oldest Offers"
	self.SortBy:AddOption "Lowest ID"
	self.SortBy:AddOption "Highest ID"
	self.SortBy:AddOption "Lowest Price"
	self.SortBy:AddOption "Highest Price"

	self.Price = self.TabArea:Add "pluto_inventory_auction_search_input_two"
	self.Price:Dock(TOP)
	self.Price:SetText "Price Range:"

	--[[self.ItemID = self.TabArea:Add "pluto_inventory_auction_search_input_two"
	self.ItemID:Dock(TOP)
	self.ItemID:SetText "Item ID:"--]]

	self.ItemName = self.TabArea:Add "pluto_inventory_auction_search_input"
	self.ItemName:Dock(TOP)
	self.ItemName:SetText "Item Name:"

	self.Parameters = {}

	local function update(s, what, ...)
		self.Parameters[what] = {n = select("#", ...), ...}
		self:OnSearchUpdated()
	end
	
	hook.Add("PlutoSearchChanged", self.SortBy, update)
	hook.Add("PlutoSearchChanged", self.Price, update)
	--hook.Add("PlutoSearchChanged", self.ItemID, update)
	hook.Add("PlutoSearchChanged", self.ItemName, update)
end

function PANEL:AddTab(name)
	local btn = self.ButtonArea:Add "pluto_inventory_button"
	btn:Dock(LEFT)
	btn:SetCurve(4)
	btn:SetColor(self.InactiveColor, pluto.ui.theme "InnerColorSeperator")

	function btn.DoClick()
		self:SelectTab(name)
	end

	local lbl = btn:Add "pluto_label"
	lbl:SetFont "pluto_inventory_font_lg"
	lbl:SetRenderSystem(pluto.fonts.systems.shadow)
	lbl:SetText(name)
	lbl:Dock(FILL)
	lbl:SetTextColor(pluto.ui.theme "TextActive")
	lbl:SetContentAlignment(5)

	table.insert(self.Labels, btn)

	local tab = self.Cache:Add "EditablePanel"
	tab:Dock(TOP)
	tab:SetVisible(false)
	tab:SetTall(0)
	self.Tabs[name] = {
		Panel = tab,
		Label = btn,
		Parameters = {},
	}

	function tab.OnChildAdded(child)
		hook.Add("PlutoSearchChanged", child, function(s, what, ...)
			self:OnSearchChanged(what, ...)
		end)
	end

	if (not self.ActiveTab) then
		self:SelectTab(name)
	end

	return tab
end

function PANEL:SelectTab(name)
	if (self.ActiveTab) then
		local tab = self.Tabs[self.ActiveTab]
		tab.Panel:SetParent(self.Cache)
		tab.Panel:SetVisible(false)
		tab.Label:SetColor(self.InactiveColor, pluto.ui.theme "InnerColorSeperator")
	end
	local tab = self.Tabs[name]
	self.ActiveTab = name
	tab.Panel:SetParent(self.TabArea)
	tab.Panel:SetVisible(true)
	tab.Label:SetColor(self.ActiveColor, pluto.ui.theme "InnerColorSeperator")
end

function PANEL:PerformLayout(w, h)
	local labelcount = #self.Labels
	local btnw = w - self.Padding * (labelcount + 1)
	self.Labels[labelcount]:Dock(FILL)

	for i = 1, labelcount - 1 do
		local label = self.Labels[i]
		label:SetWide(btnw / labelcount)
		label:DockMargin(0, 0, self.Padding, 0)
	end
end

function PANEL:OnSearchChanged(what, ...)
	local tab = self.Tabs[self.ActiveTab].Parameters
	tab[what] = {n = select("#", ...), ...}

	self:OnSearchUpdated()
end

function PANEL:GetCurrentSearchParameters()
	local params = {}
	for what, param in pairs(self.Tabs[self.ActiveTab].Parameters) do
		params[what] = param
	end

	for what, param in pairs(self.Parameters) do
		params[what] = param
	end

	params.what = {n = 1, self.ActiveTab}

	return params
end

function PANEL:StartNewSearch()
end

function PANEL:OnSearchUpdated()
	-- something?
end

function PANEL:OnRemove()
	self.Cache:Remove()
end

vgui.Register("pluto_inventory_auction_search", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self.Label = self:Add "pluto_label"
	self.Label:SetText "text"
	self.Label:Dock(FILL)
	self.Label:SetFont "pluto_inventory_font"
	self.Label:SetRenderSystem(pluto.fonts.systems.shadow)
	self.Label:SetTextColor(pluto.ui.theme "TextActive")
	self.Label:SetContentAlignment(4)

	self:DockMargin(0, 0, 0, 3)

	self.Label:SizeToContentsY()
	self:SetTall(self.Label:GetTall() + 4)
end

function PANEL:SetText(text)
	self.Label:SetText(text)
end

function PANEL:GetText()
	return self.Label:GetText()
end

function PANEL:OnChanged(...)
	hook.Run("PlutoSearchChanged", self:GetText(), ...)
end

vgui.Register("pluto_inventory_auction_search_base", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self.Dropdown = self:Add "pluto_dropdown"
	self.Dropdown:Dock(RIGHT)
	self.Dropdown:SetWide(120)
end

function PANEL:AddOption(what)
	self.Dropdown:AddOption(what, function()
		self:OnChanged(what)
	end)
end

vgui.Register("pluto_inventory_auction_search_dropdown", PANEL, "pluto_inventory_auction_search_base")

local PANEL = {}

function PANEL:Init()
	self.TextEntry = self:Add "pluto_inventory_textentry"
	self.TextEntry:Dock(RIGHT)
	self.TextEntry:SetWide(120)

	function self.TextEntry.OnChange()
		self:OnUpdated()
	end
end

function PANEL:OnUpdated()
	self:OnChanged(self.TextEntry:GetText())
end

vgui.Register("pluto_inventory_auction_search_input", PANEL, "pluto_inventory_auction_search_base")

local PANEL = {}

function PANEL:Init()
	self.TextEntry2 = self:Add "pluto_inventory_textentry"
	self.TextEntry2:Dock(RIGHT)
	self.TextEntry2:SetWide(55)
	
	function self.TextEntry2.OnChange(s, m)
		self:OnUpdated()
	end

	self.To = self:Add "pluto_label"
	self.To:SetContentAlignment(5)
	self.To:SetText "-"
	self.To:SetFont "pluto_inventory_font"
	self.To:SetTextColor(pluto.ui.theme "TextActive")
	self.To:SetRenderSystem(pluto.fonts.systems.shadow)
	self.To:SetWide(10)
	self.To:Dock(RIGHT)

	self.TextEntry1 = self:Add "pluto_inventory_textentry"
	self.TextEntry1:Dock(RIGHT)
	self.TextEntry1:SetWide(55)

	function self.TextEntry1.OnChange(s, m)
		self:OnUpdated()
	end
end

function PANEL:OnUpdated()
	self:OnChanged(self.TextEntry1:GetText(), self.TextEntry2:GetText())
end

vgui.Register("pluto_inventory_auction_search_input_two", PANEL, "pluto_inventory_auction_search_base")