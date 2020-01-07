-- SeekFriendMapDlg.lua
-- Created by
--

local SeekFriendMapDlg = Singleton("SeekFriendMapDlg", Dialog)

function SeekFriendMapDlg:init(data)
    self:bindListener("KnowButton", self.onKnowButton)
    self:bindListener("TellButton", self.onTellButton)
end

function SeekFriendMapDlg:onDlgOpened(para)

    local mapName = para[1]
    local mapId = MapMgr:getMapByName(mapName)

    local fileName = self:getSmallMapFile(mapId)
    local image = self:setImage("Image_1", fileName, "MainPanel")
    local size = image:getContentSize()

    image:setContentSize(450, 300)
    local parentPanel = image:getParent()
    parentPanel:requestDoLayout()
end

-- 获取小地图文件
function SeekFriendMapDlg:getSmallMapFile(id, floor_index, wall_index)
    if MapMgr:getMapinfo()[id] == nil then return end
    local map_id = MapMgr:getMapinfo()[id].map_id
    if floor_index and wall_index then
        return string.format("maps/smallMaps/%05d_%02d_%02d.jpg", map_id, floor_index, wall_index)
    else
        return string.format("maps/smallMaps/%05d.jpg", map_id)
    end
end

function SeekFriendMapDlg:onKnowButton(sender, eventType)
    self:onCloseButton()
end

function SeekFriendMapDlg:onTellButton(sender, eventType)

    local task = TaskMgr:getTaskByName(CHS[4010227])
    if task.task_extra_para ~= "6" then
        gf:ShowSmallTips(CHS[4300486])      -- 任务状态已发生变化！
        self:onCloseButton()
        return
    end

    DlgMgr:sendMsg("ChatDlg", "onChatButton")
    DlgMgr:sendMsg("ChannelDlg", "selectChannel", "TeamCheckBox")
    self:onCloseButton()
end

return SeekFriendMapDlg
