/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8711_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_C_FLEE extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_8711_0 object1 = (Vo_8711_0)object;
/* 13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 15 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.success));
/*    */     
/* 17 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.die));
/*    */   }
/*    */   
/* 20 */   public int cmd() { return 8711; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M8711_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */