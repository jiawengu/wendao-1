-- WenquanRecordDlg.lua
-- Created by huangzz Jan/21/2019
-- 玉露仙池-温泉记录界面

local WenquanRecordDlg = Singleton("WenquanRecordDlg", Dialog)

function WenquanRecordDlg:init()
    self.showAtt = false
    self:createSwichButton(self:getControl("SwitchPanel"), self.showAtt, self.onSwitchPanel)

    self.inforPanel = self:retainCtrl("InforPanel")

    self:setListView(WenQuanMgr.gameRecord)

    self:hookMsg("MSG_XCWQ_RECORD")
    self:hookMsg("MSG_XCWQ_ONE_RECORD")
end

function WenquanRecordDlg:onSwitchPanel(isOn)
    if isOn then
        self.showAtt = true
    else
        self.showAtt = false
    end

    self:setListView(WenQuanMgr.gameRecord)
end

function WenquanRecordDlg:setListView(data)
    if not data then return end

    local info = data.def_info
    local path = ResMgr.ui.wenquan_record_def_word
    if self.showAtt then
        info = data.att_info
        path = ResMgr.ui.wenquan_record_att_word
    end

    local listView = self:getControl("ListView")
    listView:removeAllItems()

    if not info or #info <= 0 then
        self:setLabelText("NumLabel", 0, "NumPanel")

        self:setCtrlVisible("NonePanel", true)
        return
    end

     self:setCtrlVisible("NonePanel", false)
    self:setLabelText("NumLabel", #info, "NumPanel")
    local size = self.inforPanel:getContentSize()
    for i = #info, 1, -1 do
        local cell = self.inforPanel:clone()
        local height, oldHeight
        if info[i].type == 1 then
            if self.showAtt then
                height, oldHeight = self:setColorText(string.format(CHS[5450467], info[i].player_name), "TextPanel", cell, nil, nil, nil, 19)
            else
                height, oldHeight = self:setColorText(string.format(CHS[5450465], info[i].player_name), "TextPanel", cell, nil, nil, nil, 19)
            end
        else
            if self.showAtt then
                height, oldHeight = self:setColorText(string.format(CHS[5450468], info[i].player_name, info[i].player_name), "TextPanel", cell, nil, nil, nil, 19)
            else
                height, oldHeight = self:setColorText(string.format(CHS[5450466], info[i].player_name), "TextPanel", cell, nil, nil, nil, 19)
            end
        end

        cell:setContentSize(size.width, size.height + math.max(0, height - oldHeight))

        cell.gid = info[i].player_gid

        self:bindTouchEndEventListener(cell, self.onInforPanel)

        self:setImage("FightImage", path, cell)
        listView:pushBackCustomItem(cell)
    end
end

function WenquanRecordDlg:onInforPanel(sender, eventType)
    if sender.gid then
        FriendMgr:requestCharMenuInfo(sender.gid, {
            needCallWhenFail = true,
            gid = sender.gid,
            requestDlg = self.name,
        })

        self.selectSender = sender
    end
end

function WenquanRecordDlg:onCharInfo(gid, isFail)
    if not self.selectSender then return end

    if isFail then
        gf:ShowSmallTips(CHS[6000139])
    else
        local dlg = DlgMgr:openDlg("CharMenuContentDlg")
        if dlg then
            dlg:setMuneType()
            dlg:setting(gid)
            local rect = self:getBoundingBoxInWorldSpace(self.selectSender)
            dlg:setFloatingFramePos(rect)
        end
    end
end

function WenquanRecordDlg:MSG_XCWQ_RECORD()
    self:setListView(WenQuanMgr.gameRecord)
end

function WenquanRecordDlg:MSG_XCWQ_ONE_RECORD()
    self:setListView(WenQuanMgr.gameRecord)
end

return WenquanRecordDlg
