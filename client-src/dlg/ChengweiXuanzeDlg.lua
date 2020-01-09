-- ChengweiXuanzeDlg.lua
-- Created by cheny Dec/05/2014
-- 称谓选择界面

local ChengweiXuanzeDlg = Singleton("ChengweiXuanzeDlg", Dialog)
local MutexGroup = require("ctrl/MutexGroup")
local ITEM_HEIGHT = 45
local CHECK_OFFSET_X = 0
local LABEL_OFFSET_X = 50
local LIST_ITEM_MARGIN = 6
local LABEL_WORD_LIMIT = 24

local TAG_CHECK = 100
local TAG_LABEL = 101

local VIP_TITLE_CONTENT = {
    [CHS[6000202]] = 1,
    [CHS[6000203]] = 1,
    [CHS[6000204]] = 1,
    [CHS[3003805]] = 1,
    [CHS[3003807]] = 1,
    [CHS[3003809]] = 1,
}

local chengWeiData = {}

function ChengweiXuanzeDlg:init()
    self:bindListener("ConfirmButton", self.onConfrimButton)
    self.cellPanel = self:getControl("UnitPanel")
    self.cellPanel:retain()
    self.cellPanel:removeFromParent()
    self:getControl("TitleListView", Const.UIListView):removeAllItems()

    self.titleSource = self:getControl("TitleSourceLabel_1")
    self.titleSourceDetail = self:getControl("TitleSourceLabel_2")
    self.titleSourceDetailExtra = self:getControl("TitleSourceLabel_3")
    self.titleTime = self:getControl("TitleTimeLabel_1")
    self.titleTimeDetail = self:getControl("TitleTimeLabel_2")
    self.titleLabel = self:getControl("TitleLabel")

    self.titleTime:setVisible(false)
    self.titleTimeDetail:setVisible(false)

    self:getChengWeiData()

    self:initTitleList()
end

function ChengweiXuanzeDlg:initTitleList()
    self.mutexGroup = MutexGroup.new()

    local currentTitle = Me:queryBasic("title")

    local list = self:getControl("TitleListView", Const.UIListView)
    list:removeAllItems()
    list:setItemsMargin(LIST_ITEM_MARGIN)
    local scrollNumber  = 0

    -- 得到 title 的数量并将之放入控件中
    local titleNum = Me:queryBasicInt("title_num")

    if titleNum <= 1 then
        -- 当没有可选称谓时，列表界面、描述界面、装备按钮置为不可见
        self:getControl("NonePanel"):setVisible(true)
        self:getControl("ListPanel"):setVisible(false)
        self:getControl("DescriptionPanel"):setVisible(false)
        self:getControl("ConfirmButton"):setVisible(false)
        return
    end

    local noneCell = nil
    local flag = 0
    for i = 1, titleNum do
        -- 增加项
        local strTitle = Me:queryBasic(string.format("title%d", i))
        local strType = Me:queryBasic(string.format("type%d", i))
        local isCurrent = (currentTitle == strTitle)

        -- 如果当前角色称谓为无，则打开界面的默认项是“第一项称谓”
        if string.len(currentTitle) == 0 and  i == 1 then

            -- 若第一项称谓和当前称谓都为无，则默认项为下一项称谓
            if string.len(strTitle) == 0 then flag = 1 end
            isCurrent = true
            self.selectType = strType
            self.selectTitle = strTitle
        end

        if string.len(strTitle) == 0 then
            strTitle = CHS[34048]
            local cell = self:createTitleItem(strTitle, strType, false)
            noneCell = cell
        else
            local cell = self:createTitleItem(strTitle, strType, isCurrent)

            if flag == 1 then
                self.selectType = strType
                self.selectTitle = strTitle
                self:addSelcetImage(cell)
                flag = 0
            end

            list:pushBackCustomItem(cell)
        end

        if isCurrent then
            scrollNumber = i - 3

            if scrollNumber < 0 then
                scrollNumber = 0
            end
        end
    end

    -- 最后插入无单元格
    list:pushBackCustomItem(noneCell)

    local totoalOffset = list:getInnerContainer():getContentSize().height - list:getContentSize().height
    local posy =  scrollNumber * (self.cellPanel:getContentSize().height ) - totoalOffset

    if posy < 0 or currentTitle == "" then
        posy = 0
    end

    list:getInnerContainer():setPositionY(posy)
end

function ChengweiXuanzeDlg:selectByName(name)
    local scrollNumber  = 0
    local list = self:getControl("TitleListView", Const.UIListView)
    local items = list:getItems()
    for i, panel in pairs(items) do
        local title = self:getLabelText("NameLabel", panel)
        if title == name then
            scrollNumber = i
            if scrollNumber < 0 then
                scrollNumber = 0
            end
            
            self.selectTitle = title
            self:addSelcetImage(panel)
        end 
    end

    local totoalOffset = list:getInnerContainer():getContentSize().height - list:getContentSize().height
    local posy =  scrollNumber * (self.cellPanel:getContentSize().height ) - totoalOffset

    if posy < list:getContentSize().height or name == "" then
        posy = list:getContentSize().height - list:getInnerContainer():getContentSize().height
    end
    list:getInnerContainer():setPositionY(posy)
    -- 如果延迟一帧，则需要用下面的方法
--[[
    local scrollNumber  = 0
    local list = self:getControl("TitleListView", Const.UIListView)
    local items = list:getItems()
    for i, panel in pairs(items) do
        local title = self:getLabelText("NameLabel", panel)
        if title == name then
            scrollNumber = i
        end 
    end
    

    local totoalOffset = list:getInnerContainer():getContentSize().height - list:getContentSize().height
    local posy =  scrollNumber * (self.cellPanel:getContentSize().height )

    if posy < list:getContentSize().height or name == "" then
        posy = list:getContentSize().height - list:getInnerContainer():getContentSize().height
    end

    list:getInnerContainer():setPositionY(posy)
    --]]
end

function ChengweiXuanzeDlg:createCell()

end

function ChengweiXuanzeDlg:getChengWeiData()
    for i = 1, Me:queryBasicInt("title_num") do
        if Me:queryBasic(string.format("title%d", i)) == "" then
            chengWeiData[CHS[3001385]] = i
        else
            chengWeiData[Me:queryBasic(string.format("title%d", i))] = i
        end
    end
end

function ChengweiXuanzeDlg:isChengWeiExist(str)
    for i = 1, Me:queryBasicInt("title_num") do
        if Me:queryBasic(string.format("title%d", i)) == str then
            return true
        end
    end
    return false
end

function ChengweiXuanzeDlg:createTitleItem(title, type, selected)
    local cell = self.cellPanel:clone()
    local equippedImage = self:getControl("EquippedImage", Const.UIImage, cell)

    -- 称谓
    local name = self:getControl("NameLabel", Const.UILabel, cell)
    name:setVisible(true)
    name:setString(CharMgr:getChengweiShowName(title))
    cell:setName(type)

    if title ~= CHS[3001385] then
        name:setColor(CharMgr:getChengWeiColor(title))
    end

    if selected then
        self.selectTitle = title
        self:addSelcetImage(cell)

        if Me:queryBasic("title") ~= "" then
            equippedImage:setVisible(true)
        end
    end

    -- 如果当前角色称谓为“无”，则在“无”图标上显示“已装备”
    if Me:queryBasic("title") == "" and title == CHS[3001385] then
        equippedImage:setVisible(true)
    end

    cell:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.selectTitle = title
            self:addSelcetImage(cell)
        end
    end)

    cell:setName(type)

    return cell
end

function ChengweiXuanzeDlg:addSelcetImage(cell)

    local selectImg = self:getControl("SelectedImage", Const.UIImage, cell)

    -- 重置文本颜色
    self.titleLabel:setColor(COLOR3.TEXT_DEFAULT)
    self.titleTimeDetail:setColor(COLOR3.TEXT_DEFAULT)

    -- 重置文本
    self.titleSource:setText(CHS[7000023])
    self.titleSourceDetailExtra:setText("")

    -- 重置可显示label
    self.titleTime:setVisible(false)
    self.titleTimeDetail:setVisible(false)

    -- 添加选中效果
    if self.selectImg == nil then
        self.selectImg = selectImg
        selectImg:setVisible(true)
    else
        self.selectImg:setVisible(false)
        self.selectImg = selectImg
        selectImg:setVisible(true)
    end

    self.selectType = cell:getName()

    -- 称谓详细信息：标题
    self.titleLabel:setString(CharMgr:getChengweiShowName(self.selectTitle))
    if self.selectTitle ~= CHS[3001385] then
        self.titleLabel:setColor(CharMgr:getChengWeiColor(self.selectTitle))
    end

    -- 称谓详细信息：称谓来源
    if self.selectTitle ~= CHS[3001385] then
        local chengWeiResourceStr = CharMgr:getChenweiResource(self.selectTitle)
        self.titleSourceDetail:setString(chengWeiResourceStr)

        -- 若称谓来源超过第一行，则超出部分显示在第二行
        if gf:getTextLength(chengWeiResourceStr) > LABEL_WORD_LIMIT then
            local frontStr = gf:subString(chengWeiResourceStr, LABEL_WORD_LIMIT)
            self.titleSourceDetail:setString(tostring(frontStr))
            local strSplited = gf:split(chengWeiResourceStr, frontStr)
            self.titleSourceDetailExtra:setString(tostring(strSplited[2]))
        end

    else
        self.titleSource:setString(CHS[7000021])
        self.titleSourceDetail:setString(CHS[7000022])
    end

    -- 称谓详细信息：剩余时间
    local titleAllTimeStr = string.format("title%d_left_time", chengWeiData[self.selectTitle])
    local titleAllTime = Me:queryBasicInt(titleAllTimeStr)
    local flag = self.selectTitle ~= CHS[3001385] and not self:isChengWeiExist(self.selectTitle)
    
    
    if VIP_TITLE_CONTENT[self.selectTitle] then
        -- 位列仙班的称谓，剩余时间特殊处理        by:songcw    WDSY-23283
        local leftDays = Me:getVipLeftDays()        
        self.titleTimeDetail:setColor(COLOR3.RED)
        self.titleTimeDetail:setString(leftDays..CHS[3003185])
        self.titleTime:setVisible(true)
        self.titleTimeDetail:setVisible(true)    
    elseif titleAllTime ~= 0 or flag then
        -- flag为true，代表当前称谓已不存在，此时剩余时间仍然显示“一分钟”
        local titleLeftTime = titleAllTime - gf:getServerTime()

        local titleTimeStr = ""
        local day = math.floor(titleLeftTime / (24 * 3600))
        local hours = math.floor(titleLeftTime % (24 * 3600) / 3600)
        local minutes = math.floor((titleLeftTime % 3600) / 60)

        if day ~= 0 then
            titleTimeStr = titleTimeStr .. tostring(day) .. CHS[3002175]
        end

        if hours ~= 0 or day ~= 0 then
            titleTimeStr = titleTimeStr .. tostring(hours) .. CHS[3003115]
        end
        titleTimeStr = titleTimeStr .. tostring(minutes) .. CHS[3003116]

        if flag or titleLeftTime < 0 or (day == 0 and hours == 0 and minutes == 0) then
            titleTimeStr = CHS[3002941]
        end

        self.titleTimeDetail:setColor(COLOR3.RED)
        self.titleTimeDetail:setString(titleTimeStr)
        self.titleTime:setVisible(true)
        self.titleTimeDetail:setVisible(true)    
    end
    

    self:updateLayout("DescriptionPanel")
end

function ChengweiXuanzeDlg:onConfrimButton()

    -- 记录当前选择称谓的剩余时间
    local titleAllTimeStr = string.format("title%d_left_time", chengWeiData[self.selectTitle])
    local titleAllTime = Me:queryBasicInt(titleAllTimeStr)

    local titleLeftTime = titleAllTime
    if titleAllTime ~= 0 then
        titleLeftTime = titleAllTime - gf:getServerTime()
    end

    if self.selectType then
        gf:CmdToServer("CMD_CHANGE_TITLE", {
            select = self.selectType,
        })
    end

    DlgMgr:closeDlg(self.name)
end

function ChengweiXuanzeDlg:cleanup()
	self.selectType = nil
	self.selectTitle = nil
	self.selectImg = nil

    if self.cellPanel then
        self.cellPanel:release()
        self.cellPanel = nil
    end
end


return ChengweiXuanzeDlg
