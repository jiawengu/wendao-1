//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.game;

import io.netty.buffer.ByteBuf;
import io.netty.util.ReferenceCountUtil;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.db.domain.NpcPoint;
import org.linlinjava.litemall.gameserver.data.vo.*;
import org.linlinjava.litemall.gameserver.data.write.*;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.process.GameUtilRenWu;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;

@Service("gmmmasdfasdfmmmm")
@Scope("prototype")
public class GameMap {
    private static final Logger log = LoggerFactory.getLogger(GameMap.class);
    public int id;
    public String name;
    public int x;
    public int y;
    public List<GameObjectChar> sessionList = new CopyOnWriteArrayList();
    public GameShiDao gameShiDao = new GameShiDao();

    public GameMap() {
    }

    public List<GameObjectChar> getSessionList() {
        return this.sessionList;
    }

    public void join(GameObjectChar gameObjectChar) {
        gameObjectChar.gameMap.leave(gameObjectChar);
        this.sessionList.remove(gameObjectChar);
        this.sessionList.add(gameObjectChar);
        Chara chara = gameObjectChar.chara;
        List<Npc> npcList = GameData.that.baseNpcService.findByMapId(this.id);
        gameObjectChar.gameMap = this;
        chara.mapid = this.id;
        chara.mapName = this.name;
        Vo_45157_0 vo_45157_0 = new Vo_45157_0();
        vo_45157_0.id = chara.id;
        vo_45157_0.mapId = chara.mapid;
        gameObjectChar.sendOne(new MSG_CLEAR_ALL_CHAR(), vo_45157_0);
        Vo_65505_0 vo_65505_1 = GameUtil.a65505(chara);
        gameObjectChar.sendOne(new MSG_ENTER_ROOM(), vo_65505_1);
        Iterator var6 = npcList.iterator();

        while(var6.hasNext()) {
            Npc npc = (Npc)var6.next();
            gameObjectChar.sendOne(new M65529_npc(), npc);
        }

        List<NpcPoint> list = GameData.that.baseNpcPointService.findByMapname(this.name);
        gameObjectChar.sendOne(new MSG_EXITS(), list);
        Vo_65529_0 vo_65529_0 = GameUtil.MSG_APPEAR(chara);
        this.send(new MSG_APPEAR(), vo_65529_0);
        Vo_61671_0 vo_61671_0;
        if (gameObjectChar.gameTeam != null && gameObjectChar.gameTeam.duiwu != null && gameObjectChar.gameTeam.duiwu.size() > 0) {
            vo_61671_0 = new Vo_61671_0();
            vo_61671_0.id = ((Chara)gameObjectChar.gameTeam.duiwu.get(0)).id;
            vo_61671_0.count = 2;
            vo_61671_0.list.add(2);
            vo_61671_0.list.add(3);
            gameObjectChar.gameMap.send(new MSG_TITLE(), vo_61671_0);
        }

        Iterator var13 = this.sessionList.iterator();

        while(var13.hasNext()) {
            GameObjectChar gameSession = (GameObjectChar)var13.next();
            if (gameSession.ctx != null && gameSession.chara != null) {
                vo_65529_0 = GameUtil.MSG_APPEAR(gameSession.chara);
                GameUtil.genchongfei(gameSession.chara);
                if(isTTTMap()){
                    if(gameObjectChar.chara!=null && gameObjectChar.chara.ttt_layer==gameSession.chara.ttt_layer){
                        gameObjectChar.sendOne(new MSG_APPEAR(), vo_65529_0);
                    }
                }else{
                    gameObjectChar.sendOne(new MSG_APPEAR(), vo_65529_0);
                }
                if (gameSession.gameTeam != null && gameSession.gameTeam.duiwu != null && gameSession.gameTeam.duiwu.size() > 0) {
                     vo_61671_0 = new Vo_61671_0();
                    vo_61671_0.id = ((Chara)gameSession.gameTeam.duiwu.get(0)).id;
                    vo_61671_0.count = 2;
                    vo_61671_0.list.add(2);
                    vo_61671_0.list.add(3);
                    gameObjectChar.sendOne(new MSG_TITLE(), vo_61671_0);
                }
            }
        }

        vo_61671_0 = new Vo_61671_0();
        vo_61671_0.id = chara.mapid;
        vo_61671_0.count = 0;
        gameObjectChar.sendOne(new MSG_TITLE(), vo_61671_0);

        if(isTTTMap()){//通天塔
            //初始化
            if(chara.ttt_layer == 0){
                String randomXjName = GameUtil.randomTTTXingJunName();
                short layer = (short) (chara.level-14);
                chara.onEnterTttLayer(layer, randomXjName);
            }

            GameUtil.notifyTTTPanelInfo(chara);
            GameUtilRenWu.notifyTTTTask(chara);

            GameUtil.a45704(chara);
        }
    }

    /**
     * 是否是通天塔地图
     */
    public boolean isTTTMap(){
        return id==37000;
    }

    public void joinduiyuan(GameObjectChar gameObjectChar, Chara charaduizhang) {
        gameObjectChar.gameMap.leave(gameObjectChar);
        this.sessionList.remove(gameObjectChar);
        this.sessionList.add(gameObjectChar);
        Chara chara = gameObjectChar.chara;

        gameObjectChar.gameMap = this;
        chara.x = charaduizhang.x;
        chara.y = charaduizhang.y;
        chara.mapid = charaduizhang.mapid;
        chara.mapName = charaduizhang.mapName;
        Vo_45157_0 vo_45157_0 = new Vo_45157_0();
        vo_45157_0.id = chara.id;
        vo_45157_0.mapId = charaduizhang.mapid;
        gameObjectChar.sendOne(new MSG_CLEAR_ALL_CHAR(), vo_45157_0);
        Vo_65505_0 vo_65505_1 = GameUtil.a65505(chara);
        gameObjectChar.sendOne(new MSG_ENTER_ROOM(), vo_65505_1);

        List<Npc> npcList = GameData.that.baseNpcService.findByMapId(this.id);
        Iterator var7 = npcList.iterator();
        while(var7.hasNext()) {
            Npc npc = (Npc)var7.next();
            gameObjectChar.sendOne(new M65529_npc(), npc);
        }

        List<NpcPoint> list = GameData.that.baseNpcPointService.findByMapname(this.name);
        gameObjectChar.sendOne(new MSG_EXITS(), list);

        Vo_65529_0 vo_65529_0 = GameUtil.MSG_APPEAR(chara);
        this.send(new MSG_APPEAR(), vo_65529_0);

        Iterator var9 = this.sessionList.iterator();
        while(var9.hasNext()) {
            GameObjectChar gameSession = (GameObjectChar)var9.next();
            if (gameSession.ctx != null && gameSession.chara != null) {
                vo_65529_0 = GameUtil.MSG_APPEAR(gameSession.chara);
                gameObjectChar.sendOne(new MSG_APPEAR(), vo_65529_0);
                GameUtil.genchongfei(gameSession.chara);
                if (gameSession.gameTeam != null && gameSession.gameTeam.duiwu.size() > 0) {
                    Vo_61671_0 vo_61671_0 = new Vo_61671_0();
                    vo_61671_0.id = ((Chara)gameSession.gameTeam.duiwu.get(0)).id;
                    vo_61671_0.count = 2;
                    vo_61671_0.list.add(2);
                    vo_61671_0.list.add(3);
                    gameObjectChar.sendOne(new MSG_TITLE(), vo_61671_0);
                }
            }
        }

        Vo_61671_0 vo_61671_0 = new Vo_61671_0();
        vo_61671_0.id = chara.id;
        vo_61671_0.count = 0;
        gameObjectChar.sendOne(new MSG_TITLE(), vo_61671_0);
    }

    public void leave(GameObjectChar gameObjectChar) {
        this.sendNoMe(new M12285_0(), gameObjectChar.chara.id, gameObjectChar);
        this.sendNoMe(new M12285_1(), gameObjectChar.chara.genchong_icon, gameObjectChar);
        this.sessionList.remove(gameObjectChar);
    }

    public void send(BaseWrite baseWrite, Object obj) {
        GameObjectChar session = GameObjectChar.getGameObjectChar();
        ByteBuf buff = baseWrite.write(obj);
        boolean hasSend = false;
        int sendNum = 0;
        Iterator var7 = this.sessionList.iterator();

        while(var7.hasNext()) {
            GameObjectChar gameSession = (GameObjectChar)var7.next();
            if(isTTTMap()&&gameSession.chara.ttt_layer!=session.chara.ttt_layer){
                continue;
            }
            if (gameSession.ctx != null) {
                ++sendNum;
                ByteBuf copy = buff.copy();
                gameSession.send0(copy);
                if (gameSession == session) {
                    hasSend = true;
                }
            }
        }

        if (!hasSend && session != null) {
            session.send0(buff.copy());
        }

        ReferenceCountUtil.release(buff);
    }

    public void sendNoMe(BaseWrite baseWrite, Object obj, GameObjectChar gameObjectChar) {
        int sendNum = 0;
        ByteBuf buff = baseWrite.write(obj);
        Iterator var6 = this.sessionList.iterator();

        while(var6.hasNext()) {
            GameObjectChar gameSession = (GameObjectChar)var6.next();
            if (!gameObjectChar.equals(gameSession) && gameSession.ctx != null) {
                ++sendNum;
                ByteBuf copy = buff.copy();
                gameSession.send0(copy);
            }
        }

        ReferenceCountUtil.release(buff);
    }

    public void sendNoMeduiwu(BaseWrite baseWrite, Object obj, GameObjectChar gameObjectChar) {
        int sendNum = 0;
        ByteBuf buff = baseWrite.write(obj);
        Iterator var6 = this.sessionList.iterator();

        while(true) {
            while(var6.hasNext()) {
                GameObjectChar gameSession = (GameObjectChar)var6.next();
                boolean has = false;
                ByteBuf copy;
                if (gameSession.gameTeam != null && gameSession.gameTeam.duiwu != null) {
                    for(int i = 0; i < gameSession.gameTeam.duiwu.size(); ++i) {
                        if (gameSession.equals(GameObjectCharMng.getGameObjectChar(((Chara)gameSession.gameTeam.duiwu.get(i)).id))) {
                            has = true;
                        }
                    }

                    if (!has && gameSession.ctx != null) {
                        ++sendNum;
                        copy = buff.copy();
                        gameSession.send0(copy);
                    }
                } else if (!gameObjectChar.equals(gameSession) && gameSession.ctx != null) {
                    ++sendNum;
                    copy = buff.copy();
                    gameSession.send0(copy);
                }
            }

            ReferenceCountUtil.release(buff);
            return;
        }
    }

    public void sendNoMeyoujian(BaseWrite baseWrite, Object obj, GameObjectChar gameObjectChar) {
        ByteBuf buff = baseWrite.write(obj);
        Iterator var5 = this.sessionList.iterator();

        while(var5.hasNext()) {
            GameObjectChar gameSession = (GameObjectChar)var5.next();
            if (gameObjectChar.equals(gameSession) && gameSession.ctx != null) {
                ByteBuf copy = buff.copy();
                gameSession.send0(copy);
            }
        }

        ReferenceCountUtil.release(buff);
    }
}
