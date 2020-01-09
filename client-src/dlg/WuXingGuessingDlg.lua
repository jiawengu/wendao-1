-- WuXingGuessingDlg.lua
-- Created by liuhb Apr/26/2016
-- 五行竞猜

local WuXingGuessingDlg = Singleton("WuXingGuessingDlg", Dialog)

local SHENGX_MAX = 12
local WUX_MAX = 5
local BET_CASH_MAX = 30000000

-- 五行对应的图片
local WUX_IMAGE = {
    [POLAR.METAL]  = ResMgr.ui.suit_polar_metal,
    [POLAR.WOOD]   = ResMgr.ui.suit_polar_wood,
    [POLAR.WATER]  = ResMgr.ui.suit_polar_water,
    [POLAR.FIRE]   = ResMgr.ui.suit_polar_fire,
    [POLAR.EARTH]  = ResMgr.ui.suit_polar_earth,
}

-- 生肖对应的图片
local SHENGX_IMAGE = {
    [SHENGX.SHU]  = ResMgr:getSmallPortrait(6179),
    [SHENGX.NIU]  = ResMgr:getSmallPortrait(6180),
    [SHENGX.HU]   = ResMgr:getSmallPortrait(6181),
    [SHENGX.TU]   = ResMgr:getSmallPortrait(6182),
    [SHENGX.LONG] = ResMgr:getSmallPortrait(6183),
    [SHENGX.SHE]  = ResMgr:getSmallPortrait(6184),
    [SHENGX.MA]   = ResMgr:getSmallPortrait(6185),
    [SHENGX.YANG] = ResMgr:getSmallPortrait(6186),
    [SHENGX.HOU]  = ResMgr:getSmallPortrait(6187),
    [SHENGX.JI]   = ResMgr:getSmallPortrait(6188),
    [SHENGX.GOU]  = ResMgr:getSmallPortrait(6177),
    [SHENGX.ZHU]  = ResMgr:getSmallPortrait(6178),
}

local wuxSelect = 0
local shengxSelect = 0
local betMoney = 0

local ready = false
local wuxResult = 0
local shengxResult = 0
local wuxStartPos = 0
local shengxStartPos = 0
local wuxCount = 0
local shengxCount = 0
local curWuxPos = 0
local curShengxPos = 0

local updateTime = 0
local delay = 20

function WuXingGuessingDlg:init()
    self:bindListener("GetMoneyButton", self.onGetMoneyButton)
    self:bindListener("StartButton", self.onStartButton)

    -- 数据初始化
    wuxSelect = 0
    shengxSelect = 0
    betMoney = 0
    ready = false

    -- 初始化按钮标签
    local sxIconPanel = self:getControl("ShengXiaoIconPanel")
    for i = 1, SHENGX_MAX do
        -- 生肖
        local ctrl = self:getControl("ShengXiaoButton" .. tostring(i))
        if ctrl then
            ctrl:setTag(i)
            self:bindTouchEndEventListener(ctrl, self.onShengXiaoButton)
        end

        self:setImage("Icon" .. i, SHENGX_IMAGE[i], sxIconPanel)

    end

    for i = 1, WUX_MAX do
        -- 五行
        local ctrl = self:getControl("WuXingButton" .. tostring(i))
        if ctrl then
            ctrl:setTag(i)
            self:bindTouchEndEventListener(ctrl, self.onWuXingButton)
        end
    end

    -- 添加数字键盘响应
    self:bindNumInput("BetMoneyPanel", nil, function()
        if GiftMgr:hasWuxGuessResult() then
            -- 有数据
            return true
        end

        return false
    end, "BetMoney")

    -- 绑定金元宝
    self:bindListener("MoneyPanel", function() gf:showBuyCash() end)

    self:setSelectSXVisible(false)

    -- 重置状态数据
    self:resetShengx()
    self:resetWux()
    self:updateMyCash()
    self:updateWuxCash()

    -- 设置选择为空
    self:updateSelect()

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_OPEN_GUESS_DIALOG")

    if GiftMgr:hasWuxGuessResult() then
        gf:ShowSmallTips(CHS[5100001])
        self:MSG_OPEN_GUESS_DIALOG({})
    end

    EventDispatcher:addEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)
end

function WuXingGuessingDlg:setSelectSXVisible(isVisible)
   local selectSXPanel = self:getControl("ShengXiaoBackImage")
   self:setCtrlVisible("ShengXiaoImage", isVisible, selectSXPanel)
   self:setCtrlVisible("BKImage", isVisible, selectSXPanel)


   self:setCtrlVisible("Image_160", isVisible, selectSXPanel)
   self:setCtrlVisible("BKImage_2", isVisible, selectSXPanel)
end

function WuXingGuessingDlg:cleanup()
    GiftMgr:releaseStartWux()
    EventDispatcher:removeEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)
end

-- 重置生肖状态
function WuXingGuessingDlg:resetShengx(noChoosen)
    for i = 1, SHENGX_MAX do
        -- 生肖
        local ctrl = self:getControl("ShengXiaoButton" .. tostring(i))
        if ctrl then
            if not noChoosen then
                self:setCtrlVisible("ChoosenImage", false, ctrl)
            end

            self:setCtrlVisible("RollImage", false, ctrl)
        end
    end
end

-- 重置五行状态
function WuXingGuessingDlg:resetWux(noChoosen)
    for i = 1, WUX_MAX do
        -- 生肖
        local ctrl = self:getControl("WuXingButton" .. tostring(i))
        if ctrl then
            if not noChoosen then
                self:setCtrlVisible("ChoosenImage", false, ctrl)
            end

            self:setCtrlVisible("RollImage", false, ctrl)
        end
    end
end

-- 设置选择状态
function WuXingGuessingDlg:setSelect(wux, shengx)
    wuxSelect = wux
    shengxSelect = shengx
    self:updateSelect()

    local shengxCtrl = self:getControl("ShengXiaoButton" .. shengxSelect)
    self:resetShengx()
    self:setCtrlVisible("ChoosenImage", true, shengxCtrl)

    local wuxCtrl = self:getControl("WuXingButton" .. wuxSelect)
    self:resetWux()
    self:setCtrlVisible("ChoosenImage", true, wuxCtrl)
end

-- 刷新选择
function WuXingGuessingDlg:updateSelect()
    local selectPanel = self:getControl("RightPanel")

    self:setSelectSXVisible(shengxSelect ~= 0)
    -- 生肖
    local shengxImgPath = SHENGX_IMAGE[shengxSelect]
    local shengxImage = self:getControl("ShengXiaoImage", nil, selectPanel)
    if shengxImgPath and shengxImage then
        shengxImage:loadTexture(shengxImgPath)
        shengxImage:setVisible(true)
    else
        shengxImage:setVisible(false)
    end

    -- 五行
    local wuxImgPath = WUX_IMAGE[wuxSelect]
    local wuxImage = self:getControl("WuXingImage", nil, selectPanel)
    if wuxImage and wuxImgPath then
        wuxImage:loadTexture(wuxImgPath, ccui.TextureResType.plistType)
        wuxImage:setVisible(true)
    else
        wuxImage:setVisible(false)
    end
end

-- 刷新身上金钱
function WuXingGuessingDlg:updateMyCash()
    local cash = Me:queryInt("cash")
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(cash))
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, self:getControl("MoneyPanel"))
end

-- 刷新五行存款
function WuXingGuessingDlg:updateWuxCash()
    local wuXData = GiftMgr:getWuxGuessData()
    local cash = 0

    -- 没有数据
    if not wuXData then
        cash = 0
    else
        if GiftMgr:hasWuxGuessResult() then
            cash = GiftMgr:getWuxGuessCash() - wuXData.money + wuXData.overflow
        else
            cash = GiftMgr:getWuxGuessCash()
        end
    end

    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(cash))
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, self:getControl("StoreMoneyPanel"))
end

-- 刷道下注金额
function WuXingGuessingDlg:updateBetCash(num)
    if num > 0 then
        local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(num))
        self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, self:getControl("BetMoneyPanel"))
        self:setCtrlVisible("Label", false, self:getControl("BetMoneyPanel"))
        self:setCtrlVisible("MoneyValuePanel", true, self:getControl("BetMoneyPanel"))
    else
        self:setCtrlVisible("Label", true, self:getControl("BetMoneyPanel"))
        self:setCtrlVisible("MoneyValuePanel", false, self:getControl("BetMoneyPanel"))
    end

    betMoney = num
    return num
end

-- 小键盘回调
function WuXingGuessingDlg:insertNumber(num, key)
    if "BetMoney" == key then
        if num > Me:queryInt("cash") or num >= BET_CASH_MAX then
            if Me:queryInt("cash") >= BET_CASH_MAX then
                gf:ShowSmallTips(CHS[5100002])
            else
                gf:ShowSmallTips(CHS[5100003])
            end

            num = math.min(Me:queryInt("cash"), BET_CASH_MAX)
        end

        self:updateBetCash(num)
        return num
    end
end

-- 生肖响应函数
function WuXingGuessingDlg:onShengXiaoButton(sender, eventType)
    if GiftMgr:hasWuxGuessResult() then
        -- 有数据
        return
    end


    self:resetShengx()
    self:setCtrlVisible("ChoosenImage", true, sender)
    shengxSelect = sender:getTag()
    self:updateSelect()
end

-- 五行响应函数
function WuXingGuessingDlg:onWuXingButton(sender, eventType)
    if GiftMgr:hasWuxGuessResult() then
        -- 有数据
        return
    end

    self:resetWux()
    self:setCtrlVisible("ChoosenImage", true, sender)
    wuxSelect = sender:getTag()
    self:updateSelect()
end

-- 取钱
function WuXingGuessingDlg:onGetMoneyButton(sender, eventType)
    if GiftMgr:hasWuxGuessResult() then
        -- 有数据
        gf:ShowSmallTips(CHS[5100004])
        return
    end

    if GameMgr.isAntiCheat then
        gf:ShowSmallTips(CHS[2000085])
        return
    end

    if 0 == GiftMgr:getWuxGuessCash() then
        gf:ShowSmallTips(CHS[5100005])
        return
    end

    if Me:queryInt("cash") >= 2000000000 then
        gf:ShowSmallTips(CHS[5100006])
        return
    end

    GiftMgr:requestGetWuxCash()
end

function WuXingGuessingDlg:onOpenDlgRequestData(sender, eventType)
    GiftMgr:startWuxGuess(0, 0, 0)
end

-- 开始
function WuXingGuessingDlg:onStartButton(sender, eventType)
    if GiftMgr:hasWuxGuessResult() then
        -- 有数据
        gf:ShowSmallTips(CHS[5100004])
        return
    end

    if GameMgr.isAntiCheat then
        gf:ShowSmallTips(CHS[2000085])
        return
    end

    local data = GiftMgr:getWuxGuessData()
    if not data then return end
    if data.leftCount <= 0 then
        gf:ShowSmallTips(CHS[4300056])
        return
    end

    if 0 == Me:queryInt("cash") then
        gf:askUserWhetherBuyCash()
        return
    end

    if 0 == wuxSelect then
        gf:ShowSmallTips(CHS[5100007])
        return
    end

    if 0 == shengxSelect then
        gf:ShowSmallTips(CHS[5100008])
        return
    end

    if GiftMgr:getWuxGuessCash() >= 20000000000 then
        gf:ShowSmallTips(CHS[5100019])
        return
    end

    if 0 == betMoney then
        gf:ShowSmallTips(CHS[5100009])
        return
    end

    if betMoney > Me:queryInt("cash") then
        gf:ShowSmallTips(CHS[5200000])
        return
    end

    if betMoney > 30000000 then
        local moneyStr = gf:getMoneyDesc(30000000)
        gf:ShowSmallTips(string.format(CHS[4300057], moneyStr))
        return
    end

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onStartButton", sender, eventType) then
        return
    end

    if not GiftMgr:canStartWux() then
        -- 上一次数据未返回
        gf:ShowSmallTips(CHS[5100004])
        return
    end

    if GiftMgr:getWuxGuessCash() >= 18000000000 then
        gf:confirm(CHS[5100010], function()
            GiftMgr:startWuxGuess(betMoney, wuxSelect, shengxSelect)
        end, function()
            GiftMgr:releaseStartWux()
        end)

        return
    end

    GiftMgr:startWuxGuess(betMoney, wuxSelect, shengxSelect)
end

-- 开始动画，准备数据
function WuXingGuessingDlg:startGuessAction()
    local wuXData = GiftMgr:getWuxGuessData()

    -- 没有数据
    if not wuXData then
        return
    end

    -- 结束位置
    wuxResult = wuXData.prize % 10
    shengxResult = math.floor(wuXData.prize / 10)

    -- 初始位置
    wuxStartPos = 1
    shengxStartPos = 1

    -- 需要转多少次
    wuxCount = wuxResult - wuxStartPos + math.random(4, 5) * WUX_MAX
    shengxCount = shengxResult - shengxStartPos + math.random(4, 5) * SHENGX_MAX

    -- 重置当前位置
    curWuxPos = 1
    curShengxPos = 1

    -- 重置间隔
    delay = 20

    ready = true

    self:resetWux(true)
    self:resetShengx(true)
end

-- 计算转圈间隔
function WuXingGuessingDlg:calcSpeed(curPos, count, type)
    if "shengxiao" == type then
        if count - curPos < 19 then
            -- 第一次减速
            return (19 - (count - curPos)) * 1
        end

        if count - curPos < 8 then
            -- 第二次减速
            return (8 - (count - curPos)) * 5
        end

        return 1
    elseif "wuxing" == type then
        if count - curPos < 15 then
            -- 第一次减速
            return (15 - (count - curPos)) * 1
        end

        if count - curPos < 9 then
            -- 第二次减速
            return (9 - (count - curPos)) * 4
        end

        return 3
    end
end

-- 开始转圈
function WuXingGuessingDlg:onUpdate()
    if not ready then
        -- 数据还没有准备好
        return
    end

    if updateTime % delay ~= 0 then
        updateTime = updateTime + 1
        return
    end


    -- 转起来
    if curWuxPos < wuxCount then
        -- 转五行
        delay = self:calcSpeed(curWuxPos, wuxCount, "wuxing")
        local wuxPos = math.floor((wuxStartPos + curWuxPos) % WUX_MAX) + 1
        local wuxCtrl = self:getControl("WuXingButton" .. wuxPos)
        local rollCtrl = self:getControl("RollImage", nil, wuxCtrl)
        rollCtrl:setVisible(true)
        rollCtrl:setOpacity(255)
        curWuxPos = curWuxPos + 1
        if curWuxPos ~= wuxCount then
            rollCtrl:runAction(cc.FadeOut:create(delay * 0.1))
        end
    elseif curShengxPos < shengxCount then
        -- 转生肖
        delay = self:calcSpeed(curShengxPos, shengxCount, "shengxiao")
        local shengxPos = math.floor((shengxStartPos + curShengxPos) % SHENGX_MAX) + 1
        local shengxCtrl = self:getControl("ShengXiaoButton" .. shengxPos)
        local rollCtrl = self:getControl("RollImage", nil, shengxCtrl)
        rollCtrl:setVisible(true)
        rollCtrl:setOpacity(255)
        curShengxPos = curShengxPos + 1
        if curShengxPos ~= shengxCount then
            rollCtrl:runAction(cc.FadeOut:create(delay * 0.1))
        end
    else
        local data = GiftMgr:getWuxGuessData()
        if data then
            ready = false

            -- 如果中奖，则弹出奖励界面
            if data.money > 0 then  -- 通过money字段来判断是否中奖
                local dlg = DlgMgr:openDlg("WuXingGuessingRewardDlg")
                local uiData = {}
                uiData.wuxResult = wuxResult
                uiData.wuxSelect = wuxSelect
                uiData.shengxResult = shengxResult
                uiData.shengxSelect = shengxSelect
                uiData.money = data.money
                dlg:setData(uiData)
            else
                gf:ShowSmallTips(CHS[5100011])
                local cashContent = gf:getMoneyDesc(tonumber(data.amount), true)
                local tipMsg = string.format(CHS[5100011], cashContent)
                ChatMgr:sendMiscMsg(tipMsg)
                self:finish()
            end
        end
    end

    -- 递增
    updateTime = 1
end

function WuXingGuessingDlg:finish(tipMsg)
    -- 结束
    GiftMgr:clearWuxGuessData()
    self:updateWuxCash()

    -- 给杂项
    if tipMsg then
        ChatMgr:sendMiscMsg(tipMsg)
    end

    local wuXData = GiftMgr:getWuxGuessData()
    if nil ~= wuXData.overflow and wuXData.overflow > 0 then
        local cashText = gf:getMoneyDesc(tonumber(wuXData.overflow))
        local msg = string.format(CHS[5200001], cashText)
        gf:ShowSmallTips(msg)
        ChatMgr:sendMiscMsg(msg)
    end
end

function WuXingGuessingDlg:MSG_UPDATE(data)
    self:updateMyCash()
end

function WuXingGuessingDlg:MSG_OPEN_GUESS_DIALOG(newData)
    local data = GiftMgr:getWuxGuessData()
    if newData.flag ~= 4 then
        -- flag 为 4 时只是刷新每天的次数
        if GiftMgr:hasWuxGuessResult() then
            -- 更新当前选择
            wuxSelect = data.choice % 10
            shengxSelect = math.floor(data.choice / 10)

            self:setSelect(wuxSelect, shengxSelect)
            self:updateBetCash(data.amount)
            self:startGuessAction()
        else
            self:updateWuxCash()
        end
    end

    -- 剩余次数
    self:setLabelText("RestTimesLabel", string.format(CHS[4300058], data.leftCount))
end

return WuXingGuessingDlg
