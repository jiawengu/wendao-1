-- GrantGiftDlg.lua
-- Created by yangym Feb/08/2017
-- 礼物设置界面

local GrantGiftDlg = Singleton("GrantGiftDlg", Dialog)
local MAX_GRANT_MONEY = 1000000

function GrantGiftDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CleanRemarksButton", self.onCleanRemarksButton)
    
    self:bindEditFieldForSafe("RemarksPanel", 20, "CleanRemarksButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    self:setCtrlVisible("CleanRemarksButton", false)
    
    -- 绑定数字键盘
    self:bindNumInput("MoneyPanel")
    
    -- 初始化红包金额
    local cash, color = gf:getArtFontMoneyDesc(0)
    self:setNumImgForPanel("MoneyValuePanel", color, cash, false, LOCATE_POSITION.MID, 21)
    self.money = 0
end

function GrantGiftDlg:onCleanRemarksButton(sender, eventType)
    self:setInputText("TextField", "")
    sender:setVisible(false)
    self:setCtrlVisible("DefaultLabel", true)
end

-- 数字键盘插入数字
function GrantGiftDlg:insertNumber(num)
    local count = num
    local meMoney = Me:queryBasicInt("cash")
    
    if count < 0 then
        count = 0
    end
    
    local limit = math.max(math.min(MAX_GRANT_MONEY, meMoney), 0)
    if count > limit then
        count = limit
        if meMoney < MAX_GRANT_MONEY then
            gf:ShowSmallTips(CHS[7002047])
        else
            gf:ShowSmallTips(CHS[7002048])
        end
    end
    
    local cash, color = gf:getArtFontMoneyDesc(count)
    self:setNumImgForPanel("MoneyValuePanel", color, cash, false, LOCATE_POSITION.MID, 21)
    self.money = count

    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(count)
    end
end

function GrantGiftDlg:onConfirmButton()
    local money = self.money
    local meMoney = Me:queryBasicInt("cash")
    local message = self:getInputText("TextField") or ""
    
    -- 金钱不足
    if money > meMoney then
        gf:ShowSmallTips(CHS[7002049])
        return
    end
    
    -- 留言框没有内容
    if not message or message == "" or message == CHS[7002090] then
        gf:ShowSmallTips(CHS[7002050])
        return
    end
    
    -- 输入金额为0
    if self.money == 0 then
        gf:ShowSmallTips(CHS[7002051])
        return
    end
    
    -- 留言是否有敏感词
    local content, contentFilt = gf:filtText(message)
    if contentFilt then
        return 
    end
    
    -- 弹出确认提示
    local moneyStr = gf:getMoneyDesc(money)
    local tip = string.format(CHS[7002052], moneyStr)
    gf:confirm(tip, function()
        gf:CmdToServer("CMD_SET_FOOL_GIFT_RESULT", {money = money, message = message})
        DlgMgr:closeDlg("GrantGiftDlg")
    end)
end

function GrantGiftDlg:cleanup()
    self.money = 0
end

return GrantGiftDlg