/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_12023_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class MSG_REFRESH_PET_GODBOOK_SKILLS_1
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 15 */     Vo_12023_0 object1 = (Vo_12023_0)object;
/*    */     
/* 17 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.owner_id));
/*    */     
/* 19 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/* 20 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(0));
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 27 */     return 12023;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M12023_1.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */