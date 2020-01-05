/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.db.domain.NpcPoint;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */

/**
 * MSG_EXITS
 */
/*    */ @Service
/*    */ public class MSG_EXITS
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 16 */     List<NpcPoint> list = (List)object;
/*    */     
/* 18 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(1));
/*    */     
/* 20 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(list.size()));
/* 21 */     for (NpcPoint npcPoint : list)
/*    */     {
/* 23 */       GameWriteTool.writeString(writeBuf, npcPoint.getDoorname());
/*    */       
/* 25 */       GameWriteTool.writeShort(writeBuf, npcPoint.getX());
/*    */       
/* 27 */       GameWriteTool.writeShort(writeBuf, npcPoint.getY());
/*    */       
/* 29 */       GameWriteTool.writeShort(writeBuf, npcPoint.getZ());
/*    */     }
/*    */   }
/*    */   
/* 33 */   public int cmd() { return 65531; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\MSG_EXITS.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */