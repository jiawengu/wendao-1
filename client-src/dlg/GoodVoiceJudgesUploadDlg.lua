-- GoodVoiceJudgesUploadDlg.lua
-- Created by
--

local GoodVoiceJudgesUploadDlg = Singleton("GoodVoiceJudgesUploadDlg", Dialog)

local NAME_LIMINT = 6
local MESSAGE_LIMINT = 20

function GoodVoiceJudgesUploadDlg:init()
    self:bindListener("SubmissionButton", self.onSubmissionButton)
    self:bindListener("DelButton", self.onDelButton, "NameInputPanel")
    self:bindListener("DelButton", self.onDelButton, "MessageInputPanel")
    self:bindListener("HeadButton", self.onHeadButton)

    self.filePath = ""

    -- 昵称
    self:bindEditFieldForSafe("NameInputPanel", NAME_LIMINT, "DelButton", cc.TEXT_ALIGNMENT_LEFT, nil, true)

    -- 评委简介
    self:bindEditFieldForSafe("MessageInputPanel", MESSAGE_LIMINT, "DelButton", cc.TEXT_ALIGNMENT_LEFT, nil, true)
end

function GoodVoiceJudgesUploadDlg:onSubmissionButton(sender, eventType)

    if self.filePath == "" then
        gf:ShowSmallTips(CHS[4200656])
        return
    end

    local name = self:getInputText("TextField", "NameInputPanel")
    if name == "" then
        gf:ShowSmallTips(CHS[4200657])    -- 你没有设置昵称！
        return
    end

    local desc = self:getInputText("TextField", "MessageInputPanel")
    if desc == "" then
        gf:ShowSmallTips(CHS[4200658])     -- 你没有设置简介！
        return
    end


    -- 屏蔽敏感字
    local name, haveFiltName = gf:filtText(name)
    if haveFiltName then
        self:setInputText("TextField", name, "NameInputPanel")
    end

    local desc, haveFiltDesc = gf:filtText(desc)
    if haveFiltDesc then
        self:setInputText("TextField", desc, "MessageInputPanel")
    end

    if haveFiltDesc or haveFiltName then
        return
    end

    gf:CmdToServer("CMD_GOOD_VOICE_ADD_JUDGE", { name = name, desc = desc, icon_addr = self.filePath})
end


-- 头像上传完成
function GoodVoiceJudgesUploadDlg:onFinishUploadIcon(files, uploads)
    if #files ~= #uploads then
        gf:ShowSmallTips(CHS[2000447])
        ChatMgr:sendMiscMsg(CHS[2000447])
        return
    end

    self.filePath = uploads[1]
end


function GoodVoiceJudgesUploadDlg:onDelButton(sender, eventType)
    local parentPanel = sender:getParent()
    local textCtrl = self:getControl("TextField", nil, parentPanel)
    textCtrl:setText("")
    sender:setVisible(false)
    self:setCtrlVisible("DefaultLabel", true, parentPanel)
end

function onGoodVoiceJudgesUploadDlgPortraitUpload(filePath)
    if string.isNilOrEmpty(filePath) then return end

    filePath = string.trim(string.gsub(filePath, "\\/", "/"))
    local s = string.sub(filePath, 1, 1)
    if '{' == s then
        local data = json.decode(filePath)
        if 'save' == data.action then
            filePath = data.path
        else
            return
        end
    end

    DlgMgr:sendMsg("GoodVoiceJudgesUploadDlg", "uploadPortrait", filePath)
end

function GoodVoiceJudgesUploadDlg:uploadPortrait(filePath)
    if string.isNilOrEmpty(filePath) then return end
    self:setImage("GuardImage", filePath)
    BlogMgr:cmdUpload(BLOG_OP_TYPE.GOOD_VOICE_ICON, self.name, "onFinishUploadIcon", filePath)
end

function GoodVoiceJudgesUploadDlg:onHeadButton(sender, eventType)
    local cw, ch = BlogMgr:getPortraitClipRange()
    BlogMgr:comDoOpenPhoto(0, "onGoodVoiceJudgesUploadDlgPortraitUpload", cc.size(cw, ch), cc.size(256, 256), 80)
end

return GoodVoiceJudgesUploadDlg
