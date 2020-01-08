/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */

/**
 * MSG_DISAPPEAR    角色不再视野内
 */
/*    */ @Service
/*    */ public class M12285_0
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 15 */     int id = ((Integer)object).intValue();
/* 16 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(id));
/* 17 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(32768));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 22 */     return 12285;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M12285_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */