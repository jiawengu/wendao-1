/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49171_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class M49171_0
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 16 */     List<Vo_49171_0> object1 = (List)object;
/* 17 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.size()));
/* 18 */     for (int i = 0; i < object1.size(); i++) {
/* 19 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(((Vo_49171_0)object1.get(i)).isGot));
/* 20 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(((Vo_49171_0)object1.get(i)).limitLevel));
/* 21 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(((Vo_49171_0)object1.get(i)).vo491710s.size()));
/* 22 */       for (int j = 0; j < ((Vo_49171_0)object1.get(i)).vo491710s.size(); j++) {
/* 23 */         GameWriteTool.writeString(writeBuf, ((Vo_49171_0)((Vo_49171_0)object1.get(i)).vo491710s.get(j)).name);
/* 24 */         GameWriteTool.writeInt(writeBuf, Integer.valueOf(((Vo_49171_0)((Vo_49171_0)object1.get(i)).vo491710s.get(j)).number));
/* 25 */         GameWriteTool.writeInt(writeBuf, Integer.valueOf(((Vo_49171_0)((Vo_49171_0)object1.get(i)).vo491710s.get(j)).level));
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 32 */     return 49171;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M49171_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */