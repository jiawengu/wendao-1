-- BlogMgr_Decorate.lua
-- created by song Sep/20/2017
-- 空间装饰相关

BlogMgr = BlogMgr or Singleton("BlogMgr")

BlogMgr.blogUsedDecInfo = {}

BlogMgr.myBlogDecoratesInfo = {}

-- 获取个人空间装饰品名称
function BlogMgr:getBlogDecorateName(gid, type)
    if self.blogUsedDecInfo[gid] and self.blogUsedDecInfo[gid][type] then
        return self.blogUsedDecInfo[gid][type].name
    end
end

-- 个人空间装饰品信息
function BlogMgr:MSG_BLOG_DECORATION_LIST(data)
    self.blogUsedDecInfo[data.user_gid] = data
end

-- 
function BlogMgr:getMyDecorateInfo()
    return self.myBlogDecoratesInfo
end

function BlogMgr:clearDecorateInfo()
    self.blogUsedDecInfo = {}
    self.myBlogDecoratesInfo = {}
end

-- MSG_DECORATION_LIST 消息调用
function BlogMgr:setMyDecorateInfo(data)
    if data.type ~= "blog_head" and data.type ~= "blog_floor" then
        return
    end
    
    local gid = Me:queryBasic("gid")
    self.myBlogDecoratesInfo[data.type] = data.list
    
    -- 默认装饰
    table.insert(self.myBlogDecoratesInfo[data.type], 1, {name = "", time = -1}) 

    if not self.blogUsedDecInfo[gid] then
        self.blogUsedDecInfo[gid] = {}
    end
    
    self.blogUsedDecInfo[gid][data.type] = {}
    
    for i = 1, #data.list do
        if data.list[i].name == data.usedName then
            self.blogUsedDecInfo[gid][data.type].name = data.list[i].name
            self.blogUsedDecInfo[gid][data.type].end_time = data.list[i].time
        end
    end
end

-- 检测是否有可使用的装饰
function BlogMgr:checkHasDecorate()
    local gid = Me:queryBasic("gid")
    if not next(self.myBlogDecoratesInfo) then
        return false
    end
    
    local curTime = gf:getServerTime()
    for type, info in pairs(self.myBlogDecoratesInfo) do
        for _, item in pairs(info) do
            if item.name ~= "" and (curTime < item.time or item.time == -1) then
                return true
            end
        end
    end
    
    return false
end

MessageMgr:regist("MSG_BLOG_DECORATION_LIST", BlogMgr)