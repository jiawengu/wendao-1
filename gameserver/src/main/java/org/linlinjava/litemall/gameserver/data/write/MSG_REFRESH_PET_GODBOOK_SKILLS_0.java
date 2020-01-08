/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_12023_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */

/**
 * MSG_REFRESH_PET_GODBOOK_SKILLS
 */
/*    */ @Service
/*    */ public class MSG_REFRESH_PET_GODBOOK_SKILLS_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 15 */     List<Vo_12023_0> object1 = (List)object;
/* 16 */     if (object1.size() > 0) {
/* 17 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(((Vo_12023_0)object1.get(0)).owner_id));
/*    */       
/* 19 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(((Vo_12023_0)object1.get(0)).id));
/*    */       
/* 21 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.size()));
/* 22 */       for (int i = 0; i < object1.size(); i++) {
/* 23 */         Vo_12023_0 vo_12023_0 = (Vo_12023_0)object1.get(i);
/*    */         
/* 25 */         GameWriteTool.writeString(writeBuf, vo_12023_0.god_book_skill_name);
/*    */         
/* 27 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_12023_0.god_book_skill_level));
/*    */         
/* 29 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_12023_0.god_book_skill_power));
/*    */         
/* 31 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(vo_12023_0.god_book_skill_disabled));
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 39 */     return 12023;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M12023_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */