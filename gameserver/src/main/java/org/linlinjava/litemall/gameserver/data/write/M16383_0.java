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
/*    */ import org.linlinjava.litemall.gameserver.data.UtilObjMap;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */

/**
 * MSG_MESSAGE_EX
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class M16383_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 21 */     Vo_16383_0 object1 = (Vo_16383_0)object;
/* 22 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.channel));
/*    */     
/* 24 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 26 */     GameWriteTool.writeString(writeBuf, object1.name);
/*    */     
/* 28 */     GameWriteTool.writeString2(writeBuf, object1.msg);
/*    */     
/* 30 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.time));
/*    */     
/* 32 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.privilege));
/*    */     
/* 34 */     GameWriteTool.writeString(writeBuf, object1.server_name);
/*    */     
/* 36 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.show_extra));
/*    */     
/* 38 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.compress));
/*    */     
/* 40 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.orgLength));
/*    */     
/* 42 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.cardCount));
/*    */     
/* 44 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.voiceTime));
/*    */     
/* 46 */     GameWriteTool.writeString2(writeBuf, object1.token);
/*    */     
/* 48 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.checksum));
/*    */     
/*    */ 
/* 51 */     Map<Object, Object> map = new HashMap();
/* 52 */     map = UtilObjMap.Vo_16383_0(object1);
/* 53 */     map.remove("channel");
/* 54 */     map.remove("id");
/*    */     
/* 56 */     map.remove("name");
/* 57 */     map.remove("msg");
/* 58 */     map.remove("time");
/* 59 */     map.remove("privilege");
/* 60 */     map.remove("server_name");
/* 61 */     map.remove("show_extra");
/*    */     
/* 63 */     map.remove("compress");
/* 64 */     map.remove("cardCount");
/* 65 */     map.remove("orgLength");
/* 66 */     map.remove("voiceTime");
/* 67 */     map.remove("token");
/* 68 */     map.remove("checksum");
/*    */     
/*    */ 
/* 71 */     Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*    */     Entry<Object, Object> entry;
/* 73 */     while (it.hasNext()) {
/* 74 */       entry = (Entry)it.next();
/* 75 */       if (entry.getValue().equals(Integer.valueOf(0))) {
/* 76 */         it.remove();
/*    */       }
/*    */     }
/*    */     
/* 80 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 81 */     for (Entry<Object, Object> entry2 : map.entrySet()) {
/* 82 */       if (BuildFields.data.get((String)entry2.getKey()) != null) {
/* 83 */         BuildFields.get((String)entry2.getKey()).write(writeBuf, entry2.getValue());
/*    */       } else {
/* 85 */         System.out.println(entry2.getKey());
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 92 */     return 16383;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M16383_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */