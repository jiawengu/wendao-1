/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_36871_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M36871_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_36871_0 object1 = (Vo_36871_0)object;
/* 13 */     GameWriteTool.writeString(writeBuf, object1.msg_type);
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.icon));
/*    */     
/* 17 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 19 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.level));
/*    */     
/* 21 */     GameWriteTool.writeString(writeBuf, object1.gid);
/*    */     
/* 23 */     GameWriteTool.writeString(writeBuf, object1.name);
/*    */     
/* 25 */     GameWriteTool.writeString(writeBuf, object1.party);
/*    */     
/* 27 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.friend_score));
/*    */     
/* 29 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.setting_flag));
/*    */     
/* 31 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.char_status));
/*    */     
/* 33 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.vip));
/*    */     
/* 35 */     GameWriteTool.writeString(writeBuf, object1.serverId);
/*    */     
/* 37 */     GameWriteTool.writeString(writeBuf, object1.account);
/*    */     
/* 39 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.polar));
/*    */     
/* 41 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isInThereFrend));
/*    */     
/* 43 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.ringScore));
/*    */     
/* 45 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.comeback_flag));
/*    */   }
/*    */   
/* 48 */   public int cmd() { return 36871; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M36871_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */