
package org.linlinjava.litemall.gameserver.netty;

import com.google.common.collect.Maps;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandler;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;
import io.netty.util.Attribute;
import io.netty.util.AttributeKey;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.process.C4274_0;
import org.linlinjava.litemall.gameserver.process.CMD_MULTI_MOVE_TO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.util.HashMap;

@Qualifier("serverHandler")
@ChannelHandler.Sharable
@Component
public class ServerHandler extends ChannelInboundHandlerAdapter {
    private static final Logger log = LoggerFactory.getLogger(ServerHandler.class);

    public static final AttributeKey<GameObjectChar> akey = AttributeKey.newInstance("session");

    @Autowired
    private java.util.List<GameHandler> gameHandlers;

    private HashMap<Integer, GameHandler> gameHandlerHashMap;

    @PostConstruct
    private void init() {
        gameHandlerHashMap = Maps.newHashMap();
        for (GameHandler gameHandler : gameHandlers) {
            gameHandlerHashMap.put(gameHandler.cmd(), gameHandler);
        }
    }

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
        GameObjectChar session = (GameObjectChar) attr.get();
        if ((session == null) || (session.chara == null)) {
            return;
        }
        GameObjectCharMng.remove(session);
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
        GameHandler gameHandler = gameHandlerHashMap.getOrDefault(cmd, null);
        if (gameHandler != null) {
            if (session != null) {
                if (session.lock()) {
                    try {
                        if(! (gameHandler instanceof C4274_0 || gameHandler instanceof CMD_MULTI_MOVE_TO)){//todo 打印消息
                            log.info("recive msg!=>"+gameHandler);
                        }
                        gameHandler.process(ctx, buff);
                    } catch (Exception e) {
                        log.error(String.format("Fail to execute cmd: %d, buff: %s", cmd, buff), e);
                    } finally {
                        session.unlock();
                    }
                }
            } else {
                gameHandler.process(ctx, buff);
            }
        } else {
            log.debug(String.format("Cannot find a match cmd: %d, buff: %s", cmd, buff));
        }
    }

    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
        if (!cause.toString().contains("java.io.IOException")) {
            log.error("exceptionCaught", cause);
        }
        ctx.close();
    }
}
