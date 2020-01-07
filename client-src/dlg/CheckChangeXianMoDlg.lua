-- CheckChangeXianMoDlg.lua
-- Created by lixh Nov/16 2017
-- 仙魔转换确认界面

local CheckChangeXianMoDlg = Singleton("CheckChangeXianMoDlg", Dialog)

function CheckChangeXianMoDlg:init(data)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    
    self.selectType = data.type
    self.material = data.material
    
    self:setTips()
    self:setMaterialPanel()
end

-- 设置提示
function CheckChangeXianMoDlg:setTips()
    local str = ""
    if self.selectType == CHILD_TYPE.UPGRADE_IMMORTAL then
        str = string.format(CHS[7100070], CHS[7100065], CHS[7100064])
    else
        str = string.format(CHS[7100070], CHS[7100064], CHS[7100065])
    end
    
    self:setLabelText("Label1", str, "MainPanel")
end

-- 设置材料消耗(天星石)
function CheckChangeXianMoDlg:setMaterialPanel()
    local panel = self:getControl("ItemImagePanel1")
    panel.data = self.material
    self:setImage("ItemImage", ResMgr:getIconPathByName(self.material.name), panel)

    local amount = InventoryMgr:getAmountByName(self.material.name)
    if amount < self.material.num then
        self:setNumImgForPanel("NumberPanel1", ART_FONT_COLOR.RED, amount, false, LOCATE_POSITION.RIGHT_TOP, 21, panel)
    else
        self:setNumImgForPanel("NumberPanel1", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_TOP, 21, panel)
    end

    local needStr = "/" .. self.material.num
    self:setNumImgForPanel("NumberPanel2", ART_FONT_COLOR.NORMAL_TEXT, needStr, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
    self:bindTouchEndEventListener(panel, self.onMaterialPanel)
end

function CheckChangeXianMoDlg:onMaterialPanel(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    if sender.data then
        InventoryMgr:showBasicMessageDlg(sender.data.name, rect)
    end
end

function CheckChangeXianMoDlg:onCancelButton(sender, eventType)
    Dialog.onCloseButton(self)
end

function CheckChangeXianMoDlg:onConfrimButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003663])
        return
    end

    -- 真身状态，才能完成仙魔的转换
    if not Me:isRealBody() then
        gf:ShowSmallTips(CHS[7100067])
        return
    end

    local meUpgradeType = Me:getChildType() == 1 and CHILD_TYPE.UPGRADE_IMMORTAL or CHILD_TYPE.UPGRADE_MAGIC

    -- 你当前已飞升成仙
    if self.selectType == meUpgradeType and meUpgradeType == CHILD_TYPE.UPGRADE_IMMORTAL then
        gf:ShowSmallTips(string.format(CHS[7100068], CHS[7100064]))
        return
    end

    -- 你当前已飞升成魔
    if self.selectType == meUpgradeType and meUpgradeType == CHILD_TYPE.UPGRADE_MAGIC then
        gf:ShowSmallTips(string.format(CHS[7100068], CHS[7100065]))
        return
    end

    -- 你携带的天星石数量不足
    if InventoryMgr:getAmountByName(self.material.name) < self.material.num then
        gf:ShowSmallTips(CHS[7100069])
        return
    end

    -- 安全锁判断
    if SafeLockMgr:isToBeRelease() then
        return
    end

    gf:CmdToServer("CMD_CONFIRM_RESULT", {select = self.selectType})
    self:onCloseButton()
end

return CheckChangeXianMoDlg
