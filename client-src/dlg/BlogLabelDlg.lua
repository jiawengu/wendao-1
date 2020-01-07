-- BlogLabelDlg.lua
-- Created by sujl, Sept/25/2017
-- 空间标签界面

local BlogLabelDlg = Singleton("BlogLabelDlg", Dialog)
local BLOG_TAGS = require("cfg/BlogTags")
local RadioGroup = require("ctrl/RadioGroup")

local START_COL = 10

function BlogLabelDlg:init(gid)
    self:bindListener("IconPanel", self.onClickPanel, "IconListPanel")
    self:bindListener("ConfirmButton", self.onConfirmButton)
    for i = 1, 4 do
        self:bindListener(string.format("IconPanel%d", i), self.onClickSelPanel, "ChosenIconPanel")
    end

    self.tagPanel = self:retainCtrl("IconPanel", "IconListPanel")
    self.scrollView = self:getControl("MemberScrollView", "IconListPanel")
    local isFirst = true
    local function onScrollView(sender, eventType)
        if ccui.ScrollviewEventType.scrolling == eventType then
            -- 获取控件
            local listViewCtrl = sender

            local listInnerContent = listViewCtrl:getInnerContainer()
            local innerSize = listInnerContent:getContentSize()
            local listViewSize = listViewCtrl:getContentSize()

            -- 计算滚动的百分比
            local totalHeight = innerSize.height - listViewSize.height

            local innerPosY = listInnerContent:getPositionY()
            local persent = 1 - (-innerPosY) / totalHeight

            if not isFirst then
                self:setCtrlVisible("UpImage", persent > 0 and innerSize.height > listViewSize.height, "MainPanel")
                self:setCtrlVisible("DownImage", persent < 1 and innerSize.height > listViewSize.height, "MainPanel")
            end
            isFirst = nil
        end
    end
    self.scrollView:addEventListener(onScrollView)

    self:getControl("IconListPanel"):removeFromParent()

    local tagStr = BlogMgr:getTagsByGid(gid)   
    self.curTags = gf:split(tagStr, "|")
    if self.curTags and 1 == #self.curTags and string.isNilOrEmpty(self.curTags[1]) then
        table.remove(self.curTags, 1)
    end
    self:refreshSelectList()
    
    self.gid = gid

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"TypeCheckBox1", "TypeCheckBox2", "TypeCheckBox3", "TypeCheckBox4", "TypeCheckBox5"}, self.onCheckbox, "TabPanel")
    self.radioGroup:selectRadio(1)
end

function BlogLabelDlg:hasTag(tagName)
    for i = 1, #self.curTags do
        if tonumber(self.curTags[i]) == tagName then
            return i
        end
    end
end

-- 刷新列表
function BlogLabelDlg:refreshList(tagType)
    local tags = BLOG_TAGS[tagType]
    if not tags then return end
    self.scrollView:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    contentLayer:setName("ContentLayer")
    local viewSize = self.scrollView:getContentSize()
    local panelSize = self.tagPanel:getContentSize()
    local col = math.floor((viewSize.width - START_COL * 2) / panelSize.width)
    local wm = (viewSize.width - START_COL * 2 - col * panelSize.width) / (col - 1)
    local lineInterval = 20
    local maxHeight = (panelSize.height + lineInterval) * math.floor(#tags / 5 + 0.5)

    local x, y = START_COL, maxHeight - panelSize.height - 10
    for i = 1, #tags do
        local item = self.tagPanel:clone()
        item.tagName = tags[i]
        item.tagIndex = self.typeIndex + i
        item:setPosition(x, y)
        contentLayer:addChild(item)
        x = x + wm + panelSize.width

        if 0 == i % col then
            x, y = START_COL, y - panelSize.height - lineInterval
        end

        self:setLabelText("PlayerNameLabel", tags[i], item)
        self:setCtrlVisible("ChosenBKImage", nil ~= self:hasTag(item.tagIndex), item)
    end

    contentLayer:setContentSize(cc.size(viewSize.width, maxHeight))
    self.scrollView:addChild(contentLayer)
    self.scrollView:setInnerContainerSize(contentLayer:getContentSize())
    self.scrollView:setTouchEnabled(true)

    self:setCtrlVisible("UpImage", false, "MainPanel")
    self:setCtrlVisible("DownImage", maxHeight > viewSize.height, "MainPanel")
end

-- 刷新选择标签
function BlogLabelDlg:refreshSelectList()
    for i = 1, #self.curTags do
        local panel = self:getControl(string.format("IconPanel%d", i), nil, "ChosenIconPanel")
        panel:setVisible(true)
        local tagIndex = self.curTags[i]
        local typeIndex = math.floor(tagIndex / 100)
        local labelIndex = tagIndex - typeIndex * 100
        local typeTags = BLOG_TAGS[BLOG_TAGS["type"][typeIndex]]
        if typeTags then
            self:setLabelText("PlayerNameLabel", typeTags[labelIndex], panel)
        end
    end

    for i = #self.curTags + 1, 4 do
        self:setCtrlVisible(string.format("IconPanel%d", i), false, "ChosenIconPanel")
    end

    self:setLabelText("NumLabel", string.format("%d/%d", #self.curTags, 4), "ChosenIconPanel")
end

function BlogLabelDlg:refreshListSel()
    local contentLayer = self.scrollView:getChildByName("ContentLayer")
    if not contentLayer then return end
    local children = contentLayer:getChildren()
    for i = 1, #children do
        local item = children[i]
        self:setCtrlVisible("ChosenBKImage", nil ~= self:hasTag(item.tagIndex), item)
    end
end

function BlogLabelDlg:onCheckbox(sender, eventType)
    local name = sender:getName()
    local tagType
    if "TypeCheckBox1" == name then
        tagType = CHS[2000448]
        self.typeIndex = 100
    elseif "TypeCheckBox2" == name then
        tagType = CHS[2000449]
        self.typeIndex = 200
    elseif "TypeCheckBox3" == name then
        tagType = CHS[2000450]
        self.typeIndex = 300
    elseif "TypeCheckBox4" == name then
        tagType = CHS[2000451]
        self.typeIndex = 400
    elseif "TypeCheckBox5" == name then
        tagType = CHS[2000452]
        self.typeIndex = 500
    end

    self:refreshList(tagType)
end

function BlogLabelDlg:onConfirmButton(sender, eventType)
    local tags = {}
    local tagStr = BlogMgr:getTagsByGid(self.gid)
    local hasTags = gf:split(tagStr, "|") or {}
    local hasNewTag = false
    for i, v in ipairs(self.curTags) do
        table.insert(tags, v)
        if not hasNewTag then
            if tostring(v) ~= hasTags[i] then
                hasNewTag = true
            end
        end
    end
    
    if hasNewTag or #hasTags ~= #self.curTags then
        gf:CmdToServer('CMD_BLOG_CHANGE_TAG', { tag = table.concat(tags, '|') })
        gf:ShowSmallTips(CHS[5400578])
    end
    
    self:onCloseButton()
end

-- 点击标签
function BlogLabelDlg:onClickPanel(sender, eventType)
    local tagIndex = sender.tagIndex
    local index = self:hasTag(tagIndex)
    if index then
        self:setCtrlVisible("ChosenBKImage", false, sender)
        local tagIndex = self.curTags[index]
        table.remove(self.curTags, index)
    else
        if #self.curTags >= 4 then
            gf:ShowSmallTips(CHS[2100118])
            return
        end
        self:setCtrlVisible("ChosenBKImage", true, sender)
        table.insert(self.curTags, tagIndex)
    end

    self:refreshSelectList()
end

function BlogLabelDlg:onClickSelPanel(sender, eventType)
    local senderName = sender:getName()
    local index = tonumber(string.match(senderName, "IconPanel(%d+)"))
    if index then
        local tagIndex = self.curTags[index]
        table.remove(self.curTags, index)
    end
    
    self:refreshSelectList()
    self:refreshListSel()
end

return BlogLabelDlg