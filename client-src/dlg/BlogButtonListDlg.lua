-- BlogButtonListDlg.lua
-- Created by sujl, Sept/25/2017
-- 空间操作菜单

local BlogButtonListDlg = Singleton("BlogButtonListDlg", Dialog)

local BUTTON_LIST = {
    ["showPortrait"] = {
        { text = CHS[2000429], func = "onOpenPhoto" },
        { text = CHS[2000430], func = "onOpenCamera", cond = function() return gf:gfIsFuncEnabled(FUNCTION_ID.IMAGE_PICK_FIXED) end },
        { text = CHS[2000431], func = "onDelPortrait", cond = function(dlgName) return (dlgName == "CityInfoDlg" and not CitySocialMgr:isDefaultIcon())
            or (dlgName == "MatchmakingDlg" and not MatchMakingMgr:isDefaultIcon())
            or (dlgName ~= "CityInfoDlg" and not BlogMgr:isDefaultIcon(dlgName)) end }
    },
    ["reportPortrait"] = {
        { text = CHS[2000432], func = "onReportPortrait" }
    },
    ["reportSign"] = {
        { text = CHS[2000433], func = "onReportSign" }
    },
    ["blogCommentOp"] = {
        { text = CHS[4100852], func = "onReComment" },  -- 回复评论
        { text = CHS[4100853], func = "onDelComment" }, -- 删除评论
    },
    ["blogDelCommentOp"] = {
        { text = CHS[4100853], func = "onDelComment" }, -- 删除评论
    },
    ["petDelCommentOp"] = {
        { text = CHS[4100853], func = "onDelComment" }, -- 删除评论
    },

    ["blogStateDel"] = {
        { text = CHS[4200452], func = "onDeletePhote" },
        { text = CHS[4300292], func = "onViewPhoto" },
    },
    ["blogStateSel"] = {
        { text = CHS[4200466], func = "onSelectPhote" },
        { text = CHS[2000430], func = "onSelectCamera", cond = function() return gf:gfIsFuncEnabled(FUNCTION_ID.IMAGE_PICK_FIXED) end },
    },

    ["weddingBookPhotoMenu"] = {
        { text = CHS[2000469], func = "onOpenPhoto" },
        { text = CHS[2000470], func = "onOpenCamera" },
        { text = CHS[2000471], func = "onReset", cond = function(dlgName) return not DlgMgr:sendMsg(dlgName, "isDefaultPhoto") end },
    },

    ["weddingBookViewPhoto"] = {
        { text = CHS[2000472], func = "onViewPhoto" },
        { text = CHS[2000473], func = "onEditComment", cond = function(dlgName) return DlgMgr:sendMsg(dlgName, "isBookOwner") end },
        { text = CHS[2000474], func = "onDeletePhote", cond = function(dlgName) return DlgMgr:sendMsg(dlgName, "isBookOwner") end },
    },

    ["weddingBookShare"] = {
        { text = CHS[2100151], func = "onShareWBToCurrent" },
        { text = CHS[2100152], func = "onShareWBToWorld" },
        { text = CHS[2100153], func = "onShareWBToParty" },
        { text = CHS[2100154], func = "onShareWBToTeam" },
        { text = CHS[2100155], func = "onShareWBToFriend" },
    },
    ["reportWBCover"] = {
        { text = CHS[2100163], func = "onReportWBCover" }
    },
    ["reportWBPhoto"] = {
        { text = CHS[2100163], func = "onReportWBPhoto" }
    },

    ["TipOffMarket"] = {
        { text = CHS[4300467], func = "onTipOffMarket" }
    },

    ["partyAnnouce"] = {
        { text = CHS[4300311], func = "onPartyAnnouce" }
    },

    ["teamFixedMore"] = {
        { text = CHS[2100274], func = "onViewProp" },
        { text = CHS[2100275], func = "onReserve", cond = function(dlgName, typeStr, sender) return DlgMgr:sendMsg(dlgName, "isOtherMemberForReserve", sender) end },
        { text = CHS[2100276], func = "onCommunicate", cond = function(dlgName, typeStr, sender) return DlgMgr:sendMsg(dlgName, "isOtherMemberForCommunicate", sender) end },
        { text = CHS[2100277], func = "onViewBlog" },
    },

    -- 招募
    ["playerEnlistPolar"] = {
        {text = CHS[4200046], func = "onEnlistPolar", cond = function(dlgName, typeStr, sender, param) return param and not param.excepts[CHS[4200046]] end},
        {text = CHS[3000253], func = "onEnlistPolar", cond = function(dlgName, typeStr, sender, param) return param and not param.excepts[CHS[3000253]] end},
        {text = CHS[3000256], func = "onEnlistPolar", cond = function(dlgName, typeStr, sender, param) return param and not param.excepts[CHS[3000256]] end},
        {text = CHS[3000259], func = "onEnlistPolar", cond = function(dlgName, typeStr, sender, param) return param and not param.excepts[CHS[3000259]] end},
        {text = CHS[3000261], func = "onEnlistPolar", cond = function(dlgName, typeStr, sender, param) return param and not param.excepts[CHS[3000261]] end},
        {text = CHS[3000263], func = "onEnlistPolar", cond = function(dlgName, typeStr, sender, param) return param and not param.excepts[CHS[3000263]] end},
    },
    ["playerEnlistPoint"] = {
        {text = CHS[4200046], func = "onEnlistPoint", cond = function(dlgName, typeStr, sender, param) return param and not param.excepts[CHS[4200046]] end},
        {text = CHS[5410280], func = "onEnlistPoint", cond = function(dlgName, typeStr, sender, param) return param and not param.excepts[CHS[5410280]] end},
        {text = CHS[5410281], func = "onEnlistPoint", cond = function(dlgName, typeStr, sender, param) return param and not param.excepts[CHS[5410281]] end},
        {text = CHS[5410282], func = "onEnlistPoint", cond = function(dlgName, typeStr, sender, param) return param and not param.excepts[CHS[5410282]] end},
        {text = CHS[5410283], func = "onEnlistPoint", cond = function(dlgName, typeStr, sender, param) return param and not param.excepts[CHS[5410283]] end},
    },
    ["TeamEnlistOther"] = {
        {text = CHS[4300311], func = "onReportEnlist"},
        {text = CHS[5000062], func = "onOperFriend", cond = function(dlgName, typeStr, sender, param) return param and not param.excepts[CHS[5000062]] end},
        {text = CHS[5000064], func = "onOperFriend", cond = function(dlgName, typeStr, sender, param) return param and not param.excepts[CHS[5000064]] end},
    },

    -- 复制，相关内容具体
    ["copy_content"] = {},

    ["matchMakingOther"] = {
        { text = CHS[2000506], func = "onReportMatchMaking" },
        { text = CHS[2000507], func = "onAddFriend", cond = function(dlgName) return DlgMgr:sendMsg(dlgName, "isCanAddFriend") end },
        { text = CHS[2000508], func = "onDeleteFriend", cond = function(dlgName) return DlgMgr:sendMsg(dlgName, "isCanDeleteFriend") end },
    },
    ["matchMakeShow"] = {
        { text = CHS[2000429], func = "onOpenPhoto" },
        { text = CHS[2000430], func = "onOpenCamera", cond = function() return gf:gfIsFuncEnabled(FUNCTION_ID.IMAGE_PICK_FIXED) end },
        { text = CHS[2000542], func = "onDelPortrait", cond = function(dlgName) return (dlgName == "MatchmakingDlg" and not MatchMakingMgr:isDefaultIcon()) end }
    },

    -- 胎儿
    ["taier1"] = {
        { text = CHS[4010389], func = "onKidInfoDlgCare"},      -- 散步
        { text = CHS[4010390], func = "onKidInfoDlgCare"},      -- 音乐
        { text = CHS[4010391], func = "onKidInfoDlgCare"},      -- 按摩
    },

    -- 好声音-点击某个留言
    ["goodVoiceMsg"] = {
        { text = CHS[4200664], func = "onGoodVoiceDetailsDlgjbly"},   -- GoodVoiceDetailsDlg 界面的举报留言
        { text = CHS[4200665], func = "onGoodVoiceDetailsDlghfly"},  -- GoodVoiceDetailsDlg 界面的回复此留言
    },

    -- 好声音-点击某个留言  自己发的留言
    ["goodVoiceMsgEx"] = {
        { text = CHS[4200664], func = "onGoodVoiceDetailsDlgjbly"},   -- GoodVoiceDetailsDlg 界面的举报留言
        { text = CHS[4200706], func = "onGoodVoiceDetailsDlgchly"},   -- GoodVoiceDetailsDlg 界面的举报留言
    },

    ["goodVoiceOnlyJb"] = {
        { text = CHS[4200664], func = "onGoodVoiceDetailsDlgjbly"},   -- GoodVoiceDetailsDlg 界面的举报留言
    },


    ["blogCommentAndReport"] = {
        { text = CHS[4300501], func = "onReplyCommentForBlog"},
        { text = CHS[4300502], func = "onReportCommentForBlog"},
    },

    ["blogCommentAndReportForMessage"] = {
        { text = CHS[4300509], func = "onReplyCommentForBlog"},
        { text = CHS[4300510], func = "onReportCommentForBlog"},
    },

    ["onReportComment"] = {
     --   { text = "回复评论", func = "onReplyCommentForBlog"},
        { text = CHS[4300502], func = "onReportCommentForBlog"},
    },
    --{ text = CHS[2000506], func = "onReportMatchMaking" },

}

function BlogButtonListDlg:init(info)
    self:bindListener("UserButton", self.onButton, "ListView")
    self.btnItem = self:retainCtrl("UserButton")
    local listView = self:getControl("ListView")
    self.viewSize = listView:getContentSize()
    self.dlgSize = self.root:getContentSize()
    self.sender = info.sender
    self.gid = nil
    self.typeStr = info.typeStr
    self.parentDlg = info.dlgName
    self.param = info.param
    self:initList(info.typeStr, info.param)
end

function BlogButtonListDlg:setGid(gid)
    self.gid = gid
end

-- 点击按钮A，弹出列表，sender为A控件
function BlogButtonListDlg:setCallbackObj(sender)
    self.sender = sender
end

function BlogButtonListDlg:initListForCopyContent(listView, param)
    for i = 1, #param do
        local item = self.btnItem:clone()
        local list = gf:split(param[i], "=")
        item.copeContent = list[2]
        self:setLabelText("NameLabel", list[1], item)
        listView:pushBackCustomItem(item)
        self:bindTouchEndEventListener(item, self.onCopyButton)
    end
end

function BlogButtonListDlg:onCopyButton(sender)
    gf:copyTextToClipboard(sender.copeContent)
    gf:ShowSmallTips(CHS[4200610])
    self:onCloseButton()
end

function BlogButtonListDlg:initList(typeStr, param)
    local list = BUTTON_LIST[typeStr]
    if not list then return end

    local listView = self:resetListView("ListView")

    if typeStr == "copy_content" then
        self:initListForCopyContent(listView, param)
    else
    for i = 1, #list do
        if 'function' ~= type(list[i].cond) or (list[i].cond)(self.parentDlg, typeStr, self.sender, param) then
            local item = self.btnItem:clone()
            self:setLabelText("NameLabel", list[i].text, item)
            item.func = list[i].func
            item.info = list[i]
            listView:pushBackCustomItem(item)
        end
    end
    end

    local cnt = #(listView:getItems())
    local itemSize = self.btnItem:getContentSize()
    local height = itemSize.height * cnt
    listView:setContentSize(cc.size(self.viewSize.width, height))
    self.root:setContentSize(cc.size(self.dlgSize.width, self.dlgSize.height - self.viewSize.height + height))
end

function BlogButtonListDlg:onButton(sender, eventType)
    local func = sender.func
    if func then
        self[func](self, sender)
    end
    self:onCloseButton()
end

-- 打开相册
function BlogButtonListDlg:onOpenPhoto()
    DlgMgr:sendMsg(self.parentDlg, "openPhoto", 0)
end

-- 相机拍照
function BlogButtonListDlg:onOpenCamera()
    DlgMgr:sendMsg(self.parentDlg, "openPhoto", 1)
end

-- 删除头像
function BlogButtonListDlg:onDelPortrait()
    DlgMgr:sendMsg(self.parentDlg, "deleteIcon")
end

-- 举报头像
function BlogButtonListDlg:onReportPortrait()
    DlgMgr:sendMsg(self.parentDlg, "reportIcon", self.sender)
end

function BlogButtonListDlg:onReportSign()
    DlgMgr:sendMsg(self.parentDlg, "reportSign")
end

--
function BlogButtonListDlg:onReComment()
    DlgMgr:sendMsg(self.parentDlg, "onReComment")
end

-- 编辑备注
function BlogButtonListDlg:onEditComment()
    DlgMgr:sendMsg(self.parentDlg, "onEditComment", self.sender)
end

-- 删除朋友圈评论
function BlogButtonListDlg:onDelComment()
    DlgMgr:sendMsg(self.parentDlg, "onDelComment", self.sender)
end

-- 发布时选择图片
function BlogButtonListDlg:onSelectPhote()
    DlgMgr:sendMsg(self.parentDlg, "onSelectPhote", self.sender, 0)
end

function BlogButtonListDlg:onSelectCamera()
    DlgMgr:sendMsg(self.parentDlg, "onSelectPhote", self.sender, 1)
end

-- 发布时选择图片
function BlogButtonListDlg:onDeletePhote()
    DlgMgr:sendMsg(self.parentDlg, "onDeletePhote", self.sender)
end

-- 查看
function BlogButtonListDlg:onViewPhoto()
    DlgMgr:sendMsg(self.parentDlg, "onViewPhoto", self.sender)
end

-- 恢复默认
function BlogButtonListDlg:onReset()
    DlgMgr:sendMsg(self.parentDlg, "doReset", self.sender)
end

-- 分享纪念册到当前频道
function BlogButtonListDlg:onShareWBToCurrent()
    DlgMgr:sendMsg(self.parentDlg, "doShareWeddingBook", self.sender, CHAT_CHANNEL.CURRENT)
end

-- 分享纪念册到世界频道
function BlogButtonListDlg:onShareWBToWorld()
    DlgMgr:sendMsg(self.parentDlg, "doShareWeddingBook", self.sender, CHAT_CHANNEL.WORLD)
end

-- 分享纪念册到帮派频道
function BlogButtonListDlg:onShareWBToParty()
    DlgMgr:sendMsg(self.parentDlg, "doShareWeddingBook", self.sender, CHAT_CHANNEL.PARTY)
end

-- 分享纪念册到队伍频道
function BlogButtonListDlg:onShareWBToTeam()
    DlgMgr:sendMsg(self.parentDlg, "doShareWeddingBook", self.sender, CHAT_CHANNEL.TEAM)
end

-- 分享纪念册到好友频道
function BlogButtonListDlg:onShareWBToFriend()
    DlgMgr:sendMsg(self.parentDlg, "doShareWeddingBook", self.sender, CHAT_CHANNEL.FRIEND)
end

-- 举报纪念册封面
function BlogButtonListDlg:onReportWBCover()
    DlgMgr:sendMsg(self.parentDlg, "doReportCover", self.sender)
end

-- 举报纪念册相片
function BlogButtonListDlg:onReportWBPhoto()
    DlgMgr:sendMsg(self.parentDlg, "doReportPhoto", self.sender)
end

-- 查看属性
function BlogButtonListDlg:onViewProp()
    DlgMgr:sendMsg(self.parentDlg, "doViewProp", self.param)
end

-- 补充储备
function BlogButtonListDlg:onReserve()
    DlgMgr:sendMsg(self.parentDlg, "doReserve", self.param)
end

-- 交流
function BlogButtonListDlg:onCommunicate()
    DlgMgr:sendMsg(self.parentDlg, "doCommunicate", self.param)
end

-- 查看空间
function BlogButtonListDlg:onViewBlog()
    DlgMgr:sendMsg(self.parentDlg, "doViewBlog", self.param)
end

-- 招募系别选择
function BlogButtonListDlg:onEnlistPolar(sender)
    DlgMgr:sendMsg(self.parentDlg, "doSelectPolar", sender.info.text)
end

-- 招募加点偏向选择
function BlogButtonListDlg:onEnlistPoint(sender)
    DlgMgr:sendMsg(self.parentDlg, "doSelectPoint", sender.info.text)
end

-- 删除添加好友
function BlogButtonListDlg:onOperFriend()
    DlgMgr:sendMsg(self.parentDlg, "doOperFriend")
end

-- 举报
function BlogButtonListDlg:onReportEnlist()
    DlgMgr:sendMsg(self.parentDlg, "doReport")
end

function BlogButtonListDlg:cleanup()
    DlgMgr:sendMsg(self.parentDlg, "doCloseButtonListDlg")
end

-- 举报寻缘
function BlogButtonListDlg:onReportMatchMaking()
    DlgMgr:sendMsg(self.parentDlg, "doReport", self.sender)
end

-- 增加好友
function BlogButtonListDlg:onAddFriend()
    DlgMgr:sendMsg(self.parentDlg, "doAddFriend", self.sender)
end

-- 删除好友
function BlogButtonListDlg:onDeleteFriend()
    DlgMgr:sendMsg(self.parentDlg, "doDeleteFriend", self.sender)
end

function BlogButtonListDlg:setFloatingFramePos(rect)
    if self.typeStr == "blogDelCommentOp" or self.typeStr == "blogCommentOp" or self.typeStr == "blogCommentAndReportForMessage" or self.typeStr == "blogCommentAndReport" then
        local size = self.root:getContentSize()
        self:setCtrlVisible("PointImage", true)

        local x = (rect.x + rect.width * 0.5)
        local y = (rect.y + rect.height * 0.5)
        local dlgSize = self.root:getContentSize()
        dlgSize.width = dlgSize.width * Const.UI_SCALE
        dlgSize.height = dlgSize.height * Const.UI_SCALE
        local ap = self.root:getAnchorPoint()
        self.root:setAnchorPoint(0,0)
        local posX, posY, isUp
        posX = rect.x - dlgSize.width - 14
        posY = y - dlgSize.height * 0.5
        self:setPosition(cc.p(posX, posY))
    elseif self.typeStr == "petDelCommentOp" or "onReportComment" == self.typeStr then
        local size = self.root:getContentSize()
        local x = (rect.x + rect.width * 0.5)
        local y = (rect.y + rect.height * 0.5)
        self.root:setAnchorPoint(0.5, 0.5)
        self:setPosition(cc.p(x, y))
    elseif self.typeStr == "playerEnlistPolar" or self.typeStr == "playerEnlistPoint" or self.typeStr == "TeamEnlistOther" then
        local x = (rect.x + rect.width * 0.5)
        local y = rect.y + rect.height
        self.root:setAnchorPoint(0.5, 0)
        self:setPosition(cc.p(x, y))
    else
        Dialog.setFloatingFramePos(self, rect)
    end
end

-- 集市聚宝
function BlogButtonListDlg:onTipOffMarket()
    DlgMgr:sendMsg(self.parentDlg, "onTipOffMarket", self.sender)
end

function BlogButtonListDlg:onGoodVoiceDetailsDlgjbly()
    DlgMgr:sendMsg(self.parentDlg, "onReportMsg", self.sender)
end


function BlogButtonListDlg:onReportCommentForBlog()
    DlgMgr:sendMsg(self.parentDlg, "onReportCommentForBlog", self.sender)
end

function BlogButtonListDlg:onReplyCommentForBlog()
    DlgMgr:sendMsg(self.parentDlg, "onReplyCommentForBlog", self.sender)
end

function BlogButtonListDlg:onGoodVoiceDetailsDlgchly()
    DlgMgr:sendMsg(self.parentDlg, "onChehly", self.sender)
end


function BlogButtonListDlg:onGoodVoiceDetailsDlghfly()
    DlgMgr:sendMsg(self.parentDlg, "onCommentMsg", self.sender)
end


-- 查看
function BlogButtonListDlg:onPartyAnnouce()
    if not self.sender.partyInfo then return end

    local announce = self.sender.partyInfo.partyAnnounce or self.sender.partyInfo.annouce
    if not announce or announce == "" then
        gf:ShowSmallTips(CHS[4300479])
        return
    end

    if Me:queryBasicInt("level") < 35 then
        gf:ShowSmallTips(CHS[4300480])
        return
    end

    local data = {}
    data.user_gid = self.sender.partyInfo.partyId
    data.user_name = self.sender.partyInfo.partyName
    data.type = "dlg"
    data.content = {}
    data.count = 1
    data.user_dist = ""
    data.content[1] = {}
    data.content[1].reason = "party_annouce"

    gf:CmdToServer("CMD_REPORT_USER", data)

    ChatMgr:setTipDataForAnnounce(self.sender.partyInfo)

--    DlgMgr:sendMsg(self.parentDlg, "onViewPhoto", self.sender)
end

function BlogButtonListDlg:onKidInfoDlgCare(sender)
    local text = self:getLabelText("NameLabel", sender)
    DlgMgr:sendMsg("KidInfoDlg", "onKidInfoDlgCare", text)
end


return BlogButtonListDlg
