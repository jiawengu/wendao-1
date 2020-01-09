-- TongTianTopTargetDlg.lua
-- Created by songcw Nov/27/2018
-- 通天塔塔顶 使用通天令牌界面

local TongTianTopTargetDlg = Singleton("TongTianTopTargetDlg", Dialog)

function TongTianTopTargetDlg:init(data)
    self:bindListener("RefuseButton", self.onRefuseButton)
    self:bindListener("AgreeButton", self.onAgreeButton)
    self:bindListener("LastButton", self.onLastButton)
    self:bindListener("NextButton", self.onNextButton)

    self:bindListener("ItemPanel", self.onShowItem)

    self.curItemIdx = 0
    self.useItems = {}

    self:setData(data)
    self:hookMsg("MSG_OPEN_TTLP_DLG")
end

function TongTianTopTargetDlg:setData(data)
    self.data = data

    for i = 1, 5 do
        local panel = self:getControl("MemberPanel_" .. i)

        if data.xingJunInfo[i] then
            panel:setVisible(true)

            self:setImage("ShapeImage", ResMgr:getSmallPortrait(data.xingJunInfo[i].icon), panel)
            self:setLabelText("NameLabel", gf:getRealName(data.xingJunInfo[i].name), panel)
        else
            panel:setVisible(false)
        end
    end

    self:setItemInfo(data)

    local isLeader = Me:isTeamLeader() or not TeamMgr:isTeamMeber(Me)

    self:setCtrlVisible("RefuseButton", isLeader)
    self:setCtrlVisible("AgreeButton", isLeader)
--    self:setCtrlVisible("ItemPanel", Me:isTeamLeader())

    self:setCtrlVisible("ChooseItemPanel", isLeader)
    self:setCtrlVisible("NoteLabel_1", isLeader)

    self:setCtrlVisible("NoteLabel_2", not isLeader)

    self:setCtrlVisible("NoteLabel_3", isLeader)

    self:setLabelText("NoteLabel_3", string.format(CHS[4200634], data.leftTime ), panel)

end

function TongTianTopTargetDlg:getAllUseItems()
    local inventory = InventoryMgr:getAllInventory()
    local allBagItem = {}

    local minDurability = 100
    local minDurabilityLimit = 100

    for _, v in pairs(inventory) do
        if v.name == CHS[7000081] or v.name == CHS[4200614] then
            if minDurability > v.durability then
                minDurability = v.durability
            end

            if InventoryMgr:isLimitedItem(v) and minDurabilityLimit > v.durability then
                minDurabilityLimit = v.durability
            end

            table.insert(allBagItem, v)
        end
    end

    table.sort(allBagItem, function(l, r)
        if l.pos < r.pos then return true end
        if l.pos > r.pos then return false end
    end)

    local minDurabilityPos
    local minDurabilityPosLimit

    for pos, v in pairs(allBagItem) do
        if v.durability == minDurability then
            minDurabilityPos = pos
        end

        if minDurabilityLimit ~= 100 and v.durability == minDurabilityLimit then
            minDurabilityPosLimit = pos
        end
    end

    return allBagItem, minDurabilityPosLimit or minDurabilityPos
end

function TongTianTopTargetDlg:setItemInfo(data)
    local panel = self:getControl("ChooseItemPanel")

    local itemPanel = self:getControl("ItemPanel", nil, panel)
    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[7000081])), itemPanel)

    self.useItems, self.curItemIdx = self:getAllUseItems()

    local item = self.useItems[self.curItemIdx]
    if data.itemPos and data.itemPos ~= 0 then
        for i = 1, #self.useItems do
            if self.useItems[i].pos == data.itemPos then
                item = self.useItems[i]
                self.curItemIdx = i
            end
        end
    end
    self:updateDurability(item)

end

function TongTianTopTargetDlg:updateDurability(item)


    if item then
        self:setLabelText("NaijiuNumLabel", string.format( CHS[7002360], item.durability, item.max_durability))
    else
        self:setLabelText("NaijiuNumLabel", "")
    end

    if #self.useItems <= 1 then
        self:setCtrlEnabled("LastButton", false)
        self:setCtrlEnabled("NextButton", false)

        if #self.useItems == 0 then
            self:setCtrlEnabled("ItemImage", false, "ChooseItemPanel")
            self:setCtrlEnabled("ItemPanel", false)
        end

    elseif self.curItemIdx == 1 then
        self:setCtrlEnabled("LastButton", false)
        self:setCtrlEnabled("NextButton", true)
    elseif self.curItemIdx == #self.useItems then
        self:setCtrlEnabled("LastButton", true)
        self:setCtrlEnabled("NextButton", false)
    else
        self:setCtrlEnabled("LastButton", true)
        self:setCtrlEnabled("NextButton", true)
    end
end

function TongTianTopTargetDlg:onShowItem(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[7000081], rect)
end

function TongTianTopTargetDlg:onRefuseButton(sender, eventType)
    local isLeader = Me:isTeamLeader() or not TeamMgr:isTeamMeber(Me)
    if not isLeader then
        gf:ShowSmallTips(CHS[4101269])
        return
    end

    gf:CmdToServer("CMD_RESTORE_TTTD_XINGJUN")
end

function TongTianTopTargetDlg:onAgreeButton(sender, eventType)
    local isLeader = Me:isTeamLeader() or not TeamMgr:isTeamMeber(Me)
    if not isLeader then
        gf:ShowSmallTips(CHS[4101269])
        return
    end

    if self.data.leftTime <= 0 then
        gf:ShowSmallTips(CHS[4200635])
        return
    end

    gf:confirm(CHS[4101272], function ( )
        -- body
        if #self.useItems == 0 then
            gf:ShowSmallTips(CHS[4101273])
            return
        end

        local item = self.useItems[self.curItemIdx]
        if not item then return end -- 正常不会出现

        gf:CmdToServer("CMD_RANDOM_TTTD_XINGJUN", {pos = item.pos})
    end)
end

function TongTianTopTargetDlg:onLastButton(sender, eventType)
    self.curItemIdx = self.curItemIdx - 1
    local item = self.useItems[self.curItemIdx]
    self:updateDurability(item)
end

function TongTianTopTargetDlg:onNextButton(sender, eventType)
    self.curItemIdx = self.curItemIdx + 1
    local item = self.useItems[self.curItemIdx]
    self:updateDurability(item)
end


function TongTianTopTargetDlg:cleanup()
    local isLeader = Me:isTeamLeader()
    if isLeader then
        gf:CmdToServer("CMD_CLOSE_DIALOG", { para1 = "tongtianlingpai", para2 = "" })
    end
end

function TongTianTopTargetDlg:MSG_OPEN_TTLP_DLG(data)
    self:setData(data)
end



return TongTianTopTargetDlg
