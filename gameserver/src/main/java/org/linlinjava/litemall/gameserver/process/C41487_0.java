/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */
/*     */ import org.linlinjava.litemall.db.domain.PackModification;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41488_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M41488_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M61677_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M61677_SHIZHUANG;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_APPEARANCE;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.springframework.stereotype.Service;
/*     */ 
/*     */ @Service
/*     */ public class C41487_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  23 */     String para = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);
/*     */     
/*  25 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*  27 */     Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/*  28 */     vo_61677_0.store_type = "fasion_store";
/*  29 */     vo_61677_0.npcID = 0;
/*  30 */     vo_61677_0.list = chara.shizhuang;
/*  31 */     vo_61677_0.count = chara.shizhuang.size();
/*  32 */     GameObjectChar.send(new M61677_0(), vo_61677_0);
/*     */     
/*  34 */     vo_61677_0 = new Vo_61677_0();
/*  35 */     vo_61677_0.store_type = "custom_store";
/*  36 */     vo_61677_0.npcID = 0;
/*  37 */     GameObjectChar.send(new M61677_SHIZHUANG(), vo_61677_0);
/*     */     
/*  39 */     vo_61677_0 = new Vo_61677_0();
/*  40 */     vo_61677_0.store_type = "effect_store";
/*  41 */     vo_61677_0.npcID = 0;
/*  42 */     vo_61677_0.list = chara.texiao;
/*  43 */     vo_61677_0.count = chara.texiao.size();
/*  44 */     GameObjectChar.send(new M61677_0(), vo_61677_0);
/*     */     
/*     */ 
/*  47 */     for (int i = 0; i < chara.backpack.size(); i++) {
/*  48 */       if (((Goods)chara.backpack.get(i)).pos == 31) {
/*  49 */         PackModification packModification = GameData.that.basePackModificationService.findOneByStr(((Goods)chara.backpack.get(i)).goodsInfo.str);
/*  50 */         Vo_61677_0 vo_61677_12 = new Vo_61677_0();
/*  51 */         vo_61677_12.store_type = "fasion_store";
/*  52 */         vo_61677_12.npcID = 0;
/*  53 */         vo_61677_12.count = 1;
/*  54 */         vo_61677_12.isGoon = 0;
/*  55 */         vo_61677_12.pos = packModification.getPosition().intValue();
/*  56 */         GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61677_01(), vo_61677_12);
/*     */       }
/*     */     }
/*     */     
/*     */ 
/*     */ 
/*  62 */     org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
/*  63 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*     */     
/*     */ 
/*  66 */     Vo_41488_0 vo_41488_0 = new Vo_41488_0();
/*  67 */     vo_41488_0.flag = 1;
/*  68 */     vo_41488_0.label = 0;
/*  69 */     vo_41488_0.para = para;
/*  70 */     vo_41488_0.count2 = 20;
/*  71 */     vo_41488_0.name0 = "点红烛·永久";
/*  72 */     vo_41488_0.goods_price0 = 26888;
/*  73 */     vo_41488_0.name1 = "日耀辰辉·永久";
/*  74 */     vo_41488_0.goods_price1 = 26888;
/*  75 */     vo_41488_0.name2 = "星垂月涌·永久";
/*  76 */     vo_41488_0.goods_price2 = 26888;
/*  77 */     vo_41488_0.name3 = "剑魄琴心·永久";
/*  78 */     vo_41488_0.goods_price3 = 26888;
/*  79 */     vo_41488_0.name4 = "引天长歌·永久";
/*  80 */     vo_41488_0.goods_price4 = 26888;
/*  81 */     vo_41488_0.name5 = "如意年·永久";
/*  82 */     vo_41488_0.goods_price5 = 26888;
/*  83 */     vo_41488_0.name6 = "星火昭·永久";
/*  84 */     vo_41488_0.goods_price6 = 26888;
/*  85 */     vo_41488_0.name7 = "吉祥天·永久";
/*  86 */     vo_41488_0.goods_price7 = 26888;
/*  87 */     vo_41488_0.name8 = "汉宫秋·永久";
/*  88 */     vo_41488_0.goods_price8 = 36888;
/*  89 */     vo_41488_0.name9 = "凤鸣空·永久";
/*  90 */     vo_41488_0.goods_price9 = 36888;
/*  91 */     vo_41488_0.name10 = "水光衫·永久";
/*  92 */     vo_41488_0.goods_price10 = 36888;
/*  93 */     vo_41488_0.name11 = "月孤影·永久";
/*  94 */     vo_41488_0.goods_price11 = 36888;
/*  95 */     vo_41488_0.name12 = "狐灵娇·永久";
/*  96 */     vo_41488_0.goods_price12 = 36888;
/*  97 */     vo_41488_0.name13 = "晓色红妆·永久";
/*  98 */     vo_41488_0.goods_price13 = 36888;
/*  99 */     vo_41488_0.name14 = "千秋梦·永久";
/* 100 */     vo_41488_0.goods_price14 = 36888;
/* 101 */     vo_41488_0.name15 = "龙吟水·永久";
/* 102 */     vo_41488_0.goods_price15 = 36888;
/* 103 */     vo_41488_0.name16 = "峥岚衣·永久";
/* 104 */     vo_41488_0.goods_price16 = 36888;
/* 105 */     vo_41488_0.name17 = "狐灵逸·永久";
/* 106 */     vo_41488_0.goods_price17 = 36888;
/* 107 */     vo_41488_0.name18 = "云暮风华·永久";
/* 108 */     vo_41488_0.goods_price18 = 36888;
/* 109 */     vo_41488_0.name19 = "星寒魄·永久";
/* 110 */     vo_41488_0.goods_price19 = 36888;
/* 111 */     GameObjectChar.send(new M41488_0(), vo_41488_0);
/*     */   }
/*     */   
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 117 */     return 41487;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C41487_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */