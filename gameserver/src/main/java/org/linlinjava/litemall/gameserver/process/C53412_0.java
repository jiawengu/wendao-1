/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.LinkedList;
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53411_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M53411_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_APPEARANCE;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.springframework.stereotype.Service;
/*     */ 
/*     */ @Service
/*     */ public class C53412_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  24 */     int petId = GameReadTool.readInt(buff);
/*     */     
/*  26 */     int isHide = GameReadTool.readByte(buff);
/*     */     
/*  28 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*     */ 
/*  31 */     List list = new LinkedList();
/*  32 */     list.add(Integer.valueOf(petId));
/*  33 */     list.add(Integer.valueOf(isHide));
/*  34 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M65527_4(), list);
/*     */     
/*  36 */     if (isHide == 1) {
/*  37 */       chara.zuowaiguan = 0;
/*  38 */       chara.zuoqiwaiguan = 0;
/*     */     }
/*  40 */     if (isHide == 0) {
/*  41 */       for (int i = 0; i < chara.pets.size(); i++) {
/*  42 */         if (petId == ((Petbeibao)chara.pets.get(i)).id) {
/*  43 */           chara.zuoqiwaiguan = (((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).type + 1000);
/*  44 */           chara.zuowaiguan = typeMounts(chara.zuoqiwaiguan, chara.menpai, chara.sex - 1);
/*     */         }
/*     */       }
/*     */     }
/*  48 */     Vo_53411_0 vo_53411_0 = new Vo_53411_0();
/*  49 */     vo_53411_0.petId = petId;
/*  50 */     vo_53411_0.isHide = isHide;
/*  51 */     GameObjectChar.send(new M53411_0(), vo_53411_0);
/*     */     
/*     */ 
/*  54 */     Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
/*  55 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*     */   }
/*     */   
/*     */ 
/*     */   public int cmd()
/*     */   {
/*  61 */     return 53412;
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */   private static int typeMounts(int type, int polar, int sex)
/*     */   {
/*  73 */     if (type == 31025) {
/*  74 */       int[][] type_31025 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/*  75 */       return type_31025[sex][(polar - 1)]; }
/*  76 */     if (type == 31010) {
/*  77 */       int[][] type_31010 = { { 760011, 770012, 770013, 760014, 760015, 760010 }, { 770011, 760012, 760013, 770014, 770015, 770010 } };
/*  78 */       return type_31010[sex][(polar - 1)]; }
/*  79 */     if (type == 31011) {
/*  80 */       int[][] type_31011 = { { 760021, 770022, 770023, 760024, 760025, 760020 }, { 770021, 760022, 760023, 770024, 770025, 770020 } };
/*  81 */       return type_31011[sex][(polar - 1)]; }
/*  82 */     if (type == 31013) {
/*  83 */       int[][] type_31013 = { { 760021, 770022, 770023, 760024, 760025, 760020 }, { 770021, 760022, 760023, 770024, 770025, 770020 } };
/*  84 */       return type_31013[sex][(polar - 1)]; }
/*  85 */     if (type == 31029) {
/*  86 */       int[][] type_31029 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/*  87 */       return type_31029[sex][(polar - 1)]; }
/*  88 */     if (type == 31026) {
/*  89 */       int[][] type_31026 = { { 760011, 770012, 770013, 760014, 760015, 760010 }, { 770011, 760012, 760013, 770014, 770015, 770010 } };
/*  90 */       return type_31026[sex][(polar - 1)]; }
/*  91 */     if (type == 31001) {
/*  92 */       int[][] type_31001 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/*  93 */       return type_31001[sex][(polar - 1)]; }
/*  94 */     if (type == 31019) {
/*  95 */       int[][] type_31019 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/*  96 */       return type_31019[sex][(polar - 1)]; }
/*  97 */     if (type == 31003) {
/*  98 */       int[][] type_31003 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/*  99 */       return type_31003[sex][(polar - 1)]; }
/* 100 */     if (type == 31020) {
/* 101 */       int[][] type_31020 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/* 102 */       return type_31020[sex][(polar - 1)]; }
/* 103 */     if (type == 31021) {
/* 104 */       int[][] type_31021 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/* 105 */       return type_31021[sex][(polar - 1)]; }
/* 106 */     if (type == 31006) {
/* 107 */       int[][] type_31006 = { { 760011, 770012, 770013, 760014, 760015, 760010 }, { 770011, 760012, 760013, 770014, 770015, 770010 } };
/* 108 */       return type_31006[sex][(polar - 1)]; }
/* 109 */     if (type == 31023) {
/* 110 */       int[][] type_31023 = { { 760031, 770032, 770033, 760034, 760035, 760030 }, { 770021, 760022, 760023, 770024, 770025, 770030 } };
/* 111 */       return type_31023[sex][(polar - 1)];
/*     */     }
/*     */     
/* 114 */     return 0;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C53412_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */