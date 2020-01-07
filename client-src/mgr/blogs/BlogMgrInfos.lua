-- BlogMgr_infos.lua
-- Created by sujl, Sept/25/2017
-- 个人信息

BlogMgr = BlogMgr or Singleton("BlogMgr")

local POLAR_IMAGE = {
    [POLAR.METAL]  = ResMgr.ui.suit_polar_metal,
    [POLAR.WOOD]   = ResMgr.ui.suit_polar_wood,
    [POLAR.WATER]  = ResMgr.ui.suit_polar_water,
    [POLAR.FIRE]   = ResMgr.ui.suit_polar_fire,
    [POLAR.EARTH]  = ResMgr.ui.suit_polar_earth,
}

local LOCATION_LIMIT_WORD = 6 -- 地址最多显示 8个字

BlogMgr.userInfo = {}

-- 清除数据
function BlogMgr:clearInfos()
    self.userInfo = {}
end

-- 获取用户信息
function BlogMgr:getUserDataByDlgName(dlgName)
    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    if self.userInfo and self.userInfo[gid] then
        return self.userInfo[gid]
    end

    return {}
end

-- 获取用户信息
function BlogMgr:getUserDataByGid(gid)
    if self.userInfo and self.userInfo[gid] then
        return self.userInfo[gid]
    end

    return {}
end

-- 是否自己的空间
function BlogMgr:isMySelf(dlgName)
    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    return gid == Me:queryBasic("gid")
end

-- 获取GID
function BlogMgr:getUserGid(dlgName)
    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    
    return self.userInfo and self.userInfo[gid] and self.userInfo[gid].user_gid
end

-- 获取用户名
function BlogMgr:getUserName(dlgName)
    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    return self.userInfo and self.userInfo[gid] and self.userInfo[gid].name
end

-- 获取相性
function BlogMgr:getPolar(gid)
    return self.userInfo and self.userInfo[gid] and self.userInfo[gid].polar
end

function BlogMgr:getPolarImage(dlgName)

    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    return POLAR_IMAGE[self:getPolar(gid)]
end

function BlogMgr:getPolarImageByGid(gid)

    return POLAR_IMAGE[self:getPolar(gid)]
end

-- 性别
function BlogMgr:getGender(dlgName)
    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    return self.userInfo and self.userInfo[gid] and self.userInfo[gid].gender    
end

-- 称谓
function BlogMgr:getTitleByGid(gid)
    return self.userInfo and self.userInfo[gid] and self.userInfo[gid].title    
end

-- 帮派名称
function BlogMgr:getPartyName(dlgName)
    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    return self.userInfo and self.userInfo[gid] and self.userInfo[gid].party_name    
end

-- 夫妻名称
function BlogMgr:getCoupleName(dlgName) 
    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    return self.userInfo and self.userInfo[gid] and self.userInfo[gid].couple_name  
end

function BlogMgr:getLocationShowStr(str)
    if not str then
        return
    end
    
    if gf:getTextLength(str) > LOCATION_LIMIT_WORD * 2 then
        str = gf:subString(str, (LOCATION_LIMIT_WORD - 1) * 2) .. "..."
    end

    return str
end

-- 地理位置
function BlogMgr:getLocation(dlgName) 
    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    return self.userInfo and self.userInfo[gid] and self.userInfo[gid].location  
end

-- 获取签名
function BlogMgr:getSignature(dlgName) 
    local gid = BlogMgr:getBlogGidByDlgName(dlgName)

    if self.userInfo and self.userInfo[gid] then
        return self.userInfo[gid].signature, self.userInfo[gid].signature_voice, self.userInfo[gid].signature_voice_time
    end
end

-- 获取签名
function BlogMgr:getSignatureByGid(gid) 

    if self.userInfo and self.userInfo[gid] then
        return self.userInfo[gid].signature, self.userInfo[gid].signature_voice, self.userInfo[gid].signature_voice_time
    end
end

-- 获取标签
function BlogMgr:getTags(dlgName)
    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    return self.userInfo and self.userInfo[gid] and self.userInfo[gid].tag  
end

function BlogMgr:getTagsByGid(gid)    
    return self.userInfo and self.userInfo[gid] and self.userInfo[gid].tag  
end

-- 获取头像最后修改时间
function BlogMgr:getLastIconModifyTime(dlgName)
    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    return self.userInfo and self.userInfo[gid] and self.userInfo[gid].icon_img_ex_ti      
end

-- 获取结拜
function BlogMgr:getBrothers(dlgName)
    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    return self.userInfo and self.userInfo[gid] and self.userInfo[gid].brothers
end

-- 获取图像路径
function BlogMgr:getIcon(dlgName)

    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    

    local icon = self.userInfo[gid] and self.userInfo[gid].icon_img
    if string.isNilOrEmpty(icon) then
        return ResMgr:getBigPortrait(ResMgr:getIconByPolarAndGender(self:getPolar(gid), self:getGender(dlgName)))
    else
        return icon
    end
end

-- 是否默认图标
function BlogMgr:isDefaultIcon(dlgName)
    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    return not self.userInfo[gid] or string.isNilOrEmpty(self.userInfo[gid].icon_img)
end

function BlogMgr:isDefaultIconByGid(gid)
    return not self.userInfo[gid] or string.isNilOrEmpty(self.userInfo[gid].icon_img)
end

-- 获取审核标志
function BlogMgr:isReview(dlgName)
    local gid = BlogMgr:getBlogGidByDlgName(dlgName)
    return self:isMySelf(dlgName) and 1 == (self.userInfo[gid] and self.userInfo[gid].under_review)
end



BlogMgr:regSub({ clear = BlogMgr.clearInfos })