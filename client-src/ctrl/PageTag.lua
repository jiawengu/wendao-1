-- PageTag.lua
-- created by cheny Dec/04/2014
-- 分页标签

local PAGETAG_SIZE = 36
local PAGETAG_WIDTH = 36
local MutexGroup = require("ctrl/MutexGroup")
local PageTag = class("PageTag", function()
    return cc.LayerColor:create(cc.c4b(0,0,0,0))
end)

local DISPLAY_RES = {
    [1] = {selected = ResMgr.ui.checkbox_file1, unSelected = ResMgr.ui.checkbox_file2, resType = ccui.TextureResType.plistType},
    [2] = {selected = ResMgr.ui.page_circle_selected, unSelected = ResMgr.ui.page_circle_unSelected, resType = ccui.TextureResType.localType}
}

-- count 个数  
-- resIndex 资源索引
-- 间隔宽度
function PageTag:ctor(count, resIndex, pageSize,scale)
    local group = MutexGroup.new()
    self.mutexGroup = group
    self.count = count
    resIndex = resIndex or 1
    pageSize = pageSize or PAGETAG_WIDTH
    scale = scale or 0.8
    local imageRes = DISPLAY_RES[resIndex]
    for i = 1, count do
        local check = ccui.CheckBox:create(imageRes.unSelected, imageRes.unSelected, imageRes.selected, imageRes.unSelected, imageRes.unSelected, imageRes.resType)
        check:setTouchEnabled(false)
        check:setPosition((i-0.5)*pageSize, PAGETAG_SIZE/2)
        self:addChild(check, 0, i)
        group:addItem(check)
        check:setScale(scale)
    end

    self:setContentSize(pageSize*count, PAGETAG_SIZE)
end

-- 设置页，1～count
function PageTag:setPage(page)
    self.page = page
    local checkBox = self:getChildByTag(page)
    checkBox = tolua.cast(checkBox, "ccui.CheckBox")
    if nil ~= checkBox then
        self.mutexGroup:select(checkBox)
    end
end

function PageTag:getPage()
    return self.page
end

return PageTag
