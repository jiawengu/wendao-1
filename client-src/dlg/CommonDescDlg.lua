-- CommonDescDlg.lua
-- Created by sujl, Apr/10/2017
-- 支持通用描述格式的描述性界面

local CommonDescDlg = Singleton("CommonDescDlg", Dialog)

local SliderPanel = require("ctrl/SliderPanel")

local FONTSIZE_TITLE = 25 -- 标题字体大小
local FONTSIZE_TEXT1 = 21 -- 一级文本字体大小
local FONTSIZE_TEXT2 = 19 -- 二级文本字体大小

-- layout 与  listView 左边距
-- 序号右对齐，序号数值超过一位时，要往左移，设置边距，避免往左移时，数值被裁减掉
-- 目前只能显示到百分位，多余会被裁减
local WIDTH_LEFT_MARGIN = 10

function CommonDescDlg:getTitleFontSize()
    return FONTSIZE_TITLE
end

function CommonDescDlg:getText1FontSize()
    return FONTSIZE_TEXT1
end

function CommonDescDlg:getText2FontSize()
    return FONTSIZE_TEXT2
end

function CommonDescDlg:getListView()
end

function CommonDescDlg:initContent(list, listViewName)
    local noticeList = list or {}

    listViewName = listViewName or self:getListView()
    assert(nil ~= listViewName, "ListViewName can't be nil")
    if not listViewName then return end

    local listView = self:getControl(listViewName)
    if #listView:getItems() ~= 0 then return end  -- 初值过了

    local contentLayer = ccui.Layout:create()
    local height = 0

    -- 计算文本序号和间距
    self:calTextNoAndInterval(noticeList)

    for i = #noticeList, 1, -1 do
        local layout = self:createLabelLayout(noticeList[i], height, i)
        height = height + layout:getContentSize().height
        contentLayer:addChild(layout)
    end

    contentLayer:setContentSize(listView:getContentSize().width, height)

    listView:pushBackCustomItem(contentLayer)

    local slierPanel = self:getControl("SliderPanel")
    local slider = SliderPanel.new(slierPanel:getContentSize(), listView)
    slierPanel:addChild(slider)

    local function listener(sender, eventType)
        if ccui.ScrollviewEventType.scrolling == eventType then
            slider:scrolling()
        end
    end

    listView:addScrollViewEventListener(listener)
end

-- 计算文本序号和间距
function CommonDescDlg:calTextNoAndInterval(noticeList)
    local textNo1 = 1
    local textNo2 = 1
    local fatherType = 1
    local flag = 0
    self.textNo = {}   -- 每条文本对应的序号，无序号为{}
    self.textInterval = {} -- 每条文本的上接间距

    local cou = #noticeList
    for i = 1, cou do
        self.textNo[i] = {}
        if noticeList[i]["K"] == "C" then
            if string.match(noticeList[i]["C"], "^# ") then
                -- 计算一级文本（# 开头）序号及上接间距
                self.textNo[i].noText = textNo1 .. ". "
                textNo1 = textNo1 + 1

                -- 二级序号重算
                textNo2 = 1

                fatherType = 1
                self.textInterval[i] = 8
            elseif string.match(noticeList[i]["C"], "^* ") then
                -- 计算一级文本（* 开头）序号及上接间距
                self.textNo[i].noText = ""

                -- 有序号的一级文本及二级序号重算
                textNo1 = 1
                textNo2 = 1

                fatherType = 2
                self.textInterval[i] = 8
            elseif string.match(noticeList[i]["C"], "^## ") then
                -- 计算二级文本序号及上接间距
                self.textNo[i].noText = " " .. string.char(textNo2 + 96) .. ". "
                if fatherType == 1 then
                    self.textNo[i].fatherNoText = (textNo1 - 1) .. ". "
                else
                    self.textNo[i].fatherNoText = "· "
                end

                textNo2 = textNo2 + 1

                self.textInterval[i] = 4
            else
                -- 计算标题上接间距
                self.textInterval[i] = 12

                if flag ~= 0 and noticeList[i]["isNewC"] then
                    -- 不同的更新内容间要空一行。
                    noticeList[i]["C"] =  " \n" .. noticeList[i]["C"]
                end

                if noticeList[i]["isNewC"] then
                    flag = 1
                end

                -- 断开，序号重算
                self.textNo[i] = {}
                textNo1 = 1
                textNo2 = 1
            end
        else
            self.textInterval[i] = 0
        end

        if noticeList[i]["K"] == "T" then
            flag = 0
        end
    end

    local lableNo = CGAColorTextList:create()
    lableNo:setFontSize(self:getText1FontSize())
    lableNo:setContentSize(self.listView:getContentSize().width - 10, 0)
    -- 获取序号单个数值时的文本宽度
    lableNo:setString("1. ")
    lableNo:updateNow()
    self.no1Width = lableNo:getRealSize()
end

function CommonDescDlg:createLabelLayout(content, posy, pos)
    local labelLayout = ccui.Layout:create()

    -- 一级文本
    local text1 = string.match(content["C"], "^# ")
    if not text1 then
        text1 = string.match(content["C"], "^* ")
    end

    -- 二级文本
    local text2 = string.match(content["C"], "^## ")

    -- 删除文本前的标识
    content["C"] = string.gsub(content["C"], "^# ", "")
    content["C"] = string.gsub(content["C"], "^## ", "")
    content["C"] = string.gsub(content["C"], "^* ", "")

    -- 文本内容
    local lableText = CGAColorTextList:create()
    lableText:setFontSize(self:getTitleFontSize())

    local indentW = 0 -- 缩进距离
    local lableNo
    local labelNoW, labelNoH = 0, 0 -- 文本序号宽高
    if (text1 or text2) and content["K"] == "C" then
        -- 文本序号
        lableNo = CGAColorTextList:create()
        lableNo:setFontSize(self:getTitleFontSize())
        lableNo:setContentSize(self.listView:getContentSize().width - 10, 0)
        lableNo:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)

        indentW = 20 -- 一、二级文本相对标题缩进距离
        if text1 then
            -- 一级文本序号
            lableNo:setFontSize(self:getText1FontSize())
            lableNo:setString(tostring(self.textNo[pos].noText))
            lableNo:updateNow()
            labelNoW, labelNoH = lableNo:getRealSize()

            -- 一级文本的缩进距离
            if text1 == "# " then
                -- 序号右对齐，所以数值超过一位数，序号整体要往左移
                indentW = indentW - (labelNoW - self.no1Width)
            end

            lableText:setFontSize(self:getText1FontSize())
        else
            -- 二级文本缩进距离
            if self.textNo[pos].fatherNoText ~= "· " then
                indentW = indentW + self.no1Width
            end

            -- 文本内容字体大小
            lableText:setFontSize(self:getText2FontSize())

            -- 二级文本序号
            lableNo:setFontSize(self:getText2FontSize())
            lableNo:setString(self.textNo[pos].noText)
            lableNo:updateNow()
            labelNoW, labelNoH = lableNo:getRealSize()
        end
    end


    if lableText.setPunctTypesetting then
        lableText:setPunctTypesetting(true)
    end

    lableText:setString(content["C"])

    -- 文本内容宽度 = listView 总宽度 - 缩进宽度 - 序号宽度 - 边距
    lableText:setContentSize(self.listView:getContentSize().width - 10 - indentW - labelNoW - WIDTH_LEFT_MARGIN, 0)
    lableText:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    lableText:updateNow()
    local labelW, labelH = lableText:getRealSize()

    if lableNo then
        lableNo:setPosition(indentW, labelH)
        labelLayout:addChild(tolua.cast(lableNo, "cc.LayerColor"))
    end

    lableText:setPosition(indentW + labelNoW, labelH)
    labelLayout:addChild(tolua.cast(lableText, "cc.LayerColor"))
    local posInfo = NoticeMgr:getContentPosAndAnchor(posy, self.listView:getContentSize().width, content)
    labelLayout:setContentSize(labelW - 10 + indentW + labelNoW - WIDTH_LEFT_MARGIN, labelH + self.textInterval[pos])
    labelLayout:setPosition(posInfo.position.x + WIDTH_LEFT_MARGIN, posy)
    labelLayout:setAnchorPoint(posInfo.anchorPoint)

    local function ctrlTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            if lableText:getCsType() == CONST_DATA.CS_TYPE_URL then
                gf:onCGAColorText(lableText, sender, nil, self.name)
            end
        end
    end

    labelLayout:setTouchEnabled(true)
    labelLayout:addTouchEventListener(ctrlTouch)

    return labelLayout
end

return CommonDescDlg