-- UserListDlg.lua
-- created by songcw Jan/4/2015
-- 长按玩家信息对话框

local UserListDlg = Singleton("UserListDlg", Dialog)
local PARTY_MAP = 26000

-- 某些形象没有对应的头像，使用其它特定的头像（目前用于帮派巨兽）
local SPECIAL_ICON = {
    [51518] = 06660,  -- 一阶巨兽
    [51520] = 06203,  -- 二阶巨兽
    [51521] = 06203,  -- 三阶巨兽
    [51523] = 06600,  -- 四阶巨兽
}

function UserListDlg:init()
    --self:getControl("UserPanel"):removeFromParent()
    self.size = self.size or self.root:getContentSize()
    self.userPanel = self:getControl("UserPanel")
    self.userPanel:retain()
    self.userPanel:removeFromParent()
end

function UserListDlg:cleanup()
    self:releaseCloneCtrl("userPanel")
    self.clickPos = nil
end

function UserListDlg:isNpc(type)
    if type ~= "Npc" and type ~= "MaidNpc" and type ~= "Monster"
        and type ~= "GatherNpc" and type ~= "TMFollowNpc" and type ~= "FollowNpc"
        and type ~= "LSNpc" and type ~= "MoveNpc" and type ~= "QTNpc" then
        return false
    end

    return true
end

function UserListDlg:needShowNpcTag(type)
    if type == "Npc" or type == "Monster" or type == "TMFollowNpc"
        or type == "FollowNpc" or type == "MaidNpc" or type == "LSNpc"
        or type == "QTNpc" then
        return true
    end

    return false
end

function UserListDlg:setInfo(playerList, count, pos)
    local list, listSize = self:resetListView("ListView")
    local height = 0
    self.clickPos = pos
    for _, char in pairs(playerList) do
        local panel = self.userPanel:clone()
        local type = char:getType()
        if type == "Furniture" or type == "FurnitureEx" then
            -- 家具
            local name = char:getName()
            if gf:getTextLength(name) > 16 then
                name = gf:subString(name, 14) .. "..."
            end

            self:setLabelText("NameLabel", name, panel)
            panel:setTag(char:getId())
            self:setImage("IconImage", ResMgr:getItemIconPath(char:queryBasicInt("icon")), panel)
            self:setItemImageSize("IconImage", panel)

            local btn = self:getControl("UserButton", nil, panel)
            self:bindTouchEndEventListener(btn, self.chooseFurniture, {x = char.curX, y = char.curY})
        else
            if Me:getTitle() ~= CHS[4300269] and GameMgr:isInPartyWar() and char:queryBasic("party") ~= Me:queryBasic("party") and char:getType() == "Player" and char:getTitle() ~= CHS[4300269] then
                self:setLabelText("NameLabel", char:getShowName(), panel, COLOR3.RED)
            elseif MapMgr.mapData and MapMgr.mapData.map_id == PARTY_MAP then
                -- 帮派地图中，角色列表中帮派NPC的名字不显示帮派名
                local nameStr = char:getName()
                local showName
                local pos = gf:findStrByByte(nameStr, " ")
                if pos then
                    showName = string.sub(nameStr,pos + 1, -1)
                else
                    showName = nameStr
                end

                self:setLabelText("NameLabel", showName, panel)
            else
                local name = char:getShowName()
                if gf:getTextLength(name) > 16 then
                    -- 目前悬赏相关的 NPC 名字超过 8 个汉字的，取前 7 个汉字加“...”
                    name = gf:subString(name, 14) .. "..."
                end

                self:setLabelText("NameLabel", name, panel)
            end

            local icon = nil
            if not self:isNpc(type) then
                -- 不是 NPC 直接使用 icon 就行了
                icon = char:queryBasicInt("icon")
            else
                -- NPC 类型可能会自行配置 icon 和 portrait，
                -- 并且部分 icon 没有对应的 portrait 所以需要直接取服务端配置的 portrait
                icon = char:queryBasicInt("portrait")
            end

            if SPECIAL_ICON[icon] then
                icon = SPECIAL_ICON[icon]
            end

            panel:setTag(char:getId())
            panel:setName(char:queryBasic("gid"))
            self:setImage("IconImage", ResMgr:getSmallPortrait(icon), panel)
            self:setItemImageSize("IconImage", panel)

            if self:needShowNpcTag(type) then
                local iconImage = self:getControl("IconImage", nil, panel)
                gf:addNpcLogo(iconImage)
            end

            if not self:isNpc(type) then
                -- 不是 NPC 还需要显示等级
                self:setNumImgForPanel("IconImage", ART_FONT_COLOR.NORMAL_TEXT, char:queryBasicInt("level"), false, LOCATE_POSITION.LEFT_TOP, 21, panel, nil, -5, 5)
            end

            local btn = self:getControl("UserButton", nil, panel)
            self:bindTouchEndEventListener(btn,self.chooseChar)
        end

        list:pushBackCustomItem(panel)
        height = panel:getContentSize().height + height
    end

    local size = self.root:getContentSize()
    if height > self.size.height - 16 then height = self.size.height - 16 end
    list:setContentSize(listSize.width,height)
    self.root:setContentSize(size.width,height + 16)
    local rect = {height = 0, width = 0, x = pos.x, y = pos.y}
    self:setFloatingFramePos(rect)
end

function UserListDlg:setInfoByFightObj(playerList, count)
    local list, listSize = self:resetListView("ListView")
    local height = 0

    for _, char in pairs(playerList) do
        if char:queryBasicInt("type") == OBJECT_TYPE.CHAR then
            char.order = 1
        elseif char:queryBasicInt("type") == OBJECT_TYPE.PET then
            char.order = 2
        elseif char:queryBasicInt("type") == OBJECT_TYPE.MONSTER then
            char.order = 3
        else
            char.order = 4
        end
    end

    local function sort(l,r)
        if l.order < r.order then return true end
    end

    table.sort(playerList, function(l, r)  return sort(l,r)  end)


    for _, char in pairs(playerList) do
        local panel = self.userPanel:clone()
        if GameMgr:isInPartyWar() and char:queryBasic("party") ~= Me:queryBasic("party") and char:getType() == "Player" then
            self:setLabelText("NameLabel", char:getShowName(), panel, COLOR3.RED)
        else
            self:setLabelText("NameLabel", char:getShowName(), panel)
        end

        local icon = char:queryBasicInt("icon")
        panel:setTag(char:getId())
        panel:setName(char:queryBasic("gid"))
        self:setImage("IconImage", ResMgr:getSmallPortrait(icon), panel)
        self:setItemImageSize("IconImage", panel)
        local btn = self:getControl("UserButton", nil, panel)
        self:bindTouchEndEventListener(btn,self.chooseFightChar)
        list:pushBackCustomItem(panel)
        height = panel:getContentSize().height + height
    end

    local size = self.root:getContentSize()
    if height > self.size.height - 16 then height = self.size.height - 16 end
    list:setContentSize(listSize.width,height)
    self.root:setContentSize(size.width,height + 16)
end

function UserListDlg:chooseFightChar(sender, eventType)
    local panel = sender:getParent()
    local meFightObj = nil
    for _, v in pairs(FightMgr.objs) do
        if v:getId() == panel:getTag() then
            meFightObj = v
        end
    end

    -- 如果是组合技能
    if meFightObj and meFightObj.selectZHSkillImg and meFightObj.selectZHSkillImg:isVisible() then
        DlgMgr:sendMsg("ZHSkillTargetChoseDlg", "nextTarget", meFightObj:getId(), meFightObj:getName(), FightMgr:getObjectPosById(meFightObj:getId()))
        self:onCloseButton()
        return
    end

    if Me:queryBasicInt("auto_fight") == 0 then
        meFightObj:onSelectChar()
        self:onCloseButton()
        Log:D('onClickChar: selectImg' .. meFightObj:getName())
    end
end

function UserListDlg:chooseChar(sender, eventType)
    local panel = sender:getParent()
    local char = CharMgr:getChar(panel:getTag())

    if not char then
        gf:ShowSmallTips(CHS[3003789])
        self:onCloseButton()
        return
    end

    local type = char:getType()
    if type == "Npc" or type == "MaidNpc" or type == "Monster" or type == "GatherNpc" or type == "TMFollowNpc" then
        char:onClickChar()
        self:onCloseButton()
        return
    end

    if MapMgr:isInYuLuXianChi() and type == "Player" then
        self:onCloseButton()

        if WenQuanMgr:isInThrowSoap() then
            -- 仍肥皂
            local pos = gf:getMapLayer():convertToWorldSpace(cc.p(char.curX, char.curY))
            WenQuanMgr:mePlayThrowSoap(pos, char)
        else
            -- 寻路到角色旁，等待捶背
            local pos = WenQuanMgr:getClickCharToPos(char)
            Me:touchMapBegin(pos)
            Me:touchMapEnd(pos)
        end

        Me.selectTarget = char
        char:showTargetHeadDlg()
        char:addFocusMagic()
        return
    end

    if not Me:isInTeam() then
        Me:setEndPos(gf:convertToMapSpace(char.curX, char.curY))
    end

    if MapMgr:isInMasquerade() and char and char:queryBasicInt("masquerade") == 1 then
        -- 化妆舞会的怪物，特殊处理
        local dlg = DlgMgr:openDlg("CharMenuContentDlg")
        dlg:setInfoByDataObject(char)
        dlg:setMuneType(CHAR_MUNE_TYPE.SCENE)
        dlg:setMonsterInMasqueradeInfo()
        Me.selectTarget = char
        self:onCloseButton()
        char:addFocusMagic()
        return
    end

    local function onCharInfo(gid)
        local dlg = DlgMgr:openDlg("CharMenuContentDlg")
        if dlg then
            dlg:setting(gid)
            dlg:setMuneType(CHAR_MUNE_TYPE.SCENE)
        end
    end

    FriendMgr:requestCharMenuInfo(char:queryBasic("gid"), onCharInfo)
    Me.selectTarget = char
    self:onCloseButton()

    if char then
        char:addFocusMagic()
    end
end

function UserListDlg:chooseFurniture(sender, eventType, pos)
    if not self.clickPos then
        return
    end

    local panel = sender:getParent()
    local furniture = HomeMgr:getFurnitureById(panel:getTag())
    if not furniture then
        -- 目标家具已消失
        gf:ShowSmallTips(CHS[4200431])
        ChatMgr:sendMiscMsg(CHS[4200431])
        self:onCloseButton()
        return
    end

    if furniture.curX ~= pos.x or furniture.curY ~= pos.y then
        -- 对应家具位置已发生改变
        gf:ShowSmallTips(CHS[4200418])
        ChatMgr:sendMiscMsg(CHS[4200418])
        self:onCloseButton()
        return
    end

    furniture:onClickFurniture(self.clickPos)
    self:onCloseButton()
end

return UserListDlg
