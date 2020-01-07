-- UsefulWordsMgr.lua
-- Created by lixh Mar/16/2018
-- 常用短语管理器

UsefulWordsMgr = Singleton()

local Json = require('json')

-- 常用短语数据存储路径
local USEFUL_WORDS_SAVE_PATH = Const.WRITE_PATH .. "usefulWords/"

local DEFAULT_USEFUL_WORDS = {
    CHS[7100206], -- "",
    CHS[7100207], -- 大家好
    CHS[7100208], -- 辛苦了
    CHS[7100209], -- 谢谢
    CHS[7100210], -- 刷道来人
    CHS[7100211], -- 押镖求组
}

UsefulWordsMgr.usefulWords = {}

-- 初始化常用语数据
function UsefulWordsMgr:initUsefulWordsData()
    self.usefulWords = {}

    -- 默认常用语
    for i = 1, #DEFAULT_USEFUL_WORDS do
        self.usefulWords[i] = DEFAULT_USEFUL_WORDS[i]
    end

    -- 尝试使用文件更新数据
    local account = Client:getAccount()
    local data = {}
    local filePath = cc.FileUtils:getInstance():getWritablePath() .. USEFUL_WORDS_SAVE_PATH .. account .. ".lua"
    local ok = pcall(function ()
        data = dofile(filePath)
    end)

    if data then
        for i = 1, #data do
            self.usefulWords[i] = data[i]
        end
    end
end

-- 保存常用短语数据到数据库
function UsefulWordsMgr:saveUsefulWordsData()
    local account = Client:getAccount()
    local saveData = "return {\n"

    local count = #self.usefulWords
    for i = 1, count do
        saveData = saveData .. string.format("[%d] = '%s',\n", i, self.usefulWords[i])
    end

    saveData = saveData .. "}"

    gfSaveFile(saveData, USEFUL_WORDS_SAVE_PATH .. account .. ".lua")
end

-- 设置常用短语数据
function UsefulWordsMgr:setUsefulWordsData(key, value)
    if self.usefulWords[key] then
        self.usefulWords[key] = value
        UsefulWordsMgr:saveUsefulWordsData()
    end

    DlgMgr:sendMsg("LinkAndExpressionDlg", "updateUsefulWords", key, value)
end

-- 获取常用短语数据
function UsefulWordsMgr:getUsefulWordsData()
    if #self.usefulWords == 0 then
        self:initUsefulWordsData()
    end

    return self.usefulWords
end

function UsefulWordsMgr:clearData()
    self.usefulWords = {}
end
