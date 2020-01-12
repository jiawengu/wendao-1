/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41051_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41106_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M41051_0;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */

/**
 * CMD_GET_ACTIVE_BONUS_INFO    -- 获取活动会员信息
 */
/*    */ @Service
/*    */ public class CMD_GET_ACTIVE_BONUS_INFO
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 19 */     Vo_41051_0 vo_41051_0 = new Vo_41051_0();
/* 20 */     vo_41051_0.count = 1;
/* 21 */     vo_41051_0.name0 = "month_charge_gift";
/* 22 */     vo_41051_0.amount0 = 0;
/* 23 */     vo_41051_0.startTime0 = 1577825999;
/* 24 */     vo_41051_0.endTime0 = 1577825999;
/*    */     
/* 26 */     GameObjectChar.send(new M41051_0(), vo_41051_0);
/*    */     
/*    */ 
/*    */ 
/* 30 */     Vo_41106_0 vo_41106_0 = new Vo_41106_0();
/* 31 */     vo_41106_0.month = 7;
/* 32 */     vo_41106_0.startTime = 1561928400;
/* 33 */     vo_41106_0.endTime = 1564606799;
/* 34 */     vo_41106_0.count = 4;
/* 35 */     vo_41106_0.item_name0 = "刷道卷轴";
/* 36 */     vo_41106_0.item_amount0 = 5;
/* 37 */     vo_41106_0.item_gift0 = 1;
/* 38 */     vo_41106_0.item_icon0 = "";
/* 39 */     vo_41106_0.item_name1 = "随机变身卡";
/* 40 */     vo_41106_0.item_amount1 = 4;
/* 41 */     vo_41106_0.item_gift1 = 0;
/* 42 */     vo_41106_0.item_icon1 = "BigRewardIcon0028.png";
/* 43 */     vo_41106_0.item_name2 = "急急如律令";
/* 44 */     vo_41106_0.item_amount2 = 1;
/* 45 */     vo_41106_0.item_gift2 = 1;
/* 46 */     vo_41106_0.item_icon2 = "";
/* 47 */     vo_41106_0.item_name3 = "风灵丸";
/* 48 */     vo_41106_0.item_amount3 = 1;
/* 49 */     vo_41106_0.item_gift3 = 1;
/* 50 */     vo_41106_0.item_icon3 = "";
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 55 */     return 53496;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C53496_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */