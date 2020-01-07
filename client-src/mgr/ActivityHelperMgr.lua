-- ActivityHelperMgr.lua
-- created by lixh Aug/22/2018
-- 活动帮助管理器
-- 主要用于特殊节日、礼包等活动的数据管理、打开界面等操作

ActivityHelperMgr = Singleton()

-- 特效配置
local EFFECT_CFG = {
    ["qixi_2019_qqzy"] = {effect = ResMgr.ArmatureMagic.qixi_color_flower, blackLayer = true},
}

function ActivityHelperMgr:clearData()
    self.shntmData = nil
end

-- 是否是守护南天门怪物
function ActivityHelperMgr:isShntmMonster(id)
    if self.shntmData and self.shntmData.monsterIdMap[id] then
        return true
    end

    return false
end

-- 随机事件之守卫南天门失败
function ActivityHelperMgr:MSG_SHNTM_FAIL(data)
    self.shntmData = data

    -- 剩余怪物喊话，并以1.4倍速度冲破南天门
    for k, v in pairs(self.shntmData.monsterIdMap) do
        local monster = CharMgr:getChar(k)
        if monster then
            ChatMgr:sendCurChannelMsgOnlyClient({
                id = k,
                gid = 0,
                icon = monster:queryBasicInt("icon"),
                name = monster:getName(),
                msg =  CHS[7100399],
            })

            monster:setSeepPrecentByClient(40)
            monster:setEndPos(self.shntmData.x, self.shntmData.y)
        end
    end

    -- 注册守卫南天门帧函数
    GameMgr:registFrameFunc("shntm", function()
        if not self.shntmData then
            -- 取消守卫南天门帧函数
            GameMgr:unRegistFrameFunc("shntm")
            self.shntmData = nil
            return
        end

        local monsterIdMap = self.shntmData.monsterIdMap
        local tarX, tarY = self.shntmData.x, self.shntmData.y
        local notRemoveIdMap = {}
        local notRemoveCount = 0
        for k, v in pairs(monsterIdMap) do
            local monster = CharMgr:getChar(k)
            if monster then
                local posX, posY = gf:convertToMapSpace(monster.curX, monster.curY)
                if posX == tarX and posY == tarY then
                    -- 已经到达目的地的怪物直接析构
                    CharMgr:deleteChar(k)
                else
                    notRemoveIdMap[k] = true
                    notRemoveCount = notRemoveCount + 1
                end
            end
        end

        if notRemoveCount == 0 then
            self.shntmData = nil
        else
            self.shntmData.monsterIdMap = notRemoveIdMap
        end
    end, nil, true)
end

-- 是否在2019暑假冰火考验游戏中
function ActivityHelperMgr:isInBhkySummer2019()
    if MapMgr:getCurrentMapName() == CHS[7190602] then
        return true
    end

    return false
end

-- 进入2019年暑假冰火考验活动
function ActivityHelperMgr:enterSummerdayBhky2019(data)
    -- 打开游戏信息界面
    local dlg = DlgMgr.dlgs["BinghkyDlg"]
    if not dlg then
        dlg = DlgMgr:openDlg("BinghkyDlg")
    end

    dlg:setData(data)

    local chatDlg = DlgMgr.dlgs["ChatDlg"]
    if chatDlg then chatDlg:setVisible(false) end
end

-- 2019年暑假冰火考验开始游戏
function ActivityHelperMgr:MSG_SUMMER_2019_BHKY_START(data)
    self:enterSummerdayBhky2019(data)
end

function ActivityHelperMgr:MSG_WQX_QUESTION_DATA(data)
    if data.stage == "verify" then
        -- 验证答题
        DlgMgr:openDlgEx("WenqxVerifyDlg", data)
    else
        DlgMgr:openDlgEx("WenqxDlg", data)
    end
end

function ActivityHelperMgr:MSG_WQX_HELP_QUESTION_DATA(data)
    DlgMgr:openDlgEx("WenqxQuestionInfoDlg", data)
end

function ActivityHelperMgr:MSG_WQX_STAGE_RESULT(data)
    if data.stage ~= "verify" then
        if not DlgMgr:getDlgByName("WenqxDlg") then
            local dlg = DlgMgr:openDlgEx("WenqxDlg")
            dlg:MSG_WQX_STAGE_RESULT(data)
        end
    end
end

-- 在屏幕中间播放特效
function ActivityHelperMgr:MSG_PLAY_EFFECT(data)
    local effectCfg = EFFECT_CFG[data.name]
    if not effectCfg then
        return
    end

    local uiLayer = gf:getUILayer()

    if effectCfg.blackLayer then
        -- 需要置灰屏幕效果
        local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 153))
        colorLayer:setAnchorPoint(0, 0)
        colorLayer:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
        colorLayer:setName("ActivityColorLayer")
        uiLayer:addChild(colorLayer)
    end

    gf:createArmatureOnceMagic(effectCfg.effect.name, effectCfg.effect.action, uiLayer, function()
        -- 回调中尝试移除置灰效果
        local colorLayer = uiLayer:getChildByName("ActivityColorLayer")
        if colorLayer then
            colorLayer:removeFromParent()
            colorLayer = nil
        end
    end, nil, nil, Const.WINSIZE.width / Const.UI_SCALE / 2, Const.WINSIZE.height / Const.UI_SCALE / 2)
end

function ActivityHelperMgr:MSG_QIXI_2019_LMQG_INFO(data)

    DlgMgr:openDlgEx("LangmqgDlg", data)
end

MessageMgr:regist("MSG_QIXI_2019_LMQG_INFO", ActivityHelperMgr)
MessageMgr:regist("MSG_PLAY_EFFECT", ActivityHelperMgr)
MessageMgr:regist("MSG_WQX_STAGE_RESULT", ActivityHelperMgr)
MessageMgr:regist("MSG_WQX_HELP_QUESTION_DATA", ActivityHelperMgr)
MessageMgr:regist("MSG_WQX_QUESTION_DATA", ActivityHelperMgr)
MessageMgr:regist("MSG_SUMMER_2019_BHKY_START", ActivityHelperMgr)
MessageMgr:regist("MSG_SHNTM_FAIL", ActivityHelperMgr)
