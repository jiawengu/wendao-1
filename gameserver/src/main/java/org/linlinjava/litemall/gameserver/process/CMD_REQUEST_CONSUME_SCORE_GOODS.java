/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41106_0;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */

/**
 * CMD_REQUEST_CONSUME_SCORE_GOODS  -- 请求消费积分商品信息
 */
/*    */ @Service
/*    */ public class CMD_REQUEST_CONSUME_SCORE_GOODS
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 16 */     Vo_41106_0 vo_41106_0 = new Vo_41106_0();
/* 17 */     vo_41106_0.month = 7;
/* 18 */     vo_41106_0.startTime = 1561928400;
/* 19 */     vo_41106_0.endTime = 1564606799;
/* 20 */     vo_41106_0.count = 4;
/* 21 */     vo_41106_0.item_name0 = "刷道卷轴";
/* 22 */     vo_41106_0.item_amount0 = 5;
/* 23 */     vo_41106_0.item_gift0 = 1;
/* 24 */     vo_41106_0.item_icon0 = "";
/* 25 */     vo_41106_0.item_name1 = "随机变身卡";
/* 26 */     vo_41106_0.item_amount1 = 4;
/* 27 */     vo_41106_0.item_gift1 = 0;
/* 28 */     vo_41106_0.item_icon1 = "BigRewardIcon0028.png";
/* 29 */     vo_41106_0.item_name2 = "急急如律令";
/* 30 */     vo_41106_0.item_amount2 = 1;
/* 31 */     vo_41106_0.item_gift2 = 1;
/* 32 */     vo_41106_0.item_icon2 = "";
/* 33 */     vo_41106_0.item_name3 = "风灵丸";
/* 34 */     vo_41106_0.item_amount3 = 1;
/* 35 */     vo_41106_0.item_gift3 = 1;
/* 36 */     vo_41106_0.item_icon3 = "";
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 42 */     return 41111;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C41111_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */