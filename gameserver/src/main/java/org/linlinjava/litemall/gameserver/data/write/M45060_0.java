/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45060_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */

/**
 * MSG_SHUADAO_REFRESH
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class M45060_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_45060_0 object1 = (Vo_45060_0)object;
/* 14 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.hasBonus));
/*    */     
/* 16 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.xy_higest));
/*    */     
/* 18 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.fm_higest));
/*    */     
/* 20 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.fx_higest));
/*    */     
/* 22 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.off_line_time));
/*    */     
/* 24 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.buy_one));
/*    */     
/* 26 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.buy_five));
/*    */     
/* 28 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.buy_time));
/*    */     
/* 30 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.max_buy_time));
/*    */     
/* 32 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.offlineStatus));
/*    */     
/* 34 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.max_turn));
/*    */     
/* 36 */     GameWriteTool.writeString(writeBuf, object1.lastTaskName);
/*    */     
/* 38 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.max_double));
/*    */     
/* 40 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.max_jiji));
/*    */     
/* 42 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.jijiStatus));
/*    */     
/* 44 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.chongfengsan_time));
/*    */     
/* 46 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.max_chongfengsan_time));
/*    */     
/* 48 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.ziqihongmeng_time));
/*    */     
/* 50 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.max_ziqihongmeng_time));
/*    */     
/* 52 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.max_chongfengsan));
/*    */     
/* 54 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.chongfengsan_status));
/*    */     
/* 56 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.max_ziqihongmeng));
/*    */     
/* 58 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.ziqihongmeng_status));
/*    */     
/* 60 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.hasDaofaBonus));
/*    */     
/* 62 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count));
/*    */     
/* 64 */     GameWriteTool.writeString(writeBuf, object1.taskName);
/*    */     
/* 66 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.taskTime));
/*    */     
/* 68 */     GameWriteTool.writeString(writeBuf, object1.taskName1);
/*    */     
/* 70 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.taskTime1));
/*    */     
/* 72 */     GameWriteTool.writeString(writeBuf, object1.taskName2);
/*    */     
/* 74 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.taskTime2));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 79 */     return 45060;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M45060_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */