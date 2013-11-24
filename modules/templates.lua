local Prefs = import('/lua/user/prefs.lua')
local current_focus = nil
local buildable_categories = {}
local buildable_units = {}
local pos_hash = nil

toggle_template = 1

function setBuildableCategories(categories)
	buildable_categories = categories
	buildable_units = EntityCategoryGetUnitList(buildable_categories)
	resetToggle()
end

function ConvertID(BPID, skip_buildable)
	local selection = GetSelectedUnits()
	local current_faction = selection[1]:GetBlueprint().General.FactionName

	local prefixes = {
		["AEON"] = {
			"uab",
			"xab",
			"dab",
		},
		["UEF"] = {
			"ueb",
			"xeb",
			"deb",
		},
		["CYBRAN"] = {
			"urb",
			"xrb",
			"drb",
		},
		["SERAPHIM"] = {
			"xsb",
			"usb",
			"dsb",
			},
	}
	for i, prefix in prefixes[string.upper(current_faction)] do
		if skip_buildable or table.find(buildable_units, string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")) then
			return string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")
		end
	end
	return false
end

function GetPositionHash()
	if not pos_hash or GetFocusArmy() ~= current_focus then
		local armies = GetArmiesTable()
		local me = armies.focusArmy
		local info = SessionGetScenarioInfo()
		local map = info.map
		local position = nil

		current_focus = armies.focusArmy

		for id, army in armies.armiesTable do
			if(id == me) then
				position = army.name
			end
		end

		index = string.find(map, "/[^/]*$")

		if(index) then
			map = string.sub(map, index+1)
		end

		pos_hash = map .. '-' .. position
	end

	return pos_hash
end

function BindTemplateToPosition(id)
	templates[id].hash = GetPositionHash()
	Prefs.SetToCurrentProfile('build_templates', templates)
end

function GetTemplates()
	local all_templates = Prefs.GetFromCurrentProfile('build_templates')
	local filtered = {}

	hash = GetPositionHash()

	for id, t in all_templates do
		local valid = true

		if(t.hash and t.hash ~= hash) then
			valid = false
		else
			for n, entry in t.templateData do
				if type(entry) == 'table' then
			    	if not table.find(buildable_units, entry[1]) then
			    		local new_id = ConvertID(entry[1], true)
			    		if not table.find(buildable_units, new_id) then
							--valid = false
							t.templateData[n] = nil
						else
							t.templateData[n][1] = new_id
						end
			    	end
			    end
			end

			t.icon = ConvertID(t.icon, true)
		end

		if(valid) then
			filtered[id] = t
		end
	end

	return filtered
end

function findTemplates(item_id)
	local all_templates = GetTemplates()
	local templates = {}

	for id, t in all_templates do
		if(item_id == t.icon) then
			table.insert(templates, t)
		end
	end

	return templates
end

function mod(a, b)
	return a - math.floor(a/b)*b
end

function resetToggle()
	toggle_template = 1
end

function toggleTemplate(item_id)
	templates = findTemplates(item_id)

	n = table.getsize(templates)

	ClearBuildTemplates()
	if(n > 0) then
		if(toggle_template <= n) then
			SetActiveBuildTemplate(templates[toggle_template].templateData)
			toggle_template = toggle_template + 1
		else
			toggle_template = 1
		end
	end
end

