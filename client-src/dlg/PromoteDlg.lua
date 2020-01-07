-- PromoteDlg.lua
-- Created by liuyw July/16/2015
-- 提升界面

local PromoteDlg = Singleton("PromoteDlg", Dialog)

function PromoteDlg:init()
    self.promoteListPanel = self:getControl("PromoteListPanel", Const.UIPanel)
    self.promoteListView = self:getControl("SearchMatchListView", Const.UIListView)
    self.searchMatchUnitPanel = self:getControl("SearchMatchUnitPanel", Const.UIPanel)
    self.root:setAnchorPoint(0,0)
    -- 为"x"绑定点击事件
    self:bindListener("CloseItemButton", self.onCloseItem)              -- 绑定关闭按钮
    self:bindListener("SearchMatchUnitPanel", self.onItemPanel)         -- 绑定条目

    -- 为克隆做准备
    self.searchMatchUnitPanel:retain()
    self.searchMatchUnitPanel:removeFromParent()

    self:setPromoteList()   -- 设置列表项
end

-- 检查提升数据
function PromoteDlg:checkPromote()
    self.attrib_point = Me:queryInt("attrib_point")                     -- 获取剩余属性点数
    self.polar_point = Me:queryInt("polar_point")                       -- 获取剩余相性点数
    self.promotable_skillLevel_sum = SkillMgr:getMePromotableSkillSum() -- 获取可提升技能等级数

    self.guardCanBeExp = GuardMgr:getGuardCanBeExp()
end

function PromoteDlg:setPromoteList()
    -- 首先清空列表
    self.promoteListView:removeAllItems()
    local listInfo = PromoteMgr:getDisplayList()
    for i, info in pairs(listInfo) do
        local tempItemPanel = self.searchMatchUnitPanel:clone()         -- 添加人物加点
        tempItemPanel:setTag(info.tag)
        self:setLabelText("SearchMatchLabel", info.content, tempItemPanel)
        self.promoteListView:pushBackCustomItem(tempItemPanel)
    end
end

-- "x"点击事件（CloseItemButton）
function PromoteDlg:onCloseItem(sender, eventType)
    local tag = sender:getParent():getTag()
    self:removeByTag(tag)
end

--
function PromoteDlg:removeByTag(tag)
    self.promoteListView:removeChildByTag(tag, true)
    PromoteMgr:setPromoteTriggerByTag(tag, 0)

    -- 判断是否关闭对话框：条目全部清空
    if self.promoteListView:getChildrenCount() == 0 then
        -- 向SystemFunctionDlg发送隐藏提升按钮的消息
        DlgMgr:sendMsg("SystemFunctionDlg", "setPromoteButtonVisible", false)
        DlgMgr:closeDlg(self.name)
    end
end

-- 点击列表项事件(SearchMatchUnitPanel)
function PromoteDlg:onItemPanel(sender, eventType)
    local tag = sender:getTag()

    PromoteMgr:clickPromote(tag)
    self:onCloseButton()

end

function PromoteDlg:cleanup()
    self:releaseCloneCtrl("searchMatchUnitPanel")

	self.promoteListView = nil      -- 通知内存自动回收
	self.promoteListPanel = nil
	self.searchMatchUnitPanel = nil
end

return PromoteDlg