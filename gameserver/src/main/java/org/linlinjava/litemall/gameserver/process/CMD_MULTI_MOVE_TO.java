/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_16431_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40981_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M16431_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M40981_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.fight.FightMove;
/*    */ import org.linlinjava.litemall.gameserver.game.GameMap;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.linlinjava.litemall.gameserver.game.GameTeam;
/*    */

/**
 * CMD_MULTI_MOVE_TO
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class CMD_MULTI_MOVE_TO implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 23 */     int id = GameReadTool.readInt(buff);
/*    */     
/* 25 */     int map_id = GameReadTool.readInt(buff);
/*    */     
/* 27 */     int map_index = GameReadTool.readInt(buff);
/*    */     
/* 29 */     int count = GameReadTool.readShort(buff);
/*    */     
/* 31 */     int x = 0;
/* 32 */     int y = 0;
/* 33 */     for (int i = 0; i < count; i++)
/*    */     {
/* 35 */       x = GameReadTool.readShort(buff);
/*    */       
/* 37 */       y = GameReadTool.readShort(buff);
/*    */     }
/*    */     
/*    */
//    System.out.println("x:"+x+",y:"+y);
/*    */ 
/* 42 */     int dir = GameReadTool.readShort(buff);
/*    */     
/* 44 */     int send_time = GameReadTool.readInt(buff);
/* 45 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 47 */     if ((GameObjectChar.getGameObjectChar().gameTeam != null) && (GameObjectChar.getGameObjectChar().gameTeam.duiwu != null) && (GameObjectChar.getGameObjectChar().gameTeam.duiwu.size() > 0)) {
/* 48 */       for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.duiwu.size(); i++) {
/* 49 */         Chara chara1 = (Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i);
/* 50 */         chara1.x = x;
/* 51 */         chara1.y = y;
/*    */       }
/*    */     } else {
/* 54 */       GameObjectChar.getGameObjectChar().chara.x = x;
/* 55 */       GameObjectChar.getGameObjectChar().chara.y = y;
/*    */     }
/*    */     
/*    */ 
/*    */ 
/* 60 */     Vo_16431_0 vo_16431_0 = new Vo_16431_0();
/* 61 */     vo_16431_0.id = id;
/* 62 */     vo_16431_0.x = x;
/* 63 */     vo_16431_0.y = y;
/* 64 */     GameObjectChar.getGameObjectChar().gameMap.send(new M16431_0(), vo_16431_0);
/* 65 */     if ((chara.qumoxiang != 1) && 
/* 66 */       (FightMove.move(chara.id))) {
/* 67 */       org.linlinjava.litemall.gameserver.fight.FightManager.goFight(GameObjectChar.getGameObjectChar().chara, GameObjectChar.getGameObjectChar().chara.mapName);
/* 68 */       return;
/*    */     }
/*    */     
/*    */ 
/* 72 */     if ((chara.changbaotu.mapid == chara.mapid) && (chara.changbaotu.x == chara.x) && (chara.changbaotu.y == y)) {
/* 73 */       Vo_40981_0 vo_40981_0 = new Vo_40981_0();
/* 74 */       vo_40981_0.start_time = ((int)(System.currentTimeMillis() / 1000L));
/* 75 */       vo_40981_0.end_time = ((int)(System.currentTimeMillis() / 1000L) + 3);
/* 76 */       vo_40981_0.icon = 258;
/* 77 */       vo_40981_0.word = "挖宝中…";
/* 78 */       vo_40981_0.gather_style = "default";
/* 79 */       GameObjectChar.getGameObjectChar();GameObjectChar.send(new M40981_0(), vo_40981_0);
/* 80 */       chara.changbaotu = new Vo_65529_0();
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 87 */     return 61634;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\CMD_MULTI_MOVE_TO.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */