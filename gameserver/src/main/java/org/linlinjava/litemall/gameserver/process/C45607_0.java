/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */
/*    */ import org.linlinjava.litemall.db.domain.PackModification;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41505_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45608_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M41505_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M61677_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C45607_0 implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 24 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 26 */     Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/* 27 */     vo_61677_0.store_type = "effect_store";
/* 28 */     vo_61677_0.npcID = 0;
/* 29 */     vo_61677_0.list = chara.texiao;
/* 30 */     vo_61677_0.count = chara.texiao.size();
/* 31 */     GameObjectChar.send(new M61677_0(), vo_61677_0);
/*    */     
/*    */ 
/* 34 */     for (int i = 0; i < chara.backpack.size(); i++) {
/* 35 */       if (((Goods)chara.backpack.get(i)).pos == 32) {
/* 36 */         PackModification packModification = GameData.that.basePackModificationService.findOneByStr(((Goods)chara.backpack.get(i)).goodsInfo.str);
/* 37 */         Vo_61677_0 vo_61677_12 = new Vo_61677_0();
/* 38 */         vo_61677_12.store_type = "effect_store";
/* 39 */         vo_61677_12.npcID = 0;
/* 40 */         vo_61677_12.count = 1;
/* 41 */         vo_61677_12.isGoon = 0;
/* 42 */         vo_61677_12.pos = packModification.getPosition().intValue();
/* 43 */         GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61677_01(), vo_61677_12);
/*    */       }
/*    */     }
/*    */     
/*    */ 
/*    */ 
/* 49 */     Vo_45608_0 vo_45608_0 = new Vo_45608_0();
/* 50 */     vo_45608_0.count = 13;
/* 51 */     vo_45608_0.name0 = "浪漫玫瑰";
/* 52 */     vo_45608_0.goods_price0 = 0;
/* 53 */     vo_45608_0.name1 = "星汉灿烂·永久";
/* 54 */     vo_45608_0.goods_price1 = 10888;
/* 55 */     vo_45608_0.name2 = "风花雪月·永久";
/* 56 */     vo_45608_0.goods_price2 = 10888;
/* 57 */     vo_45608_0.name3 = "轻羽飞扬·永久";
/* 58 */     vo_45608_0.goods_price3 = 8888;
/* 59 */     vo_45608_0.name4 = "繁花盛开·永久";
/* 60 */     vo_45608_0.goods_price4 = 6888;
/* 61 */     vo_45608_0.name5 = "踏雪无痕·永久";
/* 62 */     vo_45608_0.goods_price5 = 8888;
/* 63 */     vo_45608_0.name6 = "雨过天晴·永久";
/* 64 */     vo_45608_0.goods_price6 = 8888;
/* 65 */     vo_45608_0.name7 = "翩翩起舞";
/* 66 */     vo_45608_0.goods_price7 = 20888;
/* 67 */     vo_45608_0.name8 = "蝶影翩翩·永久";
/* 68 */     vo_45608_0.goods_price8 = 6888;
/* 69 */     vo_45608_0.name9 = "多彩泡泡";
/* 70 */     vo_45608_0.goods_price9 = 20888;
/* 71 */     vo_45608_0.name10 = "步步生莲·永久";
/* 72 */     vo_45608_0.goods_price10 = 6888;
/* 73 */     vo_45608_0.name11 = "星影特效";
/* 74 */     vo_45608_0.goods_price11 = 20888;
/* 75 */     vo_45608_0.name12 = "鸾凤宝玉";
/* 76 */     vo_45608_0.goods_price12 = 20888;
/* 77 */     vo_45608_0.count1 = 0;
/* 78 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M45608_0(), vo_45608_0);
/*    */     
/* 80 */     Vo_41505_0 vo_41505_0 = new Vo_41505_0();
/* 81 */     vo_41505_0.type = "fasion_effect_view";
/* 82 */     GameObjectChar.send(new M41505_0(), vo_41505_0);
/*    */     
/* 84 */     org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0 vo_65529_0 = GameUtil.MSG_APPEAR(chara);
/* 85 */     GameObjectChar.send(new MSG_APPEAR(), vo_65529_0);
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 91 */     return 45607;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C45607_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */