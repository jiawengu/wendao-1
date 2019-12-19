/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_7659_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M7659_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_7659_0 object1 = (Vo_7659_0)object;
/* 13 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.a));
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 17 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.time));
/*    */     
/* 19 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.question));
/*    */     
/* 21 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.round));
/*    */     
/* 23 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.curTime));
/*    */   }
/*    */   
/* 26 */   public int cmd() { return 7659; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M7659_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */