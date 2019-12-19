/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4321_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M4321_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_4321_0 object1 = (Vo_4321_0)object;
/* 13 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.flag));
/*    */     
/* 15 */     GameWriteTool.writeString(writeBuf, object1.dist);
/*    */     
/* 17 */     GameWriteTool.writeString(writeBuf, object1.name);
/*    */     
/* 19 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.time));
/*    */     
/* 21 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.a));
/*    */     
/* 23 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.b));
/*    */     
/* 25 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.c));
/*    */   }
/*    */   
/* 28 */   public int cmd() { return 4321; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M4321_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */