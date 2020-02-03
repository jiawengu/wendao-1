package org.linlinjava.litemall.gameserver.disruptor;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;

public class LogicEvent implements Cleanable {
    private LogicEventType logicEventType;
    private ByteBuf byteBuf;
    private ChannelHandlerContext context;
    private int intParam;
    private int intParam2;

    public LogicEvent() {
    }

    @Override
    public void clean() {
        this.logicEventType = null;
        this.context = null;
        this.byteBuf = null;
    }

    public LogicEventType getLogicEventType() {
        return logicEventType;
    }

    public void setLogicEventType(LogicEventType logicEventType) {
        this.logicEventType = logicEventType;
    }

    public ByteBuf getByteBuf() {
        return byteBuf;
    }

    public void setByteBuf(ByteBuf byteBuf) {
        this.byteBuf = byteBuf;
    }

    public ChannelHandlerContext getContext() {
        return this.context;
    }

    public void setContext(ChannelHandlerContext context) {
        this.context = context;
    }

    public int getIntParam() {
        return intParam;
    }

    public void setIntParam(int intParam) {
        this.intParam = intParam;
    }

    public int getIntParam2() {
        return intParam2;
    }

    public void setIntParam2(int intParam2) {
        this.intParam2 = intParam2;
    }
}