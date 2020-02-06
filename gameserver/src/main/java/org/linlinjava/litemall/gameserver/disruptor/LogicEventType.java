package org.linlinjava.litemall.gameserver.disruptor;

public enum LogicEventType {
    /**
     * 玩家断开连接
     */
    LOGIC_PLAYER_DISCONNECT,
    /**
     * 收到客户端的请求消息
     */
    LOGIC_PLAYER_CMD_REQUEST,
    /**
     * 停服
     */
    LOGIC_CLOSE_GAME,
    /**
     * 跨天事件
     */
    LOGIC_DAY_BREAK,
}
