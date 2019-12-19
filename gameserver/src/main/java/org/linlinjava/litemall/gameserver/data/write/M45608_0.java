/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45608_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M45608_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_45608_0 object1 = (Vo_45608_0)object;
/* 13 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count));
/*    */     
/* 15 */     GameWriteTool.writeString(writeBuf, object1.name0);
/*    */     
/* 17 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price0));
/*    */     
/* 19 */     GameWriteTool.writeString(writeBuf, object1.name1);
/*    */     
/* 21 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price1));
/*    */     
/* 23 */     GameWriteTool.writeString(writeBuf, object1.name2);
/*    */     
/* 25 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price2));
/*    */     
/* 27 */     GameWriteTool.writeString(writeBuf, object1.name3);
/*    */     
/* 29 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price3));
/*    */     
/* 31 */     GameWriteTool.writeString(writeBuf, object1.name4);
/*    */     
/* 33 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price4));
/*    */     
/* 35 */     GameWriteTool.writeString(writeBuf, object1.name5);
/*    */     
/* 37 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price5));
/*    */     
/* 39 */     GameWriteTool.writeString(writeBuf, object1.name6);
/*    */     
/* 41 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price6));
/*    */     
/* 43 */     GameWriteTool.writeString(writeBuf, object1.name7);
/*    */     
/* 45 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price7));
/*    */     
/* 47 */     GameWriteTool.writeString(writeBuf, object1.name8);
/*    */     
/* 49 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price8));
/*    */     
/* 51 */     GameWriteTool.writeString(writeBuf, object1.name9);
/*    */     
/* 53 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price9));
/*    */     
/* 55 */     GameWriteTool.writeString(writeBuf, object1.name10);
/*    */     
/* 57 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price10));
/*    */     
/* 59 */     GameWriteTool.writeString(writeBuf, object1.name11);
/*    */     
/* 61 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price11));
/*    */     
/* 63 */     GameWriteTool.writeString(writeBuf, object1.name12);
/*    */     
/* 65 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price12));
/*    */     
/* 67 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count1));
/*    */   }
/*    */   
/* 70 */   public int cmd() { return 45608; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M45608_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */