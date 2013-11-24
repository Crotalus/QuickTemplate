local oldOnSelection = OnSelection
function OnSelection(buildableCategories, selection, isOldSelection)
	oldOnSelection(buildableCategories, selection, isOldSelection)
	if table.getsize(selection) > 0 then
		import('/mods/quicktemplate/modules/templates.lua').setBuildableCategories(buildableCategories)
	end
end