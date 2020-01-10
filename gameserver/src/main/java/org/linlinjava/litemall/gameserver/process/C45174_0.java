/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.db.domain.Characters;
/*    */
/*    */ import org.linlinjava.litemall.db.util.JSONUtils;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M45185_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M8165_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C45174_0 implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 26 */     String type = GameReadTool.readString(buff);
/*    */     
/* 28 */     String para = GameReadTool.readString(buff);
/*    */     
/*    */ 
/* 31 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/* 32 */     if ("team".equals(type)) {
/* 33 */       Characters characters = GameData.that.characterService.finOnByGiD(para);
/* 34 */       String data = characters.getData();
/* 35 */       Chara chara1 = (Chara)JSONUtils.parseObject(data, Chara.class);
/*    */       
/* 37 */       Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 38 */       vo_8165_0.msg = ("已向#Y" + chara.name + "#n发送震动提醒。");
/* 39 */       vo_8165_0.active = 0;
/* 40 */       GameObjectChar.send(new M8165_0(), vo_8165_0);
/*    */       
/* 42 */       Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 43 */       vo_20481_0.msg = (chara.name + "在队伍中向你发送了一次震动提醒");
/* 44 */       vo_20481_0.time = 1562987118;
/* 45 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*    */       
/* 47 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M45185_0(), "");
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 56 */     return 45174;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C45174_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */