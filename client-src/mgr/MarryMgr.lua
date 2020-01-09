-- MarryMgr.lua
-- Created by zhengjh Jun/12/2016
-- 结婚管理器

MarryMgr = Singleton()
MarryMgr.agree = 1
MarryMgr.refuse = 0
local WeddingMenu = require('cfg/WeddingMenu')

function MarryMgr:MSG_OPEN_TIQIN_DLG(data)
    local dlg = DlgMgr:openDlg("ProposeDlg")
    dlg:setInfo(data)
end

function MarryMgr:sendProposeReslutToServer(result)
    gf:CmdToServer("CMD_RESPONSE_TIQIN", {result = result})
end

-- type 表示头像图片或ui图片
function MarryMgr:getImagePath(name)
    local data = WeddingMenu[name]
    if not data then return end
    -- 设置头型
    local path, type
    if data.filePath == "portraits" then
        path = ResMgr:getSmallPortrait(data.icon)
        type = 1
    else
        path = data.icon
        type = 0
    end

    return path, type
end

function MarryMgr:getOneWeddingMenuInfo(name)
    return WeddingMenu[name] or ""
end

function MarryMgr:buyWeddingList(list)
    gf:CmdToServer("CMD_BUY_WEDDING_LIST", {weddinglist = list})
end

function MarryMgr:setRedPacket(data)
    gf:CmdToServer("CMD_SET_RED_PACKET",data)
end

-- 是否已婚
function MarryMgr:isMarried()
    if Me:queryBasic("marriage/marry_id") ~= "" then
        return true
    else
        return false
    end
end

-- 婚礼状态
function MarryMgr:MSG_WEDDING_NOW(data)
    self.weedingStatus = data.result
    self.isPlayWeddingMusic = data.isPlayWeddingMusic
    if self:isWeddingStatus() then
        DlgMgr:closeDlgWhenNoramlDlgOpen(nil, true) -- 隐藏界面
        DlgMgr:closeNormalAndFloatDlg()

        if self:isNeedPlayWeddingMusic() then
            SoundMgr:playMusic("marryMusic", true)
        end

        DlgMgr:openDlg("MarryFlowerDlg")
    else
        DlgMgr:preventDlg() -- 显示界面
        SoundMgr:playMusic(MapMgr:getCurrentMapName(), false)
        DlgMgr:closeDlg("MarryFlowerDlg")
    end
end

function MarryMgr:isNeedPlayWeddingMusic()
    if self.isPlayWeddingMusic == 1 then
        return true
    end

    return false
end

-- 是否在婚礼状态
function MarryMgr:isWeddingStatus()
    if self.weedingStatus  == 1 then
        return true
    end

    return false
end

function MarryMgr:MSG_WEDDING_LIST(data)
    self.weddingList = data
    local dlg = DlgMgr:openDlg("WeddinglistDlg")
    dlg:initList(data)
end

-- 横幅
function MarryMgr:MSG_BANNER(data)
    PlayActionsMgr:playBanner(data)
end

-- 刷新元宝价格列表
function MarryMgr:MSG_WEDDING_ALL_LIST(data)
    self.serverWeddingList = {}
    for i = 1, data.count do
        local item = data.items[i]
        if WeddingMenu[item.name] then
            WeddingMenu[item.name]["price"] = item.price
            self.serverWeddingList[item.name] = item.price
        end
    end

    self.cost_type = data.cost_type
    -- 除10000后才是打折的数值
    self.discount = data.discount / 10000
end

function MarryMgr:isInSerVerList(name)
    if self.serverWeddingList then
	   return self.serverWeddingList[name]
	end

	return true
end


function MarryMgr:questLoverInfo()
    gf:CmdToServer("CMD_REQUEST_COUPLE_INFO", {})
end

function MarryMgr:MSG_COUPLE_INFO(data)
    if data.flag == 0 then
        -- 清空数据
        self.loverInfo = nil
        return
    end

    self.loverInfo = data
end

function MarryMgr:getLoverInfo()
    if self.loverInfo and self.loverInfo.gid ~= "" then

        if not self.loverInfo.relation then
            local gender = tonumber(gf:getGenderByIcon(self.loverInfo.icon))
            local relation
            if gender == GENDER_TYPE.MALE then
                relation = CHS[6000292]
            elseif gender == GENDER_TYPE.FEMALE then
                relation = CHS[6000293]
            end
            self.loverInfo.relation = relation
        end
        return self.loverInfo
    end

    return
end

function MarryMgr:isInMarryAction(char)
    local status = char:queryBasicInt("status")
    if Const.NS_BAIBAI == status or
        Const.NS_BAOBAO == status or
        Const.NS_QINQIN == status or
        Const.NS_JIAOBEI == status then
        return true
    end

    return false
end

function MarryMgr:checkWeddingActionZone(char)
    -- 特殊判断，如果有播放结婚光效的玩家，那么就需要进行区域清空
    -- 不是Me，判断周围的玩家是否处于风月谷对应的区域范围内
    local mapId = MapMgr:getMapByName("风月谷")
    if mapId ~= MapMgr:getCurrentMapId() then
        -- 不是风月谷的地图
        return false
    end

    local charPos = cc.p(gf:convertToMapSpace(char.curX, char.curY))
    local weddingZone = MapMgr:getWeddingActionZone()
    if not cc.rectContainsPoint(weddingZone, charPos) then
        -- 不在对应的区域
        return false
    end

    if self:isInMarryAction(char) then
        return false
    end

    -- 查找固定点上的玩家
    local chars = CharMgr:getCharsByPos(MapMgr:getWeddingActionPos())
    for _, charTmp in pairs(chars) do
        local status = charTmp:queryBasicInt("status")
        if self:isInMarryAction(charTmp) then
            -- 并且自己不是做动作的这两个人
            if charTmp:getId() ~= char:getId() then
                return true
            else
                return false
            end
        end
    end
end

function MarryMgr:cleanData()
    self.weedingStatus = nil

    DlgMgr:sendMsg("MarriageTreeDlg", "resetWaitStatus")
    DlgMgr:sendMsg("PeachTreeDlg", "resetWaitStatus")
end

-- 请求姻缘签分页数据
function MarryMgr:sendCurPageToServer(page)
    DlgMgr:openDlg("WaitDlg")
    gf:CmdToServer("CMD_REQUEST_YYQ_PAGE", {page = page})
end

-- 搜索姻缘签结果
function MarryMgr:MSG_SEARCH_YYQ_RESULT(data)
    if not self.marriageSign then
        self.marriageSign = {}
    end

    self.marriageSign["searchSign"] = {}

    table.insert(self.marriageSign["searchSign"], data)
end

-- 姻缘签分页数据
function MarryMgr:MSG_YYQ_PAGE(data)
    if not self.marriageSign then
        self.marriageSign = {}
    end

    if data.allPage > 9999 then
        data.allPage = 9999
    end

    self.marriageSign["allSign"] = data
end

-- 我的姻缘签数据
function MarryMgr:MSG_REQUEST_MY_YYQ_RESULT(data)
    if not self.marriageSign then
        self.marriageSign = {}
    end

    self.marriageSign["mySign"] = data
end

-- 刷新单个姻缘签
function MarryMgr:MSG_REFRESH_YYQ_INFO(data)
    if not self.marriageSign then
        self.marriageSign = {}
    end

    if self.marriageSign["searchSign"] then
        for i, v in ipairs(self.marriageSign["searchSign"]) do
            if v.yyq_no == data.yyq_no then
                self.marriageSign["searchSign"][i] = data
                break
            end
        end
    end

    if self.marriageSign["allSign"] then
        for i, v in ipairs(self.marriageSign["allSign"]) do
            if v.yyq_no == data.yyq_no then
                self.marriageSign["allSign"][i] = data
                break
            end
        end
    end

    if self.marriageSign["mySign"] then
        for i, v in ipairs(self.marriageSign["mySign"]) do
            if v.yyq_no == data.yyq_no then
                self.marriageSign["mySign"][i] = data
                break
            end
        end
    end
end

-- 搜索祝福签结果
function MarryMgr:MSG_SEARCH_ZFQ_RESULT(data)
    self:MSG_SEARCH_YYQ_RESULT(data)
end

-- 祝福签分页数据
function MarryMgr:MSG_ZFQ_PAGE(data)
    self:MSG_YYQ_PAGE(data)
end

-- 我的祝福签数据
function MarryMgr:MSG_REQUEST_MY_ZFQ_RESULT(data)
    self:MSG_REQUEST_MY_YYQ_RESULT(data)
end

-- 刷新单个祝福签
function MarryMgr:MSG_REFRESH_ZFQ_INFO(data)
    self:MSG_REFRESH_YYQ_INFO(data)
end

function MarryMgr:getLastPage()
    local time = gf:getServerTime()

    if not self.lastCloseTreeDlgTime or time - self.lastCloseTreeDlgTime > 150 then
        return 1
    end

    return self.lastTreeDlgPage
end

function MarryMgr:MSG_WEDDING_CHECK_MUSIC(data)
    local musicOn = SystemSettingMgr:getMusicEnable()
    local volumeValue = SystemSettingMgr:getVolumeValue()

    local startWedding = function()
        if 1 == data.isReturn then
            gf:CmdToServer("CMD_START_WEDDING", {})
        end
    end

    -- 判断玩家当前是否开启设置界面音乐按钮，若否，则予以如下确认取消选项：
    if not musicOn then
        gf:confirm("豪华婚礼期间会播放特殊的婚礼音乐，是否开启音乐并将音量调整至合适的大小？", function()
            -- 点击确定，则开启玩家设置界面音乐按钮，并将音量调整为30，并继续执行后续流程，并予以如下弹出提示：
            SystemSettingMgr:setMusicEnable(true)
            SystemSettingMgr:setVolumeValue(30)
            gf:ShowSmallTips("设置成功，音乐已开启，音量已调整至合适的大小。")
            startWedding()
        end, function()
            -- 点击取消，则继续执行后续流程。
            startWedding()
        end)

        return
    end

    -- 若玩家当前已开启游戏音乐，则判断玩家当前音量是否小于5，若是则予以如下确认取消选项：
    if volumeValue < 5 then
        gf:confirm("豪华婚礼期间会播放特殊的婚礼音乐，当前游戏音量过小，是否调整至合适的大小？", function()
            -- 点击确定，则将游戏音量调整为30，并继续执行后续流程，并予以如下弹出提示：
            SystemSettingMgr:setMusicEnable(true)
            SystemSettingMgr:setVolumeValue(30)
            gf:ShowSmallTips("设置成功，游戏音量已调整至合适的大小。")
            startWedding()
        end, function()
            -- 点击取消，则继续执行后续流程。
            startWedding()
        end)

        return
    end

    startWedding()
end

function MarryMgr:MSG_OPEN_WEDDING_CHANNEL(data)
    DlgMgr:openDlgEx("WeddingBarrageDlg", data)
end

function MarryMgr:MSG_CLOSE_WEDDING_CHANNEL(data)
    DlgMgr:closeDlg("WeddingBarrageDlg")
end

MessageMgr:regist("MSG_OPEN_WEDDING_CHANNEL", MarryMgr)
MessageMgr:regist("MSG_CLOSE_WEDDING_CHANNEL", MarryMgr)
MessageMgr:regist("MSG_COUPLE_INFO", MarryMgr)
MessageMgr:regist("MSG_OPEN_TIQIN_DLG", MarryMgr)
MessageMgr:regist("MSG_WEDDING_NOW", MarryMgr)
MessageMgr:regist("MSG_WEDDING_LIST", MarryMgr)
MessageMgr:regist("MSG_BANNER", MarryMgr)
MessageMgr:regist("MSG_WEDDING_ALL_LIST", MarryMgr)
MessageMgr:regist("MSG_SEARCH_YYQ_RESULT", MarryMgr)
MessageMgr:regist("MSG_YYQ_PAGE", MarryMgr)
MessageMgr:regist("MSG_REQUEST_MY_YYQ_RESULT", MarryMgr)
MessageMgr:regist("MSG_REFRESH_YYQ_INFO", MarryMgr)
MessageMgr:regist("MSG_SEARCH_ZFQ_RESULT", MarryMgr)
MessageMgr:regist("MSG_ZFQ_PAGE", MarryMgr)
MessageMgr:regist("MSG_REQUEST_MY_ZFQ_RESULT", MarryMgr)
MessageMgr:regist("MSG_REFRESH_ZFQ_INFO", MarryMgr)
MessageMgr:regist("MSG_WEDDING_CHECK_MUSIC", MarryMgr)

return MarryMgr
