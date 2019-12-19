/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.beans.factory.annotation.Value;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M8405 extends BaseWrite
/*    */ {
/*    */   @Value("${netty.ip}")
/*    */   private String ip;
/*    */   
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 16 */     String charaName = (String)object;
/* 17 */     GameWriteTool.writeString(writeBuf, this.ip + ",8300,8300,8300," + charaName);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 22 */     return 8405;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M8405.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */