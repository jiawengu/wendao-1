/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */
/*    */ import java.util.Map.Entry;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_APPEARANCE;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class C4288_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 21 */     String select = GameReadTool.readString(buff);
/*    */     
/* 23 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/* 24 */     boolean haschenhao = false;
/* 25 */     for (Entry<String, String> entry : chara.chenghao.entrySet()) {
/* 26 */       if (((String)entry.getKey()).equals(select)) {
/* 27 */         chara.chenhao = ((String)entry.getValue());
/* 28 */         haschenhao = true;
/*    */       }
/*    */     }
/* 31 */     if (!haschenhao) {
/* 32 */       chara.chenhao = "";
/*    */     }
/* 34 */     ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 35 */     GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*    */     
/* 37 */     Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
/* 38 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 43 */     return 4288;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4288_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */