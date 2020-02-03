
package org.linlinjava.litemall.gameserver.netty;

import com.lmax.disruptor.RingBuffer;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandler;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;
import io.netty.util.Attribute;
import io.netty.util.AttributeKey;
import org.linlinjava.litemall.gameserver.ApplicationNetty;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.disruptor.LogicEvent;
import org.linlinjava.litemall.gameserver.disruptor.LogicEventType;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

@Qualifier("serverHandler")
@ChannelHandler.Sharable
@Component
public class ServerHandler extends ChannelInboundHandlerAdapter {
    private static final Logger log = LoggerFactory.getLogger(ServerHandler.class);

    public static final AttributeKey<GameObjectChar> akey = AttributeKey.newInstance("session");

    @Autowired
    private ApplicationNetty applicationNetty;

    public void channelActive(ChannelHandlerContext ctx) throws Exception {
        super.channelActive(ctx);
    }

    public void channelInactive(ChannelHandlerContext ctx)
            throws Exception {
        super.channelInactive(ctx);

        Attribute<GameObjectChar> attr = ctx.channel().attr(akey);
        if (attr == null) {
            return;
        }
        GameObjectChar session = attr.get();
        if ((session == null) || (session.chara == null)) {
            return;
        }

        RingBuffer<LogicEvent> ringBuffer = applicationNetty.getGlobalQueue().getRingBuffer();
        long sequence = ringBuffer.next();
        try{
            LogicEvent logicEvent = ringBuffer.get(sequence);
            logicEvent.setContext(ctx);
            logicEvent.setLogicEventType(LogicEventType.LOGIC_PLAYER_DISCONNECT);
            logicEvent.setIntParam(session.chara.id);
        }finally{
            ringBuffer.publish(sequence);
        }
    }

    public void channelRead(ChannelHandlerContext ctx, Object msg) {
        Attribute<GameObjectChar> attr = ctx.channel().attr(akey);
        GameObjectChar session = null;
        if ((attr != null) && (attr.get() != null)) {
            session = attr.get();
            GameObjectChar.GAMEOBJECTCHAR_THREAD_LOCAL.set(session);
        }
        ByteBuf buff = (ByteBuf) msg;
        GameReadTool.readInt(buff);
        GameReadTool.readShort(buff);
        int cmd = GameReadTool.readShort(buff);

        RingBuffer<LogicEvent> ringBuffer = applicationNetty.getGlobalQueue().getRingBuffer();
        long sequence = ringBuffer.next();
        try
        {
            LogicEvent logicEvent = ringBuffer.get(sequence);
            logicEvent.setLogicEventType(LogicEventType.LOGIC_PLAYER_CMD_REQUEST);
            logicEvent.setContext(ctx);
            logicEvent.setIntParam(cmd);
            logicEvent.setIntParam2(session.chara.id);
            logicEvent.setByteBuf(buff);
        }
        finally
        {
            ringBuffer.publish(sequence);
        }
    }

    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
        if (!cause.toString().contains("java.io.IOException")) {
            log.error("exceptionCaught", cause);
        }
        ctx.close();
    }

}
