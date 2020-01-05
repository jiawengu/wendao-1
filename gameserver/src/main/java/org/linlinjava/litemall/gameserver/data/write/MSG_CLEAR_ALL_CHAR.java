/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45157_0;
/*    */

/**
 * "MSG_CLEAR_ALL_CHAR", -- 清除所有的玩家
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_CLEAR_ALL_CHAR extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_45157_0 object1 = (Vo_45157_0)object;
/* 13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.mapId));
/*    */   }
/*    */   
/* 18 */   public int cmd() { return 45157; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\MSG_CLEAR_ALL_CHAR.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */