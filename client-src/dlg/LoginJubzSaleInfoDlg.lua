-- LoginJubzSaleInfoDlg.lua
-- Created by songcw Jan/10/2017
-- 登入界面中，显示玩家寄售信息界面

local LoginJubzSaleInfoDlg = Singleton("LoginJubzSaleInfoDlg", Dialog)

function LoginJubzSaleInfoDlg:init()
    self:bindListener("SellOperateButton", self.onSellOperateButton)

    self.data = nil
end

function LoginJubzSaleInfoDlg:setData(data, sender)
    self.data = data

    -- 头像
    self:setImage("HeadImage", ResMgr:getSmallPortrait(data.icon))
    self:setItemImageSize("HeadImage")

    -- 价格
    self:setLabelText("PriceLabel_2", data.trading_price)

    -- 状态
    local chs = TradingMgr:getTradingState(data.trading_state)
    self:setLabelText("StageLabel_2", chs)

    -- 时间
    if data.trading_left_time <= 0 or chs == CHS[4100413] then
        self:setLabelText("LeftTimeLabel_1", "")
        self:setLabelText("LeftTimeLabel_2", "")
    else
        self:setLabelText("LeftTimeLabel_2", TradingMgr:getLeftTime(data.trading_left_time))
    end

    -- dengji
    if  data.level ~= 0 then
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    local rect = self:getBoundingBoxInWorldSpace(sender)
    self:setDlgPosition(rect)
end

function LoginJubzSaleInfoDlg:setDlgPosition(rect)
    local x = (rect.x + 0)
    local y = rect.y
    local dlgSize = self.root:getContentSize()
    dlgSize.width = dlgSize.width * Const.UI_SCALE
    dlgSize.height = dlgSize.height * Const.UI_SCALE
    local ap = self.root:getAnchorPoint()
    self.root:setAnchorPoint(0,0)
    local posX, posY, isUp
    if x < Const.WINSIZE.width * 0.5 then
        if y > dlgSize.height then
            -- 触发控件下
            posX = rect.x
            posY = rect.y - dlgSize.height
            isUp = false
        else
            -- 触发控件在上
            posX = rect.x
            posY = rect.y + rect.height
            isUp = true
        end
    else
        if y > dlgSize.height then
            -- 触发控件在右上
            posX = rect.x
            posY = rect.y - dlgSize.height
            isUp = false
        else
            -- 触发控件在右下
            posX = rect.x
            posY = rect.y + rect.height
            isUp = true
        end
    end

    -- 上下限判断    超出上下限，20单位间隔
    if isUp then
        if (posY + dlgSize.height)  > Const.WINSIZE.height then
            -- 超出高度
            posY = (Const.WINSIZE.height - dlgSize.height - 20) * Const.UI_SCALE
        end
    else
        if posY < 0 then
            posY = 20 * Const.UI_SCALE
        end
    end
    self:setPosition(cc.p(posX, posY))
end

function LoginJubzSaleInfoDlg:cleanup()
end

function LoginJubzSaleInfoDlg:onSellOperateButton(sender, eventType)
    if not self.data then return end

    local loginListInfo = Client:getCharListInfo()
    if loginListInfo and loginListInfo.account_online > CHAR_ONLINE_STATE.CHAR_LIST_T_NONE then
        gf:ShowSmallTips(CHS[4100544])  -- 当前账号正在创建角色或有其他角色在游戏中，无法操作。
        return
    end

    local data = self.data
    if data.trading_state == TRADING_STATE.FROZEN then
        gf:ShowSmallTips(CHS[4100419])
        return
    elseif data.trading_state == TRADING_STATE.CLOSED then
        gf:ShowSmallTips(CHS[4100420])
        return
    elseif data.trading_state == TRADING_STATE.PAYMENT then
        gf:ShowSmallTips(CHS[4100420])
        return
    else
        -- 弹出 UserSellDlg界面
        TradingMgr:tradingSnapshot(data.trading_goods_gid, TRAD_SNAPSHOT.SNAPSHOT)
    end

    self:onCloseButton()
end

return LoginJubzSaleInfoDlg
