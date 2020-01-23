/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.io.PrintStream;
/*    */ import java.util.HashMap;
/*    */ import java.util.Map;
/*    */ import java.util.Map.Entry;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.UtilObjMap;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45128_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class MSG_BASIC_GUARD_ATTRI extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 20 */     Vo_45128_0 object1 = (Vo_45128_0)object;
/* 21 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(1));
/*    */     
/*    */ 
/*    */ 
/*    */ 
/* 26 */     Map<Object, Object> map = new HashMap();
/* 27 */     map = UtilObjMap.Vo_45128_0(object1);
/* 28 */     map.remove("no");
/* 29 */     map.remove("type1");
/* 30 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no));
/* 31 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.type1));
/* 32 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 33 */     for (Entry<Object, Object> entry : map.entrySet()) {
/* 34 */       if (BuildFields.data.get((String)entry.getKey()) != null) {
/* 35 */         BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
/*    */       } else {
/* 37 */         System.out.println(entry.getKey());
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 44 */     return 45128;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M45128_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */