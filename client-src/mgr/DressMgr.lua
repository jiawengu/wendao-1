-- DressMgr.lua
-- Created by sujl, Jan/2/2018
-- 穿戴管理器

DressMgr = Singleton()

function DressMgr:clearData()
    self.favs = nil
end

-- 获取方案列表
function DressMgr:getFavs()
    local lists = {}
    if self.favs then
        for k, v in pairs(self.favs) do
            table.insert(lists, v)
        end
    end

    table.sort(lists, function(l, r)
        return l.fav_no < r.fav_no
    end)

    return lists
end

function DressMgr:getFav(id)
   return self.favs and self.favs[id]
end

-- 获取光效配置
-- 内测读内测的配置，公测读公测的配置
function DressMgr:getFashionEffect()
    local key = DistMgr:curIsTestDist() and "beta" or "release"
    local fashionEffect = require("cfg/FashionEffect")
    local temp = gf:deepCopy(fashionEffect)


    if not DistMgr:curIsTestDist() then
        -- 公测区  2019年6月27号5点显示  轻音小调
        local showRuleTime = os.time{year = 2019,month = 6,day = 27,hour = 5,min = 0,sec = 0}
        if gf:getServerTime() < showRuleTime then
            if temp and temp[key] and temp[key][CHS[4300513]] then
                temp[key][CHS[4300513]] = nil
            end
        end
    end

    return temp and temp[key] or {}
end

-- 获取跟随宠配置
-- 内测读内测的配置，公测读公测的配置
function DressMgr:getFollowPet()
    local key = DistMgr:curIsTestDist() and "beta" or "release"
    local followPetInfo = require("cfg/FollowPet")
    return followPetInfo and followPetInfo[key] or {}
end

function DressMgr:MSG_FASION_FAVORITE_LIST(data)
    self.favs = data.favs
end

function DressMgr:MSG_FASION_CUSTOM_END(data)
end

function DressMgr:MSG_CHOOSE_FASION_LIST(data)
    local dlg = DlgMgr:openDlg("ChoseDressDlg")
    dlg:setData(data)
end

MessageMgr:regist("MSG_FASION_FAVORITE_LIST", DressMgr)
MessageMgr:regist("MSG_FASION_CUSTOM_END", DressMgr)
MessageMgr:regist("MSG_CHOOSE_FASION_LIST", DressMgr)
-- MessageMgr:regist("MSG_FASION_CUSTOM_LIST", DressMgr)

return DressMgr