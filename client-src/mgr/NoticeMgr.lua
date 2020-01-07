-- NoticeMgr.lua
-- created by zhengjh Nov/11/2015
-- 公告管理器

NoticeMgr = Singleton()

local agreement = require("UserAgreement")

-- 预创角公告信息
local PRE_CREATE_DESC = 'patch/CreateCharDesc.lua'
local UPDATE_DESC = 'patch/UpdateDesc.lua'
local OFFLINE_ACTIVE = 'patch/OffLineActive.lua'
local LOGIN_ANNOUNCEMENT = 'patch/LoginAnnouncement.lua'
local UPDATE_PATH = cc.FileUtils:getInstance():getWritablePath()


function NoticeMgr:reloadUpdateDesc()
    -- 设置更新公告信息
    NoticeMgr:setUpdateDesc()
    NoticeMgr:setOffLineActive()
end

function NoticeMgr:setUpdateDesc()
    local updateDesc = NoticeMgr:getUpdateDesc()
    if not updateDesc or #updateDesc == 0 then return end
    self.updateDesc = updateDesc
    self.updateDescVersion = updateDesc[1]["Version"]
    table.remove(self.updateDesc, 1)
    local curVersion = updateDesc[1]["Current_Version"] -- 移除当前版号，给运营看的
    table.remove(self.updateDesc, 1)
end

function NoticeMgr:setOffLineActive()
    local activeDesc = NoticeMgr:getOffLineActive()
    if not activeDesc or #activeDesc == 0 then return end
    self.activeDesc = activeDesc
    self.activeDescVersion = activeDesc[1]["Version"]
    table.remove(self.activeDesc, 1)
    local curVersion = activeDesc[1]["Current_Version"] -- 移除当前版号，给运营看的
    table.remove(self.activeDesc, 1)
end

function NoticeMgr:getUpdateDescVersion()
    return self.updateDescVersion
end

function NoticeMgr:getActiveDescVersion()
    return self.activeDescVersion
end

-- 获取更新公告信息
function NoticeMgr:getUpdateDesc()
    local desc = nil
    local filePath = UPDATE_PATH .. UPDATE_DESC
    if cc.FileUtils:getInstance():isFileExist(filePath) then
        local ok = pcall(function ()
            desc = dofile(filePath)
        end)
    end

    return desc
end

-- 获取活动信息
function NoticeMgr:getOffLineActive()
    local desc = nil
    local filePath = UPDATE_PATH .. OFFLINE_ACTIVE
    if cc.FileUtils:getInstance():isFileExist(filePath) then
        local ok = pcall(function ()
            desc = dofile(filePath)
        end)
    end

    return desc
end

function NoticeMgr:getNoticeList()
    return self:getcontentList(self.updateDesc)
end

function NoticeMgr:isNoticeContentEmpty()
    local lenth = 0
    local lsit = self:getNoticeList()
    for i = 1, #lsit  do
        if lsit[i]["K"] == "C" then
            lenth = lenth + string.len(lsit[i]["C"])
        end
    end

    if lenth == 0 then
        return true
    else
        return false
    end
end

function NoticeMgr:getActiveList()
    return self:getcontentList(self.activeDesc)
end

function NoticeMgr:isActiveContentEmpty()
    local lenth = 0
    local lsit = self:getActiveList()
    for i = 1, #lsit  do
        if lsit[i]["K"] == "C" then
            lenth = lenth + string.len(lsit[i]["C"])
        end
    end

    if lenth == 0 then
        return true
    else
        return false
    end
end

function NoticeMgr:setAgreementVersion()
    self.agreementVersion = agreement["version"]
end

function NoticeMgr:getAgreementVersion()
    return self.agreementVersion
end

function NoticeMgr:isNeedShowAgreement()
    local userDefault =  cc.UserDefault:getInstance()
    local version = userDefault:getStringForKey("agreementVersion", "")
    if not self.agreementVersion or self.agreementVersion ~= version  then
        return true
    end

    return false
end

function NoticeMgr:sendAgreemnetVersionToServer()
    local userDefault =  cc.UserDefault:getInstance()
    local time = userDefault:getStringForKey("agreementTime", "")
    if time ~= "" then
        gf:CmdToServer("CMD_USER_AGREEMENT", {time = tonumber(time), version = self.agreementVersion or ""})
        userDefault:setStringForKey("agreementTime", "")
    end
end

function NoticeMgr:getAgreement()
    return self:getPages(agreement)
end

function NoticeMgr:getPages(data)
    local pages = {}
    local pageNum = data["pageNum"] or 0
    for i = 1, pageNum do
        local page = self:getcontentList(data["page"..i])
        table.insert(pages, page)
    end

    return pages
end

function NoticeMgr:getcontentList(list)
    local noticeList = {}
    if list then
        for i = 1, #list do
            if type(list[i]["C"]) == "table" then
                local content = list[i]["C"]
                for j = 1, #content do
                    local line = {}
                    if j == 1 then
                         line["isNewC"] = true
                    end

                    if content[j] == "\n" then
                        line["K"] = list[i]["K"]
                        line["C"] = " \n"
                        table.insert(noticeList, line)
                    else
                        line["K"] = list[i]["K"]
                        line["C"] = content[j]
                        table.insert(noticeList, line)
                    end
                end
            else
                table.insert(noticeList, list[i])
            end
        end
    end

    return noticeList
end

-- 获取单个显示内容的位置和锚点
-- 当前控件要排的y轴位置posy
-- width 页面宽度
function NoticeMgr:getContentPosAndAnchor(posy, width, contentData, anchorPointY)
    anchorPointY = anchorPointY or 0
    local posInfo = {}
    if contentData["K"] == "T" then
        posInfo["anchorPoint"] = {x = 0.5, y = anchorPointY}
        posInfo["position"] = {x = width / 2, y = posy}
    elseif contentData["K"] == "C" then
        posInfo["anchorPoint"] = {x = 0, y = anchorPointY}
        posInfo["position"] = {x = 0, y = posy}
    elseif contentData["K"] == "R" then
        posInfo["anchorPoint"] = {x = 1, y = anchorPointY}
        posInfo["position"] = {x = width, y = posy}
    end

    return posInfo
end

-- 登录过程中需要弹出公告的检测
function NoticeMgr:isShowUpdate(showType)
    local show = false
    local userDefault =  cc.UserDefault:getInstance()
    local updateVersion = userDefault:getStringForKey("showUpdateDesc", "")
    local activeVersion = userDefault:getStringForKey("showActiveDesc", "")
    local tabDataList = {}

    if NoticeMgr:getUpdateDescVersion() and updateVersion ~= NoticeMgr:getUpdateDescVersion() and not NoticeMgr:isNoticeContentEmpty() then
        table.insert(tabDataList, {name = "update", desc = self:getNoticeList()})
        userDefault:setStringForKey("showUpdateDesc", NoticeMgr:getUpdateDescVersion() or "")
    end

    if NoticeMgr:getActiveDescVersion() and activeVersion ~= NoticeMgr:getActiveDescVersion() and not NoticeMgr:isActiveContentEmpty() then
        table.insert(tabDataList, {name = "active", desc = self:getActiveList()})
        userDefault:setStringForKey("showActiveDesc", NoticeMgr:getActiveDescVersion() or "")

        if #tabDataList > 1 then -- 活动和更新公告同时存在，插入小红点
            self:setIsNeddShowActivityRedDot(true)
        end
    end

    if #tabDataList > 0 then
        self:showUpdateDescDlg(tabDataList, showType)
        show = true
    end

    return show
end

function NoticeMgr:setIsNeddShowActivityRedDot(isNeed)
    self.isNeed = isNeed
end

function NoticeMgr:getIsNeddShowActivityRedDot()
    return self.isNeed
end

-- 游戏中点击公告按钮弹出公告
function NoticeMgr:showDescDlg()
    local tabDataList = {}
    if self.updateDesc and not NoticeMgr:isNoticeContentEmpty()  then
        table.insert(tabDataList, {name = "update", desc = self:getNoticeList()})
    end

    if self.activeDesc and not NoticeMgr:isActiveContentEmpty() then
        table.insert(tabDataList, {name = "active", desc = self:getActiveList()})
    end

    if #tabDataList > 0 then
        self:showUpdateDescDlg(tabDataList, true)
    end
end

function NoticeMgr:showUpdateDescDlg(list, noLogin)
    local dlg = DlgMgr:openDlg("UpdateDescDlg")
    dlg:setNoLogin(noLogin)
    dlg:setDescInfo(list)
end

-- 获取预创角公告
function NoticeMgr:getPreCreatDesc()
    local desc = nil
    local ok = pcall(function ()
        desc = dofile(cc.FileUtils:getInstance():getWritablePath() .. PRE_CREATE_DESC)
    end)

    return desc
end

-- 是否显示预创角公告
function NoticeMgr:isShowPreCreatDescDlg()
    local distName = Client:getWantLoginDistName()
    local creatDesc = NoticeMgr:getPreCreatDesc()

    if not creatDesc or not creatDesc[distName] then
        return false
    else
        return true
    end
end

-- 显示预创角公告
function NoticeMgr:showPreCreateDescDlg(showTabDlg)
    local dist = Client:getWantLoginDistName()
    local creatDesc = NoticeMgr:getPreCreatDesc()

    local dlg
    if showTabDlg then
        dlg = DlgMgr:getDlgByName("CreateCharDescExDlg")

        if not dlg then
            dlg = DlgMgr:openDlg("CreateCharDescExDlg")
        end
    else
        dlg = DlgMgr:openDlg("CreateCharDescDlg")
    end

    dlg:setNoLogin(false)
    if creatDesc[dist] == "default" then
        dlg:initContent(self:getcontentList(creatDesc["default"]))
    else
        dlg:initContent(self:getcontentList(creatDesc[dist]))
    end
end

-- 是否显示新服预充值
function NoticeMgr:isShowNewDistPreChargeDlg()
    local distName = Client:getWantLoginDistName()
    local data = Client:getNewDistPreChargeData()

    if data and data.dist_name == distName then
        local curTime = gf:getServerTime()
        if curTime >= data.start_time and curTime < data.end_time then
            return true
        end
    end

    return false
end

-- 显示新服预充值
function NoticeMgr:showNewDistPreChargeDlg(showTabDlg)
    local data = Client:getNewDistPreChargeData()

    local dlg
    if showTabDlg then
        dlg = DlgMgr:getDlgByName("ReserveRechargeExDlg")

        if not dlg then
            dlg = DlgMgr:openDlg("ReserveRechargeExDlg")
        end
    else
        dlg = DlgMgr:openDlg("ReserveRechargeDlg")
    end

    dlg:setData(data)
end

-- 是否显示新服预充值和预创角色公告
function NoticeMgr:isShowPreChargeAndPreCreateChar()
    if self:isShowNewDistPreChargeDlg() and self:isShowPreCreatDescDlg() then
        return true
    end

    return false
end

-- 登录过程检测弹出渠道公告
function NoticeMgr:showLoginAnnouncement(noLogin)
    local show = false
    local desc = NoticeMgr:getLoginAnnouncement()
    if not desc then return false end

    -- 指定渠道
    local channelNo = DeviceMgr:getChannelNO()
    if not desc.channelNo or channelNo == "" or not string.match(desc.channelNo, channelNo) then
        return false
    end

    -- 有效期
    local curTimeStr = gf:getServerDate("%Y%m%d%H%M%S", gf:getServerTime())
    if desc.validTime < curTimeStr then
        return false
    end

    -- 当天首次
    local lastShowTime =  cc.UserDefault:getInstance():getStringForKey("loginAnnouncementLastTime", "")
    if lastShowTime ~= "" and gf:isSameDay(lastShowTime, gf:getServerTime()) then
        return false
    end

    -- 内容为空
    if not desc.content or #desc.content == 0 then
        return false
    end

    -- 打开界面
    local dlg = DlgMgr:openDlg("LoginAnnouncementDlg")
    dlg:setDescInfo(desc.content)
    dlg:setNoLogin(noLogin)
    cc.UserDefault:getInstance():setStringForKey("loginAnnouncementLastTime", gf:getServerTime())

    return true
end

-- 获取登录公告(文件编译错误，返回nil)
function NoticeMgr:getLoginAnnouncement()
    local desc = nil
    local ok = pcall(function ()
        desc = dofile(cc.FileUtils:getInstance():getWritablePath() .. LOGIN_ANNOUNCEMENT)
    end)

    return desc
end

return NoticeMgr
