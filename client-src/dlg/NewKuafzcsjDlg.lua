-- NewKuafzcsjDlg.lua
-- Created by songcw Dec/26/2018
-- 新跨服战场赛程界面

local NewKuafzcsjDlg = Singleton("NewKuafzcsjDlg", Dialog)

function NewKuafzcsjDlg:init()
    self.firstPanel = self:retainCtrl("StagePanel_1")
    self.unitPanel = self:retainCtrl("StagePanel_2")


    self.timeData = KuafzcMgr:getNewKuafzcsjDlgData()
    if not self.timeData then
        KuafzcMgr:queryTimeData2019()
    else
        self:setCalendar()
    end

    self:hookMsg("MSG_CSML_ROUND_TIME")
    --self:setCalendar()
end

-- 设置日程表
function NewKuafzcsjDlg:setCalendar()
    local list = self:resetListView("ListView", 18, ccui.ListViewGravity.centerHorizontal)
    local data = KuafzcMgr:getNewKuafzcsjDlgData()

    for i = 1, #data do
        local panel
        if i == 1 then
            panel = self.firstPanel:clone()
        else
            panel = self.unitPanel:clone()
        end

        self:setUnitCalendar(data[i], panel, i)
        list:pushBackCustomItem(panel)
    end
end

function NewKuafzcsjDlg:setUnitCalendar(data, panel, idx)
    -- 索引
    self:setLabelText("Label", idx, panel)

    -- 时间
    local timeStr = ""
    if idx == 1 then
        timeStr = gf:getServerDate(CHS[4010326], data.startTime)
    else
        local timeStr1 = gf:getServerDate(CHS[4010327], data.startTime)
        local timeStr2 = gf:getServerDate(CHS[4010328], data.endTime)
        timeStr = timeStr1 .. timeStr2
    end
    self:setLabelText("TimeLabel", timeStr, panel)
    -- 赛程说明
    self:setLabelText("StageLabel", data.desc, panel)
end

function NewKuafzcsjDlg:MSG_CSML_ROUND_TIME(data)
    self:setCalendar()
end


return NewKuafzcsjDlg
