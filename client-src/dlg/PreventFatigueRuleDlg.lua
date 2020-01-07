-- PreventFatigueRuleDlg.lua
-- Created by chenyq Jun/1/2017
-- 防沉迷说明界面

local PreventFatigueRuleDlg = Singleton("PreventFatigueRuleDlg", Dialog)


local panelSize
local bkImageSize

function PreventFatigueRuleDlg:init()
    self:setFullScreen()
    self:bindListener("RuleTipPanel", self.onRulePanel)

    panelSize = self:getControl("RuleTipPanel"):getContentSize()
    bkImageSize = self:getControl("BackImage"):getContentSize()

    self:updateInfo()

    self:hookMsg("MSG_UPDATE_ANTIADDICTION_STATUS")
end

function PreventFatigueRuleDlg:updateInfo()
    local adultStatus = Me:getAdultStatus()
    local antiaddictionInfo = Me:getAntiaddictionInfo()
    local title = CHS[3010001] -- 未实名认证
    local ruleTips = ""
    if antiaddictionInfo["second_enable"] == 1 then
        -- 第二套监管开启
        self:setCtrlVisible("PreventFatiguePanel", false)
        if antiaddictionInfo["is_guest"] == 1 then
            -- 游客模式、官方
            if LeitingSdkMgr:isLeiting() then
                ruleTips = string.format(CHS[5420335], CHS[5420342], CHS[5420346])
            elseif LeitingSdkMgr:isSpecialRealNameChannel() then
                ruleTips = string.format(CHS[5420335], CHS[5420342], CHS[5420347])
            else
                ruleTips = string.format(CHS[5420335], CHS[5420342], CHS[5420348])
            end
        elseif adultStatus == 2 then
            -- 未实名认证
            if LeitingSdkMgr:isLeiting() then
                -- 官方
                ruleTips = string.format(CHS[5420335], CHS[5420343], CHS[5420347])
            elseif LeitingSdkMgr:isSpecialRealNameChannel() then
                ruleTips = string.format(CHS[5420335], CHS[5420343], CHS[5420347])
            else
                ruleTips = string.format(CHS[5420335], CHS[5420343], CHS[5420348])
            end
        elseif adultStatus == 0 then
            -- 未成年
            title = CHS[3010002]
            if antiaddictionInfo["player_age"] >= 0 and antiaddictionInfo["player_age"] < antiaddictionInfo["small_age"] then
                -- 未满十三周岁
                ruleTips = string.format(CHS[5420335], string.format(CHS[5420344], antiaddictionInfo["small_age"]), CHS[5420349])
            else
                -- 未知或已满十三周岁
                ruleTips = string.format(CHS[5420335], CHS[5420345], CHS[5420349])
            end
        end

        local info = {}
        if antiaddictionInfo["is_guest"] == 1 or antiaddictionInfo["young_coin_cost_limit"] == 0 then
            -- 游客或限制元宝为 0
            table.insert(info, CHS[5420336] .. CHS[5420338])
        else
            table.insert(info, string.format(CHS[5420337], antiaddictionInfo["young_coin_cost_limit"]))
        end

        if antiaddictionInfo["player_age"] < antiaddictionInfo["small_age"] or adultStatus == 2 then
            table.insert(info, CHS[5420339])
        end

        table.insert(info, string.format(CHS[5420340], Me:getAntiaddictionLimitTime() / 3600))

        if antiaddictionInfo["switch5"] == 1 then
            table.insert(info, CHS[5420341])
        end

        for i = 1, #info do
            ruleTips = ruleTips .. "#r        " .. i .. CHS[6000084] .. info[i]
        end
    else
        self:setCtrlVisible("PreventFatiguePanel", true)

        if adultStatus == 0 then
            -- 未成年
            title = CHS[3010002]
            ruleTips = CHS[3010006]

            if antiaddictionInfo.switch5 == 1 then
                -- 开启了未成年人的功能限制
                ruleTips = ruleTips .. '#r' .. CHS[3010007]
            end
        elseif adultStatus == 2 then
            -- 未认证
            title = CHS[3010001]

            if LeitingSdkMgr:isLeiting() then
                ruleTips = CHS[3010003]
            else
                ruleTips = CHS[3010004]
            end

            if antiaddictionInfo.switch3 == 1 then
                -- 开启了禁止登录
                ruleTips = ruleTips .. '#r' .. CHS[3010005]
            end
        end
    end

    self:setLabelText("TitleLabel", title, "PreventFatigueRulePanel")

    local tipPanel = self:getControl("RuleTipPanel")
    local cs = tipPanel:getContentSize()
    tipPanel:removeAllChildren()

    local textCtrl = CGAColorTextList:create(true)
    textCtrl:setFontSize(19)
    textCtrl:setString(ruleTips)
    textCtrl:setContentSize(574, 0)
    textCtrl:updateNow()
    textCtrl:setPosition(0, cs.height + 2)
    local layer = tolua.cast(textCtrl, "cc.LayerColor")
    tipPanel:addChild(layer)

    local textW, textH = textCtrl:getRealSize()
    self.textCtrl = textCtrl

    if panelSize.height < textH then
        self:getControl("BackImage"):setContentSize(bkImageSize.width, bkImageSize.height + textH - panelSize.height)
    else
        self:getControl("BackImage"):setContentSize(bkImageSize.width, bkImageSize.height)
    end
end

function PreventFatigueRuleDlg:onRulePanel(sender, eventType)
    if self.textCtrl and ccui.TouchEventType.ended == eventType then
        local csType = self.textCtrl:getCsType()
        if csType > 4 then
            -- 有动作需要处理
            gf:onCGAColorText(self.textCtrl)
        else
            self:close()
        end
    end
end

-- 防沉迷数据更新了
function PreventFatigueRuleDlg:MSG_UPDATE_ANTIADDICTION_STATUS(data)
    self:updateInfo()
end

return PreventFatigueRuleDlg
