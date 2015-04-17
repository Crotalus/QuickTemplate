local CM = import('/lua/ui/game/commandmode.lua')
local Templates = import('/mods/quicktemplate/modules/templates.lua')

local oldWorldView = WorldView
WorldView = Class(oldWorldView)
{
    HandleEvent = function(self, event)
        local res = oldWorldView.HandleEvent(self, event)

        if (event.Type == 'ButtonPress' and event.Modifiers.Middle) or IsKeyDown('Control') then
            local currentCM = CM.GetCommandMode()
            local selected = GetSelectedUnits()

            if currentCM[1] == 'build' then
                Templates.toggleTemplate(currentCM[2]['name'])
            elseif selected then
                local rollOver = GetRolloverInfo()

                if not (rollOver and rollOver.userUnit) then return res end

                if rollOver.userUnit:GetArmy() == GetFocusArmy() and rollOver.userUnit:IsInCategory('STRUCTURE') then
                    local availableOrders, availableToggles, buildableCategories = GetUnitCommandData(selected or {})
                    local buildableUnits =  EntityCategoryGetUnitList(buildableCategories)
                    local item_id = rollOver.blueprintId
                    local upgrades_to = rollOver.userUnit:GetBlueprint().General.UpgradesTo

                    if rollOver.userUnit:GetFocus() and upgrades_to then -- treat upping mexes as next level
                        item_id = upgrades_to
                    end

                    item_id = Templates.ConvertID(item_id, true)

                    if not table.find(buildableUnits, item_id) then
                        local templates = Templates.findTemplates(item_id)
                        if templates then
                            item_id = templates[1].icon
                        else
                            item_id = nil
                        end
                    end

                    if item_id then
                        Templates.resetToggle()
                        CM.StartCommandMode('build', {name = item_id}, true )
                        Templates.toggleTemplate(item_id)
                    end
                end
            end
        end

        return res
    end

}
