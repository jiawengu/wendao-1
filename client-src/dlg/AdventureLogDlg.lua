-- AdventureLogDlg.lua
-- Created by
--

local AdventureLogDlg = Singleton("AdventureLogDlg", Dialog)

local MAX_COUNT = 100

function AdventureLogDlg:init()
    --self:bindListViewListener("ListView", self.onSelectListView)

    self.unitLogPanel = self:retainCtrl("UnitLogPanel")
    self.layerCountPanel = self:retainCtrl("TitlePanel", "InfoPanel")

    local data = ActivityMgr:getMyAct2019kwdzLogData()
    self:setData(data)
end

function AdventureLogDlg:setData(data)
    if not data or not next(data) then return end
    local list = self:resetListView("ListView")

    local count = 0

    for i = #data, 1, -1 do

        if count >= MAX_COUNT then return end
        count = count + 1


        local panel = self.unitLogPanel:clone()
        local str = os.date("%H:%M", data[i].ti) .. "  " .. data[i].log
        self:setColorText(str, panel)
        list:pushBackCustomItem(panel)

        if data[i].isAddLayrt then
            local panel = self.layerCountPanel:clone()
            self:setLabelText("NumberLabel", string.format(CHS[4200633], data[i].layer), panel)
            list:pushBackCustomItem(panel)
        end

--[[
        local layerCount = string.match(data[i].log, CHS[4200632])
        if layerCount then
            local panel = self.layerCountPanel:clone()
            self:setLabelText("NumberLabel", string.format(CHS[4200633], layerCount), panel)
            list:pushBackCustomItem(panel)
        end
        --]]
    end
end

return AdventureLogDlg
