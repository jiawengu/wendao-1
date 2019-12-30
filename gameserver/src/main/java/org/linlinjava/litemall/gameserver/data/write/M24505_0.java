/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.io.PrintStream;
/*    */ import java.util.Iterator;
/*    */ import java.util.Map;
/*    */ import java.util.Map.Entry;
/*    */ import java.util.Set;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.UtilObjMap;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_24505_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ //MSG_FRIEND_UPDATE_PARTIAL
/*    */ @Service
/*    */ public class M24505_0
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 23 */     Vo_24505_0 object1 = (Vo_24505_0)object;
/* 24 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.update_type));
/*    */     
/* 26 */     GameWriteTool.writeString(writeBuf, object1.groupBuf);
/*    */     
/* 28 */     GameWriteTool.writeString(writeBuf, object1.charBuf);
/*    */     
/*    */ 
/* 31 */     Map<Object, Object> map = UtilObjMap.Vo_24505_0(object1);
/* 32 */     map.remove("update_type");
/* 33 */     map.remove("groupBuf");
/* 34 */     map.remove("charBuf");
/*    */     
/* 36 */     Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*    */     
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/* 44 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 45 */     for (Entry<Object, Object> entry : map.entrySet()) {
/* 46 */       if (BuildFields.data.get((String)entry.getKey()) != null) {
/* 47 */         BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
/*    */       } else {
/* 49 */         System.out.println(entry.getKey());
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 56 */     return 24505;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M24505_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */