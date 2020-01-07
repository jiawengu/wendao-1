return {
    TOUCH_MAP_BEGIN         = "touchMapBegin",          -- 点击开始
    TASK_REFRESH            = "taskRefresh",            -- 任务刷新
    AUTO_WALK               = "auto_walk",              -- 自动寻路开始时
    CMD_TELEPORT            = "cmd_teleport",           -- 请求飞行
    CMD_ENTER_ROOM          = "cmd_enter_room",         -- 请求进入房间
    TOUCH_TASK_LOG          = "touch_task_log",         -- 点击任务追踪
    TOUCH_GOTO_ACTIVITY     = "touch_goto_activity",    -- 点击任务界面的前往
    TEAM_DISMISS            = "team_dismiss",           -- 队伍解散
    OTHER_LOGIN             = "other_login",            -- 顶号操作
    RELOAD_OBSTACLE         = "reload_obstacle",        -- 重新载入障碍信息
    START_LOOKON            = "start_lookon",           -- 进入观战

    GET_BAG_ITEM            = "GET_BAG_ITEM",           -- 从Inventory生成包裹道具
    BAG_ITEM_CLICK          = "BAG_ITEM_CLICK",         -- 点击包裹道具
    BAGDLG_CLEANUP          = "BAGDLG_CLEANUP",         -- 包裹道具关闭

    PUT_FURNITURE           = "PUT_FURNITURE",          -- 放下家具
    SET_FLYWORDS_OR_ACT     = "set_flywords_or_act",      -- 设置战斗中指令
    ENTER_COMBAT            = "enter_combat",           -- 进入战斗
    EVENT_END_COMBAT        = "end_combat",            -- 结束战斗
    FIGHT_ADD_FRIEND        = "fight_add_friend",      -- 增加队友(召唤宠物)
    FIGHT_ADD_OPPONENT      = "fight_add_opponent",    -- 增加对手(召唤宠物)
    CHANGE_CROSS_SERVER     = "change_cross_server",     -- 进入或退出跨服区组
    FIGHT_OBJ_ICON_CHANGED  = "fight_obj_icon_changed",      -- 战斗对象icon变化
    FIGHT_OPPONENT_SHOW_LIFE = "fight_opponent_show_life",   -- 敌方显示血条
}
