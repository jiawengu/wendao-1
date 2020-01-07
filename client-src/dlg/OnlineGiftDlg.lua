-- OnlineGiftDlg.lua
-- Created by zhengjh Apr/15/2015
-- 神秘大礼

local OnlineGiftDlg = Singleton("OnlineGiftDlg", Dialog)

local RewardStep =
{
    start = 1,
    rewardEnd = 2,
    close = 3,
}

local EGG_STATE = {
    NOMOR           =   1,  --  正常的蛋
    CAN_GET         =   2,  --  可以砸的蛋
    GOT             =   3,  --  已砸开的蛋
}

local REWARD_ICON =
{
        [CHS[3003157]] = ResMgr.ui["experience"],
        [CHS[3003158]] = ResMgr.ui["daohang"],
        [CHS[3003159]] = ResMgr.ui["pot_icon"],
        [CHS[3003160]] = ResMgr.ui["big_yinyuanbao"],
        [CHS[3003161]] = ResMgr.ui["experience"],
        [CHS[3003162]] = ResMgr.ui["daohang"],
        [CHS[3003163]] = ResMgr.ui["pot_icon"],
        [CHS[3003164]] = ResMgr.ui["big_yinyuanbao"],
        [CHS[3003165]] = ResMgr.ui["experience"],
        [CHS[3003166]] = ResMgr.ui["daohang"],
        [CHS[3003167]] = ResMgr.ui["pot_icon"],
        [CHS[3003168]] = ResMgr.ui["big_yinyuanbao"],
}

function OnlineGiftDlg:init()
    self:bindListener("DrawButton", self.onDrawButton)
    for i = 1, 8 do
        self:bindListener("EggPanel" .. i, self.onKnockEggButtom)
    end
    
    self.eggPanel = self:retainCtrl("ShowPanel")
    self:setCtrlVisible("BreakenPanel", false, self.eggPanel)
    self:setCtrlVisible("Completemage", true, self.eggPanel)
    self:setCtrlVisible("DrawButton", false)

    self.isInited = false
    self.data = nil
    self.playing = false

    GiftMgr:queryOnlineGiftEggData()

    self:hookMsg("MSG_AWARD_OPEN")
    self:hookMsg("MSG_SHENMI_DALI_OPEN")
    self:hookMsg("MSG_SHENMI_DALI_PICK")
    GiftMgr.lastIndex = "WelfareButton1"
    GiftMgr:setLastTime()

end

function OnlineGiftDlg:initEggs()
    if self.isInited then return end
    self.isInited = true
    for i = 1, 8 do
        local panel = self:getControl("EggPanel" .. i)
        local eggPanel = self.eggPanel:clone()
        panel:addChild(eggPanel)
    end

    self:setCtrlVisible("DrawButton", true)
end

function OnlineGiftDlg:beginningBreakEgg(data)
    if not self.isInited then return end
    local function eggCallBall(dlg, effPanel)    
        effPanel:removeAllChildren()
        local panel = effPanel:getParent()        
        self:setCtrlVisible("Imageweiza", false, panel)
        self.playing = false
        local name = data.name
        if data.brate > 1 then
            name = data.brate .. CHS[4200470] .. " " .. name
        end
        self:setLabelText("TextLabel", name, panel)

        GiftMgr:queryOnlineGiftEggData()
    end

    self.playing = true
    local key = data.index
    local numPanel = self:getControl("EggPanel" .. key)
    local effPanel = self:getControl("BottomEffectPanel", nil, numPanel)
    if not effPanel then
        -- WDSY-26221存在MSG_SHENMI_DALI_OPEN数据还没有回来，玩家就点击了全部砸开的情况，此时不处理后续逻辑即可
        return
    end

    effPanel:removeAllChildren()
    
    local topEffPanel = self:getControl("TopeffectPanel", nil, numPanel)
    local magic5 = topEffPanel:getChildByName("Bottom05")
    if magic5 then
         magic5:removeFromParent()
    end

    self:setCtrlVisible("BreakenPanel", true, numPanel)
    -- 奖励
    local imgPath = REWARD_ICON[data.name]
    if imgPath then
        self:setImagePlist("ItemImage", imgPath, numPanel)
    end 

    self:getControl("ShowPanel", nil, numPanel).isKnocked = true
    self:setCtrlVisible("Completemage", false, numPanel)
    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.online_gift_egg.name, "Bottom01", effPanel, eggCallBall, self, effPanel)

    local topEffPanel = self:getControl("TopeffectPanel", nil, numPanel)
    if data.brate == 3 then
        gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.online_gift_egg.name, "Bottom04", topEffPanel)
    elseif data.brate == 10 then
        gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.online_gift_egg.name, "Bottom03", topEffPanel)
    end
end


function OnlineGiftDlg:onKnockEggButtom(sender, eventType)
    local panel = self:getControl("ShowPanel", nil, sender)
    if not panel or panel.isKnocked then return end
    
    --self:beginningBreakEgg(1)
    gf:CmdToServer("CMD_SHENMI_DALI_PICK", {index = panel:getTag()})
end

function OnlineGiftDlg:onDrawButton(sender, eventType)
    if not self.isInited then return end
    if self.playing then return end
    gf:CmdToServer("CMD_SHENMI_DALI_PICK", {index = 0})
end


function OnlineGiftDlg:MSG_SHENMI_DALI_OPEN(data)
    self.data = nil
    self:initEggs()

    self:updateEggs(data)
end

function OnlineGiftDlg:MSG_SHENMI_DALI_PICK(data)
    if data.result == 0 then
        
        self:beginningBreakEgg(data)
    end
end

function OnlineGiftDlg:onUpdate()
    if self.data then 
        self:updateEggs(self.data)
    end
end


function OnlineGiftDlg:updateEggs(data)
    if not self.data then
        self.timeTag = gf:getServerTime()
    end
    self.data = data
    local isFirst = true
    local canKnock = 0    
    
    for i = 1, 8 do
        local eggPanel = self:getControl("ShowPanel", nil, "EggPanel" .. i)
        eggPanel:setTag(i)
        if not eggPanel.isKnocked then
            if data[i].name == "" then
                -- 没有砸过
                canKnock = canKnock + 1
                self:setCtrlVisible("Completemage", true, eggPanel)
                if data[i].time <= data.online_time then
                    -- 可以砸
                    local effPanel = self:getControl("BottomEffectPanel", nil, eggPanel)
                    local magic = effPanel:getChildByName("Bottom02")
                    if not magic then
                        gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.online_gift_egg.name, "Bottom02", effPanel)
                    end
                    
                    local topEffPanel = self:getControl("TopeffectPanel", nil, eggPanel)
                    local magic5 = topEffPanel:getChildByName("Bottom05")
                    if not magic5 then
                        gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.online_gift_egg.name, "Bottom05", topEffPanel)
                    end
                    
                    self:setLabelText("TextLabel", CHS[4200471], eggPanel)
                    eggPanel.state = EGG_STATE.CAN_GET
                else
                    if isFirst then
                        isFirst = false
                        local leftTime = data[i].time - data.online_time - (gf:getServerTime() - self.timeTag)
                        if leftTime <= 0 then
                            leftTime = 0
                            GiftMgr:queryOnlineGiftEggData()
                        end
                        self:setLabelText("TextLabel", string.format("%02d:%02d", math.floor(leftTime / 60), leftTime % 60), eggPanel)
                    else
                        self:setLabelText("TextLabel", "", eggPanel)
                    end            
                    
                    eggPanel.state = EGG_STATE.NOMOR
                end
            elseif data[i].name == CHS[4200472] then
                -- 内测区更新可能会出现
                eggPanel.isKnocked = true -- 开启以后不必刷新
                self:setCtrlVisible("Completemage", false, eggPanel)
                
                self:setLabelText("TextLabel", "", eggPanel)

                self:setCtrlVisible("ItemImage", false, eggPanel)
                self:setCtrlVisible("BreakenPanel", true, eggPanel)
                eggPanel.state = EGG_STATE.GOT
            else
                -- 开启
                eggPanel.isKnocked = true -- 开启以后不必刷新
                self:setCtrlVisible("Completemage", false, eggPanel)
                local name = data[i].name
                if data[i].brate > 1 then
                    name = data[i].brate .. CHS[4200470] .. " " .. name
                end
                self:setLabelText("TextLabel", name, eggPanel)
    
                local imgPath = REWARD_ICON[data[i].name]
                if imgPath then
                    self:setImagePlist("ItemImage", imgPath, eggPanel)
                end 
                self:setCtrlVisible("BreakenPanel", true, eggPanel)
                eggPanel.state = EGG_STATE.GOT
            end
        end
    end
    
    if canKnock == 0 then
        self:setLabelText("TimesLabel", CHS[6000173], "TimesPanel")
    else
        self:setLabelText("TimesLabel", string.format(CHS[6000174], canKnock), "TimesPanel")
    end
end

return OnlineGiftDlg
