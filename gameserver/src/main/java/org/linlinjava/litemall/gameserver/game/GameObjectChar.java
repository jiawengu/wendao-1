package org.linlinjava.litemall.gameserver.game;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.db.domain.Map;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_61593_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
import org.linlinjava.litemall.gameserver.data.write.*;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.GameParty;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.linlinjava.litemall.gameserver.user_logic.UserLogic;
import org.slf4j.Logger;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class GameObjectChar {
    private static final Logger log = org.slf4j.LoggerFactory.getLogger(GameObjectChar.class);
    private final int accountid;
    private ChannelHandlerContext ctx;
    public static final ThreadLocal<GameObjectChar> GAMEOBJECTCHAR_THREAD_LOCAL = new ThreadLocal();

    public Chara chara;
    public Characters characters;
    public UserLogic logic;
    public GameMap gameMap;
    public GameTeam gameTeam;
    public int upduizhangid;
    public long heartEcho;
    private AtomicBoolean lock = new AtomicBoolean(false);

    public boolean lock() {
        return this.lock.compareAndSet(false, true);
    }

    public void unlock() {
        this.lock.set(false);
    }

    public GameObjectChar(Characters characters) {
        String data = characters.getData();
        Chara chara = org.linlinjava.litemall.db.util.JSONUtils.parseObject(data, Chara.class);
        chara.id = characters.getId().intValue();
        this.chara = chara;
        this.characters = characters;
        this.accountid = characters.getAccountId();
    }

    public boolean isOnline(){
        return null!=ctx && chara!=null;
    }

    public void closeChannel(){
        if(null!=ctx){
            ctx.close();
        }
    }

    public GameObjectChar(int accountid, ChannelHandlerContext ctx) {
        this.accountid = accountid;
        this.ctx = ctx;
    }

    public boolean equals(Object obj) {
        if ((obj instanceof GameObjectChar)) {
            GameObjectChar gs = (GameObjectChar) obj;
            if ((this.chara != null) && (gs.chara != null) && (this.chara.id == gs.chara.id)) {
                return true;
            }
        }
        return false;
    }

    public void creator(GameTeam gameTeam) {
        this.gameTeam = gameTeam;
    }

    public synchronized void init(Characters characters) {
        String data = characters.getData();
        Chara chara = (Chara) org.linlinjava.litemall.db.util.JSONUtils.parseObject(data, Chara.class);
        chara.id = characters.getId().intValue();
        this.chara = chara;
        this.characters = characters;
        this.logic = new UserLogic();

        this.logic.init(chara.id, this.logic, this);
        //GameObjectCharMng.add(this);
        // herder todo 不允许在副本地图登录
        String mapSS[]  = {"黑风洞", "兰若寺", "烈火涧"};
        for(String s: mapSS){
            Pattern pattern = Pattern.compile(s + "(.*?)");
            Matcher matcher = pattern.matcher(chara.mapName);
            if(matcher.find()){
                chara.mapName = "天墉城";
                Map map = GameData.that.baseMapService.findOneByName("天墉城");
                chara.x = map.getX().intValue();
                chara.y = map.getY().intValue();
                break;
            }
        }

        GameMap gameMap = GameLine.getGameMap(chara.line, chara.mapName);
        System.out.println("login init PartyId:" + chara.partyId);
        if(chara.partyId > 0){
            GameParty party = GameCore.that.partyMgr.get(chara.partyId);
            if(party == null){
                chara.partyId = 0;
                chara.partyName = "";
            }else{
                chara.partyName = party.data.getName();
            }
        }
        this.gameMap = gameMap;
        GameObjectCharMng.add(this);
    }
    public static final GameObjectChar getGameObjectChar() {
        return GAMEOBJECTCHAR_THREAD_LOCAL.get();
    }

    public static void send(BaseWrite baseWrite, Object obj) {
        GameObjectChar gameObjectChar = (GameObjectChar) GAMEOBJECTCHAR_THREAD_LOCAL.get();

        if(!gameObjectChar.isOnline()){
            return;
        }
        ByteBuf write = baseWrite.write(obj);
        gameObjectChar.ctx.writeAndFlush(write);
    }

    public static void send(BaseWrite baseWrite, Object obj, int id) {
        GameObjectChar gameObjectChar = GameObjectCharMng.getGameObjectChar(id);
        if (gameObjectChar == null || !gameObjectChar.isOnline()) {
            return;
        }
        ByteBuf write = baseWrite.write(obj);
        gameObjectChar.ctx.writeAndFlush(write);
    }

    public static void sendduiwu(BaseWrite baseWrite, Object obj, int duiyuanid) {
        GameObjectChar gameObjectChar = GameObjectCharMng.getGameObjectChar(duiyuanid);
        if ((gameObjectChar.gameTeam != null) && (gameObjectChar.gameTeam.duiwu != null)) {
            for (int i = 0; i < gameObjectChar.gameTeam.duiwu.size(); i++) {
                GameObjectChar gameObjectChar1 = GameObjectCharMng.getGameObjectChar(((Chara) gameObjectChar.gameTeam.duiwu.get(i)).id);
                if(!gameObjectChar1.isOnline()){
                    continue;
                }
                ByteBuf write = baseWrite.write(obj);
                gameObjectChar1.ctx.writeAndFlush(write);
            }
        } else {
            ByteBuf write = baseWrite.write(obj);
            gameObjectChar.ctx.writeAndFlush(write);
        }
    }


    protected void send0(ByteBuf write) {
        if(isOnline()){
            this.ctx.writeAndFlush(write);
        }
    }

    public void offline() {
        try {
            if ((this.gameTeam != null) && (this.gameTeam.duiwu != null) && (this.gameTeam.duiwu.size() > 0)) {
                if (((Chara) this.gameTeam.duiwu.get(0)).id == this.chara.id) {
                    for (int i = 0; i < this.gameTeam.zhanliduiyuan.size(); i++) {
                        List<org.linlinjava.litemall.gameserver.data.vo.Vo_4119_0> object1 = new ArrayList();
                        GameObjectCharMng.getGameObjectChar(((Vo_4121_0) this.gameTeam.zhanliduiyuan.get(i)).id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M4119_0(), object1);
                        List<Vo_4121_0> vo_4121_0List = new ArrayList();
                        GameObjectCharMng.getGameObjectChar(((Vo_4121_0) this.gameTeam.zhanliduiyuan.get(i)).id).sendOne(new M4121_0(), vo_4121_0List);
                        Vo_20480_0 vo_20480_0 = new Vo_20480_0();
                        vo_20480_0.msg = "队伍解散了。";
                        vo_20480_0.time = 1562593376;
                        GameObjectCharMng.getGameObjectChar(((Vo_4121_0) this.gameTeam.zhanliduiyuan.get(i)).id).sendOne(new M20480_0(), vo_20480_0);
                        Vo_61671_0 vo_61671_0 = new Vo_61671_0();
                        vo_61671_0.id = ((Chara) this.gameTeam.duiwu.get(i)).id;
                        vo_61671_0.count = 0;
                        GameObjectCharMng.getGameObjectChar(this.chara.id).gameMap.send(new org.linlinjava.litemall.gameserver.data.write.MSG_TITLE(), vo_61671_0);
                    }

                    for (int i = 0; i < GameObjectCharMng.getGameObjectChar(this.chara.id).gameTeam.zhanliduiyuan.size() - 1; i++) {
                        GameObjectCharMng.getGameObjectChar(((Vo_4121_0) GameObjectCharMng.getGameObjectChar(this.chara.id).gameTeam.zhanliduiyuan.get(i + 1)).id).gameTeam = null;
                    }
                    Vo_61593_0 vo_61593_0 = new Vo_61593_0();
                    vo_61593_0.ask_type = "request_join";
                    sendOne(new MSG_CLEAN_ALL_REQUEST(), vo_61593_0);

                    vo_61593_0 = new Vo_61593_0();
                    vo_61593_0.ask_type = "request_team_leader";
                    send(new MSG_CLEAN_ALL_REQUEST(), vo_61593_0);
                    List<Vo_4121_0> vo_4121_0List = new ArrayList();
                    sendOne(new M4121_0(), vo_4121_0List);
                    this.gameTeam = null;
                } else {
                    Vo_61671_0 vo_61671_0 = new Vo_61671_0();
                    vo_61671_0.id = this.chara.id;
                    vo_61671_0.count = 0;
                    gameMap.send(new MSG_TITLE(), vo_61671_0);
                    List<org.linlinjava.litemall.gameserver.data.vo.Vo_4119_0> object1 = new ArrayList();
                    sendOne(new org.linlinjava.litemall.gameserver.data.write.M4119_0(), object1);
                    List<Vo_4121_0> vo_4121_0List = new ArrayList();
                    sendOne(new M4121_0(), vo_4121_0List);
                    Vo_20480_0 vo_20480_0 = new Vo_20480_0();
                    vo_20480_0.msg = "你离开了队伍";
                    vo_20480_0.time = 1562593376;
                    sendOne(new M20480_0(), vo_20480_0);
                    for (int i = 0; i < this.gameTeam.duiwu.size(); i++) {
                        org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = org.linlinjava.litemall.gameserver.process.GameUtil.MSG_UPDATE_APPEARANCE((Chara) this.gameTeam.duiwu.get(i));
                        GameObjectCharMng.getGameObjectChar(((Chara) this.gameTeam.duiwu.get(i)).id).sendOne(new org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_APPEARANCE(), vo_61661_0);
                    }

                    org.linlinjava.litemall.gameserver.data.vo.Vo_49189_0 vo_49189_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_49189_0();
                    sendOne(new org.linlinjava.litemall.gameserver.data.write.M49189_0(), vo_49189_0);
                    for (int i = 0; i < this.gameTeam.duiwu.size(); i++) {
                        if (((Chara) this.gameTeam.duiwu.get(i)).id == this.chara.id) {
                            this.gameTeam.duiwu.remove(i);
                        }
                    }
                    for (int i = 0; i < this.gameTeam.zhanliduiyuan.size(); i++) {
                        if (((Vo_4121_0) this.gameTeam.zhanliduiyuan.get(i)).id == this.chara.id) {
                            this.gameTeam.zhanliduiyuan.remove(i);
                        }
                    }
                    List<Chara> duiwu = GameObjectCharMng.getGameObjectChar(this.chara.id).gameTeam.duiwu;
                    org.linlinjava.litemall.gameserver.process.GameUtil.MSG_UPDATE_TEAM_LIST(duiwu);
                    org.linlinjava.litemall.gameserver.process.GameUtil.MSG_UPDATE_TEAM_LIST_EX(GameObjectCharMng.getGameObjectChar(this.chara.id).gameTeam.zhanliduiyuan);

                    org.linlinjava.litemall.gameserver.data.vo.Vo_20568_0 vo_20568_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20568_0();
                    vo_20568_0.gid = "";
                    GameObjectCharMng.getGameObjectChar(((Chara) this.gameTeam.duiwu.get(0)).id).sendOne(new MSG_TEAM_COMMANDER_GID(), vo_20568_0);

                    for (int i = 0; i < duiwu.size(); i++) {
                        vo_20480_0 = new Vo_20480_0();
                        vo_20480_0.msg = (this.chara.name + "离开了队伍");
                        vo_20480_0.time = 1562593376;
                        GameObjectCharMng.getGameObjectChar(((Chara) duiwu.get(i)).id).sendOne(new M20480_0(), vo_20480_0);

                        org.linlinjava.litemall.gameserver.data.vo.Vo_45124_0 vo_45124_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45124_0();
                        GameObjectCharMng.getGameObjectChar(((Chara) duiwu.get(i)).id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M45124_0(), vo_45124_0);
                    }
                }
            }
        } catch (Exception e) {
            log.error("", e);
        }
        if(null!=gameMap){
            try {
                this.gameMap.send(new MSG_DISAPPEAR_Chara(), Integer.valueOf(this.chara.id));
                this.gameMap.leave(GameObjectCharMng.getGameObjectChar(this.chara.id));
            } catch (Exception e) {
                log.error("", e);
            }

            if(this.gameMap.isDugeno()){
                Map map = GameData.that.baseMapService.findOneByName("天墉城");
                this.chara.mapid = map.getMapId();
                this.chara.y = map.getY().intValue();
                this.chara.x = map.getX().intValue();
            }
        }

        this.chara.updatetime = System.currentTimeMillis();
        this.chara.online_time += this.chara.updatetime - this.chara.uptime;

        this.closeChannel();
    }


    public void sendOne(BaseWrite baseWrite, Object obj) {
        if(this.ctx == null){ return; }
        ByteBuf buff = baseWrite.write(obj);
        ByteBuf copy = buff.copy();
        send0(copy);
    }

    public int getAccountid() {
        return accountid;
    }
}
