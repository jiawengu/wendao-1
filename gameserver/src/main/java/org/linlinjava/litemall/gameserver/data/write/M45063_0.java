/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0;
/*    */

/**
 * MSG_AUTO_WALK
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class M45063_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_45063_0 object1 = (Vo_45063_0)object;
/* 13 */     GameWriteTool.writeString(writeBuf, object1.task_name);
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.check_point));
/*    */   }
/*    */   
/* 18 */   public int cmd() { return 45063; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M45063_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */