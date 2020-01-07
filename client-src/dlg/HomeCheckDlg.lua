-- HomeCheckDlg.lua
-- Created by huangzz Aug/08/2017
-- 居所修炼界面

local HomeCheckDlg = Singleton("HomeCheckDlg", Dialog)

function HomeCheckDlg:init()
    self:bindListener("CheckButton", self.onCheckXiulianButton, "UserPanel")
    local uPromotePanel = self:getControl("PromotePanel", nil, "UserPanel")
    self:bindListener("CheckButton", self.onCheckXiulianBuffButton, uPromotePanel)
    
    self:bindListener("CheckButton", self.onCheckArtifactButton, "ArtifactPanel")
    local aPromotePanel = self:getControl("PromotePanel", nil, "ArtifactPanel")
    self:bindListener("CheckButton", self.onCheckArtifactBuffButton, aPromotePanel)
    
    self:bindListener("CheckButton", self.onCheckPetFeedButton, "InfoPanel_1")
    self:bindListener("CheckButton", self.onCheckPetFeedButton, "InfoPanel_2")
    self:bindListener("CheckButton_2", self.onCheckPetFeedButton, "InfoPanel_3")
    local pPromotePanel = self:getControl("PromotePanel", nil, "PetPanel")
    self:bindListener("CheckButton", self.onCheckPetFeedBuffButton, pPromotePanel)

    self:bindListener("ComeBackButton2", self.onComeBackQTButton)  -- 前往前庭
    self:bindListener("ComeBackButton1", self.onComeBackFWButton)  -- 前往房屋
    
    self.petInfoPanel2 = self:retainCtrl("InfoPanel_2", "PetPanel")
    self.petInfoPanel3 = self:retainCtrl("InfoPanel_3", "PetPanel")
    self.petBuffPanel = self:retainCtrl("PromotePanel", "PetPanel")

    self.mainBodyPanel = self:retainCtrl("MainBodyPanel")
    
    self.listView = self:resetListView("ListView_16", 2)
    
    self:setData()
    
    self:hookMsg("MSG_HOUSE_FEEDING_LIST")
    self:hookMsg("MSG_HOUSE_CUR_ARTIFACT_PRACTICE")
    self:hookMsg("MSG_HOSUE_CUR_PLAYER_PRACTICE_INFO")
    self:hookMsg("MSG_HOUSE_ALL_PRACTICE_BUFF_DATA")
    
end

function HomeCheckDlg:setData()
    self.mainPanel = self.mainBodyPanel:clone()
    self:setListView()
    self:setArtifactInfo()
    self:setXiulianInfo()
end

function HomeCheckDlg:setListView()
    self.feedPetInfo = PetMgr.feedPets or {}
    
    self.listView:removeAllItems()
    self.listView:pushBackCustomItem(self.mainPanel)
    self.listView:setVisible(true)
    
    local cou = #self.feedPetInfo

    if cou == 0 then
        local petPanel = self:getControl("PetPanel", nil, self.mainPanel)
        self:setCtrlVisible("InfoPanel_1", false, petPanel)
        self:setCtrlVisible("NonePanel", true, petPanel)
    else
        local petPanel = self:getControl("PetPanel", nil, self.mainPanel)
        self:setCtrlVisible("InfoPanel_1", true, petPanel)
        self:setCtrlVisible("NonePanel", false, petPanel)
        
        local infoPanel = self:getControl("InfoPanel_1", nil, petPanel)
        self:setPetInfoPanel(self.feedPetInfo[1], infoPanel)
    end
    
    if cou == 2 then
        local panel2 = self.petInfoPanel2:clone()
        self.listView:pushBackCustomItem(panel2)
        self:setPetInfoPanel(self.feedPetInfo[2], panel2)

    elseif cou == 3 then
        local panel2 = self.petInfoPanel2:clone()
        self.listView:pushBackCustomItem(panel2)
        self:setPetInfoPanel(self.feedPetInfo[2], panel2)
        
        local panel3 = self.petInfoPanel3:clone()
        self.listView:pushBackCustomItem(panel3)
        self:setPetInfoPanel(self.feedPetInfo[3], panel3)

    end    
    
    -- 既然宠物list都在这，那我也加在这好了
    local petBuffData = HomeMgr:getPracticeBuffByType(3)
    if not petBuffData or cou == 0 then
        self.mainPanel:setContentSize(self.mainPanel:getContentSize().width, self.mainPanel:getContentSize().height - (self.petInfoPanel2:getContentSize().height + 2) * 3)
        return
    end

    -- 设置加成家具信息
    local panel = self.petBuffPanel:clone()
    self.listView:pushBackCustomItem(panel)
    self:setBuffData(petBuffData, panel)    
    self.mainPanel:setContentSize(self.mainPanel:getContentSize().width, self.mainPanel:getContentSize().height - (self.petInfoPanel2:getContentSize().height + 2) * 3)
    self.listView:refreshView()
end

function HomeCheckDlg:setXiulianInfo()
    self.xiulianInfo = HomeMgr.playerPracticeInfo or {}
    if next(self.xiulianInfo) then
        local userPanel = self:getControl("UserPanel", nil, self.mainPanel)
        self:setCtrlVisible("InfoPanel", true, userPanel)
        self:setCtrlVisible("NonePanel", false, userPanel)
        self:setXiulianInfoPanel(self.xiulianInfo)        
    else
        local userPanel = self:getControl("UserPanel", nil, self.mainPanel)
        self:setCtrlVisible("InfoPanel", false, userPanel)
        self:setCtrlVisible("NonePanel", true, userPanel)
        self:setLabelText("NameLabel", CHS[5410113], userPanel)
        
        local cell = self:getControl("UserPanel")
        local panel = self:getControl("PromotePanel", nil, cell)
        -- 没有加成道具在使用
        panel:setVisible(false)
        cell:setContentSize(cell:getContentSize().width, cell:getContentSize().height - panel:getContentSize().height - 2)
        self.mainPanel:setContentSize(self.mainPanel:getContentSize().width, self.mainPanel:getContentSize().height - panel:getContentSize().height - 2)
        self.listView:refreshView()
    end
end

function HomeCheckDlg:setArtifactInfo()
    self.artifactInfo = HomeMgr.artifactPracticeInfo or {}
    if next(self.artifactInfo) then
        local artifactPanel = self:getControl("ArtifactPanel", nil, self.mainPanel)
        self:setCtrlVisible("InfoPanel", true, artifactPanel)
        self:setCtrlVisible("NonePanel", false, artifactPanel)
        self:setArtifactInfoPanel(self.artifactInfo)
    else
        local artifactPanel = self:getControl("ArtifactPanel", nil, self.mainPanel)
        self:setCtrlVisible("InfoPanel", false, artifactPanel)
        self:setCtrlVisible("NonePanel", true, artifactPanel)
        self:setLabelText("NameLabel", CHS[5410114], artifactPanel)
        
        local cell = self:getControl("ArtifactPanel")
        local panel = self:getControl("PromotePanel", nil, cell)
        -- 没有加成道具在使用
        panel:setVisible(false)
        cell:setContentSize(cell:getContentSize().width, cell:getContentSize().height - panel:getContentSize().height - 2)
        self.mainPanel:setContentSize(self.mainPanel:getContentSize().width, self.mainPanel:getContentSize().height - panel:getContentSize().height - 2)
        self.listView:refreshView()
    end
end

-- 宠物饲养条目
function HomeCheckDlg:setPetInfoPanel(data, cell)
    -- 宠物名
    self:setLabelText("EffectLabel_1", data.pet_name, self:getControl("EffectPanel", nil, cell))
    
    -- 食盆
    local bowlPanel = self:getControl("EffectPanel_0", nil, cell)
    self:setLabelText("NameLabel", data.bowl_name .. "：", bowlPanel)
    self:setLabelText("EffectLabel_1", data.food_num .. "/" .. data.max_food, bowlPanel)
    
    -- 宠物图标
    self:setImage("GuardImage", ResMgr:getSmallPortrait(data.pet_icon), cell)
end

-- 修炼阵条目
function HomeCheckDlg:setXiulianInfoPanel(data)
    local cell = self:getControl("UserPanel")
    
    local furnInfo = HomeMgr:getFurnitureInfo(data.furniture_name) or {}
    
    -- 修炼阵名字
    self:setLabelText("NameLabel", data.furniture_name, cell)

    -- 耐久度
    self:setLabelText("EffectLabel_1", data.dur .. "/" .. furnInfo.max_dur, self:getControl("EffectPanel", nil, cell))

    -- 干扰度
    local colorXinmo = COLOR3.TEXT_DEFAULT
    if data.xinmo >= 20 then
        colorXinmo = COLOR3.RED        
    end

    self:setLabelText("EffectLabel_1", data.xinmo .. "%", self:getControl("EffectPanel_0", nil, cell), colorXinmo)
    
    -- 修炼阵图标    
    local imgPath = ResMgr:getItemIconPath(furnInfo.icon)
    self:setImage("GuardImage", imgPath, cell)
    
    --=============================================
    local panel = self:getControl("PromotePanel", nil, cell)
    local playerBuffData = HomeMgr:getPracticeBuffByType(1)
    if not playerBuffData then
        -- 没有加成道具在使用
        panel:setVisible(false)
        cell:setContentSize(cell:getContentSize().width, cell:getContentSize().height - panel:getContentSize().height - 2)
        self.mainPanel:setContentSize(self.mainPanel:getContentSize().width, self.mainPanel:getContentSize().height - panel:getContentSize().height - 2)
        self.listView:refreshView()
        return
    end

    -- 设置加成家具信息
    self:setBuffData(playerBuffData, panel)
end

function HomeCheckDlg:setBuffData(data, panel)

    local ITEM_NAME = {
        [1] = CHS[7190001],  -- 白玉观音像
        [2] = CHS[7190002],   -- 七宝如意
        [3] = CHS[7190000],   -- 金丝鸟笼    
    }

    -- 加成道具设置
    -- 图标
    local imgPath2 = ResMgr:getIconPathByName(ITEM_NAME[data.type])
    self:setImage("GuardImage", imgPath2, panel)

        -- 耐久度
    local furnInfo2 = HomeMgr:getFurnitureInfo(ITEM_NAME[data.type]) or {}
    self:setLabelText("EffectLabel_1", data.furniture_durability .. "/" .. furnInfo2.max_dur or 100, self:getControl("EffectPanel", nil, panel))

    -- 加成值
    self:setLabelText("EffectLabel_1", data.buff_value .. "%", self:getControl("EffectPanel_0", nil, panel))

    if data.amount > 1 then
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, data.amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21, panel)
    end
end

-- 炼器台条目
function HomeCheckDlg:setArtifactInfoPanel(data)
    local cell = self:getControl("ArtifactPanel")
    
    -- 炼器台名字
    self:setLabelText("NameLabel", data.furniture_name, cell)

    -- 耐久度
    self:setLabelText("EffectLabel_1", data.dur .. "/" .. data.max_dur, self:getControl("EffectPanel", nil, cell))

    -- 灵气值
    self:setLabelText("EffectLabel_1", data.nimbus .. "/" .. data.max_nimbus, self:getControl("EffectPanel_0", nil, cell))

    -- 炼器台图标
    if data.artifact and data.artifact.icon then
        local imgPath = ResMgr:getItemIconPath(data.artifact.icon)
        self:setImage("GuardImage", imgPath, cell)
    end

    --==============
    local panel = self:getControl("PromotePanel", nil, cell)
    local artifactBuffData = HomeMgr:getPracticeBuffByType(2)
    if not artifactBuffData then
        -- 没有加成道具在使用
        panel:setVisible(false)
        cell:setContentSize(cell:getContentSize().width, cell:getContentSize().height - panel:getContentSize().height - 2)
        self.mainPanel:setContentSize(self.mainPanel:getContentSize().width, self.mainPanel:getContentSize().height - panel:getContentSize().height - 2)
        self.listView:refreshView()
        return
    end

    -- 设置加成家具信息
    self:setBuffData(artifactBuffData, panel)
end


function HomeCheckDlg:onCheckXiulianButton(sender, eventType)
    if not self.xiulianInfo or not next(self.xiulianInfo) then
        return
    end
    
    HomeMgr:queryHourPlayerPractice("my_data", self.xiulianInfo.furniture_pos)   
end

function HomeCheckDlg:onCheckXiulianBuffButton(sender, eventType)
    local data = HomeMgr:getPracticeBuffByType(1)

    if not data then
        return
    end
    
    -- 应服务器要求，para1 = "data", para2 = "" 固定
    gf:CmdToServer("CMD_HOUSE_REMOTE_USE_FURNITURE", {action = "practice_buff", furniture_pos = data.furniture_pos, para1 = "data", para2 = ""})
end

function HomeCheckDlg:onCheckArtifactBuffButton(sender, eventType)
    local data = HomeMgr:getPracticeBuffByType(2)

    if not data then
        return
    end

    -- 应服务器要求，para1 = "data", para2 = "" 固定
    gf:CmdToServer("CMD_HOUSE_REMOTE_USE_FURNITURE", {action = "practice_buff", furniture_pos = data.furniture_pos, para1 = "data", para2 = ""})
end

function HomeCheckDlg:onCheckArtifactButton(sender, eventType)
    if not self.artifactInfo or not next(self.artifactInfo) then
        return
    end
    
    gf:CmdToServer("CMD_HOUSE_REQUEST_ARTIFACT_INFO")
end

function HomeCheckDlg:onComeBackQTButton(sender)
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5420212]))
    DlgMgr:closeDlg("HomeCheckDlg")
end

function HomeCheckDlg:onComeBackFWButton(sender)
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5420210]))
    DlgMgr:closeDlg("HomeCheckDlg")
end

function HomeCheckDlg:onCheckPetFeedBuffButton(sender, eventType)
    local data = HomeMgr:getPracticeBuffByType(3)

    if not data then
        return
    end

    -- 应服务器要求，para1 = "data", para2 = "" 固定
    gf:CmdToServer("CMD_HOUSE_REMOTE_USE_FURNITURE", {action = "practice_buff", furniture_pos = data.furniture_pos, para1 = "data", para2 = ""})
end

function HomeCheckDlg:onCheckPetFeedButton(sender, eventType)
    if not self.feedPetInfo or #self.feedPetInfo == 0 then
        return
    end
    
    local tag = tonumber(string.match(sender:getParent():getName(), "_(%d)"))
    
    HomeMgr:setCurChooseBowlId(self.feedPetInfo[tag].bowl_pos)
    gf:CmdToServer("CMD_HOUSE_REQUEST_PET_FEED_INFO", {furniture_iid = self.feedPetInfo[tag].bowl_iid})
end

function HomeCheckDlg:MSG_HOUSE_FEEDING_LIST(data)
    self:setData()
end

function HomeCheckDlg:MSG_HOUSE_CUR_ARTIFACT_PRACTICE(data)
    self:setData()
end

function HomeCheckDlg:MSG_HOSUE_CUR_PLAYER_PRACTICE_INFO(data)
    self:setData()
end

function HomeCheckDlg:MSG_HOUSE_ALL_PRACTICE_BUFF_DATA(data)
    self:setData()
end


return HomeCheckDlg
