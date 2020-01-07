-- GuardListChildDlg.lua
-- Created by liuhb Jan/29/2015
-- 创建守护列表

local ITEM_HEIGHT = 80

local GuardListChildDlg = Singleton("GuardListChildDlg", Dialog)
local MARGIN = 6

function GuardListChildDlg:init()
    self.selectName = nil
    self.selectImg = nil
    self.guardPanel = nil
    self.advanceGuardId = nil

    self.firstCall = nil
    self.firstAdvanced = nil
    
    self.guardPanels = {}

    -- 缓存守护列表条目
    self.guardPanel = self:getControl("GuardPanel")
    self.guardPanel:retain()

    self:initGuardList()
    self:hookMsg("MSG_GUARDS_REFRESH")
    self:hookMsg("MSG_LEADER_COMBAT_GUARD")
    self:hookMsg("MSG_GUARD_EXPERIENCE_ID")

    -- 请求正在历练的守护的id
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REQUEST_GUARD_ID)
end

function GuardListChildDlg:cleanup()
    if nil ~= self.guardPanel then
        self.guardPanel:release()
        self.guardPanel = nil
    end

    if nil ~= self.selectImg then
        self.selectImg:release()
        self.selectImg = nil
    end
    
    for _, v in ipairs(self.guardPanels) do
        if v then
            v:release()
        end
    end
    
    self.guardPanels = {}
end

-- 参战和辅助状态的守护在列表最上方，之下为休息状态的守护
-- 各状态内部按照长老、弟子、童子的阶位顺序从上往下排列
-- 各阶位内部按照金木水火土的顺序由上往下排列
function GuardListChildDlg:sortFunc(l, r)
    -- 排序逻辑
    if l.combat_guard > r.combat_guard then
        return true
    elseif l.combat_guard < r.combat_guard then
        return false
    end

    if 1 == l.combat_guard then
        if l.combat_index < r.combat_index then
            return true
        elseif l.combat_index > r.combat_index then
            return false
        end
    end

    if l.has > r.has then
        return true
    elseif l.has < r.has then
        return false
    end

    if l.rank < r.rank then
        return true
    elseif l.rank > r.rank then
        return false
    end

    if gf:getIntPolar(l.polarStr) < gf:getIntPolar(r.polarStr) then
        return true
    else
        return false
    end
end

function GuardListChildDlg:initGuardList()
    -- 移除选择框
    self:getSelectImg():removeFromParent(false)

    -- 重置守护列表
    local list, size = self:resetListView("GuardListView", MARGIN)
    self.guardList = list
    self.guardListSize = size

    -- 获取守护列表
    local guardInfos = GuardMgr:getAllGuard(Me:queryInt("level"))
    if nil == guardInfos then
        return
    end

    -- 刷新列表
    self:reflashList(guardInfos)
end

function GuardListChildDlg:reflashList(guardInfos)
    -- 排序规则
    local function sort(l, r)
        return self:sortFunc(l, r)
    end

    -- 分别对参战与休息状态的守护进行排序
    table.sort(guardInfos, sort)

    -- 存储列表信息
    self.guardInfos = guardInfos

    local list, size = self:resetListView("GuardListView", MARGIN)
    local defaultSelectName = 0
    if 0 ~= #guardInfos then
        defaultSelectName = guardInfos[1].raw_name
    end

    local selectName = 0
    if not self.selectName then
        selectName = defaultSelectName
    else
        selectName = self.selectName
    end

    -- 循环进行listView条目的创建
    for i = 1, #guardInfos do
        list:pushBackCustomItem(self:createGuardItem(guardInfos[i], selectName == guardInfos[i].raw_name, i))
    end
end

function GuardListChildDlg:selectGuard(sender, eventType)
    if ccui.TouchEventType.ended == eventType then
        local img = self:getSelectImg()
        img:removeFromParent(false)
        sender:addChild(img)

        -- 如果id为0则表示不存在此守护
        self.selectName = sender.raw_name

        -- 添加需要刷新的窗口
        DlgMgr:sendMsg("GuardAttribDlg", "setGuardInfo", self.selectName)
    end
end

function GuardListChildDlg:createGuardItem(guardInfo, select, index)
    if nil == self.guardPanel then
        return
    end

    -- 创建item
    local itemPanel
    if self.guardPanels[index] then
        itemPanel = self.guardPanels[index]
    else
        itemPanel = self.guardPanel:clone()
        itemPanel:retain()
        table.insert(self.guardPanels, itemPanel)
    end
    
    itemPanel.raw_name = guardInfo.raw_name
    -- 添加点击监听事件，默认单点
    itemPanel:setTouchEnabled(true)
    self:bindTouchEndEventListener(itemPanel, self.selectGuard)

    -- 首先将Icon、守护名称、等级添加到条目中
    -- 添加图标
    local imgPath = ResMgr:getSmallPortrait(guardInfo.icon)
    self:setImage("GuardImage", imgPath, itemPanel)
    self:setItemImageSize("GuardImage", itemPanel)
    
    local polarPath = ResMgr:getPolarImagePath(guardInfo.polarStr)
    self:setImagePlist("PolarImage", polarPath, itemPanel)

    -- 获取宠物的状态 参战、未参战
    local combat_guard = guardInfo.combat_guard
    local use_skill_d = guardInfo.use_skill_d
    local status = nil
    if 1 == combat_guard then
        local statusImgCtrl = self:getControl("StatusImage", nil, itemPanel)
        if 1 == use_skill_d then
            statusImgCtrl:loadTexture(ResMgr.ui.fuzhu_flag)
        else
            statusImgCtrl:loadTexture(ResMgr.ui.attack_flag)
        end

        self:setCtrlVisible("StatusImage", true, itemPanel)
    else
        self:setCtrlVisible("StatusImage", false, itemPanel)
    end

    -- 添加守护名称
    local name = guardInfo.name

    -- 根据守卫的品质类型，设置守卫名字的颜色:Dialog:setLabelText(name, text, root, color3)
    local rank = guardInfo.rank  -- 获取守卫品质
    local color = CharMgr:getNameColorByType(OBJECT_TYPE.GUARD, false, rank)  -- 获取与品质对应的颜色
    self:setLabelText('NameLabel', name, itemPanel, color)  -- 设置颜色

    -- 如果守护在参战状态
    if 1 == combat_guard then
        self:setLabelText("NameLabel", name, itemPanel, COLOR3.GREEN)   -- 参战状态显示绿色
    end

    -- 设置相性
    self:setLabelText("PolarLabel", guardInfo.polarStr, itemPanel)

    -- 根据rank设置边框颜色
    local rankImg = self:getGuardColorByRank(guardInfo.rank)
    local coverImgCtrl = self:getControl("CoverImage", nil, itemPanel)
    self:setCtrlVisible("CoverImage", true, itemPanel)
    coverImgCtrl:loadTexture(rankImg, ccui.TextureResType.plistType)

    -- 如果没有拥
    local guardImage = self:getControl("GuardImage", Const.UIImage, itemPanel)
    local shapePanel = self:getControl("ShapePanel", nil, itemPanel)
    if 0 == guardInfo.id then
        gf:grayImageView(guardImage)
        shapePanel:removeChildByTag(999 * LOCATE_POSITION.RIGHT_BOTTOM)
        
        self:setCtrlVisible("UnCalledImage", true, itemPanel)
        if not self.firstCall then self.firstCall = index - 1 end

        if guardInfo.callLevel > Me:queryInt("level") then
            -- 设置可召唤等级
            self:setLabelText("DescLabel", string.format(CHS[3002799], guardInfo.callLevel), itemPanel, COLOR3.RED)
        else
            self:setLabelText("DescLabel", string.format(CHS[3002800], guardInfo.callLevel), itemPanel, COLOR3.GREEN)
        end
    else
        gf:resetImageView(guardImage)
        local level = guardInfo.level
        self:setNumImgForPanel(shapePanel, ART_FONT_COLOR.NORMAL_TEXT, level, false, LOCATE_POSITION.LEFT_TOP, 21, itemPanel)
        
        self:setCtrlVisible("UnCalledImage", false, itemPanel)
        self:setLabelText("DescLabel", "", itemPanel)
    end

    -- 设置标签
    itemPanel:setTag(guardInfo.icon)

    -- 设置历练标志
    self:addAnvancedSign(guardInfo.raw_name, itemPanel, self.advanceGuardId == guardInfo.id, index)

    -- 默认选择
    if select then
        self:selectGuard(itemPanel, ccui.TouchEventType.ended)
    end

    return itemPanel
end

-- 通过守护名称进行选中
function GuardListChildDlg:selectGuardByName(guardName)
    local list = self:getControl("GuardListView")
    local items = list:getItems()
    for k, v in pairs(items) do
        if guardName == v.raw_name then
            self:selectGuard(v, ccui.TouchEventType.ended)
            self:scrollToIndex(k - 1)
        end
    end
end

-- 根据等级获取守护的颜色
function GuardListChildDlg:getGuardColorByRank(rank)
    if rank == GUARD_RANK.TONGZI then
        return ResMgr.ui.guard_rank1
    elseif rank == GUARD_RANK.ZHANGLAO then
        return ResMgr.ui.guard_rank2
    elseif rank == GUARD_RANK.SHENLING then
        return ResMgr.ui.guard_rank3
    end

    return nil
end

function GuardListChildDlg:getCurrentGuard()
    if self.selectName == nil then return end

    return GuardMgr:getGuardByRawName(self.selectName)
end

function GuardListChildDlg:getSelectImg()
    if nil == self.selectImg then
        -- 创建选择框
        self.selectImg = self:getControl("ChosenEffectImage", Const.UIImage)
        self.selectImg:retain()
        self.selectImg:setVisible(true)
        self.selectImg:setPosition(0, 0)
        self.selectImg:setAnchorPoint(0, 0)
    end

    return self.selectImg
end

function GuardListChildDlg:getCurrentFightGuardCount()
    local fightGuardCount = 0
    local guards = GuardMgr.objs
    if nil == guards then
        return fightGuardCount
    end

    for k, v in pairs(guards) do
        -- 进行判断，如果宠物状态为”参战“则加入fightArr，否则加入waitArr
        if 1 == v:queryInt("combat_guard") then
            fightGuardCount = fightGuardCount + 1
        end
    end

    return fightGuardCount
end

-- 添加历练标志
function GuardListChildDlg:addAnvancedSign(raw_name, item, isAdvanced, index)
    local guard = GuardMgr:getGuardByRawName(raw_name)
    if nil == guard then
        self:setCtrlVisible("AdvanceImage", false, item)
        self:setCtrlVisible("AdvanceLabel", false, item)
        return
    end

    local myLevel = Me:queryBasicInt("level")
    local str = nil
    local rank_now = guard:queryBasicInt("rank")
    if rank_now == GUARD_RANK.TONGZI and myLevel >= 30 then
        str = CHS[3002801]
    elseif rank_now == GUARD_RANK.ZHANGLAO and myLevel >= 65 then
        str = CHS[3002801]
    end

    if isAdvanced then
        str = CHS[3002802]
        self.firstAdvanced = nil
    elseif self.advanceGuardId
        and 0 ~= self.advanceGuardId then
        str = nil
    end

    if str then
        self:setLabelText("AdvanceLabel", str, item)
        self:setCtrlVisible("AdvanceImage", true, item)
        self:setCtrlVisible("AdvanceLabel", true, item)
        if CHS[3002801] == str then
            if not self.firstAdvanced then
                self.firstAdvanced = index - 1
            end
        end
    else
        self:setCtrlVisible("AdvanceImage", false, item)
        self:setCtrlVisible("AdvanceLabel", false, item)
    end
end

-- 滚动到第一只可以历练的守护
function GuardListChildDlg:scrollToAnvenced()
    if not self.firstAdvanced then return end
    self:scrollToIndex(self.firstAdvanced)
end

-- 滚动到第一支可以召唤的守护
function GuardListChildDlg:scrollToCall()
    if not self.firstCall then return end
    self:scrollToIndex(self.firstCall)
end

function GuardListChildDlg:scrollToIndex(index)
    if nil == index then return end

    performWithDelay(self.guardList, function()
        local posy =  index * (self.guardPanel:getContentSize().height + MARGIN)
        if posy > self.guardList:getInnerContainer():getContentSize().height - self.guardList:getContentSize().height then
            posy = self.guardList:getInnerContainer():getContentSize().height - self.guardList:getContentSize().height
        end

        self.guardList:getInnerContainer():setPositionY(-self.guardList:getInnerContainer():getContentSize().height + self.guardList:getContentSize().height + posy)
    end, 0)

    Log:D("index :" .. index)
    local itemPanel = self.guardList:getItem(index)
    local img = self:getSelectImg()
    img:removeFromParent(false)
    itemPanel:addChild(img)

    -- 如果id为0则表示不存在此守护
    self.selectName = itemPanel.raw_name

    -- 添加需要刷新的窗口
    DlgMgr:sendMsg("GuardAttribDlg", "setGuardInfo", self.selectName)
end

function GuardListChildDlg:MSG_GUARDS_REFRESH(data)
    self:initGuardList()
end

-- 刷新历练中守护
function GuardListChildDlg:MSG_GUARD_EXPERIENCE_ID(data)
    local guard = GuardMgr:getGuard(data.guard_id)
    self.advanceGuardId = data.guard_id
    if self.advanceGuardId and 0 ~= self.advanceGuardId then
        self:initGuardList()
    end
end

function GuardListChildDlg:MSG_LEADER_COMBAT_GUARD(data)
    local guard = GuardMgr:getGuardByRawName(self.selectName)
    if not guard then return end

    self:initGuardList()
end

return GuardListChildDlg
