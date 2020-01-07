-- MenuItem.lua
-- created by cheny Dec/2/2014
-- 菜单项

-- 直接被选择的标志
local MENUITEM_FLAG_DIRECT_SELECTED =   MENUITEM_FLAG.DIRECT_SELECTED

-- 灰色显示（不可选）
local MENUITEM_FLAG_CRAY_DRAW       =   MENUITEM_FLAG.CRAY_DRAW

-- 弹出确定及取消按钮
local MENUITEM_FLAG_OKCANCEL        =   MENUITEM_FLAG.OKCANCEL

-- 密码处理
local MENUITEM_FLAG_PASSWORD        =   MENUITEM_FLAG.PASSWORD

local MENUITEM_FORMAT_PROMPT       = MENUITEM_FORMAT.PROMPT
local MENUITEM_FORMAT_LEN          = MENUITEM_FORMAT.LEN
local MENUITEM_FORMAT_MINLEN       = MENUITEM_FORMAT.MINLEN
local MENUITEM_FORMAT_DLG          = MENUITEM_FORMAT.DLG
local MENUITEM_FORMAT_ECARD_DLG    = MENUITEM_FORMAT.ECARD_DLG
local MENUITEM_DEFAULT_TEXT        = MENUITEM_FORMAT.DEFAULT_TEXT -- 默认内容
local MENUITEM_MAX                 = MENUITEM_FORMAT.MAX          -- 默认内容
local MENUITEM_FORMAT_TIP          = MENUITEM_FORMAT.TIP

local MENUITEM_FORMAT = MENUITEM_FORMATS

local MIF_NONE              = MIF.NONE               -- 无
local MIF_DIRECT_SELECTED   = MIF.DIRECT_SELECTED    -- 直接被选择的标志
local MIF_CRAY_DRAW         = MIF.CRAY_DRAW          -- 灰色显示（不可选）
local MIF_OKCANCEL          = MIF.OKCANCEL           -- 弹出确定及取消按钮
local MIF_PASSWORD          = MIF.PASSWORD           -- 密码显示


local MenuItem = class("MenuItem", function()
    return ccui.Button:create(ResMgr.ui["npc_button"], ResMgr.ui["npc_button_down"], ResMgr.ui["npc_button"], ccui.TextureResType.localType)
end)

function MenuItem:ctor(text, id, key)
    self:setMenuText(text)
    self.npc_id = id
    self.secret_key = key
    self:createItem()
    self.canProcessMenu = true  -- 是否能响应菜单
    self.isFightMenu = false    -- 是否为战斗菜单
    self.relativeDlg = 'NpcDlg'
    self.talkId = Me:getTalkId()

    self:procMenuItemDirectly()
    self:setContentSize(55, 398)
end

-- 1、 菜单条目格式：[菜单条目文字] 或 [!菜单条目文字] 或 [!*菜单条目文字]
-- ! 表示需要携带一个字符串参数
-- * 表示需要携带的字符串参数输入时以密码方式输入
-- !* 均不实现在菜单栏
-- 2、菜单条目文字中不会含有\n
function MenuItem:setMenuText(text)
    local len = string.len(text)
    if nil == text or len <= 2 then return end

    if gf:getStringChar(text,1) ~= '[' or gf:getStringChar(text,-1) ~= ']' then
        return
    end

    text = string.sub(text, 2, -2)
    self.text = text
    local ch1 = gf:getStringChar(text, 1)

    if ch1 == MENUITEM_FLAG_DIRECT_SELECTED then
        -- 直接被选择的标志
        self.menuItemFlag = MIF_DIRECT_SELECTED
    elseif ch1 == MENUITEM_FLAG_CRAY_DRAW then
        -- 灰色显示（不可选）
        self.menuItemFlag = MIF_CRAY_DRAW
    elseif ch1 == MENUITEM_FLAG_OKCANCEL then
        -- 弹出确定及取消按钮
        self.menuItemFlag = MIF_OKCANCEL
    elseif ch1 == MENUITEM_FLAG_PASSWORD then
        -- 密码显示
        self.menuItemFlag = MIF_PASSWORD
    else
        -- 默认
        self.menuItemFlag = MIF_NONE
    end

    -- 获取显示字符串
    local startPos = self:getDrawTextStartPos(text)
    local endPos = self:getDrawTextEndPos(text)
    self.strDraw = string.sub(text, startPos, endPos)

    if self.strDraw then
        self.strDraw = string.gsub(self.strDraw, "@2018jsj@", "/")
    end

    startPos = self:getActionTextStartPos(text)
    endPos = self:getActionTextEndPos(text)
    self.strAction = string.sub(text, startPos, endPos)

    -- 提示信息
    self.strPrompt = self:getFormatText(MENUITEM_FORMAT_PROMPT)
end

function MenuItem:clickMenu(npcName, itemStr)
    self:setHighlighted(true)

    local function click ()
        self:stopAllActions()

        if  Me:isInCombat() then
            self:setHighlighted(false)
            return
        end

        self:procMenuItem(true)

        -- 需要特殊处理的函数
        self:specialClickAfterAutoClick(npcName, itemStr)
    end

    schedule(self, click, 0)
end

function MenuItem:specialClickAfterAutoClick(npcName, itemStr)
    if nil == npcName or nil == itemStr then return end

    if     (CHS[3002135] == npcName and CHS[3002136] == itemStr)
        or (CHS[3002137] == npcName and CHS[3002138] == itemStr) then
        Me.isAutoShuaDao = true

        -- 3s内没有领取到任务，重置这个状态
        performWithDelay(gf:getUILayer(), function() Me.isAutoShuaDao = false end, 3)
    end
end

function MenuItem:clickMenuWithDoNothing()
    self:setHighlighted(true)

    local function click ()
        self:stopAllActions()
        local dlg = DlgMgr:getDlgByName(self.relativeDlg)
        dlg:doNextMenu()
    end

    schedule(self, click, 0.5)
end

function MenuItem:createItem()
    local show, cmd = self.strDraw, self.strAction
    self:setTitleText(show)

    local showVip = self:getFormatText(MENUITEM_FORMAT_TIP)
    if "1" == showVip then
        -- 需要显示vip图标
        if not self.vipImg then
            self.vipImg = cc.Sprite:create(ResMgr.ui.menu_item_vip)
        end

        self.vipImg:setVisible(true)
        self.vipImg:setAnchorPoint(0, 1)
        local size = self.vipImg:getContentSize()
        local btnSize = self:getContentSize()
        self.vipImg:setPosition(0,  btnSize.height)
        self.vipImg:setLocalZOrder(10)
        self:addChild(self.vipImg)
    elseif self.vipImg then
        self.vipImg:setVisible(false)
    end

    self:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
        elseif eventType == ccui.TouchEventType.canceled then
        elseif eventType == ccui.TouchEventType.ended then

            if CHS[4400032] == self.strDraw then
                RecordLogMgr:isMeetCGPluginCondition("NpcDlg")
            end

            self:procMenuItem()
        end
    end)
end

function MenuItem:setcolorAndSize(textColor, menuContentSize, meunFontSize)
    self:ignoreContentAdaptWithSize(true)
    self:setScale9Enabled(true)
    self:setTitleColor(textColor)
    self:setTitleFontSize(meunFontSize)
    self:setContentSize(menuContentSize)

    local show, cmd = self.strDraw, self.strAction
    local tip = CGAColorTextList:create()
    if tip.setPunctTypesetting then
        tip:setPunctTypesetting(true)
    end
    tip:setFontSize(23)
    tip:setContentSize(self:getContentSize().width, 0)
    tip:setString(show)
    tip:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    tip:updateNow()
    local labelW, labelH = tip:getRealSize()
    self:addChild(tolua.cast(tip, "cc.LayerColor"))
    tip:setPosition((self:getContentSize().width - labelW) / 2, (self:getContentSize().height + labelH) / 2)
    self:setTitleText("")

    if self.vipImg then
        local btnSize = self:getContentSize()
        self.vipImg:setPosition(0,  btnSize.height)
    end
