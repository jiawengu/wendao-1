/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45177_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8425_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M45177_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_APPEARANCE;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class C4382_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  24 */     int pet_id = org.linlinjava.litemall.gameserver.data.GameReadTool.readInt(buff);
/*  25 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*     */ 
/*  28 */     chara.yidongsudu = 0;
/*  29 */     chara.zuoqiId = 0;
/*  30 */     chara.zuoqiwaiguan = 0;
/*  31 */     chara.zuowaiguan = 0;
/*  32 */     for (int i = 0; i < chara.pets.size(); i++) {
/*  33 */       if (((Petbeibao)chara.pets.get(i)).id == pet_id) {
/*  34 */         for (int j = 0; j < ((Petbeibao)chara.pets.get(i)).petShuXing.size(); j++) {
/*  35 */           if (((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(j)).no == 23) {
/*  36 */             chara.yidongsudu = ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).capacity_level;
/*     */           }
/*     */         }
/*  39 */         chara.zuoqiwaiguan = (((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).type + 1000);
/*  40 */         chara.zuowaiguan = typeMounts(((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).type + 1000, chara.menpai, chara.sex - 1);
/*  41 */         chara.zuoqiId = ((Petbeibao)chara.pets.get(i)).id;
/*     */       }
/*     */     }
/*     */     
/*  45 */     if (pet_id != 0) {
/*  46 */       Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/*  47 */       vo_20481_0.msg = "坐骑包裹已开启。";
/*  48 */       vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
/*  49 */       GameObjectChar.getGameObjectChar();GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*     */     } else {
/*  51 */       Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/*  52 */       vo_20481_0.msg = "坐骑包裹已关闭。";
/*  53 */       vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
/*  54 */       GameObjectChar.getGameObjectChar();GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*     */     }
/*     */     
/*     */ 
/*  58 */     Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
/*  59 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*     */     
/*  61 */     Vo_8425_0 vo_8425_0 = new Vo_8425_0();
/*  62 */     vo_8425_0.id = pet_id;
/*  63 */     GameObjectChar.getGameObjectChar().gameMap.send(new org.linlinjava.litemall.gameserver.data.write.M8425_0(), vo_8425_0);
/*     */     
/*     */ 
/*  66 */     GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
/*     */     
/*     */ 
/*  69 */     Vo_45177_0 vo_45177_0 = new Vo_45177_0();
/*  70 */     vo_45177_0.id = chara.id;
/*  71 */     vo_45177_0.moveSpeedPercent = chara.yidongsudu;
/*  72 */     GameObjectChar.getGameObjectChar().gameMap.send(new M45177_0(), vo_45177_0);
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/*  79 */     return 4382;
/*     */   }
/*     */   
/*     */   private static int typeMounts(int type, int polar, int sex) {
/*  83 */     if (type == 31025) {
/*  84 */       int[][] type_31025 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/*  85 */       return type_31025[sex][(polar - 1)]; }
/*  86 */     if (type == 31010) {
/*  87 */       int[][] type_31010 = { { 760011, 770012, 770013, 760014, 760015, 760010 }, { 770011, 760012, 760013, 770014, 770015, 770010 } };
/*  88 */       return type_31010[sex][(polar - 1)]; }
/*  89 */     if (type == 31011) {
/*  90 */       int[][] type_31011 = { { 760021, 770022, 770023, 760024, 760025, 760020 }, { 770021, 760022, 760023, 770024, 770025, 770020 } };
/*  91 */       return type_31011[sex][(polar - 1)]; }
/*  92 */     if (type == 31013) {
/*  93 */       int[][] type_31013 = { { 760021, 770022, 770023, 760024, 760025, 760020 }, { 770021, 760022, 760023, 770024, 770025, 770020 } };
/*  94 */       return type_31013[sex][(polar - 1)]; }
/*  95 */     if (type == 31029) {
/*  96 */       int[][] type_31029 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/*  97 */       return type_31029[sex][(polar - 1)]; }
/*  98 */     if (type == 31026) {
/*  99 */       int[][] type_31026 = { { 760011, 770012, 770013, 760014, 760015, 760010 }, { 770011, 760012, 760013, 770014, 770015, 770010 } };
/* 100 */       return type_31026[sex][(polar - 1)]; }
/* 101 */     if (type == 31001) {
/* 102 */       int[][] type_31001 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/* 103 */       return type_31001[sex][(polar - 1)]; }
/* 104 */     if (type == 31019) {
/* 105 */       int[][] type_31019 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/* 106 */       return type_31019[sex][(polar - 1)]; }
/* 107 */     if (type == 31003) {
/* 108 */       int[][] type_31003 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/* 109 */       return type_31003[sex][(polar - 1)]; }
/* 110 */     if (type == 31020) {
/* 111 */       int[][] type_31020 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/* 112 */       return type_31020[sex][(polar - 1)]; }
/* 113 */     if (type == 31021) {
/* 114 */       int[][] type_31021 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/* 115 */       return type_31021[sex][(polar - 1)]; }
/* 116 */     if (type == 31006) {
/* 117 */       int[][] type_31006 = { { 760011, 770012, 770013, 760014, 760015, 760010 }, { 770011, 760012, 760013, 770014, 770015, 770010 } };
/* 118 */       return type_31006[sex][(polar - 1)]; }
/* 119 */     if (type == 31023) {
/* 120 */       int[][] type_31023 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/* 121 */       return type_31023[sex][(polar - 1)];
/*     */     }
/*     */     
/* 124 */     return 0;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4382_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */