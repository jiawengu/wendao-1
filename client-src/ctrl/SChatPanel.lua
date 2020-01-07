-- SChatPanel.lua
-- Created by sujl, Dec/8/2016
-- 主界面显示的聊天面板控件

local SChatPanel = class("SChatPanel", function()
    return ccui.Layout:create()
end)

function SChatPanel:ctor(oneChatTable, width, height)
    self.width = width
    self:refresh(oneChatTable)
    self.onChannelOpen = nil
end

function SChatPanel:refresh(oneChatTable)
    self.oneChatTable = oneChatTable
    self:removeAllChildren()    -- 清除所有数据

    -- CGAColorTextList 底层实现不支持刷新数据，此处需要全部重建
    self.textCtrl = CGAColorTextList:create()
    self.textCtrl:setFontSize(20)
    self.textCtrl:setString(self.oneChatTable["chatStr"], self.oneChatTable["show_extra"])
    self.textCtrl:setContentSize(self.width, 0)
    self.textCtrl:updateNow()
    local textW, textH = self.textCtrl:getRealSize()
    self.textCtrl:setPosition(0, textH)
    local layer = tolua.cast(self.textCtrl, "cc.LayerColor")
    self:setContentSize(self.width, textH)
    self:addChild(layer)
    self:setAnchorPoint(0,0)

    -- 频道图片
    local channelSprite = self.textCtrl:getChannelSprite()

    if channelSprite then
        local sprite = tolua.cast(channelSprite, "cc.Sprite")
        sprite:retain()
        self.chanenelLayout = ccui.Layout:create()
        self:addChild(self.chanenelLayout)
        self.chanenelLayout:setContentSize(sprite:getContentSize())
        self.chanenelLayout:setPosition(sprite:getPosition())
        self.chanenelLayout:setAnchorPoint(sprite:getAnchorPoint())
        self.chanenelLayout:setTouchEnabled(true)
        sprite:removeFromParent()
        self.chanenelLayout:addChild(sprite)
        sprite:release()
        sprite:setPosition(self.chanenelLayout:getContentSize().width/2, self.chanenelLayout:getContentSize().height/2)

        local function channelSpriteTouch(sender, eventType)
            if ccui.TouchEventType.ended == eventType then
                -- 处理类型点击
                if self.onChannelOpen and 'function' == type(self.onChannelOpen) then self.onChannelOpen() end
            end
        end
        self.chanenelLayout:addTouchEventListener(channelSpriteTouch)
    end

    -- 名字
    local nameLabelSprite = self.textCtrl:getNameStringSprite()

    if nameLabelSprite then
        local labelSprite = tolua.cast(nameLabelSprite, "cc.Sprite")
        labelSprite:retain()
        self.labelLayout = ccui.Layout:create()
        self:addChild(self.labelLayout)
        self.labelLayout:setContentSize(labelSprite:getContentSize())
        self.labelLayout:setTouchEnabled(true)
        self.labelLayout:setPosition(labelSprite:getPosition())
        self.labelLayout:setAnchorPoint(labelSprite:getAnchorPoint())
        labelSprite:removeFromParent()
        self.labelLayout:addChild(labelSprite)
        labelSprite:release()
        labelSprite:setPosition(self.labelLayout:getContentSize().width/2, self.labelLayout:getContentSize().height/2)

        local function nameTouch(sender, eventType)
            if ccui.TouchEventType.ended == eventType then
                -- 处理类型点击
                if self.oneChatTable["gid"] and self.oneChatTable["gid"] ~= 0 and self.oneChatTable["gid"] ~= Me:queryBasic("gid") then
                    FriendMgr:requestCharMenuInfo(self.oneChatTable["gid"])
                    ChatMgr:setTipData(self.oneChatTable)

                    -- 过滤掉左下角角色职称
                    local name = string.match(self.oneChatTable["name"], "(.*) .*")
                    if not name then
                        name = self.oneChatTable["name"]
                    end

                    local char = {}
                    char.gid = self.oneChatTable["gid"]
                    char.name = name
                    char.level = self.oneChatTable["level"]
                    char.icon = self.oneChatTable["icon"]
                    local dlg = DlgMgr:openDlg("CharMenuContentDlg")
                    dlg:setting(self.oneChatTable["gid"])
                    dlg:setbackCharInfo(char)
                    dlg.root:setPositionX(dlg.root:getPositionX() + 100)
                else
                    if self.onChannelOpen and 'function' == type(self.onChannelOpen) then self.onChannelOpen() end
                end
            end
        end
        self.labelLayout:addTouchEventListener(nameTouch)
    end

    local function ctrlTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 处理类型点击
            if self.textCtrl:getCsType() ~= CONST_DATA.CS_TYPE_STRING then
                if not self.oneChatTable["gid"] or self.oneChatTable["gid"] == 0 then
                    -- 系统发出的信息可以寻路
                    gf:onCGAColorText(self.textCtrl, sender)
                else
                    if self.textCtrl:getCsType() ~= CONST_DATA.CS_TYPE_ZOOM and
                       self.textCtrl:getCsType() ~= CONST_DATA.CS_TYPE_NPC and 
                       self.textCtrl:getCsType() ~= CONST_DATA.CS_TYPE_CALL then
                        gf:onCGAColorText(self.textCtrl, sender)
                    end
                end
            else
                if self.onChannelOpen and 'function' == type(self.onChannelOpen) then self.onChannelOpen() end
            end
        end
    end

    self:setTouchEnabled(true)
    self:addTouchEventListener(ctrlTouch)
end

-- 只刷新文本，主要用于语音文本的刷新
function SChatPanel:refreshText(oneChatTable)
    self.oneChatTable = oneChatTable

    if not self.textCtrl then return end
    self.textCtrl:setString(self.oneChatTable["chatStr"], self.oneChatTable["show_extra"])
    self.textCtrl:setContentSize(self.width, 0)
    self.textCtrl:updateNow()
    local textW, textH = self.textCtrl:getRealSize()
    self.textCtrl:setPosition(0, textH)
    self:setContentSize(self.width, textH)

    local channelSprite = self.textCtrl:getChannelSprite()
    if channelSprite then
        local sprite = tolua.cast(channelSprite, "cc.Sprite")
        sprite:retain()
        if self.chanenelLayout then
            self.chanenelLayout:removeAllChildren()
        else
            self.chanenelLayout = ccui.Layout:create()
            self:addChild(self.chanenelLayout)
        end
        self.chanenelLayout:setContentSize(sprite:getContentSize())
        self.chanenelLayout:setPosition(sprite:getPosition())
        self.chanenelLayout:setAnchorPoint(sprite:getAnchorPoint())
        self.chanenelLayout:setTouchEnabled(true)
        sprite:removeFromParent()
        self.chanenelLayout:addChild(sprite)
        sprite:release()
        sprite:setPosition(self.chanenelLayout:getContentSize().width/2, self.chanenelLayout:getContentSize().height/2)
    end

    local nameLabelSprite = self.textCtrl:getNameStringSprite()
    if nameLabelSprite then
        local labelSprite = tolua.cast(nameLabelSprite, "cc.Sprite")
        labelSprite:retain()
        if self.labelLayout then
            self.labelLayout:removeAllChildren()
        else
            self.labelLayout = ccui.Layout:create()
            self:addChild(self.labelLayout)
        end
        self.labelLayout:setContentSize(labelSprite:getContentSize())
        self.labelLayout:setTouchEnabled(true)
        self.labelLayout:setPosition(labelSprite:getPosition())
        self.labelLayout:setAnchorPoint(labelSprite:getAnchorPoint())
        labelSprite:removeFromParent()
        self.labelLayout:addChild(labelSprite)
        labelSprite:release()
        labelSprite:setPosition(self.labelLayout:getContentSize().width/2, self.labelLayout:getContentSize().height/2)
    end
end

return SChatPanel