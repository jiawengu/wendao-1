-- WeddingBarrageDlg.lua
-- Created by songcw
-- 婚礼弹幕界面

local WeddingBarrageDlg = Singleton("WeddingBarrageDlg", Dialog)

local BARRAGE_LEN = 20 * 2

function WeddingBarrageDlg:init(data)

    -- 婚礼光效
    if not self.notMagicWeddingId then self.notMagicWeddingId = {} end    
    if data and data.startTime and not self.notMagicWeddingId[data.startTime] then
        gf:createArmatureMagic(ResMgr.ArmatureMagic.item_around, self:getControl("BarrageButton"), Const.ARMATURE_MAGIC_TAG)
        self.notMagicWeddingId[data.startTime] = 1
    end    

    self:bindListener("CleanFieldButton", self.onCleanFieldButton)
    self:bindListener("SendButton", self.onSendButton)
    self:bindListener("BarrageButton", self.onBarrageButton)
    self:bindListener("HideButton", self.onHideButton)
    self:bindListener("BarrageOpenButton", self.onBarrageOpenButton)
    self:bindListener("BarrageCloseButton", self.onBarrageCloseButton)

    -- 获取系统设置状态
    local settingTable = SystemSettingMgr:getSettingStatus()

    -- 拒绝切磋
    local interchangeOn = settingTable["refuse_wedding_msg"] == 1 and false or true
    self:createSwichButton(self:getControl("UseOpenStatePanel"), interchangeOn, self.onSystemSwichBtn)

    -- 发送弹幕点击时间间隔, 不能用通用判断。应该要在最后一步
    -- self:setValidClickTime("SendButton", 3 * 1000, CHS[4010007])

    -- 是否隐藏弹幕
    self:barrageBtnState()

    -- 界面一些隐藏、显示初始化
    self:setCtrlVisible("BarragePanel", false)
    self:setCtrlVisible("HideButton", false)
    self:setCtrlVisible("CleanFieldButton", false)
    self:setCtrlVisible("DefaultLabel", false)

    -- 绑定输入框
    self:bindEditBoxInPanel()

    self:setInputDownCloseDlg(false)
    
    self:hookMsg("MSG_SET_SETTING")
end


function WeddingBarrageDlg:onSystemSwichBtn(isOn, key)
    if isOn then
        self:onBarrageOpenButton()
    else                
        self:onBarrageCloseButton()
    end


end

function WeddingBarrageDlg:barrageBtnState()
    --[[
    -- 是否隐藏弹幕
        self:setCtrlVisible("BarrageOpenButton", SystemSettingMgr:getSettingStatus("refuse_wedding_msg", 0) == 1)
        self:setCtrlVisible("BarrageCloseButton", SystemSettingMgr:getSettingStatus("refuse_wedding_msg", 0) == 0)
        --]]
end

function WeddingBarrageDlg:onUpdate()
    if not self.lastHideTime then return end

    if gfGetTickCount() - self.lastHideTime >= 20 * 1000 then
        self:onHideButton(self:getControl("HideButton"))
        self.lastHideTime = gfGetTickCount() 
    end
end

-- 获取当前输入状态
function WeddingBarrageDlg:getInputState()
    return self.inputState
end

function WeddingBarrageDlg:setInputDownCloseDlg(isClose)
    self.isInputDownClosed = isClose
end

-- 绑定发送消息弹幕panel
function WeddingBarrageDlg:bindEditBoxInPanel()
    self.newNameEdit = self:createEditBox("WordPanel", nil, nil, function(sender, type)
        if type == "began" then
            self.inputState = "began"
            self:setLastHideTime()
        elseif type == "changed" then
            local newName = self.newNameEdit:getText()
            -- 若输入内容为空，则将按钮置灰；若不为空，使按钮可用。
            if newName == "" then
                self:setCtrlVisible("CleanFieldButton", false)
            else
                self:setCtrlVisible("CleanFieldButton", true)
            end

            if gf:getTextLength(newName) > BARRAGE_LEN then
                gf:ShowSmallTips(CHS[4000224])
                newName = gf:subString(newName, BARRAGE_LEN)
                self.newNameEdit:setText(newName)
            end
            
            self.inputState = "changed"

            if self.isInputDownClosed then
                self:onCloseButton()
            end
            self:setLastHideTime()
        end
    end)
    self.newNameEdit:setPlaceholderFont(CHS[3003794], 23)
    self.newNameEdit:setFont(CHS[3003794], 23)
    self.newNameEdit:setPlaceHolder(CHS[4010008])
    self.newNameEdit:setPlaceholderFontColor(COLOR3.GRAY)
    self.newNameEdit:setFontColor(COLOR3.BROWN)
end

function WeddingBarrageDlg:onCleanFieldButton(sender, eventType)
    self.newNameEdit:setText("")
    sender:setVisible(false)
    self:setLastHideTime()
end

function WeddingBarrageDlg:onSendButton(sender, eventType)
    local msg = self.newNameEdit:getText()
    if msg == "" then
        return
    end

    if SystemSettingMgr:getSettingStatus("refuse_wedding_msg", 0) == 1 then
        gf:ShowSmallTips(CHS[4010009])        
        return
    end

    if self.lastTime and gfGetTickCount() - self.lastTime < 3000 then
        gf:ShowSmallTips(CHS[4010007])
        return
    end

    self.lastTime = gfGetTickCount()
    local data = {}
    
    data["channel"] = CHAT_CHANNEL["WEDDING"]
    data["compress"] = 0
    data["orgLength"] = string.len(msg)
    data["msg"] = msg
    
    ChatMgr:sendMessage(data)
    self:onCleanFieldButton(self:getControl("CleanFieldButton"))
end

-- 标记一下，上一次自动隐藏界面时间。需求20没有弹幕操作，自动隐藏
function WeddingBarrageDlg:setLastHideTime()
    self.lastHideTime = gfGetTickCount()
end

function WeddingBarrageDlg:onBarrageButton(sender, eventType)
    self:setCtrlVisible("BarragePanel", true)
    self:setCtrlVisible("HideButton", true)
    sender:setVisible(false)
    self:removeMagic(sender, Const.ARMATURE_MAGIC_TAG)
    self:setLastHideTime()
end

function WeddingBarrageDlg:onHideButton(sender, eventType)
    self:setCtrlVisible("BarragePanel", false)
    self:setCtrlVisible("HideButton", false)
    self:setCtrlVisible("BarrageButton", true)
    sender:setVisible(false)
end

function WeddingBarrageDlg:onBarrageOpenButton(sender, eventType)
    SystemSettingMgr:sendSeting("refuse_wedding_msg", 0)    
    self:setLastHideTime()
end

function WeddingBarrageDlg:onBarrageCloseButton(sender, eventType)
    SystemSettingMgr:sendSeting("refuse_wedding_msg", 1)
    BarrageTalkMgr:removeAllBarrages()
    self:setLastHideTime()
end

function WeddingBarrageDlg:MSG_SET_SETTING(data)
    if data.setting and data.setting.refuse_wedding_msg then
        if data.setting.refuse_wedding_msg == 0 then
            gf:ShowSmallTips(CHS[4101081])
        else
            gf:ShowSmallTips(CHS[4101082])
        end

        self:barrageBtnState()
    end    
end


return WeddingBarrageDlg
