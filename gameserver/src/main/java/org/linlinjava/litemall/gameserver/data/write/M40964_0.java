/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M40964_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_40964_0 object1 = (Vo_40964_0)object;
/* 14 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.type));
/*    */     
/* 16 */     GameWriteTool.writeString(writeBuf, object1.name);
/*    */     
/* 18 */     GameWriteTool.writeString(writeBuf, object1.param);
/*    */     
/* 20 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.rightNow));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 25 */     return 40964;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M40964_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */