/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class MSG_SUIJI_RICHANGE_FANBEI
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 14 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(4));
/*    */     
/* 16 */     GameWriteTool.writeString(writeBuf, "xiux");
/*    */     
/* 18 */     GameWriteTool.writeString(writeBuf, "xiuxjz");
/*    */     
/* 20 */     GameWriteTool.writeString(writeBuf, "xiuxjz");
/*    */     
/* 22 */     GameWriteTool.writeString(writeBuf, "xiuxjz");
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 27 */     return 41017;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M41017_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */