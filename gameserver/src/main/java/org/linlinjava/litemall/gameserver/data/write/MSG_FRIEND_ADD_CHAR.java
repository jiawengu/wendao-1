/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.io.PrintStream;
/*    */ import java.util.Iterator;
/*    */ import java.util.List;
/*    */ import java.util.Map;
/*    */ import java.util.Map.Entry;
/*    */ import java.util.Set;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.UtilObjMap;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61545_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class MSG_FRIEND_ADD_CHAR extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 22 */     List<Vo_61545_0> vo_61545_0List = (List)object;
/* 23 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_61545_0List.size()));
/* 24 */     for (Vo_61545_0 object1 : vo_61545_0List)
/*    */     {
/* 26 */       GameWriteTool.writeString(writeBuf, object1.groupBuf);
/*    */       
/* 28 */       GameWriteTool.writeString(writeBuf, object1.charBuf);
/*    */       
/* 30 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.blocked));
/*    */       
/* 32 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.online));
/*    */       
/* 34 */       GameWriteTool.writeString(writeBuf, object1.server_name1);
/*    */       
/* 36 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.insider_level));
/*    */       
/* 38 */       Map<Object, Object> map = UtilObjMap.Vo_61545_0(object1);
/* 39 */       map.remove("groupBuf");
/* 40 */       map.remove("charBuf");
/* 41 */       map.remove("blocked");
/* 42 */       map.remove("online");
/* 43 */       map.remove("server_name1");
/* 44 */       map.remove("insider_level");
/*    */       
/*    */ 
/* 47 */       Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*    */       
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/* 55 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 56 */       for (Entry<Object, Object> entry : map.entrySet()) {
/* 57 */         if (BuildFields.data.get((String)entry.getKey()) != null) {
/* 58 */           BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
/*    */         } else {
/* 60 */           System.out.println(entry.getKey());
/*    */         }
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 69 */     return 61545;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M61545_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */