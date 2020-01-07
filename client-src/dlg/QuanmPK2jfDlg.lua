-- QuanmPK2jfDlg.lua
-- Created by lixh Jul/16/2018
-- 全民PK赛第2版 积分界面

local QuanmPK2jfDlg = Singleton("QuanmPK2jfDlg", Dialog)

-- 由于ListView中子节点可能有150个，所以才去分页加载，每次加载10个
local PER_PAGE_NUM = 10

function QuanmPK2jfDlg:init()
    self.selectImage = self:retainCtrl("ChosenEffectImage", "MatchPanel")
    self.unitItem = self:retainCtrl("MatchPanel", "UserScorePanel")
    self:bindListViewListener("ListView", self.onSelectListView)
    self:bindTouchPanel()
    self:setCtrlVisible("NoticePanel", true)

    QuanminPK2Mgr:requestQmpkMyData()

    QuanminPK2Mgr:requestQmpkJfInfo()

    self:hookMsg("MSG_CSQ_SCORE_TEAM_DATA")
end

-- 设置界面数据
function QuanmPK2jfDlg:setData()
    self.data = QuanminPK2Mgr:getScoreRankData()
    self.pageStartIndex = 0
    self:resetListView("ListView", Const.UIListView, "UserScorePanel")
    if not self.data or self.data.count == 0 then
        self:setCtrlVisible("NoticePanel", true)
        return
    end

    self:setCtrlVisible("NoticePanel", false)

    -- 增加积分信息
    self:addItems()

    -- 不知道服务器myData与rankData先后，所以都刷新一下我的排行
    self:setMyRank()
end

-- 增加积分信息
function QuanmPK2jfDlg:addItems()
    if not self.data or not self.pageStartIndex then return end
    if self.pageStartIndex >= self.data.count then return end

    local listView = self:getControl("ListView", Const.UIListView, "UserScorePanel")
    for i = self.pageStartIndex + 1, self.pageStartIndex + PER_PAGE_NUM do
        local unitInfo = self.data.list[i]
        if not unitInfo then
            self.pageStartIndex = i
            return
        end

        local item = self:setSingleItem(self.unitItem:clone(), unitInfo, i)
        listView:pushBackCustomItem(item)
    end

    self.pageStartIndex = self.pageStartIndex + PER_PAGE_NUM
end

-- 设置单个积分信息
function QuanmPK2jfDlg:setSingleItem(item, info, index, isMe)
    item.info = info

    local isOdd = index % 2 ~= 0 or isMe
    self:setCtrlVisible("BackImage_1", isOdd, item)
    self:setCtrlVisible("BackImage_2", not isOdd, item)

    self:setLabelText("IndexLabel", index, item)        -- 排名
    self:setLabelText("NameLabel", info.name, item)     -- 队长名称
    self:setLabelText("WinLabel", info.winTimes, item)       -- 胜场
    self:setLabelText("LostLabel", info.lostTimes, item)     -- 负场
    self:setLabelText("QuitLabel", info.giveUpTimes, item)     -- 弃权
    self:setLabelText("WinMaxLabel", info.seriesWinTimes, item) -- 连胜
    self:setLabelText("ScoreLabel", info.score, item)   -- 积分
    return item
end

-- 设置我的排行
function QuanmPK2jfDlg:setMyRank()
    local data = QuanminPK2Mgr:getMyData()
    if not data then return end

    local root = self:getControl("MyselfPanel")
    self:setLabelText("NoteLabel", "", root)

    if not QuanminPK2Mgr:isMeSignUp() or not QuanminPK2Mgr:isMeEnsureTeam() then
        -- 没有报名，或没有确认阵容，都提示没有报名参与比赛
        self:setLabelText("NoteLabel", CHS[7100289], root)
    else
        local meInRank = false
        local rankData = self.data
        if rankData then
            for i = 1, rankData.count do
                if rankData.list[i] and rankData.list[i].teamId == data.teamId then
                    self:setSingleItem(root, data, i, true)
                    meInRank = true
                end
            end
        end

        if not meInRank then
            self:setLabelText("NoteLabel", CHS[7100290], root)
        end
    end
end

-- 滑动ListView，分页加载
function QuanmPK2jfDlg:bindTouchPanel()
    local panel = self:getControl("TouchPanel", Const.UIPanel)
    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        touchPos = panel:getParent():convertToNodeSpace(touchPos)

        local box = panel:getBoundingBox()
        if box and cc.rectContainsPoint(box, touchPos) then
            return true
        end

        return false
    end

    local function onTouchMove(touch, event)
    end

    local function onTouchEnd(touch, event)
        local percent = self:getCurScrollPercent("ListView", true, "UserScorePanel")
        Log:D("The percent is %d%%", percent)

        if percent > 100 then
            self:addItems()
        end
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

function QuanmPK2jfDlg:cleanup()
    self.data = nil
    self.pageStartIndex = nil
end

-- 选中效果
function QuanmPK2jfDlg:addSelectImage(sender)
    self.selectImage:removeFromParent()
    if sender then
        sender:addChild(self.selectImage)
    end
end

function QuanmPK2jfDlg:onSelectListView(sender, eventType)
    local item = self:getListViewSelectedItem(sender)
    if not item then return end

    self:addSelectImage(item)

    gf:CmdToServer("CMD_CSQ_SCORE_TEAM_DATA", {teamId = item.info.teamId})
end

-- 积分排行榜上的队伍数据
function QuanmPK2jfDlg:MSG_CSQ_SCORE_TEAM_DATA(data)
    local dlg = DlgMgr:openDlg("QuanmPKTeamInfoDlg")
    dlg:setData(data)
end

return QuanmPK2jfDlg
