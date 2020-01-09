-- KidScheduleRecordDlg.lua
-- Created by songcw Apir/15/2019
-- 娃娃-历史行程

local KidScheduleRecordDlg = Singleton("KidScheduleRecordDlg", Dialog)

function KidScheduleRecordDlg:init()
    self.unitPanel = self:retainCtrl("OneCasePanel")
    self.lineImage = self:retainCtrl("LineImage")
    self.lineImage:setVisible(false)
end

function KidScheduleRecordDlg:setData(data, cfg)
    self:setLabelText("NameLabel", data.name)


    local bar = self:setProgressBar("ProgressBar", data.mature, 1000)
    self:setLabelText("ValueLabel", string.format( "%d/%d", data.mature, 1000))
    self:setLabelText("ValueLabel2", string.format( "%d/%d", data.mature, 1000))

   -- gf:ShowSmallTips(data.wuxing)
    local infoStr = HomeChildMgr:getXinggeChs(data.xingge) .. "，" .. HomeChildMgr:getWuXinChs(data.wuxing)
    self:setLabelText("TypeLabel", infoStr)


    local list = self:resetListView("ListView", 15)
    local lastTime
    for i = data.sch_count, 1, -1 do

        if lastTime and not gf:isSameDay(lastTime, data.sch_data[i].time) then
            local lineImage = self.lineImage:clone()
            lineImage:setVisible(true)
            list:pushBackCustomItem(lineImage)
        end

        lastTime = data.sch_data[i].time
        local timeStr = os.date("%Y.%m.%d %H时", data.sch_data[i].time)
        local content = string.format(cfg[data.sch_data[i].sch_type].template, data.sch_data[i].para1, data.sch_data[i].para2, data.sch_data[i].para3)
        local retStr = timeStr .. " " .. content
        local panel = self.unitPanel:clone()
        self:setColorText(retStr, panel, nil, 0, 0, nil, 19)
        list:pushBackCustomItem(panel)
    end

    self:setCtrlVisible("NoticePanel", data.sch_count == 0)
end

return KidScheduleRecordDlg
