-- MoreCharMenuDlg.lua
-- Created by songcw Oct/12/2016
-- 玩家信息对话框-更多

local MoreCharMenuDlg = Singleton("MoreCharMenuDlg", Dialog)

local MAGAN_X = 5
local MAGAN_Y = 2

local ButtonList = {
    [1] = {button = CHS[4100299], tag = 1, longPress = true},    -- 赠　　送
    [2] = {button = CHS[6000268], tag = 2},    -- 提升友好度
    [3] = {button = CHS[6000426], tag = 3},    -- 备　　注
    [4] = {button = CHS[5000065], tag = 4},    -- 加入黑名单
    [5] = {button = CHS[4101106], tag = 5},    -- 复制名字
    [7] = {button = CHS[2100099], tag = 7},    -- 查看居所
    [8] = {button = CHS[4300311], tag = 8},  -- 举         报
}

--
MoreCharMenuDlg.tipOffUser = {}

function MoreCharMenuDlg:init()
    --self:bindListener("Button13", self.onButton13)
    self.btnCell = self:getControl("Button")
    self.x, self.y = self.btnCell:getPosition()
    self.btnCell:retain()
    self.btnCell:removeFromParent()
    self.btnCell:setTitleText("")

    self.menus = {}
    self.char = nil
    self.size = self.size or self:getControl("MorePanel"):getContentSize()

    self.root:setAnchorPoint(0, 1)

    self:hookMsg("MSG_CHAR_INFO")
    self:hookMsg("MSG_GIVING_RECORD")
end

function MoreCharMenuDlg:cleanup()
    self:releaseCloneCtrl("btnCell")
end

function MoreCharMenuDlg:closeCharDlg()
    DlgMgr:closeDlg("CharMenuContentDlg")
    self:onCloseButton()
end

function MoreCharMenuDlg:getMenu(char, isFromChatGroup)
    if not char then return end

    self.char = char
    -- 赠送
    if not isFromChatGroup then  -- 群成员不显赠送度按钮
        table.insert(self.menus, ButtonList[1])
    end
    --
    -- 提升友好度
    if not isFromChatGroup then -- 群成员不显提升友好度按钮
        table.insert(self.menus, ButtonList[2])
    end

    -- 备注
    if (FriendMgr:hasFriend(char.gid) or CitySocialMgr:hasCityFriendByGid(char.gid) or FriendMgr:isBlackByGId(char.gid))
        and not isFromChatGroup then
        table.insert(self.menus, ButtonList[3])
    end

    -- 黑名单
    if FriendMgr:isBlackByGId(char.gid) then
        table.insert(self.menus, {["button"] = CHS[5000063],["tag"] = 4})
    else
        if not isFromChatGroup then -- 群成员不显加入黑名单按钮
            table.insert(self.menus, {["button"] = CHS[5000065],["tag"] = 4})
        end
    end

    table.insert(self.menus, ButtonList[5])
    table.insert(self.menus, ButtonList[7])
    table.insert(self.menus, ButtonList[8])

    local morePanel = self:getControl("MorePanel")
    local newSize = {width = 0, height = 0}
    local panel = self:getControl("MainPanel")

    if #self.menus > 1 then
        newSize.width = self.size.width + self.btnCell:getContentSize().width + MAGAN_X
        local line = math.floor((#self.menus - 1) / 2) + 1
        if line > 1 then newSize.height = self.size.height + (self.btnCell:getContentSize().height + MAGAN_Y) * (line - 1) end
        morePanel:setContentSize(newSize)
        self.root:setContentSize(newSize)

        morePanel:requestDoLayout()
        self.root:requestDoLayout()
        panel:setAnchorPoint(0, 1)
        panel:setPosition(8, newSize.height - 8)
    end

    for i, info in pairs(self.menus) do
        local x = self.x
        if i % 2 == 0 then x = x + self.btnCell:getContentSize().width + MAGAN_X end

        local line2 = math.floor((i - 1) / 2)
        local y = self.y - line2 * (self.btnCell:getContentSize().height + MAGAN_Y)

        local btn = self.btnCell:clone()
        btn:setTag(self.menus[i].tag)
        btn:setTitleText(self.menus[i].button)
        btn:setPosition(x, y)
        panel:addChild(btn)

        self:blindLongPress(btn, self.onLongPressButton, self.onButton, nil, not self.menus[i].longPress)
    end
end

function MoreCharMenuDlg:onLongPressButton(sender, eventType)
    if not self.char then return end

    local tag = sender:getTag()
    if tag == 1 then
        -- DlgMgr:openDlg("GiveRecordDlg")
        gf:CmdToServer("CMD_GIVING_RECORD", {gid = self.char.gid, name = self.char.name})
        -- self:closeCharDlg()
    end
end

function MoreCharMenuDlg:onButton(sender, eventType)
    if not self.char then return end

    local tag = sender:getTag()
    if tag == 1 then
        self:givingThings(self.char)
        self:closeCharDlg()
    elseif tag == 2 then
        self:sendToFriend(self.char)
        self:closeCharDlg()
    elseif tag == 3 then
        self:remark(self.char)
    elseif tag == 4 then
        self:onAddBlacklistButton(self.char)
        self:closeCharDlg()
    elseif tag == 5 then
        self:copyCard(self.char)
    elseif tag == 7 then
        if GameMgr:IsCrossDist() then
            gf:ShowSmallTips(CHS[5000267])
        else
            -- 请求居所信息
            HomeMgr:showHomeData(self.char.gid, HOUSE_QUERY_TYPE.QUERY_BY_CHAR_GID)
        end

        self:closeCharDlg()
    elseif tag == 8 then
        self:onJubao(self.char)

    end
end

function MoreCharMenuDlg:onJubao(char)

    local function doIt()
        if Me:queryInt("level") < 35 then
            gf:ShowSmallTips(CHS[4300312])
            self:closeCharDlg()
            return
        end

        ChatMgr:questOpenReportDlg(self.char.gid, self.char.name, self.char.dist_name)
        self:closeCharDlg()
        return
    end

    if ChatMgr.hasTipOffUser[char.gid] and ChatMgr.hasTipOffUser[char.gid] == 1 then
        if not FriendMgr:isBlackByGId(char.gid) then
            gf:confirm(string.format(CHS[4300318], char.name), function()
                FriendMgr:addBlack(char.name, char.icon, char.level, char.gid)
            end, function ()
                doIt()
            end)
            self:closeCharDlg()
            return
        else
            doIt()
        end
    else
        doIt()
    end
end

-- 提升友好度
function MoreCharMenuDlg:sendToFriend(friend)
    if not FriendMgr:hasFriend(friend.gid) then
        gf:ShowSmallTips(string.format(CHS[6000269], gf:getRealName(friend.name)))
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
        gf:ShowSmallTips(string.format(CHS[4200168], gf:getRealName(friend.name)))
    end
end

-- 加入黑名单
function MoreCharMenuDlg:onAddBlacklistButton(friend)
    local name = friend.name
    local gid = friend.gid
    if not name or not gid then return end

    local icon = friend.icon
    local level = friend.level
    if FriendMgr:isBlackByGId(gid) then
        FriendMgr:deleteFromBlack(friend.gid)
    else
        if FriendMgr:hasFriend(gid) then
            local str = string.format(CHS[5000061], gf:getRealName(name))
            gf:confirm(str, function()
                FriendMgr:addBlack(name, icon, level, friend.gid)
            end)
        else
            FriendMgr:addBlack(name, icon, level, friend.gid)
        end
    end
end

-- 备注
function MoreCharMenuDlg:remark(friend)
    local dlg = DlgMgr:openDlg("RemarksDlg")
    dlg:onDlgOpened(friend.gid)
end

-- 赠送
function MoreCharMenuDlg:givingThings(friend)
    GiveMgr:tryRequestGiving(friend)
end

-- 复制名字
function MoreCharMenuDlg:copyName(friend)
    if not friend then return end
    gf:copyTextToClipboard(friend.name or "")
    gf:ShowSmallTips(CHS[2100087])
end

-- 复制名片
function MoreCharMenuDlg:copyCard(friend)
    if not friend then return end
    gf:ShowSmallTips(CHS[4101107])


    local sendInfo = string.format("{\t%s=%s=%s}", friend.name, CHS[4101110], "charCard:" .. friend.gid)
    local showInfo = string.format(string.format(CHS[4101137], friend.name))
    local copyInfo = friend.name
    gf:copyTextToClipboardEx(copyInfo, {copyInfo = copyInfo, showInfo = showInfo, sendInfo = sendInfo})
end

function MoreCharMenuDlg:MSG_GIVING_RECORD(data)
    local dlg = DlgMgr:openDlg("GiveRecordDlg")
    dlg:setData(data)

    self:closeCharDlg()
end

function MoreCharMenuDlg:MSG_CHAR_INFO()
    if not self.char or not self.char.gid then return end
    local data = FriendMgr:getCharMenuInfoByGid(self.char.gid)
    if nil == data then return end

    self.char = data
end

return MoreCharMenuDlg
