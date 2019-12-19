/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.db.domain.GroceriesShop;
/*    */ import org.linlinjava.litemall.db.domain.MedicineShop;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class M65503_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 16 */     List object1 = (List)object;
/* 17 */     if ((object1.get(0) instanceof MedicineShop))
/*    */     {
/* 19 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(15907));
/*    */     } else {
/* 21 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(15908));
/*    */     }
/*    */     
/* 24 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(1));
/*    */     
/* 26 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(100));
/*    */     
/* 28 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(0));
/*    */     
/* 30 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(6));
/*    */     
/* 32 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.size()));
/*    */     
/* 34 */     for (int i = 0; i < object1.size(); i++) {
/* 35 */       if ((object1.get(i) instanceof MedicineShop)) {
/* 36 */         MedicineShop obj = (MedicineShop)object1.get(i);
/* 37 */         GameWriteTool.writeShort(writeBuf, obj.getGoodsNo());
/*    */         
/* 39 */         GameWriteTool.writeInt(writeBuf, obj.getPayType());
/*    */         
/* 41 */         GameWriteTool.writeShort(writeBuf, obj.getItemcount());
/*    */         
/* 43 */         GameWriteTool.writeString(writeBuf, obj.getName());
/*    */         
/* 45 */         GameWriteTool.writeInt(writeBuf, obj.getValue());
/*    */         
/* 47 */         GameWriteTool.writeShort(writeBuf, obj.getLevel());
/*    */         
/* 49 */         GameWriteTool.writeByte(writeBuf, obj.getType());
/*    */       } else {
/* 51 */         GroceriesShop obj = (GroceriesShop)object1.get(i);
/* 52 */         GameWriteTool.writeShort(writeBuf, obj.getGoodsNo());
/*    */         
/* 54 */         GameWriteTool.writeInt(writeBuf, obj.getPayType());
/*    */         
/* 56 */         GameWriteTool.writeShort(writeBuf, obj.getItemcount());
/*    */         
/* 58 */         GameWriteTool.writeString(writeBuf, obj.getName());
/*    */         
/* 60 */         GameWriteTool.writeInt(writeBuf, obj.getValue());
/*    */         
/* 62 */         GameWriteTool.writeShort(writeBuf, obj.getLevel());
/*    */         
/* 64 */         GameWriteTool.writeByte(writeBuf, obj.getType());
/*    */       }
/*    */     }
/*    */     
/*    */ 
/*    */ 
/*    */ 
/* 71 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(0));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 76 */     return 65503;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M65503_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */