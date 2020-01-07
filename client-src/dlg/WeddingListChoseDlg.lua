-- WeddingListChoseDlg.lua
-- Created by zhengjh Jun/20/2016
-- 结婚礼单选择界面

local WeddingListChoseDlg = Singleton("WeddingListChoseDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local COLUNM = 6
local SPACE = 3
local TOLAL_IDNEX = 30

local action_value =
    {
        ["qinqin"] = Const.SA_QINQIN,
        ["baibai"] = Const.SA_BAIBAI,
        ["yongbao"] = Const.SA_YONGBAO,
        ["jiaobei"] = Const.SA_JIAOBEI,
        ["walk"] = Const.SA_WALK,
    }

local radioType =
    {
        mustSelect = 1, -- 必选
        singleSelect = 2, -- 单选
        mulSelect = 3, -- 多选(可选)
    }

local weddingList =
    {
        ["基础"] = {
            {checkName = "", keyList = {"龙凤呈祥礼服"}, radioType = radioType.mustSelect},
            {checkName = "huajiaoGroup", keyList = {"4人抬花轿", "銮舆式花车", "象驮銮舆花车"}, radioType = radioType.singleSelect},
            {checkName = "yahuanGroup", keyList = { "1名丫鬟散花/钱", "2名丫鬟散花/钱"}, radioType = radioType.singleSelect},
            {checkName = "", keyList = {"背景音乐", "喇叭手", "敲锣手"}, radioType = radioType.mustSelect},
        },
        ["护卫"] = {
            {checkName = "", keyList = {"2名护牌手"}, radioType = radioType.mulSelect},
            {checkName = "guardGroup", keyList = {"朱雀护卫8名", "疆良护卫8名", "玄武护卫8名", "东山护卫8名", "朱雀护卫4名", "疆良护卫4名", "玄武护卫4名", "东山神灵护卫4名"}, radioType = radioType.singleSelect, needCancel = true},
        },
        ["祝词"] = {
            {checkName = "", keyList = {"月老祠许愿", "桃园意境", "三心聚合"}, radioType = radioType.mulSelect},
        },
        ["仪式"] = {
            {checkName = "", keyList = {"夫妻拜拜", "夫妻抱抱", "夫妻交杯", "夫妻亲亲", "30天洞房效果"}, radioType = radioType.mulSelect},
        },
        ["特效"] = {
            {checkName = "", keyList = {"夫妻同心光效", "特殊烟花效果", "全服光效效果"}, radioType = radioType.mulSelect},
        },
        ["佩饰"] = {
            {checkName = "", keyList = {"鸾凤宝玉"}, radioType = radioType.mulSelect},
        }
    }

local keyToGroup =
    {
        ["4人抬花轿"] = "huajiaoGroup",
        ["銮舆式花车"] = "huajiaoGroup",
        ["象驮銮舆花车"] = "huajiaoGroup",
        ["1名丫鬟散花/钱"] = "yahuanGroup",
        ["2名丫鬟散花/钱"] = "yahuanGroup",
        ["朱雀护卫8名"] = "guardGroup",
        ["疆良护卫8名"] = "guardGroup",
        ["玄武护卫8名"] = "guardGroup",
        ["东山护卫8名"] = "guardGroup",
        ["朱雀护卫4名"] = "guardGroup",
        ["疆良护卫4名"] = "guardGroup",
        ["玄武护卫4名"] = "guardGroup",
        ["东山神灵护卫4名"] = "guardGroup",
    }

local checkBoxToPanel =
    {
        ["BasicCheckBox"] = {"BasicListView", CHS[6400059]},
        ["GuardCheckBox"] = {"GuardListView", CHS[6400060]},
        ["WordsCheckBox"] = {"WordsListView", CHS[6400061]},
        ["EffectCheckBox"] = {"EffectListView", CHS[6400062]},
        ["CeremonyCheckBox"] = {"CeremonyListView", CHS[6400063]},
        ["BaldricCheckBox"] = {"BaldricListView", CHS[6400064]},
    }

-- checkBox 对应套餐名字
local typeCheckToKey =
    {
        ["TypeCheckBox_1"] = CHS[6400067],
        ["TypeCheckBox_2"] = CHS[6400068],
        ["TypeCheckBox_3"] = CHS[6400066],
    }

function WeddingListChoseDlg:init()
    self:bindListener("ConfrimButton", self.onConfrimButton)

    self.itemCell = self:getControl("ClonePanel")
    self.itemCell:retain()
    self.itemCell:removeFromParent()

    self.lineImage = self:getControl("CloneSeparateImage")
    self.lineImage:retain()
    self.lineImage:removeFromParent()

    local listView = self:getControl("ListView")
    self.imagePanel = self:getControl("ImagePanel", nil, listView)
    self.imagePanel:retain()
    self.imagePanel:removeFromParent()
    self.imagePanel:setScale(0.9)


    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"BasicCheckBox", "GuardCheckBox", "WordsCheckBox", "EffectCheckBox", "CeremonyCheckBox", "BaldricCheckBox",}, self.onCheckBox)
    self.radioGroup:selectRadio(1)

    self.typeGroup = RadioGroup.new()
    self.typeGroup:setItems(self, {"TypeCheckBox_1", "TypeCheckBox_2", "TypeCheckBox_3",}, self.onTypeCheckBox)
    self:setTestDistUI()
    self:initAllListInfo()
    self.selectWeddingList = {}
    self.typeGroup:selectRadio(3)
    self:setMyCoin()
    self:refreshShapePanel(CHS[6400073])

    self:hookMsg("MSG_WEDDING_ALL_LIST")
end

function WeddingListChoseDlg:setTestDistUI()
    if DistMgr:curIsTestDist() then
        self:setCtrlVisible("GoldCoinImage", false, self.itemCell)
        self:setCtrlVisible("SilverCoinImage", true, self.itemCell)
        local panel = self:getControl("GoldCoinPanel")
        self:setCtrlVisible("SilverCoinImage", true, panel)
        self:setCtrlVisible("GoldCoinImage", false, panel)
        local btn = self:getControl("ConfrimButton")
        self:setCtrlVisible("SilverCoinImage", true, btn)
        self:setCtrlVisible("GoldCoinImage", false, btn)
        self:setCtrlVisible("TestPanel", true)
        self:setCtrlVisible("GoldCoinPanel", false)
    else
        self:setCtrlVisible("GoldCoinImage", true, self.itemCell)
        self:setCtrlVisible("SilverCoinImage", false, self.itemCell)
        local panel = self:getControl("GoldCoinPanel")
        self:setCtrlVisible("SilverCoinImage", false, panel)
        self:setCtrlVisible("GoldCoinImage", true, panel)
        local btn = self:getControl("ConfrimButton")
        self:setCtrlVisible("SilverCoinImage", false, btn)
        self:setCtrlVisible("GoldCoinImage", true, btn)
        self:setCtrlVisible("TestPanel", false)
        self:setCtrlVisible("GoldCoinPanel", true)
    end
end

function WeddingListChoseDlg:setMyCoin()
    local goldPanel = self:getControl("TestGoldCoinPanel")
    local goldText = gf:getArtFontMoneyDesc(Me:queryBasicInt('gold_coin') or 0)
    self:setNumImgForPanel("GoldCoinValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23, goldPanel)

    local sliverPanel = self:getControl("SliverCoinPanel")
    local goldText = gf:getArtFontMoneyDesc(Me:queryBasicInt('silver_coin') or 0)
    self:setNumImgForPanel("GoldCoinValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23, sliverPanel)

    local goldPanel = self:getControl("GoldCoinPanel")
    local goldText = gf:getArtFontMoneyDesc(Me:queryBasicInt('gold_coin') or 0)
    self:setNumImgForPanel("GoldCoinValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23, goldPanel)
end

function WeddingListChoseDlg:initTypeInfo(key)
    local list = gf:deepCopy(MarryMgr:getOneWeddingMenuInfo(key).keyList)
    self.selectWeddingList = {}

    for i = 1, #list do
        if MarryMgr:isInSerVerList(list[i]) then -- 不显示服务器没发的列表
            table.insert(self.selectWeddingList, list[i])
        end
    end
    --self.selectWeddingList = list

    for i = 1, TOLAL_IDNEX do -- 取消原来选中
        local checkBox = self:getControl("CheckBox" .. i)
        if checkBox then
            checkBox:setSelectedState(false)
        end
    end

    for i = 1, #self.selectWeddingList do
        local info = MarryMgr:getOneWeddingMenuInfo(self.selectWeddingList[i])
        local checkBox = self:getControl("CheckBox" .. info.index or "")
        if checkBox then
            checkBox:setSelectedState(true)
        end
    end

    self:refreshSelectPanel()
end

function WeddingListChoseDlg:onTypeCheckBox(sender, type)
    local senderName = sender:getName()
    self:initTypeInfo(typeCheckToKey[senderName])
end

function WeddingListChoseDlg:onCheckBox(sender, type)
    local name = sender:getName()

    for k,v in pairs(checkBoxToPanel) do
        if k ~= name then
            self:setCtrlVisible(v[1], false)
        else
            self:setCtrlVisible(v[1], true)
        end
    end
end

function WeddingListChoseDlg:initAllListInfo()
    for k, v in pairs(checkBoxToPanel) do
        self:initList(v[1], weddingList[v[2]])
    end
end

function WeddingListChoseDlg:initList(listViewName, data)
    local listView = self:getControl(listViewName, data)
    listView:removeAllChildren()

    for i = 1, #data do
        local groupLayer = self:initGroup(data[i], listView)
        listView:pushBackCustomItem(groupLayer)

        if i ~= #data then
            listView:pushBackCustomItem(self.lineImage:clone())
        end
    end
end

-- 初值化每个组
function WeddingListChoseDlg:initGroup(data, listView)
    local groupItems = {}
    local groupLayer = ccui.Layout:create()

    local list = {}
    for i = 1, #data.keyList do
        if MarryMgr:isInSerVerList(data.keyList[i]) then -- 不显示服务器没发的列表
            table.insert(list, data.keyList[i])
        end
    end

    local count = #list
    local height = self.itemCell:getContentSize().height * count + (count -1) * SPACE
    for i = 1, #list do
        local key = list[i]
        local cell = self.itemCell:clone()
        cell:setName(key)
        cell:setAnchorPoint(0, 1)
        cell:setPosition(0, height)
        self:initCell(key, cell, groupItems, data.radioType)
        height = height - cell:getContentSize().height - SPACE
        groupLayer:addChild(cell)
    end

    groupLayer:setContentSize(self.itemCell:getContentSize().width, self.itemCell:getContentSize().height* count + (count -1) * SPACE)

    -- 单选互斥框
    if data.radioType == radioType.singleSelect then
        local checkBoxName = data.checkName
        self[checkBoxName] = RadioGroup.new()
        self[checkBoxName]:setItems(self, groupItems, self.onselectSingleGroup, groupLayer, self.onselectSameCheckBox)
    end

    return groupLayer
end

function WeddingListChoseDlg:initCell(key, cell, groupItems, type)
    local info = MarryMgr:getOneWeddingMenuInfo(key)
    if type == radioType.mustSelect then
        self:setCtrlVisible("ChosenImage", true, cell)
    elseif type == radioType.singleSelect then
        local checkBox = self:getControl("CheckBox_1", nil, cell)
        self:setCtrlVisible("CheckBox_1", true, cell)
        checkBox:setName("CheckBox"..info.index)
        table.insert(groupItems, checkBox:getName())
    elseif type == radioType.mulSelect then
        local checkBox = self:getControl("CheckBox", nil, cell)
        self:setCtrlVisible("CheckBox", true, cell)
        checkBox:setName("CheckBox"..info.index)

        local function checkBoxClick(self, sender , eventType)
            self:onselectMulGroup(sender, eventType)
        end
        
        self:bindCheckBoxWidgetListener(checkBox, checkBoxClick)
    end

    -- 设置头型
    local path, imageType = MarryMgr:getImagePath(key)
    self:setImage("Image", path, cell)
    if imageType == 1 then
        self:setItemImageSize("Image", cell)
    end

    -- 名字
    self:setLabelText("NameLabel", key, cell)

    -- 元宝
    local goldText = gf:getArtFontMoneyDesc(info.price or 0)
    self:setNumImgForPanel("CoinPanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.LEFT_BOTTOM, 21, cell)

    local key = key
    local function touchPanel(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            self:refreshShapePanel(key)
        end
    end

    local chosePanel = self:getControl("ChosePanel", nil, cell)
    chosePanel:addTouchEventListener(touchPanel)
end

function WeddingListChoseDlg:getImagePath(data)
    -- 设置头型
    local path
    if data.filePath == "portraits" then
        path = ResMgr:getSmallPortrait(data.icon)
    else
        path = data.icon
    end

    return path
end


function WeddingListChoseDlg:onselectSameCheckBox(sender, eventType)
    local key = sender:getParent():getName()
    local groupName = keyToGroup[key]
    if groupName == "guardGroup" then
        sender:setSelectedState(false)

        -- 清除单选之前选项
        for i = 1, #self.selectWeddingList do
            if groupName == keyToGroup[self.selectWeddingList[i]] then
                table.remove(self.selectWeddingList, i)
                break
            end
        end

        self:refreshSelectPanel()
    else
        gf:ShowSmallTips(CHS[6400065])
    end
end

function WeddingListChoseDlg:onselectSingleGroup(sender, eventType)
    local key = sender:getParent():getName()
    local groupName = keyToGroup[key]

    -- 清除单选之前选项
    for i = 1, #self.selectWeddingList do
        if groupName == keyToGroup[self.selectWeddingList[i]] then
            table.remove(self.selectWeddingList, i)
            break
        end
    end

    table.insert(self.selectWeddingList, key)

    self:refreshSelectPanel()
    self:refreshShapePanel(key)
end

function WeddingListChoseDlg:onselectMulGroup(sender, eventType)
    local key = sender:getParent():getName()
    local groupName = keyToGroup[key]
    if eventType == ccui.CheckBoxEventType.selected then
        table.insert(self.selectWeddingList, key)
    else
        for i = 1, #self.selectWeddingList do
            if key == self.selectWeddingList[i] then
                table.remove(self.selectWeddingList, i)
                break
            end
        end
    end

    self:refreshShapePanel(key)
    self:refreshSelectPanel()
end

function WeddingListChoseDlg:refreshSelectPanel()
    self:sortMyWeddingList()
    self:initMySelectList(self.selectWeddingList)
    self:refreshCoin()
end

function WeddingListChoseDlg:refreshCoin()
    local total = self:getTotalMoney() or 0
    local discount = MarryMgr.discount
    local confrimBtn = self:getControl("ConfrimButton")
    local goldText = gf:getArtFontMoneyDesc(total * discount)
    self:setNumImgForPanel("CoinPanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23, confrimBtn)


    if discount < 1 then
        self:setCtrlVisible("DiscountImage", true)
    else
        self:setCtrlVisible("DiscountImage", false)
    end
end

function WeddingListChoseDlg:getTotalMoney()
    local total = 0
    for i = 1, #self.selectWeddingList do
        local info = MarryMgr:getOneWeddingMenuInfo(self.selectWeddingList[i])
        total = total + info.price
    end

    return total
end

function WeddingListChoseDlg:refreshShapePanel(key)
    local shapePanel = self:getControl("ShapePanel")
    local info = MarryMgr:getOneWeddingMenuInfo(key)
    shapePanel:removeAllChildren()
    if info.magicType == "ui" then
        local path = info.magicIcon
        local image = ccui.ImageView:create(path)
        image:setPosition(shapePanel:getContentSize().width / 2, shapePanel:getContentSize().height / 2)
        shapePanel:addChild(image)
    elseif info.magicType == "charAction" then
        if key == CHS[6400072] then -- "4人抬花轿"  特殊处理
            self:setCtrlVisible("ShapePanel", false)
            self:setCtrlVisible("ShapePanel_1", true)
            self:setCtrlVisible("ShapePanel_2", true)
            self:setPortrait("ShapePanel_2", 42104, 0, nil, false, action_value[info.actionType], nil, nil, info.magicIcon, nil, 7)
            self:setPortrait("ShapePanel_1", 42105, 0, nil, false, action_value[info.actionType], nil, nil, info.magicIcon, nil, 7)
        else
            self:setCtrlVisible("ShapePanel_1", false)
            self:setCtrlVisible("ShapePanel_2", false)
            self:setCtrlVisible("ShapePanel", true)
            self:setPortrait("ShapePanel", info.magicIcon, 0, nil, false, action_value[info.actionType], nil, nil, info.magicIcon, nil, 7)
        end
    end
end



function WeddingListChoseDlg:sortMyWeddingList()
    if not self.selectWeddingList then return end

    local function sortList(l, r)
        local lInfo = MarryMgr:getOneWeddingMenuInfo(l)
        local rInfo = MarryMgr:getOneWeddingMenuInfo(r)
        return lInfo.index < rInfo.index
    end

    table.sort(self.selectWeddingList, sortList)
end

function WeddingListChoseDlg:initMySelectList(data)
    local panel = self:getControl("ListView")
    panel:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    local count = #data
    local cellColne = self.imagePanel:clone()
    local line = math.floor(count / COLUNM)
    local left =  count % COLUNM

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * cellColne:getBoundingBox().height + (line - 1) * SPACE

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = COLUNM
        end

        for j = 1, curColunm do
            local tag = j + (i - 1) * COLUNM
            local cell = cellColne:clone()
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * cell:getBoundingBox().width + (j -1 )* SPACE
            local y = totalHeight - ((i - 1) * cell:getBoundingBox().height + i * SPACE)
            cell:setPosition(x, y)
            self:setCellData(cell, data[tag])
            contentLayer:addChild(cell)
        end
    end

    contentLayer:setContentSize(panel:getContentSize().width, totalHeight)
    local scroview = ccui.ScrollView:create()
    scroview:setContentSize(panel:getContentSize())
    scroview:setDirection(ccui.ScrollViewDir.vertical)
    scroview:addChild(contentLayer)
    scroview:setInnerContainerSize(contentLayer:getContentSize())
    scroview:setTouchEnabled(true)
    scroview:setClippingEnabled(true)
    scroview:setBounceEnabled(true)

    if totalHeight < scroview:getContentSize().height then
        contentLayer:setPositionY(scroview:getContentSize().height  - totalHeight)
    end

    panel:addChild(scroview)

end

function WeddingListChoseDlg:setCellData(cell, data)
    local info = MarryMgr:getOneWeddingMenuInfo(data)
    -- 设置头型
    local path, imageType = MarryMgr:getImagePath(data)
    self:setImage("Image", path, cell)
    if imageType == 1 then
        self:setItemImageSize("Image", cell)
    end

    if info.number and info.number > 1 then
        self:setNumImgForPanel("ImagePanel", ART_FONT_COLOR.NORMAL_TEXT, info.number, false, LOCATE_POSITION.RIGHT_BOTTOM, 23, cell)
    end
end

function WeddingListChoseDlg:onConfrimButton(sende, eventType)

    -- 安全锁判断
    --[[ if self:checkSafeLockRelease("onConfrimButton") then
    return
    end]]

    --[[ local moneystr = ""
    if DistMgr:curIsTestDist() then
    moneystr = CHS[6400070]
    else
    moneystr = CHS[6400071]
    end

    local message = string.format(CHS[6400069], self:getTotalMoney(), moneystr)

    gf:confirm(message, function ()
    local list = ""
    for i = 1, #self.selectWeddingList do
    list = list .. self.selectWeddingList[i] .. ";"
    end

    MarryMgr:buyWeddingList(list)
    end, nil)]]

    local list = ""
    for i = 1, #self.selectWeddingList do
        list = list .. self.selectWeddingList[i] .. ";"
    end

    MarryMgr:buyWeddingList(list)
end

function WeddingListChoseDlg:MSG_WEDDING_ALL_LIST()
    self:refreshCoin()
end

function WeddingListChoseDlg:cleanup()
    self:releaseCloneCtrl("itemCell")
    self:releaseCloneCtrl("lineImage")
    self:releaseCloneCtrl("imagePanel")
end
return WeddingListChoseDlg
