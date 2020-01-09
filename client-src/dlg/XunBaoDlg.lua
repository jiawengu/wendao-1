-- XunBaoDlg.lua
-- Created by huangzz Oct/10/2018
-- 新春寻宝界面

local XunBaoDlg = Singleton("XunBaoDlg", Dialog)

local TOOLS = {
    {name = CHS[5400771], ctrl = "ShovelPanel", icon = ResMgr.magic.xunbao_use_shovel},
    {name = CHS[5400772], ctrl = "BombPanel", icon = ResMgr.magic.xunbao_use_bomb},
    {name = CHS[5400773], ctrl = "TntPanel", icon = ResMgr.magic.xunbao_use_bomb},
}

-- 岩石类型
local ROCK_TYPE = {
    NORMAL  = 1, -- 普通岩石
    GOLD    = 2, -- 黄金岩石
    SPECIAL = 3, -- 特殊岩石
}

-- 工具类型
local TOOL_TYPE = {
    SHOVEL  = 1, -- 铲子
    BOMB    = 2, -- 小型炸弹
    BIG_BOMB = 3, -- 超级炸弹
}

local ROCK_BROKEN_MAGIC = {
    [ROCK_TYPE.NORMAL] = ResMgr.magic.xunbao_broken_nomal_rock,
    [ROCK_TYPE.GOLD] = ResMgr.magic.xunbao_broken_gold_rock
}

local COL = 6
local ROW = 6

function XunBaoDlg:init()
    self:bindListener("ItemImage", self.onItemImage, "ShovelPanel", true)
    self:bindListener("ItemImage", self.onItemImage, "BombPanel", true)
    self:bindListener("ItemImage", self.onItemImage, "TntPanel", true)

    self:bindListener("ItemImage", self.onRockItemImage, "RockPanel")

    self:bindListener("HuoyLabel", self.onHuoyLabel, "SourcePanel")
    self:bindListener("TieclLabel", self.onTieclLabel, "SourcePanel")
    self:bindListener("YuanbLabel", self.onYuanbLabel, "SourcePanel")

    self:bindListener("BoxButton", self.onBoxButton, "BoxPanel")

    self:bindListener("RuleImage", self.onRuleImage, "MainPanel")

    self.rockPanel = self:retainCtrl("RockPanel")
    self.rockSize = self.rockPanel:getContentSize()

    local winSize = cc.Director:getInstance():getWinSize()

    -- 加载背景图
    local dlgBack = ccui.ImageView:create(ResMgr.loadingPic["createchar"])
    dlgBack:setPosition(winSize.width / Const.UI_SCALE / 2, winSize.height / Const.UI_SCALE / 2)
    dlgBack:setAnchorPoint(0.5, 0.5)
    self.blank:addChild(dlgBack)
    local order = self.root:getOrderOfArrival()
    self.root:setOrderOfArrival(dlgBack:getOrderOfArrival())
    dlgBack:setOrderOfArrival(order)
    dlgBack:setTouchEnabled(true)

    self:setItemsInfo()

    -- 创建用于拖动的道具图片
    self:creatDragItem()

    self.hasShowGuide = InventoryMgr:getLimitItemFlag(self.name, 0)

    self.data = nil
    self.isPlayAction = false
    self.dataSeq = {}
    self.rockPanels = {}
    self.clickRockInfo = nil

    -- 划线
    self:getControl("HuoyLabel", self.onHuoyLabel, "SourcePanel"):addChild(gf:drawLine(0.5, cc.c4f(21 / 255, 171 / 255, 1 / 255, 1), cc.p(0, 2), cc.p(103, 2)))
    self:getControl("TieclLabel", self.onHuoyLabel, "SourcePanel"):addChild(gf:drawLine(0.5, cc.c4f(21 / 255, 171 / 255, 1 / 255, 1), cc.p(0, 2), cc.p(103, 2)))
    self:getControl("YuanbLabel", self.onHuoyLabel, "SourcePanel"):addChild(gf:drawLine(0.5, cc.c4f(21 / 255, 171 / 255, 1 / 255, 1), cc.p(0, 2), cc.p(85, 2)))

    self:hookMsg("MSG_SPRING_2019_XCXB_DATA")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_SPRING_2019_XCXB_BONUS_DATA")
    self:hookMsg("MSG_SPRING_2019_XCXB_BUY_DATA")
    self:hookMsg("MSG_SPRING_2019_XCXB_USET_TOOL_FAIL")
    self:hookMsg("MSG_SPRING_2019_XCXB_GET_BONUS")
end

function XunBaoDlg:doGuideMagic()
    gf:frozenScreen(5000)
    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.xunbao_guide.name, "Top", self.root, function()
        local cell = self.rockPanels[8]
        if cell then
            self:playMagic(cell, TOOLS[TOOL_TYPE.SHOVEL].icon, function()
                gf:unfrozenScreen()
            end)
        else
            gf:unfrozenScreen()
        end
    end, self, nil, 490, 310, 10)
end

function XunBaoDlg:doItemGuideMagic(cell)
    local playCou = 3
    local size = cell:getContentSize()
    local pos = cell:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))

    local magic
    magic = gf:createCallbackMagic(ResMgr.magic.guide_magic, function()
        playCou = playCou - 1
        if playCou == 0 then
            magic:removeFromParent()
            GuideMgr:closeTipInfo()
        else
            magic:updateNow()
        end
    end)

    local magicPos = self.root:convertToNodeSpace(pos)
    magic:setAnchorPoint(0.45, 0.55)
    magic:setPosition(magicPos.x, magicPos.y)
    self.root:addChild(magic)

    GuideMgr:showTipInfo(CHS[5410320], cc.rect(pos.x - size.width + 20, pos.y - size.height + 20, size.width, size.height), {posType = "rightUp"})
end

function XunBaoDlg:setItemsInfo()
    for i = 1, 3 do
        local panel = self:getControl(TOOLS[i].ctrl)

        local iconPath = ResMgr:getIconPathByName(TOOLS[i].name)
        self:setImage("ItemImage", iconPath, panel)

        local amount = InventoryMgr:getAmountByName(TOOLS[i].name, true)

        self:setNumImgForPanel("NumLabel", ART_FONT_COLOR.MALL_NUM2, amount, false, LOCATE_POSITION.MID, 20, panel)
        panel.itemInfo = {amount = amount, iconPath = iconPath, type = i}
    end
end

-- 创建拖动的道具
function XunBaoDlg:creatDragItem(sender, eventType)
    local image = ccui.ImageView:create()
    image:setPosition(0, 0)
    image:setVisible(false)
    image:setLocalZOrder(30)
    image:setScale(0.8)
    self.root:addChild(image)

    self.dragItem = image
end

-- 更新拖动道具的位置
function XunBaoDlg:setDragItemPos()
    local pos = GameMgr.curTouchPos
    if pos then
        local pos = self.root:convertToNodeSpace(pos)
        self.dragItem:setPosition(pos.x, pos.y)
    end
end

function XunBaoDlg:setSelectImageIcon(row, col, toolType)
    if not self:isInRange(col, row) then
        return
    end

    local tag = row * COL + col
    local icon = ResMgr.ui.select_green_rect
    if self.rockPanels[tag] and self.rockPanels[tag].info then
        local info = self.rockPanels[tag].info
        if info.stone_visible == 1 and info.stone_type == ROCK_TYPE.SPECIAL then
            icon = ResMgr.ui.select_red_rect
        end

        self:setImage("GreenImage", icon, self.rockPanels[tag])
        self:setCtrlVisible("GreenImage", true, self.rockPanels[tag])
    end

    return tips
end

function XunBaoDlg:isInRange(x, y)
    if y < 1 or y > ROW or x < 1 or x > COL then
        return false
    end

    return true
end

-- 设置选择的岩层
function XunBaoDlg:setSelcetRockPanel(toolType, needTip)
    local x, y = self.dragItem:getPosition()
    local mPanel = self:getControl("MovePanel")
    local pos = self.root:convertToWorldSpace(cc.p(x, y))
    pos = mPanel:convertToNodeSpace(pos)

    local row = - math.floor(pos.y / self.rockSize.height) + 1
    local col = math.floor(pos.x / self.rockSize.width) + 1

    self:initAllSelectImageVisible()

    if not self:isInRange(col, row) then
        return
    end

    local tag = row * COL + col
    if not self.rockPanels[tag] then return end

    local info = self.rockPanels[tag].info
    if needTip then
        -- 将破碎材料拖动到可破碎区域时，若背包已满，则出现不可选提示
        if InventoryMgr:getEmptyPosCount() == 0 then
            gf:ShowSmallTips(CHS[5400775])
            return
        end

        -- 将破碎材料拖动至特殊岩石上时，出现不可选提示
        if info.stone_type == ROCK_TYPE.SPECIAL then
            gf:ShowSmallTips(CHS[5400776])
            return
        end

        -- 将破碎材料拖动至隐藏岩石上时，出现不可选提示
        if info.stone_visible == 0 then
            gf:ShowSmallTips(CHS[5400777])
            return
        end

        -- 将镐子拖动至#已开采区域时，出现不可选提示
        if toolType == TOOL_TYPE.SHOVEL and info.stone_dura == 0 then
            gf:ShowSmallTips(CHS[5400778])
            return
        end

        -- 将小型炸弹和超级炸弹拖动至岩石层时，出现不可选提示
        if toolType ~= TOOL_TYPE.SHOVEL and info.stone_dura ~= 0 then
            gf:ShowSmallTips(CHS[5400779])
            return
        end

        -- 将小型炸弹和超级炸弹拖动至#已开采区域时，若对应可开采区域无任何岩石，则出现不可选提示
        if toolType ~= 1 then
            local function check1()
                -- 检测一行内是否有可开采的岩石
                local i = row
                for j = 1, 6 do
                    local tag = i * COL + j
                    if i > 0 and i <= ROW and j > 0 and j <= COL and self.rockPanels[tag] then
                        local info = self.rockPanels[tag].info
                        if info and info.stone_dura > 0 and info.stone_type ~= ROCK_TYPE.SPECIAL then
                            return true
                        end
                    end
                end
            end

            if toolType == TOOL_TYPE.BOMB and not check1() then
                gf:ShowSmallTips(CHS[5400789])
                return
            end

            local function check2()
                -- 检测九宫格范围内是否有可开采的岩石
                for i = row - 1, row + 1 do
                    for j = col - 1, col + 1 do
                        local tag = i * COL + j
                        if i > 0 and i <= ROW and j > 0 and j <= COL and self.rockPanels[tag] then
                            local info = self.rockPanels[tag].info
                            if info and info.stone_dura > 0 and info.stone_type ~= ROCK_TYPE.SPECIAL then
                                return true
                            end
                        end 
                    end
                end
            end

            if toolType == TOOL_TYPE.BIG_BOMB and not check2() then
                gf:ShowSmallTips(CHS[5400789])
                return
            end
        end

        return col, row
    end

    -- 设置对应工具一次性可开采的范围
    if toolType == TOOL_TYPE.SHOVEL and info.stone_dura == 0 then
            self:setCtrlVisible("GreenImage", false, self.rockPanels[tag])
    elseif (toolType ~= TOOL_TYPE.SHOVEL and info.stone_dura ~= 0)
            or (toolType == TOOL_TYPE.SHOVEL and info.stone_visible == 0) then
        self:setImage("GreenImage", ResMgr.ui.select_red_rect, self.rockPanels[tag])
        self:setCtrlVisible("GreenImage", true, self.rockPanels[tag])
    else
        local hasRock = false
        if toolType == TOOL_TYPE.SHOVEL then
            -- 选一个
            self:setSelectImageIcon(row, col, toolType)
        elseif toolType == TOOL_TYPE.BOMB then
            -- 选一行
            for j = 1, 6 do
                self:setSelectImageIcon(row, j, toolType)
            end
        else
            -- 选九宫格
            for i = row - 1, row + 1 do
                for j = col - 1, col + 1 do
                    self:setSelectImageIcon(i, j, toolType)
                end
            end
        end
    end

    return col, row
end

function XunBaoDlg:initAllSelectImageVisible()
    for i = 1, #self.rockPanels do
        self:setCtrlVisible("GreenImage", false, self.rockPanels[i])
    end
end

function XunBaoDlg:onItemImage(sender, eventType)
    if not self.data then
        return
    end

    local lastTouchPos
    local info = sender:getParent().itemInfo
    if eventType == ccui.TouchEventType.began then
        if info.amount == 0 then
            self.isMoveItem = false
            sender:setScale(0.9)
        else
            self.isMoveItem = true
            self.dragItem:setVisible(true)
            sender:setVisible(false)
            self.dragItem:loadTexture(info.iconPath)

            self.dragItem.iconPath = info.iconPath

            self:setDragItemPos()
        end
    elseif eventType == ccui.TouchEventType.moved then
        if not self.isMoveItem then
            return
        end

        self:setDragItemPos()

        if self.isPlayAction then
            return
        end

        self:setSelcetRockPanel(info.type)
    else
        self.dragItem:setVisible(false)
        sender:setVisible(true)
        self:initAllSelectImageVisible()
        if not self.isMoveItem then
            sender:setScale(0.8)
            if eventType == ccui.TouchEventType.ended then
                gf:CmdToServer("CMD_SPRING_2019_XCXB_BUY_DATA", {})
                self.selectToolType = info.type
            end
        else
            if self.isPlayAction then
                return
            end

            local x, y = self:setSelcetRockPanel(info.type, true)
            if x and y then
                self:cmdUseTool(x, y, info.type)
            end
        end
    end
end

function XunBaoDlg:cmdUseTool(x, y, type)
    self.isPlayAction = true
    gf:CmdToServer("CMD_SPRING_2019_XCXB_USE_TOOL", {x = x, y = y, tool_type = type})
    self.clickRockInfo = {x = x, y = y, toolType = type}
end

function XunBaoDlg:onRockItemImage(sender, eventType)
    local cell = sender:getParent()
    local tag = cell:getTag()
    local col = tag % COL
    local row = math.floor((tag - 1) / COL)

    if col == 0 then col = COL end

    gf:CmdToServer("CMD_SPRING_2019_XCXB_GET_BONUS", {x = col, y = row, layer_count = self.data.layer_count})
end

function XunBaoDlg:onBoxButton(sender, eventType)
    gf:CmdToServer("CMD_SPRING_2019_XCXB_BONUS_DATA", {})
end

function XunBaoDlg:onRuleImage(sender, eventType)
    DlgMgr:openDlg("XunBaoTipsDlg")
end

function XunBaoDlg:onHuoyLabel(sender, eventType)
    DlgMgr:openDlg('ActivitiesDlg')
end

function XunBaoDlg:onTieclLabel(sender, eventType)
    DlgMgr:openDlgWithParam({"ActivitiesDlg", CHS[5420152]})
end

function XunBaoDlg:onYuanbLabel(sender, eventType)
    gf:CmdToServer("CMD_SPRING_2019_XCXB_BUY_DATA", {})
    self.selectToolType = TOOL_TYPE.SHOVEL
end

function XunBaoDlg:getRockPanel(tag)
    if self.rockPanels[tag] then
        return self.rockPanels[tag]
    else
        local cell = self.rockPanel:clone()
        cell:retain()
        cell:setTag(tag)
        self.rockPanels[tag] = cell
        return cell
    end
end

function XunBaoDlg:setOneRockInfo(cell, info)
    cell.info = info
    local hasItem = info.bonus_name and info.bonus_name ~= "" and info.isGot == 0
    if info.stone_dura == 0 then
        -- 已开采
        self:setCtrlVisible("RockImage", false, cell)
        self:setCtrlVisible("ShadowImage", false, cell)
    elseif info.stone_visible == 0 then
        -- 不可见
        self:setCtrlVisible("ItemImage", false, cell)
        self:setCtrlVisible("ShadowImage", false, cell)
        self:setCtrlVisible("RockImage", true, cell)
        self:setImage("RockImage", ResMgr.ui.xunbao_rock_hide, cell)
        return
    else
        self:setCtrlVisible("ShadowImage", true, cell)
        self:setCtrlVisible("RockImage", true, cell)
        if info.stone_type == ROCK_TYPE.NORMAL then
            -- 普通岩石
            if hasItem then
                self:setImage("RockImage", ResMgr.ui.xunbao_rock_nomal_has_item, cell)
                self:setImage("ShadowImage", ResMgr.ui.xunbao_rock_shadow_nomal, cell)
            else
                self:setImage("RockImage", ResMgr.ui.xunbao_rock_nomal, cell)
            end
        elseif info.stone_type == ROCK_TYPE.GOLD then
            -- 黄金岩石
            if hasItem then
                if info.stone_dura == 1 then
                    self:setImage("RockImage", ResMgr.ui.xunbao_rock_gold1_has_item, cell)
                else
                    self:setImage("RockImage", ResMgr.ui.xunbao_rock_gold2_has_item, cell)
                end

                self:setImage("ShadowImage", ResMgr.ui.xunbao_rock_shadow_gold, cell)
            else
                if info.stone_dura == 1 then
                    self:setImage("RockImage", ResMgr.ui.xunbao_rock_gold1, cell)
                else
                    self:setImage("RockImage", ResMgr.ui.xunbao_rock_gold2, cell)
                end
            end
        else
            -- 特殊岩石
            self:setImage("RockImage", ResMgr.ui.xunbao_rock_special, cell)
        end
    end

    -- 奖励
    if hasItem then
        self:setCtrlVisible("ItemImage", true, cell)
        local img = self:getControl("ItemImage", nil, cell)
        if string.match(info.bonus_name, CHS[6000583]) then
            -- 道行
            img:loadTexture(ResMgr.ui.daohang, ccui.TextureResType.plistType)
        else
            img:loadTexture(ResMgr:getIconPathByName(info.bonus_name))
        end
    else
        self:setCtrlVisible("ItemImage", false, cell)
    end
end

function XunBaoDlg:setAllRockStatus(data)
    local mPanel = self:getControl("MovePanel", nil, "CommodityPanel")
    mPanel:removeAllChildren()
    mPanel:stopAllActions()
    mPanel:setPosition(0, 418)
    local size = self.rockSize
    local hasOper = false
    local firstItemCell
    for i = 1, data.layer_size do
        for j = 1, data[i].stone_size do
            local rockInfo = data[i][j]
            local y = -(i - 1) * size.width
            local x = (j - 1) * size.width

            local tag = i *  data.layer_size + j
            local cell = self:getRockPanel(tag)
            cell:setPosition(x, y)

            self:setOneRockInfo(cell, rockInfo)
            mPanel:addChild(cell)

            if self.hasShowGuide == 0 then
                if rockInfo.stone_dura == 0
                    or (type == ROCK_TYPE.GOLD and dura < 2)
                    or (type == ROCK_TYPE.NORMAL and dura < 1) then
                    hasOper = true
                end
            end

            if self.data and self.data.has_play_item_guide == 0
                    and data.has_play_item_guide == 1
                    and not firstItemCell
                    and rockInfo.isGot == 0
                    and rockInfo.stone_dura == 0
                    and rockInfo.bonus_name ~= "" then
                firstItemCell = cell
            end
        end
    end

    if firstItemCell then
        self:doItemGuideMagic(firstItemCell)
    end

    if self.hasShowGuide == 0 and not hasOper then
        -- 播放指引
        self:doGuideMagic()
        self.hasShowGuide = 1
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    end

    self.isPlayAction = false
    self.data = data

    table.remove(self.dataSeq, 1)
    self:doAction()
end

function XunBaoDlg:doMoveUpAction(data)
    local mPanel = self:getControl("MovePanel", nil, "CommodityPanel")

    -- 从岩层第二行开始刷新数据到 n + 1 行
    local size = self.rockSize
    for i = 1, data.layer_size do
        for j = 1, data[i].stone_size do
            local rockInfo = data[i][j]
            local tag = (i + 1) *  data.layer_size + j
            if rockInfo and self.rockPanels[tag] and self.rockPanels[tag]:getParent() then
                self:setOneRockInfo(self.rockPanels[tag], rockInfo)
            elseif rockInfo then
                local y = - i * size.width
                local x = (j - 1) * size.width
                local cell = self:getRockPanel(tag)
                cell:setPosition(x, y)

                self:setOneRockInfo(cell, rockInfo)
                mPanel:addChild(cell)
            end
        end
    end

    -- 震动上移
    local x, y = mPanel:getPosition()
    local moveLen = 2
    local action1 = cc.Repeat:create(cc.Sequence:create(
        cc.MoveBy:create(0.03, cc.p(moveLen, 0)),
        cc.MoveBy:create(0.03, cc.p(-moveLen * 2, 0)),
        cc.MoveBy:create(0.03, cc.p(moveLen, 0))
    ), 100)

    local action2 = cc.Sequence:create(
        cc.MoveBy:create(1, cc.p(0, self.rockSize.height)),
        cc.CallFunc:create(function()
            mPanel:stopAllActions()
            self:setAllRockStatus(data)
        end)
    )

    mPanel:runAction(action1)
    mPanel:runAction(action2)
end

function XunBaoDlg:playMagic(cell, icon, cb)
    local size = self.rockSize
    local magic = gf:createCallbackMagic(icon, function(node)
        node:removeFromParent(true)
        if cb then cb() end
    end)

    local x, y = cell:getPosition()
    local pos = cell:getParent():convertToWorldSpace(cc.p(x, y))
    pos = self.root:convertToNodeSpace(pos)
    magic:setPosition(pos.x + size.width / 2, pos.y + size.height / 2)
    magic:setLocalZOrder(20)
    self.root:addChild(magic)
end

function XunBaoDlg:playOneAction(cell, info, chooseInfo, cb)
    local size = self.rockSize

    local needMagic = false  -- 是否需要播放第二个光效
    local needChangeGoldImage = false -- 是否需要替换黄金岩石的图片
    if info and info.stone_type ~= ROCK_TYPE.SPECIAL and info.stone_dura > 0 then-- and info.stone_visible == 1 and info.stone_dura > 0 then
        if chooseInfo.toolType == TOOL_TYPE.SHOVEL or chooseInfo.toolType == TOOL_TYPE.BOMB then
            if info.stone_dura == 1 then
                needMagic = true
            elseif info.stone_dura == 2 and info.stone_type == ROCK_TYPE.GOLD then
                needChangeGoldImage = true
            end
        else
            needMagic = true
        end
    end

    if needMagic then
        self:playMagic(cell, TOOLS[chooseInfo.toolType].icon)
        if chooseInfo.toolType == TOOL_TYPE.SHOVEL then
            performWithDelay(cell, function()
                self:setCtrlVisible("RockImage", false, cell)
                self:setCtrlVisible("ShadowImage", false, cell)
                self:playMagic(cell, ROCK_BROKEN_MAGIC[info.stone_type], cb)
            end, 0.452)
        else
            self:setCtrlVisible("RockImage", false, cell)
            self:setCtrlVisible("ShadowImage", false, cell)
            self:playMagic(cell, ROCK_BROKEN_MAGIC[info.stone_type], cb)
        end
    else
        if needChangeGoldImage then
            local hasItem = info.bonus_name and info.bonus_name ~= "" and info.isGot == 0
            if chooseInfo.toolType == TOOL_TYPE.SHOVEL then
                performWithDelay(cell, function()
                    self:setImage("RockImage", ResMgr.ui.xunbao_rock_gold1 .. (hasItem and "_has_item" or ""), cell)
                end, 0.452)
            else
                self:setImage("RockImage", ResMgr.ui.xunbao_rock_gold1 .. (hasItem and "_has_item" or ""), cell)
            end
        end

        self:playMagic(cell, TOOLS[chooseInfo.toolType].icon, cb)
    end
end

-- 播放敲碎石头动画
function XunBaoDlg:playAction(chooseInfo, cb)
    local needCallBack = true
    if chooseInfo.toolType == TOOL_TYPE.SHOVEL then
        -- 炸单个
        local tag = chooseInfo.y * COL + chooseInfo.x
        if self.rockPanels[tag] then
            local info = self.rockPanels[tag].info
            if info then
                self:playOneAction(self.rockPanels[tag], info, chooseInfo, needCallBack and cb or nil)
                needCallBack = false
            end
        end
    elseif chooseInfo.toolType == TOOL_TYPE.BOMB then
        -- 炸一行
        local i = chooseInfo.y
        for j = 1, 6 do
            local tag = i * COL + j
            if i > 0 and i <= ROW and j > 0 and j <= COL and self.rockPanels[tag] then
                local info = self.rockPanels[tag].info
                if info then
                    self:playOneAction(self.rockPanels[tag], info, chooseInfo, needCallBack and cb or nil)
                    needCallBack = false
                end
            end
        end
    elseif chooseInfo.toolType == TOOL_TYPE.BIG_BOMB then
        -- 炸一个九宫格
        for i = chooseInfo.y - 1, chooseInfo.y + 1 do
            for j = chooseInfo.x - 1, chooseInfo.x + 1 do
                local tag = i * COL + j
                if i > 0 and i <= ROW and j > 0 and j <= COL and self.rockPanels[tag] then
                    local info = self.rockPanels[tag].info
                    if info then
                        self:playOneAction(self.rockPanels[tag], info, chooseInfo, needCallBack and cb or nil)
                        needCallBack = false
                    end
                end 
            end
        end
    end

    if needCallBack then
        cb()
    end
end

function XunBaoDlg:needUseTool(newData, oldData)
    if not oldData then return end
    local count = newData.layer_count - oldData.layer_count
    for i = 1, newData.layer_size do
        for j = 1, newData[i].stone_size do
            if newData[i - count] and newData[i - count][j].stone_dura < oldData[i][j].stone_dura then
                return true
            end
        end
    end
end

function XunBaoDlg:doAction()
    if #self.dataSeq <= 0 then
        return
    end

    self.isPlayAction = true
    local data = self.dataSeq[1]

    local function func()
        if data.layer_count >= 6 and self.data and self.data.layer_count ~= data.layer_count then
            -- 向上移动一层
            self:doMoveUpAction(data)
        else
            -- 重置岩石层状态
            self:setAllRockStatus(data)
        end

        self:setLabelText("NumLabel", data.layer_count, "CommodityPanel")
    end

    if self.data and self:needUseTool(data, self.data) and self.clickRockInfo then
        self:playAction(self.clickRockInfo, func)
        self.clickRockInfo = nil
    else
        func()
    end

    self:setLabelText("NumLabel", data.today_bonus_num .. "/20", "MainPanel")
end

function XunBaoDlg:MSG_SPRING_2019_XCXB_DATA(data, kk)
    table.insert(self.dataSeq, data)

    if #self.dataSeq == 1 then
        self:doAction()
    end
end

function XunBaoDlg:MSG_INVENTORY(data)
    self:setItemsInfo()
end

function XunBaoDlg:MSG_SPRING_2019_XCXB_USET_TOOL_FAIL(data)
    self.isPlayAction = false
    self.clickRockInfo = nil
end

function XunBaoDlg:MSG_SPRING_2019_XCXB_GET_BONUS(data)
    local row = data.y
    local col = data.x
    local tag = row * COL + col

    if self.rockPanels[tag] and self.rockPanels[tag].info.bonus_name ~= "" then
        local itemImg = self:getControl("ItemImage", nil, self.rockPanels[tag])
        local cell = itemImg:clone()
        local pos = itemImg:getParent():convertToWorldSpace(cc.p(itemImg:getPosition()))
        pos = self.root:convertToNodeSpace(pos)
        cell:setPosition(pos.x, pos.y)
        cell:setLocalZOrder(100)
        self.root:addChild(cell)

        local boxButton = self:getControl("BoxButton", nil, "BoxPanel")
        local destPos = boxButton:getParent():convertToWorldSpace(cc.p(boxButton:getPosition()))
        destPos = self.root:convertToNodeSpace(destPos)
        local time = gf:distance(destPos.x, destPos.y, pos.x, pos.y) / 500
        local action = cc.Sequence:create(
            cc.MoveTo:create(time, destPos),
            cc.RemoveSelf:create()
        )

        cell:runAction(action)

        itemImg:setVisible(false)
    end
end

function XunBaoDlg:MSG_SPRING_2019_XCXB_BONUS_DATA(data)
    local dlg = DlgMgr:openDlg("XunBaoBagDlg")
    dlg:setData(data)
end

function XunBaoDlg:MSG_SPRING_2019_XCXB_BUY_DATA(data)
    local dlg = DlgMgr:openDlg("XunBaoBuyDlg")
    dlg:setData(data, self.selectToolType)
end

function XunBaoDlg:cleanup()
    if self.rockPanels then
        for _, v in pairs(self.rockPanels) do
            v:release()
        end
    end

    self.rockPanels = nil
    self.selectToolType = nil

    DlgMgr:closeDlg("XunBaoBagDlg")
    DlgMgr:closeDlg("XunBaoBuyDlg")

    gf:CmdToServer("CMD_SPRING_2019_XCXB_FINISH", {})
end


return XunBaoDlg