end

-- 处理菜单项
function MenuItem:procMenuItem(isAuto)
    if not self.canProcessMenu then
        return
    end

    if self.menuItemFlag == MIF_OKCANCEL then
        DlgMgr:setVisible(self.relativeDlg, false)
        if not TeamMgr:isTeamMeber(Me) then
            gf:confirm(self.strPrompt,
                function(str) self:onConfirm(str) end,
                function(str) self:onCancel(str) end)
            return
        end
    end

    local dlg = self:getFormatText(MENUITEM_FORMAT_DLG)
    if dlg ~= nil then
        DlgMgr:setVisible(self.relativeDlg, false)
        if not TeamMgr:isTeamMeber(Me) then
            local dlgC = gf:confirm(self.strPrompt,
                function(str) self:onConfirm(str) end,
                function(str) self:onCancel(str) end)

            schedule(dlgC.root,function()
                if self.talkId ~= Me:getTalkId() then
                    DlgMgr:closeDlg("ConfirmDlg")
                end
            end, 0.1)
            return
        end
    end

    local ch1 = gf:getStringChar(self.strAction, 1)
    if ch1 == '!' then
        local tip = self.strPrompt
        if tip == nil or string.len(tip) == 0 then
            tip = CHS[2000019]
        end

        DlgMgr:setVisible(self.relativeDlg, false)
        if not TeamMgr:isTeamMeber(Me) then
            local dlg = gf:confirm(tip, function(str) self:onAskCfm(str) end,
                function(str) self:onAskCancel(str) end, true)

            schedule(dlg.root,function()
                if self.talkId ~= Me:getTalkId() then
                    DlgMgr:closeDlg("ConfirmDlg")
                end
            end, 0.1)

            local ch2 = gf:getStringChar(self.strAction, 2)

            if ch2 == '*' then
                dlg:setPassword(true)
            elseif ch2 == '^' then
                dlg:setNumberOnly(true)
            end

            local len = self:getFormatText(MENUITEM_FORMAT_LEN)
            if len ~= nil then
                dlg:setMaxLen(tonumber(len))
            end

            local minlen = self:getFormatText(MENUITEM_FORMAT_MINLEN)
            if minlen ~= nil then
                dlg:setMaxLen(tonumber(minlen))
            end

            -- 设置编辑框默认内容
            local default = self:getFormatText(MENUITEM_DEFAULT_TEXT)
            if default ~= nil then
                dlg:setDefaultInput(default)
            end

            -- 设置编辑框可输入的最大数值
            local max = self:getFormatText(MENUITEM_MAX)
            if max ~= nil then
                dlg:setMax(max)
            end
        end

    elseif ch1 == '$' then
    --[[ ----todo
    // 取得菜单信息
    ((GColloquizeDlg *) m_pParent)->GetInfoMap(&map);
    map.Set("content", m_strAction.c_str());

    strParent = m_pParent->GetName();

    // 显示物品给予对话框
    gfSendMsg(strParent.c_str(), NULL, CM_SETVISIBLE, FALSE, 0);
    gfSendMsg("TalkItemDlg", NULL, CM_CREATE, 0, 0);
    if (! gfSendMsg("EquipmentDlg", NULL, CM_GETVISIBLE, 0, 0))
    gfSendMsg("EquipmentDlg", NULL, CM_CREATE, 0, 0);

    gfSendMsg("TalkItemDlg", NULL, TIM_SETINFO, (DWORD) &map, 0);

    if (m_strAction[1] == '*')
    strParent = "";

    gfSendMsg("TalkItemDlg", NULL, TIM_SETPARENTDLG, (DWORD) strParent.c_str(), 0);
    break;
    ]]
    else
        local para = ""
        if isAuto then
            para = "1"
        end

        if not TeamMgr:isTeamMeber(Me) then
            self:sendMenuItemCmd2Server(para)
            schedule(self,function() DlgMgr:setVisible(self.relativeDlg, false) end , 0.5)
        elseif TeamMgr:isTeamMeber(Me) and (not self:getFormatText(MENUITEM_FORMAT_DLG) and self.menuItemFlag ~= MIF_OKCANCEL ) then
            self:sendMenuItemCmd2Server(para)
        end
    end

    local npcDlg = DlgMgr:getDlgByName("NpcDlg")
    if npcDlg and not isAuto then

        RecordLogMgr:setChangqsdjc_2TouchPos(GameMgr.curTouchPos)
        RecordLogMgr:paraChangqsdjljc(npcDlg.npcName, self.strAction)
    end
end

function MenuItem:sendMenuItemCmd2Server(para)
    local ch1, ch2 = gf:getStringChar(self.strAction,1), gf:getStringChar(self.strAction,2)
    if ch1 == '!' and ch2 == '*' and nil ~= para then
        local key = self.secret_key
        -- 对数据要进行加密处理
        local md5 = gfGetMd5(para)

        if key ~= nil and string.len(key) > 0 then
            -- 存在密鈅，则对Md5进行des加密
            self:sendMenuItem(self.npc_id, self.strAction, gfEncrypt(md5, key))
        else
            -- 发送消息
            self:sendMenuItem(self.npc_id, self.strAction, md5)
        end
    else
        -- 发送消息
        self:sendMenuItem(self.npc_id, self.strAction, para);
    end
end

function MenuItem:sendMenuItem(id, action, para)
    if id == 1 then -- 1为特殊id，一般为客户端生成的
        if MapMgr:isInMapByName(CHS[4010103]) then  -- 通天塔
            local dlg = DlgMgr:getDlgByName("NpcDlg")
            if dlg and dlg.itemPos then

                -- 多做一些判断没有坏处
                local item = InventoryMgr:getItemByPos(dlg.itemPos)
                if item and item.name ~= CHS[4101286] then return end
                gf:CmdToServer("CMD_APPLY_EX", {pos = item.pos, amount = 1, str = action})
                TaskMgr:setIsAutoChallengeTongtian(false)
                performWithDelay(dlg.root, function ( )
					local dlg = DlgMgr:getDlgByName("NpcDlg")
                    if dlg then dlg:onCloseButton() end
                end, 0)
                return
            end
        end
    end

    if TeamMgr:isTeamMeber(Me) and not self.isFightMenu then
        gf:ShowSmallTips(CHS[6000210])
        return
    end

    -- 如果npc有被要求记录点击事件，则发送消息
    local npcDlg = DlgMgr:getDlgByName("NpcDlg")
    if npcDlg then
        local rcdInfo = RecordLogMgr:getAssignDataByDlgName("NpcDlg")
        if rcdInfo and rcdInfo[npcDlg.npcName] and rcdInfo[npcDlg.npcName].content == action then
            if gfGetTickCount() - rcdInfo[npcDlg.npcName].lastClickTime >= Const.RECORD_CLICK_TIME then
                RecordLogMgr:sendAssignClickLog("NpcDlg", npcDlg.npcName)
            end
        end


        local tiggerInfo = RecordLogMgr:getTiggerDataByDlgName("NpcDlg")
        if tiggerInfo and tiggerInfo[npcDlg.npcName] and tiggerInfo[npcDlg.npcName].content == action and not RecordLogMgr.isContinuing then
            RecordLogMgr:tiggerStart("NpcDlg", npcDlg.npcName)
        end
    end

    local cmd = "CMD_SELECT_MENU_ITEM"
    if self.isFightMenu then
        cmd = "CMD_C_SELECT_MENU_ITEM"
    end

    gf:CmdToServer(cmd, {
        id = id,
        menu_item = action,
        para = para,
    })
end

-- 对菜单进行直接处理
function MenuItem:procMenuItemDirectly()
    local dlg = self:getFormatText(MENUITEM_FORMAT_DLG) or ""
    local ecard = self:getFormatText(MENUITEM_FORMAT_ECARD_DLG) or ""

    -- 判断是否要弹出一卡通对话框
    if MIF_DIRECT_SELECTED == self.menuItemFlag or
        tonumber(dlg) ~= nil and tonumber(dlg) > 0 or
        tonumber(ecard) ~= nil and tonumber(ecard) > 0 then
        DlgMgr:setVisible(self.relativeDlg, false)
        return self:procMenuItem()
    end
end

-- 询问对话框确定
function MenuItem:onAskCfm(str)
    self:sendMenuItemCmd2Server(str)
end

-- 询问对话框取消
function MenuItem:onAskCancel(str)
    if MIF_DIRECT_SELECTED ~= self.menuItemFlag then
        -- 显示对话框
        DlgMgr:setVisible(self.relativeDlg, true)
    end
end

-- 确定/取消对话框点了确定
function MenuItem:onConfirm(str)
    self:sendMenuItemCmd2Server(str)
end

-- 确定/取消对话框点了取消
function MenuItem:onCancel(str)
    local dlg = self:getFormatText(MENUITEM_FORMAT_DLG)
    if MIF_OKCANCEL == self.menuItemFlag and dlg == nil then
        -- 显示对话框
        DlgMgr:setVisible(self.relativeDlg, true)
    end
end

-- 辅助函数
function MenuItem:getDrawTextStartPos(text)
    local ch1 = gf:getStringChar(text, 1)
    if  ch1 == MENUITEM_FLAG_DIRECT_SELECTED or
        ch1 == MENUITEM_FLAG_CRAY_DRAW or
        ch1 == MENUITEM_FLAG_OKCANCEL then
        return 2
    else
        return 1
    end
end

function MenuItem:getDrawTextEndPos(text)
    local pos = gf:findStrByByte(text, '/')
    if pos ~= nil then return pos - 1 end

    local format, pos = self:firstFormat(text)
    if self.menuItemFlag ~= MIF_NONE and format ~= nil then
        return pos - 1
    end

    return string.len(text)
end

function MenuItem:getActionTextStartPos(text)
    if nil ~= text then
        local pos = gf:findStrByByte(text, '/')
        if pos ~= nil then
            return pos + 1
        end
    end

    return self:getDrawTextStartPos(text)
end

function MenuItem:getActionTextEndPos(text)
    if nil ~= gf:findStrByByte(text, '/') then
        local format, pos = self:firstFormat(text)
        if format ~= nil then
            return pos - 1
        else
            return string.len(text)
        end
    end

    return self:getDrawTextEndPos(text)
end

-- 得到格式中的字符串
function MenuItem:getFormatText(format)
    local text = self.text
    if text == nil or format == nil then return end

    local pos = gf:findStrByByte(text, format)
    if pos == nil then return end

    text = string.sub(text, pos + string.len(format), -1)

    format, pos = self:firstFormat(text)
    if format ~= nil then
        return string.sub(text, 1, pos - 1)
    end

    return text
end

-- 返回第一个格式字符的位置及格式字符串
function MenuItem:firstFormat(text)
    local pos = gf:findStrByByte(text, '/') or 0
    local len = string.len(text)
    for i = pos, len do
        if gf:getStringChar(text, i) == '#' then
            for _, v in ipairs(MENUITEM_FORMAT) do
                local substr = string.sub(text, i, i+string.len(v)-1)
                if v == substr then
                    return v, i
                end
            end
        end
    end
end

function MenuItem:getShowInfo()
    return self.strDraw
end

function MenuItem:getAction()
    return self.strAction
end

return MenuItem
