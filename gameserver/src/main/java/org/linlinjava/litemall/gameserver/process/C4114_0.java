/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */
/*    */ import org.linlinjava.litemall.db.domain.Characters;
/*    */
/*    */ import org.linlinjava.litemall.db.util.JSONUtils;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*    */
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C4114_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 23 */     int victim_id = GameReadTool.readInt(buff);
/*    */     
/* 25 */     int flag = GameReadTool.readShort(buff);
/*    */     
/* 27 */     String gid = GameReadTool.readString(buff);
/*    */     
/* 29 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 31 */     Characters characters = GameData.that.characterService.finOnByGiD(gid);
/* 32 */     Chara chara1 = (Chara)JSONUtils.parseObject(characters.getData(), Chara.class);
/*    */     
/* 34 */     if ((GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam != null) && (GameObjectChar.getGameObjectChar().gameTeam != null) && (GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu != null) && (GameObjectChar.getGameObjectChar().gameTeam.duiwu != null) && 
/* 35 */       (((Chara)GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.get(0)).id == ((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(0)).id)) {
/* 36 */       return;
/*    */     }
/*    */     
/*    */ 
/*    */ 
/*    */ 
/* 42 */     Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 43 */     vo_20481_0.msg = "你进入切磋战斗中！";
/* 44 */     vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
/* 45 */     GameObjectChar.getGameObjectChar();GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*    */     
/*    */ 
/* 48 */     org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara, chara1);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 53 */     return 4114;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4114_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */