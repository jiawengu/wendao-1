/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41106_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M41106_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_41106_0 object1 = (Vo_41106_0)object;
/* 13 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.month));
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime));
/*    */     
/* 17 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime));
/*    */     
/* 19 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.count));
/*    */     
/* 21 */     GameWriteTool.writeString(writeBuf, object1.item_name0);
/*    */     
/* 23 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.item_amount0));
/*    */     
/* 25 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.item_gift0));
/*    */     
/* 27 */     GameWriteTool.writeString(writeBuf, object1.item_icon0);
/*    */     
/* 29 */     GameWriteTool.writeString(writeBuf, object1.item_name1);
/*    */     
/* 31 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.item_amount1));
/*    */     
/* 33 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.item_gift1));
/*    */     
/* 35 */     GameWriteTool.writeString(writeBuf, object1.item_icon1);
/*    */     
/* 37 */     GameWriteTool.writeString(writeBuf, object1.item_name2);
/*    */     
/* 39 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.item_amount2));
/*    */     
/* 41 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.item_gift2));
/*    */     
/* 43 */     GameWriteTool.writeString(writeBuf, object1.item_icon2);
/*    */     
/* 45 */     GameWriteTool.writeString(writeBuf, object1.item_name3);
/*    */     
/* 47 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.item_amount3));
/*    */     
/* 49 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.item_gift3));
/*    */     
/* 51 */     GameWriteTool.writeString(writeBuf, object1.item_icon3);
/*    */   }
/*    */   
/* 54 */   public int cmd() { return 41106; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M41106_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */