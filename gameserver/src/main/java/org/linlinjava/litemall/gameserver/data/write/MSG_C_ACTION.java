/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_19959_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */

/**
 * MSG_C_ACTION
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_C_ACTION extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_19959_0 object1 = (Vo_19959_0)object;
/* 14 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.round));
/*    */     
/* 16 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.aid));
/*    */     
/* 18 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.action));
/*    */     
/* 20 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.vid));
/*    */     
/* 22 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.para));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 27 */     return 19959;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M19959_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */