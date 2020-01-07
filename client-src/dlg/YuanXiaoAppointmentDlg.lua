-- YuanXiaoAppointmentDlg.lua
-- Created by huangzz Sep/28/2018
-- 相约元宵-邀约对象界面

local YuanXiaoAppointmentDlg = Singleton("YuanXiaoAppointmentDlg", Dialog)

function YuanXiaoAppointmentDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)

    self:bindListener("ChoosePanel1", self.onChoosePanel1)
    self:bindListener("ChoosePanel2", self.onChoosePanel2)
    self:initView()
end

function YuanXiaoAppointmentDlg:initView(sender, eventType)
    self:creatCharDragonBones(ResMgr.icon.zhanglaoban, "ChoosePanel1")
    self:creatCharDragonBones(ResMgr.icon.lianhuaguniang, "ChoosePanel2")

    self:onChoosePanel1()
end

function YuanXiaoAppointmentDlg:creatCharDragonBones(icon, panelName)
    local panel = self:getControl("BodyPanel", nil, panelName)
    local dbMagic = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    if not dbMagic then return end

    local magic = tolua.cast(dbMagic, "cc.Node")   
    magic:setPosition(panel:getContentSize().width * 0.5 + 16, 10)
    magic:setName("charPortrait")
    magic:setTag(icon)
    magic:setRotationSkewY(isFilp and 180 or 0)
    magic:setScale(0.7)
    panel:addChild(magic)

    self[panelName] = dbMagic
    self[panelName .. "node"] = magic
    return magic
end

function YuanXiaoAppointmentDlg:stopCharDragonBones(panelName)
    if self[panelName] then
        DragonBonesMgr:toStop(self[panelName], "stand", 1)
        -- self[panelName .. "node"]:setColor(cc.c3b(30, 30, 30))
    end

    self:setCtrlVisible("ChoseeImage1", false, panelName)
    self:setCtrlVisible("ChoseeImage2", false, panelName)
end

function YuanXiaoAppointmentDlg:playCharDragonBones(panelName)
    if self[panelName] then
        DragonBonesMgr:toPlay( self[panelName] , "stand", 0)
        -- self[panelName .. "node"]:setColor(cc.c3b(255, 255, 255))
    end

    self:setCtrlVisible("ChoseeImage1", true, panelName)
    self:setCtrlVisible("ChoseeImage2", true, panelName)
end

function YuanXiaoAppointmentDlg:onChoosePanel1(sender, eventType)
    self:stopCharDragonBones("ChoosePanel2")
    self:playCharDragonBones("ChoosePanel1")

    self.selectNpc = CHS[3000850]
end

function YuanXiaoAppointmentDlg:onChoosePanel2(sender, eventType)
    self:stopCharDragonBones("ChoosePanel1")
    self:playCharDragonBones("ChoosePanel2")

    self.selectNpc = CHS[3000797]
end

function YuanXiaoAppointmentDlg:onConfirmButton(sender, eventType)
    if not self.selectNpc then return end

    gf:confirm(string.format(CHS[5400762], self.selectNpc), function()
        gf:CmdToServer("CMD_YUANXJ_2019_SELECT_TARGET_NPC", {target_npc = self.selectNpc})
        DlgMgr:closeDlg("YuanXiaoAppointmentDlg")
    end)
end

function YuanXiaoAppointmentDlg:cleanup()
    DragonBonesMgr:removeCharDragonBonesResoure(ResMgr.icon.zhanglaoban, string.format("%05d", ResMgr.icon.zhanglaoban))
    DragonBonesMgr:removeCharDragonBonesResoure(ResMgr.icon.lianhuaguniang, string.format("%05d", ResMgr.icon.lianhuaguniang))
end

return YuanXiaoAppointmentDlg
