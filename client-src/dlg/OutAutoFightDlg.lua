-- OutAutoFightDlg.lua
-- Created by zhengjh Aug/29/2016
-- 巡逻界面的自动战斗技能界面

local AutoFightDlg = require("dlg/AutoFightDlg")
local OutAutoFightDlg = Singleton("OutAutoFightDlg", AutoFightDlg)

function OutAutoFightDlg:getCfgFileName() 
    return ResMgr:getDlgCfg("OutAutoFightDlg")
end

function OutAutoFightDlg:init()
    self:setCtrlFullClient("BlackPanel")
    AutoFightDlg.init(self)
end

function OutAutoFightDlg:refreshRootSize(size)
    self:getControl("MainPanel"):setContentSize(size)
end

function OutAutoFightDlg:setCombinationVisible(visible)
    self:setCtrlVisible("CombinationPanel", visible)
    self:setCtrlVisible("BKPanel", visible)
end

function OutAutoFightDlg:cleanup()
    DlgMgr:sendMsg("PracticeDlg", "swichUpAndDownButton")
    AutoFightDlg.cleanup(self)
end

function OutAutoFightDlg:isExitFightPet()
    local  pet = PetMgr:getFightPet()
    if not pet then
        return false
    end

    return true
end

function OutAutoFightDlg:isExitFightKid()
    local kid = HomeChildMgr:getFightKid()
    if not kid then
        return false
    end

    return true
end

-- 点击组合技能图标
function OutAutoFightDlg:onZHPlayerSkillButton(sender)
    local petAutoData = AutoFightMgr:getPlayerAutoFightData()
    if petAutoData and next(petAutoData)  and petAutoData.multi_count > 0 then
        local data = AutoFightMgr:changeMeDataToCmd()
        data.multi_index = 1
        AutoFightMgr:setMeAutoFightAction(nil, nil, data)
        self.fuc(self.obj, self:getZHFirstSkill(), "me")
        self:onCloseButton()
    else
        gf:ShowSmallTips(CHS[4100977]) -- "你还未设置任何组合指令，请点击组合指令图标右侧#R设置#n按钮进行组合指令设置。
    end    
end

-- 点击组合技能图标
function OutAutoFightDlg:onZHPetSkillButton(sender)
    if not HomeChildMgr:getFightKid() and not PetMgr:getFightPet() then return end
    local petAutoData = AutoFightMgr:changePetDataToCmd()
    if petAutoData and next(petAutoData)  and petAutoData.multi_count > 0 then
        local data = AutoFightMgr:changePetDataToCmd()
        data.multi_index = 1
        AutoFightMgr:setPetAutoFightAction(nil, nil, data)
        self.fuc(self.obj, self:getZHFirstSkill(), "pet")
        self:onCloseButton()
    else
        gf:ShowSmallTips(CHS[4100977])
    end    
end

function OutAutoFightDlg:onCloseButton()
    AutoFightDlg.onCloseButton(self)
    DlgMgr:sendMsg("PracticeDlg", "swichUpAndDownButton")
end



return OutAutoFightDlg
