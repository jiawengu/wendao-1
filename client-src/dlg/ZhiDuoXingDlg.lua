-- ZhiDuoXingDlg.lua
-- Created by huangzz Aug/16/2017
-- 帮派智多星技能求助界面


local ZhiDuoXingDlg = Singleton("ZhiDuoXingDlg", Dialog)

local SKILLS = {
    {name = CHS[5450006], icon = ResMgr.ui.tianzhijuan, type = "tianzhijuan", desc = CHS[5450009]},
    {name = CHS[5450007], icon = ResMgr.ui.dizhijuan, type = "dizhijuan", desc = CHS[5450010]},
    {name = CHS[5450008], icon = ResMgr.ui.renzhijuan, type = "renzhijuan", desc = CHS[5450011]},
}

local COUNT_DOWN_FONT_SIZE = 23
local AMOUNT_FONT_SIZE = 17

function ZhiDuoXingDlg:init()
    self:setFullScreen()
    self:bindListener("ShowButton", self.onShowButton)
    self:bindCtrlTouchListener()

    self:doInit()
    self:onShowButton()
    self:setBasicInfo()
    self:hookMsg("MSG_PARTY_ZHIDUOXING_SKILL")
end

function ZhiDuoXingDlg:bindCtrlTouchListener()
    for i = 1, #SKILLS do
        local itemPanel = self:getControl("ItemPanel", nil, "SkillPanel" .. i)
        itemPanel:setTag(i)
        self:blindLongPress("ItemPanel", self.onOneSecondLater, self.onClick, "SkillPanel" .. i)
    end
end

function ZhiDuoXingDlg:doInit()
    for i = 1, #SKILLS do
        self:setCtrlVisible("ChosenImage_1", false, "SkillPanel" .. i)
        self:setCtrlVisible("ChosenImage_2", false, "SkillPanel" .. i)
    end
end

-- 长按弹出道具描述
function ZhiDuoXingDlg:onOneSecondLater(sender, eventType)
    local tag = sender:getTag()
    local skill = SKILLS[tag]
    local rect = self:getBoundingBoxInWorldSpace(sender)

    local data = {
        desc = skill.desc,
        imagePath = skill.icon,
        resType = ccui.TextureResType.localType,
        basicInfo = {
            skill.name,
        }
    }
    local dlg = DlgMgr:openDlg("BonusInfoDlg")
    local rect = self:getBoundingBoxInWorldSpace(sender)
    dlg:setRewardInfo(data)
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

-- 单击使用道具
function ZhiDuoXingDlg:onClick(sender, eventType)
    local tag = sender:getTag()
    local skill = SKILLS[tag]
    local amount = PartyMgr:getPartyZdxSkillCount(skill.type)
    if amount == 0 then
        gf:ShowSmallTips(CHS[5450012])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[8000005])
        return
    end

    PartyMgr:usePartyZdxSkill(skill.type)
end

function ZhiDuoXingDlg:setBasicInfo()
    for i = 1, #SKILLS do
        local skill = SKILLS[i]
        local itemImage = self:getControl("ItemImage", nil, "SkillPanel" .. i)
        self:setImage("ItemImage", skill.icon, "SkillPanel" .. i)
        local amount = PartyMgr:getPartyZdxSkillCount(skill.type)

        -- 技能剩余次数
        if amount > 1 then
            self:setCtrlVisible("NumPanel", true, "SkillPanel" .. i)
            self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.MID, AMOUNT_FONT_SIZE, "SkillPanel" .. i)
        else
            self:setCtrlVisible("NumPanel", false, "SkillPanel" .. i)
        end

        if amount == 0 then
            -- 技能可使用次数用完，置灰图标
            gf:grayImageView(itemImage)
        else
            gf:resetImageView(itemImage)
        end
    end
end

function ZhiDuoXingDlg:onShowButton()
    local dlg = DlgMgr:openDlg("GameFunctionDlg")
    dlg:onHideButton()
    if Me:isInCombat() then
        dlg:setVisible(false)
    end

    self:setCtrlVisible("ShowButton", false)
    self:setCtrlVisible("FunctionPanel", true)
end

function ZhiDuoXingDlg:onCloseButton()
    self:setCtrlVisible("ShowButton", true)
    self:setCtrlVisible("FunctionPanel", false)
end

function ZhiDuoXingDlg:MSG_PARTY_ZHIDUOXING_SKILL(data)
    self:setBasicInfo()
end

return ZhiDuoXingDlg
