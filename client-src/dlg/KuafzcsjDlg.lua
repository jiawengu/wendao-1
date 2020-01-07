-- KuafzcsjDlg.lua
-- Created by songcw Aug/7/2017
-- 跨服战场，时间表界面

local KuafzcsjDlg = Singleton("KuafzcsjDlg", Dialog)

function KuafzcsjDlg:init()
    local data = KuafzcMgr:getTimeData()
    self:setData(data)
    
    -- 没有数据需要请求
    if not data then        
        KuafzcMgr:queryRoundTime()
    end
    
    if not KuafzcMgr:getJfSimpleData() then
        KuafzcMgr:queryMatchScoreSimple()
    end
end

function KuafzcsjDlg:setData(data)
    if not data then
        for i = 1, 10 do
            local panel = self:getControl("StagePanel_" .. i)
            self:setLabelText("TimeLabel", "", panel)        
            self:setLabelText("StageLabel", "", panel)
        end
    else
        for i = 1, 10 do
            local panel = self:getControl("StagePanel_" .. i)
            if data[i] then
                self:setLabelText("TimeLabel", data[i].timeStr, panel)        
                self:setLabelText("StageLabel", data[i].title, panel)
            else
                self:setLabelText("TimeLabel", "", panel)        
                self:setLabelText("StageLabel", "", panel)
            end
        end
    end
end

return KuafzcsjDlg
