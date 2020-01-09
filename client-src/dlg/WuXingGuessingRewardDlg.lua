-- WuXingGuessingRewardDlg.lua
-- Created by liuhb Apr/26/2016
-- 五行竞猜奖励界面

local WuXingGuessingRewardDlg = Singleton("WuXingGuessingRewardDlg", Dialog)

local tipMsg = nil -- 杂项提示语

function WuXingGuessingRewardDlg:init()
    self:bindListener("ConfrimButton", self.onConfrimButton)
    -- 五行屏蔽分享
    --[[
    self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.WUXINGGUESS)
    
    if not ShareMgr:isShowShareBtn() then
        local confirmButton = self:getControl("ConfrimButton")
        local mainPanel = self:getControl("MainPanel")
        confirmButton:setPositionX(mainPanel:getContentSize().width / 2)
    end
    --]]
end

function WuXingGuessingRewardDlg:setData(data)
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(data.money))
    local cashContent = gf:getMoneyDesc(tonumber(data.money))
    local str = ""
    local guessStr = ""
    local number = ""
    
    if data.wuxResult == data.wuxSelect and data.shengxResult == data.shengxSelect then
        guessStr = CHS[6200020]
        number = 60
		tipMsg = string.format(CHS[5100016], cashContent)
    elseif data.wuxResult == data.wuxSelect then
        guessStr = CHS[6200018]
        number = 5
		tipMsg = string.format(CHS[5100017], cashContent)
    elseif data.shengxResult == data.shengxSelect then
        guessStr = CHS[6200019]
        number = 12
		tipMsg = string.format(CHS[5100018], cashContent)
    end
    
    str = string.format(CHS[6200017], gf:getPolar(data.wuxSelect), GiftMgr:getShengXiaoName(data.shengxSelect), guessStr, number)
    
    local infoPanel = self:getControl("GuessInfoPanel")
    local lableText = CGAColorTextList:create(true)
    lableText:setFontSize(19)
    lableText:setString(str)
    lableText:setContentSize(infoPanel:getContentSize().width, 0)
    lableText:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    lableText:updateNow()
    local labelW, labelH = lableText:getRealSize()
    lableText:setPosition((infoPanel:getContentSize().width - labelW) * 0.5, infoPanel:getContentSize().height)
    infoPanel:addChild(tolua.cast(lableText, "cc.LayerColor"))

	self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23)
end

function WuXingGuessingRewardDlg:cleanup()
    DlgMgr:sendMsg("WuXingGuessingDlg", "finish", tipMsg)
end

function WuXingGuessingRewardDlg:onConfrimButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

return WuXingGuessingRewardDlg
