-- TongTianDlg.lua
-- Created by songcw Nov/14/2018
-- 通天令牌使用界面

local TongTianDlg = Singleton("TongTianDlg", Dialog)


local XingJunList = {
    -- 玉衡星君         天权星君        天玑星君            天璇星君        天枢星君        摇光星君              开阳星君
    CHS[3000992],   CHS[3000991],      CHS[3000990],    CHS[3000989],   CHS[3000988],   CHS[3000994],    CHS[3000993]
}

function TongTianDlg:init(data)
    self:bindListener("UseButton", self.onUseButton)
    self:bindListener("ItemPanel", self.onShowItem)

    self:bindListViewListener("ArtifactView", self.onSelectArtifactView)

    self.namePanel1 = self:retainCtrl("NamePanel_1")
    self.namePanel2 = self:retainCtrl("NamePanel_2")

    self:bindCheckBoxListener("ChoiceCheckBox", self.onSelectXingJun, self.namePanel1)
    self:bindCheckBoxListener("ChoiceCheckBox", self.onSelectXingJun, self.namePanel2)

    self:bindListener("FullPanel", self.onFullPanel, self.namePanel1)
    self:bindListener("FullPanel", self.onFullPanel, self.namePanel2)

    if not self.selectXingJun then self.selectXingJun = {} end
    if self.MeGid ~= Me:queryBasic("gid") then
        self.selectXingJun = {}
        self.MeGid = Me:queryBasic("gid")
    end

    self:setXingJunList()

    self:refreshSelectXingJun()

    self:hookMsg("MSG_TTT_NEW_XING")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_ENTER_ROOM")
 --   self:hookMsg("MSG_UPDATE_TEAM_LIST")

     EventDispatcher:addEventListener("EVENT_JOIN_TEAM", self.onJoinTeam, self)

    self:MSG_TTT_NEW_XING(data)
end

function TongTianDlg:cleanup()
    EventDispatcher:removeEventListener("EVENT_JOIN_TEAM", self.onJoinTeam, self)
end

function TongTianDlg:onJoinTeam()
    self:onCloseButton()
end

function TongTianDlg:setItemInfo()
    local panel = self:getControl("ArtifactInfoPanel")

    local itemPanel = self:getControl("ItemPanel", nil, panel)
    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[7000081])), itemPanel)
    self:setCtrlVisible("NumLabel", false, itemPanel)

    local durability = self:getAllDurability()

    self:setLabelText("NumLabel", string.format("%d", durability), panel)
end

function TongTianDlg:getAllDurability()
    local items = InventoryMgr:getAllInventory()
    local durability = 0
    for _, v in pairs(items) do
        if v.name == CHS[7000081] or v.name == CHS[4200614] then
            durability = durability + v.durability
        end
    end

    return durability
end

function TongTianDlg:onFullPanel(sender, eventType)
    gf:ShowSmallTips(CHS[4200611])
end

function TongTianDlg:isSelectXingjun(xingjun)
    for i = 1, #self.selectXingJun do
        if xingjun == self.selectXingJun[i] then return true end
    end

    return false
end

function TongTianDlg:onSelectXingJun(sender, eventType)
    local name = self:getLabelText("NameLabel", sender:getParent())
    local list = self:getControl("ArtifactView")
    if sender:getSelectedState() then
        if #self.selectXingJun >= 2 then
            sender:setSelectedState(false)
            gf:ShowSmallTips(CHS[4200611])
        else
            table.insert( self.selectXingJun,  name)

            if #self.selectXingJun >= 2 then

                local items = list:getItems()
                for i = 1, #items do
                    local uName = self:getLabelText("NameLabel", items[i])
                    if not self:isSelectXingjun(uName) then
                        self:setCtrlOnlyEnabled("ChoiceCheckBox", false, items[i])
                    end
                end
            end
        end
    else
        local idx = 0
        for i = 1, 2 do
            if self.selectXingJun[i] == name then
                idx = i
            end
        end

        if idx ~= 0 then
            table.remove( self.selectXingJun, idx )

            local items = list:getItems()
            for i = 1, #items do
                local uName = self:getLabelText("NameLabel", items[i])
                if not self:isSelectXingjun(uName) then
                    self:setCtrlOnlyEnabled("ChoiceCheckBox", true, items[i])
                end
            end
        end


    end

    self:checkSelectXingj()

    self:refreshSelectXingJun()
end

function TongTianDlg:setXingJunList()
    local list = self:resetListView("ArtifactView")

    for i = 1, #XingJunList do
        local panel
        if i % 2 == 1 then
            panel = self.namePanel1:clone()
        else
            panel = self.namePanel2:clone()
        end

        self:setUnitXingJunPanel(XingJunList[i], panel)
        list:pushBackCustomItem(panel)
    end

    if #self.selectXingJun >= 2 then

        local items = list:getItems()
        for i = 1, #items do
            local uName = self:getLabelText("NameLabel", items[i])
            if not self:isSelectXingjun(uName) then
                self:setCtrlOnlyEnabled("ChoiceCheckBox", false, items[i])
            end
        end
    end
end

function TongTianDlg:setUnitXingJunPanel(name, panel)
    self:setLabelText("NameLabel", name, panel)

    if self:isSelectXingjun(name) then
        self:setCheck("ChoiceCheckBox", true, panel)
    end
end

function TongTianDlg:refreshSelectXingJun()
    local panel = self:getControl("QiwPanel")
    for i = 1, 2 do
        local name = self.selectXingJun[i] or ""
        self:setLabelText("NameLabel_" .. i, name, panel)
    end
end

function TongTianDlg:onUseButton(sender, eventType)
    if sender.isGray then
        gf:ShowSmallTips(CHS[4200612])    -- 当前已刷新到选中的星君，无法继续使用，修改当前刷新的星君后可继续使用！
        return
    end


    local items = InventoryMgr:getItemByName(CHS[7000081])
    local itemsRH = InventoryMgr:getItemByName(CHS[4200614])  -- 通天令牌·融合

    if #items == 0 and #itemsRH == 0 then
        -- 能打开界面，基本不可能，如果消息延迟可能，容错下
        self:onCloseButton()
        return
    end

    if self.isLock then
        -- 这个锁的功能时为了防止玩家快速点击
        return
    end

    local item
    local pos
    local durability

    if #itemsRH > 0 then
        -- 默认取第一个当成最耐久度最低的
        item = itemsRH[1]
        pos = itemsRH[1].pos
        durability = itemsRH[1].durability
    else
        item = items[1]
        pos = items[1].pos
        durability = items[1].durability
    end

    for i = 1, #itemsRH do
        if itemsRH[i].durability < durability then
            item = itemsRH[i]
            pos = itemsRH[i].pos
            durability = itemsRH[i].durability
        elseif itemsRH[i].durability == durability then
            if itemsRH[i].pos < pos then
                item = itemsRH[i]
                pos = itemsRH[i].pos
                durability = itemsRH[i].durability
            end
        end
    end

    for i = 1, #items do
        if items[i].durability < durability then
            --选择耐久度最低的那个
            item = items[i]
            pos = items[i].pos
            durability = items[i].durability
        elseif items[i].durability == durability then
            --耐久度相同选靠前的
            if items[i].pos < pos then
                item = items[i]
                pos = items[i].pos
                durability = items[i].durability
            end
        end
    end

    self.isLock = true
    gf:CmdToServer("CMD_USE_TONGTIAN_LINGPAI", {pos = item.pos})
end


function TongTianDlg:MSG_TTT_NEW_XING(data)
    if not self:isVisible() then return end

    self.isLock = false
    self.data = data

    self:setLabelText("NameLabel", data.xing_name, "DanqPanel")

    self:checkSelectXingj()

    self:setItemInfo()

    if data.result == 1 and self:getAllDurability() == 0 then
        gf:showTipAndMisMsg(CHS[4200615])
        self:setVisible(false)
        performWithDelay(gf:getUILayer(), function ( )
            self:onCloseButton()
        end)
    end
end

function TongTianDlg:checkSelectXingj()
    local isRandomSelect = false
    for i = 1, #self.selectXingJun do
        if self.data.xing_name == self.selectXingJun[i] then
            isRandomSelect = true
        end
    end


    self:setCtrlEnabled("UseButton", not isRandomSelect, nil, true)
end


function TongTianDlg:MSG_ENTER_ROOM(data)
    self:onCloseButton()
end

function TongTianDlg:MSG_INVENTORY(data)
    self:setItemInfo()
end

function TongTianDlg:onShowItem(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[7000081], rect)
end


function TongTianDlg:onSelectArtifactView(sender, eventType)
end

return TongTianDlg
