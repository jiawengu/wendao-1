package org.linlinjava.litemall.gameserver.game;

import io.netty.buffer.ByteBuf;

import java.util.Iterator;
import java.util.List;

import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.db.util.JSONUtils;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Async;


public class GameObjectCharMng
{
    private static final Logger log = LoggerFactory.getLogger(GameObjectCharMng.class);
    private static final List<GameObjectChar> gameObjectCharList = new java.util.concurrent.CopyOnWriteArrayList();

    public static void add(GameObjectChar gameObjectChar) {
        log.info(gameObjectChar.chara.name+"put GameObjectMng cache!");
        if (gameObjectCharList.contains(gameObjectChar)) {
            for (GameObjectChar gameSession : gameObjectCharList) {
                if (gameObjectChar.chara.id == gameSession.chara.id) {
                    gameSession.closeChannel();
                    gameObjectChar.gameTeam = gameSession.gameTeam;
                    gameObjectCharList.remove(gameSession);
                    throw new RuntimeException("不应该走到这里");
                }
            }
        }
        gameObjectCharList.add(gameObjectChar);
    }

    public static void relogin(GameObjectChar newSession, int charaId){
        int count = 0;
        for (Iterator<GameObjectChar> iter = gameObjectCharList.iterator();iter.hasNext();) {
            GameObjectChar gameSession = iter.next();
            if (charaId == gameSession.chara.id) {
                downline(gameSession);
                count++;
            }
        }
        assert count==1;
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
        for (int i = 0; i < gameObjectCharList.size(); i++) {
            GameObjectChar session = gameObjectCharList.get(i);
            ByteBuf write = baseWrite.write(obj);
            session.send0(write);
        }
    }

    public static List<GameObjectChar> getGameObjectCharList() {
        return gameObjectCharList;
    }

    public static void sendAllmap(BaseWrite baseWrite, Object obj, int mapid) {
        for (int i = 0; i < gameObjectCharList.size(); i++) {
            GameObjectChar gameObjectChar = gameObjectCharList.get(i);
            if (gameObjectChar.isOnline() && gameObjectChar.gameMap.id == mapid ) {
                ByteBuf write = baseWrite.write(obj);
                gameObjectChar.send0(write);
            }
        }
    }

    public static void sendAllmapname(BaseWrite baseWrite, Object obj, String mapname) {
        for (int i = 0; i < gameObjectCharList.size(); i++) {
            GameObjectChar gameObjectChar = gameObjectCharList.get(i);
            if (gameObjectChar.isOnline() && gameObjectChar.gameMap.name.equals(mapname)) {
                ByteBuf write = baseWrite.write(obj);
                gameObjectChar.send0(write);
            }
        }
    }

    public static final boolean isCharaCached(int charaId) {
        for (GameObjectChar gameObjectChar : gameObjectCharList) {
            if (charaId==gameObjectChar.chara.id) {
                return true;
            }
        }
        return false;
    }
    public static final GameObjectChar getGameObjectChar(int id) {
        for (GameObjectChar gameObjectChar : gameObjectCharList) {
            if (gameObjectChar.chara.id == id) {
                return gameObjectChar;
            }
        }
        Characters characters = GameData.that.baseCharactersService.findById(id);
        if (characters == null) {
            return null;
        }
        GameObjectChar gameObjectChar = new GameObjectChar(characters);
        gameObjectCharList.add(gameObjectChar);
        return gameObjectChar;
    }

    public static void downline(GameObjectChar gameObjectChar) {
        log.info(gameObjectChar.characters.getName()+"downline!");
        gameObjectChar.offline();
        save(gameObjectChar);

        gameObjectCharList.remove(gameObjectChar);
    }

    public static void save(GameObjectChar gameObjectChar) {
        if(null!=gameObjectChar.chara) {
            synchronized (gameObjectChar) {
                String data = gameObjectChar.characters.getData();
                Chara chara111 = JSONUtils.parseObject(data, Chara.class);
                if (chara111.level > gameObjectChar.chara.level) {
                    log.error("人物等级{old}", chara111.name, chara111.level);
                    log.error("人物等级{new}", gameObjectChar.chara.name, gameObjectChar.chara.level);
                    log.error("人物队伍信息", gameObjectChar.gameTeam.toString());
                    throw new RuntimeException("角色等级回档！！！");
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
}
