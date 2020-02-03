package org.linlinjava.litemall.gameserver.disruptor;

import com.lmax.disruptor.EventHandler;
import com.lmax.disruptor.RingBuffer;
import com.lmax.disruptor.dsl.Disruptor;
import com.lmax.disruptor.dsl.ProducerType;

import java.util.Objects;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class GlobalQueue {
    private static final int INIT_LOGIC_EVENT_CAPACITY = 8192;
    private final Disruptor<LogicEvent> DISRUPTOR;
    private final RingBuffer<LogicEvent> ringBuffer;
    private final SleepingWaitExtendStrategy strategy;

    public GlobalQueue(EventConsumer<LogicEvent> logicEventConsumer) {
        Objects.requireNonNull(logicEventConsumer);
        ExecutorService logicExecutor=Executors.newFixedThreadPool(1, (r)->new Thread(r,"LOGIC_THREAD"));

        this.strategy = new SleepingWaitExtendStrategy(logicEventConsumer);
        this.DISRUPTOR = new Disruptor(() -> {
            return new LogicEvent();
        }, INIT_LOGIC_EVENT_CAPACITY, logicExecutor, ProducerType.MULTI, this.strategy);
        EventHandler<LogicEvent>[] hand = new EventHandler[1];
        hand[0] = logicEventConsumer::onEventTemplate;
        this.DISRUPTOR.handleEventsWith(hand);
        this.ringBuffer = this.DISRUPTOR.getRingBuffer();
        this.DISRUPTOR.start();
    }

    public RingBuffer<LogicEvent> getRingBuffer() {
        return ringBuffer;
    }
}
