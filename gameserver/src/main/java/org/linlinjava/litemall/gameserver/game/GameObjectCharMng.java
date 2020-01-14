package org.linlinjava.litemall.gameserver.game;

import io.netty.buffer.ByteBuf;

import java.util.HashMap;
import java.util.List;

import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.db.util.JSONUtils;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class GameObjectCharMng
{
    private static final Logger log = LoggerFactory.getLogger(GameObjectCharMng.class);
    private static final HashMap<Integer, GameObjectChar> gameObjectCharList = new HashMap<>();

//    public static void add(GameObjectChar gameObjectChar) {
//        if (gameObjectCharList.contains(gameObjectChar)) {
//            for (GameObjectChar gameSession : gameObjectCharList) {
//                if (gameObjectChar.chara.id == gameSession.chara.id) {
//                gameSession.ctx.disconnect();
//                gameObjectChar.gameTeam = gameSession.gameTeam;
//                gameObjectCharList.remove(gameSession);
//                }
//            }
//        }
//        gameObjectCharList.add(gameObjectChar);
//    }

    public static void sendAll(BaseWrite baseWrite, Object obj) {
        for(GameObjectChar session : gameObjectCharList.values()){
            if(session.ctx != null){
                ByteBuf write = baseWrite.write(obj);
                session.ctx.writeAndFlush(write);
            }
        }
    }

    public static HashMap<Integer, GameObjectChar> getGameObjectCharList() {
        return gameObjectCharList;
    }

    public static void sendAllmap(BaseWrite baseWrite, Object obj, int mapid) {
        for (GameObjectChar session : gameObjectCharList.values()) {
            if (session.gameMap.id == mapid) {
                if(session.ctx != null){
                    ByteBuf write = baseWrite.write(obj);
                    session.ctx.writeAndFlush(write);
                }
            }
        }
    }

    public static void sendAllmapname(BaseWrite baseWrite, Object obj, String mapname) {
        for (GameObjectChar session : gameObjectCharList.values()) {
            if (session.ctx != null && session.gameMap.name.equals(mapname)) {
                ByteBuf write = baseWrite.write(obj);
                session.ctx.writeAndFlush(write);
            }
        }
    }

    public static final GameObjectChar getGameObjectChar(int id) {
        GameObjectChar exist = gameObjectCharList.get(id);
        if(exist != null){
            return exist;
        }
        Characters characters = GameData.that.baseCharactersService.findById(id);
        if (characters == null) {
            return null;
        }
        GameObjectChar gameObjectChar = new GameObjectChar(characters);
        gameObjectCharList.put(id, gameObjectChar);
        return gameObjectChar;
    }

    public static HashMap<Integer, GameObjectChar> getAll() {
        return gameObjectCharList;
    }

    public static void remove(GameObjectChar gameObjectChar) {
        gameObjectChar.chara.updatetime = System.currentTimeMillis();
        save(gameObjectChar);
    }

    public static void save(GameObjectChar gameObjectChar) {
        String data = gameObjectChar.characters.getData();
        Chara chara111 = JSONUtils.parseObject(data, Chara.class);
        if (chara111.level > gameObjectChar.chara.level) {
            log.error("人物等级{old}",chara111.name,chara111.level);
            log.error("人物等级{new}",gameObjectChar.chara.name,gameObjectChar.chara.level);
            log.error("人物队伍信息", gameObjectChar.gameTeam.toString());
            throw new RuntimeException("角色等级回档！！！");
        }
        gameObjectChar.characters.setData(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(gameObjectChar.chara));
        GameData.that.baseCharactersService.updateById(gameObjectChar.characters);
        gameObjectChar.logic.cacheSave();
    }

    public static void offlineObj(GameObjectChar obj){
        obj.offline();
        obj.ctx = null;
        gameObjectCharList.remove(obj.chara.id);
    }

}
