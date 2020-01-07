-- ArtifactInfoDlg.lua
-- Created by yangym Dec/12/2016
-- 法宝悬浮框
local ArtifactInfoDlg = Singleton("ArtifactInfoDlg", Dialog)

local BTN_FUNC = {
    [CHS[3002410]] = { normalClick = "onSell" },
    [CHS[7000295]] = { normalClick = "onBaitan" },
    [CHS[7000296]] = { normalClick = "onTreasureBaitan" },
    [CHS[7000175]] = { normalClick = "onRefillNimbus"},
    [CHS[3002816]] = { normalClick = "onResource"},
    [CHS[4010210]] = { normalClick = "onGongtong"},
}

local menuMore = {}

local ARTIFACT_SELL_PRICE = 10000

local EQUIP_ING = 9
local EQUIP_BACK = 19

function ArtifactInfoDlg:init()

    self:bindListener("MoreOperateButton", self.onMoreOperateButton)
    self:bindListener("OperateButton", self.onOperateButton)
    self:bindListener("MainPanel", self.onCloseButton)
    self:bindListener("DepositButton", self.onDepositButton)
    self:bindListener("SourceButton", self.onResource)
    self:bindListener("ResourceButton", self.onResource)

    self:getControl("MoreOperateButton"):setLocalZOrder(10)

    self.btn = self:getControl("MoreOperateButton"):clone()
    --self.btn:setAnchorPoint(0, 0)
    self.btn:retain()

    self.btnLayer = cc.Layer:create()
    self.btnLayer:setAnchorPoint(0, 0)
    self.btnLayer:retain()

    self.artifact = nil
    self.isMore = nil

    self.mainPanelHeight = self:getControl("MainPanel"):getContentSize().height
    self.descPanel1Height = self:getControl("DescPanel1"):getContentSize().height
    self.descPanel2Height = self:getControl("DescPanel2"):getContentSize().height

    self:hookMsg("MSG_INVENTORY")
end

function ArtifactInfoDlg:setBasicInfo(artifact, isCard)

    -- 保存当前法宝数据
    self.artifact = artifact

    -- 已装备标签
    self:setCtrlVisible("WearImage", artifact.pos and (artifact.pos <= 10))

    -- 法宝图标
    self:setImage("ItemImage", InventoryMgr:getIconFileByName(artifact.name))
    self:setItemImageSize("ItemImage")

    -- 图标左上角等级
    self:setNumImgForPanel("ArtifactShapePanel", ART_FONT_COLOR.NORMAL_TEXT,
                           artifact.level, false, LOCATE_POSITION.LEFT_TOP, 21)

    -- 图标左下角限制交易/限时标记
    if artifact and InventoryMgr:isTimeLimitedItem(artifact) then
        InventoryMgr:addLogoTimeLimit(self:getControl("ItemImage"))
    elseif artifact and InventoryMgr:isLimitedItem(artifact) then
        InventoryMgr:addLogoBinding(self:getControl("ItemImage"))
    end

    -- 图标右下角相性标志
    if artifact.item_polar and artifact.item_polar >= 1 and artifact.item_polar <= 5 then
        InventoryMgr:addArtifactPolarImage(self:getControl("ItemImage"), artifact.item_polar)
    end

    -- 法宝名称
    self:setLabelText("NameLabel", artifact.name, "MainPanel", COLOR3.YELLOW)

    -- 法宝类型
    self:setLabelText("CommondLabel", CHS[7000145], "MainPanel")

    -- 贵重物品
    if gf:isExpensive(artifact, false) then
        self:setCtrlVisible("PreciousImage", true)
    else
        self:setCtrlVisible("PreciousImage", false)
    end

    -- 道法、灵气、亲密度、金相
    local daoFa = string.format(CHS[7000190], artifact.exp or 0, artifact.exp_to_next_level or 0)
    local lingQi = string.format(CHS[7000190], artifact.nimbus or 0, Formula:getArtifactMaxNimbus(artifact.level or 0))
    local qinMiDu = artifact.intimacy or 0
    local polarAttrib = EquipmentMgr:getPolarAttribByArtifact(artifact)
    self:setLabelText("DaoFaLabel2", daoFa)
    self:setLabelText("LingqiLabel2", lingQi)

    self:setLabelText("QinmiduLabel2", qinMiDu)

    self:setLabelText("QinmiduInfoLabel", EquipmentMgr:getArtifactBuffPercentStr(artifact))
    if artifact.isMarket or artifact.isJubao then
        self:setLabelText("QinmiduLabel2", CHS[4300225])
        self:setLabelText("QinmiduInfoLabel", EquipmentMgr:getArtifactBuffPercentStr({level = artifact.level, intimacy = 0, name = artifact.name}))
    elseif artifact.isGiveType then
        self:setLabelText("QinmiduInfoLabel", EquipmentMgr:getArtifactBuffPercentStr({level = artifact.level, intimacy = 0, name = artifact.name}))

        self:setLabelText("QinmiduLabel2", CHS[4300226])
    end

    self:setLabelText("PolarLabel2", polarAttrib)
self:setLabelText("PolarLabel1", string.format(CHS[7000183], gf:getPolar(artifact.item_polar)))

    if artifact.item_polar and artifact.item_polar == 6 then
        self:setLabelText("PolarLabel1", CHS[7000192])
        self:setLabelText("PolarLabel2", CHS[7000193])
    end

    -- 法宝技能
    local descPanel1 = self:getControl("DescPanel1")
    local descPanel2 = self:getControl("DescPanel2")

    local desc1 = string.format(CHS[7000151], CHS[7000152]) .. CHS[7000078] .. (EquipmentMgr:getArtifactSkillDesc(artifact.name) or CHS[3001385])
    local height1 = self:setDescript(desc1, descPanel1, COLOR3.LIGHT_WHITE)
    descPanel1:setContentSize(descPanel1:getContentSize().width, height1)

    -- 特殊技能
    local desc2
    if artifact.extra_skill and artifact.extra_skill ~= "" then
        local extraSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
        local extraSkillLevel = artifact.extra_skill_level
        local extraSkillDesc = SkillMgr:getSkillDesc(extraSkillName).desc
        desc2 = string.format(CHS[7000311], extraSkillName, extraSkillLevel)
                           .. CHS[7000078] .. extraSkillDesc
    else
        desc2 = string.format(CHS[7000151], CHS[7000153]) .. CHS[7000078]
                           .. CHS[3001385] .. "\n" .. CHS[7000310]
    end

    local height2 = self:setDescript(desc2, descPanel2, COLOR3.LIGHT_WHITE)
    descPanel2:setContentSize(descPanel2:getContentSize().width, height2)

    -- 限制交易时间
    local bindLabel = self:getControl("BindLabel")
    local bindLabelHeight = bindLabel:getContentSize().height
    local height3 = - bindLabelHeight
    if InventoryMgr:isLimitedItem(artifact) then
        local str, day = gf:converToLimitedTimeDay(artifact.gift)
        self:setLabelText("BindLabel", str)
        height3 = 0
    end

    -- 限时时间
    local limitTimeLabel = self:getControl("LimitTimeLabel")
    local limitTimeLabelHeight = limitTimeLabel:getContentSize().height
    local height4 = - bindLabelHeight
    if InventoryMgr:isTimeLimitedItem(artifact) then
        local timeLimitStr
        if artifact.isTimeLimitedReward then
            timeLimitStr = CHS[7000191]
        else
            timeLimitStr = string.format(CHS[7000184], gf:getServerDate(CHS[4200022], artifact.deadline))
        end

        self:setLabelText("LimitTimeLabel", timeLimitStr)
        height4 = 0
    end

    -- 总高度自适应
    local offset = height1 - self.descPanel1Height + height2 - self.descPanel2Height + height3 + height4
    local mainPanel = self:getControl("MainPanel")
    mainPanel:setContentSize(mainPanel:getContentSize().width, self.mainPanelHeight + offset)
    self:updateLayout("MainPanel")

    if isCard then  -- 名片信息仅显示来源
        self:setCtrlVisible("SourceButton", true)
        self:setCtrlVisible("MoreOperateButton", false)
        self:setCtrlVisible("OperateButton", false)
        self:setCtrlVisible("StorePanel", false)
    else
        self:setCtrlVisible("SourceButton", false)
        self:setCtrlVisible("MoreOperateButton", true)
        self:setCtrlVisible("OperateButton", true)
        self:setCtrlVisible("StorePanel", false)

        if (artifact.pos <= EQUIP.BACK_ARTIFACT) then
            self:setButtonText("OperateButton", CHS[3002420])
        else
            self:setButtonText("OperateButton", CHS[3002421])
        end
    end

    menuMore = self:setMenuMore(isCard, artifact)
end

function ArtifactInfoDlg:onMoreOperateButton(sender, eventType)
    if not self.isMore then
        self.isMore = true
        local btnSize = self.btn:getContentSize()
        for i,v in pairs(menuMore) do
            local btn = self.btn:clone()
            btn:setTitleText(tostring(v))
            btn:setPosition(0 + btnSize.width / 2, btnSize.height * i + btnSize.height / 2)
            btn:setVisible(true)
            self.btnLayer:addChild(btn)

            self:bindTouchEndEventListener(btn, function(self, sender, eventType)
                local title = sender:getTitleText()
                if BTN_FUNC[title].normalClick and "function" == type(self[BTN_FUNC[title].normalClick]) then
                    self[BTN_FUNC[title].normalClick](self, sender, eventType)
                end
            end)
        end
        self.btnLayer:setPosition(0, 0)
        self.btnLayer:removeFromParent()
        sender:addChild(self.btnLayer)
    else
        self.isMore = false
        self.btnLayer:removeFromParent()
    end
end

function ArtifactInfoDlg:onOperateButton(sender, eventType)
    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.artifact) then
        -- 如果处于战斗中，装备的法宝即使过期也不析构
        if self.artifact.pos >= 1 and self.artifact.pos <= EQUIP.BACK_ARTIFACT and Me:isInCombat() then
            gf:ShowSmallTips(CHS[3002430])
            return
        end

        InventoryMgr:notifyItemTimeout(self.artifact)
        self:close()
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002430])
        return
    end

    local str = sender:getTitleText()
    if str == CHS[3002431] or str == CHS[3002421] then
        if Me:queryBasicInt("level") < Const.ARTIFACT_EQUIPPED_MIN_LEVEL then
            gf:ShowSmallTips(string.format(CHS[7000178], Const.ARTIFACT_EQUIPPED_MIN_LEVEL))
            return
        end

        EquipmentMgr:CMD_EQUIP(self.artifact.pos)
    else
        EquipmentMgr:CMD_UNEQUIP(self.artifact.pos)
    end

    self:onCloseButton()
end

-- 存入/取出
function ArtifactInfoDlg:onDepositButton(sender, eventType)
    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.artifact) then
        -- 如果处于战斗中，装备的法宝即使过期也不析构
        if self.artifact.pos >= 1 and self.artifact.pos <= EQUIP.BACK_ARTIFACT and Me:isInCombat() then
            gf:ShowSmallTips(CHS[3002430])
            return
        end

        InventoryMgr:notifyItemTimeout(self.artifact)
        self:close()
        return
    end

    local str = self:getLabelText("Label_16", sender)
    if str == CHS[4300070] then
        StoreMgr:cmdBagToStore(self.artifact.pos)
    else
        StoreMgr:cmdStoreToBag(self.artifact.pos)
    end
    self:onCloseButton()
end

-- 法宝共通
function ArtifactInfoDlg:onGongtong(sender, eventType)
    local artifact1 = InventoryMgr:getItemByPos(EQUIP_ING)
    local artifact2 = InventoryMgr:getItemByPos(EQUIP_BACK)

    local str = (Me:queryBasicInt("equip_page") + 1) == 1 and gf:changeNumber(2) or gf:changeNumber(1)

    if not artifact2 then
        gf:ShowSmallTips(string.format(CHS[4010211],  str))
        return
    end

    if InventoryMgr:isTimeLimitedItem(artifact1) or InventoryMgr:isTimeLimitedItem(artifact2) then
        gf:ShowSmallTips(CHS[4101206])
        return true
    end


    DlgMgr:openDlg("FaBaoChangeDlg")
end

-- 来源
function ArtifactInfoDlg:onResource(sender, eventType)
    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.artifact) then
        -- 如果处于战斗中，装备的法宝即使过期也不析构
        if self.artifact.pos >= 1 and self.artifact.pos <= EQUIP.BACK_ARTIFACT and Me:isInCombat() then
            gf:ShowSmallTips(CHS[3002430])
            return
        end

        InventoryMgr:notifyItemTimeout(self.artifact)
        self:close()
        return
    end

    if not self.artifact then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    if #InventoryMgr:getRescourse(self.artifact.name) == 0 then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    local rect = self:getBoundingBoxInWorldSpace(self:getControl("MainPanel"))
    InventoryMgr:openItemRescourse(self.artifact.name, rect)
end

-- 出售
function ArtifactInfoDlg:onSell(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.artifact) then
        -- 如果处于战斗中，装备的法宝即使过期也不析构
        if self.artifact.pos >= 1 and self.artifact.pos <= EQUIP.BACK_ARTIFACT and Me:isInCombat() then
            gf:ShowSmallTips(CHS[3002430])
            return
        end

        InventoryMgr:notifyItemTimeout(self.artifact)
        self:close()
        return
    end

    if self.artifact.pos <= EQUIP.BACK_ARTIFACT then
        gf:ShowSmallTips(CHS[7000179])
        return
    end

    if gf:isExpensive(self.artifact) then
        gf:ShowSmallTips(CHS[5420155])
        ChatMgr:sendMiscMsg(CHS[5420155])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onSell") then
        return
    end

    local value = gf:getMoneyDesc(ARTIFACT_SELL_PRICE)
    local str = ""

    if InventoryMgr:isLimitedItem(self.artifact) then
        str = string.format(CHS[6400047], value, CHS[6400050], self.artifact.name)
    else
        str = string.format(CHS[6400047], value, CHS[6400049], self.artifact.name)
    end

    local pos = self.artifact.pos
    gf:confirm(str,
        function ()
            InventoryMgr.sellAllTipsFlag = {}
            gf:sendGeneralNotifyCmd(NOTIFY.SELL_ITEM, pos, 1)
            self:onCloseButton()
        end)
end

-- 摆摊
function ArtifactInfoDlg:onBaitan(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.artifact) then
        InventoryMgr:notifyItemTimeout(self.artifact)
        self:close()
        return
    end

    if self.artifact.pos <= EQUIP.BACK_ARTIFACT then
        gf:ShowSmallTips(CHS[7000180])
        return
    end

    -- 判断是否可以摆摊
    if InventoryMgr:isLimitedItem(self.artifact) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002435], MarketMgr:getOnSellLevel()))
        return
    end


    local artifact = {name = self.artifact.name, bagPos = self.artifact.pos, icon = self.artifact.icon, amount = self.artifact.amount, level = self.artifact.level, detail = self.artifact}
    local dlg = DlgMgr:openDlg("MarketSellDlg")
    dlg:setSelectItem(artifact.detail.pos)
    MarketMgr:openSellItemDlg(artifact.detail, 3)
    self:onCloseButton()
end

function ArtifactInfoDlg:onTreasureBaitan()
    if not DistMgr:checkCrossDist() then return end

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.artifact) then
        InventoryMgr:notifyItemTimeout(self.artifact)
        self:close()
        return
    end

    if self.artifact.pos <= EQUIP.BACK_ARTIFACT then
        gf:ShowSmallTips(CHS[7000180])
        return
    end

    -- 判断是否可以摆摊
    if InventoryMgr:isLimitedItem(self.artifact) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getGoldOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002435], MarketMgr:getGoldOnSellLevel()))
        return
    end


    local artifact = {name = self.artifact.name, bagPos = self.artifact.pos, icon = self.artifact.icon, amount = self.artifact.amount, level = self.artifact.level, detail = self.artifact}
    local dlg = DlgMgr:openDlg("MarketGoldSellDlg")
    dlg:setSelectItem(artifact.detail.pos)

    MarketMgr:openZhenbaoSellDlg(artifact.detail)
    self:onCloseButton()
end

-- 补灵气
function ArtifactInfoDlg:onRefillNimbus()
    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.artifact) then
        -- 如果处于战斗中，装备的法宝即使过期也不析构
        if self.artifact.pos >= 1 and self.artifact.pos <= EQUIP.BACK_ARTIFACT and Me:isInCombat() then
            gf:ShowSmallTips(CHS[3002430])
            return
        end

        InventoryMgr:notifyItemTimeout(self.artifact)
        self:close()
        return
    end

    if not self.artifact then
        return
    end

    local artifact = self.artifact
    local maxNimbus = Formula:getArtifactMaxNimbus(artifact.level)

    if artifact.nimbus >= maxNimbus then
        gf:ShowSmallTips(CHS[7000181])
        return
    end

    local money = (maxNimbus - artifact.nimbus) * 100
    local moneyStr = gf:getMoneyDesc(money)
    local str = string.format(CHS[7000194], moneyStr)

    gf:confirm(str,
        function ()
            local cash = math.max(Me:queryBasicInt("cash"), 0)
            local voucher = math.max(Me:queryBasicInt("voucher"), 0)
            if cash + voucher < money then
                gf:askUserWhetherBuyCash(money - cash - voucher)
            else
                gf:CmdToServer("CMD_REFILL_ARTIFACT_NIMBUS", {id = artifact.item_unique})
            end
            self:onCloseButton()
        end)
end

-- 仓库显示存入/取出格式
function ArtifactInfoDlg:setStoreDisplayType()
    if not self.artifact then
        return
    end

    if self.artifact.pos < 200 then
        self:setLabelText("Label_16", CHS[4300070], "DepositButton")
    else
        self:setLabelText("Label_16", CHS[4300071], "DepositButton")
    end

    self:setCtrlVisible("StorePanel", true)
    self:setCtrlVisible("OperateButton", false)
    self:setCtrlVisible("MoreOperateButton", false)
    self:setCtrlVisible("SourceButton", false)
end

function ArtifactInfoDlg:setMenuMore(isCard, artifact)
    local menuTab = {}
    local isInBag = artifact.pos and InventoryMgr:isInBagByPos(artifact.pos)
    if not isCard then
        if isInBag then
            table.insert(menuTab, CHS[3002410])
            table.insert(menuTab, CHS[7000295])

            -- 贵重法宝增加珍宝摆摊选项
            if self.artifact and gf:isExpensive(self.artifact) and MarketMgr:isShowGoldMarket() then
                table.insert(menuTab, CHS[7000296])
            end
        end

        table.insert(menuTab, CHS[7000175])     -- 补灵气
        local artifact1 = InventoryMgr:getItemByPos(EQUIP_ING)
        local artifact2 = InventoryMgr:getItemByPos(EQUIP_BACK)

        if not isInBag and artifact1 then
            table.insert(menuTab, CHS[4010210])
        end

        table.insert(menuTab, CHS[3002816])     -- 来源

        -- 创建分享按钮
        self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.EQUIPATTRIB)
    else
        self:setCtrlVisible("ShareButton", false)
    end

    return menuTab
end

function ArtifactInfoDlg:setDescript(descript, panel, defaultColor)
    panel:removeAllChildren()
    local textCtrl = CGAColorTextList:create()
    if defaultColor then
        textCtrl:setDefaultColor(defaultColor.r, defaultColor.g, defaultColor.b)
    end
    textCtrl:setFontSize(19)
    textCtrl:setString(descript)
    textCtrl:setContentSize(panel:getContentSize().width, 0)
    textCtrl:updateNow()

    -- 垂直方向居左显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition(0, textH)

    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    return textH
end

function ArtifactInfoDlg:cleanup()
    self.artifact = nil

    if self.btnLayer then
        self.btnLayer:release()
        self.btnLayer = nil
    end

    if self.btn then
        self.btn:release()
        self.btn = nil
    end
end

function ArtifactInfoDlg:MSG_INVENTORY(data)
    for i = 1, data.count do
        if not self.artifact or data[i].pos == self.artifact.pos then
            self:onCloseButton()
            return
        end
    end
end

return ArtifactInfoDlg
