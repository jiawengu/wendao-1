-- SkillStatusDlg.lua
-- Created by songcw Sep/23/2015
-- 战斗状态mini悬浮框

local SkillStatusDlg = Singleton("SkillStatusDlg", Dialog)

local LINE_MAX = 4
local MARGIN_X = 4

function SkillStatusDlg:init()
    self:setFullScreen()

    -- 图片控件
    self.imageCtrl = self:getControl("StatusImage")
    self.imageCtrl:retain()
    self.imageCtrl:removeFromParent()
    self.imageCtrl:setAnchorPoint({0.5, 0})

    self.imageSize = self.imageCtrl:getContentSize()

    -- me的状态panel    pet 状态panel
    self.MeStatusPanel = self:getControl("UserStatusPanel")
    self.petStatusPanel = self:getControl("PetStatusPanel")
    self.meState = {}
    self.petState = {}
end

function SkillStatusDlg:cleanup()
    self:releaseCloneCtrl("imageCtrl")
end

-- 增加状态 petId == nil 代表me
function SkillStatusDlg:addStatus(status, petId)
    local file = ResMgr:getBuffIconPath()
    cc.SpriteFrameCache:getInstance():addSpriteFrames(file .. ".plist")
    local imageCtr = self.imageCtrl:clone()
    local displayImage = self:getControl("Image", nil, imageCtr)
    displayImage:loadTexture(ResMgr:getFightStatus(status), ccui.TextureResType.plistType)
    imageCtr:setTag(status)

    -- 绑定事件
    imageCtr:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local dlg = DlgMgr:openDlg("CombatStatusDlg")
            local rect = self:getBoundingBoxInWorldSpace(sender)
            if petId then
                dlg:queryInfo(FightMgr:getObjectById(petId), rect)
            else
                dlg:queryInfo(FightMgr:getObjectById(Me:getId()), rect)
            end
        end
    end)

    if petId then
        -- 宠物状态
        if #self.petState > LINE_MAX * 2 - 1 then return end
        table.insert(self.petState, status)

        local panelSize = self.petStatusPanel:getContentSize()
        local xIndex, yIndex
        xIndex = #self.petState % LINE_MAX
        if xIndex == 0 then xIndex = 4 end
        if #self.petState > LINE_MAX then yIndex = 1 else yIndex = 0 end

        imageCtr:setPosition((xIndex - 1) * (self.imageSize.width + MARGIN_X),panelSize.height - (yIndex + 1) * (self.imageSize.height + MARGIN_X))
        self.petStatusPanel:addChild(imageCtr)
    else
        -- me状态
        if #self.meState > LINE_MAX * 2 - 1 then return end
        table.insert(self.meState, status)

        local panelSize = self.petStatusPanel:getContentSize()
        local xIndex, yIndex
        xIndex = #self.meState % LINE_MAX
        if xIndex == 0 then xIndex = 4 end
        if #self.meState > LINE_MAX then yIndex = 1 else yIndex = 0 end

        imageCtr:setPosition((xIndex - 1) * (self.imageSize.width + MARGIN_X),panelSize.height - (yIndex + 1) * (self.imageSize.height + MARGIN_X))
        self.MeStatusPanel:addChild(imageCtr)
    end
end

-- 移除效果
function SkillStatusDlg:removeStatus(status, petId)
    if petId then
        self:removeLogic(self.petStatusPanel, self.petState, status, petId)
    else
        self:removeLogic(self.MeStatusPanel, self.meState, status, petId)
    end
end

function SkillStatusDlg:removeLogic(panel, stateTab, status, petId)
    if #stateTab == 0 then return end
    panel:getChildByTag(status)
    local pos = nil
    for i, tag in pairs(stateTab) do
        if status == tag then pos = i end
    end
    if pos then table.remove(stateTab, pos) end

    self:reflashState(petId)
end

function SkillStatusDlg:reflashState(petId)
    local file = ResMgr:getBuffIconPath()
    cc.SpriteFrameCache:getInstance():addSpriteFrames(file .. ".plist")

    local stateTab = {}
    local panel
    if petId then
        stateTab = self.petState
        panel = self.petStatusPanel
    else
        stateTab = self.meState
        panel = self.MeStatusPanel
    end

    panel:removeAllChildren()
    for i = 1, #stateTab do
        local status = stateTab[i]
        local imageCtr = self.imageCtrl:clone()
        local displayImage = self:getControl("Image", nil, imageCtr)
        displayImage:loadTexture(ResMgr:getFightStatus(status), ccui.TextureResType.plistType)
        imageCtr:setTag(status)

        local panelSize = self.petStatusPanel:getContentSize()
        local xIndex, yIndex
        xIndex = i % LINE_MAX
        if xIndex == 0 then xIndex = 4 end
        if #stateTab > LINE_MAX then yIndex = 1 else yIndex = 0 end

        imageCtr:setPosition((xIndex - 1) * (self.imageSize.width + MARGIN_X),panelSize.height - (yIndex + 1) * (self.imageSize.height + MARGIN_X))
        panel:addChild(imageCtr)

        -- 绑定事件
        imageCtr:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local dlg = DlgMgr:openDlg("CombatStatusDlg")
                local rect = self:getBoundingBoxInWorldSpace(sender)
                if petId then
                    dlg:queryInfo(FightMgr:getObjectById(petId), rect)
                else
                    dlg:queryInfo(FightMgr:getObjectById(Me:getId()), rect)
                end
            end
        end)
    end
end

return SkillStatusDlg
