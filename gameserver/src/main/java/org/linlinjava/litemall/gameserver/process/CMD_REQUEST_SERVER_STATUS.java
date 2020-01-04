/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M61663;
/*    */ import org.linlinjava.litemall.gameserver.game.GameCore;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */

/**
 * CMD_REQUEST_SERVER_STATUS     -- 请求线列表跟状态
 */
/*    */ @Service
/*    */ public class CMD_REQUEST_SERVER_STATUS implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 16 */     GameObjectChar.send(new M61663(), GameCore.that.getGameLineAll());
/*    */   }
/*    */   
/*    */   public int cmd() {
/* 20 */     return 222;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C222.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */