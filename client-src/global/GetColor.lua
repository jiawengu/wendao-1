-- created by songcw Sep/10/2016
-- 全局函数

local ColorForColorText = require("cfg/ColorForColorText")

GetColor = {}

-- C++层通过这个接口获取颜色
function GetColor:getColorR(colorStr)
    if ColorForColorText[colorStr] then
        return ColorForColorText[colorStr].r
    end
    return 0
end

function GetColor:getColorG(colorStr)
    if ColorForColorText[colorStr] then
        return ColorForColorText[colorStr].g
    end
    return 0
end

function GetColor:getColorB(colorStr)
    if ColorForColorText[colorStr] then
        return ColorForColorText[colorStr].b
    end
    return 0
end

