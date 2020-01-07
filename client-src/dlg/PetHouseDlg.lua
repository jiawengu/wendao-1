-- PetHouseDlg.lua
-- Created by sujl, May/30/2018
-- 宠物小屋界面

local PetHouseDlg = Singleton("PetHouseDlg", Dialog)

function PetHouseDlg:init(param)
    self.id = param
    local furniture = HomeMgr:getFurnitureById(self.id)
    self.curX, self.curY = furniture.curX, furniture.curY

    self:refreshPetNum()

    self:bindListener("NumButton", self.onNumButton)
    self:bindListener("AccessButton", self.onAccessButton)

    self:hookMsg("MSG_HOUSE_PET_STORE_DATA")
    self:hookMsg("MSG_STORE")

    EventDispatcher:addEventListener("EVENT_JOIN_TEAM", self.onJoinTeam, self)
end

function PetHouseDlg:cleanup()
    self.id = nil
    EventDispatcher:removeEventListener("EVENT_JOIN_TEAM", self.onJoinTeam, self)
end

function PetHouseDlg:getPetNum()
    if not StoreMgr.storeHousePets then return 0 end

    local c = 0
    for _, v in pairs(StoreMgr.storeHousePets) do
        if v then
            c = c + 1
        end
    end

    return c
end

-- 刷新宠物数量
function PetHouseDlg:refreshPetNum()
    if not self.id then return end
    local storeData = HomeMgr:getHousePetStoreData()
    if not storeData then return end
    local count = self:getPetNum()
    local maxCount = storeData.cur_size or 0
    self:setLabelText("NumLabel", string.format("%d/%d", count, maxCount), "NumPanel")
end

-- 增加宠物数量
function PetHouseDlg:onNumButton(sender)
    local furn = HomeMgr:getFurnitureById(self.id)
    if not furn then
        gf:ShowSmallTips(CHS[4200431])
        self:onCloseButton()
        return
    elseif furn.curX ~= self.curX or furn.curY ~= self.curY then
        gf:ShowSmallTips(CHS[4200418])
        self:onCloseButton()
        return
    end

    local storeData = HomeMgr:getHousePetStoreData()
    if not storeData then return end
    local maxCount = storeData.cur_size or 0
    if maxCount >= 10 then
        gf:ShowSmallTips(CHS[2100226])
        return
    end

    DlgMgr:openDlgEx("PetHouseBuyDlg", self.id)
end

-- 存取宠物
function PetHouseDlg:onAccessButton(sender)
    local furn = HomeMgr:getFurnitureById(self.id)
    if not furn then
        gf:ShowSmallTips(CHS[4200431])
        self:onCloseButton()
        return
    elseif furn.curX ~= self.curX or furn.curY ~= self.curY then
        gf:ShowSmallTips(CHS[4200418])
        self:onCloseButton()
        return
    end

    DlgMgr:openDlgEx("HousePetStoreDlg", self.id)
end

function PetHouseDlg:onJoinTeam()
    self:onCloseButton()
end

function PetHouseDlg:MSG_HOUSE_PET_STORE_DATA(data)
    self:refreshPetNum()
end

function PetHouseDlg:MSG_STORE()
    self:refreshPetNum()
end

return PetHouseDlg