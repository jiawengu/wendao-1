/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_19945_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_C_ACCEPT_HIT extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_19945_0 object1 = (Vo_19945_0)object;
/* 14 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 16 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.hid));
/*    */     
/* 18 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.para_ex));
/*    */     
/* 20 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.missed));
/*    */     
/* 22 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.para));
/*    */     
/* 24 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.damage_type));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 29 */     return 19945;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M19945_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */