-- ExpressionDlg.lua
-- Created by zhengjh Feb/13/2015
-- 表情选择框 

local MALE = "1"
local FEMALE = "2"

local CONST_DATA = 
{
  ExpressionNumber = 92,  -- 表情总的个数
  ExpressionFrameNumber = 10,  -- 每个表情最多的帧数
  ExpressSpace = 0,     -- 每个表情的列间距   
  ExpressLineSapce = 0, -- 每个表情的行
  LineNumber = 4,
  ColumnNumber = 12,
}

local historyExpress = 
{
}

-- 没分性别的表情
local EXPRESSION_CONFIG =
{
    [5] = 5,
    [6] = 6,
    [9] = 9,
    [10] = 10,
    [11] = 11,
    [12] = 12,
    [13] = 13,
    [16] = 16,
    [18] = 18,
    [19] = 19,
    [20] = 20,
    [22] = 22,
    [26] = 26,
    [27] = 27,
    [30] = 30,
    [31] = 31,
    [33] = 33,
    [37] = 37,
    [39] = 39,
    [40] = 40,
    [48] = 48,
    [51] = 51,
    [57] = 57,
    [65] = 65,
    [67] = 67,
    [70] = 70,
    [77] = 77,
    [82] = 82,
    [84] = 84,
    [85] = 85,
    [90] = 90,    
}

local ExpressionDlg = Singleton("ExpressionDlg", Dialog)

function ExpressionDlg:init()
    self:bindListener("PageButton", self.onPageButton)
    self:bindListener("WordButton", self.onWordButton)
    self:bindListener("HistoryButton", self.onHistoryButton)
    self:bindListener("ExpressionButton", self.onExpressionButton)
    self:bindListener("SpaceButton", self.onSpaceButton)
    self:bindListener("DelButton", self.onDelButton)
    self:bindListener("LinkButton", self.onLinkButton)
    self:bindListener("SendButton", self.onSendButton)
    self.root:setAnchorPoint(0,0)
    self.root:setPosition(0,0)
    
    self.pageView = self:getControl("ExpressPageView", Const.UIPageView) 
    self.ExpressHeight = math.floor((self.pageView:getContentSize().height - CONST_DATA.ExpressLineSapce * CONST_DATA.LineNumber) / CONST_DATA.LineNumber )
    self.ExpressWidth =  math.floor((self.pageView:getContentSize().width - CONST_DATA.ExpressSpace * CONST_DATA.ColumnNumber) / CONST_DATA.ColumnNumber )
    
    self:onExpressionButton()
    self.pageView:scrollToPage(0)  
end

-- 创建页面
function ExpressionDlg:createPages(dataTable)
    local expressionNumber = #dataTable + 1
    local pageNumber = math.floor(expressionNumber / (CONST_DATA.ColumnNumber * CONST_DATA.LineNumber)) + 1
    local pageLeft = expressionNumber % (CONST_DATA.ColumnNumber * CONST_DATA.LineNumber)
    local curPageContainNumber = 0
    for z = 1, pageNumber do
        if pageNumber  == z then 
            curPageContainNumber = pageLeft
        else
            curPageContainNumber = CONST_DATA.ColumnNumber * CONST_DATA.LineNumber
        end
        local page = ccui.Layout:create()
        page:setContentSize(self.pageView:getContentSize())
        local line = math.floor( curPageContainNumber / CONST_DATA.ColumnNumber)
        local left = curPageContainNumber % CONST_DATA.ColumnNumber
        local lineCount = 0
        for i = 0, line do
            if i == line then
                lineCount = left
            else
                lineCount = CONST_DATA.ColumnNumber
            end
            for j = 0, lineCount-1 do
                local data = dataTable[CONST_DATA.ColumnNumber*i+j + (z - 1)* CONST_DATA.ColumnNumber * CONST_DATA.LineNumber]
                if nil ~= data then
                    local layoutSprite = self:createOneExpression(dataTable[CONST_DATA.ColumnNumber*i+j + (z - 1)* CONST_DATA.ColumnNumber * CONST_DATA.LineNumber])
                    layoutSprite:setPosition(j*(self.ExpressWidth+CONST_DATA.ExpressSpace), page:getContentSize().height-i*(self.ExpressHeight + CONST_DATA.ExpressLineSapce))
                    page:addChild(layoutSprite)
                end
            end
        end
        self.pageView:addPage(page)
    end
end

function ExpressionDlg:createOneExpression(fileName)
    
    local historyFile = fileName
    if EXPRESSION_CONFIG[fileName] == nil then
        if Me:queryBasic("gender") == FEMALE then
            fileName = fileName.."f"
        elseif Me:queryBasic("gender") == MALE then
            fileName = fileName.."m"
        end
    end
    
    local filePath = "brow/"..fileName
    gfAddFrames(filePath .. ".plist", filePath .. "/");

    -- 创建帧动画
    local animation =  cc.Animation:create()
    animation:setDelayPerUnit(0.5)
    for i = 0,CONST_DATA.ExpressionFrameNumber do 
        local framName = string.format("%s/%05d",filePath,i)
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framName)
        if  not frame then
            break
        end
        animation:addSpriteFrame(frame)
    end
    -- 创建动作

    local animate = cc.Animate:create(animation)
    local sprite =  cc.Sprite:create()
    local repeatAction = cc.RepeatForever:create(animate)
    sprite:runAction(repeatAction)
    sprite:setAnchorPoint(0.5,0.5)
    sprite:setPosition(self.ExpressWidth/2,self.ExpressHeight/2)
    animate:update(0)

    local layout = ccui.Layout:create()
    layout:setContentSize(self.ExpressWidth,self.ExpressHeight)
    layout:setTouchEnabled(true)
    layout:setAnchorPoint(0,1)
    layout:addChild(sprite)
    local function imgTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            self:callBack("addExpression", "#"..fileName)
            historyExpress[fileName] = historyFile
        end
    end
    layout:addTouchEventListener(imgTouch)
    
    return layout
end

-- 回调对象
function ExpressionDlg:setCallObj(obj)
    self.obj = nil
	self.obj = obj 
end

-- 调用回调方法
function ExpressionDlg:callBack(funcName, ...)
	local func = self.obj[funcName]
	if self.obj and func then
	   func(self.obj, ...)
	end 
end

function ExpressionDlg:onPageButton(sender, eventType)
end

function ExpressionDlg:onWordButton(sender, eventType)
    DlgMgr:closeDlg("ExpressionDlg")
    self:callBack("swichWordInput")
    
end

function ExpressionDlg:onHistoryButton(sender, eventType)
    self.pageView:removeAllPages()
    local sortTable = {}
    local l = 0
    
    for k,v in pairs(historyExpress) do
        sortTable[l] = v
        l = l + 1
    end
    
   self:createPages(sortTable)
end

function ExpressionDlg:onExpressionButton(sender, eventType)
    self.pageView:removeAllPages()
    local sortTable = {}
    local l = 0
    
    for i = 0, CONST_DATA.ExpressionNumber-1 do
        sortTable[i] = i
    end
    
    self:createPages(sortTable)
end

function ExpressionDlg:onSpaceButton(sender, eventType)
    self:callBack("addSpace")
end

function ExpressionDlg:onDelButton(sender, eventType)
    self:callBack("deleteWord")
end

function ExpressionDlg:onLinkButton(sender, eventType)
end

function ExpressionDlg:onSendButton(sender, eventType)
    self:callBack("sendMessage")
end

return ExpressionDlg
