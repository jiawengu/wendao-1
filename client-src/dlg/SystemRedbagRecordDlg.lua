-- SystemRedbagRecordDlg.lua
-- Created by zhengjh Sep/19/2016
-- 系统红包记录

local SystemRedbagRecordDlg = Singleton("SystemRedbagRecordDlg", Dialog)
local COLUMN = 2

-- 奖励类型
local REWARD_TYPE =
{
    TYPE_BONUS_VOUCHER    =  0,   -- 奖励代金券
    TYPE_BONUS_CASH       =  1,   -- 奖励金钱
    TYPE_BONUS_SILVER     =  2,   -- 奖励银元宝
    TYPE_BONUS_GOLDEN     =  3,   -- 奖励金元宝
    TYPE_BONUS_ITEM       =  4,   -- 奖励道具
    TYPE_BONUS_EQUIP      =  5,   -- 奖励装备
    TYPE_BONUS_TAO        =  6,   -- 奖励道行
    TYPE_BONUS_CG_CARD    =  7,   -- 奖励变身卡
    TYPE_BONUS_JEWELRY    =  8,   -- 奖励首饰
}

function SystemRedbagRecordDlg:init()
    self:bindListener("NoteButton", self.onNoteButton)
    
    self.oneRedBagRow = self:getControl("OneRowRecordPanel")
    self.oneRedBagRow:retain()
    self.oneRedBagRow:removeFromParent()

    self.redBagCell = self:getControl("RecordPanel_1", nil, self.oneRedBagRow)
    self.redBagCell:retain()
    self.redBagCell:removeFromParent()
    
    gf:CmdToServer("CMD_QUANFU_HONGBAO_RECORD")
    self:hookMsg("MSG_QUANFU_HONGBAO_RECORD")
    
    -- 关闭tip
    self:bindCloseTips()
    
    -- 规则界面（根据线路数目不同，规则界面显示内容不同）
    self:refreshRulePanel()
end

function SystemRedbagRecordDlg:refreshRulePanel()
    self:setColorText(CHS[7150130], "Panel6", "RulePanel", nil, nil, COLOR3.WHITE, 19)

    if GameMgr:getTotalLieNum() and GameMgr:getTotalLieNum() <= 6 then
        self:setCtrlVisible("Panel4", false, "RulePanel")
        self:setCtrlVisible("Label4_OTHER", true, "RulePanel")
    else
        self:setCtrlVisible("Panel4", true, "RulePanel")
        local lineNum = ActivityMgr:getActivityExtraInfo("quanfu_hongbao")
        if lineNum then
            self:setColorText(string.format(CHS[7150128], lineNum), "Panel4", "RulePanel", nil, nil, COLOR3.WHITE, 19)
        end

        self:setCtrlVisible("Label4_OTHER", false, "RulePanel")
    end
end

function SystemRedbagRecordDlg:initInfo(data)
    -- 抢到红包个数
    self:setLabelText("GetNumLabel_2", data.size or 0)
    
    -- 初值抢到红包列表
    self:initRecordList(data.list, data.size or 0)
end

function SystemRedbagRecordDlg:initRecordList(data, count)

    local count = count

    if count == 0 then
        self:setCtrlVisible("EmptyPanel", true)
        self:setCtrlVisible("MyRecordListView", false)
        return
    end


    local listView = self:getControl("MyRecordListView")
    listView:removeAllChildren()
    listView:setVisible(true)
    self:setCtrlVisible("EmptyPanel", false)

    local line = math.floor(count / COLUMN)
    local left = count % COLUMN

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0

   --[[ for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = COLUMN
        end

        local oneRow = self:createRow(data, i, curColunm)
        listView:pushBackCustomItem(oneRow)
    end]]
    
    local loadcount = 0
    local count = line

    local function func()
        if loadcount >= count  then 
            self.root:stopAllActions()
            return 
        end

        loadcount = loadcount + 1

        if loadcount == line and left ~= 0 then
            curColunm = left
        else
            curColunm = COLUMN
        end

        local oneRow = self:createRow(data, loadcount, curColunm)
        listView:pushBackCustomItem(oneRow)
    end

    schedule(self.root, func, 0.02)
end

function SystemRedbagRecordDlg:createRow(data, line, column)
    local row = self.oneRedBagRow:clone()
    for i = 1, column do
        local tag = (line - 1) * COLUMN + i
        local cell = self:createCell(data[tag])
        cell:setAnchorPoint(0, 1)
        local x = (cell:getContentSize().width + 10) * (i - 1)
        local y = cell:getContentSize().height
        cell:setPosition(x, y)
        row:addChild(cell)
        row:requestDoLayout()
    end

    return row
end

function SystemRedbagRecordDlg:createCell(data)
    local cell = self.redBagCell:clone()
    local list = gf:split(data.text, "|")
    local info = {}
    info.time = tonumber(list[1])
    info.type = tonumber(list[2])
    info.content = list[3]
    info.count = list[4]
    
    local path, text, color = SystemRedbagRecordDlg:getIconPathAndText(info)
    
    self:setLabelText("TimeLabel", gf:getServerDate("%m-%d %H:%M:%S", info.time or  0), cell)
    self:setLabelText("BonusLabel", text, cell, color)
    self:setImagePlist("BonusImage", path, cell)
    
    return cell
end

function SystemRedbagRecordDlg:getIconPathAndText(data)
    -- 奖励图片
    local name = ""
    local text = ""
    local color = nil

    if data.type == REWARD_TYPE.TYPE_BONUS_CASH then
        name = CHS[3002143]
        local cashText, textcolor = gf:getMoneyDesc(tonumber(data.count), true)
        text = cashText
        color = textcolor
    elseif data.type == REWARD_TYPE.TYPE_BONUS_TAO then
        name = CHS[3002147]
        text = data.content
    elseif data.type == REWARD_TYPE.TYPE_BONUS_SILVER then
        name = CHS[6000042]
        text = data.count
    elseif data.type == REWARD_TYPE.TYPE_BONUS_ITEM then
        name = CHS[3002166]
        text = data.content
    elseif data.type == REWARD_TYPE.TYPE_BONUS_VOUCHER then
        name = CHS[3002145]
        text = data.count
    elseif data.type == REWARD_TYPE.TYPE_BONUS_GOLDEN then    
        name = CHS[3002153]
        text = data.count
    elseif data.type == REWARD_TYPE.TYPE_BONUS_EQUIP then        
        name = CHS[3002170]
        text = data.content
    elseif data.type == REWARD_TYPE.TYPE_BONUS_CG_CARD then     
        name = CHS[6200002]
        text = data.content
    elseif data.type == REWARD_TYPE.TYPE_BONUS_JEWELRY then        
        name = CHS[3002168]
        text = data.content
    end
     
    return TaskMgr:getSamllImage(name), text, color
end

function SystemRedbagRecordDlg:MSG_QUANFU_HONGBAO_RECORD(data)
    self:initInfo(data)
end

function SystemRedbagRecordDlg:bindCloseTips()
    local panel = self:getControl("RulePanel")
    local bkPanel = self:getControl("BKPanel")
    local layout = ccui.Layout:create()
    layout:setContentSize(bkPanel:getContentSize())
    layout:setPosition(bkPanel:getPosition())
    layout:setAnchorPoint(bkPanel:getAnchorPoint())
    self:setCtrlVisible("RulePanel", false)

    local  function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(panel)
        local toPos = touch:getLocation()
        if not cc.rectContainsPoint(rect, toPos) and panel:isVisible() then
            self:setCtrlVisible("RulePanel", false)
            return true
        end
    end

    self.root:addChild(layout, 10, 1)
    gf:bindTouchListener(layout, touch)
end


function SystemRedbagRecordDlg:onNoteButton(sender, eventType)
    local panel = self:getControl("RulePanel")
    if panel:isVisible()  then
        self:setCtrlVisible("RulePanel", false)
    else
        self:setCtrlVisible("RulePanel", true)
    end 
end

function SystemRedbagRecordDlg:cleanup()
    self:releaseCloneCtrl("oneRedBagRow")
    self:releaseCloneCtrl("redBagCell")
end

return SystemRedbagRecordDlg
