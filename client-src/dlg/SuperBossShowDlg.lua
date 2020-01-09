-- SuperBossShowDlg.lua
-- Created by songcw Nov/23/2016
-- 超级大BOSS，选择boss界面

local SuperBossShowDlg = Singleton("SuperBossShowDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local SUPER_BOSS_CHECKS = {
    "BearCheckBox1",    -- 黑熊妖皇
    "BearCheckBox2",    -- 血炼魔猪
    "BearCheckBox3",    -- 赤血鬼猿
    "BearCheckBox4",    -- 魅影蝎后
}

local BOSS_SHAPE_INFO = {
    BearCheckBox1 = {icon = 06600, name = CHS[4300156], nameIcon = ResMgr.ui.super_boss_word1},      -- 黑熊妖皇
    BearCheckBox2 = {icon = 06603, name = CHS[4300157], nameIcon = ResMgr.ui.super_boss_word2},      -- 血炼魔猪
    BearCheckBox3 = {icon = 06604, name = CHS[7002094], nameIcon = ResMgr.ui.super_boss_word3},      -- 赤血鬼猿
    BearCheckBox4 = {icon = 06605, name = CHS[7002306], nameIcon = ResMgr.ui.super_boss_word4},      -- 魅影蝎后
}

function SuperBossShowDlg:init()
    -- 单选框初始化
    self:initCheckBox()
    
    -- 点评
    self:bindListener("CommentButton", self.onCommentButton)
end

-- 初始化单选框
function SuperBossShowDlg:initCheckBox()
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, SUPER_BOSS_CHECKS, self.onCheckBox)
    self.radioGroup:setSetlctByName(SUPER_BOSS_CHECKS[1])
    self:onCheckBox(self:getControl(SUPER_BOSS_CHECKS[1]))
end

-- checkBox点击事件
function SuperBossShowDlg:onCheckBox(sender, eventType)    
    local info = BOSS_SHAPE_INFO[sender:getName()]
    self.bossInfo = info
    self:setPortrait("BossIconPanel", info.icon, 0, self.root, true, nil, nil)
    self:setImage("NameImage", info.nameIcon)
    
    DlgMgr:sendMsg("SuperBossFirstKillDlg","setDlgData", info)
    
    DlgMgr:sendMsg("SuperBossIntroduceDlg","setDlgData", info)
end

-- 点评
function SuperBossShowDlg:onCommentButton(sender)
    if not self.bossInfo then return end
    
    if not DistMgr:checkCrossDist() then return end

    local dlg = DlgMgr:openDlg("BookCommentDlg")
    dlg:setCommentObj({name = self.bossInfo.name, icon = self.bossInfo.icon}, "boss")
end


return SuperBossShowDlg
