/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.HashMap;
/*    */ import java.util.Iterator;
/*    */ import java.util.List;
/*    */ import java.util.Map;
/*    */ import java.util.Map.Entry;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.UtilObjMap;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65017_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M64995_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 20 */     List<Vo_65017_0> obj = (List)object;
/* 21 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(obj.size()));
/* 22 */     for (int i = 0; i < obj.size(); i++) {
/* 23 */       Vo_65017_0 object1 = (Vo_65017_0)obj.get(i);
/*    */       
/* 25 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */       
/* 27 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.leader));
/*    */       
/* 29 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.weapon_icon));
/*    */       
/* 31 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.pos));
/*    */       
/* 33 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.rank));
/*    */       
/* 35 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.vip_type));
/*    */       
/*    */ 
/* 38 */       Map<Object, Object> map = new HashMap();
/* 39 */       map = UtilObjMap.Vo_65019_0(object1);
/*    */       
/* 41 */       map.remove("id");
/* 42 */       map.remove("leader");
/* 43 */       map.remove("weapon_icon");
/* 44 */       map.remove("pos");
/* 45 */       map.remove("rank");
/* 46 */       map.remove("vip_type");
/* 47 */       map.remove("org_icon");
/* 48 */       map.remove("suit_icon");
/* 49 */       map.remove("suit_light_effect");
/* 50 */       map.remove("special_icon");
/*    */       
/* 52 */       Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*    */       
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/* 60 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 61 */       for (Entry<Object, Object> entry : map.entrySet()) {
/* 62 */         if (BuildFields.data.get((String)entry.getKey()) != null) {
/* 63 */           BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
/*    */         } else {
/* 65 */           System.out.println(entry.getKey());
/*    */         }
/*    */       }
/*    */       
/* 69 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.org_icon));
/*    */       
/* 71 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.suit_icon));
/*    */       
/* 73 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.suit_light_effect));
/*    */       
/* 75 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.special_icon));
/*    */     }
/*    */     
/*    */ 
/*    */ 
/*    */ 
/* 81 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));
/* 82 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 87 */     return 65019;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M64995_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */