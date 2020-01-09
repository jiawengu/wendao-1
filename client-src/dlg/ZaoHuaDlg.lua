-- ZaoHuaDlg.lua
-- Created by songcw June/20/2017
-- 造化之池

local ZaoHuaDlg = Singleton("ZaoHuaDlg", Dialog)

ZaoHuaDlg.lastOpenTime = 0

-- 造化之池进度条特效上方粒子高度
local EFFECT_EXTRA_HEIGHT = 60

-- 造化之池进度条特效高度
local EFFECT_HEIGHT = 230

function ZaoHuaDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)

    -- 请求数据
    GiftMgr:requestZaohuaData()

    self:setCtrlVisible("ActiveValueImage", false)

    self:hookMsg("MSG_OPEN_ZAOHUA_ZHICHI")

    if not gf:isSameDay5(self.lastOpenTime, gf:getServerTime()) or self.id ~= Me:queryBasic("gid") then
        self.data = nil
    end

    if self.data then
        self:MSG_OPEN_ZAOHUA_ZHICHI(self.data)
    end

    self.lastOpenTime = gf:getServerTime()
    self.id = Me:queryBasic("gid")
end

function ZaoHuaDlg:onConfirmButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[5000229])
        return
    end

    -- 等级
    if Me:queryBasicInt("level") < 70 or Me:queryBasicInt("level") >= 110 then
        gf:ShowSmallTips(CHS[4200393])  -- 当前等级无法吸收造化之力
        return
    end

    local userStr = ""
    if Me:queryBasicInt("lock_exp") == 1 then
        userStr = CHS[4200394]
    end

    local petStr = ""
    if PetMgr:getFightPet() and PetMgr:getFightPet():queryBasicInt("lock_exp") == 1 then
        petStr = CHS[4200395]
    end

    if PetMgr:getChangePet() and PetMgr:getChangePet():queryBasicInt("lock_exp") == 1 then
        petStr = CHS[4200395]
    end

    local str = userStr
    if str ~= "" and petStr ~= "" then
        str = str .. "、" .. petStr
    elseif str == "" and petStr ~= "" then
        str = str .. petStr
    end

    if str ~= "" then
        gf:confirm(string.format(CHS[4200396], str), function ()
            GiftMgr:recvZaohua()
        end)
    else
        GiftMgr:recvZaohua()
    end
end

function ZaoHuaDlg:getEffY(data, height)
    if data.total == 0 or data.rec_times >= 2 then
        -- 没有活跃度或者至少吸收 2 次了，为空
        return - EFFECT_HEIGHT / 2
    elseif data.total >= 100 and data.rec_times <= 0 then
        -- 满值且没吸收过
        return math.min(data.total, 100) * 0.01 * height + EFFECT_EXTRA_HEIGHT - EFFECT_HEIGHT / 2 + 10
    else
        local progress = math.min(data.total, 100)
        if data.rec_times == 1 then
            -- 吸收一次减 50
            progress = math.max(progress - 50, 0)
        end

        if progress == 0 then
            return - EFFECT_HEIGHT / 2
        end

        return progress * 0.01 * height + EFFECT_EXTRA_HEIGHT - EFFECT_HEIGHT / 2
    end
end

function ZaoHuaDlg:MSG_OPEN_ZAOHUA_ZHICHI(data)
    self.data = data
    self:setData(data)
end

function ZaoHuaDlg:setData(data)
    -- 光效
    local magic = self:getLoopMagicFromCtrl("EffectPanel", ResMgr.magic.zaohua)
    local effPanel = self:getControl("EffectPanel")
    if magic then
        if self.moveAct then
            self.root:stopAction(self.moveAct)
            self.moveAct = nil
        end
        local newY = self:getEffY(data, effPanel:getContentSize().height)
        self.moveAct = cc.MoveTo:create(0.5, cc.p(magic:getPositionX(), newY))
        magic:runAction(self.moveAct)
    else
        local pos = cc.p(effPanel:getContentSize().width / 2,effPanel:getContentSize().height / 2)
        pos.y = self:getEffY(data, effPanel:getContentSize().height)
        self:addLoopMagicToCtrl("EffectPanel", ResMgr.magic.zaohua, nil, pos)
    end

    -- 当前次数
    self:setLabelText("Label_144", string.format(CHS[4200397], data.count))

    -- 按钮
    self:setCtrlEnabled("ConfirmButton", data.count > 0)

    -- 进度条
    self:setProgressBar("activityProgressBar", data.total, 100)
    local activeValueImage = self:getControl("ActiveValueImage")
    self:setLabelText("Label_1", data.total, activeValueImage)
    self:setLabelText("Label_2", data.total, activeValueImage)
    local posx
    local activeProgress = self:getControl("activityProgressBar")
    if data.total > 100 then
        posx = activeProgress:getContentSize().width * (100 / 100)
    else
        posx = activeProgress:getContentSize().width * (data.total / 100)
    end

    activeValueImage:stopAllActions()
    performWithDelay(activeValueImage, function ()
        activeValueImage:setVisible(true)
        activeValueImage:setPositionX(posx)
    end, 0)

end

return ZaoHuaDlg
