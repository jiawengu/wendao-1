/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.io.PrintStream;
/*    */ import java.util.HashMap;
/*    */ import java.util.Iterator;
/*    */ import java.util.List;
/*    */ import java.util.Map;
/*    */ import java.util.Map.Entry;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45105_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*    */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*    */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_MARKET_PET_CARD extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 23 */     Vo_45105_0 object1 = (Vo_45105_0)object;
/* 24 */     GameWriteTool.writeString(writeBuf, object1.goodId);
/*    */     
/* 26 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.status));
/*    */     
/* 28 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime));
/*    */     
/* 30 */     Petbeibao list = object1.petbeibao;
/*    */     
/*    */ 
/*    */ 
/*    */ 
/* 35 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(list.petShuXing.size()));
/* 36 */     for (int j = 0; j < list.petShuXing.size(); j++)
/*    */     {
/* 38 */       PetShuXing petShuXing = (PetShuXing)list.petShuXing.get(j);
/* 39 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(((PetShuXing)list.petShuXing.get(j)).no));
/*    */       
/* 41 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(((PetShuXing)list.petShuXing.get(j)).type1));
/*    */       
/* 43 */       Map<Object, Object> map = new HashMap();
/* 44 */       map = UtilObjMapshuxing.PetShuXing(petShuXing);
/* 45 */       map.remove("no");
/* 46 */       map.remove("type1");
/*    */       
/*    */ 
/*    */ 
/* 50 */       Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*    */       
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/* 57 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 58 */       for (Entry<Object, Object> entry : map.entrySet()) {
/* 59 */         if (BuildFields.data.get((String)entry.getKey()) != null) {
/* 60 */           BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
/*    */         } else {
/* 62 */           System.out.println(entry.getKey());
/*    */         }
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 70 */     return 45105;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M45105_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */