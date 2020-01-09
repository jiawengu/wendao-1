-- TeamGuardMenuDlg.lua
-- Created by songcw June/16/2015
-- 队伍界面点击守护     选择守护界面

local TeamGuardMenuDlg = Singleton("TeamGuardMenuDlg", Dialog)


function TeamGuardMenuDlg:init()
    self:bindListViewListener("GuardListView", self.onSelectGuardListView)

    self.guardPanel = self:getControl("GuardListPanel"):clone()
    self.guardPanel:retain()
    self:setCtrlVisible("TipImage", false, self.guardPanel)
    self:getControl("GuardListPanel"):removeFromParent()
    
    -- 是否为“替换守护”界面
    self.isExchangeGuard = false
    
    self.selectGuardId = nil
end

function TeamGuardMenuDlg:cleanup()
    self:releaseCloneCtrl("guardPanel")
end

function TeamGuardMenuDlg:setSelectGuardId(id)
    self.selectGuardId = id
    self:setGuardList()
end

-- “替换守护”界面生成
function TeamGuardMenuDlg:initExchangeGuard(id)
    self.selectGuardId = id
    
    -- 标题更换为“替换守护”
    self:getControl("InfoLabel"):setString(CHS[7000036])
    
    -- 生成“替换守护”列表
    self.isExchangeGuard = true
    self:setGuardList()
end

function TeamGuardMenuDlg:setGuardList()
    local guardList = {}
    
    -- 根据isExchangeGuard参数，生成“选择守护”或“替换守护”列表
    if not self.isExchangeGuard then
        if self.selectGuardId == 0 then
            guardList = GuardMgr:getGuardListByFight(false)
        else
            guardList = GuardMgr:getOrderGuardList()
        end
    else
        guardList = GuardMgr:getGuardListByFight(true)
    end

    local listPanel = self:resetListView("GuardListView")
    listPanel:setGravity(ccui.ListViewGravity.centerVertical)
    for i, v in pairs(guardList) do
        local guardPanel = self.guardPanel:clone()
        self:setImage("GuardImage", ResMgr:getSmallPortrait(v.icon), guardPanel)
        self:setItemImageSize("GuardImage", guardPanel)

        local statusImgCtrl = self:getControl("StatusImage", nil, guardPanel)
        if 1 == v.use_skill_d then
            statusImgCtrl:loadTexture(ResMgr.ui.guard_status_use_skill_d)
        else
            statusImgCtrl:loadTexture(ResMgr.ui.guard_status_combat)
        end
        statusImgCtrl:setVisible(v.combat_guard == 1)

        -- 添加守护名称
        local name = v.name

        -- 根据守卫的品质类型，设置守卫名字的颜色:Dialog:setLabelText(name, text, root, color3)
        local rank = v.rank  -- 获取守卫品质
        local color = CharMgr:getNameColorByType(OBJECT_TYPE.GUARD, false, rank)  -- 获取与品质对应的颜色
        self:setLabelText('NameLabel', name, guardPanel, color)  -- 设置颜色

        -- 相性
        local polar = tonumber(v.polar) or 0
        self:setLabelText("PolarLabel", gf:getPolar(polar), guardPanel)

        -- desc
        self:setLabelText("DescLabel", GuardMgr:getGuardbriefIntro(GuardMgr:getGuard(v.id):queryBasic("raw_name")), guardPanel)

        -- 根据rank设置边框颜色
        local rankImg = self:getGuardColorByRank(rank)
        local coverImgCtrl = self:getControl("CoverImage", nil, guardPanel)
        coverImgCtrl:setVisible(true)
        coverImgCtrl:loadTexture(rankImg, ccui.TextureResType.plistType)

        guardPanel:setTag(v.id)
        self:bindTouchEndEventListener(guardPanel, self.onGuardListButton)
        listPanel:pushBackCustomItem(guardPanel)
    end
end

-- 根据等级获取守护的颜色
function TeamGuardMenuDlg:getGuardColorByRank(rank)
    if rank == GUARD_RANK.TONGZI then
        return ResMgr.ui.guard_rank1
    elseif rank == GUARD_RANK.ZHANGLAO then
        return ResMgr.ui.guard_rank2
    elseif rank == GUARD_RANK.SHENLING then
        return ResMgr.ui.guard_rank3
    end

    return nil
end

function TeamGuardMenuDlg:onGuardListButton(sender, eventType)
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3003746])
        return
    end
    
    -- 若当前列表是“替换守护”列表，则“列表项的点击响应”要考虑玩家是否处于禁闭状态
    if self.isExchangeGuard then
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return
        end
    end
    
    if self.selectGuardId == nil then return end
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SET_COMBAT_GUARD, sender:getTag(), self.selectGuardId)
    self:onCloseButton()
end

function TeamGuardMenuDlg:setIndex(idx, boundingBox)
    local contentSize = self.root:getContentSize()
    if idx < 3 then
        -- 在控件的右侧
        self.root:setAnchorPoint(0, 1)
        self.root:setPosition(boundingBox.x + boundingBox.width, boundingBox.y + boundingBox.height / 2)
    else
        -- 在控件的左侧
        self.root:setAnchorPoint(1, 1)
        self.root:setPosition(boundingBox.x, boundingBox.y + boundingBox.height / 2)
    end

    if self.root:getPositionY() < contentSize.height then
        self.root:setPositionY(contentSize.height + 20)
    end
end

function TeamGuardMenuDlg:onSelectGuardListView(sender, eventType)


end

return TeamGuardMenuDlg
