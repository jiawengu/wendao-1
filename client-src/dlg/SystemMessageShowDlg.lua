-- SystemMessageShowDlg.lua
-- Created by liuhb Mar/02/2015
-- 系统消息显示界面

local SystemMessageShowDlg = Singleton("SystemMessageShowDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

local rewardContainer = nil

function SystemMessageShowDlg:init()
    self:bindListener("GetButton", self.onGetButton)
    self:bindListener("DelButton", self.onDelButton)
    self:bindListener("GotoButton", self.onGotoButton)
    self:bindListener("SubmitButton", self.onSubmitButton)

    self:hookMsg("MSG_MAILBOX_REFRESH")
    local size = self.root:getContentSize()
    rewardContainer = nil
    self.rawHeight = size.height
    --local winSize = cc.Director:getInstance():getWinSize()
    local winSize = self:getWinSize()
    self.heightScale = winSize.height / Const.UI_SCALE / self.rawHeight
    self.root:setContentSize(size.width, self.rawHeight * self.heightScale)
    self:adjustSize()

    self.isCanAutoWalk = false
    self.listViewSize = self:getControl("ListView"):getContentSize()



    self:hookMsg("MSG_MAIL_NOT_EXIST")
    self:hookMsg("MSG_LOGIN_DONE")
    self:hookMsg("MSG_SWITCH_SERVER")
    self:hookMsg("MSG_SWITCH_SERVER_EX")
    self:hookMsg("MSG_SPECIAL_SWITCH_SERVER")
    self:hookMsg("MSG_SPECIAL_SWITCH_SERVER_EX")
end

function SystemMessageShowDlg:adjustSize()

    self:adjustSizebyControlName("MessagePanel")
    self:adjustSizebyControlName("BKImage")
    self:adjustSizebyControlName("ContentPanel")
    self:adjustSizebyControlName("ListView")
end

function SystemMessageShowDlg:adjustSizebyControlName(name)
    local panel = self:getControl(name)
    local panelSize = panel:getContentSize()
    local tmpH = self.rawHeight - panelSize.height
    panel:setContentSize(panelSize.width, self.rawHeight * self.heightScale - tmpH)
end

function SystemMessageShowDlg:cleanup()
end

function SystemMessageShowDlg:setShowInfo(info)
	-- 获取消息
    if not info or not info.index then return end
	self.curMsgIndex = info.index
	local friendDlg = DlgMgr:getDlgByName("FriendDlg")
    local msg = friendDlg.systemMessageDlg:getItemByIndex(info.index)
    if not msg then return end

    self.curMsgId = msg.id
    info.id = msg.id

    -- 给列表发送切换消息
    DlgMgr:sendMsg("FriendDlg", "setSysMsgSelect", info)

    -- 根据没有附件来设置listview大小
    if string.match(msg.msg, "{\\9") then
        -- 名片格式转义下
        msg.msg = string.gsub(msg.msg, "{\\9", "{\9")
    end
    self:setUiInfo(msg)

    local showMsg = msg.msg
    if msg.name and string.match(msg.name, CHS[7003087]) then
        -- 如果是帮派公告，屏蔽部分颜色字符串
        showMsg = gf:filterPlayerColorText(msg.msg)
    end

    -- 更新消息
    local list, size =  self:resetListView("ListView", 0)
    local textCtrl = CGAColorTextList:create(true)
    self.textCtrl = textCtrl
    textCtrl:setFontSize(20)
    textCtrl:setString(showMsg)
    textCtrl:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    textCtrl:setContentSize(size.width, 0)
    textCtrl:updateNow()

    local textW, textH = textCtrl:getRealSize()
    local layer = tolua.cast(textCtrl, "cc.LayerColor")
    local itemPanel = ccui.Layout:create()
    layer:setAnchorPoint(0, 0)
    itemPanel:setContentSize(math.max(textW, size.width), textH)
    itemPanel:addChild(layer)
    list:addChild(itemPanel)
    list:setContentSize(math.max(textW, size.width), size.height)
    list:setInnerContainerSize({width = math.max(textW, size.width), height = textH})
    list:requestDoLayout()

    self:updateLayout("ContentPanel")

    local function ctrlTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 处理类型点击
            self:goToButton(textCtrl, sender)
        end
    end

    local csType = textCtrl:getCsType()
    if csType == CONST_DATA.CS_TYPE_ZOOM or csType == CONST_DATA.CS_TYPE_NPC or csType == CONST_DATA.CS_TYPE_DLG
        or csType == CONST_DATA.CS_TYPE_URL or csType == CONST_DATA.CS_TYPE_CARD
        or SystemMessageMgr:isCommunityJump(msg.attachment) then
        self.isCanAutoWalk = true
    else
        self.isCanAutoWalk = false
    end

    itemPanel:setTouchEnabled(true)
    itemPanel:addTouchEventListener(ctrlTouch)

    -- 设置标题名称
    self:setLabelText("TitleLabel", msg.name)

    -- 设置按钮状态
    self:refreshButton(msg)

    -- 如果为未阅读，向服务器发送阅读消息
    if SystemMessageMgr.SYSMSG_STATUS.UNREAD == msg.status then
        if not SystemMessageMgr:readMsg(msg.id) then
            -- 客户端自动消息会因为断线重连或切入后台等原因被清除，此处在管理器没有处理的情况下直接模拟
                AutoMsgMgr:readSysMail(msg)
            end
        end

    -- 奖励 add by zhengjh
    local accListPanel = self:getControl("AccListPanel", Const.UIPanel)
    accListPanel:removeAllChildren(true)
    rewardContainer  = RewardContainer.new(msg.attachment, accListPanel:getContentSize(), nil, nil, true)
    rewardContainer:setAnchorPoint(0, 0.5)
    rewardContainer:setPosition(0, accListPanel:getContentSize().height / 2)
    if not SystemMessageMgr:notGetAcc(msg.id) then
        rewardContainer:grayAllReward()
    end

    accListPanel:addChild(rewardContainer)

    self:updateUI()
end

function SystemMessageShowDlg:getMessageId()
    return self.curMsgId
end

function SystemMessageShowDlg:updateUI()
end

-- 领取的物品是否是血精
function SystemMessageShowDlg:getBossXueJingTips(str)
    local itemTab = {}

    if string.match(str, CHS[4100951]) then
        table.insert(itemTab, CHS[4100951])
    end

    if string.match(str, CHS[4100952]) then
        table.insert(itemTab, CHS[4100952])
    end

    if string.match(str, CHS[4100953]) then
        table.insert(itemTab, CHS[4100953])
    end

    if string.match(str, CHS[4100954]) then
        table.insert(itemTab, CHS[4100954])
    end

    local itemStr = ""

    if  #itemTab > 0 then
        local itemReward = TaskMgr:getRewardList(str)[1]
        for i, rew in pairs(itemReward) do
            local info = TaskMgr:spliteItemInfo(rew)
            local amount = InventoryMgr:getAmountByName(itemTab[i])
            if not info.number then info.number = 1 end
            if tonumber(info.number) + amount > 10 then
                if itemStr == "" then
                    itemStr = "#R" .. itemTab[i] .. "#n"
                else
                    itemStr = itemStr .. "、#R" .. itemTab[i] .. "#n"
                end
            end
        end
    end

    return itemStr
end

function SystemMessageShowDlg:onGetButton(sender, eventType)
    if not self.curMsgId then return end
    local msg = SystemMessageMgr:getSystemMessageById(self.curMsgId)
    if msg then
        if SystemMessageMgr.SYSMSG_STATUS.GET ~= msg.status
        and (not SystemMessageMgr:isAttachmentEmpty(msg.attachment)) then
            -- 处于禁闭状态
            if Me:isInJail() then
                gf:ShowSmallTips(CHS[6000214])
                return
            end

            -- 如果过期直接删除
            if SystemMessageMgr:isOverdue(self.curMsgId) then
                SystemMessageMgr:deleteOneMail(self.curMsgId)
                self:updateSystemMessageDlg()
                gf:ShowSmallTips(CHS[3003698])
            else
                if GameMgr.inCombat and self:getCombatTip(msg.attachment) then
                    gf:ShowSmallTips(self:getCombatTip(msg.attachment))
                    return
                end

                if Me:queryBasic("party/name") == "" and self:getPartyTip(msg.attachment) then -- 没有帮派  ，并且有帮贡或帮派活力值
                    gf:ShowSmallTips(string.format(CHS[6400031], self:getPartyTip(msg.attachment)))
                    return
                end

                local tips = SystemMessageMgr:getRewardTips(msg.attachment) or {}

                local tip = self:getWuxuAndExpTip(msg.attachment)
                if tip then
                    -- 没有参战宠物，并且有武学或者经验奖励
                    local fightPet = PetMgr:getFightPet()
                    if not fightPet then
                        table.insert(tips, string.format(CHS[6400030], tip))
                    end
                end

                if SystemMessageMgr:isHaveRewardByName(CHS[7000282], msg.attachment) then
                    -- 没有装备法宝，但有道法奖励
                    local artifact = EquipmentMgr:getCanGetDaofaArtifact()
                    if not artifact then
                        table.insert(tips, CHS[7000297])
                    elseif InventoryMgr:isTimeLimitedItem(artifact) then
                        table.insert(tips, CHS[5450330])
                    end
                end

                local tip = self:getFriendShipTips(msg.attachment)
                if not string.isNilOrEmpty(tip) then
                    -- 如果是好友度并且你们不是好友
                    table.insert(tips, tip)
                end

                local tip = self:getBossXueJingTips(msg.attachment)
                if not string.isNilOrEmpty(tip) then
                    -- 如果BOSS血精
                    table.insert(tips, string.format(CHS[4300334], tip))
                end

                local function func()
                    if #tips <= 0 then
                            SystemMessageMgr:getAccessory(self.curMsgId)
                        return
                    end

                    local tip = table.remove(tips, 1)
                    gf:confirm(tip, function()
                        func()
                        end)
                        end

                func()
                    end
                end
            end
        end

-- 战斗中禁止领取附件的提示
function SystemMessageShowDlg:getCombatTip(rewardStr)
    local tip = nil
    local types = {}

    if SystemMessageMgr:isHaveRewardByName(CHS[6000582], rewardStr) then -- 经验
        table.insert(types, CHS[6000582])
    end
    if SystemMessageMgr:isHaveRewardByName(CHS[6000583], rewardStr) then -- 道行
        table.insert(types, CHS[6000583])
    end
    if SystemMessageMgr:isHaveRewardByName(CHS[6000584], rewardStr) then -- 武学
        table.insert(types, CHS[6000584])
    end
    if SystemMessageMgr:isHaveRewardByName(CHS[6000585], rewardStr) then -- 道法
        table.insert(types, CHS[6000585])
    end

    -- 如果有禁止领取的类型
    if #types > 0 then
        for i = 1, #types do
            if tip then
                tip = tip .. "、" ..  types[i]
            else
                tip = types[i]
            end
        end
        tip = string.format(CHS[6000586], tip)
    end

    return tip
end

function SystemMessageShowDlg:getWuxuAndExpTip(rewardStr)
    local tip = nil
    local classList = TaskMgr:getRewardList(rewardStr)
    if #classList > 0 then
        local rewardList = classList[1]
        for i = 1, #rewardList do
            local oneReward = rewardList[i]

            if not string.match(oneReward[1]..oneReward[2], CHS[3001111]) then -- 如果有宠物经验丹，则跳过不作考虑
                if string.match(oneReward[1]..oneReward[2], CHS[6400029]) then -- 如果在跳过宠物经验丹后，存在宠物经验，则满足条件
                    tip = CHS[6400029]
                    break
                end
            end
        end
    end

    if SystemMessageMgr:isHaveRewardByName(CHS[3002149], rewardStr) then -- 武学
        if tip then
            tip = tip .. "、"..CHS[3002149]
        else
            tip = CHS[3002149]
        end
    end

    return tip
end

function SystemMessageShowDlg:getPartyTip(rewardStr)
    local tip = nil
    if SystemMessageMgr:isHaveRewardByName(CHS[3002157], rewardStr) then -- 帮贡
        tip = CHS[3002157]
    end

    if SystemMessageMgr:isHaveRewardByName(CHS[3002159], rewardStr) then -- 帮派活力值
        if tip then
            tip = tip .. "、"..CHS[3002159]
        else
            tip = CHS[3002159]
        end
    end

    return tip
end

function SystemMessageShowDlg:getFriendShipTips(rewardStr)
    local classList = TaskMgr:getRewardList(rewardStr)
    local tips = nil

    if #classList > 0 then
        local rewardList = classList[1]
        for i = 1, #rewardList do
            local oneReward = rewardList[i]
            if string.match(oneReward[1], CHS[6000260]) then
                local list =  gf:splitBydelims(oneReward[2], {"$", "#r"})
                local friendlyInfo = TaskMgr:spliteFriendlyInfo(list)

                if friendlyInfo["friendName"] and not FriendMgr:hasFriend(friendlyInfo["gid"]) then
                    local str = string.format(CHS[6400053], friendlyInfo["friendName"], friendlyInfo["gid"] or "")
                    if tips then
                        tips = tips .. "、".. str
                    else
                        tips = str
                    end
                end
            end
        end
    end

    if tips then
        tips = string.format(CHS[6400054], tips)
    end

    return tips
end


function SystemMessageShowDlg:MSG_MAIL_NOT_EXIST(data)
    if data.id == self.curMsgId then
        DlgMgr:closeDlg("SystemMessageShowDlg")
    end
end

function SystemMessageShowDlg:onDelButton(sender, eventType)
    if not self.curMsgId then return end

    if SystemMessageMgr:isOverdue(self.curMsgId) then
        SystemMessageMgr:deleteOneMail(self.curMsgId)
        self:updateSystemMessageDlg()
        gf:ShowSmallTips(CHS[3003698])
    elseif SystemMessageMgr:checkNeedSubmitMsg(self.curMsgId) then
        -- 需要提交信息
        local ts = SystemMessageMgr:getGatherEndTime(self.curMsgId)
        local data = os.time{year = string.sub(ts, 1, 4),
            month = string.sub(ts, 5, 6),
            day = string.sub(ts, 7, 8),
            hour = string.sub(ts, 9, 10),
            min = string.sub(ts, 11, 12),
            sec = string.sub(ts, 13, 14)}
        if gf:getServerTime() < data then
            -- 没有超时，无法删除
            gf:ShowSmallTips(CHS[2000164])
        else
            local msg = SystemMessageMgr:getSystemMessageById(self.curMsgId)

            if SystemMessageMgr:getGatherTypeById(self.curMsgId) == 3 then
                -- 大R特权信息由特殊消息处理
                gf:CmdToServer("CMD_MAILBOX_GATHER_PRIVILEGE", {
                    mail_id = msg.id,
                    mail_oper = 2,
                })
            else
                gf:CmdToServer("CMD_MAILBOX_GATHER", {
                    mail_type = msg.type,
                    mail_id = msg.id,
                    mail_oper = 2,
                })
            end

            self:updateSystemMessageDlg()
        end
    elseif SystemMessageMgr:notGetAcc(self.curMsgId) then
        local tips = CHS[4200002]
        local mail = SystemMessageMgr:getSystemMessageById(self.curMsgId)
        if string.match(mail.attachment, "{ConversionCode=(.+)}") then
            tips = CHS[4300258]
        end

        gf:ShowSmallTips(tips)
    else
        self:deleteMail()
    end
end

function SystemMessageShowDlg:deleteMail()
    SystemMessageMgr:deleteSystemMessage(self.curMsgId)
    self:updateSystemMessageDlg()
end

-- 删除邮件更新邮件列表
function SystemMessageShowDlg:updateSystemMessageDlg()
    local friendDlg = DlgMgr:getDlgByName("FriendDlg")
    if nil == friendDlg then return end
    local count = friendDlg.systemMessageDlg:getItemsCount()
    if 1 < count then
        -- 有新邮件刷新时选中的邮件的 index 会改变，重新获取 index 保证删除完邮件后会选中下一条
        self.curMsgIndex = friendDlg.systemMessageDlg:getCurSelectIndex() or self.curMsgIndex

        if self.curMsgIndex == count - 1 then
            self.curMsgIndex = self.curMsgIndex - 1
        end

        local cur = self.curMsgId
        friendDlg.systemMessageDlg:updateOneMsgView({ id = cur, status = SystemMessageMgr.SYSMSG_STATUS.DEL })
        self:upadteMsg()
    else
        DlgMgr:closeDlg("SystemMessageShowDlg")
    end
end

function SystemMessageShowDlg:upadteMsg()
    self:setShowInfo({index = self.curMsgIndex})
    self:updateUI()
end

function SystemMessageShowDlg:MSG_MAILBOX_REFRESH(data)
    -- local info = {}
    -- info.id = self.curMsgId
    -- self:setShowInfo(info)
    for i = 1, data.count do
        if data[i].id == self.curMsgId then
            if data[i].status == SystemMessageMgr.SYSMSG_STATUS.GET then
                -- 设置按钮状态
                self:refreshButton( data[i])
            end
        end
    end
end

function SystemMessageShowDlg:refreshButton(msg)
    local getBtn = self:getControl("GetButton")
    local gotoBtn = self:getControl("GotoButton")
    local submitBtn = self:getControl("SubmitButton")

    if SystemMessageMgr:isChildJump(msg.attachment) then
        -- 娃娃跳转邮件
        getBtn:setVisible(false)
        submitBtn:setVisible(false)
        gotoBtn:setVisible(true)
        return
    end

    if not SystemMessageMgr:isAttachmentEmpty(msg.attachment) then  -- 有附件
        local endTime = SystemMessageMgr:getGatherEndTime(msg.id)
        if SystemMessageMgr.SYSMSG_STATUS.GET ~= msg.status then

            if string.match(msg.attachment, "{ConversionCode=(.+)}") then
            -- 兑换码
                self:setLabelText("Label_1", CHS[4300256], getBtn)          -- 兑换奖励
                self:setLabelText("Label_2", CHS[4300256], getBtn)          -- 兑换奖励
            else
                self:setLabelText("Label_1", CHS[3003701], getBtn)
                self:setLabelText("Label_2", CHS[3003701], getBtn)
            end

            gf:resetImageView(getBtn)
            gf:resetImageView(submitBtn)
            if rewardContainer then
                rewardContainer:resetAllReward()
            end

            getBtn:setVisible(not endTime)
            submitBtn:setVisible(nil ~= endTime)
            gotoBtn:setVisible(false)
        else
            if string.match(msg.attachment, "{ConversionCode=(.+)}") then
                -- 兑换码
                self:setLabelText("Label_1", CHS[4300257], getBtn)               -- 已兑换
                self:setLabelText("Label_2", CHS[4300257], getBtn)               -- 已兑换
            else
                self:setLabelText("Label_1", CHS[3003702], getBtn)
                self:setLabelText("Label_2", CHS[3003702], getBtn)
            end


            gf:grayImageView(getBtn)
            gf:grayImageView(submitBtn)
            if rewardContainer then
                rewardContainer:grayAllReward()
            end

            getBtn:setVisible(not self.isCanAutoWalk and not endTime)
            submitBtn:setVisible(not self.isCanAutoWalk and nil ~= endTime)
            gotoBtn:setVisible(self.isCanAutoWalk)
        end
    else
        getBtn:setVisible(false) -- 没有附件隐藏按钮
        submitBtn:setVisible(false)
        gotoBtn:setVisible(self.isCanAutoWalk)
    end
end

function SystemMessageShowDlg:setUiInfo(msg)
    local listView = self:getControl("ListView")
    local panel = self:getControl("AttachPanel")
    self:setCtrlVisible("SheQuPanel", false)

    if (SystemMessageMgr:isAttachmentEmpty(msg.attachment) and not SystemMessageMgr:isCommunityJump(msg.attachment))
        or SystemMessageMgr:getGatherEndTime(msg.id)
        or string.match(msg.attachment, "{ConversionCode=(.+)}") then  -- 没有附件，并且不是微社区跳转类型邮件
        listView:setContentSize(self.listViewSize.width, panel:getContentSize().height + self.listViewSize.height)
        panel:setVisible(false)
        self:setCtrlVisible("CoverImage", false)
    else
        listView:setContentSize(self.listViewSize)
        panel:setVisible(true)
        self:setCtrlVisible("CoverImage", true)
    end

    -- 微社区跳转界面需要隐藏附件，显示特定的内容
    self.articleId = ""
    local title
    if SystemMessageMgr:isCommunityJump(msg.attachment) then
        self:setCtrlVisible("SheQuPanel", true)
        self:setCtrlVisible("AttachPanel", false)

        self.articleId, title = SystemMessageMgr:getCommunityJumpInfo(msg.attachment)
        title = gf:getTextByLenth(title, 48)
        self:setColorText(title, "TitlePanel", "SheQuPanel", nil, nil, nil, 17)
end
end

-- 点击前往时，检查邮件附件信息是否符合要求，不符合时在此给提示，符合要求时走gf:onCGAColorText逻辑
function SystemMessageShowDlg:goToButton(textCtrl, sender)
    local mail = SystemMessageMgr:getSystemMessageById(self:getMessageId())
    if mail and mail.attachment and mail.attachment ~= "" then
        local childCid = string.match(mail.attachment, "{ChildCid=(.+)}")
        if not string.isNilOrEmpty(childCid) then
            -- 处理娃娃信息
            local child = HomeChildMgr:getKidByCid(childCid)
            if child then
                DlgMgr:openDlgEx("KidInfoDlg", {selectId = childCid})
            else
                gf:ShowSmallTips(CHS[7120254])
            end

            return
        end

        local partyId, notInPartyTip = string.match(mail.attachment, "{PartyId=(.+)$NotInPartyTip=(.+)}$")
        if partyId and notInPartyTip and partyId ~= Me:queryBasic("party/id") then
            gf:ShowSmallTips(notInPartyTip)
            return
        end

        local articleId, title = SystemMessageMgr:getCommunityJumpInfo(mail.attachment)
        if articleId and title then
            -- 微社区跳转邮件，走社区跳转逻辑
            if CommunityMgr:isCommunityOpen() then
                CommunityMgr:openCommunityDlg(articleId)
            else
                gf:ShowSmallTips(CHS[7150072])
            end

            return
        end
    end

    gf:onCGAColorText(textCtrl, sender, nil, self.name)
end

function SystemMessageShowDlg:onGotoButton(sender, eventType)
    if self.textCtrl then
        self:goToButton(self.textCtrl, sender)
    end
end

function SystemMessageShowDlg:onCloseButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    local dlg = DlgMgr:getDlgByName("FriendDlg")

    if dlg then
        dlg:moveToWinOut()
    end
end

function SystemMessageShowDlg:onSubmitButton(sender, eventType)
    local msg = SystemMessageMgr:getSystemMessageById(self.curMsgId)
    if msg then
        if SystemMessageMgr.SYSMSG_STATUS.GET == msg.status then
            if SystemMessageMgr:getGatherTypeById(self.curMsgId) == 3 then
            -- 特权认证信息，不需提示WDSY-27247
            else
                gf:ShowSmallTips(CHS[2000165])
            end
            return
        else
            local ts = SystemMessageMgr:getGatherEndTime(msg.id)
            local endTime = os.time{year = string.sub(ts, 1, 4), month = string.sub(ts, 5, 6), day = string.sub(ts, 7, 8), hour = string.sub(ts, 9, 10), min = string.sub(ts, 11, 12), sec = string.sub(ts, 13, 14)}

            if SystemMessageMgr:getGatherTypeById(self.curMsgId) == 3 then
                -- 特权认证信息，不需要客户端判断 WDSY-27247
            else
                if gf:getServerTime() > endTime then
                    local timeStr = gf:getServerDate("%Y-%m-%d %H:%M:%S", endTime)
                    gf:ShowSmallTips(string.format(CHS[2000166], timeStr))
                    return
                end
            end
        end

        local type = SystemMessageMgr:getGatherTypeById(self.curMsgId)
        if type == 1 then
            local dlg = DlgMgr:openDlg("GatherInfoDlg")
            dlg:setMailInfo({ ["id"] = msg.id, ["date"] = SystemMessageMgr:getGatherEndTime(msg.id), ["type"] = msg.type })
        elseif type == 2 then
            local dlg = DlgMgr:openDlg("GatherPhoneDlg")
            dlg:setMailInfo({ ["id"] = msg.id, ["date"] = SystemMessageMgr:getGatherEndTime(msg.id), ["type"] = msg.type })
        elseif type == 3 then
            local dlg = DlgMgr:openDlg("GatherPrivilegeDlg")
            dlg:setMailInfo({ ["id"] = msg.id, ["date"] = SystemMessageMgr:getGatherEndTime(msg.id), ["type"] = msg.type })
        elseif type == 4 then
            local dlg = DlgMgr:openDlg("GatherRewardDlg")
            dlg:setMailInfo({["id"] = msg.id, ["date"] = SystemMessageMgr:getGatherEndTime(msg.id), ["type"] = msg.type})
        elseif type == 5 then
            local dlg = DlgMgr:openDlg("GatherBankDlg")
            dlg:setMailInfo({["id"] = msg.id, ["date"] = SystemMessageMgr:getGatherEndTime(msg.id), ["type"] = msg.type})
        elseif type == 6 then
            local dlg = DlgMgr:openDlg("GatherChannelDlg")
            dlg:setMailInfo({["id"] = msg.id, ["date"] = SystemMessageMgr:getGatherEndTime(msg.id), ["type"] = msg.type})
        end
    end
end

function SystemMessageShowDlg:MSG_LOGIN_DONE(data)
    self:onCloseButton()
end

function SystemMessageShowDlg:MSG_SWITCH_SERVER(data)
    self:onCloseButton()
end

function SystemMessageShowDlg:MSG_SWITCH_SERVER_EX(data)
    self:onCloseButton()
end

function SystemMessageShowDlg:MSG_SPECIAL_SWITCH_SERVER(data)
    self:onCloseButton()
end

function SystemMessageShowDlg:MSG_SPECIAL_SWITCH_SERVER_EX(data)
    self:onCloseButton()
end

return SystemMessageShowDlg

