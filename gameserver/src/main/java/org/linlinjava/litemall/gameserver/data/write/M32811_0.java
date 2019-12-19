/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_32811_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M32811_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_32811_0 object1 = (Vo_32811_0)object;
/* 13 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.size));
/*    */     
/* 15 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.max_size));
/*    */     
/* 17 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.top_size));
/*    */   }
/*    */   
/* 20 */   public int cmd() { return 32811; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M32811_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */