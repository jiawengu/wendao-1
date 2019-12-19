/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.db.domain.PackModification;
/*    */ import org.linlinjava.litemall.db.service.base.BasePackModificationService;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41505_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53713_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M41505_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M61677_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M61677_01;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*    */ import org.linlinjava.litemall.gameserver.domain.GoodsInfo;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C53714_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 26 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 28 */     Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/* 29 */     vo_61677_0.store_type = "follow_pet_store";
/* 30 */     vo_61677_0.npcID = 0;
/* 31 */     vo_61677_0.list = chara.genchong;
/* 32 */     vo_61677_0.count = chara.genchong.size();
/* 33 */     GameObjectChar.send(new M61677_0(), vo_61677_0);
/*    */     
/*    */ 
/* 36 */     for (int i = 0; i < chara.backpack.size(); i++) {
/* 37 */       if (((Goods)chara.backpack.get(i)).pos == 37) {
/* 38 */         PackModification packModification = GameData.that.basePackModificationService.findOneByStr(((Goods)chara.backpack.get(i)).goodsInfo.str);
/* 39 */         Vo_61677_0 vo_61677_12 = new Vo_61677_0();
/* 40 */         vo_61677_12.store_type = "follow_pet_store";
/* 41 */         vo_61677_12.npcID = 0;
/* 42 */         vo_61677_12.count = 1;
/* 43 */         vo_61677_12.isGoon = 0;
/* 44 */         vo_61677_12.pos = packModification.getPosition().intValue();
/* 45 */         GameObjectChar.send(new M61677_01(), vo_61677_12);
/*    */       }
/*    */     }
/*    */     
/*    */ 
/*    */ 
/* 51 */     Vo_53713_0 vo_53713_0 = new Vo_53713_0();
/* 52 */     vo_53713_0.count = 11;
/* 53 */     vo_53713_0.name0 = "小绯·永久";
/* 54 */     vo_53713_0.goods_price0 = 8888;
/* 55 */     vo_53713_0.name1 = "水精·永久";
/* 56 */     vo_53713_0.goods_price1 = 8888;
/* 57 */     vo_53713_0.name2 = "太小极·永久";
/* 58 */     vo_53713_0.goods_price2 = 28888;
/* 59 */     vo_53713_0.name3 = "火魂·永久";
/* 60 */     vo_53713_0.goods_price3 = 8888;
/* 61 */     vo_53713_0.name4 = "木心·永久";
/* 62 */     vo_53713_0.goods_price4 = 8888;
/* 63 */     vo_53713_0.name5 = "小海龟·永久";
/* 64 */     vo_53713_0.goods_price5 = 8888;
/* 65 */     vo_53713_0.name6 = "泥泥·永久";
/* 66 */     vo_53713_0.goods_price6 = 28888;
/* 67 */     vo_53713_0.name7 = "蓝极公主·永久";
/* 68 */     vo_53713_0.goods_price7 = 18888;
/* 69 */     vo_53713_0.name8 = "土魄·永久";
/* 70 */     vo_53713_0.goods_price8 = 8888;
/* 71 */     vo_53713_0.name9 = "金灵·永久";
/* 72 */     vo_53713_0.goods_price9 = 8888;
/* 73 */     vo_53713_0.name10 = "灯笼宝宝·永久";
/* 74 */     vo_53713_0.goods_price10 = 18888;
/* 75 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M53713_0(), vo_53713_0);
/*    */     
/*    */ 
/*    */ 
/* 79 */     Vo_41505_0 vo_41505_0 = new Vo_41505_0();
/* 80 */     vo_41505_0.type = "view_follow_pet";
/* 81 */     GameObjectChar.send(new M41505_0(), vo_41505_0);
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 88 */     return 53714;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C53714_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */