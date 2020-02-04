package org.linlinjava.litemall.gameserver.disruptor;

import com.lmax.disruptor.AlertException;
import com.lmax.disruptor.Sequence;
import com.lmax.disruptor.SequenceBarrier;
import com.lmax.disruptor.WaitStrategy;
import java.util.concurrent.locks.LockSupport;

public class SleepingWaitExtendStrategy implements WaitStrategy {
    private final EventConsumer<?> eventConsumer;
    private static final int DEFAULT_RETRIES = 200;
    private final int retries = 200;

    public SleepingWaitExtendStrategy(EventConsumer<?> eventConsumer) {
        this.eventConsumer = eventConsumer;
    }

    public long waitFor(long sequence, Sequence cursor, Sequence dependentSequence, SequenceBarrier barrier) throws AlertException, InterruptedException {
        long availableSequence;
        for(int counter = this.retries; (availableSequence = dependentSequence.get()) < sequence; counter = this.applyWaitMethod(barrier, counter)) {
            this.eventConsumer.loopTemplate();
        }

        return availableSequence;
    }

    public void signalAllWhenBlocking() {
    }

    private int applyWaitMethod(SequenceBarrier barrier, int counter) throws AlertException {
        barrier.checkAlert();
        if (counter > 100) {
            --counter;
        } else if (counter > 0) {
            --counter;
            Thread.yield();
        } else {
            LockSupport.parkNanos(100000L);
        }

        return counter;
    }
}