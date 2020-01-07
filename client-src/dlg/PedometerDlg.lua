-- PedometerDlg.lua
-- Created by songcw May/25/2017
-- 计步工具界面

local PedometerDlg = Singleton("PedometerDlg", Dialog)

local LIMIT = 4 -- 字符长度
local MAX_STEPS = 500

function PedometerDlg:init()
    self:bindListener("PosGOButton", self.onPosGOButton)
    self:bindListener("DoublePosGOButton", self.onDoublePosGOButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("ConfirmButton_0", self.onDelButton)
    self:bindListener("CopyButton", self.onCopyButton)
    self:bindListener("CollectedButton", self.onCollectedButton)
    self:bindListener("OpenButton", self.onOpenButton)
    self:bindListViewListener("ListView", self.onSelectListView)

    self:setCtrlVisible("CollectedButton", true)
    self:setCtrlVisible("OpenButton", false)

    -- 单个目的地
    self:bindEditField("XInputTextField", "PosPanel", LIMIT)
    self:bindEditField("YInputTextField", "PosPanel", LIMIT)

    -- 两个目的地
    self:bindEditField("XInputTextField", "DoublePosPanel1", LIMIT)
    self:bindEditField("YInputTextField", "DoublePosPanel1", LIMIT)
    self:bindEditField("XInputTextField", "DoublePosPanel2", LIMIT)
    self:bindEditField("YInputTextField", "DoublePosPanel2", LIMIT)

    -- 克隆
    self.posPanel = self:toCloneCtrl("ListPanel")

    self:onDelButton()
end

function PedometerDlg:cleanup()
    self:releaseCloneCtrl("posPanel")
end

function PedometerDlg:getCoordinates(panelName)
    local namePanel = self:getControl(panelName)
    local xCtrl = self:getControl("XInputTextField", nil, namePanel)
    local yCtrl = self:getControl("YInputTextField", nil, namePanel)

    local x = tonumber(xCtrl:getStringValue())
    local y = tonumber(yCtrl:getStringValue())

    if not x or not y then
        return
    end

    return x, y
end

function PedometerDlg:bindEditField(tfName, parentPanelName, lenLimit, verAlign, eventCallBack)
    local textCtrl = self:getControl(tfName, nil, parentPanelName)
    textCtrl:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    textCtrl:setTextVerticalAlignment(verAlign or cc.TEXT_ALIGNMENT_CENTER)

    textCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then
            local str = textCtrl:getStringValue()

            if gf:getTextLength(str) > lenLimit then
                gf:ShowSmallTips(CHS[4000224])
            end

            textCtrl:setText(tostring(gf:subString(str, lenLimit)))
        elseif ccui.TextFiledEventType.delete_backward == eventType then
        elseif ccui.TextFiledEventType.detach_with_ime == eventType then

            local str = textCtrl:getStringValue()
            local num = tonumber(str)
            if not num then
                textCtrl:setText("")
                gf:ShowSmallTips(CHS[4200354])
            end
        end

        if eventCallBack then
            eventCallBack(self, sender, eventType)
        end
    end)
end

function PedometerDlg:checkPos(panelName)
    local x, y = self:getCoordinates(panelName)
    if not x or not y then
        gf:ShowSmallTips(CHS[4200362])
        return
    end

    local mapSize = MapMgr:getMapSize()
    if x < 0 or x > mapSize.width then
        gf:ShowSmallTips(CHS[4200361])
        return
    end

    if y < 0 or y > mapSize.height then
        gf:ShowSmallTips(CHS[4200360])
        return
    end

    return true
end

function PedometerDlg:willGoToDest(panelName)
    local x, y = self:getCoordinates(panelName)
    self.isRecording = true
    Me:setEndPos(x, y)
end

function PedometerDlg:onPosGOButton(sender, eventType)
    if not self:checkPos("PosPanel") then
        return
    end

    self:onDelButton()
    self:willGoToDest("PosPanel")
end

function PedometerDlg:onDoublePosGOButton(sender, eventType)

    if not self:checkPos("DoublePosPanel1") then
        return
    end

    if not self:checkPos("DoublePosPanel2") then
        return
    end
    self:onDelButton()

    local x, y = self:getCoordinates("DoublePosPanel1")
    if Me.lastMapPosX == x and Me.lastMapPosY == y then
        self:willGoToDest("DoublePosPanel2")
        return
    end

    self.isNeedAutoNext = true
    self:willGoToDest("DoublePosPanel1")
end

function PedometerDlg:autoNextDest()
    self.isNeedAutoNext = false
    self:willGoToDest("DoublePosPanel2")
end

function PedometerDlg:addStep(x, y)
    if not self.isRecording then return end

    if self.totalSteps >= MAX_STEPS then
        gf:ShowSmallTips(string.format(CHS[4200355], MAX_STEPS))
        return
    end

    local ctrl = self:getControl("ListView")

    self.totalSteps = self.totalSteps + 1
    local panel = self.posPanel:clone()
    self:setLabelText("Label_137", self.totalSteps, panel)
    self:setLabelText("Label_137_0", string.format("(%d,%d)", x, y), panel)
    ctrl:pushBackCustomItem(panel)

    table.insert(self.steps, {step = self.totalSteps, pos = string.format("%d,%d", x, y)})

    self:updateTotalSteps()
end

function PedometerDlg:updateTotalSteps()
    self:setLabelText("NumLabel", self.totalSteps)
end

function PedometerDlg:onConfirmButton(sender, eventType)
end

-- 停止计算
function PedometerDlg:onDelButton(sender, eventType)
    self:resetListView("ListView")
    self.totalSteps = 0         -- 步数初始化 0
    self.isRecording = false       -- 是否记录中
    self.isNeedAutoNext = false -- 是否需要下一个目的地
    self.steps = {}             -- 步数数据
    self:updateTotalSteps()     -- 刷新部分界面
end

function PedometerDlg:onCopyButton(sender, eventType)
    if not next(self.steps) then
        gf:ShowSmallTips(CHS[4200356])
        return
    end

    local curTime = os.date("%Y%m%d%H%M%S", os.time())
    local path = Const.WRITE_PATH .. "StepsRecord/" .. Me:queryBasic("gid") .. "/" .. curTime

    local control = ""
    local content = ""
    local i = 0
    local startPos = ""
    local endPos = ""

    for _, value in pairs(self.steps) do
        control = control .. string.format(CHS[4200357], value.step, value.pos) .. ",\n"
        content = content .. value.pos .. ","
        i = 1 + i
        if i % 10 == 0 then
            content = content .. "\n"
        end

        if i == 1 then
            startPos = value.pos
        else
            endPos = value.pos
        end
    end

    local ret = "\nreturn {\n" .. control
    ret = ret .. "}"
    gfSaveFile(ret, path .."_" .. startPos .. "_" .. endPos .. ".lua")
    gfSaveFile(content, path .."_" .. startPos .. "_" .. endPos .. ".list")

    local tipMsg = CHS[4200358] .. path .. "..."
    gf:ShowSmallTips(tipMsg)
    ChatMgr:sendMiscMsg(tipMsg)
end

function PedometerDlg:onCollectedButton(sender, eventType)
    if self.isMoving then
        gf:ShowSmallTips(CHS[4200359])
        return
    end
    self.isMoving = true
    local size = self:getControl("MainPanel"):getContentSize()

    local moveAct = cc.MoveBy:create(0.25, cc.p(size.width, 0))
    local func = cc.CallFunc:create(function()
        self.isMoving = false
        self:setCtrlVisible("CollectedButton", false)
        self:setCtrlVisible("OpenButton", true)
    end)

    self.root:runAction(cc.Sequence:create(moveAct, func))
end

function PedometerDlg:onOpenButton(sender, eventType)
    if self.isMoving then
        gf:ShowSmallTips(CHS[4200359])
        return
    end
    self.isMoving = true
    local size = self:getControl("MainPanel"):getContentSize()

    local moveAct = cc.MoveBy:create(0.25, cc.p(-size.width, 0))
    local func = cc.CallFunc:create(function()
        self.isMoving = false
        self:setCtrlVisible("CollectedButton", true)
        self:setCtrlVisible("OpenButton", false)
    end)

    self.root:runAction(cc.Sequence:create(moveAct, func))
end

function PedometerDlg:onSelectListView(sender, eventType)
end

return PedometerDlg
