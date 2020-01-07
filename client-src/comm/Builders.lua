-- created by cheny Oct/12/2014
-- 数据解析

local Builders = {}

Builders._fields = require("comm/Fields")
Builders._objectDefaultFields = require("comm/ObjectDefaultFields")

local FIELD_INT8        = 1 -- 8bits signed byte
local FIELD_INT16       = 2 -- 16bits signed short
local FIELD_INT32       = 3 -- 32bits signed long
local FIELD_STRING      = 4 -- len(8-bits) - string
local FIELD_LONG_STRING = 5 -- len(16-bits) - string
local FIELD_UINT8       = 6 -- 8bits unsigned byte
local FIELD_UINT16      = 7 -- 16bits unsigned short
local FIELD_UINT32      = 8 -- 32bits unsigned short

local FIELDS_BASIC      = 1 -- 物品基础属性值
local FIELDS_VALUE      = 2 -- 物品加成属性值
local FIELDS_SCALE      = 3 -- 物品加成百分比

local STONE_START       = 12 -- 妖石组编号开始
local STONE_END         = 22 -- 妖石组编号结束

local FIELDS_MOUNT_ATTRIB = 23 -- 宠物坐骑属性

-- 动态字段
function Builders:BuildFields(pkt, data, suffix)
	local count = pkt:GetShort()
    for i = 1, count, 1 do
        local no = pkt:GetShort()
        local key = self._fields[no]
		if suffix ~= nil then
			key = key .. suffix
		end

        if not key then
            assert(nil, "BuildFields no find field " .. no)
        end

		if key ~= nil then
			local type = pkt:GetChar()

			if type == FIELD_INT8 then
				data[key] = pkt:GetSignedChar()
			elseif type == FIELD_UINT8 then
				data[key] = pkt:GetChar()
			elseif type == FIELD_INT16 then
				data[key] = pkt:GetSignedShort()
			elseif type == FIELD_UINT16 then
				data[key] = pkt:GetShort()
			elseif type == FIELD_INT32 then
                data[key] = pkt:GetSignedLong()
            elseif type == FIELD_UINT32 then
                data[key] = pkt:GetLong()
			elseif type == FIELD_STRING then
				data[key] = pkt:GetLenString()
			elseif type == FIELD_LONG_STRING then
				data[key] = pkt:GetLenString2()
			end

			if no == 879 then
				data[key] = string.gsub(data[key], CHS[6000310], CHS[5440001])
        		data[key] = string.gsub(data[key], CHS[6000324], CHS[5440002])
			end
		end
	end
end

-- 构造一个物品信息
function Builders:BuildItemInfo(pkt, data)
	local extra = {}
	local groupCount = pkt:GetShort()
	for i = 1, groupCount, 1 do
		local groupNo = pkt:GetChar()
		local groupType = pkt:GetChar()
		if groupType == FIELDS_BASIC then
			Builders:BuildFields(pkt,data)
		else
			local suffix = nil
			if groupType == FIELDS_VALUE then
				suffix = string.format("_%d", groupNo)
			elseif groupType == FIELDS_SCALE then
				suffix = string.format("_scale_%d", groupNo)
			end
			extra[string.format("%d_group", groupNo)] = 1
			Builders:BuildFields(pkt, extra, suffix)
		end
	end
	data.extra = extra

	if self._objectDefaultFields[data.item_type] then
		for k, v in pairs(self._objectDefaultFields[data.item_type]) do
			if not data[k] then
				data[k] = v
			end
		end
	end
end

-- 构造一个技能信息
function Builders:BuildSkillBasicInfo(pkt, data)
    data.skill_no = pkt:GetShort()
    data.skill_attrib = pkt:GetShort()
    data.skill_level = pkt:GetShort()
    data.level_improved = pkt:GetShort()
    data.skill_mana_cost = pkt:GetShort()
    data.skill_nimbus = pkt:GetLong()
    data.skill_disabled = pkt:GetChar()
    data.range = pkt:GetShort()
    data.max_range = pkt:GetShort()

    -- 获取消耗信息
    local count = pkt:GetShort()
    for i = 1, count do
        data['cost_' .. pkt:GetLenString()] = pkt:GetLong()
    end

    -- 如果没有 cost_voucher_or_cash，客户端中级设置为0
    -- 因为被动技能 神体术、修道术都有，但是后发制人、釜底抽薪没有，SkillDlg中，默认逻辑有调用到。
    if not data["cost_voucher_or_cash"] then data["cost_voucher_or_cash"] = 0 end

    -- 是否是临时技能（目前用于区分角色自身的技能和“亲密无间”复制的宠物技能）
    data.isTempSkill = pkt:GetChar()
end

-- 构造宠物信息
function Builders:BuildPetInfo(pkt, data)
    local count = pkt:GetShort()
    data.stone_num = 0
    local j = 1
    for i = 1, count do
        local no = pkt:GetChar()
        local type = pkt:GetChar()
        if type == FIELDS_BASIC then
            self:BuildFields(pkt, data)
        else
            local groupData = { no = no }
            self:BuildFields(pkt, groupData)
            data['group_' .. no] = groupData

            if no >= STONE_START and no <= STONE_END then
                data.stone_num = data.stone_num + 1
            end

            j = j + 1
        end
    end

    data.group_num = j - 1
end

return Builders