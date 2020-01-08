/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */

/**
 * MSG_TITLE
 */
/*    */ @Service
/*    */ public class MSG_TITLE
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 16 */     Vo_61671_0 object1 = (Vo_61671_0)object;
/* 17 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 19 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.count));
/* 20 */     for (int i = 0; i < object1.count; i++) {
/* 21 */       GameWriteTool.writeByte(writeBuf, (Integer)object1.list.get(i));
/*    */     }
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 27 */     return 61671;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M61671_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */