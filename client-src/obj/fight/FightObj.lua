-- FightObj.lua
-- Created by chenyq Nov/22/2014
-- 战斗对象的基类

local NumImg = require('ctrl/NumImg')
local Progress = require('ctrl/Progress')
local Bitset = require('core/Bitset')
local Object = require('obj/Object')
local Char = require('obj/Char')
local Shake = require('animate/Shake')
local IconColorScheme = require(ResMgr:getCfgPath("IconColorScheme.lua"))

local FightObj = class('FightObj', Char)

local STATUS_POISON         = 1     -- 中毒
local STATUS_SLEEP          = 2     -- 昏睡
local STATUS_FORGOTTEN      = 3     -- 遗忘
local STATUS_FROZEN         = 4     -- 冰冻
local STATUS_CONFUSION      = 5     -- 混乱
local STATUS_JOINT_ATTACK   = 6     -- 合击
local STATUS_REVIVE         = 7     -- 重生
local STATUS_STUNT          = 8     -- 必杀
local STATUS_DOUBLE_HIT     = 9     -- 连击
local STATUS_DAMAGE_SEL     = 10    -- 反震
local STATUS_COUNTER_ATTACK = 11    -- 反击
local STATUS_PROTECTED      = 12    -- 被保护
local STATUS_SPEED_UP       = 13    -- 速度上升
local STATUS_PHY_POWER_UP   = 14    -- 物理伤害上升
local STATUS_DEFENSE        = 15    -- 防御状态
local STATUS_MAX_LIFE_UP    = 16    -- 最大气血值上升
local STATUS_DODGE_UP       = 17    -- 躲闪上升
local STATUS_DEF_UP         = 18    -- 防御力上升
local STATUS_RECOVER_LIFE   = 19    -- 气血上升(持续加血)
local STATUS_METAL          = 20    -- 金相性改变
local STATUS_WOOD           = 21    -- 木相性改变
local STATUS_WATER          = 22    -- 水相性改变
local STATUS_FIRE           = 23    -- 火相性改变
local STATUS_EARTH          = 24    -- 土相性改变
local STATUS_LEECH_PHY_DAMAGE = 25  -- 转换物理伤害为HP
local STATUS_LEECH_MAG_DAMAGE = 26  -- 转换魔法伤害为HP
local STATUS_PASSIVE_ATTACK   = 27  -- 反弹物理攻击(乾坤罩)
local STATUS_DEADLY_KISS      = 28  -- 死亡缠绵特效
local STATUS_LOYALTY          = 29  -- 忠诚度变化(游说之舌)
local STATUS_IMMUNE_PHY_DAMAGE = 30 -- 免疫物理攻击(神龙罩)
local STATUS_IMMUNE_MAG_DAMAGE = 31 -- 免疫魔法攻击(如意圈)
local STATUS_POLAR_CHANGED     = 32 -- 相性改变
local STATUS_FANZHUAN_QIANKUN  = 33 -- 翻转乾坤
local STATUS_MANA_SHIELD       = 34 -- 法力护盾
local STATUS_PASSIVE_MAG_ATTACK= 35 -- 反弹魔法攻击(无色光环)
local STATUS_ADD_LIFE_BY_MANA  = 36 -- 移花接木技能状态
local STATUS_SELECT            = 40 -- 师徒任务中选中状态
local STATUS_XUWU              = 42 -- 虚无状态
local STATUS_HUANBING_ZHIJI    = 43  -- 缓兵之计
local STATUS_SHUSHOU_JIUQIN    = 44  -- 束手就擒
local STATUS_AITONG_YUJUE      = 45  -- 哀痛欲绝
local STATUS_WENFENG_SANGDAN   = 46  -- 闻风丧胆
local STATUS_YANGJING_XURUI    = 47  -- 养精蓄锐
local STATUS_DIANDAO_QIANKUN   = 48  -- 颠倒乾坤
local STATUS_JINGANGQUAN       = 49  -- 金刚圈
local STATUS_WUJI_BIFAN        = 50  -- 物极必反
local STATUS_TIANYAN           = 51  -- 天眼
local STATUS_CHAOFENG          = 52  -- 嘲讽
local STATUS_QINMJI_WUJIAN     = 53  -- 亲密无间
local STATUS_QISHA_YIN         = 54  -- 七杀-阴
local STATUS_QISHA_YANG        = 55  -- 七杀-阳
local STATUS_YANCHUAN_SHENJIAO = 56   -- 言传身教
local STATUS_DAOFA_WUBIAN      = 57  -- 道法无边

local STATUS_WEIYA      = 58  -- 威压
local STATUS_DLB_BJ            = 60 -- 地裂波标记

-- 血条、法力条相对于头顶基准点的偏移
local MANA_OFFSET_Y = 20
local MANA_OFFSET_X = 3
local LIFE_OFFSET_Y = 30
local ANGER_OFFSET_Y = 10
local ANGER_OFFSET_X = 6

local JT_OFFSET_Y = 40
local JT_OFFSET_X = 0

-- 时钟相对于头顶基准点的偏移
local CLOCK_OFFESET_Y = 60

-- 飞行数字之间的间隔
local FLY_NUM_IMG_INTERVAL = 30

-- 角色移动时（如 GoAhead、GoBack等）允许花费的最短时间
local MIN_MOVE_TIME = 300

-- 飘图相关位置
local FLY_IMG_START_X = 0
local FLY_IMG_START_Y = 50
local FLY_IMG_END_X = FLY_IMG_START_X - 50
local FLY_IMG_END_Y = FLY_IMG_START_Y + 60

-- 光效播放位置
local POS_FOOT = 1
local POS_WAIST = 2
local POS_HEAD = 3

-- 非循环动作允许播放的最大时间
local ACTION_MAX_INTERVAL = 3000

-- 动作与对应的处理函数的名称的映射表
local ACT_FUN_MAP = {
    [Const.FA_STAND]                    = 'actStand',           -- 站立
    [Const.FA_ACTION_PHYSICAL_ATTACK]   = 'actAttack',          -- 物理攻击
    [Const.FA_ACTION_CAST_MAGIC]        = 'actCast',            -- 施展魔法
    [Const.FA_ACTION_CAST_MAGIC_END]    = 'actCastEnd',         -- 施展魔法结束
    [Const.FA_ACTION_REVIVE]            = 'actRevive',          -- 重生
    [Const.FA_ACTION_FLEE]              = 'actFlee',            -- 逃跑
    [Const.FA_GO_AHEAD]                 = 'actGoAhead',         -- 前去攻击
    [Const.FA_GO_BACK]                  = 'actGoBack',          -- 攻击返回
    [Const.FA_DIE_NOW]                  = 'actDieNow',          -- 正在死亡
    [Const.FA_DIED]                     = 'actDied',            -- 已经死亡
    [Const.FA_ACTION_COUNTER_ATTACK]    = 'actCounterAttack',   -- 反击
    [Const.FA_ACTION_ATTACK_FINISH]     = 'actAttackFinish',    -- 攻击完成
    [Const.FA_GO_TO_PROTECT]            = 'actGoToProtect',     -- 前出保护
    [Const.FA_PROTECT_BACK]             = 'actProtectBack',     -- 保护回来
    [Const.FA_QUIT_GAME]                = 'actQuitGame',        -- 退出战斗
    [Const.FA_DODGE_START]              = 'actDodgeStart',      -- 开始躲避动作(离开站立原点)
    [Const.FA_DODGE_END]                = 'actDodgeEnd',        -- 结束躲避动作(回到站立原点)
    [Const.FA_PARRY_START]              = 'actParryStart',      -- 格挡开始
    [Const.FA_PARRY_END]                = 'actParryEnd',        -- 格挡结束
    [Const.FA_DEFENSE_START]            = 'actDefenseStart',    -- 防御开始
    [Const.FA_DEFENSE_END]              = 'actDefenseEnd',      -- 防御结束
}

-- 相性对应辅助技能状态
local Polar_Status =
{
    [POLAR.METAL] = STATUS_PHY_POWER_UP,
    [POLAR.WOOD]  = STATUS_RECOVER_LIFE,
    [POLAR.WATER]  = STATUS_DEF_UP,
    [POLAR.FIRE]  = STATUS_SPEED_UP,
    [POLAR.EARTH]  = STATUS_DODGE_UP,
}

-- 天生技能对应的状态(对己方)(敌方有些没状态)
local Raw_Status =
{
   [CHS[3000071]] = STATUS_FANZHUAN_QIANKUN,    -- 翻转乾坤
   [CHS[3000072]] = "",                         -- 神圣之光
   [CHS[3000079]] = STATUS_IMMUNE_MAG_DAMAGE,   -- 如意圈
   [CHS[3000074]] = STATUS_LOYALTY,             -- 游说之舌
   [CHS[3000075]] = "",                         -- 漫天血舞
   [CHS[3000076]] = "",                         -- 舍命一击
   [CHS[3000077]] = STATUS_PASSIVE_ATTACK,      -- 乾坤罩
   [CHS[3000078]] = STATUS_IMMUNE_PHY_DAMAGE,   -- 神龙罩
   [CHS[3000073]] = STATUS_DEADLY_KISS,         -- 死亡缠绵
   [CHS[3000084]] = STATUS_DEF_UP,     -- 防微杜渐
   [CHS[3000081]] = STATUS_PHY_POWER_UP,     -- 天生神力
   [CHS[3000083]] = STATUS_RECOVER_LIFE,     -- 拔苗助长
   [CHS[3000080]] = STATUS_SPEED_UP,     -- 十万火急
   [CHS[3000082]] = STATUS_DODGE_UP,     -- 鞭长莫及
}

function FightObj:init(fightPos)
    Char.init(self)
    self.fightPos = fightPos or 0
    self.isCreated = false
    self.showLife = true -- 是否显示血条信息，默认显示
    self.showMana = true -- 是否显示法力信息，默认显示
    self.needBindClickEvent = false -- 角色本身不需要绑定点击事件
    self.startTime = 0
    self.isActionEnd = false     -- 动作是否已播放完成
    self.isArrivedEndPos = false -- 是否到达指定位置

    -- 添加选择按钮
    self.selectImg = ccui.ImageView:create(ResMgr.ui.fight_sel_img, ccui.TextureResType.localType)
    self.selectImg:retain()
    self.selectImg:setLocalZOrder(Const.FIGHT_SEL_IMG_ORDER)
    self.selectImg:setVisible(false)


    -- 组合技能目标选择按钮
    self.selectZHSkillImg = ccui.ImageView:create(ResMgr.ui.fight_sel_img, ccui.TextureResType.localType)
    self.selectZHSkillImg:retain()
    self.selectZHSkillImg:setLocalZOrder(Const.FIGHT_SEL_IMG_ORDER + 1)
    self.selectZHSkillImg:setVisible(false)
    self.selectZHSkillImg:setEnabled(true)
    self.selectZHSkillImg:setTouchEnabled(true)

    self.selectZHSkillImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.selectZHSkillImg:loadTexture(ResMgr.ui.fight_sel_down_img)
            -- 判断是否有重合
            local curTouchPos = GameMgr.curTouchPos
            local list = {}
            for _, v in pairs(FightMgr.objs) do
                local image = v.topLayer:getChildByName(ResMgr.ui.fightClick)
                if image then
                    local rect = image:getBoundingBox()
                    local xy = image:convertToWorldSpace(cc.p(0, 0))
                    rect.x = xy.x
                    rect.y = xy.y
                    if cc.rectContainsPoint(rect, curTouchPos) then
                        table.insert(list, v)
                    end
                end
            end
            if #list > 1 then
                self:openUserListDlg(list)
            end
        elseif eventType == ccui.TouchEventType.ended then
            if DlgMgr:getDlgByName("UserListDlg") then
            else
            DlgMgr:sendMsg("ZHSkillTargetChoseDlg", "nextTarget", self:getId(), self:getName(), FightMgr:getObjectPosById(self:getId()))
            end
            return false
        elseif eventType == ccui.TouchEventType.canceled then
            self.selectZHSkillImg:loadTexture(ResMgr.ui.fight_sel_img)
        end
    end)
end

function FightObj:setZHSelectImageVisible(visible)
    if self.selectZHSkillImg then
        self.selectZHSkillImg:setVisible(visible)
    end
end

function FightObj:addCommandText(str)
    if not self.commandText then
        self.commandText = FightCommanderCmdMgr:createObjCommandPanel()
        self:addToTopLayer(self.commandText)
        local sz = self.commandText:getContentSize()
        if self.charAction then
            local x, y = self.charAction:getWaistOffset()
            self.commandText:setPosition(x - sz.width / 2, y - sz.height / 2)
        end
    end

    self.commandText:getChildByName("TextLabel"):setString(str)
    self.commandText:setVisible(true)
end

-- 如果退出游戏时要释放相关资源，可调用该接口
function FightObj:destruct()
    if self.selectImg then
        self.selectImg:release()
        self.selectImg = nil
    end

    if self.selectZHSkillImg then
        self.selectZHSkillImg:release()
        self.selectZHSkillImg = nil
    end
    Char.cleanup(self)
end

function FightObj:showSelectImg(visible)
    if self.selectImg then
        self.selectImg:setVisible(visible)
    end
end

function FightObj:openUserListDlg(list)
    local dlg = DlgMgr:openDlg("UserListDlg")
    dlg:setInfoByFightObj(list)
    local rect = self.selectImg:getBoundingBox()
    local xy = self.selectImg:convertToWorldSpace(cc.p(0, 0))
    rect.x = xy.x
    rect.y = xy.y
    dlg:setFloatingFramePos(rect)
end

function FightObj:create(attr)
    -- 设置默认方向
    self.dir = self:getRawDir()

    self.auto_fight = 0  -- 先清空旧对象自动战斗标记
    self:absorbBasicFields(attr)
    self:setVisible(true)

    if self.middleLayer then
        self.middleLayer:setVisible(true)
    end

    local x, y = self:getRawPos()
    self:setAct(Const.FA_STAND)
    self:onEnterScene(gf:convertToMapSpace(x, y))
    self:setPos(x, y)
    self:addToTopLayer(self.selectImg)
    if self.charAction then
        local x, y = self.charAction:getWaistOffset()
        self.selectImg:setPosition(x, y)
    end

    local image = ccui.ImageView:create(ResMgr.ui.fightClick, ccui.TextureResType.localType)
    image:setName(ResMgr.ui.fightClick)
    local imageX, imageY = self.selectImg:getPosition()
    image:setPosition(imageX, imageY)
    self:addToTopLayer(image)
    image:setOpacity(0)
    image:setEnabled(true)
    image:setTouchEnabled(true)
    image:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.selectImg:loadTexture(ResMgr.ui.fight_sel_down_img)
            local callFunc = cc.CallFunc:create(function()
                if GuideMgr:isRunning() then
                    return
                end

                if not sender:isHighlighted() then
                    -- 会响应 canceled 事件，不处理长按回调
                    return
                end

                self:objLongPress()
            end)

            -- 判断是否有重合
            local curTouchPos = GameMgr.curTouchPos
            local list = {}
            for _, v in pairs(FightMgr.objs) do
                local image = v.topLayer:getChildByName(ResMgr.ui.fightClick)
                if image then
                    local rect = image:getBoundingBox()
                    local xy = image:convertToWorldSpace(cc.p(0, 0))
                    rect.x = xy.x
                    rect.y = xy.y
                    if cc.rectContainsPoint(rect, curTouchPos) then
                        table.insert(list, v)
                    end
                end
            end

            if #list > 1 and not BattleSimulatorMgr:isRunning() then
                -- 如果有重叠，弹出玩家列表选择玩家
                self:openUserListDlg(list)
            else
                self.action = cc.Sequence:create(cc.DelayTime:create(GameMgr:getLongPressTime()),callFunc)
                self.charAction:runAction(self.action)
            end
            return true
        elseif eventType == ccui.TouchEventType.ended then
            if BattleSimulatorMgr:isRunning() then
                if not DlgMgr:getDlgByName("FightTargetChoseDlg") or not DlgMgr:getDlgByName("FightTargetChoseDlg"):isVisible() then
                    -- 自动战斗快速点击敌人，会引起指引在命令之后开始
					return false
                end
            end


            self.selectImg:loadTexture(ResMgr.ui.fight_sel_img)
            -- 判断下是否处于自动战斗状态
            if self.action then
                if Me:queryBasicInt("auto_fight") == 0 then
                    self:onSelectChar()
                    Log:D('onClickChar: selectImg' .. self:getName())
                end
            end

            self.charAction:stopAction(self.action)
           self.action = nil
           return false
        elseif eventType == ccui.TouchEventType.canceled then
            self.selectImg:loadTexture(ResMgr.ui.fight_sel_img)
        end
    end)

    self.touchImg = image

    -- 优先响应组合技能选择目标
	self.selectZHSkillImg:setVisible(false)
    self:addToTopLayer(self.selectZHSkillImg)

    self.isCreated = true
    self.isEnd = false          -- 人物动画是否播放结束
    self.isFinished = false     -- 当前命令是否执行完成
    self.status = Bitset.new(0) -- 人物的状态
    self.offline = false        -- 玩家是否掉线
    self.isWaiting = false      -- 是否正在等待输入
    self:setWaiting(self.isWaiting)

    if attr.effectIcons then
        for i = 1, #attr.effectIcons do
            CharMgr:playLightEffect(self, {effectIcon = attr.effectIcons[i]})
        end
    end

    self:updateLifeProgress()
    self:updateManaProgress()
    self:updateAngerProgress()
    self:updateJTStatus()

    -- 添加角色阴影
    self:addShadow()

    -- 重置透明度状态
    self.middleLayer:setCascadeOpacityEnabled(true)
    self.middleLayer:setOpacity(255)

    local fightPos = self.fightPos

    if FightMgr and FightMgr.zuheSelectInfo and FightMgr.zuheSelectInfo.visible then
        if FightMgr.zuheSelectInfo.isFriend and fightPos >= FightPosMgr.NUM_PER_LINE * 2 and fightPos <= FightPosMgr.NUM_PER_LINE * 4 - 1 then
            self:setZHSelectImageVisible(true)
            self.selectZHSkillImg:loadTexture(ResMgr.ui.fight_sel_img)
        end

        if not FightMgr.zuheSelectInfo.isFriend and fightPos >= 0 and fightPos <= FightPosMgr.NUM_PER_LINE * 2 - 1 then
            self:setZHSelectImageVisible(true)
            self.selectZHSkillImg:loadTexture(ResMgr.ui.fight_sel_img)
        end
    end
end

-- 指令输入完毕后的特效
function FightObj:addReadyToFightEffect()
    if self.readyToFight then
        self.readyToFight:removeFromParent()
        self.readyToFight = nil
    end

    local id = self:getId()
    if FightMgr.glossObjsInfo and FightMgr.glossObjsInfo[id] and (not FightMgr.glossObjsInfo[id]["show_sandglass"] or 1 ~= FightMgr.glossObjsInfo[id]["show_sandglass"]) then
       return
    end

    if not self.charAction then
        return
    end

    local headX, headY = self.charAction:getHeadOffset()
    self.readyToFight = gf:createLoopMagic(ResMgr.magic.ready_to_fight)
    self.readyToFight:setAnchorPoint(0.5, 0.5)
    self.readyToFight:setLocalZOrder(Const.CHARACTION_ZORDER)
    self.readyToFight:setPosition(0, headY + CLOCK_OFFESET_Y)
    self:addToMiddleLayer(self.readyToFight)
end

-- 移除时钟动画
function FightObj:removeReadyToFightEffect()
    if self.readyToFight then
        self.readyToFight:removeFromParent()
    end

    self.readyToFight = nil
end

function FightObj:cleanup()
    self:onExitScene()

    -- 此处需要清一下，有可能出现 cleanup 之前 self.readyToFight 没有删除的情况
    self.readyToFight = nil

    if self:getType() == "FightOpponent" then
        self.showLife = false
    end

    self.basic:cleanup()
    self.extra:cleanup()
    self.comAtt:cleanup()
    self.isCreated = false
    self.lifeProgress = nil
    self.manaProgress = nil
    self.angerProgress = nil
    self.jtStatus = nil
    self.flyDelayTime = nil
    self.lastFlyImgTime = nil
    self.commandText = nil
end

-- 初始化状态
function FightObj:initStatus(data)
    if data.die ~= 0 then
        self:setAct(Const.FA_DIED)
    end

    self:refreshStatus(data)
end

function FightObj:canShowJTStatus()
    return false
end

function FightObj:updateJTStatus()
end

-- 是否需要显示血条
function FightObj:canShowLife()
    if self.showLife or WatchRecordMgr:getCurReocrdCombatId() then
        return true
    end

    return
end

-- 更新血条
function FightObj:updateLifeProgress()
    if not self.isCreated or not self.charAction then
        return
    end

    if not self:canShowLife() then
        if self.lifeProgress then
            self.lifeProgress:setVisible(false)
        end

        return
    end

    if not self.lifeProgress then
        self.lifeProgress = Progress.new(ResMgr.ui.fight_progress_back, ResMgr.ui.fight_progress_life)
        self.lifeProgress:setLocalZOrder(Const.CHAR_PROGRESS_ZORDER)
        self:addToMiddleLayer(self.lifeProgress)
    end

    -- 变身卡变幻后调整高度
    local headX, headY = self.charAction:getHeadOffset()
    self.lifeProgress:setPosition(0, headY + LIFE_OFFSET_Y)
    self.lifeProgress:setVisible(true)
    local max = self:queryInt('max_life')

    local percent = 0
    if max > 0 then
        percent = self:queryInt('life') * 100 / max
    end

    local id = self:getId()
    if FightMgr.glossObjsInfo[id] and FightMgr.glossObjsInfo[id].isSet == 1
        and FightMgr.glossObjsInfo[id].life and FightMgr.glossObjsInfo[id].max_life then
        percent = FightMgr.glossObjsInfo[id].life / FightMgr.glossObjsInfo[id].max_life * 100
    end

    self.lifeProgress:setPercent(percent)
end

-- 是否需要显示法力条
function FightObj:canShowMana()
    if WatchRecordMgr:getCurReocrdCombatId() and not self:isGuard() and not self:isNpc() then return true end

    return self.showMana and not self:isGuard() and not self:isNpc() and not self:isMonster()
end

-- 更新法力条
function FightObj:updateManaProgress()
    if not self.isCreated or not self.charAction then
        return
    end

    if not self:canShowMana() then
        if self.manaProgress then
            self.manaProgress:setVisible(false)
        end
        return
    end

    if not self.manaProgress then

        self.manaProgress = Progress.new(ResMgr.ui.fight_progress_back, ResMgr.ui.fight_progress_mana)
        self.manaProgress:setLocalZOrder(Const.CHAR_PROGRESS_ZORDER)

        self:addToMiddleLayer(self.manaProgress)
    end
    local headX, headY = self.charAction:getHeadOffset()
    self.manaProgress:setPosition(MANA_OFFSET_X, headY + MANA_OFFSET_Y)
    local max = self:queryInt('max_mana')

    local percent = 0
    if max > 0 then
        percent = self:queryInt('mana') * 100 / max
    end

    local id = self:getId()
    if FightMgr.glossObjsInfo[id] and FightMgr.glossObjsInfo[id].isSet == 1
        and FightMgr.glossObjsInfo[id].mana and FightMgr.glossObjsInfo[id].max_mana then
        percent = FightMgr.glossObjsInfo[id].mana / FightMgr.glossObjsInfo[id].max_mana * 100
    end
    self.manaProgress:setPercent(percent)
end

-- 是否需要显示怒气条
-- 目前只有“有进阶技能的宠物”可以显示怒气条，在FightPet中进行是否需要显示怒气条的判断
function FightObj:canShowAnger()
    return false
end

-- 更新怒气条
function FightObj:updateAngerProgress()
    if not self.isCreated or not self.charAction then
        return
    end

    if not self:canShowAnger() then
        if self.angerProgress then
            self.angerProgress:setVisible(false)
        end
        return
    end

    if not self.angerProgress then

        self.angerProgress = Progress.new(ResMgr.ui.fight_progress_back_anger,
                             ResMgr.ui.fight_progress_anger, ResMgr.ui.fight_progress_top_anger)
        self.angerProgress:setLocalZOrder(Const.CHAR_PROGRESS_ZORDER)

        self:addToMiddleLayer(self.angerProgress)
    end

    local headX, headY = self.charAction:getHeadOffset()
    if not self:canShowLife() and not self:canShowMana() then
        self.angerProgress:setPosition(0, headY + LIFE_OFFSET_Y)
    elseif not self:canShowMana() then
        self.angerProgress:setPosition(MANA_OFFSET_X, headY + MANA_OFFSET_Y)
    else
        self.angerProgress:setPosition(ANGER_OFFSET_X, headY + ANGER_OFFSET_Y)
    end

    local anger = tonumber(self:queryBasic("boss_anger"))
    if not anger then
        anger = self:queryInt("pet_anger")
    end

    local max = 100
    local percent = 0
    if max > 0 then
        percent = anger * 100 / max
    end

    self.angerProgress:setPercent(percent)
end



-- 设置位置
function FightObj:setPos(x, y)
    -- Char.setPos 会进行遮挡判断，战斗对象无此要求，故直接调 Object 的 setPos 方法
    Object.setPos(self, x, y)
end

-- 清空动作
function FightObj:clearAction()
    if not self.isCreated then
        return
    end

    if self.faAct == Const.FA_QUIT_GAME then
        -- 已经退出战斗场景，清空此对象
        self:cleanup()
        return
    elseif self.faAct == Const.FA_DIE_NOW then
        -- 正在死亡
        self:setFinished(true)

        -- 置为死亡状态
        self:setAct(Const.FA_DIED)
        return
    elseif self.faAct == Const.FA_DIED then
        -- 已经死亡
        self:setFinished(true)
        return
    end

    -- 人物恢复原位
    self:setPos(self:getRawPos())

    -- 设为站立状态
    self:setAct(Const.FA_STAND)

    self:setFinished(true)
end

-- 计算目标位置
function FightObj:calculateDestPos(fromPos, toPos)
    local nearX, nearY = FightPosMgr:getPos(fromPos)
    local farX, farY = FightPosMgr:getPos(toPos)

    if self.faAct == Const.FA_GO_AHEAD then
        -- 前进
        self.desX, self.desY = FightPosMgr:getPointBetweenAB(farX, farY, nearX,
            nearY, FightPosMgr.ATTACK_DIS)
    elseif self.faAct == Const.FA_GO_TO_PROTECT then
        -- 去保护
        self.desX, self.desY = FightPosMgr:getPointBetweenAB(nearX, nearY, farX,
            farY, FightPosMgr.PROTECTED_DIS)
    elseif self.faAct == Const.FA_DODGE_START then
        -- 躲闪
        self.desX, self.desY = FightPosMgr:getPointDistanceFormA(nearX, nearY, farX,
            farY, FightPosMgr.PROTECTED_DIS)
    elseif self.faAct == Const.FA_DEFENSE_START then
        -- 防御开始
        self.desX, self.desY = FightPosMgr:getPointBetweenAB(nearX, nearY, farX,
            farY, FightPosMgr.ATTACK_DIS)
    else
        self.desX, self.desY = FightPosMgr:getPointDistanceFormA(nearX, nearY, farX, farY, 0)
    end
end

-- 设置动作是否已完成
function FightObj:setFinished(finished)
    self.isEnd = finished
    self.isFinished = finished
end

-- 判断动作是否完成了
function FightObj:getIsFinished()
    if self.isFinished then
        -- 动作播放完成
        return true
    end

    if gfGetTickCount() - self.startTime > ACTION_MAX_INTERVAL then
        -- 超时了，直接设置动作完成
        self.isFinished = true
    end

    return self.isFinished
end


-- 播放相关光效，当前用于顶号
function FightObj:playLoopEffectForLogin(data)
    -- 如果看录像，跳过，则不播放效果
    if WatchRecordMgr.skipMagic then return end

    local flag = Bitset.new(data.effectPos)

    if flag:isSet(EFFECT_TYPE.GLOBAL) then
        -- 暂时不会用到
    elseif flag:isSet(EFFECT_TYPE.LOCATION_WAIST) then
        -- 光效显示在腰上
        -- 暂时不会用到
    elseif flag:isSet(EFFECT_TYPE.LOCATION_HEAD) then
        -- 光效显示在头上
        -- 暂时不会用到
    else
        -- 光效显示在脚上
        self:addMagicOnFoot(tonumber(data.effectIcon), true, data.effectIcon)
    end
end

