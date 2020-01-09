-- ArtifactInfoCampareDlg.lua
-- Created by yangym Dec/15/2016
-- 法宝对比悬浮框
local ArtifactInfoCampareDlg = Singleton("ArtifactInfoCampareDlg", Dialog)

local BTN_FUNC = {
    [CHS[3002410]] = { normalClick = "onSell" },
    [CHS[7000295]] = { normalClick = "onBaitan" },
    [CHS[7000296]] = { normalClick = "onTreasureBaitan" },
    [CHS[7000175]] = { normalClick = "onRefillNimbus"},
    [CHS[3002816]] = { normalClick = "onResource"},
}

local menuMore = {
    [1] = {},
    [2] = {},
}

local ARTIFACT_SELL_PRICE = 10000
function ArtifactInfoCampareDlg:init()
    for i = 1, 2 do
        local panel = self:getControl("MainPanel" .. i)
        panel:setTag(i)
        self:bindListener("MoreOperateButton", self.onMoreOperateButton, panel)
        self:bindListener("OperateButton", self.onOperateButton, panel)
        self:bindListener("MainPanel" .. i, self.onCloseButton, panel)
        self:bindListener("SourceButton", self.onResource, panel)
        self:bindListener("ResourceButton", self.onResource, panel)
        self:getControl("MoreOperateButton", nil, panel):setTag(i)
        self:getControl("OperateButton", nil, panel):setTag(i)
        self:getControl("SourceButton", nil, panel):setTag(i)
    end


    self.btn = self:getControl("MoreOperateButton"):clone()
    -- self.btn:setAnchorPoint(0, 0)
    self.btn:retain()

    self.btnLayer = cc.Layer:create()
    self.btnLayer:setAnchorPoint(0, 0)
    self.btnLayer:retain()

    self.mainPanel1Height = self:getControl("MainPanel1"):getContentSize().height
    self.mainPanel2Height = self:getControl("MainPanel2"):getContentSize().height
    self.descPanel1Height = self:getControl("DescPanel1"):getContentSize().height
    self.descPanel2Height = self:getControl("DescPanel2"):getContentSize().height

    self.artifact = {}
    self.isMore = nil

    self:hookMsg("MSG_INVENTORY")
end

function ArtifactInfoCampareDlg:setCompareInfo(artifact, isCard)
    local panel = self:getControl("MainPanel1")
    local artifact1 = InventoryMgr:getItemByPos(artifact.equip_type)

    menuMore[1] = self:setMenuMore(false, artifact1, panel)
    self:setBasicInfo(artifact1, panel, false)
    self.artifact[1] = artifact1

    local panel2 = self:getControl("MainPanel2")
    menuMore[2] = self:setMenuMore(isCard, artifact, panel2)
    self:setBasicInfo(artifact, panel2, isCard)
    self.artifact[2] = artifact

    local size1 = panel:getContentSize()
    local size2 = panel2:getContentSize()

    local rootSize = self.root:getContentSize()
    self.root:setContentSize(rootSize.width, math.max(size1.height, size2.height))

    self:align(ccui.RelativeAlign.centerInParent)
    self.root:requestDoLayout()
end

function ArtifactInfoCampareDlg:setBasicInfo(artifact, panel, isCard)

    -- 已装备标签
    self:setCtrlVisible("WearImage", artifact.pos and (artifact.pos <= 10), panel)

    -- 法宝图标
    self:setImage("ItemImage", InventoryMgr:getIconFileByName(artifact.name), panel)
    self:setItemImageSize("ItemImage", panel)

    -- 图标左上角等级
    self:setNumImgForPanel("ArtifactShapePanel", ART_FONT_COLOR.NORMAL_TEXT,
                           artifact.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 图标左下角限制交易/限时标记
    if artifact and InventoryMgr:isTimeLimitedItem(artifact) then
        InventoryMgr:addLogoTimeLimit(self:getControl("ItemImage", nil, panel))
    elseif artifact and InventoryMgr:isLimitedItem(artifact) then
        InventoryMgr:addLogoBinding(self:getControl("ItemImage", nil, panel))
    end

    -- 图标右下角相性标志
    if artifact.item_polar and artifact.item_polar >= 1 and artifact.item_polar <= 5 then
        InventoryMgr:addArtifactPolarImage(self:getControl("ItemImage", nil, panel), artifact.item_polar)
    end

    -- 法宝名称
    self:setLabelText("NameLabel", artifact.name, panel, COLOR3.YELLOW)

    -- 法宝类型
    self:setLabelText("CommondLabel", CHS[7000145], panel)

    -- 贵重物品
    if gf:isExpensive(artifact, false) then
        self:setCtrlVisible("PreciousImage", true, panel)
    else
        self:setCtrlVisible("PreciousImage", false, panel)
    end

    -- 道法、灵气、亲密度、金相
    local daoFa = string.format(CHS[7000190], artifact.exp or 0, artifact.exp_to_next_level or 0)
    local lingQi = string.format(CHS[7000190], artifact.nimbus or 0, Formula:getArtifactMaxNimbus(artifact.level or 0))
    local qinMiDu = artifact.intimacy or 0
    local polarAttrib = EquipmentMgr:getPolarAttribByArtifact(artifact)
    self:setLabelText("DaoFaLabel2", daoFa, panel)
    self:setLabelText("LingqiLabel2", lingQi, panel)

    -- 亲密度
    self:setLabelText("QinmiduLabel2", qinMiDu, panel)

    self:setLabelText("QinmiduInfoLabel", EquipmentMgr:getArtifactBuffPercentStr(artifact), panel)

    if artifact.isMarket or artifact.isJubao then
        self:setLabelText("QinmiduLabel2", CHS[4300225], panel)
        self:setLabelText("QinmiduInfoLabel", EquipmentMgr:getArtifactBuffPercentStr({level = artifact.level, intimacy = 0, name = artifact.name}), panel)
    elseif artifact.isGiveType then
        self:setLabelText("QinmiduLabel2", CHS[4300226], panel)
        self:setLabelText("QinmiduInfoLabel", EquipmentMgr:getArtifactBuffPercentStr({level = artifact.level, intimacy = 0, name = artifact.name}), panel)
    end

    self:setLabelText("PolarLabel2", polarAttrib, panel)
    self:setLabelText("PolarLabel1", string.format(CHS[7000183], gf:getPolar(artifact.item_polar)), panel)

    if artifact.item_polar and artifact.item_polar == 6 then
        self:setLabelText("PolarLabel1", CHS[7000192])
        self:setLabelText("PolarLabel2", CHS[7000193])
    end

    local descPanel1 = self:getControl("DescPanel1", nil, panel)
    local descPanel2 = self:getControl("DescPanel2", nil, panel)

    -- 法宝技能
    local desc1 = string.format(CHS[7000151], CHS[7000152]) .. CHS[7000078] .. EquipmentMgr:getArtifactSkillDesc(artifact.name)
    local height1 = self:setDescript(desc1, descPanel1, COLOR3.LIGHT_WHITE, panel)
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
            .. CHS[3001385].. "\n" .. CHS[7000310]
    end

    local height2 = self:setDescript(desc2, descPanel2, COLOR3.LIGHT_WHITE, panel)
    descPanel2:setContentSize(descPanel2:getContentSize().width, height2)

    -- 限制交易时间
    local bindLabel = self:getControl("BindLabel", nil, panel)
    local bindLabelHeight = bindLabel:getContentSize().height
    local height3 = - bindLabelHeight
    if InventoryMgr:isLimitedItem(artifact) then
        local str, day = gf:converToLimitedTimeDay(artifact.gift)
        self:setLabelText("BindLabel", str, panel)
        height3 = 0
    end

    -- 限时时间
    local limitTimeLabel = self:getControl("LimitTimeLabel", nil, panel)
    local limitTimeLabelHeight = limitTimeLabel:getContentSize().height
    local height4 = - bindLabelHeight
    if InventoryMgr:isTimeLimitedItem(artifact) then
        local timeLimitStr
        if artifact.isTimeLimitedReward then
            timeLimitStr = CHS[7000191]
        else
            timeLimitStr = string.format(CHS[7000184], gf:getServerDate(CHS[4200022], artifact.deadline))
        end

        self:setLabelText("LimitTimeLabel", timeLimitStr, panel)
        height4 = 0
    end


    if isCard then  -- 名片信息仅显示来源
        self:setCtrlVisible("SourceButton", true, panel)
        self:setCtrlVisible("MoreOperateButton", false, panel)
        self:setCtrlVisible("OperateButton", false, panel)
        self:setCtrlVisible("StorePanel", false, panel)
    else
        self:setCtrlVisible("SourceButton", false, panel)
        self:setCtrlVisible("MoreOperateButton", true, panel)
        self:setCtrlVisible("OperateButton", true, panel)
        self:setCtrlVisible("StorePanel", false, panel)

        if (artifact.pos <= 10) then
            self:setButtonText("OperateButton", CHS[3002420], panel)
        else
            self:setButtonText("OperateButton", CHS[3002421], panel)
        end
    end

    local tempHeight = 0
    if artifact and artifact.pos and artifact.pos <= 10 then
        -- 穿的隐藏来源和卸下
        self:setCtrlVisible("MoreOperateButton", false, panel)
        self:setCtrlVisible("OperateButton", false, panel)

        tempHeight = self:getCtrlContentSize("OperateButton", panel).height
    end

    -- 总高度自适应
    local mainPanelHeight
    if panel:getName() == "MainPanel1" then
        mainPanelHeight = self.mainPanel1Height
    elseif panel:getName() == "MainPanel2" then
        mainPanelHeight = self.mainPanel2Height
    end

    local offset = height1 - self.descPanel1Height + height2 - self.descPanel2Height + height3 + height4 - tempHeight
    panel:setContentSize(panel:getContentSize().width, mainPanelHeight + offset)
end

function ArtifactInfoCampareDlg:onMoreOperateButton(sender, eventType)
    local tag = sender:getTag()
    if not self.isMore or self.btnLayer:getTag() ~= tag then
        self.isMore = true
        self.btnLayer:removeAllChildren()
        local btnSize = self.btn:getContentSize()
        for i,v in pairs(menuMore[tag]) do
            local btn = self.btn:clone()
            btn:setTitleText(tostring(v))
            btn:setPosition(btnSize.width / 2, btnSize.height * i + btnSize.height / 2)
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
        self.btnLayer:setTag(tag)
        sender:addChild(self.btnLayer)
    else
        self.isMore = false
        self.btnLayer:removeFromParent()
    end
end

function ArtifactInfoCampareDlg:onOperateButton(sender, eventType)
    local tag = sender:getTag()

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.artifact[tag]) then
        -- 如果处于战斗中，装备的法宝即使过期也不析构
        if self.artifact[tag].pos >= 1 and self.artifact[tag].pos <= 10 and Me:isInCombat() then
            gf:ShowSmallTips(CHS[3002430])
            return
        end

        InventoryMgr:notifyItemTimeout(self.artifact[tag])
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

        EquipmentMgr:CMD_EQUIP(self.artifact[tag].pos)
    else
        EquipmentMgr:CMD_UNEQUIP(self.artifact[tag].pos)
    end

    self:onCloseButton()
end

-- 来源
function ArtifactInfoCampareDlg:onResource(sender, eventType)
    local tag = self.btnLayer:getTag()
    if tag == -1 or sender:getName() == "SourceButton" then
        tag = sender:getTag()
    end

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.artifact[tag]) then
        -- 如果处于战斗中，装备的法宝即使过期也不析构
        if self.artifact[tag].pos >= 1 and self.artifact[tag].pos <= 10 and Me:isInCombat() then
            gf:ShowSmallTips(CHS[3002430])
            return
        end

        InventoryMgr:notifyItemTimeout(self.artifact[tag])
        self:close()
        return
    end

    local artifact = self.artifact[tag]

    if not artifact then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    if #InventoryMgr:getRescourse(artifact.name) == 0 then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    local rect1 = self:getBoundingBoxInWorldSpace(self:getControl("MainPanel1"))
    local rect2 = self:getBoundingBoxInWorldSpace(self:getControl("MainPanel2"))

    if tag == 1 then
        self:getControl("MainPanel2"):setVisible(false)
        InventoryMgr:openItemRescourse(artifact.name, rect1)
    else
        self:getControl("MainPanel1"):setVisible(false)
        InventoryMgr:openItemRescourse(artifact.name, rect2)
    end
end

-- 出售
function ArtifactInfoCampareDlg:onSell(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    local tag = self.btnLayer:getTag()

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.artifact[tag]) then
        -- 如果处于战斗中，装备的法宝即使过期也不析构
        if self.artifact[tag].pos >= 1 and self.artifact[tag].pos <= 10 and Me:isInCombat() then
            gf:ShowSmallTips(CHS[3002430])
            return
        end

        InventoryMgr:notifyItemTimeout(self.artifact[tag])
        self:close()
        return
    end

    if self.artifact[tag].pos <= 10 then
        gf:ShowSmallTips(CHS[7000179])
        return
    end

    if gf:isExpensive(self.artifact[tag]) then
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
        str = string.format(CHS[6400047], value, CHS[6400050], self.artifact[tag].name)
    else
        str = string.format(CHS[6400047], value, CHS[6400049], self.artifact[tag].name)
    end

    local pos = self.artifact[tag].pos
    gf:confirm(str,
        function ()
            InventoryMgr.sellAllTipsFlag = {}
            gf:sendGeneralNotifyCmd(NOTIFY.SELL_ITEM, pos, 1)
            self:onCloseButton()
        end)
end

-- 摆摊
function ArtifactInfoCampareDlg:onBaitan(sender, eventType)
    if not DistMgr:checkCrossDist() then return end
    local tag = self.btnLayer:getTag()

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.artifact[tag]) then
        InventoryMgr:notifyItemTimeout(self.artifact[tag])
        self:close()
        return
    end

    if self.artifact[tag].pos <= 10 then
        gf:ShowSmallTips(CHS[7000180])
        return
    end

    -- 判断是否可以摆摊
    if InventoryMgr:isLimitedItem(self.artifact[tag]) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002435], MarketMgr:getOnSellLevel()))
        return
    end


    local artifact = {name = self.artifact[tag].name, bagPos = self.artifact[tag].pos, icon = self.artifact[tag].icon,
                      amount = self.artifact[tag].amount, level = self.artifact[tag].level, detail = self.artifact[tag]}
    local dlg = DlgMgr:openDlg("MarketSellDlg")
    dlg:setSelectItem(artifact.detail.pos)
    MarketMgr:openSellItemDlg(artifact.detail, 3)
    self:onCloseButton()
end

-- 珍宝摆摊
function ArtifactInfoCampareDlg:onTreasureBaitan(sender, eventType)
    if not DistMgr:checkCrossDist() then return end
    local tag = self.btnLayer:getTag()

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.artifact[tag]) then
        InventoryMgr:notifyItemTimeout(self.artifact[tag])
        self:close()
        return
    end

    if self.artifact[tag].pos <= 10 then
        gf:ShowSmallTips(CHS[7000180])
        return
    end

    -- 判断是否可以摆摊
    if InventoryMgr:isLimitedItem(self.artifact[tag]) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getGoldOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002435], MarketMgr:getGoldOnSellLevel()))
        return
    end

    local artifact = {name = self.artifact[tag].name, bagPos = self.artifact[tag].pos, icon = self.artifact[tag].icon,
        amount = self.artifact[tag].amount, level = self.artifact[tag].level, detail = self.artifact[tag]}
    local dlg = DlgMgr:openDlg("MarketGoldSellDlg")
    dlg:setSelectItem(artifact.detail.pos)
    MarketMgr:openZhenbaoSellDlg(artifact.detail)
    self:onCloseButton()
end

-- 补灵气
function ArtifactInfoCampareDlg:onRefillNimbus()
    local tag = self.btnLayer:getTag()

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.artifact[tag]) then
        -- 如果处于战斗中，装备的法宝即使过期也不析构
        if self.artifact[tag].pos >= 1 and self.artifact[tag].pos <= 10 and Me:isInCombat() then
            gf:ShowSmallTips(CHS[3002430])
            return
        end

        InventoryMgr:notifyItemTimeout(self.artifact[tag])
        self:close()
        return
    end

    if not self.artifact[tag] then
        return
    end

    local artifact = self.artifact[tag]
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

function ArtifactInfoCampareDlg:setMenuMore(isCard, artifact, panel)
    local menuTab = {}
    local isInBag = artifact.pos and InventoryMgr:isInBagByPos(artifact.pos)
    if not isCard then
        if isInBag then
            table.insert(menuTab, CHS[3002410])
            table.insert(menuTab, CHS[7000295])

            -- 贵重法宝增加珍宝摆摊选项
            if artifact and gf:isExpensive(artifact) and MarketMgr:isShowGoldMarket() then
                table.insert(menuTab, CHS[7000296])
            end
        end

        table.insert(menuTab, CHS[7000175])
        table.insert(menuTab, CHS[3002816])

        -- 创建分享按钮
        self:createShareButton(self:getControl("ShareButton", nil, panel), SHARE_FLAG.EQUIPATTRIB)
    else
        self:setCtrlVisible("ShareButton", false, panel)
    end

    return menuTab
end

function ArtifactInfoCampareDlg:setDescript(descript, panel, defaultColor, root)
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

function ArtifactInfoCampareDlg:cleanup()
    self.artifact = {}

    if self.btnLayer then
        self.btnLayer:release()
        self.btnLayer = nil
    end

    if self.btn then
        self.btn:release()
        self.btn = nil
    end
end

function ArtifactInfoCampareDlg:MSG_INVENTORY(data)
    for i = 1, data.count do
        for j = 1, #self.artifact do
            if data[i].pos == self.artifact[j].pos then
                self:onCloseButton()
                return
            end
        end
    end
end

return ArtifactInfoCampareDlg
