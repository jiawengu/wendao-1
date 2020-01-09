-- XitclDlg.lua
-- Created by songcw Oct/17/2018
--喜填春联

local XitclDlg = Singleton("XitclDlg", Dialog)

-- 备选字，需要分割处理一下，
local FAKE_POOL = CHS[4300477]

local FADEOUT_TIME = 1

function XitclDlg:init(data)
    self:setFullScreen()
    self:setCtrlFullClientEx("BKPanel")

    self:bindListener("SubmitButton", self.onSubmitButton)


    local backupPanel = self:getControl("BackUpPanel")
    local leftPanel = self:getControl("LeftPanel")
    local rightPanel = self:getControl("RightPanel")
    for i = 1, 8 do
        -- 右侧
        local panel = self:getControl("WordPanel_" .. i, nil, backupPanel)
        if panel then
            panel:setTag(i)
            panel.key = "WordPanel_" .. i
            self:bindTouchEndEventListener(panel, self.onSelectBack)
        end
        -- 春联
        local panel = self:getControl("WordPanel_" .. i, nil, leftPanel)
        if panel then
            self:bindTouchEndEventListener(panel, self.onClickChunlian)
        end

        local panel = self:getControl("WordPanel_" .. i, nil, rightPanel)
        if panel then
            self:bindTouchEndEventListener(panel, self.onClickChunlian)
        end
    end

    self.selectImage = self:retainCtrl("ChosenImage")
    self.isResetting = false
    self.movePanel = nil    -- 拖动中的
    self.canPushPool = {}   -- 可放入的池
    self.isGameOver = nil
    if data then
        self.data = self:paraData(data)
        self:setData(self.data)
    end

    self:hookMsg("MSG_SPRING_2019_XTCL_STOP_GAME")
end

function XitclDlg:onSelectBack(sender)

    if self.isLock then return end

    local str = self:getLabelText("Label", sender)

    local panel = self.selectImage:getParent()
    if panel then
        local str2 = self:getLabelText("Label", panel)
        local backupPanel = self:getControl("BackUpPanel")
        for i = 1, 8 do
            local item = self:getControl("WordPanel_" .. i, nil, backupPanel)
            if panel.key == item.key then
                item:setVisible(true)
            end
        end

        self:setLabelText("Label", str, panel)
        sender:setVisible(false)

        panel.key = sender.key
    else
        gf:ShowSmallTips(CHS[4200617])  -- 请先在上方春联区域选中待填的位置。
    end
end

function XitclDlg:onClickChunlian(sender)
	if self.isLock then return end
    local panel = self.selectImage:getParent()
    if panel then
        if sender == panel then
            self.selectImage:removeFromParent()
            local str = self:getLabelText("Label", sender)

            local backupPanel = self:getControl("BackUpPanel")
            for i = 1, 8 do
                local item = self:getControl("WordPanel_" .. i, nil, backupPanel)
                if panel.key == item.key then
                    item:setVisible(true)
                end
            end
            self:setLabelText("Label", "", sender)

            panel.key = nil
        else
            self.selectImage:removeFromParent()
            sender:addChild(self.selectImage)
        end
    else
        sender:addChild(self.selectImage)
    end
end

-- 收到新对联
function XitclDlg:resetData(data)

    self:disApper(data) -- 渐隐效果
    self.isResetting = true
    self.selectImage:removeFromParent()
    self:removeMovePanel()
    local leftPanel = self:getControl("LeftPanel")
    local rightPanel = self:getControl("RightPanel")

    for i = 1, 8 do

        -- 春联
        local panel = self:getControl("WordPanel_" .. i, nil, leftPanel)
        if panel then
            panel.key = nil
        end

        local panel = self:getControl("WordPanel_" .. i, nil, rightPanel)
        if panel then
            panel.key = nil
        end

    end

    performWithDelay(self.root, function ()
        self.isResetting = false
        self.movePanel = nil    -- 拖动中的
        self.canPushPool = {}   -- 可放入的池
        self.data = self:paraData(data)
        self:setData(self.data)
        self.isLock = false
    end, FADEOUT_TIME + 0.1)
end

-- 获取备用字对应的panel
function XitclDlg:getBackupPanelByName(name)
    local backupPanel = self:getControl("BackUpPanel")
    for i = 1, 8 do
        -- 右侧
        local panel = self:getControl("WordPanel_" .. i, nil, backupPanel)
        if panel then
            local str = self:getLabelText("Label", panel)
            if name == str then
                return panel
            end
        end
    end
end

function XitclDlg:removeMovePanel()
    if not self.movePanel then return end
    self.movePanel:removeFromParent()
    self.movePanel = nil
end

-- 检测该位置是否可以放进
function XitclDlg:updateCL()
    if not self.movePanel then return end
    local isPush

    for name, node in pairs(self.canPushPool) do
        local rect = self:getBoundingBoxInWorldSpace(node)
        if cc.rectContainsPoint(rect, GameMgr.curTouchPos) then
            local para = gf:split(name, "_")
            local panel = self:getControl("WordPanel_" .. para[2], nil, para[1])
            local oldStr = self:getLabelText("Label", panel)
            if oldStr ~= "" then
                local backupPanel = self:getControl("BackUpPanel")

                for i = 1, 8 do
                    local oldPanel = self:getControl("WordPanel_" .. i, nil, backupPanel)

                    if oldPanel and self:getLabelText("Label", oldPanel) == oldStr then
                        oldPanel:setVisible(true)
                    end
                end
            end

            -- 设置新的
            local str = self:getLabelText("Label", self.movePanel)
            self:setLabelText("Label", str, panel)
            self:setCtrlVisible("BKImage", true, panel)
            isPush = true

            self:removeMovePanel()
        end
    end

    return isPush
end

function XitclDlg:disApper(data)
    local leftPanel = self:getControl("LeftPanel")
    local rightPanel = self:getControl("RightPanel")
    local henpiPanel = self:getControl("HengpiPanel")
    local backupPanel = self:getControl("BackUpPanel")

    local function getAction(ctl)
        local fadeAct = cc.FadeOut:create(FADEOUT_TIME)

        local disAct = cc.CallFunc:create(function()
            ctl:setOpacity(255)
        end)
        return cc.Sequence:create(fadeAct, cc.DelayTime:create(0.5), disAct)
    end

    for i = 1, 8 do
        local panel = self:getControl("WordPanel_" .. i, nil, leftPanel)
        if panel then
            local label = self:getControl("Label", nil, panel)
            label:runAction(getAction(label))

            local bImage = self:getControl("BKImage", nil, panel)
            bImage:runAction(getAction(bImage))
        end

        local panel = self:getControl("WordPanel_" .. i, nil, rightPanel)
        if panel then
            local label = self:getControl("Label", nil, panel)
            label:runAction(getAction(label))

            local bImage = self:getControl("BKImage", nil, panel)
            bImage:runAction(getAction(bImage))
        end

        local label = self:getControl("Label_" .. i, nil, henpiPanel)
        if label then
            local fadeAct = cc.FadeOut:create(FADEOUT_TIME)
            label:runAction(getAction(label))
        else
        end

        local panel = self:getControl("WordPanel_" .. i, nil, backupPanel)
        if panel then
            local fadeAct = cc.FadeOut:create(FADEOUT_TIME)
            local label = self:getControl("Label", panel)
            if panel then panel:runAction(getAction(panel)) end
        end
    end
end

function XitclDlg:setData(data)
    local leftPanel = self:getControl("LeftPanel")
    local rightPanel = self:getControl("RightPanel")
    local henpiPanel = self:getControl("HengpiPanel")
    for i = 1, 7 do
        local panel = self:getControl("WordPanel_" .. i, nil, leftPanel)
        self:setLabelText("Label", data.disPlayLeftStr[i], panel)
        self:setCtrlVisible("Label", true, panel)
        self:setCtrlVisible("BKImage", false, panel)
        if data.disPlayLeftStr[i] == "" then
            self.canPushPool["LeftPanel_" .. i] = panel            --self:getBoundingBoxInWorldSpace(panel)
        end

        panel:setEnabled(data.disPlayLeftStr[i] == "")
        self:setCtrlVisible("BKImage", data.disPlayLeftStr[i] == "", panel)

        local panel = self:getControl("WordPanel_" .. i, nil, rightPanel)
        self:setCtrlVisible("Label", true, panel)
        self:setCtrlVisible("BKImage", false, panel)
        self:setLabelText("Label", data.disPlayRightStr[i], panel)
        if data.disPlayRightStr[i] == "" then
            self.canPushPool["RightPanel_" .. i] = panel               --self:getBoundingBoxInWorldSpace(panel)
        end

        self:setCtrlVisible("BKImage", data.disPlayRightStr[i] == "", panel)
        panel:setEnabled(data.disPlayRightStr[i] == "")

        if data.henpi and data.henpi[i] then
            self:setLabelText("Label_" .. i, data.henpi[i], henpiPanel)
            self:setCtrlVisible("Label_" .. i, true, henpiPanel)
        end
    end

    -- 设置右侧随机
    local ret = {}
    for _, key in pairs(data.answer) do
        ret = self:getRandNumNotMap(ret, key)
    end

    local backupPanel = self:getControl("BackUpPanel")
    for i = 1, 8 do
        if not ret[i] then
            local num = self:getRandBackUoNotMap(ret)
            ret[i] = self.fakePools[num]
        end

        local panel = self:getControl("WordPanel_" .. i, nil, backupPanel)
        if panel then
            self:setLabelText("Label", ret[i], panel)
            panel:setVisible(true)
        end
    end

    -- 请选择合适的文字填入春联(%d/3)
    self:setLabelText("Label", string.format( CHS[4300473], data.idx), "InfoPanel")
end

function XitclDlg:getRandBackUoNotMap(ret)
    local num = math.random( 1, #self.fakePools )
    local isOk = true
    for i = 1, 8 do
        if ret[i] == self.fakePools[num] then
            isOk = false
        end
    end

    if isOk then return num end
    return self:getRandBackUoNotMap(ret)
end

function XitclDlg:getRandNumNotMap(ret, key)
    local rNum = math.random( 1, 8 )
    if ret[rNum] then
        return self:getRandNumNotMap(ret, key)
    else
        ret[rNum] = key
        return ret
    end
end

-- 获取第几位上的数字,如果大于7，自己转换下
function XitclDlg:getNumByUnit(src, unit)
    return math.floor( src / math.pow(10, (unit - 1)) % 7 + 1 )
end

function XitclDlg:getNextKeyNum(key, para)
    local ret = key + 2 + para % 2 + 1
    if ret > 7 then ret = ret - 7 end

    return ret
end


function XitclDlg:paraData(data)
    local retData = {}
    local leftStr = {}
    local rightStr = {}
    local henpi = {}
    self.fakePools = {}
    for i = 1, string.len(FAKE_POOL), 3 do
        local fZi = string.sub(FAKE_POOL, i, i + 2)
        if fZi and fZi ~= "" then
            table.insert( self.fakePools, fZi)
        end

        local lZi = string.sub(data.cl1, i, i + 2)
        if lZi and lZi ~= "" then
            table.insert( leftStr, lZi)
        end

        local rZi = string.sub(data.cl2, i, i + 2)
        if rZi and rZi ~= "" then
            table.insert( rightStr, rZi)
        end

        local hZi = string.sub(data.cl3, i, i + 2)
        if hZi and hZi ~= "" then
            table.insert( henpi, hZi)
        end
    end

    -- 当前次数
    retData.idx = data.idx

    retData.encrypt_id = data.encrypt_id

    -- 完整的对联
    retData.leftStr = leftStr
    retData.rightStr = rightStr
    retData.henpi = henpi

    -- 服务器关键字
    retData.keyNum = data.cl_rand_value

    retData.leftKey = self:getNumByUnit(data.cl_rand_value, 2)
    retData.rightKey = self:getNumByUnit(data.cl_rand_value, 1)
    retData.answer = {}

    -- 界面显示的对联
    local disPlayLeftStr = gf:deepCopy(leftStr)
    local nextKey = self:getNextKeyNum(retData.leftKey, retData.rightKey)   -- 用另一个为了增加随机性

    table.insert( retData.answer, disPlayLeftStr[retData.leftKey])
    table.insert( retData.answer, disPlayLeftStr[nextKey])
    disPlayLeftStr[retData.leftKey] = ""
    disPlayLeftStr[nextKey] = ""
    retData.disPlayLeftStr = disPlayLeftStr

    local disPlayRightStr = gf:deepCopy(rightStr)
    local nextKey = self:getNextKeyNum(retData.rightKey, retData.leftKey)   -- 用另一个为了增加随机性
    table.insert( retData.answer, disPlayRightStr[retData.rightKey])
    table.insert( retData.answer, disPlayRightStr[nextKey])
    disPlayRightStr[nextKey] = ""
    disPlayRightStr[retData.rightKey] = ""
    retData.disPlayRightStr = disPlayRightStr

    return retData
end


function XitclDlg:checkAnswer()
    local isNil
    local isError

    local leftPanel = self:getControl("LeftPanel")
    local rightPanel = self:getControl("RightPanel")
    for i = 1, 7 do
        local panel = self:getControl("WordPanel_" .. i, nil, leftPanel)
        local str = self:getLabelText("Label", panel)
        if str == "" then
            isNil = true
        end

        if str ~= self.data.leftStr[i] then
            isError = true
        end

        local panel = self:getControl("WordPanel_" .. i, nil, rightPanel)
        local str = self:getLabelText("Label", panel)
        if str == "" then
            isNil = true
        end

        if str ~= self.data.rightStr[i] then
            isError = true
        end
    end

    if isNil then
        gf:ShowSmallTips(CHS[4300474])  -- 别急别急，有的地方没填好呢！
        return
    end

    if isError then
        gf:ShowSmallTips(CHS[4300475]) -- 好像有地方填的不对，还是再仔细瞧瞧吧！
        return
    end

    gf:ShowSmallTips(CHS[4300476]) -- 补齐春联成功！
    local result = gfEncrypt("succ", self.data.encrypt_id)
    gf:CmdToServer("CMD_SPRING_2019_XTCL_COMMIT", {result = result})
    return true
end

function XitclDlg:onSubmitButton(sender, eventType)
    if self.isResetting then return end
    if self.isLock then return end
    if self:checkAnswer() then
        self.isLock = true
    end

end

function XitclDlg:MSG_SPRING_2019_XTCL_STOP_GAME(data)
    self.isGameOver = true
    self:onCloseButton()
end

function XitclDlg:cleanup()
    gf:CmdToServer("CMD_SPRING_2019_XTCL_STOP")

    self:removeMovePanel()
    self.isLock = false
end

return XitclDlg
