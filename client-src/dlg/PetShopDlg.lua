-- PetShopDlg.lua
-- Created by Chang_back Jun/19/2015
-- 宠物商城

local RadioGroup = require("ctrl/RadioGroup")
local PetShopDlg = Singleton("PetShopDlg", Dialog)

-- 普遍宠物列表信息
local normalPetList = require(ResMgr:getCfgPath('NormalPetList.lua'))

local MAX_REQ_LEVEL = 120
local MENU_COUNT = MAX_REQ_LEVEL / 5

-- 捕捉信息提示控件宽高
local CATCH_NOTE_CTRL_W = 302
local CATCH_NOTE_CTRL_H = 49

PetShopDlg.curSelectItem = nil

function PetShopDlg:init()
    self:bindListener("MoneyAddButton", self.onMoneyAddButton)
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("CatchNoteButton", self.onCatchNoteButton)
    self.catchListView = self:getControl("CatchLevelListView", Const.UIListView)
    self.petListView = self:getControl("PetListView", Const.UIListView)

    -- 金钱、代金券
    self:bindListener("CashPanel", self.onCashCheckBox) --onVoucherCheckBox
    self:bindListener("VoucherPanel", self.onVoucherCheckBox)

    local moneyType = Me:queryBasicInt("use_money_type")
    if moneyType == MONEY_TYPE.CASH then
        self:setCtrlVisible("CashPanel", true)
        self:setCtrlVisible("VoucherPanel", false)
        self:setCtrlVisible("MoneyAddButton", true)
        self:setCtrlVisible("TicketImage", false)
    else
        self:setCtrlVisible("CashPanel", false)
        self:setCtrlVisible("VoucherPanel", true)
        self:setCtrlVisible("MoneyAddButton", false)
        self:setCtrlVisible("TicketImage", true)
    end
    -- self:updateMoneyInfo()


    self.tempSingleLevelPanel = self:getControl("SingleLevelPanel", Const.UIPanel)
    self.tempSingleLevelPanel:retain()
    self.catchListView:removeAllItems()

    self.tempOneRowPetPanel = self:getControl("OneRowPetPanel", Const.UIPanel)
    self.tempOneRowPetPanel:retain()
    self.tempOneRowPetPanel:removeFromParent()

    self.petItems = nil
    self.isUpateData = false
    self.openSelectParam = nil


    self:hookMsg("MSG_UPDATE", PetShopDlg)
end

-- 清理资源
function PetShopDlg:cleanup()
    self:releaseCloneCtrl("tempSingleLevelPanel")
    self:releaseCloneCtrl("tempOneRowPetPanel")
end

function PetShopDlg:setInfo(data)
    self.petItems = data.items
    self:setMenuList()
    self:updateMoney()
    self.isUpateData = true
end

function PetShopDlg:setMoney(money)
    money = tonumber(money)
    local cashPanel = self:getControl("OwnCashPanel")
    local cash, color = gf:getArtFontMoneyDesc(money)
    self:setNumImgForPanel("MoneyValuePanel", color, cash, false, LOCATE_POSITION.CENTER, 21, cashPanel)
end

function PetShopDlg:MSG_UPDATE(data)
    self:updateMoney()
end

function PetShopDlg:setMenuList()
    local req_max_level = self:getMaxReqLevel()

    for i = 1, MENU_COUNT do

        local tempPanel = self.tempSingleLevelPanel:clone()
        local req_level = i * 5

        if i == 1 then
            req_level = 1
        elseif i == 2 then
            req_level = (i - 1) * 5
        end

        self:setLabelText("LevelLabel", req_level .. CHS[3003411], tempPanel)

        tempPanel:addTouchEventListener(function(sender, eventType)

                if eventType == ccui.TouchEventType.ended then
                    self:cleanMenuState()
                    self:setCtrlVisible("ChosenEffectImage", true, sender)
                    self:showPetItemsByReqLevel(req_level)
                end

        end)

        -- 默认选中
        if req_max_level == req_level then
            self:cleanMenuState()
            self:setCtrlVisible("ChosenEffectImage", true, tempPanel)
            self:showPetItemsByReqLevel(req_level)

            self.catchListView:getInnerContainer():setPositionY( (i - 1) * (tempPanel:getContentSize().height + 7))
        end

        self.catchListView:pushBackCustomItem(tempPanel)
    end
end

function PetShopDlg:getPetItemsByReqLevel(req_level)
    local newData = {}

    for k, v in pairs(self.petItems) do
        local item = normalPetList[v.name]
        if item and item.level_req == req_level then
            v.icon = item.icon
            v.polar = item.polar
            v.zoon = item.zoon
            v.req_level = item.level_req
            table.insert(newData, v)
        end
    end

    return newData
end

function PetShopDlg:showPetItemsByReqLevel(req_level, name)

    local items = self:getPetItemsByReqLevel(req_level)
    self.petListView:removeAllItems()

    local count = #items

    local index = 1

    local firstPanel = nil
    local firstItem = nil

    if not name then
        firstItem = items[1]
    end


    while index <= count do
        local tempPanel = self.tempOneRowPetPanel:clone()

        if not name then
            if index == 1 then
                firstPanel = self:getControl("LeftPetPanel", Const.UIPanel, tempPanel)
            end
        else
            if items[index].name == name then
                firstPanel = self:getControl("LeftPetPanel", Const.UIPanel, tempPanel)
                firstItem = items[index]
            end
        end

        self:setOneCellData(items[index], "LeftPetPanel", tempPanel)
        index = index + 1

        if index > count then
            self.petListView:pushBackCustomItem(tempPanel)
            self:setCtrlVisible("RightPetPanel", false, tempPanel)
            break
        else
            self:setOneCellData(items[index], "RightPetPanel", tempPanel)

            if items[index].name == name then
                firstPanel = self:getControl("RightPetPanel", Const.UIPanel, tempPanel)
                firstItem = items[index]
            end

            self.petListView:pushBackCustomItem(tempPanel)
            index = index + 1
        end
    end


    self:setOnTouchPet(firstItem, firstPanel)

end

function PetShopDlg:getMaxReqLevel()
    local meLevel = Me:queryBasicInt("level")

    if meLevel < 5 then
        return 1
    end

    if meLevel >= MAX_REQ_LEVEL then
        return MAX_REQ_LEVEL
    end

    if meLevel >= 5 and meLevel < 15 then
        return 5
    end

    for i = 1, MENU_COUNT do
        if i ~= 2 then
            local minLevel = i * 5
            local maxLevel = (i + 1) * 5

            if meLevel >= minLevel and meLevel < maxLevel then
                return minLevel
            end
        end
    end
end

function PetShopDlg:setOneCellData(item, panelName, root)
    local panel = self:getControl(panelName, Const.UIPanel, root)
    local icon = item.icon
    local name= item.name .. CHS[3003412]
    local price = item.price
    local path = ResMgr:getSmallPortrait(icon)
    self:setImage("GuardImage", path, panel)
    self:setItemImageSize("GuardImage", panel)
    --self:setLabelText("PolarLabel", item.polar, panel)

    local polarPath = ResMgr:getPolarImagePath(item.polar)
    local polarImage = self:getControl("PolarImage", Const.UIImage, panel)
    polarImage:loadTexture(polarPath, ccui.TextureResType.plistType)
    --self:setImage("PolarImage", polarPath, panel)
    self:setLabelText("NameLabel", name, panel)
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, item.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
    local cash, color = gf:getArtFontMoneyDesc(price)
    self:setNumImgForPanel("PricePanel", color, cash, false, LOCATE_POSITION.CENTER, 21, panel)
    panel:setVisible(true)

    panel:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:setOnTouchPet(item, sender)
        end
    end)


end

-- 获取传送位置
function PetShopDlg:getFlyPosition(mapName)
    local mapInfo =  MapMgr:getMapinfo()

    for k,v in pairs(mapInfo) do
        if v["map_name"] == mapName then
            return v["teleport_x"],v["teleport_y"]
        end
    end

    gf:ShowSmallTips(CHS[6000073])
end

function PetShopDlg:setOnTouchPet(item, sender)
    self:cleanSelectState()
    self:setCtrlVisible("ChosenEffectImage", true, sender)
    self.curSelectItem = item
end

function PetShopDlg:cleanMenuState()
    local items = self.catchListView:getItems()
    for k, v in pairs(items) do
        self:setCtrlVisible("ChosenEffectImage", false, v)
    end
end

function PetShopDlg:cleanSelectState()
    -- 清空当前listview选中状态
    local items = self.petListView:getItems()
    for k, v in pairs(items) do
        local leftPanel = self:getControl("LeftPetPanel", Const.UIPanel, v)
        self:setCtrlVisible("ChosenEffectImage", false, leftPanel)
        local rightPanel = self:getControl("RightPetPanel", Const.UIPanel, v)
        self:setCtrlVisible("ChosenEffectImage", false, rightPanel)
    end
end

-- 创建一个触摸层来响应touchmoved事件
function PetShopDlg:createTouchLayer()
    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

        touchPos = self.touchPanel:convertToNodeSpace(touchPos)

        if not self.touchPanel:isVisible() then
            return false
        end

        local box = self.touchPanel:getBoundingBox()
        if nil == box then
            return false
        end

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

        local box = self.touchPanel:getBoundingBox()

        if nil == box then
            return false
        end

        return true
    end


    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)
    -- 添加监听
    local dispatcher = self.touchPanel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self.touchPanel)
end
-- 打开窗口后选定宠物
function PetShopDlg:openSelect(level, name)
    local menuItems = self.catchListView:getItems()
    self:cleanMenuState()

    for k, v in pairs(menuItems) do
        local targetLevel = self:getLabelText("LevelLabel", v)

        if targetLevel == level then
            local realLevel = 1
            local pos = gf:findStrByByte(level, CHS[3003411])
            self:setCtrlVisible("ChosenEffectImage", true, v)
            if pos then
                level = string.sub(level, 1, pos - 1)
                realLevel = tonumber(level)
                self:showPetItemsByReqLevel(realLevel, name)
            end
        end

    end
end

function PetShopDlg:onMoneyAddButton(sender, eventType)
    gf:showBuyCash()
end

function PetShopDlg:onBuyButton(sender, eventType)
    if not self.curSelectItem then
        return
    end

    if TaskMgr:isExistNewPersonTasg() then
        gf:ShowSmallTips(CHS[3003413])
        return
    end

    local meCash = Me:queryBasicInt("cash")
    local costCash = self.curSelectItem.price

    -- 判断金钱、代金券是否足够
    local hasEnough = gf:checkCurMoneyEnough(costCash, function()
        gf:CmdToServer("CMD_EXCHANGE_GOODS", {
            type = 1,
            name = self.curSelectItem.name,
            amount = 1,
        })
    end)

    if not hasEnough then
        if nil == hasEnough then
            gf:askUserWhetherBuyCash(costCash - Me:queryInt("cash"))
        end

        return
    end

    gf:CmdToServer("CMD_EXCHANGE_GOODS", {
        type = 1,
        name = self.curSelectItem.name,
        amount = 1,
    })

    self:frozeButton("BuyButton")   -- 防止误触

end

-- 金钱响应
function PetShopDlg:onCashCheckBox(sender, eventType)
    if Me:queryBasicInt("use_money_type") == MONEY_TYPE.VOUCHER then return end

    gf:ShowSmallTips(CHS[3003414])
    self:VoucherCheckBox()
    CharMgr:setUseMoneyType(MONEY_TYPE.VOUCHER)
end

function PetShopDlg:CashCheckBox()
    local cash = Me:query("cash")
    self:setMoney(cash)
    --self.moneyRGroup:selectRadio(1, true)

    self:setCtrlVisible("CashPanel", true)
    self:setCtrlVisible("VoucherPanel", false)
    self:setCtrlVisible("MoneyAddButton", true)
    self:setCtrlVisible("TicketImage", false)
end

-- 代金券响应
function PetShopDlg:onVoucherCheckBox(sender, eventType)
    if Me:queryBasicInt("use_money_type") == MONEY_TYPE.CASH then return end
    gf:ShowSmallTips(CHS[3003415])

    self:CashCheckBox()
    CharMgr:setUseMoneyType(MONEY_TYPE.CASH)
end

function PetShopDlg:VoucherCheckBox()
    local voucher = Me:query("voucher")
    self:setMoney(voucher)

    self:setCtrlVisible("CashPanel", false)
    self:setCtrlVisible("VoucherPanel", true)
    self:setCtrlVisible("MoneyAddButton", false)
    self:setCtrlVisible("TicketImage", true)
end

-- 刷新金钱
function PetShopDlg:updateMoneyByAmount(money)
    money = tonumber(money)
    Log:D(">>>> money :" .. money)

    -- 拥有
    local cashPanel = self:getControl("HavePanel")
    local cash, color = gf:getMoneyDesc(money, true)
    self:setLabelText("HaveValueLabel", cash, cashPanel, color)
end

function PetShopDlg:updateMoney()
    local useMoneyType = Me:queryBasicInt("use_money_type")

    if useMoneyType == MONEY_TYPE.CASH then
        self:CashCheckBox()
    elseif useMoneyType == MONEY_TYPE.VOUCHER then
        self:VoucherCheckBox()
    end
end

function PetShopDlg:onCatchNoteButton(sender, eventType)
end

function PetShopDlg:onSelectCatchLevelListView(sender, eventType)
end

function PetShopDlg:onSelectPetListView(sender, eventType)

end

-- 打开界面需要某些参数需要重载这个函数
function PetShopDlg:onDlgOpened(param)
    self.openSelectParam = param
end

-- 监听数据是否已经同步
function PetShopDlg:onUpdate()
    if self.isUpateData and self.openSelectParam then
        self.isUpateData = false
        self:openSelect(self.openSelectParam[1],  self.openSelectParam[2])
        self.openSelectParam = nil
    end
end

return PetShopDlg
