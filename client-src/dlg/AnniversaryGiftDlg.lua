-- AnniversaryGiftDlg.lua
-- Created by songcw Mar/15/2017
-- 周年庆 礼包界面

local HolidayGiftDlg = require('dlg/HolidayGiftDlg')
local AnniversaryGiftDlg = Singleton("AnniversaryGiftDlg", HolidayGiftDlg)

function AnniversaryGiftDlg:getCfgFileName()
    return ResMgr:getDlgCfg("AnniversaryGiftDlg")
end

function AnniversaryGiftDlg:init()
        
    for i = 1, 4 do
        local box = self:getControl("ChestPanel" .. i)
        box:setTag(i)
        self:bindTouchEndEventListener(box, self.onGiftBox)
        box:setVisible(false)
    end
    
    self:setLabelText("BoughNumbertLabel", "")
    self:setProgressBar("ConsumeProgressBar", 0, 0)
    self.rewardPanel = self:getControl("ItemPanel")
    self.rewardPanel:retain()
    self.rewardPanel:removeFromParent()
    self.rewardPanelSize = self.rewardPanel:getContentSize()
    
    GiftMgr:questHolidayData()
    self:hookMsg("MSG_MY_FESTIVAL_GIFT_INFO")
    
    self:setIntroduce()
end

function AnniversaryGiftDlg:setIntroduce(data)
    local panel = self:getControl("IntroducePanel")
    if not data then
        self:setLabelText("Label1", "", panel)
        self:setLabelText("Label2", "", panel)
        return 
    end
    
    local intro = data.introduce
    local dateTime = data.time
    
    self:setLabelText("Label1", intro, panel)
    self:setLabelText("Label2", gf:getServerDate(CHS[4100498], dateTime), panel)
end

return AnniversaryGiftDlg
