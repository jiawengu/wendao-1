/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_15857_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_C_LIFE_DELTA extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_15857_0 object1 = (Vo_15857_0)object;
/* 13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.hitter_id));
/*    */     
/* 17 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.point));
/*    */     
/* 19 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.effect_no));
/*    */     
/* 21 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.damage_type));
/*    */   }
/*    */   
/* 24 */   public int cmd() { return 15857; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M15857_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */