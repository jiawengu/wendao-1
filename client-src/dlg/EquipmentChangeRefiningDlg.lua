-- EquipmentChangeRefiningDlg.lua
-- Created by songcw Api/21/2015
-- 更换炼化属性界面

local EquipmentChangeRefiningDlg = Singleton("EquipmentChangeRefiningDlg", Dialog)
local attrib_blue = 1
local attrib_pink = 2
local attrib_yellow = 3

function EquipmentChangeRefiningDlg:init()
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)

    -- 克隆
    self.listUintPanel = self:getControl("ListUintPanel", Const.UIPanel)
    self.listUintPanel:setColor(COLOR3.WHITE)
    self.listUintPanel:retain()
    self.listUintPanel:removeFromParent()
end

function EquipmentChangeRefiningDlg:cleanup()
    self:releaseCloneCtrl("listUintPanel")
end

function EquipmentChangeRefiningDlg:setList(listTab, pos, refiningType, curSaveAtt, curAttTag)
    self.attList = listTab
    self.saveAtt = curSaveAtt or 0  -- 蓝属性 3条需要用到
    self.curAttTag = curAttTag      -- 蓝属性 3条需要用到
    self.pos = pos
    self.refiningType = refiningType

    if refiningType == attrib_pink then self:setLabelText("TitleLabel", CHS[4000342]) end

    local attriListView = self:resetListView("AttListView")
    for i,att in pairs(listTab) do
        local listUintPanel = self.listUintPanel:clone()
        listUintPanel:setTag(i)
        local str = EquipmentMgr:getAttribChsOrEng(att.field) .. att.value
        if i == 1 then
            self:chooseAttrib(listUintPanel)
            for i,temp in pairs(self.saveAtt) do
                if temp.field == att.field then
                    str = str .. (CHS[4000343])
                end
            end
        end
        self:setLabelText("Label", str, listUintPanel)
        self:bindTouchEndEventListener(listUintPanel, self.chooseAttrib)
        attriListView:pushBackCustomItem(listUintPanel)
    end
end

-- 选择属性按钮
function EquipmentChangeRefiningDlg:chooseAttrib(sender, eventType)
    local attriListView = self:getControl("AttListView")
    local listPanels = attriListView:getItems()
    for i,listPanel in pairs(listPanels) do
        listPanel:setColor(COLOR3.WHITE)
    end

    sender:setColor(COLOR3.GREEN)
    local saveButton = self:getControl("ConfirmButton")
    saveButton:setTag(sender:getTag())
end

function EquipmentChangeRefiningDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

function EquipmentChangeRefiningDlg:onConfirmButton(sender, eventType)
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002399])
        return
    end

    local tag = sender:getTag()
    if self.refiningType == attrib_blue then
        self:confirmBlue(tag)
    elseif self.refiningType == attrib_pink then
        self:confirmPink(tag)
    elseif self.refiningType == attrib_yellow then
    end
    self:onCloseButton()
end

function EquipmentChangeRefiningDlg:confirmBlue(tag)
    local attStr = ""
    for i = 1, 3 do
        if i == self.curAttTag then self.saveAtt[i] = self.attList[tag] end
        if self.saveAtt[i] then
            if attStr == "" then
                attStr = self.saveAtt[i].field
            else
                attStr = attStr .. "|" .. self.saveAtt[i].field
            end
        end
    end

    gf:CmdToServer("CMD_UPGRADE_EQUIP", {
        pos = self.pos,
        type = Const.UPGRADE_EQUIP_SELECT_BLUE,
        para = attStr
    })

end

function EquipmentChangeRefiningDlg:confirmPink(tag)
    local data = {pos = self.pos, type = Const.UPGRADE_EQUIP_SELECT_PINK, para = self.attList[tag].field}
    gf:CmdToServer("CMD_UPGRADE_EQUIP", data)
end

return EquipmentChangeRefiningDlg
