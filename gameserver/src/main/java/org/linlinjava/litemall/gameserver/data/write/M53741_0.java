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
/*    */ import org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing;
/*    */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*    */ import org.linlinjava.litemall.gameserver.domain.Duiyuan;
/*    */ import org.linlinjava.litemall.gameserver.domain.LieBiao;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */

/**
 * MSG_REQUEST_LIST -- 通知客户端请求数据
 */
/*    */ @Service
/*    */ public class M53741_0
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 24 */     List<LieBiao> object1 = (List)object;
/*    */     
/* 26 */     if (object1.size() > 0) {
/* 27 */       GameWriteTool.writeString(writeBuf, ((LieBiao)object1.get(0)).ask_type);
/*    */     }
/*    */     
/*    */ 
/* 31 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.size()));
/*    */     
/* 33 */     for (LieBiao lieBiao : object1) {
/* 34 */       GameWriteTool.writeString(writeBuf, lieBiao.peer_name);
/*    */       
/*    */ 
/* 37 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(lieBiao.duiyuanList.size()));
/* 38 */       for (Duiyuan duiyuan : lieBiao.duiyuanList) {
/* 39 */         GameWriteTool.writeInt(writeBuf, Integer.valueOf(duiyuan.org_icon));
/*    */         
/* 41 */         Map<Object, Object> map = UtilObjMapshuxing.Duiyuan(duiyuan);
/* 42 */         map.remove("org_icon");
/* 43 */         map.remove("mapteamMembersCount");
/* 44 */         map.remove("mapcomeback_flag");
/*    */         
/*    */ 
/* 47 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*    */         Entry<Object, Object> entry;
/* 49 */         while (it.hasNext()) {
/* 50 */           entry = (Entry)it.next();
/* 51 */           if ((entry.getValue().equals(Integer.valueOf(0))) || (entry.getKey().equals(""))) {
/* 52 */             it.remove();
/*    */           }
/*    */         }
/* 55 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 56 */         for (Entry<Object, Object> objectEntry : map.entrySet()) {
/* 57 */           if (BuildFields.data.get((String)objectEntry.getKey()) != null) {
/* 58 */             BuildFields.get((String)objectEntry.getKey()).write(writeBuf, objectEntry.getValue());
/*    */           } else {
/* 60 */             System.out.println(objectEntry.getKey());
/*    */           }
/*    */         }
/*    */         
/*    */ 
/* 65 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(duiyuan.mapteamMembersCount));
/* 66 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(duiyuan.mapcomeback_flag));
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 75 */     return 53741;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M53741_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */