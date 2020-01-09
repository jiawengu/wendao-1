-- JewelryDecomposeDlg.lua
-- Created by huangzz Apr/19/2018
-- 首饰分解界面

local JewelryDecomposeDlg = Singleton("JewelryDecomposeDlg", Dialog)

local RewardContainer = require("ctrl/RewardContainer")

local RadioGroup = require("ctrl/RadioGroup")

local LIMIT_POINT = 9999  -- 最多可携带精华数

local COST_CASH_ONE_POINT = 10000 -- 1精华点消耗 10000 金钱

function JewelryDecomposeDlg:init()
    self:bindListener("DecomposeButton", self.onDecomposeButton)
    self:bindListener("ItemPanel", self.onItemPanel)
    -- self:bindListViewListener("ListView", self.onSelectListView)

    self:bindListener("GetJinghuaPanel", self.onShowFloat)
    self:bindListener("HaveJinghuaPanel", self.onShowFloat)
    self:bindListener("JinghuaImage", self.onShowFloat)
    self:bindListener("JinghuaImage_0", self.onShowFloat)

    self:bindListener("CostCashPanel", self.onShowFloat)
    self:bindListener("OwnCashPanel", self.onShowFloat)
    self:bindListener("CashImage1", self.onShowFloat)
    self:bindListener("CashImage2", self.onShowFloat)

    self.itemPanel = self:retainCtrl("ItemPanel")
    self.chooseImg = self:retainCtrl("ChoosingEffectImage", self.itemPanel)

    self.selectItems = {}
    self.canGetEssence = 0
    self.lastMyEssence = 0
    self.isPlayMagic = nil
    self.isCmdDecompose = false
    self.schId = nil
    self.myEssence = Me:queryBasicInt("jewelry_essence")

    self.canGetEssence = 0
    self:setPointNum()
    self:setCashNum()

    self.selectType = InventoryMgr:getLimitItemFlag("JewelryDecomposeDlg", 1)
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"OrdinaryCheckBox", "ValuedCheckBox"}, self.onCheckBox)
    self.radioGroup:selectRadio(self.selectType)

    self:hookMsg("MSG_SPLIT_JEWELRY_COMPLETE")
    self:hookMsg("MSG_UPDATE")
end

function JewelryDecomposeDlg:onShowFloat(sender)
    local parent = sender:getParent()
    if parent:getName() == "JinghuaPanel" then
        RewardContainer:showCommonReward(sender, {CHS[5450185], CHS[5450185]})
    else
        RewardContainer:showCommonReward(sender, {CHS[3002690], CHS[3002690]})
    end
end

function JewelryDecomposeDlg:onCheckBox(sender, index)
    InventoryMgr:setLimitItemDlgs(self.name, index)
    self.selectType = index
    self:initScrollView()
    self:setPointNum()
    self:setCashNum()
end

function JewelryDecomposeDlg:doJinghuaAction()
    local img = self:getControl("JinghuaImage_0", nil, "JinghuaPanel")
    if img then
        local action = cc.Sequence:create(
            cc.ScaleTo:create(0.08, 0.5, 0.5),
            cc.ScaleTo:create(0.08, 0.30, 0.30)
        )

        img:runAction(cc.RepeatForever:create(action))
    end

    local cou = 1
    local addNum = self.myEssence - self.lastMyEssence
    local totalNum = self.lastMyEssence

    if addNum == 0 then
        addNum = self.addNum or  0
    end

    if self.schId then
        self.root:stopAction(self.schId)
        self.schId = nil
    end

    if addNum == 0 then
        self.isPlayMagic = nil

        self:setPointNum()
        self:setCashNum()
        return
    end

    self.schId = schedule(self.root, function()
        local w = 1
        local num = addNum
        repeat
            if num == 0 then
                break
            end

            local m = num % 10
            if m == 0 then
                num = num / 10
                w = w * 10
            else
                break
            end
        until false

        addNum = addNum - w
        totalNum = totalNum + w

        local str = gf:getArtFontMoneyDesc(tonumber(totalNum))
        self:setNumImgForPanel("HaveJinghuaPanel", ART_FONT_COLOR.NORMAL_TEXT, str, false, LOCATE_POSITION.CENTER, 21)

        local str = gf:getArtFontMoneyDesc(tonumber(addNum))
        self:setNumImgForPanel("GetJinghuaPanel", ART_FONT_COLOR.NORMAL_TEXT, str, false, LOCATE_POSITION.CENTER, 21)

        if addNum <= 0 then
            self.root:stopAction(self.schId)
            self.schId = nil
            self.isPlayMagic = nil

            self:setPointNum()
            self:setCashNum()
        end
    end, 0.03)
end

-- 创建分解动画
function JewelryDecomposeDlg:createArmature()
    local img = self:getControl("LuziImage", nil, "BKPanel")
    img:removeAllChildren()
    local size = img:getContentSize()
    local magic = ArmatureMgr:createArmature("01263")
    magic:setAnchorPoint(0.5, 0.5)

    local wPos = img:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
    local pos = self.root:convertToNodeSpace(wPos)

    magic:setPosition(pos.x, pos.y)
    self.root:addChild(magic, 100, 0)

    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.complete then
            magic:stopAllActions()
            magic:removeFromParent()

            img = self:getControl("JinghuaImage_0", nil, "JinghuaPanel")
            img:stopAllActions()
            img:setScale(0.30)
        end
    end

    magic:getAnimation():setMovementEventCallFunc(func)
    magic:getAnimation():play("Bottom01", -1, 0)

    self.isPlayMagic = true

    performWithDelay(self.root, function()
        self:doJinghuaAction()
    end, 1)
end

function JewelryDecomposeDlg:setCashNum()
    local str, color = gf:getArtFontMoneyDesc(Me:queryBasicInt("cash"))
    self:setNumImgForPanel("OwnCashPanel", color, str, false, LOCATE_POSITION.CENTER, 21)

    local str, color = gf:getArtFontMoneyDesc(self.canGetEssence * COST_CASH_ONE_POINT)
    self:setNumImgForPanel("CostCashPanel", color, str, false, LOCATE_POSITION.CENTER, 21)
end

function JewelryDecomposeDlg:setPointNum()
    local str = gf:getArtFontMoneyDesc(self.myEssence)
    self:setNumImgForPanel("HaveJinghuaPanel", ART_FONT_COLOR.NORMAL_TEXT, str, false, LOCATE_POSITION.CENTER, 21)

    local str = gf:getArtFontMoneyDesc(self.canGetEssence)
    self:setNumImgForPanel("GetJinghuaPanel", ART_FONT_COLOR.NORMAL_TEXT, str, false, LOCATE_POSITION.CENTER, 21)
end

function JewelryDecomposeDlg:initScrollView()
    local jewelrys = EquipmentMgr:getCanDecomposeJewelry(self.selectType == 2)

    self.selectItems = {}
    self.canGetEssence = 0

    local cou = #jewelrys
    if cou == 0 then
        self:setCtrlVisible("ScrollView", false)
        self:setCtrlVisible("NoticeLabel1", self.selectType == 1)
        self:setCtrlVisible("NoticeLabel2", self.selectType == 2)
    else
        self:setCtrlVisible("ScrollView", true)
        self:setCtrlVisible("NoticeLabel1", false)
        self:setCtrlVisible("NoticeLabel2", false)
        self:initScrollViewPanel(jewelrys, self.itemPanel, self.setOneItemPanel, self:getControl("ScrollView"), 5, 14, 14, 7, 7)
    end
end

function JewelryDecomposeDlg:setOneItemPanel(cell, data)
    if next(data) then
        local img = self:getControl("ItemImage", nil, cell)
        img:loadTexture(ResMgr:getItemIconPath(data.icon))

        self:setNumImgForPanel("ItemPanel", ART_FONT_COLOR.NORMAL_TEXT, data.req_level, false, LOCATE_POSITION.LEFT_TOP, 19, cell)

        cell.data = data
    end

    self:setCtrlVisible("GetImage", false, cell)
end

function JewelryDecomposeDlg:onItemPanel(sender, eventType)
    if self.isPlayMagic or self.isCmdDecompose then return end

    local data = sender.data
    if not data then return end

    local needReFresh
    if self.selectType == 1 then
        needReFresh = self:doSelectMulti(sender, data)
    else
        needReFresh = self:doSelectOne(sender, data)
    end

    if needReFresh then
        self:setCashNum()
        self:setPointNum()
    end
end

function JewelryDecomposeDlg:doSelectOne(sender, data)
    -- 贵重首饰
    if self.chooseImg:getParent() == sender then
        return
    end

    self.chooseImg:removeFromParent()
    self.canGetEssence = 0
    self.selectItems = {}

    local essence = EquipmentMgr:getDecJewelryGetEssence(data.req_level) or 0
    -- 若分解后角色身上的首饰精华点数＞limit_point点，给予弹出提示
    if self.canGetEssence + self.myEssence + essence > LIMIT_POINT then
        gf:ShowSmallTips(CHS[5450176])
        return
    end

    sender:addChild(self.chooseImg)

    table.insert(self.selectItems, data)

    self.canGetEssence = self.canGetEssence + essence
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showItemByItemData(data, rect)

    return true
