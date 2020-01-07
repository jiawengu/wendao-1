-- ZHSkillTargetChoseDlg.lua
-- Created by songcw Jan/15/2018
-- 组合技能选择对象
local FightTargetChoseDlg = require('dlg/FightTargetChoseDlg')
local ZHSkillTargetChoseDlg = Singleton("ZHSkillTargetChoseDlg", FightTargetChoseDlg)

function ZHSkillTargetChoseDlg:getCfgFileName()
    return ResMgr:getDlgCfg("FightTargetChoseDlg")
end

function ZHSkillTargetChoseDlg:init(type)
    self:setFullScreen()
    self:bindListener("ReturnButton", self.onReturnButton)

    self.type = type

    self.selectType = nil
    self.enemyId = nil
    self.friendId = nil

    local playerData = AutoFightMgr:getPlayerAutoFightData()
    if type == "player" then
    else
        playerData = AutoFightMgr:getPetAutoFightData()
    end

    self:selectTargetChoseByData(playerData)

    DlgMgr:setVisible("AutoFightSettingDlg", false)
end

function ZHSkillTargetChoseDlg:nextTarget(lastId, name, pos)
    if self.selectType == "all" then
        if self.step == 1 then
            self.enemyId = lastId
            self.enemyName = name
            self.enemyPos = pos
            self.step = self.step + 1
            self:setTips(CHS[4300372])
            FightMgr:showZHSelectImage(false, false)
            FightMgr:showZHSelectImage(true, true)
            return
        else
            self.friendId = lastId
            local friendPara = string.format("%s,,%s,,%s", tostring(lastId), name, self:getRealPosInServerByPos(pos))
            local enemyPara = string.format("%s,,%s,,%s", tostring(self.enemyId), self.enemyName, self:getRealPosInServerByPos(self.enemyPos))
            AutoFightMgr:setAutoFightTarget(self:getId(), friendPara, enemyPara)
        end
    elseif self.selectType == "enemy" then
        self.enemyId = lastId
        local enemyPara = string.format("%s,,%s,,%s", lastId, name, tostring(self:getRealPosInServerByPos(pos)))
        AutoFightMgr:setAutoFightTarget(self:getId(), "", enemyPara)

    elseif self.selectType == "friend" then
        self.friendId = lastId
        local friendPara = string.format("%s,,%s,,%s", lastId, name, tostring(self:getRealPosInServerByPos(pos)))
        AutoFightMgr:setAutoFightTarget(self:getId(), friendPara, "")
    end

    self:onCloseButton()
end

-- 服务器的位置，都是1 - 10，客户端会把所有战斗角色位置设置为 0 -19
-- 不行用 fight:queryBasicInt("pos") 原因是，C++会把pos改掉
-- ===========
-- 服务顺序
--        5    10               6    1
--       4    9                7    2
--      3    8                8    3
--     2    7                9    4
--    1    6               10    5

function ZHSkillTargetChoseDlg:getRealPosInServerByPos(pos)
    if pos < 10 then
        return tostring(pos + 1)
    else
        return tostring(10 - (pos - 10))
    end
end

function ZHSkillTargetChoseDlg:selectTargetChoseByData(data)

    local opTab = {}
    for i = 1, data.multi_count do
        local skillNo = AutoFightMgr:getSkillNoByData(data.autoFightData[i])
        local skillName = SkillMgr:getSkillName(skillNo)
        local skillInfo = SkillMgr:getSkillDesc(skillName)
        if skillInfo["op_obj"] then
            opTab[skillInfo["op_obj"]] = 1
        end
    end

    if opTab.enemy and opTab.friend then
        self.selectType = "all"
        self.step = 1
        FightMgr:showZHSelectImage(true, false)
        self:setTips(CHS[4300373])
    elseif opTab.enemy then
        self.selectType = "enemy"
        FightMgr:showZHSelectImage(true, false)
        self:setTips(CHS[4300333])
    elseif opTab.friend then
        self.selectType = "friend"
        FightMgr:showZHSelectImage(true, true)
        self:setTips(CHS[4300333])

    end
end

function ZHSkillTargetChoseDlg:getId()
    if self.type == "player" then
        return Me:getId()
    elseif self.type == "pet" then
        if PetMgr:getFightPet() then
            return PetMgr:getFightPet():getId()
        end
    elseif self.type == "kid" then
        if HomeChildMgr:getFightKid() then
            return HomeChildMgr:getFightKid():getId()
        end
    end
end

function ZHSkillTargetChoseDlg:cleanup()
    DlgMgr:setVisible("AutoFightSettingDlg", true)

    FightMgr:showZHSelectImage(false, true)
    FightMgr:showZHSelectImage(false, false)
end

function ZHSkillTargetChoseDlg:onReturnButton()
    DlgMgr:setVisible("AutoFightSettingDlg", true)
    if self.type == "player" then
        DlgMgr:sendMsg("AutoFightSettingDlg", "onPlayerSkillPanel")
    else
        DlgMgr:sendMsg("AutoFightSettingDlg", "onPetSkillPanel")
    end

    self:onCloseButton()
end

-- CHS[4300333]
function ZHSkillTargetChoseDlg:setTips(tips)
    self:setLabelText('SkillNameLabel', CHS[4300332], "MainPanel")
    self:setLabelText('TargetChoseLabel', tips, "MainPanel")

    self:setLabelText('SkillNameLabel', CHS[4300332], "MainPanel2")
    self:setLabelText('TargetChoseLabel', tips, "MainPanel2")

    self:setCtrlVisible("MainPanel", true)
    self:setCtrlVisible("MainPanel2", false)
end

return ZHSkillTargetChoseDlg
