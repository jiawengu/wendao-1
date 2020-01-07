-- ExpStoreHouseDlg.lua
-- Created by huangzz Aug/29/2018
-- 经验仓库界面

local ExpStoreHouseDlg = Singleton("ExpStoreHouseDlg", Dialog)

local NEED_LOCK_DAYS = 8

local ONE_DAY = 24 * 60 * 60

local CAN_GET_DAYS = 14  -- 总共可领取的天数

local NEED_GET_DAYS = 7  -- 领取完所有经验所需天数

function ExpStoreHouseDlg:init()
    self:bindListener("GetButton", self.onGetButton)
    self:bindListener("InfoButton", self.onInfoButton)

    self:setCtrlEnabled("LockButton")
    self:setCtrlEnabled("GotButton")
    self:setCtrlEnabled("StoreButton")

    self:creatCharDragonBones(ResMgr.icon.tonglingdaoren, "NPCImage")

    self:setView()

    self:hookMsg("MSG_UPDATE")
end

function ExpStoreHouseDlg:creatCharDragonBones(icon, panelName)
    local panel = self:getControl(panelName)

    local magic = panel:getChildByName("charPortrait")
    
    if magic then 
        if magic:getTag() == icon then
            -- 已经有了，不需要加载
            return
        else
            DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
        end
    end

    panel:removeAllChildren()
    
    local dbMagic = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    if not dbMagic then return end

    local magic = tolua.cast(dbMagic, "cc.Node")   
    magic:setPosition(panel:getContentSize().width * 0.5 + 16, -20)
    magic:setName("charPortrait")
    magic:setTag(icon)
    magic:setScale(0.65)
    panel:addChild(magic)

    DragonBonesMgr:toPlay(dbMagic, "stand", 0)
    self[panelName] = dbMagic
    return magic
end

function ExpStoreHouseDlg:getLockDays()
    local curTime = gf:getServerTime()
    local dTime = curTime - Me:queryBasicInt("exp_ware_data/lock_time")
    local day = math.floor(dTime / ONE_DAY)
    if not gf:isSameDay5(curTime, Me:queryBasicInt("exp_ware_data/lock_time") + day * ONE_DAY) then
        day = day + 2
    else
        day = day + 1
    end

    return day
end

function ExpStoreHouseDlg:getUnLockDays()
    local curTime = gf:getServerTime()
    local dTime = curTime - Me:queryBasicInt("exp_ware_data/unlock_time")
    local day = math.floor(dTime / ONE_DAY)
    if not gf:isSameDay5(curTime, Me:queryBasicInt("exp_ware_data/unlock_time") + day * ONE_DAY) then
        day = day + 2
    else
        day = day + 1
    end

    return day
end

function ExpStoreHouseDlg:setView()
    self:setCtrlVisible("LockButton", false)
    self:setCtrlVisible("StoreButton", false)
    self:setCtrlVisible("GotButton", false)
    self:setCtrlVisible("GetButton", false)
    -- 存储的经验
    local str = gf:getArtFontMoneyDesc(Me:queryBasicInt("exp_ware_data/exp_ware"))
    self:setLabelText("NumLabel", str, "BonusNumPanel")
    if Me:isLockExp() then
        -- 经验锁定
        local lockDays = self:getLockDays()
        local leftDays = NEED_LOCK_DAYS - lockDays
        if leftDays > 0 then
            -- 锁定中
            self:setLabelText("InfoLabel", string.format(CHS[5400641], leftDays), "ExpNumPanel")
            self:setCtrlVisible("LockButton", true)
        else
            -- 储存中
            self:setLabelText("InfoLabel", CHS[5400642], "ExpNumPanel")
            self:setCtrlVisible("StoreButton", true)
        end

        self:setCtrlVisible("GetTimesLabel", false)
    else
        -- 解锁中
        local lockDays = self:getUnLockDays()
        local leftDays = CAN_GET_DAYS - lockDays
        local leftTimes = NEED_GET_DAYS - Me:queryBasicInt("exp_ware_data/fetch_times")
        if leftDays <= 0 then
            self:setLabelText("InfoLabel", CHS[5400644], "ExpNumPanel")
        else
            self:setLabelText("InfoLabel", string.format(CHS[5400643], leftDays), "ExpNumPanel")
        end

        if Me:queryBasicInt("exp_ware_data/today_fetch_times") > 0 then
            -- 今日已领取
            self:setCtrlVisible("GotButton", true)
        else
            -- 未领取
            local str
            if leftTimes == 0 then
                str = "0"
            else
                str = gf:getArtFontMoneyDesc(math.floor(Me:queryBasicInt("exp_ware_data/exp_ware") / leftTimes))
            end

            self:setLabelText("ExpNumLabel_2", str, "GetButton")
            self:setLabelText("ExpNumLabel_1", str, "GetButton")
            self:setCtrlVisible("GetButton", true)
        end

        self:setCtrlVisible("GetTimesLabel", true)
        self:setLabelText("GetTimesLabel", string.format(CHS[5400645], leftTimes), "ButtonPanel")
    end
end

function ExpStoreHouseDlg:onGetButton(sender, eventType)
    gf:CmdToServer("CMD_EXP_WARE_FETCH", {})
end

function ExpStoreHouseDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("ExpStoreHouseRuleDlg")
end

function ExpStoreHouseDlg:MSG_UPDATE()
    self:setView()
end

function ExpStoreHouseDlg:cleanup()
    -- 如果有骨骼动画时，释放相关资源 
    local panel = self:getControl("NPCImage")
    local magic = panel:getChildByName("charPortrait")
    if magic then 
        DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))  
    end
end

return ExpStoreHouseDlg
