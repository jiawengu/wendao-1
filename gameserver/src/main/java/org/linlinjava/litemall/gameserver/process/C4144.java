/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.db.domain.NpcPoint;
/*    */ import org.linlinjava.litemall.db.service.base.BaseNpcPointService;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65505_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.linlinjava.litemall.gameserver.game.GameLine;
/*    */ import org.linlinjava.litemall.gameserver.game.GameMap;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */

/**
 * CMD_ENTER_ROOM
 */
/*    */ @Service
/*    */ public class C4144
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 25 */     String room_name = GameReadTool.readString(buff);
/*    */     
/* 27 */     int isTaskWalk = GameReadTool.readByte(buff);
/* 28 */     GameObjectChar session = GameObjectChar.getGameObjectChar();
/* 29 */     Chara chara = session.chara;
/* 30 */     GameMap gameMap = GameLine.getGameMap(chara.line, room_name);
/*    */     
/* 32 */     if (!chara.mapName.equals(room_name)) {
/* 33 */       List<NpcPoint> list = GameData.that.baseNpcPointService.findByMapname(room_name);
/* 34 */       for (NpcPoint npcPoint : list) {
/* 35 */         if (npcPoint.getDoorname().equals(chara.mapName)) {
/* 36 */           chara.x = npcPoint.getInx().intValue();
/* 37 */           chara.y = npcPoint.getIny().intValue();
/*    */         }
/*    */       }
/*    */     }
/* 41 */     gameMap.join(session);
/*    */   }
/*    */   
/*    */   public Vo_65505_0 a65505(Chara chara) {
/* 45 */     Vo_65505_0 vo_65505_1 = new Vo_65505_0();
/* 46 */     vo_65505_1.map_id = chara.mapid;
/* 47 */     vo_65505_1.map_name = chara.mapName;
/* 48 */     vo_65505_1.map_show_name = chara.mapName;
/* 49 */     vo_65505_1.x = chara.x;
/* 50 */     vo_65505_1.y = chara.y;
/* 51 */     vo_65505_1.map_index = 50331648;
/* 52 */     vo_65505_1.compact_map_index = 49408;
/* 53 */     vo_65505_1.floor_index = 0;
/* 54 */     vo_65505_1.wall_index = 0;
/* 55 */     vo_65505_1.is_safe_zone = 0;
/* 56 */     vo_65505_1.is_task_walk = 0;
/* 57 */     vo_65505_1.enter_effect_index = 0;
/* 58 */     return vo_65505_1;
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 63 */     return 4144;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4144.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */