-- ZhengDaoHuFaDlg.lua
-- Created by zhengjh Jan/92016
-- 帮派掌门

local ChallengingLeaderDlg = require('dlg/ChallengingLeaderDlg')
local ZhengDaoHuFaDlg = Singleton("ZhengDaoHuFaDlg", ChallengingLeaderDlg)

local WORD_LIMIT = 114

function ZhengDaoHuFaDlg:getCfgFileName()
    return ResMgr:getDlgCfg("ChallengingLeaderDlg")
end

function ZhengDaoHuFaDlg:init()
    self:bindListener("SaveButton", self.onSaveButton)
    self:bindListener("EditButton", self.onEditButton)
    self:hookMsg("MSG_OVERCOME_NPC_INFO")
end

function ZhengDaoHuFaDlg:onSaveButton(sender, eventType)
    self:changeEditState(false)
    local text = self:getInputText("TextField")
    text = gf:filtText(text, Me:queryBasic("gid"))
    text = BrowMgr:addGenderSign(text, self.data.gender)
    self:setInputText("TextField", text)
    self:setText(text, self.data.insider_level, Me:queryBasicInt("gender"))

    local data = {}
    data.id = self.data.id
    data.signature = text

    if self.data.dlgType == "zhengdao" then
        gf:CmdToServer("CMD_OVERCOME_SET_SIGNATURE",data)
    else
        gf:CmdToServer("CMD_HERO_SET_SIGNATURE",data)
    end
end

function ZhengDaoHuFaDlg:setLeaderInfo(data)
    self.data = data
    self:setLabelText("TitleLabel_1", data.titleContent)
    self:setLabelText("TitleLabel_2", data.titleContent)

    self:setLabelText("TitleLabel", data.titleMsg, "AttribTitle")
    ChallengingLeaderDlg.setLeaderInfo(self, data)
end

function ZhengDaoHuFaDlg:getShareType()
    if self.data and self.data.dlgType == "zhengdao" then
        -- 正道殿 护法风采
        return SHARE_FLAG.HFFC
    else
        -- 英雄殿 英雄风采
        return SHARE_FLAG.YXFC
    end
end

return ZhengDaoHuFaDlg
