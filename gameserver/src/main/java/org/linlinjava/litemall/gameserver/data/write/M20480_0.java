/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*    */

/**
 * MSG_NOTIFY_MISC
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class M20480_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_20480_0 object1 = (Vo_20480_0)object;
/* 13 */     GameWriteTool.writeString2(writeBuf, object1.msg);
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.time));
/*    */   }
/*    */   
/* 18 */   public int cmd() { return 20480; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M20480_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */