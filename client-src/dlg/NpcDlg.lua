-- NpcDlg.lua
-- created by cheny Dec/1/2014
-- NPC对话

local NpcDlg = Singleton("NpcDlg", Dialog)
local MenuItem = require "ctrl/MenuItem"
local List = require("core/List")
local Bitset = require("core/Bitset")
local MARGIN = 6
local MARGIN_ITEM = 7
local DATA_TYPE = {
    MENU = 1,
    SELECT = 2,
}

local PARTY_MAP = 26000

-- 显示下发箭头时，需要多少个NPC菜单项，龙骨动画替换后，新的json需要4个，旧的5个
-- NpcDlg:getCfgFileName() 中会修改
local ARROW_DISPLAY_COUNT = 4

NpcDlg.lastCloseTime = 0    -- 用于判断NPC语音

-- 人物头像配置
-- opacity 透明度
-- staticDb 播放龙骨动画时需要静止的效果
local ICON_CFG = {
    [CHS[7190301]] = {opacity = 180},   -- 小童的魂魄
    [CHS[7100365]] = {staticDb = true}, -- 小童
}

-- 派生对象中可通过重新该函数来实现共用对话框配置
function NpcDlg:getCfgFileName()
    return ResMgr:getDlgCfg("NewNpcDlg")
end

function NpcDlg:init()
    self:setFullScreen()
    self:setCtrlFullClient("TouchPanel")
    local menuBtn = self:getControl("MenuButton1", Const.UIButton)
    self.textColor = menuBtn:getTitleColor()
    self.menuContentSize = menuBtn:getContentSize()
    self.meunFontSize = menuBtn:getTitleFontSize()

    local listViewCtrl = self:getControl("MenuListView")
    listViewCtrl:removeAllItems()
    listViewCtrl:addScrollViewEventListener(function(sender, eventType) self:updateSlider(sender, eventType) end)

    self.itemPos = nil

    self:setCtrlVisible("TouchPanel", false)

    self:hookMsg("MSG_MENU_SELECT")

    -- 调整NPC方向
    local talkId = Me:getTalkId()
    local npc = CharMgr:getChar(talkId)
    if not npc then return end

    local npcDir = gf:defineDirForPet(cc.p(npc.curX, npc.curY), cc.p(Me.curX, Me.curY))
    npc:setDir(npcDir)

    if not Me:isInTeam() then
        local dir = gf:defineDir(cc.p(Me.curX, Me.curY), cc.p(npc.curX, npc.curY), Me:getDlgIcon())
        Me:setDir(dir)
    else
        local dir = gf:defineDir(cc.p(Me.curX, Me.curY), cc.p(npc.curX, npc.curY), Me:getDlgIcon())
        Me:setDir(dir)
        local teamMember = TeamMgr.members
        local count = teamMember.count and teamMember.count or 0
        for i = 1, count do
            local id = teamMember[i].id
            local char = CharMgr:getChar(id)
            if char then
                local charDir = gf:defineDir(cc.p(char.curX, char.curY), cc.p(npc.curX, npc.curY), char:getDlgIcon())
                char:setDir(charDir)
            end
        end
    end

    EventDispatcher:addEventListener("EVENT_JOIN_TEAM", self.onJoinTeam, self)
end

-- 更新滚动条
function NpcDlg:updateSlider(sender, eventType)

    if ccui.ScrollviewEventType.scrolling == eventType then
        -- 获取控件
        local listViewCtrl = sender

        -- 获取菜单控件的数量
        local menuItemCount = listViewCtrl:getChildrenCount()

        -- 获取内部滚动控件的大小
        local listInnerContent = listViewCtrl:getInnerContainer()
        local innerSize = listInnerContent:getContentSize()
        local listViewSize = listViewCtrl:getContentSize()

        -- 计算滚动的百分比
        local totalHeight = innerSize.height - listViewSize.height
        local innerPosY = listInnerContent:getPositionY()
        local persent = 1 - (-innerPosY) / totalHeight
        persent = math.floor(persent * 100)
        if menuItemCount > 0 and totalHeight > MARGIN_ITEM then
            if innerPosY <= -totalHeight + MARGIN_ITEM  then
                self:addMagic("MagicPanel", ResMgr:getMagicDownIcon())
            else
                if not self.first then
                    self:removeMagic("MagicPanel", ResMgr:getMagicDownIcon())
                end

                self.first = false
            end
        end

        -- 设置显示状态，如果滚动的话，就让他显示，在滚动1s之后消失
        local fadeOut = cc.FadeOut:create(1)
        local func = cc.CallFunc:create(function() sliderCtrl:setVisible(false) end)
        local action = cc.Sequence:create(fadeOut, func)
    end
end

function NpcDlg:close(now)
    Dialog.close(self, now)
    self.menuList = nil
    self.isRunAction = false
    self.npcName = nil

    Me:setTalkWithNpc(false)

    -- 移除选中对象脚底的光效
    Me:removeSelectTargetFocusMagic()

    self.lastCloseTime = gfGetTickCount()
end

function NpcDlg:setSecretKey(key)
    self.secret_key = key
end

function NpcDlg:setAllowClose(notAllowClose)
    self.notAllowClose = notAllowClose
end

function NpcDlg:setDlgAttrib(attrib)
     local state = Bitset.new(attrib or 0)
    -- NPC不可见了是否可关闭界面
    self:setAllowClose(state:isSet(NPC_DLG_ATTRIB.NOT_CLOSE_WHEN_NOT_NPC) and 1 or 0)

    -- 点击对外框外是否关闭界面
    self:setCtrlVisible("TouchPanel", state:isSet(NPC_DLG_ATTRIB.NOT_CLOSE_WHEN_CLICK_OUT))
end

function NpcDlg:onUpdate()
    if self.npc_id ~= 1 then
        if nil == CharMgr:getChar(self.npc_id) then
            -- NPC不可见了

            if TeamMgr:inTeam(Me:getId()) and TeamMgr:getLeaderId() ~= Me:getId() then
                -- 如果在队伍中且不是队长
                return
            end

            if ((not self.notAllowClose) or (self.notAllowClose ~= 1)) and not self.delayCloseDlg then
                -- 服务器是否允许关闭对话框
                local npcId = self.npc_id
                self.delayCloseDlg = performWithDelay(self.root, function()
                     self.delayCloseDlg = nil
                     if self.npc_id == npcId and not CharMgr:getChar(self.npc_id) then
                        DlgMgr:closeDlg(self.name)
                     end
                end, 0)
            end
        end
    end
end

function NpcDlg:setMenuNpcId(id, nameStr)
    self.npc_id = id

    local name = self:getControl("NameLabel", Const.UILabel)
    if id == 1 then
        name:setString(CHS[2000012])
    else
        if nameStr then
            if MapMgr.mapData and MapMgr.mapData.map_id == PARTY_MAP then
                local pos = gf:findStrByByte(nameStr, " ")
                if pos then
                    name:setString(string.sub(nameStr,pos + 1, -1))
                    self.npcName = string.sub(nameStr,pos + 1, -1)
                else
                    name:setString(nameStr)
                    self.npcName = nameStr
                end
            else
                name:setString(nameStr)
                self.npcName = nameStr
            end
        else
            local char = CharMgr:getChar(id)
            if char == nil then
                name:setString("")
            else
                name:setString(char:getShowName())
                self.npcName = char:getName()
            end
        end
    end
end

function NpcDlg:creatCharDragonBones(icon, panelName, staticDb)
    local panel = self:getControl(panelName)
    local magic = panel:getChildByName("charPortrait")

    if magic then
        if magic:getTag() == icon then
            -- 已经有了，不需要加载
            return magic
        else
            DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
            magic:removeFromParent()
        end
    end

    local dbMagic = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    if not dbMagic then return end

    local magic = tolua.cast(dbMagic, "cc.Node")
    magic:setPosition(panel:getContentSize().width * 0.5, -13)
    magic:setName("charPortrait")
    magic:setTag(icon)
    panel:addChild(magic)
    magic:setRotationSkewY(180)

    if not staticDb then
        DragonBonesMgr:toPlay(dbMagic, "stand", 0)
    end

    return magic
end

function NpcDlg:cleanup()
    -- 如果有骨骼动画时，释放相关资源
    local panel = self:getControl("PortraitBonesPanel")
    if panel then
        local magic = panel:getChildByName("charPortrait")

        if magic then
            DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
        end
    end

    -- 周年蛋糕，点击便捷使用框，弹出NPC菜单，若关闭界面，则不能再次点击使用。需要将按钮设置为可点击
    DlgMgr:sendMsg("FastUseItemDlg", "setCtrlOnlyEnabled", "UseButton", true)

    self.delayCloseDlg = nil

    -- 调回提示框正常的层级
    SmallTipsMgr:setLocalZOrder(nil, self.name)

    EventDispatcher:removeEventListener("EVENT_JOIN_TEAM", self.onJoinTeam, self)
end

function NpcDlg:setPortrait(icon)
    local bonesPath, texturePath = ResMgr:getBonesCharFilePath(icon)
    local bExist = cc.FileUtils:getInstance():isFileExist(bonesPath)
    self:setCtrlVisible("PortraitBonesPanel", bExist)
    self:setCtrlVisible("PortraitNormalPanel", not bExist)
    local npcPortrait
    local iconCfg = ICON_CFG[self.npcName]
    if bExist then
        local playStaticDb = false
        if iconCfg and iconCfg.staticDb then
            playStaticDb = true
        end

        npcPortrait = self:creatCharDragonBones(icon, "PortraitBonesPanel", playStaticDb)
    else
        npcPortrait = self:getControl("PortraitImage", Const.UIImage, "PortraitNormalPanel")
        npcPortrait:loadTexture(ResMgr:getBigPortrait(icon))
    end

    if iconCfg and iconCfg.opacity then
        -- 配置了透明度则更新头像透明度
        npcPortrait:setOpacity(iconCfg.opacity)
    end
end

function NpcDlg:setMenu(content, npcName)
    self:removeMagic("MagicPanel", ResMgr:getMagicDownIcon())
    self.first = true
    local data = gf:parseMenu(content, npcName)
    self:setTip(data.instruction)

    local list, _ = self:resetListView("MenuListView", MARGIN_ITEM)
    local count = data.count
    local autoClickIndex = nil
    local messageIndex = nil

    -- 点击某条菜单可能带有参数
    -- 需要带参数的dlg格式  M=菜单项::对话框名字=参数1:参数2:...
    -- 这个格式需要点击对应的条目
    local msgIndex = AutoWalkMgr:getMessageIndex()
    if msgIndex then
        local msgList =  gf:split(msgIndex, "::")
        messageIndex = msgList[1] -- 菜单项

        if msgList[2] then
            -- 约定好的对话框参数
            local paramList = gf:split(msgList[2], "=")
            local dlgName = paramList[1] -- 对话框名字
            local dlgParamList = gf:split(paramList[2], ":") -- 解析出所有的参数
            AutoWalkMgr:setOpenDlgParam(dlgName, dlgParamList)
        end

        self.blank:setVisible(false)

        -- 解析过了，清除相应的处理
        AutoWalkMgr:clearMessageIndex()
    end

    local selectCell
    local selectIndex = 0
    for i = 1, count do
        -- 创建菜单项
        local cell = self:createMenuItem(data[i], self.npc_id, self.secret_key)
        cell:setcolorAndSize(self.textColor, self.menuContentSize, self.meunFontSize)
        list:pushBackCustomItem(cell)

        -- 点击某条菜单
        if cell:getShowInfo() == messageIndex then
            autoClickIndex = i - 1
        end

        -- 给某个菜单加光效索引
        if cell:getShowInfo() == AutoWalkMgr:getEffectIndex() then
            -- 如果这个时候需要显示菜单光效
            -- lixh2 WDSY-21401 帧光效修改为粒子光效：NPC对话框环绕光效
            selectCell = cell
            selectIndex = i
            gf:createArmatureMagic(ResMgr.ArmatureMagic.npc_dlg, cell, Const.ARMATURE_MAGIC_TAG)
            AutoWalkMgr:clearEffectIndex()
        end

        self.menuItemFlag = cell.menuItemFlag
    end

    -- 滑动到选中项
    if selectCell then
        list:requestRefreshView()
        list:doLayout()

        local size = selectCell:getContentSize()
        local innerCtrl = list:getInnerContainer()
        local scrollHeight = innerCtrl:getContentSize().height - list:getContentSize().height
        if selectIndex > 3 then
            list:getInnerContainer():setPositionY(size.height * (selectIndex - 3) - scrollHeight)
        end
    end

    if count >= ARROW_DISPLAY_COUNT and selectIndex <= 3 then
        -- 大于n个条目，添加向下的标记
        self:addMagic("MagicPanel", ResMgr:getMagicDownIcon())
    end

    local function cliclMenu()
        if autoClickIndex then
            -- 如果存在自动点击的条目，直接点击
            local item = list:getItem(autoClickIndex)
            item:clickMenu(self.npcName, messageIndex)
            -- list:stopAllActions()
        elseif not autoClickIndex and AutoWalkMgr:getMessageIndex() then
            -- 自动寻路中的自动点击条目与当前显示的菜单项对不上
            self.blank:setVisible(true)
            -- list:stopAllActions()
        end
    end

    -- schedule(list, cliclMenu, 0)
    cliclMenu()
end

function NpcDlg:createMenuItem(text, id, key)
    return MenuItem.new(text, id, key)
end

function NpcDlg:setTip(strTip)
    local panel = self:getControl("TipBackPanel")
    panel:removeAllChildren()
    local box = panel:getBoundingBox()

    local container = ccui.Layout:create()
    container:setPosition(0,0)
    local scrollview = ccui.ScrollView:create()
    scrollview:setContentSize(panel:getContentSize())
    scrollview:setDirection(ccui.ScrollViewDir.vertical)
    scrollview:addChild(container)
    panel:addChild(scrollview)

    local tip = CGAColorTextList:create()
    if tip.setPunctTypesetting then
        tip:setPunctTypesetting(true)
    end
    tip:setFontSize(21)
    tip:setContentSize(box.width - MARGIN*4, 0)
    tip:setString(strTip)
    tip:setDefaultColor(self.textColor.r, self.textColor.g, self.textColor.b)
    tip:updateNow()
    local labelW, labelH = tip:getRealSize()
    tip:setPosition(MARGIN, labelH)
    container:addChild(tolua.cast(tip, "cc.LayerColor"))
    container:setContentSize(labelW, labelH)

    scrollview:setInnerContainerSize(container:getContentSize())

    if labelH < panel:getContentSize().height then
        container:setPositionY(panel:getContentSize().height - labelH)
    end

end

-- 更新NPC对话框， 在队员状态下使用
function NpcDlg:updateDlg(data)
    -- 在队员状态下，可能出现连续切换NPC对话框，所以，需要对消息进行缓存
    if self.isRunAction then
        if not self.menuList then
            self.menuList = List.new()
        end

        data.type = DATA_TYPE.MENU

        self.menuList:pushBack(data)
    else
        self:setVisible(true)
        self:setMenuNpcId(data.id, data.name)
        self:setPortrait(data.portrait)
        self:setSecretKey(data.secret_key)
        self:setMenu(data.content, data.name)
    end
end

-- 选择菜单，不进行操作，仅仅是点击
function NpcDlg:selectItemWithDoNothing(data)
    local listCtrl = self:getControl("MenuListView")

    if listCtrl then
        local items = listCtrl:getItems()
        for key, value in pairs(items) do
            if value then
                local action = value:getAction()
                if action and data.item == action then
                    -- 找到选中项，播放点击动画
                    value:clickMenuWithDoNothing()
                    listCtrl:stopAllActions()

                    self.isRunAction = true
                end
            end
        end
    end
end

function NpcDlg:doNextMenu()
    -- 重置状态
    self.isRunAction = false

    -- 播放下一个菜单项
    if not self.menuList or 0 == self.menuList:size() then
        -- 没有了，关掉！
        DlgMgr:closeDlg(self.name)
        return
    end

    local item = self.menuList:popFront()
    if item.type ==  DATA_TYPE.SELECT then
        self:MSG_MENU_SELECT(item)
    elseif item.type == DATA_TYPE.MENU then
        self:setVisible(true)
        self:setMenuNpcId(item.id, item.name)
        self:setPortrait(item.portrait)
        self:setSecretKey(item.secret_key)
        self:setMenu(item.content, item.name)

        if 0 < self.menuList:size() then
            local select = self.menuList:popFront()
            if select then
                self:selectItemWithDoNothing(select)
            end
        end
    end
end

function NpcDlg:onJoinTeam()
    self:onCloseButton()
end

function NpcDlg:MSG_MENU_SELECT(data)
    -- 在队员状态下，可能出现连续切换NPC对话框，所以，需要对消息进行缓存
    if self.isRunAction then
        if not self.menuList then
            self.menuList = List.new()
        end

        data.type = DATA_TYPE.SELECT
        self.menuList:pushBack(data)
        return
    end

    self:selectItemWithDoNothing(data)
end

return NpcDlg
