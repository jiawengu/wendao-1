-- OreFunctionDlg.lua
-- Created by yangym Apr/14/2017
-- 矿石大战宝石使用界面


local OreFunctionDlg = Singleton("OreFunctionDlg", Dialog)

local BAOSHI = {
    CHS[7002266],
    CHS[7002267],
    CHS[7002268],
}

local QIANGLI_IMAGE = {
    [0] = ResMgr.ui.qiangli_word1,
    [1] = ResMgr.ui.qiangli_word2,
    [2] = ResMgr.ui.qiangli_word3,
    [3] = ResMgr.ui.qiangli_word4,
    [4] = ResMgr.ui.qiangli_word5,
    [5] = ResMgr.ui.qiangli_word6,
}

local QIANGLI_CIRCLE_IMAGE = {
    [1] = ResMgr.ui.qiangli_circlr1,
    [2] = ResMgr.ui.qiangli_circlr1,
    [3] = ResMgr.ui.qiangli_circlr2,
    [4] = ResMgr.ui.qiangli_circlr2,
    [5] = ResMgr.ui.qiangli_circlr3,
}

-- 倒计时类型（加速/虚隐），数值代表对应扇形进度条特效的tag
local COUNT_DOWN_TYPE = {
    jiasu = 888,
    xuyin = 999,
}

local COUNT_DOWN_FONT_SIZE = 23
local AMOUNT_FONT_SIZE = 17

function OreFunctionDlg:init()
    self:setFullScreen()
    self:bindListener("ShowButton", self.onShowButton)
    self:bindCtrlTouchListener()

    self:doInit()
    self:onShowButton()
    self:setBasicInfo()
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_BAOSHI_INFO")
end

function OreFunctionDlg:bindCtrlTouchListener()
    for i = 1, #BAOSHI do
        local itemPanel = self:getControl("ItemPanel", nil, "JewelPanel_" .. i)
        itemPanel:setTag(i)
        self:blindLongPress("ItemPanel", self.onOneSecondLater, self.onClick, "JewelPanel_" .. i)
    end
end

function OreFunctionDlg:doInit()
    for i = 1, #BAOSHI do
        self:setCtrlVisible("ChosenImage_1", false, "JewelPanel_" .. i)
        self:setCtrlVisible("ChosenImage_2", false, "JewelPanel_" .. i)
    end
end

-- 长按弹出道具名片
function OreFunctionDlg:onOneSecondLater(sender, eventType)
    local tag = sender:getTag()
    local itemName = BAOSHI[tag]
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(itemName, rect)
end

-- 单击使用道具
function OreFunctionDlg:onClick(sender, eventType)
    local tag = sender:getTag()
    local itemName = BAOSHI[tag]
    local amount = InventoryMgr:getAmountByName(itemName)
    if amount == 0 then
        gf:ShowSmallTips(CHS[7002269])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[8000005])
        return
    end

    local pos = InventoryMgr:getItemPosByName(itemName)
    InventoryMgr:applyItem(pos)
end

function OreFunctionDlg:setBasicInfo()
    for i = 1, #BAOSHI do
        local itemName = BAOSHI[i]
        local itemImage = self:getControl("ItemImage", nil, "JewelPanel_" .. i)
        self:setImage("ItemImage", InventoryMgr:getIconFileByName(itemName), "JewelPanel_" .. i)
        local amount = InventoryMgr:getAmountByName(itemName)

        -- 宝石数量
        if amount > 1 then
            self:setCtrlVisible("NumPanel", true, "JewelPanel_" .. i)
            self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.MID, AMOUNT_FONT_SIZE, "JewelPanel_" .. i)
        else
            self:setCtrlVisible("NumPanel", false, "JewelPanel_" .. i)
        end

        if amount == 0 then
            -- 没有可使用的宝石，置灰图标
            gf:grayImageView(itemImage)
        else
            gf:resetImageView(itemImage)
        end
    end
end

-- 倒计时相关（加速/虚隐）；加速/虚隐的光圈显示/隐藏也在此中（不包括强力）
function OreFunctionDlg:playCountDown(type, time)
    local panel
    if type == COUNT_DOWN_TYPE.jiasu then
        panel = self:getControl("ItemPanel", nil, "JewelPanel_1")
    elseif type == COUNT_DOWN_TYPE.xuyin then
        panel = self:getControl("ItemPanel", nil, "JewelPanel_2")
    end

    panel:removeChildByTag(type)
    panel:stopAllActions()

    -- 添加光圈效果
    self:setCtrlVisible("ChosenImage_1", true, panel)

    -- 扇形倒计时
    local progressTimer = cc.ProgressTimer:create(cc.Sprite:create(ResMgr.ui.ore_progress_timer))
    progressTimer:setReverseDirection(true)
    progressTimer:setTag(type)
    panel:addChild(progressTimer)

    local contentSize = panel:getContentSize()
    progressTimer:setPosition(contentSize.width / 2, contentSize.height / 2)

    progressTimer:setPercentage(100)
    local progressTo = cc.ProgressTo:create(time, 0)
    local endAction = cc.CallFunc:create(function()
        progressTimer:removeFromParent()

        -- 移除光圈
        self:setCtrlVisible("ChosenImage_1", false, panel)
    end)

    progressTimer:runAction(cc.Sequence:create(progressTo, endAction))

    -- 倒计时秒数显示
    local sec = time
    self:setCtrlVisible("TimePanel", true, panel)
    self:setNumImgForPanel("TimePanel", ART_FONT_COLOR.NORMAL_TEXT, sec, false, LOCATE_POSITION.MID, COUNT_DOWN_FONT_SIZE, panel)
    schedule(panel, function()
        sec = sec - 1
        if sec > 0 then
            self:setNumImgForPanel("TimePanel", ART_FONT_COLOR.NORMAL_TEXT, sec, false, LOCATE_POSITION.MID, COUNT_DOWN_FONT_SIZE, panel)
        else
            self:setCtrlVisible("TimePanel", false, panel)
            panel:stopAllActions()
        end
    end, 1)
end

function OreFunctionDlg:onShowButton()
    local dlg = DlgMgr:openDlg("GameFunctionDlg")
    dlg:onHideButton()
    self:setCtrlVisible("ShowButton", false)
    self:setCtrlVisible("FunctionPanel", true)
end

function OreFunctionDlg:onCloseButton()
    self:setCtrlVisible("ShowButton", true)
    self:setCtrlVisible("FunctionPanel", false)
end

function OreFunctionDlg:MSG_INVENTORY(data)
    self:setBasicInfo()
end

function OreFunctionDlg:MSG_BAOSHI_INFO(data)
    local nowTime = gf:getServerTime()

    -- 加速宝石
    local jiasuTime = data.jiasu
    if not self.data or self.data.jiasu ~= jiasuTime then
        if nowTime < jiasuTime then
            self:playCountDown(COUNT_DOWN_TYPE.jiasu, jiasuTime - nowTime)
        end
    end

    -- 虚隐宝石
    local xuyinTime = data.xuyin
    if not self.data or self.data.xuyin ~= xuyinTime then
        if nowTime < xuyinTime then
            self:playCountDown(COUNT_DOWN_TYPE.xuyin, xuyinTime - nowTime)
        end
    end

    -- 强力宝石
    local qiangliLevel = data.qiangli or 0

    -- 是否有强力宝石效果
    if qiangliLevel == 0 then
        self:setCtrlVisible("ChosenImage_1", false, "JewelPanel_3")
    else
        self:setCtrlVisible("ChosenImage_1", true, "JewelPanel_3")
    end

    -- 有几层强力宝石效果（光圈）
    if qiangliLevel >= 1 and qiangliLevel <= 5 then
        self:setImage("ChosenImage_1", QIANGLI_CIRCLE_IMAGE[qiangliLevel], "JewelPanel_3")
    end

    -- 有几层强力宝石效果（文字）
    if qiangliLevel >= 0 and qiangliLevel <= 5 then
        self:setImage("NameImage", QIANGLI_IMAGE[qiangliLevel], "JewelPanel_3")
    end

    self.data = data
end

return OreFunctionDlg