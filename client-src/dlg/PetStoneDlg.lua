-- PetStoneDlg.lua
-- Created by chenyq Jan/18/2015
-- 宠物妖石

local RadioGroup = require('ctrl/RadioGroup')
local PetStoneDlg = Singleton("PetStoneDlg", Dialog)

-- 妖石属性名称列表
local STONE_ATTRIB_LIST = {
    [CHS[3000093]] = 1,    -- 凝香幻彩
    [CHS[3000095]] = 2,    -- 炫影霜星
    [CHS[3000096]] = 3,    -- 风寂云清
    [CHS[3000097]] = 4,    -- 枯月流魂
    [CHS[3000098]] = 5,    -- 雷极弧光
    [CHS[3004454]] = 6,    -- 冰落残阳
}

local STONE_INDEX_LIST = {
    ALL_STONE         = 0,
    NINGXIANG_HUANCAI = 1,
    XUANYING_SHUANGXING = 2,
    FENGJI_YUNQING = 3,
    KUYUE_LIUHUN   = 4,
    LEIJI_HUGUANG = 5,
    BINGLUO_CANYANG = 6,
}

-- 妖石列表间隔
local MARGIN = 11

-- 策划要求列表最低显示15格
local ITEM_SHOW_COUNT = 15

function PetStoneDlg:init()

    local screenPanel3 = self:getControl("ScreenPanel_3", Const.UIPanel)
    self.clonePanel = self:retainCtrl("ShapePanel", screenPanel3)
    self.cloneUnInfoPanel = self:retainCtrl("UnShapePanel", screenPanel3)
    self.imageSz = self:getControl("GuardImage", nil, self.clonePanel):getContentSize()

    self.scrollView = self:getControl("ScrollView_218", Const.UIScrollView)

   -- 初始化宠物相关信息
    self.attribs = { num = 0 }
    self.selectAttrib = nil
    self.slotPos = 0
    self.selectStone = nil
    self.pet = nil

    -- 绑定事件
    self:bindListener("PetFigurePanel", function(sender, eventType)
        self:setCtrlVisible("ScreenPanel_1", true)
        self:setCtrlVisible("ScreenBKPanel_1", true)
        self:setCtrlVisible("ScreenPanel_2", false)
        self:setCtrlVisible("ScreenBKPanel_2", false)
        self:setCtrlVisible("ScreenPanel_3", false)
        self:hideSelectEffect("StoneInsertedPanel_")
        self:hideSelectEffect("ChoseStonePanel_")

        self:setCtrlVisible("ReplenishPanel", false)
        self:setCtrlVisible("BKImage_2", false, "ReplenishPanel")
    end)

    self:bindListener("ScreenPanel_2", function(sender, eventType)
        self:setCtrlVisible("ReplenishPanel", false)
        self:setCtrlVisible("BKImage_2", false, "ReplenishPanel")
    end)

    self:bindListener("BKPanel_1", function(sender, eventType)
        self:setCtrlVisible("ReplenishPanel", false)
        self:setCtrlVisible("BKImage_2", false, "ReplenishPanel")
    end)

    self:bindListener("AddButton", self.onActiveButton)
    self:bindListener("DeletButton", self.onForgetButton)
    self:bindListener("MakeupButton", self.onMakeupButton)
    self:bindListener("ReplenishButton", self.onReplenishButton)
    self:bindListener("MarkerButton", self.onMarketButton)
    self:bindListener("BagButton", self.onBagButton)
    self:bindListener("StoreButton", self.onStoreButton)
    self:bindListener("AddStoneImage", self.onAddStoneImage, "ReplenishPanel")

    self:setCtrlVisible("ReplenishPanel", false)
    self:setCtrlVisible("BKImage_2", false, "ReplenishPanel")

    self:bindPanelEvent("ChoseStonePanel")

    for i = 1, 3 do
        -- 绑定未打入妖石的按钮事件
        self:bindListener("ChoseStonePanel_" .. i, function(dlg, sender, eventType)
            self:setCtrlVisible("ScreenPanel_1", false)
            self:setCtrlVisible("ScreenBKPanel_1", false)
            self:setCtrlVisible("ScreenPanel_2", false)
            self:setCtrlVisible("ScreenBKPanel_2", false)
            self:setCtrlVisible("ScreenPanel_3", true)
            self:hideSelectEffect("ChoseStonePanel_")
            self:hideSelectEffect("StoneInsertedPanel_")
            self:setCtrlVisible("ChosenEffectImage", true, sender)
            self:setLabelText("TitleNameLabel", CHS[3003444], screenPanel3)
            self:showStoneInListView(STONE_INDEX_LIST.ALL_STONE)
            self.selectAttrib = nil
            self.selectStone = nil

            GuideMgr:needCallBack("ChoseStonePanel")
        end)
    end

    self:bindListener("StoneChoseBox", function(dlg, sender, eventType)
        local isVisible = self:getControl("ChoseStonePanel"):isVisible()
        self:setCtrlVisible("ChoseStonePanel", not isVisible)
    end)

    self:bindListener("AllStonePanel", function(dlg, sender, eventType)
        self:setCtrlVisible("ChoseStonePanel", false)
        self:showStoneInListView(STONE_INDEX_LIST.ALL_STONE)
        self:setLabelText("TitleNameLabel", CHS[3003444], screenPanel3)
    end)

    self:bindListener("LifeStonePetsPanel", function(dlg, sender, eventType)
        self:setCtrlVisible("ChoseStonePanel", false)
        self:showStoneInListView(STONE_INDEX_LIST.NINGXIANG_HUANCAI)
        self:setLabelText("TitleNameLabel", CHS[3003453], screenPanel3)
    end)

    self:bindListener("SpeedStonePanel", function(dlg, sender, eventType)
        self:setCtrlVisible("ChoseStonePanel", false)
        self:showStoneInListView(STONE_INDEX_LIST.XUANYING_SHUANGXING)
        self:setLabelText("TitleNameLabel", CHS[3003454], screenPanel3)
    end)

    self:bindListener("DefenceStonePanel", function(dlg, sender, eventType)
        self:setCtrlVisible("ChoseStonePanel", false)
        self:showStoneInListView(STONE_INDEX_LIST.FENGJI_YUNQING)
        self:setLabelText("TitleNameLabel", CHS[3003450], screenPanel3)
    end)

    self:bindListener("PhyStonePanel", function(dlg, sender, eventType)
        self:setCtrlVisible("ChoseStonePanel", false)
        self:showStoneInListView(STONE_INDEX_LIST.KUYUE_LIUHUN)
        self:setLabelText("TitleNameLabel", CHS[3003451], screenPanel3)
    end)

    self:bindListener("MagcStonePanel", function(dlg, sender, eventType)
        self:setCtrlVisible("ChoseStonePanel", false)
        self:showStoneInListView(STONE_INDEX_LIST.LEIJI_HUGUANG)
        self:setLabelText("TitleNameLabel", CHS[3003452], screenPanel3)
    end)

    self:bindListener("ManacStonePanel", function(dlg, sender, eventType)
        self:setCtrlVisible("ChoseStonePanel", false)
        self:showStoneInListView(STONE_INDEX_LIST.BINGLUO_CANYANG)
        self:setLabelText("TitleNameLabel", CHS[3004454], screenPanel3)
    end)

    local pet = DlgMgr:sendMsg("PetListChildDlg","getCurrentPet")
    self:setPetInfo(pet)

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_GENERAL_NOTIFY")
end

function PetStoneDlg:cleanup()
    self.notResetInfo = nil
end

-- 显示当前选中的光效
function PetStoneDlg:hideSelectEffect(name)
    for i = 1, 3 do
        local node = self:getControl(name .. i, Const.UIPanel)
        self:setCtrlVisible("ChosenEffectImage", false, node)
    end
end


function PetStoneDlg:bindPanelEvent(name)
    local panel = self:getControl(name, Const.UIPanel)
    if not panel then return end


    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)
        touchPos = panel:getParent():convertToNodeSpace(touchPos)

        if not panel:isVisible() then
            return false
        end

        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end
        self:setCtrlVisible(name, false)
        if cc.rectContainsPoint(box, touchPos) then
            return true
        end
        return false
    end

    local function onTouchMove(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

    end

    local function onTouchEnd(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)

        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        return true
    end


    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

function PetStoneDlg:showStoneInListView(type)
    type = type or STONE_INDEX_LIST.ALL_STONE
    self.curShowType = type
    self.selectAttrib = nil

    local items = {}
    if type == STONE_INDEX_LIST.FENGJI_YUNQING then
        items = InventoryMgr:getItemByName(CHS[3003450])
    elseif type == STONE_INDEX_LIST.KUYUE_LIUHUN then
        items = InventoryMgr:getItemByName(CHS[3003451])
    elseif type == STONE_INDEX_LIST.LEIJI_HUGUANG then
        items = InventoryMgr:getItemByName(CHS[3003452])
    elseif type == STONE_INDEX_LIST.NINGXIANG_HUANCAI then
        items = InventoryMgr:getItemByName(CHS[3003453])
    elseif type == STONE_INDEX_LIST.BINGLUO_CANYANG then
        items = InventoryMgr:getItemByName(CHS[3004454])
    elseif type == STONE_INDEX_LIST.XUANYING_SHUANGXING then
        items = InventoryMgr:getItemByName(CHS[3003454])
    elseif type == STONE_INDEX_LIST.ALL_STONE then
        for k, v in pairs(STONE_ATTRIB_LIST) do
            local tmp = InventoryMgr:getItemByName(k)
            for i = 1, #tmp do
                table.insert(items, tmp[i])
            end
        end
    end

    -- 名称按STONE_ATTRIB_LIST中的顺序排列，相同名称按等级从大到小排列
    table.sort(items, function(l, r)
        if STONE_ATTRIB_LIST[l.name] < STONE_ATTRIB_LIST[r.name] then return true end
        if STONE_ATTRIB_LIST[l.name] > STONE_ATTRIB_LIST[r.name] then return false end
        if l.level > r.level then return true end
        if l.level < r.level then return false end
    end)

    self.scrollView:removeAllChildren()
    self:refreshSelectStoneInfo(true, #items)

    local count = math.max(#items, ITEM_SHOW_COUNT)
    local row = math.ceil(count / 5)
    local scrollViewSz = self.scrollView:getContentSize()
    local innerHeight = math.max(row * (MARGIN + self.imageSz.height) + MARGIN, scrollViewSz.height)
    self.scrollView:setInnerContainerSize({width = scrollViewSz.width, height = innerHeight})

    for i = 1, count do
        local item
        local v = items[i]
        if v then
            item = self.clonePanel:clone()
            self:setImage("GuardImage", InventoryMgr:getIconFileByName(v.name), item)
            self:setItemImageSize("GuardImage", item)
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT,
                v.level, false, LOCATE_POSITION.CENTER, 19, item)
            self:setLabelText("NameLabel", v.name, item)
            self:setLabelText("NimbusValueLabel", CHS[3003455] .. v.nimbus, item)
            local key, value = self:getStoneKeyAndValue(v)
            self:setLabelText("AddValueLabel", key .. CHS[3003456] .. value, item)

            local img = self:getControl("GuardImage", nil, item)
            if v and InventoryMgr:isLimitedItem(v) then
                InventoryMgr:addLogoBinding(img)
            else
                InventoryMgr:removeLogoBinding(img)
            end

            if v.amount > 0 then
                self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT,
                    v.amount, false,
                    LOCATE_POSITION.RIGHT_BOTTOM, 19, item)
            end

            item.info = v

            item:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    self:lostFocusListView()
                    self:setCtrlVisible("ChoseImage", true, item)
                    self.selectAttrib = v
                    self:refreshSelectStoneInfo(false)
                end
            end)
        else
            item = self.cloneUnInfoPanel:clone()
        end

        local newY = math.ceil(i / 5)
        local newX = i % 5
        newX = newX == 0 and 5 or newX
        item:setPosition(MARGIN + (newX - 1) * (self.imageSz.width + MARGIN), innerHeight - newY * (self.imageSz.height + MARGIN))
        self.scrollView:addChild(item)
    end
end

-- 刷新选中妖石信息
function PetStoneDlg:refreshSelectStoneInfo(notShow, stoneCount)
    if not self.selectAttrib then notShow = true end
    local panel = self:getControl("StoneAttributePanel")
    if notShow then
        self:setCtrlVisible("StonePanel", false, panel)
        self:setLabelText("StoneNameLabel", "", panel)
        self:setLabelText("StoneAttributeLabel1", "", panel)
        self:setLabelText("StoneAttributeLabel2", "", panel)
        self:setLabelText("StoneLVLabel", "", panel)
        local showFlag = stoneCount and stoneCount > 0
        self:setCtrlVisible("StoneDetailPanel", showFlag, panel)
        self:setCtrlVisible("TipsLabel", not showFlag, panel)
    else
        local item = self.selectAttrib
        self:setImage("GuardImage", InventoryMgr:getIconFileByName(item.name), panel)
        self:setCtrlVisible("StonePanel", true, panel)
        self:setItemImageSize("GuardImage", panel)
        self:setLabelText("StoneNameLabel", item.name, panel)
        self:setLabelText("StoneAttributeLabel2", CHS[3003455] .. item.nimbus, panel)
        local key, value = self:getStoneKeyAndValue(item)
        self:setLabelText("StoneAttributeLabel1", key .. CHS[3003456] .. value, panel)
        self:setLabelText("StoneLVLabel", string.format(CHS[7150044], item.level), panel)
    end

    panel:requestDoLayout()
end

function PetStoneDlg:lostFocusListView()
    local items = self.scrollView:getChildren()

    for k, v in pairs(items) do
        self:setCtrlVisible("ChoseImage", false, v)
    end
end

function PetStoneDlg:getStoneKeyAndValue(item)
    if not item then return "", "" end

    if item.name == CHS[3003450] then
        return CHS[3003457], item.extra["def_2"]
    elseif item.name == CHS[3003451] then
        return CHS[3003458], item.extra["phy_power_2"]
    elseif item.name == CHS[3003452] then
        return CHS[3003459], item.extra["mag_power_2"]
    elseif item.name == CHS[3003453] then
        return CHS[3003460], item.extra["max_life_2"]
    elseif item.name == CHS[3004454] then
        return CHS[3000104], item.extra["max_mana_2"]
    elseif item.name == CHS[3003454] then
        return CHS[3003461], item.extra["speed_2"]
    end
end

-- 打入妖石
function PetStoneDlg:onActiveButton(sender, eventType)
    local petNo, item, pos
    local function checkCanAdd()
        -- 若在战斗中直接返回
        if Me:isInCombat() then
            gf:ShowSmallTips(CHS[3003462])
            return
        end

        if not self.selectAttrib or not self.pet then
            -- 还未选择
            gf:ShowSmallTips(CHS[3003463])
            return
        end

        if self.pet:queryInt("rank") == Const.PET_RANK_WILD then
            gf:ShowSmallTips(CHS[3003464])
            return
        end

        if self.pet:queryBasicInt("stone_num") >= 3 then
            gf:ShowSmallTips(string.format(CHS[3003465], self.pet:getShowName()))
            return
        end

        if self.attribs[self.selectAttrib.name] then
            gf:ShowSmallTips(string.format(CHS[3003466], self.pet:getShowName(), self.selectAttrib.name))
            return
        end

        petNo = self.pet:queryBasicInt("no")
        item = InventoryMgr:getItemByPos(self.selectAttrib.pos)
        pos = self.selectAttrib.pos

        if not item then
            return
        end

        if item["name"] ~=  self.selectAttrib.name then
            gf:ShowSmallTips(CHS[3003467]..self.selectAttrib.name)
            return
        end

        if  item.level > math.floor(self.pet:queryBasicInt("level") / 10 ) then
            gf:ShowSmallTips(string.format(CHS[3003468], self.pet:getShowName()))
            return
        end

        -- 如果宠物为限时宠物，给出确认提示框
        if PetMgr:isTimeLimitedPet(self.pet) then
            local selectAttribName = self.selectAttrib.name
            gf:confirm(CHS[7000089], function()
                InventoryMgr:feedPet(petNo, pos, "inset")
            end)
            return
        end

        return true
    end

    if checkCanAdd() then
        InventoryMgr:feedPet(petNo, pos, "inset")
    end

    GuideMgr:needCallBack("ActiveButton")
end

function PetStoneDlg:onMarketButton(sender, eventType)
    if not self.selectStone then return end
    if Me:queryBasicInt("level") < 50 then
        gf:ShowSmallTips(CHS[4300064])
        return
    end

    if self.selectStone.level < 5 then
        gf:ShowSmallTips(CHS[4300072])
        return
    end

    local str = string.format(CHS[4300065], self.selectStone.name, self.selectStone.level)
    DlgMgr:openDlgAndsetParam(str)
    DlgMgr:closeDlg("PetAttribDlg")
    self:onCloseButton()
end

function PetStoneDlg:onBagButton(sender, eventType)
    DlgMgr:openDlg("AlchemyDlg")
end

function PetStoneDlg:onAddStoneImage(sender, eventType)
    local isVisible = self:getCtrlVisible("BKImage_2", "ReplenishPanel")
    self:setCtrlVisible("BKImage_2", not isVisible, "ReplenishPanel")
end

function PetStoneDlg:onStoreButton(sender, eventType)
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4300066]))
    DlgMgr:closeDlg("PetAttribDlg")
    self:onCloseButton()
end

function PetStoneDlg:onReplenishButton(sender, eventType)
    if not self.selectStone or not self.selectAttrib then return end
    local amount = InventoryMgr:getAmountByNameLevel(self.selectStone.name, self.selectStone.level)
    if amount == 0 then
        gf:ShowSmallTips(CHS[4300067])
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002257])
        return
    end

    if self.selectStone.nimbus + (self.selectStone.level * 1000 + 3000) > (self.selectStone.level * 1000 + 3000) * 2 then
        gf:ShowSmallTips(CHS[4300068])
        return
    end

    local petNo = self.pet:queryBasicInt("no")
    local items = InventoryMgr:getItemByNameAndLevel(self.selectStone.name, self.selectStone.level)
    if #items == 0 then return end
    local pos = items[1].pos

    local attribName = self.selectAttrib.name
    gf:confirm(string.format(CHS[4300069], self.selectStone.name), function ()
        InventoryMgr:feedPet(petNo, pos, "replenish")
    end)
end

function PetStoneDlg:onMakeupButton(sender, eventType)
    local isVisible = self:getCtrlVisible("ReplenishPanel")
    self:setCtrlVisible("ReplenishPanel", not isVisible)
end

-- 移除妖石
function PetStoneDlg:onForgetButton(sender, eventType)
    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003462])
        return
    end

    if not self.selectAttrib or not self.pet then
        -- 还未选择
        return
    end

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    local petNo = self.pet:queryBasicInt("no")

    -- 安全锁判断
    if self:checkSafeLockRelease("onForgetButton", sender, eventType) then
        return
    end

    -- 去除妖石
    local attribName = self.selectAttrib.name
    gf:confirm(string.format(CHS[3000124], self.selectAttrib.name), function()  -- '你确认要移除妖石#R%s#n吗？'
        -- 服务器延迟响应或进入战斗，有可能导致报错，所以增加判断
        gf:sendGeneralNotifyCmd(NOTIFY.DELETE_STONE_ATTRIB, petNo, attribName)
    end)
end

-- 设置宠物信息
function PetStoneDlg:setPetInfo(pet, addStoneFlag)
    if not pet then return end

    self.pet = pet

    local icon = 0
    local polar = 0
    local life = 0
    local maxLife = 0
    local mana = 0
    local maxMana = 0
    local phyPower = 0
    local magPower = 0
    local speed = 0
    local def = 0

    local life_add_temp = 0
    local mana_add_temp = 0
    local phy_power_add_temp = 0
    local mag_power_add_temp = 0
    local speed_add_temp = 0
    local def_add_temp = 0

    if pet then
        icon = pet:getDlgIcon(nil, nil, true)
        polar = pet:queryInt('polar')
        life = pet:queryInt('life')
        maxLife = pet:queryInt('max_life')
        mana = pet:queryInt('mana')
        maxMana = pet:queryInt('max_mana')
        phyPower = pet:queryInt('phy_power')
        magPower = pet:queryInt('mag_power')
        speed = pet:queryInt('speed')
        def = pet:queryInt('def')
    end

    local life_add_temp = 0
    local mana_add_temp = 0
    local phy_power_add_temp = 0
    local mag_power_add_temp = 0
    local speed_add_temp = 0
    local def_add_temp = 0

    -- 存储一下妖石属性修改前的信息(打入妖石后，需要对比打入前后妖石情况，进行选中)
    self.originAttribs = self.attribs

    -- 获取妖石属性信息
    self.attribs = { num = 0 }
    if self.pet then
        self.attribs.num = pet:queryBasicInt("group_num")

        local count = 1
        for i = GROUP_NO.STONE_START, GROUP_NO.STONE_END do
            local info = pet:queryBasic('group_' .. i)
            if info.no and info.no >= GROUP_NO.STONE_START and info.no <= GROUP_NO.STONE_END then
                self.attribs[count] = info
                count = count + 1
            end
        end

        self.attribs.num = pet:queryBasicInt("stone_num")

        -- 如果是打入妖石，则需要选中该妖石
        local insertIndex = nil
        if addStoneFlag then
            -- 对比打入前后，妖石数据，找到新打入的妖石(存在玩家选中最后一个打入框，打入妖石显示在第一个框的情况，所以需要对比数据)
            for i = 1, self.attribs.num do
                local findIt = false
                for j = 1, self.originAttribs.num do
                    if self.originAttribs[j].name == self.attribs[i].name and
                        self.originAttribs[j].nimbus == self.attribs[i].nimbus then
                        -- 灵气值变化时，认为新打入了，需要重新选择，刷新该妖石信息
                        findIt = true
                    end
                end

                if not findIt then
                    insertIndex = i
                    self.notResetInfo = true
                    break
                end
            end
        else
            if self.originAttribs and self.attribs.num ~= self.originAttribs.num then
                -- 移除妖石的情况
                self.notResetInfo = false
            end

            if not self.notResetInfo then
                -- 重置显示宠物信息
                self:resetInfo()
                self.selectAttrib = nil
                self.notResetInfo = true
            end
        end

        for i = 1, self.attribs.num do
            local info = self.attribs[i]
            if info.no then
                if info.max_life then
                    life_add_temp = info.max_life
                    info.key = CHS[3003460]
                    info.value = info.max_life
                elseif info.max_mana then
                    mana_add_temp = info.max_mana
                    info.key = CHS[3003470]
                    info.value = info.max_mana
                elseif info.phy_power then
                    phy_power_add_temp = info.phy_power
                    info.key = CHS[3003458]
                    info.value = info.phy_power
                elseif info.mag_power then
                    mag_power_add_temp = info.mag_power
                    info.key = CHS[3003459]
                    info.value = info.mag_power
                elseif info.speed then
                    speed_add_temp = info.speed
                    info.key = CHS[3003461]
                    info.value = info.speed
                elseif info.def then
                    def_add_temp = info.def
                    info.key = CHS[3003457]
                    info.value = info.def
                end
                self:setPetStoneInfo(info, i)
                if insertIndex == i then
                    -- 需要选中新打入的妖石
                    self:setInsertStone(info, insertIndex, "StoneInsertedPanel_" .. i)
                end

                -- 绑定要移除的按钮事件
                self:bindListener("StoneInsertedPanel_" .. i, function(dlg, sender, eventType)
                    self:setInsertStone(info, i, sender)
                end)
            end
        end
    end

    -- 设置信息
    self:setPetValueInfo("LifeValueLabel", maxLife, life_add_temp, "LifePanel")
    self:setPetValueInfo("ManaValueLabel", maxMana, mana_add_temp, "ManaPanel")
    self:setPetValueInfo("PhyValueLabel", phyPower, phy_power_add_temp, "PhyPanel")
    self:setPetValueInfo("MagValueLabel", magPower, mag_power_add_temp, "MagPanel")
    self:setPetValueInfo("SpeedValueLabel", speed, speed_add_temp, "SpeedPanel")
    self:setPetValueInfo("DefenceValueLabel", def, def_add_temp, "DefencePanel")

    -- 设置头像区域信息
    PetMgr:setPetLogo(self, self.pet)
    self:setCtrlVisible("SuffixImage", true)
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(self.pet))
    self:setPortrait("PetIconPanel", pet:getDlgIcon(nil, nil, true), 0, nil, true, nil, nil, cc.p(0, -36))
    self:setLabelText("PetNameLabel", self.pet:getShowName())
end

function PetStoneDlg:setInsertStone(info, i, sender)
    self.selectStone = info
    self:setCtrlVisible("ScreenPanel_1", false)
    self:setCtrlVisible("ScreenPanel_2", true)
    self:setCtrlVisible("ScreenBKPanel_1", false)
    self:setCtrlVisible("ScreenBKPanel_2", true)
    self:setCtrlVisible("ScreenPanel_3", false)
    self:hideSelectEffect("StoneInsertedPanel_")
    self:hideSelectEffect("ChoseStonePanel_")
    self:setCtrlVisible("ChosenEffectImage", true, sender)
    self:setStoneDetail(info)
    self.selectAttrib = {}
    self.selectAttrib.name = info.name
    self:setCtrlVisible("ReplenishPanel", false)
    self:setCtrlVisible("BKImage_2", false, "ReplenishPanel")
    self:setReplenishPanel()
end

-- 设置补充面板的信息
function PetStoneDlg:setReplenishPanel()
    local panel = self:getControl("ReplenishPanel")

    -- icon
    self:setImage("ItemImage", InventoryMgr:getIconFileByName(self.selectStone.name), panel)
    self:setItemImageSize("ItemImage", panel)

    -- 等级
    self:setLabelText("LevelLabel", self.selectStone.level .. "级", panel)

    -- 名称
    self:setLabelText("NameLabel", self.selectStone.name, panel)

    -- 数量
    local amount = InventoryMgr:getAmountByNameLevel(self.selectStone.name, self.selectStone.level)
    local color = COLOR3.GREEN
    if amount == 0 then
        color = COLOR3.RED
        self:setCtrlEnabled("ItemImage", false, panel)
        self:setCtrlVisible("AddStoneImage", true, panel)

        -- 本次补充
        self:setLabelText("AddValueLabel", 0, panel)
    else
        self:setCtrlEnabled("ItemImage", true, panel)
        self:setCtrlVisible("AddStoneImage", false, panel)

        -- 本次补充
        self:setLabelText("AddValueLabel", (self.selectStone.level * 1000 + 3000), panel)
    end
    self:setLabelText("HasCountLabel", amount, panel, color)

    -- 当前灵气
    self:setLabelText("NimbusValueLabel", self.selectStone.nimbus .. "/" .. (2 * (self.selectStone.level * 1000 + 3000)), panel)

    self:updateLayout("AddInfoPanel")
end

function PetStoneDlg:setPetStoneInfo(info, index)
    if not info then
        return
    end

    local node = self:getControl("StoneInsertedPanel_" .. index, Const.UIPanel)
    self:setCtrlVisible("ChoseStonePanel_" .. index, false)
    self:setCtrlVisible("StoneInsertedPanel_" .. index, true)
    self:setImage("GuardImage", InventoryMgr:getIconFileByName(info.name), node)
    self:setItemImageSize("GuardImage", node)
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT,
        info.level, false, LOCATE_POSITION.CENTER, 19, node)
end

function PetStoneDlg:setPetValueInfo(name, value, addValue, rootName)
    local node = self:getControl(rootName, Const.UIPanel)
    self:setLabelText(name, value - addValue)
    self:setLabelText(name .. "_2", value, node, COLOR3.GREEN)
    self:setCtrlVisible(name .. "_2", addValue ~= 0, node)
    self:setCtrlVisible("GoToImage", addValue ~= 0, node)
    self:updateLayout(rootName)
end

function PetStoneDlg:resetInfo()
    for i = 1, 3 do
        self:setCtrlVisible("StoneInsertedPanel_" .. i, false)
        self:setCtrlVisible("ChoseStonePanel_" .. i, true)
    end

    self:setCtrlVisible("ScreenPanel_1", true)
    self:setCtrlVisible("ScreenPanel_2", false)
    self:setCtrlVisible("ScreenBKPanel_1", true)
    self:setCtrlVisible("ScreenBKPanel_2", false)
    self:setCtrlVisible("ScreenPanel_3", false)
    self:hideSelectEffect("StoneInsertedPanel_")
    self:hideSelectEffect("ChoseStonePanel_")
    self:setCtrlVisible("EmptyItemLabel", false)
end

function PetStoneDlg:setStoneDetail(info)
    local node = self:getControl("ScreenPanel_2", Const.UIPanel)
    self:setImage("GuardImage", InventoryMgr:getIconFileByName(info.name), node)
    self:setItemImageSize("GuardImage", node)
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT,
        info.level, false, LOCATE_POSITION.CENTER, 19, node)
    self:setLabelText("StoneLevelLabel", info.level .. CHS[3003471], node)
    self:setLabelText("StoneNameLabel", info.name, node)
    self:setLabelText("StoneEffectLabel", info.key, node)
    self:setLabelText("EffectNumLabel", "+" .. info.value, node)
    self:setLabelText("SpiritNumLabel", info.nimbus, node)
end

-- 显示提示信息
function PetStoneDlg:onNoteButton(sender, eventType)
    gf:showTipInfo(CHS[3000100] .. '\n' .. CHS[3000101] .. '\n' .. CHS[3000102], sender)
end

-- 物品变更了
function PetStoneDlg:MSG_INVENTORY()
    if not self.pet then
        return
    end

    if self.selectAttrib and self.selectAttrib.pos and not InventoryMgr:getItemByPos(self.selectAttrib.pos) then
        self.selectAttrib = nil
        self:showStoneInListView(self.curShowType)
    end
end

function PetStoneDlg:getSelectItemBox(clickItem)
    if clickItem == "chooseEmptyPanel" then
        if not self.pet then
            return
        end

        local num = self.pet:queryBasicInt("stone_num")
        local panel = self:getControl("ChoseStonePanel_" .. (num + 1))
        if panel then
            return self:getBoundingBoxInWorldSpace(panel)
        end
    elseif clickItem == "chooseStone" then
        local childs = self.scrollView:getChildren()
        for i = 1, #childs do
            if childs[i].info and childs[i].info.level * 10 <= self.pet:getLevel() then
                local x, y = childs[i]:getPosition()
                local curHeight = y -- childs[i]:getContentSize().height / 2
                local totalHeight = self.scrollView:getInnerContainerSize().height
                local height = self.scrollView:getContentSize().height
                if totalHeight - curHeight > height then
                    self.scrollView:getInnerContainer():setPositionY(-curHeight)
                end

                return self:getBoundingBoxInWorldSpace(childs[i])
            end
        end
    end
end

function PetStoneDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_FEED_STONE_OK == data.notify and self.pet then
        self:setPetInfo(self.pet, true)
    end
end

function PetStoneDlg:getSenderByName(name)
end

return PetStoneDlg
