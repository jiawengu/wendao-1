-- PeachSignWriteDlg.lua
-- Created by huangzz  Nov/17/2017 
-- 祝福签填写界面

local MarriageSignWriteDlg = require('dlg/MarriageSignWriteDlg')
local PeachSignWriteDlg = Singleton("PeachSignWriteDlg", MarriageSignWriteDlg)

local WORD_LIMIT = 75

function PeachSignWriteDlg:init()
    self:bindListener("SignButton", self.onSignButton, "SignTabPanel0")
    self:bindListener("SignButton", self.onSignButton, "SignTabPanel1")
    self:bindListener("SignButton", self.onSignButton, "SignTabPanel3")
    self:bindListener("DelButton", self.onDelButton,  "InfoPanel")
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindCheckBoxListener("CheckBox", self.onCheckBox, "MyNamePanel")
    
    self.inputText = ""
    self.isShowName = 1 -- 是否显示玩家名字，0 否，1 是
    local ctrl = self:getControl("CheckBox", nil, "MyNamePanel")
    ctrl:setSelectedState(true)
    
    self.lastSelectPanel = nil
    self:onSignButton(self:getControl("SignButton", nil, "SignTabPanel0"))
    
    self:bindEditField("InfoPanel", WORD_LIMIT, "DelButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP, self.onGetInputText)
    self:setCtrlVisible("AfterPanel", false)
    self:setCtrlVisible("DelButton", false, "InfoPanel")
    
    self:setLabelText("BeforeLabel", CHS[5410169])
    
    self:hookMsg("MSG_WRITE_ZFQ_RESULT")
end

-- 提交祝福签内容
function PeachSignWriteDlg:onConfirmButton(sender, eventType)
    if gf:getTextLength(self.inputText) < 10 then
        gf:ShowSmallTips(CHS[5420087])
        return
    end

    -- 屏蔽敏感字
    local filtTextStr, haveFilt = gf:filtText(self.inputText, nil, false)
    if haveFilt then
        self:setInputText("InputTextField", filtTextStr)
        local dlg = DlgMgr:openDlg("OnlyConfirmDlg")
        dlg:setTip(CHS[5420088])
        self.inputText = filtTextStr
        return
    end
    
    if self.type > 1 then
        local coin = Me:getTotalCoin()
        if coin < self.coin then
            gf:askUserWhetherBuyCoin()
            return
        end
    
        local realUseSilver = Me:queryInt("silver_coin")
        local coin_type = CHS[6000042]
        if realUseSilver <= 0 then 
            realUseSilver = 0 
        end
        
        if self.coin <= realUseSilver then
            realUseSilver = self.coin
            coin_type = CHS[6000042] -- 银元宝
        else
            coin_type = CHS[3002769] .. string.format(CHS[5410178], self.coin - realUseSilver) -- 有金元宝
        end
        
        -- 安全锁判断
        if self:checkSafeLockRelease("onConfirmButton") then
            return
        end

        gf:confirm(string.format(CHS[5410170] , self.coin, coin_type), function() 
            gf:confirm(CHS[5410171], function ()
                gf:CmdToServer("CMD_WRITE_ZFQ", {text = self.inputText, type = self.type, isShowName = self.isShowName})
            end)
        end)
    else
        gf:confirm(CHS[5410171], function ()
            gf:CmdToServer("CMD_WRITE_ZFQ", {text = self.inputText, type = self.type, isShowName = self.isShowName})
        end)
    end
end

-- 祝福签类型选择
function PeachSignWriteDlg:onSignButton(sender, eventType)
    if self.lastSelectPanel then
        self:setCtrlVisible("ChoosenEffectImage", false, self.lastSelectPanel)
    end

    self.lastSelectPanel = sender:getParent()
    self:setCtrlVisible("ChoosenEffectImage", true, self.lastSelectPanel)

    if self.lastSelectPanel:getName() == "SignTabPanel0" then
        -- 纸签
        self:setCtrlVisible("MoneyImage", false)
        self:setCtrlVisible("NumPanel", false)
        self:setCtrlVisible("BKPanel_1", true)
        self:setCtrlVisible("BKPanel_2", false)
        self:setCtrlVisible("BKPanel_3", false)
        self:setCtrlVisible("TipsLabel", false)
        self:setCtrlVisible("TextLabel_2", true, "MoneyPanel")
        self:setCtrlVisible("TextLabel", false, "MoneyPanel")

        self.coin = 0
        self.type = 1
    elseif self.lastSelectPanel:getName() == "SignTabPanel1" then
        -- 竹签
        self:setCtrlVisible("MoneyImage", true)
        self:setCtrlVisible("NumPanel", true)
        self:setCtrlVisible("BKPanel_1", false)
        self:setCtrlVisible("BKPanel_2", true)
        self:setCtrlVisible("BKPanel_3", false)
        self:setCtrlVisible("TipsLabel", true)
        self:setCtrlVisible("TextLabel_2", false, "MoneyPanel")
        self:setCtrlVisible("TextLabel", true, "MoneyPanel")

        local goldText = gf:getArtFontMoneyDesc(999)
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.LEFT_TOP, 23)

        self.coin = 999
        self.type = 2
    else
        -- 玉签
        self:setCtrlVisible("MoneyImage", true)
        self:setCtrlVisible("NumPanel", true)
        self:setCtrlVisible("BKPanel_1", false)
        self:setCtrlVisible("BKPanel_2", false)
        self:setCtrlVisible("BKPanel_3", true)
        self:setCtrlVisible("TipsLabel", true)
        self:setCtrlVisible("TextLabel_2", false, "MoneyPanel")
        self:setCtrlVisible("TextLabel", true, "MoneyPanel")

        local goldText = gf:getArtFontMoneyDesc(9999)
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.LEFT_TOP, 23)

        self.coin = 9999
        self.type = 3
    end
end

function PeachSignWriteDlg:onDelButton(sender, eventType)
    self:setCtrlVisible("BeforePanel", true)
    self:setInputText("InputTextField", "")
    self.inputText = ""
    sender:setVisible(false)
end

function PeachSignWriteDlg:MSG_WRITE_ZFQ_RESULT(data)
    self:MSG_WRITE_YYQ_RESULT(data)
end

return PeachSignWriteDlg
