-- RealNameVerifyDlg.lua
-- Created by zhengjh Mar/23/2015
-- 身份验证

local RealNameVerifyDlg = Singleton("RealNameVerifyDlg", Dialog)



local NAMEWORD_LIMIT = 6 * 3
local CARD_LIMIT = 18

function RealNameVerifyDlg:init()
    self:bindListener("SubmitButton", self.onSubmitButton)
    self:bindListener("DelNameButton", self.onDelNameButton)
    self:bindListener("DelCardButton", self.onDelCardButton)
    self.nameTextField = self:getControl("NameTextField", Const.UITextField)
    self.cardTextField = self:getControl("CardTextField", Const.UITextField)
    self.delNameBtn = self:getControl("DelNameButton", Const.UIButton)
    self.delCardBtn = self:getControl("DelCardButton", Const.UIButton)
    self.delNameBtn:setVisible(false)
    self.delCardBtn:setVisible(false)
    
    local  function nameFieldListener(sender, type)
        if type == ccui.TextFiledEventType.delete_backward then
            local len = self.nameTextField:getStringLength()
            if len <= 0 then
                self.delNameBtn:setVisible(false)
            end
        elseif type == ccui.TextFiledEventType.insert_text then
           self:checkIsChinese()          
        end
    end
    self.nameTextField:addEventListener(nameFieldListener)
    
    
    local  function cardTextFieldListener(sender, type)
        if type == ccui.TextFiledEventType.attach_with_ime then
        
        elseif type == ccui.TextFiledEventType.delete_backward then
            local len = self.cardTextField:getStringLength()
            if len <= 0 then
                self.delCardBtn:setVisible(false)
            end
        elseif type == ccui.TextFiledEventType.insert_text then
            self:checkIsNumber()
        end
        
    end
    self.cardTextField:addEventListener(cardTextFieldListener)
    

end

function RealNameVerifyDlg:onSubmitButton(sender, eventType)
    if self.nameTextField:getStringLength() == 0 or self.cardTextField:getStringLength() == 0 then
        gf:ShowSmallTips(CHS[6000146])
        return 
    else
        if self:checkName() == true and self:chechCard() == true then
            DlgMgr:closeDlg(self.name)
            DlgMgr:openDlg("CreateCharDlg")
         end
    end
end

function RealNameVerifyDlg:onDelNameButton()
    self.nameTextField:setText("")
    self.delNameBtn:setVisible(false)
end

function RealNameVerifyDlg:onDelCardButton()
    self.cardTextField:setText("")
    self.delCardBtn:setVisible(false)
end

-- 名字输入文字检测
function RealNameVerifyDlg:checkIsChinese()
    local text = self.nameTextField:getStringValue()
    local len = string.len(text)
    local leftString = text
    local filterStr = ""
    local index = 1
    
    -- utf8 编码规则
    --0000 - 007F 这部分是最初的ascii部分，按原始的存储方式，即0xxxxxxx。
    --0080 - 07FF 这部分存储为110xxxxx 10xxxxxx
    --0800 - FFFF 这部分存储为1110xxxx 10xxxxxx 10xxxxxx
    -- 标点符号的范围 gb2312 10100001 00111111 ~ 10101010 01000000
    -- 转换成utf8  11101010 10000100 10111111 ~ 11101010 10101001 10000000
    
    while len >= index and string.len(filterStr) < NAMEWORD_LIMIT do   
       local byteValue = string.byte(text, index)
       if byteValue < 128 then
            index = index + 1
       elseif byteValue >= 192 and byteValue < 224 then
            index = index + 2
       elseif  byteValue >= 224 and byteValue <= 239 then
            local gbkStr = gfUTF8ToGBK(string.sub(text, index, index + 2))
            local value = string.byte(gbkStr,1) * 256 + string.byte(gbkStr,2)
            if  value >= 0xA13F and value <= 0xAA40 then
            else
                filterStr = filterStr..string.sub(text, index, index + 2)
            end
            index = index + 3
       end    
    end
    
    if string.len(filterStr) > 0 then
        self.delNameBtn:setVisible(true)
    else
        self.delNameBtn:setVisible(false)
    end
    
    if len > string.len(filterStr) and string.len(filterStr) >= NAMEWORD_LIMIT then
        gf:ShowSmallTips(CHS[6000133])  
    elseif len ~= string.len(filterStr) then
        gf:ShowSmallTips(CHS[6000141])
    end
    
    self.nameTextField:setText(filterStr)

end

function RealNameVerifyDlg:checkIsNumber()
    local text = self.cardTextField:getStringValue()
    local len = string.len(text)
    local filterStr = ""
    local index = 1
    
    while len >= index and string.len(filterStr) < CARD_LIMIT do   
        local charValue = string.sub(text, index, index)
        local byteValue = string.byte(charValue, 1)
        
        if byteValue < 128 then
            index = index + 1
            if  string.match(charValue,"(%w)") then
                filterStr = filterStr..charValue
            end  
        elseif byteValue >= 192 and byteValue < 224 then
            index = index + 2
        elseif  byteValue >= 224 and byteValue <= 239 then
            index = index + 3
        else
            Log:W("Invalid code")
            break
        end    
    end
    
    if string.len(filterStr) > 0 then
        self.delCardBtn:setVisible(true)
    else
        self.delCardBtn:setVisible(false)
    end
    
    if len > string.len(filterStr) and string.len(filterStr) >= NAMEWORD_LIMIT then
        gf:ShowSmallTips(CHS[6000133])  
    elseif len ~= string.len(filterStr) then
        gf:ShowSmallTips(CHS[6000142])
    end
    
    self.cardTextField:setText(filterStr)
end


function RealNameVerifyDlg:checkName()
    local len = string.len(self.nameTextField:getStringValue()) 
    if len < 6 or len > NAMEWORD_LIMIT then
        gf:ShowSmallTips(CHS[6000143])
        return false
    end
    
    return true
end

function RealNameVerifyDlg:chechCard()
    local text = self.cardTextField:getStringValue()
    local len = string.len(text) 
    
    if len ~= 18 then
        gf:ShowSmallTips(CHS[6000144])
        return false
    end
    
    -- 保证前面17或14都为数字
    if len == 15 then
        if tonumber(string.sub(text, 1, 14)) == nil then
            gf:ShowSmallTips(CHS[6000145])
            return false
        end
    elseif len == 18 then
         if tonumber(string.sub(text, 1, 17)) == nil then
            gf:ShowSmallTips(CHS[6000145])
            return false
        end
    end
    
    local area = string.sub(text, 1, 2)
    
    if tonumber(area) == nil or AREA_CODE[tonumber(area)] == nil  then
        gf:ShowSmallTips(CHS[6000145])
        return false
    else
        if len == 15 then
            local year  = tonumber("19"..string.sub(text, 7, 8))
            local month = tonumber(string.sub(text,  9, 10))
            local day = tonumber(string.sub(text, 11, 12))
            if not year or not month or not day then
                gf:ShowSmallTips(CHS[6000145])
                return false
            else
                return self:checkCardTime(year, month, day)
            end
        elseif len== 18 then
            local year  = tonumber(string.sub(text, 7, 10))
            local month = tonumber(string.sub(text,  11, 12))
            local day = tonumber(string.sub(text, 13, 14))
            if not year or not month or not day then
                gf:ShowSmallTips(CHS[6000145])
                return false
            else
                if self:checkCardTime(year, month, day) == false then
                    gf:ShowSmallTips(CHS[6000145])
                    return false
                end
            end
        end
    end
    
    local wi = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2, 1}
    local ai = {}
    if len == 18 then
        for i = 1, 17 do
            local oneChar = string.sub(text, i, i)
            table.insert(ai, tonumber(oneChar))
        end
    end
    
    local Y = {1,0,10,9,8,7,6,5,4,3,2} -- x 
    local s = 0
    for j = 1, 17 do
        s = s + ai[j] * wi[j]
    end
    
    local lastNmnmber = string.sub(text, 18, 18)
    local lastNumValue 
    
    if string.lower(lastNmnmber) ~= "x" and (string.byte(lastNmnmber,1) < 48 or string.byte(lastNmnmber,1) > 57) then
        gf:ShowSmallTips(CHS[6000145])
        return false
    else
        if string.lower(string.sub(text, 18, 18)) == "x" then
            lastNumValue = 10
        else 
            lastNumValue = tonumber(string.sub(text, 18, 18))
        end
    end

    local y = s % 11
    if Y[y + 1] ~= lastNumValue then
        gf:ShowSmallTips(CHS[6000145])
        return false
    end
    
    return true
    
end


function RealNameVerifyDlg:checkCardTime(year, month, day)
    local febDay  = 28
    local curtimeTabel = gf:getServerDate("*t", gf:getServerTime())
    local curYear = curtimeTabel["year"]
    
    if year % 100 == 0 and year % 4 == 0 then
        febDay  = 29
    elseif year % 4 == 0 then
        febDay = 29
    end
    
    if year < 1800  or year > curYear then
        return false
    elseif (curYear== year and month > curtimeTabel["month"]) or month == 0 then 
        return false
    else
        if month > 12 or month <= 0 then
            return false      
        else
            if month == 2 then
                if day <= 0 or day > febDay then
                    return false
                end
            else 
                if day <= 0 or day > MONTH_DAY[month]  then
                    return false
                end
            end
        
        end
    end
    
    return true
end

return RealNameVerifyDlg
