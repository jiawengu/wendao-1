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
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20467_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class M20467_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 21 */     Vo_20467_0 object1 = (Vo_20467_0)object;
/* 22 */     GameWriteTool.writeString(writeBuf, object1.caption);
/*    */     
/* 24 */     GameWriteTool.writeString(writeBuf, object1.content);
/*    */     
/* 26 */     GameWriteTool.writeString(writeBuf, object1.peer_name);
/*    */     
/* 28 */     GameWriteTool.writeString(writeBuf, object1.ask_type);
/*    */     
/* 30 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(1));
/* 31 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.org_icon));
/*    */     
/* 33 */     Map<Object, Object> map = UtilObjMap.Vo_20467_0(object1);
/* 34 */     map.remove("caption");
/* 35 */     map.remove("content");
/* 36 */     map.remove("org_icon");
/*    */     
/* 38 */     map.remove("peer_name");
/* 39 */     map.remove("ask_type");
/* 40 */     map.remove("teamMembersCount");
/*    */     
/* 42 */     map.remove("comeback_flag");
/*    */     
/* 44 */     Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*    */     Entry<Object, Object> entry;
/* 46 */     while (it.hasNext()) {
/* 47 */       entry = (Entry)it.next();
/* 48 */       if ((entry.getValue() instanceof Integer)) {
/* 49 */         if (entry.getValue().equals(Integer.valueOf(0))) {
/* 50 */           it.remove();
/*    */         }
/*    */       }
/* 53 */       else if (entry.getValue() == null) {
/* 54 */         it.remove();
/*    */       }
/*    */     }
/*    */     
/* 58 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 59 */     for (Entry<Object, Object> objectEntry : map.entrySet()) {
/* 60 */       if (BuildFields.data.get((String)objectEntry.getKey()) != null) {
/* 61 */         BuildFields.get((String)objectEntry.getKey()).write(writeBuf, objectEntry.getValue());
/*    */       } else {
/* 63 */         System.out.println(objectEntry.getKey());
/*    */       }
/*    */     }
/*    */     
/*    */ 
/* 68 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.teamMembersCount));
/*    */     
/* 70 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.comeback_flag));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 75 */     return 20467;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M20467_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */