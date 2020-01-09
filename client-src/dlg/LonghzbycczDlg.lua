-- LonghzbycczDlg.lua
-- Created by songcw Nov/28/2016
-- 龙争虎斗有奖预测界面

local LonghzbycczDlg = Singleton("LonghzbycczDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

-- 等级段选择
local LEVEL_RANGE_CHECKBOX = {
    "LevelCheckBox_1",
    "LevelCheckBox_2",
    "LevelCheckBox_3",
    "LevelCheckBox_4",
}

-- 积分淘汰赛单选框
local SCORE_WAR_CHECKBOX = {
    "ScoreQLCheckBox",
    "ScoreBHCheckBox",
}

-- 巅峰决赛单选框
local FINAL_WAR_CHECKBOX = {
    "FinalQLCheckBox",
    "FinalBHCheckBox",
}

-- 等级段对应的key
local LEVEL_KEY = {
    ["LevelCheckBox_1"] = "60-79",
    ["LevelCheckBox_2"] = "80-89",
    ["LevelCheckBox_3"] = "90-99",
    ["LevelCheckBox_4"] = "100-109",
}

LonghzbycczDlg.key = ""

function LonghzbycczDlg:init()

    -- 点击奖励
    self:bindListener("BonusPanel", self.onBonusPanel, "PointsracePanel")  
    self:bindListener("BonusPanel", self.onBonusPanel, "FinalsPanel")  
    
    -- 对话框初始化显示,将控件该隐藏的隐藏
    self:initDisplay()
    
    -- 设置按钮的类别， 积分还是决赛,绑定点击事件
    self:setBtnType()
    
    self:hookMsg("MSG_LH_GUESS_INFO")
end

-- 设置按钮的类别， 积分还是决赛
function LonghzbycczDlg:setBtnType()
    -- =============积分赛
    local scorePanel = self:getControl("PointsracePanel")    
    -- 青龙
    local QLPanel = self:getControl("DragonGroupPanel", nil, scorePanel)
    local btnCon = self:getControl("ConfirmButton", nil, QLPanel)
    local btnMod = self:getControl("ModifyButton", nil, QLPanel)
    btnCon.race_index = LongZHDMgr.RACE_INDEX.SCORE
    btnMod.race_index = LongZHDMgr.RACE_INDEX.SCORE
    btnCon.camp_type = LongZHDMgr.WAR_RET.QL_WIN
    btnMod.camp_type = LongZHDMgr.WAR_RET.QL_WIN
    -- 事件监听
    self:bindTouchEndEventListener(btnCon, self.onConfirmButton)
    self:bindTouchEndEventListener(btnMod, self.onModifyButton)
    
    -- 白虎
    local BHPanel = self:getControl("TigerGroupPanel", nil, scorePanel)
    local btnCon = self:getControl("ConfirmButton", nil, BHPanel)
    local btnMod = self:getControl("ModifyButton", nil, BHPanel)
    btnCon.race_index = LongZHDMgr.RACE_INDEX.SCORE
    btnMod.race_index = LongZHDMgr.RACE_INDEX.SCORE
    btnCon.camp_type = LongZHDMgr.WAR_RET.BH_WIN
    btnMod.camp_type = LongZHDMgr.WAR_RET.BH_WIN
    -- 事件监听
    self:bindTouchEndEventListener(btnCon, self.onConfirmButton)
    self:bindTouchEndEventListener(btnMod, self.onModifyButton)
    -- =============积分赛
    
    -- =============决赛
    local finalsPanel = self:getControl("FinalsPanel")
    -- 青龙
    local QLPanel = self:getControl("DragonGroupPanel", nil, finalsPanel)
    local btnCon = self:getControl("ConfirmButton", nil, QLPanel)
    local btnMod = self:getControl("ModifyButton", nil, QLPanel)
    btnCon.race_index = LongZHDMgr.RACE_INDEX.FINAL
    btnMod.race_index = LongZHDMgr.RACE_INDEX.FINAL
    btnCon.camp_type = LongZHDMgr.WAR_RET.QL_WIN
    btnMod.camp_type = LongZHDMgr.WAR_RET.QL_WIN
    -- 事件监听
    self:bindTouchEndEventListener(btnCon, self.onConfirmButton)
    self:bindTouchEndEventListener(btnMod, self.onModifyButton)

    -- 白虎
    local BHPanel = self:getControl("TigerGroupPanel", nil, finalsPanel)
    local btnCon = self:getControl("ConfirmButton", nil, BHPanel)
    local btnMod = self:getControl("ModifyButton", nil, BHPanel)
    btnCon.race_index = LongZHDMgr.RACE_INDEX.FINAL
    btnMod.race_index = LongZHDMgr.RACE_INDEX.FINAL
    btnCon.camp_type = LongZHDMgr.WAR_RET.BH_WIN
    btnMod.camp_type = LongZHDMgr.WAR_RET.BH_WIN
    -- 事件监听
    self:bindTouchEndEventListener(btnCon, self.onConfirmButton)
    self:bindTouchEndEventListener(btnMod, self.onModifyButton)
end

-- 将预测的投票的checkBox设置取消状态
function LonghzbycczDlg:setVoteCheckBoxUnSelect()
    -- 预测的check状态取消选中
    self:setCheck("ScoreQLCheckBox", false)
    self:setCheck("ScoreBHCheckBox", false)
    self:setCheck("FinalQLCheckBox", false)
    self:setCheck("FinalBHCheckBox", false)
    
    self:setCtrlVisible("ScoreBHChosenImage", false)
    self:setCtrlVisible("FinalBHChosenImage", false)  
    self:setCtrlVisible("ScoreQLChosenImage", false)  
    self:setCtrlVisible("FinalQLChosenImage", false)    
end

-- 根据Panel将该panel下的青龙、白虎对应的 确认、修改按钮隐藏
function LonghzbycczDlg:setUnVisible(panel)
    -- 青龙
    local QLPanel = self:getControl("DragonGroupPanel", nil, panel)
    self:setCtrlVisible("ConfirmButton", false, QLPanel)
    self:setCtrlVisible("ModifyButton", false, QLPanel)    
    self:setCtrlVisible("LeftModifyTimesLabel", false, QLPanel)

    -- 白虎
    local BHPanel = self:getControl("TigerGroupPanel", nil, panel)
    self:setCtrlVisible("ConfirmButton", false, BHPanel)
    self:setCtrlVisible("ModifyButton", false, BHPanel)
    self:setCtrlVisible("LeftModifyTimesLabel", false, BHPanel)
end

-- 将确认和修改按钮设为隐藏状态
function LonghzbycczDlg:setAllBtnUnVisible()
    self:setUnVisible(self:getControl("PointsracePanel"))
    self:setUnVisible(self:getControl("FinalsPanel"))
end

-- 将控件该隐藏的隐藏
function LonghzbycczDlg:initDisplay()
    -- 将投票的check初始化为取消选择状态
    self:setVoteCheckBoxUnSelect()
    
    -- 投票按钮初始化为隐藏
    self:setAllBtnUnVisible()
end

-- 单选框初始化
function LonghzbycczDlg:initCheckBoxs(initSelect)
    initSelect = initSelect or LEVEL_RANGE_CHECKBOX[1]

    -- 等级段
    self.levelGroup = RadioGroup.new()
    self.levelGroup:setItems(self, LEVEL_RANGE_CHECKBOX, self.onLevelCheckBox)
    self.levelGroup:setSetlctByName(initSelect)
    --self:onLevelCheckBox(self:getControl(LEVEL_RANGE_CHECKBOX[1]))
    
    -- 积分赛单选框
    self.scoreGroup = RadioGroup.new()
    self.scoreGroup:setItems(self, SCORE_WAR_CHECKBOX, self.onScoreCheckBox)
    
    -- 巅峰决赛单选框
    self.finalGroup = RadioGroup.new()
    self.finalGroup:setItems(self, FINAL_WAR_CHECKBOX, self.onFinalCheckBox)
end

-- 选择等级段
function LonghzbycczDlg:onLevelCheckBox(sender, eventType)
    self:initDisplay()
    self.key = LEVEL_KEY[sender:getName()]
    LongZHDMgr:queryGuess(self.key)
end

-- 选择积分赛的checkbox
function LonghzbycczDlg:onScoreCheckBox(sender, eventType)
    local parentPanel = sender:getParent()    
    
    -- 显示后面的确认框
    self:setUnVisible(self:getControl("PointsracePanel"))
    self:setCtrlVisible("ConfirmButton", true, parentPanel)
end

-- 巅峰决赛的check点击
function LonghzbycczDlg:onFinalCheckBox(sender, eventType)
    local parentPanel = sender:getParent()

    -- 显示后面的确认框
    self:setUnVisible(self:getControl("FinalsPanel"))
    self:setCtrlVisible("ConfirmButton", true, parentPanel)
end

function LonghzbycczDlg:MSG_LH_GUESS_INFO(data)
    if data.race_name ~= self.key then return end
    
    if data.race_index == LongZHDMgr.RACE_INDEX.SCORE then
        local panel = self:getControl("PointsracePanel")
        local QLPanel = self:getControl("DragonGroupPanel", nil, panel)
        local BHPanel = self:getControl("TigerGroupPanel", nil, panel)
        if data.camp_type == LongZHDMgr.WAR_RET.QL_WIN then
            self:setCtrlVisible("ScoreQLChosenImage", true)
            self:setCtrlVisible("ScoreBHChosenImage", false)  
            self:setCtrlVisible("ScoreQLCheckBox", false)
            self:setCtrlVisible("ScoreBHCheckBox", false)
            self:setCheck("ScoreQLCheckBox", true)
            -- 修改按钮显示            
            self:setCtrlVisible("ModifyButton", true, QLPanel)
            
            self:setCtrlVisible("LeftModifyTimesLabel", true, QLPanel)
            self:setLabelText("LeftModifyTimesLabel", string.format(CHS[4300188], data.select_times), QLPanel)
            
        elseif data.camp_type == LongZHDMgr.WAR_RET.BH_WIN then
            self:setCtrlVisible("ScoreQLChosenImage", false)
            self:setCtrlVisible("ScoreBHChosenImage", true)    
            self:setCtrlVisible("ScoreQLCheckBox", false)
            self:setCtrlVisible("ScoreBHCheckBox", false)  
            self:setCheck("ScoreBHCheckBox", true)
            -- 修改按钮显示            
            self:setCtrlVisible("ModifyButton", true, BHPanel)  
            self:setCtrlVisible("LeftModifyTimesLabel", true, BHPanel)
            self:setLabelText("LeftModifyTimesLabel", string.format(CHS[4300188], data.select_times), BHPanel) 
        else
            self:setCtrlVisible("ScoreQLCheckBox", true)
            self:setCtrlVisible("ScoreBHCheckBox", true) 
            self:setCheck("ScoreQLCheckBox", false)
            self:setCheck("ScoreBHCheckBox", false)
            self:setCtrlVisible("ScoreQLChosenImage", false) 
            self:setCtrlVisible("ScoreBHChosenImage", false)
            self:setCtrlVisible("ModifyButton", false, BHPanel)
            self:setCtrlVisible("ModifyButton", false, QLPanel)   
            self:setCtrlVisible("LeftModifyTimesLabel", false, QLPanel)
            self:setCtrlVisible("LeftModifyTimesLabel", false, BHPanel)
        end
        
        self:setLabelText("Label_2", data.timeStr, panel)      
        panel:requestDoLayout()      
    else
        local panel = self:getControl("FinalsPanel")
        local QLPanel = self:getControl("DragonGroupPanel", nil, panel)
        local BHPanel = self:getControl("TigerGroupPanel", nil, panel)
        if data.camp_type == LongZHDMgr.WAR_RET.QL_WIN then
            self:setCtrlVisible("FinalQLChosenImage", true)
            self:setCtrlVisible("FinalQLCheckBox", false)
            self:setCtrlVisible("FinalBHCheckBox", false)
            self:setCheck("FinalQLCheckBox", true)
            -- 修改按钮显示
            self:setCtrlVisible("ModifyButton", true, QLPanel)
            
            self:setCtrlVisible("LeftModifyTimesLabel", true, QLPanel)
            self:setLabelText("LeftModifyTimesLabel", string.format(CHS[4300188], data.select_times), QLPanel)
        elseif data.camp_type == LongZHDMgr.WAR_RET.BH_WIN then
            self:setCtrlVisible("FinalBHChosenImage", true)
            self:setCtrlVisible("FinalQLCheckBox", false)
            self:setCtrlVisible("FinalBHCheckBox", false)
            self:setCheck("FinalBHCheckBox", true)
            -- 修改按钮显示            
            self:setCtrlVisible("ModifyButton", true, BHPanel)
            self:setCtrlVisible("LeftModifyTimesLabel", true, BHPanel)
            self:setLabelText("LeftModifyTimesLabel", string.format(CHS[4300188], data.select_times), BHPanel)
        else
            self:setCtrlVisible("FinalQLChosenImage", false)
            self:setCtrlVisible("FinalBHChosenImage", false)
            self:setCtrlVisible("FinalQLCheckBox", true)
            self:setCtrlVisible("FinalBHCheckBox", true)
            self:setCheck("FinalQLCheckBox", false)
            self:setCheck("FinalBHCheckBox", false)
            self:setCtrlVisible("ModifyButton", false, BHPanel)
            self:setCtrlVisible("ModifyButton", false, QLPanel) 
            self:setCtrlVisible("LeftModifyTimesLabel", false, QLPanel)
            self:setCtrlVisible("LeftModifyTimesLabel", false, BHPanel)
        end
        self:setLabelText("Label_2", data.timeStr, panel) 
        panel:requestDoLayout()    
    end
end

function LonghzbycczDlg:onConfirmButton(sender, eventType)
    local race_index = sender.race_index
    local camp_type = sender.camp_type
    
    if not race_index or not race_index then return end
    local curTime = gf:getServerTime()
    local data = LongZHDMgr:getguessDataByKey(self.key .. race_index)
    if not data then
        data = LongZHDMgr:getguessDataByKeyDef(race_index)
    end    
    
    local warName = CHS[4300189]
    if race_index == "final_race" then warName = CHS[4300190] end
    
    -- 未开始 判断
    if curTime < data.start_ti then
        gf:ShowSmallTips(string.format(CHS[4300177], warName, gf:getServerDate(CHS[4300178], data.start_ti)))
        return
    end
    
    -- 已经结束 判断
    if curTime > data.end_ti then
        gf:ShowSmallTips(string.format(CHS[4300179], warName, gf:getServerDate(CHS[4300178], data.end_ti)))
        return
    end
    
    -- 等级判断
    if Me:getLevel() < 60 then
        gf:ShowSmallTips(CHS[4300180])
        return
    end
    
    LongZHDMgr:guessCamp(self.key, race_index, camp_type)
end

function LonghzbycczDlg:onModifyButton(sender, eventType)
    local race_index = sender.race_index
    
    local data = LongZHDMgr:getguessDataByKey(self.key .. race_index)

    local curTime = gf:getServerTime()

    -- 已经结束 判断
    if curTime > data.end_ti then
        gf:ShowSmallTips(CHS[4300181])
        return
    end

    -- 等级判断
    if Me:getLevel() < 60 then
        gf:ShowSmallTips(CHS[4300182])
        return
    end
    
    -- 次数判断
    if data.select_times <= 0 then
        gf:ShowSmallTips(CHS[4300183])
        return
    end
    
    local parentPanel = sender:getParent()
    sender:setVisible(false)
    self:setCtrlVisible("ConfirmButton", true, parentPanel) 
    self:setCtrlVisible("LeftModifyTimesLabel", false, parentPanel)
    if race_index == LongZHDMgr.RACE_INDEX.SCORE then
        local panel = self:getControl("PointsracePanel")
        local QLPanel = self:getControl("DragonGroupPanel", nil, panel)
        local BHPanel = self:getControl("TigerGroupPanel", nil, panel)
        
        self:setCtrlVisible("ScoreQLChosenImage", false) 
        self:setCtrlVisible("ScoreBHChosenImage", false)
        
        self:setCtrlVisible("ScoreQLCheckBox", true)
        self:setCtrlVisible("ScoreBHCheckBox", true) 
    elseif race_index == LongZHDMgr.RACE_INDEX.FINAL then
        local panel = self:getControl("FinalsPanel")
        local QLPanel = self:getControl("DragonGroupPanel", nil, panel)
        local BHPanel = self:getControl("TigerGroupPanel", nil, panel)
        
        self:setCtrlVisible("FinalQLChosenImage", false)
        self:setCtrlVisible("FinalBHChosenImage", false)
        
        self:setCtrlVisible("FinalQLCheckBox", true)
        self:setCtrlVisible("FinalBHCheckBox", true)
    end
end

function LonghzbycczDlg:onBonusPanel(sender, eventType)
    -- 打开预测界面，选中相应的check
    local dlg = DlgMgr:openDlg("LonghzbgzDlg")  

    
    self:onCloseButton()

    performWithDelay(dlg.root, function ()
        local list = dlg:getControl("ListView")

        list:getInnerContainer():setPositionY(0)
    end, 0)

end

return LonghzbycczDlg
