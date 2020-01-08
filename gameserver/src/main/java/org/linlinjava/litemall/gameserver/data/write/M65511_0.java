/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.io.PrintStream;
/*    */ import java.util.HashMap;
/*    */ import java.util.Iterator;
/*    */ import java.util.Map;
/*    */ import java.util.Map.Entry;
/*    */ import java.util.Set;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing;
/*    */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*    */ import org.linlinjava.litemall.gameserver.domain.ZbAttribute;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ //MSG_UPDATE_IMPROVEMENT
/*    */ @org.springframework.stereotype.Service
/*    */ public class M65511_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 21 */     ZbAttribute object1 = (ZbAttribute)object;
/* 22 */     Map<Object, Object> map = new HashMap();
/* 23 */     if (object1 != null) {
/* 24 */       map = UtilObjMapshuxing.ZbAttribute(object1);
/* 25 */       Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 26 */       map.remove("id");
/* 27 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */       
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/* 35 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 36 */       for (Entry<Object, Object> entry : map.entrySet()) {
/* 37 */         if (BuildFields.data.get((String)entry.getKey()) != null) {
/* 38 */           BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
/*    */         } else {
/* 40 */           System.out.println(entry.getKey());
/*    */         }
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 60 */     return 65511;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M65511_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */