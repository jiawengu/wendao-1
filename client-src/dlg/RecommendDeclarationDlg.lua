-- RecommendDeclarationDlg.lua
-- Created by songcw Mar/10/2015
-- 自荐界面

local RecommendDeclarationDlg = Singleton("RecommendDeclarationDlg", Dialog)

-- 自荐内容上限100个汉字
local content_limit_max = 70

-- 默认自荐宣言
local DEFAULT_TEXT = CHS[4000203]

function RecommendDeclarationDlg:init()
    self:bindListener("CleanTextButton", self.onCleanTextButton)
    self:bindListener("DefaultButton", self.onDefaultButton)
    self:bindListener("SaveButton", self.onSaveButton)

    self:setCtrlVisible("CleanTextButton", false)
    local textCtrl = self:getControl("TextField")
    textCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then
            self:setCtrlVisible("CleanTextButton", true)
            self:setCtrlVisible("DefaultLabel", false)
            local str = textCtrl:getStringValue()
            local len = string.len(str)
            local leftString = len
            local filterStr = ""
            local index = 1
            if gf:getTextLength(str) > content_limit_max * 2 then
                gf:ShowSmallTips(CHS[4000224])
            end

            while  gf:getTextLength(filterStr) < content_limit_max * 2 and index <= len do
                local byteValue = string.byte(str, index)
                if byteValue < 128 then
                    filterStr = filterStr..string.sub(str, index, index)
                    index = index + 1
                elseif byteValue >= 192 and byteValue < 224 then
                    index = index + 2
                elseif  byteValue >= 224 and byteValue <= 239 then
                    if gf:getTextLength(filterStr..string.sub(str, index, index + 2)) > content_limit_max * 2 then
                        break
                    else
                        filterStr = filterStr..string.sub(str, index, index + 2)
                        index = index + 3
                    end
                end
            end
            textCtrl:setText(tostring(filterStr))
        elseif ccui.TextFiledEventType.delete_backward == eventType then
            -- 判断是否为空
            local str = sender:getStringValue()
            if "" == str then
                self:setCtrlVisible("CleanTextButton", false)
                self:setCtrlVisible("DefaultLabel", true)
            end
        end
    end)

    self:onDefaultButton()
end

-- 打开界面需要某些参数需要重载这个函数
function RecommendDeclarationDlg:onDlgOpened(list, param)
    self:setInputText("TextField", param)
    self:setCtrlVisible("CleanTextButton", param ~= "")
    self:setCtrlVisible("DefaultLabel", param == "")
end

function RecommendDeclarationDlg:onCleanTextButton(sender, eventType)
    self:setInputText("TextField", "")
    self:setCtrlVisible("CleanTextButton", false)
    self:setCtrlVisible("DefaultLabel", true)
end

function RecommendDeclarationDlg:onDefaultButton(sender, eventType)
    self:setInputText("TextField", DEFAULT_TEXT)
    self:setCtrlVisible("DefaultLabel", false)
    self:setCtrlVisible("CleanTextButton", true)
end

function RecommendDeclarationDlg:onSaveButton(sender, eventType)
    -- 发送帮派自荐宣言
    local str = self:getInputText("TextField")
    if str == "" then
        self:onDefaultButton()
    end

    local str, haveFit = gf:filtText(str)
    if haveFit then
        return
    end

    PartyMgr:saveDeclaration(self:getInputText("TextField"))

    if self:getInputText("TextField") ~= DEFAULT_TEXT then
        -- 保存串与默认串不相等，提示保存成功
        gf:ShowSmallTips(CHS[7150074])
    end

    self:onCloseButton()
end

return RecommendDeclarationDlg


