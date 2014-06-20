local oldOnSelection = OnSelection
function OnSelection(buildableCategories, selection, isOldSelection)
	oldOnSelection(buildableCategories, selection, isOldSelection)
	if table.getsize(selection) > 0 then
		import('/mods/quicktemplate/modules/templates.lua').setBuildableCategories(buildableCategories)
	end
end

local oldOnClickHandler = OnClickHandler
function OnClickHandler(button, modifiers)
	local item = button.Data

	if(item.type == 'item') then
		import('/mods/quicktemplate/modules/templates.lua').resetToggle()
	end

	return oldOnClickHandler(button, modifiers)
end