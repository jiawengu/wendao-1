-- PetStruggleDlg.lua
-- Created by huangzz Sep/20/2017
-- 斗宠大会界面

local PetStruggleDlg = Singleton("PetStruggleDlg", Dialog)
local CONST_DATA =
{
    ContainerTag = 999,
    CS_TYPE_CARD = 8,
    InitNumber = 30,
    CellSpace = 0,
    FloatingFramWidth = 200,
    ChallengePrice = 10,
}

local CHALLENGE_MAX_NUM = 5 -- 最大的挑战次数

local HEIGHT_FONTSIZE19 = 25  -- 战报 19 号字体高度

function PetStruggleDlg:init()
    self:bindListener("ChallengeButton", self.onChallengeButton, "NPCChallengerPanel")
    self:bindListener("LookonButton", self.onLookOnButton, "NPCChallengerPanel")
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:bindListener("PetStruggleOrderButton", self.onPetStruggleOrderButton)
    self:bindListener("CombatResultButton", self.onComBatResultButton)
    self:bindListener("RankButton", self.onRankingListButton)
    self:bindListener("RuleButton", self.onRuleButton)

    for i = 1, 3 do
        self:bindListener("ChallengeButton", self.onChallengeButton, "UserChallengerPanel_" .. i)
        self:bindListener("LookonButton", self.onLookOnButton, "UserChallengerPanel_" .. i)
    end

    self.lastSelectPanel = nil

    self:MSG_DC_OPPONENT_LIST()
    self:MSG_DC_PETS()

    self:hookMsg("MSG_DC_INFO")
    self:hookMsg("MSG_DC_OPPONENT_LIST")
    self:hookMsg("MSG_DC_PETS")
end

function PetStruggleDlg:onChallengeButton(sender, eventType)
    local panel = sender:getParent()
    local no = panel.no
    if not self.myInfo then
        return
    end

    -- 若角色等级不足70级，给予弹出提示
    if Me:queryBasicInt("level") < 70 then
        gf:ShowSmallTips(CHS[5450040])
        return
    end

    -- 若玩家为非暂离队员，给予弹出提示
    if  TeamMgr:inTeam(Me:getId()) and not Me:isTeamLeader() then
        gf:ShowSmallTips(CHS[3004066])
        return
    end

    -- 若玩家今日剩余挑战次数为0，给予弹出提示
    if self.myInfo.left_num <= 0 then
        gf:ShowSmallTips(CHS[5450041])
        return
    end

    -- 若玩家当前出阵宠物数量为0，给予弹出提示
    if self.combatCount <= 0 then
        gf:ShowSmallTips(CHS[5450042])
        return
    end

    ArenaMgr:ChallengeByPet(no)
end

function PetStruggleDlg:onLookOnButton(sender, eventType)
    ArenaMgr:requestLookonPet()
end

function PetStruggleDlg:onChooseInfoType(sender, eventType)
    if self.lastSelectPanel then
        self:setCtrlVisible("ChosenImage", false, self.lastSelectPanel)
        self:setCtrlVisible(self.lastSelectPanel.showPanel, false)
    end

    self.lastSelectPanel = sender
    self:setCtrlVisible("ChosenImage", true, sender)
    self:setCtrlVisible(sender.showPanel, true)
end

-- 刷新对手
function PetStruggleDlg:onRefreshButton(sender, eventType)
    ArenaMgr:refreshOpponentsByPet()
end

-- 宠物布阵界面
function PetStruggleDlg:onPetStruggleOrderButton(sender, eventType)
    DlgMgr:openDlg("PetStruggleOrderDlg")
end

--排行榜
function PetStruggleDlg:onRankingListButton(sender, eventType)
    RankMgr:setOpenByPlace("petStruggle")
    DlgMgr:openDlg("RankingListDlg")
end

-- 战报
function PetStruggleDlg:onComBatResultButton(sender, eventType)
    DlgMgr:openDlg("PetStruggleCombatResultDlg")
end

-- 规则
function PetStruggleDlg:onRuleButton(sender, eventType)
    if self.myInfo then
        DlgMgr:openDlgEx("PetStruggleRuleDlg", self.myInfo)
    end
end

function PetStruggleDlg:initPetsList(data)
    self.combatCount = 0
    for i = 1, 5 do
        local petPanel = self:getControl("PetPanel_" .. i)
        self:setImagePlist("Image", ResMgr.ui.touming, petPanel)
        self:setImagePlist("PolarImage", ResMgr.ui.touming, petPanel)

        local levelPanel = self:getControl("LevelPanel", nil, petPanel)
        levelPanel:removeAllChildren()
    end

    for i = 1, 6 do
        if data[i] then
            self.combatCount = self.combatCount + 1
            local petPanel = self:getControl("PetPanel_" .. self.combatCount)
            local pet = PetMgr:getPetById(data[i])

            -- 头像
            local path = ResMgr:getSmallPortrait(pet:queryBasicInt("portrait"))
            self:setImage("Image", path, petPanel)

            -- 宠物等级
            local petLevel = pet:queryBasicInt("level")
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, petLevel, false, LOCATE_POSITION.LEFT_TOP, 23, petPanel)

            -- 设置宠物相性
            local polar = gf:getPolar(pet:queryBasicInt("polar"))
            local polarPath = ResMgr:getPolarImagePath(polar)
            self:setImagePlist("PolarImage", polarPath, petPanel)
        end
    end
end

function PetStruggleDlg:MSG_DC_PETS(data)
    local data = ArenaMgr.combatPetsOrder
    if not data then
        return
    end

    self:initPetsList(data)
end

function PetStruggleDlg:initOpponentList(data)
    for i = 1, 3 do
        local panel = self:getControl("UserChallengerPanel_" .. (3 - i + 1))

        self:setOneOpponentInfo(data[i], panel)

        -- 排名
        self:setLabelText("RankingLabel", data[i].rank, panel)

        -- 宠物数量
        self:setLabelText("PetNumLabel", CHS[5450037] .. " " .. data[i].num, panel)
    end
end

function PetStruggleDlg:setOneOpponentInfo(data, panel)
    -- 排名
    self:setLabelText("RankingLabel", data.rank, panel)

    -- 宠物数量
    self:setLabelText("PetNumLabel",  CHS[5450037] .. " " .. data.num, panel)

    -- 名字
    self:setLabelText("NameLabel", data.name, panel)

    -- 头像
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.icon), panel)
    self:setItemImageSize("PortraitImage", panel)

    -- 等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 23, panel)

    -- 挑战或观战按钮
    if data.isChallenging == 0 then
        self:setCtrlVisible("ChallengeButton", true, panel)
        self:setCtrlVisible("LookonButton", false, panel)
        self:setCtrlVisible("CombatImage", false, panel)
    else
        self:setCtrlVisible("ChallengeButton", false, panel)
        self:setCtrlVisible("LookonButton", true, panel)
        self:setCtrlVisible("CombatImage", true, panel)
    end

    panel.no = data.no
end

function PetStruggleDlg:setTongziInfo(data)
    local panel = self:getControl("NPCChallengerPanel")
    self:setOneOpponentInfo(data, panel)

    -- 排名
    self:setLabelText("RankingLabel", CHS[5450050], panel)

    -- 宠物数量
    self:setLabelText("PetNumLabel", CHS[5450051], panel)
end

function PetStruggleDlg:MSG_DC_OPPONENT_LIST()
    local data = ArenaMgr.opponentListByPet
    if not data then
        return
    end

    local tongziInfo
    local opponentList = {}
    for i = 1, data["count"] do
        if data[i]["no"] == 0 then
            tongziInfo = data[i]
        else
            table.insert(opponentList, data[i])
        end
    end

    if next(opponentList) then
        self:initOpponentList(opponentList)
    end

    if tongziInfo then
        self:setTongziInfo(tongziInfo)
    end
end

function PetStruggleDlg:getChengWeiImage(rank)
    if rank <= 3 then
        return ResMgr.ui.dcdh_chengwei_xcds
    elseif rank <= 10 then
        return ResMgr.ui.dcdh_chengwei_xczj
    elseif rank <= 50 then
        return ResMgr.ui.dcdh_chengwei_xcdr
    else
        return ResMgr.ui.dcdh_chengwei_none
    end
end

function PetStruggleDlg:initMyinfo(data)
    -- 赛季
    self:setLabelText("TitleLabel_1", CHS[5400294] .. " " .. data.seasonStr .. " " .. CHS[4100386], "BKPanel")
    self:setLabelText("TitleLabel_2", CHS[5400294] .. " " .. data.seasonStr .. " " .. CHS[4100386], "BKPanel")

    -- 剩余次数
    self:setLabelText("LeftLabel_2", data.left_num .. "/" .. CHALLENGE_MAX_NUM, "LeftTimePanel")

    -- 累计可领取武学
    self:setLabelText("LeftLabel_2", data.total_martial .. CHS[5410085], "BonusPanel")

    -- 效率
    local str = data.martial .. CHS[5410085] .. "/20" .. CHS[3003847]
    self:setLabelText("LeftLabel_2", str, "EfficiencyPanel")

    -- 排名
    local panel = self:getControl("MyRankingAtlasLabel", Const.UIAtlasLabel)
    panel:setString(data.rank)

    -- 称谓
    local imagePath = self:getChengWeiImage(data.rank)
    self:setImage("TitleImage", imagePath, "RankPanel")
end

function PetStruggleDlg:MSG_DC_INFO(data)
    self.myInfo = data
    self:initMyinfo(data)
end

return PetStruggleDlg
