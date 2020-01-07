-- SmallTipDlg.lua
-- created by songcw Oct/16/2015
-- 角色头顶聊天泡泡

local HEIGHT_MARGIN = 10
local WIDTH_MARGIN = 12
local BACK_WIDTH = 600
local TIP_WIDTH = BACK_WIDTH - WIDTH_MARGIN * 2
local SHOW_OFFSET_Y = 100
local SHOW_DURATION = 1.2
local MOVE_DURATION = 0.25
local MOVE_TAG = 100

local GENERAL_WIDTH = 166
local POS4_WIDTH = 266      -- 战斗中用，位置为4的用这个。  位置从0开始

local List = require "core/List"
local PopUpDlg = Singleton("PopUpDlg", Dialog)

function PopUpDlg:open()
    self.root = cc.Layer:create()
    self.root:setLocalZOrder(Const.ZORDER_SMALLTIP)
    gf:getUILayer():addChild(self.root)
    self.list = List.new()
 --   self:align(ccui.RelativeAlign.centerInParent)
end

function PopUpDlg:generateTip(str, fightPos, isVip)
    -- 生成颜色字符串控件
    local tip = CGAColorTextList:create()
    tip:setFontSize(17)
    if isVip then
        tip:setString(str, isVip)
    else
        tip:setString(str)
    end
    if fightPos and fightPos == FightPosMgr.POS5 then
        tip:setContentSize(POS4_WIDTH - WIDTH_MARGIN * 2, 0)
    else
        tip:setContentSize(GENERAL_WIDTH - WIDTH_MARGIN * 2, 0)
    end

    tip:updateNow()
    local w, h = tip:getRealSize()
    local textOffset = 0;
    if 0 == w then
        -- 文本解析后为空串，则给一个空格大小
        textOffset = 4.25
    end
    
    tip:setPosition(WIDTH_MARGIN, HEIGHT_MARGIN + h)
    local layer = ccui.Layout:create()
    local arrow = ccui.ImageView:create(ResMgr.ui.talk_bubbles_arrow)
    -- arrow:setScale(0.5)
    layer:setContentSize(cc.size(w + (WIDTH_MARGIN * 2) + textOffset, h + HEIGHT_MARGIN * 2))

    if fightPos and fightPos == FightPosMgr.POS1 then
        arrow:setPosition(layer:getContentSize().width * 0.3, 0)
    else
        arrow:setPosition(layer:getContentSize().width * 0.5, 0)
    end
    
    layer:setBackGroundImage(ResMgr.ui.talk_bubbles)
    layer:setBackGroundImageCapInsets(Const.BUBBLE_CAPINSECT_RECT)
    layer:setBackGroundImageScale9Enabled(true)

    --    layer:setPosition(Const.WINSIZE.width/2, Const.WINSIZE.height/2 - SHOW_OFFSET_Y)
    layer:ignoreAnchorPointForPosition(false)
    layer:setAnchorPoint(0.5, 0)
    local colorLayer = tolua.cast(tip, "cc.LayerColor")
    colorLayer:setName("word")
    layer:addChild(colorLayer)
    layer:addChild(arrow)


    -- layer:scheduleUpdateWithPriorityLua(function() self:onUpdate() end, 0)

    return layer
end

function PopUpDlg:addTip(str, pos, isVip)
    if nil == str then return end
    local curTip = self:generateTip(str, pos, isVip)
    self.list:pushBack(curTip)
    return curTip
end



return PopUpDlg
