package org.linlinjava.litemall.gameserver.disruptor;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class EventConsumer<T extends LogicEvent> {
    private static final Logger logger = LoggerFactory.getLogger(EventConsumer.class);
    private static final int LOOP_PER_EVENT_TIMES = 10000;
    private int eventTimeIndex = 0;
    private boolean isFirstLoop = true;
    protected World logicEventInterface;

    public EventConsumer(World logicEventInterface) {
        this.logicEventInterface = logicEventInterface;
    }

    public final void loopTemplate() {
        try {
            this.ensureThreadStart();
            this.logicEventInterface.tick();
            this.eventTimeIndex = 0;
        } catch (Throwable var2) {
            logger.error("", var2);
            if (var2 instanceof OutOfMemoryError) {
                System.exit(-1);
            }
        }

    }

    private void ensureThreadStart() {
        if (this.isFirstLoop) {
            long beginMill = System.currentTimeMillis();
            logger.info("logic thread starting");
            this.isFirstLoop = false;

            try {
                this.logicEventInterface.initWhenThreadStart();
            } catch (Throwable var2) {
                logger.error("", var2);
                System.exit(-1);
            }

            logger.info("logic thread started, server start use {}s", (System.currentTimeMillis() - beginMill) / 1000L);
        }

    }

    public final void onEventTemplate(T event, long sequence, boolean endOfBatch) throws Exception {
        try {
            this.ensureThreadStart();

            try {
                this.logicEventInterface.onLogicEvent(event);
            } finally {
                event.clean();
                ++this.eventTimeIndex;
                if (this.eventTimeIndex == LOOP_PER_EVENT_TIMES) {
                    this.eventTimeIndex = 0;
                    this.loopTemplate();
                    return;
                }

                if (this.eventTimeIndex > LOOP_PER_EVENT_TIMES) {
                    throw new UnsupportedOperationException("an impossible event happen , I think we need stop the world");
                }

            }
        } catch (Throwable var9) {
            logger.error("", var9);
            if (var9 instanceof OutOfMemoryError) {
                logger.error("", var9);
                System.exit(-1);
            }
        }

    }
}