end

function JewelryDecomposeDlg:doSelectMulti(sender, data)
    local isSelect
    local img = self:getControl("GetImage", nil, sender)
    isSelect = not img:isVisible()

    local essence =  EquipmentMgr:getDecJewelryGetEssence(data.req_level) or 0
    if isSelect then
        -- 若勾选道具大于10件，则不予选中，并予以如下弹出提示：
        if #self.selectItems >= 10 then
            gf:ShowSmallTips(CHS[5450175])
            return
        end

        -- 若分解后角色身上的首饰精华点数＞limit_point点，给予弹出提示
        if self.canGetEssence + self.myEssence + essence > LIMIT_POINT then
            gf:ShowSmallTips(CHS[5450176])
            return
        end
    end

    img:setVisible(isSelect)

    if isSelect then
        table.insert(self.selectItems, data)

        self.canGetEssence = self.canGetEssence + essence
        local rect = self:getBoundingBoxInWorldSpace(sender)
        InventoryMgr:showItemByItemData(data, rect)
    else
        for i = #self.selectItems, 1, -1 do
            if self.selectItems[i].pos == data.pos then
                self.canGetEssence = self.canGetEssence - essence
                table.remove(self.selectItems, i)
            end
        end
    end

    return true
end

function JewelryDecomposeDlg:onDecomposeButton(sender, eventType)
    if self.isPlayMagic or self.isCmdDecompose then
        return
    end

    -- 若该角色处于禁闭状态，给予弹出提示
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not next(self.selectItems) then
        gf:ShowSmallTips(CHS[5420319])
        return
    end

    for _, jewelry in pairs(self.selectItems) do
        local item = InventoryMgr:getItemByPos(jewelry.pos)
        if not item or not EquipmentMgr:isJewelry(item) then
            gf:ShowSmallTips(CHS[4200585])
            self:initScrollView()
            self:setCashNum()
            self:setPointNum()
            return
        end
    end

    -- 若勾选道具大于10件，予以如下弹出提示：
    if #self.selectItems > 10 then
        gf:ShowSmallTips(CHS[5450175])
        return
    end

    -- 若分解后角色身上的首饰精华点数＞limit_point点，给予弹出提示
    if self.canGetEssence + self.myEssence > LIMIT_POINT then
        gf:ShowSmallTips(CHS[5450176])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onDecomposeButton") then
        return
    end

    if not gf:checkEnough("cash", self.canGetEssence * COST_CASH_ONE_POINT) then
        return
    end

    if self.selectType == 1 then
        local moneyStr = gf:getMoneyDesc(self.canGetEssence * COST_CASH_ONE_POINT)
        gf:confirm(string.format(CHS[5450177], moneyStr), function()
            EquipmentMgr:cmdDecomposeJewelry(self.selectItems)
            self.isCmdDecompose = true
            self.lastMyEssence = self.myEssence
        end)
    else
        DlgMgr:openDlgEx("JewelryConfirmDlg", self.selectItems[1])
    end
end

function JewelryDecomposeDlg:doBuyExJewelry(jewelry)
    EquipmentMgr:cmdDecomposeJewelry({jewelry})
    self.isCmdDecompose = true
    self.lastMyEssence = self.myEssence
end

function JewelryDecomposeDlg:MSG_SPLIT_JEWELRY_COMPLETE(data)
    self.addNum = self.canGetEssence

    self.canGetEssence = 0
    self:setCashNum()

    self:initScrollView()
    if data.type == 1 then
        self:createArmature()
    else
        self:setPointNum()
    end

    if not string.isNilOrEmpty(data.tip) then
        gf:ShowSmallTips(data.tip)
        ChatMgr:sendMiscMsg(data.tip)
    end

    self.isCmdDecompose = false
end

function JewelryDecomposeDlg:MSG_UPDATE(data)
    self.myEssence = Me:queryBasicInt("jewelry_essence")

    if not self.isCmdDecompose and not self.isPlayMagic then
        self:setPointNum()
        self:setCashNum()
    end
end

function JewelryDecomposeDlg:cleanup()
    DlgMgr:closeDlg("JewelryConfirmDlg")
end

return JewelryDecomposeDlg
