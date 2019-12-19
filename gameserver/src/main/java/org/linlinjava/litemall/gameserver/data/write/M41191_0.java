/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41191_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M41191_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_41191_0 object1 = (Vo_41191_0)object;
/* 13 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.flag));
/*    */     
/* 15 */     GameWriteTool.writeString(writeBuf, object1.opType);
/*    */   }
/*    */   
/* 18 */   public int cmd() { return 41191; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M41191_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */