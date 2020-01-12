/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.db.domain.SaleGood;
/*    */
/*    */ import org.linlinjava.litemall.db.util.JSONUtils;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45104_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45105_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M45104_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_MARKET_PET_CARD;
/*    */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*    */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C4301_0
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 26 */     String item_cookie = GameReadTool.readString(buff);
/*    */     
/* 28 */     String[] split = item_cookie.split("\\;");
/* 29 */     String goodsid = split[0];
/* 30 */     String pos = split[1];
/*    */     
/* 32 */     SaleGood saleGood = GameData.that.saleGoodService.findOneByGoodsId(goodsid);
/* 33 */     if (saleGood == null) {
/* 34 */       return;
/*    */     }
/* 36 */     String goods = saleGood.getGoods();
/*    */     
/* 38 */     if (saleGood.getIspet().intValue() == 1) {
/* 39 */       Goods goods1 = (Goods)JSONUtils.parseObject(goods, Goods.class);
/* 40 */       Vo_45104_0 vo_45104_0 = new Vo_45104_0();
/* 41 */       vo_45104_0.id = goodsid;
/* 42 */       vo_45104_0.status = 2;
/* 43 */       vo_45104_0.endTime = saleGood.getEndTime().intValue();
/* 44 */       vo_45104_0.goods = goods1;
/* 45 */       GameObjectChar.send(new M45104_0(), vo_45104_0);
/*    */     }
/*    */     else {
/* 48 */       Petbeibao petbeibao = (Petbeibao)JSONUtils.parseObject(goods, Petbeibao.class);
/* 49 */       Vo_45105_0 vo_45105_0 = new Vo_45105_0();
/* 50 */       vo_45105_0.goodId = goodsid;
/* 51 */       vo_45105_0.status = 2;
/* 52 */       vo_45105_0.endTime = saleGood.getEndTime().intValue();
/* 53 */       vo_45105_0.petbeibao = petbeibao;
/* 54 */       GameObjectChar.send(new MSG_MARKET_PET_CARD(), vo_45105_0);
/* 55 */       return;
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 64 */     return 4301;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4301_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */