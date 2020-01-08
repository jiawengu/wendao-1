/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_64971_0;
/*    */ //MSG_C_REFRESH_PET_LIST
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_C_REFRESH_PET_LIST extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_64971_0 object1 = (Vo_64971_0)object;
/* 13 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count));
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 17 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.haveCalled));
/*    */   }
/*    */   
/* 20 */   public int cmd() { return 64971; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M64971_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */