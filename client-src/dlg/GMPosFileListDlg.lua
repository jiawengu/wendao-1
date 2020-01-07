-- GMPosFileListDlg.lua
-- Created by songcw Mar/06/2017
-- GM记录点文件列表

local GMPosFileListDlg = Singleton("GMPosFileListDlg", Dialog)

function GMPosFileListDlg:init()
    self:bindListener("DelButton", self.onDelButton)
    self:bindListener("ViewButton", self.onViewButton)
    self:bindListViewListener("ListView", self.onSelectListView)
    
    self.unitPanel = self:toCloneCtrl("OneFilePanel")
    self.selectImage = self:toCloneCtrl("ChosenEffectImage", self.unitPanel)
    
    self:bindTouchEndEventListener(self.unitPanel, self.onSelectFileButton)
    

    
    self:setFileList()
end

function GMPosFileListDlg:cleanup()
    self:releaseCloneCtrl("unitPanel")
    self:releaseCloneCtrl("selectImage")
end

function GMPosFileListDlg:setFileList()
    self.selectFile = nil
    self.fileList = nil
    self.pos = nil

    local list = self:resetListView("ListView")
    local fileList = RecordLogMgr:getPosRecordFile("fileName")
    self.fileList = fileList
 --   for _, ts in pairs(fileList) do
    for st = #fileList, 1 , -1 do
        local ts = fileList[st]
        local recordTime = os.time{year = string.sub(ts, 1, 4), month = string.sub(ts, 5, 6), day = string.sub(ts, 7, 8), hour = string.sub(ts, 9, 10), min = string.sub(ts, 11, 12), sec = string.sub(ts, 13, 14)}
    
        local text = os.date("%m-%d %H:%M:%S", tonumber(recordTime))
        local panel = self.unitPanel:clone()
        panel.fileName = ts
        panel.pos = st
        self:setLabelText("NameLabel", text, panel)
        list:pushBackCustomItem(panel)        
    end
end

function GMPosFileListDlg:addSelectImage(sender)
    self.selectImage:removeFromParent()
    sender:addChild(self.selectImage)
end

function GMPosFileListDlg:onSelectFileButton(sender, eventType)
    self.selectFile = sender.fileName
    self.pos = sender.pos
    self:addSelectImage(sender)
end

function GMPosFileListDlg:onDelButton(sender, eventType)
    if not self.selectFile then
        gf:ShowSmallTips(CHS[4400013]) 
        return 
    end
    
    local file = self.selectFile
    local pos = self.pos
    --[[
    local recordTime = os.time{year = string.sub(ts, 1, 4), month = string.sub(ts, 5, 6), day = string.sub(ts, 7, 8), hour = string.sub(ts, 9, 10), min = string.sub(ts, 11, 12), sec = string.sub(ts, 13, 14)}
    local file = os.date("%m-%d %H:%M:%S", tonumber(recordTime))
    --]]
    gf:confirm(string.format(CHS[4400014], file), function ()
        table.remove(self.fileList, pos)
        local allInfoFullPath, path = RecordLogMgr:getFileNamePath("fileName")
        RecordLogMgr:saveFileByTab(self.fileList, path)
        
        local posFullPath, posPath = RecordLogMgr:getFileNamePath(file)
        os.remove(posPath)
        
        local tipMsg = string.format(CHS[4400015], file, posPath)
        gf:ShowSmallTips(tipMsg)
        ChatMgr:sendMiscMsg(tipMsg)
        
        performWithDelay(self.root, function ()
            GMPosFileListDlg:setFileList()
        end,0)
    end)
end

function GMPosFileListDlg:onViewButton(sender, eventType)
    if not self.selectFile then return end
    
    local posInfos = RecordLogMgr:getPosRecordFile(self.selectFile)
    
    if not next(posInfos) then return end
    
    local dlg = DlgMgr:openDlg("GMPosListDlg")
    dlg:setListInfo(posInfos)
    
    
    local dlg1 = DlgMgr:getDlgByName("GMManageDlg")
    if dlg1 then
        dlg1:setVisible(false)
    end
    
    local dlg2 = DlgMgr:getDlgByName("GMPosFileListDlg")
    if dlg2 then
        dlg2:setVisible(false)
    end

end

function GMPosFileListDlg:onSelectListView(sender, eventType)
end

return GMPosFileListDlg
