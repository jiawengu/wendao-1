/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49169_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M49169_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */

/**
 * CMD_REQUEST_RECHARGE_SCORE_GOODS -- 客户端请求积分商品列表
 */
/*    */ @Service
/*    */ public class CMD_REQUEST_RECHARGE_SCORE_GOODS
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 19 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 21 */     Vo_49169_0 vo_49169_0 = new Vo_49169_0();
/* 22 */     vo_49169_0.monthDays = 31;
/*    */     
/* 24 */     vo_49169_0.signDays = chara.signDays;
/*    */     
/* 26 */     vo_49169_0.isCanSgin = chara.isCanSgin;
/*    */     
/* 28 */     vo_49169_0.isCanReplenishSign = 0;
/* 29 */     vo_49169_0.name0 = "超级归元露";
/* 30 */     vo_49169_0.number0 = 1;
/* 31 */     vo_49169_0.name1 = "银元宝";
/* 32 */     vo_49169_0.number1 = 100;
/* 33 */     vo_49169_0.name2 = "超级神兽丹";
/* 34 */     vo_49169_0.number2 = 1;
/* 35 */     vo_49169_0.name3 = "超级晶石";
/* 36 */     vo_49169_0.number3 = 1;
/* 37 */     vo_49169_0.name4 = "宠物强化丹";
/* 38 */     vo_49169_0.number4 = 1;
/* 39 */     vo_49169_0.name5 = "宠风散";
/* 40 */     vo_49169_0.number5 = 1;
/* 41 */     vo_49169_0.name6 = "银元宝";
/* 42 */     vo_49169_0.number6 = 100;
/* 43 */     vo_49169_0.name7 = "超级神兽丹";
/* 44 */     vo_49169_0.number7 = 1;
/* 45 */     vo_49169_0.name8 = "超级晶石";
/* 46 */     vo_49169_0.number8 = 1;
/* 47 */     vo_49169_0.name9 = "点化丹";
/* 48 */     vo_49169_0.number9 = 1;
/* 49 */     vo_49169_0.name10 = "超级归元露";
/* 50 */     vo_49169_0.number10 = 1;
/* 51 */     vo_49169_0.name11 = "银元宝";
/* 52 */     vo_49169_0.number11 = 100;
/* 53 */     vo_49169_0.name12 = "超级神兽丹";
/* 54 */     vo_49169_0.number12 = 1;
/* 55 */     vo_49169_0.name13 = "超级晶石";
/* 56 */     vo_49169_0.number13 = 1;
/* 57 */     vo_49169_0.name14 = "装备共鸣石";
/* 58 */     vo_49169_0.number14 = 1;
/* 59 */     vo_49169_0.name15 = "宠风散";
/* 60 */     vo_49169_0.number15 = 1;
/* 61 */     vo_49169_0.name16 = "银元宝";
/* 62 */     vo_49169_0.number16 = 100;
/* 63 */     vo_49169_0.name17 = "超级神兽丹";
/* 64 */     vo_49169_0.number17 = 1;
/* 65 */     vo_49169_0.name18 = "超级晶石";
/* 66 */     vo_49169_0.number18 = 1;
/* 67 */     vo_49169_0.name19 = "羽化丹";
/* 68 */     vo_49169_0.number19 = 1;
/* 69 */     vo_49169_0.name20 = "超级归元露";
/* 70 */     vo_49169_0.number20 = 1;
/* 71 */     vo_49169_0.name21 = "银元宝";
/* 72 */     vo_49169_0.number21 = 100;
/* 73 */     vo_49169_0.name22 = "超级神兽丹";
/* 74 */     vo_49169_0.number22 = 1;
/* 75 */     vo_49169_0.name23 = "超级晶石";
/* 76 */     vo_49169_0.number23 = 1;
/* 77 */     vo_49169_0.name24 = "神木鼎";
/* 78 */     vo_49169_0.number24 = 1;
/* 79 */     vo_49169_0.name25 = "宠风散";
/* 80 */     vo_49169_0.number25 = 1;
/* 81 */     vo_49169_0.name26 = "银元宝";
/* 82 */     vo_49169_0.number26 = 100;
/* 83 */     vo_49169_0.name27 = "超级神兽丹";
/* 84 */     vo_49169_0.number27 = 1;
/* 85 */     vo_49169_0.name28 = "超级晶石";
/* 86 */     vo_49169_0.number28 = 1;
/* 87 */     vo_49169_0.name29 = "精怪诱饵";
/* 88 */     vo_49169_0.number29 = 1;
/* 89 */     vo_49169_0.name30 = "超级归元露";
/* 90 */     vo_49169_0.number30 = 1;
/* 91 */     GameObjectChar.send(new M49169_0(), vo_49169_0);
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 97 */     return 53448;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C53448_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */