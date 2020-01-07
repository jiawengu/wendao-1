-- YuanXiaoGuideDlg.lua
-- Created by huangzz Sep/09/2018
-- 相约元宵-约会表现安排界面

local YuanXiaoGuideDlg = Singleton("YuanXiaoGuideDlg", Dialog)

local BOOKS = {
    CHS[5400704],
    CHS[5400705],
    CHS[5400706],
}

local NPC = {
    [CHS[3000850]] = {name = CHS[5400712], des = CHS[5400711], icon = ResMgr.icon.zhanglaoban, offX = -8},   -- 大胡子
    [CHS[3000797]] = {name = CHS[5400713], des = CHS[5400710], icon = ResMgr.icon.lianhuaguniang}, -- 莲花姑娘
}

function YuanXiaoGuideDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)

    for i = 1, 3 do
        local panel = self:getControl("ItemPanel", nil, "BookPanel" .. i)
        panel:setTag(i)
        self:setCtrlVisible("SelectImage", false, panel)
        self:bindTouchEventListener(panel, self.onBookItem)

        local panel = self:getControl("ItemPanel", nil, "RoundPanel" .. i)
        panel:setTag(i)
        panel:setTouchEnabled(false)
        self:setCtrlVisible("SelectImage", false, panel)
        self:bindTouchEndEventListener(panel, self.onRoundItem)
    end

    self.roundItems = {}
    self.selectRound = nil
    self.npcName = nil

    self:initBooks()

    -- 在 onDlgOpened 中处理
    -- self:autoSelectRound()
end

function YuanXiaoGuideDlg:setNpcView(name)
    -- 形象
    self:creatCharDragonBones(NPC[name].icon, NPC[name].offX or 0)

    -- 名字
    self:setLabelText("NameLabel", NPC[name].name, "NPCPanel")

    -- 描述
    self:setLabelText("Label_228", NPC[name].des, "NPCPanel")

    self.npcName = name
end

function YuanXiaoGuideDlg:creatCharDragonBones(icon, offX)
    local panel = self:getControl("BodyPanel", nil, "NPCPanel")
    local dbMagic = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    if not dbMagic then return end

    local magic = tolua.cast(dbMagic, "cc.Node")   
    magic:setPosition(panel:getContentSize().width * 0.5 + 16 + offX, 10)
    magic:setName("charPortrait")
    magic:setTag(icon)
    magic:setRotationSkewY(isFilp and 180 or 0)
    magic:setScale(0.7)
    panel:addChild(magic)

    DragonBonesMgr:toPlay(dbMagic , "stand", 0)

    self.npcMagic = dbMagic
    return magic
end

-- 自动选中下一个未设置约会表现的步骤
function YuanXiaoGuideDlg:autoSelectRound()
    for i = 1, 3 do
        if not self.roundItems[i] then
            self:onRoundItem(self:getControl("ItemPanel", nil, "RoundPanel" .. i))
            return
        end
    end

    self:setCtrlVisible("RoundTipLabel", false)
    self.selectRound = nil
end

function YuanXiaoGuideDlg:initBooks()
    for i = 1, #BOOKS do
        local cell = self:getControl("BookPanel" .. i)
        local icon = ResMgr:getIconPathByName(BOOKS[i])
        self:setImage("ItemImage", icon, cell)
        self:setCtrlVisible("ItemImage", true, cell)
        local item = InventoryMgr:getItemByName(BOOKS[i])
        if item[1] then
            self:setCtrlColor("Label", InventoryMgr:getItemColor(item[1]), cell)
        end

        local itemPanel = self:getControl("ItemPanel", nil, cell)
        itemPanel.itemName = BOOKS[i]
    end
end

function YuanXiaoGuideDlg:onBookItem(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        self:setCtrlVisible("SelectImage", true, sender)
    elseif eventType == ccui.TouchEventType.ended then
        self:setCtrlVisible("SelectImage", false, sender)
        if not self.selectRound then
            gf:ShowSmallTips(CHS[5400708])
            return
        end

        self:setOneRound(sender.itemName, self.selectRound)

        self:autoSelectRound()
    elseif eventType == ccui.TouchEventType.canceled then
        self:setCtrlVisible("SelectImage", false, sender)
    end

    --[[for i = 1, 3 do
        local panel = self:getControl("ItemPanel", nil, "BookPanel" .. i)
        self:setCtrlVisible("SelectImage", false, panel)
    end

    self:setCtrlVisible("SelectImage", true, sender)]]
end

function YuanXiaoGuideDlg:onRoundItem(sender, eventType)
    local tag = sender:getTag()
    self.selectRound = tag

    self:setCtrlVisible("RoundTipLabel", true)
    self:setLabelText("RoundTipLabel", string.format(CHS[5400707], gf:getChineseNum(tag)))

    for i = 1, 3 do
        local panel = self:getControl("ItemPanel", nil, "RoundPanel" .. i)
        self:setCtrlVisible("SelectImage", false, panel)
    end

    self:setCtrlVisible("SelectImage", true, sender)
end

function YuanXiaoGuideDlg:setOneRound(itemName, index)
    self.roundItems[index] = itemName
    local roundPanel = self:getControl("ItemPanel", nil, "RoundPanel" .. index)
    local icon = ResMgr:getIconPathByName(itemName)
    self:setImage("ItemImage", icon, roundPanel)
    self:setCtrlVisible("ItemImage", true, roundPanel)
    self:setCtrlVisible("NoneImage", false, roundPanel)
    self:setCtrlVisible("SelectImage", false, roundPanel)

    roundPanel:setTouchEnabled(true)
end

function YuanXiaoGuideDlg:onDlgOpened(list)
    if list[1] then
        self:setNpcView(list[1])

        for i = 2, #list do
            self:setOneRound(BOOKS[tonumber(list[i])], i - 1)
        end

        self:autoSelectRound()
    end
end

function YuanXiaoGuideDlg:onConfirmButton(sender, eventType)
    if #self.roundItems < 3 then
        gf:ShowSmallTips(CHS[5400709])
        return
    end

    gf:CmdToServer("CMD_YUANXJ_2019_MAKE_TASK_ITEM", {para = table.concat(self.roundItems, "|")})
end

function YuanXiaoGuideDlg:clenaup()
    if self.npcName then
        local info = NPC[self.npcName]
        DragonBonesMgr:removeCharDragonBonesResoure(info.icon, string.format("%05d", info.icon))
    end
end

return YuanXiaoGuideDlg
