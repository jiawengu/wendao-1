/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.game.BasicAttributesUtils;
/*     */ import org.linlinjava.litemall.gameserver.data.game.PetAttributesUtils;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_14337_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M14337_0;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.springframework.stereotype.Service;
/*     */ 
/*     */ @Service
/*     */ public class C14338_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  22 */     int id = GameReadTool.readInt(buff);
/*     */     
/*  24 */     int type = GameReadTool.readByte(buff);
/*     */     
/*  26 */     int para1 = GameReadTool.readShort(buff);
/*     */     
/*  28 */     int para2 = GameReadTool.readShort(buff);
/*     */     
/*  30 */     int para3 = GameReadTool.readShort(buff);
/*     */     
/*  32 */     int para4 = GameReadTool.readShort(buff);
/*     */     
/*  34 */     int para5 = GameReadTool.readShort(buff);
/*     */     
/*  36 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*  38 */     if (para1 > 3000) {
/*  39 */       para1 -= 65536;
/*     */     }
/*  41 */     if (para2 > 3000) {
/*  42 */       para2 -= 65536;
/*     */     }
/*  44 */     if (para3 > 3000) {
/*  45 */       para3 -= 65536;
/*     */     }
/*  47 */     if (para4 > 3000) {
/*  48 */       para4 -= 65536;
/*     */     }
/*  50 */     if (para5 > 3000) {
/*  51 */       para5 -= 65536;
/*     */     }
/*     */     
/*     */ 
/*  55 */     if (0 == id) {
/*  56 */       Vo_14337_0 vo_14337_0 = new Vo_14337_0();
/*  57 */       if (type == 1)
/*     */       {
/*  59 */         int[] ints = BasicAttributesUtils.changeCalculationAttributes(chara.level, para1, para2, para3, para4);
/*  60 */         vo_14337_0.id = 0;
/*  61 */         vo_14337_0.type = 1;
/*  62 */         vo_14337_0.life_plus = ints[0];
/*  63 */         vo_14337_0.max_life_plus = ints[0];
/*  64 */         vo_14337_0.mana_plus = ints[1];
/*  65 */         vo_14337_0.max_mana_plus = ints[1];
/*  66 */         vo_14337_0.phy_power_plus = ints[2];
/*  67 */         vo_14337_0.mag_power_plus = ints[3];
/*  68 */         vo_14337_0.speed_plus = ints[4];
/*  69 */         vo_14337_0.def_plus = ints[5];
/*  70 */         vo_14337_0.free = 0;
/*  71 */       } else if (type == 2) {
/*  72 */         int[] ints = BasicAttributesUtils.changeRelAttributes(chara.level, chara.life, chara.mag_power, chara.phy_power, chara.speed, para1, para2, para3, para4, para5);
/*  73 */         vo_14337_0.id = 0;
/*  74 */         vo_14337_0.type = 1;
/*  75 */         vo_14337_0.life_plus = ints[0];
/*  76 */         vo_14337_0.max_life_plus = ints[0];
/*  77 */         vo_14337_0.mana_plus = ints[1];
/*  78 */         vo_14337_0.max_mana_plus = ints[1];
/*  79 */         vo_14337_0.phy_power_plus = ints[2];
/*  80 */         vo_14337_0.mag_power_plus = ints[3];
/*  81 */         vo_14337_0.speed_plus = ints[4];
/*  82 */         vo_14337_0.def_plus = ints[5];
/*  83 */         vo_14337_0.free = 0;
/*     */       }
/*  85 */       GameObjectChar.send(new M14337_0(), vo_14337_0);
/*     */     } else {
/*  87 */       for (int i = 0; i < chara.pets.size(); i++) {
/*  88 */         Petbeibao petbeibao = (Petbeibao)chara.pets.get(i);
/*  89 */         if (petbeibao.id == id) {
/*  90 */           PetShuXing petShuXing = (PetShuXing)petbeibao.petShuXing.get(0);
/*     */           
/*  92 */           boolean fagong = petShuXing.pet_mag_shape > petShuXing.pet_phy_shape;
/*     */           
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/* 102 */           int[] ints = PetAttributesUtils.petAttributes(fagong, petShuXing.level, petShuXing.con + para1, petShuXing.wiz + para2, petShuXing.str + para3, petShuXing.dex + para4, petShuXing.pet_life_shape, petShuXing.pet_mana_shape, petShuXing.pet_speed_shape, petShuXing.pet_phy_shape, petShuXing.pet_mag_shape);
/* 103 */           int[] ints1 = PetAttributesUtils.petAttributes(fagong, petShuXing.level, petShuXing.con, petShuXing.wiz, petShuXing.str, petShuXing.dex, petShuXing.pet_life_shape, petShuXing.pet_mana_shape, petShuXing.pet_speed_shape, petShuXing.pet_phy_shape, petShuXing.pet_mag_shape);
/* 104 */           Vo_14337_0 vo_14337_0 = new Vo_14337_0();
/* 105 */           vo_14337_0.id = id;
/* 106 */           vo_14337_0.type = 1;
/* 107 */           vo_14337_0.life_plus = (ints[0] - ints1[0]);
/* 108 */           vo_14337_0.max_life_plus = (ints[0] - ints1[0]);
/* 109 */           vo_14337_0.mana_plus = (ints[1] - ints1[1]);
/* 110 */           vo_14337_0.max_mana_plus = (ints[1] - ints1[1]);
/* 111 */           vo_14337_0.phy_power_plus = (ints[2] - ints1[2]);
/* 112 */           vo_14337_0.mag_power_plus = (ints[3] - ints1[3]);
/* 113 */           vo_14337_0.speed_plus = (ints[4] - ints1[4]);
/* 114 */           vo_14337_0.def_plus = (ints[5] - ints1[5]);
/* 115 */           vo_14337_0.free = 0;
/* 116 */           GameObjectChar.send(new M14337_0(), vo_14337_0);
/*     */         }
/*     */       }
/*     */     }
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 126 */     return 14338;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C14338_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */