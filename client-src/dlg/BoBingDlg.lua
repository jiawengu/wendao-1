-- BoBingDlg.lua
-- Created by sujl, Aug/24/2016
-- 中秋博饼界面

local BoBingDlg = Singleton("BoBingDlg", Dialog)
local SliceImage = {
    ResMgr.ui.bobing_touzi1,   -- 1
    ResMgr.ui.bobing_touzi2,   -- 2
    ResMgr.ui.bobing_touzi3,   -- 3
    ResMgr.ui.bobing_touzi5,   -- 5
    ResMgr.ui.bobing_touzi6,   -- 6
    ResMgr.ui.bobing_touzi4,   -- 4
}

local BB_BonusType = {
    None    = 0,    -- 无
    Wzw     = 1,    -- 状元插金花
    Mth     = 2,    -- 满堂红
    Bdj     = 3,    -- 遍地锦
    Lbh     = 4,    -- 六勃黑
    Ww      = 5,    -- 五王
    Wz      = 6,    -- 五子
    Zy      = 7,    -- 状元
    Dt      = 8,    -- 对堂
    Sh      = 9,    -- 三红
    Sj      = 10,   -- 四进
    Ej      = 11,   -- 二举
    Yx      = 12,   -- 一秀
    Gg      = 13,   -- 杠龟
}

function BoBingDlg:init()
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("BoBingButton", self.onBoBingButton)
    self:bindListener("ShaiZiImage", self.onShaiZi, "TimesPanel")

    self.dices = {}
    for i = 1, 6 do
        self.dices[i] = self:getControl("Image_" .. i, nil, "BowlImage")
    end

    self.timesLabel = self:setNumImgForPanel("TimesLabel", ART_FONT_COLOR.DEFAULT, 0, false, LOCATE_POSITION.MID, 21, "TimesPanel")

    self:refreshTimes()

    -- 播放动画过程有可能界面被关闭
    -- 尝试领取奖励
    gf:CmdToServer('CMD_MOONCAKE_GAMEBLING', { ["oper"] = 2 })

    self:hookMsg("MSG_MOONCAKE_GAMEBLING_RESULT")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_AUTUMN_2017_BUY")
    
    -- 试试手气按钮屏蔽
    self:setCtrlVisible("TryButton", false)
end

function BoBingDlg:cleanup()
    self.curMagic = nil

    DlgMgr:closeDlg("TouZiBuyDlg")

    ArmatureMgr:removeUIArmature(ResMgr.ArmatureMagic.bobing_prize.name)
    ArmatureMgr:removeUIArmature(ResMgr.ArmatureMagic.bobing_toutouzi.name)
end

function BoBingDlg:refreshTimes()
    local items = InventoryMgr:getItemByName(CHS[5450281])
    if items and #items > 0 then
        self.timesLabel:setNum(items[1].amount)
    else
        self.timesLabel:setNum(0)
    end
end

-- 播放骨骼动画
function BoBingDlg:createArmatureAction(icon, actionName, callback)
    local magic = ArmatureMgr:createArmature(icon)

    local function func(sender, etype, id)
        if self.curMagic ~= magic then return end
        if etype == ccs.MovementEventType.complete then
            magic:stopAllActions()
            magic:removeFromParent(true)
            self.curMagic = nil
            if callback and "function" == type(callback) then callback() end
        end
    end

    local showPanel = self:getControl("BowlImage")
    magic:setAnchorPoint(0.5, 0.5)
    local size = showPanel:getContentSize()
    magic:setPosition(size.width / 2, size.height / 2)
    showPanel:addChild(magic)

    magic:getAnimation():setMovementEventCallFunc(func)
    magic:getAnimation():play(actionName)

    self.curMagic = magic
    self.curMagic.quickFinish = function()
        magic:stopAllActions()
        magic:removeFromParent(true)
        self.curMagic = nil
    end
end

function BoBingDlg:setSlicesVisible(visible)
    for i = 1, #self.dices do
        self.dices[i]:setVisible(visible)
    end
end

function BoBingDlg:playBobing(callback)
    if self.curMagic and self.curMagic.quickFinish then
        self.curMagic.quickFinish()
    end

    self:setSlicesVisible(false)
    self:createArmatureAction(ResMgr.ArmatureMagic.bobing_toutouzi.name, "Top", function()
        self:setSlicesVisible(true)
        if callback then callback() end
    end)
    SoundMgr:playEffect(CHS[2000120])
end

function BoBingDlg:playPrize(actionName)
    self:createArmatureAction(ResMgr.ArmatureMagic.bobing_prize.name, actionName)
end

function BoBingDlg:makeSlice(bonus)
    if BB_BonusType.None == bonus or BB_BonusType.Gg == bonus then
        self:makeGg()
    elseif BB_BonusType.Wzw == bonus then
        self:makeWzw()
    elseif BB_BonusType.Mth == bonus then
        self:makeMth()
    elseif BB_BonusType.Bdj == bonus then
        self:makeBdj()
    elseif BB_BonusType.Lbh == bonus then
        self:makeLbh()
    elseif BB_BonusType.Ww == bonus then
        self:makeWw()
    elseif BB_BonusType.Wz == bonus then
        self:makeWz()
    elseif BB_BonusType.Zy == bonus then
        self:makeZy()
    elseif BB_BonusType.Dt == bonus then
        self:makeDt()
    elseif BB_BonusType.Sh == bonus then
        self:makeSh()
    elseif BB_BonusType.Sj == bonus then
        self:makeSj()
    elseif BB_BonusType.Ej == bonus then
        self:makeEj()
    elseif BB_BonusType.Yx == bonus then
        self:makeYx()
    else
        self:makeGg()
    end
end

-- 杠龟
function BoBingDlg:makeGg(notShow)
    local vs = {}
    for i = 1, #self.dices do
        local v
        repeat
            v = math.random(1, 5)
        until(nil == vs[v] or vs[v] < 3)
        if vs[v] then
            vs[v] = tonumber(vs[v]) + 1
        else
            vs[v] = 1
        end

        self:setImagePlist("Image_" .. i, SliceImage[v], "BowlImage")
    end

    if not notShow then
        self:playPrize("Top")
    end
end

-- 一秀
function BoBingDlg:makeYx()
    local vs = {}
    local vi = {}
    for i = 1, #self.dices do
        local v
        repeat
            v = math.random(1, 5)
        until(nil == vs[v] or vs[v] < 3)
        if vs[v] then
            vs[v] = tonumber(vs[v]) + 1
        else
            vs[v] = 1
        end

        vi[i] = v
        self:setImagePlist("Image_" .. i, SliceImage[v], "BowlImage")
    end

    -- 过滤对堂
    local index
    local isDt = true
    local count = 0
    repeat
        index = math.random(1, 6)
        local old = vi[index]
        vi[index] = 6
        local vv = {}
        local v
        for i = 1, #vi do
           v = vi[i]
           vv[v] = (vv[v] or 0) + 1
        end

        count = 0
        for k, _ in pairs(vv) do
            count = count + 1
        end

        if count >= 6 then
            vi[index] = old
        end

    until count < 6

    self:setImagePlist("Image_" .. index, SliceImage[6], "BowlImage")

    self:playPrize("Top02")
end

-- 二举
function BoBingDlg:makeEj()
    local index = {}
    for i = 1, 2 do
        local k
        repeat
            k = math.random(1, #self.dices)
        until (nil == index[k])
        index[k] = true
    end

    self:makeGg(true)
    for k, _ in pairs(index) do
        self:setImagePlist("Image_" .. k, SliceImage[6], "BowlImage")
    end

    self:playPrize("Top03")
end

-- 四进
function BoBingDlg:makeSj()
    local index = {}
    for i = 1, 4 do
        local k = math.random(1, #self.dices)
        while index[k] do
            k = math.random(1, #self.dices)
        end
        index[k] = 1
    end

    local v = math.random(1, 5)
    for i = 1, #self.dices do
        if index[i] then
            self:setImagePlist("Image_" .. i, SliceImage[v], "BowlImage")
        else
            local k
            repeat
                k = math.random(1, 6)
            until (k ~= v)
            self:setImagePlist("Image_" .. i, SliceImage[k], "BowlImage")
        end
    end

    self:playPrize("Top04")
end

-- 三红
function BoBingDlg:makeSh()
    local index = {}
    for i = 1, 3 do
        local k = math.random(1, #self.dices)
        while index[k] do
            k = math.random(1, #self.dices)
        end
        index[k] = 1
    end

    for i = 1, #self.dices do
        if index[i] then
            self:setImagePlist("Image_" .. i, SliceImage[6], "BowlImage")
        else
            self:setImagePlist("Image_" .. i, SliceImage[math.random(1, 5)], "BowlImage")
        end
    end

    self:playPrize("Top05")
end

-- 对堂
function BoBingDlg:makeDt()
    local index = {}
    for i = 1, #self.dices do
        local k
        repeat
            k = math.random(1, 6)
        until (nil == index[k])
        index[k] = 1
        self:setImagePlist("Image_" .. i, SliceImage[k], "BowlImage")
    end

    self:playPrize("Top06")
end

-- 状元
function BoBingDlg:makeZy()
    local index = {}
    for i = 1, 4 do
        local k = math.random(1, #self.dices)
        while index[k] do
            k = math.random(1, #self.dices)
        end
        index[k] = 1
    end

    for i = 1, #self.dices do
        if index[i] then
            self:setImagePlist("Image_" .. i, SliceImage[6], "BowlImage")
        else
            self:setImagePlist("Image_" .. i, SliceImage[math.random(2, 5)], "BowlImage")
        end
    end

    self:playPrize("Top07")
end

-- 五子
function BoBingDlg:makeWz()
    local index = {}
    for i = 1, 5 do
        local k = math.random(1, #self.dices)
        while index[k] do
            k = math.random(1, #self.dices)
        end
        index[k] = 1
    end

    local v = math.random(1, 5)
    for i = 1, #self.dices do
        if index[i] then
            self:setImagePlist("Image_" .. i, SliceImage[v], "BowlImage")
        else
            local k
            repeat
                k = math.random(1, 6)
            until (k ~= v)
            self:setImagePlist("Image_" .. i, SliceImage[k], "BowlImage")
        end
    end

    self:playPrize("Top08")
end

-- 五王
function BoBingDlg:makeWw()
    local index = {}
    for i = 1, 5 do
        local k = math.random(1, #self.dices)
        while index[k] do
            k = math.random(1, #self.dices)
        end
        index[k] = 1
    end

    for i = 1, #self.dices do
        if index[i] then
            self:setImagePlist("Image_" .. i, SliceImage[6], "BowlImage")
        else
            self:setImagePlist("Image_" .. i, SliceImage[math.random(1, 5)], "BowlImage")
        end
    end

    self:playPrize("Top09")
end

-- 六勃黑
function BoBingDlg:makeLbh()
    local v
    repeat
        v = math.random(1, 6)
    until (1 ~= v and 6 ~= v)

    for i = 1, #self.dices do
        self:setImagePlist("Image_" .. i, SliceImage[v], "BowlImage")
    end

    self:playPrize("Top10")
end

-- 遍地锦
function BoBingDlg:makeBdj()
    for i = 1, #self.dices do
        self:setImagePlist("Image_" .. i, SliceImage[1], "BowlImage")
    end

    self:playPrize("Top11")
end

-- 满堂红
function BoBingDlg:makeMth()
    for i = 1, #self.dices do
        self:setImagePlist("Image_" .. i, SliceImage[6], "BowlImage")
    end

    self:playPrize("Top12")
end

-- 王中王
function BoBingDlg:makeWzw()
    local index = {}
    for i = 1, 4 do
        local k = math.random(1, #self.dices)
        while index[k] do
            k = math.random(1, #self.dices)
        end
        index[k] = 1
    end

    for i = 1, #self.dices do
        if index[i] then
            self:setImagePlist("Image_" .. i, SliceImage[6], "BowlImage")
        else
            self:setImagePlist("Image_" .. i, SliceImage[1], "BowlImage")
        end
    end

    self:playPrize("Top13")
end

function BoBingDlg:setButtonEnabled(enabled)
    self:setCtrlEnabled("BoBingButton", enabled)
end

-- 奖励一览
function BoBingDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("BoBingInfoDlg")
end

-- 博饼
function BoBingDlg:onBoBingButton(sender, eventType)
    local items = InventoryMgr:getItemByName(CHS[5450281])
    if not items or #items <= 0 or items[1].amount <= 0 then
        -- 玩家骰子数量不足
        gf:ShowSmallTips(CHS[2000122])
        return
    end

    if Me:getLevel() < 30 then
        -- 玩家等级<30
        gf:ShowSmallTips(CHS[2000123])
        return
    end

    local count = InventoryMgr:getEmptyPosCount()
    if not count or count <= 0 then
        -- 包裹没有空位置
        gf:ShowSmallTips(CHS[2000124])
        return
    end

    gf:frozenScreen(5000)
    self:setButtonEnabled(false)
    gf:CmdToServer('CMD_MOONCAKE_GAMEBLING', { ["oper"] = 0 })
end

-- 骰子
function BoBingDlg:onShaiZi(sender, eventType)
    gf:CmdToServer("CMD_AUTUMN_2017_BUY", {flag = 0})
end

-- 返回奖励结果
function BoBingDlg:MSG_MOONCAKE_GAMEBLING_RESULT(data)
    if data.bonus < 0 then
        -- 博饼失败
        self:setButtonEnabled(true)
        gf:unfrozenScreen()

        if data.bonus == -4 then
            self:onCloseButton()
        end
        return
    end

    self:playBobing(function()
        self:makeSlice(data.bonus)
        self:setButtonEnabled(true)
        gf:unfrozenScreen()
        gf:CmdToServer('CMD_MOONCAKE_GAMEBLING', { ["oper"] = 2 })  -- 领取奖励
    end)

    self:refreshTimes()
end

function BoBingDlg:MSG_INVENTORY(data)
    self:refreshTimes()
end

function BoBingDlg:MSG_AUTUMN_2017_BUY(data)
    local dlg = DlgMgr:openDlg("TouZiBuyDlg")
    dlg:MSG_AUTUMN_2017_BUY(data)
end

return BoBingDlg