-- ArenaDlg.lua
-- Created by zhengjh Mar/13/2015
-- 竞技场

local ArenaDlg = Singleton("ArenaDlg", Dialog)

local CONST_DATA =
{
    ContainerTag = 999,
    CS_TYPE_CARD = 8,
    InitNumber = 30,
    CellSpace = 0,
    FloatingFramWidth = 200,
    ChallengePrice = 10,
}

local MAX_CHALLENG_TIMES = 5

function ArenaDlg:init()
    self:bindListener("HighestRankingButton", self.onHighestRankingButton)
    self:bindListener("GetRewardButton", self.onGetRewardButton)
    self:bindListener("ReputationStoreButton", self.onReputationStoreButton)
    self:bindListener("RankingListButton", self.onRankingListButton)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:bindListener("AddChanceButton", self.onAddChanceButton)
    self:bindListener("BoyInfoButton", self.onBoyInfoImage)
    self:bindListener("ChallengeTimesInfoButton", self.onChallengeTimesInfoImage)
    self:bindListener("ChangeGuardButton", self.onChangeGuardButton)
    self:bindListener("ShowRecordButton", self.onShowRecordButton)
    self:bindListener("HideRecordButton", self.onHideRecordButton)


    self:hookMsg("MSG_ARENA_INFO")
    self:hookMsg("MSG_ARENA_OPPONENT_LIST")
    self:hookMsg("MSG_CHALLENGE_MSG")
    self:hookMsg("MSG_GUARDS_REFRESH")
    self:hookMsg("MSG_ARENA_TOP_BONUS_LIST")
    self:hookMsg("MSG_UPDATE")

    self.oneRecord1 = self:getControl("OneRecordPanel1")
    self.oneRecord1:retain()
    self.oneRecord1:removeFromParent()

    self.oneRecord2 = self:getControl("OneRecordPanel2")
    self.oneRecord2:retain()
    self.oneRecord2:removeFromParent()


    self.showRecordList = false
    ArenaMgr:openArena()
    self.number = 1
    self:setRecordInfo()
    self:MSG_GUARDS_REFRESH() -- 初值化守护信息
    self:MSG_UPDATE()
end

function ArenaDlg:cleanup()
    if self.oneRecord1 then
        self.oneRecord1:release()
        self.oneRecord1 = nil
    end

    if self.oneRecord2 then
        self.oneRecord2:release()
        self.oneRecord2 = nil
    end

    FriendMgr:unrequestCharMenuInfo(self.name)
end

function ArenaDlg:onHighestRankingButton(sender, eventType)
    ArenaMgr:getTopRewardList()
end

function ArenaDlg:MSG_ARENA_TOP_BONUS_LIST()
    DlgMgr:openDlg("ArenaRewardDlg")
end

function ArenaDlg:MSG_CHALLENGE_MSG()
    self:newMessage()
end

function ArenaDlg:onGetRewardButton(sender, eventType)
    ArenaMgr:getTimeCountReward()
end

function ArenaDlg:onReputationStoreButton(sender, eventType)
    ArenaMgr:openArenaStore()
end

function ArenaDlg:onRankingListButton(sender, eventType)
    --RankMgr:setLastSelectRankTypeAndSubType(7, 1)
    RankMgr:setOpenByPlace("arena")
    DlgMgr:openDlg("RankingListDlg")
end

function ArenaDlg:onRuleButton(sender, eventType)
    DlgMgr:openDlg("ArenaRuleDlg")
end

function ArenaDlg:onRefreshButton(sender, eventType)
    ArenaMgr:refreshChallenger()
end

function ArenaDlg:onAddChanceButton(sender, eventType)
    self:buyChallengeTimes(string.format(CHS[3002265],CONST_DATA.ChallengePrice))
end

function ArenaDlg:onBoyInfoImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    self:showInfo(rect, CHS[6000103])
end

function ArenaDlg:onChallengeTimesInfoImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    self:showInfo(rect, CHS[6000104])
end

function ArenaDlg:showInfo(rect, text)
    local dlg = DlgMgr:openDlg("FloatingFrameDlg")
    dlg:setText(text, CONST_DATA.FloatingFramWidth)
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

-- 调整守护
function ArenaDlg:onChangeGuardButton()
    DlgMgr:openDlg("GuardAttribDlg")
end

function ArenaDlg:loadRecordData()
    local innerSizeheight = 0
    local recordTable = ArenaMgr:getRecordData("area")
    local container = self.scrollView:getChildByTag(CONST_DATA.ContainerTag)
    container:removeAllChildren()

    local sartIndex = 0
    if  #recordTable - CONST_DATA.InitNumber + 1 < 1 then
        sartIndex = 1
    else
        sartIndex = #recordTable - CONST_DATA.InitNumber + 1
    end

    for  i = sartIndex, #recordTable do
        local cellPanel
        if i % 2 == 0 then
            cellPanel = self.oneRecord1:clone()
        else
            cellPanel = self.oneRecord2:clone()
        end
        self:setOneRecord(cellPanel, recordTable[i])
        cellPanel:setAnchorPoint(0.5,0)
        cellPanel:setPosition(self.scrollView:getContentSize().width / 2, innerSizeheight)
        innerSizeheight =innerSizeheight + cellPanel:getContentSize().height + CONST_DATA.CellSpace
        container:addChild(cellPanel, 0 , i)
    end
    container:setContentSize(self.scrollView:getContentSize().width, innerSizeheight - CONST_DATA.CellSpace)

    -- 内容小于显示区域往上移
    if container:getContentSize().height < self.scrollView:getContentSize().height then
        for  i = sartIndex, #recordTable do
            local cell = container:getChildByTag(i)
            local posx, posy = cell:getPosition()
            cell:setPosition(posx, posy + self.scrollView:getContentSize().height - innerSizeheight)
        end

    end

    self.scrollView:setInnerContainerSize(container:getContentSize())
end

-- 最新的战报
function ArenaDlg:setCurRecord()
    local recordPanel = self:getControl("RecordPanel")
    local oneRecordPanel = self:getControl("OneRecordPanel", Const.UIPanel, recordPanel)
    local labelPanel = self:getControl("LablePanel", Const.UIPanel, oneRecordPanel)
    local recordTable = ArenaMgr:getRecordData("area")
    labelPanel:removeAllChildren()
    if #recordTable == 0 then
        local lable = ccui.Text:create()
        lable:setColor(COLOR3.TEXT_DEFAULT)
        lable:setPosition(5, labelPanel:getContentSize().height / 2)
        lable:setAnchorPoint(0, 0.5)
        lable:setString(CHS[3002266])
        lable:setFontSize(19)
        labelPanel:addChild(lable)
    else
        self:setOneRecord(labelPanel, recordTable[#recordTable])
    end
end

-- 初值化战报
function ArenaDlg:setRecordInfo()
    local recordPanel = self:getControl("RecordPanel")
    local allRecordPanel = self:getControl("AllRecordPanel", Const.UIPanel, recordPanel)
    local recordTable = ArenaMgr:getRecordData("area")

    local size = allRecordPanel:getContentSize()
    self.scrollView = ccui.ScrollView:create()
    local container = ccui.Layout:create()
    container:setPosition(0,0)
    self.scrollView:setContentSize(size.width, size.height - 5)
    self.scrollView:setDirection(ccui.ScrollViewDir.vertical)
    self.scrollView:addChild(container, 0, CONST_DATA.ContainerTag)
    self.scrollView:setAnchorPoint(0.5, 0.5)
    self.scrollView:setPosition(size.width / 2, size.height / 2)
    allRecordPanel:addChild(self.scrollView)

    self:loadRecordData()
    self:setCurRecord()
end

function ArenaDlg:onShowRecordButton()
    local recordPanel = self:getControl("RecordPanel")
    local oneRecordPanel = self:getControl("OneRecordPanel", Const.UIPanel, recordPanel)
    local allRecordPanel = self:getControl("AllRecordPanel", Const.UIPanel, recordPanel)
    local hideBtn = self:getControl("HideRecordButton")
    local showBtn = self:getControl("ShowRecordButton")
    oneRecordPanel:setVisible(false)
    allRecordPanel:setVisible(true)
    hideBtn:setVisible(true)
    showBtn:setVisible(false)
end

function ArenaDlg:onHideRecordButton()
    local recordPanel = self:getControl("RecordPanel")
    local oneRecordPanel = self:getControl("OneRecordPanel", Const.UIPanel, recordPanel)
    local allRecordPanel = self:getControl("AllRecordPanel", Const.UIPanel, recordPanel)
    oneRecordPanel:setVisible(true)
    allRecordPanel:setVisible(false)
    local hideBtn = self:getControl("HideRecordButton")
    local showBtn = self:getControl("ShowRecordButton")
    hideBtn:setVisible(false)
    showBtn:setVisible(true)
end


-- record_time 战报时间
-- challenge_staus 0表示挑战    1表示被挑战
-- gid
-- player_name
-- vectory_status 0表示胜利   1表示失败
-- last_ranking  上次排名
-- cur_ranking  本次排名
function ArenaDlg:setOneRecord(cell, data)
    local recordPanel = ccui.Layout:create()

    -- 获取单条战报内容
    local text = string.format("%s%s%s%s", self:getTimestr(data["record_time"]), self:createChallengeStr(data),
        self:createVectoryStatusStr(data["vectory_status"]), self:createRankStr(data["last_ranking"], data["cur_ranking"]))

    local lableText = CGAColorTextList:create()
    lableText:setFontSize(19)
    lableText:setContentSize(cell:getContentSize().width, 0)
    lableText:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    lableText:setString(text)
    lableText:updateNow()
    recordPanel:addChild(tolua.cast(lableText, "cc.LayerColor"))
    local labelW, labelH = lableText:getRealSize()
    recordPanel:setContentSize(labelW, labelH)
    lableText:setPosition(0,labelH)
    recordPanel:setTouchEnabled(true)

    local function ctrlTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 处理类型点击
            if data["gid"] == "" then   -- 目标位npc
                gf:ShowSmallTips(CHS[6000139])
            else
                FriendMgr:requestCharMenuInfo(data["gid"], {
                    needCallWhenFail = true,
                    gid = data["gid"],
                    requestDlg = self.name
                })
            end
        end
    end

    recordPanel:addTouchEventListener(ctrlTouch)
    recordPanel:setAnchorPoint(0, 0.5)
    recordPanel:setPosition(5, cell:getContentSize().height / 2)
    cell:addChild(recordPanel, 5, 0)
end

-- 获取时间
function ArenaDlg:getTimestr(servTime)
    local time = gf:getServerTime() - servTime
    local timeStr = ""
    local days = math.floor(time / (3600 *24))

    if days >= 30 then
        timeStr =  CHS[6000085]
    elseif days > 1 then
        timeStr =  string.format(CHS[6000086], days)
    else
        local hours = math.floor(time / 3600)

        if hours >= 1 then
            timeStr = string.format(CHS[6000087], hours)
        else
            local minutes = math.floor(time / 60)

            if minutes <= 0 then
                timeStr = string.format(CHS[6000088], 1)
            else
                timeStr = string.format(CHS[6000088], minutes)
            end
        end
    end

	return timeStr
end

-- 获取挑战字符串
function ArenaDlg:createChallengeStr(data)
    local challengeStr = ""
    if data["challenge_staus"] == 0 then
        challengeStr = string.format(CHS[6000089], data["player_name"])
    elseif data["challenge_staus"] == 1 then
        challengeStr = string.format(CHS[6000090], data["player_name"])
    end

    return challengeStr
end

-- 获取胜利失败字符串
function ArenaDlg:createVectoryStatusStr(vectoryStatus)
	local vectoryStatusStr = ""

	if vectoryStatus == 0 then
        vectoryStatusStr = CHS[6000091]
	else
        vectoryStatusStr = CHS[6000092]
	end

    return vectoryStatusStr
end

-- 获取排名字符串
function ArenaDlg:createRankStr(lastRank, curRank)
    local rankStr = ""

    if lastRank > curRank then
        rankStr = string.format(CHS[6000095],lastRank - curRank)
    elseif lastRank == curRank then
        rankStr = CHS[6000094]
    else
        if curRank > 5000 then
            rankStr = string.format(CHS[6000093],5500 - lastRank)
        else
            rankStr = string.format(CHS[6000093],curRank - lastRank)
        end
    end

    return rankStr
end

function ArenaDlg:newMessage()
    self:loadRecordData()
    self.scrollView:scrollToTop(0.01,false)
    self:setCurRecord()
end

function ArenaDlg:setChallengePanel()
    -- 玩家数据
    local challengerList,tongziList = ArenaMgr:getChallengrList()

    for i = 1, 3 do
        local challengerPanel = self:getControl(string.format("ChallengerPanel%d", i), Const.UIPanel)
        self:setChallengerInfo(challengerPanel, challengerList[i])
    end

    -- 童子
    local boyPanel = self:getControl("BoyPanel", Const.UIPanel)
    self:setTongziInfo(boyPanel,tongziList[1])
end

function ArenaDlg:setTongziInfo(panel, data)

    -- 名字
    --[[local nameLabel = self:getControl("NameLabel", Const.UILabel, panel)
    nameLabel:setString(data["name"])

    -- 道行
    local daoLabel = self:getControl("ReligionLabel", Const.UILabel, panel)
    daoLabel:setString(gf:getTaoStr(data["daohang"], 0))

    -- 玩家等级
    local levelLabel = self:getControl("LevelLabel", Const.UILabel, panel)
    levelLabel:setString(data["level"])]]

    -- 玩家头像
    local imgPath = ResMgr:getSmallPortrait(data["icon"])
    local image = self:getControl("PortraitImage", Const.UIImage, panel)
    image:loadTexture(imgPath)
    self:setItemImageSize("PortraitImage", panel)
    local challengBtn = self:getControl("ChallengeButton", Const.UIButton, panel)

    local function btnTouch(sender, type)
        if type == ccui.TouchEventType.ended then
            self:challenge(data["key"])
        end
    end
    challengBtn:addTouchEventListener(btnTouch)
    panel:addTouchEventListener(btnTouch)
end

function ArenaDlg:setChallengerInfo(panel, data)
    -- 排名
    local rankingLabel = self:getControl("RankingLabel", Const.UILabel, panel)
    rankingLabel:setString(CHS[3002267]..data["rank"])

    -- 名字
    local nameLabel = self:getControl("NameLabel", Const.UILabel, panel)
    nameLabel:setString(gf:getRealName(data["name"]))

    -- 帮派
    local partyLabel = self:getControl("PartyLabel", Const.UILabel, panel)

    if data["party"] == "" then
        partyLabel:setString(CHS[6000132])
    else
        partyLabel:setString(data["party"])
    end


    -- 道行
    local taoLabel = self:getControl("TaoLabel", Const.UILabel, panel)
    local tao = data["daohang"]

    if  math.floor(tao / 360) >= 100 then
        taoLabel:setString(math.floor(tao / 360)..CHS[3002268])
    else
        taoLabel:setString(gf:getTaoStr(tao, 0))
    end

    -- 玩家等级
    local levelLabel = self:getControl("LVLabel", Const.UILabel, panel)
    --levelLabel:setString(data["level"])
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data["level"], false, LOCATE_POSITION.LEFT_TOP, 21, panel)


    -- 玩家头像
    local imgPath = ResMgr:getSmallPortrait(data["icon"])
    local image = self:getControl("PortraitImage", Const.UIImage, panel)
    image:loadTexture(imgPath)
    self:setItemImageSize("PortraitImage", panel)
    local challengBtn = self:getControl("ChallengeButton", Const.UIButton, panel)

    local function btnTouch(sender, type)
        if type == ccui.TouchEventType.ended then
            self:challenge(data["key"])
        end
    end

    challengBtn:addTouchEventListener(btnTouch)
    panel:addTouchEventListener(btnTouch)
end

-- 挑战
function ArenaDlg:challenge(key)
    local arenaInfo = ArenaMgr:getArenaInfo()
    if not arenaInfo then return end
    if arenaInfo["challengLeftTimes"] > 0 then
        gf:confirm(CHS[3002269], function()
            ArenaMgr:challenge(key)
        end)
    else
        gf:ShowSmallTips(CHS[6000125])
    end
end

-- 购买次数
function ArenaDlg:buyChallengeTimes(str)
    local arenaInfo = ArenaMgr:getArenaInfo()

    if arenaInfo["buyLeftTimes"] > 0 then
        gf:confirm(str, function()
            local coin = Me:queryBasicInt('gold_coin') + Me:queryBasicInt('silver_coin')
            if coin < CONST_DATA.ChallengePrice then
                gf:askUserWhetherBuyCoin()
            else
                ArenaMgr:buyChallengeTimes()
            end
        end)
    else
        if Me:getVipType() == 3 then
            gf:ShowSmallTips(CHS[3002270])
        else
            gf:ShowSmallTips(CHS[3002271])
        end
    end
end

-- 刷新基本信息
function ArenaDlg:MSG_ARENA_INFO()
   local arenaInfo = ArenaMgr:getArenaInfo()

   -- 排名
   local rankingLabel = self:getControl("MyRankingAtlasLabel", Const.UIAtlasLabel)
   rankingLabel:setString(arenaInfo["rank"])

   -- 每20分钟获取的奖励
   local rewardLabel = self:getControl("RewardLabel", Const.UILabel)
   rewardLabel:setString(arenaInfo["rewardNumber"]..CHS[3002272])


   -- 已获得奖励
  --[[ local totalRewardLabel = self:getControl("TotalRewardLabel", Const.UILabel)
   totalRewardLabel:setString(arenaInfo["totalReward"])

   local getRewardBtn = self:getControl("GetRewardButton", Const.UIButton)

   if arenaInfo["totalReward"] <= 0 then
        gf:grayImageView( getRewardBtn)
        getRewardBtn:setTouchEnabled(false)
   else
        gf:resetImageView( getRewardBtn)
        getRewardBtn:setTouchEnabled(true)
   end]]

   -- 挑战次数
   local timesLabel = self:getControl("ChanceLabel", Const.UILabel)
   timesLabel:setString(string.format(CHS[6000124], arenaInfo["challengLeftTimes"]))

   self:updateLayout("TopPanel")
end

function ArenaDlg:MSG_UPDATE()
    -- 拥有的声望
  --  local totalRewardLabel = self:getControl("TotalRewardLabel", Const.UILabel)
  --  totalRewardLabel:setString(Me:queryBasic("reputation"))

    local text = gf:getArtFontMoneyDesc(Me:queryBasicInt("reputation"))
    self:setNumImgForPanel("TotalRewardPanel", ART_FONT_COLOR.DEFAULT, text, false, LOCATE_POSITION.MID, 23)
    self:updateLayout("TopPanel")
end

function ArenaDlg:setTeamInfo(gaurdList)
    -- 道行
    local teamPanel = self:getControl("TeamPanel")
    local taoLabel = self:getControl("TaoLabel", Const.UILabel, teamPanel)
    local tao = Me:queryBasicInt("tao")

    if  math.floor(tao / 360) >= 100 then
        taoLabel:setString(CHS[3002273]..math.floor(tao / 360)..CHS[3002268])
    else
        taoLabel:setString(CHS[3002273]..gf:getTaoStr(Me:queryBasicInt("tao"), 0))
    end

    -- 玩家头像等级
    local playerPanel = self:getControl("PlayerPanel")
    local imgPath = ResMgr:getSmallPortrait(Me:queryBasic("icon"))
    local image = self:getControl("HeadImage", Const.UIImage, playerPanel)
    image:loadTexture(imgPath)
    self:setItemImageSize("HeadImage", playerPanel)
    local levelLabel = self:getControl("LVLabel", Const.UILabel, playerPanel)
    --levelLabel:setString(Me:queryBasic("level"))
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, Me:queryBasic("level"), false, LOCATE_POSITION.LEFT_TOP, 21, playerPanel)

    -- 守护队列
    for i = 1, 4 do
        local panel = self:getControl(string.format("GuardPanel%d", i))
        local guardImg =  self:getControl("HeadImage", Const.UIImage, panel)
        if i <= #gaurdList then
            local imgPath = ResMgr:getSmallPortrait(gaurdList[i]["icon"])
            guardImg:loadTexture(imgPath)
            self:setItemImageSize("HeadImage", panel)
        else
            guardImg:loadTexture(ResMgr.ui.bag_item_bg_img, ccui.TextureResType.plistType)
        end
    end

end

-- 刷新守护队列
function ArenaDlg:MSG_GUARDS_REFRESH()
    self:setTeamInfo(GuardMgr:getGuardListByFight(true))
end

-- 刷新对手
function ArenaDlg:MSG_ARENA_OPPONENT_LIST()
    self:setChallengePanel()
end

-- 新手引导
function ArenaDlg:getSelectItemBox(param)
    if param == "challeng" then
         -- 新手指引
        local challengerPanel = self:getControl("ChallengerPanel1", Const.UIPanel)
        local image = self:getControl("PortraitImage", Const.UIImage, challengerPanel)
        self.rect = self:getBoundingBoxInWorldSpace(image)
        return self.rect
    end
end

function ArenaDlg:onCharInfo(gid, isFail)
    if isFail then
        gf:ShowSmallTips(CHS[6000139])
    else
        local dlg = DlgMgr:openDlg("CharMenuContentDlg")
        if dlg then
            local dlgSize = dlg.root:getContentSize()
            local x = Const.WINSIZE.width * 0.5 - dlgSize.width
            if x - dlgSize.width * 0.5 < 0 then x = dlgSize.width * 0.5 + 20 end
            dlg.root:setPositionX(x)
            dlg:setting(gid)
        end
    end
end

return ArenaDlg
