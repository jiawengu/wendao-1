-- Monster.lua
-- Created by chenyq Nov/14/2014
-- 场景中的怪物对应的类

local Char = require("obj/Char")

local Monster = class("Monster", Char)
local TITLE_MAGIC_MAP = {}
TITLE_MAGIC_MAP[Const.TITLE_IN_COMBAT]          = {'fighting',      'head'}
TITLE_MAGIC_MAP[Const.TITLE_IN_EXCHANGE]        = {'exchanging',    'head'}
TITLE_MAGIC_MAP[Const.TITLE_TEAM_LEADER]        = {'leader',        'head'}
TITLE_MAGIC_MAP[Const.TITLE_LOOKON]             = {'look_on',       'head'}
TITLE_MAGIC_MAP[Const.TITLE_USE_JINGYAOSHU]     = {'jiangyaoshu',   'foot'}
TITLE_MAGIC_MAP[Const.TITLE_USE_JINGYAOLING]    = {'jiangyaoling',  'head'}
TITLE_MAGIC_MAP[Const.TITLE_RAID_LEADER]        = {'corps',         'head'}

function Monster:getLoadType()
    return LOAD_TYPE.NPC
end

-- 点击角色
function Monster:onClickChar()
    Char.onClickChar(self)
    --CharMgr:openNpcDlg(self:getId())

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


function Monster:init()
    Char.init(self)

    -- 存放 title 信息
    self.titleInfo = {}
end

function Monster:updateAfterLoadAction(notCheckFrozen)
    Char.updateAfterLoadAction(self, notCheckFrozen)

    self:showHeadTitle()
end

function Monster:showHeadTitle()
    if not self.charAction or not self.middleLayer or self.middleLayer:getChildByName("funcTitle") then
        return
    end

    if not self.headTitle then
        if self:queryBasic("name") == CHS[4010374] then
            local titleInfo = {classIcon = "ui/Icon2182.png", wordIcon = "ui/Icon2519.png"}

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
    end

    if self.headTitle then
        local x, y = self.charAction:getHeadOffset()
        self.headTitle:setPosition(x + 30, y + 30)
    end
end

-- 刷新头衔
function Monster:refreshTitle(data)
    -- 吸收头衔信息（在吸收前清头衔信息时，有些信息需要转化）
    local oldTitle = self:absorbTitleInfo(data)
    if not oldTitle then return end

    -- 更新人物正在战斗中/观战效果
    self:reRefreshTitle(oldTitle)
end

-- 重新刷新头衔
function Monster:reRefreshTitle(oldTitle)
    if nil == oldTitle then
        oldTitle = {}
    end

    -- 更新人物正在战斗中/观战效果
    self:updateTitleEffect(oldTitle, Const.TITLE_LOOKON)
    self:updateTitleEffect(oldTitle, Const.TITLE_IN_COMBAT)
end

-- 更新 title 效果
function Monster:updateTitleEffect(oldTitle, title)
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
function Monster:setDir(dir)
    if not gf:has8Dir(self:getIcon()) and dir % 2 == 0 then
        dir = dir + 1
    end

    Char.setDir(self, dir)
end

return Monster
