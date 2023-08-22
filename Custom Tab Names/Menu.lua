
		--Replace Tab Names with custom ones...
		BlackMarketGui._SUB_TABLE = {
			["<SKULL>"] = utf8.char(57364),	--Skull icon
			["<GHOST>"] = utf8.char(57363),	--Ghost icon
		}

		local BlackMarketGui__setup_original = BlackMarketGui._setup
		function BlackMarketGui:_setup(is_start_page, component_data)
			self._renameable_tabs = false
			local setting = true
			component_data = component_data or self:_start_page_data()
			local inv_name_tweak = CTM:getSetting({"CUSTOM_TAB_NAMES"}, {})
			if inv_name_tweak then
				for i, tab_data in ipairs(component_data) do
					if not tab_data.prev_node_data then
						local category_tab_names = inv_name_tweak[tab_data.category]
						local custom_tab_name = category_tab_names and category_tab_names[i] or ""
						for key, subst in pairs(BlackMarketGui._SUB_TABLE) do
							custom_tab_name = custom_tab_name:upper():gsub(key, subst)
						end
						if string.len(custom_tab_name or "") > 0 then
							tab_data.name_localized = custom_tab_name or tab_data.name_localized
						end
						self._renameable_tabs = self._renameable_tabs or category_tab_names and true or false
					end
				end
			end

			BlackMarketGui__setup_original(self, is_start_page, component_data)

			if self._renameable_tabs and self._tabs[1] then
				local first_tab_name = self._tabs[1]._tab_panel and self._tabs[1]._tab_panel:child("tab_text")
				self._renameable_tabs = first_tab_name:visible()
			end
		end

		-- Input Dialog on double click selected tab
		local BlackMarketGui_mouse_clicked_original = BlackMarketGui.mouse_clicked
		function BlackMarketGui:mouse_clicked(...)
			BlackMarketGui_mouse_clicked_original(self, ...)

			if not self._enabled or not self._mouse_click or not self._mouse_click[0] or not self._mouse_click[1] then
				return
			end
			
			self._mouse_click[self._mouse_click_index].selected_tab = self._selected
		end

		local BlackMarketGui_mouse_double_click_original = BlackMarketGui.mouse_double_click
		function BlackMarketGui:mouse_double_click(o, button, x, y)
			if self._enabled and not self._data.is_loadout and self._renameable_tabs then
				if self._mouse_click and self._mouse_click[0] and self._mouse_click[1] then
					if self._tabs and self._mouse_click[0].selected_tab == self._mouse_click[1].selected_tab then
						local current_tab = self._tabs[self._selected]
						if current_tab and button == Idstring("0") then
							if self._tab_scroll_panel:inside(x, y) and current_tab:inside(x, y) ~= 1 then
								self:rename_tab_clbk(current_tab, self._selected)
								return
							end
						end
					end
				end
			end

			BlackMarketGui_mouse_double_click_original(self, o, button, x, y)
		end

		function BlackMarketGui:rename_tab_clbk(tab, tab_id)
			local current_tab = tab or self._tabs[self._selected]
			local tab_data = self._data[self._selected]
			local inv_name_tweak = CTM:getSetting({"CUSTOM_TAB_NAMES"}, nil)
			if _G.HMH and current_tab and tab_data and inv_name_tweak and not self:in_setup()then
				local prev_name = inv_name_tweak[tab_data.category] and inv_name_tweak[tab_data.category][tab_id or self._selected] or current_tab._tab_text_string
				local menu_options = {
					[1] = {
						text = "save",
						callback = function(cb_data, button_id, button, text)
							if self._data and text and text ~= "" then
								if tab_data and inv_name_tweak then
									inv_name_tweak[tab_data.category] = inv_name_tweak[tab_data.category] or {}
									inv_name_tweak[tab_data.category][tab_id or self._selected] = text
									CTM:Save()

									for key, subst in pairs(BlackMarketGui._SUB_TABLE) do
										text = text:upper():gsub(key, subst)
									end

									current_tab._tab_text_string = text
									local name = current_tab._tab_panel:child("tab_text")
									if alive(name) then
										name:set_text(text)
									end
									self:rearrange_tab_width(true)
									self:_round_everything()
								end
							end
						end,
					},
					[2] = {
						text = managers.localization:text("dialog_cancel"),
						is_cancel_button = true,
					}
				}
				QuickInputMenu:new("Rename Inventory Page", "Enter the new name for this Inventory page.", prev_name, menu_options, true, {w = 420, to_upper = true, max_len = 15})

				return
			end
		end

		function BlackMarketGui:rearrange_tab_width(start_with_selected)
			local current = start_with_selected and self._selected or 1
			local start = current + 1
			local stop = #self._tabs

			local current_tab = self._tabs[current]
			if current_tab then
				local current_panel = current_tab._tab_panel
				local current_text = current_panel and current_panel:child("tab_text")
				local current_selection = current_panel and current_panel:child("tab_select_rect")
				if alive(current_panel) and alive(current_text) and alive(current_selection) then
					local _, _, w, _ = current_text:text_rect()
					current_panel:set_w(w + 15)
					current_selection:set_w(w + 15)
					current_text:set_w(w + 15)
					current_text:set_center_x(current_panel:w() / 2)
				end
			end

			local offset = alive(self._tabs[current]._tab_panel) and self._tabs[current]._tab_panel:right() or 0
			for i = start, stop do
				local tab = self._tabs[i]
				local tab_panel = tab._tab_panel
				if alive(tab._tab_panel) then
					offset = tab:set_tab_position(offset)
				end
			end
		end