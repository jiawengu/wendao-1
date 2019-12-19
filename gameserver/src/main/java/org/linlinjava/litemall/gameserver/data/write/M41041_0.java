/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41041_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M41041_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_41041_0 object1 = (Vo_41041_0)object;
/* 14 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.type));
/*    */     
/* 16 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.limitNum));
/*    */     
/* 18 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.count));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 23 */     return 41041;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M41041_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */