/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */

/**
 * MSG_TASK_PROMPT  任务提示
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class M61553_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_61553_0 object1 = (Vo_61553_0)object;
/* 14 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count));
/* 15 */     for (int i = 0; i < object1.count; i++)
/*    */     {
/* 17 */       GameWriteTool.writeString(writeBuf, object1.task_type);
/*    */       
/* 19 */       GameWriteTool.writeString2(writeBuf, object1.task_desc);
/*    */       
/* 21 */       GameWriteTool.writeString2(writeBuf, object1.task_prompt);
/*    */       
/* 23 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.refresh));
/*    */       
/* 25 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.task_end_time));
/*    */       
/* 27 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.attrib));
/*    */       
/* 29 */       GameWriteTool.writeString2(writeBuf, object1.reward);
/*    */       
/* 31 */       GameWriteTool.writeString(writeBuf, object1.show_name);
/*    */       
/* 33 */       GameWriteTool.writeString(writeBuf, object1.tasktask_extra_para);
/*    */       
/* 35 */       GameWriteTool.writeString(writeBuf, object1.tasktask_state);
/*    */     }
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 41 */     return 61553;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M61553_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */