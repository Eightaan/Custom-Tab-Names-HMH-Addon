if not _G.CTM then
	_G.CTM = {}
	CTM.save_path = SavePath
	CTM.new_settings_path = CTM.save_path .. "Custom_Tab_Names.json"
	CTM.settings = {}

	function CTM:Custom_Tab_names()
		CTM.settings = {
			CUSTOM_TAB_NAMES = {
				primaries 		= { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" },
				secondaries 	= { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" },
				masks 			= { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" },
				melee_weapons 	= { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" },
			},	
		}
	end

	function CTM:Load()
		local file = io.open(self.new_settings_path, "r")
		if file then
			local function parse_settings(table_dst, table_src, setting_path)
				for k, v in pairs(table_src) do
					if type(table_dst[k]) == type(v) then
						if type(v) == "table" then
							table.insert(setting_path, k)
							parse_settings(table_dst[k], v, setting_path)
							table.remove(setting_path, #setting_path)
						else
							table_dst[k] = v
						end
					end
				end
			end

			local settings = json.decode(file:read("*all"))
			parse_settings(self.settings, settings, {})
			file:close()
		end
	end

	function CTM:Save()
		local file = io.open(self.new_settings_path, "w+")
		if file then
			file:write(json.encode(self.settings))
			file:close()
		end
	end

	function CTM:getSetting(id_table, default)
		if type(id_table) == "table" then
			local entry = self.settings
			for i = 1, #id_table do
				entry = entry[id_table[i]]
				if entry == nil then
					return default
				end
			end
			return entry
		end
		return default
	end

	CTM:Custom_Tab_names()
	CTM:Load()
end