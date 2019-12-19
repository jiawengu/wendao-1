/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41051_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M41051_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_41051_0 object1 = (Vo_41051_0)object;
/* 13 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.count));
/*    */     
/* 15 */     GameWriteTool.writeString(writeBuf, object1.name0);
/*    */     
/* 17 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.amount0));
/*    */     
/* 19 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime0));
/*    */     
/* 21 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime0));
/*    */   }
/*    */   
/* 24 */   public int cmd() { return 41051; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M41051_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */