-- CreatePartyDlg.lua
-- Created by songcw Feb/28/2015
-- 创建帮派界面

local CreatePartyDlg = Singleton("CreatePartyDlg", Dialog)

-- 帮派名字长度限制
local nameLenLimit = 6
local nameMin = 2

local announceLimit = 200

-- 创建帮派默认价格
local CREATE_PARTY_NEED_MONEY = 10000000

function CreatePartyDlg:init()
    self:bindListener("CreateButton", self.onCreateButton)
    self:bindListener("CleanName", self.CleanName)
    self:bindListener("CleanAnnounce", self.CleanAnnounce)

    -- 编辑框添加监听
    -- 帮派名称
    self:bindEditFieldForSafe("NamePanel", nameLenLimit, "CleanName", nil, nil, true)
    local textCtrl = self:getControl("TextField", nil, "NamePanel")
    textCtrl:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    textCtrl:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)

    -- 设置创建帮派默认价格
    local moneyStr, fontColor = gf:getArtFontMoneyDesc(CREATE_PARTY_NEED_MONEY)
    local numImg = self:setNumImgForPanel("MoneyPanel", fontColor, moneyStr, false, LOCATE_POSITION.CENTER, 25)
end

function CreatePartyDlg:CleanName(sender, eventType)
    local namePanel = self:getControl("NamePanel")
    self:setInputText("TextField", "", namePanel)
    self:setCtrlVisible("DefaultLabel", true, namePanel)
    self:setCtrlVisible("CleanName", false)
end

function CreatePartyDlg:CleanAnnounce(sender, eventType)
    local tenetPanel = self:getControl("TenetPanel")
    self:setInputText("TextField", "", tenetPanel)
    self:setCtrlVisible("DefaultLabel", true, tenetPanel)
    self:setCtrlVisible("CleanAnnounce", false)
end

function CreatePartyDlg:onCreateButton(sender, eventType)
    local limitJoinPartyLevel = PartyMgr:getJoinPartyLevelMin()
    if Me:queryBasicInt("level") < limitJoinPartyLevel then
        gf:ShowSmallTips(string.format(CHS[3002371], limitJoinPartyLevel))
        return
    end

    if Me:queryBasic("party/name") ~= "" then
        -- 无帮派显示申请和创建
        gf:ShowSmallTips(CHS[3002373])
        return
    end

    local namePanel = self:getControl("NamePanel")
    local partyName = self:getInputText("TextField", namePanel)
    if partyName == nil or partyName == "" then
        gf:ShowSmallTips(CHS[4000192])
        return
    end

    local len = string.len(partyName)
    if len < nameMin * 2 then
        gf:ShowSmallTips(CHS[3002374])
        return
    end

    if gf:isMeetSearchByGid(partyName) then
        gf:ShowSmallTips(CHS[3002375])
        return
    end

    if not gf:checkHasEnoughMoney(CREATE_PARTY_NEED_MONEY) then
        return
    end

    -- 过滤敏感词
    local announcePanel = self:getControl("TenetPanel")
    local nameText, haveBadName = gf:filtText(partyName)

    if haveBadName then
        return
    end

    PartyMgr:createParty(partyName, "")
    self:onCloseButton()
end

return CreatePartyDlg
