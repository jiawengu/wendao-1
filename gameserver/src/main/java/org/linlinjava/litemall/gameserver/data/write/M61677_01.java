/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.HashMap;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ @Service
/*    */ public class M61677_01
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 21 */     Vo_61677_0 object1 = (Vo_61677_0)object;
/* 22 */     GameWriteTool.writeString(writeBuf, object1.store_type);
/*    */     
/* 24 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.npcID));
/*    */     
/*    */ 
/* 27 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(1));
/*    */     
/* 29 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isGoon));
/* 30 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.pos));
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 37 */     return 61677;
/*    */   }
/*    */   
/*    */   public boolean weizhi(List<Goods> list, int j) {
/* 41 */     HashMap<Object, Object> map = new HashMap();
/* 42 */     for (int i = 0; i < list.size(); i++) {
/* 43 */       map.put(Integer.valueOf(((Goods)list.get(i)).pos), Integer.valueOf(((Goods)list.get(i)).pos));
/*    */     }
/* 45 */     if (map.get(Integer.valueOf(j)) == null) {
/* 46 */       return true;
/*    */     }
/* 48 */     return false;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M61677_01.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */