-- CaseTWBoxDlg.lua
-- Created by huangzz Jun/01/2018
-- 探案 盒子界面

local CaseTWBoxDlg = Singleton("CaseTWBoxDlg", Dialog)

local BUTTON_ORDER_MAP = {
    ["Button1"] = 1,
    ["Button2"] = 3,
    ["Button3"] = 2,
    ["Button4"] = 4,
}

function CaseTWBoxDlg:init()
    self:setFullScreen()

    self:bindListener("Button1", self.onButton)
    self:bindListener("Button2", self.onButton)
    self:bindListener("Button3", self.onButton)
    self:bindListener("Button4", self.onButton)


    self.clickNum = {0, 0, 0, 0}
    self.totalNum = 0
    self.lastClickNum = 0

    self:hookMsg("MSG_TWZM_BOX_RESULT")
end

function CaseTWBoxDlg:setButtonsEnabled(enabled)
    for i = 1, 4 do
        self:setCtrlEnabled("Button" .. i, enabled)
    end
end

function CaseTWBoxDlg:setData(data)
    self.data = data
    self.order = {}
    for i = 1, 4 do
        local panel = self:getControl("IconPanel" .. i)
        local path = ResMgr:getCaseTianganWordImg(data[i].word)
        self:setImage("NumImage", path, panel)
        self:setImage("IconImage", ResMgr.ui["case_box_img" .. data[i].img_index], panel)

        self.order["Button" .. data[i].img_index] = i
    end
end

function CaseTWBoxDlg:getTotalNum()
    local total = 0
    for i = 1, 4 do
        total = total + self.clickNum[i]
    end

    return total
end

function CaseTWBoxDlg:cmdBoxAnswer()
    gf:CmdToServer("CMD_TWZM_BOX_ANSWER", self.clickNum)
end

function CaseTWBoxDlg:onButton(sender, eventType)
    local num = self.order[sender:getName()]
    self.totalNum = self.totalNum + 1
    if self.lastClickNum == num or self.lastClickNum + 1 == num then
        self.clickNum[num] = self.clickNum[num] + 1
        self.lastClickNum = num
    end

    if self.totalNum >= self.data.total_num then
        if self:getTotalNum() < self.data.total_num  then
            self:setButtonsEnabled(false)
            self:MSG_TWZM_BOX_RESULT({result = 0})
        else
            self:cmdBoxAnswer()
            self:setButtonsEnabled(false)
            -- self:MSG_TWZM_BOX_RESULT({result = 1})
        end

        return
    end
end

-- 播放打开盒子的光效
function CaseTWBoxDlg:creatBoxArmature(icon, actName, ctrlName, callback, isLoop)
    local panel = self:getControl(ctrlName)
    local size = panel:getContentSize()
    local magic = ArmatureMgr:createArmature(icon)

    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.complete then
            magic:stopAllActions()
            magic:removeFromParent(true)
            magic = nil

            if callback and "function" == type(callback) then callback(self, cbPara) end
        end
    end


    magic:setPosition(size.width / 2, size.height / 2)
    magic:getAnimation():setMovementEventCallFunc(func)
    magic:getAnimation():play(actName, -1, isLoop and 1 or 0)
    panel:addChild(magic)

    return magic
end


function CaseTWBoxDlg:playAction(result)
    if result ~= 0 then
        -- 成功
        local img1 = self:getControl("RightImage1")
        local img2 = self:getControl("RightImage2")
        local fadeAction = cc.Repeat:create(cc.Sequence:create(
                cc.FadeIn:create(0.1),
                cc.FadeOut:create(0.1)
            ), 3)

        local action = cc.Sequence:create(
            cc.Repeat:create(cc.Sequence:create(
                cc.FadeIn:create(0.1),
                cc.FadeOut:create(0.1)
            ), 3),

            cc.CallFunc:create(function()
                if result == 2 then
                    self:setButtonsEnabled(true)
                    gf:ShowSmallTips(CHS[5400602])
                else
                    self:creatBoxArmature(ResMgr.ArmatureMagic.tanan_tw_open_box.name, "Top01", "OpenUpPanel")

                    self:creatBoxArmature(ResMgr.ArmatureMagic.tanan_tw_open_box.name, "Top02", "OpenDownPanel")

                    local leftImg = self:getControl("LeftImage", nil, "TaiChiPanel")
                    local action = cc.MoveBy:create(1.3, cc.p(-leftImg:getContentSize().width - 3, 0))
                    leftImg:runAction(action)

                    local rightImg = self:getControl("RightImage", nil, "TaiChiPanel")
                    local action = cc.Sequence:create(
                        cc.MoveBy:create(1.3, cc.p(rightImg:getContentSize().width + 3, 0)),
                        cc.CallFunc:create(function()
                            self:setButtonsEnabled(true)

                            gf:CmdToServer("CMD_TWZM_RESPONSE_BOX_RESULT", {})
                            self:onCloseButton()
                        end)
                    )

                    rightImg:runAction(action)
                end
            end)
        )

        img1:runAction(fadeAction)
        img2:runAction(action)
    else
        -- 失败
        local img1 = self:getControl("WrongImage1")
        local img2 = self:getControl("WrongImage2")
        local fadeAction = cc.Repeat:create(cc.Sequence:create(
                cc.FadeIn:create(0.1),
                cc.FadeOut:create(0.1)
            ), 3)
        local action = cc.Sequence:create(
            cc.Repeat:create(cc.Sequence:create(
                cc.FadeIn:create(0.1),
                cc.FadeOut:create(0.1)
            ), 3),

            cc.CallFunc:create(function() 
                 self:setButtonsEnabled(true)
            end)
        )

        gf:ShowSmallTips(CHS[5450253])

        img1:runAction(fadeAction)
        img2:runAction(action)
    end
end

function CaseTWBoxDlg:MSG_TWZM_BOX_RESULT(data)
    self:playAction(data.result)

    self.clickNum = {0, 0, 0, 0}
    self.totalNum = 0
    self.lastClickNum = 0
end

return CaseTWBoxDlg
