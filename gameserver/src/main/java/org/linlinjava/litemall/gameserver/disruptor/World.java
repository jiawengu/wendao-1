package org.linlinjava.litemall.gameserver.disruptor;

import com.google.common.collect.Maps;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.util.Attribute;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.game.GameCore;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.netty.NettyServer;
import org.linlinjava.litemall.gameserver.netty.ServerHandler;
import org.linlinjava.litemall.gameserver.process.CMD_ECHO;
import org.linlinjava.litemall.gameserver.process.CMD_HEART_BEAT;
import org.linlinjava.litemall.gameserver.process.CMD_MULTI_MOVE_TO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.Map;


@Service
public class World {
    private static final Logger logger = LoggerFactory.getLogger(World.class);
    @Autowired
    private GameCore gameCore;
    @Value("${netty.port}")
    private int port;
    @Value("${netty.url}")
    private String url;
    @Autowired
    private NettyServer server;
    @Autowired
    private java.util.List<GameHandler> gameHandlers;
    /**
     * 玩家消息处理器
     */
    private HashMap<Integer, GameHandler> gameHandlerHashMap;
    /**
     * 逻辑处理器
     */
    private Map<LogicEventType, LogicHandler> logicHandlers;


    public void initWhenThreadStart() {
        registerLogicHandler();

        registerCmdHandler();

        java.net.InetSocketAddress address = new java.net.InetSocketAddress(this.url, this.port);
        logger.debug("run .... . ... " + this.url);
        this.server.start(address);

        this.gameCore.init(this.server);
    }

    private void registerCmdHandler(){
        gameHandlerHashMap = Maps.newHashMap();
        for (GameHandler gameHandler : gameHandlers) {
            gameHandlerHashMap.put(gameHandler.cmd(), gameHandler);
        }
    }

    private void registerLogicHandler(){
        EnumMap<LogicEventType, LogicHandler> logicHandlers = new EnumMap<LogicEventType, LogicHandler>(LogicEventType.class);
        {
            logicHandlers.put(LogicEventType.LOGIC_PLAYER_DISCONNECT, this::ON_LOGIC_PLAYER_DISCONNECT);
            logicHandlers.put(LogicEventType.LOGIC_PLAYER_CMD_REQUEST, this::ON_LOGIC_PLAYER_CMD_REQUEST);
        }
        this.logicHandlers = Collections.unmodifiableMap(logicHandlers);
    }

    private void ON_LOGIC_PLAYER_DISCONNECT(LogicEvent logicEvent){
        int charaId = logicEvent.getIntParam();
        GameObjectChar gameObjectChar = GameObjectCharMng.getGameObjectChar(charaId);
        GameObjectCharMng.downline(gameObjectChar);
    }
    private void ON_LOGIC_PLAYER_CMD_REQUEST(LogicEvent logicEvent){
        int cmd = logicEvent.getIntParam();
        ByteBuf buff = logicEvent.getByteBuf();
        ChannelHandlerContext context = logicEvent.getContext();

        Attribute<GameObjectChar> attr = context.channel().attr(ServerHandler.akey);
        GameObjectChar session = null;
        if ((attr != null) && (attr.get() != null)) {
            session = attr.get();
            GameObjectChar.GAMEOBJECTCHAR_THREAD_LOCAL.set(session);
        }

        GameHandler gameHandler = gameHandlerHashMap.getOrDefault(cmd, null);
        if (gameHandler != null) {
            try {
                long beginMill = System.currentTimeMillis();
                if(! (gameHandler instanceof CMD_ECHO || gameHandler instanceof CMD_MULTI_MOVE_TO || gameHandler instanceof CMD_HEART_BEAT)){//todo 打印消息
                    logger.info("recive msg!=>"+gameHandler);
                }
                gameHandler.process(context, buff);
                long cost = System.currentTimeMillis()-beginMill;
                if(cost>30){
                    logger.error(gameHandler+",cost==>"+cost);
                }
            } catch (Exception e) {
                logger.error(String.format("Fail to execute cmd: %d, buff: %s", cmd, buff), e);
            }
        } else {
            logger.debug(String.format("Cannot find a match cmd: %d, buff: %s", cmd, buff));
        }
    }

    public void tick() {

    }

    public void onLogicEvent(LogicEvent event) {
        LogicHandler logicHandler = logicHandlers.get(event.getLogicEventType());
        logicHandler.handler(event);
    }
}
