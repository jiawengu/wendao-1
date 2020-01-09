-- KuafjjsxDlg.lua
-- Created by huangzz Jan/05/2018
-- 跨服竞技组队匹配筛选界面

local KuafjjsxDlg = Singleton("KuafjjsxDlg", Dialog)

local POLAR_INFO = {
    "Metal",
    "Wood",
    "Water",
    "Fire",
    "Earth",
}

local MIN_LEVEL = 100
local MAX_LEVEL = Const.PLAYER_MAX_LEVEL

local MIN_TAO = 3 * math.floor(Formula:getStdTao(100) / Const.ONE_YEAR_TAO)
local MAX_TAO = 50000

local NONE_TAG = 0

function KuafjjsxDlg:init()
    MIN_LEVEL, MAX_LEVEL = KuafjjMgr:getLimitLevel()
    MIN_TAO, MAX_TAO = KuafjjMgr:getLimitTao()
    
    self.inputCtrls = {}

    -- 等级
    local minPanel = self:getControl("MinPanel", nil , "LevelPanel")
    local maxPanel = self:getControl("MaxPanel", nil , "LevelPanel")
    minPanel:setTag(1)
    maxPanel:setTag(2)
    self:bindListener("ReduceButton", self.onReduceButton, minPanel)
    self:bindListener("AddButton", self.onAddButton, minPanel)
    self:bindListener("ReduceButton", self.onReduceButton, maxPanel)
    self:bindListener("AddButton", self.onAddButton, maxPanel)
    
    -- 绑定数字键盘
    self:bindNumInput("ConValueLabel", minPanel, nil, 1)
    self:bindNumInput("ConValueLabel", maxPanel, nil, 2)
    self.inputCtrls[1] = minPanel
    self.inputCtrls[2] = maxPanel
    
    -- 道行
    local minPanel = self:getControl("MinPanel", nil , "TaoPanel")
    local maxPanel = self:getControl("MaxPanel", nil , "TaoPanel")
    minPanel:setTag(3)
    maxPanel:setTag(4)
    self:bindListener("ReduceButton", self.onReduceButton, minPanel)
    self:bindListener("AddButton", self.onAddButton, minPanel)
    self:bindListener("ReduceButton", self.onReduceButton, maxPanel)
    self:bindListener("AddButton", self.onAddButton, maxPanel)
    
    -- 绑定数字键盘
    self:bindNumInput("ConValueLabel", minPanel, nil, 3)
    self:bindNumInput("ConValueLabel", maxPanel, nil, 4)
    self.inputCtrls[3] = minPanel
    self.inputCtrls[4] = maxPanel
    
    self:bindListener("AgreeButton", self.onAgreeButton)
    
    self:bindListener("BKImage", self.onSelectAllPolar, "AllPolarPanel") 
    
    for i = 1, #POLAR_INFO do
        local img = self:getControl("BKImage", nil, POLAR_INFO[i] .. "Panel")
        img:setTag(i)
        self:bindTouchEndEventListener(img, self.onSelectPolar)
    end
    
    -- 相性
    self.choosePolars = {}
    
    -- 设置默认数值
    self:setDefaultNum()
end

-- 选择具体相性
function KuafjjsxDlg:onSelectPolar(sender, eventType) 
    local tag = sender:getTag()
    local panel = sender:getParent()
    
    self.choosePolars[tag] = not self.choosePolars[tag]
    self:setCtrlVisible("ChosenImage", self.choosePolars[tag], panel)
    
    self.choosePolars[NONE_TAG] = false
    self:setCtrlVisible("ChosenImage", false, "AllPolarPanel")
end

-- 选择随机相性
function KuafjjsxDlg:onSelectAllPolar(sender, eventType)
    local panel = sender:getParent()
    
    if self.choosePolars[NONE_TAG] then
        self.choosePolars[NONE_TAG] = false
        self:setCtrlVisible("ChosenImage", false, panel)
    else
        self.choosePolars[NONE_TAG] = true
        self:setCtrlVisible("ChosenImage", true, panel)
        for i = 1, #POLAR_INFO do
            local panel = self:getControl(POLAR_INFO[i] .. "Panel")
            self:setCtrlVisible("ChosenImage", false, panel)
            self.choosePolars[i] = false
        end
    end
end

-- 设置默认数值
function KuafjjsxDlg:setDefaultNum()
    local matchInfo = TeamMgr:getCurMatchInfo() or {}
    local minLevel = matchInfo.minLevel or 0
    local maxLevel = matchInfo.maxLevel or 0
    local minTao = matchInfo.minTao or 0
    local maxTao = matchInfo.maxTao or 0
    local polars = matchInfo.polars or {}
    
    if minLevel <= 0 or  maxLevel <= 0 then 
        minLevel, maxLevel = KuafjjMgr:getDefaultLevel()
    end
    
    if maxTao <= 0 or minTao <= 0 then
        minTao, maxTao = KuafjjMgr:getDefaultTao()
    end
    
    local cou = #polars
    if cou == 0 or cou == 5 then
        self:onSelectAllPolar(self:getControl("BKImage", nil, "AllPolarPanel"))
    else
        for i = 1, cou do
            self:onSelectPolar(self:getControl("BKImage", nil, POLAR_INFO[polars[i]] .. "Panel"))
        end
    end
    
    -- 默认显示的等级
    local minPanel = self:getControl("MinPanel", nil , "LevelPanel")
    local maxPanel = self:getControl("MaxPanel", nil , "LevelPanel")
    self:setLabelText("ConValueLabel", minLevel, minPanel)
    self:setLabelText("ConValueLabel", maxLevel, maxPanel)
    
    -- 默认显示的道行
    local minPanel = self:getControl("MinPanel", nil , "TaoPanel")
    local maxPanel = self:getControl("MaxPanel", nil , "TaoPanel")
    self:setLabelText("ConValueLabel", minTao, minPanel)
    self:setLabelText("ConValueLabel", maxTao, maxPanel)
    
    self.nums = {minLevel, maxLevel, minTao, maxTao}
    
    -- 等级、道行范围提示
    self:setLabelText("LeftLabel", CHS[5400415] .. " " .. MIN_LEVEL .. " ~ " .. MAX_LEVEL, "LevelPanel")
    self:setLabelText("LeftLabel", CHS[5400416] .. " " .. MIN_TAO .. " ~ " .. MAX_TAO, "TaoPanel")
end

function KuafjjsxDlg:onReduceButton(sender, eventType)
    local panel = sender:getParent()
    local tag = panel:getTag()
    local reduceNum = 1
    if tag > 2 then
        reduceNum = 1000
    end

    self.nums[tag] = self:checkDownLimitNum(self.nums[tag] - reduceNum, tag)
    
    self:setLabelText("ConValueLabel", self.nums[tag], panel)
end

function KuafjjsxDlg:onAddButton(sender, eventType)
    local panel = sender:getParent()
    local tag = panel:getTag()
    local addNum = 1
    if tag > 2 then
        addNum = 1000
    end
    
    self.nums[tag] = self:checkUpLimitNum(self.nums[tag] + addNum, tag)

    self:setLabelText("ConValueLabel", self.nums[tag], panel)
end

-- 检查上边界
function KuafjjsxDlg:checkUpLimitNum(num, tag)
    if tag == 1 then
        if num > self.nums[tag + 1] then
            gf:ShowSmallTips(CHS[5400376]) 
            return self.nums[tag + 1]
        end
    elseif tag == 2 then
        if num > MAX_LEVEL then 
            gf:ShowSmallTips(string.format(CHS[5400378], MAX_LEVEL)) 
            return MAX_LEVEL
        end
    elseif tag == 3 then
        if num > self.nums[tag + 1] then
            gf:ShowSmallTips(CHS[5400380]) 
            return self.nums[tag + 1]
        end
    elseif tag == 4 then
        if num > MAX_TAO then
            gf:ShowSmallTips(string.format(CHS[5400382], MAX_TAO)) 
            return MAX_TAO
        end
    end
    
    return num
end

-- 检查下边界
function KuafjjsxDlg:checkDownLimitNum(num, tag)
    if tag == 1 then
        if num < MIN_LEVEL then
            gf:ShowSmallTips(string.format(CHS[5400375], MIN_LEVEL))
            return MIN_LEVEL
        end
    elseif tag == 2 then
        if num < self.nums[tag - 1] then
            gf:ShowSmallTips(CHS[5400377])
            return self.nums[tag - 1]
        end
    elseif tag == 3 then
        if num < MIN_TAO then
            gf:ShowSmallTips(string.format(CHS[5400379], MIN_TAO))
            return MIN_TAO
        end
    elseif tag == 4 then
        if num < self.nums[tag - 1] then
            gf:ShowSmallTips(CHS[5400381]) 
            return self.nums[tag - 1]
        end
    end
    
    return num
end


-- 数字键盘插入数字
function KuafjjsxDlg:insertNumber(num, key)
    self.nums[key] = self:checkUpLimitNum(num, key)
    
    self:setLabelText("ConValueLabel", self.nums[key], self.inputCtrls[key])

    -- 更新键盘数据
    local dlg = DlgMgr:getDlgByName("SmallNumInputDlg")
    if dlg then
        dlg:setInputValue(self.nums[key])
    end
end

function KuafjjsxDlg:comfireNumber(key)
    self.nums[key] = self:checkUpLimitNum(self.nums[key], key)
    self.nums[key] = self:checkDownLimitNum(self.nums[key], key)
    self:setLabelText("ConValueLabel", self.nums[key], self.inputCtrls[key])
end

-- 确认筛选
function KuafjjsxDlg:onAgreeButton(sender, eventType)
    if KuafjjMgr:checkKuafjjIsEnd() then
        return
    end

    local polars = {}
    for key, v in pairs(self.choosePolars) do
        if v then
            table.insert(polars, key)
        end
    end
    
    if not next(polars) then
        gf:ShowSmallTips(CHS[5410215])
        return
    end
    
    -- 不限
    if polars[1] == 0 then
        polars = {1, 2, 3, 4, 5}
    end 

    local combatMode, needNum = KuafjjMgr:getCurCombatMode()
    local num = TeamMgr:getTeamTotalNum()
    if num >= needNum then
        gf:ShowSmallTips(CHS[5400426])
    elseif not combatMode then
        gf:ShowSmallTips(CHS[5400408])
    elseif needNum == 1 then
        gf:ShowSmallTips(CHS[5400409])
    else
        TeamMgr:requestMatchMember(CHS[5400341] .. combatMode, self.nums[1], self.nums[2], polars, self.nums[3], self.nums[4])
        DlgMgr:sendMsg("TeamDlg", "setMatchInfo", CHS[5400341] .. combatMode, self.nums[1], self.nums[2], polars, self.nums[3], self.nums[4])
    end
    
    self:onCloseButton()
end

return KuafjjsxDlg
