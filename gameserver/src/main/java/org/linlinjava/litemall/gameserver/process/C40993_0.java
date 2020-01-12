/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.Random;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40995_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M20480_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M40995_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C40993_0
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 24 */     int amount = GameReadTool.readInt(buff);
/*    */     
/* 26 */     int choice = GameReadTool.readByte(buff);
/* 27 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 29 */     chara.balance -= amount;
/* 30 */     ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 31 */     GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*    */     
/* 33 */     int prize = prize();
/* 34 */     int money = 0;
/* 35 */     if (choice == prize) {
/* 36 */       money = amount * 60;
/* 37 */     } else if (choice / 10 == prize / 10) {
/* 38 */       money = amount * 12;
/* 39 */     } else if (choice % 10 == prize % 10) {
/* 40 */       money = amount * 5;
/*    */     }
/* 42 */     chara.wuxingBalance += money;
/* 43 */     if (chara.wuxingBalance < 0) {
/* 44 */       chara.wuxingBalance = 200000000;
/*    */     }
/* 46 */     Vo_40995_0 vo_40995_1 = new Vo_40995_0();
/* 47 */     vo_40995_1.flag = 1;
/* 48 */     vo_40995_1.money = money;
/* 49 */     vo_40995_1.surlus = String.valueOf(chara.wuxingBalance);
/* 50 */     vo_40995_1.overflow = "0";
/* 51 */     vo_40995_1.amount = amount;
/* 52 */     vo_40995_1.choice = choice;
/* 53 */     vo_40995_1.prize = prize;
/* 54 */     vo_40995_1.leftCount = 77;
/* 55 */     GameObjectChar.send(new M40995_0(), vo_40995_1);
/*    */     
/* 57 */     Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 58 */     vo_20480_0.msg = ("你花费了" + amount + "文钱#n进行五行竞猜。");
/* 59 */     vo_20480_0.time = ((int)(System.currentTimeMillis() / 1000L));
/* 60 */     GameObjectChar.send(new M20480_0(), vo_20480_0);
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 66 */     return 40993;
/*    */   }
/*    */   
/*    */   public static int prize() {
/* 70 */     Random random = new Random();
/* 71 */     int i = random.nextInt(5) + 1;
/* 72 */     int i1 = random.nextInt(12) + 1;
/* 73 */     return i1 * 10 + i;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C40993_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */