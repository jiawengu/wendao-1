-- CaseTWArrayDlg.lua
-- Created by huangzz Jun/06/2018
-- 探案天外之谜-尸变阵界面

local CaseTWArrayDlg = Singleton("CaseTWArrayDlg", Dialog)

local Json = require('json')

local SCRATCH_NUM = 5

-- 公示
local MATH_FORMULA = {
	{"1", "0.5+0.5", "√4-1",    "X^2+X-2=0\nX>=0,X=?"},
	{"2", "1+1",     "√4",      "X^2+X-6=0\nX>=0,X=?"},
	{"3", "2+1",    "√9",       "X^2-X-6=0\nX>=0,X=?"},
	{"4", "2*2",    "√9+1",     "X^2-2X-8=0\nX>=0,X=?"},
	{"5", "2+3",    "√4+3",     "2X^2-5X-25=0\nX>=0,X=?"},
	{"6", "3*2",    "√5*√5+1",  "2X^2-6X-36=0\nX>=0,X=?"},
	{"7", "3+4",    "√9+4",     "X^2-6X-7=0\nX>=0,X=?"},
	{"8", "4*2",    "√4*√4 *2", "X^2-64=0\nX>=0,X=?"},
	{"9", "3+6",    "√4*√4 +5", "3X^2-26X-9=0\nX>=0,X=?"},
}

local TIPS = {
    "+，奇变偶不变", 	 
    "x，奇变偶不变", 	 
    "+，偶变奇不变", 	 
    "x，偶变奇不变",
}

function CaseTWArrayDlg:init(param)
    self:setFullScreen()
    
    self:bindListener("ConfirmButton", self.onConfirmButton)

    self.eraser = GiftMgr:getEraser("CaseTWArrayDlg", SCRATCH_NUM, 75, 10)

    if param and param.gameStatus ~= "" then
        local gameStatus = Json.decode(param.gameStatus)
        self.scratchStatus = gameStatus.scratchStatus or {}
        self.arrayStatus = gameStatus.arrayStatus or {}
    else
        self.scratchStatus = {}
        self.arrayStatus = {}
    end

    for i = 1, 30 do
        if not self.arrayStatus[i] then
            self.arrayStatus[i] = 0
        end
    end

    for i = 1, 5 do
        if not self.scratchStatus[i] then
            self.scratchStatus[i] = 0
        end
    end

    self.isComplete = param.isComplete == 1 and true or false
    self.zhensfNum = param.zhensf_num

    if self:checkIsComplete() and not self.isComplete then
        -- 镇尸符全部贴完，但贴错了，直接清空
        for i = 1, 30 do
            self.arrayStatus[i] = 0
        end
    end
    
    self:initView(param)

    self:hookMsg("MSG_TWZM_MATRIX_RESULT")
end

function CaseTWArrayDlg:cmdAnswer()
    local data = {}
    for i = 1, 20 do
        if self.arrayStatus[i] == 1 then
            table.insert(data, i)
        end
    end

    gf:CmdToServer("CMD_TWZM_MATRIX_ANSWER",data)
end

function CaseTWArrayDlg:cmdCurGameStatus()
    local status = {}
    status.arrayStatus = self.arrayStatus
    status.scratchStatus = self.scratchStatus

    gf:CmdToServer("CMD_TWZM_MATRIX_STATE", {status = Json.encode(status)})
end

function CaseTWArrayDlg:initScratchPanel()
    if not self.rText then
        self.rText = {}
    end
   
    local path = ResMgr.ui.case_scratch
    for i = 1, SCRATCH_NUM do
        -- 重新生成其它的画布前，先释放之前的画布
        if self.rText[i] and self.rText[i]:getParent() then
            self.rText[i]:removeFromParent()
        end
        
        self['canTouchFlag' .. i] = true
        local ctrlName = "DustPanel" .. i
        self.rText[i] = GiftMgr:getScratchRTextbByName(ctrlName)
        if not self.rText[i] then
            if self.scratchStatus[i] ~= 1 then
                self.rText[i] = self:createScratch(ctrlName, path, self.eraser[i], 0.60, self.onErased, 0.62, 'canTouchFlag' .. i)
                GiftMgr:setScratchRText(ctrlName, self.rText[i])
            end
        elseif not self.rText[i]:getParent() then
            local panel = self:getControl(ctrlName)
            panel:addChild(self.rText[i])
        end

        self:setCtrlVisible("DustImage", false, ctrlName)
    end
end

function CaseTWArrayDlg:initView(data)
    for i = 1, 20 do
        local panel = self:getControl("CasketPanel" .. i)
        panel:setTag(i)
        self:setCtrlVisible("SpellImage", self.arrayStatus[i] == 1, panel)
        self:bindTouchEndEventListener(panel, self.onCasketPanel)
    end
    
    -- 用于显示镇尸符剩余数量
    self:checkIsComplete()

    -- 显示公示
    local formula = data.formula
    for i = 1, 4 do
        if formula[i + 5].index == 4 then
            self:setLabelText("MathLabel" .. i, "")
            self:setColorText("#m" .. MATH_FORMULA[formula[i + 5].num][formula[i + 5].index] .. "#n", "MathLabel" .. i, nil, nil, nil, cc.c3b(117, 97, 77), 15)
        else
            self:setLabelText("MathLabel" .. i, MATH_FORMULA[formula[i + 5].num][formula[i + 5].index])
        end
    end

    for i = 5, 9 do
        if formula[i - 4].index == 4 then
            self:setLabelText("MathLabel" .. i, "")
            self:setColorText("#m" .. MATH_FORMULA[formula[i - 4].num][formula[i - 4].index] .. "#n", "MathLabel" .. i, nil, nil, nil, cc.c3b(117, 97, 77), 15)
        else
            self:setLabelText("MathLabel" .. i, MATH_FORMULA[formula[i - 4].num][formula[i - 4].index])
        end
    end
    
    -- 创建刮图
    self:initScratchPanel()

    -- 设置提示语
    for i = 1, 5 do
        if data.tip_place == i then
            self:setLabelText("TipsLabel", TIPS[data.tip_index], "DustPanel" .. i)
        else
            self:setLabelText("TipsLabel", "", "DustPanel" .. i)
        end
    end
    
    -- 已经完成，播放镇尸符光效
    if self:checkIsComplete() and self.isComplete then
        for i = 1, 20 do
            local img = self:getControl("SpellImage", nil, "CasketPanel" .. i)
            img:setVisible(false)
            if self.arrayStatus[i] == 1 then
                local panel = img:getParent()
                gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.tanan_tw_zhenshifu_light.name, "Top02", panel, nil, nil, nil, img:getPosition())
            end
        end
    end

end

-- 刮完后要回调函数
function CaseTWArrayDlg:onErased(panelName)
    local tag = tonumber(string.match(panelName, "DustPanel(.+)"))

    if self.scratchStatus[tag] ~= 1 then
        self.scratchStatus[tag] = 1
        self:cmdCurGameStatus()
    end
end

function CaseTWArrayDlg:onCasketPanel(sneder, eventType)
    if self.isComplete then
        gf:ShowSmallTips(CHS[5450271])
        return
    end

    if InventoryMgr:getEmptyPosCount() == 0 then
        gf:ShowSmallTips(CHS[5450270])
        return
    end

    if self:checkIsComplete() then
        return
    end

    local tag = sneder:getTag()
    self.arrayStatus[tag] = self.arrayStatus[tag] == 1 and 0 or 1
    self:setCtrlVisible("SpellImage", self.arrayStatus[tag] == 1, sneder)
    
    self:cmdCurGameStatus()
    if self:checkIsComplete() then
        self:cmdAnswer()
    end
end

function CaseTWArrayDlg:onConfirmButton(sender, eventType)
end

function CaseTWArrayDlg:checkIsComplete()
    local cou = 0
    for i = 1, 20 do
        if self.arrayStatus[i] == 1 then
            cou = cou + 1
        end
    end

    self:setLabelText("NumLabel", string.format(CHS[5450275], self.zhensfNum - cou, self.zhensfNum))

    return self.zhensfNum <= cou
end

function CaseTWArrayDlg:MSG_TWZM_MATRIX_RESULT(data)
    if data.result == 1 then
        self.isComplete = true
         
        gf:frozenScreen(3000)
        local isFirst = true
        for i = 1, 20 do
            local img = self:getControl("SpellImage", nil, "CasketPanel" .. i)
            img:setVisible(false)
            if self.arrayStatus[i] == 1 then
                local panel = img:getParent()
                if not isFirst then
                    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.tanan_tw_zhenshifu_light.name, "Top01", panel, nil, nil, nil, img:getPosition())
                else
                    isFirst = false
                    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.tanan_tw_zhenshifu_light.name, "Top01", panel, function() 
                        gf:CmdToServer("CMD_TWZM_RESPONSE_MATRIX_RESULT", {})
                        gf:unfrozenScreen()
                        self:onCloseButton()
                    end, nil, nil, img:getPosition())
                end
            end
        end
    else
        local isFirst = true
        gf:frozenScreen(3000)
        for i = 1, 20 do
            local img = self:getControl("SpellImage", nil, "CasketPanel" .. i)
            performWithDelay(img, function()
                -- 延迟一帧，防止出现闪一下的效果
                img:setVisible(false) 
            end, 0)

            if self.arrayStatus[i] == 1 then
                local panel = img:getParent()
                local magic
                if not isFirst then
                    magic = gf:createSelfRemoveMagic(ResMgr.magic.tanan_tw_zhenshifu_burn, {frameInterval = 65})
                else
                    isFirst = false
                    magic = gf:createCallbackMagic(ResMgr.magic.tanan_tw_zhenshifu_burn, function(node) 
                        self:setLabelText("NumLabel", string.format(CHS[5450275], self.zhensfNum, self.zhensfNum))
                        gf:ShowSmallTips(CHS[5450276])
                        node:removeFromParent()
                        gf:unfrozenScreen()
                    end, {frameInterval = 65})
                end

                magic:setAnchorPoint(0.5, 0.5)
                magic:setPosition(img:getPosition())
                panel:addChild(magic)
            end

            self.arrayStatus[i] = 0
        end
    end
end

function CaseTWArrayDlg:cleanup()
    self.rText = nil

    self.eraser = nil

    self.scratchStatus = nil
end

return CaseTWArrayDlg
