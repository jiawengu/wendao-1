-- TradingSpotItemInfoBasicDlg.lua
-- Created by lixh Des/26/2018
-- 商贾货站货品详情界面基类
-- 负责货站画折线图、历史涨跌、盈亏记录与对应CheckBox的响应
-- TradingSpotItemInfoDlg, TradingSpotShareItemDlg 继承此类，其他有类似需求的界面也应继承此类

local TradingSpotItemInfoBasicDlg = Singleton("TradingSpotItemInfoBasicDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

-- 界面数据类型
local DLG_DATA_TYPE = TradingSpotMgr:getDetailListTypeCfg()

-- 交易类型
local TRADING_STATUS = TradingSpotMgr:getTradingStatusCfg()

-- 折线图画笔配置
local LINE_CFG = {
    DOT_RADIUS = 4,      -- 圆半径
    WIDTH = 1.5,         -- 线宽
    COLOR = {r = 1, g = 0.45, b = 0.1, a = 1}, -- 颜色
    START_X = 73,        -- x 轴起始坐标
    MARGIN_X = 44,       -- x 轴坐标间隔
    HEIGHT_Y = 408,      -- y 轴高度
    LABEL_OFFSET_Y = 10, -- 坐标点上Label高度差
}

-- ListView分页加载数量
local PAGE_ADD_NUM = 20

function TradingSpotItemInfoBasicDlg:init(root)
    self.root = root

    self.radioGroup = RadioGroup.new()

    self.lineFloatPanel = self:getControl("RecentFloatPanel")
    self.historyFloatPanel = self:getControl("HistoryFloatPanel")
    self.profitRecordPanel = self:getControl("ProfitRecordPanel")

    self.historyListView = self:getControl("ItemsListView", nil, self.historyFloatPanel)
    self.historyItemPanel = self:retainCtrl("ItemsUnitPanel", nil, self.historyFloatPanel)

    self.profitListView = self:getControl("ItemsListView", nil, self.profitRecordPanel)
    self.profitItemPanel = self:retainCtrl("ItemsUnitPanel", nil, self.profitRecordPanel)

    self:bindListener("TurnLeftButton", self.onTurnLeftButton)
    self:bindListener("TurnRightButton", self.onTurnRightButton)

    self:updateTurnButtonShow()
end

-- 设置界面数据
function TradingSpotItemInfoBasicDlg:setData(data)
    if data.list_type ~= self.dlgType then return end

    self.lineFloatPanel:setVisible(false)
    self.historyFloatPanel:setVisible(false)
    self.profitRecordPanel:setVisible(false)
    if data.count > 0 then
        self:setCtrlVisible("NoticePanel", false)
    else
        -- 显示莲花姑娘
        self:setCtrlVisible("NoticePanel", true)
        if self.dlgType == DLG_DATA_TYPE.RANGE or self.dlgType == DLG_DATA_TYPE.LINE then
            self:setCtrlVisible("InfoPanel1", true, "NoticePanel")
            self:setCtrlVisible("InfoPanel2", false, "NoticePanel")
        elseif self.dlgType == DLG_DATA_TYPE.RECORD then
            self:setCtrlVisible("InfoPanel1", false, "NoticePanel")
            self:setCtrlVisible("InfoPanel2", true, "NoticePanel")
        end

        return
    end

    local listView
    local itemPanel
    local root
    if self.dlgType == DLG_DATA_TYPE.LINE then
        self.lineFloatPanel:setVisible(true)
        self:setLinePanel(data.rangeList)
        return
    elseif self.dlgType == DLG_DATA_TYPE.RANGE then
        root = self.historyFloatPanel
        self.historyFloatPanel:setVisible(true)
        listView = self.historyListView
        itemPanel = self.historyItemPanel
    else
        root = self.profitRecordPanel
        self.profitRecordPanel:setVisible(true)
        listView = self.profitListView
        itemPanel = self.profitItemPanel
    end

    listView:removeAllItems()

    -- 分页加载
    self.startNum = 0
    self.goodsListInfo = data
    self:bindListViewByPageLoad("ItemsListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 加载
            self:pushData()
        end
    end, root)

    -- 设置数据
    local sumProfit = 0
    local addCount = math.min(PAGE_ADD_NUM, data.count)
    for i = 1, data.count do
        if i <= addCount then
            local item = itemPanel:clone()
            self:setSingleItemInfo(item, data.list[i])

            self:setCtrlVisible("BackImage1", i % 2 ~= 0, item)
            self:setCtrlVisible("BackImage2", i % 2 == 0, item)

            listView:pushBackCustomItem(item)
        end

        sumProfit = sumProfit + (data.list[i].profit or 0)
    end

    self.startNum = self.startNum + addCount

    if self.dlgType == DLG_DATA_TYPE.RECORD then
        -- 盈亏记录需要显示累计盈亏
        local panel = self:getControl("AllProfitPanel", nil, self.profitRecordPanel)
        local allProfitStr, allProfitColor = TradingSpotMgr:getProfitTextInfo(sumProfit)
        self:setLabelText("NumLabel", allProfitStr, panel, allProfitColor)
    end
end

-- 分页加载增加数据显示
function TradingSpotItemInfoBasicDlg:pushData()
    local data = self.goodsListInfo
    local listView = self.historyListView
    local itemPanel = self.historyItemPanel
    if self.dlgType == DLG_DATA_TYPE.RECORD then
        listView = self.profitListView
        itemPanel = self.profitItemPanel
    end

    local endIndex = math.min(self.startNum + PAGE_ADD_NUM, data.count)
    if endIndex == self.startNum then return end

    for i = self.startNum + 1, endIndex do
        local item = itemPanel:clone()
        self:setSingleItemInfo(item, data.list[i])

        self:setCtrlVisible("BackImage1", i % 2 ~= 0, item)
        self:setCtrlVisible("BackImage2", i % 2 == 0, item)

        listView:pushBackCustomItem(item)
    end

    listView:refreshView()
    self:setListJumpItem(listView, self.startNum + 1)
    self.startNum = endIndex
end

-- 设置单个item数据
function TradingSpotItemInfoBasicDlg:setSingleItemInfo(panel, info)
    -- 期数
    self:setLabelText("TimeLabel", TradingSpotMgr:getTradingNoDes(info.trading_no), panel)

    if self.dlgType == DLG_DATA_TYPE.RANGE then
        -- 涨跌
        local upStr, _ = TradingSpotMgr:getPriceUpTextInfo(info.range)
        self:setLabelText("ValueLabel", upStr, panel)
        self:setLabelText("ValueLabel_1", upStr, panel)

        local greenProgress = self:getControl("ProgressBar1", nil, panel)
        local redProgress = self:getControl("ProgressBar2", nil, panel)
        greenProgress:setVisible(false)
        redProgress:setVisible(false)
        if info.range > 0 then
            redProgress:setVisible(true)
            redProgress:setPercent(info.range / 30)
        elseif info.range < 0 then
            greenProgress:setVisible(true)
            greenProgress:setPercent(-info.range / 30)
        end
    else
        -- 总额
        local allPriceDes, _ = gf:getMoneyDesc(math.floor(info.all_price), true)
        self:setLabelText("AllPriceLabel", allPriceDes, panel)

        -- 盈亏
        local profitStr, profitColor = TradingSpotMgr:getProfitTextInfo(info.profit)
        self:setLabelText("ProfitNumLabel", profitStr, panel, profitColor)
    end
end

-- 设置折线图
function TradingSpotItemInfoBasicDlg:setLinePanel(data)
    local pointCount = #data
    if pointCount <= 0 then return end

    -- y轴坐标
    local minY, maxY = data[1].percent, data[1].percent
    if pointCount == 1 then
        -- 点的数量为1时，设置y轴最大最小值
        minY, maxY = 70, 130
    end

    for i = 1, pointCount do
        if data[i] then
            minY = math.min(minY, data[i].percent)
            maxY = math.max(maxY, data[i].percent)
        end
    end

    minY = math.floor(minY / 10) * 10
    maxY = math.ceil(maxY / 10) * 10
    local stepY = (maxY - minY) / 10
    for i = 1, 11 do
        self:setLabelText("Label" .. i, (maxY - (i - 1) * stepY) .. "%", self.lineFloatPanel)
    end

    local labelPanel = self:getControl("DrawLabelPanel", nil, self.lineFloatPanel)
    if not self.pen then
        -- 创建画笔
        self.pen = cc.DrawNode:create()
        self.pen:setAnchorPoint(0.5, 0.5)
        self.pen:setBlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
        local antiAlisingShader = ShaderMgr:createAntiAliasingShader()
        if antiAlisingShader then
            self.pen:setGLProgramState(antiAlisingShader)
        end

        self.lineFloatPanel:addChild(self.pen)
    else
        self.pen:clear()
        labelPanel:removeAllChildren()
    end

    -- Y刻度高
    local startPercentY = minY - stepY / 2
    local percentHeight = maxY - minY + stepY

    -- 计算点坐标
    local posList = {}
    for i = 1, pointCount do
        local x = LINE_CFG.START_X + (i - 1) * LINE_CFG.MARGIN_X
        local y = math.floor(LINE_CFG.HEIGHT_Y * (data[i].percent - startPercentY) / percentHeight)
        table.insert(posList, cc.p(x, y))
    end

    -- 画点
    for i = 1, pointCount do
        if i > 1 and data[i].status ~= TRADING_STATUS.HALT then
            -- 从第2个点开始，非停盘的点，需要与上一个点连线
            self.pen:drawSegment(posList[i - 1], posList[i], LINE_CFG.WIDTH, LINE_CFG.COLOR)
        end
    end

    -- 画点
    for i = 1, pointCount do
        self.pen:drawDot(posList[i], LINE_CFG.DOT_RADIUS, LINE_CFG.COLOR)
    end

    -- 创建涨幅显示的Label
    for i = 1, pointCount do
        local labelPos = cc.p(posList[i].x, posList[i].y + LINE_CFG.LABEL_OFFSET_Y)
        local rangeDes, rangeColor = TradingSpotMgr:getPriceUpTextInfo(data[i].range)
        local label = self:createLineLabel(rangeColor, rangeDes, labelPos, "NumLabel" .. i)
        local bkLabel = self:createLineLabel(COLOR3.BLACK, rangeDes, labelPos, "BkNumLabel" .. i)
        bkLabel:setOpacity(153)
        labelPanel:addChild(bkLabel)
        labelPanel:addChild(label)
        if self:isLabelMixed(label, labelPanel:getChildByName("NumLabel" .. (i - 1))) then
            -- 与前一个label相交，则y坐标下移
            labelPos.y = labelPos.y - 2 * LINE_CFG.LABEL_OFFSET_Y
            label:setPosition(labelPos)
            bkLabel:setPosition(labelPos)
        end
    end
end

-- 创建折线图上方数字label
function TradingSpotItemInfoBasicDlg:createLineLabel(color, str, pos, name)
    local label = ccui.Text:create()
    label:setFontSize(17)
    label:setColor(color)
    label:setString(str)
    label:setPosition(pos)
    label:setName(name)
    return label
end

-- 判断两个Label是否相交
function TradingSpotItemInfoBasicDlg:isLabelMixed(label1, label2)
    if not label1 or not label2 then return false end

    local x1, y1 = label1:getPosition()
    local sz1 = label1:getContentSize()
    local x11, y11 = x1 - sz1.width / 2, y1 - sz1.height / 2
    local x12, y12 = x1 + sz1.width / 2, y1 + sz1.height / 2

    local x2, y2 = label2:getPosition()
    local sz2 = label2:getContentSize()
    local x21, y21 = x2 - sz2.width / 2, y2 - sz2.height / 2
    local x22, y22 = x2 + sz2.width / 2, y2 + sz2.height / 2

    if Formula:getRectOvelLapArea(x11, y11, x12, y12, x21, y21, x22, y22) > 0 then
        return true
    end

    return false
end

-- 切换界面数据：折线图，历史涨跌，盈亏记录
function TradingSpotItemInfoBasicDlg:onTypeCheckBox(sender, eventType)
    local name = sender:getName()
    local dlgType
    if name == "RecentFloatCheckBox" then
        dlgType = DLG_DATA_TYPE.LINE
    elseif name == "HistoryFloatCheckBox" then
        dlgType = DLG_DATA_TYPE.RANGE
    elseif name == "ProfitRecordCheckBox" then
        dlgType = DLG_DATA_TYPE.RECORD
    end

    if self.dlgType ~= dlgType then
        -- 请求界面数据
        self.dlgType = dlgType

        if dlgType == DLG_DATA_TYPE.RECORD and self.name == "TradingSpotShareItemDlg" then
            -- 名片界面用玩家名片的盈亏记录数据
            self:setData(TradingSpotMgr:getCharCardData())
        else
            TradingSpotMgr:requestOpenGoodsDetailDlg(self.goodsInfo.goods_id, self.dlgType)
        end
    end
end

-- 更新左右切换按钮的显示
function TradingSpotItemInfoBasicDlg:updateTurnButtonShow(goodsId)
    if self:getNextGoodsId(goodsId or self.goodsInfo.goods_id, true) then
        self:setCtrlVisible("TurnLeftButton", true)
    else
        self:setCtrlVisible("TurnLeftButton", false)
    end

    if self:getNextGoodsId(goodsId or self.goodsInfo.goods_id) then
        self:setCtrlVisible("TurnRightButton", true)
    else
        self:setCtrlVisible("TurnRightButton", false)
    end
end

-- 左切换货品
function TradingSpotItemInfoBasicDlg:onTurnLeftButton(sender, eventType)
    local goodsId = self:getNextGoodsId(self.goodsInfo.goods_id, true)
    if goodsId then
        if self.name == "TradingSpotShareItemDlg" then
            DlgMgr:sendMsg("TradingSpotSharePlanDlg", "requestItemInfo", goodsId)
        else
            TradingSpotMgr:requestOpenGoodsDetailDlg(goodsId, self.dlgType)
            self:setGoodsData(TradingSpotMgr:getGoodsInfoById(goodsId))
        end

        self:updateTurnButtonShow(goodsId)
    end
end

-- 右切换货品
function TradingSpotItemInfoBasicDlg:onTurnRightButton(sender, eventType)
    local goodsId = self:getNextGoodsId(self.goodsInfo.goods_id)
    if goodsId then
        if self.name == "TradingSpotShareItemDlg" then
            DlgMgr:sendMsg("TradingSpotSharePlanDlg", "requestItemInfo", goodsId)
        else
            TradingSpotMgr:requestOpenGoodsDetailDlg(goodsId, self.dlgType)
            self:setGoodsData(TradingSpotMgr:getGoodsInfoById(goodsId))
        end

        self:updateTurnButtonShow(goodsId)
    end
end

return TradingSpotItemInfoBasicDlg
