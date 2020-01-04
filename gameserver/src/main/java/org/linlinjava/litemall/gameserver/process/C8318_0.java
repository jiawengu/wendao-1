/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C8318_0 implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 20 */     int id = GameReadTool.readInt(buff);
/*    */     
/* 22 */     int money = GameReadTool.readInt(buff);
/*    */     
/* 24 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 26 */     chara.balance -= money;
/* 27 */     if (chara.gender + money > 2000000000) {
/* 28 */       chara.gender = 2000000000;
/*    */     } else {
/* 30 */       chara.gender += money;
/*    */     }
/* 32 */     ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 33 */     GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/* 34 */     Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 35 */     vo_20481_0.msg = ("#成功存入#cBA55DC" + money + "#n文钱#n。");
/* 36 */     vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
/* 37 */     GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 42 */     return 8318;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C8318_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */