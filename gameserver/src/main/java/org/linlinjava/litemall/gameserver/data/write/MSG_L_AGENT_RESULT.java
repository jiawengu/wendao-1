/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_13143_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_L_AGENT_RESULT extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_13143_0 object1 = (Vo_13143_0)object;
/* 13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.result));
/*    */     
/* 15 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.privilege));
/*    */     
/* 17 */     GameWriteTool.writeString(writeBuf, object1.ip);
/*    */     
/* 19 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.port));
/*    */     
/* 21 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.seed));
/*    */     
/* 23 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.auth_key));
/*    */     
/* 25 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 27 */     GameWriteTool.writeString(writeBuf, object1.serverName);
/*    */     
/* 29 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.serverStatus));
/*    */     
/* 31 */     GameWriteTool.writeString(writeBuf, object1.msg);
/*    */   }
/*    */   
/* 34 */   public int cmd() { return 13143; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M13143_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */