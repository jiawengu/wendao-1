package org.linlinjava.litemall.gameserver.disruptor;

public interface TriggerInterface {

    void addTimer(Timer timer);

    public void tickTrigger();


}
