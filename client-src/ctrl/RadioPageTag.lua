-- RadioPageTag.lua
-- created by chenyq May/06/2015
-- 分页标签

local RadioGroup = require("ctrl/RadioGroup")
local RadioPageTag = class("RadioPageTag")

function RadioPageTag:ctor(dlg, radioNames)
    self.group = RadioGroup.new()
    self.group:setItems(dlg, radioNames)

    -- 设置为不可交互
    local radios = self.group.radios
    for i = 1, #radios do
        radios[i]:setTouchEnabled(false)
    end
end

-- 设置页，1～count
function RadioPageTag:setPage(page)
    self.page = page
    self.group:selectRadio(page)
end

function RadioPageTag:getPage()
    return self.page
end

return RadioPageTag
