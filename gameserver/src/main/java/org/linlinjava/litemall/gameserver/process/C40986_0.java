/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40987_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M40987_0;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C40986_0 implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 17 */     int petId = GameReadTool.readInt(buff);
/*    */     
/* 19 */     String type = GameReadTool.readString(buff);
/*    */     
/* 21 */     Vo_40987_0 vo_40987_0 = new Vo_40987_0();
/* 22 */     vo_40987_0.petId = petId;
/* 23 */     vo_40987_0.count = 0;
/* 24 */     GameObjectChar.send(new M40987_0(), vo_40987_0);
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 30 */     return 40986;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C40986_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */