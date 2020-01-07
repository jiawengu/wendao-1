-- ShengxdjDlg.lua
-- Created by songcw Jan/14/2019
-- 生肖对决游戏界面

-- 消息相关详细说明见 WDSY-33932

local ShengxdjDlg = Singleton("ShengxdjDlg", Dialog)


local EggPath = ResMgr.ui.sxdj_egg

-- 编号对应的位置
local NO_TO_POS = {
    [1]  = {x = 408 + 72, y = 298 + 36}
}

local LEFT_CHAR_POS = cc.p(552, 504)
local RIGHT_CHAR_POS = cc.p(1164, 180)

local EGG_TYPE = {
    [1] = {icon = 6183, name = CHS[3001773], pow = 6,isPet = true},          -- 酷酷龙
    [2] = {icon = 6181, name = CHS[3001767], pow = 5,isPet = true},          -- 威威虎
    [3] = {icon = 6180, name = CHS[3001762], pow = 4,isPet = true},          -- 笨笨牛
    [4] = {icon = 6185, name = CHS[3001779], pow = 3,isPet = true},          -- 溜溜马
    [5] = {icon = 6178, name = CHS[3001786], pow = 2,isPet = true},          -- 招财猪
    [6] = {icon = 6177, name = CHS[3001784], pow = 1,isPet = true},          -- 乖乖狗
    [7] = {icon = ResMgr.ui.sxdj_zd},                                -- 炸弹
    [8] = {icon = ResMgr.ui.sxdj_hyjj},                                 -- 火眼金睛
}

local POWER_MAP = {
    [CHS[3001773]] = 6,          -- 酷酷龙
    [CHS[3001767]] = 5,          -- 威威虎
    [CHS[3001762]] = 4,          -- 笨笨牛
    [CHS[3001779]] = 3,          -- 溜溜马
    [CHS[3001786]] = 2,          -- 招财猪
    [CHS[3001784]] = 1,          -- 乖乖狗
}

local PLAYER_OPERATE = {
    OPEN = 1,   -- 打开
    MOVE = 2,   -- 移动
    LOSE = 3,   -- 认输
}

local OPEN_TYPE = {
    BOON = "1",   -- 炸弹
    HYJJ = "2",   -- 火眼金睛
    PET = "3",   -- PET
    NONE = "4",
}

function ShengxdjDlg:init()
    self:bindListener("LostButton", self.onLostButton)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("CloseImage", self.onExitButton)
    self:bindListener("Panel_62", self.onTextButton)
    self:setCtrlVisible("RulePanel_3", false)
    self:setCtrlVisible("GameResultPanel", false)
    self:setCtrlVisible("WaitImage", false)

    self:setCtrlVisible("TipsPanel", false)
    self:setFullScreen()
    self:setCtrlFullClientEx("GameResultPanel")

    DlgMgr:closeDlg("ChannelDlg")
    DlgMgr:closeDlg("FriendDlg")

    DlgMgr:closeNormalAndFloatDlg()

    DlgMgr:closeDlgWhenNoramlDlgOpen(nil, true) -- 隐藏界面
    CharMgr:doCharHideStatus(Me)

    local icon = ResMgr.ui.sxdj_grid_white
    local img = ccui.ImageView:create(icon)

    self.gridSize = self.gridSize or img:getContentSize()
    self:initPos()

    -- 创建格子
    self:creatAllGrid()

    self:hookMsg("MSG_SUMMER_2019_SXDJ_DATA")
    self:hookMsg("MSG_SUMMER_2019_SXDJ_DO_ACTION")
    self:hookMsg("MSG_SUMMER_2019_SXDJ_OPERATOR")
    self:hookMsg("MSG_SUMMER_2019_SXDJ_BONUS")
    self:hookMsg("MSG_SUMMER_2019_SXDJ_FAIL")

    self:hookMsg("MSG_MESSAGE")
    self:hookMsg("MSG_MESSAGE_EX")
end

function ShengxdjDlg:initPos()
    for i = 2, 6 do
        NO_TO_POS[i] = cc.p(NO_TO_POS[1].x + (i - 1) * 76, NO_TO_POS[1].y + (i - 1) * 38)
    end

    NO_TO_POS[7] = cc.p(NO_TO_POS[1].x + 76, NO_TO_POS[1].y - 38)
    NO_TO_POS[13] = cc.p(NO_TO_POS[7].x + 76, NO_TO_POS[7].y - 38)
    NO_TO_POS[19] = cc.p(NO_TO_POS[13].x + 76, NO_TO_POS[13].y - 38)
    NO_TO_POS[25] = cc.p(NO_TO_POS[19].x + 76, NO_TO_POS[19].y - 38)
    NO_TO_POS[31] = cc.p(NO_TO_POS[25].x + 76, NO_TO_POS[25].y - 38)

    for i = 7, 12 do
        NO_TO_POS[i] = cc.p(NO_TO_POS[7].x + (i - 7) * 76, NO_TO_POS[7].y + (i - 7) * 38)
    end

    for i = 13, 18 do
        NO_TO_POS[i] = cc.p(NO_TO_POS[13].x + (i - 13) * 76, NO_TO_POS[13].y + (i - 13) * 38)
    end

    for i = 19, 24 do
        NO_TO_POS[i] = cc.p(NO_TO_POS[19].x + (i - 19) * 76, NO_TO_POS[19].y + (i - 19) * 38)
    end

    for i = 25, 30 do
        NO_TO_POS[i] = cc.p(NO_TO_POS[25].x + (i - 25) * 76, NO_TO_POS[25].y + (i - 25) * 38)
    end

    for i = 31, 36 do
        NO_TO_POS[i] = cc.p(NO_TO_POS[31].x + (i - 31) * 76, NO_TO_POS[31].y + (i - 31) * 38)
    end

end

function ShengxdjDlg:onTextButton(sender, eventType)
--[[
    -- 砸蛋
    local magic = gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.online_gift_egg.name, "Bottom01", sender, nil, self)
    magic:setScale(0.5)
    --]]
end

function ShengxdjDlg:tryToAttack(selectPet, destPet)
    if selectPet:queryBasicInt("corp") == destPet:queryBasicInt("corp") then
        return
    end

    local selectPow = queryBasicInt("power")
    local destPow = queryBasicInt("power")

    if selectPow >= destPow then
        if selectPow == 6 and destPow == 1 then
        else
            return true
        end
    end
end

-- 删除选中光效
function ShengxdjDlg:removeAllSelectMagic()
    if not self.petList then return end
    for _, pet in pairs(self.petList) do
        pet:addSelectFlag("remove", Const.TITLE_IN_COMBAT)
    end
end

-- 获取我的阵营
function ShengxdjDlg:getMyCorp()
    if not self.data then return end
    for i = 1, 2 do
        if Me:queryBasic("gid") == self.data.corps_info[i].gid then
            return self.data.corps_info[i].corp
        end
    end
end

function ShengxdjDlg:creatAllGrid()
    self.grids = {}
    for i = 1, #NO_TO_POS do
        self:creatUnitGrid(i, true)
    end
end

-- 创建格子
function ShengxdjDlg:creatUnitGrid(no, hasAction)
    if self.grids[no] then
        return
    end

    local pos = NO_TO_POS[no]
    local icon = ResMgr.ui.sxdj_grid_white
    if no % 2 == 0 then
        -- 深色格子
        icon = ResMgr.ui.sxdj_grid_black
    end

    local img = ccui.ImageView:create(icon)
    img:setName("ShengxdjDlgGrids" .. no)

    local x = pos.x
    local y = pos.y


    img:setPosition(x, y)
    img:setEnabled(true)


    self.grids[no] = img

    self:creatCropland(img)

    -- 0.3s 淡入效果
    if hasAction then
        img:setOpacity(0)
        local action = cc.FadeIn:create(0.3)
        img:runAction(action)
    end
end

function ShengxdjDlg:onUpdate()
    if self.petList then
        for _, char in pairs(self.petList) do
            char:update()
        end
    end
end

-- 创建农田
function ShengxdjDlg:creatCropland(image)
    gf:getMapObjLayer():addChild(image, Const.ZORDER_CROPLAND)

    -- 点击农田的响应判断
    local function clickCroplandJudge(image)
        self:onClickGezi(image)

        return true
    end


    if self.croplandLayer then
        return image
    end

    self.croplandLayer = cc.Layer:create()
    gf:getCharTopLayer():addChild(self.croplandLayer)

    local function containsTouchPos(touch)
        local grids = self.grids
        for _, v in ipairs(grids) do
            local pos = v:convertTouchToNodeSpace(touch)
            local rect = {["height"] = 60,["width"] = 94,["x"] = 11,["y"] = 10}
            if cc.rectContainsPoint(rect, pos) then
                return v
            end
        end
    end

    local clickObj
    local function clickCropLand(sender, event)
        if event:getEventCode() == cc.EventCode.BEGAN then
            if self.isClickCropland then
                return
            end

            clickObj = containsTouchPos(sender)
            self.isClickCropland = true
        elseif event:getEventCode() == cc.EventCode.ENDED then
            clickCroplandJudge(clickObj)
            self.isClickCropland = false
        elseif event:getEventCode() == cc.EventCode.CANCELLED then
            self.isClickCropland = false
        end

        return true
    end

    gf:bindTouchListener(self.croplandLayer, clickCropLand, {
    cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_ENDED,
        cc.Handler.EVENT_TOUCH_CANCELLED
    }, false)
    return image
end

function ShengxdjDlg:addMagicAndSee(ctrl, icon)
    local magic = self:addMagic(ctrl, icon)
    magic:setPositionY(200)
    return magic
end

function ShengxdjDlg:removeMagic(ctrl, icon)
    local magic = ctrl:getChildByTag(icon)
    magic:removeFromParent()
end

function ShengxdjDlg:onClickReady(sender)
    self:setCtrlVisible("TipsPanel", self.data.board_count == 0)
end


-- 点击格子
function ShengxdjDlg:onClickGezi(sender)
    if self.isLock then return end
    if not sender then return end
    if not self.data then return end

    if self.data.board_count == 0 then
        gf:ShowSmallTips(CHS[4101319])
        return
    end

    local no = tonumber(string.match(sender:getName(), "ShengxdjDlgGrids(%d+)"))
    local data = self.data.board_info[no]

    if not no then
        return
    end

    if not self:isMyTurnNow() and data.state ~= 3 then
        gf:ShowSmallTips(CHS[4010356])
        return
    end

    -- 砸蛋
    if (data.state == 0 or data.state == 1) then
        self.selectPetNo = nil
        self.isLock = true
        self:removeAllSelectMagic()
        gf:CmdToServer("CMD_SUMMER_2019_SXDJ_OPERATE", {index = no - 1, type = PLAYER_OPERATE.OPEN, para = ""})
        return
    end

    if self.selectPetNo and self.selectPetNo ~= no then
        local pet = self:getSelectPetByIdx(self.selectPetNo)
        if data.state == 3 then
            if self:checkValid(self.selectPetNo, no) then
                self.isLock = true
                self:removeAllSelectMagic()
                gf:CmdToServer("CMD_SUMMER_2019_SXDJ_OPERATE", {index = self.selectPetNo - 1, type = PLAYER_OPERATE.MOVE, para = tostring(no - 1)})
                self.selectPetNo = nil
            else
                gf:ShowSmallTips(CHS[4010357])  -- 这个位置无法到达哦！
            end
        elseif data.state == 2 then     -- 点击到的位置有正常的宠物
            local toPpet = self:getSelectPetByIdx(no)
            -- 检测位置是否合法   和 目标宠物是否是自己的
            if self:checkValid(self.selectPetNo, no) and toPpet and toPpet:queryBasicInt("corp") ~= self:getMyCorp() then
                self:removeAllSelectMagic()
                gf:CmdToServer("CMD_SUMMER_2019_SXDJ_OPERATE", {index = self.selectPetNo - 1, type = PLAYER_OPERATE.MOVE, para = tostring(no - 1)})
                self.isLock = true
                self.selectPetNo = nil
            elseif toPpet and toPpet:queryBasicInt("corp") == self:getMyCorp() then
                self:removeAllSelectMagic()
                toPpet:addSelectFlag("add", Const.TITLE_IN_COMBAT)
                self.selectPetNo = no
            elseif toPpet and toPpet:queryBasicInt("corp") ~= self:getMyCorp() and not self:checkValid(self.selectPetNo, no) then
                gf:ShowSmallTips(CHS[4101317])  -- 距离太远无法攻击。
            end
        end
        return
    end

    if data.state == 2 then
        -- 正常的宠物
        if self.selectPetNo then
            local pet = self:getSelectPetByIdx(self.selectPetNo)
            pet:addSelectFlag("remove", Const.TITLE_IN_COMBAT)
            self.selectPetNo = nil
        else
            local pet, pos = self:getSelectPetByIdx(no)

            if pet:queryBasicInt("corp") == self:getMyCorp() then
                self.selectPetNo = no
                pet:addSelectFlag("add", Const.TITLE_IN_COMBAT)
            end
        end
        return
    end
end

function ShengxdjDlg:checkValid(curPos, toPos)
    if math.abs(curPos - toPos) == 6 then
        return true
    end

    if math.abs(curPos - toPos) == 1 and (math.floor((curPos - 1) / 6) + 1) == (math.floor((toPos - 1) / 6) + 1) then
        return true
    end

    return false
end

function ShengxdjDlg:getSelectPetByIdx(idx)
    if not self.petList then return end
    if not idx then return end
    for _, pet in pairs(self.petList) do
        if pet:queryBasicInt("idx") == idx then
            return pet, _
        end
    end
end

function ShengxdjDlg:cleanupChar()
    self.root:stopAllActions()

    self.data = nil
    self.selectPetNo = nil
    self.isClickCropland = nil
    self.isLock = false

    if self.charList then
        for i = 1, 2 do
            self.charList[i]:cleanup()
        end

        self.charList = nil
    end

    if self.petList then
        for _, char in pairs(self.petList) do
            char:cleanup()
        end

        self.petList = nil
    end

    if self.itemList then
        for _, img in pairs(self.itemList) do
            img:removeFromParent()
        end

        self.itemList = nil
    end

    if self.eggList then
        for _, img in pairs(self.eggList) do
            img:removeFromParent()
        end

        self.eggList = nil
    end
end

function ShengxdjDlg:cleanup()
    self:cleanupChar()

    DlgMgr:closeDlg("ShengxdjgzDlg")
    DlgMgr:closeDlg("ShengxdjStartDlg")

    if self.grids then
        for _, v in pairs(self.grids) do
            v:removeFromParent()
        end
        self.grids = nil
    end

    if self.croplandLayer then
        self.croplandLayer:removeFromParent()
        self.croplandLayer = nil
    end

    CharMgr:doCharHideStatus(Me)
    Me:setVisible(true)
    performWithDelay(gf:getUILayer(), function ()
        DlgMgr:preventDlg() -- 显示界面
    end)
end

-- 设置对阵角色
function ShengxdjDlg:setChar(data)
    -- 已经设置过了直接返回就好了
    if self.charList then return end

    self.charList = {}
    local playerInfo = data.corps_info
    for i = 1, 2 do
        local char
        playerInfo[i].title = playerInfo[i].corp == 1 and CHS[4010358] or CHS[4010359]
        if playerInfo[i].gid ~= Me:queryBasic("gid") then
            playerInfo[i].dir = 5
            playerInfo[i].vip_type = CharMgr:getCharByGid(playerInfo[i].gid):queryBasicInt("vip_type")

            char = self:createChar(playerInfo[i], LEFT_CHAR_POS)
        else
            playerInfo[i].dir = 1
            playerInfo[i].vip_type = Me:getVipType()
            char = self:createChar(playerInfo[i], RIGHT_CHAR_POS)
        end

        self.charList[i] = char
    end
end

-- 创建角色
function ShengxdjDlg:createChar(info, pos)
    local char = require("obj/activityObj/SxdjNpc").new()
    char:absorbBasicFields({
        icon = info.icon,
        name = info.name or "",
        dir = info.dir or 5,
        pow = info.pow,
        idx = info.idx,
        corp = info.corp,
        power = POWER_MAP[info.name],
        vip_type = info.vip_type,
        title = info.title,
        isPet = info.isPet and 1 or 0,
        gid = info.gid or ""
    })

    char:onEnterScene(pos.x, pos.y)
    char:setAct(Const.FA_STAND)
    return char
end

function ShengxdjDlg:createObjectByInfo(idx, info)
    local pos = NO_TO_POS[idx]
    if info.isPet then
        info.idx = idx
        info.dir = self:getMyCorp() == info.corp and 1 or 5

        local pet = self:getSelectPetByIdx(idx)
        if pet then
            pet:setOpacity(255)
        else
            local char = self:createChar(info, NO_TO_POS[idx])

            char:setOpacity(110)
            table.insert(self.petList, char)
        end

    else
        local itemImage = ccui.ImageView:create(info.icon)
        --local x, y = gf:convertToClientSpace(pos.x, pos.y)
        local x = pos.x
        local y = pos.y
        local destPos = cc.p(x, y + 20)
        itemImage:setPosition(destPos)
        itemImage:setScale(0.5)
        itemImage:setOpacity(110)
        itemImage:setName("ShengxdjDlgItem" .. idx)
        gf:getMapObjLayer():addChild(itemImage, Const.ZORDER_CROPLAND)
        self.itemList[idx] = itemImage
    end
end

function ShengxdjDlg:setCanSeeEgg(idx, info)
    local eggImage = self.eggList[idx]
    if not eggImage then return end

    local op = eggImage:getOpacity()

    if op == 110 then
        -- 执行过不在执行了
        return
    end
    eggImage:setOpacity(110)

    if info then
        self:createObjectByInfo(idx, info)
    end
end

function ShengxdjDlg:setBoardData(data)
    if not self.eggList then self.eggList = {} end
    if not self.petList then self.petList = {} end
    if not self.itemList then self.itemList = {} end

    local boardData = data.board_info
    for i = 1, 36 do
        local pos = NO_TO_POS[i]
        local unitData = boardData[i]
        if unitData.state == 0 or unitData.state == 1 then
            -- 表示该位置是蛋
            local eggImage = ccui.ImageView:create(EggPath)
            local eggShadow = ccui.ImageView:create(ResMgr.ui.char_shadow_img)
            --local x, y = gf:convertToClientSpace(pos.x, pos.y)
            local x = pos.x
            local y = pos.y
            local destPos = cc.p(x, y + 20)
            eggImage:setPosition(destPos)
            eggImage:setName("ShengxdjDlgEgg" .. i)
            eggImage:setTag(i)

            eggShadow:setPosition(pos)
            eggShadow:setName("ShengxdjDlgEggShadow" .. i)

            gf:getMapObjLayer():addChild(eggShadow, Const.ZORDER_CROPLAND)
            gf:getMapObjLayer():addChild(eggImage, Const.ZORDER_CROPLAND)
            self.eggList[i] = eggImage

            self.eggList[i * 100] = eggShadow

            if unitData.state == 1 then
                local info = gf:deepCopy(EGG_TYPE[unitData.type])
                if info then
                    info.corp = unitData.corp
                end
                self:setCanSeeEgg(i, info)
            end
        else
            -- 已经砸开的宠物
            local info = EGG_TYPE[unitData.type]
            if info and info.isPet then
                info.idx = i
                info.corp = unitData.corp
                info.dir = self:getMyCorp() == info.corp and 1 or 5

                local char = self:createChar(info, pos)
                table.insert(self.petList, char)
            end
        end
    end
end

-- 设置玩家数据（左右上角）
function ShengxdjDlg:setPlayerData(data)
    local playerInfo = data.corps_info
    for i = 1, 2 do
        if playerInfo[i].gid == Me:queryBasic("gid") then
            self:setUnitPlayerData(playerInfo[i], "RolePanel_2")
        else
            self:setUnitPlayerData(playerInfo[i], "RolePanel_1")
        end
    end
end

function ShengxdjDlg:setUnitPlayerData(playerInfo, panelName)
    local panel = self:getControl(panelName)

    -- icon
    self:setImage("PortraitImage_2", ResMgr:getSmallPortrait(playerInfo.icon) , panel)

    -- 行动力
    self:setLabelText("NumLabel", playerInfo.action_point, panel)
end

-- 当前是否我行动
function ShengxdjDlg:isMyTurnNow()
    if not self.data then return end
    if self.data.cur_oper_gid == Me:queryBasic("gid") then
        return true
    end
end

function ShengxdjDlg:onLostButton(sender, eventType)
    if not self.data then return end
    if not self:isMyTurnNow() then
        gf:ShowSmallTips(CHS[4010360])  -- 己方行动时才能进行操作！
        return
    end

    if self.data.cur_round <= 5 then
        gf:ShowSmallTips(CHS[4010361])     -- 至少需要进行5回合才能认输哦！
        return
    end

    gf:confirm(CHS[4010362], function ()
        gf:CmdToServer("CMD_SUMMER_2019_SXDJ_OPERATE", {index = 0, type = PLAYER_OPERATE.LOSE, para = ""})
    end)
end


function ShengxdjDlg:onExitButton(sender, eventType)
    gf:CmdToServer("CMD_SUMMER_2019_SXDJ_QUIT")
end

function ShengxdjDlg:onRuleButton(sender, eventType)
    DlgMgr:openDlg("ShengxdjgzDlg")
end

function ShengxdjDlg:setFightInfo(data)
    self.isLock = false

    self:setLabelText("NumLabel", data.cur_round, "InforPanel")

    local opStr = data.cur_oper_gid == Me:queryBasic("gid") and CHS[4010363] or CHS[4010364]
    local label = self:setLabelText("ObjectLabel", opStr, "InforPanel")

    if self.data then
        for i = 1, self.data.corp_count do
            if data.cur_oper_gid == self.data.corps_info[i].gid then
                if self.data.corps_info[i].corp == 1 then
                    label:setColor(COLOR3.RED)
                else
                    label:setColor(COLOR3.BLUE)
                end
            end
        end
    end

    if self.charList then

        for _, char in pairs(self.charList) do
            if char:queryBasic("gid") == data.cur_oper_gid then
                char:addSelectFlag("add")
            else
                char:addSelectFlag("remove")
            end
        end
    end
end

function ShengxdjDlg:playBombMagic(cell, cb)
    local icon = ResMgr.magic.xunbao_use_bomb
    local size = self.rockSize
    local magic = gf:createCallbackMagic(icon, function(node)
        node:removeFromParent(true)
        if cb then cb() end
    end)

    --magic:setPosition(72, 56)
    local rect = self:getBoundingBoxInWorldSpace(cell)
    magic:setPosition(rect.x + 72, rect.y + 56)
    gf:getUILayer():addChild(magic)
end

function ShengxdjDlg:addBreakEggEffByIdx(idx, callBack, flag)
    if not self.grids or not self.grids[idx] then return end

    local actName = "Bottom01"
    local sender = self.grids[idx]
    local rect = self:getBoundingBoxInWorldSpace(sender)

    if self.eggList[idx] then
        rect = self:getBoundingBoxInWorldSpace(self.eggList[idx])
    end

  --  local magic = gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.online_gift_egg.name, actName, sender, callBack, self)
    --magic:setScale(0.5)
    local magicBottom = ArmatureMgr:createArmatureByType(ARMATURE_TYPE.ARMATURE_MAP, ResMgr.ArmatureMagic.sxdj_egg.name, "Bottom")
    ArmatureMgr:setArmaturePlayOnce(magicBottom, "Bottom")
    magicBottom:setPosition(cc.p((rect.x + 23) / Const.UI_SCALE, (rect.y + 30) / Const.UI_SCALE))
    gf:getUILayer():addChild(magicBottom)

    local greyFog = gf:createSelfRemoveMagic(ResMgr.magic.grey_fog, {blendMode = "add", scaleX = 0.8, scaleY = 0.8})
    greyFog:setOpacity(102)
    greyFog:setPosition(cc.p((rect.x + 23) / Const.UI_SCALE, (rect.y + 30) / Const.UI_SCALE))
    gf:getUILayer():addChild(greyFog)

    local magicTop = ArmatureMgr:createArmatureByType(ARMATURE_TYPE.ARMATURE_MAP, ResMgr.ArmatureMagic.sxdj_egg.name, "Top")
    ArmatureMgr:setArmaturePlayOnce(magicTop, "Top")
    magicTop:setPosition(cc.p((rect.x + 23) / Const.UI_SCALE, (rect.y + 30) / Const.UI_SCALE))
    --sender:addChild(magicTop)
    gf:getUILayer():addChild(magicTop)

    if self.eggList[idx] then
        self.eggList[idx]:removeFromParent()
        self.eggList[idx] = nil

        self.eggList[idx * 100]:removeFromParent()
        self.eggList[idx * 100] = nil
    end

    if self.itemList[idx] then
        self.itemList[idx]:removeFromParent()
        self.itemList[idx] = nil
    end

    if flag == OPEN_TYPE.BOON then
        self:playBombMagic(sender)
    end

    if callBack then
        -- 只延迟0.1，因为策划希望0.1后显示物品而不是动画全部播放完后
        performWithDelay(self.root, function ()
            callBack()
        end, 0.1)
    end
end

-- 资源暂无，统一砸蛋
function ShengxdjDlg:addMagicByIdx(idx, icon, action, callBack)
    if not self.grids or not self.grids[idx] then return end
    local sender = self.grids[idx]
    local magic = gf:createArmatureOnceMagic(icon, action, sender, callBack, self)
    magic:setScale(0.5)

    if self.eggList[idx] then
        self.eggList[idx]:removeFromParent()
        self.eggList[idx] = nil

        self.eggList[idx * 100]:removeFromParent()
        self.eggList[idx * 100] = nil
    end
end

-- 执行客户端某个操作
function ShengxdjDlg:MSG_SUMMER_2019_SXDJ_DO_ACTION(data)
    if not self.data then return end
    if data.cur_round ~= self.data.cur_round then return end
    data.index = data.index + 1

    if self.itemList[data.index] then
        self.itemList[data.index]:removeFromParent()
        self.itemList[data.index] = nil
    end

    if data.type == PLAYER_OPERATE.OPEN then
        -- 播放光效
        self:addBreakEggEffByIdx(data.index, function ( )
            if data.para1 == OPEN_TYPE.PET then
                -- 翻开的是宠物
                local pet = self:getSelectPetByIdx(data.index)
                if pet then
                    pet:setOpacity(255)
                else
                    local corp, type = string.match(data.para2, "(%d+),(%d+)")
                    corp = tonumber(corp)
                    type = tonumber(type)
                    local info = EGG_TYPE[type]
                    info.idx = data.index
                    info.corp = corp
                    info.dir = self:getMyCorp() == info.corp and 1 or 5
                    local char = self:createChar(info, NO_TO_POS[data.index])
                    table.insert(self.petList, char)
                end

                -- 动画结束
                gf:CmdToServer("CMD_SUMMER_2019_SXDJ_END_ACTION", {status = "running"})
            elseif data.para1 == OPEN_TYPE.BOON then

                -- 翻开的时炸弹
                local paraTab = gf:split(data.para2, ",")
                local toPos = tonumber(paraTab[1]) + 1
                local eggType = tonumber(paraTab[2])
                local exPara = tonumber(paraTab[3])
                if exPara == 2 then
                    local pet, inPos = self:getSelectPetByIdx(toPos)
                    -- 把目标宠物砸死了
                    if pet and self.petList[inPos] then
                         pet:setActAndCB(Const.FA_DIE_NOW, function()
                            pet:cleanup()
                            self.petList[inPos] = nil
                        end)
                    end
                end

                if eggType ~= 7 then
                    -- 动画结束
                    gf:CmdToServer("CMD_SUMMER_2019_SXDJ_END_ACTION", {status = "running"})
                end

            elseif data.para1 == OPEN_TYPE.HYJJ then
                -- 翻开的是火眼金睛
                local paraTab = gf:split(data.para2, ",")
                local toPos = tonumber(paraTab[1]) + 1
                local eggType = tonumber(paraTab[2])
                local exPara = tonumber(paraTab[3])
                local info = gf:deepCopy(EGG_TYPE[eggType])

                -- 当前显示火眼金睛，显示一秒
                local itemImage = ccui.ImageView:create(ResMgr.ui.sxdj_hyjj)
                local pos =  NO_TO_POS[data.index]
                local x = pos.x
                local y = pos.y
                local destPos1 = cc.p(x, y + 20)
                itemImage:setPosition(destPos1)
                itemImage:setScale(0.5)
                itemImage:setName("ShengxdjDlgItem" .. data.index)
                gf:getMapObjLayer():addChild(itemImage, Const.ZORDER_CROPLAND)
                self.itemList[data.index] = itemImage
                local missAct = cc.FadeOut:create(1.5)
                local callbackAct = cc.CallFunc:create(function()
                    if self.itemList[data.index] then
                        self.itemList[data.index]:removeFromParent()
                        self.itemList[data.index] = nil
                    end
                end)
                itemImage:runAction(cc.Sequence:create(missAct, callbackAct))

                local tempData = self.data.board_info[toPos]
                if tempData and tempData.state <= 1 then
                    -- 火眼金睛光效
                    if info then info.corp = exPara end
                    self:setCanSeeEgg(toPos, info)

                    -- 动画结束
                    gf:CmdToServer("CMD_SUMMER_2019_SXDJ_END_ACTION", {status = "running"})

                    --[[策划说火眼不需要光效
                    self:addBreakEggEffByIdx(toPos, function ()
                        -- 火眼金睛光效
                        info.corp = exPara
                        self:setCanSeeEgg(toPos, info)

                        -- 动画结束
                        gf:CmdToServer("CMD_SUMMER_2019_SXDJ_END_ACTION", {status = "running"})
                    end, "Bottom03")
                    --]]
                else-- 动画结束
                    gf:CmdToServer("CMD_SUMMER_2019_SXDJ_END_ACTION", {status = "running"})
                end


            elseif data.para1 == OPEN_TYPE.NONE then
                gf:CmdToServer("CMD_SUMMER_2019_SXDJ_END_ACTION", {status = "running"})
            end
        end, data.para1)
    elseif data.type == PLAYER_OPERATE.MOVE then
        local idx = tonumber(data.index)
        local toIdx = tonumber(data.para1) + 1
        local pet, posInTab = self:getSelectPetByIdx(idx)
        if pet and data.para2 == "1" then
            -- 直接移动到没有宠物的地方
            pet:absorbBasicFields({idx = toIdx, cur_round = self.data.cur_round})
           -- pet:setAct(Const.SA_STAND, nil, true)

            local x, y = gf:convertToMapSpace(NO_TO_POS[toIdx].x, NO_TO_POS[toIdx].y)
            local tempPos = cc.p(x,y)
            local dir = self:getDirByIdx(idx, toIdx)
            pet.toDir = dir
            pet:setDestPos(NO_TO_POS[toIdx])
            pet:setEndPos(NO_TO_POS[toIdx].x, NO_TO_POS[toIdx].y)
            return
        else
            local diePet, pos = self:getSelectPetByIdx(toIdx)
            if diePet then
                diePet:setActAndCB(Const.FA_DIE_NOW, function()
                    diePet:cleanup()
                    self.petList[pos] = nil
                end)
            end
--
            -- 吃的移动
            if pet then
                local dir = self:getDirByIdx(idx, toIdx)
                pet.toDir = dir
                pet:setDir(dir)
                pet:absorbBasicFields({idx = toIdx, cur_round = self.data.cur_round})
                pet:setActAndCB(Const.FA_ACTION_PHYSICAL_ATTACK, function()
                    pet:setActAndCB(Const.FA_ACTION_ATTACK_FINISH, function()
                        pet:setAct(Const.SA_STAND, nil, true)
                        local x, y = gf:convertToMapSpace(NO_TO_POS[toIdx].x, NO_TO_POS[toIdx].y)
                        local tempPos = cc.p(x,y)
                        pet:setDestPos(NO_TO_POS[toIdx])
                        pet:setEndPos(NO_TO_POS[toIdx].x, NO_TO_POS[toIdx].y)

                    end)
                end)
            end
            --]]
        end
    end
end



function ShengxdjDlg:getDirByIdx(curIdx, toIdx)
    if toIdx - curIdx == 6 then
        return 5
    elseif toIdx - curIdx == -6 then
        return 1
    elseif toIdx - curIdx == 1 then
        return 3
    elseif toIdx - curIdx == -1 then
        return 7
    end
end

function ShengxdjDlg:endWorkCallBack(pet)
    if pet:queryBasicInt("cur_round") == self.data.cur_round then
        gf:CmdToServer("CMD_SUMMER_2019_SXDJ_END_ACTION", {status = "running"})
    end
end

function ShengxdjDlg:MSG_SUMMER_2019_SXDJ_OPERATOR(data)
    self:removeAllSelectMagic()
    self.selectPetNo = nil
    self:setFightInfo(data)
    if self.data then
        self.data.cur_round = data.cur_round
        self.data.cur_oper_gid = data.cur_oper_gid
    end


    self:setCtrlVisible("WaitImage", data.cur_oper_gid ~= Me:queryBasic("gid"))
    if data.cur_oper_gid == Me:queryBasic("gid") then
        local endTime = math.min( data.remain_ti, gf:getServerTime() + 20)
        gf:startCountDowm(endTime, nil, nil, "scale80")
    else
        gf:closeCountDown()
    end
end

-- 整体数据信息
function ShengxdjDlg:MSG_SUMMER_2019_SXDJ_DATA(data)

    local isMyReady = false
    for i = 1, data.corp_count do
        if data.corps_info[i].gid == Me:queryBasic("gid") and data.corps_info[i].prepared == 1 then
            isMyReady = true
        end
    end

    self:setCtrlVisible("TipsPanel", data.board_count == 0 and isMyReady)

    -- 未准备，自己模拟数据
    if data.board_count == 0 and not self.data then
        -- 设置棋盘数据
        local tempData = {}
        tempData.board_info = {}
        for i = 1, 36 do
            tempData.board_info[i] = {}
            tempData.board_info[i].state = 0
        end

        self:setBoardData(tempData)
    elseif not self.data then
        self:setBoardData(data)
    end

    self.data = data

    -- 设置左右上角的角色信息
    self:setPlayerData(data)

    -- 设置战场上角色
    self:setChar(data)

    self:setFightInfo(data)

    -- 如果我未准备，则显示准备界面
    for i = 1, data.corp_count do
        if data.corps_info[i].gid == Me:queryBasic("gid") then
            if data.corps_info[i].prepared == 0 then
                DlgMgr:openDlg("ShengxdjStartDlg")
            end
        end
    end
end

function ShengxdjDlg:MSG_SUMMER_2019_SXDJ_BONUS(data)
    gf:closeCountDown()
    self:setCtrlVisible("GameResultPanel", true)
    if data.tao then
        self:setLabelText("NumLabel_1", gf:getTaoStr(tonumber(data.tao)) .. CHS[4100702], "DaoPanel")
    else
        self:setLabelText("NumLabel_1", CHS[5000059], "DaoPanel")
    end

    if data.exp then
        self:setLabelText("NumLabel_1", data.exp, "ExpPanel")
    else
        self:setLabelText("NumLabel_1", CHS[5000059], "ExpPanel")
    end

    local getItem = data.item and data.item ~= "" and data.item or CHS[5000059]
    self:setLabelText("NumLabel_1", getItem, "ItemPanel")

    self:setCtrlVisible("WinBkImage", data.result == 1)
    self:setCtrlVisible("WinImage", data.result == 1)

    self:setCtrlVisible("FailImage", data.result == 2 or data.result == 3)
    self:setCtrlVisible("FailBkImage", data.result == 2 or data.result == 3)

    self:setCtrlVisible("PingImage", data.result == 4)
    self:setCtrlVisible("PingBkImage", data.result == 4)
end

function ShengxdjDlg:MSG_SUMMER_2019_SXDJ_FAIL(data)
    -- 其他参数暂时不需要，留着备用
    self.isLock = false
end

function ShengxdjDlg:MSG_MESSAGE_EX(data)
    if data.channel == CHAT_CHANNEL.CURRENT or data.channel == CHAT_CHANNEL.TEAM then

        local char = CharMgr:getCharById(data.id)
        if not char then return end
        for _, standChar in pairs(self.charList) do
            if char:queryBasic("gid") == standChar:queryBasic("gid") then
                standChar:setChat({msg = data.msg, show_time = 3}, nil, true)
            end
        end
    end
end

function ShengxdjDlg:MSG_MESSAGE(data)
    self:MSG_MESSAGE_EX(data)
end

return ShengxdjDlg
