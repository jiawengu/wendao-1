package org.linlinjava.litemall.gameserver.disruptor;

/**
 * timer的回调函数接口
 */
public interface TimerCallBackFunc {

    void callBack(Timer timer) throws Exception;

}