-- FightMgr.lua
-- created by cheny Oct/25/2014
-- 战斗管理器

local Bitset = require('core/Bitset')
local FightOpponent = require('obj/fight/FightOpponent')
local FightPet = require('obj/fight/FightPet')
local FightFriend = require('obj/fight/FightFriend')
local FightComObj = require('obj/fight/FightComObj')
local json = require("json")

FightMgr = Singleton()

local FLAG_NORMAL_ACTION = 0
local FLAG_SELECT_MENU   = 1

local MIN_LEVEL_CAN_SPEED = 10 -- 等级不低于 10 级才允许加速
local FIGHT_CHAT_SHOW_TIME = 5 -- 战斗中头顶信息的显示时间

-- 伤害类型
local DAMAGE_TYPE_DAMAGE_SEL        = 4             -- 反震伤害
local DAMAGE_TYPE_JOINT_ATTACK      = 7             -- 合击伤害
local DAMAGE_TYPE_JOINT_ATTACK_EX   = 15            -- 合击伤害
local DAMAGE_TYPE_PENETRATE         = 14            -- 破防伤害

-- 飘字效果标记
local FLY_FLAG_BU_ZHUO   = 0    -- 捕捉
local FLY_FLAG_BI_SHA    = -1   -- 必杀
local FLY_FLAG_HE_JI     = -2   -- 合击
local FLY_FLAG_LIAN_JI   = -3   -- 连击
local FLY_FLAG_SHAN_DUO  = -4   -- 躲闪
local FLY_FLAG_FAN_ZHEN  = -5   -- 反震
local FLY_FLAG_FAN_JI    = -6   -- 反击
local FLY_FLAG_FANG_YU   = -7   -- 防御
local FLY_FLAG_ZHAO_HUAN = -8   -- 召唤
local FLY_FLAG_TAO_PAO   = -9   -- 逃跑
local FLY_FLAG_DAO_JU    = -10  -- 道具
local FLY_FLAG_LI_PO     = -11  -- 力破千均
local FLY_FLAG_PENETRATE = -12  -- 破防

local SOUND_TYPE_ATTACK = 0        --  物理攻击
local SOUND_TYPE_CAST = 1          --  使用技能, fight_used_skill_no
local SOUND_TYPE_ENRICH_BLOOD = 2  --  补血
local SOUND_TYPE_CATCH = 3         --  捕捉
local SOUND_TYPE_FLEE = 4          --  逃走
local SOUND_TYPE_DIE = 5           --  死亡
local SOUND_TYPE_FIGHT_BACK = 6    --  反击
local SOUND_TYPE_ANTI_SHAKE = 7    --  反震
local SOUND_TYPE_ALL_OUT_HIT = 8   --  致命一击
local SOUND_TYPE_BREAK_INTO = 9    --  中途进场
local SOUND_TYPE_FIGHT_MISS = 10   --  攻击失败

-- 攻击类型
local FAT_NULL           = 0;
local FAT_LIPO           = 1;    -- 力破
local FAT_DOUBLE_HIT     = 2;    -- 连击

-- 角色防御/格挡时移动的持续时间
-- 注意：修改此时间需要一并修改动作播放时间生成工具：tools/node/GenPlayTime
FightMgr.PARRY_MOVE_BACK_DURATION = 100
FightMgr.PARRY_MOVE_FRONT_DURATION = 30

-- 飘字效果标记对应的名字
local FLY_NAMES = {
    CHS[3000005], -- 捕捉
    CHS[3000006], -- 必杀
    CHS[3000007], -- 合击
    CHS[3000008], -- 连击
    CHS[3000009], -- 躲闪
    CHS[3000010], -- 反震
    CHS[3000011], -- 反击
    CHS[3000012], -- 防御
    CHS[3000013], -- 召唤
    CHS[3000014], -- 逃跑
    CHS[3000015], -- 道具
    CHS[3000016], -- 力破千钧
    CHS[2000212], -- 破防
}

-- 战斗的中指引id
local FIGHT_GUIDE_ID =
    {
        [17] = CHS[3003999],
        [18] = CHS[3004000],
        [19] = CHS[3004001],
        [20] = CHS[3004002],
        [21] = CHS[3004003],
        [22] = CHS[3004004],
        [43] = CHS[3004005],
        [42] = CHS[3004006],
        [10001] = CHS[3004007],
        [10002] = CHS[3004008],
        [10003] = CHS[3004009],
        [34] = CHS[3004010],
        [51] = CHS[3004010],
    }

FightMgr.fastSkill = {["Me"] = {skillNo = -1, isQinMiWuJianCopySkill = false}, ["Pet"] = -1}

-- 战斗中假的属性
FightMgr.glossObjsInfo = {}

-- 初始化最基本的信息
function FightMgr:init()
    self.objs = {}

    -- 战斗加速的倍数
    self.speedFactor = 1

    -- 添加未初始化的敌方对象(下标从0开始)
    for i = 0, FightPosMgr.NUM_PER_LINE * 2 - 1 do
        self.objs[i] = FightOpponent.new(i)
    end

    -- 添加未初始化的宠物对象
    for i = FightPosMgr.NUM_PER_LINE * 2, FightPosMgr.NUM_PER_LINE * 3 - 1 do
        self.objs[i] = FightPet.new(i)
    end

    -- 添加未初始化的己方对象
    for i = FightPosMgr.NUM_PER_LINE * 3, FightPosMgr.NUM_PER_LINE * 4 - 1 do
        self.objs[i] = FightFriend.new(i)
    end

    self.objs[FightComObj.fightPos] = FightComObj
    FightComObj:create()
    self.bSelectMenu = FLAG_NORMAL_ACTION
    self.wordsImgCfg = require(ResMgr:getCfgPath('WordsImg.lua'))["fight"]

    -- 背景地图
    FightMgr:createBgImage()

    --  捕获update消息切换自动战斗
    MessageMgr:hook("MSG_UPDATE", self, "FightMgr")

    -- 初始化标志为
    self.isInClear = nil

    -- 用于标记是否预加载过了
    self.preloadFlag = {}
end

function FightMgr:setFastSkill(skill, isPet)
    if not skill or skill == "" then
        skill = -1
    end

    if not isPet then
        FightMgr.fastSkill.Me.skillNo = skill
        if SkillMgr:isQinMiWuJianCopySkill(SkillMgr:getSkillName(skill), Me:getId()) then
            -- 记录的技能如果是亲密无间复制的宠物技能，需要标记一下
            FightMgr.fastSkill.Me.isQinMiWuJianCopySkill = true
        else
            FightMgr.fastSkill.Me.isQinMiWuJianCopySkill = false
        end
    else
        FightMgr.fastSkill.Pet = skill
    end
end

-- 战斗背景
function FightMgr:initBgMap(mapId, x, y)
    local MapClass = require "obj/Map"
    local map = MapClass.new(mapId, true)
    local mapContentSize = map:getContentSize()
    map:setCurMapPos(x * Const.RAW_PANE_WIDTH, mapContentSize.height - y * Const.RAW_PANE_HEIGHT, true)
    map:loadBlocksByPos(true, x, y)

    return map
end

-- 创建
function FightMgr:create(mode)
    -- me 不能移动
    Me:setAct(Const.FA_STAND)
    Me:setCanMove(false)

    -- 不可输入命令
    Me:setBasic('c_enable_input', 0)

    -- me、pet 已经完成命令的输入
    Me:setBasic('c_me_finished_cmd', 1)
    Me:setBasic('c_pet_finished_cmd', 1)

    Me:setTalkId(Me:getId())

    Me.op = ME_OP.NULL

    -- 隐藏场景中的角色
    CharMgr:setVisible(false)

    -- 隐藏地图NPC
    MapMgr:setMapNpcVisible(false)

    -- 隐藏场景中地板上的物品
    DroppedItemMgr:setVisible(false)

    PuttingItemMgr:setVisible(false)

    -- 隐藏场景光效
    PlayActionsMgr:setVisible(false)

    -- 隐藏地表光效
    gf:getMapEffectLayer():setVisible(false)

    -- 隐藏地表物件
    -- WDSY-22707 中注释，居所地表物件要显示在地图上
    -- gf:getMapObjLayer():setVisible(false)

    -- 隐藏天气
    gf:getWeatherLayer():setVisible(false)

    -- 隐藏天气光效
    gf:getWeatherAnimLayer():setVisible(false)

    -- 隐藏居所家具及农作物
    HomeMgr:setFurnitureAndCropsVisible(false)

    if COMBAT_MODE.COMABT_MODE_ARENA == mode or COMBAT_MODE.COMBAT_MODE_LIFEDEATH == mode then
        -- 获取指定坐标的地图背景
        FightMgr:addFightMapBg(5000, 184, 83) -- 天墉城
    elseif COMBAT_MODE.COMBAT_MODE_LCHJ == mode then
        -- 灵宠幻境
        FightMgr:addFightMapBg(8100, 48, 46)  -- 轩辕坟一层
    elseif COMBAT_MODE.COMBAT_MODE_QISHA == mode then
        -- 七杀试练
        FightMgr:addFightMapBg(25002, 29, 38) -- 昆仑云海
        end
    self.combatMode = mode

    -- 初始化战斗位置
    FightPosMgr:init()

    -- 清空所有宠物的状态
    PetMgr:cleanAllPetStatus()

    -- 战斗中需要关闭的界面
    local dlgs = DlgMgr:fightNeedCloseDlg()

    -- 隐藏已打开的界面
    DlgMgr:showAllOpenedDlg(false, {["CommunityDlg"] = 1, ["ScreenRecordingDlg"] = 1, ["HeadTipsDlg"] = 1})

    -- 如果当前有指引关闭指引
    if GuideMgr:isRunning() then
        GuideMgr:closeCurrentGuide()
    end

    -- 打开战斗相关界面
    self:openFightDlgs()

    -- 战斗中聊天和 好友不隐藏
    DlgMgr:setChatDlgZoderAndVisible(true, 0)

    self.isCreated = true

    -- 战斗加速的倍数
    self.speedFactor = 1

    -- 添加战斗背景地图
    FightMgr:addFightBg()

    -- 播放战斗背景音乐
    self.lastMusicInfo = { MapMgr:getCurrentMapName(), SoundMgr:getMusicPostion() }
    SoundMgr:playFightingBackupMusic()

    -- 添加冻屏效果
    gf:frozenScreen(300, nil, 3000)

    -- 战斗需要重新打开的界面
    DlgMgr:fightNeedReopenDlg(dlgs)

    EventDispatcher:dispatchEvent(EVENT.ENTER_COMBAT)
end

-- 退出游戏的时候清理的战斗数据
function FightMgr:clearWhenEndGame()
    if Me:isInCombat() then
        GFightMgr:OnQuitCombat()
        GameMgr:onEndCombat()
    end

    if Me:isLookOn() then
         Me:setLookFightState(false)
    end

    if self.bgImage then
        self.bgImage:release()
        self.bgImage = nil
    end

    if self.bgImage2 then
        self.bgImage2:release()
        self.bgImage2 = nil
    end

    for i = 0, FightPosMgr.OBJ_NUM do
        if self.objs[i] then
            self.objs[i]:destruct()
        end
    end

    self.objs = {}
    FightMgr.glossObjsInfo = {}
end

function FightMgr:createBgImage()
    -- 背景地图
    if not self.bgImage then
        self.bgImage = ccui.ImageView:create(ResMgr.ui.fight_bg_img)
        self.bgImage:setAnchorPoint(0.5, 0.5)
        self.bgImage:retain()

        -- 背景黑色进行缩放
        local destScale = math.max((Const.WINSIZE.width + 40) / self.bgImage:getContentSize().width, (Const.WINSIZE.height + 40) / self.bgImage:getContentSize().height)

        self.bgImage:setScale(destScale)
    end

    if not self.bgImage2 then
        self.bgImage2 = ccui.ImageView:create(ResMgr.ui.fight_bg_img_center)
        self.bgImage2:setAnchorPoint(0.5, 0.5)
        self.bgImage2:retain()
    end
end

-- 添加战斗背景地图，直接加在地图层上
function FightMgr:addFightBg()
    self.bgImage:setPosition(Const.WINSIZE.width / 2 - gf:getMapLayer():getPositionX(),
        Const.WINSIZE.height / 2 - gf:getMapLayer():getPositionY())

    self.bgImage2:setPosition(Const.WINSIZE.width / 2 - gf:getMapLayer():getPositionX(),
        Const.WINSIZE.height / 2 - gf:getMapLayer():getPositionY() - 74)

    if not self.bgImage:getParent() then
    gf:getMapLayer():addChild(self.bgImage)
    end

    if not self.bgImage2:getParent() then
    gf:getMapLayer():addChild(self.bgImage2)
    end
end

function FightMgr:updateFightBg()
    if self.bgImage:getParent() then
        self.bgImage:setPosition(Const.WINSIZE.width / 2 - gf:getMapLayer():getPositionX(),
            Const.WINSIZE.height / 2 - gf:getMapLayer():getPositionY())
    end

    if self.bgImage2:getParent() then
        self.bgImage2:setPosition(Const.WINSIZE.width / 2 - gf:getMapLayer():getPositionX(),
            Const.WINSIZE.height / 2 - gf:getMapLayer():getPositionY() - 74)
    end
end

-- 添加战斗背景地图，直接加在地图层上
function FightMgr:addFightBgOnlyBlack()
    self.bgImage:setPosition(Const.WINSIZE.width / 2 - gf:getMapLayer():getPositionX(),
    Const.WINSIZE.height / 2 - gf:getMapLayer():getPositionY())

    if not self.bgImage:getParent() then
        gf:getMapLayer():addChild(self.bgImage)
    end
end

function FightMgr:removeFightBg()
    gf:getMapLayer():removeChild(self.bgImage)
    gf:getMapLayer():removeChild(self.bgImage2)
end

-- 登录时清除的信息
function FightMgr:cleanupDataLogin()
    self.autoTalk = nil
    self.notCatchCondition = false
end

-- 清空信息
function FightMgr:cleanup()
    self.isCreated = false
    self.notCatchCondition = false

    FightMgr.zuheSelectInfo = nil

    -- 指令输入完成，清空已有的动作
    self:CleanAllAction()

    -- 重置一些标记，由于顶号或切后台的原因，m_bCombatMsg可能会因为没有执行或缺少MSG_C_END_COMBAT导致没有重置
    -- GFightMgr:OnMsg_C_CombatEnd会重置m_bCombatMsg及GFightMgr:bFlag = false
    -- 由于战斗外GFightMgr:bFlag = true，需要调用GFightMgr:Update来执行GSeqMgr:cleanup及置GFightMgr:bFlag = true
    -- 由于GFightMgr:Update重置上述过程时会触发CmdCEndAnimate，需要丢弃本次调用，避免导致异常
    GFightMgr:OnMsg_C_CombatEnd(0x0DFD, gf:ConvertToUtilMapping(nil))

    self.ignoreCmdCEndAnimtate = true   -- 此处标记丢弃本次CmdCEndAnimate调用，因为GFightMgr:Update会导致底层触发CmdCEndAnimate
    GFightMgr:Update(0)                 -- 目的是重置GFightMgr:bFlag = true

    -- 有可能是顶号，故需要调此接口
    GFightMgr:OnQuitCombat()

    -- 移除战斗背景地图
    FightMgr:removeFightBg()

    -- 移除战斗指令资源
    FightCmdRecordMgr:clearFightCmdSprite()

    -- 移除战斗背景地图
    if self.fightBgMap then
        gf:getMapLayer():removeChild(self.fightBgMap)
        self.fightBgMap = nil

        -- 还原位置，避免地图闪烁
        local map = GameMgr.scene.map
        if map then
            local mapX, mapY = gf:convertToMapSpace(Me.curX, Me.curY)
            map:setCurMapPos(Me.curX, Me.curY)
            map:loadBlocksByPos(true, mapX, mapX)
        end

        -- MapMgr.defaultMapLayer:loadBlocksByPos(true, gf:convertToMapSpace(18, 56))
    end

    for i = 0, FightPosMgr.OBJ_NUM - 1 do
        self.objs[i]:cleanup()
    end

    FightMgr.glossObjsInfo = {}

    -- 战斗加速的倍数
    self.speedFactor = 1

    self.bSelectMenu = FLAG_NORMAL_ACTION

    -- 显示地表光效
    gf:getMapEffectLayer():setVisible(true)

    -- 显示地表物件
    -- gf:getMapObjLayer():setVisible(true)

    -- 显示天气
    gf:getWeatherLayer():setVisible(true)

    -- 显示天气光效
    gf:getWeatherAnimLayer():setVisible(true)

    -- 显示场景中地板上的物品
    DroppedItemMgr:setVisible(true)

    PuttingItemMgr:setVisible(true)

    PlayActionsMgr:setVisible(true)

    -- 显示场景中的角色
    CharMgr:setVisible(true)

    -- 隐藏地图NPC
    MapMgr:setMapNpcVisible(true)

    -- 显示居所家具及农作物
    HomeMgr:setFurnitureAndCropsVisible(true)

    -- 显示已打开的界面
    --[[ local npcDlgVisible = false
    if DlgMgr:isDlgOpened("NpcDlg") then
    -- 如果Npcdlg打开的话,让他保持原样即可
    npcDlgVisible = DlgMgr:getDlgByName("NpcDlg"):isVisible()
    end]]

    if not DlgMgr.dlgs["DramaDlg"] and not DlgMgr.dlgs["ArenaDlg"]  then
        DlgMgr:showAllOpenedDlg(true, {["CommunityDlg"] = 1, ["LoadingDlg"] = 1, ["HeadTipsDlg"] = 1})
    end

    if DlgMgr.dlgs["ArenaDlg"] then
        DlgMgr:closeDlgWhenNoramlDlgOpen("ArenaDlg")
    end

    --[[  if DlgMgr:isDlgOpened("NpcDlg") then
    -- 如果Npcdlg打开的话,让他保持原样即可
    DlgMgr:getDlgByName("NpcDlg"):setVisible(npcDlgVisible)
    end]]

    -- me 可以移动
    Me:setCanMove(true)

    Me.op = ME_OP.NULL

    -- 设置刚从战斗中出来，加载地图
    Me.isFightJustNow = true

    -- 继续播放背景音乐
    if self.lastMusicInfo and self.lastMusicInfo[1] == MapMgr:getCurrentMapName() then
        SoundMgr:playMusic(MapMgr:getCurrentMapName(), false, self.lastMusicInfo[2])
    else
        SoundMgr:playMusic(MapMgr:getCurrentMapName(), false)
    end
    self.lastMusicInfo = nil

    self.battleArrayInfo = nil

    -- 全屏技能光效
    self:clearFihgtFullScreenEffect()

    -- 清除全屏播放光效标志
    SkillEffectMgr:clearFullScreenEffect()
end

-- 设置是否显示选择图片
function FightMgr:showSelectImg(visible)
    for i = 0, FightPosMgr.OBJ_NUM - 1 do
        if self.objs[i].isCreated then
            self.objs[i]:showSelectImg(visible)
        end
    end
end

-- 设置是否显示选择图片 组合技能施法目标
-- isFriend true 显示友方，反之敌方
function FightMgr:showZHSelectImage(visible, isFriend)

    FightMgr.zuheSelectInfo = {visible = visible, isFriend = isFriend}

    if isFriend then
        for i = FightPosMgr.NUM_PER_LINE * 2, FightPosMgr.NUM_PER_LINE * 4 - 1 do
        if self.objs[i] and self.objs[i].isCreated then
            self.objs[i]:setZHSelectImageVisible(visible)
            self.objs[i].selectZHSkillImg:loadTexture(ResMgr.ui.fight_sel_img)
        end
    end
    else
        for i = 0, FightPosMgr.NUM_PER_LINE * 2 - 1 do
            if self.objs[i] and self.objs[i].isCreated then
                self.objs[i]:setZHSelectImageVisible(visible)
                self.objs[i].selectZHSkillImg:loadTexture(ResMgr.ui.fight_sel_img)
            end
        end
    end
end

-- 获取文字图片
function FightMgr:getWordsImgFile(name)
    local img = self.wordsImgCfg[name]
    if not img then
        Log:W('WordsImg.lua: Not found cfg for: ' .. name)
        return
    end

    return ResMgr:getWordsImgPath(img)
end

-- 获取加速的倍数
function FightMgr:getSpeedFactor()
    return self.speedFactor
end

-- 增加加速的倍数
function FightMgr:addSpeedFactor()
    if Me:queryBasicInt('level') < MIN_LEVEL_CAN_SPEED then
        -- 等级未达到要求,不允许加速
        gf:ShowSmallTips(CHS[3000004])
        return
    end

    -- 支持 1 倍加速（即原始速度）、2 倍速度和 3 倍速度
    self.speedFactor = self.speedFactor + 1
    if self.speedFactor > 3 then
        self.speedFactor = 1
    end
end

-- 如果在战斗中则除以加速倍数
function FightMgr:divideSpeedFactorIfInCombat(v)
    if GameMgr.inCombat and self.speedFactor > 1 then
        return v / self.speedFactor
    end

    return v
end

-- 更新
function FightMgr:update()
    if WatchRecordMgr:getCurReocrdCombatId() and WatchRecordMgr:isPause() then return end

    GFightMgr:Update(Me:queryBasicInt('c_enable_input'))

    if not self.isCreated then
        return
    end

    for _, obj in pairs(self.objs) do
        obj:update()
    end
end

-- 添加对象
function FightMgr:insertObj(data, isFriend)
    -- 设置初始方向
    local pos = data.pos
    if pos > 0 then
        if (isFriend and pos <= FightPosMgr.OBJ_NUM / 2) or
            (not isFriend and pos > FightPosMgr.OBJ_NUM / 2) then
            -- 在观战时，如果观战者观看的为非主动者，服务器发送的位置会相反
            pos = FightPosMgr.OBJ_NUM + 1 - pos
        end

        -- 客户端从 0 开始索引
        pos = pos - 1

        local obj = self:getNotCreateObj(pos)
        if obj then
            obj:create(data)
        else
            Log:W('FightMgr: Not create obj not found at pos: ' .. pos)
        end
    end
end

-- 添加队友
function FightMgr:insertFriend(data)
    self:insertObj(data, true)
end

-- 添加敌人
function FightMgr:insertOpponent(data)
    self:insertObj(data, false)
end

-- 获取指定位置中已创建好的对象
function FightMgr:getCreatedObj(pos)
    if not pos or pos < 0 or pos > FightPosMgr.OBJ_NUM then
        return
    end

    if not self.objs[pos].isCreated then
        return
    end

    return self.objs[pos]
end

-- 获取指定位置中未创建好的对象
function FightMgr:getNotCreateObj(pos)

    if not pos or pos < 0 or pos > FightPosMgr.OBJ_NUM then
        return
    end

    if self.objs[pos].isCreated then
        return
    end

    return self.objs[pos]
end

-- 吸收基本信息
function FightMgr:absorbBasicFields(data)
    local obj = self:getCreatedObj(data.pos)
    if not obj then
        return
    end

    -- 更新战斗对象信息
    obj:playOrStopEffectFoot(data)
    obj:playOrStopEffectWaist(data)
    obj:playOrStopEffectHead(data)

    obj:absorbBasicFields(data)

    if data['update_me_and_pet'] then
        local objId = obj:getId()
        if objId == Me:getId() then
            -- 因为在战斗中，需要刷新 UserDlg 里的玩家数值
            -- 所以不仅仅 战斗对象需要吸收数据
            -- 这边 Me 也需要吸收战斗中变化的相关数值
            Me:absorbBasicFields(data)
            DlgMgr:sendMsg('HeadDlg', 'updatePlayerInfo')
            DlgMgr:sendMsg('UserDlg', 'setMeInfo')
            DlgMgr:sendMsg('AutoFightSettingDlg', 'refreshManaImage')
            DlgMgr:sendMsg('PracticeDlg', 'refreshManaImage')
            return
        end

        local pet = PetMgr:getPetById(objId)
        if not pet and objId > 0 and HomeChildMgr:getFightKid() and objId == HomeChildMgr:getFightKid():getId() then
            pet = HomeChildMgr:getFightKid()
        end

        if pet then
            -- 因为在战斗中，需要刷新 PetAttribDlg 里的玩家数值
            -- 所以不仅仅 战斗对象需要吸收数据
            -- 这边 Pet 也需要吸收战斗中变化的相关数值
            pet:absorbBasicFields(data)
            if not DlgMgr:sendMsg("HeadDlg", "checkGrayPetHeadImgInCombat") then
                DlgMgr:sendMsg('HeadDlg', 'updatePetInfo')
                DlgMgr:sendMsg('PetAttribDlg', 'MSG_UPDATE_PETS')
                DlgMgr:sendMsg('AutoFightSettingDlg', 'refreshManaImage')
                DlgMgr:sendMsg('PracticeDlg', 'refreshManaImage')
            end

            DlgMgr:sendMsg('KidInfoDlg', 'updatePropsShow', pet)
        end
    end
end

-- 吸收战斗相关属性信息
function FightMgr:absorbComFields(data)
    local obj = self:getCreatedObj(data.pos)
    if not obj then
        return
    end

    if data['update_me_and_pet'] then
        local objId = obj:getId()
        if objId == Me:getId() then
            -- 因为在战斗中，需要刷新 UserDlg 里的玩家数值
            -- 所以不仅仅 战斗对象需要吸收数据
            -- 这边 Me 也需要吸收战斗中变化的相关数值
            Me:absorbComFields(data)
            DlgMgr:sendMsg('HeadDlg', 'updatePlayerInfo')
            DlgMgr:sendMsg('UserDlg', 'setMeInfo')
        end

        local pet = PetMgr:getPetById(objId)
        if not pet and objId > 0 and HomeChildMgr:getFightKid() and objId == HomeChildMgr:getFightKid():getId() then
            pet = HomeChildMgr:getFightKid()
        end

        if pet then
            -- 因为在战斗中，需要刷新 PetAttribDlg 里的玩家数值
            -- 所以不仅仅 战斗对象需要吸收数据
            -- 这边 Pet 也需要吸收战斗中变化的相关数值
            pet:absorbComFields(data)
            if not DlgMgr:sendMsg("HeadDlg", "checkGrayPetHeadImgInCombat") then
                DlgMgr:sendMsg('HeadDlg', 'updatePetInfo')
                DlgMgr:sendMsg('PetAttribDlg', 'MSG_UPDATE_PETS')
            end

            DlgMgr:sendMsg('KidInfoDlg', 'updatePropsShow', pet)
        end
    end

    -- 更新战斗对象信息
    obj:absorbComFields(data)
end

-- 添加对象
function FightMgr:addObj(data)
    local obj = self:getNotCreateObj(tonumber(data.pos))
    if not obj then
        return
    end

    obj:create(data)

    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if pet and obj:getId() == pet:getId() then
        -- 刷新设置自动战斗菜单的技能的显示隐藏
        -- 刷新宠物的自动战斗状态时，该接口已调过一次，但当时战斗对象 obj 可能还未创建，导致技能隐藏，此处再次调用
        DlgMgr:sendMsg("AutoFightSettingDlg", "refreshMenu")

        -- 战斗中召唤宠物，服务端不会发 NOTIFY_AUTO_FIGHT_SKILL 刷新自动战斗技能，客户端根据缓存自己刷新
        -- 由于可能是从未进行过自动战斗的宠物，所以要先调用 AutoFightMgr:setDefaultAction() 获取宠物的默认自动战斗技能
        AutoFightMgr:setDefaultAction()
        DlgMgr:sendMsg("AutoFightSettingDlg", "refreshAllData")
    end

    -- 处于输入命令状态时需要显示选择图片

    if Me:queryBasicInt("auto_fight") == 0  then
        obj:showSelectImg(Me:queryBasicInt('c_enable_input') > 0)
    end
end

-- 在 id 对象上播放光效  effect_no (Unit 中不关心光效是否播放完成)
-- 如果 skill_no 大于 0，则需要播放对应的飘字效果
function FightMgr:attachSkillLightEffect(data)

    -- 如果看录像，跳过，则不播放效果
    if WatchRecordMgr.skipMagic then return end

    data.id = tonumber(data.id)
    data.type = tonumber(data.type)
    data.effect_no = tonumber(data.effect_no)
    local obj = self:getObjectById(data.id)
    if not obj then
        return
    end

    -- 1116 效果与1117效果相同，但是一个为左边阵营，一个右边阵营，type也不一样，服务器不方便做，有客户端处理，任务 WDSY-25144
    if tonumber(data.effect_no) == ResMgr.magic.xian_skill_left then
        if FightMgr:getObjectPosById(data.id) <= FightPosMgr.OBJ_NUM * 0.5 then
            data.effect_no = ResMgr.magic.xian_skill_right
            data.type = EFFECT_TYPE.FRONT
        end
    end

    local flag = Bitset.new(data.type)


    -- 2016中秋活动，希望部分战斗中，不显示变身卡阵法光效，服务器不愿意改，还是下发了光效，客户端特殊处理....特殊处理....
    -- 当前阵法光效 编号为8001-8010
    if FightMgr.glossObjsInfo[data.id] and (data.effect_no >= 8001 and data.effect_no <= 8010) then
        return
    end

    if data.effect_no > 0 then
        local behind = false
        if flag:isSet(EFFECT_TYPE.BEHIND) then
            -- 在人物后面显示的光效
            behind = true
        end

        local armatureType = 0
        if flag:isSet(EFFECT_TYPE.ARMATURE_MAP) then
            armatureType = ARMATURE_TYPE.ARMATURE_MAP
        elseif flag:isSet(EFFECT_TYPE.ARMATURE_SKILL) then
            armatureType = ARMATURE_TYPE.ARMATURE_SKILL
        end


        local magicKey = nil
        if flag:isSet(EFFECT_TYPE.IS_LOOP_EFFECT) then
            magicKey = data.effect_no
        end

        -- layerFlag 1：顶层，   2：中级（默认），  3 下层
        -- 这里的层是指 整个战斗中层级
        local layerFlag = 2
        if flag:isSet(EFFECT_TYPE.TOP) then
            layerFlag = 1
        elseif flag:isSet(EFFECT_TYPE.BOTTOM) then
            layerFlag = 3
        end



        if flag:isSet(EFFECT_TYPE.GLOBAL) then
            -- 光效显示在屏幕中央
            local cx, cy = FightPosMgr:getScreenCenterPos()
            cx = cx - obj.curX
            cy = cy - obj.curY
            obj:addMagic(cx, cy, data.effect_no, behind, magicKey, armatureType, {blendMode = data.blendMode}, nil, layerFlag)
        elseif flag:isSet(EFFECT_TYPE.LOCATION_WAIST) then
            -- 光效显示在腰上
            obj:addMagicOnWaist(data.effect_no, behind, magicKey, armatureType, {blendMode = data.blendMode}, nil,layerFlag)
        elseif flag:isSet(EFFECT_TYPE.LOCATION_HEAD) then
            -- 光效显示在头上
            obj:addMagicOnHead(data.effect_no, behind, magicKey, armatureType, {blendMode = data.blendMode}, nil,layerFlag)
        else
            -- 光效显示在脚上
            obj:addMagicOnFoot(data.effect_no, behind, magicKey, armatureType, {blendMode = data.blendMode}, nil,layerFlag)
        end
    end

    if not data.name or string.len(data.name) <= 0 then
        -- 不需要显示名字图片
        return
    end

    -- 获取文字图片
    local img = self:getWordsImgFile(data.name)
    if not img then
        return
    end

    if not (flag:isSet(EFFECT_TYPE.SPECIAL)) then
        -- 名字图片显示在当前位置对应的角色上
        obj = self:getCreatedObj(data.pos)
        if not obj then
            return
        end
    end

    -- 显示技能名字图片
    obj:flyImg(img)
end

-- 让战斗菜单播放闪动效果
function FightMgr:blinkMenu(menu)
    local dlg = DlgMgr:openDlg("FightTalkMenuDlg")
    dlg:blinkMenu('[' .. menu .. ']')
end

-- 战斗菜单是否已关闭
function FightMgr:menuIsClosed(menu)
    if not DlgMgr:isDlgOpened('FightTalkMenuDlg') then
        return 1
    end

    local dlg = DlgMgr:openDlg("FightTalkMenuDlg")
    if dlg:menuIsClosed('[' .. menu .. ']') then
        return 1
    end

    return 0
end

-- 指定位置上是否可添加对象
function FightMgr:canAddObjAtPos(pos)
    local obj = self:getNotCreateObj(tonumber(pos))
    if obj then
        return 1
    end

    return 0
end

function FightMgr:calculateDestPos(paras)
    local obj = self:getCreatedObj(tonumber(paras['obj_pos']))
    if not obj then
        return
    end

    obj:calculateDestPos(tonumber(paras['from_pos']), tonumber(paras['to_pos']))
end

-- 清除对象动作
function FightMgr:clearObjAction(pos)
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        obj:clearAction()
    end
end

-- 清除对象
function FightMgr:cleanupObj(pos)
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        obj:cleanup()
    end
end

-- 清除技能光效
function FightMgr:clearSkillEffect()
---- cyq todo g_pSkillEffectMgr->Clear();
end

-- 显示伤害效果
function FightMgr:showDamageEffect(info)
    if self:checkIsInClear() then
        return
    end

    local _, _, pos, damageType = string.find(info, "(%d+),([-]?%d+)")
    damageType = tonumber(damageType)
    if not damageType then return end
    damageType = Bitset.new(damageType)
    if damageType:isSet(DAMAGE_TYPE_JOINT_ATTACK) or damageType:isSet(DAMAGE_TYPE_JOINT_ATTACK_EX) then
        -- 合击
        self:showFlyWordsImg(pos, FLY_FLAG_HE_JI)
    elseif damageType:isSet(DAMAGE_TYPE_DAMAGE_SEL) then
        -- 反震
        self:showFlyWordsImg(pos, FLY_FLAG_FAN_ZHEN)
    end

    if damageType:isSet(DAMAGE_TYPE_PENETRATE) then
        -- 破防
        self:showFlyWordsImg(pos, FLY_FLAG_PENETRATE)
    end
end

-- 显示飘字效果
-- nFlag > 0 时对应于技能编号
function FightMgr:flyWordsImg(info)
    if self:checkIsInClear() then
        return
    end

    local _, _, pos, flag = string.find(info, "(%d+),([-]?%d+)")
    flag = tonumber(flag)
    self:showFlyWordsImg(pos, flag)
end

function FightMgr:showFlyWordsImg(pos, flag)
    -- 如果看录像，跳过，则不播放效果
    if WatchRecordMgr.skipMagic then return end

    local name
    flag = tonumber(flag)
    if not flag then return end
    if flag > 0 then
        name = SkillMgr:getFlyWordByNo(flag)
    else
        name = FLY_NAMES[1 - flag]
    end

    if not name then
        Log:W('Not found wordsimg name for flag: ' .. flag)
        return
    end

    local img = self:getWordsImgFile(name)
    if not img then
        return
    end

    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        obj:flyImg(img)

        local actionName = name
        if flag > 0 then
            -- 使用魔法
            actionName = CHS[7150093]
        end

        EventDispatcher:dispatchEvent(EVENT.SET_FLYWORDS_OR_ACT, {obj = obj, actionName = actionName,
            type = "piaoZi", para = flag > 0})
    end
end

function FightMgr:getSkillInfoByNo(skillNo)
    local info = SkillMgr:getskillAttrib(tonumber(skillNo)) or {}
    local whoFirst = info.skill_effect_who_first or 2
    local toWhom = info.skill_effect_to_whom or 2
    local stricken = 0
    if info.stricken then stricken = 1 end

    return 'skill_effect_who_first=' .. whoFirst .. ',skill_effect_to_whom=' .. toWhom .. ',stricken=' .. stricken
end

-- 根据 id 返回对应对象的位置
function FightMgr:getObjectPosById(id)
    id = tonumber(id)
    for i = 0, FightPosMgr.OBJ_NUM do
        if self.objs[i].isCreated and self.objs[i]:getId() == id then
            return i
        end
    end

    -- 没有找到
    return -1
end

-- 根据 id 返回对应的对象
function FightMgr:getObjectById(id)
    id = tonumber(id)
    for i = 0, FightPosMgr.OBJ_NUM do
        if self.objs[i].isCreated and self.objs[i]:getId() == id then
            return self.objs[i]
        end
    end
end

-- 播放声音
function FightMgr:playSound(data)
    --Log:D("playSound")
    Log:D("playSound"..data.sound_type)

    local soundType = tonumber(data.sound_type)
    local objectIcon = tonumber(data.object_icon)
    local weaponIcon = tonumber(data.weapon_icon)

    -- 根据声音类型播放声音
    if soundType == SOUND_TYPE_ATTACK or soundType == SOUND_TYPE_FIGHT_BACK then
        -- 物理攻击
        -- 反击
        --weapon_icon
        local effectName = "attack"

        local fightObj = self:getObjectById(data.attackerId)
        local special_icon = 0
        if fightObj then special_icon = fightObj:queryBasicInt("special_icon") end

        if special_icon ~= 0 then
            effectName = "attack"
        else
            if weaponIcon == 0 then
            -- 没有使用武器
            else
                -- 使用了武器
                if objectIcon == 6001 or objectIcon == 7001 then        -- 金
                    effectName = "attack_qiang"
                elseif objectIcon == 6002 or objectIcon == 7002 then    -- 木
                    effectName = "attack_zhua"
                elseif objectIcon == 6003 or objectIcon == 7003 then    -- 水
                    effectName = "attack_jian"
                elseif objectIcon == 6004 or objectIcon == 7004 then    -- 火
                    effectName = "attack_shan"
                elseif objectIcon == 6005 or objectIcon == 7005 then    -- 土
                    effectName = "attack_chui"
                else
                    effectName = "attack"
                end
            end
        end

        local icon
        if fightObj then
            icon = fightObj:getIcon()
        else
            icon = objectIcon
        end
        local cartoonInfo = require(ResMgr:getCharCartoonPath(icon))
        if cartoonInfo then
            local info = cartoonInfo["attack"]
            if info then
                local kf = info["keyframe"] or 0
                local interval = (tonumber(info["rate"]) or 100) / 1000 * 0.7
                local delay = kf * interval
                SoundMgr:playSkillEffect(effectName, delay)
            end
        else
        SoundMgr:playEffect(effectName)
        end

        if data.attackType and FAT_LIPO == tonumber(data.attackType) then -- 力破
            SoundMgr:playSkillEffect("lipocast3")
        end
    elseif soundType == SOUND_TYPE_DIE then
        -- 死亡
        if data.object_icon == "6001" or data.object_icon == "6004" or data.object_icon == "6005"
            or data.object_icon == "7002" or data.object_icon == "7003" then
            -- 男角色死亡
            SoundMgr:playEffect("diem")
        elseif data.object_icon == "6002" or data.object_icon == "6003"
            or data.object_icon == "7001" or data.object_icon == "7004" or data.object_icon == "7005" then
            -- 女角色死亡
            SoundMgr:playEffect("dief")
        else
            -- 其他角色
            SoundMgr:playEffect("cast9")
        end
    elseif soundType == SOUND_TYPE_CAST then
        local no = tonumber(data.fight_used_skill_no)
        local info = SkillMgr:getskillAttrib(no)

        local effectName = SkillMgr:getSkillCast(info.skill_class, info.skill_subclass)

        -- 使用技能
        if not effectName then
            SoundMgr:playEffect("cast")
        end
    elseif soundType == SOUND_TYPE_ENRICH_BLOOD then
        -- 补血
        SoundMgr:playEffect("recover")
    elseif soundType ==  SOUND_TYPE_ANTI_SHAKE or -- 反震
        soundType ==  SOUND_TYPE_ALL_OUT_HIT      -- 致命一击
    then
        SoundMgr:playEffect("attack")
    elseif soundType == SOUND_TYPE_FLEE then
        -- 逃走
        SoundMgr:playEffect("escape")
    elseif soundType ==  SOUND_TYPE_FIGHT_MISS then
        -- 攻击失败
        SoundMgr:playEffect("cast5")
    elseif soundType == SOUND_TYPE_CATCH then     -- 捕捉
        SoundMgr:playEffect("cast7")
    elseif soundType ==  SOUND_TYPE_BREAK_INTO then
        -- 中途进场
        SoundMgr:playEffect("cast6")
    end
end

-- 播放宠物天书技能
function FightMgr:playGodBookSkillEffect(data)
    local obj = self:getCreatedObj(tonumber(data.pos))
    if obj then
        obj:playGodBookSkillEffect(data)
    end
end

-- 查询指定位置上对象的 basic 信息
function FightMgr:queryBasicInt(posAndKey)
    local _, _, pos, key = string.find(posAndKey, "(%d+),(%D+)")
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        return obj:queryBasicInt(key)
    end

    if "magic_finish" == key then return 1 end

    return 0
end

-- 刷新状态（客户自定义）
function FightMgr:refreshObjCustomStatus(posAndStatus)
    local _, _, pos, status = string.find(posAndStatus, "(%d+),(%d+)")
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        obj:refreshCustomStatus(tonumber(status))
    end
end

-- 刷新状态（客户自定义）
function FightMgr:refreshObjCustomStatusEx(posAndStatus)
    local _, _, pos, status = string.find(posAndStatus, "(%d+),(%d+)")
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        obj:refreshCustomStatusEx(tonumber(status))
    end
end

-- 刷新状态
function FightMgr:refreshObjStatus(data)
    local obj = self:getCreatedObj(tonumber(data.pos))
    if obj then
        obj:refreshStatus(data)
    end
end

-- 在头顶显示对话信息
function FightMgr:setChat(data, isNotUpdate)
    local obj = self:getObjectById(tonumber(data.id))

    if obj then
        -- 停留时间
        if data.show_time and tonumber(data.show_time) > 0 then
            data.show_time = tonumber(data.show_time) or FIGHT_CHAT_SHOW_TIME
        else
            data.show_time = FIGHT_CHAT_SHOW_TIME
        end

        -- 战斗对象是否是Vip
        local isVip = false
        if data.vip_type and tonumber(data.vip_type) == 1 then
            isVip = true
        end

        -- 过滤
        if obj:isPlayer() or obj:isPet() then
            data["msg"] = ChatMgr:filtText(data, true)
        end

        data.time = gf:getServerTime()
        obj:setChat(data, obj.fightPos, isVip)

        if data.channel and tonumber(data.channel) and tonumber(data.channel) == CHAT_CHANNEL.HEAD then
            isNotUpdate = true
        end

        if not isNotUpdate then
            data.name = obj:getName()
            -- 发到当前频道 （头顶冒泡）
            data.channel = CHAT_CHANNEL["CURRENT"]
            data.show_extra = true
            data.icon = obj:queryBasicInt("icon")
            ChatMgr:insertChatdata("currentChatData",data)

            local dlg = DlgMgr.dlgs["ChatDlg"]
            if dlg then
                dlg:MSG_MESSAGE()
            end
        end
    end
end

-- 设置光效
function FightMgr:setMagic(info)
    -- 如果看录像，跳过，则不播放效果
    if WatchRecordMgr.skipMagic then return end

    local _, _, pos, icon, align = string.find(info, "(%d+),(%d+),(%d+)")
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        obj:setMagic(tonumber(icon), tonumber(align))
    end
end

-- 设置技能光效
function FightMgr:setSkillEffect(info)
    -- 如果看录像，跳过，则不播放效果
    if WatchRecordMgr.skipMagic then return end

    local _, _, pos, skillNo, toOthers = string.find(info, "(%d+),(%d+),(%d+)")
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        obj:setSkillEffect(tonumber(skillNo), tonumber(toOthers))
        return 1
    end

    return 0
end

-- 预加载动作资源
function FightMgr:preloadAct(info)
    local _, _, pos, act = string.find(info, "(%d+),(%d+)")
    act = tonumber(act)

    if act == Const.FA_DIE_NOW or act == Const.FA_DIED then
        -- 死亡
        act = Const.SA_DIE
    elseif act == Const.FA_ACTION_PHYSICAL_ATTACK or
        act == Const.FA_ACTION_COUNTER_ATTACK then
        -- 物理攻击、反击
        act = Const.SA_ATTACK
    elseif act == Const.FA_DEFENSE_START then
        -- 人物被击中时的动作状态
        act = Const.SA_DEFENSE
    elseif act == Const.FA_DYMAGE_COUNTER or
        act == Const.FA_PARRY_START then
        -- 反击伤害、格挡开始
        act = Const.SA_PARRY
    elseif act == Const.FA_ACTION_CAST_MAGIC or
        act == Const.FA_ACTION_CATCH_PET then
        -- 施展魔法、捕捉宠物
        act = Const.SA_CAST
    else
        -- 其他的不处理
        return
    end

    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        local icon = obj:getIcon()
        local weapon = obj:getWeaponIcon()
        local cartoonInfo = require(ResMgr:getCharCartoonPath(icon)) or {}
        if (not info or not info["centre_x"]) and not dontChangeAct then
            -- 动作不存在且需要判断是否复用别的动作
            local reuseAct = ACTION_REUSE_MAP[act]
            act = reuseAct
        end
        if not act then return end

        local actStr = gf:getActionStr(tonumber(act))

        -- 预加载角色图片
        local path = string.format("%05d/%05d", icon, 0)
        local pngFile = ResMgr:getCharPath(path, actStr) .. ".png"
        if not self.preloadFlag[pngFile] then
            self.preloadFlag[pngFile] = true -- 标记一下发起预加载了
            TextureMgr:loadAsync(LOAD_TYPE.CHAR, pngFile, function(tex) end, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
        end

        if weapon > 0 then
            -- 预加载武器图片
            icon = obj:queryBasicInt("org_icon")
            local path = string.format("%05d/%05d", icon, weapon)
            local pngFile = ResMgr:getCharPath(path, actStr) .. ".png"
            if not self.preloadFlag[pngFile] then
                self.preloadFlag[pngFile] = true -- 标记一下发起预加载了
                TextureMgr:loadAsync(LOAD_TYPE.CHAR, pngFile, function(tex) end, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444);
            end
        end
    end
end

-- 预加载技能光效资源
function FightMgr:preloadSkillEffect(info)
    local _, _, skillNo, toOthers = string.find(info, "(%d+),(%d+)")
    skillNo = tonumber(skillNo)
    toOthers = tonumber(toOthers)
    if skillNo and  toOthers then
        local magics = SkillEffectMgr:getMagicInfo(skillNo, toOthers)
        if magics then
            for i = 1, magics.count do
                if magics[i].type ~= "armature" then -- 骨骼资源动画不先预加载
                    self:preloadMagic(magics[i].icon, SkillEffectMgr:getMagicScale(magics[i].icon))
                end
            end
        end
    end
end

-- 预加载动画资源
function FightMgr:preloadMagic(info, extra)
    local icon = tonumber(info)
    if icon and not self.preloadFlag[icon] then
        self.preloadFlag[icon] = true -- 标记一下发起预加载了
        AnimationMgr:syncGetMagicAnimation(icon, MAGIC_TYPE.NORMAL, nil, extra)
    end
end

-- 根据主人上下线信息设置宠物上下线信息
function FightMgr:setOffline(info)
    local _, _, pos, ownerId = string.find(info, "(%d+),(%d+)")
    local obj = self:getCreatedObj(tonumber(pos))
    local owner = self:getObjectById(tonumber(ownerId))
    if obj and owner then
        obj:setOffline(owner:isOffline())
    end
end

-- 能否执行指定的动作
function FightMgr:objCanDoAct(info)
    local _, _, pos, saAct = string.find(info, "(%d+),(%d+)")
    local obj = self:getCreatedObj(tonumber(pos))
    if obj and obj:canDoAct(tonumber(saAct)) then
        return 1
    end

    return 0
end

-- 是否被冰冻了
function FightMgr:objIsFrozen(pos)
    local obj = self:getCreatedObj(tonumber(pos))
    if obj and obj:isFrozen() then
        return 1
    end

    return 0
end

-- 是否处于某种状态
function FightMgr:objIsInStatus(info)
    local _, _, pos, status = string.find(info, "(%d+),(%d+)")
    local obj = self:getCreatedObj(tonumber(pos))
    if obj and obj:isSetStatus(tonumber(status)) then
        return 1
    end

    return 0
end

-- 是否在初始位置
function FightMgr:objIsInitialPos(pos)
    local obj = self:getCreatedObj(tonumber(pos))
    if obj and obj:isInitialPos() then
        return 1
    end

    return 0
end

-- 显示动作
function FightMgr:objShowAct(info)
    local _, _, pos, toPos, faAct = string.find(info, "(%d+),(%d+),(%d+)")
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        obj:showAct(tonumber(toPos), tonumber(faAct))

        -- 死亡的是宠物且是Me的宠物
        if tonumber(faAct) == Const.FA_DIED then
            if obj and (tonumber(obj:queryBasic("type")) == OBJECT_TYPE.PET or tonumber(obj:queryBasic("type")) == OBJECT_TYPE.CHILD)
                and obj:queryBasicInt("owner_id") == Me:queryBasicInt("id") then
                DlgMgr:sendMsg("HeadDlg", "grayPetHeadImgWithoutUpdate")
            end
        end

    end
end

-- 恢复到创建时的状态
function FightMgr:objRecover(pos)
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        obj:recover()
    end
end

-- 设置指定对象的动作是否已完成
function FightMgr:setObjFinished(info)
    local _, _, pos, finished = string.find(info, "(%d+),(%d+)")
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        obj:setFinished(finished == '1')
    end
end

-- 设置指定对象的动作
function FightMgr:setObjAct(info)
    local _, _, pos, faAct = string.find(info, "(%d+),(%d+)")
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        obj:setAct(tonumber(faAct))
    end
end

-- 设置朝向
function FightMgr:setObjLookAt(info)
    local _, _, pos, toPos, saAct = string.find(info, "(%d+),(%d+),(%d+)")
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        obj:setLookAt(tonumber(toPos), tonumber(saAct))
    end
end

-- 设置朝向
function FightMgr:setObjOffsetLookAt(info)
    local _, _, pos, toPos, saAct = string.find(info, "(%d+),(%d+),(%d+)")
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then
        obj:setOffsetLookAt(tonumber(toPos), tonumber(saAct))
    end
end

-- 指定对象的动作是否已完成
function FightMgr:isObjFinished(pos)
    local obj = self:getCreatedObj(tonumber(pos))
    if not obj or obj:getIsFinished() then
        return 1
    end

    return 0
end

function FightMgr:goAheadNow(pos)
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then obj:goAheadNow() end
end

function FightMgr:goBackNow(pos)
    local obj = self:getCreatedObj(tonumber(pos))
    if obj then obj:goBackNow() end
end

-- 显示血条变化数值
function FightMgr:showLifeDeltaNumber(info)
    -- 如果看录像，跳过，则不播放效果
    if WatchRecordMgr.skipMagic then return end

    local _, _, objId, lifeDelta, numberGroup = string.find(info, "(%d+),([-]?%d+),(%d+)")
    local obj = self:getObjectById(tonumber(objId))
    if obj then
        obj:showLifeDeltaNumber(tonumber(lifeDelta), tonumber(numberGroup))
    end
end

-- 显示沙漏
-- id 为 -1 表示对所有的队友都有效
function FightMgr:sandglassSomeone(id, show)
    for i = FightPosMgr.OBJ_NUM * 3 / 4, FightPosMgr.OBJ_NUM - 1 do
        if self.objs[i].isCreated and (id == -1 or self.objs[i]:getId() == id) then
            self.objs[i]:setWaiting(show)
        end
    end

    if not show and (-1 == id or id == Me:getId()) and not Me:isLookOn() then
        local dlg = DlgMgr:showDlg('FightInfDlg', true)
        if dlg then
        dlg:showPleaseWait(true)
        end

        DlgMgr:showDlg('FightTargetChoseDlg', false)

        -- 不可输入命令
        Me:setBasic('c_enable_input', 0)

        -- 不显示选择图片
        self:showSelectImg(false)
    end
end

-- 根据人物现在正在攻击的人的 id 来确实人物的攻击是否已经完成
function FightMgr:changeMeActionFinished()
    if Me:queryBasicInt('c_enable_input') == 0 then return end
    if Me:queryBasicInt('c_attacking_id') == Me:getId() then
        -- 当前的动作者为 me，设置 me 操作完成，关闭对应的操作菜单
        Me:setBasic('c_me_finished_cmd', 1)
        if 1 ~= Me:queryBasicInt('c_pet_finished_cmd') then
            -- 如果me完成了相应的操作命令，而宠物没有完成操作指令
            -- 获取战斗宠物
            local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
            local obj
            -- 判断战斗宠物是否存在
            if pet then
                -- 如果战斗宠物存在 ，保存战斗宠物
                obj = self:getObjectById(pet:getId())
            end

            if not obj then
                Me:setBasic('c_pet_finished_cmd', 1)
                -- 如果战斗宠物不存在，则认为所有的战斗指令下达完成
                -- 指令输入完成打开“自动”菜单
                if not BattleSimulatorMgr:isRunning() then    -- 如果不是”第一场战斗“
                    local dialog = DlgMgr:openDlg("FightPlayerMenuDlg")
                    if dialog then
                        dialog:updateFastSkillButton()
                        dialog:showOnlyAutoFightButton(true)
                    end
                    dialog:showOnlyAutoFightButton(true)
                end
            else
                -- 如果战斗宠物存在，则关闭人物战斗指令菜单并打开宠物操作菜单，进入宠物指令设置，并设置当前动作者id为宠物id
                self:closeFightMeMenuDlg()

                -- 如果存在宠物，玩家下达完角色的战斗指令，但是还并未下达宠物战斗指令(认为战斗指令没有下达完成)隐藏玩家选择对话框
                DlgMgr:showDlg('FightPlayerSkillDlg', false)  -- 隐藏技能选择对话框
                DlgMgr:showDlg('FightCallPetMenuDlg', false)  -- 隐藏召唤对话框
                DlgMgr:showDlg("FightUseResDlg", false)       -- 隐藏道具对话框
                self:openFightPetMenuDlg()
                Me:setBasic('c_attacking_id', pet:getId())
            end
        else
            -- 如果me和宠物都下达完成战斗指令
            -- 指令输入完成打开“自动”菜单
            if not BattleSimulatorMgr:isRunning() then    -- 如果不是”第一场战斗“
                local dialog = DlgMgr:openDlg("FightPlayerMenuDlg")
                if dialog then
                    dialog:updateFastSkillButton()
                    dialog:showOnlyAutoFightButton(true)
                end
            end
            self:CleanAllAction()
        end
    else
        -- 宠物完成指令操作
        Me:setBasic('c_pet_finished_cmd', 1)
        self:closeFightPetMenuDlg()

        if 0 == Me:queryBasicInt('c_me_finished_cmd') then
            -- me 的指令操作未完成，打开 me 的操作菜单
            self:openFightMeMenuDlg()
            Me:setBasic('c_attacking_id', Me:getId())
        else
            -- 指令输入完成，清空已有的动作
            -- 指令输入完成打开“自动”菜单
            if not BattleSimulatorMgr:isRunning() then    -- 如果不是”第一场战斗“
                local dialog = DlgMgr:openDlg("FightPlayerMenuDlg")
                if dialog then
                    dialog:showOnlyAutoFightButton(true)
                    dialog:updateFastSkillButton()
                end
            end
            self:CleanAllAction()
        end
    end
end

function FightMgr:cmdCEndAnimate()
    if self.ignoreCmdCEndAnimtate then
        -- 已经标记丢弃本次调用
        self.ignoreCmdCEndAnimtate = nil
        return
    end

    if gf:isWindows() and DebugMgr:isRunning() then
        DebugMgr:sendDoAction('CMD_C_END_ANIMATE', {answer = FightMgr.speedFactor})
    elseif not BattleSimulatorMgr:isRunning() then
        gf:CmdToServer('CMD_C_END_ANIMATE', {answer = FightMgr.speedFactor})
    else
        gf:sendDoActionToBattleSimulator('CMD_C_END_ANIMATE', {answer = FightMgr.speedFactor})
    end

    if WatchRecordMgr:getCurReocrdCombatId() then
        -- 观战中心录像，标记一下动画播放完了
        WatchRecordMgr.waitingAnimationEnd = false
    end

    if self.rcvEndCombat then
        -- 收到结束战斗的消息后要等动画播放完成才能结束战斗
        GameMgr:onEndCombat()

        DlgMgr:sendMsg("HeadDlg", "checkGrayPetHeadImgInCombat")
        DlgMgr:sendMsg('HeadDlg', 'updatePlayerInfo')
        DlgMgr:sendMsg("HeadDlg", "updatePetInfo")
    end
end

-- 菜单对话框是否已关闭
function FightMgr:talkMenuDlgIsClosed()
    if DlgMgr:isDlgOpened('FightTalkMenuDlg') then
        return 0
    end

    if DlgMgr:isDlgOpened('DramaDlg') and not DlgMgr:sendMsg('DramaDlg', 'isTurnToNextScene') then
        return 0
    end

    return 1
end

-- 显示倒计时和回合信息
function FightMgr:showFightInfo(time, curRound, curTime)
    if not Me:isLookOn() then
        local infoDlg = DlgMgr:openDlg('FightInfDlg')
        local interval = gf:getServerTime()
        infoDlg:startCountDown(time - math.min(time, math.max(0, (interval - curTime))))
    end

    local roundDlg = DlgMgr:openDlg("FightRoundDlg")
    roundDlg:setCurRound(curRound)
    self.curRound = curRound

    -- 战斗记录，插入回合数
    FightCmdRecordMgr:insertRoundInfo(self.curRound)
end

-- 获取回合倒计时
function FightMgr:getRoundLeftTime()
    local fightInfoDlg = DlgMgr:getDlgByName("FightInfDlg")
    local leftTime = 0
    if fightInfoDlg then
        leftTime = fightInfoDlg:getLeftTime()
    end

    return leftTime
end

-- 刷新当前回合的战斗
-- 操作: 1. 将当前回合之前的动画清除
--       2. 刷新场上存在的角色的状态
--       3. 播放当前回合的动画
function FightMgr:refreshCurrentCombatAction()
    if not Me:isInCombat() then
        return
    end

    if BattleSimulatorMgr:isRunning() then
        return
    end

    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_COMBAT_GET_CUR_ROUND)
end

-- 强制改变战斗中对象信息
function FightMgr:MSG_C_UPDATE_COMBAT_INFO(data)
    local obj = FightMgr:getObjectById(data.id)
    if not obj then return end
    if data.isSet == 1 then
        FightMgr.glossObjsInfo[data.id] = data
    else
        FightMgr.glossObjsInfo[data.id] = nil
    end

    obj:onAbsorbBasicFields()
    obj:addShadow()
end

function FightMgr:MSG_C_CREATE_SEQUENCE(data)
    GFightActMgr:OnMsg_C_CreateSequence(data.MSG, gf:ConvertToUtilMapping(data))
end

function FightMgr:MSG_LC_CREATE_SEQUENCE(data)
    self:MSG_C_CREATE_SEQUENCE(data)
end

-- 当前回合数回来了
function FightMgr:MSG_LC_CUR_ROUND(data)
    if not WatchRecordMgr:getCurReocrdCombatId() then
        return
    end

    GFightMgr:refreshCurrentCombatAction(data.animate_done)
end

-- 当前回合数回来了
function FightMgr:MSG_C_CUR_ROUND(data)
    if not Me:isInCombat() then
        return
    end

    if data.animate_done == 0 then
        -- animate_done 为 0 时，GFightMgr:refreshCurrentCombatAction() 会清除当前正在执行的动作
        -- 这样客户端播放动画的时间过短，向服务端发送动画结束的消息被服务端拦截导致卡战斗
        -- 所以此时不应该往下执行
        return
    end

    GFightMgr:refreshCurrentCombatAction(data.animate_done)
end

-- 设置当前是在清空前一回合的所有动作（主要用于切换到后台到前台的操作）
function FightMgr:setClearStatus(status)
    if 1 == tonumber(status) then
        self.isInClear = ture
    else
        self.isInClear = false
    end
end

-- 检查是否处于后台且回来的清除动作的状态
function FightMgr:checkIsInClear()
    return self.isInClear
end

-- 获取当前回合
function FightMgr:getCurRound()
    self.curRound = self.curRound or 1
    return self.curRound
end

function FightMgr:setLCFightWait(data)
    -- 是否为菜单回合(FLAG_NORMAL_ACTION：弹出默认菜单；FLAG_SELECT_MENU：选择菜单)
    self.bSelectMenu = data.menu

    self:closeMenuDlgs()

    local time = data.time
    if time < 0 then
        Log:W('invalid wait time: ' .. time)
        return
    end

    -- 显示倒计时和回合信息
    self:showFightInfo(time, data.round, data.curTime)

    if self.bSelectMenu == FLAG_SELECT_MENU then
        self:sandglassSomeone(data.id, true)
        return
    elseif self.bSelectMenu == FLAG_NORMAL_ACTION then
        -- 不是选择菜单
        -- 所有好友都要显示沙漏
        -- 第一个参数为 -1 表示对所有的队员都有效
        self:sandglassSomeone(-1, true)
    else
        Log:W('Invalid bSelectMenu: ' .. self.bSelectMenu)
    end
end

function FightMgr:setFightWait(data)
    -- 用于标记是否预加载过了
    self.preloadFlag = {}

    -- 是否为菜单回合(FLAG_NORMAL_ACTION：弹出默认菜单；FLAG_SELECT_MENU：选择菜单)
    self.bSelectMenu = data.menu

    self:closeMenuDlgs()

    local time = data.time
    if time < 0 then
        Log:W('invalid wait time: ' .. time)
        return
    end

    -- 显示倒计时和回合信息
    self:showFightInfo(time, data.round, data.curTime)

    for i = 0, FightPosMgr.OBJ_NUM do
        if self.objs[i].isCreated then
            self.objs[i]:onNewRound()
        end
    end

    if self.bSelectMenu == FLAG_SELECT_MENU then
        self:sandglassSomeone(data.id, true)
        return
    elseif self.bSelectMenu == FLAG_NORMAL_ACTION then
        -- 不是选择菜单
        -- 所有好友都要显示沙漏
        -- 第一个参数为 -1 表示对所有的队员都有效
        self:sandglassSomeone(-1, true)
    else
        Log:W('Invalid bSelectMenu: ' .. self.bSelectMenu)
    end

    -- 启动了倒计时则可以输入命令
    Me:setBasic('c_enable_input', 1)

    -- 每回合开始清空人物使用变身卡位置
    Me:clearFightUseChangeCardPos()

    -- 判断是否在自动战斗中，显示选择图片
    if Me:queryBasicInt("auto_fight") == 0 then
        self:showSelectImg(true)
    else
       self:showSelectImg(false)
    end
    -- 当前攻击者设为自己(默认为先出现自己的菜单)
    Me:setBasic('c_attacking_id', Me:getId())

    -- 标记 me 还没有输入命令
    Me:setBasic('c_me_finished_cmd', 0)

    -- 刷新自动战斗的菜单
    if Me:queryBasicInt('auto_fight') == 1 then
        local dlg = DlgMgr.dlgs["AutoFightSettingDlg"]
        if dlg then
            dlg:refreshMenu()
        end
    end

    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if pet and self:getObjectById(pet:getId()) then
        -- 参战宠物没有输入命令
        Me:setBasic('c_pet_finished_cmd', 0)
    else
        -- 没有参战宠物或者参战宠物不在战斗中，则标志宠物输入命令已经完成
        Me:setBasic('c_pet_finished_cmd', 1)
    end

    if Me:isInCombat() then
        if not Me:isPassiveMode()  then
            if Me:queryBasicInt('auto_fight') ~= 1 then
                -- 非被动（自动）模式，可以输入命令
                self:openFightMeMenuDlg()
            else
                -- 自动战斗
                FightMgr:setAutoFightSettingDlg()
            end

            -- 默认为物理工具
            Me.op = ME_OP.FIGHT_ATTACK
        end
    end

end

function FightMgr:acceptedCmd(data)
    if not Me:isInCombat() then
        Log:W('cmd accepted result out combat.')
        return;
    end

    if data.result ~= 0 then
        Log:W('Invalid cmd accepted result')
        return
    end

    if self.bSelectMenu == FLAG_SELECT_MENU then
        ---- cyq todo
        -- gfSendMsg("TalkMenuDlg", NULL, CM_SETVISIBLE, TRUE, 0);
        return
    end

    if Me:queryBasicInt('c_attacking_id') == -1 then
        -- 如果激活宠物菜单返回按钮
        Me:setBasic('c_me_finished_cmd', 0)
        Me:setBasic('c_pet_finished_cmd', 0)
        Me:setBasic('c_attacking_id', Me:getId())
        -- 重新打开人物战斗操作菜单
        self:openFightMeMenuDlg()
        return
    end

    local id = data.id
    if Me:queryBasicInt('c_attacking_id') == id then
        if Me:getId() == id and Me:queryBasicInt('c_me_finished_cmd') == 0 then
            -- me 的动作未完成并且当前攻击者为 me
            return
        end

        if Me:queryBasicInt('c_pet_finished_cmd') == 0 then
            -- 宠物的命令未完成
            -- 判断宠物是否参战
            local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
            if not pet then
                Log:W('Not found fight pet')
                return
            end

            local obj = self:getObjectById(pet:getId())
            if not obj then
                Log:W('Not found fight obj for fight pet')
                return
            end

            if id == pet:getId() then
                -- 宠物命令未完成
                return
            end
        end
    end


    -- 自动战斗无效命令发送物理攻击
    --[[  if Me:queryBasicInt('auto_fight') == 1  then
    local acttcedId

    for i = 0, FightPosMgr.NUM_PER_LINE * 2 - 1 do
    if FightMgr.objs[i].isCreated and FightMgr.objs[i]:queryBasicInt("c_seq_died") == 0 then
    acttcedId = FightMgr.objs[i]:getId()
    break
    end
    end

    gf:ShowSmallTips(CHS[3004011])
    gf:sendFightCmd(id, acttcedId, FIGHT_ACTION.PHYSICAL_ATTACK, FIGHT_ACTION.PHYSICAL_ATTACK)
    return
    end]]


    if id == Me:getId() then
        if Me:queryBasicInt('c_me_finished_cmd') == 1 then
            -- me的操作完成，但被服务器拒绝，重新打开操作菜单
            self:openFightMeMenuDlg()
            Me:setBasic('c_attacking_id', id)
        end

        -- 接受 me 的指令失败，重新操作
        Me:setBasic('c_me_finished_cmd', 0)
        return
    end

    -- 指令失败的不是 me，则为宠物，获取参战宠物
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if not pet then
        Log:W('Not found fight pet')
        return
    end

    if Me:queryBasicInt('c_me_finished_cmd') == 1 and Me:queryBasicInt('c_pet_finished_cmd') == 1 then
        -- me 及宠物都操作完成，重新打开操作菜单
        self:openFightPetMenuDlg()
        Me:setBasic('c_attacking_id', id)
    end

    -- 重新操作
    Me:setBasic('c_pet_finished_cmd', 0)
end

function FightMgr:closeMenuDlgs()
    --DlgMgr:closeDlg("NpcDlg")               -- 关闭平时带菜单选项的对话框
    DlgMgr:closeDlg("FightTalkMenuDlg")     -- 关闭战斗时带菜单选项的对话框
    DlgMgr:closeDlg("FightTalkNoMenuDlg")   -- 关闭战斗时不带菜单选项的对话框
end

-- 打开战斗相关界面
function FightMgr:openFightDlgs()
    DlgMgr:openDlg('ChatDlg')
    DlgMgr:setDlgCtrlVisible('ChatDlg', "SpeedButton", false)
    DlgMgr:closeFloatingDlg()   -- 关闭悬浮框

    if not BattleSimulatorMgr:isRunning() then
        DlgMgr:openDlg("HeadDlg")
        DlgMgr:openDlg("SkillStatusDlg")
        DlgMgr:openDlg("CombatViewDlg")
    end
end

-- 关闭战斗相关界面
function FightMgr:closeFightDlgs()
    DlgMgr:closeDlg('FightRoundDlg', nil, true)
    DlgMgr:closeDlg('FightInfDlg', nil, true)
    DlgMgr:closeDlg('FightPlayerMenuDlg', nil, true)
    DlgMgr:closeDlg('FightPetMenuDlg', nil, true)
    DlgMgr:closeDlg('FightCallPetMenuDlg', nil, true)
    DlgMgr:closeDlg('FightPetSkillDlg', nil, true)
    DlgMgr:closeDlg('FightChildSkillDlg', nil, true)
    DlgMgr:closeDlg('FightPlayerSkillDlg', nil, true)
    DlgMgr:closeDlg('FightTargetChoseDlg', nil, true)
    DlgMgr:closeDlg('FightTalkMenuDlg', nil, true)
    DlgMgr:closeDlg('FightTalkNoMenuDlg', nil, true)
    DlgMgr:closeDlg('FightUseResDlg', nil, true)
    DlgMgr:setDlgCtrlVisible('ChatDlg', "FriendButton", true)
    DlgMgr:setDlgCtrlVisible('ChatDlg', "SpeedButton", false)
    DlgMgr:closeDlg('AutoFightSettingDlg', nil, true)
    DlgMgr:closeDlg('AutoFightDlg', nil, true)
    DlgMgr:closeDlg('ZuheSkillSelectDlg', nil, true)
    DlgMgr:closeDlg("SkillStatusDlg")
    DlgMgr:closeDlg("CombatStatusDlg")
    DlgMgr:closeDlg("FightCommanderSetDlg")
    DlgMgr:closeDlg("CombatViewDlg")
    DlgMgr:closeDlg("FightLookOnDlg")
    DlgMgr:closeDlg("WatchCentreBattleInterfaceDlg")
    DlgMgr:closeDlg("ZHSkillTargetChoseDlg")
    DlgMgr:closeDlg("JiuTianBuffDlg")
    DlgMgr:setVisible("HeadDlg", false)
    gf:closeConfirmByType("set_auto_fight")

    local dlg = DlgMgr:getDlgByName("ConfirmDlg")
    if dlg and dlg:isFightDlg() then
        DlgMgr:closeDlg('ConfirmDlg')
    end

    -- 如果有战斗指引 没清除就清掉
    if FIGHT_GUIDE_ID[GuideMgr:getCurGuidId()] then
        GuideMgr:closeCurrentGuide()
    end
end

-- 隐藏战斗操作界面
function FightMgr:hideOperateDlgs()
    -- 隐藏人物战斗操作按钮
    if Me:queryBasicInt('auto_fight') == 1 then
        -- 如果已经是自动战斗模式，就隐藏自动战斗菜单
        DlgMgr:showDlg('FightPlayerMenuDlg', false)
    else
        -- 如果是手动模式，显示”自动“菜单
        if not BattleSimulatorMgr:isRunning() then    -- 如果不是在第一场指引战斗
            local dlg = DlgMgr:showDlg('FightPlayerMenuDlg', true)
            if dlg then
                dlg:updateFastSkillButton()
                dlg:showOnlyAutoFightButton(true)
            end
        end
    end

    DlgMgr:showDlg('FightPetMenuDlg', false)
    DlgMgr:showDlg('FightCallPetMenuDlg', false)
    DlgMgr:showDlg('FightPetSkillDlg', false)     -- 下达完成战斗指令，隐藏宠物技能对话框
    DlgMgr:showDlg('FightChildSkillDlg', false)   -- 下达完成战斗指令，隐藏娃娃技能对话框
    DlgMgr:showDlg('FightPlayerSkillDlg', false)  -- 下达完成战斗指令，隐藏玩家技能对话框
    DlgMgr:showDlg('FightTargetChoseDlg', false)
    DlgMgr:showDlg('FightUseResDlg', false)

    local dlg = DlgMgr:getDlgByName("ConfirmDlg")
    if dlg and dlg:needCloseWhenRoundOver() then
        DlgMgr:closeDlg('ConfirmDlg')
    end

    -- 如果有战斗指引 没清除就清掉
    if FIGHT_GUIDE_ID[GuideMgr:getCurGuidId()] then
        GuideMgr:closeCurrentGuide()
    end
end

function FightMgr:getFightGuideId()
    return FIGHT_GUIDE_ID
end

-- 增加战斗地图背景
function FightMgr:addFightMapBg(mapId, x, y)
    if self.fightBgMap then
        gf:getMapLayer():removeChild(self.fightBgMap)
    end

    self.fightBgMap = FightMgr:initBgMap(mapId, x, y)
    gf:getMapLayer():addChild(self.fightBgMap)
end

-- 打开 me 的操作菜单
function FightMgr:openFightMeMenuDlg()
    Me.op = ME_OP.FIGHT_ATTACK
    DlgMgr:showDlg('FightTargetChoseDlg', false)
    self:closeFightPetMenuDlg()
    local dlg = DlgMgr:openDlg('FightPlayerMenuDlg', true)
    if dlg then
        dlg:updateFastSkillButton()
    end
    -- 显示所有战斗操作菜单
    dlg:showOnlyAutoFightButton(false)
end

-- 关闭  me 的操作菜单
function FightMgr:closeFightMeMenuDlg()
    DlgMgr:closeDlg('FightPlayerMenuDlg')
end

-- 打开宠物的操作菜单
function FightMgr:openFightPetMenuDlg()
    Me.op = ME_OP.FIGHT_ATTACK
    DlgMgr:showDlg('FightTargetChoseDlg', false)
    local dlg = DlgMgr:openDlg('FightPetMenuDlg')
    if dlg then
        dlg:updateFastSkillButton()
    end
end

-- 关闭宠物的操作菜单
function FightMgr:closeFightPetMenuDlg()
    DlgMgr:closeDlg('FightPetMenuDlg')
end

-- 获取战斗类型
function FightMgr:getCombatMode()
    return self.combatMode
end

-- 获取是否已收到战斗结束消息
function FightMgr:hasRecvEndCombatMsg()
    return self.rcvEndCombat
end

-- FightMgr
function FightMgr:MSG_C_START_COMBAT(map)
    if Me:isLookOn() or Me:isInCombat() then self:cmdCEndAnimate() end

    self.rcvEndCombat = false
    GameMgr:setInCombat(true)
    GameMgr:onStartCombat(map)
    GFightMgr:OnMsg_C_StartCombat(map.MSG, gf:ConvertToUtilMapping(map))
end

-- 重置玩家行路数据
function FightMgr:resetMoveData()
    Me:clearMoveCmds()
    if Me.lastMap and Me:isControlMove() then
        -- 战斗结束后为了防止被服务器拉回，我们重置下在战斗之前的位置。
        local endX, endY = gf:convertToClientSpace(Me.lastMap.x, Me.lastMap.y)
        Me:setPos(endX, endY)
        Me:setLastMapPos(Me.lastMap.x, Me.lastMap.y)
        Me:sendFollow()
        Me.lastMap = nil
    end
end

function FightMgr:MSG_C_END_COMBAT(map)
    self:resetMoveData()

    self.rcvEndCombat = true
    GFightMgr:OnMsg_C_CombatEnd(map.MSG, gf:ConvertToUtilMapping(map))

--    if map.receiverInBackground then
--        while GameMgr.inCombat do
--            FightMgr:update()
--        end
--    end
end

function FightMgr:MSG_LC_END_LOOKON(map)
    local combatId = WatchRecordMgr:getCurReocrdCombatId()
    if combatId then
        gf:ShowSmallTips(CHS[4200242])
        ChatMgr:sendMiscMsg(CHS[4200242])
    end

    self:resetMoveData()

    self.rcvEndCombat = true
    GFightMgr:OnMsg_C_CombatEnd(map.MSG, gf:ConvertToUtilMapping(map))

    if map.receiverInBackground then
        while GameMgr.inCombat do
            FightMgr:update()
        end
    end

    self:CleanAllAction()
    WatchRecordMgr:cleanData()
    BarrageTalkMgr:removeBarrageLayer()
end

function FightMgr:MSG_LC_START_LOOKON(map)
    if Me:isLookOn() or Me:isInCombat() then self:cmdCEndAnimate() end

    self.rcvEndCombat = false
    GameMgr:onStartCombat(map, true)
    GFightMgr:OnMsg_C_CombatEnd(map.MSG, gf:ConvertToUtilMapping(map))
    GFightMgr:OnMsg_C_StartCombat(map.MSG, gf:ConvertToUtilMapping(map))

    if WatchCenterMgr:getCombatData() then
        DlgMgr:openDlg("WatchCentreBattleInterfaceDlg")
    else
        -- 如果观战状态没打开观战界面，打开观战界面
        local dlg = DlgMgr.dlgs["FightLookOnDlg"]
        if not dlg then
            DlgMgr:openDlg("FightLookOnDlg")
        elseif not dlg:isVisible() then
            dlg:setVisible(true)
        end
    end

    local fightInfo = DlgMgr:openDlg("FightInfDlg")
    fightInfo:showLookInfo()

    -- 开始观战事件
    EventDispatcher:dispatchEvent(EVENT.START_LOOKON, {})
end

function FightMgr:MSG_LC_LOOKON_NUM(map)
    -- 显示观战人数
    local dlg = DlgMgr:openDlg("FightInfDlg")
    dlg:setLookOnNum(map)
end

function FightMgr:MSG_C_FRIENDS(map)
    local count = map.count
    local msg = map.MSG
    for i = 1, count do
        self:insertFriend(map[i])
    end

    -- 顶号时，可能宠物已经死亡，此处需要刷新一下界面
    DlgMgr:sendMsg("HeadDlg", "checkGrayPetHeadImgInCombat")
end

function FightMgr:MSG_LC_FRIENDS(map)
    self:MSG_C_FRIENDS(map)
end

function FightMgr:MSG_C_OPPONENTS(map)
    local count = map.count
    local msg = map.MSG
    for i = 1, count, 1 do
        self:insertOpponent(map[i])
    end
end

function FightMgr:clearFastSkillData()
    FightMgr.fastSkill = {["Me"] = {skillNo = -1, isQinMiWuJianCopySkill = false}, ["Pet"] = -1}
end

function FightMgr:clearData()
    self.isInClear = nil
end

function FightMgr:MSG_LC_OPPONENTS(map)
    self:MSG_C_OPPONENTS(map)
end

function FightMgr:MSG_C_WAIT_COMMAND(map)
    self:setFightWait(map);

    GFightMgr:OnMsg_C_WaitCommand(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_WAIT_COMMAND(map)
    self:setLCFightWait(map)
    GFightMgr:OnMsg_C_WaitCommand(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_C_ACCEPTED_COMMAND(map)
end

function FightMgr:MSG_C_LEAVE_AT_ONCE(map)
    local obj = self:getObjectById(map.id)
    if obj then
        obj:cleanup()
    end
end

function FightMgr:MSG_LC_LEAVE_AT_ONCE(map)
    self:MSG_C_LEAVE_AT_ONCE(map)
end

function FightMgr:MSG_C_COMMAND_ACCEPTED(map)
    self:acceptedCmd(map);
end

function FightMgr:MSG_C_REFRESH_PET_LIST(map)
    local count = map.count
    local msg = map.MSG
    for i = 1, count do
        local petId = map[i].id
        local pet = PetMgr:getPetById(petId)
        if pet then
            pet:setBasic('pet_cannot_call', 1)
            pet:setBasic('pet_have_called', map[i].haveCalled)
        end
    end
end

function FightMgr:MSG_C_SANDGLASS(map)
    self:sandglassSomeone(map.id, map.show == 1)

    if map.show == 0 and map.id == Me:getId() then
        self.notCatchCondition = false
    end
end
function FightMgr:MSG_LC_SANDGLASS(map)
    self:MSG_C_SANDGLASS(map)
end

function FightMgr:MSG_C_CHAR_OFFLINE(map)
    local obj = self:getObjectById(map.id)
    if obj then
        obj:setOffline(map.offline == 1)
        local pet = self:getCreatedObj(obj:getPetPos())
        if pet then
            pet:setOffline(map.offline == 1)
        end
    end
end

function FightMgr:MSG_LC_CHAR_OFFLINE(map)
    self:MSG_C_CHAR_OFFLINE(map)
end

function FightMgr:MSG_GODBOOK_EFFECT_NORMAL(map)
    local obj = self:getObjectById(map.id)
    if obj then
        obj:playGodBookSkillEffect(map)
    end
end

function FightMgr:MSG_C_UPDATE_APPEARANCE(map)
    local obj = self:getObjectById(map.id)

    -- 战斗不需要显示称谓
    map.title = ""

    if obj then
        obj:updateAppearance(map)
    end
end

function FightMgr:openTalkDlg(data, dlgName)
    local content = data.content
    if not content or string.len(content) == 0 then
        -- 没有菜单内容
        return
    end

    Me:setTalkId(data.id)

    local dlg = DlgMgr:openDlg(dlgName)
    dlg:setVisible(true)
    dlg:setMenuNpcId(data.id)
    dlg:setPortrait(data.portrait)
    dlg:setSecretKey('')
    dlg:setMenu(content)
end

function FightMgr:MSG_C_MENU_LIST(data)
    self:openTalkDlg(data, 'FightTalkMenuDlg')
end

function FightMgr:MSG_LC_MENU_LIST(data)
    self:MSG_C_MENU_LIST(data)
end

function FightMgr:MSG_PICTURE_DIALOG(data)
    self:openTalkDlg(data, 'FightTalkNoMenuDlg')
end

function FightMgr:MSG_LC_INIT_STATUS(data)
    for i = 1, data.count do
        local obj = self:getObjectById(data[i].id)
        if obj then
            obj:initStatus(data[i])
        end
    end

    -- 待所有对象create完毕，去掉用于选择目标的光圈
    self:showSelectImg(false)
end

-- 直接更新对手信息
function FightMgr:MSG_C_DIRECT_OPPONENT_INFO(data)
    for i = 1, data.count do
        local obj = self:getObjectById(data[i].id)
        if obj then
            if data[i].life then
                -- 需要显示血条
                obj:setBasic("show_life", 1)
            end

            obj:absorbBasicFields(data[i])
        end
    end
end

-- FightActMgr
function FightMgr:MSG_C_ACTION(map)
    if not GameMgr.inCombat and not Me:isLookOn() then return end

    -- 战斗指令记录管理器 记录指令
    FightCmdRecordMgr:insertRecord(map)

    GFightActMgr:OnMsg_C_Action(map.MSG, gf:ConvertToUtilMapping(map))

    -- 削除所有人向上的沙漏状态
    self:sandglassSomeone(-1, false)

    -- 不可输入命令
    Me:setBasic('c_enable_input', 0)

    -- 当前选择的技能为 0
    Me:setBasic('sel_skill_no', 0)

    -- 隐藏对话框
    FightMgr:hideOperateDlgs()

    -- 隐藏等待图片
    local dlg = DlgMgr:showDlg('FightInfDlg', true)
    dlg:showPleaseWait(false)

    -- 关闭由于战斗对象重叠而打开的选择对象对话框
    DlgMgr:closeDlg("UserListDlg")
end

function FightMgr:MSG_LC_ACTION(map)
	--self:MSG_C_ACTION(map)
    if not Me:isLookOn() then return end
    GFightActMgr:OnMsg_C_Action(map.MSG, gf:ConvertToUtilMapping(map))
    -- 削除所有人向上的沙漏状态
    self:sandglassSomeone(-1, false)


    -- 隐藏等待图片
   --[[ local dlg = DlgMgr:showDlg('FightInfDlg', true)
    dlg:showPleaseWait(false)]]
end

-- 获取战斗中 对应位置的世界区域
function FightMgr:getFightPosRect(index)
    local rect

    if self.objs[index].isCreated then
        local clickCtrl = self.objs[index].topLayer:getChildByName(ResMgr.ui.fightClick)

        rect = clickCtrl:getBoundingBox()
        local pt = clickCtrl:convertToWorldSpace(cc.p(0, 0))
        rect.x = pt.x
        rect.y = pt.y
        rect.width = rect.width
        rect.height = rect.height

        self.objs[index].oldZOrder = self.objs[index].selectImg:getParent():getLocalZOrder()

        self.objs[index].selectImg:getParent():setLocalZOrder(9999)
    end

    return rect
end

-- 指引完成恢复 战斗中对应位置的数据
function FightMgr:reviveFightPosData(index)
    if self.objs[index].isCreated and self.objs[index].oldZOrder then
        self.objs[index].selectImg:getParent():setLocalZOrder(self.objs[index].oldZOrder)
        self.objs[index].oldZOrder = nil
    end
end

-- 清空所有动作
function FightMgr:CleanAllAction()
    GFightMgr:CleanAllAction()
    DebugMgr:recordFightMsg("CMD_C_CLEANALLACTION", { call_stack = debug.traceback() })
end

function FightMgr:MSG_C_ACCEPT_MULTI_HIT(data)
    for i = 1, data.count do
        GFightActMgr:OnMsg_C_AcceptMultiHit(data.MSG, gf:ConvertToUtilMapping(data[i]))
    end
end

function FightMgr:MSG_C_ACCEPT_HIT(map)
    local damageTypeBit = Bitset.new(map.damage_type)
    if damageTypeBit:isSet(DAMAGE_TYPE_JOINT_ATTACK_EX) and not gf:gfIsFuncEnabled(FUNCTION_ID.NEW_JOINTJOINT_TYPE) then
        -- 不支持新版合击，转换为旧版
        map.damage_type = map.damage_type - 0x4000 + 0x40
        local attrib = Bitset.new(map.para)
        if attrib:isSet(1) then
            map.para = 1
        elseif attrib:isSet(2) then
            map.para = 2
        elseif attrib:isSet(3) then
            map.para = 3
        elseif attrib:isSet(4) then
            map.para = 4
        elseif attrib:isSet(5) then
            map.para = 5
        elseif attrib:isSet(6) then
            map.para = 6
        end

        if attrib.isSet(7) then
            map.para = map.para + 100
        end
    end

    GFightActMgr:OnMsg_C_AcceptHit(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_ACCEPT_HIT(map)
    self:MSG_C_ACCEPT_HIT(map)
end

function FightMgr:MSG_C_FLEE(map)
    GFightActMgr:OnMsg_C_Flee(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_FLEE(map)
    self:MSG_C_FLEE(map)
end

function FightMgr:MSG_C_LIFE_DELTA(map)
    GFightActMgr:OnMsg_C_LifeDelta(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_LIFE_DELTA(map)
    self:MSG_C_LIFE_DELTA(map)
end

function FightMgr:MSG_C_MANA_DELTA(map)
    GFightActMgr:OnMsg_C_ManaDelta(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_MANA_DELTA(map)
    self:MSG_C_MANA_DELTA(map)
end

function FightMgr:MSG_C_CHAR_DIED(map)
    -- 战斗指令记录管理器 记录指令
    FightCmdRecordMgr:insertRecord({attacker_id = map.id, action = FIGHT_ACTION.DIE, victim_id = 0, para = 0})

    GFightActMgr:OnMsg_C_CharacterDied(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_CHAR_DIED(map)
    self:MSG_C_CHAR_DIED(map)
end

function FightMgr:MSG_C_CHAR_REVIVE(map)
    GFightActMgr:OnMsg_C_CharacterRevie(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_CHAR_REVIVE(map)
    self:MSG_C_CHAR_REVIVE(map)
end


function FightMgr:MSG_C_CATCH_PET(map)
    GFightActMgr:OnMsg_C_CatchPet(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_CATCH_PET(map)
    self:MSG_C_CATCH_PET(map)
end

function FightMgr:MSG_C_ADD_FRIEND(map)
    local count = map.count
    local msg = map.MSG
    for i = 1, count, 1 do
        GFightActMgr:OnMsg_C_AddFriend(msg, gf:ConvertToUtilMapping(map[i]))
    end

    EventDispatcher:dispatchEvent(EVENT.FIGHT_ADD_FRIEND, map)
end

function FightMgr:MSG_LC_ADD_FRIEND(map)
    self:MSG_C_ADD_FRIEND(map)
end

function FightMgr:MSG_C_ADD_OPPONENT(map)
    local count = map.count
    local msg = map.MSG
    for i = 1, count, 1 do
        GFightActMgr:OnMsg_C_AddOpponent(msg, gf:ConvertToUtilMapping(map[i]))
    end

    EventDispatcher:dispatchEvent(EVENT.FIGHT_ADD_OPPONENT, map)
end

function FightMgr:MSG_LC_ADD_OPPONENT(map)
    self:MSG_C_ADD_OPPONENT(map)
end

function FightMgr:MSG_C_QUIT_COMBAT(map)
    GFightActMgr:OnMsg_C_QuitCombat(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_QUIT_COMBAT(map)
    self:MSG_C_QUIT_COMBAT(map)
end

function FightMgr:MSG_C_UPDATE_STATUS(map)
    GFightActMgr:OnMsg_C_UpdateStatus(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_UPDATE_STATUS(map)
    self:MSG_C_UPDATE_STATUS(map)
end

function FightMgr:MSG_C_ACCEPT_MAGIC_HIT(map)
    local count = map.count
    local msg = map.MSG
    for i = 1, count, 1 do
        GFightActMgr:OnMsg_C_AcceptMagicHit(msg, gf:ConvertToUtilMapping(map[i]))
    end
end

function FightMgr:MSG_LC_ACCEPT_MAGIC_HIT(map)
    self:MSG_C_ACCEPT_MAGIC_HIT(map)
end

function FightMgr:MSG_C_UPDATE_IMPROVEMENT(map)

    GFightActMgr:OnMsg_C_UpdatImprove(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_UPDATE_IMPROVEMENT(map)
    self:MSG_C_UPDATE_IMPROVEMENT(map)
end

function FightMgr:MSG_C_MENU_SELECTED(map)
    GFightActMgr:OnMsg_C_MenuSelected(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_MENU_SELECTED(map)
    self:MSG_C_MENU_SELECTED(map)
end

function FightMgr:MSG_C_DELAY(map)
    GFightActMgr:OnMsg_C_Delay(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_DELAY(map)
    self:MSG_C_DELAY(map)
end


function FightMgr:MSG_C_LIGHT_EFFECT(map)
    GFightActMgr:OnMsg_C_MagicApplyItem(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_LIGHT_EFFECT(map)
    self:MSG_C_LIGHT_EFFECT(map)
end

function FightMgr:MSG_C_WAIT_ALL_END(map)
    GFightActMgr:OnMsg_C_WaitAllEnd(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_WAIT_ALL_END(map)
    self:MSG_C_WAIT_ALL_END(map)
end

function FightMgr:MSG_C_UPDATE(map)
    GFightActMgr:OnMsg_C_Update(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_UPDATE(map)
    self:MSG_C_UPDATE(map)
end

function FightMgr:MSG_C_START_SEQUENCE(map)
    GFightActMgr:OnMsg_C_Seq(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_START_SEQUENCE(map)
    self:MSG_C_START_SEQUENCE(map)
end

function FightMgr:MSG_C_OPPONENT_INFO(map)
    if map.count == 0 then
        GFightActMgr:OnMsg_C_Opponent_Info(map.MSG, gf:ConvertToUtilMapping(map))
        return
    end

    for i = 1, map.count, 1 do
        GFightActMgr:OnMsg_C_Opponent_Info(map.MSG, gf:ConvertToUtilMapping(map[i]))
    end
end

function FightMgr:MSG_C_DIALOG_OK(map)
    GFightActMgr:OnMsg_C_Dialog_Ok(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_C_MESSAGE(map)
    GFightActMgr:OnMsg_C_Message(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_C_END_ACTION(map)
    if not GameMgr.inCombat and not Me:isLookOn() then return end
    GFightActMgr:OnMsg_C_EndAction(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_LC_END_ACTION(map)
    if not Me:isLookOn() then return end
    GFightActMgr:OnMsg_C_EndAction(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_C_SET_FIGHT_PET(map)

    -- 更新下头像界面，娃娃、宠物小标识
    DlgMgr:sendMsg("HeadDlg", "updateFightPetWhenHasFightKid")

    -- 由于有娃娃参战时，参战宠物标记会被清掉，所以客户端自己记着参战宠物id
    local pet = PetMgr:getPetById(map.id)
    if pet then
        -- 当前没有进入战斗      目标id的宠物是参战宠物       取消参战标记     有参战的娃娃
        -- 满足以上情况，说明准备进入战斗，服务器会清空客户端参战宠物标识，所以要记住是哪一只宠物，供 PetFollowRuleDlg 使用
        if not Me:isInCombat() and pet:queryBasicInt('pet_status') == 1 and map.pet_status == 0 and HomeChildMgr:getFightKid() then
            local tempPetId = map.id
            DlgMgr:sendMsg("HeadDlg", "updateFightPetWhenHasFightKid", tempPetId)
        end
    end


    GFightActMgr:OnMsg_C_SetFightPet(map.MSG, gf:ConvertToUtilMapping(map))
    DlgMgr:closeDlg("FightPetSkillDlg", nil, true)
end

function FightMgr:MSG_C_SET_CUSTOM_MSG(map)
    GFightActMgr:OnMsg_C_SetCustomMsg(map.MSG, gf:ConvertToUtilMappingN(map))
end

function FightMgr:MSG_GODBOOK_EFFECT_SUMMON(map)
    GFightActMgr:OnMsg_C_AddObjectEffect(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_ATTACH_SKILL_LIGHT_EFFECT(map)

	GFightActMgr:OnMsg_C_AttachSkillLightEffect(map.MSG, gf:ConvertToUtilMapping(map))
end

function FightMgr:MSG_SYNC_MESSAGE(map)
    if Me:isLookOn() then
        map["isLookOn"] = 1
    end
    GFightActMgr:OnMsg_Sync_Message(map.MSG, gf:ConvertToUtilMapping(map))
end

-- 申请观战
function FightMgr:lookFight(id)
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3004012])
        return
    end

    FightMgr:cmdLookOn(id)
end

-- 如果在设置组合战斗时，是不能打开 AutoFightSettingDlg
function FightMgr:setAutoFightSettingDlg()
    if not DlgMgr:isDlgOpened("ZHSkillTargetChoseDlg") then
        DlgMgr:openDlg("AutoFightSettingDlg")
    end
end


-- 更新数据MSG_UPDATE
function FightMgr:MSG_UPDATE(data)
    if not data.auto_fight or not Me:isInCombat() then return end

    if data.auto_fight == 1 then
        -- 自动模式下
        DlgMgr:closeDlg("FightPlayerMenuDlg")
        FightMgr:setAutoFightSettingDlg()
    else
        -- 手动模式下
        DlgMgr:closeDlg("AutoFightSettingDlg")

        -- 打开人物战斗指令操作按钮
        local dlg = DlgMgr:openDlg('FightPlayerMenuDlg')
        if dlg then
            dlg:updateFastSkillButton()
        end
        if Me:queryBasicInt('c_enable_input') == 1 then
            FightMgr:showSelectImg(true)
            -- 如果可以输入战斗指令了（即开始倒计时）此时战斗指令菜单全部显示
            dlg:showOnlyAutoFightButton(false)
        else
            -- 如果还没开始倒计时（即不能输入战斗指令时），按取消按钮仅显示“自动”菜单
            dlg:showOnlyAutoFightButton(true)
        end
    end
end

function FightMgr:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTICE_UPDATE_MAIN_ICON == data.notify and (GameMgr.inCombat or Me:isLookOn())then
        DlgMgr:closeDlg("CombatViewDlg", nil, true)
        DlgMgr:openDlg("CombatViewDlg")
    end
end

function FightMgr:MSG_LC_SHOW_SKIP_LOOK_ON(data)
    DlgMgr:sendMsg("FightLookOnDlg", "swicthSkipModel")
end

function FightMgr:cmdSkipLookOn()
    gf:CmdToServer("CMD_SKIP_LOOK_ON")
end

function FightMgr:cmdLookOn(id)
    gf:CmdToServer("CMD_LOOK_ON", {id = id})
end

function FightMgr:cmdQuitLookOn()
    gf:CmdToServer("CMD_QUIT_LOOK_ON")
end

function FightMgr:setFightFullScreenEffect(icon, magic)
    if not self.fightFullScreenEffect then
        self.fightFullScreenEffect = {}
    end

    self.fightFullScreenEffect[magic] = icon
end

function FightMgr:clearFihgtFullScreenEffect()
    if self.fightFullScreenEffect then
        for magic, icon in pairs(self.fightFullScreenEffect) do
            if magic and magic.removeFromParent and "function" == type(magic.removeFromParent)then
                magic:removeFromParent(true)
            end
        end
    end

    self.fightFullScreenEffect = {}
end

function FightMgr:MSG_START_TASK_COMBAT(data)
    self.battleType = data.task_name
end

function FightMgr:getBattleType()
    return self.battleType
end

function FightMgr:clearBattleType()
    self.battleType = nil
end

function FightMgr:getFightAutoTalkById(id)
    if not self.autoTalk then return end

    if not id then return self.autoTalk end
    return self.autoTalk[id]
end

function FightMgr:MSG_AUTO_TALK_DATA(data)
    -- 战斗自动喊话数据
    if not self.autoTalk then self.autoTalk = {} end
    if data.content == "" then
        self.autoTalk[data.id] = {}
    else
        data.content = string.gsub(data.content, "\\/", "/")
        data.content = string.gsub(data.content, "\\u", "")
        local talkData = json.decode(data.content)
        self.autoTalk[data.id] = talkData
    end
end

-- 收到该消息，当场战斗抓捕不需要条件
function FightMgr:MSG_C_UNRESERVED_CATCH(data)
    if data.count > 0 then
        self.notCatchCondition = true
    end
end

-- 战斗中切后台再切前台，需要取消服务器已保存的Me的操作指令，WDSY-28909
-- 因为服务器已保存的Me指令，再次选择Me指令将不生效，造成异常表现
function FightMgr:onEnterForeGround()
    if Me:isInCombat() then
        local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
        if pet then
            gf:sendFightCmd(pet:getId(), pet:getId(), FIGHT_ACTION.CANCEL, 0)
        end
    end
end

function FightMgr:MSG_C_STOP_LIGHT_EFFECT(data)

    local char = FightMgr:getObjectById(data.charId)
    if char then
        char:deleteMagic(data.effectIcon)
    end
end

function FightMgr:MSG_COMBAT_LIGHT_EFFECT(map)
    local obj = self:getObjectById(map.charId)
    if obj then
        obj:playLoopEffectForLogin(map)
    end
end

function FightMgr:MSG_C_UPDATE_DATA(data)
    data["update_me_and_pet"] = 1
    data["pos"] = self:getObjectPosById(data.id)
    self:absorbBasicFields(data)
end

function FightMgr:MSG_LC_UPDATE_DATA(data)
    self:MSG_C_UPDATE_DATA(data)
end

function FightMgr:getBattleArrayInfo()
    return self.battleArrayInfo
end

function FightMgr:MSG_BATTLE_ARRAY_INFO(data)
    self.battleArrayInfo = data
end

-- 战斗指挥战斗数据
function FightMgr:MSG_TEAM_COMMANDER_COMBAT_DATA(data)
    for i = 0, FightPosMgr.OBJ_NUM - 1 do
        if self.objs[i] and self.objs[i].commandText then
            self.objs[i].commandText:setVisible(false)
        end
    end

    for i = 1, data.count do
        local obj = self:getObjectById(data[i].id)
        if obj then
            obj:addCommandText(data[i].command)
        end
    end
end

-- 初始化
FightMgr:init()
EventDispatcher:addEventListener("ENTER_FOREGROUND", FightMgr.onEnterForeGround)
MessageMgr:regist("MSG_TEAM_COMMANDER_COMBAT_DATA", FightMgr)
MessageMgr:regist("MSG_C_UNRESERVED_CATCH", FightMgr)
MessageMgr:regist("MSG_AUTO_TALK_DATA", FightMgr)
MessageMgr:hook("MSG_GENERAL_NOTIFY", FightMgr, "FightMgr")
MessageMgr:regist("MSG_C_START_COMBAT", FightMgr)
MessageMgr:regist("MSG_C_FRIENDS", FightMgr)
MessageMgr:regist("MSG_C_OPPONENTS", FightMgr)
MessageMgr:regist("MSG_C_WAIT_COMMAND", FightMgr)
MessageMgr:regist("MSG_C_END_COMBAT", FightMgr)
MessageMgr:regist("MSG_C_ACTION", FightMgr)
MessageMgr:regist("MSG_C_END_ACTION", FightMgr)
MessageMgr:regist("MSG_C_ACCEPT_HIT", FightMgr)
MessageMgr:regist("MSG_C_ACCEPT_MULTI_HIT", FightMgr)
MessageMgr:regist("MSG_C_LIFE_DELTA", FightMgr)
MessageMgr:regist("MSG_C_CHAR_DIED", FightMgr)
MessageMgr:regist("MSG_C_QUIT_COMBAT", FightMgr)
MessageMgr:regist("MSG_C_UPDATE", FightMgr)
MessageMgr:regist("MSG_C_FLEE", FightMgr)
MessageMgr:regist("MSG_C_MANA_DELTA", FightMgr)
MessageMgr:regist("MSG_C_CHAR_REVIVE", FightMgr)
MessageMgr:regist("MSG_C_CATCH_PET", FightMgr)
MessageMgr:regist("MSG_C_ADD_FRIEND", FightMgr)
MessageMgr:regist("MSG_C_ADD_OPPONENT", FightMgr)
MessageMgr:regist("MSG_C_UPDATE_STATUS", FightMgr)
MessageMgr:regist("MSG_C_ACCEPT_MAGIC_HIT", FightMgr)
MessageMgr:regist("MSG_C_UPDATE_IMPROVEMENT", FightMgr)
MessageMgr:regist("MSG_C_MENU_SELECTED", FightMgr)
MessageMgr:regist("MSG_C_DELAY", FightMgr)
MessageMgr:regist("MSG_C_LIGHT_EFFECT", FightMgr)
MessageMgr:regist("MSG_C_WAIT_ALL_END", FightMgr)
MessageMgr:regist("MSG_C_START_SEQUENCE", FightMgr)
MessageMgr:regist("MSG_C_OPPONENT_INFO", FightMgr)
MessageMgr:regist("MSG_C_DIALOG_OK", FightMgr)
MessageMgr:regist("MSG_C_MESSAGE", FightMgr)
MessageMgr:regist("MSG_C_ACCEPTED_COMMAND", FightMgr)
MessageMgr:regist("MSG_C_LEAVE_AT_ONCE", FightMgr)
MessageMgr:regist("MSG_C_COMMAND_ACCEPTED", FightMgr)
MessageMgr:regist("MSG_C_REFRESH_PET_LIST", FightMgr)
MessageMgr:regist("MSG_C_SANDGLASS", FightMgr)
MessageMgr:regist("MSG_C_CHAR_OFFLINE", FightMgr)
MessageMgr:regist("MSG_C_SET_FIGHT_PET", FightMgr)
MessageMgr:regist("MSG_C_SET_CUSTOM_MSG", FightMgr)
MessageMgr:regist("MSG_GODBOOK_EFFECT_NORMAL", FightMgr)
MessageMgr:regist("MSG_GODBOOK_EFFECT_SUMMON", FightMgr)
MessageMgr:regist("MSG_C_UPDATE_APPEARANCE", FightMgr)
MessageMgr:regist("MSG_SYNC_MESSAGE", FightMgr)
MessageMgr:regist("MSG_C_MENU_LIST", FightMgr)
MessageMgr:regist("MSG_PICTURE_DIALOG", FightMgr)
MessageMgr:regist("MSG_ATTACH_SKILL_LIGHT_EFFECT", FightMgr)
MessageMgr:regist("MSG_C_DIRECT_OPPONENT_INFO", FightMgr)
MessageMgr:regist("MSG_C_CUR_ROUND", FightMgr)
MessageMgr:regist("MSG_C_UPDATE_COMBAT_INFO", FightMgr)
MessageMgr:regist("MSG_C_CREATE_SEQUENCE", FightMgr)
MessageMgr:regist("MSG_C_STOP_LIGHT_EFFECT", FightMgr)
MessageMgr:regist("MSG_COMBAT_LIGHT_EFFECT", FightMgr)
MessageMgr:regist("MSG_C_UPDATE_DATA", FightMgr)

-- 观战相关
MessageMgr:regist("MSG_LC_FRIENDS", FightMgr)
MessageMgr:regist("MSG_LC_OPPONENTS", FightMgr)
MessageMgr:regist("MSG_LC_INIT_STATUS", FightMgr)
MessageMgr:regist("MSG_LC_WAIT_COMMAND", FightMgr)
MessageMgr:regist("MSG_LC_LEAVE_AT_ONCE", FightMgr)
MessageMgr:regist("MSG_LC_SANDGLASS", FightMgr)
MessageMgr:regist("MSG_LC_CHAR_OFFLINE", FightMgr)
MessageMgr:regist("MSG_LC_END_LOOKON", FightMgr)
MessageMgr:regist("MSG_LC_START_LOOKON", FightMgr)
MessageMgr:regist("MSG_LC_LOOKON_NUM", FightMgr)
MessageMgr:regist("MSG_LC_ACTION", FightMgr)
MessageMgr:regist("MSG_LC_CHAR_DIED", FightMgr)
MessageMgr:regist("MSG_LC_CHAR_REVIVE", FightMgr)
MessageMgr:regist("MSG_LC_LIFE_DELTA", FightMgr)
MessageMgr:regist("MSG_LC_MANA_DELTA", FightMgr)
MessageMgr:regist("MSG_LC_UPDATE_STATUS", FightMgr)
MessageMgr:regist("MSG_LC_ACCEPT_HIT", FightMgr)
MessageMgr:regist("MSG_LC_END_ACTION", FightMgr)
MessageMgr:regist("MSG_LC_FLEE", FightMgr)
MessageMgr:regist("MSG_LC_CATCH_PET", FightMgr)
MessageMgr:regist("MSG_LC_QUIT_COMBAT", FightMgr)
MessageMgr:regist("MSG_LC_UPDATE_IMPROVEMENT", FightMgr)
MessageMgr:regist("MSG_LC_ACCEPT_MAGIC_HIT", FightMgr)
MessageMgr:regist("MSG_LC_ADD_FRIEND", FightMgr)
MessageMgr:regist("MSG_LC_ADD_OPPONENT", FightMgr)
MessageMgr:regist("MSG_LC_UPDATE", FightMgr)
MessageMgr:regist("MSG_LC_MENU_LIST", FightMgr)
MessageMgr:regist("MSG_LC_MENU_SELECTED", FightMgr)
MessageMgr:regist("MSG_LC_DELAY", FightMgr)
MessageMgr:regist("MSG_LC_LIGHT_EFFECT", FightMgr)
MessageMgr:regist("MSG_LC_WAIT_ALL_END", FightMgr)
MessageMgr:regist("MSG_LC_START_SEQUENCE", FightMgr)
MessageMgr:regist("MSG_START_TASK_COMBAT", FightMgr)
MessageMgr:regist("MSG_LC_CREATE_SEQUENCE", FightMgr)
MessageMgr:regist("MSG_LC_SHOW_SKIP_LOOK_ON", FightMgr)
MessageMgr:regist("MSG_LC_UPDATE_DATA", FightMgr)
MessageMgr:regist("MSG_BATTLE_ARRAY_INFO", FightMgr)