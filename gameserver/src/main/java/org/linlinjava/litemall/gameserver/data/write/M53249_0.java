/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53249_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M53249_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_53249_0 object1 = (Vo_53249_0)object;
/* 14 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.type));
/*    */     
/* 16 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count));
/*    */     
/* 18 */     GameWriteTool.writeString(writeBuf, object1.name0);
/*    */     
/* 20 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price0));
/*    */     
/* 22 */     GameWriteTool.writeString(writeBuf, object1.name1);
/*    */     
/* 24 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price1));
/*    */     
/* 26 */     GameWriteTool.writeString(writeBuf, object1.name2);
/*    */     
/* 28 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price2));
/*    */     
/* 30 */     GameWriteTool.writeString(writeBuf, object1.name3);
/*    */     
/* 32 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price3));
/*    */     
/* 34 */     GameWriteTool.writeString(writeBuf, object1.name4);
/*    */     
/* 36 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price4));
/*    */     
/* 38 */     GameWriteTool.writeString(writeBuf, object1.name5);
/*    */     
/* 40 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price5));
/*    */     
/* 42 */     GameWriteTool.writeString(writeBuf, object1.name6);
/*    */     
/* 44 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price6));
/*    */     
/* 46 */     GameWriteTool.writeString(writeBuf, object1.name7);
/*    */     
/* 48 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price7));
/*    */     
/* 50 */     GameWriteTool.writeString(writeBuf, object1.name8);
/*    */     
/* 52 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price8));
/*    */     
/* 54 */     GameWriteTool.writeString(writeBuf, object1.name9);
/*    */     
/* 56 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price9));
/*    */     
/* 58 */     GameWriteTool.writeString(writeBuf, object1.name10);
/*    */     
/* 60 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price10));
/*    */     
/* 62 */     GameWriteTool.writeString(writeBuf, object1.name11);
/*    */     
/* 64 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.price11));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 69 */     return 53249;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M53249_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */