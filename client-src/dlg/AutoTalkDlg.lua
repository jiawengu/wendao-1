-- AutoTalkDlg.lua
-- Created by songcw June/8/2017
-- 战斗自动喊话

local AutoTalkDlg = Singleton("AutoTalkDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local json = require("json")

local TYPE_CHECKBOS = {
    "UserCheckBox",
    "PetCheckBox",
    "ChildCheckBox",
}

local DISPLAY_PANEL = {
    UserCheckBox      = "UserTalkPanel",
    PetCheckBox       = "PetTalkPanel",
    ChildCheckBox     = "ChildTalkPanel",
}


-- 自动喊话宏定义
local AUTO_TT_SKILL                 =      0   -- 技能 (特殊类型，可扩展多项)
local AUTO_TT_PHYSICAL_ATTACK       =      1   -- 普攻
local AUTO_TT_DEFENSE               =      2   -- 防御
local AUTO_TT_CATCH_PET             =      3   -- 捕捉宠物
local AUTO_TT_SELECT_PET            =      4   -- 选择宠物出战
local AUTO_TT_FLEE                  =      5   -- 逃跑
local AUTO_TT_DIE                   =      6   -- 死亡
local AUTO_TT_ADD_PET               =      7   -- 宠物上场

-- 修改自动喊话的类型
local AUTO_TO_NONE       = 0   -- 没有变化
local AUTO_TO_ADD        = 1   -- 增加 
local AUTO_TO_CHANGE     = 2   -- 修改
local AUTO_TO_REMOVE     = 3   -- 删除

-- 默认喊话数据
local DEFAULT_ACTION = {
    UserCheckBox      = {
        [1] = {chs = CHS[4100640], inconPath = "skillicon/09166.png", isDefault = true, type = AUTO_TT_PHYSICAL_ATTACK}, -- 普攻
        [2] = {chs = CHS[4100641], inconPath = "skillicon/09167.png", isDefault = true, type = AUTO_TT_DEFENSE},    --  "防御"

    },            -- 拜师
    PetCheckBox    = {
        [1] = {chs = CHS[4100645], inconPath = "skillicon/09166.png", isDefault = true, type = AUTO_TT_PHYSICAL_ATTACK},
        [2] = {chs = CHS[4100646], inconPath = "skillicon/09167.png", isDefault = true, type = AUTO_TT_DEFENSE},
        [3] = {chs = CHS[4100647], inconPath = ResMgr.ui.auto_talk2, isDefault = true, type = AUTO_TT_ADD_PET},
    },
    ChildCheckBox      = {
        [1] = {chs = CHS[4100640], inconPath = "skillicon/09166.png", isDefault = true, type = AUTO_TT_PHYSICAL_ATTACK}, -- 普攻
        [2] = {chs = CHS[4100641], inconPath = "skillicon/09167.png", isDefault = true, type = AUTO_TT_DEFENSE},    --  "防御"
    },                    
}

-- 喊话最长长度
local MSG_MAX = 24

function AutoTalkDlg:init()

    self:bindListener("NoteButton", self.onNoteButton)
    
    -- 克隆
    self.petPanel = self:toCloneCtrl("PetPanel") -- 宠物列表
    self.petSelectEff = self:toCloneCtrl("ChosenEffectImage", self.petPanel)
    --
    self.skillPanel = self:toCloneCtrl("AddSkillPanel") -- 技能
    self:setCtrlVisible("AddLabel2", false, self.skillPanel)
    self:bindListener("ReduceButton", self.onReduceButton, self.skillPanel)    
    self:bindListener("DelAllButton", self.onDelAllButton, self.skillPanel)
    self:bindListener("SaveButton", self.onSaveButton, self.skillPanel)    
    self:bindListener("SkillImagePanel", self.onSkillImagePanel, self.skillPanel)       
    
    self.addSkillPanel = self:toCloneCtrl("AddPanel") -- 增加
    self:bindListener("AddButton", self.onAddButton, self.addSkillPanel) 

    -- 娃娃
    self.kidSelectEff = self:retainCtrl("ChosenEffectImage", "ChildPanel")
    self.kidPanel = self:retainCtrl("ChildPanel")
    
    -- 查询所有战斗喊话信息
    self:queryAllData()
    
    self.talkData = {}  
    self.isLoaded = {}

    -- 设置玩家名字、形象
    self:setUserShapeInfo()
    
    -- 设置宠物列表
    self:setPetList()

    -- 设置娃娃列表
    self:setKidList()
    
    -- 设置角色、宠物喊话checkBox
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, TYPE_CHECKBOS, self.onCheckBox)
    self.radioGroup:selectRadio(1)
    
    local statePanel = self:getControl("OpenStatePanel")
    local talkOn = SystemSettingMgr:getSettingStatus("combat_auto_talk") == 1
    self:createSwichButton(statePanel, talkOn, self.onSwichButton, "combat_auto_talk", self.notOpenTalk)
    
    -- 自动喊话数据
    self:hookMsg("MSG_AUTO_TALK_DATA")
end

function AutoTalkDlg:onNoteButton(sender, eventType)    
    DlgMgr:openDlg("AutoTalkRuleDlg")   
end

function AutoTalkDlg:notOpenTalk()
    local talkOn = SystemSettingMgr:getSettingStatus("combat_auto_talk") == 1
    if talkOn then return end

    local isPetCollected, isKidCollected, isAllNotSet = self:checkIsCollected()
    if isAllNotSet then
        -- 未设置任何喊话内容
        gf:ShowSmallTips(CHS[4200373])
        return true 
    end

    if not isPetCollected then
        -- 加载宠物信息中
        gf:ShowSmallTips(CHS[4200372]) 
        return true
    end
    
    if not isKidCollected then
        -- 加载娃娃信息中
        gf:ShowSmallTips(CHS[7120207]) 
        return true
    end
    
    return false
end

-- 返回   是否已经接收完成          是否全部对象都没有设置
function AutoTalkDlg:checkIsCollected()
    local data = FightMgr:getFightAutoTalkById()
    if not data then return false end

    local isCollected = true
    local isPetCollected = true
    local isKidCollected = true
    if not data[Me:getId()] then isCollected = false end
    
    for _, pet in pairs(PetMgr.pets) do
        if not data[pet:getId()] then isPetCollected = false end
    end

    for _, kid in pairs(HomeChildMgr.kids) do
        if not data[kid:getId()] then isKidCollected = false end
    end

    if not isPetCollected or not isKidCollected then
        isCollected = false
    end

    local isAllNotSet = true    
    if isCollected then        
        for _, talk in pairs(data[Me:getId()]) do
            if talk.msg ~= "" then isAllNotSet = false end
        end
        
        for _, pet in pairs(PetMgr.pets) do
            for i, talk in pairs(data[pet:getId()]) do
                if talk.msg ~= "" then isAllNotSet = false end
            end
        end

        for _, kid in pairs(HomeChildMgr.kids) do
            for i, talk in pairs(data[kid:getId()]) do
                if talk.msg ~= "" then isAllNotSet = false end
            end
        end
    else
        isAllNotSet = false
    end
    
    return isPetCollected, isKidCollected, isAllNotSet
end

function AutoTalkDlg:queryAllData()
    self:queryAutoTalkData(Me:getId())
    
    for _, pet in pairs(PetMgr.pets) do
        self:queryAutoTalkData(pet:getId())
    end

    for _, kid in pairs(HomeChildMgr.kids) do
        self:queryAutoTalkData(kid:getId())
    end
end

function AutoTalkDlg:onSwichButton(isOn, key)
    SystemSettingMgr:sendSeting(key, isOn and 1 or 0)
    gf:ShowSmallTips(CHS[3003682])
end

-- 设置战斗喊话动作
function AutoTalkDlg:setSkillActions()
    if self.radioGroup:getSelectedRadioIndex() == 1 then
        -- 角色的动作
  --      self:setUserActions()
    else
        -- 宠物的动作
  --      self:setPetActions(true)
    end
end

-- 设置娃娃战斗喊话动作
function AutoTalkDlg:setKidActions(isRefreash)
    local data = FightMgr:getFightAutoTalkById(self.selectKid:getId())
    if not data then
        self:resetListView("KidTalkListView")
        return
    end

    if not isRefreash then
        if self.isLoaded[self.selectKid:getId()] then
            self.isLoaded[self.selectKid:getId()] = true -- 界面只打开时，才全部刷新 
            return 
        end        
    end    

    self.isLoaded[self.selectKid:getId()] = true -- 界面只打开时，才全部刷新 
    self.talkData[self.selectKid:getId()] = {} 

    local list = self:resetListView("KidTalkListView")

    -- 默认
    local defActions = DEFAULT_ACTION["ChildCheckBox"]
    for i = 1, #defActions do
        local panel = self.skillPanel:clone()
        local panelData = gf:deepCopy(defActions[i])
        panel.id = self.selectKid:getId()
        panel:setTag(i)        
        
        self:setUnitSkillPanel(panelData, panel)
        panel.listView = "KidTalkListView"         
        
        local edit = self:creatEditBoxByPanel(panel)   
        list:pushBackCustomItem(panel)
        
        -- 默认没有操作
        local msg = ""
        if data[i] and data[i].msg then msg = data[i].msg end
        if msg ~= "" then edit:setText(msg) end
        self:setCtrlVisible("DelAllButton", msg ~= "", panel) 
        self.talkData[self.selectKid:getId()][i] = {para = 0, type = defActions[i].type, msg = msg, op_type = AUTO_TO_NONE}
    end
    
    -- 自定义
    for i = #defActions + 1, #data do
        local panel = self.skillPanel:clone()
        panel.id = self.selectKid:getId()
        panel:setTag(i)
        local panelData = gf:deepCopy(data[i])
        panelData.skillName = SkillMgr:getSkillName(data[i].para) -- chs 和Skill不一样，是因为 有时候skillName 和显示的chs不同
        panelData.chs = SkillMgr:getSkillName(data[i].para)
        self:setUnitSkillPanel(panelData, panel)            
        panel.listView = "KidTalkListView"

        local edit = self:creatEditBoxByPanel(panel)        
        list:pushBackCustomItem(panel)

        -- 默认没有操作
        local msg = ""
        if data[i] and data[i].msg then msg = data[i].msg end
        if msg ~= "" then edit:setText(msg) end
        self:setCtrlVisible("DelAllButton", msg ~= "", panel) 
        self.talkData[self.selectKid:getId()][i] = {para = panelData.para, type = panelData.type, msg = msg, op_type = AUTO_TO_NONE}
    end 

    -- 增加按钮
    local amount = #list:getItems()
    local panel = self.addSkillPanel:clone()
    panel.id = self.selectKid:getId()
    panel:setTag(amount + 1)
    panel.listView = "KidTalkListView"
    list:pushBackCustomItem(panel)
end

-- 设置宠物战斗喊话动作
function AutoTalkDlg:setPetActions(isRefreash)
    
    local data = FightMgr:getFightAutoTalkById(self.selectPet:getId())
    if not data then
        self:resetListView("PetTalkListView")
        return
    end

    if not isRefreash then
        if self.isLoaded[self.selectPet:getId()] then
            self.isLoaded[self.selectPet:getId()] = true -- 界面只打开时，才全部刷新 
            return 
        end        
    end    

    self.isLoaded[self.selectPet:getId()] = true -- 界面只打开时，才全部刷新 
    self.talkData[self.selectPet:getId()] = {} 
    local list = self:resetListView("PetTalkListView")
    -- 默认
    local defActions = DEFAULT_ACTION["PetCheckBox"]
    for i = 1, #defActions do
        local panel = self.skillPanel:clone()
        local panelData = gf:deepCopy(defActions[i])
        panel.id = self.selectPet:getId()
        panel:setTag(i)        
        
        self:setUnitSkillPanel(panelData, panel)
        panel.listView = "PetTalkListView"         
        
        local edit = self:creatEditBoxByPanel(panel)   
        list:pushBackCustomItem(panel)
        
        -- 默认没有操作
        local msg = ""
        if data[i] and data[i].msg then msg = data[i].msg end
        if msg ~= "" then edit:setText(msg) end
        self:setCtrlVisible("DelAllButton", msg ~= "", panel) 
        self.talkData[self.selectPet:getId()][i] = {para = 0, type = defActions[i].type, msg = msg, op_type = AUTO_TO_NONE}
    end
    
    -- 自定义
    for i = #defActions + 1, #data do
        local panel = self.skillPanel:clone()
        panel.id = self.selectPet:getId()
        panel:setTag(i)
        local panelData = gf:deepCopy(data[i])
        panelData.skillName = SkillMgr:getSkillName(data[i].para) -- chs 和Skill不一样，是因为 有时候skillName 和显示的chs不同
        panelData.chs = SkillMgr:getSkillName(data[i].para)
        self:setUnitSkillPanel(panelData, panel)            
        panel.listView = "PetTalkListView"

        local edit = self:creatEditBoxByPanel(panel)        
        list:pushBackCustomItem(panel)

        -- 默认没有操作
        local msg = ""
        if data[i] and data[i].msg then msg = data[i].msg end
        if msg ~= "" then edit:setText(msg) end
        self:setCtrlVisible("DelAllButton", msg ~= "", panel) 
        self.talkData[self.selectPet:getId()][i] = {para = panelData.para, type = panelData.type, msg = msg, op_type = AUTO_TO_NONE}
    end 
    
    -- 增加按钮
    local amount = #list:getItems()
    local panel = self.addSkillPanel:clone()
    panel.id = self.selectPet:getId()
    panel:setTag(amount + 1)
    panel.listView = "PetTalkListView"
    list:pushBackCustomItem(panel)
end

function AutoTalkDlg:creatEditBoxByPanel(panel)
    local editCtl = self:createEditBox("AddPanel", panel, nil, function(sender, type, eCtl)
        if type == "end" then
            
        elseif type == "changed" then
            local newName = eCtl:getText()
            if gf:getTextLength(newName) > MSG_MAX then
                newName = gf:subString(newName, MSG_MAX)
                eCtl:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end
            
            local desStr = eCtl:getText()
                        
            if desStr ~= self.talkData[panel.id][panel:getTag()].msg and not panel.data.toBeSelect then
                self:setCtrlVisible("SaveButton", true, panel)
            end
            
            if desStr ~= "" then            
                self:setCtrlVisible("DelAllButton", true, panel)
            end  
            
            self.talkData[panel.id][panel:getTag()].msg = desStr
            if panel.data.toBeSelect == 1 then
                gf:ShowSmallTips(CHS[4100648])
                return
            end
        end
    end)
    editCtl:setFontColor(COLOR3.TEXT_DEFAULT)
    editCtl:setPlaceholderFont(CHS[3003794], 19)
    editCtl:setFont(CHS[3003794], 19)
    editCtl:setPlaceHolder(CHS[4100649])
    editCtl:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    panel.editCtl = editCtl
    return editCtl
end

-- 设置玩家战斗喊话动作
function AutoTalkDlg:setUserActions()
    local data = FightMgr:getFightAutoTalkById(Me:getId())
    if not data then
        self:resetListView("UserTalkListView")
        return
    end
    
    -- WDSY-25521 自动喊话行为设置优化(client)
    --
    local retData = {}
    for i = 1, #data do
        if data[i].type == AUTO_TT_CATCH_PET or data[i].type == AUTO_TT_SELECT_PET or data[i].type == AUTO_TT_FLEE then
        -- 捕捉   召唤  逃跑 不处理了，旧数据直接删除
        else
            table.insert(retData, data[i])
        end
    end
    data = retData    
    
    if self.isLoaded[Me:getId()] then return end
    self.isLoaded[Me:getId()] = true

    self.talkData[Me:getId()] = {} 

    local list = self:resetListView("UserTalkListView")
    -- 默认
    local defActions = DEFAULT_ACTION["UserCheckBox"]
    for i = 1, #defActions do
        local panel = self.skillPanel:clone()
        panel.id = Me:getId()
        panel:setTag(i)
        
        local panelData = gf:deepCopy(defActions[i])
        self:setUnitSkillPanel(panelData, panel)        
        panel.listView = "UserTalkListView"        
        local edit = self:creatEditBoxByPanel(panel)        
        list:pushBackCustomItem(panel)
        
        -- 默认没有操作
        local msg = ""
        if data[i] and data[i].msg then msg = data[i].msg end
        if msg ~= "" then edit:setText(msg) end
        self:setCtrlVisible("DelAllButton", msg ~= "", panel) 
        self.talkData[Me:getId()][i] = {para = 0, type = defActions[i].type, msg = msg, op_type = AUTO_TO_NONE}
    end
    
    -- 新增
    for i = #defActions + 1, #data do
        local panel = self.skillPanel:clone()
        panel.id = Me:getId()
        panel:setTag(i)
        local panelData = gf:deepCopy(data[i])
        panelData.skillName = SkillMgr:getSkillName(data[i].para) -- chs 和Skill不一样，是因为 有时候skillName 和显示的chs不同
        panelData.chs = SkillMgr:getSkillName(data[i].para)
        self:setUnitSkillPanel(panelData, panel)            
        panel.listView = "UserTalkListView"

        local edit = self:creatEditBoxByPanel(panel)        
        list:pushBackCustomItem(panel)

        -- 默认没有操作
        local msg = ""
        if data[i] and data[i].msg then msg = data[i].msg end
        if msg ~= "" then edit:setText(msg) end
        self:setCtrlVisible("DelAllButton", msg ~= "", panel) 
        self.talkData[Me:getId()][i] = {para = panelData.para, type = panelData.type, msg = msg, op_type = AUTO_TO_NONE}
    end 
    
    
    -- 增加按钮
    local amount = #list:getItems()
    local panel = self.addSkillPanel:clone()
    panel.id = Me:getId()
    panel:setTag(amount + 1)
    panel.listView = "UserTalkListView"
    list:pushBackCustomItem(panel)
end


-- 点击了技能
function AutoTalkDlg:onSkillImagePanel(sender, eventType)
    local parentPanel = sender:getParent()
    if parentPanel.data.toBeSelect then
        local dlg = DlgMgr:openDlg("AutoFightTalkDlg")
        if dlg then
            dlg:setHasData(self.talkData[parentPanel.id])
            dlg:initSkill(parentPanel.id)
            dlg:setCallBcak(self, self.onSelectSkill, sender)
        end
    end
end

function AutoTalkDlg:onSelectSkill(skillNo, ob, sender)
    local skillInfo = SkillMgr:getskillAttrib(skillNo)
    local panel = sender:getParent()
    
    panel.data.inconPath = ResMgr:getSkillIconPath(skillInfo['skill_icon'])
    panel.data.chs = skillInfo.name
    panel.data.toBeSelect = nil
    panel.data.isPlist = nil
    self.talkData[panel.id][panel:getTag()].para = skillInfo.skill_no
    self:setUnitSkillPanel(panel.data, panel)
    
    self:setCtrlVisible("AddButton", true, panel)
    
    -- 如果已经输入了喊话内容，显示保存按钮
    local str = panel.editCtl:getText()    
    local filtTextStr, haveFilt = gf:filtText(str, nil, true)
    if not haveFilt and str ~= "" then
        self:setCtrlVisible("SaveButton", true, panel)
    end
end

-- 保存
function AutoTalkDlg:onSaveButton(sender, eventType)
    local panel = sender:getParent()
    local editCtl = panel.editCtl
    local desStr = editCtl:getText()
    
    local filtTextStr, haveFilt = gf:filtText(desStr, nil, true)
    if haveFilt or not gf:checkIsGBK(desStr) then
        gf:ShowSmallTips(CHS[6000033])
        return
    end

    self.talkData[panel.id][panel:getTag()].op_type = AUTO_TO_CHANGE
    if panel.data.isNew then self.talkData[panel.id][panel:getTag()].op_type = AUTO_TO_ADD end
    
    local data = self.talkData[panel.id]
    for _, unitData in pairs(data) do    
        unitData.msg = BrowMgr:addGenderSign(unitData["msg"])
    end
    self:saveAutoTalkData(panel.id, json.encode(data))
    
    self.talkData[panel.id][panel:getTag()].op_type = AUTO_TO_NONE    
    self:setUnitSkillPanel(panel.data, panel)
end

-- 清空当前输入
function AutoTalkDlg:onDelAllButton(sender, eventType)
    local tempPanel = sender:getParent()
    local parentPanel = tempPanel:getParent()
    parentPanel.editCtl:setText("")
    self.talkData[parentPanel.id][parentPanel:getTag()].msg = ""  
    
    self:setCtrlVisible("SaveButton", true, parentPanel)
    sender:setVisible(false)
end

-- 删除当前action
function AutoTalkDlg:onReduceButton(sender, eventType)
    local parentPanel = sender:getParent()
    
    local skillName = parentPanel.data.chs
    if skillName == "" then skillName = CHS[4100638] end
    local str = string.format(CHS[4100639], skillName)
    gf:confirm(str, function ()
        self.talkData[parentPanel.id][parentPanel:getTag()].op_type = AUTO_TO_REMOVE
        self:saveAutoTalkData(parentPanel.id, json.encode(self.talkData[parentPanel.id]))
        table.remove(self.talkData[parentPanel.id], parentPanel:getTag())

        local list = self:getControl(parentPanel.listView)
        list:removeItem(parentPanel:getTag() - 1)   
        list:requestDoLayout()
        self:resetListItemsTag()
    end)    
end

-- 增加一个战斗技能action
function AutoTalkDlg:onAddButton(sender, eventType)
    -- 刷新自己
    local parentPanel = sender:getParent()
    
    if parentPanel.listView == "UserTalkListView" then
        if #self.talkData[parentPanel.id] - #DEFAULT_ACTION["UserCheckBox"] >= self:getUserSkillCount() then
            gf:ShowSmallTips(CHS[4200374])
            return
        end
    elseif parentPanel.listView == "KidTalkListView" then
        if #self.talkData[parentPanel.id] - #DEFAULT_ACTION["ChildCheckBox"] >= self:getKidSkillCount() then
            gf:ShowSmallTips(CHS[4200374])
            return
        end
    else
        if #self.talkData[parentPanel.id] - #DEFAULT_ACTION["PetCheckBox"] >= self:getPetSkillCount() then
            gf:ShowSmallTips(CHS[4200374])
            return
        end
    end
    
    local tag = parentPanel:getTag()
    parentPanel:setTag(tag + 1)

    -- 新增一个    
    local list = self:getControl(parentPanel.listView)
    local panel = self.skillPanel:clone()    
    panel.id = parentPanel.id
    panel:setTag(tag)    
    self.talkData[panel.id][panel:getTag()] = {para = 0, type = AUTO_TT_SKILL, msg = "", op_type = AUTO_TO_NONE}

    local data = {inconPath = ResMgr.ui.auto_talk_add_symbol, chs = "", toBeSelect = 1, isNew = true}
    self:setUnitSkillPanel(data, panel)
    
    panel.listView = parentPanel.listView    
    self:creatEditBoxByPanel(panel)     

    list:insertCustomItem(panel, tag - 1)
    list:requestRefreshView()
    list:requestDoLayout()

    local items = list:getItems()
    local innerContentSize = list:getInnerContainer():getContentSize()
    local height = 0
    for _, panel in pairs(items) do
        height = panel:getContentSize().height + height
        list:getInnerContainer():setContentSize(innerContentSize.width, height)
        list:requestRefreshView()
        list:requestDoLayout()
    end
    
    list:getInnerContainer():setPositionY(0)
    list:requestRefreshView()
    list:requestDoLayout()
    --[[
    performWithDelay(self.root, function ()
        list:getInnerContainer():setPositionY(0)
        list:requestRefreshView()
        list:requestDoLayout()
    end, 0)
    --]]
end

-- 由于删除可能删除中级的，所以将list的项
function AutoTalkDlg:resetListItemsTag()    
    local function reset(listName)
        local list = self:getControl(listName)
        local items = list:getItems()
        for i, panel in pairs(items) do
            panel:setTag(i)
        end     
    end
    
    reset("UserTalkListView")
    reset("KidTalkListView")
    reset("PetTalkListView")
end

function AutoTalkDlg:setUnitSkillPanel(data, panel)
    -- 技能图片
    if data.inconPath then
        if data.isPlist then
            self:setImagePlist("Image", data.inconPath, panel)
        else
            self:setImage("Image", data.inconPath, panel)
        end
    else
        self:setImage("Image", SkillMgr:getSkillIconFilebyName(data.skillName), panel)
    end
    
    -- 技能名称
    self:setLabelText("SkillNameLabel", data.chs, panel)
    
    -- 默认的不可以删除
    self:setCtrlVisible("ReduceButton", not data.isDefault, panel)
    
    -- 保存按钮
    self:setCtrlVisible("SaveButton", false, panel)
    
    panel.data = data
end

function AutoTalkDlg:cleanup()
    self:releaseCloneCtrl("addSkillPanel")
    self:releaseCloneCtrl("petPanel")
    self:releaseCloneCtrl("skillPanel")
    self:releaseCloneCtrl("petSelectEff")    
    self.selectPet = nil
    self.selectKid = nil
    FightMgr:cleanupDataLogin()
end

-- 设置娃娃列表
function AutoTalkDlg:setKidList()
    local list = self:resetListView("ChildListView", 0 , ccui.ListViewGravity.centerHorizontal)
    local kids = HomeChildMgr:getKidList(HomeChildMgr.CHILD_TYPE.KID)

    -- 排序
    table.sort(kids, function(l, r)
        if l:getId() == r:getId() then return false end
        if l:getId() == HomeChildMgr.combatKidId then return true end
        if r:getId() == HomeChildMgr.combatKidId then return false end
        if l:queryInt("intimacy") > r:queryInt("intimacy") then return true end
        if l:queryInt("intimacy") < r:queryInt("intimacy") then return false end
        if l:queryInt("level") > r:queryInt("level") then return true end
        if l:queryInt("level") < r:queryInt("level") then return false end
        if l:getAllShape() > r:getAllShape() then return true end
        if l:getAllShape() < r:getAllShape() then return false end
        if l:getName() > r:getName() then return true end
        if l:getName() < r:getName() then return false end
    end)

    for i = 1, #kids do
        local panel = self:createKidItem(kids[i])
        list:pushBackCustomItem(panel)
 
        if not self.selectKid then
            self:onSelectKid(panel)
        end
    end
end

-- 点击娃娃
function AutoTalkDlg:onSelectKid(sender, eventType)
    self.kidSelectEff:removeFromParent()
    sender:addChild(self.kidSelectEff)
    
    self.selectKid = sender.kid
    
    self:setKidActions(true)
end

function AutoTalkDlg:createKidItem(kid)
    local kidPanel = self.kidPanel:clone()
    kidPanel:setTag(kid:queryBasicInt("id"))
    kidPanel.kid = kid

    local function selectKid(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onSelectKid(sender, eventType)
        end
    end

    kidPanel:addTouchEventListener(selectKid)

    -- 头像
    self:setImage("GuardImage", ResMgr:getSmallPortrait(kid:queryBasicInt("portrait")), kidPanel)
    self:setItemImageSize("GuardImage", kidPanel)

    -- 等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, kid:queryBasicInt("level"), false, LOCATE_POSITION.LEFT_TOP, 25, kidPanel)

    -- 名称，跟随标记
    if kid:getId() == HomeChildMgr.combatKidId then
        -- 参战娃娃名字显示绿色
        self:setLabelText("NameLabel", kid:getName(), kidPanel, COLOR3.GREEN)
        self:setCtrlVisible("StatusImage", true, kidPanel)
        self:setImage("StatusImage", ResMgr.ui.follow_flag_new, kidPanel)
    else
        self:setLabelText("NameLabel", kid:getName(), kidPanel, COLOR3.TEXT_DEFAULT)
        self:setCtrlVisible("StatusImage", false, kidPanel)
    end
    
    return kidPanel
end

-- 设置宠物列表
function AutoTalkDlg:setPetList()
    local list = self:resetListView("PetListView", 0 , ccui.ListViewGravity.centerHorizontal)
    local pets = PetMgr:getOrderPets()
    for i, v in pairs(pets) do
        local panel = self:createPetItem(v)
        list:pushBackCustomItem(panel)
        
        if not self.selectPet then
            self:onselectPet(panel)
        end
    end
end

-- 点击宠物
function AutoTalkDlg:onselectPet(sender, eventType)
    self.petSelectEff:removeFromParent()
    sender:addChild(self.petSelectEff)
    
    self.selectPet = sender.pet
    
    self:setPetActions(true)
end

function AutoTalkDlg:createPetItem(pet, select)
    local pet_status = pet:queryInt("pet_status")
    local petPanel = self.petPanel:clone()
    petPanel:setTag(pet:queryBasicInt("id"))
    local function selectPet(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onselectPet(sender, eventType)
        end
    end
    petPanel:addTouchEventListener(selectPet)
    petPanel.pet = pet
    local petImage = self:getControl("GuardImage", Const.UIImage, petPanel)
    local path = ResMgr:getSmallPortrait(pet:queryBasicInt("portrait"))
    petImage:loadTexture(path)
    self:setItemImageSize("GuardImage", petPanel)

    local petNameLabel = self:getControl("NameLabel", Const.UILabel, petPanel)
    petNameLabel:setString(pet:getShowName())

    local petLevelValueLabel = self:getControl("LevelLabel", Const.UILabel, petPanel)
    local petRankDesc = gf:getPetRankDesc(pet) or ""
    petLevelValueLabel:setString("(".. petRankDesc .. ")")

    -- 宠物等级
    local petLevel = pet:queryBasicInt("level")
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, petLevel, false, LOCATE_POSITION.LEFT_TOP, 25, petPanel)

    -- 设置宠物相性
    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("Image", polarPath, petPanel)

    local statusImg = self:getControl("StatusImage", Const.UIImage, petPanel)
    statusImg:setVisible(false)

    if pet_status == 1 then
        -- 参战
        statusImg:setVisible(true)
        petNameLabel:setColor(COLOR3.GREEN)
        petLevelValueLabel:setColor(COLOR3.GREEN)
        statusImg:loadTexture(ResMgr.ui.canzhan_flag_new)
    elseif pet_status == 2 then
        -- 掠阵
        petNameLabel:setColor(COLOR3.YELLOW)
        petLevelValueLabel:setColor(COLOR3.YELLOW)
        petLevelValueLabel:setColor(COLOR3.YELLOW)
        if 1 == SystemSettingMgr:getSettingStatus("award_supply_pet", 0) then
            statusImg:loadTexture(ResMgr.ui.gongtong_flag_new)
        else
            statusImg:loadTexture(ResMgr.ui.luezhen_flag_new)
        end
        statusImg:setVisible(true)
    elseif PetMgr:isRidePet(pet:getId()) then -- 骑乘状态
        statusImg:loadTexture(ResMgr.ui.ride_flag_new)
        if 2 == SystemSettingMgr:getSettingStatus("award_supply_pet", 0) then
            statusImg:loadTexture(ResMgr.ui.gongtong_flag_new)
        end
        statusImg:setVisible(true)
    end

    -- 默认选择
    if select then
        selectPet(petPanel, ccui.TouchEventType.ended)
    end
    
    return petPanel
end


-- 设置玩家名字、形象
function AutoTalkDlg:setUserShapeInfo()
    self:setLabelText("NameLabel", Me:queryBasic("name"), "UserTalkPanel")
    
    if not Me:isRealBody() then
        -- 设置元婴、血婴图
        self:setImage("PortraitImage", Me:getChildIconPath())
    else
        -- 设置角色底图
        if Me:queryBasicInt("polar") == 0 then
            self:setCtrlVisible("PortraitImage", false)
        else
            self:setImage("PortraitImage", ResMgr:getUserDlgPolarBgImg(Me:queryBasicInt("polar"), Me:queryBasicInt("gender")))
        end
    end
end

function AutoTalkDlg:onCheckBox(sender, eventType)
    for _, panelName in pairs(DISPLAY_PANEL) do
        self:setCtrlVisible(panelName, false)
    end
    
    self:setCtrlVisible(DISPLAY_PANEL[sender:getName()], true)
    
    self:setSkillActions()
end

-- 请求对象的自动喊话信息
function AutoTalkDlg:queryAutoTalkData(id)
    gf:CmdToServer("CMD_AUTO_TALK_DATA", {id = id})
end

-- 请求保存自动喊话信息
function AutoTalkDlg:saveAutoTalkData(id, content)
    content = gf:filterControlChar(content)
    gf:CmdToServer("CMD_AUTO_TALK_SAVE", {id = id, content = content})
end


function AutoTalkDlg:MSG_AUTO_TALK_DATA(data)
    if data.id == Me:getId() then    
        self:setUserActions()
    elseif self.selectPet and data.id == self.selectPet:getId() then
        self:setPetActions()
    elseif self.selectKid and data.id == self.selectKid:getId() then
        self:setKidActions()
    end
end

function AutoTalkDlg:getKidSkillCount()
    local SKILL_TYPE_LIST = {"DType", "CType", "BType", "PhyType"}
    local amount = 0
    for i = 1, #SKILL_TYPE_LIST do
        local skills = self:getKidActionData(SKILL_TYPE_LIST[i])
        if next(skills) and next(skills.skills) then
            amount = #skills.skills + amount
        end
    end

    return amount
end

function AutoTalkDlg:getKidActionData(name)
    local actionData = {}
    local skill = {}
    local attackId = self.selectKid:getId()

    if name == "PhyType" then
        -- 力破千钧
        local phySkill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_J)
        if phySkill then
            table.insert(skill, phySkill[1])
        end

        actionData["skills"] = skill
    elseif name == "BType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_B)

        if #skill > 0 then
            actionData["skills"] = skill
        end
    elseif name == "CType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_C)

        if #skill > 0 then
            actionData["skills"] = skill
        end
    elseif name == "DType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_D)

        if #skill > 0 then
            actionData["skills"] = skill
        end
    end

    return actionData
end

function AutoTalkDlg:getPetSkillCount()
    local SKILL_PET_TYPE_LIST = {"PartyType", "InnerType", "BType", ""}
    local amount = 0
    for i = 1, #SKILL_PET_TYPE_LIST do
        local skills = self:getPetSkillData(SKILL_PET_TYPE_LIST[i])
        if next(skills) and next(skills.skills) then
            amount = #skills.skills + amount
        end
    end

    return amount
end

function AutoTalkDlg:getPetSkillData(name)
    local actionData = {}
    local skill = {}
    local attackId = self.selectPet:getId()

    --SkillMgr:getSkill(attackId, skills.skills[j].no)

    if name == "PhyType" then

    elseif name == "BType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_B)
        local destSkills = {}
        for i, sk in pairs(skill) do
            if SkillMgr:getSkill(attackId, sk.no) then
                table.insert(destSkills, sk)
            end
        end
        if #destSkills > 0 then
            actionData["skills"] = destSkills
        end
    elseif name == "InnerType" then
        skill = SkillMgr:getPetRawSkillNoAndLadder(attackId)
        local dunWuSkills = SkillMgr:getPetDunWuSkillsInfo(attackId) -- 宠物顿悟技能，放在天生技能后面        

        for i = 1, #dunWuSkills do
            table.insert(skill, dunWuSkills[i])
        end

        local destSkills = {}
        for i, sk in pairs(skill) do
            if SkillMgr:getSkill(attackId, sk.no) then
                table.insert(destSkills, sk)
            end
        end

        if #destSkills > 0 then
            for i = 1, #destSkills do
                destSkills[i].ladder = 0
            end

            actionData["skills"] = destSkills
        end
    elseif name == "PartyType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_E, SKILL.CLASS_PET)

        local destSkills = {}
        for i, sk in pairs(skill) do
            if SkillMgr:getSkill(attackId, sk.no) then
                table.insert(destSkills, sk)
            end
        end

        SkillMgr:sortStudySkill(destSkills)
        if #destSkills > 0 then
            for i = 1, #destSkills do
                destSkills[i].ladder = 0
            end
            actionData["skills"] = destSkills
        end
    end

    return actionData
end

function AutoTalkDlg:getUserSkillCount()
    local SKILL_TYPE_LIST = {"DType", "CType", "BType", "PhyType"}
    local amount = 0
    for i = 1, #SKILL_TYPE_LIST do
        local skills = self:getSkillData(SKILL_TYPE_LIST[i])
        if next(skills) and next(skills.skills) then
            amount = #skills.skills + amount
        end
    end
    
    return amount
end

function AutoTalkDlg:getSkillData(name)
    local actionData = {}
    local skill = {}
    local attackId =  Me:getId()

    if name == "PhyType" then

        -- 力破千钧
        local phySkill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_J)
        if phySkill then
            table.insert(skill, phySkill[1])
        end

        actionData["skills"] = skill
    elseif name == "BType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_B)

        if #skill > 0 then
            actionData["skills"] = skill
        end
    elseif name == "CType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_C)

        if #skill > 0 then
            actionData["skills"] = skill
        end
    elseif name == "DType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_D)

        if #skill > 0 then
            actionData["skills"] = skill
        end
    end

    -- 特殊处理：人物身上由亲密无间获得的技能
    local result = {}
    if actionData["skills"] then
        local skills = {}
        for i = 1, #actionData["skills"] do
            local skillInfo = actionData["skills"][i]
            local skillName = skillInfo.name
            local skill = SkillMgr:getSkill(Me:getId(), skillInfo.no)
            if skill and (not skill.isTempSkill or skill.isTempSkill == 0)
                or (skillName == CHS[3002286] or skillName == CHS[3002275]) then
                table.insert(skills, skillInfo)
            end
        end

        if #skills > 0 then
            result["skills"] = skills
        end
    end

    return result
end

return AutoTalkDlg
