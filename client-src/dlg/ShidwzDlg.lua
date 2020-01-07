-- ShidwzDlg.lua
-- Created by liuhb Apr/13/2015
-- 试道排行榜

local ShidwzDlg = Singleton("ShidwzDlg", Dialog)
local MARGIN = 1
local ITEM_HEIGHT = 40

local LEVEL_STR =
{
    [60] = "60 - 79" .. CHS[7002280],
    [80] = "80 - 89" .. CHS[7002280],
    [90] = "90 - 99" .. CHS[7002280],
    [100] = "100 - 109" .. CHS[7002280],
    [110] = "110 - 119" .. CHS[7002280],
    [120] = "120 - 129" .. CHS[7002280],
}

function ShidwzDlg:init()
    self:initCtrl()
end

-- 初始化控件
function ShidwzDlg:initCtrl()
    self.bigPanel = self:getControl("BigPanel")
    self.bigChosenEff = self:getControl("BChosenEffectImage", nil, self.bigPanel)
    self.bigChosenEff:removeFromParent()
    self.bigChosenEff:retain()
    
    self.bigPanel:retain()
    self.bigPanel:removeFromParent()


    self.bigStr = 80

    self.levelCell = self:getControl("LevelCellPanel")
    self.levelCellEff = self:getControl("ChoseImage_0", nil, self.levelCell)
    self.levelCellEff:retain()
    self.levelCellEff:removeFromParent()

    self.levelCell:retain()
    self.levelCell:removeFromParent()

    -- 事件监听
    self:bindListener("ChoseButton", self.onChoseButton)
    
    self:setCtrlVisible("LevelListPanel", false)
end

function ShidwzDlg:cleanup()
    self:releaseCloneCtrl("bigPanel")
    self:releaseCloneCtrl("bigChosenEff")
    self:releaseCloneCtrl("levelCell")
    self:releaseCloneCtrl("levelCellEff")
end

function ShidwzDlg:close(now)
    Dialog.close(self, now)
end


function ShidwzDlg:addEffChosenBig(sender)
    self.bigChosenEff:removeFromParent()
    sender:addChild(self.bigChosenEff)
end

function ShidwzDlg:addEffChosenLevel(sender)
    self.levelCellEff:removeFromParent()
    sender:addChild(self.levelCellEff)
end

function ShidwzDlg:setTeamInfo(teamInfos, sTag)
    if not teamInfos[self.bigStr] or not teamInfos[self.bigStr][sTag] then  return end 
    local info = teamInfos[self.bigStr][sTag]

    for i = 1, 5 do
        if i > info.memberCount then
            local panel = self:getControl("MemberPanel_" .. i)
            panel:setVisible(false)
        else
            local panel = self:getControl("MemberPanel_" .. i)
            panel:setVisible(true)
            self:setTeamInfoCell(info.team[i], panel)
        end    
    end
end

function ShidwzDlg:setTeamInfoCell(data, cell)
    -- 人物等级使用带描边的数字图片显示
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, cell)
    self:setImage("UserImage", ResMgr:getSmallPortrait(data.icon or 6002), cell)
    self:setItemImageSize("UserImage", cell)
    self:setLabelText("MemberNameLabel", gf:getRealName(data.memberName), cell)
    self:setLabelText("MemberIDLabel", "ID:"..(gf:getShowId(data.gid) or "65644"), cell)
    
    if data.isLeader == 1 then
        self:setCtrlVisible("TeamLeaderImage", true, cell)
    else
        self:setCtrlVisible("TeamLeaderImage", false, cell)    
    end
    
    cell:requestDoLayout()
end

-- 更新左侧列表
function ShidwzDlg:updateShidList(data, teamInfos)
    self.data = data
    self.teamInfos = teamInfos 
    self.bigStr = data[1].level
    self:initTimeList(data[1]["timeList"])
    self:setChoseTitle(LEVEL_STR[data[1].level])
    self:initLevelPanel(data)
end

function ShidwzDlg:initTimeList(data)
    local listView = self:getControl("ListView")
    listView:removeAllChildren()
    for i = 1, #data do
        listView:pushBackCustomItem(self:setTimeCell(data[i], i))
    end
end

function ShidwzDlg:setTimeCell(data, index)
    local cell = self.bigPanel:clone()
    self:setLabelText("TimeLabel", data.timestr, cell)

    self:setCtrlVisible("MonthImage", data.isMonth == 1, cell)
    
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:addEffChosenBig(sender)
            self:setTeamInfo(self.teamInfos, data.time)
        end
    end
    
    -- 默认选中第一个
    if index == 1 then
        self:addEffChosenBig(cell)
        self:setTeamInfo(self.teamInfos, data.time)
    end

    cell:addTouchEventListener(listener)
    return cell
end

function ShidwzDlg:onChoseButton(sender, eventType)
    local levelPanel = self:getControl("LevelListPanel")
    if levelPanel:isVisible() then
        levelPanel:setVisible(false)
    else
        levelPanel:setVisible(true)
    end
end

function ShidwzDlg:initLevelPanel(data)
    local panel = self:getControl("LevelListPanel")
    local levelListView = self:getControl("LevelListView")
    if not data or #data == 0 then  return end
    
    levelListView:setContentSize(levelListView:getContentSize().width, (self.levelCell:getContentSize().height + 5)* #data - 5)
	for i = 1, #data  do
        local cell = self.levelCell:clone()
        self:setLabelText("NameLabel", LEVEL_STR[data[i]["level"]], cell)
          
        local function listener(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:addEffChosenLevel(sender)
                self.bigStr = data[i]["level"]
                self:initTimeList(data[i]["timeList"])
                self:setChoseTitle(LEVEL_STR[self.bigStr])
                self:onChoseButton()
            end
        end

        cell:addTouchEventListener(listener)
        
        levelListView:pushBackCustomItem(cell)
	end
	
    panel:setContentSize(panel:getContentSize().width, levelListView:getContentSize().height + 15)
    panel:requestDoLayout()
end

function ShidwzDlg:setChoseTitle(str)
    self:setLabelText("TitleNameLabel", str)
end

return ShidwzDlg