-- 播放宠物天书技能
function FightObj:playGodBookSkillEffect(data)
    -- 如果看录像，跳过，则不播放效果
    if WatchRecordMgr.skipMagic then return end

    self:addMagicOnFoot(tonumber(data.effect_no), true, 'god_book')
end

-- 播放或者移除脚底光效（通过msg_c_update）
function FightObj:playOrStopEffectFoot(data)
    if data["effect_foot"] == nil then
        return
    end

    if data["effect_foot"] ~= 0 then
        local behind    = math.floor(tonumber(data.effect_foot) / Const.EFFECT_LAYER_OFFSET)
        local effectId  = math.fmod(tonumber(data.effect_foot), Const.EFFECT_LAYER_OFFSET)
        self:addMagicOnFoot(effectId, (behind == 0), 'effect_foot')
    else
        self:deleteMagic('effect_foot')
    end
end

-- 播放或者移除腰部光效（通过msg_c_update）
function FightObj:playOrStopEffectWaist(data)
    if data["effect_waist"] == nil then
        return
    end

    if data["effect_waist"] ~= 0 then
        local behind    = math.floor(tonumber(data.effect_waist) / Const.EFFECT_LAYER_OFFSET)
        local effectId  = math.fmod(tonumber(data.effect_waist), Const.EFFECT_LAYER_OFFSET)
        self:addMagicOnWaist(effectId, (behind == 0), 'effect_waist')
    else
        self:deleteMagic('effect_waist')
    end
end

-- 播放或者移除头部光效（通过msg_c_update）
function FightObj:playOrStopEffectHead(data)
    if data["effect_head"] == nil then
        return
    end

    if data["effect_head"] ~= 0 then
        local behind    = math.floor(tonumber(data.effect_head) / Const.EFFECT_LAYER_OFFSET)
        local effectId  = math.fmod(tonumber(data.effect_head), Const.EFFECT_LAYER_OFFSET)
        self:addMagicOnHead(effectId, (behind == 0), 'effect_head')
    else
        self:deleteMagic('effect_head')
    end
end

-- 刷新状态（客户自定义）
function FightObj:refreshCustomStatus(status)
    -- 如果看录像，跳过，则不播放效果
    if WatchRecordMgr.skipMagic then return end

    local magic = 0

    -- 分离飘字信息
    local flyImgFlag = math.floor(status / 100)
    status = status % 100

    if status == 1 then magic = ResMgr.magic.stunt              -- 必杀
    elseif status == 2 then magic = ResMgr.magic.tj_lie_yan     -- 烈炎
    elseif status == 3 then magic = ResMgr.magic.tj_jing_lei    -- 惊雷
    elseif status == 4 then magic = ResMgr.magic.tj_qing_mu     -- 青木
    elseif status == 5 then magic = ResMgr.magic.tj_sui_shi     -- 碎石
    elseif status == 6 then magic = ResMgr.magic.tj_han_bing    -- 寒冰
    else
        Log:W("FightObj:refreshCustomStatus: Unknown status " .. status)
    end

    if magic > 0 then
        -- 显示在角色前面
        self:addMagicOnFoot(magic, false)
    end

    if flyImgFlag == 1  then
        -- 必杀
        self:flyImg(FightMgr:getWordsImgFile(CHS[3000006]))
    else
        Log:W("FightObj:refreshCustomStatus: Unknown flyImgFlag " .. flyImgFlag)
    end
end

-- 刷新状态（客户自定义）
function FightObj:refreshCustomStatusEx(status)
    -- 如果看录像，跳过，则不播放效果
    if WatchRecordMgr.skipMagic then return end

    local magic = 0

    -- 分离飘字信息
    local attrib = Bitset.new(status)

    if attrib:isSet(1) then
        self:addMagicOnFoot(ResMgr.magic.stunt, false)
    end
    if attrib:isSet(2) then
        self:addMagicOnFoot(ResMgr.magic.tj_lie_yan, false)
    end
    if attrib:isSet(3) then
        self:addMagicOnFoot(ResMgr.magic.tj_jing_lei, false)
    end
    if attrib:isSet(4) then
        self:addMagicOnFoot(ResMgr.magic.tj_qing_mu, false)
    end
    if attrib:isSet(5) then
        self:addMagicOnFoot(ResMgr.magic.tj_sui_shi, false)
    end
    if attrib:isSet(6) then
        self:addMagicOnFoot(ResMgr.magic.tj_han_bing, false)
    end

    if attrib:isSet(7) then
        -- 必杀
        self:flyImg(FightMgr:getWordsImgFile(CHS[3000006]))
    else
        Log:W("FightObj:refreshCustomStatus: Unknown flyImgFlag " .. status)
    end

end

-- 获取物理伤害上升状态光效 key
function FightObj:getPhyPowerUpEffectKey()
    return 'phy_power_up'
end

-- 刷新状态
function FightObj:refreshStatus(statusInfo)
    local statusArray = {}
    for i = 1, statusInfo.s_num do
        table.insert(statusArray, gf:uint(statusInfo['s' .. i]))
    end

    local s = Bitset.new(statusArray)

    if self.status:isEqual(s) then
        return
    end

    local phyPowerEffectKey = self:getPhyPowerUpEffectKey()

    self:checkStatus(s, STATUS_SPEED_UP,            'speed_up',             POS_FOOT,   false,  5)  -- 速度上升
    self:checkStatus(s, STATUS_PHY_POWER_UP,        phyPowerEffectKey,      POS_FOOT,   true) -- 物理伤害上升
    self:checkStatus(s, STATUS_DODGE_UP,            'dodge_up',             POS_WAIST,  false) -- 躲闪上升
    self:checkStatus(s, STATUS_DEF_UP,              'def_up',               POS_FOOT,   true,   3)  -- 防御力上升
    self:checkStatus(s, STATUS_RECOVER_LIFE,        'recover_life',         POS_WAIST,  false) -- 气血上升(持续加血)
    self:checkStatus(s, STATUS_POISON,              'poison',               POS_WAIST,  false) -- 中毒
    self:checkStatus(s, STATUS_SLEEP,               'sleep',                POS_WAIST,  false) -- 昏睡
    self:checkStatus(s, STATUS_FORGOTTEN,           'forgotten',            POS_WAIST,  false) -- 遗忘
    self:checkStatus(s, STATUS_FROZEN,              'frozen',               POS_WAIST,  false) -- 冰冻
    self:checkStatus(s, STATUS_CONFUSION,           'confusion',            POS_HEAD,   false) -- 混乱

    self:checkStatus(s, STATUS_PASSIVE_ATTACK,      'passive_attack',       POS_FOOT,   false) -- 反弹物理攻击(乾坤罩)
    self:checkStatus(s, STATUS_IMMUNE_PHY_DAMAGE,   'immune_phy_damage',    POS_FOOT,   false) -- 免疫物理攻击(神龙罩)
    self:checkStatus(s, STATUS_IMMUNE_MAG_DAMAGE,   'immune_mag_damage',    POS_WAIST,  false) -- 免疫魔法攻击(如意圈)
    self:checkStatus(s, STATUS_DEADLY_KISS,         'deadly_kiss',          POS_FOOT,   true,   2)  -- 死亡缠绵
    self:checkStatus(s, STATUS_POLAR_CHANGED,       'polar_changed',        POS_WAIST,  false) -- 五行改变
    self:checkStatus(s, STATUS_FANZHUAN_QIANKUN,    'fanzhuan_qiankun',     POS_WAIST,  false) -- 翻转乾坤
    self:checkStatus(s, STATUS_LOYALTY,             'loyalty',              POS_WAIST,  false) -- 游说之舌
    self:checkStatus(s, STATUS_MANA_SHIELD,         'mana_shield',          POS_FOOT,  false) -- 法力护盾
    self:checkStatus(s, STATUS_ADD_LIFE_BY_MANA,    'add_life_by_mana',     POS_WAIST, false) -- 移花接木
    self:checkStatus(s, STATUS_PASSIVE_MAG_ATTACK,  'five_color',           POS_WAIST, false) -- 五色光环
    self:checkStatus(s, STATUS_SELECT,              'master_select',        POS_FOOT, false) -- 五色光环
    self:checkStatus(s, STATUS_HUANBING_ZHIJI,      'huanbing_zhiji',       POS_FOOT,   true,   1)  -- 缓兵之计
    self:checkStatus(s, STATUS_SHUSHOU_JIUQIN,      'shushou_jiuqin',       POS_FOOT,   true,   4)  -- 束手就擒
    self:checkStatus(s, STATUS_AITONG_YUJUE,        'aitong_yujue',         POS_FOOT,   true,   4)  -- 哀痛欲绝
    self:checkStatus(s, STATUS_WENFENG_SANGDAN,     'wenfeng_sangdan',      POS_FOOT,   true,   4)  -- 闻风丧胆
    self:checkStatus(s, STATUS_YANGJING_XURUI,      'yangjing_xurui',       POS_FOOT,   true,   1)  -- 养精蓄锐
    self:checkStatus(s, STATUS_JINGANGQUAN,         'jingangquan',          POS_WAIST, false)  -- 金刚圈
    self:checkStatus(s, STATUS_CHAOFENG,            'chaofeng',             POS_FOOT, true)  -- 嘲讽
    self:checkStatus(s, STATUS_QISHA_YIN,           'status_qisha_yin',    POS_FOOT, false)  -- 七杀-阴
    self:checkStatus(s, STATUS_QISHA_YANG,          'status_qisha_yang',  POS_FOOT, false)  -- 七杀-阳
    self:checkStatus(s, STATUS_YANCHUAN_SHENJIAO,   'status_yanchuan_shenjiao',  POS_FOOT, false)  -- 七杀-阳
    self:checkStatus(s, STATUS_DAOFA_WUBIAN,        'status_daofa_wubian',  POS_WAIST, false)  -- 道法无边

    self:checkStatus(s, STATUS_WEIYA,           'status_weiya',    POS_WAIST, false)  -- 威压
    self:checkStatus(s, STATUS_DLB_BJ,           'status_diliebo_flag',    POS_HEAD, false)  -- 威压

    self:checkStatus(s, STATUS_XUWU) -- 虚无状态
    self:checkStatus(s, STATUS_DIANDAO_QIANKUN)  -- 颠倒乾坤

    self.status = s
end

-- 检查状态
function FightObj:checkStatus(status, statusType, magicType, pos, behind, z)
    if self:isSetStatus(statusType) then

        -- 当前已存在该状态
        -- 服务器端的索引是从 0 开始的，lua 中是从 1 开始的，故需要加 1
        if status:isSet(statusType + 1) then
            -- 此状态没有改变
            return
        end

        -- 要删除该状态
        if magicType then
            self:deleteMagic(magicType)
        end

        if statusType == STATUS_FROZEN then
            -- 解除冰冻，需要恢复动作
            self.charAction:continuePlay()
        elseif statusType == STATUS_XUWU then
            -- 虚无状态没有光效，只有半透明状态，所以删除状态时将半透明状态移除
            self.middleLayer:setCascadeOpacityEnabled(true)
            self.middleLayer:setOpacity(255)
        end

        -- 通知状态显示
        if self:getId() == Me:getId() then
            DlgMgr:sendMsg("SkillStatusDlg", "removeStatus", statusType)
        end

        local obj = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
        if obj and self:getId() == obj:getId() then
            DlgMgr:sendMsg("SkillStatusDlg", "removeStatus", statusType, obj:getId())
        end
        return
    end

    if not status:isSet(statusType + 1) then
        -- 此状态没有改变，依然没有该状态
        return
    end

    -- 添加该状态
    local magic
    if magicType and ResMgr.magic[magicType] then
        if pos == POS_FOOT then
            magic = self:addMagicOnFoot(ResMgr.magic[magicType], behind, magicType)
        elseif pos == POS_WAIST then
            magic = self:addMagicOnWaist(ResMgr.magic[magicType], behind, magicType)
        elseif pos == POS_HEAD then
            magic = self:addMagicOnHead(ResMgr.magic[magicType], behind, magicType)
        else
        end
    end

    if magic and z then
        local zorder = self:getMagicZorder(behind)
        magic:setLocalZOrder(zorder + z)
    end

    if statusType == STATUS_FROZEN then
        -- 冰冻，需要暂停动作
        self.charAction:pausePlay()
    elseif statusType == STATUS_XUWU then
        -- 虚无状态，将角色设置为半透明状态
        self.middleLayer:setCascadeOpacityEnabled(true)
        self.middleLayer:setOpacity(110)
    end

    -- 通知状态显示
    if self:getId() == Me:getId() then
        DlgMgr:sendMsg("SkillStatusDlg", "addStatus", statusType)
    end

    local obj = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if obj and self:getId() == obj:getId() then
        DlgMgr:sendMsg("SkillStatusDlg", "addStatus", statusType, obj:getId())
    end
end

-- 显示飘图效果
function FightObj:flyImg(imgFile)
    local now = gfGetTickCount()
    if not self.lastFlyImgTime then
        self.lastFlyImgTime = 0
    end

    if not self.flyDelayTime then
        self.flyDelayTime = 0
    end

    if now - self.lastFlyImgTime < 33 then
        self.flyDelayTime = self.flyDelayTime + 0.5
    else
        self.flyDelayTime = 0
        self.lastFlyImgTime = now
    end

    local img = cc.Sprite:create(imgFile)
    img:setPosition(FLY_IMG_START_X, FLY_IMG_START_Y)
    img:setLocalZOrder(Const.FLYIMG_ZORDER)
    self:addToMiddleLayer(img)
    img:setOpacity(0)

    local duration = 1.5
    local action = cc.Spawn:create(
        cc.MoveTo:create(duration, cc.p(FLY_IMG_END_X, FLY_IMG_END_Y)),
        cc.FadeOut:create(duration))

    action = cc.Sequence:create(cc.DelayTime:create(self.flyDelayTime), cc.FadeIn:create(0),action, cc.RemoveSelf:create())
    img:runAction(action)
end

-- 添加光效，光效播放完成后需要设置结束标记
function FightObj:setMagic(icon, align, type, shake_screen, blendMode)
    local flag = Bitset.new(align)
    local x, y = 0, 0
    if flag:isSet(Const.MAGIC_ALIGN_TYPE_CENTER) then
        -- 在屏幕中央显示，把坐标调整到屏幕中央
        local cx, cy = FightPosMgr:getScreenCenterPos()
        x = x + cx - self.curX
        y = y + cy - self.curY
    elseif flag:isSet(Const.MAGIC_ALIGN_TYPE_HEAD) then
        if self.charAction then
            x, y = self.charAction:getHeadOffset()
        end
    elseif flag:isSet(Const.MAGIC_ALIGN_TYPE_WAIST) then
        if self.charAction then
            x, y = self.charAction:getWaistOffset()
        end
    end

    -- 标记动画未播放完成
    -- self:setFinished(false)
    self:setBasic("magic_finish", 0)

    -- 正在播放播放同一个全屏光效不需要播放
    local pos = Const.MAGIC_ALIGN_TYPE_TOP
    if flag:isSet(Const.MAGIC_ALIGN_TYPE_TOP) then
        -- 顶层播放
        pos = Const.MAGIC_ALIGN_TYPE_TOP
    elseif flag:isSet(Const.MAGIC_ALIGN_TYPE_BOTTOM) then
        pos = Const.MAGIC_ALIGN_TYPE_BOTTOM
    end

    SkillEffectMgr:setPlayFullScreenFightPos(self.fightPos)

    if flag:isSet(Const.MAGIC_ALIGN_TYPE_CENTER) then
        if SkillEffectMgr:isPlayingFullScreenEffect(icon, pos) then
            return
        else
            SkillEffectMgr:setFightPlayFullScreen(icon, pos, self.fightPos)
        end
    end

    local magic
    if type == "armature" then -- 动作类型为骨骼动画
        magic = self:createArmatureAction(icon, flag)
    else
        local callback = function(node, data) self:onMagicFinish(node, data) end
        local extraPara = {
            blendMode = blendMode,
        }
        magic = gf:createCallbackMagic(icon, callback, extraPara)
        magic:setPosition(x, y)

        if flag:isSet(Const.MAGIC_ALIGN_TYPE_TOP) then
            -- 顶层播放
            self:addToTopLayer(magic)
        elseif flag:isSet(Const.MAGIC_ALIGN_TYPE_BOTTOM) then
            -- 底层播放
            self:addToBottomLayer(magic)
        else
            local zorder = self:getMagicZorder(false)
            self:addToMiddleLayer(magic)
            magic:setLocalZOrder(zorder)
        end
    end

    if shake_screen then
        local shake = Shake.new(cc.Director:getInstance():getRunningScene(), 0, shake_screen)
        magic:addChild(shake)
    end

    return true
end

-- 播放骨骼动画
function FightObj:createArmatureAction(icon, flag)
    local callback
    if gfIsDebug() then
        local startTime = gfGetTickCount()
        callback = function(node, data)
            self:onMagicFinish(node, data)
            local endTime = gfGetTickCount()
            ChatMgr:sendMiscMsg(string.format("[%d] play time:%d", icon, endTime - startTime))
        end
    else
        callback = function(node, data)
            self:onMagicFinish(node, data)
        end
    end

    local magic = ArmatureMgr:createSkillArmature(icon)

    local function func(sender, type, id)
        if type == ccs.MovementEventType.complete then
            FightMgr:setFightFullScreenEffect(nil, magic)
            magic:stopAllActions()
            magic:removeFromParent(true)
            callback()
        end
    end

    magic:setAnchorPoint(0.5, 0.5)
    magic:getAnimation():setMovementEventCallFunc(func)

    local actionName = ""
    if flag:isSet(Const.MAGIC_ALIGN_TYPE_TOP) then
        actionName = "Top"
    elseif flag:isSet(Const.MAGIC_ALIGN_TYPE_BOTTOM) then
        actionName = "Bottom"
    end

    magic:getAnimation():play(actionName)

    if flag:isSet(Const.MAGIC_ALIGN_TYPE_CENTER) then
        -- 在屏幕中央显示
        local cx, cy = FightPosMgr:getScreenCenterPos()
        magic:setPosition(cx, cy)
        if flag:isSet(Const.MAGIC_ALIGN_TYPE_TOP) then
            -- 顶层播放
            gf:getCharTopLayer():addChild(magic)
        elseif flag:isSet(Const.MAGIC_ALIGN_TYPE_BOTTOM) then
            -- 底层播放
            gf:getCharBottomLayer():addChild(magic)
        else
            local zorder = self:getMagicZorder(false)
            gf:getCharMiddleLayer():addChild(magic)
            magic:setLocalZOrder(zorder)
        end

        FightMgr:setFightFullScreenEffect(icon, magic)
    else
        -- 针对对象显示
        local x, y = 0, 0
        if self.charAction then
            if flag:isSet(Const.MAGIC_ALIGN_TYPE_HEAD) then
                x, y = self.charAction:getHeadOffset()
            elseif flag:isSet(Const.MAGIC_ALIGN_TYPE_WAIST) then
                x, y = self.charAction:getWaistOffset()
            end
        end

        magic:setPosition(x, y)
        if flag:isSet(Const.MAGIC_ALIGN_TYPE_TOP) then
            -- 顶层播放
            self:addToTopLayer(magic)
        elseif flag:isSet(Const.MAGIC_ALIGN_TYPE_BOTTOM) then
            -- 底层播放
            self:addToBottomLayer(magic)
        else
            local zorder = self:getMagicZorder(false)
            self:addToMiddleLayer(magic)
            magic:setLocalZOrder(zorder)
        end
    end

    return magic
end

-- 光效播放完成
function FightObj:onMagicFinish(node, data)
    -- 移除动画
    if node then
        node:removeFromParent(true)
    end

    -- 标记动画已播放完成
    self:setBasic("magic_finish", 1)

    -- 清除全屏播放光效标志
    SkillEffectMgr:clearFullScreenEffect()
end

-- 设置光效播放完成
function FightObj:onMagicFinish_ex()
    -- 标记动画已播放完成
    self:setBasic("magic_finish", 1)
end

-- 设置技能光效
function FightObj:setSkillEffect(skillNo, toOthers)
    local magics = SkillEffectMgr:getMagicInfo(skillNo, toOthers)
    if magics then
        for i = 1, magics.count do
            if self:setMagic(magics[i].icon, magics[i].align, magics[i].type, magics[i].shake_screen, magics[i].blendMode) then
                -- 成功播放技能光效，播放技能音效
                SoundMgr:playSkillEffect(magics[i].icon)
            end
        end
    else
        self:onMagicFinish()
    end
end

-- 设置玩家是否掉线
function FightObj:setOffline(offline)
    if offline then
        self.offline = true
    else
        self.offline = false
    end
end

-- 玩家是否掉线
function FightObj:isOffline()
    return self.offline
end

-- 能否执行指定的动作
function FightObj:canDoAct(saAct)
    if self.faAct == Const.FA_DIED or not self.charAction then
        return false
    end

    if self.charAction:haveAct(saAct) then
        return true
    end

    return false
end

-- 是否是宠物
function FightObj:isPet()
    return self:queryBasicInt('type') == OBJECT_TYPE.PET
end

-- 是否是守护
function FightObj:isGuard()
    return self:queryBasicInt('type') == OBJECT_TYPE.GUARD
end

-- 是否是玩家
function FightObj:isPlayer()
    return self:queryBasicInt('type') == OBJECT_TYPE.CHAR
end

-- 是否是Npc
function FightObj:isNpc()
    return self:queryBasicInt('type') == OBJECT_TYPE.NPC
end

-- 是否是娃娃
function FightObj:isKid()
    return self:queryBasicInt('type') == OBJECT_TYPE.CHILD
end

-- 是否是怪物
function FightObj:isMonster()
    return self:queryBasicInt('type') == OBJECT_TYPE.MONSTER
end

-- 是否中毒了
function FightObj:isPoison()
    return self:isSetStatus(STATUS_POISON)
end

-- 是否被冰冻了
function FightObj:isFrozen()
    return self:isSetStatus(STATUS_FROZEN)
end

function FightObj:isSetStatus(status)
   return self.status and self.status:isSet(status + 1)
end

-- 是否处于虚无状态
function FightObj:isXuWu()
    return self:isSetStatus(STATUS_XUWU)
end

-- 攻击技能的权重
function FightObj:getSkillTargetWeight()
    local weight = 50

    if self:isSetStatus(STATUS_FROZEN) then                -- 冰冻
        weight = 10
    end

    if self:isSetStatus(STATUS_PASSIVE_MAG_ATTACK) then    -- 无色光环
        weight = 20
    end

    if self:isSetStatus(STATUS_SLEEP) then                 -- 昏睡
        weight = 30
    end

    if self:isSetStatus(STATUS_IMMUNE_MAG_DAMAGE) then     -- 如意圈
        weight = 40
    end

    if self:isSetStatus(STATUS_LOYALTY) then               -- 游说之舌
        weight = 60
    end

    if self:isSetStatus(STATUS_POISON) then                -- 中毒
        weight = 70
    end

    return weight
end

-- 物理攻击和力破千钧权重
function FightObj:getPhyAtacctWeight()
    local weight = 60

    if self:isSetStatus(STATUS_FROZEN) then                -- 冰冻
        weight = 10
    end

    if self:isSetStatus(STATUS_PASSIVE_ATTACK) then        -- 乾坤罩
        weight = 20
    end

    if self:isSetStatus(STATUS_SLEEP) then                 -- 昏睡
        weight = 30
    end

    if self:isSetStatus(STATUS_IMMUNE_PHY_DAMAGE) then     -- 神龙罩
        weight = 40
    end

    if self:isSetStatus(STATUS_DODGE_UP) then              -- 躲闪
        weight = 50
    end

    if self:isSetStatus(STATUS_LOYALTY) then               -- 游说之舌
        weight = 70
    end

    if self:isSetStatus(STATUS_POISON) then                -- 中毒
        weight = 80
    end

    return weight
end

-- 是否是障碍状态
function FightObj:isBalkStatus()
    local isBaklStatus = false

    if self:isSetStatus(STATUS_POISON) then                -- 中毒
        isBaklStatus = true
    elseif self:isSetStatus(STATUS_SLEEP) then             -- 昏睡
        isBaklStatus = true
    elseif self:isSetStatus(STATUS_FORGOTTEN) then         -- 遗忘
        isBaklStatus = true
    elseif self:isSetStatus(STATUS_FROZEN) then            -- 冰冻
        isBaklStatus = true
    elseif self:isSetStatus(STATUS_CONFUSION) then         -- 混乱
        isBaklStatus = true
    end

    return isBaklStatus
end

-- 是否有me辅助技能辅助状态
function FightObj:isHaveAuxiliaryStatus()
    local polarStatus = Polar_Status[tonumber(Me:queryBasic("polar"))]

    if self:isSetStatus(polarStatus) then
        return true
    end

    return false
end

-- 是否是有五色光环状态
function FightObj:isPassiveMagAttack()
    if self:isSetStatus(STATUS_PASSIVE_MAG_ATTACK) then    -- 无色光环
       return true
    end

    return false
end

-- 是否有使用天生技能状态
function FightObj:isRawStatus(skillNo)
   local status = Raw_Status[SkillMgr:getSkillName(skillNo)]

    if status and self:isSetStatus(status) then
        return true
    end

    return false
end

-- 是否在初始位置
function FightObj:isInitialPos()
    local initX, initY = self:getRawPos()
    return initX == math.floor(self.curX + 0.5) and initY == math.floor(self.curY + 0.5)
end

-- 显示动作
function FightObj:showAct(toPos, faAct)
    self.isActionEnd = false
    self.isArrivedEndPos = false
    self:setFinished(false)
    self:setAct(faAct)

    EventDispatcher:dispatchEvent(EVENT.SET_FLYWORDS_OR_ACT, {obj = self,
        actionName = FightCmdRecordMgr:getNotFlyWorldsAct(faAct), type = "setAct", para = faAct})

    if faAct == Const.FA_ACTION_PHYSICAL_ATTACK then
        self:setOffsetLookAt(toPos, Const.SA_ATTACK)
    elseif faAct == Const.FA_ACTION_CAST_MAGIC then
        self:setDir(self:getRawDir())
    elseif faAct == Const.FA_DEFENSE_START and not self:isFrozen() then
        self:setDir(self:getRawDir())
        self:setMoveLine(FightPosMgr.DEFENSE_BACK_DIS)
        self:addMagicOnWaist(ResMgr.magic.parry_effect, false, nil, 0, {blendMode='add'})
    elseif faAct == Const.FA_PARRY_START and not self:isFrozen() then
        self:setDir(self:getRawDir())
        self:setMoveLine(FightPosMgr.PARRY_BACK_DIS)
        self:addMagicOnWaist(ResMgr.magic.parry_effect, false, nil, 0, {blendMode='add'})
    elseif faAct == Const.FA_DIE_NOW or faAct == Const.FA_DIE then
        self:setDir(self:getRawDir())
    elseif faAct == Const.FA_DODGE_START then
        self:setDir(self:getRawDir())
    elseif faAct == Const.FA_GO_BACK then
        self:rotateDir()
    elseif faAct == Const.FA_GO_TO_PROTECT then
        self:setLookAt(toPos, Const.SA_STAND)
    elseif faAct == Const.FA_ACTION_FLEE then
        -- 设置为初始方向的反方向
        self:setDir((self:getRawDir() + 4) % 8)
    elseif faAct == Const.FA_ACTION_REVIVE then
        -- 重生
        self:flyImg(FightMgr:getWordsImgFile(CHS[3000029]))
    end
end

-- 获取初始朝向
function FightObj:getRawDir()
    return 1
end

function FightObj:setDir(dir)
    if dir % 2 == 0 then
        dir = dir + 1
    end

    Char.setDir(self, dir)
end

function FightObj:getIcon(excludeRideIcon, excludeShowChild, excludeColorIcon)
    local icon
    repeat
        if self:queryBasicInt('special_icon') ~= 0  then
            icon = self:queryBasicInt('special_icon')
            break
        end

        if self:queryBasicInt("suit_icon") ~= 0 then
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

function FightObj:getWeaponIcon()
    -- 更换形象 不需要武器
    if self:queryBasicInt('special_icon') ~= 0 then
        return 0
    end

    local weaponIcon = self:queryBasicInt('weapon_icon')
    return weaponIcon
end

function FightObj:getRideIcon()
    -- 目前战斗中不需要显示坐骑形象
    return 0
end

function FightObj:setOffsetLookAt(toPos, saAct)
    local xTo, yTo = FightPosMgr:getPos(toPos)
    local dir = gf:defineDir(cc.p(self.curX, self.curY), cc.p(xTo, yTo), self:getIcon())
    self:setDir(dir)
end

-- 设置法术攻击时的方向
function FightObj:setCastDir(toPos)
    if not (self.charAction and self.charAction:haveAct(Const.SA_CAST)) then
        self:setOffsetLookAt(toPos, Const.SA_ATTACK)
        return
    end

    self:setDir(self:getRawDir())
end

-- 设置朝向
function FightObj:setLookAt(toPos, saAct)
    if self.fightPos == toPos then
        -- 目标位置为自己
        if self.faAct == Const.FA_ACTION_CAST_MAGIC or
            self.faAct == Const.FA_ACTION_CAST_MAGIC_END then
            self:setDir(self:getRawDir())
            return
        end
    end

    local xFrom, yFrom = self:getRawPos()
    local xTo, yTo = FightPosMgr:getPos(toPos)
    local dir = gf:defineDir(cc.p(xFrom, yFrom), cc.p(xTo, yTo), self:getIcon())
    self:setDir(dir)
end

-- 数据变化了，需要进行一些更新
-- 战斗中不需要更新方向
function FightObj:onAbsorbBasicFields()
    if self.charAction then
        if self.charAction.icon ~= self:getIcon() then
            self.actChanged = true
            EventDispatcher:dispatchEvent(EVENT.FIGHT_OBJ_ICON_CHANGED, self:getId())
        end

        if FightMgr.glossObjsInfo[self:getId()] then
            self.charAction.orgIcon = 0
            self.charAction:setIcon(FightMgr.glossObjsInfo[self:getId()].icon, true)
            self.charAction:setWeapon(0, true)
            self.charAction:setBodyPartIndex(FightMgr.glossObjsInfo[self:getId()].part_index, true)
            self.charAction:setBodyColorIndex(FightMgr.glossObjsInfo[self:getId()].part_color_index, true)
        else
            self.charAction.orgIcon = self:getOrgIcon()
            self.charAction:setIcon(self:getIcon(), true)
            self.charAction:setWeapon(self:getWeaponIcon(), true)
            self.charAction:setBodyPartIndex(self:getPartIndex(), true)
            self.charAction:setBodyColorIndex(self:getPartColorIndex(), true)
        end

        if self.charAction:isDirtyUpdate() then
        self.charAction:updateNow()
    end
    end

    -- 更新名字
    self:updateName()

    -- 更新血条
    self:updateLifeProgress()
    self:updateManaProgress()
    self:updateAngerProgress()
    self:updateJTStatus()
end

function FightObj:absorbComFields(tbl)
    Char.absorbComFields(self, tbl)

    -- 因为逻辑一致，直接调用
    self:onAbsorbBasicFields()
end

-- 设置为相反的方向
function FightObj:rotateDir()
    local dirdir = (self.dir + 4) % 8
    Log:D("FightObj:rotateDir()"..dirdir)
    self:setDir(dirdir)----(self.dir + 4) % 8)
end

-- 恢复到创建时的状态
function FightObj:recover()
    if self:isSetStatus(STATUS_FROZEN) and self.faAct ~= Const.FA_ACTION_FLEE then
        -- 冰冻时不能 recover（逃跑除外）
        return
    end

    if self.faAct == Const.FA_DIED then
        -- 人物死亡了，不能恢复
        return
    end

    self.desX, self.desY = self:getRawPos()
    self:setAct(Const.FA_STAND)
    self:setDir(self:getRawDir())
end

-- 设置是否正在等待输入
function FightObj:setWaiting(flag)
    self.isWaiting = flag

    local type = self:queryBasicInt("type")

    -- 如果是玩家
    if type == 1 then
        if not flag then
            self:removeReadyToFightEffect()
        else
            self:addReadyToFightEffect()
        end
    end
end

-- 获取对应的宠物位置
function FightObj:getPetPos()
    local numPerline = FightPosMgr.OBJ_NUM / 4
    if self.fightPos < numPerline then
        -- 第一排，对应的宠物在第二排
        return self.fightPos + numPerline
    elseif self.fightPos >= numPerline * 3 then
        -- 第四排，对应的宠物在第三排
        return self.fightPos - numPerline
    end

    return -1
end

function FightObj:updateAppearance(data)
    self:absorbBasicFields(data)

    self.desX, self.desY = self:getRawPos()
end

-- 点击战斗对象
function FightObj:onClickChar()
    Log:D('onClickChar: ' .. self:queryBasic('name'))
end

-- 长按战斗对象回调
function FightObj:objLongPress()
    self.action = nil

    if not BattleSimulatorMgr:isRunning() then
        local dlg = DlgMgr:openDlg("CombatStatusDlg")
        local rect = dlg:getBoundingBoxInWorldSpace(self.topLayer:getChildByName(ResMgr.ui.fightClick))
        dlg:queryInfo(self, rect)
    end
end

-- 绑定事件
function FightObj:bindEvent()
    -- 绑定角色点击事件
--[[  WDSY-22519，角色形象不再绑定相关事件，事件由 fightClick图片资源绑定
    if self.charAction then
        local this = self
        self.action = nil
        local function onTouchBegan(touch, event)
            if event:getEventCode() == cc.EventCode.BEGAN then
                if self.charAction:containsTouchPos(touch) and self.visible then
                    local callFunc = cc.CallFunc:create(function() self:objLongPress(touch) end)
                    self.action = cc.Sequence:create(cc.DelayTime:create(GameMgr:getLongPressTime()),callFunc)
                    self.charAction:runAction(self.action)
                    return true
                end
                return false
            elseif event:getEventCode() == cc.EventCode.ENDED then
                if self.action then

                end
                self.charAction:stopAction(self.action)
                self.action = nil
                return false
            end
        end

        gf:bindTouchListener(self.charAction, onTouchBegan, cc.Handler.EVENT_TOUCH_ENDED)
    end
    --]]
end

-- 选择对象
function FightObj:onSelectChar()
    if Me:queryBasicInt('c_enable_input') == 0 then
        return
    end

    if not self.selectImg or not self.selectImg:isVisible() then return end

    local attackId = Me:queryBasicInt('c_attacking_id')

    if Me.op == ME_OP.FIGHT_ATTACK then
        -- 物理攻击
        if attackId == self:getId() then
            -- 不能自己攻击自己
            return
        end

        gf:sendFightCmd(attackId, self:getId(), FIGHT_ACTION.PHYSICAL_ATTACK, FIGHT_ACTION.PHYSICAL_ATTACK)
    elseif Me.op == ME_OP.FIGHT_CATCH then
        -- 捕捉
        if not self:canProcessCatch() then
            gf:ShowSmallTips(CHS[3000003])
            return
        end

        gf:sendFightCmd(attackId, self:getId(), FIGHT_ACTION.CATCH_PET, 0)
    elseif Me.op == ME_OP.FIGHT_SKILL then
        -- 法术攻击
        local skillNo = Me:queryBasicInt('sel_skill_no')
        local skill = SkillMgr:getSkill(attackId, skillNo)
        if not BattleSimulatorMgr:isRunning() or BattleSimulatorMgr:getCurCombatData().isCheckSkill then
            if not skill or not self:canProcessSkill(skill) then
                -- 不能使用技能
                gf:ShowSmallTips(CHS[3000002])
                return
            end
        end

        -- 颠倒乾坤
        if SkillMgr:getSkillName(skillNo) == CHS[3001942] and self:getType() == "FightFriend" then
            DlgMgr:closeDlg("FightTargetChoseDlg")
            DlgMgr:showDlg("FightPetSkillDlg", true)
            gf:CmdToServer("CMD_VIEW_DDQK_ATTRIB", {id = self:getId()})
            return
        end

        -- 嘲讽（不能对处于障碍状态的目标使用嘲讽）
        if SkillMgr:getSkillName(skillNo) == CHS[3001946] and self:isBalkStatus() then
            gf:ShowSmallTips(CHS[7003003])
            return
        end

        if attackId == Me:getId() then
            FightMgr:setFastSkill(skillNo)
        else
            FightMgr:setFastSkill(skillNo, true)
        end

        FightMgr.useFastSkill = false

        local fightAction = FIGHT_ACTION.CAST_MAGIC
        if SkillMgr:isArtifactSpSkillByNo(skillNo) then
            -- 施放法宝特殊技能action
            fightAction = FIGHT_ACTION.ACTION_USE_ARTIFACT_EXTRA_SKILL
        end

        gf:sendFightCmd(attackId, self:getId(), fightAction, skillNo)
    elseif Me.op == ME_OP.FIGHTING_PROPERTY_ME then
        -- 对己方人物使用药品
        local medicinePos = Me:queryBasicInt("sel_medicine_pos")

        -- 进行判断是否肯以对对象使用药品
        if not medicinePos then
            -- 道具不存在
            gf:ShowSmallTips(CHS[5000057])
            return
        end

        if not self:canUseMedicine(medicinePos) then
            gf:ShowSmallTips(CHS[3004400])
            return
        end

        gf:sendFightCmd(attackId, self:getId(), FIGHT_ACTION.APPLY_ITEM, medicinePos)
    elseif Me.op == ME_OP.FIGHTING_PROPERTY_YOU then
        -- todo
        return
    else
    end

    FightMgr:changeMeActionFinished()
end

-- 是否可捕捉
function FightObj:canProcessCatch()
    return false
end

-- 是否能施法
function FightObj:canProcessSkill(skill)
    return false
end

function FightObj:update()
    if not self.isCreated then
        return
    end

    -- 执行对应的动作
    local doActFunc = self[ACT_FUN_MAP[self.faAct]]
    if doActFunc then
        doActFunc(self)
    end

    Char.update(self)
end

-- 开始新的回合
function FightObj:onNewRound()
end

-- 显示血条变化数值
function FightObj:showLifeDeltaNumber(lifeDelta, numberGroup)
    local x, y = 0, 100
    if self.charAction then
        x, y = self.charAction:getHeadOffset()
    end

    y = y + FLY_NUM_IMG_INTERVAL
    local curTime = gfGetTickCount()
    if self.lastFlyTime and curTime - self.lastFlyTime < 100 then
        y = y + FLY_NUM_IMG_INTERVAL
    end

    self.lastFlyTime = curTime

    local group = 'red_s'
    if 1 == numberGroup then
        group = 'blue_s'
    end

    local numImg = NumImg.new(group, lifeDelta, true)
    numImg:setPosition(x, y + LIFE_OFFSET_Y)
    self:addToTopLayer(numImg)

    numImg:startMove(1.0, cc.p(x, y + LIFE_OFFSET_Y + 80))
end

function FightObj:getRawPos()
    return FightPosMgr:getPos(self.fightPos)
end

-- 移到指定位置（战斗中不需要考虑障碍信息）
function FightObj:moveToPoint(rawX, rawY, desX, desY, duration)
    if not self.isCreated then
        return
    end

    local rawDist = gf:distance(rawX, rawY, desX, desY)
    local moveSpeed = 1.1
    local time = rawDist / moveSpeed
    if duration then
        -- 指定了移动的持续时间，使用该时间
        time = duration
    else
        if time <= 0 then
            return true
        end

        if MIN_MOVE_TIME > time then
            time = MIN_MOVE_TIME
        end
    end

    -- 如果在战斗中则需要除以战斗加速倍数
    time = FightMgr:divideSpeedFactorIfInCombat(time)
    -- 战斗加速，通过 设置 cc.Director:getInstance():getScheduler():setTimeScale()来实现
    local timeScale = cc.Director:getInstance():getScheduler():getTimeScale()
    time = time / timeScale

    local dt = gfGetTickCount() - self.startTime
    local dx = (desX - rawX) * dt / time
    local dy = (desY - rawY) * dt / time

    self:setPos(rawX + dx, rawY + dy)

    if desX >= rawX and desX - self.curX < 0.0001 or
        rawX > desX and self.curX - desX <= 0.0001 then
        return true
    end

    return false
end

-- 设置动作
function FightObj:setAct(act)
    Char.setAct(self, act)
    self.startTime = gfGetTickCount()
end

-- 角色动作执行完成的回调
function FightObj:onActionEnd()
    self.isActionEnd = true
    if self.faAct == Const.FA_DEFENSE_START or self.faAct == Const.FA_DEFENSE_END
        or self.faAct == Const.FA_PARRY_START or self.faAct == Const.FA_PARRY_END then
        -- 防御/格挡动作播放完成
        if self.isArrivedEndPos then
            -- 已到指定位置，标记完成
            self:setFinished(true)
        end

        return
    end

    self:setFinished(true)
end

function FightObj:goAheadNow()
    self:setPos(self.desX, self.desY)
    self:setFinished(true)
end

function FightObj:goBackNow()
    local rawX, rawY = self:getRawPos()
    self:setPos(rawX, rawY)
    self:setFinished(true)
    self:setDir(self:getRawDir())
    self:setAct(Const.FA_STAND)
end

-- 站立
function FightObj:actStand()
end

-- 物理攻击
function FightObj:actAttack()
end

-- 施展魔法
function FightObj:actCast()
end

-- 施展魔法结束
function FightObj:actCastEnd()
end

-- 重生
function FightObj:actRevive()
end

-- 逃跑
function FightObj:actFlee()
    -- 只要一逃跑，就把人物假复活
    self:setBasic('c_seq_died', 0)
end

-- 前去攻击
function FightObj:actGoAhead()
    local rawX, rawY = self:getRawPos()
    if self:moveToPoint(rawX, rawY, self.desX, self.desY) then
        -- 到达目的地
        self:goAheadNow()
    end
end

-- 攻击返回
function FightObj:actGoBack()
    local rawX, rawY = self:getRawPos()
    if self:moveToPoint(self.desX, self.desY, rawX, rawY) then
        self:goBackNow()
    end
end

-- 正在死亡
function FightObj:actDieNow()
end

-- 已经死亡
function FightObj:actDied()
end

-- 反击
function FightObj:actCounterAttack()
    self:actAttack()
end

-- 攻击完成
function FightObj:actAttackFinish()
end

-- 前出保护
function FightObj:actGoToProtect()
    local rawX, rawY = self:getRawPos()
    if self:moveToPoint(rawX, rawY, self.desX, self.desY) then
        -- 到达目的地
        self:setPos(self.desX, self.desY)
        self:setFinished(true)
        self:setAct(Const.FA_STAND)
    end
end

-- 保护回来
function FightObj:actProtectBack()
    self:actGoBack()
end

-- 退出战斗
function FightObj:actQuitGame()
    local t = gfGetTickCount()
    local show = math.floor((t - self.startTime) / 200) % 2 == 0

    if self.middleLayer then
        self.middleLayer:setVisible(show)
    end

    local magicFinishFlag = self:queryBasic("magic_finish")
    if 0 ~= self:queryBasicInt('c_seq_died') and magicFinishFlag == "0" then
        -- 已死亡，需要等光效播放完成
        return
    end

    -- 未死亡的对象需要立即退出
    -- 已死亡的对象需要播放一段时间的闪烁效果后再退出
    if 0 == self:queryBasicInt('c_seq_died') or t - self.startTime > 800 then
        self:setFinished(true)
        self:cleanup()
        return
    end
end

-- 开始躲避动作(离开站立原点)
function FightObj:actDodgeStart()
    self:actGoAhead()
end

-- 结束躲避动作(回到站立原点)
function FightObj:actDodgeEnd()
    self:actGoBack()
end

-- 设置防御/格挡动作移动路线
function FightObj:setMoveLine(dis)
    self.moveLine = {
        startX = self.curX,
        startY = self.curY,
        endX = self.curX + dis,
        endY = self.curY - dis
    }
end

-- 格挡开始
function FightObj:actParryStart()
    if self:isFrozen() then
        -- 处理冰冻状态不能被物理攻击
        self:setFinished(true)
        return
    end

    local rawX, rawY = self.moveLine.startX, self.moveLine.startY
    local desX, desY = self.moveLine.endX, self.moveLine.endY
    if self:moveToPoint(rawX, rawY, desX, desY, FightMgr.PARRY_MOVE_BACK_DURATION) then
        -- 到达目的地
        self:setPos(desX, desY)
        self.isArrivedEndPos = true
        if self.isActionEnd then
            -- 动作也已播完，标记结束
            self:setFinished(true)
        end
    end
end

-- 格挡结束
function FightObj:actParryEnd()
    if self:isFrozen() then
        -- 处理冰冻状态不能被物理攻击
        self:setFinished(true)
        return
    end

    local rawX, rawY = self.moveLine.startX, self.moveLine.startY
    local desX, desY = self.moveLine.endX, self.moveLine.endY
    if self:moveToPoint(desX, desY, rawX, rawY, FightMgr.PARRY_MOVE_FRONT_DURATION) then
        -- 到达目的地
        self:setPos(rawX, rawY)
        self.isArrivedEndPos = true
        if self.isActionEnd then
            -- 动作也已播完，标记结束
            self:setFinished(true)
        end
    end
end

-- 防御开始
function FightObj:actDefenseStart()
    self:actParryStart()
end

-- 防御结束
function FightObj:actDefenseEnd()
    self:actParryEnd()
end

-- 是否可以使用药品
function FightObj:canUseMedicine(mediPos)
    return false
end

-- 是否是战斗对象
function FightObj:isFightObj()
    return true
end

-- 获取相应的阴影，根据套装属性获取光效效果
function FightObj:getShadow()
    local suit_light_effect = self:queryInt("suit_light_effect")

    if nil == suit_light_effect or 0 == suit_light_effect or FightMgr.glossObjsInfo[self:getId()] then
        return self:getDefaultShadow()
    end

    return gf:createLoopMagic(suit_light_effect)
end

--[[
function FightObj:setChat(data)
    if not self.charAction then
        return
    end

    local headX, headY = self.charAction:getHeadOffset()

    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(19)
    textCtrl:setString(data.msg)
    if  1 == self.fightPos + 1
        or 5 == self.fightPos + 1 then
        textCtrl:setContentSize(114, 0)
    else
        textCtrl:setContentSize(152, 0)
    end

    textCtrl:updateNow()

    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition(2, textH + 2)

    local bg = cc.LayerColor:create(cc.c4b(0, 0, 0, 128))
    bg:ignoreAnchorPointForPosition(false)
    bg:setContentSize(textW + 4, textH + 4)
    bg:setAnchorPoint(0.5, 0)
    bg:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    bg:setPosition(headX, headY + 40)

    -- 显示一定时间后删除
    local action = cc.Sequence:create(
        cc.DelayTime:create(5),
        cc.RemoveSelf:create()
    )

    self:addToTopLayer(bg)
    bg:runAction(action)
end
--]]

function FightObj:updateAfterLoadAction()
    Char.updateAfterLoadAction(self)

    if self.charAction and self.selectImg then
        local x, y = self.charAction:getWaistOffset()
        self.selectImg:setPosition(x, y)
        self.selectZHSkillImg:setPosition(x, y)
        self.touchImg:setPosition(x, y)
    end

    -- 延时一帧，等待模型显示出来
    performWithDelay(self.charAction, function()
        -- 冰冻，需要暂停动作
        if self:isFrozen() and self.charAction then
            self.charAction:pausePlay()
        end

        if WatchRecordMgr:getCurReocrdCombatId() and WatchRecordMgr:isPause() then
            -- 如果正常播放录像，并且处于暂停中
            self.charAction:pausePlay()
        end
    end, 0)
end

return FightObj
