/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.db.domain.StoreGoods;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ 
/*    */ @Service
/*    */ public class M65499_0
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 17 */     List<StoreGoods> list = (List)object;
/* 18 */     GameWriteTool.writeString(writeBuf, "");
/*    */     
/* 20 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));
/*    */     
/* 22 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(list.size()));
/*    */     
/* 24 */     for (int i = 0; i < list.size(); i++) {
/* 25 */       GameWriteTool.writeString(writeBuf, ((StoreGoods)list.get(i)).getName());
/*    */       
/* 27 */       GameWriteTool.writeString(writeBuf, ((StoreGoods)list.get(i)).getBarcode());
/*    */       
/* 29 */       GameWriteTool.writeShort(writeBuf, ((StoreGoods)list.get(i)).getForSale());
/*    */       
/* 31 */       GameWriteTool.writeShort(writeBuf, ((StoreGoods)list.get(i)).getShowPos());
/*    */       
/* 33 */       GameWriteTool.writeShort(writeBuf, ((StoreGoods)list.get(i)).getRpos());
/*    */       
/* 35 */       GameWriteTool.writeShort(writeBuf, ((StoreGoods)list.get(i)).getSaleQuota());
/*    */       
/* 37 */       GameWriteTool.writeShort(writeBuf, ((StoreGoods)list.get(i)).getRecommend());
/*    */       
/* 39 */       GameWriteTool.writeInt(writeBuf, ((StoreGoods)list.get(i)).getCoin());
/*    */       
/* 41 */       GameWriteTool.writeByte(writeBuf, ((StoreGoods)list.get(i)).getDiscount());
/*    */       
/* 43 */       GameWriteTool.writeInt(writeBuf, ((StoreGoods)list.get(i)).getDiscount());
/*    */       
/* 45 */       GameWriteTool.writeByte(writeBuf, ((StoreGoods)list.get(i)).getType());
/*    */       
/* 47 */       GameWriteTool.writeShort(writeBuf, ((StoreGoods)list.get(i)).getQuotaLimit());
/*    */       
/* 49 */       GameWriteTool.writeByte(writeBuf, ((StoreGoods)list.get(i)).getMustVip());
/*    */       
/* 51 */       GameWriteTool.writeByte(writeBuf, ((StoreGoods)list.get(i)).getIsGift());
/*    */       
/* 53 */       GameWriteTool.writeByte(writeBuf, ((StoreGoods)list.get(i)).getFollowPetType());
/*    */     }
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 59 */     return 65499;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M65499_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */