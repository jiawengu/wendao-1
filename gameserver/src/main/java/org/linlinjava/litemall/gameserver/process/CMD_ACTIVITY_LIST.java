/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_32825_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M32825_0;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ 
/*    */ @Service
/*    */ public class CMD_ACTIVITY_LIST
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 18 */     Vo_32825_0 vo_32825_0 = new Vo_32825_0();
/* 19 */     vo_32825_0.name0 = "summer_day_2019_xzjs";
/* 20 */     vo_32825_0.startTime0 = 1562792400;
/* 21 */     vo_32825_0.endTime0 = 1563397199;
/* 22 */     vo_32825_0.name1 = "qixi_2019_qqzy";
/* 23 */     vo_32825_0.startTime1 = 1564952400;
/* 24 */     vo_32825_0.endTime1 = 1565211599;
/* 25 */     vo_32825_0.name2 = "huazhuang_wuhui";
/* 26 */     vo_32825_0.startTime2 = 1562679000;
/* 27 */     vo_32825_0.endTime2 = 1562680800;
/* 28 */     vo_32825_0.name3 = "suiji_richange";
/* 29 */     vo_32825_0.startTime3 = 1563570000;
/* 30 */     vo_32825_0.endTime3 = 1563742799;
/* 31 */     vo_32825_0.name4 = "tianjiangbaohe";
/* 32 */     vo_32825_0.startTime4 = 1562965200;
/* 33 */     vo_32825_0.endTime4 = 1563137999;
/* 34 */     vo_32825_0.name5 = "huanlebaoxiang";
/* 35 */     vo_32825_0.startTime5 = 1563397200;
/* 36 */     vo_32825_0.endTime5 = 1563742799;
/* 37 */     vo_32825_0.name6 = "new_year_attendance";
/* 38 */     vo_32825_0.startTime6 = 1577826000;
/* 39 */     vo_32825_0.endTime6 = 1578430799;
/* 40 */     vo_32825_0.name7 = "qixi_2019_lmqg";
/* 41 */     vo_32825_0.startTime7 = 1564952400;
/* 42 */     vo_32825_0.endTime7 = 1565211599;
/* 43 */     vo_32825_0.name8 = "summer_day_2019_sxdj";
/* 44 */     vo_32825_0.startTime8 = 1562187600;
/* 45 */     vo_32825_0.endTime8 = 1562792399;
/* 46 */     vo_32825_0.name9 = "limit_purchase";
/* 47 */     vo_32825_0.startTime9 = 1561928400;
/* 48 */     vo_32825_0.endTime9 = 1564952399;
/* 49 */     vo_32825_0.name10 = "summer_day_2019_smsz";
/* 50 */     vo_32825_0.startTime10 = 1562792400;
/* 51 */     vo_32825_0.endTime10 = 1563397199;
/* 52 */     vo_32825_0.name11 = "summer_day_2019_sswg";
/* 53 */     vo_32825_0.startTime11 = 1563397200;
/* 54 */     vo_32825_0.endTime11 = 1564001999;
/* 55 */     vo_32825_0.name12 = "yisheng_pengyou";
/* 56 */     vo_32825_0.startTime12 = 1556226000;
/* 57 */     vo_32825_0.endTime12 = 1585601999;
/* 58 */     vo_32825_0.name13 = "reentry_asktao_2016";
/* 59 */     vo_32825_0.startTime13 = 1483218000;
/* 60 */     vo_32825_0.endTime13 = 2113938000;
/* 61 */     vo_32825_0.name14 = "global_double";
/* 62 */     vo_32825_0.startTime14 = 1562668200;
/* 63 */     vo_32825_0.endTime14 = 1562675400;
/* 64 */     vo_32825_0.name15 = "summer_day_2019_bhky";
/* 65 */     vo_32825_0.startTime15 = 1563397200;
/* 66 */     vo_32825_0.endTime15 = 1564001999;
/* 67 */     vo_32825_0.name16 = "month_charge_gift";
/* 68 */     vo_32825_0.startTime16 = 1561928400;
/* 69 */     vo_32825_0.endTime16 = 1564606799;
/* 70 */     vo_32825_0.name17 = "newdisthelp";
/* 71 */     vo_32825_0.startTime17 = 1556312400;
/* 72 */     vo_32825_0.endTime17 = 1557435599;
/* 73 */     vo_32825_0.name18 = "good_voice";
/* 74 */     vo_32825_0.startTime18 = 1561582800;
/* 75 */     vo_32825_0.endTime18 = 1563364800;
/* 76 */     GameObjectChar.send(new M32825_0(), vo_32825_0);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 81 */     return 32824;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C32824_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */