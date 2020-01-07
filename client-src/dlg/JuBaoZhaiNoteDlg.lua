-- JuBaoZhaiNoteDlg.lua
-- Created by 
-- 

local JuBaoZhaiNoteDlg = Singleton("JuBaoZhaiNoteDlg", Dialog)

function JuBaoZhaiNoteDlg:init()
    self:bindListViewListener("ListView", self.onSelectListView)

    -- 修改网址
    self:setLabelText("ResourceLabel_2", string.format("【%s】", TradingMgr.BUY_URL), "BuyNotePanel")


    -- 注意事项区分内测和公测   10 看json文件中个数
    local sellNotePanel = self:getControl("SellNotePanel")
    for i = 1, 10 do
        local labelName = "ResourceLabel_" .. i
        local testDistCtrl = self:getControl(labelName .. "_Test", nil, sellNotePanel)
        self:setCtrlVisible(labelName, true, sellNotePanel)
        if testDistCtrl then
            local isTest = DistMgr:curIsTestDist()
            testDistCtrl:setVisible(isTest)
            self:setCtrlVisible(labelName, not isTest, sellNotePanel)
        end        
    end

end

function JuBaoZhaiNoteDlg:onSelectListView(sender, eventType)
end

return JuBaoZhaiNoteDlg
