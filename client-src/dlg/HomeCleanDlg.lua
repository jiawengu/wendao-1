-- HomeCleanDlg.lua
-- Created by songcw July/19/2017
-- 居所-清理界面

local HomeCleanDlg = Singleton("HomeCleanDlg", Dialog)

function HomeCleanDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("CleanButton", self.onCleanButton)

    self:setDlg()
    
    self:hookMsg("MSG_HOUSE_DATA")
    self:hookMsg("MSG_UPDATE")
end

function HomeCleanDlg:setDlg()

    -- 拥有的
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("GoldValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23)
    
    -- 消耗的    
    local costCash =  HomeMgr:getCleanCost(HomeMgr:getClean(), HomeMgr:getMaxClean())
    local cashText, fontColor = gf:getArtFontMoneyDesc(costCash)
    self:setNumImgForPanel("CostPanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23)
end

function HomeCleanDlg:MSG_UPDATE()
    self:setDlg()
end

function HomeCleanDlg:MSG_HOUSE_DATA()
    self:setDlg()
end

function HomeCleanDlg:onBuyButton(sender, eventType)
    if HomeMgr:getClean() == HomeMgr:getMaxClean() then
        -- 当前清洁度已满，无需清洁了。
        gf:ShowSmallTips(CHS[7002347])
        return
    end
    
    gf:CmdToServer("CMD_HOUSE_CLEAN")    
end

function HomeCleanDlg:onCleanButton(sender, eventType)

    if HomeMgr:getClean() == HomeMgr:getMaxClean() then
        -- 当前清洁度已满，无需清洁了。
        gf:ShowSmallTips(CHS[7002347])
        return
    end
    
    if Me:queryBasic("party/name") == "" then
        gf:ShowSmallTips(CHS[4200412])
        return
    end

    if not self:isOutLimitTime("lastTime", 30 * 1000) then
        gf:ShowSmallTips(CHS[4200413])
        return
    end

    self:setLastOperTime("lastTime", gfGetTickCount())

    -- 打开帮派
    DlgMgr:openDlgWithParam("ChannelDlg=5")    
    local strChs = CHS[4200414]
    local sendInfo = string.format("{\t%s=%s=%s}", Me:queryBasic("house/id"), CHS[2100095],  Me:getId())
    local key = strChs .. sendInfo
    local data = {}
    data["channel"] = CHAT_CHANNEL.PARTY
    data["compress"] = 0
    data["orgLength"] = string.len(key)
    data["msg"] = key
    data["voiceTime"] = 0
    data["token"] = ""

    -- 名片处理
    local param = string.match(data["msg"], "{\t..-=(..-=..-)}")
    if param then
        data["cardCount"] = 1
        data["cardParam"] = param
    end


    ChatMgr:sendMessage(data)
    self:onCloseButton()
    DlgMgr:closeDlg("HomeTakeCareDlg")

end

return HomeCleanDlg
