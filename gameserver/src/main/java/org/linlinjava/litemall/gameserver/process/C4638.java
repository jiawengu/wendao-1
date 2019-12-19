/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8131_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M8131_0;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C4638 implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 16 */     ByteBuf type = GameReadTool.readLenBuffer2(buff);
/*    */     
/* 18 */     int cookie = GameReadTool.readInt(buff);
/*    */     
/* 20 */     Vo_8131_0 vo_8131_0 = new Vo_8131_0();
/* 21 */     vo_8131_0.buf = "";
/* 22 */     vo_8131_0.cookie = (cookie + 1);
/* 23 */     new M8131_0().write(vo_8131_0);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 28 */     return 4638;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4638.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */