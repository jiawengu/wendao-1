-- ConversionCodeDlg.lua
-- Created by songcw Oct/13/2015
-- 礼包对话界面

local LEN_MAX = 5 * 2
local LEN_MAX2 = 4 * 2
local LEN_MAX3 = 3 * 2

local ConversionCodeDlg = Singleton("ConversionCodeDlg", Dialog)

function ConversionCodeDlg:init()
    self:bindListener("CleanTextButton", self.onCleanTextButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:setCtrlVisible("CleanTextButton", false)
    self:setCtrlVisible("Label", true)
    
    self.newNameEdit = self:createEditBox("BKImage", nil, nil, function(sender, type) 

            if type == "end" then

            elseif type == "changed" then
                local newName = self.newNameEdit:getText()
                if gf:getTextLength(newName) == 0 then
                    self:onCleanTextButton(self:getControl("CleanTextButton"))
                    self:setCtrlVisible("Label", true)
                elseif gf:getTextLength(newName) > 0 then
                    self:setCtrlVisible("CleanTextButton", true)
                    self:setCtrlVisible("Label", false)
                end
                
                if gf:getTextLength(newName) > LEN_MAX then
                    newName = gf:subString(newName, LEN_MAX)
                    self.newNameEdit:setText(newName)
                    gf:ShowSmallTips(CHS[5400041])
                end    
            end
    end)
    self.newNameEdit:setLocalZOrder(1)
    self.newNameEdit:setPlaceholderFont(CHS[3002363], 20)
    self.newNameEdit:setFont(CHS[3002363], 20)
    self.newNameEdit:setFontColor(cc.c3b(255, 255, 255))

    self:updateLayout("ConversionCodePanel")
    self.root:requestDoLayout()
end



function ConversionCodeDlg:onCleanTextButton(sender, eventType)
    self.newNameEdit:setText("")
    self:setCtrlVisible("Label", true)
    sender:setVisible(false)
end

function ConversionCodeDlg:onConfrimButton(sender, eventType)
    local code = self.newNameEdit:getText()
    
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end
    
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002364])
        return 
    end

    if not self:isOutLimitTime("lastTime", 3000) then
        gf:ShowSmallTips(CHS[3002365])
        return
    end
    
    if gf:getTextLength(code) ~= LEN_MAX 
        and gf:getTextLength(code) ~= LEN_MAX2
        and gf:getTextLength(code) ~= LEN_MAX3 then
        gf:ShowSmallTips(CHS[3002366])
        return
    end
    
    if not self:checkIsNumberOrChar(code) then
        gf:ShowSmallTips(CHS[3002367])
        return
    end
    
    self:setLastOperTime("lastTime", gfGetTickCount())
    
    gf:CmdToServer("CMD_FETCH_GIFT", {
        code = code
    })
end

-- 检测是否是字母或者数字
function ConversionCodeDlg:checkIsNumberOrChar(text)
    local len = string.len(text)
    local filterStr = ""
    local index = 1
    local isNumberOrChar = true

    while len >= index and string.len(filterStr) < LEN_MAX do   
        local charValue = string.sub(text, index, index)
        local byteValue = string.byte(charValue, 1)

        if byteValue > 128 or not string.match(charValue,"(%w)") then
            isNumberOrChar = false
           break 
        end   
        index = index + 1 
    end
    
    return isNumberOrChar
end

return ConversionCodeDlg
