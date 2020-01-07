-- JewelryConfirmDlg.lua
-- Created by huangzz Aug/03/2018
-- 分解贵重首饰确认框

local JewelryConfirmDlg = Singleton("JewelryConfirmDlg", Dialog)

local LIMIT_POINT = 9999  -- 最多可携带精华数

local COST_CASH_ONE_POINT = 10000 -- 1精华点消耗 10000 金钱

function JewelryConfirmDlg:init(param)
    self:bindListener("ConfrimButton", self.onConfrimButton)

    self:setJewelryView(param)
end

function JewelryConfirmDlg:onConfrimButton(sender, eventType)
    if not self.jewelry then
        self:onCloseButton()
        return
    end

    -- 若该角色处于禁闭状态，给予弹出提示
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    local essence =  EquipmentMgr:getDecJewelryGetEssence(self.jewelry.req_level)
    local myEssence = Me:queryBasicInt("jewelry_essence")
    -- 若分解后角色身上的首饰精华点数＞limit_point点，给予弹出提示
    if essence + myEssence > LIMIT_POINT then
        gf:ShowSmallTips(CHS[5450176])
        return
    end

    local moneyStr = gf:getMoneyDesc(essence * COST_CASH_ONE_POINT)
    gf:confirm(string.format(CHS[5420318], moneyStr), function()
        DlgMgr:sendMsg("JewelryDecomposeDlg", "doBuyExJewelry", self.jewelry)
        self:onCloseButton()
    end)
end

-- 播放新属性动画
function JewelryConfirmDlg:doAction(data)
    if not data[1] then
        self.isDoAction = false
        return
    end

    local ctrl = table.remove(data, 1)
    local action = cc.Sequence:create(
        cc.FadeIn:create(0.5),
        cc.CallFunc:create(function() 
            self:doAction(data)
        end)
    )

    ctrl:runAction(action)
end

function JewelryConfirmDlg:setJewelryView(jewelry)
    if not jewelry then
        return
    end

    self.jewelry = jewelry

    local ctrls = {self:getControl("NoticeLabel")}
    local icon = InventoryMgr:getIconByName(jewelry["name"])
    local img = self:getControl("ItemImage", ResMgr:getItemIconPath(icon), "ItemShapePanel")
    img:loadTexture(ResMgr:getItemIconPath(icon))
    table.insert(ctrls, img)

    local label = self:getControl("ItemNameLabel")
    label:setString(jewelry["name"])
    table.insert(ctrls, label)

    local blueAtt = EquipmentMgr:getJewelryBule(jewelry)
    local panel = self:getControl("AttachAttibutePanel")
    for i = 1, 5 do
        local label = self:getControl("AttachAttribLabel" .. i, nil, panel)
        if blueAtt[i] then
            label:setString(blueAtt[i])
            table.insert(ctrls, label)
        else
            label:setString("")
        end
    end

    local size = panel:getContentSize()
    panel:setContentSize(size.width, 20 + #blueAtt * 28)

    table.insert(ctrls, self:getControl("ConfrimButton"))

    for i = 1, #ctrls do
        ctrls[i]:setOpacity(0)
    end

    -- 播放新属性动画
    self.isDoAction = true
    self:doAction(ctrls)
end

return JewelryConfirmDlg
