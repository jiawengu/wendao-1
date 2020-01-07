-- MiGongMapMgr.lua
-- Created by 
-- 

MiGongMapMgr = Singleton()

local Furniture = require("obj/Furniture")

local DIRS = {
    UP = 1,
    DOWN = 2,
    LEFT = 3,
    RIGHT = 4,
}

local FLOOR_NUM = 3 -- 1 草地 2 砖地  3 大理石

local ROW = 11
local COL = 11

local CON_NUM = {
    [2] = {3, 8},  -- 砖地连续面积区间
    [3] = {1, 5},  -- 大理石连续面积区间
}

-- 地皮上放置的东西
local ITEMS = {
    {"xiaohonghua", "xiaohuanghua", "xiaoshitou", "xiaotukeng"},
}

local WALL_ICON = {
    {29000, 29001},
    {29000, 29001},
    {29002, 29003},
    {29004, 29005},
}

local LIGHT_WIDTH = 300

local path = {}

local connected = {}

local hasWalkMapPos = {}

local function isConnect(index, index2)
    if not connected[index] then return end
    for i = 1, #connected[index] do
        if connected[index][i] == index2 then
            return true
        end
    end
    
    return false
end

function MiGongMapMgr:getMapRange(size)
    local w, h = self.blockSize.width, self.blockSize.height
    local lx, ly = self:getPosByRC(1, ROW)
    local ux, uy = self:getPosByRC(COL, ROW)
    local rx, ry = self:getPosByRC(COL, 1)

    local x1 = math.max(0, lx - 192)
    local y1 = size.height - uy - 192

    local x2 = math.max(0, size.width - rx - w - 192)
    local y2 = 0

    return {x1 = x1, x2 = x2, y1 = y1, y2 = y2}
end

function MiGongMapMgr:addExit()
    local data = {}
    data.count = 2

    local ux, uy = self:getPosByRC(COL, ROW - 0.8)
    local x, y = gf:convertToMapSpace(ux, uy)
    local exit = {
        add_exit = 1,
        room_name = "入口",
        x = x,
        y = y,
        dir = 1,
    }
    data[1] = exit

    local ux, uy = self:getPosByRC(1, 0.2)
    local x, y = gf:convertToMapSpace(ux, uy)
    local exit = {
        add_exit = 1,
        room_name = "出口",
        x = x,
        y = y,
        dir = 1,
    }
    data[2] = exit

    data.MSG = 0xFFFB

    MessageMgr:pushMsg(data)
end

function MiGongMapMgr:getIndex(c, r)
    return c * 100 + r
end

function MiGongMapMgr:getRCByIndex(index)
    return math.floor(index / 100), index % 100
end

-- 四边形的点按顺时针(或逆时针)排列
function MiGongMapMgr:isPointInRect(x, y, pts)
    local A = pts[1]
    local B = pts[2]
    local C = pts[3]
    local D = pts[4]
    local int a = (B.x - A.x)*(y - A.y) - (B.y - A.y)*(x - A.x)
    local int b = (C.x - B.x)*(y - B.y) - (C.y - B.y)*(x - B.x)
    local int c = (D.x - C.x)*(y - C.y) - (D.y - C.y)*(x - C.x)
    local int d = (A.x - D.x)*(y - D.y) - (A.y - D.y)*(x - D.x)
    if((a > 0 and b > 0 and c > 0 and d > 0) or (a < 0 and b < 0 and c < 0 and d < 0)) then
        return true
    end

    return false
end

function MiGongMapMgr:getPosByRC(c, r)
    local height = self.mapSize.height
    local w, h = self.blockSize.width, self.blockSize.height

    local sy = h - (height % h)
    local sx = math.ceil(ROW / 2) * 2 * w / 2
    return sx + (c - (c + r) / 2) * w, sy +  ((c + r) * h) / 2
end

function MiGongMapMgr:getRCByPos(x, y)
    local height = self.mapSize.height
    local w, h = self.blockSize.width, self.blockSize.height
    local sy = h - (height % h)
    local sx = math.ceil(ROW / 2) * 2 * w / 2
    x = x - sx
    y = y - sy

    local c = x / w + y / h
    local r = 2 * y / h - c

    c = c - 0.5
    r = r + 0.5

    local fc = math.floor(c)
    local fr = math.floor(r)

    return fc + 1, fr + 1
end

function MiGongMapMgr:updateWallStatus(x, y)
    if self.lastX == x and self.lastY == y then return end
    self.lastX = x
    self.lastY = y
    local c, r =  self:getRCByPos(x, y)
    local index= self:getIndex(c, r)
    local furns = HomeMgr:getFurnitures()
    for id, v in pairs(furns) do
        local ind = math.floor(id / 10)
        local dir = id % 10
        if ((ind == index or math.abs(ind - index) == 1 or math.abs(ind - index) == 100) and (dir == DIRS.DOWN or dir == DIRS.LEFT))
            or ((ind + 1 == index or ind + 1 + 100 == index or ind + 1 - 100 == index) and dir == DIRS.UP)
            or ((ind + 100 == index or ind + 100 + 1 == index or ind + 100 - 1 == index) and dir == DIRS.RIGHT) then
            local sx = x - v.curX + 108
            local sy = y - v.curY + 24
            -- 判断点是否在墙的图片上，在需设置墙的透明度
            if sx >= 0 and sx <= 216 and sy >= 0 and sy <= 216 then
                v:setOpacity(0x7f)
            else
                v:setOpacity(255)
            end
        else
            v:setOpacity(255)
        end
    end

    -- visit 中会判断超出视口范围不渲染，故先将纹理缩小，visit后再放大
    self:setLightVisit(x, y)

    self.hasWalk[index] = true

    -- 记录需要渲染透明光圈的位置
    local mx, my = gf:convertToMapSpace(x,y)
    hasWalkMapPos[mx * 1000 + my] = true
end

function MiGongMapMgr:update()
    if #self.hasWalkMapPos == 0 then return end
    for i = 2, 20 do
        local k = table.remove(self.hasWalkMapPos)
        if k then
            local x = k / 1000
            local y = k % 1000
            x, y = gf:convertToClientSpace(x, y)

            self:setLightVisit(x, y, i)
        else
            break
        end
    end
end

function MiGongMapMgr:setLightVisit(x, y, num)
    local rText = self:getRenderText()

    -- visit 中会判断超出视口范围不渲染，故先将纹理缩小，visit后再放大
    rText:setScale(1)
    rText:begin()

    local light = self:getLight(num)
    light:setPosition(x / self.rTextScale, y / self.rTextScale)
    light:visit()

    rText:endToLua()

    rText:setScale(self.rTextScale)
end

function MiGongMapMgr:checkCanMove(x, y)
    local c, r =  self:getRCByPos(x, y)
    local index= self:getIndex(c, r)

    -- 直走已走过的，或已走过的相邻的块
    if self.hasWalk[index]
        or (self.hasWalk[index + 1] and isConnect(index, index + 1))
        or (self.hasWalk[index + 100] and isConnect(index, index + 100))
        or (self.hasWalk[index - 1] and isConnect(index, index - 1))
        or (self.hasWalk[index - 100] and isConnect(index, index - 100)) then
        return true
    end
end

-- 深搜生成地图
function MiGongMapMgr:dfs(x, y, flag)
    local dirs = {0, 1, 0, -1, 1, 0, -1, 0}
    local index = self:getIndex(x, y)
    for i = 1, 4 do
        -- 随机方向
        local num = math.random(1, #dirs / 2)
        local nx = x + table.remove(dirs, num * 2)
        local ny = y + table.remove(dirs, num * 2 - 1)

        local nIndex = self:getIndex(nx, ny)
        if not flag[nIndex] then flag[nIndex] = 0 end

        if nx > 0 and nx <= COL and ny > 0 and ny <= ROW and flag[nIndex] == 0 then
            flag[nIndex] = 1
            if not connected[index] then connected[index] = {} end
            if not connected[nIndex] then connected[nIndex] = {} end
            
            table.insert(connected[index], nIndex)
            table.insert(connected[nIndex], index)
            
            self:dfs(nx, ny, flag)
        end
    end
end

function MiGongMapMgr:generateFloor(blocks)
    local flag = {}

    local count = 0
    local showNum
    local dirs = {1, 100}

    -- 递归生成一块连续的相同底板的地块
    local function func(index, floorNo, flagNum)
        if blocks[index] then
            return
        end

        local x, y = self:getRCByIndex(index)
        if x > COL or y > ROW or x <= 0 or y <= 0 then
            return
        end

        -- 不同的连续相同底板的地不能相连，用草地隔开
        if (blocks[index - 1] and blocks[index - 1] > 1 and flag[index - 1] ~= flagNum)
            or (blocks[index - 100] and blocks[index - 100] > 1 and flag[index - 100] ~= flagNum)
            or (blocks[index + 100] and blocks[index + 100] > 1 and flag[index + 100] ~= flagNum)
            or (blocks[index + 1] and blocks[index + 1] > 1 and flag[index + 1] ~= flagNum) then
            blocks[index] = 1
            return
        end

        count = count + 1

        if count > showNum then
            return
        end

        flag[index] = flagNum
        blocks[index] = floorNo

        local dirs = {1, 100, -1, -100}
        for i = 1, #dirs do
            local num = math.random(1, #dirs)
            local nIndex = index + table.remove(dirs, num)
            func(nIndex, floorNo, flagNum)
        end

        -- 小于最小的连续面积，直接显示草地
        if count < CON_NUM[floorNo][1] then
            blocks[index] = 1
        end
    end

    for i = 1, COL do
        for j = 1, ROW do
            local index = self:getIndex(i, j)
            if not blocks[index] then
                blocks[index] = math.random(1, 2)
                --[[if (blocks[index - 1] and blocks[index - 1] > 1)
                        or (blocks[index - 100] and blocks[index - 100] > 1)
                        or (blocks[index + 100] and blocks[index + 100] > 1)
                        or (blocks[index + 1] and blocks[index + 1] > 1) then
                    blocks[index] = 1

                    --table.insert(self)
                else
                    local floorNo = math.random(2, FLOOR_NUM)
                    count = 0
                    showNum = math.random(CON_NUM[floorNo][1], CON_NUM[floorNo][2])
                    func(index, floorNo, index)
                end]]
            end
        end
    end
end

function MiGongMapMgr:generateWalls(size)
    local walls = {}

    local w, h = self.blockSize.width, self.blockSize.height
    local off = cc.p(5, 70)
    for r = 1, ROW do
        for c = 1, COL do
            local index = self:getIndex(c, r)

            if c == 1 then
                -- 左边墙
                local info = {}
                local x, y = self:getPosByRC(c, r)
                x = x + w / 4 - off.x
                y = y - h / 4 * 3 - off.y

                local bx, by = gf:convertToMapSpace(x, y)
                local ox, oy = HomeMgr:convertToOffset(x, y, bx, by)
                info.x = bx
                info.y = by
                info.ox = ox
                info.oy = oy
                info.dir = 0
                info.index = index * 10 + DIRS.LEFT
                info.class_id = WALL_ICON[self.blocks[index] or 1][2]
                table.insert(walls, info)
            end

            if r == 1 then
                -- 下边墙
                local info = {}
                local x, y = self:getPosByRC(c, r)
                x = x + w / 4 * 3 - off.x
                y = y - h / 4 * 3 - off.y

                local bx, by = gf:convertToMapSpace(x, y)
                local ox, oy = HomeMgr:convertToOffset(x, y, bx, by)
                info.x = bx
                info.y = by
                info.ox = ox
                info.oy = oy
                info.dir = 0
                info.index = index  * 10 + DIRS.DOWN
                info.class_id = WALL_ICON[self.blocks[index] or 1][1]

                if c == 1 then
                    info.needHide = true
                end

                table.insert(walls, info)
            end

            if not isConnect(index, index + 100) then
                -- 右边有墙
                local info = {}
                local x, y = self:getPosByRC(c, r)

                x = x + w / 4 * 3 - off.x
                y = y - h / 4 - off.y

                local bx, by = gf:convertToMapSpace(x, y)
                local ox, oy = HomeMgr:convertToOffset(x, y, bx, by)
                info.x = bx
                info.y = by
                info.ox = ox
                info.oy = oy
                info.dir = 0
                info.index = index   * 10 + DIRS.RIGHT
                if self.blocks[index + 100] then
                    info.class_id = WALL_ICON[self.blocks[index + 100] or 1][2]
                else
                    info.class_id = WALL_ICON[self.blocks[index] or 1][2]
                end

                table.insert(walls, info)
            end
        
            if not isConnect(index, index + 1) then
                -- 上边有墙
                local info = {}
                local x, y = self:getPosByRC(c, r)
                x = x + w / 4 - off.x
                y = y - h / 4 - off.y

                local bx, by = gf:convertToMapSpace(x, y)
                local ox, oy = HomeMgr:convertToOffset(x, y, bx, by)
                info.x = bx
                info.y = by
                info.ox = ox
                info.oy = oy
                info.dir = 0
                info.index = index * 10 + DIRS.UP
                info.class_id = WALL_ICON[self.blocks[index] or 1][1]

                if r == ROW and c == COL then
                    info.needHide = true
                end
                
                table.insert(walls, info)
            end
        end
    end

    return walls
end

function MiGongMapMgr:getLight(num)
    num = num or 1
    if not self.lights then self.lights = {} end
    if not self.lights[num] then
        local sp = cc.Sprite:create("ui/Icon1718.png")
        local spSize = sp:getContentSize()
        sp:setBlendFunc(gl.ZERO, gl.ONE_MINUS_SRC_ALPHA)
        sp:setScale(LIGHT_WIDTH / spSize.width / self.rTextScale)
        sp:retain()
        self.lights[num] = sp
    end

    return self.lights[num]
end

function MiGongMapMgr:getRenderText()
    if not self.rText then
        local size = self.mapSize
        local scale = math.min(size.width / (Const.WINSIZE.width / Const.UI_SCALE), size.height / (Const.WINSIZE.height / Const.UI_SCALE))
        local rText = cc.RenderTexture:create(size.width / scale, size.height / scale)
        rText:setPosition(0, 0)
        rText:getSprite():setAnchorPoint(0, 0)
        rText:clear(0, 0, 0, 1)
        rText:setScale(scale)
        rText:setName("MiGongRender")
        gf:getCharTopLayer():addChild(rText)

        self.rTextScale = scale
        self.rText = rText
    end

    return self.rText
end

-- 生成迷宫
function MiGongMapMgr:generate(size, blockSize)
    self.mapSize = size
    self.blockSize = blockSize

    -- 创建黑幕层
    local rText = self:getRenderText()
 

    self.hasWalk = {}

    self.hasWalkMapPos = {}
    for key, v in pairs(hasWalkMapPos) do
        table.insert(self.hasWalkMapPos, key)
    end

    -- 生成路径
    local flag = {}
    connected = {}
    local sx, sy = math.floor(COL / 2), math.floor(ROW / 2)
    flag[self:getIndex(sx, sy)] = 1
    self:dfs(sx, sy, flag)

    -- 生成地块
    self.blocks = {}
    self.objs = {}
    self:generateFloor(self.blocks, self.objs)
    
    -- 生成墙
    local walls
    local function func()
        for i = 1, 10 do
            local v = table.remove(walls)
            if not v then return end

            local info = HomeMgr:getFurnitureInfoById(v.class_id)
            if info then
                info.furniture_type = info.furniture_type
                info.icon = info.icon
                info.name = info.name
                info.dirs = info.dirs
                info.bx = v.x
                info.by = v.y
                info.y = v.oy
                info.x = v.ox
                info.furniture_id = v.class_id
                info.furniture_pos = v.index
                info.flip = 0
                info.dir = HomeMgr:getDirByFlip(info, v.dir)

                local furn = HomeMgr:doPut(info, false)
                if v.needHide then furn:setVisible(false) end
            end
        end

        performWithDelay(gf:getUILayer(), func, 0)
    end

    performWithDelay(gf:getUILayer(), function() 
        walls = self:generateWalls(size)
        func()
    end, 0)
end

function MiGongMapMgr:getBlocks(size)
    local blocks = {}
    local height = self.mapSize.height
    for index, v in pairs(self.blocks) do
        local c, r = self:getRCByIndex(index)
        local x, y = self:getPosByRC(c, r)
        y = height - y  -- Map 中的加载时会将 y 值取反，故此需先取反

        blocks[x .. "_" .. y] = tostring(v)
    end

    return blocks
end

function MiGongMapMgr:MSG_ENTER_ROOM(data)
    if MapMgr:isInMiGong() then
        --[[local function loadAllBlocksAfterLoadEnd()
            if not MapMgr.isLoadEnd then
                performWithDelay(GameMgr.scene.map, function()
                    loadAllBlocksAfterLoadEnd()
                end, 0)
                return
            end]]

            performWithDelay(gf:getUILayer(), function()
                local x, y = self:getPosByRC(COL, ROW - 1)
                self.hasWalk[self:getIndex(COL, ROW - 1)] = true
                Me:setPos(x, y)
                Me:setLastMapPos(gf:convertToMapSpace(x,y))

                MiGongMapMgr:addExit()
            end, 0)

            GameMgr.scene.map:loadBlocksByMyPos(true, nil, true)
        --end
        -- loadAllBlocksAfterLoadEnd()
    else
        MiGongMapMgr:clearData()
    end
end

function MiGongMapMgr:clearData()
    if self.lights then
        for _, v in pairs(self.lights) do
            v:release()
        end

        self.lights = nil
    end

    if self.rText then
        self.rText:removeFromParent()
        self.rText = nil
    end
end

MessageMgr:hook("MSG_ENTER_ROOM", MiGongMapMgr, "MiGongMapMgr")

