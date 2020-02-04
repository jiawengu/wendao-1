package org.linlinjava.litemall.gameserver.disruptor;


public abstract class Timer {

    private static long idGenerator = 0;
    /**
     * 随机生成的id,唯一标识该timer,不能重复
     */
    private long timerId;
    /**
     * timer创建的时间戳
     */
    private long startTime;
    /**
     * 间隔几毫秒秒执行
     */
    protected long delayTime;
    /**
     * 执行几次
     */
    private int executeNum;
    /**
     * 回调函数
     */
    private TimerCallBackFunc callBackFunc;

    public Timer(long delayTime, int executeNum,TimerCallBackFunc callBackFunc) {

        this.setTimerId(++idGenerator);

        this.delayTime = delayTime;

        this.executeNum = executeNum;

        this.callBackFunc=callBackFunc;
    }

    public long getTriggerTime() {
        return startTime + delayTime;
    }

    public long getTimerId() {
        return timerId;
    }

    public void setTimerId(long timerId) {
        this.timerId = timerId;
    }

    public long getStartTime() {
        return startTime;
    }

    public long getDelayTime() {
        return delayTime;
    }

    public void setDelayTime(long delayTime) {
        this.delayTime = delayTime;
    }

    public void setStartTime(long startTime) {
        this.startTime = startTime;
    }

    public int getExecuteNum() {
        return executeNum;
    }

    public void setExecuteNum(int executeNum) {
        this.executeNum = executeNum;
    }

    public final void trigger() throws Exception{
        callBackFunc.callBack(this);
    }

    public void setCallBackFunc(TimerCallBackFunc callBackFunc) {
        this.callBackFunc = callBackFunc;
    }

    public final void closeTimer() {
        this.executeNum = 0;
    }
}
