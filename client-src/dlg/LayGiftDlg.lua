-- LayGiftDlg.lua
-- Created by yangym Feb/08/2017
-- 获得玩家礼物界面

local LayGiftDlg = Singleton("LayGiftDlg", Dialog)

function LayGiftDlg:init()
    self:bindListener("ReceiveButton", self.onReceiveButton)
end

function LayGiftDlg:setData(data)
    self.data = data
    
    -- 标题
    local name = data.name
    local titleStr = string.format(CHS[7002053], name)
    self:setDescript("FromPlayerPanel", titleStr)
    
    -- 钱
    local money = data.money
    local cash, color = gf:getArtFontMoneyDesc(money)
    self:setNumImgForPanel("MoneyValuePanel", color, cash, false, LOCATE_POSITION.MID, 21)
    
    -- 留言
    local message = data.message
    self:setLabelText("RemarksLabel", message)
end

function LayGiftDlg:setDescript(panelName, str)
    -- 需要在固定panel的情况下，水平和垂直方向都居中
    local titlePanel = self:getControl(panelName)
    local size = titlePanel:getContentSize()
    titlePanel:removeAllChildren()
    
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(20)
    textCtrl:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    textCtrl:setContentSize(size.width, 0)
    textCtrl:setString(str)
    textCtrl:updateNow()
    
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition((size.width - textW) / 2, (size.height + textH) / 2)
    titlePanel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
end

function LayGiftDlg:onReceiveButton()
    -- 物品栏已满
    if not InventoryMgr:getFirstEmptyPos() then
        gf:ShowSmallTips(CHS[7002056])
        return
    end
    
    -- 宠物栏已满
    if PetMgr:getFreePetCapcity() < 1 then
        gf:ShowSmallTips(CHS[7002057])
        return
    end
    
    if self.data and self.data.pos then
        gf:CmdToServer("CMD_RECEIVE_FOOL_GIFT", {pos = self.data.pos})
        self:close()
    end
end

function LayGiftDlg:cleanup()
    self.data = nil
end

return LayGiftDlg