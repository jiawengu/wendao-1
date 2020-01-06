/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.GameHandler;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_APPEARANCE;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_TITLE;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M8165_0;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*     */ import org.linlinjava.litemall.gameserver.game.GameTeam;
/*     */ import org.springframework.stereotype.Service;
/*     */

/**
 * CMD_RETURN_TEAM
 */
/*     */ @Service
/*     */ public class C28_0
/*     */   implements GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  29 */     GameTeam gameTeam = GameObjectChar.getGameObjectChar().gameTeam;
/*     */     
/*  31 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*  33 */     GameObjectChar.getGameObjectChar().gameTeam = GameObjectCharMng.getGameObjectChar(((Chara)gameTeam.duiwu.get(0)).id).gameTeam;
/*     */     
/*  35 */     GameObjectChar session1 = GameObjectCharMng.getGameObjectChar(((Chara)gameTeam.duiwu.get(0)).id);
/*     */     
/*  37 */     GameObjectChar.getGameObjectChar().gameTeam.duiwu.add(chara);
/*  38 */     for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.duiwu.size(); i++) {
/*  39 */       GameObjectChar session = GameObjectCharMng.getGameObjectChar(((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i)).id);
/*  40 */       session.gameTeam = GameObjectChar.getGameObjectChar().gameTeam;
/*     */     }
/*     */     
/*  43 */     GameObjectChar.getGameObjectChar().gameMap.joinduiyuan(GameObjectChar.getGameObjectChar(), session1.chara);
/*     */     
/*  45 */     for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan.size(); i++) {
/*  46 */       GameObjectChar session = GameObjectCharMng.getGameObjectChar(((Vo_4121_0)GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan.get(i)).id);
/*  47 */       for (int j = 0; j < session.gameTeam.zhanliduiyuan.size(); j++) {
/*  48 */         if (((Vo_4121_0)session.gameTeam.zhanliduiyuan.get(j)).id == chara.id) {
/*  49 */           ((Vo_4121_0)session.gameTeam.zhanliduiyuan.get(j)).memberteam_status = 1;
/*     */         }
/*     */       }
/*     */     }
/*  53 */     for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.duiwu.size(); i++) {
/*  54 */       Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i));
/*  55 */       GameObjectCharMng.getGameObjectChar(((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i)).id).sendOne(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*  56 */       Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/*  57 */       vo_8165_0.msg = (chara.name + "回到队伍中");
/*  58 */       vo_8165_0.active = 0;
/*  59 */       GameObjectCharMng.getGameObjectChar(((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i)).id).sendOne(new M8165_0(), vo_8165_0);
/*     */     }
/*     */     
/*  62 */     Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/*  63 */     vo_61671_0.id = ((Chara)GameObjectCharMng.getGameObjectChar(((Chara)gameTeam.duiwu.get(0)).id).gameTeam.duiwu.get(0)).id;
/*  64 */     vo_61671_0.count = 2;
/*  65 */     vo_61671_0.list.add(Integer.valueOf(2));
/*  66 */     vo_61671_0.list.add(Integer.valueOf(3));
/*  67 */     session1.gameMap.send(new MSG_TITLE(), vo_61671_0);
/*     */     
/*  69 */     vo_61671_0 = new Vo_61671_0();
/*  70 */     vo_61671_0.id = chara.id;
/*  71 */     vo_61671_0.count = 2;
/*  72 */     vo_61671_0.list.add(Integer.valueOf(2));
/*  73 */     vo_61671_0.list.add(Integer.valueOf(5));
/*  74 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/*  75 */     Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/*  76 */     vo_20480_0.msg = (chara.name + "回到了队伍。");
/*  77 */     vo_20480_0.time = 1562593376;
/*  78 */     GameObjectChar.send(new M20480_0(), vo_20480_0);
/*  79 */     vo_20480_0 = new Vo_20480_0();
/*  80 */     vo_20480_0.msg = (chara.name + "你回到了#Y#<" + session1.chara.name + "#>#n的队伍。");
/*  81 */     vo_20480_0.time = 1562593376;
/*  82 */     GameObjectChar.send(new M20480_0(), vo_20480_0);
/*     */     
/*  84 */     GameUtil.a4119(gameTeam.duiwu);
/*  85 */     GameUtil.a4121(gameTeam.zhanliduiyuan);
/*     */     
/*     */ 
/*  88 */     vo_61671_0 = new Vo_61671_0();
/*  89 */     vo_61671_0.id = chara.id;
/*  90 */     vo_61671_0.count = 2;
/*  91 */     vo_61671_0.list.add(Integer.valueOf(2));
/*  92 */     vo_61671_0.list.add(Integer.valueOf(5));
/*  93 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/*     */     
/*     */ 
/*  96 */     vo_61671_0 = new Vo_61671_0();
/*  97 */     vo_61671_0.id = ((Chara)GameObjectCharMng.getGameObjectChar(((Chara)gameTeam.duiwu.get(0)).id).gameTeam.duiwu.get(0)).id;
/*  98 */     vo_61671_0.count = 2;
/*  99 */     vo_61671_0.list.add(Integer.valueOf(2));
/* 100 */     vo_61671_0.list.add(Integer.valueOf(3));
/* 101 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/*     */   }
/*     */   
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 107 */     return 28;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C28_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */