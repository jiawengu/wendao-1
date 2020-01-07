-- CharMenuContentDlg.lua
-- created by songcw Jan/4/2015
-- 玩家信息对话框

local Bitset = require("core/Bitset")
local DataObject = require("core/DataObject")
local CharMenuContentDlg = Singleton("CharMenuContentDlg", Dialog)

-- 该列表不影响顺序，顺序在 getMenuList中依次增加
local ButtonList = {
    [1] = {button = CHS[3002315], tag = 1},    -- 查　　看
    [2] = {button = CHS[3000057], tag = 2},    -- 交　　流
    [3] = {button = CHS[5000064], tag = 3},    -- 加为好友
    [4] = {button = CHS[3002316], tag = 4},    -- 切　　磋
    [5] = {button = CHS[3002317], tag = 5},    -- 观　　战
    [6] = {button = CHS[4000302], tag = 6},    -- 申请组队
    [7] = {button = CHS[4000303], tag = 7},    -- 邀请入帮
    [8] = {button = CHS[5000065], tag = 8},    -- 加入黑名单
    [9] = {button = CHS[3002318], tag = 9},    -- GM管理
    [10] = {button = CHS[6000268], tag = 10},  -- 提升友好度
    [11] = {button = CHS[6000426], tag = 11},  -- 备　　注
    [12] = {button = CHS[6000427], tag = 12},  -- 分          组
    [13] = {button = CHS[4100299], tag = 13},  -- 赠　　送
    [14] = {button = CHS[4300124], tag = 14},  -- 更          多
    [15] = {button = CHS[2100086], tag = 15},  -- 复制名字
    [16] = {button = CHS[2000425], tag = 16},  -- 查看空间
    [17] = {button = CHS[5400502], tag = 17},  -- 加为区域好友/删除区域好友
    [18] = {button = CHS[4300311], tag = 18},  -- 举         报
    [19] = {button = CHS[5450428], tag = 19},  -- 转移群主
}

local TEAM_BUTTON_TYPE =
{
    invite = 1,
    request = 2,
}

function CharMenuContentDlg:init()
    local mainPanel = self:getControl("InfoPanel")
    self.panelSize = self.panelSize or mainPanel:getContentSize()
    self.rootSize = self.rootSize or self.root:getContentSize()
    self.rect = nil
    self.backCharInfo = nil -- 已经有的数据，如果服务器下发， MSG_FIND_CHAR_MENU_FAIL，则显示该数据
    self.charPanelOrgSz = self:getCtrlContentSize("CharInfoPanel")
    self.remarkPanelOrgHeight = self:getCtrlContentSize("RemarkValuePanel").height
    self.showBtnCou = 1

    self:bindListener("RelationshipButton", self.onRelationshipButton)
    self:bindListener("SpouseButton", self.onSpouseButton)

    self.buttonCell = self:retainCtrl("Button1")

    self:hookMsg("MSG_FRIEND_ADD_CHAR")
    self:hookMsg("MSG_FRIEND_REMOVE_CHAR")
    self:hookMsg("MSG_CHAR_INFO")
    self:hookMsg("MSG_LOOK_PLAYER_EQUIP")
    self:hookMsg("MSG_FIND_CHAR_MENU_FAIL")
    self:hookMsg("MSG_FRIEND_MEMO")
    self:hookMsg("MSG_TEMP_FRIEND_STATE")
end

-- 菜单类型
function CharMenuContentDlg:setMuneType(type, param)
    self.muneType = type

    self.param = param
end

function CharMenuContentDlg:isFromChatGroup()
    return self.muneType == CHAR_MUNE_TYPE.GROUP_MEMBER or self.muneType == CHAR_MUNE_TYPE.GROUP_OWNER
end

-- 判断是否从好友列表中打开
function CharMenuContentDlg:setting(gid)
    self.gid = gid

    self:MSG_CHAR_INFO()
end

function CharMenuContentDlg:setInfoByDataObject(char)
    local charTemp = {}
    charTemp.id = char:queryBasicInt("id")
    charTemp.icon = char:queryBasicInt("icon")
    charTemp.gid = char:queryBasic("gid")
    charTemp.level = char:queryBasicInt("level")
    charTemp.name = char:queryBasic("name")
    charTemp.party = char:queryBasic("party")
    charTemp.vip = char:queryBasicInt("vip_type")
    charTemp.masquerade = char:queryBasicInt("masquerade")
    charTemp.alicename = char:queryBasic("alicename")
    charTemp.comeback_flag = char:queryBasicInt("comeback_flag")
    charTemp.titleInfo = char.titleInfo
    self.backCharInfo = charTemp
end

function CharMenuContentDlg:setbackCharInfo(char)
    self.backCharInfo = char
end

-- 设置player信息
function CharMenuContentDlg:setInfo(char)
    self.curChar = char
    self.gid = self.curChar.gid
    if string.isNilOrEmpty(self.curChar.party) and FriendMgr:isTempByGid(self.gid) then
        -- 若帮派信息为空，则使用临时好友数据更新一下帮派信息(是好友帮派信息不会为nil,WDSY-29692)
        self.curChar.party = FriendMgr:getTemFriendByGid(self.gid):queryBasic("party/name")
    end


    self:setImage("PortraitImage", ResMgr:getSmallPortrait(char.icon))
    self:setItemImageSize("PortraitImage")

    if char.ringScore then
        local satge, level = RingMgr:getStepAndLevelByScore(char.ringScore)
        self:setLabelText("ArenaValueLabel", RingMgr:getJobChs(satge, level))
    else
        self:setLabelText("ArenaValueLabel", "")
    end

    -- 设置备注
    self:setColorText(FriendMgr:getMemoByGid(char.gid), "RemarkValuePanel", nil, nil, nil, COLOR3.WHITE, 21)
    self:setLabelText("LineLabel", "")
    self:setCtrlVisible("LineBKImage", false)
    if char.isOnline == 2 and FriendMgr:getFriendByGid(char.gid) then
        self:setCtrlEnabled("PortraitImage", false)
    else
        self:setCtrlEnabled("PortraitImage", true)
        -- 增加线名
        if not string.isNilOrEmpty(self.curChar.serverId) and not MapMgr:isInMasquerade() then
            -- 舞会场地不显示线路
            self:setLabelText("LineLabel", self.curChar.serverId)
            self:setCtrlVisible("LineBKImage", true)
        end
    end

    local level = tonumber(char.level)
    if level and level > 0 then
        self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT, level, false, LOCATE_POSITION.LEFT_TOP, 21)
    else
        self:removeNumImgForPanel("PortraitPanel", LOCATE_POSITION.LEFT_TOP)
    end

    local nameColor = CharMgr:getNameColorByType(OBJECT_TYPE.CHAR, char.vip, nil, true)
    local realName, flagName = gf:getRealNameAndFlag(char.name)
    if self:isOperateMonsterInMasquerade() and char.alicename then
        -- 化妆舞会怪物的名称显示为别名
        realName = char.alicename
    end

    self:setLabelText("NameLabel", realName, nil, nameColor)

    if flagName then
        self:setLabelText("PartyValueLabel", flagName)
        self:setLabelText("PartyTypeLabel", CHS[2000110])
    else
        self:setLabelText("PartyValueLabel", char.party or "")
        self:setLabelText("PartyTypeLabel", CHS[5420149])
    end

    self:setLabelText("IDValueLabel", gf:getShowId(char.gid))
    self:setLabelText("FDValueLabel", FriendMgr:getFriendScore(char.gid) or char.friend_score or 0)

    -- 跨服标记
    local dist = FriendMgr:getKuafObjDist(self.gid)

    if not dist and char.dist_name and char.dist_name ~= GameMgr:getDistName() then
        -- 朋友圈中，点击其他人评论，该角色可能是跨服，但是没有好友
        dist = char.dist_name
    end

    -- 默认隐藏夫妻动作按钮
    self:setCtrlVisible("SpouseButton", false)

    if dist then
        gf:addKuafLogo(self:getControl("PortraitPanel"), true)
        self:setCtrlVisible("KuafTipLabel", true)
        self:setCtrlVisible("ServerTypeLabel", true)
        self:setCtrlVisible("ServerValueLabel", true)
        self:setCtrlVisible("FDValueLabel", false)
        self:setCtrlVisible("FDTypeLabel", false)
        self:setCtrlVisible("PartyValueLabel", false)
        self:setCtrlVisible("PartyTypeLabel", false)
        self:setCtrlVisible("ArenaValueLabel", false)
        self:setCtrlVisible("ArenaTypeLabel", false)
        self:setCtrlVisible("RelationshipButton", false)
        self:setCtrlVisible("RelationshipImage", false)
        self:setCtrlVisible("BackPlayerImage", false)

        self:setLabelText("ServerValueLabel", dist)
    else
        gf:removeKuafLogo(self:getControl("PortraitPanel"))
        self:setCtrlVisible("KuafTipLabel", false)
        self:setCtrlVisible("ServerTypeLabel", false)
        self:setCtrlVisible("ServerValueLabel", false)
        self:setCtrlVisible("PartyValueLabel", true)
        self:setCtrlVisible("PartyTypeLabel", true)
        self:setCtrlVisible("ArenaValueLabel", true)
        self:setCtrlVisible("ArenaTypeLabel", true)

        -- 好友度
        if FriendMgr:hasFriend(self.gid) then
            self:setCtrlVisible("FDValueLabel", true)
            self:setCtrlVisible("FDTypeLabel", true)
        else
            self:setCtrlVisible("FDValueLabel", false)
            self:setCtrlVisible("FDTypeLabel", false)
        end

        -- 回归标记
        self:setCtrlVisible("BackPlayerImage", char.comeback_flag == 1)

        -- 更新好友状态
        self:updateRelationShip()

        -- 化妆舞会不显示右上角加好友相关
        if MapMgr:isInMasquerade() and self.muneType == CHAR_MUNE_TYPE.SCENE then
            self:setCtrlVisible("RelationshipButton", false)
            self:setCtrlVisible("RelationshipImage", false)
        else
            self:setCtrlVisible("RelationshipButton", true)
            self:setCtrlVisible("RelationshipImage", true)
        end

        -- 同服且是夫妻则显示动作按钮
        local info = MarryMgr:getLoverInfo()
        if MarryMgr:isMarried() and info and info.gid == char.gid then
            self:setCtrlVisible("SpouseButton", true)
        end
    end

    -- 创建按钮列表
    self.showBtnCou = self:initButtonList(self:isFromChatGroup())

    self:setVisible(true)
    self:refreshDlgHeight()

    self:somethingForChild()
end

-- 子类需要做的事
function CharMenuContentDlg:somethingForChild()
end

-- 策划要求，设置完备注后，刷新界面高度
function CharMenuContentDlg:refreshDlgHeight(btnCou)
    -- 根据备注高度，重新设置CharInfoPanel的高度
    local remarkPanelHeight = math.max(self.remarkPanelOrgHeight, self:getCtrlContentSize("RemarkValuePanel").height)
    local charInfoSetHeight = self.charPanelOrgSz.height
    if remarkPanelHeight ~= self.remarkPanelOrgHeight then
        charInfoSetHeight = self.charPanelOrgSz.height - self.remarkPanelOrgHeight + remarkPanelHeight
    end

    self:setCtrlContentSize("CharInfoPanel", self.charPanelOrgSz.width, charInfoSetHeight)

    if not self.showBtnCou then
        return
    end

    -- 根据操作按钮的高度，重新计算操作Panel的显示高度
    local operatePanelSz = self:getCtrlContentSize("OperatePanel")
    local addHeight = (math.ceil(self.showBtnCou / 2) - 1) * self.buttonCell:getContentSize().height

    -- 重新设置InfoPanel与root的高度
    local rootHeight = charInfoSetHeight + operatePanelSz.height + addHeight + 10
    self:setCtrlContentSize("InfoPanel", self.rootSize.width, rootHeight)
    self.root:setContentSize(self.rootSize.width, rootHeight)
    self:updateLayout("InfoPanel")
end

function CharMenuContentDlg:initButtonList(isFromChatGroup)
    local btnMenu = self:getMenuList(isFromChatGroup)
    local panel = self:getControl("OperatePanel")
    panel:removeAllChildren()
    local columnSpace = 2  -- 列间隔
    local lineSpace = 2    -- 行间隔
    local cou = #btnMenu
    local size = self.buttonCell:getContentSize()
    local x, y = self.buttonCell:getPosition()
    for i = 1, #btnMenu do
        local btn = self.buttonCell:clone()
        btn:setTag(btnMenu[i].tag)
        btn:setTitleText(btnMenu[i].button)
        btn:setPosition(x + ((i + 1) % 2) * (size.width + columnSpace), y)
        if i % 2 == 0 then
            y = y - size.height - lineSpace
        end

        panel:addChild(btn)
        self:blindLongPress(btn, self.longChooseButton, self.chooseButton, nil, not btnMenu[i] or 4 ~= btnMenu[i].tag)
    end

    return cou
end

function CharMenuContentDlg:getMenuListByCity(isFromChatGroup)
    local menus = {}

    -- 交流
    table.insert(menus, ButtonList[2])

    -- 区域好友
    if CitySocialMgr:hasCityFriendByGid(self.curChar.gid) then
        table.insert(menus, {["button"] = CHS[5400503],["tag"] = 17})   -- 加为区域好友
    else
        table.insert(menus, {["button"] = CHS[5400502],["tag"] = 17})   -- 删除区域好友
    end

        -- 空间
    table.insert(menus, ButtonList[16])


    -- 备注
    if (FriendMgr:hasFriend(self.curChar.gid) or CitySocialMgr:hasCityFriendByGid(self.curChar.gid) or FriendMgr:isBlackByGId(self.curChar.gid)) then
        table.insert(menus, ButtonList[11])
    end

    -- 黑名单
    if FriendMgr:isBlackByGId(self.gid) then
        table.insert(menus, {["button"] = CHS[5000063], ["tag"] = 8})
    else
        if not isFromChatGroup then -- 群成员不显加入黑名单按钮
            table.insert(menus, {["button"] = CHS[5000065], ["tag"] = 8})
        end
    end

    table.insert(menus, ButtonList[18])

    return menus
end

function CharMenuContentDlg:getMenuListByKuafuBlog(isFromChatGroup)
    local menus = {}

    -- 交流
    table.insert(menus, ButtonList[2])

        -- 空间
    table.insert(menus, ButtonList[16])


    -- 备注
    if (FriendMgr:hasFriend(self.curChar.gid) or CitySocialMgr:hasCityFriendByGid(self.curChar.gid) or FriendMgr:isBlackByGId(self.curChar.gid)) then
        table.insert(menus, ButtonList[11])
    end

    -- 黑名单
    if FriendMgr:isBlackByGId(self.gid) then
        table.insert(menus, {["button"] = CHS[5000063], ["tag"] = 8})
    else
        if not isFromChatGroup then -- 群成员不显加入黑名单按钮
            table.insert(menus, {["button"] = CHS[5000065], ["tag"] = 8})
        end
    end

    table.insert(menus, ButtonList[18])

    return menus
end

function CharMenuContentDlg:getMenuList(isFromChatGroup)
    local menus = {}

    if self.muneType == CHAR_MUNE_TYPE.CITY then
        return self:getMenuListByCity(isFromChatGroup)
    elseif self.muneType == CHAR_MUNE_TYPE.KUAFU_BLOG then
        return self:getMenuListByKuafuBlog(isFromChatGroup)
    end

    -- 社区的跨服菜单
    if FriendMgr:getKuafObjDist(self.gid) then
        -- 交流
        table.insert(menus, ButtonList[2])

        -- 区域好友
        if CitySocialMgr:hasCityFriendByGid(self.gid) then
            table.insert(menus, {["button"] = CHS[5400503],["tag"] = 17})
        else
            table.insert(menus, {["button"] = CHS[5400502],["tag"] = 17})
        end

        -- 黑名单
        if FriendMgr:isBlackByGId(self.gid) then
            table.insert(menus, {["button"] = CHS[5000063], ["tag"] = 8})
        else
            if not isFromChatGroup then -- 群成员不显加入黑名单按钮
                table.insert(menus, {["button"] = CHS[5000065], ["tag"] = 8})
            end
        end

        if CitySocialMgr:hasCityFriendByGid(self.gid) or FriendMgr:isBlackByGId(self.gid) then
            table.insert(menus, ButtonList[11])
        end

        return menus
    end

    -- 查看
    table.insert(menus, ButtonList[1])

    -- 交流
    table.insert(menus, ButtonList[2])

    if self.muneType == CHAR_MUNE_TYPE.GROUP_OWNER then
        -- 从群组打开-群主
        table.insert(menus, ButtonList[19])
    end

    local name = self.curChar.name
    -- 好友
    if not (MapMgr:isInMasquerade() and self.muneType == CHAR_MUNE_TYPE.SCENE) then
        if FriendMgr:hasFriend(self.gid) then
            if not isFromChatGroup then -- 群成员不显示删除按钮
                table.insert(menus, {["button"] = CHS[5000062],["tag"] = 3})
            end
        else
            table.insert(menus, {["button"] = CHS[5000064],["tag"] = 3})
        end
    end

    -- 组队
    if TeamMgr:inTeamEx(Me:getId()) == false and
            (self:isOperateMonsterInMasquerade() or (self.curChar.charStatus and self.curChar.charStatus:isSet(CHAR_STATUS.IN_TEAM))) == true then
        -- Me为单人，对方为队伍中  申请组队
        table.insert(menus, {["button"] = CHS[4000276],["tag"] = 6})
        self.teamButtonType = TEAM_BUTTON_TYPE.request
    elseif TeamMgr:getLeaderId() == Me:getId() then
        -- Me为队长
        table.insert(menus, {["button"] = CHS[4000275],["tag"] = 6})
        self.teamButtonType = TEAM_BUTTON_TYPE.invite
    elseif not TeamMgr:inTeamEx(Me:getId()) and
            (self:isOperateMonsterInMasquerade() or (self.curChar.charStatus and not self.curChar.charStatus:isSet(CHAR_STATUS.IN_TEAM))) then
        -- 双方都是单人 邀请
        table.insert(menus, {["button"] = CHS[4000275],["tag"] = 6})
        self.teamButtonType = TEAM_BUTTON_TYPE.invite
    end

    -- 空间
    table.insert(menus, ButtonList[16])

    -- 切磋
    if not isFromChatGroup then  -- 群成员不显示切磋按钮
        table.insert(menus, ButtonList[4])
    end

    -- 观战
    if ((self:isOperateMonsterInMasquerade() and self.backCharInfo and self.backCharInfo.titleInfo[Const.TITLE_IN_COMBAT]) or
        (self.curChar.charStatus and (self.curChar.charStatus:isSet(CHAR_STATUS.IN_COMBAT) == true or self.curChar.charStatus:isSet(CHAR_STATUS.IN_LOOKON) == true)) and
        self.muneType == CHAR_MUNE_TYPE.SCENE) then
        table.insert(menus, ButtonList[5])
    end

    -- 帮派
    if not (MapMgr:isInMasquerade() and self.muneType == CHAR_MUNE_TYPE.SCENE) then
        if Me:queryBasic("party/name") ~= "" and string.isNilOrEmpty(self.curChar.party)
            and (not string.isNilOrEmpty(self.curChar.isOnline) and self.curChar.isOnline ~= 2) then
            -- 我有帮派，对方没有帮派，邀请入帮（且我有招收帮派成员的权限），且该玩家不处于离线状态(离线状态不能邀请入帮，服务器会提示无法邀请)
            if PartyMgr:checkAgreeOrDenyApply() then
                table.insert(menus, {["button"] = CHS[4000303],["tag"] = 7})
            end
        elseif Me:queryBasic("party/name") == "" and not string.isNilOrEmpty(self.curChar.party) then
            -- 对方有帮派，我没有帮派，申请入帮
            table.insert(menus, {["button"] = CHS[4000319],["tag"] = 7})
        end
    end

    if GMMgr:isGM() then
        table.insert(menus, {["button"] = CHS[3002320],["tag"] = 9})
    end

    -- 分组
    if FriendMgr:hasFriend(self.gid) and not isFromChatGroup and not (MapMgr:isInMasquerade() and self.muneType == CHAR_MUNE_TYPE.SCENE)  then
        table.insert(menus, ButtonList[12])
    end

    -- 更多
    if not isFromChatGroup and not (MapMgr:isInMasquerade() and self.muneType == CHAR_MUNE_TYPE.SCENE) then
        table.insert(menus, ButtonList[14])
    end

    return menus
end

function CharMenuContentDlg:getMoreCount(isFromChatGroup)
    local count = 0
    -- 赠送
    if not isFromChatGroup then  -- 群成员不显赠送度按钮
        count = count + 1
    end

    -- 提升友好度
    if not isFromChatGroup then -- 群成员不显提升友好度按钮
        count = count + 1
    end

    -- 备注
    if (FriendMgr:hasFriend(self.gid) or FriendMgr:isBlackByGId(self.gid))
        and not isFromChatGroup then
        count = count + 1
    end

    -- 黑名单
    if FriendMgr:isBlackByGId(self.gid) then
        count = count + 1
    else
        if not isFromChatGroup then -- 群成员不显加入黑名单按钮
            count = count + 1
        end
    end

    -- 赋值名字
    count = count + 1

    -- 居所
    count = count + 1


    return count
end

function CharMenuContentDlg:longChooseButton(sender, eventType)
    local tag = sender:getTag()
    if 4 == tag then
        self:onFightButton(true)
        self:onCloseButton()
    end
end

function CharMenuContentDlg:chooseButton(sender, eventType)
    if not self.curChar then return end
    local tag = sender:getTag()
    if tag == 1 then
        self:onViewEquipmentButton()
    elseif tag == 2 then
        self:onCommunicatButton()
        self:onCloseButton()
    elseif tag == 3 then
        self:onAddFriendButton(self.curChar)
        self:onCloseButton()
    elseif tag == 4 then
        self:onFightButton()
        self:onCloseButton()
    elseif tag == 5 then
        self:onLookonButton()
        self:onCloseButton()
    elseif tag == 6 then
        self:onTeamButton()
        self:onCloseButton()
    elseif tag == 7 then
        self:onPartyButton()
        self:onCloseButton()
    elseif tag == 8 then
        self:onAddBlacklistButton()
        self:onCloseButton()
    elseif tag == 9 then
        local dlg = DlgMgr:openDlg("GMUserManageDlg")
        local data = {account = self.curChar.account, name = self.curChar.name, gid = self.curChar.gid, level = self.curChar.level, polar = self.curChar.polar}
        dlg:setUser(data)
        GMMgr:cmdQueryByPlayer(self.curChar.name, "name")
    elseif tag == 10 then
        self:sendToFriend(self.curChar)
    elseif tag == 11 then -- 备注
        self:remark(self.curChar)
    elseif tag == 12 then -- 分组
        self:friendGroup(self.curChar)
    elseif tag == 13 then
        self:givingThings(self.curChar)
    elseif tag == 14 then
        -- 更多
        self:theMore(self.curChar, self:isFromChatGroup())
    elseif tag == 15 then
        -- 复制名字
        gf:copyTextToClipboard(self.curChar and self.curChar.name or "")
        gf:ShowSmallTips(CHS[2100087])
    elseif tag == 16 then
        -- 个人空间
        BlogMgr:openBlog(self.curChar.gid, nil, nil, self.curChar.dist_name)
        self:onCloseButton()
    elseif tag == 17 then
        self:onAddCityFriendButton()
        self:onCloseButton()
    elseif tag == 18 then
        self:onJubao(self.curChar)
        self:onCloseButton()
    elseif tag == 19 then
        self:onChangeGroupOwner(self.curChar)
        self:onCloseButton()
    else
        self:onClickButton(sender)
        self:onCloseButton()
    end
end

function CharMenuContentDlg:onClickButton(sender)
end

-- 关系（心按钮）
function CharMenuContentDlg:onRelationshipButton(sender)
    if not self.curChar then return end

    if FriendMgr:hasFriend(self.gid) then
       -- gf:showTipInfo(CHS[3002321] .. (self.curChar.friend_score or 0), sender)
        self:setCtrlVisible("FDValueLabel", true)
    else
        local char = self.curChar
        gf:confirm(CHS[3002322], function() self:onAddFriendButton(char) end)
    end
end

function CharMenuContentDlg:onSpouseButton(sender)
    if not self.curChar then return end

    local rect = self:getBoundingBoxInWorldSpace(self.root)

    local dlg = DlgMgr:openDlg("SpouseDlg")
    dlg:setData(self.curChar)
    dlg:setFloatingFramePos(rect)
end

-- 查看装备
function CharMenuContentDlg:onViewEquipmentButton()
    if self:isOperateMonsterInMasquerade() then
        gf:ShowSmallTips(CHS[7002121])
        return
    end

    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_LOOK_PLAYER_EQUIP, self.curChar.gid)
end

-- 查看界面返回数据
function CharMenuContentDlg:MSG_LOOK_PLAYER_EQUIP(data)
    self:onCloseButton()
end

-- 交流
function CharMenuContentDlg:onCommunicatButton()
    if self:isOperateMonsterInMasquerade() and self.backCharInfo then
        local charInfo = self.backCharInfo
        FriendMgr:communicat(charInfo.alicename, charInfo.gid, charInfo.icon, charInfo.level, true, charInfo.dist_name)
    else
        FriendMgr:communicat(self.curChar.name, self.curChar.gid, self.curChar.icon, self.curChar.level, true, self.curChar.dist_name)
    end
end

-- 加为好友
function CharMenuContentDlg:onAddFriendButton(char)
    local name = char.name
    local gid = self.gid or char.gid
    if not name or not gid then return end

    if FriendMgr:hasFriend(gid) then
        -- 如果已经是己方好友
        local str = string.format(CHS[5000060], name)

        gf:confirm(str, function()
            FriendMgr:deleteFriend(name, gid)
        end)

    else
        FriendMgr:addFriendCheck(char)
    end

    DlgMgr:closeDlg(self.name)
end

-- 添加/删除区域好友
function CharMenuContentDlg:onAddCityFriendButton()
    local name = self.curChar.name
    if nil == name then return end

    CitySocialMgr:tryToAddCityFriend(name, self.gid, self.curChar.isOnline)
end

-- 切磋
function CharMenuContentDlg:onFightButton(isPk)
    if GameMgr:IsCrossDist() and not DistMgr:isInZBYLServer() and not DistMgr:isInQcldServer() and not QuanminPK2Mgr:isCanFightInQuanmpk() and not DistMgr:isInKFZC2019Server() then
        gf:ShowSmallTips(CHS[5000267])
        return
    end

    if Me:isInPrison() then
        gf:ShowSmallTips(CHS[7000070])
        return
    end

    if self:isOperateMonsterInMasquerade() and self.backCharInfo then
        gf:CmdToServer("CMD_KILL", {victim_id = self.backCharInfo.id, flag = (isPk and 1 or 0), gid = (self.backCharInfo.gid or "") })
        return
    end

    if not self.curChar then return end
    if self.curChar.id then
        gf:CmdToServer("CMD_KILL", {victim_id = self.curChar.id, flag = (isPk and 1 or 0), gid = (self.curChar.gid or "") })
    else
        gf:ShowSmallTips(CHS[3000118])
    end
end

-- 观战
function CharMenuContentDlg:onLookonButton()
    if self:isOperateMonsterInMasquerade() and self.backCharInfo then
        FightMgr:lookFight(self.backCharInfo.id)
        return
    end

    if not self.curChar.id then return end
    FightMgr:lookFight(self.curChar.id)
end

-- 组队
function CharMenuContentDlg:onTeamButton()
    if Me:isInPrison() then
        gf:ShowSmallTips(CHS[7000071])
        return
    end

    if self:isOperateMonsterInMasquerade() and self.teamButtonType and self.backCharInfo then
        if self.teamButtonType == TEAM_BUTTON_TYPE.invite then

            if TaskMgr:isInTaskBKTX() then
                gf:ShowSmallTips(CHS[4010222])
                return
            end


            gf:CmdToServer("CMD_REQUEST_JOIN", {
                peer_name = self.backCharInfo.name,
                id = self.backCharInfo.id,
                ask_type = Const.INVITE_JOIN_TEAM,
            })
            return
        elseif self.teamButtonType == TEAM_BUTTON_TYPE.request then
            gf:CmdToServer("CMD_REQUEST_JOIN", {
                peer_name = self.backCharInfo.name,
                id = self.backCharInfo.id,
                ask_type = Const.REQUEST_JOIN_TEAM,
            })
            return
        end
    end

    if not self.curChar then return end
    if Me:isTeamLeader() then

        if TaskMgr:isInTaskBKTX() then
            gf:ShowSmallTips(CHS[4010222])
            return
        end

        gf:CmdToServer("CMD_REQUEST_JOIN", {
            peer_name = self.curChar.name,
            id = self.curChar.id,
            ask_type = Const.INVITE_JOIN_TEAM,
        })
        return
    end

    if not self.curChar.charStatus then return end

    if not self.curChar.charStatus:isSet(CHAR_STATUS.IN_TEAM) then
        if TaskMgr:isInTaskBKTX() then
            gf:ShowSmallTips(CHS[4010222])
            return
        end

        gf:CmdToServer("CMD_REQUEST_JOIN", {
            peer_name = self.curChar.name,
            id = self.curChar.id,
            ask_type = Const.INVITE_JOIN_TEAM,
        })
    else
        gf:CmdToServer("CMD_REQUEST_JOIN", {
            peer_name = self.curChar.name,
            id = self.curChar.id,
            ask_type = Const.REQUEST_JOIN_TEAM,
        })
    end
end

-- 邀请入帮
function CharMenuContentDlg:onPartyButton()
    if not self.curChar.party then return end
    if Me:queryBasic("party/name") == "" and not string.isNilOrEmpty(self.curChar.party) then
        -- 对方有帮派，我没有帮派，申请入帮
        PartyMgr:addParties(self.curChar.party)
        self:onCloseButton()
        return
    end
    PartyMgr:inviteJionParty(self.curChar.name)
    self:onCloseButton()
end

-- 加入黑名单
function CharMenuContentDlg:onAddBlacklistButton()
    local name = self.curChar.name
    if nil == name then return end

    if FriendMgr:isBlackByGId(self.gid) then
        FriendMgr:deleteFromBlack(self.gid)
    else
        local curChar = self.curChar
        local gid = self.gid

        if FriendMgr:hasFriend(self.gid) then
            local str = string.format(CHS[5000061], name)
            gf:confirm(str, function()
                FriendMgr:addBlack(name, curChar.icon, curChar.level, gid, curChar.dist_name)
            end)
        else
            FriendMgr:addBlack(name, curChar.icon, curChar.level, gid, curChar.dist_name)
        end
    end
end

-- 更新加好友和黑名单按钮
function CharMenuContentDlg:updateFriendButton()
    if not self.curChar then return end
    local name = self.curChar.name
    if FriendMgr:hasFriend(self.gid) then
        self:setButtonText("AddFriendButton", CHS[5000062])
    else
        self:setButtonText("AddFriendButton", CHS[5000064])
    end

    if FriendMgr:isBlackByGId(self.gid) then
        self:setButtonText("AddFriendButton", CHS[5000063])
    else
        self:setButtonText("AddFriendButton", CHS[5000065])
    end
end

-- 提升友好度
function CharMenuContentDlg:sendToFriend(friend)
    if not FriendMgr:hasFriend(friend.gid) then
        gf:ShowSmallTips(string.format(CHS[6000269], friend.name))
        return
    elseif friend.isOnline  == 2 then
        gf:ShowSmallTips(CHS[6000270])
        return
    end

    if not FriendMgr:hasUpdateCharInfo(friend.gid) then
        gf:ShowSmallTips(CHS[2200064])
        return
    end

    if friend.isInThereFrend == 1 then
        local dlg = DlgMgr:openDlgEx("SubmitFDIDlg", friend.gid)
    else
        gf:ShowSmallTips(string.format(CHS[4200168], friend.name))
    end
end


function CharMenuContentDlg:onChangeGroupOwner(char)
    if not char then return end

    if not self.param or not self.param.groupId then return end

    gf:CmdToServer("CMD_CHANGE_CHAT_GROUP_LEADER", {changer_gid = char.gid, group_id = self.param.groupId})
end

-- 更多
function CharMenuContentDlg:theMore(char, isFromChatGroup)
    if self:getMoreCount(isFromChatGroup) == 0 then return end
    local dlg = DlgMgr:openDlg("MoreCharMenuDlg")
    dlg:getMenu(char, isFromChatGroup)

    local dlgRect = self:getBoundingBoxInWorldSpace(dlg.root)
    local rect = self:getBoundingBoxInWorldSpace(self.root)

    if rect.x + rect.width + dlgRect.width > Const.WINSIZE.width then
        dlg.root:setPosition(rect.x - dlgRect.width, rect.y + rect.height)
    else
        dlg.root:setPosition(rect.x + rect.width, rect.y + rect.height)
    end
end

-- 备注
function CharMenuContentDlg:remark(friend)
    local dlg = DlgMgr:openDlg("RemarksDlg")
    dlg:onDlgOpened(friend.gid)
end

-- 分组
function CharMenuContentDlg:friendGroup(friend)
    local rect = self.root:getBoundingBox()
    local rect = self:getBoundingBoxInWorldSpace(self.root)
    local gidsStr = friend.gid .. ";"
    local nameStr = friend.name .. ";"

    if FriendMgr:getFriendGroupCount() <= 1 then
        gf:ShowSmallTips(CHS[6000443])
        return
    end

    local dlg = DlgMgr:openDlg("SingleFlockMoveDlg")
    local group = FriendMgr:getFriendByGid(friend.gid)
    dlg:setMoveGidsString(group:queryBasic("group"), gidsStr, nameStr)
    dlg.root:setPosition(rect.x + rect.width, rect.y)
end

-- 赠送
function CharMenuContentDlg:givingThings(friend)
    if not DistMgr:checkCrossDist() then return end

    GiveMgr:tryRequestGiving(friend)
    self:onCloseButton()
end

function CharMenuContentDlg:MSG_FRIEND_ADD_CHAR(data)
    self:updateFriendButton()
end

function CharMenuContentDlg:MSG_FRIEND_REMOVE_CHAR(data)
    self:updateFriendButton()
end

function CharMenuContentDlg:MSG_CHAR_INFO()
    if nil == self.gid then return end
    local data = FriendMgr:getCharMenuInfoByGid(self.gid)
    if nil == data then return end

    self.curChar = data
    self.curChar.settingFlag = Bitset.new(data.setting_flag)

    self.curChar.charStatus = Bitset.new(data.char_status)
    self:setInfo(self.curChar)
    self:updateRelationShip()
    self:setVisible(true)
    if self.rect then
        self:setFloatingFramePos(self.rect)
    end
end

function CharMenuContentDlg:MSG_FIND_CHAR_MENU_FAIL(data)
    if self.backCharInfo then
        local friend = FriendMgr:getFriendByGid(self.backCharInfo.gid)
        if friend then
            self.backCharInfo.friend_score = friend:queryInt("friend")
            self.backCharInfo.party = friend:queryBasic("party/name")
        end
        self.backCharInfo.isOnline = 2
        self:setInfo(self.backCharInfo)
    end

    if self.curChar then
        self.curChar.isOnline = 2
        self:setInfo(self.curChar)
    end

    gf:ShowSmallTips(CHS[3003112])
    self:setCtrlEnabled("PortraitImage", false)
    self:setLabelText("LineLabel", "")
    self:setCtrlVisible("LineBKImage", false)
end

-- setFloatingFramePos
function CharMenuContentDlg:setFloatingFramePos(rect)
    self.rect = rect
    Dialog.setFloatingFramePos(self, rect)
end

-- 更新好友状态
function CharMenuContentDlg:updateRelationShip()
    local file = ""
    if FriendMgr:hasFriend(self.gid) then
        file = ResMgr.ui.friend_heart_filled
    else
        file = ResMgr.ui.friend_heart_empty
    end
    self:setImage("RelationshipImage", file)
end

-- 更新备注
function CharMenuContentDlg:MSG_FRIEND_MEMO()
    if not self.curChar then return end
    self:setColorText(FriendMgr:getMemoByGid(self.curChar.gid), "RemarkValuePanel", nil, nil, nil, COLOR3.WHITE, 21)
    self:updateLayout("CharInfoPanel")
    self:refreshDlgHeight()
end

function CharMenuContentDlg:isOperateMonsterInMasquerade()
    -- 化妆舞会下与怪物交互，并特殊处理与怪物交互的相关按钮响应（查看、交流、组队、切磋、观战）
    if MapMgr:isInMasquerade() and self.backCharInfo and self.backCharInfo.masquerade == 1 then
        return true
    end
end

function CharMenuContentDlg:setMonsterInMasqueradeInfo()
    self:setInfo(self.backCharInfo)
end

function CharMenuContentDlg:MSG_TEMP_FRIEND_STATE(data)
    if not self.curChar or self.curChar.gid ~= data.gid then return end

    if data.online == 2 then
        gf:ShowSmallTips(CHS[3003112])
        self:setCtrlEnabled("PortraitImage", false)
    end

    self.curChar.isOnline = data.online
end

function CharMenuContentDlg:cleanup()
    self.curChar = nil
    self.muneType = nil

    DlgMgr:closeDlg("SpouseDlg")
end

function CharMenuContentDlg:onJubao(char)
    local function doIt()
        if Me:queryInt("level") < 35 then
            gf:ShowSmallTips(CHS[4300312])
            self:onCloseButton()
            return
        end

        local data = {}
        data.user_gid = char.gid
        data.user_name = char.name
        data.type = "dlg"
        data.content = {}
        data.count = 0
        data.user_dist = char.dist_name
        if not data.user_dist or data.user_dist == "" then
            data.user_dist = GameMgr:getDistName()
        end

        gf:CmdToServer("CMD_REPORT_USER", data)
        self:onCloseButton()
        return
    end

    if ChatMgr.hasTipOffUser[char.gid] and ChatMgr.hasTipOffUser[char.gid] == 1 then
        if not FriendMgr:isBlackByGId(char.gid) then
            gf:confirm(string.format(CHS[4300318], char.name), function()
                FriendMgr:addBlack(char.name, char.icon, char.level, char.gid, char.user_dist)
            end, function ()
                doIt()
            end)
            self:onCloseButton()
            return
        else
            doIt()
        end
    else
        doIt()
    end
end

return CharMenuContentDlg
