-- JiuTianDlg.lua
-- Created by songcw July/04 2018
-- 九天真君界面

local JiuTianDlg = Singleton("JiuTianDlg", Dialog)

local BX_STATE = {
    PASS = 1,      -- 通关
    NO_OPEN = 2,   -- 未开启
    LIMIT = 3,     -- 未开放
    CUR_NO_PASS = 4,
    CUR_PASS = 5,
}

function JiuTianDlg:init(data)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("EnterButton", self.onEnterButton)

    self:bindFloatPanelListener("RulePanel")

    self:setDataInfo(data)
end

function JiuTianDlg:onRuleButton(sender, eventType)
    self:setCtrlVisible("RulePanel", true)
end

function JiuTianDlg:onEnterButton(sender, eventType)
    gf:CmdToServer("CMD_JIUTIAN_ZHENJUN")
    self:onCloseButton()
end

-- 设置对话框信息
function JiuTianDlg:setDataInfo(data)
    self.data = data
    local curNum = -1
    for i = 0, 8 do
        local state = BX_STATE.LIMIT
        if i < data.openMax then
            -- 此关已经开放
            state = BX_STATE.NO_OPEN
            if i < data.curCheckpoint then
                -- 小于当前关，必然已通关
                state = BX_STATE.PASS
            elseif i == data.curCheckpoint then
                if data.mainState == 2 then
                    -- 当前任务关卡完成
                    state = BX_STATE.PASS
                else
                    -- 进行中或者可以开启
                    curNum = i
                end
            elseif i == data.curCheckpoint + 1 then
                if data.mainState == 2 then
                    -- 上一关已经完成
                    curNum = i
                end
            end
        end

        local panel = self:getControl("CheckPointPanel_" .. (i + 1))
        panel:setTag(i + 1)
        self:setTaskByState(state, panel, (curNum == i))
    end

    self.curIndex = curNum + 1
end

-- 设置关卡开启状态
function JiuTianDlg:setTaskByState(state, panel, isCur)
    if not panel  then return end

    if isCur then
        local pickImage = self:getControl("ChoseImage", nil, panel)
        pickImage:setVisible(true)
        pickImage:stopAllActions()
        pickImage:setPosition(panel.choseImagex, panel.choseImagey)
        local time = 0.6
        local high = 8
        local moveUp = cc.MoveBy:create(time, cc.p(0, high))
        local moveDown = cc.MoveBy:create(time, cc.p(0, -high))
        local act = cc.Sequence:create(moveUp, moveDown)
        pickImage:runAction(cc.RepeatForever:create(act))
        pickImage:setVisible(true)

        if state == BX_STATE.PASS then
            state = BX_STATE.CUR_PASS
        else
            state = BX_STATE.CUR_NO_PASS
        end
    end


    if state == BX_STATE.PASS then
        -- 通关
        self:setImageResume("PersonImage", panel)
        self:setCtrlVisible("PersonImage", true, panel)
        self:setCtrlEnabled("PersonImage", true, panel)
        self:setCtrlVisible("NameImage", true, panel)
        self:setCtrlVisible("NameImage_1", true, panel)
        self:setCtrlVisible("ChoseImage", false, panel)
        self:setCtrlVisible("SuccessImage", true, panel)
    elseif state == BX_STATE.NO_OPEN then
        -- 未开启
        self:setImageResume("PersonImage", panel)
        self:setCtrlVisible("PersonImage", true, panel)
        self:setCtrlEnabled("PersonImage", false, panel)
        self:setCtrlVisible("NameImage", false, panel)
        self:setCtrlVisible("NameImage_1", false, panel)
        self:setCtrlVisible("ChoseImage", false, panel)
        self:setCtrlVisible("SuccessImage", false, panel)
    elseif state == BX_STATE.LIMIT then
        -- 未开放
        self:setImageResume("PersonImage", panel)
        self:setImageShadow("PersonImage", panel)
        self:setCtrlVisible("NameImage", false, panel)
        self:setCtrlVisible("NameImage_1", false, panel)
        self:setCtrlVisible("ChoseImage", false, panel)
        self:setCtrlVisible("SuccessImage", false, panel)
    elseif state == BX_STATE.CUR_NO_PASS then
        self:setImageResume("PersonImage", panel)
        self:setCtrlEnabled("PersonImage", true, panel)
        self:setCtrlVisible("NameImage", true, panel)
        self:setCtrlVisible("NameImage_1", true, panel)
        self:setCtrlVisible("ChoseImage", true, panel)
        self:setCtrlVisible("SuccessImage", false, panel)
    elseif state == BX_STATE.CUR_PASS then
        self:setImageResume("PersonImage", panel)
        self:setCtrlVisible("NameImage", true, panel)
        self:setCtrlVisible("NameImage_1", true, panel)
        self:setCtrlVisible("ChoseImage", true, panel)
        self:setCtrlVisible("SuccessImage", true, panel)
    end
end

-- 还原图片设置
function JiuTianDlg:setImageResume(ctrlName, panel)
    local hero = self:getControl(ctrlName, Const.UIImage, panel)
    hero:resume()
end

-- 设置图片剪影效果
function JiuTianDlg:setImageShadow(ctrlName, panel)
    local hero = self:getControl(ctrlName, nil, panel)
    hero:setOpacity(125)
    hero:setColor(COLOR3.BLACK)
end

return JiuTianDlg
