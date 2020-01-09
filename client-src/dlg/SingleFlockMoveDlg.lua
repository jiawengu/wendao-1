-- SingleFlockMoveDlg.lua
-- Created by zhengjh   Aug/03/2016
-- 移动到某个分组菜单

local SingleFlockMoveDlg = Singleton("SingleFlockMoveDlg", Dialog)
local CELL_SPACE = 5

function SingleFlockMoveDlg:init()
    self.menuButton = self:getControl("MenuButton2")
    self.menuButton:retain()
    self.menuButton:removeFromParent()
    self.menuButton:setAnchorPoint(0.5, 0)
    self.root:setAnchorPoint(0, 0)
end

function SingleFlockMoveDlg:setMoveGidsString(fromGroupId, gidsStr, nameListStr)
    self.gidsStr = gidsStr
    self.fromGroupId = fromGroupId
    self.nameListStr = nameListStr
    self:setGroupList()
end

function SingleFlockMoveDlg:setGroupList()
    local data = FriendMgr:getFriendGroupData(self.fromGroupId)
    local count = #data
    local mainPanel = self:getControl("MainPanel")
    local totalHeight = CELL_SPACE + 2
    
    for i = count , 1, - 1 do
        local btn = self.menuButton:clone()
        self:setCellData(btn, data[i])
        btn:setPosition(mainPanel:getContentSize().width / 2, totalHeight)
        totalHeight = totalHeight + btn:getContentSize().height + CELL_SPACE
        mainPanel:addChild(btn)
        
        local function listener(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:sendMoveFriends(data[i])
                
                DlgMgr:sendMsg("FriendOperationDlg", "setGroup", data[i])
            end
        end

        btn:addTouchEventListener(listener)
    end
    
    mainPanel:setContentSize(mainPanel:getContentSize().width, totalHeight + 2)
    self.root:setContentSize(mainPanel:getContentSize())
end

function SingleFlockMoveDlg:sendMoveFriends(group)
    local data = {}
    data.formGroupId = self.fromGroupId
    data.toGroupId = group.groupId
    data.gidListStr = self.gidsStr
    data.nameListStr = self.nameListStr
    gf:CmdToServer("CMD_MOVE_FRIEND_GROUP", data)
    DlgMgr:closeDlg(self.name)
   -- DlgMgr:closeDlg("FlockMoveDlg")
end

function SingleFlockMoveDlg:setCellData(cell, data)
    cell:setTitleText(data.name)
end

function SingleFlockMoveDlg:cleanup()
    self:releaseCloneCtrl("menuButton")
    self.gidsStr = nil
    self.fromGroupId = nil
    self.nameListStr = nil
end

return SingleFlockMoveDlg
