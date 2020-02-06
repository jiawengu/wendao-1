package org.linlinjava.litemall.gameserver.game;

import io.netty.buffer.ByteBuf;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

import it.unimi.dsi.fastutil.ints.Int2ObjectMap;
import it.unimi.dsi.fastutil.ints.Int2ObjectOpenHashMap;
import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.db.util.JSONUtils;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class GameObjectCharMng
{
    private static final Logger log = LoggerFactory.getLogger(GameObjectCharMng.class);
    /**
     * key:charaId
     */
    private static final Int2ObjectMap<GameObjectChar> gameObjectCharMap = new Int2ObjectOpenHashMap<>();

    public static void add(GameObjectChar gameObjectChar) {
        log.info(gameObjectChar.chara.name+"put GameObjectMng cache!");
        int charaId = gameObjectChar.chara.id;
        if (gameObjectCharMap.containsKey(charaId)) {
            GameObjectChar oldSession = gameObjectCharMap.get(charaId);
            oldSession.closeChannel();
            gameObjectChar.gameTeam = oldSession.gameTeam;
            gameObjectCharMap.remove(charaId);
            log.error("不应该走到这里");
        }
        gameObjectCharMap.put(charaId, gameObjectChar);
    }

    public static void relogin(GameObjectChar newSession, int charaId){
        GameObjectChar oldSession = gameObjectCharMap.get(charaId);
        downline(oldSession);

        newSession.init(GameData.that.characterService.findById(charaId));
        log.info(newSession.chara.name+"relogin!");
    }

    public static void sendOne(int charaId,BaseWrite baseWrite, Object obj){
        GameObjectChar gameObjectChar = getGameObjectChar(charaId);
        if(gameObjectChar.isOnline()){
//            GameObjectChar.send(baseWrite, obj, charaId);
            ByteBuf write = baseWrite.write(obj);
            gameObjectChar.send0(write);
        }
    }

    public static void sendAll(BaseWrite baseWrite, Object obj) {
        for (GameObjectChar session : gameObjectCharMap.values()) {
            ByteBuf write = baseWrite.write(obj);
            session.send0(write);
        }
    }

    public static Collection<GameObjectChar> getGameObjectCharMap() {
        return gameObjectCharMap.values();
    }

    public static void sendAllmap(BaseWrite baseWrite, Object obj, int mapid) {
        for (GameObjectChar gameObjectChar: gameObjectCharMap.values()) {
            if (gameObjectChar.isOnline() && gameObjectChar.gameMap.id == mapid ) {
                ByteBuf write = baseWrite.write(obj);
                gameObjectChar.send0(write);
            }
        }
    }

    public static void sendAllmapname(BaseWrite baseWrite, Object obj, String mapname) {
        for (GameObjectChar gameObjectChar : gameObjectCharMap.values()) {
            if (gameObjectChar.isOnline() && gameObjectChar.gameMap.name.equals(mapname)) {
                ByteBuf write = baseWrite.write(obj);
                gameObjectChar.send0(write);
            }
        }
    }

    public static final boolean isCharaCached(int charaId) {
        return gameObjectCharMap.containsKey(charaId);
    }
    public static final GameObjectChar getGameObjectChar(int charaId) {
        GameObjectChar gameObjectChar = gameObjectCharMap.get(charaId);
        if(null!=gameObjectChar){
            return gameObjectChar;
        }

        Characters characters = GameData.that.baseCharactersService.findById(charaId);
        if (characters == null) {
            return null;
        }
        gameObjectChar = new GameObjectChar(characters);
        gameObjectCharMap.put(charaId, gameObjectChar);
        return gameObjectChar;
    }

    public static void downline(GameObjectChar gameObjectChar) {
        log.info(gameObjectChar.characters.getName()+"downline!");
        gameObjectChar.offline();
        save(gameObjectChar);

        gameObjectCharMap.remove(gameObjectChar.chara.id);
    }

    public static void save(GameObjectChar gameObjectChar) {
        if(null!=gameObjectChar.chara) {
            synchronized (gameObjectChar) {
                String data = gameObjectChar.characters.getData();
                if(null!=data){
                    Chara chara111 = JSONUtils.parseObject(data, Chara.class);
                    if (chara111.level > gameObjectChar.chara.level) {
                        log.error("人物等级{old}", chara111.name, chara111.level);
                        log.error("人物等级{new}", gameObjectChar.chara.name, gameObjectChar.chara.level);
                        log.error("人物队伍信息", gameObjectChar.gameTeam.toString());
                        throw new RuntimeException("角色等级回档！！！");
                    }
                }

                long beginMill = System.currentTimeMillis();
                String charData = org.linlinjava.litemall.db.util.JSONUtils.toJSONString(gameObjectChar.chara);
                gameObjectChar.characters.setData(charData);
                long seriaCost = System.currentTimeMillis() - beginMill;
                beginMill = System.currentTimeMillis();
                GameData.that.baseCharactersService.updateById(gameObjectChar.characters);
//            log.info("save char [{}] db: ==>charData size:{}, serialize cost:{}, db cost:{}", gameObjectChar.chara.name, charData.length(), seriaCost, (System.currentTimeMillis()-beginMill));

            }
        }
    }

    public static void closeServer(){
        List<GameObjectChar> list = new ArrayList<>(gameObjectCharMap.values());
        for(GameObjectChar gameObjectChar:list){
            downline(gameObjectChar);
        }
    }
}
