-- JiaoSx2Dlg.lua
-- Created by
--

local JiaoSx2Dlg = Singleton("JiaoSx2Dlg", Dialog)


local FAMILY_ICON = {

    [CHS[3000881]] = 06052,
    [CHS[3000911]] = 06053,
    [CHS[3000918]] = 06054,
    [CHS[3000904]] = 06055,
    [CHS[3000926]] = 06056,
}


function JiaoSx2Dlg:init()
    self:bindListener("YouJiButton", self.onYouJiButton)
    self:bindListener("ZenSongButton", self.onZenSongButton)

    self:hookMsg("MSG_MY_APPENTICE_INFO")
    self:updateData()
end

function JiaoSx2Dlg:updateData()
    local teacher = MasterMgr:getMyTeacherInfo()

    if teacher then
        self:setCtrlVisible("BKImage1", false, "DaoImage")
        self:setPortrait("DaoPanel", teacher.icon, 0, nil, nil, nil, nil, nil, teacher.icon, nil, nil)
        self:setLabelText("NameLabel", teacher.name, "DaoImage")
    else
        self:removePortrait("DaoPanel")
        self:setCtrlVisible("BKImage1", true, "DaoImage")
        self:setLabelText("NameLabel", CHS[4010128], "DaoImage")
    end

    self:setCtrlEnabled("YouJiButton", teacher ~= nil)

    if Me:queryBasic("family") == "" then
        -- 哪个不走寻常路的玩家就是不拜入师门，怎么办？所以特殊处理一下
        self:setLabelText("NameLabel", CHS[4010129], "NpcImage")
    else
        local familyLeader = gf:getPolarNPC(Me:queryBasicInt("polar"))
        self:setCtrlVisible("BKImage1", false, "NpcImage")
        self:setPortrait("NpcPanel", FAMILY_ICON[familyLeader], 0, nil, nil, nil, nil, nil, FAMILY_ICON[familyLeader], nil, nil)
        self:setLabelText("NameLabel", familyLeader, "NpcImage")
    end
    self:setCtrlEnabled("ZenSongButton", Me:queryBasic("family") ~= "")
end

function JiaoSx2Dlg:onYouJiButton(sender, eventType, isCon)

    if not isCon then
        gf:confirm(CHS[4010133], function ( )
            -- body
            self:onYouJiButton(sender, eventType, true)
        end)
        return
    end

    local item = InventoryMgr:getItemByClass(ITEM_CLASS.BAIHE_HUA)[1]
    if not item then return end


    if not DistMgr:checkCrossDist() then return end

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(item) then
        InventoryMgr:notifyItemTimeout(item)
        self:close()
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002958])
        return
    end

    local limitLevel = 30
    if Me:queryInt("level") < limitLevel then
        gf:ShowSmallTips(string.format(CHS[3004067], limitLevel))
        return
    end

    local friends = FriendMgr:getFriends()
    if not friends or #friends == 0 then
        gf:ShowSmallTips(CHS[6200084])
        return
    end

    local teacher = MasterMgr:getMyTeacherInfo()
    if not teacher then
        gf:ShowSmallTips(CHS[4101104])
        return
    end

    local friend =  FriendMgr:convertToUserData(FriendMgr:getFriendByGid(teacher.gid))
    if not friend then return end   -- 好友已经不存在
    if 1 ~= friend.isOnline then
        gf:ShowSmallTips(CHS[6200080])
        return
    end


    local data = {}
    data.pos = item.pos
    data.amount = 1
    data.gid = teacher.gid
    data.name = teacher.name

    gf:CmdToServer("CMD_MAILING_ITEM", data)
    self:onCloseButton()
end

function JiaoSx2Dlg:onZenSongButton(sender, eventType)
    AutoWalkMgr:beginAutoWalk(gf:findDest(string.format("#P%s|$0#P", gf:getPolarNPC(Me:queryBasicInt("polar")))))
    self:onCloseButton()
end

function JiaoSx2Dlg:MSG_MY_APPENTICE_INFO(data)
    self:updateData()
end


return JiaoSx2Dlg
