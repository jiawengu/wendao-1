-- PetOneClickDevelopDlg.lua
-- Created by liuhb Mar/11/2016
-- 宠物界面一键强化

local PetOneClickDevelopDlg = Singleton("PetOneClickDevelopDlg", Dialog)

local REBUILD_STATUS = {  -- 强化的状态
    NONE  = 0,
    START = 1,
    END   = 2,
}

local COST_EVERY_TIME = 216  -- 一次消耗的元宝
local DEVELOP_DELTA = 1      -- 每次强化的间隔

local curSelectPet = nil                    -- 当前选择的宠物
local curTargetRebuildLevel = 0             -- 当前需要强化的目标等级
local rebuildStatus = REBUILD_STATUS.NONE   -- 强化状态
local lastEndTime = 0                       -- 最后一次强化的时间

-- 初始化
function PetOneClickDevelopDlg:init()
    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("StopButton", self.onStopButton)
    self:bindListener("GoldBackImage", self.onGoldCoinAddButton)
    self:bindCheckBoxListener("BindCheckBox", self.onBindCheckBox)

    -- 初始化数据
    curSelectPet = nil
    curTargetRebuildLevel = 0
    self:setRebuildStatus(REBUILD_STATUS.NONE)

    -- 监听的消息
    self:hookMsg("MSG_REBUILD_PET_RESULT")
    self:hookMsg("MSG_UPDATE")
    
    -- silver_coin = 0随意传一个，只要让初始化走进去即可
    self:MSG_UPDATE({silver_coin = 0})
end

-- 金元宝按钮
function PetOneClickDevelopDlg:onGoldCoinAddButton(sender, eventType)
    DlgMgr:openDlg("OnlineRechargeDlg")
end

-- 清理数据
function PetOneClickDevelopDlg:cleanup()
    curSelectPet = nil
    curTargetRebuildLevel = 0
    
    if REBUILD_STATUS.NONE ~= self:getRebuildStatus() and GameMgr.inCombat then
        gf:ShowSmallTips(CHS[4300325])
    end
    
    self:setRebuildStatus(REBUILD_STATUS.NONE)
end

-- 获取最大可以强化的宠物等级
function PetOneClickDevelopDlg:getMaxDevelopLevel()
    if not curSelectPet then return end

    Log:D(">>>> getMaxDevelopLevel : " .. PetMgr:getMaxDevelopLevel(curSelectPet))
    return PetMgr:getMaxDevelopLevel(curSelectPet)
end

-- 设置宠物数据
function PetOneClickDevelopDlg:setPetData(pet)
    if not pet then return end

    curSelectPet = pet

    -- 设置初始等级
    self:setTargetLevel(self:getSelectPetRebuildLevel() + 1)
end

-- 获取当前选择宠物的强化类型
function PetOneClickDevelopDlg:getSelectPetRebuildType()
    local petPolar = curSelectPet:queryBasicInt("polar")
    if petPolar > 0 then
        return "mag"
    else
        return "phy"
    end
end

-- 获取当前选择的宠物的强化登记
function PetOneClickDevelopDlg:getSelectPetRebuildLevel()
    if not curSelectPet then return 0 end
    local petPolar = curSelectPet:queryBasicInt("polar")
    local rebuildLevel = 0
    if petPolar > 0 then
        rebuildLevel = curSelectPet:queryInt("mag_rebuild_level")
    else
        rebuildLevel = curSelectPet:queryInt("phy_rebuild_level")
    end

    return rebuildLevel
end

-- 获取当前选择宠物的名字
function PetOneClickDevelopDlg:getSelectPetName()
    if not curSelectPet then return 0 end
    return curSelectPet:getName()
end

-- 获取当前目标等级
function PetOneClickDevelopDlg:getTargetLevel()
    return curTargetRebuildLevel
end

-- 设置当前目标等级
function PetOneClickDevelopDlg:setTargetLevel(level)
    if not curSelectPet then return end
    if level > PetMgr:getMaxDevelopLevel(curSelectPet) then
        level = PetMgr:getMaxDevelopLevel(curSelectPet)
    end

    curTargetRebuildLevel = level
    self:updateTargetLevel()
    self:updateAddReduceBtn()
end

-- 设置当前强化状态
function PetOneClickDevelopDlg:setRebuildStatus(status)
    rebuildStatus = status
    self:updateStartEndBtn()
end

-- 获取当前强化状态
function PetOneClickDevelopDlg:getRebuildStatus()
    return rebuildStatus
end

-- 更新当前按钮状态
function PetOneClickDevelopDlg:updateAllBtn()
    self:updateAddReduceBtn()
    self:updateStartEndBtn()
end

-- 更新增加减少按钮状态
function PetOneClickDevelopDlg:updateAddReduceBtn()
    local rebuildLevel = self:getSelectPetRebuildLevel()

    local addCtrl = self:getControl("AddButton")
    if self:getTargetLevel() >= self:getMaxDevelopLevel() then
        -- 达到上限
        gf:grayImageView(addCtrl)
    else
        gf:resetImageView(addCtrl)
    end

    local reduceCtrl = self:getControl("ReduceButton")
    if self:getTargetLevel() <= rebuildLevel + 1 then
        -- 达到上限
        gf:grayImageView(reduceCtrl)
    else
        gf:resetImageView(reduceCtrl)
    end
end

-- 更新显示数值框
function PetOneClickDevelopDlg:updateTargetLevel()
    self:setLabelText("NumLabel", tostring(self:getTargetLevel()) .. CHS[5300006])
end

-- 更新开始结束按钮状态
function PetOneClickDevelopDlg:updateStartEndBtn()
    self:setCtrlVisible("StartButton", false)
    self:setCtrlVisible("StopButton", false)

    if REBUILD_STATUS.NONE == self:getRebuildStatus() then
        self:setCtrlVisible("StartButton", true)
    else
        self:setCtrlVisible("StopButton", true)
    end
end

-- 减少按钮
function PetOneClickDevelopDlg:onReduceButton(sender, eventType)
    local rebuildLevel = self:getSelectPetRebuildLevel()
    if self:getTargetLevel() <= rebuildLevel + 1 then
        gf:ShowSmallTips(string.format(CHS[5300001], rebuildLevel))
        return
    end

    self:setTargetLevel(self:getTargetLevel() - 1)
end

function PetOneClickDevelopDlg:onAddButton(sender, eventType)
    local rebuildLevel = self:getSelectPetRebuildLevel()
    if self:getTargetLevel() >= self:getMaxDevelopLevel() then
        gf:ShowSmallTips(string.format(CHS[5300002], self:getSelectPetName(), self:getMaxDevelopLevel()))
        return
    end

    self:setTargetLevel(self:getTargetLevel() + 1)
end

function PetOneClickDevelopDlg:onBindCheckBox(sender, eventType)
    if self:isCheck("BindCheckBox") then
        gf:ShowSmallTips(CHS[5300003])
    end
end

function PetOneClickDevelopDlg:onStartButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end
    
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[4300325])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onStartButton") then
        return
    end

    self:setRebuildStatus(REBUILD_STATUS.START)
end

function PetOneClickDevelopDlg:onStopButton(sender, eventType)
    self:setRebuildStatus(REBUILD_STATUS.NONE)
end

function PetOneClickDevelopDlg:onUpdate()
    if REBUILD_STATUS.NONE == self:getRebuildStatus() then
        -- 结束
        return
    end

    if REBUILD_STATUS.START == self:getRebuildStatus() then
        -- 开始
        -- 判断是否完成
        if self:getSelectPetRebuildLevel() >= self:getTargetLevel() then
            -- 已经完成
            gf:ShowSmallTips(string.format(CHS[5300004], self:getTargetLevel()))

            -- 刷新界面
            self:setTargetLevel(self:getSelectPetRebuildLevel() + 1)

            -- 设置为停止
            self:setRebuildStatus(REBUILD_STATUS.NONE)
            return
        end

        -- 金钱是否足够
        if self:isCheck("BindCheckBox") then
            -- 使用银元宝
            if Me:getTotalCoin() < COST_EVERY_TIME then
                -- 设置为停止
                self:setRebuildStatus(REBUILD_STATUS.NONE)

                gf:askUserWhetherBuyCoin()
                return
            end
        else
            -- 不使用银元宝
            if Me:queryBasicInt('gold_coin') < COST_EVERY_TIME then
                -- 设置为停止
                self:setRebuildStatus(REBUILD_STATUS.NONE)

                gf:askUserWhetherBuyCoin()
                return
            end
        end

        -- 向服务端请求
        lastEndTime = gf:getServerTime()
        if not curSelectPet then return end
        local useType = "gold_coin"
        if self:isCheck("BindCheckBox") then
            useType = ""
        end

        PetMgr:requestOneClickDevelop(curSelectPet:getId(), self:getTargetLevel(), self:getSelectPetRebuildType(), useType)
        self:setRebuildStatus(REBUILD_STATUS.END)
        return
    end

    if REBUILD_STATUS.END == self:getRebuildStatus() then
        -- 判断是否超时
        if gf:getServerTime() - lastEndTime > DEVELOP_DELTA then
            lastEndTime = gf:getServerTime()
            self:setRebuildStatus(REBUILD_STATUS.START)
        end

        return
    end
end

function PetOneClickDevelopDlg:MSG_REBUILD_PET_RESULT(data)
    if data.flag == 0 then
        self:setRebuildStatus(REBUILD_STATUS.NONE)
    end
end

function PetOneClickDevelopDlg:MSG_UPDATE(data)
    if data.silver_coin or data.gold_coin then
        local gold_coin = Me:queryBasicInt('gold_coin')
        local goldText = gf:getArtFontMoneyDesc(tonumber(gold_coin))
        self:setNumImgForPanel("GoldValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23)
    
        local silver_coin = Me:queryBasicInt('silver_coin')
        local silverText = gf:getArtFontMoneyDesc(tonumber(silver_coin))
        self:setNumImgForPanel("SilverValuePanel", ART_FONT_COLOR.DEFAULT, silverText, false, LOCATE_POSITION.MID, 23)
    end
end

return PetOneClickDevelopDlg
