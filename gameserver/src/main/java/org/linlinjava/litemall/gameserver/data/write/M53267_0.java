/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53267_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M53267_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_53267_0 object1 = (Vo_53267_0)object;
/* 14 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count));
/*    */     
/* 16 */     GameWriteTool.writeString(writeBuf, object1.barcode0);
/*    */     
/* 18 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.sale_quota0));
/*    */     
/* 20 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.toMoney0));
/*    */     
/* 22 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.costCoin0));
/*    */     
/* 24 */     GameWriteTool.writeString(writeBuf, object1.barcode1);
/*    */     
/* 26 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.sale_quota1));
/*    */     
/* 28 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.toMoney1));
/*    */     
/* 30 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.costCoin1));
/*    */     
/* 32 */     GameWriteTool.writeString(writeBuf, object1.barcode2);
/*    */     
/* 34 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.sale_quota2));
/*    */     
/* 36 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.toMoney2));
/*    */     
/* 38 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.costCoin2));
/*    */     
/* 40 */     GameWriteTool.writeString(writeBuf, object1.barcode3);
/*    */     
/* 42 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.sale_quota3));
/*    */     
/* 44 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.toMoney3));
/*    */     
/* 46 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.costCoin3));
/*    */     
/* 48 */     GameWriteTool.writeString(writeBuf, object1.barcode4);
/*    */     
/* 50 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.sale_quota4));
/*    */     
/* 52 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.toMoney4));
/*    */     
/* 54 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.costCoin4));
/*    */     
/* 56 */     GameWriteTool.writeString(writeBuf, object1.barcode5);
/*    */     
/* 58 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.sale_quota5));
/*    */     
/* 60 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.toMoney5));
/*    */     
/* 62 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.costCoin5));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 67 */     return 53267;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M53267_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */