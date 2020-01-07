-- DlgMgr.lua
-- Created by chenyq Nov/7/2014
-- 负责管理对话框

DlgMgr = Singleton()

local DLG_RELATION = require(ResMgr:getCfgPath('DlgRelation.lua'))
local DLG_MUTEX = require(ResMgr:getCfgPath('DlgMutex.lua'))
local DLG_LEVEL = require(ResMgr:getCfgPath('DlgLevelRequire.lua'))

local DLG_INSTRUCTIONS = require(ResMgr:getCfgPath('InstructionsDlgCfg.lua'))

DlgMgr.dlgs = {}
DlgMgr.hashDlgs = {}
DlgMgr.tabDlgCloseTime = {}
DlgMgr.lastTimes = {}

local tabDlgInitTime = (60 * 2 + 30) * 1000
local Msg = require "comm/global_send"

local deviceCfg = DeviceMgr:getUIScale()


  -- 键盘不关闭
local NUM_DLG = {["SmallNumInputDlg"] = 1, ["NumInputExDlg"] = 1, ["NumInputDlg"] = 1, ["LittleNumInputDlg"] = 1}

-- 对话框类型，总共五种类型
local DLG_TYPE_CFG = {
    {true,  false},     -- 菜单项
    {true,  true},      -- 悬浮框
    {false, true},      -- 普通窗口
    {false, false},     -- 确认框
    {false, true},      -- 移除背景蒙灰效果（不含BlankLayer）的普通对话框
    {false, false},     -- 进入战斗需要重新reopen的模态框
    {false, false},     -- 移除背景蒙灰效果（不含BlankLayer）的确认框
    {false, true},     -- 一般性对话框但是点击外部无影响
}

-- 对话框的类型
DlgMgr.DLG_TYPE = {
    MENU        = 1,
    FLOATING    = 2,
    NORMAL      = 3,
    MODEL       = 4,
    NORMAL_WITHOUT_BLANKLAYER = 5,
    MODEL_NEED_REOPEN_INFIGHT = 6,
    MODEL_WITHOUT_BLANKLAYER = 7,
    NORMAL_NO_EFFECT_FOR_CLICK_BLANK = 8,
}

local MAIN_DLG_LIST = {
    ["GameFunctionDlg"]     = 1,
    ["HeadDlg"]             = 1,
    ["ChatDlg"]             = 1,
    ["SystemFunctionDlg"]   = 1,
    ["MissionDlg"]          = 1,
    ["FastUseItemDlg"]      = 1,
    ["ScreenRecordingDlg"]  = 1,
    ["HeadTipsDlg"]  = 1,
}

local NEED_LOADDATA_BEFORE  =
{
     -- ["ActivitiesDlg"] = "MSG_LIVENESS_INFO",
     ["PartyManageDlg"] = "MSG_PARTY_INFO",
}

-- 进入战斗时必须关闭的界面
local FIGHT_NEED_CLOSE_DLGS= require(ResMgr:getCfgPath('FightNeedCloseDlg.lua'))

-- 进入战斗时不需要reopen
local FIGHT_NOT_REOPEN_DLGS= require(ResMgr:getCfgPath('FightNotReopenDlg.lua'))

local NORMAL_DLG_STATE = {["HIDE"] = 0, ["SHOW"] = 1}
DlgMgr.normalDlgState = NORMAL_DLG_STATE.SHOW


-- 获取主界面上的对话框
function DlgMgr:getNumDlgsCgf()
    return NUM_DLG
end

-- 获取主界面上的对话框
function DlgMgr:getDlgInMain()
	local dlgs = {}

	for k, _ in pairs(MAIN_DLG_LIST) do
	   table.insert(dlgs, k)
	end
end

function DlgMgr:resetLastDlgByTabDlg(tabDlgName)
    DlgMgr.tabDlgCloseTime[tabDlgName] = nil
end

-- 获取指定 TabDlg 最后显示的对话框
function DlgMgr:getLastDlgByTabDlg(tabDlgName)
    local dlg = require('dlg/' .. tabDlgName)

    if not dlg then return end

    -- 对比上一次关闭时间，小于2分30则打开默认对话框
    local colseTime =  DlgMgr.tabDlgCloseTime[tabDlgName]
    if not colseTime or gfGetTickCount() -colseTime > tabDlgInitTime     -- 对比上一次关闭时间
        or not GameMgr.initDataTime then  -- 对比角色数据发送的时间和窗口关闭的时间
        dlg.lastDlg = nil  -- tab对话框上一次打开的对话框
        dlg.lastSelectItemId = nil  -- tab对话框上一次打开的对话框，选中的itemID
    end

    if dlg.lastDlg then
        local subTabDefaultDlg = dlg:getSubTabDefaultDlg(dlg.lastDlg)
        if subTabDefaultDlg then
            return DlgMgr:getLastDlgByTabDlg(dlg.lastDlg) or subTabDefaultDlg
        end

        return dlg.lastDlg, dlg.lastSelectItemId
    end
end

function DlgMgr:getDefDlgByTabDlg(tabDlgName)
    local dlg = require('dlg/' .. tabDlgName)

    if not dlg then return end

    return  dlg:getFirtTabList() or dlg.defDlg
end

-- 打开tab类型对话框。如果上一次nil则打开默认对话框
function DlgMgr:openTabDlg(tabDlgName)
    -- 如果是tabdlg类型对话框
    local len = string.len(tabDlgName)
    if string.sub(tabDlgName, len - 6 + 1, -1) == "TabDlg" then
        -- 如果是帮派，特殊处理，自己弱没有帮派，打开加入帮派界面
        if tabDlgName == "PartyInfoTabDlg" then
            if Me:queryBasic("party/name") == "" then
                return DlgMgr:openDlg("JoinPartyDlg")
            end

            -- 更新帮派信息
            PartyMgr:queryPartyInfo()
            PartyMgr:queryPartyLog()
        end

        local lastDlg, itemId = DlgMgr:getLastDlgByTabDlg(tabDlgName)
        local dlg
        if lastDlg == nil then
            local defDlg = self:getDefDlgByTabDlg(tabDlgName)
            if defDlg then
                dlg = self:openDlg(defDlg)
            end
        else
            dlg = self:openDlg(lastDlg)

            -- 如果是装备tab或者宠物tab，需要选中上一次的item
            if tabDlgName == "EquipmentTabDlg" then
                DlgMgr:sendMsg("EquipmentChildDlg", "selectPanelByEquipId", itemId)
            elseif tabDlgName == "PetTabDlg" then
                DlgMgr:sendMsg("PetListChildDlg", "selectPetId", itemId)
            end
        end

        return dlg
    end

    -- 不是tab类型直接打开对话框
    return self:openDlg(tabDlgName)
end

function DlgMgr:closeTabDlg(tabDlgName)
    local len = string.len(tabDlgName)
    if string.sub(tabDlgName, len - 6 + 1, -1) == "TabDlg" then
        local dlg = self:getDlgByName(tabDlgName)
        if dlg then
            dlg:onCloseButton()
        end
    end
end

-- 通过检查当前开启的界面，判断有没有一般性界面，有一般性界面重新设置相关主界面的可见属性
function DlgMgr:resetMainDlgVisible()
    local dlgs = DlgMgr.dlgs
    for dlgName, dlg in pairs(dlgs) do
        if DlgMgr:isMeetDlgMutex({DlgMgr.DLG_TYPE.NORMAL, DlgMgr.DLG_TYPE.NORMAL_WITHOUT_BLANKLAYER, DlgMgr.DLG_TYPE.NORMAL_NO_EFFECT_FOR_CLICK_BLANK}, dlgName) then
            DlgMgr:closeDlgWhenNoramlDlgOpen(dlgName)
        end

        if DlgMgr:getDlgByName("ShengxdjDlg") then
            -- ShengxdjDlg 模态界面，所以传入一个一般性界面模拟情况就好了
            DlgMgr:closeDlgWhenNoramlDlgOpen("BagDlg")
        end
    end
end


-- 检查在战斗出来后有一般性界面打开需要隐藏主界面
function DlgMgr:normalDlgOpenNeedColseMainDlg()
    local all = self.dlgs
    for dlgName, v in pairs(all) do
        if self:showMainDlg(dlgName) then
            self:closeDlgWhenNoramlDlgOpen(dlgName)
            return
        end
    end
end

-- 一般性界面打开隐藏主界面内容
function DlgMgr:closeDlgWhenNoramlDlgOpen(dlgName, isWeedStatus)
    local isClose = false

    if isWeedStatus or (self:showMainDlg(dlgName) and self:isNeedShowAndHideMainDlg()) then
        for k, v in pairs(MAIN_DLG_LIST) do
            local dlg = self.dlgs[k]
            if dlg and (k ~= "ChatDlg" and k ~= "ScreenRecordingDlg" and k ~= (deviceCfg and deviceCfg.fullback or "")) then
                dlg:setVisible(false)
                isClose = true
            end
        end
    end

    -- 由于只是2018寒假活动，并且只有一两个界面有用，也许2018寒假结束没有用到，特殊处理，不增加新对话框类型
    if dlgName == "VacationSnowDlg" then
        for k, v in pairs(MAIN_DLG_LIST) do
            local dlg = self.dlgs[k]
            if dlg and (k ~= "ChatDlg" and k ~= "ScreenRecordingDlg" and k ~= (deviceCfg and deviceCfg.fullback or "")) then
                dlg:setVisible(false)
                isClose = true
            end
        end
    end

    if isClose then
        self.normalDlgState = NORMAL_DLG_STATE.HIDE
    end
end

-- 一般性界面关闭需要显示主界面内容
function DlgMgr:showDlgWhenNoramlDlgClose(dlgName)

    if dlgName == "LoadingDlgForAction" then return end--仅仅过图动画，不用管后面的

    local isShow = false
    local flag = false

    if not dlgName then
        flag = true
    else
        flag = self:showMainDlg(dlgName)
    end

    -- 显示主界面的dlg
    if flag and self:isNeedShowAndHideMainDlg() then
        local isShowMainDLg = true

        for k, v in pairs(self.dlgs) do
            if (DLG_MUTEX[k]  == self.DLG_TYPE.NORMAL or DLG_MUTEX[k]  == self.DLG_TYPE.NORMAL_NO_EFFECT_FOR_CLICK_BLANK or not DLG_MUTEX[k]) and k ~= dlgName and v:isVisible() then
                isShowMainDLg = false
                break
            end
        end

        -- 举行婚礼状态不显示主界面
        if MarryMgr:isWeddingStatus() or ActivityMgr:isChantingStauts() or DlgMgr:getDlgByName("ShengxdjDlg") then
            isShowMainDLg = false
        end

        if isShowMainDLg and not self.dlgs["DramaDlg"] and not self.dlgs["VacationSnowDlg"] then
            for k, v in pairs(MAIN_DLG_LIST) do
                local dlg = self.dlgs[k]
                -- 因为ChatDlg为常在的窗口，所以需要排除
                if dlg and k ~= "ChatDlg" then
                    dlg:setVisible(true)
                    isShow = true
                end
            end
        end


    end

    if isShow then
        self.normalDlgState = NORMAL_DLG_STATE.SHOW
    end
end

-- 走路的时候需要检测下界面是否处于隐藏状态，如果处于隐藏则需要显示
function DlgMgr:preventDlg()
    if HomeChildMgr:isInDailyTask() then return end

    if self.normalDlgState == NORMAL_DLG_STATE.HIDE then
        self:showDlgWhenNoramlDlgClose()
    end
end

-- 该接口打开对话框，不做任何处理，不初始化，json中显示怎样就怎样，如果界面已经打开，则不处理
function DlgMgr:openDlgForGM(dlgName, autoClose)
    local dlg = self.dlgs[dlgName]
    if dlg then
        return
    end

    dlg = require('dlg/' .. dlgName)
    if not dlg then
        Log:W("Not found dlg:" .. dlgName)
        return
    end

    dlg:setDialogType(DLG_TYPE_CFG[DlgMgr.DLG_TYPE.MENU])

    self.dlgs[dlgName] = dlg
    local s, e = xpcall(function() dlg:openForGm(autoClose) end, function(e)
        if "ConfirmDlg" ~= dlgName then
            __G__TRACKBACK__(e, 4)
        else
            local logMsg = tostring(msg) .. "\n" .. gfTraceback()
            if GameMgr.networkState == NET_TYPE.WIFI then
                gf:ftpUploadEx(logMsg)
            end
        end
    end)

    if autoClose then
        performWithDelay(dlg.root, function ()
        	dlg:onCloseButtonForGm()
        end, 2)
    end

    return dlg
end

-- 打开对话框，如果已打开，则直接返回对应的对话框，否则打开相应的对话框
-- isRelative 表示是否为关联对话框，true表示是，nil或者false表示不是，默认nil
-- noCloseFloat 表示是否要关闭悬浮框，true表示需要关闭，nil或者false表示不关闭，默认nil
-- isOnlyThisDlg 为true时，只打开自己，不打开关联
function DlgMgr:openDlg(dlgName, isRelative, noCloseFloat, isOnlyThisDlg)
    return self:openDlgEx(dlgName, nil, isRelative, noCloseFloat, isOnlyThisDlg)
end

-- 带参数打开界面
function DlgMgr:openDlgEx(dlgName, param, isRelative, noCloseFloat, isOnlyThisDlg)
    if DLG_LEVEL[dlgName] and Me:queryBasicInt("level") < DLG_LEVEL[dlgName] then
        gf:ShowSmallTips(string.format(CHS[3003960], DLG_LEVEL[dlgName]))
        return
    end

    local openDlgType = DLG_MUTEX[dlgName]
    if (openDlgType == DlgMgr.DLG_TYPE.MODEL or openDlgType == DlgMgr.DLG_TYPE.MODEL_NEED_REOPEN_INFIGHT or openDlgType == DlgMgr.DLG_TYPE.MODEL_WITHOUT_BLANKLAYER)
        and dlgName ~= "LoadingDlg" and dlgName ~= "LineUpDlg" then
        -- 使用到webView的界面，需要在确认框类型界面打开时隐藏，关闭时显示
        local communityDlg = DlgMgr:getDlgByName("CommunityDlg")
        if communityDlg then communityDlg:setVisible(false) end

        local webDlg = DlgMgr:getDlgByName("WebDlg")
        if webDlg then webDlg:setVisible(false) end
        end

    self:closeDlgWhenNoramlDlgOpen(dlgName)
    local dlg = self.dlgs[dlgName]
    if dlg then
        if not dlg:isVisible() then
            if MAIN_DLG_LIST[dlgName] and self.normalDlgState == NORMAL_DLG_STATE.HIDE and (not GameMgr.inCombat and not Me:isLookOn()) then
            -- 如果是主界面并且normalDlgState = HIDE则不做处理
            else
                dlg:setVisible(true) -- 确保界面是可见的
            end
        end

        if dlg.blank then
            dlg.blank:stopAllActions()
        end

        -- 记录最后打开的对话框
        DlgMgr.lastOpenDlg = dlg
        return dlg
    end


    if DLG_INSTRUCTIONS[dlgName] then
        for dName, insDlg in pairs(DlgMgr.dlgs) do
            if insDlg.jsonFileName then
                DlgMgr:closeDlg(dName)
            end
        end

        -- 如果有json，但是没有lua
        dlg = require('dlg/' .. "InstructionsDlg")
        dlg.jsonFileName = dlgName
    else
        dlg = require('dlg/' .. dlgName)
        if not dlg then
            DebugMgr:uploadFile('dlg/' .. dlgName)
            Log:W("Not found dlg:" .. dlgName)
            return
        end
    end

    -- WDSY-18618
    if 'boolean' == type(dlg) then
        DebugMgr:uploadFile('dlg/' .. dlgName)
    end

    Log:D(">>>>>>>>>>>>>>> openDlg : " .. dlgName)

    if not isRelative then
        local dlgType = DLG_MUTEX[dlgName]
        if nil == dlgType then
            dlg:setDialogType(DLG_TYPE_CFG[DlgMgr.DLG_TYPE.NORMAL])
        else
            dlg:setDialogType(DLG_TYPE_CFG[dlgType])
            if dlgType == DlgMgr.DLG_TYPE.NORMAL_WITHOUT_BLANKLAYER
                or dlgType == DlgMgr.DLG_TYPE.MODEL_WITHOUT_BLANKLAYER then  -- 若对话框类型值为5、7，则移除其背景蒙灰效果
                dlg:hideBlankLayer()
            end
        end
    else
        dlg:setDialogType(DLG_TYPE_CFG[DlgMgr.DLG_TYPE.MENU])
    end

    -- 清空输入法状态(有些界面，上推与输入法是否打开有关),清空界面上推标记
    dlg.checkImeStatus = {}
    dlg.rootRawY = nil

    -- 先把 dlgName 放到 mapping 中，再进行打开

    self.dlgs[dlgName] = dlg


    assert(not self.hashDlgs[dlg], string.format("dumplicate dlg(%s)-->(%s)", tostring(self.hashDlgs[dlg]), tostring(dlgName)))
    self.hashDlgs[dlg] = dlgName
    local s, e = xpcall(function() dlg:open(param) end, function(e)
        if "ConfirmDlg" ~= dlgName then
            __G__TRACKBACK__(e, 4)
        else
                local logMsg = tostring(msg) .. "\n" .. gfTraceback()
                if GameMgr.networkState == NET_TYPE.WIFI then
                    gf:ftpUploadEx(logMsg)
                end
            end
    end)
    if not s or not self.dlgs[dlgName] then
        self.dlgs[dlgName] = nil
        self.hashDlgs[dlg] = nil
        return
    end

    -- 设置打开的层级
   -- self:addShowUINumber(dlgName)
   -- self:setOpenDlgZorder(dlgName)

    -- 记录最后打开的对话框
    DlgMgr.lastOpenDlg = dlg

    if not isOnlyThisDlg then
        self:openRelativeDlg(dlgName)
    end

    -- 关闭悬浮对话框
    if not noCloseFloat then
        self:closeFloatingDlg(dlgName)
    end

    return dlg
end

-- 关闭悬浮框
-- 排出传值的窗口
function DlgMgr:closeFloatingDlg(dlgName)
    if  not dlgName
        or (dlgName ~= 'ItemInfoDlg'
        and dlgName ~= "ItemRecourseDlg"
        and dlgName ~= "EquipmentFloatingFrameDlg"
        and dlgName ~= "EquipmentInfoCampareDlg"
        and dlgName ~= "JewelryInfoCampareDlg"
        and dlgName ~= "JewelryInfoDlg"
        and dlgName ~= "ChangeCardInfoDlg"
        and dlgName ~= "ArtifactInfoDlg"
        and dlgName ~= "ArtifactInfoCampareDlg"
        and dlgName ~= "FurnitureInfoDlg") then
        self:closeDlg('ItemInfoDlg')
        self:closeDlg("EquipmentFloatingFrameDlg")
        self:closeDlg("EquipmentInfoCampareDlg")
        self:closeDlg("JewelryInfoCampareDlg")
        self:closeDlg("JewelryInfoDlg")
        self:closeDlg("ArtifactInfoDlg")
        self:closeDlg("ArtifactInfoCampareDlg")
        self:closeDlg("ChangeCardInfoDlg")
        self:closeDlg("ItemRecourseDlg")
        self:closeDlg("FurnitureInfoDlg")
    end
end

function DlgMgr:isShowFunDlg(dlgName)
    if string.match(dlgName, "Funny(%d+)Dlg") and not Const.OPEN_FUN_DLG then
        return false
    end

    return true
end


function DlgMgr:reopenDlg(dlgName)
    if self.dlgs[dlgName] then
        self.dlgs[dlgName]:reopen()
    end
end

function DlgMgr:reopenRelativeDlg(dlgName)
    local dlgs = DLG_RELATION[dlgName]
    if not dlgs then
        return
    end

    for _, v in ipairs(dlgs) do
        local tmp = self.dlgs[v]
        if not tmp then
        else
            tmp:reopen()
        end
    end
end

-- 打开关联的对话框
function DlgMgr:openRelativeDlg(dlgName)
    local dlgs = DLG_RELATION[dlgName]
    if not dlgs then
        return
    end

    local subTabDlgName
    local outerTabDlgName
    for _, v in ipairs(dlgs) do

        -- 趣味对话框，检测下是否可以开启
        if DlgMgr:isShowFunDlg(v) then
        local tmp = self.dlgs[v]
        if not tmp then
            local dlg = self:openDlg(v, true)
            if dlg:isTabDlg() then
                if dlg.outerTabDlg then
                    -- 该 Tab 对话框之外还存在一级 Tab 对话框
                    outerTabDlgName = dlg.outerTabDlg
                    subTabDlgName = v
                end

                dlg:setSelectDlg(dlgName)
            end
        else
            self:reorderDlgByName(tmp.name)
            if tmp.setSelectDlg and type(tmp.setSelectDlg) == "function" then
                tmp:setSelectDlg(dlgName)
            end

            if tmp.closeRadioDlgExclude and type(tmp.closeRadioDlgExclude) == "function" then
                tmp:closeRadioDlgExclude(dlgName)
            end
           -- self:addShowUINumber(v)
           -- self:setOpenDlgZorder(v)
        end
    end
    end

    -- 选中上一级 Tab 对话框中对 Tab 对话框对应的的 Radio
    if outerTabDlgName then
        local outerTab = self:openDlg(outerTabDlgName)
        outerTab:setSelectDlg(subTabDlgName)
    end
end

-- 关闭关联的对话框
-- 不关闭对应的 tabDlg
function DlgMgr:closeRelativeDlg(dlgName, tabDlg)
    local dlgs = DLG_RELATION[dlgName]
    if not dlgs then
        return
    end

    for _, v in ipairs(dlgs) do
        local tmp = self.dlgs[v]
        if not tabDlg or ("string" == type(tabDlg) and tabDlg ~= v) or ("table" == type(tabDlg) and nil == tabDlg[v]) then
            if tmp then
                local len = string.len(v)
                if string.sub(v, len - 6 + 1, -1) == "TabDlg" then
                    --tmp.closeTime = gfGetTickCount()
                    DlgMgr.tabDlgCloseTime[v] = gfGetTickCount()
                end
                tmp:close()
            end
        end
    end
end

-- 关闭对话框
-- 不关闭对应的 tabDlg
function DlgMgr:closeDlg(dlgName, tabDlg, now, notCloseInputNumDlg)
    local dlg = self.dlgs[dlgName]
    if nil == dlg then
        if dlgName == "InstructionsDlg" then
            -- 如果传进来的时通用类型的界面，
            for dName, dlgInfo in pairs(self.dlgs) do
                if dlgInfo.jsonFileName then
                    dlg = dlgInfo
                end
            end
        else
            return
        end
    end
    dlg:close(now, notCloseInputNumDlg)

    --self:reduceShowUINumber(dlgName)
    local retDlgName = dlgName == "InstructionsDlg" and dlg.jsonFileName or dlgName
    self:closeRelativeDlg(retDlgName, tabDlg)

    local openDlgType = DLG_MUTEX[dlgName]
    if (openDlgType == DlgMgr.DLG_TYPE.MODEL or openDlgType == DlgMgr.DLG_TYPE.MODEL_NEED_REOPEN_INFIGHT or openDlgType == DlgMgr.DLG_TYPE.MODEL_WITHOUT_BLANKLAYER)
        and dlgName ~= "LoadingDlg" and dlgName ~= "LineUpDlg" then
        -- 使用到WebView的界面如果打开，需要在确认框类型界面打开时隐藏，关闭时显示
        local communityDlg = DlgMgr:getDlgByName("CommunityDlg")
        if communityDlg then communityDlg:setVisible(true) end

        local webDlg = DlgMgr:getDlgByName("WebDlg")
        if webDlg then webDlg:setVisible(true) end
        end
end

function DlgMgr:closeDlgForGm(dlgName, tabDlg, now, notCloseInputNumDlg)
    local dlg = self.dlgs[dlgName]
    if nil == dlg then return end
    dlg:closeForGm(now, notCloseInputNumDlg)
end

-- 关闭对话框
-- 不关闭依赖的对话框
function DlgMgr:closeThisDlgOnly(dlgName, now)
    local dlg = self.dlgs[dlgName]
    if nil == dlg then return end

    dlg:close(now)
end

-- 获取所有隐藏的界面
function DlgMgr:getAllInVisbleDlgs()
    local t = {}
    for name, dlg in pairs(self.dlgs) do
        if dlg and not dlg:isVisible() then
            table.insert(t, name)
        end
    end

    return t
end

-- 显示/隐藏所有已打开的界面
function DlgMgr:showAllOpenedDlg(show, excepts)

    if not excepts then excepts = {} end
    excepts["LoadingDlgForAction"] = 1

    if HomeChildMgr:isInDailyTask() and show then return end

    for name, dlg in pairs(self.dlgs) do
        -- UserLoginDlg 不显示出来是因为在登录界面进去创建角色会清理数据，在fightMgr中cleanup 会把所有界面显示出来导致闪一下
        if name ~= "LockScreenDlg" and name ~= "ScreenRecordingDlg" and name ~= "UserLoginDlg" and (not excepts or not excepts[name]) and name ~= (deviceCfg and deviceCfg.fullback or "") then
            if show and not self:isNeedShowAndHideMainDlg() and MAIN_DLG_LIST[name] and name ~= "ChatDlg" then
                -- 显示主界面，若当前需要对主界面进行显示或隐藏操作，不处理
            else
                dlg:setVisible(show)
            end
        end
    end
end

-- 设置好友和聊天防止层级错乱
function DlgMgr:setChatDlgZoderAndVisible(visible, zoder)
    local friendDlg = DlgMgr.dlgs["FriendDlg"]
    if friendDlg then
        friendDlg:setVisible(visible)
        friendDlg:setDlgZOrder(zoder)
    end

    local channelDlg = DlgMgr.dlgs["ChannelDlg"]
    if channelDlg then
        channelDlg:setVisible(visible)
        channelDlg:setDlgZOrder(zoder)
    end
end

function DlgMgr:setVisible(dlgName, visible)
    local dlg = self.dlgs[dlgName]
    if nil ~= dlg then
        dlg:setVisible(visible)
    end
end

function DlgMgr:closeAllNormalDlg()
    for dName, dlg in pairs(self.dlgs) do
        local dlgMutex = DLG_MUTEX[dName]
        if not dlgMutex or dlgMutex == self.DLG_TYPE.NORMAL or dlgMutex == self.DLG_TYPE.NORMAL_NO_EFFECT_FOR_CLICK_BLANK then
            DlgMgr:closeDlg(dName)
        end
    end
end

-- 战斗关闭界面的操作
function DlgMgr:fightNeedCloseDlg()
    -- 进战斗需要关闭确认框
    if self:getDlgByName("ConfirmDlg") and self:sendMsg("ConfirmDlg", "getEnterCombatIsNeedClose") then
        DlgMgr:closeDlg("ConfirmDlg")
    end

    -- 关闭一般性界面防止层级错乱
    local showDlgs = DlgMgr:closeDlgByTabAndReturnShowDlgs(self:getFightNeedColseDlg())

    -- 关闭邮件显示框
    DlgMgr:closeDlg("SystemMessageShowDlg")

    -- EquipmentOneClickUpgradeDlg界面特殊，如果改造中，并且改造的装备是穿着的，需要关闭界面
    local isNeedClose = DlgMgr:sendMsg("EquipmentOneClickUpgradeDlg", "isFightNeedClose")
    if isNeedClose and DlgMgr:getDlgByName("EquipmentOneClickUpgradeDlg") then
        DlgMgr:closeDlg("EquipmentOneClickUpgradeDlg")
    end

    -- 关闭等待
    DlgMgr:closeDlg("WaitDlg")

    return showDlgs
end

-- 获取进入战斗需要关闭的界面
function DlgMgr:getFightNeedColseDlg()
    if not self.excpetDlgTable then
        self.excpetDlgTable = {}
        for _, v in ipairs(FIGHT_NEED_CLOSE_DLGS) do
            self.excpetDlgTable[v] = v

            local dlgs = DLG_RELATION[v]
            if dlgs then
                for _, v in pairs(dlgs) do
                    -- 趣味对话框特殊处理一下
                    if string.match(v, "Funny") then
                    else
                    self.excpetDlgTable[v] = v
                end
            end
        end
    end
    end

    return self.excpetDlgTable
end

-- 战斗需要重新打开的界面
function DlgMgr:fightNeedReopenDlg(dlgs)
    table.sort(dlgs, function(l, r)
        local ld = self.dlgs[l]
        local rd = self.dlgs[r]

        if not ld or not rd then return false end
        if not ld and rd then return false end
        if ld and not rd then return true end

        local lb = ld.blank
        local rb = rd.blank

        if not lb or not rb then return false end
        if not lb and rb then return false end
        if lb and not rb then return true end

        return lb:getLocalZOrder() < rb:getLocalZOrder()
            or (lb:getLocalZOrder() == rb:getLocalZOrder()
            and lb:getOrderOfArrival() < rb:getOrderOfArrival())
    end)

    for i =1, #dlgs do
        local dlg = self.dlgs[dlgs[i]]
        if dlg and not FIGHT_NOT_REOPEN_DLGS[dlgs[i]] then
            -- 观战中心不需要reopen，所以观战对应的趣味界面也不需要reopen。当前这类型的只有观战，估计在删除趣味功能的时候，也只有一个，特殊处理一下
            if self.dlgs["WatchCentreDlg"] and string.match(dlg.name, "Funny") then
            else
                dlg:reopen()
                dlg:setVisible(true)

                -- 部分界面组合形式（珍宝交易类，组合花样多），不是采用关联对话框形式，所以如果有子界面，也reopen一下
                if dlg.childDlg then

                    if not dlg.childDlg.__cls_type__ then
                        -- 多个对话框
                        for dName, uDlg in pairs(dlg.childDlg) do
                            -- 如果是说明类界面，通过 jsonFileName 获取对应界面
                            local dName2 = uDlg.name == "InstructionsDlg" and uDlg.jsonFileName or uDlg.name
                            local childDlg = DlgMgr:getDlgByName(dName2)
                            if childDlg then	-- 容错判断
                                childDlg:reopen()
                                childDlg:setVisible(true)
                            end
                        end

                    else
                        -- 本身就是对话框
                        -- 如果是说明类界面，通过 jsonFileName 获取对应界面
                        local dName = dlg.childDlg.name == "InstructionsDlg" and dlg.childDlg.jsonFileName or dlg.childDlg.name
                        local childDlg = DlgMgr:getDlgByName(dName)
                        if childDlg then	-- 容错判断
                            childDlg:reopen()
                            childDlg:setVisible(true)
                        end
                    end

                end
            end
        end
    end
end

-- 设置对话框中的指定控件是否可见
function DlgMgr:setDlgCtrlVisible(dlgName, ctrlName, visible)
    if not self.dlgs[dlgName] and not visible then
        -- 界面未打开且不需要显示
        return
    end

    local dlg = self:getDlgByName(dlgName)

    if dlg then
        dlg:setCtrlVisible(ctrlName, visible)
    end
end

-- 显示/隐藏界面
function DlgMgr:showDlg(dlgName, show)
    if not self.dlgs[dlgName] and not show then
        -- 界面未打开且不需要显示
        return
    end

    local dlg
    if not show then
        -- 不显示但对话框已打开
        dlg = self.dlgs[dlgName]
        if dlg then -- 如果对话框要求不显示，但是已经存在
            dlg:setVisible(false)
            return dlg
        end
    end

    dlg = self:openDlg(dlgName)
    if dlg then
        dlg:setVisible(show)
    end

    return dlg
end

function DlgMgr:isVisible(dlgName)
    local dlg = self:getDlgByName(dlgName)
    if dlg and dlg:isVisible() then
        return true
    end

    return false
end

-- 打开/关闭对话框
function DlgMgr:openOrCloseDlg(dlgName)
    if self:isDlgOpened(dlgName) then
        self:closeDlg(dlgName)
    else
        self:openDlg(dlgName)
    end
end

-- 对话框是否已打开
function DlgMgr:isDlgOpened(dlgName)
    return self.dlgs[dlgName] ~= nil
end

-- 清除对话框记录，正常情况下不需要调用该函数，主要供 Dialog 调用
function DlgMgr:clearDlg(dlgName)

    if dlgName == "InstructionsDlg" then
        for _,dlg in pairs(self.dlgs) do
            if dlg.jsonFileName then
                dlgName = dlg.jsonFileName
            end
        end
    end

    assert(not dlgName or self.dlgs[dlgName], string.format("failed to clearDlg(%s)", tostring(dlgName)))
    if self.dlgs[dlgName] then
        if self.hashDlgs[self.dlgs[dlgName]] then
            self.hashDlgs[self.dlgs[dlgName]] = nil
        end
        self.dlgs[dlgName] = nil
    end

    self:showDlgWhenNoramlDlgClose(dlgName)
end

function DlgMgr:cleanup(isLoginOrSwithLine)
    if not isLoginOrSwithLine then
        DlgMgr.tabDlgCloseTime = {}

        self.lastTimes = {}
    end

    -- 关闭部分确认框
    gf:closeSomeConfirm()
    DlgMgr:closeDlg("SystemMessageListDlg")
    -- 应服务器要求，客户端换线自己关闭赠送相关界面
    DlgMgr:closeDlg("GiveApplyDlg")
    DlgMgr:closeDlg("GiveDlg")
    DlgMgr:closeDlg("VacationSnowDlg")
    DlgMgr:closeDlg("ChooseItemDlg")
    DlgMgr:closeDlg("QuanmPKPrepareDlg")
    DlgMgr:closeDlg("AutoTalkDlg")
    DlgMgr:closeDlg("AutoFightTalkDlg")
    DlgMgr:closeDlg("SifqjDlg")

    DlgMgr:closeDlg("HomeTakeCareDlg")
    DlgMgr:closeDlg("HomeCleanDlg")
    DlgMgr:closeDlg("FurnitureListDlg")
    DlgMgr:closeDlg("DeadRemindDlg")
    DlgMgr:closeDlg("WeddingBarrageDlg")
    DlgMgr:closeDlg("ControlDlg")
    DlgMgr:closeDlg("SpeclalRoomStrollDlg")
    DlgMgr:closeDlg("SpeclalRoomDanceDlg")
    DlgMgr:closeDlg("SpeclalRoomConvertDlg")
    DlgMgr:closeDlg("SpeclalRoomEatDlg")

    DlgMgr:closeDlg("NoneDlg")
    DlgMgr:closeDlg("VacationTempDlg")
    DlgMgr:closeDlg("VacationWhiteDlg")
    DlgMgr:closeDlg("WatermelonRaceDlg")
    DlgMgr:closeDlg("ChangyjjDlg")

    DlgMgr:closeDlg("PetDressDlg")
    DlgMgr:closeDlg("PetChangeColorDlg")
end

-- 是否需要对主界面做隐藏和显示操作
function DlgMgr:isNeedShowAndHideMainDlg()
    local isNeed = true
    if Me:isInCombat() or Me:isLookOn() then
        isNeed = false
    -- 原因未知
    -- elseif AutoWalkMgr:getMessageIndex() then
        -- isNeed = false
    elseif self:getDlgByName("HomePuttingDlg")
        or self:getDlgByName("HomePlantDlg")
        or self:getDlgByName("SouxlpDlg")
        or self:getDlgByName("VacationPersimmonDlg")
        or self:getDlgByName("VacationTempDlg")
        or self:getDlgByName("WatermelonRaceDlg")
        or self:getDlgByName("ControlDlg")
        or self:getDlgByName("SpeclalRoomStrollDlg")
        or self:getDlgByName("SpeclalRoomDanceDlg")
        or self:getDlgByName("SpeclalRoomConvertDlg")
        or self:getDlgByName("SpeclalRoomEatDlg")
        or self:getDlgByName("NoneDlg")
        or self:getDlgByName("InnMainDlg")
        or self:getDlgByName("ChangyjjDlg")
        or self:getDlgByName("ItemPuttingDlg")
        or self:getDlgByName("BinghkyDlg")
        or self:getDlgByName("WenquanDlg")
        or self:getDlgByName("ChildDailyMission1Dlg")
        or self:getDlgByName("ChildDailyMission2Dlg")
        or self:getDlgByName("ChildDailyMission3Dlg")
        or self:getDlgByName("ChildDailyMission5Dlg")
        or InnMgr:isNeedHideMainDlg() then
        isNeed = false
    end

   return isNeed
end

-- 是否需要对主界面做隐藏和显示操作
function DlgMgr:showMainDlg(dlgName)
    if DLG_MUTEX[dlgName] == self.DLG_TYPE.NORMAL or not DLG_MUTEX[dlgName] or DLG_MUTEX[dlgName] == self.DLG_TYPE.NORMAL_NO_EFFECT_FOR_CLICK_BLANK then
        -- 普通对话框
        return true
    elseif dlgName == "DramaDlg" then
        -- 剧本特殊处理
        return true
    elseif dlgName == "HomePuttingDlg" then
        -- 居所布置界面特殊处理
        return true
    elseif dlgName == "HomePlantDlg" then
        -- 居所种植界面特殊处理
        return true
    elseif dlgName == "SouxlpDlg" then
        -- 2018元旦节搜邪罗盘界面(全屏界面)特殊处理
        return true
    elseif dlgName == "VacationSnowDlg" then
        return true
    elseif dlgName == "VacationPersimmonDlg" then
        -- 2018寒假冻柿子界面(全屏界面)特殊处理
        return true
    elseif dlgName == "VacationTempDlg" then
        -- 2018暑假元神归位
        return true
    elseif dlgName == "WatermelonRaceDlg" then
        -- 2018暑假谁能吃瓜
        return true
    elseif dlgName == "ControlDlg" then
        -- 2018暑假寒气之脉
        return true
    elseif string.match(dlgName, "SpeclalRoom") then
        -- 通天塔神秘房间
        return true
    elseif dlgName == "NoneDlg" then
        return true
    elseif dlgName == "InnMainDlg" then
        -- 客栈主界面
        return true
    elseif dlgName == "ChangyjjDlg" then
        -- 重阳节-畅饮菊酒
        return true
    elseif dlgName == "ItemPuttingDlg" then
        return true
    elseif dlgName == "BinghkyDlg" then
        -- 2019暑假冰火考验界面
        return true
    elseif dlgName == "WenquanDlg" then
        -- 温泉主界面
        return true
    end

    return false
end

function DlgMgr:closeNormalAndFloatDlg()
    local all = self.dlgs
    for dlgName, v in pairs(all) do
        if DlgMgr:isFloatingDlg(dlgName) then
            if NUM_DLG[dlgName] then
                -- 如果是键盘界面
                if v.obj and DlgMgr:getDlgByName(v.obj.name) then
                    -- 如果对于键盘的父界面存在，则不关闭
                else
                    DlgMgr:closeDlg(dlgName)
                end
            else
                DlgMgr:closeDlg(dlgName)
            end
        else
            if not DLG_MUTEX[dlgName] then
                DlgMgr:closeDlg(dlgName)
            elseif DLG_MUTEX[dlgName] == DlgMgr.DLG_TYPE.NORMAL or
                    DLG_MUTEX[dlgName] == DlgMgr.DLG_TYPE.NORMAL_WITHOUT_BLANKLAYER or
                    DLG_MUTEX[dlgName] == DlgMgr.DLG_TYPE.NORMAL_NO_EFFECT_FOR_CLICK_BLANK then
                DlgMgr:closeDlg(dlgName)
            end
        end
    end
end


-- 关闭所有悬浮界面
function DlgMgr:closeAllFloatDlg()
    local all = self.dlgs
    for dlgName, v in pairs(all) do
        if DlgMgr:isFloatingDlg(dlgName) then
            if NUM_DLG[dlgName] then
                -- 如果是键盘界面
                if v.obj and DlgMgr:getDlgByName(v.obj.name) then
                    -- 如果对于键盘的父界面存在，则不关闭
                else
            DlgMgr:closeDlg(dlgName)
        end
            else
                DlgMgr:closeDlg(dlgName)
    end
        end
    end
end

-- 检查战斗中，需要reopen的界面
function DlgMgr:checkCanFightReopenByDlgName(dlgName)
    local dlgMutex = DLG_MUTEX[dlgName]

    if NUM_DLG[dlgName] then return true end

    if dlgName == "FriendDlg" then return true end

    if dlgName == "AnnouncementDlg" then return true end

    if not dlgMutex or self.DLG_TYPE.NORMAL == dlgMutex
        or self.DLG_TYPE.NORMAL_WITHOUT_BLANKLAYER == dlgMutex
        or self.DLG_TYPE.MODEL_NEED_REOPEN_INFIGHT == dlgMutex
        or self.DLG_TYPE.NORMAL_NO_EFFECT_FOR_CLICK_BLANK == dlgMutex then
            return true
    end

    return
end

-- 从传入表中关闭当前已开启界面并且返回需要显示的界面
function DlgMgr:closeDlgByTabAndReturnShowDlgs(closeDlgTable)
    local all = self.dlgs
    local showDlgs = {}
    for dlgName, v in pairs(all) do
        if closeDlgTable and closeDlgTable[dlgName] then
            -- 关闭配表中需要关闭的界面
            --v:close() 由 v:close()修改为DlgMgr:closeDlg(v.name)，希望它关闭关联对话框
            DlgMgr:closeDlg(v.name)
        elseif (self:checkCanFightReopenByDlgName(dlgName) and dlgName ~= "LockScreenDlg")
            or (dlgName == "LoadingDlg" and v:isVisible()) then
            -- 保存普通对话框，用于后面排序后重新打开，防止层级混乱
            table.insert(showDlgs, dlgName)
        end
    end

    return showDlgs
end

function DlgMgr:closeOtherDlgs(excepts)
    local all = self.dlgs
    for k, v in pairs(all) do
        if not excepts[k] then
            DlgMgr:closeDlg(k, nil, true)
        end
    end
end

-- 关闭所有对话框
function DlgMgr:closeAllDlg()
    local all = self.dlgs
    for k, v in pairs(all) do
        DlgMgr:closeDlg(k, nil, true)
    end

    assert(0 == #self.dlgs, CHS[3003961])
    gf:getUILayer():removeAllChildren()
    self.dlgs = {}
    GuardMgr.guideLayer = nil
end

function DlgMgr:sendMsg(dlgName, funcName, ...)
    local dlg = self.dlgs[dlgName]
    if dlg == nil then return end
    local func = dlg[funcName]
    if func == nil then return end
    return func(dlg, ...)
end

function DlgMgr:getMutexLevel(dlgName)
    if nil == DLG_MUTEX[dlgName] then return end

    return  DLG_MUTEX[dlgName]
end

-- 是否是悬浮对话框
function DlgMgr:isFloatingDlg(dlgName)
    if dlgName == nil then return false end

    if DLG_MUTEX[dlgName] == 2 then return true end

    return false
end

-- 是否满足指定类型的界面
function DlgMgr:isMeetDlgMutex(dlgsMtx, dlgName)
    local isNormal = false
    for _, mtx in pairs(dlgsMtx) do
    --
        if mtx == DLG_MUTEX[dlgName] then
            return true
        end

        if mtx == 3 then
            isNormal = true
        end
    end

    -- 如果有一般性界面，DLG_MUTEX[dlgName] 也是
    if isNormal and not DLG_MUTEX[dlgName] then return true end
end


-- 关闭悬浮框外层layer
function DlgMgr:closeFloatingLayer()
    if DlgMgr.floatingLayer ~= nil then
        DlgMgr.floatingLayer:removeFromParent(true)
        DlgMgr.floatingLayer:setTag(0)
        DlgMgr.floatingLayer = nil
    end
end

-- 获取最近打开的对话框
function DlgMgr:getLastOpenDlg()
    return DlgMgr.lastOpenDlg
end

-- 关闭其他无关界面
function DlgMgr:returnToMain()
    local keepOpenDlg = {
                    ["LoadingDlg"] = 1,
                    ["RookieGiftDlg"] = 1,
                    ["FastUseItemDlg"] = 1,
                    ["ConvenientCallGuardDlg"] = 1,
					["SmallTipDlg"] = 1,

		-- 战斗中的界面
        ["FightPlayerMenuDlg"] = 1,
        ["CombatViewDlg"] = 1,
        ["AutoFightSettingDlg"] = 1,
        ["FightRoundDlg"] = 1,
        ["FightLookOnDlg"] = 1,
        ["FightInfDlg"] = 1,
                    }

    if deviceCfg and deviceCfg.fullback then
        keepOpenDlg[deviceCfg.fullback] = 1
    end

    -- 取所有的界面判断是否是主界面
        for k, v in pairs(DlgMgr.dlgs) do
            if 1 ~= MAIN_DLG_LIST[k] and not keepOpenDlg[k] and (k ~= "CommunityDlg" or v and v:isVisible()) then
                DlgMgr:closeDlg(k, true)
            end
        end
end

-- 是否可以显示WebDlg界面
function DlgMgr:canShowWebDlg(ignoreLoading, webName)
    local dlgs = DlgMgr.dlgs
    for k, v in pairs(dlgs) do
        if (not ignoreLoading or k ~= "LoadingDlg") and  k ~= webName and k ~= "LineUpDlg" then
            local dlgType = DLG_MUTEX[k]
            if (dlgType == DlgMgr.DLG_TYPE.MODEL or dlgType == DlgMgr.DLG_TYPE.MODEL_NEED_REOPEN_INFIGHT
                or dlgType == DlgMgr.DLG_TYPE.MODEL_WITHOUT_BLANKLAYER) and v:isVisible() then
                return false
            end
        end
    end

    return true
end

-- 萝卜桃子中醉心雾时，会禁闭全屏，只能走路，无法关闭界面
-- 若出现确认框等可能挡住视线的界面，需先解禁，让玩家先关闭界面。
function DlgMgr:isCanSeeMain()
    local keepOpenDlg = {
        ["LoadingDlg"] = 1,
        ["RookieGiftDlg"] = 1,
        ["FastUseItemDlg"] = 1,
        ["ConvenientCallGuardDlg"] = 1,
        ["SmallTipDlg"] = 1,
        ["FriendDlg"] = 1,
        ["ChannelDlg"] = 1,
        ["PopUpDlg"] = 1,
    }

    -- 取所有的界面判断是否有界面会挡住玩家视线
    if not Me:isInCombat() then
        for k, v in pairs(DlgMgr.dlgs) do
            if 1 ~= MAIN_DLG_LIST[k] and not keepOpenDlg[k] then
                return false
            end
        end
    end

    return true
end

-- 设置界面中所有DLG显示状态
function DlgMgr:setAllDlgVisible(isVisible, excepts)
    if isVisible and MapMgr:isInMapByName(CHS[5400718]) then
        return
    end

    for k, v in pairs(DlgMgr.dlgs) do
        if k ~= "WeddingBarrageDlg" and (not excepts or not excepts[k]) and k ~= "LoadingDlg" and k ~= "ScreenRecordingDlg" and k ~= "LockScreenDlg" and k ~= (deviceCfg and deviceCfg.fullback or "") then
            -- 如果剧本结束，显示主界面，有
            if isVisible and self.normalDlgState == NORMAL_DLG_STATE.HIDE and MAIN_DLG_LIST[k] and (k ~= "ChatDlg" or ActivityMgr:isChantingStauts() or HomeChildMgr:isInDailyTask()) then
            -- 如果显示主界面，主界面显示状态为hide，则不处理
            else
                v:setVisible(isVisible)
            end
        end
    end
end

-- 获取窗口
function DlgMgr:getDlgByName(dlgName)
    assert(not self.dlgs[dlgName] or self.dlgs[dlgName].root)
    return self.dlgs[dlgName]
end

-- 整个界面窗口淡入效果
function DlgMgr:fadeInAllDlg()
    local fadeIn = cc.FadeIn:create(0.5)
    for k, v in pairs(DlgMgr.dlgs) do
        if not v:isVisible() and self.normalDlgState == NORMAL_DLG_STATE.SHOW and MAIN_DLG_LIST[k] and k ~= "ChatDlg"  and k ~= "ScreenRecordingDlg" then
            v:setVisible(true)
            if v.blank then
                v.blank:setOpacity(0)
                v.blank:runAction(fadeIn:clone())
            end
        end
    end
end

-- param 格式：对话框名字=参数1:参数2:...
function DlgMgr:closeDlgWithParam(param)
    local paramList
    if 'string' == type(param) then
        paramList = gf:split(param, "=")
    elseif 'table' == type(param) then
        paramList = param
    end

    local dlgName = paramList[1]
    local dlg = DlgMgr:getDlgByName(dlgName)
    if dlg then
        if paramList[2] and type(dlg.checkCloseDlg) == "function" then
            if dlg:checkCloseDlg(gf:split(paramList[2], ":")) then
                DlgMgr:closeDlg(dlgName)
            end
        else
            DlgMgr:closeDlg(dlgName)
        end
    end
end

-- 打开某个对话框需要参数  addby zhengjh
-- 如果需要先加载数据需要在NEED_LOADDATA_BEFORE配置
-- loadDataThenOpenDlg实现要请求的条件
-- 在registHook添加注册回调
function DlgMgr:openDlgWithParam(param)
    local paramList
    if 'string' == type(param) then
        paramList = gf:split(param, "=")
    elseif 'table' == type(param) then
        paramList = param
    end

    local dlgName = paramList[1]

    local afterDramaDlg = {["DeadRemindDlg"] = 1}
    if NEED_LOADDATA_BEFORE[dlgName] then
        self:loadDataThenOpenDlg(dlgName, paramList)
    else
        self:openDlgAndsetParam(paramList)
    end

    if paramList and paramList[2] then
        if string.match(paramList[2], "Tips:(.+)") then
            gf:ShowSmallTips(string.match(paramList[2], "Tips:(.+)"))
        end
    end
end

-- 需要加载数据后再打开对话框
function DlgMgr:loadDataThenOpenDlg(dlgName, param)

   if dlgName == "ActivitiesDlg" then
        if tonumber(Me:queryBasicInt("level")) >= 10 then
            ActivityMgr:CMD_ACTIVITY_LIST() -- 获取活动节日开始时间
            ActivityMgr:getActiviInfo() -- 获取活跃度
            self.hooksTable[dlgName] = param
        else
            gf:ShowSmallTips(CHS[6000151])
        end
   elseif "PartyManageDlg" == dlgName then
        -- 帮派管理界面
        if not PartyMgr:getPartyInfo() then
            PartyMgr:queryPartyInfo()
            self.hooksTable[dlgName] = param
        else
            DlgMgr:openDlgAndsetParam(param)
        end
   end
end

-- 通过分割好的参数 打开对话框
function DlgMgr:openDlgAndsetParam(param)
    if not param then return end

    local paramList
    if 'string' == type(param) then
        paramList = gf:split(param, "=")
    elseif 'table' == type(param) then
        paramList = param
    end

    local dlgName = paramList[1]
    local dlgParam = paramList[2]

    if dlgName == "SendMailDlg" then
        -- 邮寄界面，蒙尘的x灵珠需要特殊处理
        if string.match(dlgParam, CHS[4100631]) then
            local data = InventoryMgr:getItemByClass(InventoryMgr:getClassByName(dlgParam), true)
            if not data or not next(data) then
                local autoWalkInfo = gf:findDest(CHS[4100605])
                AutoWalkMgr:beginAutoWalk(autoWalkInfo)
                return
            end
            local dlg = DlgMgr:openDlg(dlgName)
            dlg:initList(dlgParam)
            dlg:initSelectItemClass(dlgParam, 3)
        end
    elseif dlgName == "SummerVacationDlg" then
        if gf:getServerTime() > tonumber(dlgParam) then
            gf:ShowSmallTips(CHS[4200366])
            return
        end

        GiftMgr:setLastIndex("WelfareButton17")
        local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
        dlg:onGiftsButton(dlg:getControl("GiftsButton"))
    elseif dlgName == "ZaixqyDlg" then
        GiftMgr:setLastIndex("WelfareButton8")
        local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
        dlg:onGiftsButton(dlg:getControl("GiftsButton"))
    elseif dlgName == "ZaoHuaDlg" then
        GiftMgr:setLastIndex("WelfareButton19")
        local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
        dlg:onGiftsButton(dlg:getControl("GiftsButton"))
    elseif "HomeFishingDlg" == dlgName then
        -- 钓鱼界面由服务端通知打开
        if dlgParam == "open" then
            DlgMgr:openDlg(dlgName)
        else
            gf:CmdToServer("CMD_HOUSE_ENTER_FISH")
        end
    elseif "OnlineMallDlg" == dlgName then
        -- 在线商城引导
        if dlgParam then
            OnlineMallMgr:openOnlineMall(dlgName, nil, {[dlgParam] = 1})
        else
        OnlineMallMgr:openOnlineMall(dlgName)
        end
    elseif "InnerAlchemyDlg" == dlgName then
        if param and param[2] and param[2] == "commit_pet" and param[3] and param[4] then
            local petList = PetMgr:getPetByType(Const.PET_RANK_WILD, tonumber(param[4]), tonumber(param[3]), true, true)
            if #petList > 0 then
                gf:CmdToServer("CMD_NEIDAN_SUBMIT_PET")
            else
                local polarToCh = {[0] = CHS[3001385], [1] = CHS[3004297], [2] = CHS[3004298], [3] = CHS[3004299], [4] = CHS[3004300], [5] = CHS[3004301]}
                gf:ShowSmallTips(string.format(CHS[7100151], tonumber(param[3]), polarToCh[tonumber(param[4])]))
            end
        else
            DlgMgr:openDlg(dlgName)
        end
    elseif "AnniversaryLingMaoDlg" == dlgName then
        AnniversaryMgr:tryOpenLingMaoDlg()
    elseif "DossierDlg" == dlgName then
        if dlgParam then
            gf:CmdToServer("CMD_DETECTIVE_TASK_CLUE", {taskName = dlgParam})
        else
            gf:CmdToServer("CMD_DETECTIVE_TASK_CLUE", {taskName = CHS[7190231]})
        end
    elseif "ConvenientBuyDlg" == dlgName then
        OnlineMallMgr:openOnlineMall("ConvenientBuyDlg", nil, {[dlgParam] = 1})
    elseif "MarketGoldVendueDlg" == dlgName then
        local dlg = DlgMgr:openDlgEx(dlgName, true)
        local list = {CHS[4101226], "isOpenPay", "", dlgParam}
        dlg:onDlgOpened(list, dlgParam)
    else
        local dlg = DlgMgr:openTabDlg(dlgName)

        -- 需要带参数的dlg格式  #@别名|对话框名字=参数1:参数2:...#@)
        -- 比如（#@别名|FastUseItemDlg=一叶草#@）
        if dlgParam then
            if #paramList > 2 then
                -- param 中有多个 =，之后的内容（包括分隔符均属于参数内容）
                for i = 3, #paramList do
                    dlgParam = dlgParam .. '=' .. paramList[i]
                end
            end

            local list = gf:split(dlgParam, ":")
            dlg:onDlgOpened(list, dlgParam)
        end
    end
end

function DlgMgr:unHookMsg()
    MessageMgr:unhookByHooker("DlgMgr")
end

-- 注册回调消息
function DlgMgr:registHook()
    local function canOpenDlg(data)

        local dlgNameKey = nil
        for k, v in pairs(NEED_LOADDATA_BEFORE) do
            if Msg[data.MSG] == v then
                dlgNameKey = k
            end
        end

        if dlgNameKey == nil then return end
        local param =  self.hooksTable[dlgNameKey]
        if self.hooksTable[dlgNameKey] then
        self:openDlgAndsetParam(param)
            self.hooksTable[dlgNameKey] = nil
    end
    end

    self.hooksTable = {}

    for k, v in pairs(NEED_LOADDATA_BEFORE) do
        MessageMgr:hook(v, canOpenDlg, "DlgMgr")
    end
end

-- 打开界面的计数 addby zhengjh
-- 维护界面UI层级的关系
--                                  这个东西有问题，别用！！！
function DlgMgr:addShowUINumber(dlgName)
    if not self:CountDlg(dlgName)then return end

   if self.openUINumber  == nil then
        self.openUINumber = 0
   end

    self.openUINumber = self.openUINumber + 1
end

function DlgMgr:reduceShowUINumber(dlgName)
    if not self:CountDlg(dlgName)then return end
    self.openUINumber  = self.openUINumber  - 1
end

--                                  这个东西有问题，别用！！！
function DlgMgr:setOpenDlgZorder(dlgName)
    if not self:CountDlg(dlgName)then return end
    local dlg = self.dlgs[dlgName]
    dlg:setDlgZOrder(self.openUINumber)
end

function DlgMgr:CountDlg(dlgName)
   -- local dlg = self.dlgs[dlgName]

    if MAIN_DLG_LIST[dlgName] then
        return false
    end

    return true
end

function DlgMgr:isExsitGeneralDlg()
    for dlgName, dlg in pairs(self.dlgs) do
        if DLG_MUTEX[dlgName] == self.DLG_TYPE.NORMAL then
            return true
        end
    end

    return false
end

function DlgMgr:closeFastUseDlg()
    DlgMgr:closeDlg("FastUseItemDlg")
    DlgMgr:closeDlg("ConvenientCallGuardDlg")
    DlgMgr:closeDlg("RookieGiftDlg")
end

function DlgMgr:MSG_OPEN_NANHWS_DIALOG(data)
    local dlg = DlgMgr:openDlg("SubmitChangeCardDlg")
    dlg:setEffectCard(data)
end

function DlgMgr:MSG_DAILY_STATS(data)
    if not self.statisticsDlgRect then return end
    local dlg = DlgMgr:openDlg("StatisticsDlg")
    dlg:setData(data)
    dlg:setFloatingFramePos(self.statisticsDlgRect)
end

function DlgMgr:reorderDlgByName(dlgName)
    local dlg = self:getDlgByName(dlgName)
    if dlg then
        -- 由于调用 reorderChild 时如果 z-order 没有变化则不会触发 EventDispatcher 对监听者重新排序
        -- 故需要先修改一下 zOrder
        local zOrder = dlg:getDlgZOrder()
        dlg:setDlgZOrder(zOrder + 1)
        gf:getUILayer():reorderChild(dlg.blank, zOrder)

        gf:getUILayer():sortAllChildren()
    end
end

-- 上推一个界面
function DlgMgr:upDlg(dlgName, upHeight)
    local dlg = DlgMgr:getDlgByName(dlgName)
    if not dlg then
        -- 没有对话框
        return
    end

    if dlg.rootRawY then
        -- 已经上推过了，不能再次响应
        return
    end

    -- 初始化默认Y轴
    dlg.rootRawY = dlg.root:getPositionY()
    dlg.root:setPositionY(dlg.rootRawY + upHeight)

    -- 上推关联界面
    local dlgs = DLG_RELATION[dlgName]
    if not dlgs then
        return
    end

    for _, v in ipairs(dlgs) do
        self:upDlg(v, upHeight)
    end
end

-- 还原位置
function DlgMgr:resetUpDlg(dlgName)
    local dlg = DlgMgr:getDlgByName(dlgName)
    if not dlg then
        -- 没有对话框
        return
    end

    if not dlg.rootRawY then
        -- 没有上推操作
        return
    end

    dlg.root:setPositionY(dlg.rootRawY)
    dlg.rootRawY = nil

    -- 还原关联界面
    local dlgs = DLG_RELATION[dlgName]
    if not dlgs then
        return
    end

    for _, v in ipairs(dlgs) do
        self:resetUpDlg(v)
    end
end

-- 打开好运鉴宝
function DlgMgr:MSG_NEWYEAR_2018_HYJB(data)
    local dlg = DlgMgr:openDlg("LuckIdentifyDlg")
end

-- 打开寒假作业
function DlgMgr:MSG_WINTER_2018_HJZY(data)
    if data then
        local questionAndChoice = {}
        for i = 1, data.count do
            local question = string.split(data.question[i], "|")
            local questionContend
            if #question == 5 then
                --选择题
                questionContend = {describe = question[1], choice1 = question[2], choice2 = question[3],
                    choice3 = question[4], choice4 = question[5], type = "choice"}
            else
                questionContend = {describe = question[1], type = "fill"}
            end

            table.insert(questionAndChoice, questionContend)
        end

        data.questionContent = questionAndChoice

        local answer = gf:split(data.answer, "\t")
        if #answer < data.count then
            -- 与题目数量不相等，清空答案
            answer = {}
            for i = 1, data.count do
                table.insert(answer, "")
            end
        end

        local myData = {}
        myData.type = data.type
        myData.count = data.count
        myData.question = questionAndChoice
        myData.answer = answer

        local dlg = DlgMgr:openDlg("VacationHomeworkDlg")
        dlg:setData(myData)
    end
end

-- key 为 "文件名" .. "变量名" 防止出现重复
function DlgMgr:setLastTime(key, time)
    self.lastTimes[key] = time
end

function DlgMgr:getLastTime(key)
    return self.lastTimes[key]
end

function DlgMgr:showLoadingDlgAction(seconds)
    if DlgMgr:getDlgByName("LoadingDlg") then
        return
    end
    DlgMgr:openDlgEx("LoadingDlgForAction")
end

MessageMgr:regist("MSG_DAILY_STATS", DlgMgr)
MessageMgr:regist("MSG_OPEN_NANHWS_DIALOG", DlgMgr)
MessageMgr:regist("MSG_NEWYEAR_2018_HYJB", DlgMgr)
MessageMgr:regist("MSG_WINTER_2018_HJZY", DlgMgr)

DlgMgr:registHook()
