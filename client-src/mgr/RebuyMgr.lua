-- RebuyMgr.lua
-- created by zhengjh Feb/17/2016
-- 回购管理器

local Bitset = require('core/Bitset')
local DataObject = require('core/DataObject')
RebuyMgr = Singleton()

-- 请求名片信息
function RebuyMgr:requireCardInfo(goodId, rect, type)
    self.rect = rect

    -- 存在缓存
    if self.cardInfoList and  self.cardInfoList[goodId] then
        if type == 1 then -- 宠物
            self:MSG_BUYBACK_PET_CARD(self.cardInfoList[goodId])
        else
            self:MSG_BUYBACK_ITEM_CARD(self.cardInfoList[goodId])
        end
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REQUEST_BUYBACK_CARD, goodId)
    end
end

-- 返回回购商品信息
function RebuyMgr:MSG_BUYBACK_ITEM_CARD(data)
    -- 显示名片
    self:showItemFloatBox(data)

    if self.cardInfoList == nil then
        self.cardInfoList = {}
    end
    self.cardInfoList[data.id] = data
end

-- 显示道具名片
function RebuyMgr:showItemFloatBox(data, rect)
    local cardInfo = data.item
    local equipType = cardInfo["equip_type"]
    cardInfo.attrib = Bitset.new(cardInfo.attrib)
    InventoryMgr:showOnlyFloatCardDlgEx(cardInfo, self.rect)
end

-- 返回回购宠物信息
function RebuyMgr:MSG_BUYBACK_PET_CARD(data)
    local objcet = DataObject.new()
    data.raw_name = PetMgr:getShowNameByRawName(data.raw_name)
    data.icon =  PetMgr:getPetIcon(data.raw_name)
    data.id = 0
    objcet:absorbBasicFields(data)

     -- 显示名片
     self:showPetFloatBox(objcet)

    if self.cardInfoList == nil then
        self.cardInfoList = {}
    end

    self.cardInfoList[data.goodId] = data
end

function RebuyMgr:showPetFloatBox(pet)
    local dlg =  DlgMgr:openDlg("PetCardDlg")
    dlg:setPetInfo(pet)
end

function RebuyMgr:MSG_BUYBACK_LIST(data)
    local dlg = DlgMgr:getDlgByName("RebuyDlg")
    if dlg then
         dlg:intData(data.items)
    else
        dlg = DlgMgr:openDlg("RebuyDlg")
        dlg:intData(data.items)
    end
end


-- 重新购买
function RebuyMgr:rebuyGood(id)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_BUY_BACK, id)
end


-- 回购
MessageMgr:regist("MSG_BUYBACK_LIST", RebuyMgr)
MessageMgr:regist("MSG_BUYBACK_ITEM_CARD", RebuyMgr)
MessageMgr:regist("MSG_BUYBACK_PET_CARD", RebuyMgr)
return RebuyMgr