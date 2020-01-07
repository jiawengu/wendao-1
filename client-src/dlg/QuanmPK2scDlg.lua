-- QuanmPK2scDlg.lua
-- Created by lixh Jul/16/2018
-- 全民PK赛第2版 赛程表

local QuanmPK2scDlg = Singleton("QuanmPK2scDlg", Dialog)

-- 记录菜单选择的时间
local RECORD_MENU_TIME = 150

local MENU_TYPE = {
    TAOTAI = 1,   -- 淘汰赛
    FINAL  = 2,   -- 总决赛
}

-- 页码
local PAGE_NUM = {MIN = 1, MAX = 8}

function QuanmPK2scDlg:init()
    self:bindListener("MatchButton", self.onMatchButton)
    self:bindListener("FinalsButton", self.onFinalsButton)
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindTeamListener()
    self:setTime()

    self:hookMsg("MSG_CSQ_KICKOUT_TEAM_DATA")

    self.page = 1

    if QuanminPK2Mgr:haveScFinalData() then
        -- 当前已经是8强赛阶段时，直接选择总决赛
        self:chooseMenu(MENU_TYPE.FINAL)
        return
    end

    if not self.chooseRecord then
        -- 没有记录过选择时，默认选择淘汰赛
        self:chooseMenu(MENU_TYPE.TAOTAI)
    else
        local meGid = Me:queryBasic("gid")
        local type, time = string.match(self.chooseRecord, "(.+)" .. meGid .. "(.+)")
        if not type or not time then
            -- 不匹配，可能更换了账号
            self:chooseMenu(MENU_TYPE.TAOTAI)
        else
            type = tonumber(type)
            time = tonumber(time)
            if gf:getServerTime() - time > RECORD_MENU_TIME then
                -- 记录时间超时，默认选择时间选项
                self:chooseMenu(MENU_TYPE.TAOTAI)
            else
                self:chooseMenu(type)
            end
        end
    end
end

-- 刷新数据
function QuanmPK2scDlg:setData()
    local data = QuanminPK2Mgr:getScData()
    if not data then return end

    -- 刷新当前页的赛程数据
    self:setDataByPage(self.page)

    -- 刷新决赛的赛程数据
    self:setFinalData()
end

-- 选择菜单
function QuanmPK2scDlg:chooseMenu(type)
    if type == MENU_TYPE.FINAL and not QuanminPK2Mgr:haveScFinalData() then
        return
    end

    local isTaotai = type == MENU_TYPE.TAOTAI
    self:setCtrlVisible("MatchImage", isTaotai)
    self:setCtrlVisible("FinalsImage", not isTaotai)
    self:setCtrlVisible("MatchPanel", isTaotai)
    self:setCtrlVisible("FinalsPanel", not isTaotai)

    local meGid = Me:queryBasic("gid")
    self.chooseRecord = type .. meGid .. gf:getServerTime()
end

-- 设置赛程时间
function QuanmPK2scDlg:setTime()
    local timeData = QuanminPK2Mgr:getScTimeData()
    if not timeData then return end

    for i = 1, timeData.kickoutNum do
        local info = timeData.kickoutList[i]
        if info then
            self:setLabelText("TimeLabel_2", gf:getServerDate(CHS[7100288], info.startTime), "TimePanel_" .. i)
        end
    end

    self:setLabelText("TimeLabel_2", gf:getServerDate(CHS[7100288], timeData.finalStartTime), "TimePanel_6")
end

-- 绑定队伍信息
function QuanmPK2scDlg:bindTeamListener()
    local function onTouchTeam(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender.teamId and sender.teamId ~= "" then
                gf:CmdToServer("CMD_CSQ_KICKOUT_TEAM_DATA", {teamId = sender.teamId})
            end
        end
    end

    local matchRoot = self:getControl("MatchPanel")
    for i = 1, 16 do
        local ctrl = self:getControl("16TeamPanel" .. i, Const.UIPanel, matchRoot)
        ctrl:addTouchEventListener(onTouchTeam)
    end

    local finalRoot = self:getControl("FinalsPanel")
    for i = 1, 8 do
        local ctrl = self:getControl("8TeamPanel" .. i, Const.UIPanel, finalRoot)
        ctrl:addTouchEventListener(onTouchTeam)
    end
end

-- 根据页码设置内容
function QuanmPK2scDlg:setDataByPage(page)
    self.page = page
    self:setColorText(string.format(CHS[7120062], self.page, PAGE_NUM.MAX),
        "PageInfoPanel", "PagePanel", nil, nil, nil, nil, true)

    local data16, data8, data4, data2, data1 = self:getPageData(page)
    if not data16 then return end

    local root = self:getControl("MatchPanel")
    for i = 1, #data16 do
        local teamPanel = self:getControl("16TeamPanel" .. i, Const.UIPanel, root)
        teamPanel.teamId = nil
        if data16[i].teamId == "" then
            self:setLabelText("TeamLabel", "", teamPanel)
            self:setLabelText("Label", "", teamPanel)
        else
            self:setLabelText("TeamLabel", data16[i].name, teamPanel)
            self:setLabelText("Label", data16[i].rank, teamPanel)
            teamPanel.teamId = data16[i].teamId
        end
    end

    for i = 1, #data8 do
        local teamPanel = self:getControl("8Result" .. i, Const.UIImage, root)
        teamPanel.teamId = nil
        teamPanel.noResult = data8[i].noResult
        if data8[i].teamId == "" then
            -- 未决出64强
            self:setLabelText("Label", CHS[7100295], teamPanel)
        else
            self:setLabelText("Label", data8[i].rank, teamPanel)
            teamPanel.teamId = data8[i].teamId
        end
    end

    for i = 1, #data4 do
        local teamPanel = self:getControl("4Panel" .. i, Const.UIPanel, root)
        teamPanel.teamId = nil
        if data4[i].teamId == "" then
            -- 未决出32强
            self:setLabelText("Label", CHS[7100296], teamPanel)
        else
            self:setLabelText("Label", data4[i].rank, teamPanel)
            teamPanel.teamId = data4[i].teamId
        end
    end

    for i = 1, #data2 do
        local teamPanel = self:getControl("2Panel" .. i, Const.UIPanel, root)
        teamPanel.teamId = nil
        if data2[i].teamId == "" then
            -- 未决出16强
            self:setLabelText("Label", CHS[7100297], teamPanel)
        else
            self:setLabelText("Label", data2[i].rank, teamPanel)
            teamPanel.teamId = data2[i].teamId
        end
    end

    local teamPanel = self:getControl("1Panel", Const.UIPanel, root)
    teamPanel.teamId = nil
    if data1.teamId == "" then
        -- 未决出8强
        self:setLabelText("Label", CHS[7100298], teamPanel)
    else
        self:setLabelText("Label", data1.rank, teamPanel)
        teamPanel.teamId = data1.teamId
    end

    -- 刷新线条颜色
    local root = self:getControl("MatchPanel")
    self:refreshLineColor(64, root)
    self:refreshLineColor(32, root)
    self:refreshLineColor(16, root)
    self:refreshLineColor( 8, root)
end

-- 刷新线条颜色
function QuanmPK2scDlg:refreshLineColor(type, root)
    local cfg = {
         [64] = {count = 8, lineName = "16LineImage", parent = "16TeamPanel", son = "8Result"}, -- MatchPanel
         [32] = {count = 4, lineName =  "8LineImage", parent =    "8Result",  son =  "4Panel"}, -- MatchPanel
         [16] = {count = 2, lineName =  "4LineImage", parent =     "4Panel",  son =  "2Panel"}, -- MatchPanel
          [8] = {count = 1, lineName =  "2LineImage", parent =     "2Panel",  son =  "1Panel"}, -- MatchPanel
          [4] = {count = 4, lineName =  "8LineImage", parent = "8TeamPanel",  son =  "4Result"},-- FinalsPanel
          [2] = {count = 2, lineName =  "4LineImage", parent =    "4Result",  son =  "2Panel"}, -- FinalsPanel
    }

    if not cfg[type] then return end

    for i = 1, cfg[type].count do
        local parent1 = self:getControl(cfg[type].parent .. (i * 2 - 1), nil, root)
        local parent2 = self:getControl(cfg[type].parent .. (i * 2), nil, root)
        local parent1TeamId = parent1.teamId
        local parent2TeamId = parent2.teamId
        if type == 64 or type == 4 then
            -- 128强, 决赛8强需要恢复地板颜色
            self:resetPanelGray(parent1)
            self:resetPanelGray(parent2)
        end

        local sonTeamId
        local sonNoResult
        if type == 8 then
            sonTeamId = self:getControl(cfg[type].son, nil, root).teamId
            sonNoResult = self:getControl(cfg[type].son, nil, root).noResult
        else
            sonTeamId = self:getControl(cfg[type].son .. i, nil, root).teamId
            sonNoResult = self:getControl(cfg[type].son .. i, nil, root).noResult
        end

        if type == 8 then
            -- 8强只有一条线
            gf:removeRedEffect(self:getControl(cfg[type].lineName .. "1", Const.UIImage, root))
            gf:removeRedEffect(self:getControl(cfg[type].lineName .. "2", Const.UIImage, root))
        else
            gf:removeRedEffect(self:getControl(cfg[type].lineName .. (i * 2 - 1) .. "1", Const.UIImage, root))
            gf:removeRedEffect(self:getControl(cfg[type].lineName .. (i * 2 - 1) .. "2", Const.UIImage, root))
            gf:removeRedEffect(self:getControl(cfg[type].lineName .. (i * 2) .. "1", Const.UIImage, root))
            gf:removeRedEffect(self:getControl(cfg[type].lineName .. (i * 2) .. "2", Const.UIImage, root))
        end

        if type == 2 then
            -- 2强多一条线
            gf:removeRedEffect(self:getControl("2LineImage" .. i, Const.UIImage, root))
        end

        if sonTeamId and (parent1TeamId or parent2TeamId) then
            if parent1TeamId and sonTeamId == parent1TeamId then
                if type == 8 then
                    -- 8强只有一条线
                    gf:addRedEffect(self:getControl(cfg[type].lineName .. "1", Const.UIImage, root))
                else
                    gf:addRedEffect(self:getControl(cfg[type].lineName .. (i * 2 - 1) .. "1", Const.UIImage, root))
                    gf:addRedEffect(self:getControl(cfg[type].lineName .. (i * 2 - 1) .. "2", Const.UIImage, root))
                    if type == 64 or type == 4 then
                        -- 128强, 决赛8强需要置灰地板
                        self:setPanelGray(parent2)
                    end
                end

                if type == 2 then
                    -- 2强多一条线
                    gf:addRedEffect(self:getControl("2LineImage" .. i, Const.UIImage, root))
                end
            elseif parent2TeamId and sonTeamId == parent2TeamId then
                if type == 8 then
                    -- 8强只有一条线
                    gf:addRedEffect(self:getControl(cfg[type].lineName .. "2", Const.UIImage, root))
                else
                    gf:addRedEffect(self:getControl(cfg[type].lineName .. (i * 2) .. "1", Const.UIImage, root))
                    gf:addRedEffect(self:getControl(cfg[type].lineName .. (i * 2) .. "2", Const.UIImage, root))
                    if type == 64 or type == 4 then
                        -- 128强, 决赛8强需要置灰地板
                        self:setPanelGray(parent1)
                    end
                end

                if type == 2 then
                    -- 2强多一条线
                    gf:addRedEffect(self:getControl("2LineImage" .. i, Const.UIImage, root))
                end
            end
        elseif (type == 64 or type == 4) and not sonNoResult then
            -- sonTeamId 与 两个父物体的id都不相等，且比赛结果已经出来了，则认为轮空，两者都失败
            self:setPanelGray(parent1)
            self:setPanelGray(parent2)
        end
    end
end

-- 根据页码获取每一页的数据
function QuanmPK2scDlg:getPageData(page)
    local data16 = self:getScData(16, page)
    local data8  = self:getScData(8, page)
    local data4  = self:getScData(4, page)
    local data2  = self:getScData(2, page)
    local data1  = self:getScData(1, page)
    return data16, data8, data4, data2, data1
end

function QuanmPK2scDlg:getScData(type, page)
    local data = QuanminPK2Mgr:getScData()
    if not data then return end
    local startIndex = 0
    if type == 8 then
        startIndex = 128
    elseif type == 4 then
        startIndex = 128 + 64
    elseif type == 2 then
        startIndex = 128 + 64 + 32
    elseif type == 1 then
        startIndex = 128 + 64 + 32 + 16
        return data[startIndex + page]
    end

    local ret  = {}
    for i = startIndex + (page - 1) * type + 1, startIndex + page * type do
        table.insert(ret, data[i])
    end

    return ret
end

-- 根据决赛内容
function QuanmPK2scDlg:setFinalData()
    local data8 = self:getFinalData(8) -- 8强
    local data4 = self:getFinalData(4) -- 4强
    local data2 = self:getFinalData(2) -- 2强
    local data1 = self:getFinalData(1) -- 冠军
    local data0 = self:getFinalData(0) -- 季军
    if not data8 then return end

    local root = self:getControl("FinalsPanel")
    for i = 1, #data8 do
        local teamPanel = self:getControl("8TeamPanel" .. i, Const.UIPanel, root)
        self:setLabelText("TeamLabel", data8[i].name, teamPanel)
        self:setLabelText("Label", data8[i].rank, teamPanel)
        teamPanel.teamId = data8[i].teamId
    end

    for i = 1, #data4 do
        local teamPanel = self:getControl("4Result" .. i, Const.UIImage, root)
        teamPanel.noResult = data4[i].noResult
        if data4[i].teamId == "" then
            -- 未决出4强
            self:setLabelText("Label", CHS[7100299], teamPanel)
        else
            self:setLabelText("Label", data4[i].rank, teamPanel)
            teamPanel.teamId = data4[i].teamId
        end
    end

    -- 冠军，亚军，季军，殿军需要特殊处理
    local championRoot = self:getControl("ChampionFightPanel")
    local jijunRoot = self:getControl("ThirdFightPanel")
    local teamPanel1 = self:getControl("2Panel" .. 1, Const.UIPanel, championRoot)
    local teamPanel2 = self:getControl("2Panel" .. 2, Const.UIPanel, championRoot)
    local teamPanel3 = self:getControl("3Panel" .. 1, Const.UIPanel, jijunRoot)
    local teamPanel4 = self:getControl("3Panel" .. 2, Const.UIPanel, jijunRoot)
    local data3 = {}
    if data2[1] and data2[1].teamId == "" then
        -- 未决出1,2名与3,4名
        self:setLabelText("Label", CHS[7100300], teamPanel1)
        self:setLabelText("Label", CHS[7100300], teamPanel2)
        self:setLabelText("Label", CHS[7100301], teamPanel3)
        self:setLabelText("Label", CHS[7100301], teamPanel4)
    else
        self:setLabelText("Label", data2[1].rank, teamPanel1)
        teamPanel1.teamId = data2[1].teamId
        self:setLabelText("Label", data2[2].rank, teamPanel2)
        teamPanel2.teamId = data2[2].teamId
        for i = 1, #data4 do
            -- data4中不在data2的玩家，即为季军与殿军
            if data4[i].teamId ~= data2[1].teamId and data4[i].teamId ~= data2[2].teamId then
                table.insert(data3, data4[i])
            end
        end

        self:setLabelText("Label", data3[1].rank, teamPanel3)
        teamPanel3.teamId = data3[1].teamId
        self:setLabelText("Label", data3[2].rank, teamPanel4)
        teamPanel4.teamId = data3[2].teamId
    end

    -- 冠军
    if data1 and data1.teamId ~= "" then
        local championImage = self:getControl("ChampionImage", nil, championRoot)
        self:setLabelText("Label", data1.name, championImage)
        championImage.teamId = data1.teamId

        -- 找出季军
        local info = data2[1]
        if data1.teamId == data2[1].teamId then
            info = data2[2]
        end

        local secondImage = self:getControl("SecondImage", nil, championRoot)
        self:setLabelText("Label", info.name, secondImage)
        secondImage.teamId = info.teamId
    else
        self:setLabelText("Label", "", self:getControl("ChampionImage", nil, championRoot))
        self:setLabelText("Label", "", self:getControl("SecondImage", nil, championRoot))
    end

    -- 季军
    if data0 and data0.teamId ~= "" then
        local championImage = self:getControl("ChampionImage", nil, jijunRoot)
        self:setLabelText("Label", data0.name, championImage)
        championImage.teamId = data0.teamId

        -- 找出殿军
        for i = 1, #data4 do
            if data4[i].teamId ~= data2[1].teamId and data4[i].teamId ~= data2[2].teamId and data4[i].teamId ~= data0.teamId then
                local secondImage = self:getControl("SecondImage", nil, jijunRoot)
                self:setLabelText("Label", data4[i].name, secondImage)
                secondImage.teamId = data4[i].teamId
            end
        end
    else
        self:setLabelText("Label", "", self:getControl("ChampionImage", nil, jijunRoot))
        self:setLabelText("Label", "", self:getControl("SecondImage", nil, jijunRoot))
    end

    -- 刷新线条颜色
    self:refreshLineColor(4, root)
    self:refreshLineColor(2, root)
    self:refreshFinalLineColor(championRoot, true)
    self:refreshFinalLineColor(jijunRoot)
end

-- 刷新冠军，亚军，季军，殿军线条颜色
function QuanmPK2scDlg:refreshFinalLineColor(root, isFinal)
    local panel1 = self:getControl(isFinal and "2Panel1" or "3Panel1", nil, root)
    local panel1Line1 = self:getControl("TeamLineImage_1", Const.UIImage, panel1)
    local panel1Line2 = self:getControl("TeamLineImage_2", Const.UIImage, panel1)
    local panel1Line3 = self:getControl("TeamLineImage_3", Const.UIImage, panel1) 
    local panel1Line4 = self:getControl("TeamLineImage_4", Const.UIImage, panel1)
    local panel2 = self:getControl(isFinal and "2Panel2" or "3Panel2", nil, root)
    local panel2Line1 = self:getControl("TeamLineImage_1", Const.UIImage, panel2)
    local panel2Line2 = self:getControl("TeamLineImage_2", Const.UIImage, panel2)
    local panel2Line3 = self:getControl("TeamLineImage_3", Const.UIImage, panel2) 
    local panel2Line4 = self:getControl("TeamLineImage_4", Const.UIImage, panel2)
    gf:removeRedEffect(panel1Line1)
    gf:removeRedEffect(panel1Line2)
    gf:removeRedEffect(panel1Line3)
    gf:removeRedEffect(panel1Line4)
    gf:removeRedEffect(panel2Line1)
    gf:removeRedEffect(panel2Line2)
    gf:removeRedEffect(panel2Line3)
    gf:removeRedEffect(panel2Line4)
    local championTeamId = self:getControl("ChampionImage", nil, root).teamId
    local panel1TeamId = panel1.teamId
    local panel2TeamId = panel2.teamId
    if championTeamId and panel1TeamId and panel2TeamId then
        if championTeamId == panel1TeamId then
            gf:addRedEffect(panel1Line1)
            gf:addRedEffect(panel1Line2)
            gf:addRedEffect(panel2Line3)
            gf:addRedEffect(panel2Line4)
        else
            gf:addRedEffect(panel1Line3)
            gf:addRedEffect(panel1Line4)
            gf:addRedEffect(panel2Line1)
            gf:addRedEffect(panel2Line2)
        end
    end
end

-- 获取决赛数据
function QuanmPK2scDlg:getFinalData(type)
    local data = QuanminPK2Mgr:getScData()
    if not data then return end
    local startIndex = 0
    if type == 8 then
        startIndex = 128 + 64 + 32 + 16
    elseif type == 4 then
        startIndex = 128 + 64 + 32 + 16 + 8
    elseif type == 2 then
        startIndex = 128 + 64 + 32 + 16 + 8 + 4
    elseif type == 1 then
        startIndex = 128 + 64 + 32 + 16 + 8 + 4 + 2
        return data[startIndex + type]
    elseif type == 0 then
        -- 殿军与季军的战斗结果放在所有数据最后面
        startIndex = 128 + 64 + 32 + 16 + 8 + 4 + 2 + 1
        return data[startIndex + 1]
    end

    local ret  = {}
    for i = startIndex + 1, startIndex + type do
        table.insert(ret, data[i])
    end

    return ret
end

-- 置灰底板
function QuanmPK2scDlg:setPanelGray(panel)
    local img = self:getControl("BKImage", nil, panel)
    gf:grayImageView(img)
end

-- 重置底板
function QuanmPK2scDlg:resetPanelGray(panel)
    local img = self:getControl("BKImage", nil, panel)
    gf:resetImageView(img)
end

function QuanmPK2scDlg:onMatchButton(sender, eventType)
    self:chooseMenu(MENU_TYPE.TAOTAI)
end

function QuanmPK2scDlg:onFinalsButton(sender, eventType)
    self:chooseMenu(MENU_TYPE.FINAL)
end

function QuanmPK2scDlg:onLeftButton(sender, eventType)
    if self.page <= PAGE_NUM.MIN then return end
    self:setDataByPage(self.page - 1)
end

function QuanmPK2scDlg:onRightButton(sender, eventType)
    if self.page >= PAGE_NUM.MAX then return end
    self:setDataByPage(self.page + 1)
end

function QuanmPK2scDlg:cleanup()
    self.page = 1
end

-- 队伍数据
function QuanmPK2scDlg:MSG_CSQ_KICKOUT_TEAM_DATA(data)
    local dlg = DlgMgr:openDlg("QuanmPKTeamInfoDlg")
    dlg:setData(data)
end

return QuanmPK2scDlg
