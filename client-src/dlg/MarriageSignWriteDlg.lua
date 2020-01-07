-- MarriageSignWriteDlg.lua
-- Created by huangzz Dec/30/2016
-- 姻缘签填写界面

local MarriageSignWriteDlg = Singleton("MarriageSignWriteDlg", Dialog)

local WORD_LIMIT = 75 -- 限制汉字个数
local WORD_COLOR = cc.c3b(86, 41, 2)

-- 随机内容
local SHOW_SIGNWRITE = {
    [1] = CHS[5420097],
    [2] = CHS[5420098],
    [3] = CHS[5420099],
    [4] = CHS[5420100],
    [5] = CHS[5420101],
    [6] = CHS[5420102],
    [7] = CHS[5420103],
    [8] = CHS[5420115],
    [9] = CHS[5420116],
    [10] = CHS[5420117],
    [11] = CHS[5420118],
    [12] = CHS[5420119],
    [13] = CHS[5420120],
    [14] = CHS[5420121],
    [15] = CHS[5420122],
    [16] = CHS[5420123],
    [17] = CHS[5420124],
    [18] = CHS[5420125],
    [19] = CHS[5420126],
    [20] = CHS[5420127],
}

function MarriageSignWriteDlg:init()
    self:bindListener("SignButton", self.onSignButton, "SignTabPanel0")
    self:bindListener("SignButton", self.onSignButton, "SignTabPanel1")
    self:bindListener("SignButton", self.onSignButton, "SignTabPanel3")
    self:bindListener("DelButton", self.onDelButton, "InfoPanel")
    self:bindListener("Button_220", self.onButton_220)
    self:bindListener("DelButton", self.onDelButton_220, "ObjectPanel")
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("RoundButton", self.onRoundButton)
    self:bindCheckBoxListener("CheckBox", self.onCheckBox, "MyNamePanel")

    self:setCtrlVisible("AfterPanel", false)
    self:setCtrlVisible("DelButton", false, "ObjectPanel")

    self.wishObjectGid = ""
    self.inputText = ""
    self.isShowName = 0 -- 是否显示玩家名字，0 否，1 是

    self:bindEditField("InfoPanel", WORD_LIMIT, "DelButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP, self.onGetInputText)

    self:onSignButton(self:getControl("SignButton", nil, "SignTabPanel0"))

    self:setLabelText("BeforeLabel", CHS[5420095])

    math.randomseed(os.time())
    self.randomNum = math.random(0, #SHOW_SIGNWRITE - 1)

    self:hookMsg("MSG_WRITE_YYQ_RESULT")
end

function MarriageSignWriteDlg:onGetInputText(sender, eventType)
    self.inputText = tostring(sender:getStringValue())
end

function MarriageSignWriteDlg:bindEditField(parentPanelName, lenLimit, clenButtonName, verAlign, eventCallBack)
    local panel = self:getControl(parentPanelName)
    local textCtrl = self:getControl("InputTextField", nil, panel)
    textCtrl:setPlaceHolder("")
    textCtrl:setVisible(true)
    textCtrl:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    textCtrl:setTextVerticalAlignment(verAlign or cc.TEXT_ALIGNMENT_CENTER)
    self:setCtrlVisible(clenButtonName, true, panel)
    self:setCtrlVisible("BeforePanel", true, panel)

    textCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then
            self:setCtrlVisible(clenButtonName, true, panel)
            self:setCtrlVisible("BeforePanel", false, panel)

            local str = textCtrl:getStringValue()
            if gf:getTextLength(str) > lenLimit * 2 then
                gf:ShowSmallTips(CHS[4000224])
            end

            textCtrl:setText(tostring(gf:subString(str, lenLimit * 2)))
            if eventCallBack then
                eventCallBack(self, sender, eventType)
            end
        elseif ccui.TextFiledEventType.delete_backward == eventType then
            -- 判断是否为空,如果将来需要有清空输入按钮
            local str = sender:getStringValue()
            if "" == str then
                self:setCtrlVisible(clenButtonName, false, panel)
            end

            if eventCallBack then
                eventCallBack(self, sender, eventType)
            end
        end
    end)
end

-- 设置祈愿对象
function MarriageSignWriteDlg:setWishObject(name, gid)
    self:setCtrlVisible("Label_1", false, "FrameImage")
    self:setCtrlVisible("Label_2", true, "FrameImage")

    self:setLabelText("Label_2", name, "FrameImage")
    self:setCtrlVisible("DelButton", true, "ObjectPanel")
    self.wishObjectGid = gid
end

-- 姻缘签类型选择
function MarriageSignWriteDlg:onSignButton(sender, eventType)
    if self.lastSelectPanel then
        self:setCtrlVisible("ChoosenEffectImage", false, self.lastSelectPanel)
    end

    self.lastSelectPanel = sender:getParent()
    self:setCtrlVisible("ChoosenEffectImage", true, self.lastSelectPanel)

    if self.lastSelectPanel:getName() == "SignTabPanel0" then
        -- 纸签
        self:setCtrlVisible("FreeLabel", true)
        self:setCtrlVisible("MoneyImage", false)
        self:setCtrlVisible("NumPanel", false)
        self:setCtrlVisible("BKPanel_1", true)
        self:setCtrlVisible("BKPanel_2", false)
        self:setCtrlVisible("BKPanel_3", false)
        self:setCtrlVisible("TipsLabel", false)

        self.coin = 0
        self.type = 1
    elseif self.lastSelectPanel:getName() == "SignTabPanel1" then
        -- 竹签
        self:setCtrlVisible("FreeLabel", false)
        self:setCtrlVisible("MoneyImage", true)
        self:setCtrlVisible("NumPanel", true)
        self:setCtrlVisible("BKPanel_1", false)
        self:setCtrlVisible("BKPanel_2", true)
        self:setCtrlVisible("BKPanel_3", false)
        self:setCtrlVisible("TipsLabel", true)

        local goldText = gf:getArtFontMoneyDesc(999)
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.LEFT_TOP, 23)

        self.coin = 999
        self.type = 2
    else
        -- 玉签
        self:setCtrlVisible("FreeLabel", false)
        self:setCtrlVisible("MoneyImage", true)
        self:setCtrlVisible("NumPanel", true)
        self:setCtrlVisible("BKPanel_1", false)
        self:setCtrlVisible("BKPanel_2", false)
        self:setCtrlVisible("BKPanel_3", true)
        self:setCtrlVisible("TipsLabel", true)

        local goldText = gf:getArtFontMoneyDesc(9999)
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.LEFT_TOP, 23)

        self.coin = 9999
        self.type = 3
    end
end

function MarriageSignWriteDlg:onDelButton(sender, eventType)
    self:setCtrlVisible("BeforePanel", false)
    self:setInputText("InputTextField", "")
    self.inputText = ""
    sender:setVisible(false)
end

-- 选择祈愿对象
function MarriageSignWriteDlg:onButton_220(sender, eventType)
    if #FriendMgr:getFriends() == 0 then
        gf:ShowSmallTips(CHS[5420084])
        return
    end

    DlgMgr:openDlg("SignFriendDlg")
end

-- 删除祈愿对象
function MarriageSignWriteDlg:onDelButton_220(sender, eventType)
    self:setCtrlVisible("DelButton", false, "ObjectPanel")
    self:setCtrlVisible("Label_1", true, "FrameImage")
    self:setCtrlVisible("Label_2", false, "FrameImage")
    self.wishObjectGid = ""
end

-- 提交姻缘签内容
function MarriageSignWriteDlg:onConfirmButton(sender, eventType)
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

    gf:confirm(CHS[5420089], function ()
        local coin = Me:getTotalCoin()
        if coin < self.coin then
            gf:askUserWhetherBuyCoin()
            return
        end

        gf:CmdToServer("CMD_WRITE_YYQ", {gid = self.wishObjectGid, text = self.inputText, type = self.type, isShowName = self.isShowName})
    end)
end

function MarriageSignWriteDlg:onRoundButton(sender, eventType)
    local count = #SHOW_SIGNWRITE
    self.randomNum = (self.randomNum + 7) % count

    local gender = Me:queryBasicInt("gender")
    -- 女性角色不显示第1条
    if self.randomNum == 0 and gender == 2 then
        self.randomNum = (self.randomNum + 7) % count
    end

    -- 男性角色不显示第15条
    if self.randomNum == 14 and gender == 1 then
        self.randomNum = (self.randomNum + 7) % count
    end

    self:setCtrlVisible("BeforePanel", false)
    self:setInputText("InputTextField", SHOW_SIGNWRITE[self.randomNum + 1])
    self.inputText = SHOW_SIGNWRITE[self.randomNum + 1]
    self:setCtrlVisible("DelButton", true, "InfoPanel")
end

function MarriageSignWriteDlg:onCheckBox(sender, eventType)
    if sender:getSelectedState() then
        self.isShowName = 1
    else
        self.isShowName = 0
    end
end

-- 成功提交姻缘签内容后，关闭界面
function MarriageSignWriteDlg:MSG_WRITE_YYQ_RESULT(data)
    if data.result == 1 then
        self:close()
    end
end

return MarriageSignWriteDlg
