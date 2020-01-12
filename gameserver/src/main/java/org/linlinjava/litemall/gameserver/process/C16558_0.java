/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_16429_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_16431_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M16429_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M16431_0;
/*    */ import org.linlinjava.litemall.gameserver.game.GameMap;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */

/**
 * CMD_OTHER_MOVE_TO
 */
/*    */ @Service
/*    */ public class C16558_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 19 */     int id = GameReadTool.readInt(buff);
/*    */     
/* 21 */     int map_id = GameReadTool.readInt(buff);
/*    */     
/* 23 */     int x = GameReadTool.readShort(buff);
/*    */     
/* 25 */     int y = GameReadTool.readShort(buff);
/*    */     
/* 27 */     int dir = GameReadTool.readShort(buff);
/*    */     
/*    */ 
/*    */ 
/* 31 */     GameObjectChar.getGameObjectChar().chara.x = x;
/* 32 */     GameObjectChar.getGameObjectChar().chara.y = y;
/*    */     
/*    */ 
/* 35 */     Vo_16429_0 vo_16429_0 = new Vo_16429_0();
/* 36 */     vo_16429_0.id = id;
/* 37 */     vo_16429_0.x = x;
/* 38 */     vo_16429_0.y = y;
/* 39 */     vo_16429_0.map_id = map_id;
/* 40 */     GameObjectChar.getGameObjectChar().gameMap.send(new M16429_0(), vo_16429_0);
/*    */     
/* 42 */     Vo_16431_0 vo_16431_0 = new Vo_16431_0();
/* 43 */     vo_16431_0.id = id;
/* 44 */     vo_16431_0.x = x;
/* 45 */     vo_16431_0.y = y;
/* 46 */     GameObjectChar.getGameObjectChar().gameMap.send(new M16431_0(), vo_16431_0);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 51 */     return 16558;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C16558_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */