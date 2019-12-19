/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4275_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M4275_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_4275_0 object1 = (Vo_4275_0)object;
/* 14 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.a));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 19 */     return 4275;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M4275_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */