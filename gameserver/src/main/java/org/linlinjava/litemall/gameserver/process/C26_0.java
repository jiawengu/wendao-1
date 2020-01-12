/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import java.util.ArrayList;
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20568_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4119_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49189_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61593_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M4121_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_TITLE;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_APPEARANCE;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*     */ import org.linlinjava.litemall.gameserver.game.GameTeam;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class C26_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(io.netty.channel.ChannelHandlerContext ctx, io.netty.buffer.ByteBuf buff)
/*     */   {
/*  24 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*  25 */     GameTeam gameTeam = GameObjectChar.getGameObjectChar().gameTeam;
/*     */     
/*     */ 
/*  28 */     if (chara.id == ((Chara)gameTeam.duiwu.get(0)).id) {
/*  29 */       for (int i = 0; i < gameTeam.zhanliduiyuan.size(); i++) {
/*  30 */         List<Vo_4119_0> object1 = new ArrayList();
/*  31 */         GameObjectCharMng.getGameObjectChar(((Vo_4121_0)gameTeam.zhanliduiyuan.get(i)).id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M4119_0(), object1);
/*  32 */         List<Vo_4121_0> vo_4121_0List = new ArrayList();
/*  33 */         GameObjectCharMng.getGameObjectChar(((Vo_4121_0)gameTeam.zhanliduiyuan.get(i)).id).sendOne(new M4121_0(), vo_4121_0List);
/*  34 */         Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/*  35 */         vo_20480_0.msg = "队伍解散了。";
/*  36 */         vo_20480_0.time = 1562593376;
/*  37 */         GameObjectCharMng.getGameObjectChar(((Vo_4121_0)gameTeam.zhanliduiyuan.get(i)).id).sendOne(new M20480_0(), vo_20480_0);
/*  38 */         Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/*  39 */         vo_61671_0.id = ((Vo_4121_0)gameTeam.zhanliduiyuan.get(i)).id;
/*  40 */         vo_61671_0.count = 0;
/*  41 */         GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/*     */       }
/*     */       
/*  44 */       for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan.size() - 1; i++) {
/*  45 */         GameObjectCharMng.getGameObjectChar(((Vo_4121_0)GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan.get(i + 1)).id).gameTeam = null;
/*     */       }
/*  47 */       GameObjectChar.getGameObjectChar().gameTeam = null;
/*  48 */       Vo_61593_0 vo_61593_0 = new Vo_61593_0();
/*  49 */       vo_61593_0.ask_type = "request_join";
/*  50 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61593_0(), vo_61593_0);
/*     */       
/*     */ 
/*  53 */       vo_61593_0 = new Vo_61593_0();
/*  54 */       vo_61593_0.ask_type = "request_team_leader";
/*  55 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61593_0(), vo_61593_0);
/*  56 */       List<Vo_4121_0> vo_4121_0List = new ArrayList();
/*  57 */       GameObjectChar.send(new M4121_0(), vo_4121_0List);
/*  58 */       GameObjectChar.getGameObjectChar().gameTeam = null;
/*     */     }
/*     */     else {
/*  61 */       Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/*  62 */       vo_61671_0.id = chara.id;
/*  63 */       vo_61671_0.count = 0;
/*  64 */       GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/*  65 */       List<Vo_4119_0> object1 = new ArrayList();
/*  66 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M4119_0(), object1);
/*  67 */       List<Vo_4121_0> vo_4121_0List = new ArrayList();
/*  68 */       GameObjectChar.send(new M4121_0(), vo_4121_0List);
/*  69 */       Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/*  70 */       vo_20480_0.msg = "你离开了队伍";
/*  71 */       vo_20480_0.time = 1562593376;
/*  72 */       GameObjectChar.send(new M20480_0(), vo_20480_0);
/*  73 */       for (int i = 0; i < gameTeam.duiwu.size(); i++) {
/*  74 */         org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE((Chara)gameTeam.duiwu.get(i));
/*  75 */         GameObjectChar.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*     */       }
/*     */       
/*  78 */       Vo_49189_0 vo_49189_0 = new Vo_49189_0();
/*  79 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M49189_0(), vo_49189_0);
/*  80 */       for (int i = 0; i < gameTeam.duiwu.size(); i++) {
/*  81 */         if (((Chara)gameTeam.duiwu.get(i)).id == chara.id) {
/*  82 */           gameTeam.duiwu.remove(i);
/*     */         }
/*     */       }
/*  85 */       for (int i = 0; i < gameTeam.zhanliduiyuan.size(); i++) {
/*  86 */         if (((Vo_4121_0)gameTeam.zhanliduiyuan.get(i)).id == chara.id) {
/*  87 */           gameTeam.zhanliduiyuan.remove(i);
/*     */         }
/*     */       }
/*  90 */       List<Chara> duiwu = GameObjectChar.getGameObjectChar().gameTeam.duiwu;
/*  91 */       GameUtil.a4119(duiwu);
/*  92 */       GameUtil.a4121(GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan);
/*     */       
/*  94 */       Vo_20568_0 vo_20568_0 = new Vo_20568_0();
/*  95 */       vo_20568_0.gid = "";
/*  96 */       GameObjectCharMng.getGameObjectChar(((Chara)gameTeam.duiwu.get(0)).id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M20568_0(), vo_20568_0);
/*     */       
/*  98 */       for (int i = 0; i < duiwu.size(); i++) {
/*  99 */         vo_20480_0 = new Vo_20480_0();
/* 100 */         vo_20480_0.msg = (chara.name + "离开了队伍");
/* 101 */         vo_20480_0.time = 1562593376;
/* 102 */         GameObjectCharMng.getGameObjectChar(((Chara)duiwu.get(i)).id).sendOne(new M20480_0(), vo_20480_0);
/*     */         
/*     */ 
/* 105 */         org.linlinjava.litemall.gameserver.data.vo.Vo_45124_0 vo_45124_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45124_0();
/* 106 */         GameObjectCharMng.getGameObjectChar(((Chara)duiwu.get(i)).id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M45124_0(), vo_45124_0);
/*     */       }
/*     */     }
/* 109 */     GameObjectChar.getGameObjectChar().gameTeam = null;
/*     */   }
/*     */   
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 115 */     return 26;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C26_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */