-- CheckChangeChildDlg.lua
-- Created by songcw May/04/2017
-- 重新结婴

local CheckChangeChildDlg = Singleton("CheckChangeChildDlg", Dialog)

local RESET_COST = {
    [1] = {name = CHS[3000666], needCount = 2},
    [2] = {name = CHS[3000689], needCount = 1, isJewelry = true, level = 70},
}

function CheckChangeChildDlg:init()
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:setPayInfo()

    self.bType = nil
    self:hookMsg("MSG_ENTER_ROOM")
end

function CheckChangeChildDlg:setChildInfo(bType, str)
    self.bType = bType
    self:setLabelText("Label1", string.format(CHS[4100604], str))
end

function CheckChangeChildDlg:setPayInfo()
    for i = 1, 2 do
        local panel = self:getControl("ItemImagePanel" .. i)
        panel.data = RESET_COST[i]
        local amount = InventoryMgr:getAmountByName(RESET_COST[i].name)
        self:setImage("ItemImage", ResMgr:getIconPathByName(RESET_COST[i].name), panel)
        if amount < RESET_COST[i].needCount then
            self:setNumImgForPanel("NumberPanel1", ART_FONT_COLOR.RED, amount, false, LOCATE_POSITION.RIGHT_TOP, 21, panel)
        else
            self:setNumImgForPanel("NumberPanel1", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_TOP, 21, panel)
        end
        
        if RESET_COST[i].level then
            self:setNumImgForPanel(panel, ART_FONT_COLOR.NORMAL_TEXT, RESET_COST[i].level, false, LOCATE_POSITION.LEFT_TOP, 21)
        end

        local needStr = "/" .. RESET_COST[i].needCount
        self:setNumImgForPanel("NumberPanel2", ART_FONT_COLOR.NORMAL_TEXT, needStr, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
        self:bindTouchEndEventListener(panel, self.onCostImage)
    end
end

function CheckChangeChildDlg:onCostImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local data = sender.data
    local name = sender.data.name
    if data.isJewelry then
        local item = gf:deepCopy(InventoryMgr:getItemInfoByName(name))
        local dlg = DlgMgr:openDlg("JewelryInfoDlg")
        local pos = item.pos or 6
        local item = dlg:getInitJewelry(pos, name)
        item.pos = nil
        dlg:setJewelryInfo(item, pos, true)
        dlg:setFloatingFramePos(rect)
    else
        InventoryMgr:showBasicMessageDlg(name, rect)
    end
end

function CheckChangeChildDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

function CheckChangeChildDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

function CheckChangeChildDlg:onConfrimButton(sender, eventType)
    if not self.bType then return end

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

    -- 安全锁判断
    if self:checkSafeLockRelease("onConfrimButton") then
        return
    end


    for i = 1, 2 do
        local amount = InventoryMgr:getAmountByName(RESET_COST[i].name)
        if amount < RESET_COST[i].needCount then
            gf:ShowSmallTips(string.format(CHS[4100574], RESET_COST[i].name))
            return
        end
    end

    gf:CmdToServer("CMD_CONFIRM_RESULT", {select = self.bType})
    self:onCloseButton()
end

function CheckChangeChildDlg:MSG_ENTER_ROOM(data)
    self:onCloseButton()
end

return CheckChangeChildDlg
