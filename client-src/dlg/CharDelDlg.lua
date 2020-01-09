-- CharDelDlg.lua
-- Created by zhengjh Sep/9/2015
-- 删除角色

local CharDelDlg = Singleton("CharDelDlg", Dialog)

function CharDelDlg:init()
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindListener("1Button", self.onNumberlButton)
    self:bindListener("2Button", self.onNumberlButton)
    self:bindListener("3Button", self.onNumberlButton)
    self:bindListener("4Button", self.onNumberlButton)
    self:bindListener("5Button", self.onNumberlButton)
    self:bindListener("6Button", self.onNumberlButton)
    self:bindListener("7Button", self.onNumberlButton)
    self:bindListener("8Button", self.onNumberlButton)
    self:bindListener("9Button", self.onNumberlButton)
    self:bindListener("0Button", self.onNumberlButton)
    self:bindListener("DelButton", self.onDelButton)
    self:bindListener("DeleteButton", self.onDeleteButton)
    
    -- 玩家信息
    self:setImage("PlayerImage", ResMgr:getSmallPortrait(Me:queryBasicInt("org_icon")))
    self:setItemImageSize("PlayerImage")
    self:setLabelText("NameNoteLabel", Me:getShowName())
    self:setLabelText("LevelLabel", Me:queryBasic("level") .. CHS[3003672])
    self:setLabelText("ValueLabel", Me:queryInt("max_life"))
    self:setCtrlVisible("DelButton", false)
    self.inputNumber = ""
end

function CharDelDlg:onConfrimButton(sender, eventType)
    local password = self.inputNumber 
    
    if password ~= tostring(Me:queryInt("max_life")) then 
        gf:ShowSmallTips(CHS[6200044])
        return
    end
    
    password = string.upper(password)
    local md5 = gfGetMd5(password)
    local pwd = gfEncrypt(md5, SystemSettingMgr:getDelCharSecretKey())
      
    gf:sendGeneralNotifyCmd(NOTIFY. NOTIFY_RESPONS_SECRET, pwd)
    DlgMgr:closeDlg(self.name)
end

function CharDelDlg:onDelButton(sender, eventType)
    self.inputNumber = ""
    self:setInputText()
end

function CharDelDlg:onDeleteButton(sender, eventType)
    local lenth = string.len(self.inputNumber)

    if lenth > 0 then
        self.inputNumber = string.sub(self.inputNumber, 1, lenth - 1)
    else
        self.inputNumber = ""
    end

    self:setInputText()
end

function CharDelDlg:onNumberlButton(sender, eventType)
    local number = sender:getTag() or ""
    if string.len(self.inputNumber) >= 8 then
        gf:ShowSmallTips(CHS[5400041])
        return
    end
    
    self.inputNumber = self.inputNumber .. number
    self:setInputText()
end

function CharDelDlg:setInputText()
    if self.inputNumber == "" then
        self:setLabelText("DefaultLabel", CHS[3002306], nil, COLOR3.GRAY)
        self:setCtrlVisible("DelButton", false)
    else
        self:setLabelText("DefaultLabel", self.inputNumber, nil, COLOR3.WHITE)
        self:setCtrlVisible("DelButton", true)
    end
end


return CharDelDlg
