/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_12269_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41045_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */

/**
 *  -- 变异宠物商店
 */
/*     */ @org.springframework.stereotype.Service
/*     */ public class CMD_BUY_FROM_ELITE_PET_SHOP implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  26 */     int type = GameReadTool.readByte(buff);
/*     */     
/*  28 */     String name = GameReadTool.readString(buff);
/*  29 */     GameObjectChar session = GameObjectChar.getGameObjectChar();
/*  30 */     Chara chara = session.chara;
/*     */     
/*     */ 
/*  33 */     if (type == 1) {
/*  34 */       type = 3;
/*  35 */       int number = 0;
/*  36 */       for (int i = 0; i < chara.backpack.size(); i++) {
/*  37 */         if (((Goods)chara.backpack.get(i)).goodsInfo.str.equals("召唤令·十二生肖")) {
/*  38 */           number += ((Goods)chara.backpack.get(i)).goodsInfo.owner_id;
/*     */         }
/*     */       }
/*  41 */       if (number < 100) {
/*  42 */         Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/*  43 */         vo_20481_0.msg = "召唤令数量不足，无法兑换";
/*  44 */         vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
/*  45 */         GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*  46 */         return;
/*     */       }
/*  48 */       GameUtil.removemunber(chara, "召唤令·十二生肖", 100);
/*     */     } else {
/*  50 */       int number = 0;
/*  51 */       for (int i = 0; i < chara.backpack.size(); i++) {
/*  52 */         if (((Goods)chara.backpack.get(i)).goodsInfo.str.equals("召唤令·上古神兽")) {
/*  53 */           number += ((Goods)chara.backpack.get(i)).goodsInfo.owner_id;
/*     */         }
/*     */       }
/*  56 */       if (number < 100) {
/*  57 */         Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/*  58 */         vo_20481_0.msg = "召唤令数量不足，无法兑换";
/*  59 */         vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
/*  60 */         GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*  61 */         return;
/*     */       }
/*  63 */       type = 4;
/*  64 */       GameUtil.removemunber(chara, "召唤令·上古神兽", 100);
/*     */     }
/*  66 */     org.linlinjava.litemall.db.domain.Pet pet = GameData.that.basePetService.findOneByName(name);
/*  67 */     Petbeibao petbeibao = new Petbeibao();
/*  68 */     petbeibao.PetCreate(pet, chara, 0, type);
/*  69 */     List<Petbeibao> list = new java.util.ArrayList();
/*  70 */     chara.pets.add(petbeibao);
/*  71 */     list.add(petbeibao);
/*  72 */     GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/*     */     
/*  74 */     Vo_12269_0 vo_12269_0 = new Vo_12269_0();
/*     */     
/*  76 */     vo_12269_0.id = petbeibao.id;
/*  77 */     vo_12269_0.owner_id = chara.id;
/*  78 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M12269_0(), vo_12269_0);
/*  79 */     Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/*  80 */     vo_40964_0.type = 2;
/*  81 */     vo_40964_0.name = name;
/*  82 */     vo_40964_0.param = String.valueOf(((PetShuXing)petbeibao.petShuXing.get(0)).type);
/*  83 */     vo_40964_0.rightNow = 0;
/*  84 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40964_0(), vo_40964_0);
/*  85 */     Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/*  86 */     vo_20480_0.msg = ("恭喜你召唤了一只" + name);
/*  87 */     vo_20480_0.time = ((int)(System.currentTimeMillis() / 1000L));
/*  88 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M20480_0(), vo_20480_0);
/*  89 */     Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/*  90 */     vo_20481_0.msg = ("恭喜你召唤了一只" + name);
/*  91 */     vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
/*  92 */     GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*  93 */     Vo_41045_0 vo_41045_0 = new Vo_41045_0();
/*  94 */     vo_41045_0.flag = 3;
/*  95 */     vo_41045_0.id = petbeibao.id;
/*  96 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M41045_0(), vo_41045_0);
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 103 */     return 53252;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C53252_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */