/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53249_1;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M53249_1 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_53249_1 object1 = (Vo_53249_1)object;
/* 13 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.type));
/*    */     
/* 15 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count));
/*    */     
/* 17 */     GameWriteTool.writeString(writeBuf, object1.name0);
/*    */     
/* 19 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price0));
/*    */     
/* 21 */     GameWriteTool.writeString(writeBuf, object1.name1);
/*    */     
/* 23 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price1));
/*    */     
/* 25 */     GameWriteTool.writeString(writeBuf, object1.name2);
/*    */     
/* 27 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price2));
/*    */     
/* 29 */     GameWriteTool.writeString(writeBuf, object1.name3);
/*    */     
/* 31 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price3));
/*    */     
/* 33 */     GameWriteTool.writeString(writeBuf, object1.name4);
/*    */     
/* 35 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price4));
/*    */     
/* 37 */     GameWriteTool.writeString(writeBuf, object1.name5);
/*    */     
/* 39 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price5));
/*    */   }
/*    */   
/* 42 */   public int cmd() { return 53249; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M53249_1.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */