--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local last_tab_id = CreateConVar("pluto_last_tab_opened", "0", FCVAR_ARCHIVE)

local pluto_storage_toggled = CreateConVar("pluto_storage_toggled", 0)

local pluto_tab_order = CreateConVar("pluto_tab_order", "[]", FCVAR_ARCHIVE)


local tab_order_table

local function UpdateFromConvar()
	tab_order_table = util.JSONToTable(pluto_tab_order:GetString())
	if (not tab_order_table) then
		pluto_tab_order:SetString "[]"
		return
	end
end

cvars.AddChangeCallback(pluto_tab_order:GetName(), UpdateFromConvar, pluto_tab_order:GetString())
UpdateFromConvar()

local function GetTabPriority(tab)
	for i, tabid in ipairs(tab_order_table) do
		if (tabid == tab.ID) then
			return i
		end
	end
	return nil
end

local function UpdatePriorityConvar()
	pluto_tab_order:SetString(util.TableToJSON(tab_order_table))
end

local PANEL = {}

function PANEL:Init()
	self:SetTall(2)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(Color(26, 27, 32))
	surface.DrawLine(0, 0, w, 0)
	surface.SetDrawColor(Color(111, 112, 118))
	surface.DrawLine(0, 1, w, 1)
end

vgui.Register("pluto_inv_border", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self.KeyboardFocus = {}
	self.StorageTabs = {}

	self.SidePanelSize = pluto.ui.sizings "SidePanelSize"
	self.TopSize = pluto.ui.sizings "pluto_inventory_font" + 9
	self.BottomSize = pluto.ui.sizings "pluto_inventory_font" - 2
	self:SetSize(pluto.ui.sizings "MainWidth" + self.SidePanelSize, pluto.ui.sizings "MainHeight" + self.BottomSize)

	self.SidePanel = self:Add "ttt_curved_panel"
	self.SidePanel:SetWide(self.SidePanelSize)

	self.SidePanelContainer = self.SidePanel:Add "ttt_curved_panel"
	self.SidePanelContainer:Dock(FILL)
	self.SidePanelContainer:SetCurve(4)

	self.StorageTabListContainer = self.SidePanelContainer:Add "EditablePanel"
	self.StorageTabListContainer:Dock(FILL)
	local w_spacing = 5
	self.StorageTabListContainer:DockPadding(w_spacing, 12, w_spacing, 4)

	function self.StorageTabListContainer.PerformLayout(s, w, h)
		self:SelectTab(self.ActiveStorageTab, true)
	end

	self.StorageTabList = self.StorageTabListContainer:Add "DScrollPanel"
	self.StorageTabList:Dock(FILL)

	self.ActiveStorageTabBackground = self.StorageTabList:Add "ttt_curved_panel"
	self.ActiveStorageTabBackground:SetCurve(4)
	self.ActiveStorageTabBackground:SetColor(Color(106, 107, 112))

	self.SidePanelBorderContainer = self.SidePanelContainer:Add "pluto_inv_border"
	self.SidePanelBorderContainer:Dock(TOP)

	self.Main = self:Add "EditablePanel"
	self.Main:DockMargin(0, 0, self.SidePanelSize, 0)
	self.Main:Dock(FILL)

	self.TabContainer = self.Main:Add "ttt_curved_panel"
	self.TabContainer:Dock(TOP)
	self.TabContainer:SetTall(self.TopSize)

	self.CloseButton = self.TabContainer:Add "pluto_label"
	self.CloseButton:Dock(RIGHT)
	self.CloseButton:SetSize(self.TopSize, self.TopSize)
	self.CloseButton:SetFont "pluto_inventory_x"
	self.CloseButton:SetText "X"
	self.CloseButton:SetTextColor(pluto.ui.theme "XButton")
	self.CloseButton:SetContentAlignment(5)
	self.CloseButton:SetRenderSystem(pluto.fonts.systems.shadow)
	self.CloseButton:SetCursor "hand"
	self.CloseButton:SetMouseInputEnabled(true)
	self.CloseButton:SizeToContentsX(20)
	self.CloseButton.AllowClickThrough = true
	self.CloseButton.PaintUnder = function(s, w, h)
		if (s:IsHovered()) then
			surface.SetDrawColor(0, 0, 0, 64)
			surface.DrawRect(0, 0, w, h)
		end
	end
	function self.CloseButton.OnMousePressed(s, m)
		if (m == MOUSE_LEFT) then
			self:Remove()
		end
	end

	self.SettingsButton = self.TabContainer:Add "pluto_label"
	self.SettingsButton:Dock(RIGHT)
	self.SettingsButton:SetSize(self.TopSize, self.TopSize)
	self.SettingsButton:SetFont "pluto_inventory_x"
	self.SettingsButton:SetText "?"
	self.SettingsButton:SetTextColor(pluto.ui.theme "?Button")
	self.SettingsButton:SetContentAlignment(5)
	self.SettingsButton:SetRenderSystem(pluto.fonts.systems.shadow)
	self.SettingsButton:SetCursor "hand"
	self.SettingsButton:SetMouseInputEnabled(true)
	self.SettingsButton:SizeToContentsX(20)
	self.SettingsButton.AllowClickThrough = true
	self.SettingsButton.PaintUnder = function(s, w, h)
		if (s:IsHovered()) then
			surface.SetDrawColor(0, 0, 0, 64)
			surface.DrawRect(0, 0, w, h)
		end
	end

	self.BorderContainer = self.Main:Add "pluto_inv_border"
	self.BorderContainer:Dock(TOP)

	self.Container = self.Main:Add "ttt_curved_panel"
	self.Container:Dock(FILL)
	self.Container:SetTall(self:GetTall() - self.TopSize)
	self.Container:SetCurve(4)
	self.Container:DockPadding(15, 9, 15, 9)

	self.StorageContainer = self.Container:Add "EditablePanel"
	self.StorageContainer:SetName "pluto_storage_container"
	self.Storage = self.StorageContainer:Add "pluto_storage_area"
	self.Storage:SetStorageHandler(self)

	function self.Storage.OnBufferPressed()
		self:OnBufferPressed()
	end

	self.Storage:Dock(RIGHT)
	self.Storage:DockMargin(12, 0, 0, 0)
	self.Storage:SetColor(pluto.ui.theme "InnerColor")
	self.Storage:SetCurve(4)

	self.RestOfStorage = self.StorageContainer:Add "EditablePanel"
	self.RestOfStorage:Dock(FILL)

	self.EmptyContainer = self.Container:Add "EditablePanel"
	self.EmptyContainer:SetName "pluto_empty_container"

	function self.Container.PerformLayout(s, w, h)
		local x, y = 15, 9
		w = w - 30
		h = h - 18

		for _, child in pairs(s:GetChildren()) do
			child:SetPos(x, y)
			child:SetSize(w, h - self.BottomSize)
		end
	end

	self.StorageLabel = self.SidePanel:Add "pluto_label"
	self.StorageLabel:SetTall(self.TopSize)
	self.StorageLabel:Dock(TOP)
	self.StorageLabel:SetContentAlignment(5)
	self.StorageLabel:SetFont "pluto_inventory_font"

	self.StorageLabel:SetText "Storage"
	self.StorageLabel:SetRenderSystem(pluto.fonts.systems.shadow)
	self.StorageLabel:SetTextColor(pluto.ui.theme "TextActive")

	-- THEME
	self.SidePanel:SetColor(Color(57, 57, 57))
	self.TabContainer:SetColor(pluto.ui.theme "TabBackground")
	self.Container:SetColor(pluto.ui.theme "BackgroundColor")
	self.SidePanelContainer:SetColor(pluto.ui.theme "InnerColor")

	self.SidePanel:SetCurve(4)
	self.TabContainer:SetCurve(4)
	self.SidePanel:SetCurveTopLeft(false)
	self.SidePanel:SetCurveBottomLeft(false)
	self.Container:SetCurveTopLeft(false)
	self.Container:SetCurveTopRight(false)
	self.SidePanelContainer:SetCurveTopLeft(false)
	self.SidePanelContainer:SetCurveBottomLeft(false)
	self.SidePanelContainer:SetCurveTopRight(false)
	self.TabContainer:SetCurveBottomRight(false)
	self.TabContainer:SetCurveBottomLeft(false)

	self.Tabs = {}
	self.CachedTabs = {}
	self.ActiveTab = nil

	self:AddTab("Loadout", function(container)
		local other = container:Add "pluto_inventory_equip"
		other:SetCurve(4)
		other:Dock(FILL)
		other:SetColor(pluto.ui.theme "InnerColor")
	end, true)


	self:AddTab("Trading", function(container)
		local other = container:Add "pluto_inventory_trading"
		other:SetCurve(4)
		other:Dock(FILL)
		other:SetColor(pluto.ui.theme "InnerColor")
	end, true, true)

	self:AddTab("Crafting", function(container)
		local other = container:Add "pluto_inventory_crafting"
		other:SetCurve(4)
		other:Dock(FILL)
		other:SetColor(pluto.ui.theme "InnerColor")
		other.Storage = storage
	end, true, true)

	self:AddTab("Currency", function(container, storage)
		local other = container:Add "pluto_inventory_currency"
		other:SetCurve(4)
		other:Dock(FILL)
		other:SetColor(pluto.ui.theme "InnerColor")
		other.Storage = storage

		return other
	end, true)

	self:AddTab("Quests", function(container, storage)
		local quests = container:Add "pluto_inventory_quests"
		quests:SetCurve(4)
		quests:Dock(FILL)
		quests:SetColor(pluto.ui.theme "InnerColor")
	end, true)

	self:AddTab("Market", function(container)
		local quests = container:Add "pluto_inventory_divine_market"
		quests:SetCurve(4)
		quests:Dock(FILL)
		quests:SetColor(pluto.ui.theme "InnerColor")

		return quests
	end)

	--[[self:AddTab("Other", function(container)
		local quests = container:Add "pluto_inventory_other"
		quests:SetCurve(4)
		quests:Dock(FILL)
		quests:SetColor(pluto.ui.theme "InnerColor")

		return quests
	end)--]]

	--[[self:AddTab("Donate", function(container)
		local quests = container:Add "pluto_inventory_donate"
		quests:SetCurve(4)
		quests:Dock(FILL)
		quests:SetColor(pluto.ui.theme "InnerColor")
	end, nil, nil, Color(207, 204, 3))--]]

	self:AddTab("Events", function(container)
		local events = container:Add("pluto_inventory_events")
		--events:SetCurve(4)
		--events:Dock(FILL)
		--events:SetColor(pluto.ui.theme("InnerColor"))
	end, nil, nil, Color(240, 40, 80))

	self:CreateOrdered()

	tab_order_table = {}
	for i, tab in ipairs(self.TabList) do
		tab_order_table[i] = tab.Tab.ID
	end
	UpdatePriorityConvar()

	for _, item in ipairs(self.TabList) do
		self:AddStorageTab(item.Tab)
		if (item.Tab.ID == last_tab_id:GetInt()) then
			self:SelectTab(item.Tab)
		end
	end
end

function PANEL:CreateOrdered()
	self.TabList = {}

	for id, tab in pairs(pluto.cl_inv) do
		if (tab.Type == "normal" or tab.Type == "equip") then
			table.insert(self.TabList, {
				Tab = tab,
				Priority = GetTabPriority(tab)
			})
		end
	end

	table.sort(self.TabList, function(a, b)
		if (not a.Priority and not b.Priority) then
			return a.Tab.ID < b.Tab.ID
		elseif (a.Priority and not b.Priority) then
			return true
		elseif (b.Priority and not a.Priority) then
			return false
		else
			return a.Priority < b.Priority
		end
	end)
end

function PANEL:OnBufferPressed()
end

function PANEL:PerformLayout(w, h)
	self.SidePanel:SetPos(w - self.SidePanel:GetWide())
	self.SidePanel:SetTall(h)
end

function PANEL:ClearContainer()
	for _, pnl in pairs(self.Container:GetChildren()) do
		pnl:Remove()
	end
end

function PANEL:Center()
	local w, h = self:GetSize()
	w = w - self.SidePanel:GetWide()
	local scrw, scrh = ScrW(), ScrH()
	self:SetPos(scrw / 2 - w / 2, scrh / 2 - h / 2)
end

function PANEL:ChangeToTab(name, noupdate)
	--[[]]print("Changing to tab", name, noupdate)
	local tab = self.Tabs[name]
	if (not tab) then
		return
	end

	if (self.ActiveTab == name) then
		return tab.ActiveTabData
	end

	local old = self.Tabs[self.ActiveTab]
	if (old) then
		old.Label:SetTextColor(old.LabelColor)
	end

	self.ActiveTab = name

	tab.Label:SetTextColor(Color(28, 198, 244))

	local oldpnl = old and old.HasStorage and self.RestOfStorage or self.EmptyContainer
	local newpnl = tab.HasStorage and self.RestOfStorage or self.EmptyContainer

	self.SidePanel:SetVisible(tab.HasStorage)
	self:Center()

	if (old and old.Cache) then
		if (not IsValid(self.CachedTabs[old.Name])) then
			local cache = vgui.Create "EditablePanel"
			cache:SetVisible(false)
			self.CachedTabs[old.Name] = cache
		end

		for _, child in pairs(oldpnl:GetChildren()) do
			child:SetParent(self.CachedTabs[old.Name])
		end
	else
		for _, child in pairs(oldpnl:GetChildren()) do
			child:Remove()
		end
	end
	
	self.StorageContainer:SetVisible(tab.HasStorage)
	self.EmptyContainer:SetVisible(not tab.HasStorage)

	if (tab and tab.Cache and IsValid(self.CachedTabs[name])) then
		for _, child in pairs(self.CachedTabs[name]:GetChildren()) do
			child:SetParent(newpnl)
			child:SetVisible(true)
		end
	else
		tab.ActiveTabData = tab.Populate(newpnl, self.Storage)
	end

	return tab.ActiveTabData
end

local gradient_up = Material "gui/gradient_up"

function PANEL:AddTab(name, func, has_storage, cache, col)
	--[[]]print("adding tab", name, func, has_storage, cache, col)
	local lbl = self.TabContainer:Add "pluto_label"
	function lbl.PaintUnder(s, w, h)
		if (self.ActiveTab == name) then
			surface.SetMaterial(gradient_up)
			surface.SetDrawColor(255, 255, 255, 10)
			surface.DrawTexturedRect(0, 0, w, h)
		elseif (s:IsHovered()) then
			surface.SetDrawColor(0, 0, 0, 64)
			surface.DrawRect(0, 0, w, h)
		end
	end
	self.Tabs[name] = {
		Label = lbl,
		LabelColor = col or white_text,
		Populate = func,
		HasStorage = has_storage,
		Cache = cache,
		Name = name,
	}

	lbl:Dock(LEFT)
	lbl:SetContentAlignment(5)
	lbl:SetText(name)
	lbl:SetFont "pluto_inventory_font"
	lbl:SetTextColor(self.Tabs[name].LabelColor)
	lbl:SetRenderSystem(pluto.fonts.systems.shadow)
	lbl:SetCursor "hand"
	lbl:SetMouseInputEnabled(true)
	lbl.AllowClickThrough = true

	surface.SetFont(lbl:GetFont())
	lbl:SetWide(surface.GetTextSize(lbl:GetText()) + 24)

	function lbl.OnMousePressed(s, m)
		if (self.ActiveTab == name) then
			return
		end

		self:ChangeToTab(name)
	end

	if (not self.ActiveTab) then
		self:ChangeToTab(name, true)
	end
end

function PANEL:HandleStorageScroll(wheeled)
	--[[]]print("handling storage scroll", wheeled)
	local current_position
	for i, tab in ipairs(self.TabList) do
		if (tab.Tab == self.ActiveStorageTab) then
			current_position = i
			break
		end
	end
	current_position = math.Clamp(current_position + (wheeled < 0 and 1 or -1), 1, #self.TabList)
	self:SelectTab(self.TabList[current_position].Tab)
end

function PANEL:AddStorageTab(tab)
	--[[]]print("adding storage tab", tab)
	self.Storage:AddTab(tab)
	local pnl = self.StorageTabList:Add "EditablePanel"
	pnl.AllowClickThrough = true
	self.StorageTabs[tab] = pnl
	pnl:Dock(TOP)
	pnl:SetTall(20)
	pnl:SetZPos(GetTabPriority(tab))
	pnl.Tab = tab

	local img = pnl:Add "pluto_inventory_shape"
	img:SetSize(pnl:GetTall(), pnl:GetTall())
	img:Dock(LEFT)
	img:SetShape(tab.Shape)
	img:SetColor(tab.Color)
	img:SetMouseInputEnabled(true)
	img:SetCursor "hand"
	function img.OnMousePressed(s, m)
		if (m == MOUSE_LEFT) then
			s:GetParent():OnMousePressed(m)
		elseif (m == MOUSE_RIGHT) then
			if (IsValid(s.ImageChanger)) then
				s.ImageChanger:Remove()
			end
			s.ImageChanger = vgui.Create "pluto_inventory_shape_change"
			s.ImageChanger:MakePopup()
			s.ImageChanger:SetRGB(tab.Color)
			local x, y = s:LocalToScreen(-s.ImageChanger:GetWide(), 0)
			s.ImageChanger:SetPos(x, y)

			function s.ImageChanger.OnColorChanged(_, col)
				tab.Color = col
				timer.Create("changetabdata" .. tab.ID, 1, 1, function()
					pluto.inv.message()
						:write("changetabdata", tab)
						:send()
				end)
				img:SetColor(col)
			end
			function s.ImageChanger.OnShapeChanged(_, shape)
				tab.Shape = shape
				timer.Create("changetabdata" .. tab.ID, 1, 1, function()
					pluto.inv.message()
						:write("changetabdata", tab)
						:send()
				end)
				img:SetShape(shape)
			end
			s:GetParent():OnMousePressed(MOUSE_LEFT)

			hook.Add("VGUIMousePressed", s.ImageChanger, function(self, opnl)
				while (IsValid(opnl)) do
					if (opnl == self) then
						return
					end

					opnl = opnl:GetParent()
				end

				self:Remove()
			end)
		end
	end

	function img:OnRemove()
		if (IsValid(self.ImageChanger)) then
			self.ImageChanger:Remove()
		end
	end

	local lbl = pnl:Add "pluto_label"
	pnl.Label = lbl
	lbl:Dock(FILL)
	lbl:SetContentAlignment(4)
	lbl:SetFont "pluto_inventory_font_s"
	lbl:SetTall(22)
	lbl:SetRenderSystem(pluto.fonts.systems.shadow)
	lbl:SetTextColor(pluto.ui.theme "TextActive")
	lbl:SetText(tab.Name)
	lbl:SetMouseInputEnabled(false)

	function pnl.OnMousePressed(s, m)
		if (m == MOUSE_RIGHT) then
			self.TextEntry = s:Add "DTextEntry"
			self.TextEntry:Dock(FILL)
			self.TextEntry:SetFont "pluto_inventory_font"
			self.TextEntry:SetText(lbl:GetText())
			pluto.ui.pnl:SetKeyboardFocus(self.TextEntry, true)
			function self.TextEntry:Think()
				if (vgui.GetKeyboardFocus() == self) then
					self.WasFocussed = true
				elseif (not self.WasFocussed) then
					self:RequestFocus()
				end

				if (self.WasFocussed and not self:HasFocus()) then
					lbl:SetText(self:GetText())
					tab.Name = self:GetText()
					
					pluto.inv.message()
						:write("tabrename", tab.ID, self:GetText())
						:send()

					self:Remove()
					pluto.ui.pnl:SetKeyboardFocus(self, false)
				end
			end
		end
		self:SelectTab(tab)
		if (m == MOUSE_LEFT) then
			s.IsBeingMoved = true
		end
	end

	function pnl.CreateOrdered()
		self:CreateOrdered()
	end

	function pnl:Think()
		if (self.IsBeingMoved and input.IsMouseDown(MOUSE_LEFT)) then
			local hovered = vgui.GetHoveredPanel()
			if (not IsValid(hovered) or hovered == self or not hovered.IsTabMoveable) then
				return
			end

			local newzpos = hovered:GetZPos()

			for _, child in pairs(pnl:GetParent():GetChildren()) do
				if (child:GetZPos() >= newzpos) then
					child:SetZPos(child:GetZPos() + 1)
				end
			end

			self:SetZPos(newzpos)

			tab_order_table = {}

			local children = self:GetParent():GetChildren()
			table.sort(children, function(a, b)
				return a:GetZPos() < b:GetZPos()
			end)

			for i, child in ipairs(children) do
				if (not child.Tab) then
					continue
				end

				table.insert(tab_order_table, child.Tab.ID)
			end

			UpdatePriorityConvar()
			self:CreateOrdered()

		elseif (self.IsBeingMoved) then
			self.IsBeingMoved = false
		end
	end

	pnl.IsTabMoveable = true

	if (not self.ActiveStorageTab) then
		self:SelectTab(tab, true)
	end
end

function PANEL:SelectTab(tab, noupdate)
	if (not noupdate) then
		last_tab_id:SetInt(tab.ID)
	end
	self.ActiveStorageTabBackground:SetTall(22)
	local fg = self.StorageTabs[tab]
	
	self.ActiveStorageTabBackground:SetWide(fg:GetWide())
	self.ActiveStorageTabBackground:SetPos(fg:GetPos())

	if (tab ~= self.ActiveStorageTab) then
		self.ActiveStorageTab = tab
		self.Storage:SwapToBuffer(false)
		self.Storage:PopulateFromTab(tab)
	end
end

function PANEL:HighlightItem(tabidx)
	self.Storage:HighlightItem(tabidx)
end

function PANEL:OnRemove()
	pluto.ui.pickupitem()
	for _, pnl in pairs(self.CachedTabs) do
		if (IsValid(pnl)) then
			pnl:Remove()
		end
	end
end

function PANEL:SetKeyboardFocus(what, b)
	self.KeyboardFocus[what] = b and true or nil

	self:SetKeyboardInputEnabled(table.Count(self.KeyboardFocus) > 0)
end

function pluto.ui.SetKeyboardFocus(what, b)
	local p = what
	while (IsValid(p)) do
		if (p.SetKeyboardFocus) then
			p:SetKeyboardFocus(what, b)
		end
		
		p = p:GetParent()
	end
end

function PANEL:Think()
	if (input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible()) then
		gui.HideGameUI()
		self:Remove()
	end
end

vgui.Register("pluto_inv", PANEL, "EditablePanel")


function pluto.ui.toggle()
	--[[]]print("running pluto.ui.toggle")
	if (IsValid(pluto.ui.pnl)) then
		pluto.ui.pnl:Remove()
		--[[]]print("removing pluto.ui.pnl")
		return
	end

	--[[]]print("creating pluto.ui.pnl")
	pluto.ui.pnl = vgui.Create "pluto_inv"
	pluto.ui.pnl:Center()
	pluto.ui.pnl:MakePopup()
	pluto.ui.pnl:SetPopupStayAtBack(true)
	pluto.ui.pnl:SetKeyboardInputEnabled(false)
end

function pluto.ui.highlight(item)
	--[[]]print("running pluto.ui.highlight on", item)
	if (not IsValid(pluto.ui.pnl)) then
		return
	end

	if (not item or not item.TabID) then
		return
	end

	pluto.ui.pnl:SelectTab(pluto.cl_inv[item.TabID])
	pluto.ui.pnl:HighlightItem(item.TabIndex)
end

if (IsValid(pluto.ui.pnl)) then
	pluto.ui.pnl:Remove()
	pluto.ui.toggle()
end

function pluto.inv.writechangetabdata(tab)
	net.WriteUInt(tab.ID, 32)
	net.WriteColor(tab.Color)
	net.WriteString(tab.Shape)
end
