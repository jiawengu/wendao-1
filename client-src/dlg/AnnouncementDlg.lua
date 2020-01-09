-- AnnouncementDlg.lua
-- Created by zhengyz Nov/5/2015
-- 游戏公告

local MARGIN = 10
local BACK_WIDTH = 11600
local TIP_WIDTH = BACK_WIDTH - MARGIN*2
local i = 0                 -- 系统公告显示次数
local text_width            -- 实时显示控件规格的table
local MOVE = 2              -- 公告每帧移动的像素点（可控制公告文字移动速度）
local AnnouncementDlg = Singleton("AnnouncementDlg", Dialog)
local KEEP_TIME = 10        -- 每天公告保留十分钟
local actionTips = {}
local HORN_MAGIC_TAG = 999
local HORN_OFFSET_X = 68

local NORMAL_TIMES = 1      -- 正常滚动次数

-- 初始化，open对象后即调用
function AnnouncementDlg:init()
    self.blank:setLocalZOrder(-1)
    self.notePanel = self:getControl("NotePanel")
    self:addHornMagic()
end

-- 重载cleanup函数
function AnnouncementDlg:cleanup()
    self:removeHornMagic()
    self:cleanData()
end

-- 清除数据
function AnnouncementDlg:cleanData()
    local j
    for j=1, #actionTips do
        actionTips[j]:stopAllActions()
        actionTips[j]:removeFromParent(true)
    end
    actionTips = {}
end


-- 创建一个框把文字写进去，并把它添加到
function AnnouncementDlg:addTip(str)

    local tipCtrl = self:generateTip(str)
    tipCtrl.addTime = gf:getServerTime()
    local panelCtrl = self.notePanel -- 获取panel
    panelCtrl:addChild(tipCtrl) -- 添加一个控件
    table.insert(actionTips, tipCtrl)
end

-- 生成颜色字符串控件，并把字写进去
function AnnouncementDlg:generateTip(str)
    local tip = CGAColorTextList:create()                       -- 创建颜色字符串文本
    tip:setFontSize(20)                                         -- 设置字体大小
    tip:setString(str)
    tip:setContentSize(TIP_WIDTH, 0)                            -- 设置显示长度与宽度
    tip:updateNow()
    local w, h = tip:getRealSize()
    tip:setPosition(MARGIN, h + MARGIN)                         -- 设置字位置

    local panelCtrl = self.notePanel
    local layer = ccui.Layout:create()                          -- 创建控件
    layer:setContentSize(cc.size(w + MARGIN*2, h + MARGIN*2))   -- 设置控件的长宽
    layer:setPosition(panelCtrl:getContentSize().width, (30-(h + MARGIN*2))/2)        -- 设置控件位置
    layer:ignoreAnchorPointForPosition(false)
    layer:setAnchorPoint(0, 0)
    local colorLayer = tolua.cast(tip, "cc.LayerColor")
    colorLayer:setName("word")
    layer:addChild(colorLayer)
    return layer
end

-- 更新公告文字的位置
function AnnouncementDlg:onUpdate()
    if actionTips[1] == nil then return end
    text_width = actionTips[1]:getContentSize()
    if text_width == nil then return end

    -- 超过10分钟移除
    if gf:getServerTime() - actionTips[1].addTime > KEEP_TIME * 60 then
        actionTips[1]:removeFromParent(true)
        table.remove(actionTips, 1)
        i = 0
        if actionTips[1] == nil then
            AnnouncementDlg:close()
        end

        return
    end

  --  if Me:isInCombat() then return end

    local x, y = actionTips[1]:getPosition()
    local w = x - MOVE
    actionTips[1]:setPosition(w, y)
    if x < -text_width.width-MOVE*30 then
        local panelCtrl = self.notePanel
        actionTips[1]:setPosition(panelCtrl:getContentSize().width, actionTips[1]:getPositionY())
        i = i + 1
        if i == NORMAL_TIMES then
            actionTips[1]:removeFromParent(true)
            table.remove(actionTips, 1)
            i = 0
            if actionTips[1] == nil then
                AnnouncementDlg:close()
            end
        end
    end
end

-- 增加小喇叭特效
function AnnouncementDlg:addHornMagic()
    self:removeHornMagic()

    local root = self:getControl("MainPanel")
    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.announcement_horn.name)
    local rootSize = root:getContentSize()
    local pos = cc.p(HORN_OFFSET_X, rootSize.height / 2)
    magic:setPosition(pos)
    root:addChild(magic)
    magic:getAnimation():play(ResMgr.ArmatureMagic.announcement_horn.action)
    magic:setTag(HORN_MAGIC_TAG)
end

-- 移除小喇叭特效
function AnnouncementDlg:removeHornMagic()
    local panel = self:getControl("MainPanel")
    if not panel then return end
    local magic = panel:getChildByTag(HORN_MAGIC_TAG)
    if magic then
        magic:removeFromParent()
        magic = nil
    end
end

return AnnouncementDlg
