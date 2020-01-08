/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65505_0;
/*    */

/**
 * MSG_ENTER_ROOM
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_ENTER_ROOM extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_65505_0 object1 = (Vo_65505_0)object;
/* 13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.map_id));
/*    */     
/* 15 */     GameWriteTool.writeString(writeBuf, object1.map_name);
/*    */     
/* 17 */     GameWriteTool.writeString(writeBuf, object1.map_show_name);
/*    */     
/* 19 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.x));
/*    */     
/* 21 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.y));
/*    */     
/* 23 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.map_index));
/*    */     
/* 25 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.compact_map_index));
/*    */     
/* 27 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.floor_index));
/*    */     
/* 29 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.wall_index));
/*    */     
/* 31 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.is_safe_zone));
/*    */     
/* 33 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.is_task_walk));
/*    */     
/* 35 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.enter_effect_index));
/*    */   }
/*    */   
/* 38 */   public int cmd() { return 65505; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\MSG_ENTER_ROOM.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */