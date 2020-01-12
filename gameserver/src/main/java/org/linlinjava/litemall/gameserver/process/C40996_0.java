/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40995_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M20480_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M40964_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M40995_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C40996_0 implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 23 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/*    */ 
/* 26 */     Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 27 */     vo_20480_0.msg = ("你获得了" + chara.wuxingBalance + "文钱#n。");
/* 28 */     vo_20480_0.time = 1562593376;
/* 29 */     GameObjectChar.send(new M20480_0(), vo_20480_0);
/*    */     
/* 31 */     Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/* 32 */     vo_40964_0.type = 3;
/* 33 */     vo_40964_0.name = "金钱";
/* 34 */     vo_40964_0.param = String.valueOf(chara.wuxingBalance);
/* 35 */     vo_40964_0.rightNow = 0;
/* 36 */     GameObjectChar.send(new M40964_0(), vo_40964_0);
/* 37 */     chara.balance += chara.wuxingBalance;
/* 38 */     ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 39 */     GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/* 40 */     chara.wuxingBalance = 0;
/*    */     
/* 42 */     Vo_40995_0 vo_40995_1 = new Vo_40995_0();
/* 43 */     vo_40995_1.flag = 0;
/* 44 */     vo_40995_1.money = 0;
/* 45 */     vo_40995_1.surlus = String.valueOf(chara.wuxingBalance);
/* 46 */     vo_40995_1.overflow = "0";
/* 47 */     vo_40995_1.amount = 0;
/* 48 */     vo_40995_1.choice = 0;
/* 49 */     vo_40995_1.prize = 0;
/* 50 */     vo_40995_1.leftCount = 77;
/* 51 */     GameObjectChar.send(new M40995_0(), vo_40995_1);
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 58 */     return 40996;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C40996_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */