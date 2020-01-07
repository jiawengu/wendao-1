-- UpdateDlg.lua
-- Created by zhengjh Sep/2015/15
-- 检测更新界面

local update_state =
{
    checkUpdate = 1, -- 检测更新
    loadPatch = 2, -- 加载补丁
}

-- 获取有效区域
local function getWinSize()
    local WINSIZE = cc.Director:getInstance():getWinSize()
    local size = DeviceMgr:getUIScale() or { width = WINSIZE.width, height = WINSIZE.height, x = 0, y = 0 }
    return size
end

local UpdateDlg = class("UpdateDlg", function()
    return ccui.Layout:create()
end)


function UpdateDlg:create()
    local dlg = UpdateDlg.new()
    return dlg
end

function UpdateDlg:ctor()
    local size = cc.Director:getInstance():getWinSize()
    local winSize = getWinSize()
    local runScene =  cc.Director:getInstance():getRunningScene()
    local jsonName =  "ui/UpdateDlg.json"
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsonName)
    self.root:setAnchorPoint(0.5, 0.5)
    self.root:setPosition(size.width / 2 + winSize.x, size.height / 2 + winSize.y)
    self:addChild(self.root)

    local tipPanel = self:getControl("TipsPanel")
    tipPanel:setContentSize(size.width, tipPanel:getContentSize().height)
    local loadTips = self:getLoadMapTips()
    local randomNum = math.random(1, #loadTips)
    local tipsLabel = self:getControl("TipsLabel")
    tipsLabel:setString(loadTips[randomNum]["tips"])

    -- 健康公告
    --[[local panel = self:getControl("HealthAdvicePanel")
    local bkImage = self:getControl("BKImage", nil, panel)
    bkImage:setContentSize(cc.size(winsize.width, bkImage:getContentSize().height))]]

    require("mgr/CheckNetMgr")
    local widget = ccui.Helper:seekWidgetByName(self.root, "CheckNetButton")
    widget:setVisible(CheckNetMgr:isEnabled() and 'function' == type(runScene.showCheckNetDlg))

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            runScene:showCheckNetDlg()
        end
    end

    widget:addTouchEventListener(listener)

    self.root:setContentSize(cc.size(winSize.width, winSize.height))
end

-- 获取进度条信息
function UpdateDlg:getLoadMapTips()
    local LoadingTips = require ("cfg/LoadingTips")
    local loadMapTips = {}
    local level = 1

    for i = 1, #LoadingTips do
        if level < LoadingTips[i]["level"] then
            break
        else
            if LoadingTips[i]["distType"] then
                if LoadingTips[i]["distType"] == 1 and LeitingSdkMgr:isLeiting() then
                    table.insert(loadMapTips, LoadingTips[i] )
                elseif LoadingTips[i]["distType"] == 2 and not LeitingSdkMgr:isLeiting() and not DistMgr:curIsTestDist() then
                    table.insert(loadMapTips, LoadingTips[i] )
                end
            else
                table.insert(loadMapTips, LoadingTips[i] )
            end
        end
    end

    return loadMapTips
end

function UpdateDlg:initDefaulInfo(fromVersion)
    local curLabel = self:getControl("CurrentLabel_1")
    curLabel:setString(CHSUP[3000145]..fromVersion)
    local curLabel2 = self:getControl("CurrentLabel_2")
    curLabel2:setString(CHSUP[3000145]..fromVersion)
end

function UpdateDlg:setVersionInfo(fromVersion, toVersion)
	local serverLabel = self:getControl("ServerLabel_1")
    serverLabel:setString(CHSUP[3000146]..toVersion)
    local serverLabe2 = self:getControl("ServerLabel_2")
    serverLabe2:setString(CHSUP[3000146]..toVersion)

    local curLabel = self:getControl("CurrentLabel_1")
    curLabel:setString(CHSUP[3000145]..fromVersion)
    local curLabel2 = self:getControl("CurrentLabel_2")
    curLabel2:setString(CHSUP[3000145]..fromVersion)
end

function UpdateDlg:setUpdateDlgState(state)
    if state == update_state.checkUpdate then
        self:getControl("CheckingPanel"):setVisible(true)
        self:getControl("LoadPatchPanel"):setVisible(false)
    else
        self:getControl("CheckingPanel"):setVisible(false)
        self:getControl("LoadPatchPanel"):setVisible(true)
    end
end

-- 获取控件
function UpdateDlg:getControl(name, type, root)
    root = root or self.root
    local widget = ccui.Helper:seekWidgetByName(root, name)
    return widget
end

-- 设置更新提示
function UpdateDlg:setTips(string)
    self:setUpdateDlgState(update_state.checkUpdate)

    local checkLabel1 = self:getControl("CheckingLabel_1")
    checkLabel1:setString(string)

    local checkLabel2 = self:getControl("CheckingLabel_2")
    checkLabel2:setString(string)

end

-- 字节转换为相应的字符
function UpdateDlg:sizeToSizeStr(size)
	local m = size / (1024 * 1024)

    local sizeStr = ""
    if m > 1 then
        sizeStr = string.format("%0.2fMB", m)
    else
        local k = math.ceil(size / 1024)
        sizeStr = string.format("%dKB", k)
    end

    return sizeStr
end

-- 设置错误提示信息
function UpdateDlg:setErrorTips(operate, msg)
    local curVersionCode = cc.UserDefault:getInstance():getStringForKey("current-version-code", "")
    local downVersionCode = cc.UserDefault:getInstance():getStringForKey("downloaded-version-code", "")
    local tipsLabel = self:getControl("TipsLabel")
    tipsLabel:setString('[' .. curVersionCode .. ' ' .. downVersionCode .. ' ' .. operate .. '] ' .. msg)
end

function UpdateDlg:setLoadObbTips(str, precent, tips)
    self:setUpdateDlgState(update_state.loadPatch)
    local precentStr = string.format(str, precent)
    local loadLabel1 = self:getControl("UpdatePercentLabel_1")
    loadLabel1:setString(precentStr)
    local loadLabel2 = self:getControl("UpdatePercentLabel_2")
    loadLabel2:setString(precentStr)

    if tips then
        local sizeLabel1 = self:getControl("UpdateSizeLabel_1")
        sizeLabel1:setString(tips)
        local sizeLabel2 = self:getControl("UpdateSizeLabel_2")
        sizeLabel2:setString(tips)
    end
end

function UpdateDlg:setLoadTips(curIndex, totalIndex, precent, loadSize, totalsize)
    self:setUpdateDlgState(update_state.loadPatch)
    local precentStr = string.format(CHSUP[3000147], curIndex, totalIndex, precent)
    local loadLabel1 = self:getControl("UpdatePercentLabel_1")
    loadLabel1:setString(precentStr)
    local loadLabel2 = self:getControl("UpdatePercentLabel_2")
    loadLabel2:setString(precentStr)

    if loadSize and totalsize then
        local sizeStr = string.format("(%s/%s)", self:sizeToSizeStr(loadSize), self:sizeToSizeStr(totalsize))
        local sizeLabel1 = self:getControl("UpdateSizeLabel_1")
        sizeLabel1:setString(sizeStr)
        local sizeLabel2 = self:getControl("UpdateSizeLabel_2")
        sizeLabel2:setString(sizeStr)
    end
end


return UpdateDlg
