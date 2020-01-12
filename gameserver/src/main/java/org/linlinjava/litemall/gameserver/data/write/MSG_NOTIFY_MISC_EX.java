/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */

/**
 * MSG_NOTIFY_MISC_EX
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_NOTIFY_MISC_EX extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_20481_0 object1 = (Vo_20481_0)object;
/* 14 */     GameWriteTool.writeString2(writeBuf, object1.msg);
/*    */     
/* 16 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.time));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 21 */     return 20481;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M20481_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */