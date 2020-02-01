/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.game.GameLine;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.beans.factory.annotation.Value;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class MSG_REQUEST_SERVER_STATUS
/*    */   extends BaseWrite
/*    */ {
/*    */   @Value("${netty.ip}")
/*    */   private String ip;
/*    */   
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 20 */     List<GameLine> gameLines = (List)object;
/* 21 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(gameLines.size()));
/* 22 */     for (GameLine gameLine : gameLines) {
/* 23 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(gameLine.lineNum));
/* 24 */       GameWriteTool.writeString(writeBuf, gameLine.lineName);
/* 25 */       GameWriteTool.writeString(writeBuf, this.ip);
/* 26 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(3));
/*    */     }
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 32 */     return 61663;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M61663.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */