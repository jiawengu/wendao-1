/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M8405;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C4308 implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 16 */     String lineName = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);
/*    */     
/* 18 */     GameObjectChar.send(new M8405(), GameObjectChar.getGameObjectChar().chara.name);
/*    */   }
/*    */   
/*    */   public int cmd() {
/* 22 */     return 4308;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4308.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */