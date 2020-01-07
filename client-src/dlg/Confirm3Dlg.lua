-- Confirm3Dlg.lua
-- Created by songcw June/08/2018
-- 精研技能确认框

local Confirm3Dlg = Singleton("Confirm3Dlg", Dialog)

function Confirm3Dlg:init(data)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCloseButton)

    self:setData(data)

    self:MSG_UPDATE()
    self:hookMsg("MSG_UPDATE")
end

function Confirm3Dlg:setData(data)
    self.data = data

    local skillName = SkillMgr:getSkillName(data.skill_no)
    local tips
    local times = data.new_level - data.level
    if times == 1 then
        tips = string.format(CHS[4010139], skillName)
    else
        tips = string.format(CHS[4010140], skillName, times)
    end
    --self:setLabelText("ContentLabel", tips)
    self:setColorText(tips, "ContentPanel", nil, 0, 0, nil, 20, true)


    local costMoney = data.need_cash
    local costMoneyDesc, fontColor = gf:getArtFontMoneyDesc(costMoney, true)
    self:setNumImgForPanel("MoneyPanel2", fontColor, costMoneyDesc, false, LOCATE_POSITION.LEFT_BOTTOM, 23)

    local costPot = data.need_pot
    local costPotDesc = gf:getMoneyDesc(costPot, true)
    self:setLabelText("CostConsumeLabel", costPotDesc)
end

function Confirm3Dlg:MSG_UPDATE()

    local ownPot = Me:queryInt("pot")
    local potDesc = gf:getMoneyDesc(ownPot, true)
    self:setLabelText("OwnConsumeLabel", potDesc)

    local ownMoney = Me:queryInt("cash")
    local moneyDesc, fontColor = gf:getArtFontMoneyDesc(ownMoney, true)
    self:setNumImgForPanel("MoneyPanel1", fontColor, moneyDesc, false, LOCATE_POSITION.LEFT_BOTTOM, 23)
end

function Confirm3Dlg:onConfirmButton()

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    end
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003646])
        return
    end

    if Me:queryBasicInt("level") < 100 then
        gf:ShowSmallTips(CHS[4010135])
        return
    end

    if not TaskMgr:isCompleteBaijiTask() then
        gf:ShowSmallTips(CHS[4010136])
        return
    end

    if self.data.level < SkillMgr:getLearnLevelMax() then
        gf:ShowSmallTips(CHS[4010137])
        return
    end

    if self.data.level >= SkillMgr:getStudyLevelMax() then
        gf:ShowSmallTips(CHS[4010138])
        return
    end

    if self.data.need_pot > Me:queryInt("pot") then
        gf:ShowSmallTips(CHS[4010141])
        return
    end

    gf:CmdToServer("CMD_LEARN_UPPER_STD_SKILL", {
        skill_no = self.data.skill_no,
        up_level = self.data.new_level - self.data.level
    })

    self:onCloseButton()
end

function Confirm3Dlg:onCancelButton(sender, eventType)




end

return Confirm3Dlg
