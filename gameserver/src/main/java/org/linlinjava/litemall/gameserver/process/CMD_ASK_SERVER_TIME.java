/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41009_0;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ //CMD_ASK_SERVER_TIME  -- 请求更新服务器时间
/*    */ @Service
/*    */ public class CMD_ASK_SERVER_TIME implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 15 */     Vo_41009_0 vo_41009_0 = new Vo_41009_0();
/* 16 */     vo_41009_0.server_time = ((int)(System.currentTimeMillis() / 1000L));
/* 17 */     vo_41009_0.time_zone = 8;
/* 18 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M41009_0(), vo_41009_0);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 23 */     return 41008;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C41008_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */