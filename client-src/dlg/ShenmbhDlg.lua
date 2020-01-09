-- ShenmbhDlg.lua
-- Created by huangzz Dec/27/2018
-- 神秘宝盒界面

local ShenmbhDlg = Singleton("ShenmbhDlg", Dialog)

local COLORS = {
    [CHS[5450429]] = cc.c3b(0xdf, 0x0a, 0x0a),
    [CHS[5450430]] = cc.c3b(0x00, 0xA8, 0x06),
    [CHS[5450431]] = cc.c3b(0x00, 0x7E, 0xFF),
    [CHS[5450432]] = cc.c3b(0x00, 0x00, 0x00),
    [CHS[5450433]] = cc.c3b(0xFF, 0xFF, 0x00),
    [CHS[5450434]] = cc.c3b(0x81, 0x1f, 0xd5),
    [CHS[5450435]] = cc.c3b(0xff, 0xb2, 0xfe),
    [CHS[5450436]] = cc.c3b(0x4C, 0x20, 0x00),
    [CHS[5450437]] = cc.c3b(0x00, 0xFF, 0xFF),
    [CHS[5450438]] = cc.c3b(0xFF, 0xFF, 0xFF),
}

function ShenmbhDlg:init()
    self:bindListener("CloseButton_1", self.onCloseButton)
    self:bindListener("SubmitButton", self.onSubmitButton)
    self:bindListener("ViewButton", self.onViewButton)

    self.onOpenNumInputFuncs = {}
    for i = 1, 4 do
        self.onOpenNumInputFuncs[i] = self:bindNumInput("AnswerPanel_" .. i, nil, nil, i)
    end

    self.nums = {}
    self.isOpen = false

    self:createArmatureAction(ResMgr.ArmatureMagic.shenm_baohe.name)

    self:hookMsg("MSG_SUMMER_2019_SMSZ_SMBH_RESULT")
    self:hookMsg("MSG_SUMMER_2019_SMSZ_SMBH")
end

-- 播放骨骼动画
function ShenmbhDlg:createArmatureAction(icon)
    local magic = ArmatureMgr:createArmature(icon)

    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.complete and self.curMagic then
            self.curMagic:getAnimation():play("Top03")
        end
    end

    magic:getAnimation():setMovementEventCallFunc(func)

    local modelPanel = self:getControl("ModelPanel")
    magic:setAnchorPoint(0.5, 0.5)
    local size = modelPanel:getContentSize()
    magic:setPosition(size.width / 2 - 13, size.height / 2 - 17)
    modelPanel:addChild(magic)

    magic:getAnimation():play("Top01", -1, 1)

    self.curMagic = magic
end
function ShenmbhDlg:onSubmitButton(sender, eventType)
    -- 若宝盒已打开，给与弹出提示
    if self.isOpen then
        gf:ShowSmallTips(CHS[5450439])
        return
    end

    local cou = 0
    for i = 1, 4 do
        if not self.nums[i] then
            break
        end

        cou = i
    end

    -- 若有任意输入框为空，给与弹出提示
    if cou < 4 then
        gf:ShowSmallTips(CHS[5450440])
        return
    end

    gf:CmdToServer("CMD_SUMMER_2019_SMSZ_SMBH_COMMIT", {num_str = table.concat(self.nums, "|")})
end

function ShenmbhDlg:onViewButton(sender, eventType)
    gf:CmdToServer("CMD_SUMMER_2019_SMSZ_SMHJ_OPEN", {})
end

function ShenmbhDlg:MSG_SUMMER_2019_SMSZ_SMBH_RESULT(data)
    if not self.curMagic then return end

    if data.result == 1 then
        self.curMagic:getAnimation():play("Top02")
        self.isOpen = true
        self:setLabelText("Label", CHS[5450449], "InfoPanel")
        self:setCtrlVisible("SubmitButton", false)
        self:setCtrlVisible("ViewButton", false)
        self:setCtrlVisible("CloseButton_1", true)
    end
end

-- 数字键盘插入数字
function ShenmbhDlg:insertNumber(num, key, type)
    if num < 0 then
        num = 0
    end

    if type == "delete" then
        self.nums[key] = nil
        self:setLabelText("Label", "", "AnswerPanel_" .. key)
    else
        if key < 4 then
            self.onOpenNumInputFuncs[key + 1]()
        else
            DlgMgr:closeDlg("SmallNumInputDlg")
        end

        self.nums[key] = num
        self:setLabelText("Label", num, "AnswerPanel_" .. key)
    end

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    DlgMgr:sendMsg("SmallNumInputDlg", "setInputValue", 0)
end

function ShenmbhDlg:MSG_SUMMER_2019_SMSZ_SMBH(data)
    for i = 1, 4 do
        local info = data[i]
        self:setCtrlColor("ColorImage", COLORS[info.color], "ColorPanel_" .. i)
    end

    local nums = gf:split(data.num_str, "|")
    for i = 1, #nums do
        local num = tonumber(nums[i])
        if num then
            self:setLabelText("Label", num, "AnswerPanel_" .. i)
            self.nums[i] = num
        end
    end

    if not self.curMagic then return end

    if data.result == 1 and not self.isOpen then
        self.curMagic:getAnimation():play("Top03")
        self.isOpen = true
    end

    if data.result == 0 and self.isOpen then
        self.curMagic:getAnimation():play("Top01")
        self.isOpen = false
    end

    self:setLabelText("Label", self.isOpen and CHS[5450449] or CHS[5450448], "InfoPanel")
    self:setCtrlVisible("SubmitButton", not self.isOpen)
    self:setCtrlVisible("ViewButton", not self.isOpen)
    self:setCtrlVisible("CloseButton_1", self.isOpen)
end

function ShenmbhDlg:cleanup()
    self.curMagic = nil

    gf:CmdToServer("CMD_SUMMER_2019_SMSZ_SMBH_STOP", {})
end

return ShenmbhDlg
