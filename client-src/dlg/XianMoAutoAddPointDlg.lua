-- XianMoAutoAddPointDlg.lua
-- Created by songcw Nov/15/2017
-- 仙魔自动加点界面

local XianMoAutoAddPointDlg = Singleton("XianMoAutoAddPointDlg", Dialog)

local RadioGroup = require("ctrl/RadioGroup")

local CHECK_BOX = {
    "XianCheckBox",
    "MoCheckBox",
}


function XianMoAutoAddPointDlg:init(data)
    self:bindListener("ConfrimButton", self.onConfrimButton)

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CHECK_BOX, self.onCheckBox)

    if data.addType == 1 then
        self:setCheck("XianCheckBox", true)
    else
        self:setCheck("MoCheckBox", true)
    end

    local statePanel = self:getControl("OpenStatePanel")
    self:createSwichButton(statePanel, data.isOpen == 1, self.onSoundSwichButton)
    local tips = data.isOpen == 1 and CHS[4100881] or CHS[4100882]
    self:setLabelText("OpenStateLabel", tips)

    self:hookMsg("MSG_RECOMMEND_XMD")
    self.data = data
    self.isOpen = data.isOpen
end

function XianMoAutoAddPointDlg:MSG_RECOMMEND_XMD(data)

    self.data = data
end

function XianMoAutoAddPointDlg:onSoundSwichButton(isOn, key)
    local isOpen = isOn and 1 or 0
    local addType = self.radioGroup:getSelectedRadioIndex()
 --   gf:CmdToServer("CMD_SET_RECOMMEND_XMD", {addType = addType, isOpen = isOpen})
    self.isOpen = isOpen
    local tips = isOn and CHS[4100881] or CHS[4100882]
    self:setLabelText("OpenStateLabel", tips)
end

function XianMoAutoAddPointDlg:onConfrimButton(sender, eventType)

    -- 安全锁判断
    if not GameMgr:IsCrossDist() and self:checkSafeLockRelease("onConfrimButton") then
        return
    end

    local addType = self.radioGroup:getSelectedRadioIndex()
    gf:CmdToServer("CMD_SET_RECOMMEND_XMD", {addType = addType, isOpen = self.isOpen})


  --  gf:CmdToServer("CMD_SET_RECOMMEND_XMD", {addType = addType, isOpen = self.data.isOpen})

    if self.isOpen == 1 then
        DlgMgr:sendMsg("XianMoAddPointDlg", "aotuAssign", self.radioGroup:getSelectedRadioIndex())
    end
    self:onCloseButton()
end


return XianMoAutoAddPointDlg
