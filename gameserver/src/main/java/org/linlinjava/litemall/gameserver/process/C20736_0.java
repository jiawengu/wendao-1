/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */
/*     */ import org.linlinjava.litemall.db.domain.Characters;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20568_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61591_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61593_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_TITLE;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*     */ import org.linlinjava.litemall.gameserver.game.GameTeam;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class C20736_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(io.netty.channel.ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  25 */     String select = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);
/*  26 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*  27 */     GameTeam gameTeam = GameObjectChar.getGameObjectChar().gameTeam;
/*     */     
/*  29 */     Characters characters = GameData.that.characterService.findOneByID(GameObjectChar.getGameObjectChar().upduizhangid);
/*  30 */     String data = characters.getData();
/*  31 */     Chara chara1 = (Chara)org.linlinjava.litemall.db.util.JSONUtils.parseObject(data, Chara.class);
/*  32 */     if (select.equals("0")) {
/*  33 */       Vo_61591_0 vo_61591_0 = new Vo_61591_0();
/*  34 */       vo_61591_0.ask_type = "request_team_leader";
/*  35 */       vo_61591_0.name = chara1.name;
/*  36 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61591_0(), vo_61591_0);
/*  37 */       Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/*  38 */       vo_8165_0.msg = "队长拒绝了你的带队申请。";
/*  39 */       vo_8165_0.active = 0;
/*  40 */       GameObjectCharMng.getGameObjectChar(GameObjectChar.getGameObjectChar().upduizhangid);GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M8165_0(), vo_8165_0);
/*     */     }
/*     */     
/*  43 */     if (select.equals("1")) {
/*  44 */       Vo_61593_0 vo_61593_0 = new Vo_61593_0();
/*  45 */       vo_61593_0.ask_type = "request_join";
/*  46 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61593_0(), vo_61593_0);
/*  47 */       vo_61593_0 = new Vo_61593_0();
/*  48 */       vo_61593_0.ask_type = "request_team_leader";
/*  49 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61593_0(), vo_61593_0);
/*     */       
/*  51 */       Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/*  52 */       vo_61671_0.id = chara1.id;
/*  53 */       vo_61671_0.count = 2;
/*  54 */       vo_61671_0.list.add(Integer.valueOf(2));
/*  55 */       vo_61671_0.list.add(Integer.valueOf(3));
/*  56 */       GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/*  57 */       vo_61671_0 = new Vo_61671_0();
/*  58 */       vo_61671_0.id = chara.id;
/*  59 */       vo_61671_0.count = 2;
/*  60 */       vo_61671_0.list.add(Integer.valueOf(2));
/*  61 */       vo_61671_0.list.add(Integer.valueOf(5));
/*  62 */       GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/*  63 */       int index = 0;
/*  64 */       for (int i = 0; i < gameTeam.duiwu.size(); i++) {
/*  65 */         if (((Chara)gameTeam.duiwu.get(i)).id == chara1.id) {
/*  66 */           index = i;
/*     */         }
/*     */       }
/*     */       
/*  70 */       for (int i = 0; i < gameTeam.duiwu.size(); i++) {
/*  71 */         GameObjectCharMng.getGameObjectChar(((Chara)gameTeam.duiwu.get(i)).id).gameTeam.duiwu.set(index, chara);
/*  72 */         GameObjectCharMng.getGameObjectChar(((Chara)gameTeam.duiwu.get(i)).id).gameTeam.duiwu.set(0, GameObjectCharMng.getGameObjectChar(chara1.id).chara);
/*  73 */         if (i != index) {
/*  74 */           Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/*  75 */           vo_20481_0.msg = (((Chara)gameTeam.duiwu.get(0)).name + "成为队长。");
/*  76 */           vo_20481_0.time = 1562987118;
/*  77 */           GameObjectChar.getGameObjectChar();GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*     */         }
/*     */       }
/*  80 */       Vo_4121_0 vo_4121_0 = (Vo_4121_0)gameTeam.zhanliduiyuan.get(0);
/*  81 */       Vo_4121_0 vo_4121_1 = (Vo_4121_0)gameTeam.zhanliduiyuan.get(index);
/*  82 */       for (int i = 0; i < gameTeam.zhanliduiyuan.size(); i++) {
/*  83 */         GameObjectCharMng.getGameObjectChar(((Vo_4121_0)gameTeam.zhanliduiyuan.get(i)).id).gameTeam.zhanliduiyuan.set(0, vo_4121_1);
/*  84 */         GameObjectCharMng.getGameObjectChar(((Vo_4121_0)gameTeam.zhanliduiyuan.get(i)).id).gameTeam.zhanliduiyuan.set(index, vo_4121_0);
/*     */       }
/*  86 */       Vo_20568_0 vo_20568_0 = new Vo_20568_0();
/*  87 */       vo_20568_0.gid = "";
/*     */       
/*     */ 
/*     */ 
/*  91 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M20568_0(), vo_20568_0);
/*  92 */       vo_20568_0 = new Vo_20568_0();
/*  93 */       vo_20568_0.gid = "";
/*  94 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M20568_0(), vo_20568_0);
/*  95 */       Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/*  96 */       vo_20481_0.msg = "你被提升为队长。";
/*  97 */       vo_20481_0.time = 1562987118;
/*  98 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*     */       
/*     */ 
/* 101 */       GameUtil.a4119(gameTeam.duiwu);
/* 102 */       GameUtil.a4121(gameTeam.zhanliduiyuan);
/*     */     }
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 110 */     return 20736;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C20736_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */