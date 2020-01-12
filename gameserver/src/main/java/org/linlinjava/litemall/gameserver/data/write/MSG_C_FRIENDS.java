/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.io.PrintStream;
/*    */ import java.util.HashMap;
/*    */ import java.util.Iterator;
/*    */ import java.util.List;
/*    */ import java.util.Map;
/*    */ import java.util.Map.Entry;
/*    */ import java.util.Set;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.UtilObjMap;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65017_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */

/**
 * MSG_C_FRIENDS
 */

/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_C_FRIENDS extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 22 */     List<Vo_65017_0> obj = (List)object;
/* 23 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(obj.size()));
/* 24 */     for (int i = 0; i < obj.size(); i++) {
/* 25 */       Vo_65017_0 object1 = (Vo_65017_0)obj.get(i);
/*    */       
/* 27 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */       
/* 29 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.leader));
/*    */       
/* 31 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.weapon_icon));
/*    */       
/* 33 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.pos));
/*    */       
/* 35 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.rank));
/*    */       
/* 37 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.vip_type));
/*    */       
/*    */ 
/* 40 */       Map<Object, Object> map = new HashMap();
/* 41 */       map = UtilObjMap.Vo_65019_0(object1);
/*    */       
/* 43 */       map.remove("id");
/* 44 */       map.remove("leader");
/* 45 */       map.remove("weapon_icon");
/* 46 */       map.remove("pos");
/* 47 */       map.remove("rank");
/* 48 */       map.remove("vip_type");
/* 49 */       map.remove("org_icon");
/* 50 */       map.remove("suit_icon");
/* 51 */       map.remove("suit_light_effect");
/* 52 */       map.remove("special_icon");
/*    */       
/* 54 */       Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*    */       
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/* 62 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 63 */       for (Entry<Object, Object> entry : map.entrySet()) {
/* 64 */         if (BuildFields.data.get((String)entry.getKey()) != null) {
/* 65 */           BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
/*    */         } else {
/* 67 */           System.out.println(entry.getKey());
/*    */         }
/*    */       }
/*    */       
/* 71 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.org_icon));
/*    */       
/* 73 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.suit_icon));
/*    */       
/* 75 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.suit_light_effect));
/*    */       
/* 77 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.special_icon));
/*    */     }
/*    */     
/*    */ 
/*    */ 
/*    */ 
/* 83 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));
/* 84 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 89 */     return 65019;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M65019_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */