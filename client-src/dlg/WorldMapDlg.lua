-- WorldMapDlg.lua
-- Created by cheny Dec/29/2014
-- 世界地图界面

local SmallMapDlg = require "dlg/SmallMapDlg"

local WorldMapDlg = Singleton("WorldMapDlg", Dialog)
local SMALL_HERO_ZORDER = 10

local buttons = {
    LanXianZhenButton = CHS[2000039],
    LanXianZhenWaiButton = CHS[2000040],
    WuMingXiaoZhenButton = CHS[2000072],
    FengYueGuButton = CHS[6000600],
    XuanYuanMiaoButton = CHS[6000601],
    TongTianTaButton = CHS[2000073],
    BangPaiZongTanButton = CHS[2000074],
    TianYongChengButton = CHS[2000075],
    GuanDaoBeiButton = CHS[3000119],
    GuanDaoNanButton = CHS[3000120],
    WoLongPoButton = CHS[3000121],
    BeiHaiShaTanButton = CHS[3000122],
    ShiLiPoButton = CHS[6000602],
    DongHaiYuCunButton = CHS[6000603],
    PengLaiDaoButton = CHS[6000604],
    TaoLiuLinButton = CHS[6000605],
    WuLongShanButton = CHS[6000066],
    ZhongNanShanButton = CHS[6000067],
    QianYuanShanButton = CHS[6000069],
    FengHuangShanButton = CHS[6000068],
    KuLouShanButton = CHS[6000070],
    XuanZhouButton = CHS[6000334], -- 碧游宫
    YanZhouButton = CHS[6000335], -- 大罗宫
    LiuZhouButton = CHS[6000337], -- 八德池
    JuKuZhouButton = CHS[6000336], -- 七宝林
    XiKunLunButton = CHS[6000338], -- 西昆仑
    DongKunLunButton = CHS[6000317], -- 东昆仑
    LongGongButton = CHS[6000341], -- 龙宫
    YunxiaoButton = CHS[4010127], -- 云霄宫
}

-- 当前地图指向光效离中心点的偏移位置
local cursor_offset = {
    [CHS[2000039]] = {x = 0, y = - 10}, -- 揽仙镇
    [CHS[3000898]] = {x = 30, y = -10}, -- 十里坡
    [CHS[3000808]] = {x = 10, y = -10}, -- 揽仙镇外
    [CHS[3001307]] = {x = -20, y = -10 }, -- 官道北
    [CHS[3000935]] = {x = 10, y = -15}, -- 蓬莱岛
    [CHS[3001668]] = {x = 10, y = -10}, -- 东海渔村
    [CHS[3001670]] = {x = 10, y = 0}, -- 五龙山
    [CHS[3001684]] = {x = 15, y = 0}, -- 北海沙滩
    [CHS[3001694]] = {x = 5, y = -10}, --风月谷
    [CHS[3001667]] = {x = 10, y = -15}, --无名小镇
    [CHS[3001695]] = {x = 0, y = -5}, -- 桃柳林
    [CHS[3001704]] = {x= 0, y = -5}, -- 骷髅山
    [CHS[3001676]] = {x = 5, y = 5}, -- 乾元山
    [CHS[3001679]] = {x = 30, y = -15}, -- 轩辕庙
    [CHS[3001680]] = {x = 30, y = 5 }, -- 官道南
	[CHS[3000121]] = {x = 20, y = -10 }, -- 卧龙坡
}

function WorldMapDlg:init()
    self:bindListener("GoToFamilyButton", self.onTouch)

    -- 设置我的位置
    self:setMyPosition()

    -- 监听过图消息
    self:hookMsg("MSG_ENTER_ROOM")

    self:bindListener("GoToFamilyButton", self.onTouch)
end

-- 设置我的位置
function WorldMapDlg:setMyPosition()
    local curMap = MapMgr:getCurrentMapName()
    self:setCtrlVisible("AvatarPanel", false)

    for button, map in pairs(buttons) do
        self:bindListener(button, function(s, e)
            self:onMapButton(map)
        end)

        if map == curMap then
            local ctrl = self:getControl(button)
            if ctrl then
                local hero = self:getControl("AvatarPanel")
                local time = 0.6
                local high = 8
                local moveUp = cc.MoveBy:create(time, cc.p(0, high))
                local moveDown = cc.MoveBy:create(time, cc.p(0, -high))
                local act = cc.Sequence:create(moveUp, moveDown)
                hero:runAction(cc.RepeatForever:create(act))
                local x, y = ctrl:getPosition()
                local curX = x - hero:getContentSize().width * 0.5
                local curY = y
                if(cursor_offset[curMap]) then
                    curX = curX + cursor_offset[curMap].x
                    curY = curY + cursor_offset[curMap].y
                end

                local pos = cc.p(curX, curY)
                hero:setPosition(pos)
                hero:setVisible(true)
            end
        end
    end
end

function WorldMapDlg:onTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then

        local curMap = MapMgr:getCurrentMapName()

        -- 获取师门地图
        local polar = Me:queryBasicInt("polar")
        local polarMap = gf:getInsidePolarMap(polar)
        if curMap ~= polarMap then
            local myId = Me:getId()
            if Me:isInJail() then
                gf:ShowSmallTips(CHS[6000214])
                return
            elseif Me:isInPrison() then
                gf:ShowSmallTips(CHS[7000072])
                return
            elseif TeamMgr:inTeam(myId) and  TeamMgr:getLeaderId() ~= myId then
                gf:ShowSmallTips(CHS[6000215])
                return
            end

            MapMgr:flyTo(polarMap)
        end
        self:close()
    end
end

function WorldMapDlg:onMapButton(mapName)
    if MapMgr:getCurrentMapName() == mapName then
        local dlg = DlgMgr:openDlg("SmallMapDlg")
        dlg:initData()
    end

    if not TaskMgr:isExistTaskByName(CHS[3003799]) then
        if mapName ~= MapMgr:getCurrentMapName() then
            local myId = Me:getId()
            if Me:isInJail() then
                gf:ShowSmallTips(CHS[6000214])
                return
            elseif Me:isInPrison() then
                gf:ShowSmallTips(CHS[7000072])
                return
            elseif TeamMgr:inTeam(myId) and  TeamMgr:getLeaderId() ~= myId then
                gf:ShowSmallTips(CHS[6000215])
                return
            end

            MapMgr:flyTo(mapName)

            -- 停止自动寻路,停止随机走动
            AutoWalkMgr:endAutoWalk()
            AutoWalkMgr:endRandomWalk()
            AutoWalkMgr:endUnFlyAutoWalk()
            Me:resetGotoEndPos()
            Me:setAct(Const.SA_STAND)
        end
    else
        gf:ShowSmallTips(CHS[3003800])
        AutoWalkMgr:endUnFlyAutoWalk()
    end
    self:close()
end

function WorldMapDlg:MSG_ENTER_ROOM()
    -- 更新我的位置
    self:setMyPosition()
end

return WorldMapDlg
