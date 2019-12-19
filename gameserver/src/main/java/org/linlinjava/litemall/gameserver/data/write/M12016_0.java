/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.io.PrintStream;
/*    */ import java.util.HashMap;
/*    */ import java.util.List;
/*    */ import java.util.Map;
/*    */ import java.util.Map.Entry;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing;
/*    */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*    */ import org.linlinjava.litemall.gameserver.domain.ShouHu;
/*    */ import org.linlinjava.litemall.gameserver.domain.ShouHuShuXing;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ 
/*    */ @Service
/*    */ public class M12016_0
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 24 */     List<ShouHu> object1 = (List)object;
/*    */     
/* 26 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.size()));
/* 27 */     for (int i = 0; i < object1.size(); i++)
/*    */     {
/* 29 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(((ShouHu)object1.get(i)).id));
/* 30 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(((ShouHu)object1.get(i)).listShouHuShuXing.size()));
/* 31 */       for (int j = 0; j < ((ShouHu)object1.get(i)).listShouHuShuXing.size(); j++) {
/* 32 */         ShouHuShuXing shouHuShuXing = (ShouHuShuXing)((ShouHu)object1.get(i)).listShouHuShuXing.get(j);
/*    */         
/* 34 */         Map<Object, Object> map = new HashMap();
/* 35 */         if (shouHuShuXing != null) {
/* 36 */           map = UtilObjMapshuxing.ShouHuShuXing(shouHuShuXing);
/* 37 */           map.remove("no");
/* 38 */           map.remove("type1");
/*    */           
/* 40 */           GameWriteTool.writeByte(writeBuf, Integer.valueOf(shouHuShuXing.no));
/* 41 */           GameWriteTool.writeByte(writeBuf, Integer.valueOf(shouHuShuXing.type1));
/* 42 */           GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 43 */           for (Entry<Object, Object> entry : map.entrySet()) {
/* 44 */             if (BuildFields.data.get((String)entry.getKey()) != null) {
/* 45 */               BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
/*    */             } else {
/* 47 */               System.out.println(entry.getKey());
/*    */             }
/*    */           }
/*    */         }
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 59 */     return 12016;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M12016_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */