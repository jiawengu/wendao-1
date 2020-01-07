-- Player.lua
-- Created by chenyq Nov/14/2014
-- 场景中的玩家对应的类

local Char = require("obj/Char")
local IconColorScheme = require(ResMgr:getCfgPath("IconColorScheme.lua"))

local Player = class("Player", Char)

local TITLE_MAGIC_MAP = {}
TITLE_MAGIC_MAP[Const.TITLE_IN_COMBAT]          = {'fighting',      'head'}
TITLE_MAGIC_MAP[Const.TITLE_IN_EXCHANGE]        = {'exchanging',    'head'}
TITLE_MAGIC_MAP[Const.TITLE_TEAM_LEADER]        = {'leader',        'head'}
TITLE_MAGIC_MAP[Const.TITLE_TEAM_LEADER_TEAM_FULL] = {'leader_team_full', 'head'}
TITLE_MAGIC_MAP[Const.TITLE_LOOKON]             = {'look_on',       'head'}
TITLE_MAGIC_MAP[Const.TITLE_USE_JINGYAOSHU]     = {'jiangyaoshu',   'foot'}
TITLE_MAGIC_MAP[Const.TITLE_USE_JINGYAOLING]    = {'jiangyaoling',  'head'}
TITLE_MAGIC_MAP[Const.TITLE_RAID_LEADER]        = {'corps',         'head'}
TITLE_MAGIC_MAP[Const.TITLE_BREAK_FLAG]        = {'npw_break_flag',         'head'}
TITLE_MAGIC_MAP[Const.TITLE_OCCUPY_FLAG]        = {'npw_occupy_flag',         'head'}
TITLE_MAGIC_MAP[Const.TITLE_IN_GATHER]        = {'npw_in_gather',         'head'}

function Player:init()
    Char.init(self)

    -- 存放 title 信息
    self.titleInfo = {}
end

-- 重新刷新头衔
function Player:reRefreshTitle(oldTitle)
    if nil == oldTitle then
        oldTitle = {}
    end

    -- 更新人物title
    for k, v in pairs(TITLE_MAGIC_MAP) do
        self:updateTitleEffect(oldTitle, k)
    end

    -- 更新人物会员效果
    self:updateInsiderEffect(oldTitle)

    self:updateLeiTaiTitle()

    -- 更新名字
    self:updateName()
end



-- title 是否存在
function Player:hasTitle(title)
    return self.titleInfo[title]
end

-- 战斗中
function Player:isInCombat()
    return self:hasTitle(Const.TITLE_IN_COMBAT)
end

-- 交易中
function Player:isInExchange()
    return self:hasTitle(Const.TITLE_IN_EXCHANGE)
end

-- 队伍中
function Player:isInTeam()
    return self:hasTitle(Const.TITLE_IN_TEAM)
end

-- 队长
function Player:isTeamLeader()
    return self:hasTitle(Const.TITLE_TEAM_LEADER) or self:hasTitle(Const.TITLE_TEAM_LEADER_TEAM_FULL)
end

-- 队员
function Player:isTeamMember()
    return self:hasTitle(Const.TITLE_TEAM_MEMBER)
end

-- 观战中
function Player:isLookOn()
    return self:hasTitle(Const.TITLE_LOOKON)
end

-- 是否红名
function Player:isRedName()
    return self:hasTitle(Const.TITLE_RED_NAME)
end

-- 摆摊中
function Player:isInStall()
    return self:hasTitle(Const.TITLE_IN_STALL) or self:hasTitle(Const.TITLE_IN_STALL_OFFLINE)
end

-- 是否为会员（服务端当前未实现，该接口不可用）
--[[function Player:isInsider()
    return self:hasTitle(Const.TITLE_INSIDER)
end]]

-- 远程商店（仙灵卡）
function Player:isRemoteStore()
    return self:hasTitle(Const.TITLE_REMOTE_STORE)
end

-- 是否团长
function Player:isCorpsLeader()
    return self:hasTitle(Const.TITLE_RAID_LEADER)
end

-- 是否团员
function Player:isCorpsMember()
    return self:hasTitle(Const.TITLE_RAID_MEMBER)
end

-- 团队中
function Player:isInCorps()
    return self:hasTitle(Const.TITLE_IN_RAID)
end

-- 更新 title 效果
function Player:updateTitleEffect(oldTitle, title)
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
        elseif pos == "foot" then
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

-- 更新人物会员效果
function Player:updateInsiderEffect(oldTitle)
--[[ cyq todo
    if (IsInsider())
        // 为会员
        m_NameColor = g_pColorMgr->GetWpixel("Insider");
    else
        m_NameColor = g_pColorMgr->GetWpixel("Player");
        --]]
end

-- 更新名字颜色
function Player:updateNameColor()
    if self:isRedName() then
        return COLOR3.RED
    end

    if DistMgr:isInKFZC2019Server() and Me:queryBasic("title") ~= self:queryBasic("title") then
        return COLOR3.RED
    end
end

function Player:update()
    if self.posChanged and MapMgr:getCurrentMapName() == CHS[2000075] then
        self:checkIsInTianyongLeiTai() -- 检测是否在天墉城擂台上
        if self:updateLeiTaiTitle() then
            self:updateName()
        end
    end

    self.posChanged = nil

    Char.update(self)

    self:playFllowMagics()
end

function Player:setPos(x, y)
    if self.curX == x and self.curY == y then return end

    Char.setPos(self, x, y)

--[[
    if MapMgr:getCurrentMapName() == CHS[2000075] then
        -- 天墉城擂台有特殊需求
        self:updateName()
    end]]
    self.posChanged = true
end

function Player:playFllowMagics()
    if not self.followMagic or self:isTeamMember() or not self:getVisible() then return end

    local effect, follow_dis
    for k, v in pairs(self.followMagic) do
        if v then
            effect = v.effect
            follow_dis = v.follow_dis
            if GameMgr.scene and GameMgr.scene.map and gf:isOutDistance(v.pos.x, v.pos.y, self.curX, self.curY, follow_dis) then
                GameMgr.scene.map:addMagicToMap(effect, cc.p(self.curX, self.curY), self:getDir())
                v.pos = cc.p(self.curX, self.curY)
            end
        end
    end
end

function Player:checkIsInTianyongLeiTai()
    if MapMgr:getCurrentMapName() ~= CHS[2000075] then
        self.isInTianyongLeiTai = nil
        return
    end

    local x,y = gf:convertToMapSpace(self.curX, self.curY)
    if MapMgr:isInTianyongLeiTai({x = x, y = y}) then
        self.isInTianyongLeiTai = true
    else
        self.isInTianyongLeiTai = nil
    end
end

-- 2019端午节  口味大战称谓
function Player:isExsit2019kwdzChengWei()

    if self.dwj2019kwdzTitle then
        return self.dwj2019kwdzTitle
    end


    return false
end

function Player:updateLeiTaiTitle()
    local lastLeitaiTitle = self.leitaiTitle
    if not self.isInTianyongLeiTai then
        self.leitaiTitle = nil
        return lastLeitaiTitle ~= self.leitaiTitle
    end

    -- 如果2019口味大战称谓在，则优先用该称谓
    local kwdzChengwei = self:isExsit2019kwdzChengWei()
    if kwdzChengwei then
        self.leitaiTitle = kwdzChengwei
        return lastLeitaiTitle ~= self.leitaiTitle
    end

    local score = self:queryBasicInt('ct_data/score')
    local step, level = RingMgr:getStepAndLevelByScore(score)
    self.leitaiTitle = RingMgr:getJobChs(step, level)
    return lastLeitaiTitle ~= self.leitaiTitle
end

function Player:getTitle()
    if MapMgr:getCurrentMapName() ~= CHS[2000075] then
        -- 天墉城擂台有特殊需求
        return Char.getTitle(self)
    end

    return self.leitaiTitle or Char.getTitle(self)
end


-- 设置方向（有special_icon或者有mount_icon时候 只有四个方向）
function Player:setDir(dir)
    if gf:has8Dir(self:getIcon()) then
        Char.setDir(self, dir)
        return
    end

    if dir % 2 == 0 then
        dir = dir + 1
    end

    Char.setDir(self, dir)
end

function Player:onAbsorbBasicFields()
    self:updateLeiTaiTitle()
    Char.onAbsorbBasicFields(self)
end

function Player:isCanTouch()
    if MapMgr:isInXueJingShengdi() then
        return false
    else
        return Char.isCanTouch(self)
    end
end

-- excludeRideIcon  不获取坐骑 icon
-- excludeShowChild 不获取元婴/血婴 icon
-- excludeColorIcon 不获取换色后的 icon
function Player:getIcon(excludeRideIcon, excludeShowChild, excludeColorIcon)
    local icon
    repeat
        if MapMgr:isInYuLuXianChi() then
            icon = gf:getGenderByIcon(self:queryBasicInt("org_icon")) == "1" and 04001 or 04002
            break
        elseif ActivityHelperMgr:isInBhkySummer2019() then
            -- 冰火考验中屏蔽rideIcon, specialIcon
            icon = Char.getIcon(self, true, true, true, true)
            break
        end

        icon = CharMgr:getStatusActionIcon(self:getId(), self.faAct)
        if icon then break end

        icon = Char.getIcon(self, excludeRideIcon, excludeShowChild, true)
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

function Player:getOrgIcon()
    if MapMgr:isInYuLuXianChi() then
        return self:getIcon()
    end

    return Char.getOrgIcon(self)
end

function Player:getWeaponIcon(excludeRideIcon, excludeShowChild)
    -- 播放特殊动作时不显示武器
    if CharMgr:getStatusActionIcon(self:getId(), self.faAct) then
        return 0
    end

    if ActivityHelperMgr:isInBhkySummer2019() then
        -- 冰火考验中屏蔽武器icon
        return 0
    end

    if MapMgr:isInYuLuXianChi() then
        return 01406
    end

    return Char.getWeaponIcon(self, excludeRideIcon, excludeShowChild)
end

-- 获取部件索引
function Player:getPartIndex(excludeRideIcon)
    -- 播放特殊动作
    if CharMgr:getStatusActionIcon(self:getId(), self.faAct) then
        return ""
    end

    if MapMgr:isInYuLuXianChi() then
        return ""
    end

    if ActivityHelperMgr:isInBhkySummer2019() then
        return ""
    end

    return Char.getPartIndex(self, excludeRideIcon)
end

-- 获取部件换色
function Player:getPartColorIndex(excludeRideIcon)
    -- 播放特殊动作
    if CharMgr:getStatusActionIcon(self:getId(), self.faAct) then
        return ""
    end

    if MapMgr:isInYuLuXianChi() then
        return ""
    end

    if ActivityHelperMgr:isInBhkySummer2019() then
        return ""
    end

    return Char.getPartColorIndex(self, excludeRideIcon)
end

function Player:isShowRidePet()
    if CharMgr:getStatusActionIcon(self:getId(), self.faAct) then
        return false
    end

    if MapMgr:isInYuLuXianChi() then
        return false
    end

    if ActivityHelperMgr:isInBhkySummer2019() then
        return ""
    end

    return Char.isShowRidePet(self)
end

function Player:getShadow()
    if MapMgr:isInYuLuXianChi() then
        return false
    end

    return Char.getShadow(self)
end

function Player:getSpeed()
    if MapMgr:isInYuLuXianChi() then
        return WenQuanMgr:getPlayerSpeed()
    end

    return Char.getSpeed(self)
end

-- 点击对象时添加选中特效
function Player:addFocusMagic()
    if MapMgr:isInYuLuXianChi() then
        return
    end

    Char.addFocusMagic(self)
end

return Player
