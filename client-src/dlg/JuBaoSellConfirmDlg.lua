-- JuBaoSellConfirmDlg.lua
-- Created by songcw Nov/6/2018
-- 聚宝斋指定交易上架确认框

local JuBaoSellConfirmDlg = Singleton("JuBaoSellConfirmDlg", Dialog)

function JuBaoSellConfirmDlg:init(data)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCloseButton)

    local contents = json.decode(data.para_str)

    local tips = data.tips

    local count = #contents.check_box_tips
    for i = 1, count do
        tips =  tips .. "· " .. contents.check_box_tips[i]
        if i ~= count then
            tips = tips .. "\n"
        end
    end

    self:setColorText(tips, self:getControl("ContentPanel"), nil, nil, nil, nil, 21, LOCATE_POSITION.CENTER)
    self:getControl("BackPanel"):requestDoLayout()

    self:setCheck("CheckBox", contents.check_box_state)
end

function JuBaoSellConfirmDlg:onConfirmButton(sender, eventType)
    if not self:isCheck("CheckBox") then
        gf:ShowSmallTips(CHS[4300478])
        return
    end


    self.isRespond = true
    gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 1})
    self:onCloseButton()
end

function JuBaoSellConfirmDlg:cleanup()
    if not self.isRespond then
        gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 0})
    end

    self.isRespond = false
end

return JuBaoSellConfirmDlg
