-- Char.lua
-- Created by chenyq Nov/14/2014
-- 场景中可显示角色模型的对象的基类

local List = require('core/List')
local Mapping = require('core/Mapping')
local Object = require("obj/Object")
local CharAction = require("animate/CharAction")
local CharActionBegin = require('animate/CharActionBegin')
local CharActionEnd = require('animate/CharActionEnd')
local CharActionNoLoop = require('animate/CharActionNoLoop')
local LIGHT_EFFECT = require(ResMgr:getCfgPath('LightEffect.lua'))
local IconColorScheme = require(ResMgr:getCfgPath("IconColorScheme.lua"))
local CharConfig = require(ResMgr:getCfgPath("CharConfig.lua"))

local Char = class("Char", Object)

-- 名字偏移、字体大小
local NAME_OFFSET = -20
local NAME_FONT_SIZE = 21
local CHENWEI_FONT_SIZE = 17
local MAX_MOVE_TO_STEPS = 14
local MAX_FOLLOW_LEN = 10
local SHADOW_TAG_ID = 13796 -- 随机取一个TAG id希望不要跟我重复了

local MOVE_STEP_MAX = 1  -- 自动寻路每次移动最大的限制

-- 名字中显示精灵的TAG
local NAME_TAG = 106 -- 随便取得，没什么依据
local TILE_TAG = 108 -- 随便取得，没什么依据
local SHARE_NAME_TAT_START = 120
local SHARE_NAME_TAT_END = 125

-- 自动寻路的最大步长
local MOVE_STEP_MAX_DIS = MOVE_STEP_MAX * math.min(Const.PANE_WIDTH, Const.PANE_HEIGHT)

-- 每步移动的最小允许时间间隔（ms）
local MOVE_ONE_STEP_MIN_TIME = 70

local GATHER_COUNT              = 4          -- 最大共乘数量

local EFFECT_POS =
{
    foot = 1,
    waist = 2,
    head = 3,
}

function Char:init()
    self.moveCmds = List.new()

    -- 战斗相关属性
    self.comAtt = Mapping.new()

    self.canMove = true

    self.speedPrecentOnlyClient = nil

    -- 角色光效
    self.magics = {}

    self.lastMapPosX = 0
    self.lastMapPosY = 0
    self.chatContent = {}

    self.followSprites = nil
end

function Char:getLoadType()
    return LOAD_TYPE.CHAR
end

function Char:queryInt(key)
    return Object.queryInt(self, key) + self.comAtt:queryInt(key)
end

function Char:queryIntWithOutComAtt(key)
    return Object.queryInt(self, key)
end

-- 吸收战斗相关属性
function Char:absorbComFields(tbl)
    self.comAtt:absorbFields(tbl)
end

-- 清除战斗吸收属性
function Char:cleanComAbsorbData()
    self.comAtt:cleanup()
end

-- 获取等级信息
function Char:getLevel()
    return self:queryBasicInt('level')
end

-- 对象进入场景
function Char:onEnterScene(mapX, mapY)
    -- 执行父类逻辑
    Object.onEnterScene(self, mapX, mapY)

    -- 更新名字
    self:updateName()

    -- 添加阴影
    self:addShadow()

    -- 设置lastMapPos点
    self:setLastMapPos(mapX, mapY)

    -- 设置隐藏的状态
    self:updateShelter(mapX, mapY)

    -- 跟随精灵进入场景
    self:doFollowSpritesEnterScene(mapX, mapY)

    EventDispatcher:addEventListener("ENTER_FOREGROUND", self.removeAllChat, self)
end

-- 对象离开场景
function Char:onExitScene()
    -- 当前Me选中的对象离开场景，需要进行相应的移除操作
    if Me.selectTarget
        and Me.selectTarget:getId() == self:getId()
        and self:getType() ~= "FightOpponent"
        and self:getType() ~= "FightFriend" then

        self:deleteMagic(ResMgr.magic.focus_target)

        -- 恢复阴影
        self:addShadow()
        Me.selectTarget:removeFocusMagic()

        Me.selectTarget = nil
    end

    self:deleteMagic(ResMgr.magic.elf)

    Object.onExitScene(self)

    self.charAction = nil
    self.nameLable = nil
    self.nameLable2 = nil
    self.gatherNameLabels = nil
    self.titleLable = nil
    self.footBallIcon = nil
    self.partyIcon = nil
    self.magics = {}
    self.chatContent = {}
    self.followMagic = nil

    -- 跟随精灵离开场景
    self:doFollowSpritesExitScene()

    EventDispatcher:removeEventListener("ENTER_FOREGROUND", self.removeAllChat, self)
end

-- 获取阴影，如果是乘骑模型，需要根据坐骑决定是否要阴影
function Char:getDefaultShadow()
    local petIcon = self:getRideIcon()
    if petIcon > 0 and not PetMgr:needShowCharShadow(petIcon) and
       self:queryBasicInt('mount_icon') == self:getIcon() then
        -- 显示的是乘骑模型，且不需要显示人物影子，直接返回即可
        return
    end

    return cc.Sprite:create(ResMgr.ui.char_shadow_img)
end

-- 获取相应的阴影，根据套装属性获取光效效果
function Char:getShadow()
    if self:getShadowIcon() > 0 then
        -- 使用自定义的影子动画
        return
    end

    local shadow_icon = self:queryBasic("shadow_icon")
    if shadow_icon and "" ~= shadow_icon and "0" ~= shadow_icon then
        -- 存在自定义影子
        local sp = cc.Sprite:create(ResMgr:getShadowFilePath(shadow_icon))
        local shadow_pos = self:queryBasic("shadow_pos")
        if shadow_pos then
            sp:setPosition(shadow_pos.x or 0, shadow_pos.y or 0)
        end
        return sp
    end

    local suit_light_effect = self:queryInt("suit_light_effect")

    if nil == suit_light_effect or 0 == suit_light_effect then
        return self:getDefaultShadow()
    end

    return gf:createLoopMagic(suit_light_effect)
end

-- 添加角色阴影
function Char:addShadow()
    -- 添加前先判断shadow是否已经存在
    self:removeShadow()

    local shadow = self:getShadow()
    if not shadow then
        return
    end

    shadow:setTag(SHADOW_TAG_ID)
    self:addToBottomLayer(shadow)
end

-- 移除shadow
function Char:removeShadow()
    if self.bottomLayer then
        local shadow = self.bottomLayer:getChildByTag(SHADOW_TAG_ID)
        if shadow ~= nil then
            shadow:removeFromParent()
        end
    end
end

-- 更新影子
function Char:updateShadow()
end

-- 重载
function Char:setVisible(visible)
    if self.visible == visible then return end

    Object.setVisible(self, visible)

    if visible then
        -- 如果设置的是显示的话，那么更新一下脚底踩的
        self:updateName()
    end

    if self.followSprites then
        for _, v in pairs(self.followSprites) do
            if v and 'function' == type(v.setVisible) then
                v:setVisible(visible)
            end
        end
    end
end

-- 更新名字颜色
function Char:updateNameColor()
end

-- 如果在活动 2019口味大战，需要改变颜色
function Char:getNameColorFor2019KWDZ(curTitle)
    if curTitle ~= CHS[4010251] and curTitle ~= CHS[4010252] then return end

    local act2019kwdzTitle = Me:isExsit2019kwdzChengWei()
    if act2019kwdzTitle then
        self:checkIsInTianyongLeiTai()
        Me:checkIsInTianyongLeiTai()
        if act2019kwdzTitle and self.isInTianyongLeiTai and act2019kwdzTitle ~= curTitle then
            return COLOR3.RED
        end
    end
end

function Char:isShowTitle()
    if MapMgr:isInYuLuXianChi() then
        return false
    end

    return true
end

-- 更新名字
function Char:updateName()
    if not self:getVisible() then
        -- 人物不显示，则不刷脚底下的标签了
        return
    end

    local gather_names = self:queryBasic("gather_names")
    local isShowGather = gather_names and #gather_names > 1 and self:isShowRidePet()

    -- 如果与当前的称谓不同则更新
    -- 玉露仙池地图中不显示称谓
    local isShowTitle = self:isShowTitle()
    local curTitle = not isShowGather and isShowTitle and self:getTitle() or ""
    local partyIconChanged
    if nil == self.titleLable or self.titleLable:getString() ~= curTitle then
        if self.titleLable then
            self.titleLable:getParent():removeFromParent(true)
            self.titleLable = nil
        end

        --创建称谓
        if curTitle ~= "" then
            local color = CharMgr:getChengWeiColor(curTitle, self:getShowName(), CHENWEI_FONT_SIZE)

            local showName = CharMgr:getChengweiShowName(curTitle)
            self.titleLable = self:addName(color, 0, NAME_OFFSET, showName, CHENWEI_FONT_SIZE, TILE_TAG)
        end

        partyIconChanged = true
    else
        -- 更新颜色
        local color = CharMgr:getChengWeiColor(curTitle, self:getShowName(), CHENWEI_FONT_SIZE)

        self.titleLable:setColor(color)

        -- 更新位置
        local image = self.middleLayer:getChildByTag(TILE_TAG)
        if image then
            image:setPosition(0, NAME_OFFSET)
        end
    end

    -- 如果没有名字，或者名字不一样
    local offY = 0
    if curTitle ~= "" then
        offY = (NAME_FONT_SIZE + CHENWEI_FONT_SIZE) / 2 + 6
    end

    -- 获取类型
    local type = self:queryBasicInt("type")
    local isVip = false

    if type == 0 then
        type = OBJECT_TYPE.CHAR
    end

    if Me:queryBasicInt("id") ~= self:queryBasicInt("id") then
        isVip = tonumber(self:queryBasicInt("vip_type")) > 0
    else
        local vipType = Me:getVipType()

        if vipType then
            isVip = Me:getVipType() > 0
        end
    end

    local rank = self:queryBasicInt("rank")
    local nameColor = CharMgr:getNameColorByType(type, isVip, rank)
    local dwj2019kwdzColor = self:getNameColorFor2019KWDZ(curTitle)

    if isShowGather then
        nameColor = COLOR3.GATHER_NAME_COLOR
    elseif Me:getTitle() ~= CHS[4300269] and GameMgr:isInPartyWar() and self:queryBasic("party") ~= Me:queryBasic("party/name") and self:getType() == "Player" and self:getTitle() ~= CHS[4300269] then
        nameColor = COLOR3.RED
    elseif DistMgr:isInKFZCServer() and self:queryBasic("title") ~= Me:queryBasic("title") and self:getType() == "Player" then
        nameColor = COLOR3.RED
    elseif dwj2019kwdzColor then
        nameColor = COLOR3.RED
    else
        nameColor = self:updateNameColor() or nameColor
    end

    if nil == self.nameLable or self.nameLable:getString() ~= self:getShowName() then
        --创建名字
        if self.nameLable then
            self.nameLable:getParent():removeFromParent(true)
            self.nameLable = nil
        end

        local meCamp = Me:queryBasic("camp")
        local otherCamp = self:queryBasic("camp")

        --[[
        -- 阵营不同，需要显示不同颜色
        if "" == meCamp or "" == otherCamp or meCamp == otherCamp then
        self.nameLable = self:addName(COLOR3.GREEN, 0, NAME_OFFSET - offY, self:getShowName(), NAME_FONT_SIZE)
        else
        self.nameLable = self:addName(COLOR3.RED, 0, NAME_OFFSET - offY, self:getShowName(), NAME_FONT_SIZE)
        end
        --]]
        if not string.isNilOrEmpty(self:getShowName()) then
            local cfg = CharMgr:getCharCfg(self:getIcon(), self:getName())
            local x, y = 0, 0
            if cfg then
                local actStr = tostring(self.faAct)
                if cfg[actStr] and cfg[actStr] then
                    x, y = cfg[actStr].nameOffset.x or 0, cfg[actStr].nameOffset.y or 0
                elseif cfg.nameOffset then
                    x, y = cfg.nameOffset.x or 0, cfg.nameOffset.y or 0
                end
            end
            self.nameLable, self.nameLable2 = self:addName(nameColor, x, y + NAME_OFFSET - offY, self:getShowName(), NAME_FONT_SIZE, NAME_TAG)
        end

        partyIconChanged = partyIconChanged or (not self.titleLable)
    else
        -- 更新颜色
        self.nameLable:setColor(nameColor)

        -- 更新位置
        local image = self.middleLayer:getChildByTag(NAME_TAG)
        if image then
            local x, y = 0, 0
            if not string.isNilOrEmpty(self:getShowName()) then
                local cfg = CharMgr:getCharCfg(self:getIcon(), self:getName())
                if cfg then
                    local actStr = tostring(self.faAct)
                    if cfg[actStr] and cfg[actStr] then
                        x, y = cfg[actStr].nameOffset.x or 0, cfg[actStr].nameOffset.y or 0
                    elseif cfg.nameOffset then
                        x, y = cfg.nameOffset.x or 0, cfg.nameOffset.y or 0
                    end
                end
            end

            image:setPosition(x, y + NAME_OFFSET - offY)
        end
    end

    local count = isShowGather and #gather_names - 1 or 0
    if isShowGather then
        if not self.gatherNameLabels then self.gatherNameLabels = {} end
        for i = 1, count do
            offY = offY - NAME_OFFSET + 7
            local showName = gf:getRealName(gather_names[i + 1]) or "[NAME]"
            local nameLabel = self.gatherNameLabels[i]
            if nil == nameLabel or nameLabel:getString() ~= showName then
                --创建名字
                if nameLabel then
                    nameLabel:getParent():removeFromParent(true)
                end

                if not string.isNilOrEmpty(showName) then
                    local cfg = CharMgr:getCharCfg(self:getIcon(), self:getName())
                    local x, y = 0, 0
                    if cfg then
                        local actStr = tostring(self.faAct)
                        if cfg[actStr] and cfg[actStr] then
                            x, y = cfg[actStr].nameOffset.x or 0, cfg[actStr].nameOffset.y or 0
                        elseif cfg.nameOffset then
                            x, y = cfg.nameOffset.x or 0, cfg.nameOffset.y or 0
                        end
                    end
                    nameLabel = self:addName(nameColor, x, y + NAME_OFFSET - offY, showName, NAME_FONT_SIZE, SHARE_NAME_TAT_START + i - 1)
                    self.gatherNameLabels[i] = nameLabel
                end
            else
                -- 更新颜色
                nameLabel:setColor(nameColor)

                -- 更新位置
                local tag = nameLabel:getParent():getTag()
                local image = self.middleLayer:getChildByTag(tag)
                if image then
                    local x, y = 0, 0
                    if not string.isNilOrEmpty(showName) then
                        local cfg = CharMgr:getCharCfg(self:getIcon(), self:getName())
                        if cfg then
                            local actStr = tostring(self.faAct)
                            if cfg[actStr] and cfg[actStr] then
                                x, y = cfg[actStr].nameOffset.x or 0, cfg[actStr].nameOffset.y or 0
                            elseif cfg.nameOffset then
                                x, y = cfg.nameOffset.x or 0, cfg.nameOffset.y or 0
                            end
                        end
                    end
                    image:setPosition(x, y + NAME_OFFSET - offY)
                end
            end
        end
    end

    if self.gatherNameLabels then
        for i = count + 1, #self.gatherNameLabels do
            if self.gatherNameLabels[i] then
                self.gatherNameLabels[i]:getParent():removeFromParent(true)
                self.gatherNameLabels[i] = nil
            end
        end
    end

    local partyRoot
    if self.titleLable then
        partyRoot = self.titleLable
    else
        partyRoot = self.nameLable
    end

    if isShowGather or not isShowTitle or (not self.partyIcon or self.showPartyIcon ~= self:queryBasic("party_icon") or partyIconChanged) then
        if self.partyIcon then
            self.partyIcon:removeFromParent(true)
            self.partyIcon = nil
        end

        if not isShowGather and isShowTitle then
            self.partyIcon = self:addPartyIcon(partyRoot)
        end
    end

    -- 世界杯要处理世界杯相关称谓的图标
    self:setFootBallIcon(curTitle, isShowGather, partyRoot)

    if self.partyIcon then
        local rootBg = partyRoot:getParent()
        local rootSize = rootBg:getContentSize()
        local iconSize = self.partyIcon:getContentSize()
        local px, py = rootBg:getPosition()

        self.partyIcon:setPosition(-rootSize.width / 2, NAME_OFFSET)
        rootBg:setPosition(px + iconSize.width / 2, py)
    end

    -- 如果战斗中被强制改名，2016中秋活动
    if (GameMgr.inCombat or Me:isLookOn()) and self.nameLable and self.nameLable2 then
        if FightMgr.glossObjsInfo[self:getId()] and FightMgr.glossObjsInfo[self:getId()].name then
            nameColor = CharMgr:getNameColorByType(FightMgr.glossObjsInfo[self:getId()].type)

            self.nameLable:setString(FightMgr.glossObjsInfo[self:getId()].name)
            self.nameLable2:setString(FightMgr.glossObjsInfo[self:getId()].name)
        else

            self.nameLable:setString(self:getShowName())
            self.nameLable2:setString(self:getShowName())
        end
        self.nameLable:setColor(nameColor)
    end
end

-- isShowGather 参照帮派图标，需要判断的。
function Char:setFootBallIcon(curTitle, isShowGather, partyRoot)
    if not string.match(curTitle, CHS[4300438]) then
        if self.footBallIcon then
            self.footBallIcon:removeFromParent(true)
            self.footBallIcon = nil
            self.showFootBallIcon = nil
        end
        return
    end

    if self.partyIcon then
        self.partyIcon:removeFromParent(true)
        self.partyIcon = nil
    end

    -- 如果没有球迷图标 或者 前后不一样
    if not self.footBallIcon or self.showFootBallIcon ~= string.match(curTitle, CHS[4300438]) then
        if self.footBallIcon then
            self.footBallIcon:removeFromParent(true)
            self.footBallIcon = nil
            self.showFootBallIcon = nil
        end

        if not isShowGather then
            self.footBallIcon = self:addQiuMiIcon(partyRoot, string.match(curTitle, CHS[4300438]))
        end
    end

    if self.footBallIcon then
        local rootBg = partyRoot:getParent()
        local rootSize = rootBg:getContentSize()
        local iconSize = self.footBallIcon:getContentSize()
        local px, py = rootBg:getPosition()

        self.footBallIcon:setPosition(-rootSize.width / 2, NAME_OFFSET)
        rootBg:setPosition(px + iconSize.width / 2, py)
    end
end

-- 添加名字
function Char:addName(color, offsetX, offsetY, str, fontSize, tag)
    local nameLabel = ccui.Text:create()
    nameLabel:setFontSize(fontSize)
    nameLabel:setString(str)
    nameLabel:setColor(color)
    local size = nameLabel:getContentSize()

    if fontSize == NAME_FONT_SIZE then
        size.width = size.width + 8
        size.height = size.height + 8
    else
        size.width = size.width + 8
        size.height = size.height + 4
    end

    -- 创建一个底图
    local bgImage = ccui.ImageView:create(ResMgr.ui.chenwei_name_bgimg, ccui.TextureResType.plistType)
    self.nameBgImage = bgImage
    local bgImgSize = bgImage:getContentSize()
    bgImage:setScale9Enabled(true)
    size.height = bgImgSize.height
    bgImage:setContentSize(size)
    nameLabel:setPosition(size.width / 2, size.height / 2)

    local nameLabel2 = nameLabel:clone()
    nameLabel2:setPosition(size.width / 2 + 1, size.height / 2)
    nameLabel2:setColor(COLOR3.BLACK)
    bgImage:addChild(nameLabel2)
    bgImage:addChild(nameLabel)

    bgImage:setPosition(offsetX, offsetY)
    bgImage:setTag(tag)
    self:addToMiddleLayer(bgImage)
    bgImage:setLocalZOrder(Const.NAME_ZORDER)
    return nameLabel, nameLabel2
end

-- 添加球迷图标
function Char:addQiuMiIcon(root, teamName)

    if not ResMgr.ui[teamName .. "title"] then return end
    local filePath = ResMgr.ui[teamName .. "title"]

    if not gf:isFileExist(filePath) then return end

    local bgImage = ccui.ImageView:create(filePath)
    bgImage:ignoreContentAdaptWithSize(false)
    bgImage:setContentSize(Const.PARTYICON_SHOWSIZE)
    local bgImgSize = bgImage:getContentSize()
    --bgImage:setPosition(offsetX - rootSize.width / 2 - bgImgSize.width / 2 - 4, offsetY)
    self:addToMiddleLayer(bgImage)
    bgImage:setLocalZOrder(Const.NAME_ZORDER)
    self.showFootBallIcon = teamName

    return bgImage, bgImgSize
end

-- 添加帮派图标
function Char:addPartyIcon(root)
    local fileName = self:queryBasic("party_icon")
    if string.isNilOrEmpty(fileName) then return end

    local filePath = ResMgr:getPartyIconPath(fileName)
    if not gf:isFileExist(filePath) then
        filePath = ResMgr:getCustomPartyIconPath(fileName)
    end

    if not gf:isFileExist(filePath) then return end

    local bgImage = ccui.ImageView:create(filePath)
    bgImage:ignoreContentAdaptWithSize(false)
    bgImage:setContentSize(Const.PARTYICON_SHOWSIZE)
    local bgImgSize = bgImage:getContentSize()
    --bgImage:setPosition(offsetX - rootSize.width / 2 - bgImgSize.width / 2 - 4, offsetY)
    self:addToMiddleLayer(bgImage)
    bgImage:setLocalZOrder(Const.NAME_ZORDER)
    self.showPartyIcon = fileName

    if self.footBallIcon then
        self.footBallIcon:removeFromParent(true)
        self.footBallIcon = nil
        self.showFootBallIcon = nil
    end

    return bgImage, bgImgSize
end

-- 获取 zorder 值
-- behind: 人物后面
function Char:getMagicZorder(behind)
    local zorder = Const.MAGIC_FRONT_ZORDER
    if behind then
        zorder = Const.MAGIC_BEHIND_ZORDER
    end

    return zorder
end

-- 删除光效
function Char:deleteMagic(key)
    if self.magics[key] then
        -- 移除
        if 'function' == type(self.magics[key].removeFromParent) then
        self.magics[key]:removeFromParent(true)
        elseif 'function' == type(self.magics[key].cleanup) then
            self.magics[key]:cleanup()
        end
        self.magics[key] = nil

        if key == ResMgr.magic.frozen then
            self:checkNeedPause()
        end
    end

    if self.toPlayMagic then
        self.toPlayMagic[key] = nil
    end

    if self.followMagic then
        self.followMagic[key] = nil
    end
end

function Char:playLightEffect(effect, data)
    local char = self
    if not char.charAction and
        (effect["pos"] == EFFECT_POS["waist"] or effect["pos"] == EFFECT_POS["head"]) then
        -- 腰部光效和头部光效依赖于 charAction，当前 charAction 还未创建
        -- 先缓存信息，在 charAction 创建后处理
        if not char.toPlayMagic then
            char.toPlayMagic = {}
        end

        char.toPlayMagic[data.effectIcon] = data

        return
    end

    local magicKey = nil

    if effect["magicKey"] == true then
        magicKey = data.effectIcon
    end

    local extraPara = data and data["extraPara"] or effect["extraPara"]
    if effect["pos"] == EFFECT_POS["foot"] then
        char:addMagicOnFoot(effect["icon"], effect["behind"], magicKey, effect["armatureType"], extraPara)
    elseif effect["pos"] == EFFECT_POS["waist"] then
        char:addMagicOnWaist(effect["icon"], effect["behind"], magicKey, effect["armatureType"], extraPara)
    elseif effect["pos"] == EFFECT_POS["head"] then
        char:addMagicOnHead(effect["icon"], effect["behind"], magicKey, effect["armatureType"], extraPara)
    end
end

-- behind：在人物前面还是人物后面
-- magicKey：如果没有设置，则动画播放完后自动删除
--            如果设置了，则动画循环播放，并保存在 self.magics 中
-- armatureType:
-- 0 不是骨骼动画；
-- 1 从map目录中取的骨骼动画；
-- 2 从skill目录中取的骨骼动画 ;
-- 3 从char目录中获取的龙骨动画；
-- layerFlag 1：顶层，   2：中级（默认），  3 下层    这里的层是指 整个战斗中层级
function Char:addMagic(x, y, icon, behind, magicKey, armatureType, extraPara, callback, layerFlag)

    if (not armatureType or armatureType == 0) and LIGHT_EFFECT[icon] then
        -- 九天的光效，有些服务器下发，但是没有 armatureType 数据，所以获取下
		-- 没有配置会设置为nil，0和nil逻辑一致
        armatureType = LIGHT_EFFECT[icon].armatureType
    end

    -- 额外的偏移设置下
    local showKey = magicKey or icon
    if LIGHT_EFFECT[showKey] and LIGHT_EFFECT[showKey].offset  then
        x = x + LIGHT_EFFECT[showKey].offset.x
        y = y + LIGHT_EFFECT[showKey].offset.y
    end

    layerFlag = layerFlag or 2
    local magic, dbMagic
    if magicKey and not callback then
        if self.magics[magicKey] then
            if 'function' == type(self.magics[magicKey].removeFromParent) then
                -- 已存在该光效，先移除
                self.magics[magicKey]:removeFromParent(true)
            elseif 'function' == type(self.magics[magicKey].cleanup) then
                self.magics[magicKey]:cleanup()
            end
        end

        if ResMgr.magic.elf == icon then
            -- 跟随精灵
            magic = require("obj/FollowElf").new()
            magic:setOwner(self)
            magic:absorbBasicFields({
                id = id,
                icon = icon,
                dir = self:getDir()
            })

            magic:setVisible(self.visible)
            magic:setAct(Const.FA_STAND)
            magic:onEnterScene(gf:convertToMapSpace(self.curX, self.curY))
            self.magics[magicKey] = magic
            return magic
        elseif not armatureType or armatureType == 0 then
            magic = gf:createLoopMagic(icon, nil, extraPara)
        elseif armatureType == 3 then
            if type(icon) == "table" then
                dbMagic = DragonBonesMgr:createCharDragonBones(icon.icon, icon.armatureName)
                if dbMagic then
                    magic = tolua.cast(dbMagic, "cc.Node")
                end
            end
        else
            local actionName
            if LIGHT_EFFECT[icon] and LIGHT_EFFECT[icon]["action"] then
                -- 如果骨骼动画已经配置了动作名，则使用配置的
                actionName = LIGHT_EFFECT[icon]["action"][self:getDir()]
            end

            if not actionName then
                actionName = "Top"
                if behind then
                    actionName = "Bottom"
                end
            end

            magic = ArmatureMgr:createArmatureByType(armatureType, icon, actionName)

            -- 需要循环播放骨骼动画
            magic:getAnimation():play(actionName, -1, 1)
        end

        -- 记录真实播放使用的光效编号
        magic.showKey = gf:tryConvertMagicKey(magicKey, self:getIcon())
        self.magics[magicKey] = magic
    else
        if not armatureType or armatureType == 0 then
            if callback then
                magic = gf:createCallbackMagic(icon, callback, extraPara)
            else
                magic = gf:createSelfRemoveMagic(icon, extraPara)
            end
        else
            local actionName
            if LIGHT_EFFECT[icon] and LIGHT_EFFECT[icon]["action"] then
                -- 如果骨骼动画已经配置了动作名，则使用配置的
                actionName = LIGHT_EFFECT[icon]["action"][self:getDir()]
            end

            if not actionName then
                actionName = "Top"
                if behind then
                    actionName = "Bottom"
                end
            end

            magic = ArmatureMgr:createArmatureByType(armatureType, icon, actionName)

            -- 仅播一次的骨骼动画
            ArmatureMgr:setArmaturePlayOnce(magic, actionName)
        end
    end

    local zorder = self:getMagicZorder(behind)

    magic:setPosition(x, y)
    magic:setLocalZOrder(zorder)

    if layerFlag == 1 then
        self:addToTopLayer(magic)
    elseif layerFlag == 3 then
        self:addToBottomLayer(magic)
    else
        self:addToMiddleLayer(magic)
    end

    -- 添加冰冻光效要停止播放动画
    if magicKey == ResMgr.magic.frozen then
        self:checkNeedPause()
    end

    return magic, dbMagic
end

-- 在脚基准点上添加光效
-- behind：在人物前面还是人物后面
-- magicKey：如果没有设置，则动画播放完后自动删除
--           如果设置了，则动画循环播放，并保存在 self.magics 中
function Char:addMagicOnFoot(icon, behind, magicKey, armatureType, extraPara, callback, layerFlag)
    local x = 0
    local y = 0
    if type(icon) == "table" then
        if icon["y"] then
            y = icon["y"]
        end
    end

    return self:addMagic(x, y, icon, behind, magicKey, armatureType, extraPara, callback, layerFlag)
end

-- 在腰基准点上添加光效
-- behind：在人物前面还是人物后面
-- magicKey：如果没有设置，则动画播放完后自动删除
--           如果设置了，则动画循环播放，并保存在 self.magics 中
function Char:addMagicOnWaist(icon, behind, magicKey, armatureType, extraPara, callback, layerFlag)
    if self.charAction then
        local x, y = self.charAction:getWaistOffset()
        local magic = self:addMagic(x, y, icon, behind, magicKey, armatureType, extraPara, callback, layerFlag)
        magic.getPosFunc = "getWaistOffset"

        return magic
    end
end

-- 在头基准点上添加光效
-- behind：在人物前面还是人物后面
-- magicKey：如果没有设置，则动画播放完后自动删除
--           如果设置了，则动画循环播放
function Char:addMagicOnHead(icon, behind, magicKey, armatureType, extraPara, callback, layerFlag)
    if self.charAction then
        local x, y = self.charAction:getHeadOffset()
        local magic = self:addMagic(x, y, icon, behind, magicKey, armatureType, extraPara, callback, layerFlag)
        magic.getPosFunc = "getHeadOffset"
        return magic
    end
end

function Char:updateMagics()
    local t = {}
    for k, v in pairs(self.magics) do
        local nk = gf:tryConvertMagicKey(k, self:getIcon()) -- 转换光效
        if nk ~= v.showKey then -- 光效需要进行转换
            table.insert(t, k)
        end
    end

    for i = 1, #t do
        self:deleteMagic(t[i])
        CharMgr:playLightEffect(self, {charId = self:getId(), effectIcon = t[i]})
    end
end

function Char:isFrozen()
    local icon = ResMgr.magic.frozen
    if self.magics and self.magics[icon] and self.magics[icon]:isVisible() then
        return true
    end
end

function Char:checkNeedPause()
    if self:isFrozen() then
        if self.charAction and not self.charAction.isPausePlay then
            self.charAction:pausePlay()
        end
    else
        if self.charAction and self.charAction.isPausePlay then
            self.charAction:continuePlay()
        end
    end
end

-- 点击角色
function Char:onClickChar()
    -- 记录最近点击对象
    Me.lastSelectChar = self:queryBasic('name')
    Log:D('onClickChar: ' .. self:queryBasic('name'))
    local action = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function() Me.lastSelectChar = nil end))
    Me.charAction:runAction(action)
end

-- 点击对象时添加选中特效
function Char:addFocusMagic()

    -- 如果长按事件没有触发且没有自定影子
    local shadow_icon = self:queryBasic("shadow_icon")
    if not DlgMgr:isDlgOpened("UserListDlg") and (not shadow_icon or "" == shadow_icon or "0" == shadow_icon) then
        self:addMagicOnFoot(ResMgr.magic.focus_target, true, ResMgr.magic.focus_target)

        self:removeShadow()
    end
end

-- 当角色失去焦点时移除光效
function Char:removeFocusMagic()
    if Me.selectTarget then
        self:deleteMagic(ResMgr.magic.focus_target)
        -- 恢复阴影
        self:addShadow()
        Me.selectTarget = nil
    end
end

-- 点击角色后应该弹出对话框
function Char:showTargetHeadDlg()
    if self:getType() == "Player" then
        if not DlgMgr:isDlgOpened("UserListDlg") and not DlgMgr:isDlgOpened("NpcDlg") and not DlgMgr:isDlgOpened("UseBarDlg") then
                local dlg = DlgMgr:openDlg("CharPortraitDlg")
                dlg:setSelectTarget(Me.selectTarget:queryBasic("gid"))
                dlg:setChar(Me.selectTarget)
            end
        end
end

-- 绑定事件
function Char:bindEvent()
    if not self.needBindClickEvent then
        return
    end

    -- 绑定角色点击事件
    if self.charAction then
        local this = self
        local function onTouchBegan(touch, event)
            if event:getEventCode() == cc.EventCode.BEGAN then
                if self:queryBasicInt("type") == OBJECT_TYPE.SHINVTU_NPC then return end
                local function containsTouchPos()
                    if self.charAction.containsTouchPos then
                        return self.charAction:containsTouchPos(touch)
                    else
                        local pos = self.middleLayer:convertTouchToNodeSpace(touch)
                        local rect = self.charAction:getBoundingBox()
                        return cc.rectContainsPoint(rect, pos)
                    end
                end

                -- 可见时才处理 Touch 事件
                if containsTouchPos() and self.visible and self:isCanTouch() and self:getType() ~= "Pet" then

                    if MapMgr:isInMapByName(CHS[4010025]) and self:getType() ~= "Npc" and self:getType() ~= "GatherNpc" then
                    -- 如果端午节采集仙粽子，在无名仙境， 点击怪物不响应
                    elseif MapMgr:isInMapByName(CHS[4101241]) and self:getType() ~= "Npc" and self:getType() ~= "GatherNpc" then

                    elseif KuafzcMgr:isInKuafzc2019() and not KuafzcMgr:isMyDomain() and self:getType() == "Npc" then

                    elseif MapMgr:isInYuLuXianChi() and WenQuanMgr:isInThrowSoap() and self:getType() == "Player" then
                        -- 玉露仙池地图中执行扔肥皂效果
                        WenQuanMgr:mePlayThrowSoap(touch:getLocation(), self)
                        return true
                    else
                        if not CharMgr:openCharMenuContentDlg(touch, self:getId()) then
                            if Me:getId() == self:getId() then
                                -- 点击 me 时应透到下一层
                                return false
                            end

                            if Me:isControlMove() and self:getType() == "Player" then
                                local pos = touch:getLocation()
                                if MapMgr:isInYuLuXianChi() then
                                    -- 玉露仙池地图中调整目的地
                                    pos = WenQuanMgr:getClickCharToPos(self)
                                end

                                Me:touchMapBegin(pos)
                                Me:touchMapEnd(pos)
                            end

                            self:onClickChar()
                        end

                        return true
                    end
                end

                return false
            elseif event:getEventCode() == cc.EventCode.ENDED then
                if Me:queryBasicInt("id") ~= self:queryBasicInt("id") and self:getType() ~= "Pet" then
                    if self:getType() == "Npc" or self:getType() == "Monster" then
                        if TeamMgr:isTeamMeber(Me) then
                            -- 点击地板是事件结束
                            Me:touchMapEnd(touch:getLocation())
                            return
                        end
                    end

                    if Me.selectTarget then
                        -- 移除上一个对象的光效
                        Me.selectTarget:removeFocusMagic()
                    end

                    Me.selectTarget = self
                    self:showTargetHeadDlg()
                    self:addFocusMagic()
                end

                -- 点击地板是事件结束
                Me:touchMapEnd(touch:getLocation())
                return false
            end
        end

        gf:bindTouchListener(self.charAction, onTouchBegan, cc.Handler.EVENT_TOUCH_ENDED, false)
    end
end

-- 有对象点击是没有响应，默认为可以点击，如果需要不点击直接重载
function Char:isCanTouch()
    if MarryMgr:isWeddingStatus() or ActivityMgr:isChantingStauts() or DlgMgr:isDlgOpened("ItemPuttingDlg") then
        return false
    else
        return not self.disableTouch
    end
end

function Char:setCanTouch(isTouch)
    self.disableTouch = not isTouch
end

-- 设置是否可以移动 todo
function Char:setCanMove(flag)
    self.canMove = flag
end

-- 是否可以移动
function Char:getCanMove()
    return self.canMove
end

function Char:isShowRidePet()
    if self:queryBasicInt("notShowRidePet") == 0 then
        return gf:isShowRidePet() or (self:queryBasicInt("share_mount_leader_id") == Me:getId())
            or (Me:queryBasicInt("share_mount_leader_id") == self:getId() and ResMgr:isCoupleRideIcon(self:queryBasicInt('share_mount_icon')))
    else
        return false
    end
end

function Char:getDlgIcon(excludeRideIcon, excludeShowChild, excludeColorIcon)
    return self:getRawIcon(excludeRideIcon, excludeShowChild, excludeColorIcon)
end

-- excludeRideIcon  不获取坐骑 icon
-- excludeShowChild 不获取元婴/血婴 icon
-- excludeColorIcon 不获取换色后的 icon
function Char:getRawIcon(excludeRideIcon, excludeShowChild, excludeColorIcon, exclodeSpecialIcon)
    local icon
    repeat
        if self:queryBasicInt('mount_icon') ~= 0 and not excludeRideIcon and self:isShowRidePet() then
            icon = self:queryBasicInt('mount_icon')
            break
        end

        if self:queryBasicInt('special_icon') ~= 0 and not exclodeSpecialIcon then
            icon = self:queryBasicInt('special_icon')
            if self:queryBasicInt('notShowHunfu') == 0 or (icon ~= 42101 and icon ~= 42102 and icon ~= 7007 and  icon ~= 7006) then
                break
            end
        end

        if not excludeShowChild then
            if self:queryBasicInt("upgrade/state") == 1 then
                icon = 07008
                break
            elseif self:queryBasicInt("upgrade/state") == 2 then
                icon = 07009
                break
            end
        end

        if self:queryBasicInt("suit_icon") ~= 0 and gf:isShowSuit() then
            icon = self:queryBasicInt("suit_icon")
            break
        end

        icon = self:queryBasicInt('icon')
    until true

    if icon and not excludeColorIcon then
        local cIcon = IconColorScheme and IconColorScheme[icon] and IconColorScheme[icon].org_icon
        icon = cIcon or icon
    end

    if not gf:isCharExist(icon) then
        icon = 6004
    end

    return icon
end

-- excludeRideIcon  不获取坐骑 icon
-- excludeShowChild 不获取元婴/血婴 icon
-- excludeColorIcon 不获取换色后的 icon
function Char:getIcon(excludeRideIcon, excludeShowChild, excludeColorIcon, exclodeSpecialIcon)
    return self:getRawIcon(excludeRideIcon, excludeShowChild, excludeColorIcon, exclodeSpecialIcon)
end

function Char:getOrgIcon()
    return self:queryBasicInt("org_icon")
end

function Char:getDlgWeaponIcon(excludeRideIcon, excludeShowChild)
    return self:getRawWeaponIcon(excludeRideIcon, excludeShowChild)
end

function Char:getRawWeaponIcon(excludeRideIcon, excludeShowChild)
    -- 更换形象 不需要武器
    if self:queryBasicInt('special_icon') ~= 0 or not gf:isShowWeapon() then
        return 0
    end

    if self:queryBasicInt("upgrade/state") ~= 0 and not excludeShowChild then
        return 0
    end

    -- 有坐骑时不显示武器
    if self:getRideIcon() > 0 and not excludeRideIcon then
        return 0
    end

    local weaponIcon = self:queryBasicInt('weapon_icon')
    return weaponIcon
end

function Char:getWeaponIcon(excludeRideIcon, excludeShowChild)
    return self:getRawWeaponIcon(excludeRideIcon, excludeShowChild)
end

function Char:getRideIcon()
    if not self:isShowRidePet() then
        return 0
    end

    local petIcon = self:queryBasicInt("share_mount_icon")
    if 0 == petIcon then
        petIcon = self:queryBasicInt("pet_icon")
    end

    if CharConfig[petIcon] then
        local showMountIcons = CharConfig[petIcon].showMountIcons
        if showMountIcons and #showMountIcons > 0 then
            local changeTime = CharConfig[petIcon].showMountTime
            local index = (self:getId() + math.floor(gf:getServerTime() / changeTime)) % 3 + 1
            petIcon = showMountIcons[index]
        end
    end

    return petIcon
end

function Char:getGatherIcons()
    if not self:isShowRidePet() then return end
    local gatherCount = self:queryBasicInt("gather_count")
    if not gatherCount or gatherCount <= 0 then return end

    local gatherIcons = self:queryBasic("gather_icons")
    return gatherIcons
end

function Char:getShadowIcon()
    return self:isShowRidePet() and self:queryBasicInt("share_mount_shadow") or 0
end

function Char:getDlgPartIndex(excludeRideIcon)
    return self:getRawPartIndex(excludeRideIcon)
end

function Char:getRawPartIndex(excludeRideIcon)
    if self:queryBasicInt('mount_icon') ~= 0 and self:isShowRidePet() and not excludeRideIcon then
        return ""
    end

    local icon = self:getIcon(true, nil, true)
    if icon and IconColorScheme[icon] then
        return IconColorScheme[icon].part
    end

    return self:queryBasic("part_index")
end

-- 获取部件索引
function Char:getPartIndex(excludeRideIcon)
    return self:getRawPartIndex(excludeRideIcon)
end

function Char:getDlgPartColorIndex(excludeRideIcon)
    return self:getRawPartColorIndex(excludeRideIcon)
end

function Char:getRawPartColorIndex(excludeRideIcon)
    if self:queryBasicInt('mount_icon') ~= 0 and self:isShowRidePet() and not excludeRideIcon then
        return ""
    end

    local icon = self:getIcon(true, nil, true)
    if icon and IconColorScheme[icon] then
        return IconColorScheme[icon].dye
    end

    return self:queryBasic("part_color_index")
end

-- 获取部件换色
function Char:getPartColorIndex(excludeRideIcon)
    return self:getRawPartColorIndex(excludeRideIcon)
end

-- 动作播放完成
function Char:onActionEnd()
    if self.endActCallback then
        self.endActCallback(self.faAct)
        self.endActCallback = nil
    end
end

function Char:setEndActCallback(callback)
    self.endActCallback = callback
end

function Char:isChangeRideIcon()
    return self:queryBasicInt("pet_icon") ~= self.rideIcon
end

-- 是否为站立动作
function Char:isStandAction()
    return self.faAct == Const.FA_STAND
end

-- 是否为站立动作
function Char:isWalkAction()
    return self.faAct == Const.FA_WALK
end

function Char:recordCallLog(index)
    if 1 == index then
        self.setActCallIndex = {}
    elseif not index then
        self.setActCallIndex = nil
    end

    if self.setActCallIndex then
        table.insert(self.setActCallIndex, index)
    end
end

function Char:createCharAction(syncLoad, cb)
    return CharAction.new(syncLoad, cb)
end

-- 设置动作速率， speed : 2 速度变为原来一倍
function Char:setActSpeed(speed)
    if not self.charAction then return end
    self.charAction:setAnimationSpeed(speed)
end

-- 设置动作，内测专区增加异常处理WDSY-29520
function Char:setAct(act, callback)
    if DistMgr:curIsTestDist() then
        xpcall(function() self:_setAct(act, callback) end, __G__TRACKBACK__)
    else
        self:_setAct(act, callback)
    end
end

function Char:setActAndCB(act, callBack)
    if self:getId() == Me:getId() then
        self:setAct(act, nil, callBack)
    else
        self:setAct(act, callBack)
    end
end

-- 设置动作  回调，无callBack则 self:onActionEnd()
function Char:_setAct(act, callBack)
    if self.faAct == act and self.charAction and (self.faAct == Const.FA_STAND or self.faAct == Const.FA_WALK) then
        -- 动作相同且为站立或者行走，不用重新设置
        return
    end

    self.actChanged = true
    self:recordCallLog(1)   -- WDSY-22243

    -- 检测当前是否停止特殊动作
    CharMgr:checkStatusAction(self:getId(), act)

    if self.charAction and (self.faAct == Const.FA_STAND and act == Const.FA_WALK
        or self.faAct == Const.FA_WALK and act == Const.FA_STAND) then
        -- 动作已存在，从走路切换到站立或者从站立切换到走路，不需要重新创建
        if act == Const.FA_STAND and self.paths then
            -- 如果发现当前状态是从 走路切换到站立，需进行是否是障碍点判断
            -- 因为坐标的多次转换，并且是向下取整的操作，故而在多次之后，可能会出现坐标点的部分丢失
            -- 所以如果发现时障碍点，则需要从旁边的点中寻找一点不是障碍点进行移动
            -- 首先判断是否是障碍点
            local mapX, mapY = gf:convertToMapSpace(self.curX, self.curY)
            if GObstacle:Instance():IsObstacle(mapX, mapY) and not self.dontCheckObstacle then
                local i = 1
                local dir = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
                -- 遍历四个方向寻找第一个不是障碍点的点，走过去
                for i = 1, #dir do
                    local findX, findY = mapX + dir[i][1], mapY + dir[i][2]
                    if not GObstacle:Instance():IsObstacle(findX, findY) then
                        act = Const.FA_WALK
                        local step = {}
                        local clientFindX, clientFindY = gf:convertToClientSpace(findX, findY)
                        self.paths[string.format("x%d", self.posCount + 1)] = clientFindX
                        self.paths[string.format("y%d", self.posCount + 1)] = clientFindY
                        self.paths[string.format("len%d", self.posCount + 1)] = self.paths[string.format("len%d", self.posCount)] + 10
                        self.posCount = self.posCount + 1
                        break
                    end
                end
            else
                -- 切换到站立模式，清除行走路径信息
                -- 因为这个可能是进入战斗了，Me:setAct(Const.FA_STAND)
                -- 清除路径的时机也是动作改为站立的时候，
                -- 这个时候可能行走未完成，需要缓存上一次的路径信息，以便战斗后继续行走
                self.lastPaths = self.paths
                self.lastPosCount = self.posCount
                self.paths = nil
                self.posCount = 0
            end
        end

        self.faAct = act
        self:recordCallLog(2)   -- WDSY-22243
        if act == Const.FA_STAND then
            self.charAction:setAction(Const.SA_STAND)
        else
            self.charAction:setAction(Const.SA_WALK)
        end

        self:recordCallLog()   -- WDSY-22243
        return
    end

    self.faAct = act
    if self.charAction and self.charAction.icon == 42101 then
        if act == Const.FA_BAIBAI then -- 结婚拜拜动作
            self.charAction:setAction(Const.SA_BAIBAI)
            self:recordCallLog()   -- WDSY-22243
            return
        elseif act == Const.FA_YONGBAO then -- 结婚拥抱动作
            self.charAction:setAction(Const.SA_YONGBAO)
            self:recordCallLog()   -- WDSY-22243
            return
        elseif act == Const.FA_JIAOBEI then -- 结婚交杯动作
            self.charAction:setAction(Const.SA_JIAOBEI)
            self:recordCallLog()   -- WDSY-22243
            return
        elseif act == Const.FA_QINQIN then -- 结婚亲亲动作
            self.charAction:setAction(Const.SA_QINQIN)
            self:recordCallLog()   -- WDSY-22243
            return
        end
    end

    self:recordCallLog(4)   -- WDSY-22243

    if act == Const.FA_QUIT_GAME then
        -- 退出战斗时，不改变动作
        self:recordCallLog()   -- WDSY-22243
        return
    end

    -- 先清除之前的动作
    if self.charAction then
        local charAct = self.charAction
        charAct:setLoadComplateCallBack(nil) -- 清除播放动作的回调
        charAct:clearEndActionCallBack()
        self.charAction = nil

        -- 需要延迟一帧删除，否则切换动作时会闪一下
        performWithDelay(self.middleLayer, function() charAct:removeFromParent(true) end, 0)
        self:recordCallLog(5)   -- WDSY-22243
    end

    local icon = self:getIcon()
    local orgIcon = self:getOrgIcon()
    local weaponIcon = self:getWeaponIcon()
    local gatherIcons = self:getGatherIcons()
    local shadowIcon = self:getShadowIcon()
    local partIndex = self:getPartIndex()
    local partColorIndex = self:getPartColorIndex()

    if FightMgr.glossObjsInfo[self:getId()] and FightMgr.glossObjsInfo[self:getId()].icon then
        icon = FightMgr.glossObjsInfo[self:getId()].icon
        partIndex = FightMgr.glossObjsInfo[self:getId()].part_index
        partColorIndex = FightMgr.glossObjsInfo[self:getId()].part_color_index
        weaponIcon = 0

        local cIcon = IconColorScheme and IconColorScheme[icon] and IconColorScheme[icon].org_icon
        icon = cIcon or icon
    end

    local cfg = CharMgr:getCharCfg(self:getIcon(), self:getName())
    if cfg and cfg[tostring(self.faAct)] then
        if cfg[tostring(self.faAct)].nameOffset then
            self:updateName()
        end
    end

    local dir = self:getDir()
    local cb
    if callBack then
        cb = callBack
    else
        cb = function() self:onActionEnd() end
    end
    local loadCb = function() self:updateAfterLoadAction() end
    local charAction
    local loadType = self:getLoadType()
    self:recordCallLog(6)   -- WDSY-22243
    if act == Const.FA_STAND or
        act == Const.FA_DODGE_START or
        act == Const.FA_DODGE_END then
        -- 站立、 开始躲避动作(离开站立原点)、结束躲避动作(回到站立原点)
        self:recordCallLog(7)   -- WDSY-22243
        charAction = self:createCharAction(not Me:isInCombat(), loadCb)
        charAction.owner = self
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        local petIcon = self:getRideIcon()
        self.rideIcon = petIcon
        self:recordCallLog(8)   -- WDSY-22243
        charAction:set(icon, weaponIcon, Const.SA_STAND, dir, petIcon, gatherIcons, shadowIcon, partIndex)
        self:recordCallLog(9)   -- WDSY-22243
    elseif act == Const.FA_WALK or
        act == Const.FA_GO_AHEAD or
        act == Const.FA_GO_BACK or
        act == Const.FA_GO_TO_PROTECT or
        act == Const.FA_PROTECT_BACK then
        -- 走路、人物前移到对方前面、人物从目标点回来、前去保护、保护回来
        self:recordCallLog(10)   -- WDSY-22243
        charAction = self:createCharAction(not Me:isInCombat(), loadCb, self)
        charAction.owner = self
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        local petIcon = self:getRideIcon()
        self.rideIcon = petIcon
        self:recordCallLog(11)   -- WDSY-22243
        charAction:set(icon, weaponIcon, Const.SA_WALK, dir, petIcon, gatherIcons, shadowIcon, partIndex)
        self:recordCallLog(12)   -- WDSY-22243
    elseif act == Const.FA_DIE_NOW then
        -- 正在死亡
        charAction = CharActionBegin.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_DIE, dir, partIndex, cb)
    elseif act == Const.FA_DIED then
        -- 已经死亡
        charAction = CharActionEnd.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_DIE, dir, partIndex, cb)
    elseif act == Const.FA_ACTION_PHYSICAL_ATTACK or
        act == Const.FA_ACTION_COUNTER_ATTACK then
        -- 物理攻击、反击
        charAction = CharActionBegin.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_ATTACK, dir, partIndex, cb)
    elseif act == Const.FA_ACTION_ATTACK_FINISH then
        -- 攻击完成
        charAction = CharActionEnd.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_ATTACK, dir, partIndex, cb)
    elseif act == Const.FA_PHYSICAL_ATTACK_LOOP then
        charAction = CharAction.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_ATTACK, dir, nil, nil, nil, partIndex)
    elseif act == Const.FA_DEFENSE_LOOP then
        charAction = CharAction.new()
        charAction:setLoadType(loadType)

        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_PARRY, dir, nil, nil, nil, partIndex)
    elseif act == Const.FA_ACTION_FLEE then
        -- 逃跑
        charAction = CharActionNoLoop.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_WALK, dir, partIndex, cb)
    elseif act == Const.FA_ACTION_REVIVE then
        -- 重生
        charAction = CharActionNoLoop.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:setReverse(true)
        charAction:set(icon, weaponIcon, Const.SA_DIE, dir, partIndex, cb)

        if DistMgr and DistMgr:curIsTestDist() and self:queryBasicInt("life") <= 0 then
            DebugMgr:MSG_UPLOAD_COMBAT_MESSAGE()
        end
    elseif act == Const.FA_DEFENSE_START then
        -- 人物被击中时的动作状态
        charAction = CharActionBegin.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_DEFENSE, dir, partIndex, cb)
    elseif act == Const.FA_DEFENSE_END then
        -- 防御结束
        charAction = CharActionEnd.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_DEFENSE, dir, partIndex, cb)
    elseif act == Const.FA_DEFENSE then
        -- 防御结束
        charAction = CharActionNoLoop.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_DEFENSE, dir, partIndex, cb)
    elseif act == Const.FA_DYMAGE_COUNTER or
        act == Const.FA_PARRY_START then
        -- 反击伤害、格挡开始
        charAction = CharActionBegin.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_PARRY, dir, partIndex, cb)
    elseif act == Const.FA_PARRY_END then
        -- 格挡结束
        charAction = CharActionEnd.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_PARRY, dir, partIndex, cb)
    elseif act == Const.FA_ACTION_CAST_MAGIC then
        -- 施展魔法
        charAction = CharActionBegin.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_CAST, dir, partIndex, cb)
    elseif act == Const.FA_ACTION_CAST_MAGIC_END then
        -- 施展魔法结束
        charAction = CharActionEnd.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_CAST, dir, partIndex, cb)

    elseif act == Const.FA_BE_CALLBACK or       -- (宠物)被召回
        act == Const.FA_ACTION_DEFENSE or       -- 防御
        act == Const.FA_ACTION_APPLY_ITEM or    -- 使用道具
        act == Const.FA_ACTION_BE_APPLY_ITEM or -- 道具被使用
        act == Const.FA_ACTION_USE_STUNT or     -- 施展绝技
        act == Const.FA_ACTION_SELECT_PET or    -- 选择宠物出战
        act == Const.FA_ACTION_CALLBACK_PET or  -- 召回宠物
        act == Const.FA_ACTION_CATCH_PET or     -- 捕捉宠物
        act == Const.FA_ACTION_GUARD or         -- 保护
        act == Const.FA_ACTION_JOINT_ATTACK or  -- 合击
        act == Const.FA_ACTION_DOUBLE_HIT or    -- 连击
        act == Const.FA_DYMAGE_MAGIC or         -- 魔法伤害
        act == Const.FA_DYMAGE_POSION or        -- 毒伤害
        act == Const.FA_DYMAGE_SEL or           -- 反震伤害
        act == Const.FA_DYMAGE_DOUBLE_HIT or    -- 连击伤害
        act == Const.FA_DYMAGE_STUNT or         -- 绝招伤害
        act == Const.FA_DYMAGE_JOINT or         -- 合击伤害
        act == Const.FA_DYMAGE_GUARD then       -- 保护伤害
        charAction = CharActionBegin.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, 0, Const.SA_CAST, dir, partIndex, cb)

    -- 以下为特殊动作
    elseif act == Const.FA_BAIBAI then -- 结婚拜拜动作
        charAction = CharAction.new(not Me:isInCombat(), loadCb)
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, 0, Const.SA_BAIBAI, dir)
    elseif act == Const.FA_YONGBAO then -- 结婚拥抱动作
        charAction = CharAction.new(not Me:isInCombat(), loadCb)
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, 0, Const.SA_YONGBAO, dir)
    elseif act == Const.FA_JIAOBEI then -- 结婚交杯动作
        charAction = CharAction.new(not Me:isInCombat(), loadCb)
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, 0, Const.SA_JIAOBEI, dir)
    elseif act == Const.FA_QINQIN then -- 结婚亲亲动作
        charAction = CharAction.new(not Me:isInCombat(), loadCb)
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_QINQIN, dir)
    elseif act == Const.FA_QINQIN_ONE then
        charAction = CharActionNoLoop.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_QINQIN, dir, partIndex, cb)
    elseif act == Const.FA_YONGBAO_ONE then
        charAction = CharActionNoLoop.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_YONGBAO, dir, partIndex, cb)
    elseif act == Const.FA_SHOW_BEGIN then
        charAction = CharActionBegin.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_SHOW, dir, partIndex, cb)
    elseif act == Const.FA_SHOW_END then
        charAction = CharActionEnd.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_SHOW, dir, partIndex, cb)
    elseif act == Const.FA_SNUGGLE then
        charAction = CharAction.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, 0, Const.SA_SNUGGLE, dir)
    elseif act == Const.FA_BOW then
        charAction = CharActionNoLoop.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, 0, Const.SA_BOW, dir, partIndex, cb)
    elseif act == Const.FA_CLEAN then
        charAction = CharAction.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, 0, Const.SA_CLEAN, dir)
        -- charAction:set(icon, 0, Const.SA_CAST, dir) -- for test
    elseif act == Const.FA_EAT then
        charAction = CharActionNoLoop.new(true, loadCb)
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, 0, Const.SA_EAT, dir, partIndex, cb)
    elseif act == Const.FA_EAT_LOOP then
        charAction = CharAction.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_EAT, dir, nil, nil, nil, partIndex)
    elseif act == Const.FA_SIT_LOOP then
        charAction = CharAction.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_SIT, dir, nil, nil, nil, partIndex)
    elseif act == Const.FA_FLAPPING then
        -- 拍
        charAction = CharActionNoLoop.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_FLAPPING, dir, partIndex, cb)
    elseif act == Const.FA_THROW_BEGIN then
        charAction = CharActionBegin.new()
        charAction:setLastFrame(4)
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_THROW, dir, partIndex, cb)
    elseif act == Const.FA_THROW_END then
        charAction = CharActionEnd.new()
        charAction:setFirstFrame(5)
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_THROW, dir, partIndex, cb)
    else
        Log:W("Unknown action: " .. act)
        charAction = CharActionBegin.new()
        charAction:setLoadType(loadType)
        charAction.orgIcon = orgIcon
        charAction:set(icon, weaponIcon, Const.SA_CAST, dir, partIndex, cb)
    end

    -- 设置换色方案
    charAction:setBodyColorIndex(partColorIndex)

    -- 添加到中间层
    self:recordCallLog(13)   -- WDSY-22243
    self:addToMiddleLayer(charAction)
    self:recordCallLog(14)   -- WDSY-22243
    self.charAction = charAction
    self:recordCallLog(15)   -- WDSY-22243
    self.charAction:setLocalZOrder(Const.CHARACTION_ZORDER)

    -- 绑定事件
    self:bindEvent()
    self:recordCallLog()   -- WDSY-22243
end

-- 播放死亡动作
-- blinkDuration:倒地后闪烁时长
-- blinkTimes:倒地后闪烁次数
function Char:setDieAction(blinkDuration, blinkTimes)
    self:setActAndCB(Const.FA_DIE_NOW, function()
        if self.faAct ~= Const.FA_DIE_NOW then return end

        self:setActAndCB(Const.FA_DIED, function()
            if blinkDuration and blinkDuration > 0 then
                if self.middleLayer then
                    local action = cc.Sequence:create(
                        cc.Blink:create(blinkDuration, blinkTimes or 3),
                        cc.CallFunc:create(function()
                            CharMgr:deleteChar(self:getId())
                        end)
                    )
                    self.middleLayer:runAction(action)
                else
                    CharMgr:deleteChar(self:getId())
                end
            else
                CharMgr:deleteChar(self:getId())
            end
        end)
    end)
end

-- 获取方向
function Char:getDir()
    if not self.dir then
        self:setDir(self:queryBasicInt('dir'))
    end

    return self.dir
end

function Char:isCanChangeDir()
    if self:queryBasicInt("isFixDir") == 1 then
        return false
    end

    if self:isFrozen() and not self:isFightObj() then
        -- 冰冻状态
        return false
    end

    if self.faAct == Const.FA_DIED then
        return false
    end

    return true
end

-- 设置方向
function Char:setDir(dir, noUpdateNow)
    -- 如果当前是死亡动作则不转向
    if not self:isCanChangeDir() then return end

    self.dir = dir
    self:setBasic('dir', dir)
    if self.charAction then
        self.charAction:setDirection(dir)
    end

    -- 更新一些需要改变方向的特效
    self:updateMagicDir()
end

function Char:setEndPos(mapX, mapY, endPosCallBack)
    if mapX == nil or mapY == nil or (self:isGather() and self:isShowRidePet()) then return end

    -- 到达终点的回调
    if endPosCallBack then
        self.endPosCallBack = endPosCallBack
    else
        self.endPosCallBack = nil
    end

    -- 有可能传进来的地图坐标超出了范围，需要进行修正
    mapX, mapY = MapMgr:adjustPosition(mapX, mapY)

    local pos = GObstacle:Instance():GetNearestPos(mapX, mapY)

    if 0 ~= pos then
        mapX, mapY = math.floor(pos / 1000), pos % 1000
    end

    self.endX, self.endY = gf:convertToClientSpace(mapX, mapY)

    if not self:getCanMove() then
        return
    end

    local curX, curY = self.curX, self.curY
    if GObstacle:Instance():IsObstacle(gf:convertToMapSpace(curX, curY)) then
        -- 如果处于障碍点，则进行容错处理
        curX, curY = gf:convertToMapSpace(curX, curY)
        local curPos = GObstacle:Instance():GetNearestPos(curX, curY)
        if 0 ~= curPos then
            curX, curY = math.floor(curPos / 1000), curPos % 1000
        end

        curX, curY = gf:convertToClientSpace(curX, curY)
    end

    -- GObstacle:Instance():FindPath 中是以原始大小进行计算的，所以需要进行换算
    local sceneH = GameMgr:getSceneHeight()
    local rawBeginX = math.floor(curX / Const.MAP_SCALE)
    local rawBeginY = math.floor((sceneH - curY) / Const.MAP_SCALE)
    local rawEndX = math.floor(self.endX / Const.MAP_SCALE)
    local rawEndY = math.floor((sceneH - self.endY) / Const.MAP_SCALE)

    local badpath = false
    local paths = GObstacle:Instance():FindPath(rawBeginX, rawBeginY, rawEndX, rawEndY)
    local count = paths:QueryInt("count")
    if count > 1 then
        if MapMgr:isInMiGong() and (not MiGongMapMgr:checkCanMove(self.endX, self.endY) or paths:QueryInt(string.format("len%d", count)) * Const.MAP_SCALE > 960) then
            return
        end

        -- 复制路径
        self.paths = {}
        self.posCount = count
        for i = 1, count do
            self.paths[string.format("x%d", i)] = paths:QueryInt(string.format("x%d", i)) * Const.MAP_SCALE
            self.paths[string.format("y%d", i)] = sceneH - paths:QueryInt(string.format("y%d", i)) * Const.MAP_SCALE
            self.paths[string.format("len%d", i)] = paths:QueryInt(string.format("len%d", i)) * Const.MAP_SCALE
        end

        -- 有路可走，队员的动作切换在 updatePos 中依据与队长的距离设置
        if not self:inMeTeam() then
            self:setAct(Const.FA_WALK)
        end

        local distX = math.abs(self.endX - self:getPathValue("x", count))
        local distY = math.abs(self.endY - self:getPathValue("y", count))
        if distX + distY > (Const.PANE_WIDTH + Const.PANE_HEIGHT) * 3 then
            -- 目标点与寻路点距离太远了，标记为寻路失败
            badpath = true
        end
    else
        -- 无路可走
        self:setAct(Const.FA_STAND)

        -- 标记为寻路失败
        badpath = true
    end

    if badpath then
        if Me:isPassiveMode() or (not TeamMgr:inTeam(Me:getId()) and TeamMgr:getLeaderId() == Me:getId()) then
            -- 被动模式或者 me 是队长，寻路失败，直接移动目标到目的地
            self:setLastMapPos(mapX, mapY)
            self:setPos(self.endX, self.endY)
            self:setAct(Const.FA_STAND)
        end
    end

    self.startTime = GameMgr.lastUpdateTime
    self.lastTime = self.startTime
    self.lastLen = 0
end

-- 根据巡路出来的实际路径获取最终点位置
function Char:getEndPos()
    if self.paths == nil or self.posCount == nil then return end
    local x = self:getPathValue("x", self.posCount)
    local y = self:getPathValue("y", self.posCount)
    return gf:convertToMapSpace(x, y)
end

-- 更新人物的目的地
-- 如果是行走中，则直接更新
-- 否则延迟更新
function Char:updateDestination(mapX, mapY)
    if self:isGather() and self:isShowRidePet() then return end

    if self.faAct == Const.FA_WALK then
        self:setEndPos(mapX, mapY)
        return
    end

    -- 目前人物处于静止状态，不要立刻移动，而是延迟一定时间，以免出现人物抖动的情况
    -- 记录目的地坐标和当前时间
    self.bReadyMove = true
    self.readyMoveTick = gfGetTickCount()
    self.moveX, self.moveY = mapX, mapY
end

-- 处理延迟行走
function Char:processReadyMove()
    if self.faAct ~= Const.FA_STAND or not self.bReadyMove then
        -- 不是站立状态或者没准备，不行走
        return
    end

    if gfGetTickCount() - self.readyMoveTick < 260 then
        -- 未到行走时间
        return
    end

    self.bReadyMove = false
    self.readyMoveTick = 0
    self:setEndPos(self.moveX, self.moveY)
    self.moveX = nil
    self.moveY = nil
end

-- 输入的 speed 为相对于地图原始大小时的速度
function Char:setSpeed(speed)
    self.speed = speed * Const.MAP_SCALE
end

-- 设置调整速度的百分比
function Char:setSeepPrecent(precent)
    self.speedPrecent = precent
end

-- 客户端自己设置调整速度的百分比
function Char:setSeepPrecentByClient(precent)
    self.speedPrecentOnlyClient = precent
end

function Char:getSeepPrecent()
    return self.speedPrecentOnlyClient or self.speedPrecent
end

function Char:getSpeed()
    local speed = (100 + (self:getSeepPrecent() or 0)) / 100 * self.speed

    if speed < 0 then
        speed = 0
    end

    return speed
end

-- 更新角色速度
function Char:updateSpeed()
    if not TeamMgr:inTeam(self:getId()) or self:getId() == TeamMgr:getLeaderId() then
        -- 不在队伍中或者本对象为队长，恢复原速行走
        self:setSpeed(0.2)
        return
    end

    local char = CharMgr:getChar(TeamMgr:getLeaderId())
    if not char then
        self:setSpeed(0.2)
        return
    end

    local order = TeamMgr:getOrderById(self:getId())
    local orderDist = order * Const.CHAR_FOLLOW_DISTANCE
    if not gf:inOffset(char.curX, char.curY, self.curX, self.curY, orderDist) then
        self:setSpeed(0.25)
    else
        self:setSpeed(0.2)
    end
end

-- 玩家是否在 me 的队伍中
function Char:inMeTeam()
    return Me:getId() == TeamMgr:getLeaderId() and Me:getId() ~= self:getId() and TeamMgr:inTeam(self:getId())
end

-- 修正移动距离
function Char:reviseStepLen(len)
    if len > MOVE_STEP_MAX_DIS then
        return MOVE_STEP_MAX_DIS
    end

    return len
end

-- 打上此帧完成之后需要删除的标识
function Char:setNeedDelete()
    self.needDelete = true
end

function Char:isNeedDelete()
    return self.needDelete
end

function Char:isMountLeader()
    local driverId = self:queryBasicInt("share_mount_leader_id")
    return driverId == self:getId()
end

function Char:isGather()
    -- 共乘
    local driverId = self:queryBasicInt("share_mount_leader_id")
    return 0~= driverId and driverId ~= self:getId()
end

-- 更新人物位置
function Char:updatePos()
    if (Me:isInCombat() or Me:isLookOn()) and Me:getId() == self:getId() then
        return
    end

    if not self:isFightObj() and Me:getId() ~= self:getId() then
        if MarryMgr:checkWeddingActionZone(self) then
            -- 在对应的婚礼动作区域，隐藏
            self:setNeedDelete()
        else
            -- 否则，按照正常的逻辑进行
            CharMgr:doCharHideStatus(self)
        end
    end

    -- 打雪仗任务不处理共乘，原因是，打雪仗会把任务位置强制设置为目的坐标，若 共乘， 乘客位置又会被强制拉回去导致显示异常
    if DlgMgr:getDlgByName("VacationSnowDlg") then

    else
    -- 共乘
    local driverId = self:queryBasicInt("share_mount_leader_id")
    if 0~= driverId and driverId ~= self:getId() and self:isShowRidePet() then
        local char = CharMgr:getChar(driverId)
        if char then
            self:setLastMapPos(gf:convertToMapSpace(self.curX, self.curY))
            self:setPos(char.curX, char.curY)
        end
        return
    end
    end

    -- 更新速度
    self:updateSpeed()

    -- 如果是非战斗对象，远离队长了，重新进行终点移动
    if self:getType() == "Player" then
        if self:inMeTeam() and gf:distance(Me.curX, Me.curY, self.curX, self.curY) >= MAX_FOLLOW_LEN * Const.PANE_WIDTH and self.faAct == Const.FA_STAND and not self.bReadyMove then
            if AutoWalkMgr:isAutoWalk() then
                self:setEndPos(gf:convertToMapSpace(Me.endX, Me.endY))
            end
        end
    end

    if not self.posCount or self.posCount <= 1 then
        return
    end

    local curLen = 0
    local len = self.lastLen
    local curTime = gfGetTickCount()
    if curTime <= self.startTime then
        -- 时间有误，不需要移动
        curLen = 0
    else
        local dist = (TeamMgr:getOrderById(self:getId()) - 1) * Const.CHAR_FOLLOW_DISTANCE
        if self:inMeTeam() and gf:inOffset(Me.curX, Me.curY, self.curX, self.curY, dist) then
            -- 玩家在 me 的队伍中，且离 me 的距离够近了
            curLen = self.lastLen
            if not self:canFollow() then
                self:setAct(Const.FA_STAND)
            end
        else
            self:setAct(Const.FA_WALK)

            -- 修正移动距离
            local _, _, _, _, ct = gf:getTickCount()
            local stepLen = self:getSpeed() * ct
            stepLen = self:reviseStepLen(stepLen)
            curLen = self.lastLen + stepLen
        end

        self.lastTime = curTime
    end

    if self.faAct ~= Const.FA_WALK then
        return
    end

    while len < curLen do
        -- 计算当前走了多少距离
        local d = 12
        len = len + d
        if len > curLen then
            d = d - (len - curLen)
            len = curLen
        end

        local i = 2
        while i <= self.posCount do
            if len < self:getPathValue("len", i) then
                break
            end

            i = i + 1
        end

        if i > self.posCount then
            -- 计步工具可以输入两个目标点，如果计步工具界面存在，考虑是否有第二目的地
            local dlg = DlgMgr:getDlgByName("PedometerDlg")
            if dlg and dlg.isNeedAutoNext then
                dlg:autoNextDest()
                return
            end

            -- 没有后续的寻路信息
            self:setPos(self:getPathValue("x", i - 1), self:getPathValue("y", i - 1))
            self:sendFollow()
            if not self:canFollow() then
                self:setAct(Const.FA_STAND)

                -- 到达终点的回调,调用完就清除
                if self.endPosCallBack and type(self.endPosCallBack.func) == 'function' then
                    self.endPosCallBack.func(self.endPosCallBack.para)
                    self.endPosCallBack = nil
                end

                return
            end
        else
            -- 根据当前步的步长计算当前移动的位置及方向
            local dx = self:getPathValue("x", i) - self:getPathValue("x", i - 1)
            local dy = self:getPathValue("y", i) - self:getPathValue("y", i - 1)
            local ds = math.sqrt(dx * dx + dy * dy)
            local lastX, lastY = self.curX, self.curY

            local curX, curY
            if 0 == dx and 0 == dy then
                curX = self:getPathValue("x", i)
                curY = self:getPathValue("y", i)
            else
                curX = self:getPathValue("x", i - 1) + dx * (len - self:getPathValue("len", i - 1)) / ds
                curY = self:getPathValue("y", i - 1) + dy * (len - self:getPathValue("len", i - 1)) / ds
            end

            self:setPos(curX, curY)

            local dir = gf:defineDir(cc.p(0, 0), cc.p(dx, dy), self:getIcon())
            self:setDir(dir)
            self:sendFollow()

            -- 如果有外部手动设置停止动作，则直接跳过移动动作
            if self.faAct == Const.FA_STAND then
                break
            end
        end
    end

    self.lastLen = curLen
    self:updateToAddFocusMagic()
end

-- 切换地图后要置为nil
function Char:resetGotoEndPos()
    self.lastPaths = nil
    self.lastPosCount = nil
    self.paths = nil
    self.posCount = 0
end

-- 获取路径中的数值
function Char:getPathValue(key, index)
    if not self.paths or self.posCount <=1 then
        return 0
    end

    return self.paths[string.format("%s%d", key, index)]
end

function Char:canFollow()
    if not self:inMeTeam() then
        -- 不在 Me 的队伍中不跟随
        return false
    end

    local dist = (TeamMgr:getOrderById(self:getId()) - 1) * Const.CHAR_FOLLOW_DISTANCE
    if gf:inOffset(Me.curX, Me.curY, self.curX, self.curY, dist) and Me.faAct == Const.FA_STAND then
        return false
    end

    return true
end

function Char:setLastMapPos(mapX, mapY)
    self.lastMapPosX, self.lastMapPosY = mapX, mapY
end

function Char:sendFollow()
    if not self:canSend() then
        -- 不能发送数据包
        self:setLastMapPos(gf:convertToMapSpace(self.curX, self.curY))
        return
    end

    if self:restrictAccelerator() then
        return
    end

    self:setLastMapPos(gf:convertToMapSpace(self.curX, self.curY))

    -- 按照当前的寻路算法，斜着走的时候是有可能进入障碍点，只发送非障碍点位置
    if not GObstacle:Instance():IsObstacle(self.lastMapPosX, self.lastMapPosY) then
        self:addMoveCmd(self.lastMapPosX, self.lastMapPosY)
    end
end

function Char:randomSomePosAndBack()
    local count = 0
    local x, y = self.lastMapPosX, self.lastMapPosY

    if not GObstacle:Instance():IsObstacle(x + 1, y) then
        self:addMoveCmd(x + 1, y)
    elseif not GObstacle:Instance():IsObstacle(x - 1, y) then
        self:addMoveCmd(x - 1, y)
    elseif not GObstacle:Instance():IsObstacle(x, y - 1) then
        self:addMoveCmd(x, y - 1)
    elseif not GObstacle:Instance():IsObstacle(x, y + 1) then
        self:addMoveCmd(x, y + 1)
    end

    self:addMoveCmd(x, y)
end

function Char:canSend()
    if Me:isChangingRoom() then
        return false
    end

    if self.faAct ~= Const.FA_WALK then
        return false
    end

    if not self:getCanMove() then
        return false
    end

    if not TeamMgr:inTeam(self:getId()) then
        return false
    end

    if Me:getId() ~= TeamMgr:getLeaderId() then
        return false
    end

    local mapX, mapY = gf:convertToMapSpace(self.curX, self.curY)
    if mapX == self.lastMapPosX and mapY == self.lastMapPosY then
        return false
    end

    return true
end

-- 限制加速器
function Char:restrictAccelerator()
    local mapX, mapY = gf:convertToMapSpace(self.curX, self.curY)
    if math.abs(mapX - self.lastMapPosX) > MOVE_STEP_MAX or math.abs(mapY - self.lastMapPosY) > MOVE_STEP_MAX then
        self:setPos(gf:convertToClientSpace(self.lastMapPosX, self.lastMapPosY))
        return true
    end

    return false
end

-- 添加移动命令
function Char:addMoveCmd(mapX, mapY)
    self.moveCmds:pushBack({x=mapX, y=mapY})
    -- 如果计步界面存在，且开始计步，则增加
    DlgMgr:sendMsg("PedometerDlg", "addStep", mapX, mapY)
end

-- mergey移动命令点
function Char:mergeMoveCmd()
    local queue = self.moveCmds
    local count = queue:size()

    local newQueue = List.new()
    for i = 1, count do
        -- 先把当前点放进去
        local pos1 = queue:get(i)
        newQueue:pushBack(pos1)
        if i + 2 <= count then
            -- 判断是否符合条件
            local pos2 = queue:get(i + 2)
            if gf:inOffset(pos1.x, pos1.y, pos2.x, pos2.y, 2 * MOVE_STEP_MAX) then
                -- 符合条件递增
                i = i + 1
            end
        end
    end

    self.moveCmds = newQueue
end

-- 发送移动命令
function Char:sendMoveCmds()
    self:mergeMoveCmd()
    local speedRate = (100 + (self.speedPrecent or 0)) / 100
    local queue = self.moveCmds
    local count = queue:size()

	if self.lastSendMoveTime then
        -- 根据每步移动允许的最短间隔计算在这段时间里允许移动的最大步数
        -- 此最短间隔会根据当前速度来改变
        local moveOneStepMinTime = math.ceil(MOVE_ONE_STEP_MIN_TIME / speedRate)
        local maxSteps = math.floor((gfGetTickCount() - self.lastSendMoveTime) / moveOneStepMinTime)
        if count > maxSteps then
            count = maxSteps
        end
    end

    local moveStepLimit = math.floor(MAX_MOVE_TO_STEPS * speedRate)
    if count <= 0 then return end
    if count > moveStepLimit then count = moveStepLimit end

    local data = {}
    data.count = count
    for i = 1, count do
        local pos = queue:popFront()
        data[string.format("x%d",i)] = pos.x
        data[string.format("y%d",i)] = pos.y
    end

    data.id = self:getId()
    data.dir = self.dir
    data.map_id = MapMgr:getCurrentMapId()
    data.map_index = MapMgr:getCurrentMapIndex()
    data.send_time = gfGetTickCount()

    local cmdName = "CMD_OTHER_MOVE_TO"
    if data.id == Me:getId() then
        cmdName = "CMD_MULTI_MOVE_TO"
    end

	self.lastSendMoveTime = gfGetTickCount()
    gf:CmdToServer(cmdName, data)
end

-- 发送所有剩余步数
function Char:sendAllLeftMoves()
    local queue = self.moveCmds
    local count = queue:size()

    while count > 0 do
    	self:sendMoveCmds()
        count = count - 1
    end
end

function Char:dealAfterSendMoveCmds()
end

function Char:update()
    Object.update(self)

    self:tryFixedAct()
    self:processReadyMove()
    self:updatePos()
    self:updateMagicPos()
    self:updateFollowSprites()
    self:updateShow()
end

-- 尝试修复动作
-- 一些未知的原因，会导致设置动作时异常退出调用
-- 导致后续代码没有执行，此处尝试修复
function Char:tryFixedAct()
    if not self.startTime and self.faAct == Const.FA_WALK and self.posCount and self.posCount > 1 then
        if self == Me and self.walkDest then
            AutoWalkMgr:beginAutoWalk(self.walkDest)
        else
        local mapX, mapY = gf:convertToMapSpace(self.endX, self.endY)
        self:setAct(Const.FA_STAND)
        self:setEndPos(mapX, mapY)
    end

        Client:pushDebugInfo("Char:tryFixedAct")
    end
end

-- 根据人物基准点更新光效位置
function Char:updateMagicPos()
    local char = self.charAction
    if char == nil then return end
    if not self.actChanged then return end

    self.actChanged = false
    for k, v in pairs(self.magics) do
        if v.getPosFunc ~= nil then
            local func = char[v.getPosFunc]
            if func then
                v:setPosition(func(char))
            end
        end
    end
end

-- 根据人物方向，更新一些需要更新方向的光效
function Char:updateMagicDir()
    local char = self.charAction
    if char == nil then return end

    local dir = self:getDir()
    for k, v in pairs(self.magics) do
        if 'string' == type(k) then k = tonumber(k) end
        if not LIGHT_EFFECT[k] or not LIGHT_EFFECT[k]["action"] then return end
        local action  = LIGHT_EFFECT[k]["action"][dir]

        -- 当前方向的光效不存在
        if not action then return end

        if not self.magics[k] then
            -- 重新添加
            CharMgr:playLightEffect(self, {charId = self:getId(), effectIcon = k})
        else
            -- 直接切换方向对应的action
            self.magics[k]:getAnimation():play(action)
        end
    end
end

-- 设置是否需要分发角色移动事件
function Char:setNeedDisMoveEvent(flag)
    self.needDisMoveEvent = flag
end

function Char:setPos(x, y)
    local lastX, lastY = gf:convertToMapSpace(self.curX, self.curY)
    Object.setPos(self, x, y)
    local mapX, mapY = gf:convertToMapSpace(self.curX, self.curY)

    if mapX ~= lastX or mapY ~= lastY then
        self:updateShelter(mapX, mapY)

        if self.needDisMoveEvent then
            EventDispatcher:dispatchEvent("CHAR_UPDATE_POS", self, {x = lastX, y = lastY})
        end
    end
end

-- 可能动作还没创建，就收到当前频道的数据，先缓存起来
function Char:setChatCache(data, fightPos)
    self.chatCache = {}
    self.chatCache.data = data
    self.chatCache.fightPos = fightPos
end

function Char:loadChatCache()
    if self.chatCache and self.chatCache.data.time and gf:getServerTime() - self.chatCache.data.time < self.chatCache.data.show_time then
        self:setChat(self.chatCache.data, self.chatCache.fightPos)
    end

    self.chatCache= nil
end

-- 设置头顶聊天信息
function Char:setChat(data, fightPos, isVip)
    -- 可能动作还没创建，就收到当前频道的数据，先缓存起来
    if not self.charAction then
        self:setChatCache(data, fightPos)
    end

    if not self.charAction or data.msg == "" then  -- 空内容不需要显示
        return
    end

    -- 同骑处理
    if self:isGather() and self:isShowRidePet() then
        -- 直接通过同骑队长显示
        local driverId = self:queryBasicInt("share_mount_leader_id")
        local char =  CharMgr:getCharById(driverId)
        if char then
            char:setChat(data, fightPos, isVip)
        end
        return
    end

    local headX, headY = self.charAction:getHeadOffset()

    local dlg = DlgMgr:openDlg("PopUpDlg")
    --local filteText, haveFilt = gf:filtText(data["msg"], data["gid"], true)
    local msg = data["msg"]
    local bg = dlg:addTip(msg, fightPos, isVip or data["show_extra"])
    if fightPos == FightPosMgr.POS1 then
        bg:setPosition(headX + bg:getContentSize().width * 0.25, headY)
    else
        bg:setPosition(headX, headY)
    end
    local cb = function()
        for k, v in pairs(self.chatContent) do
            if v == bg then
                table.remove(self.chatContent, k)
            end
        end
    end

    -- 显示一定时间后删除
    local action = cc.Sequence:create(
        cc.DelayTime:create(data.show_time),
        cc.CallFunc:create(cb),
        cc.RemoveSelf:create()
    )

    self:addToTopLayer(bg)

    if #self.chatContent == 1 then
        -- 当消息不足2条时加入之前要将队头的消息向上移动
        local newAction = cc.MoveBy:create(0.2, cc.p(0, bg:getContentSize().height + 5))
        local node = self.chatContent[1]
        node:runAction(newAction)
    elseif #self.chatContent > 1 then
        -- 消息到达2条时，移除对头消息, 并拿出新的队头继续向上移动
        local node = table.remove(self.chatContent, 1)
        node:stopAllActions()
        node:removeFromParent()
        local newAction = cc.MoveBy:create(0.2, cc.p(0, bg:getContentSize().height + 5))
        node = self.chatContent[1]
        node:runAction(newAction)
    end

    bg:runAction(action)
    table.insert(self.chatContent, bg)
end

function Char:removeAllChat()
    for i = 1, #self.chatContent do
        local node = self.chatContent[i]
        if node then
            node:removeFromParent()
        end
    end

    self.chatContent = {}
end

-- 上移聊天气泡
function Char:upAllChat(height)
    for i = 1, #self.chatContent do
        local node = self.chatContent[i]
        if node and not node.isUp then
            local orgPos = cc.p(node:getPosition())
            node:setPosition(cc.p(orgPos.x, orgPos.y + height))
            node.isUp = true
        end
    end
end

-- 是否是战斗对象
function Char:isFightObj()
    return false
end

-- 更新遮挡信息
function Char:updateAfterLoadAction(notCheckFrozen)
    self:updateShelter(gf:convertToMapSpace(self.curX or 0, self.curY or 0))

    -- 需要对地图队形的头衔进行更新
    self:reRefreshTitle()

    -- 加载冒泡的缓存
    self:loadChatCache()

    if not notCheckFrozen then
        self:checkNeedPause()
    end

    self.actChanged = true
end

function Char:updateShelter(mapX, mapY)
    local map = GameMgr.scene.map
    if map == nil or self.charAction == nil then return end

    if self:isFightObj() then
        -- 战斗对象不显示遮挡效果
        self.charAction:setShelter(false)
        return
    end

    if self == Me and Me:queryBasicInt("shadow_self") == 1 then
        self.charAction:setShelter(true)
        return
    end

    if DlgMgr:isDlgOpened("ItemPuttingDlg") then
        self.charAction:setShelter(true)
        return
    end

    -- 有配置左右基准点
    local points = self.charAction:getDirPointRange()
    if points then
        local isShelter = false
        for i = 1, #points do
            local newMapX = mapX + points[i].x
            local newMapY = mapY + points[i].y
            if map:isShelter(newMapX, newMapY) then
                isShelter = true
                break
            end
        end

        self.charAction:setShelter(isShelter)
    else
        self.charAction:setShelter(map:isShelter(mapX, mapY))
    end
end

function Char:updateShow()
    local petIcon = self:queryBasicInt("pet_icon")
    -- ChatMgr:sendMiscMsg(string.format("S:%s, L:%s, E:%s", tostring(gf:getServerTime(self.lastUpdateShowTime)), tostring(self.lastUpdateShowTime), tostring(gf:getServerTime() - (self.lastUpdateShowTime or 0))))
    if CharConfig[petIcon] and CharConfig[petIcon].showMountIcons then
        local changeTime = CharConfig[petIcon].showMountTime or 30

        local lastUpdateShowTime = self.lastUpdateShowTime or 0
        if gf:getServerTime() - lastUpdateShowTime < changeTime then return end
        if self.charAction then
            self.charAction:setRideIcon(self:getRideIcon())
        end

        self.lastUpdateShowTime = math.floor(gf:getServerTime() / changeTime) * changeTime
    end
end

-- 跟随精灵开始

-- 创建跟随精灵
function Char:createFollowSprite(id, icon)
    if self.followSprites and self.followSprites[id] then
        return
    end

    local char = require("obj/FollowSprite").new()
    char:setOwner(self)
    char:absorbBasicFields({
        id = id,
        icon = icon,
        dir = self:getDir()
    })

    if not self.followSprites then
        self.followSprites = {}
    end

    if self.followSprites[char:getId()] then
        self.followSprites[char:getId()]:cleanup()
    end

    self.followSprites[char:getId()] = char
    -- char:onEnterScene(gf:convertToMapSpace(self.curX, self.curY))
    char:setVisible(self.visible)
    char:setAct(Const.FA_STAND)
    return char
end

-- 移除跟随精灵
function Char:removeFollowSprites(id)
    if not self.followSprites then return end

    local followSprite = self.followSprites[id]
    if not followSprite then return end

    if 'function' == type(followSprite.cleanup) then
        followSprite:cleanup()
    end

    self.followSprites[id] = nil
end

-- 清除跟随精灵
function Char:clearFollowSprites(keys)
    if not self.followSprites then return end

    for k, v in pairs(self.followSprites) do
        if v and 'function' == type(v.cleanup) then
            if (keys and not keys[k]) or not keys then
                v:cleanup()
                self.followSprites[k] = nil
            end
        end
    end
end

-- 跟随精灵移除场景
function Char:doFollowSpritesEnterScene(mapX, mapY)
    if not self.followSprites then return end

    for _, v in pairs(self.followSprites) do
        if v and 'function' == type(v.onEnterScene) then
            v:onEnterScene(mapX, mapY)
            v:setVisible(self.visible)
        end
    end
end

-- 跟随精灵移除场景
function Char:doFollowSpritesExitScene()
    if not self.followSprites then return end

    for _, v in pairs(self.followSprites) do
        if v and 'function' == type(v.onExitScene) then
            v:onExitScene()
        end
    end
end

function Char:updateFollowSprites()
    if self.followSprites then
    for _, v in pairs(self.followSprites) do
        v:update()
    end
    end

    if self.magics then
        for _, v in pairs(self.magics) do
           if v.isFollowSprite then
                v:update()
            end
        end
    end
end

-- 跟随精灵结束

-- 数据变化了，需要进行一些更新
function Char:onAbsorbBasicFields()
    if self.charAction then
        self.charAction:setIcon(self:getIcon(), true, self:getRideIcon())

        -- 如果suit_icon不等于0设置weapon时，需要传入旧的icon
        local suit_icon = self:queryBasicInt("suit_icon")
        local org_icon = self:getOrgIcon()
        self.charAction.orgIcon = org_icon
        self.charAction:setWeapon(self:getWeaponIcon(), true)
        self.charAction:setBodyPartIndex(self:getPartIndex(), true)
        self.charAction:setBodyColorIndex(self:getPartColorIndex(), true)
        self.charAction:setRideIcon(self:getRideIcon(), true)
        self.charAction:setGatherIcons(self:getGatherIcons(), true)
        self.charAction:setShadowIcon(self:getShadowIcon(), true)
        self:setDir(self:queryBasicInt('dir'), true)
        if self.charAction:isDirtyUpdate() then
            self.charAction:updateNow()
            self.actChanged = true
        end
    end

    -- 更新名字
    self:updateName()

    -- 更新影子
    self:updateShadow()

    -- 更新光效
    self:updateMagics()
end

function Char:refreshTitle(data)
    -- 吸收头衔信息（在吸收前清头衔信息时，有些信息需要转化）
    local oldTitle = self:absorbTitleInfo(data)
    if not oldTitle then return end

    self:reRefreshTitle(oldTitle)
end

-- 吸收 title 信息
function Char:absorbTitleInfo(info)
    if info.id ~= self:getId() then
        -- 不是此对象的 title 信息
        return
    end

    local oldInfo = self.titleInfo;
    self.titleInfo = {}
    for v = 1, info.count do
        local title = info[v]
        self.titleInfo[title] = true
    end

    return oldInfo
end

function Char:containsTouchPos(touchs, rect, pos)

end

--[[function Char:openCharMenuContentDlg(touchs)
    local playerList = {}
    local count = 0

    for _, v in pairs(CharMgr.chars) do
        if (v:getType() == "Player" and v ~= Me) or v:getType() == "Npc" or v:getType() == "Monster" or v:getType() == "GatherNpc" then
            if v.charAction then
                local isContainsTouchPos
                if v.charAction and v.charAction.containsTouchPos then
                    isContainsTouchPos = v.charAction:containsTouchPos(touchs)
                else
                    local pos = v.middleLayer:convertToNodeSpace(touchs:getLocation())
                    local rect = v.charAction:getBoundingBox()
                    isContainsTouchPos = cc.rectContainsPoint(rect, pos)
                end

                if isContainsTouchPos then
                    -- 采集物，没有采集状态不出现在列表
                    if v:getType() == "GatherNpc" and not v:isCanGather() then
                        return
                    end

                    if v:getType() == "Npc" then
                        v.order = 1
                    elseif v:getType() == "GatherNpc" and v:isCanGather() then
                        v.order = 2
                    elseif v:getType() == "Monster" then
                        v.order = 3
                    else
                        v.order = 4
                    end

                    if v:getType() == "Monster" and OUT_USER_LIST_NAME[v:getName()] then
                        -- 暑假2017追查内鬼，队伍中对象为怪物，不显示在列表中
                    else
                        table.insert(playerList, v)
                        count = count + 1
                    end
                end
            end
        end
    end

    if count > 1 then
        local dlg = DlgMgr:openDlg("UserListDlg")

        local function sort(l,r)
            if l.order < r.order then return true end
        end

        table.sort(playerList, function(l, r)  return sort(l,r)  end)
        dlg:setInfo(playerList, count)
    end
end]]

function Char:getShowName()
    local name = ""

    -- 如果是npc 显示用别名
    if  self:queryBasic('alicename') ~= "" then
        name = self:queryBasic('alicename')
    else
        name = gf:getRealName(self:queryBasic('name'))
    end

    return name
end

-- 自动寻路时，检测是否有要添加焦点光效的NPC
function Char:updateToAddFocusMagic()
    -- 当前角色出现时，判断下是否需要添加选中特效
    if self:getId() ~= Me:getId() or Me.selectTarget or TeamMgr:isTeamMeber(Me) or not AutoWalkMgr:isAutoWalk() then
        return
    end

    if AutoWalkMgr.autoWalk and AutoWalkMgr.autoWalk.npc then
        local npcObject = CharMgr:getNpcByPos(AutoWalkMgr.autoWalk)
        if npcObject then
            npcObject:addFocusMagic()
            Me.selectTarget = npcObject
        end

        if AutoWalkMgr.autoWalk.npcId then
            local furniture = HomeMgr:getFurnitureById(AutoWalkMgr.autoWalk.npcId)
            if furniture then
                furniture:addFocusMagic()
                Me.selectTarget = furniture
            end
        end


    end
end

function Char:reRefreshTitle(oldTitle)

end


function Char:doSomeSpecialAction(actionId)

end

-- 获取你能达到的最高等级
function Char:getTheMaxLevelOfYouCan()
    -- 飞升功能还没有做，当前直接返回 115，以后
    return Const.PLAYER_MAX_LEVEL_NOT_FLY
end

-- 获取实际方向
function Char:getRealDirection(dir, action)
    local flip = false
    if nil == dir or action == nil then return 5 end

    if action == Const.SA_STAND or action == Const.FA_WALK then
        if dir == 1 then dir = 3 flip = true
        elseif dir <= 0 then dir = 4 flip = true
        elseif dir >= 7 then dir = 5 flip = true
        end
    else
        if dir <= 0 or dir == 1 then dir = 3 flip = true
        elseif dir == 2 then dir = 3
        elseif dir == 4 then dir = 5
        elseif dir == 6 or dir >= 7 then dir = 5 flip = true
        end
    end
    return dir, flip
end

function Char:checkHasLoadTexture()
    local icon = self:getIcon()
    local weaponIcon = self:getWeaponIcon()
    local gatherIcons = self:getGatherIcons()
    local shadowIcon = self:getShadowIcon()
    local partIndex = self:getPartIndex()
    local rideIcon = self:getRideIcon()
    local action = Const.FA_STAND
    local dir = self:getRealDirection(self:getDir(), action)
    local startFrame = Const.CHAR_FRAME_START_NO
    local endFrame = Const.CHAR_FRAME_START_NO + 99

    if icon and icon ~= 0 then
        if not AnimationMgr:hasLoadTexture( icon, 0, action, dir, startFrame, endFrame) then
            return
        end
    end

    if weaponIcon and weaponIcon ~= 0 then
        if not AnimationMgr:hasLoadTexture(icon, weaponIcon, action, dir, startFrame, endFrame) then
            return
        end
    end

    if rideIcon and rideIcon ~= 0 then
        if not AnimationMgr:hasLoadTexture(rideIcon, 0, action, dir, startFrame, endFrame) then
            return
        end
    end

    if not string.isNilOrEmpty(gatherIcons) then
        if 'table' == type(gatherIcons) then
            for i = 1, math.min(#gatherIcons, GATHER_COUNT) do
                if not AnimationMgr:hasLoadTexture(gatherIcons[i], 0, action, dir, startFrame, endFrame) then
                    return
                end
            end
        else
            if not AnimationMgr:hasLoadTexture(gatherIcons, 0, action, dir, startFrame, endFrame) then
                return
            end
        end
    end

    if not string.isNilOrEmpty(partIndex) then
        local count = partIndex and math.floor(#partIndex / 2) or 0

        -- 读取部件信息
        for i = 1, count do
            local j = tonumber(string.sub(partIndex, i * 2 - 1, i * 2))
            if j > 0 then
                local partIcon = tonumber(string.format("%02d%03d", i, j))
                if partIcon then
                    if not AnimationMgr:hasLoadTexture(icon, partIcon, action, dir, startFrame, endFrame) then
                        return
                    end
                end
            end
        end
    end

    return true
end

-- 清理（重载）
function Char:cleanup()
    if self.charAction then
        if 'function' == type(self.charAction.clear) then
        self.charAction:clear()
        elseif DistMgr:curIsTestDist() then
            -- 上报信息
            DebugMgr:logCharActionError(tostring(self.charAction))
    end
    end

    self.showPartyIcon = nil
    self.showFootBallIcon = nil
    self.lastSendMoveTime = nil
    self.followMagic = nil

    self:cleanComAbsorbData()
    self:clearFollowSprites()
    Object.cleanup(self)
end

return Char
