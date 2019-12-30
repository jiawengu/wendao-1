/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */
/**
 * MSG_DISAPPEAR    角色不再视野内
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class M12285_1 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     int id = ((Integer)object).intValue();
/* 13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(id));
/* 14 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(1));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 19 */     return 12285;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M12285_1.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */