-- ChallengingLeaderDlg.lua
-- Created by zhengjh Jan/92016
-- 帮派掌门

local ChallengingLeaderDlg = Singleton("ChallengingLeaderDlg", Dialog)
local WORD_LIMIT = 114

function ChallengingLeaderDlg:init()
    self:bindListener("SaveButton", self.onSaveButton)
    self:bindListener("EditButton", self.onEditButton)
    self:hookMsg("MSG_MASTER_INFO")
end

function ChallengingLeaderDlg:setLeaderInfo(data)
    self.data = data
    self:setLabelText("Label_6", data.name or "")
    self:setLabelText("Label_7", data.title or "")
    self:setLabelText("Label_8", data.level or "")

    if not data.party_name or  data.party_name == "" then
        data.party_name = CHS[3002301]
    end

    self:setLabelText("Label_10", data.party_name)

    -- 有套装显示套装icon
    if data.suit_icon and data.suit_icon ~= 0 then
        self:setPortrait("LeaderIconPanel", data.suit_icon, data.weapon_icon, self.root, true, nil, nil, nil, data.icon)
    else
        self:setPortrait("LeaderIconPanel", data.icon, data.weapon_icon, self.root, true)
    end

    -- 仙魔光效
    if data["upgrade/type"] then
        self:addUpgradeMagicToCtrl("LeaderIconPanel", data["upgrade/type"], nil, true)
    end

    -- 掌门留言
    local msg
    if data.signature then
        msg = data.signature
    else
        local polar = Me:queryBasicInt("polar")
        msg = string.format(CHS[3002302], gf:getPolarLeader(polar))
    end

    self:setText(msg, data.insider_level, data.gender)

    self:changeEditState(false)

    self:bindEditFieldForSafe("TextPanel", WORD_LIMIT * 0.5, nil, cc.VERTICAL_TEXT_ALIGNMENT_TOP, nil, gf:isIos())

    if data.isLeader == 0 then
        self:setCtrlVisible("EditButton", false)
        self:setCtrlVisible("SaveButton", false)
        self:setCtrlVisible("ShareButton", false)
    else
        -- 不是名片，创建分享按钮
        self:setCtrlVisible("ShareButton", true)
        self:createShareButton(self:getControl("ShareButton"), self:getShareType())
    end
end

function ChallengingLeaderDlg:getShareType()
    return SHARE_FLAG.CHALLENGLEADER
end

function ChallengingLeaderDlg:onSaveButton(sender, eventType)
    self:changeEditState(false)
    local text = self:getInputText("TextField")
    text = gf:filtText(text, Me:queryBasic("gid"))
    text = BrowMgr:addGenderSign(text)
    self:setInputText("TextField", text)
    self:setText(text, Me:getVipType(), Me:queryBasicInt("gender"))

    local data = {}
    data.id = self.data.id
    data.para = 2
    data.msg = text
    ChallengeLeaderMgr:operMaster(data)
end

function ChallengingLeaderDlg:onEditButton(sender, eventType)
    self:changeEditState(true)
    local text = self.sign or ""
    self:setInputText("TextField", text)
end

function ChallengingLeaderDlg:changeEditState(isEdit)
    if isEdit then
        self:setCtrlVisible("EditButton", false)
        self:setCtrlVisible("MassagePanel", false)
        self:setCtrlVisible("SaveButton", true)
        self:setCtrlVisible("TextField", true)
    else
        self:setCtrlVisible("EditButton", true)
        self:setCtrlVisible("MassagePanel", true)
        self:setCtrlVisible("SaveButton", false)
        self:setCtrlVisible("TextField", false)
    end
end

function ChallengingLeaderDlg:setText(str, vipLevel, gender)
    self.sign = str
    local messagePanel = self:getControl("MassagePanel")
    if not self.lableText then
        self.lableText = CGAColorTextList:create(true)
        messagePanel:addChild(tolua.cast(self.lableText, "cc.LayerColor"))
    end

    self.lableText:setFontSize(19)

    -- 添加表情性别
    str = BrowMgr:addGenderSign(str, gender, vipLevel)
    self.lableText:setString(gf:filterPlayerColorText(str), vipLevel > 0)
    self.lableText:setContentSize(messagePanel:getContentSize().width, 0)
    self.lableText:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    self.lableText:updateNow()
    local labelW, labelH = self.lableText:getRealSize()
    self.lableText:setPosition(0, messagePanel:getContentSize().height)
end

function ChallengingLeaderDlg:bindEditField(ctrlName, lenLimit)
    local textCtrl = self:getControl(ctrlName)

    textCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then
            local text = textCtrl:getStringValue()
            if gf:getTextLength(text) > lenLimit then
                text = gf:subString(text, lenLimit)
                textCtrl:setText(tostring(text))
                gf:ShowSmallTips(CHS[5400041])
                return true
            end
        end
    end)
end

function ChallengingLeaderDlg:MSG_MASTER_INFO(data)
    self:setLeaderInfo(data)
end

function ChallengingLeaderDlg:cleanup()
    self.lableText = nil
end

return ChallengingLeaderDlg
