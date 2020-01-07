-- Npc.lua
-- Created by chenyq Nov/14/2014
-- 场景中的 NPC 对应的类

local Char = require("obj/Char")
local CharConfig = require(ResMgr:getCfgPath('CharConfig.lua'))

local Npc = class("Npc", Char)
local TITLE_MAGIC_MAP = {}
TITLE_MAGIC_MAP[Const.TITLE_IN_COMBAT]          = {'fighting',      'head'}
TITLE_MAGIC_MAP[Const.TITLE_IN_EXCHANGE]        = {'exchanging',    'head'}
TITLE_MAGIC_MAP[Const.TITLE_TEAM_LEADER]        = {'leader',        'head'}
TITLE_MAGIC_MAP[Const.TITLE_LOOKON]             = {'look_on',       'head'}
TITLE_MAGIC_MAP[Const.TITLE_USE_JINGYAOSHU]     = {'jiangyaoshu',   'foot'}
TITLE_MAGIC_MAP[Const.TITLE_USE_JINGYAOLING]    = {'jiangyaoling',  'head'}
TITLE_MAGIC_MAP[Const.TITLE_RAID_LEADER]        = {'corps',         'head'}



-- 点击角色
function Npc:onClickChar()
    if GMMgr:isStaticMode() then
        gf:ShowSmallTips(CHS[3004407])
        return
    end

    if Me:isInPrison() and self:getName() == CHS[7000064] then
        gf:ShowSmallTips(CHS[7000096])
        return
    end

    -- NPC类型为不可点击的，则返回
    if OBJECT_NPC_TYPE.CANNOT_TOUCH == self:queryBasicInt("sub_type") then
        return
    end

    local clickAutoWalk = {}
    clickAutoWalk.map = MapMgr:getCurrentMapName()
    clickAutoWalk.action = "$0"
    clickAutoWalk.npc = self:getName()
    clickAutoWalk.isClickNpc = true
    clickAutoWalk.npcId = self:getId()

    if self.lastMapPosX and self.lastMapPosY then
        clickAutoWalk.x = self.lastMapPosX
        clickAutoWalk.y = self.lastMapPosY
    end

    AutoWalkMgr:beginAutoWalk(clickAutoWalk)
end

function Npc:update()
    Char.update(self)

    -- 通天塔神秘房间-变戏法，npc自动喊话，小游戏结束顶号等没有相关游戏状态，只有根据房间和npc名定时喊话
    if self:queryBasic("name") == CHS[4010302] and MapMgr:isInMapByName(CHS[4010293]) then
        if not self.refreshTime then self.refreshTime = 0 end
        self.refreshTime = self.refreshTime + 1
        if self.refreshTime == 180 then
            self:setChat({msg = CHS[4101290], show_time = 3}, nil, true)
            self.refreshTime = 0
        end
    end
end

function Npc:init()
    Char.init(self)

    -- 存放 title 信息
    self.titleInfo = {}
    self.headTitle = nil
end

function Npc:onEnterScene(mapX, mapY)
    Char.onEnterScene(self, mapX, mapY)
    self:loadNpcTmx()
    self:markNpcObstaceDirty()

    self:addBottomImage()

    self:setFloat()
end

function Npc:addBottomImage()
    if self:getBottomImage() then return end
    local npc = MapMgr:getCurMapNpcByName(self:queryBasic("name"))
    if npc and npc.bottom_image then
        -- 存在脚底图片
        local sp = cc.Sprite:create(ResMgr:getShadowFilePath(npc.bottom_image))
        if npc.bottom_image_Zorder then
            sp:setLocalZOrder(npc.bottom_image_Zorder)
        end
        sp:setName(npc.bottom_image)
        self:addToBottomLayer(sp)
    end

    if npc and npc.armatureType == 4 then
        local actionName = npc.actionName or "Bottom"
        local magic = ArmatureMgr:createArmatureByType(npc.armatureType, npc.magicIcon, actionName)
        magic:setName(npc.magicIcon)
        magic:setLocalZOrder(npc.bottom_image_Zorder)
        -- 需要循环播放骨骼动画
        magic:getAnimation():play(actionName, -1, 1)

        self:addToBottomLayer(magic)
    end
end

function Npc:removeBottomImage()
    local sp = self:getBottomImage()
    if sp then sp:removeFromParent() end
end

function Npc:getBottomImage()
    local npc = MapMgr:getCurMapNpcByName(self:queryBasic("name"))
    if npc and npc.bottom_image then
        return self.bottomLayer:getChildByName(npc.bottom_image)
    end
end

function Npc:getFloatAction()
    local act2 = cc.MoveBy:create(1.2, cc.p(0, -3))
    local act3 = cc.MoveBy:create(1.2, cc.p(0, 3))
    return cc.RepeatForever:create(cc.Sequence:create( act2, act3))
end

-- 设置NPC浮动
function Npc:setFloat()
    local npc = MapMgr:getCurMapNpcByName(self:queryBasic("name"))
    if npc and npc.isFloat and not self.isFloating then
        self.bottomLayer:runAction(self:getFloatAction())
        self.middleLayer:runAction(self:getFloatAction())
        self.topLayer:runAction(self:getFloatAction())
        self.isFloating = true
    end
end

function Npc:onExitScene()
    self:markNpcObstaceDirty()
    EventDispatcher:removeEventListener(EVENT.RELOAD_OBSTACLE, self.onReloadObstacle, self)

    self:removeBottomImage()

    Char.onExitScene(self)

    self.headTitle = nil
end

function Npc:getLoadType()
    return LOAD_TYPE.NPC
end

-- 重新刷新头衔
function Npc:reRefreshTitle(oldTitle)
    if nil == oldTitle then
        oldTitle = {}
    end

    -- 更新人物正在战斗中/观战效果
    self:updateTitleEffect(oldTitle, Const.TITLE_LOOKON)
    self:updateTitleEffect(oldTitle, Const.TITLE_IN_COMBAT)
end

-- 更新 title 效果
function Npc:updateTitleEffect(oldTitle, title)
    if oldTitle[title] == self.titleInfo[title] then
        -- 未发生变化
        return
    end

    local info = TITLE_MAGIC_MAP[title]
    if not info then
        Log:W('Not set TITLE_MAGIC_MAP for title:' .. title)
        return
    end

    local magicType = info[1]
    if self.titleInfo[title] then
        -- 增加标志
        local pos = info[2]
        if pos == 'head' then
            self:addMagicOnHead(ResMgr.magic[magicType], false, magicType)
        elseif pos == 'waist' then
            self:addMagicOnWaist(ResMgr.magic[magicType], false, magicType)
        elseif pos == foot then
            self:addMagicOnFoot(ResMgr.magic[magicType], false, magicType)
        else
            Log:W('Invalid pos:' .. pos .. ' in TITLE_MAGIC_MAP for title:' .. title)
        end
        return
    end

    if oldTitle[title] then
        -- 删除标记
        self:deleteMagic(magicType)
    end
end

-- 设置方向
function Npc:setDir(dir)
    local icon = self:queryBasicInt('special_icon')

    if icon <= 0 then
        icon = self:getOrgIcon()
    end

    if not gf:has8Dir(icon) and dir % 2 == 0 then
        dir = dir + 1
    end

    -- 如果模型配置了显示固定方向，则设置为指定的方向
    local cfg = CharMgr:getCharCfg(self:getIcon(), self:getName())
    if cfg then
        if cfg.fixDir then
            dir = cfg.fixDir
        else
            local actStr = tostring(self.faAct)
            if cfg[actStr] and cfg[actStr].fixDir then
                dir = cfg[actStr].fixDir
            end
        end
    end

    local lastDir = self.dir
    Char.setDir(self, dir)

    -- 摆放NPC
    if lastDir ~= self.dir then
        self:markNpcObstaceDirty()
    end
end

-- npc 如果名字和称谓一样，不显示 title
--[[
function Npc:getTitle()
    local title = self:queryBasic('title')
    if self:getShowName() == title then
        return ""
    end

    return title
end
]]

-- 更新影子
function Npc:updateShadow()
    local shadow_icon = self:queryBasic("shadow_icon")
    if not shadow_icon or "" == shadow_icon or "0" == shadow_icon then
        local npcInfo = MapMgr:getCurMapNpcByPosAndName(self:getName(), self:queryBasicInt("x"), self:queryBasicInt("y"))
        if npcInfo and npcInfo.shadow then
            self:setBasic("shadow_icon", npcInfo.shadow)
            self:setBasic("shadow_pos", cc.p(npcInfo.shadow_x or 0.5, npcInfo.shadow_y or 0.5))
        end
    end
end

function Npc:getShadow()
    if CharConfig[self:getIcon()] and CharConfig[self:getIcon()].notShowShadow then
        return
    end

    return Char.getShadow(self)
end

function Npc:isObstacle()
    return 1 == self:queryBasicInt("obstacle")
end

function Npc:setAct(act, callBack)
    Char.setAct(self, act, callBack)

    -- WDSY-28207 结婚队伍经过周年蛋糕是要移除周年蛋糕的障碍点并设为半透明
    local charInfo = CharMgr:getCharCfg(self:getIcon(), self:getName())
    if charInfo and charInfo.opacityNotObstacle and not self:isObstacle() and self.charAction then
        self.charAction:setCharOpacity(charInfo.opacityNotObstacle)
    end
end

-- 加载tmx信息
function Npc:loadNpcTmx()
    if not self:isObstacle() then return end

    -- 加载tmx信息
    local icon = self:queryBasicInt("icon")
    local path = ResMgr:getNpcTmx(icon)
    if not cc.FileUtils:getInstance():isFileExist(path) then return end
    self.tmx = ccexp.TMXTiledMap:create(path)
    if self.tmx then
        self:addToBottomLayer(self.tmx)
        self.tmx:setVisible(false)

        EventDispatcher:addEventListener(EVENT.RELOAD_OBSTACLE, self.onReloadObstacle, self)
    end
end

function Npc:getLayer()
    if not self.tmx then return end
    local layer = self.tmx:getLayer(string.format("obstacle_%d", self:getDir()))
    if not layer then
        layer = self.tmx:getLayer("obstacle")
    end
    return layer
end

function Npc:getShelter()
    if not self.tmx then return end
    local shelter = self.tmx:getLayer(string.format("shelter_%d", self:getDir()))
    if not shelter then
        shelter = self.tmx:getLayer("shelter")
    end

    return shelter
end

-- 摆放NPC
function Npc:doPutNpc()
    if not self:isObstacle() or not self:isObstacle() or not GameMgr.scene.map or not self.tmx then return end

    local layer = self:getLayer()
    if not layer then return end

    local shelter = self:getShelter()

    local size = layer:getLayerSize()
    local contentSize = layer:getContentSize()
    local x, y = gf:convertToMapSpace(self.curX, self.curY)

    local bPoint = CharMgr:getCharBasicPoint(self:getIcon(), "centre")
    local bx = math.floor(bPoint.x / 24)
    local by = math.floor(bPoint.y / 24)
    local beginX, beginY = x - bx ,y - by
    --[[
    local bx = bPoint.x / 24
    local by = bPoint.y / 24
    local beginX, beginY = math.floor(x - bx + 0.5), math.floor(y - by + 0.5)
    --]]
    local tileValue, shelterValue
    local t = {}
    for i = 0, size.width - 1 do
        for j = 0, size.height - 1 do
            tileValue = layer:getTileGIDAt(cc.p(i, j))
            if shelter then
                shelterValue = shelter:getTileGIDAt(cc.p(i, j))
            end

            if tileValue ~= 0 then
                 -- 更新障碍信息
                if not GameMgr.scene.map:isMarkable('obstacleLayer', beginX + i, beginY + j) then
                    GameMgr.scene.map:markLayer('obstacleLayer', beginX + i, beginY + j, 0x7FFFFFFF)
                end
            end
            --[[
            if shelterValue ~= 0 then
                 -- 更新遮罩信息
                if not GameMgr.scene.map:isMarkable('shelterLayer', beginX + i, beginY + j) then
                    GameMgr.scene.map:markLayer('shelterLayer', beginX + i, beginY + j, 0x7FFFFFFF)
                end
            end
            ]]
        end
    end

    GameMgr.scene.map:updateObstacle()
end

-- 拿下NPC
function Npc:markNpcObstaceDirty()
    if not self:isObstacle() or not GameMgr.scene.map or not self.tmx then return end

    -- 重新加载地图障碍信息
    GameMgr.scene.map:markObstacleDirty()
end

function Npc:onAbsorbBasicFields()
    Char.onAbsorbBasicFields(self)
end

function Npc:updateAfterLoadAction(notCheckFrozen)
    Char.updateAfterLoadAction(self, notCheckFrozen)

    self:showHeadTitle()
end

function Npc:onReloadObstacle()
    self:doPutNpc()
end

function Npc:showHeadTitle()
    if not self.charAction or not self.middleLayer or self.middleLayer:getChildByName("funcTitle") then
        return
    end

    if not self.headTitle then
        local npcInfo = MapMgr:getCurMapNpcByPosAndName(self:getName(), self:queryBasicInt("x"), self:queryBasicInt("y"))
        if not npcInfo or not npcInfo.headTitle then
            return
        end

        local titleInfo = npcInfo.headTitle

        if titleInfo.needHideInPublic and not DistMgr:curIsTestDist() then
            return
        end

        local bgImage = ccui.ImageView:create(ResMgr.ui.head_title_back)
        local bgImgSize = bgImage:getContentSize()

        -- 称谓名称
        local wordImg = ccui.ImageView:create(titleInfo.wordIcon)
        wordImg:setPosition(bgImgSize.width / 2 - 10, bgImgSize.height / 2)
        bgImage:addChild(wordImg)

        -- 称谓类别
        local classImg = ccui.ImageView:create(titleInfo.classIcon)
        classImg:setPosition(0, bgImgSize.height / 2)
        bgImage:addChild(classImg)

        bgImage:setName("funcTitle")
        self.middleLayer:addChild(bgImage, self:getMagicZorder(false), 0)

        self.headTitle = bgImage
    end

    if self.headTitle then
        local x, y = self.charAction:getHeadOffset()
        self.headTitle:setPosition(x + 30, y + 30)
    end
end

return Npc
