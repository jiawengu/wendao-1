/*     */ package org.linlinjava.litemall.gameserver.game;
/*     */
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.ArrayList;
/*     */ import java.util.List;
/*     */ import java.util.concurrent.atomic.AtomicBoolean;
/*     */ import org.linlinjava.litemall.db.domain.Characters;
/*     */ import org.linlinjava.litemall.db.util.JSONUtils;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61593_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M4121_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_TITLE;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_APPEARANCE;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*     */ import org.slf4j.Logger;
/*     */
/*     */ public class GameObjectChar
        /*     */ {
    /*  21 */   private static final Logger log = org.slf4j.LoggerFactory.getLogger(GameObjectChar.class);
    /*     */   public int accountid;
    /*     */   public ChannelHandlerContext ctx;
    /*  24 */   public static final ThreadLocal<GameObjectChar> GAMEOBJECTCHAR_THREAD_LOCAL = new ThreadLocal();
    /*     */
    /*     */   public Chara chara;
    /*     */   public Characters characters;
    /*     */   public GameMap gameMap;
    /*     */   public GameTeam gameTeam;
    /*     */   public int upduizhangid;
    /*     */   public long heartEcho;
    /*  32 */   private AtomicBoolean lock = new AtomicBoolean(false);
    /*     */
    /*     */   public boolean lock() {
        /*  35 */     return this.lock.compareAndSet(false, true);
        /*     */   }
    /*     */
    /*     */   public void unlock() {
        /*  39 */     this.lock.set(false);
        /*     */   }
    /*     */
    /*     */   public GameObjectChar(int accountid, ChannelHandlerContext ctx) {
        /*  43 */     this.accountid = accountid;
        /*  44 */     this.ctx = ctx;
        /*     */   }
    /*     */
    /*     */   public boolean equals(Object obj)
    /*     */   {
        /*  49 */     if ((obj instanceof GameObjectChar)) {
            /*  50 */       GameObjectChar gs = (GameObjectChar)obj;
            /*  51 */       if ((this.chara != null) && (gs.chara != null) && (this.chara.id == gs.chara.id)) {
                /*  52 */         return true;
                /*     */       }
            /*     */     }
        /*  55 */     return false;
        /*     */   }
    /*     */
    /*     */   public void creator(GameTeam gameTeam) {
        /*  59 */     this.gameTeam = gameTeam;
        /*     */   }
    /*     */
    /*     */   public void init(Characters characters) {
        /*  63 */     String data = characters.getData();
        /*  64 */     Chara chara = (Chara)org.linlinjava.litemall.db.util.JSONUtils.parseObject(data, Chara.class);
        /*  65 */     chara.id = characters.getId().intValue();
        /*  66 */     this.chara = chara;
        /*  67 */     this.characters = characters;
        /*  68 */     GameObjectCharMng.add(this);
        /*  69 */     GameMap gameMap = GameLine.getGameMap(chara.line, chara.mapName);
        /*     */
        /*     */
        /*     */
        /*     */
        /*  74 */     this.gameMap = gameMap;
        /*     */   }
    /*     */
    /*     */   public static final GameObjectChar getGameObjectChar() {
        /*  78 */     return (GameObjectChar)GAMEOBJECTCHAR_THREAD_LOCAL.get();
        /*     */   }
    /*     */
    /*     */   public static void send(BaseWrite baseWrite, Object obj) {
        /*  82 */     GameObjectChar gameObjectChar = (GameObjectChar)GAMEOBJECTCHAR_THREAD_LOCAL.get();
        /*  83 */     ByteBuf write = baseWrite.write(obj);
        /*  84 */     gameObjectChar.ctx.writeAndFlush(write);
        /*     */   }
    /*     */
    /*     */   public static void send(BaseWrite baseWrite, Object obj, int id) {
        /*  88 */     GameObjectChar gameObjectChar = GameObjectCharMng.getGameObjectChar(id);
        /*  89 */     if (gameObjectChar == null) {
            /*  90 */       return;
            /*     */     }
        /*  92 */     ByteBuf write = baseWrite.write(obj);
        /*  93 */     gameObjectChar.ctx.writeAndFlush(write);
        /*     */   }
    /*     */
    /*     */   public static void sendduiwu(BaseWrite baseWrite, Object obj, int duiyuanid)
    /*     */   {
        /*  98 */     GameObjectChar gameObjectChar = GameObjectCharMng.getGameObjectChar(duiyuanid);
        /*  99 */     if ((gameObjectChar.gameTeam != null) && (gameObjectChar.gameTeam.duiwu != null)) {
            /* 100 */       for (int i = 0; i < gameObjectChar.gameTeam.duiwu.size(); i++) {
                /* 101 */         GameObjectChar gameObjectChar1 = GameObjectCharMng.getGameObjectChar(((Chara)gameObjectChar.gameTeam.duiwu.get(i)).id);
                /* 102 */         ByteBuf write = baseWrite.write(obj);
                /* 103 */         gameObjectChar1.ctx.writeAndFlush(write);
                /*     */       }
            /*     */     } else {
            /* 106 */       ByteBuf write = baseWrite.write(obj);
            /* 107 */       gameObjectChar.ctx.writeAndFlush(write);
            /*     */     }
        /*     */   }
    /*     */
    /*     */
    /*     */
    /*     */   protected void send0(ByteBuf write)
    /*     */   {
        /* 115 */     this.ctx.writeAndFlush(write);
        /*     */   }
    /*     */
    /*     */   public void offline()
    /*     */   {
        /*     */     try
            /*     */     {
            /* 122 */       if ((this.gameTeam != null) && (this.gameTeam.duiwu != null) && (this.gameTeam.duiwu.size() > 0))
                /*     */       {
                /* 124 */         if (((Chara)this.gameTeam.duiwu.get(0)).id == this.chara.id) {
                    /* 125 */           for (int i = 0; i < this.gameTeam.zhanliduiyuan.size(); i++) {
                        /* 126 */             List<org.linlinjava.litemall.gameserver.data.vo.Vo_4119_0> object1 = new ArrayList();
                        /* 127 */             GameObjectCharMng.getGameObjectChar(((Vo_4121_0)this.gameTeam.zhanliduiyuan.get(i)).id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M4119_0(), object1);
                        /* 128 */             List<Vo_4121_0> vo_4121_0List = new ArrayList();
                        /* 129 */             GameObjectCharMng.getGameObjectChar(((Vo_4121_0)this.gameTeam.zhanliduiyuan.get(i)).id).sendOne(new M4121_0(), vo_4121_0List);
                        /* 130 */             Vo_20480_0 vo_20480_0 = new Vo_20480_0();
                        /* 131 */             vo_20480_0.msg = "队伍解散了。";
                        /* 132 */             vo_20480_0.time = 1562593376;
                        /* 133 */             GameObjectCharMng.getGameObjectChar(((Vo_4121_0)this.gameTeam.zhanliduiyuan.get(i)).id).sendOne(new M20480_0(), vo_20480_0);
                        /* 134 */             Vo_61671_0 vo_61671_0 = new Vo_61671_0();
                        /* 135 */             vo_61671_0.id = ((Chara)this.gameTeam.duiwu.get(i)).id;
                        /* 136 */             vo_61671_0.count = 0;
                        /* 137 */             GameObjectCharMng.getGameObjectChar(this.chara.id).gameMap.send(new MSG_TITLE(), vo_61671_0);
                        /*     */           }
                    /*     */
                    /* 140 */           for (int i = 0; i < GameObjectCharMng.getGameObjectChar(this.chara.id).gameTeam.zhanliduiyuan.size() - 1; i++) {
                        /* 141 */             GameObjectCharMng.getGameObjectChar(((Vo_4121_0)GameObjectCharMng.getGameObjectChar(this.chara.id).gameTeam.zhanliduiyuan.get(i + 1)).id).gameTeam = null;
                        /*     */           }
                    /* 143 */           GameObjectCharMng.getGameObjectChar(this.chara.id).gameTeam = null;
                    /* 144 */           Vo_61593_0 vo_61593_0 = new Vo_61593_0();
                    /* 145 */           vo_61593_0.ask_type = "request_join";
                    /* 146 */           send(new org.linlinjava.litemall.gameserver.data.write.M61593_0(), vo_61593_0);
                    /*     */
                    /*     */
                    /* 149 */           vo_61593_0 = new Vo_61593_0();
                    /* 150 */           vo_61593_0.ask_type = "request_team_leader";
                    /* 151 */           send(new org.linlinjava.litemall.gameserver.data.write.M61593_0(), vo_61593_0);
                    /* 152 */           List<Vo_4121_0> vo_4121_0List = new ArrayList();
                    /* 153 */           GameObjectCharMng.getGameObjectChar(this.chara.id).sendOne(new M4121_0(), vo_4121_0List);
                    /* 154 */           GameObjectCharMng.getGameObjectChar(this.chara.id).gameTeam = null;
                    /*     */         }
                /*     */         else {
                    /* 157 */           Vo_61671_0 vo_61671_0 = new Vo_61671_0();
                    /* 158 */           vo_61671_0.id = this.chara.id;
                    /* 159 */           vo_61671_0.count = 0;
                    /* 160 */           GameObjectCharMng.getGameObjectChar(this.chara.id).gameMap.send(new MSG_TITLE(), vo_61671_0);
                    /* 161 */           List<org.linlinjava.litemall.gameserver.data.vo.Vo_4119_0> object1 = new ArrayList();
                    /* 162 */           GameObjectCharMng.getGameObjectChar(this.chara.id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M4119_0(), object1);
                    /* 163 */           List<Vo_4121_0> vo_4121_0List = new ArrayList();
                    /* 164 */           GameObjectCharMng.getGameObjectChar(this.chara.id).sendOne(new M4121_0(), vo_4121_0List);
                    /* 165 */           Vo_20480_0 vo_20480_0 = new Vo_20480_0();
                    /* 166 */           vo_20480_0.msg = "你离开了队伍";
                    /* 167 */           vo_20480_0.time = 1562593376;
                    /* 168 */           GameObjectCharMng.getGameObjectChar(this.chara.id).sendOne(new M20480_0(), vo_20480_0);
                    /* 169 */           for (int i = 0; i < this.gameTeam.duiwu.size(); i++) {
                        /* 170 */             org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = org.linlinjava.litemall.gameserver.process.GameUtil.MSG_UPDATE_APPEARANCE((Chara)this.gameTeam.duiwu.get(i));
                        /* 171 */             GameObjectCharMng.getGameObjectChar(((Chara)this.gameTeam.duiwu.get(i)).id).sendOne(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
                        /*     */           }
                    /*     */
                    /* 174 */           org.linlinjava.litemall.gameserver.data.vo.Vo_49189_0 vo_49189_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_49189_0();
                    /* 175 */           GameObjectCharMng.getGameObjectChar(this.chara.id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M49189_0(), vo_49189_0);
                    /* 176 */           for (int i = 0; i < this.gameTeam.duiwu.size(); i++) {
                        /* 177 */             if (((Chara)this.gameTeam.duiwu.get(i)).id == this.chara.id) {
                            /* 178 */               this.gameTeam.duiwu.remove(i);
                            /*     */             }
                        /*     */           }
                    /* 181 */           for (int i = 0; i < this.gameTeam.zhanliduiyuan.size(); i++) {
                        /* 182 */             if (((Vo_4121_0)this.gameTeam.zhanliduiyuan.get(i)).id == this.chara.id) {
                            /* 183 */               this.gameTeam.zhanliduiyuan.remove(i);
                            /*     */             }
                        /*     */           }
                    /* 186 */           List<Chara> duiwu = GameObjectCharMng.getGameObjectChar(this.chara.id).gameTeam.duiwu;
                    /* 187 */           org.linlinjava.litemall.gameserver.process.GameUtil.a4119(duiwu);
                    /* 188 */           org.linlinjava.litemall.gameserver.process.GameUtil.a4121(GameObjectCharMng.getGameObjectChar(this.chara.id).gameTeam.zhanliduiyuan);
                    /*     */
                    /* 190 */           org.linlinjava.litemall.gameserver.data.vo.Vo_20568_0 vo_20568_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20568_0();
                    /* 191 */           vo_20568_0.gid = "";
                    /* 192 */           GameObjectCharMng.getGameObjectChar(((Chara)this.gameTeam.duiwu.get(0)).id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M20568_0(), vo_20568_0);
                    /*     */
                    /* 194 */           for (int i = 0; i < duiwu.size(); i++) {
                        /* 195 */             vo_20480_0 = new Vo_20480_0();
                        /* 196 */             vo_20480_0.msg = (this.chara.name + "离开了队伍");
                        /* 197 */             vo_20480_0.time = 1562593376;
                        /* 198 */             GameObjectCharMng.getGameObjectChar(((Chara)duiwu.get(i)).id).sendOne(new M20480_0(), vo_20480_0);
                        /*     */
                        /* 200 */             org.linlinjava.litemall.gameserver.data.vo.Vo_45124_0 vo_45124_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45124_0();
                        /* 201 */             GameObjectCharMng.getGameObjectChar(((Chara)duiwu.get(i)).id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M45124_0(), vo_45124_0);
                        /*     */           }
                    /*     */         }
                /*     */       }
            /*     */     } catch (Exception e) {
            /* 206 */       log.error("", e);
            /*     */     }
        /*     */     try {
            /* 209 */       this.gameMap.send(new org.linlinjava.litemall.gameserver.data.write.M12285_1(), Integer.valueOf(this.chara.id));
            /* 210 */       this.gameMap.leave(GameObjectCharMng.getGameObjectChar(this.chara.id));
            /*     */     } catch (Exception e) {
            /* 212 */       log.error("", e);
            /*     */     }
        /*     */     try {
            /* 215 */       this.chara.updatetime = System.currentTimeMillis();
            /* 216 */       this.chara.online_time += this.chara.updatetime - this.chara.uptime;
            String data = this.characters.getData();
            Chara chara111 = JSONUtils.parseObject(data, Chara.class);
            if (chara111.level > this.chara.level)
            {
                log.error("人物等级{old}",chara111.name,chara111.level);
                log.error("人物等级{new}",this.chara.name,this.chara.level);
                log.error("人物队伍信息", this.gameTeam.toString());
                throw new RuntimeException("角色等级回档！！！");
            }
            /* 217 */       this.characters.setData(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(this.chara));
            /* 218 */       GameData.that.baseCharactersService.updateById(this.characters);
            /*     */     } catch (Exception e) {
            /* 220 */       log.error("", e);
            /*     */     }
        /* 222 */     this.ctx.disconnect();
        /*     */   }
    /*     */
    /*     */
    /*     */   public void sendOne(BaseWrite baseWrite, Object obj)
    /*     */   {
        /* 228 */     ByteBuf buff = baseWrite.write(obj);
        /* 229 */     ByteBuf copy = buff.copy();
        /* 230 */     send0(copy);
        /*     */   }
    /*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\game\GameObjectChar.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */