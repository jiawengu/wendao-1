-- PartyRedBagDlg.lua
-- Created by zhengjh Aug/26/2016
-- 帮派红包

local PartyRedBagDlg = Singleton("PartyRedBagDlg", Dialog)
local COLUMN = 4

function PartyRedBagDlg:init()
    self:bindListener("PartyRedBagRecordButton", self.onPartyRedBagRecordButton)
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("GiveRedBagButton", self.onGiveRedBagButton)
    
    self.oneRow = self:getControl("OneRowPanel")
    self.oneRow:retain()
    self.oneRow:removeFromParent()
    
    self.cell = self:getControl("PartyRedPacketsPanel_1", nil, self.oneRow)
    self.cell:retain()
    self.cell:removeFromParent()
    
    -- 请求帮派红包数据
    PartyMgr:requestPartyRedbagList()
    
    DlgMgr:sendMsg("ChatDlg", "removeRedbagImage")
    
    local listView = self:getControl("ListView")
    listView:removeAllChildren()
    
    self:hookMsg("MSG_PT_RB_LIST")
    self:hookMsg("MSG_PT_RB_RECV_REDBAG")
end

function PartyRedBagDlg:MSG_PT_RB_LIST()
    self:initListView()
end

function PartyRedBagDlg:initListView()
    local data = PartyMgr:getRedbagLsit()
    if not data then return end
    
    local count = #data
    local listView = self:getControl("ListView")
    listView:removeAllChildren()
    
    if count == 0 then
        self:setCtrlVisible("GetRedBagNoticePanel_0", true)
        return
    else
        self:setCtrlVisible("GetRedBagNoticePanel_0", false)    
    end
    
    local line = math.floor(count / COLUMN)
    local left = count % COLUMN

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    
    local curRow = 1
    local function createRow()
        if curRow > line then
            listView:stopAllActions()
            return
        end
        
        if curRow == line and left ~= 0 then
            curColunm = left
        else
            curColunm = COLUMN
        end

        local oneRow = self:createOneRow(data, curRow, curColunm)
        listView:pushBackCustomItem(oneRow)
        
        curRow = curRow + 1
        
       --[[ if line > 1 and curRow == 2 then -- 第一个行多加载一行
            local oneRow = self:createOneRow(data, curRow, curColunm)
            listView:pushBackCustomItem(oneRow)

            curRow = curRow + 1
        end]]
    end
    
    schedule(listView , createRow, 0)
end

function PartyRedBagDlg:createOneRow(data, line, column)
    local row = self.oneRow:clone()
    for i = 1, column do
        local tag = (line - 1) * COLUMN + i
        local cell = self.cell:clone()
        self:setData(cell, data[tag])
        cell:setAnchorPoint(0, 1)
        local x = (cell:getContentSize().width + 10) * (i - 1)
        local y = cell:getContentSize().height
        cell:setPosition(x, y)
        row:addChild(cell)
        row:requestDoLayout()
    end

    return row
end

function PartyRedBagDlg:setData(cell, data)
	self:setLabelText("LeaveMessageLabel_1", data.msg, cell)
	self:setLabelText("LeaveMessageLabel_2", data.msg, cell)
	
    self:setLabelText("NameLabel", gf:getRealName(data.senderName), cell)
    
    --[[if data.state == 1 and data.is_recv == 0 then -- 未拆开红包
        self:setCtrlVisible("PartyRedPacketsTipsLabel_1", false, cell)
        self:setCtrlVisible("PartyRedPacketsTipsLabel_2", true, cell)
    else]]
        self:setCtrlVisible("PartyRedPacketsTipsLabel_1", true, cell)
        self:setCtrlVisible("PartyRedPacketsTipsLabel_2", false, cell)
    --end
    
    local function openRedBag(sender, type)
        if ccui.TouchEventType.ended == type then
            if data.state == 1 and data.is_recv == 0  then
                if Me:queryInt("level") < 50 then
                    gf:ShowSmallTips(CHS[6000446])
                    return
                end
    
                if Me:queryBasic("party/name") == "" then
                    gf:ShowSmallTips(CHS[6000461])
                    return
                end
                
                PartyMgr:openRedBag(data.redbag_gid)
        	else
                PartyMgr:lookupRedbag(data.redbag_gid)
        	end
    	end
    end
    
    cell:setName(tostring(data.redbag_gid))
    cell:addTouchEventListener(openRedBag)
	
	return cell
end

function PartyRedBagDlg:onPartyRedBagRecordButton(sender, eventType)
    DlgMgr:openDlg("PartyRedBagMoneyRecordDlg")
end

function PartyRedBagDlg:onNoteButton(sender, eventType)
    DlgMgr:openDlg("GetPartyRedBagRuleDlg")
end

function PartyRedBagDlg:onGiveRedBagButton(sender, eventType)
    DlgMgr:openDlg("PartyOutRedBagDlg")
end

function PartyRedBagDlg:MSG_PT_RB_RECV_REDBAG(data)
    local listview = self:getControl("ListView")
    local container = listview:getInnerContainer()
    local item = self:getControl(tostring(data.redbag_gid), nil, container)
    local redbagInfo = PartyMgr:getRedbagInfoByGid(data.redbag_gid)
    redbagInfo.is_recv = data.is_recv
    redbagInfo.state = data.state
    
    if redbagInfo and item then
        self:setData(item, redbagInfo)
    end
end

function PartyRedBagDlg:cleanup()
    self:releaseCloneCtrl("oneRow")
    self:releaseCloneCtrl("cell")
end

return PartyRedBagDlg
