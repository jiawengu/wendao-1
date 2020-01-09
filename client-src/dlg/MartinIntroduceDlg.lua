-- MartinIntroduceDlg.lua
-- Created by Sep/19/2018
-- 宠物界面-武学规则说明界面

local MartinIntroduceDlg = Singleton("MartinIntroduceDlg", Dialog)

function MartinIntroduceDlg:init(pet)
    self:bindListener("MainPanel", self.onCloseButton)
    if not pet then
        self:setLabelText("Label2", 0, "STDMartinPanel")
        self:setLabelText("Label2", 0, "MonthMartinPanel")
        self:setLabelText("Label2", 0, "MonthMartinPanel_1")
        return
    end

    local level = pet:queryBasicInt("level")
    local biaozhunWuxue = math.floor(Formula:getStdMartial(level))
    self:setLabelText("Label2", biaozhunWuxue, "STDMartinPanel")
    self:setLabelText("Label2", pet:queryBasicInt("mon_martial"), "MonthMartinPanel")
    self:setLabelText("Label2", pet:queryBasicInt("last_mon_martial"), "MonthMartinPanel_1")
end

return MartinIntroduceDlg
