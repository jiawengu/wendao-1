-- GiftPreviewDlg.lua
-- Created by yangym Mar/08/2017
-- 获得玩家礼物界面

local GiftPreviewDlg = Singleton("GiftPreviewDlg", Dialog)

function GiftPreviewDlg:init()
    self:bindListener("PickupButton", self.onReceiveButton)
end

function GiftPreviewDlg:setData(data)
    self.data = data
    
    local name = data.name
    local message = data.message
    
    -- 标题
    local titleStr = string.format(CHS[7003023], name)
    self:setDescript("FromPlayerPanel", titleStr)

    -- 留言
    self:setLabelText("RemarksLabel", message, nil, COLOR3.TEXT_DEFAULT)
end

function GiftPreviewDlg:setDescript(panelName, str)
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

function GiftPreviewDlg:onReceiveButton()
    if not self.data then
        return
    end
    
    local id = self.data.pos
    if id then
        gf:CmdToServer("CMD_GATHER_UP", {id = id, para = 0})
        self:close()
    end
end

function GiftPreviewDlg:cleanup()
    self.data = nil
end

return GiftPreviewDlg