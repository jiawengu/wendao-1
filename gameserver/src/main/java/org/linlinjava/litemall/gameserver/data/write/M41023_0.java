/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41023_0;
/*    */

/**
 * MSG_TASK_STATUS_INFO
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class M41023_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_41023_0 object1 = (Vo_41023_0)object;
/* 13 */     GameWriteTool.writeString(writeBuf, object1.taskName);
/*    */     
/* 15 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.status));
/*    */   }
/*    */   
/* 18 */   public int cmd() { return 41023; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M41023_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */