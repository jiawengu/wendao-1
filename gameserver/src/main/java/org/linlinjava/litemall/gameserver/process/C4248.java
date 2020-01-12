/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */
/*    */ import org.linlinjava.litemall.db.domain.Characters;
/*    */
/*    */ import org.linlinjava.litemall.db.util.JSONUtils;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65505_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR;
import org.linlinjava.litemall.gameserver.data.write.MSG_TITLE;
/*    */
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */

/**
 * CMD_SHIFT
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class C4248 implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 25 */     int id = GameReadTool.readInt(buff);
/* 26 */     int x = GameReadTool.readShort(buff);
/* 27 */     int y = GameReadTool.readShort(buff);
/* 28 */     int taskwalk = GameReadTool.readShort(buff);
/* 29 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/* 30 */     Characters characters = GameData.that.characterService.findOneByID(id);
/* 31 */     String data = characters.getData();
/* 32 */     Chara chara1 = (Chara)JSONUtils.parseObject(data, Chara.class);
/* 33 */     chara1.x = chara.x;
/* 34 */     chara1.y = chara.y;
/* 35 */     chara1.mapid = chara.mapid;
/* 36 */     chara1.mapName = chara.mapName;
/*    */     
/* 38 */     org.linlinjava.litemall.gameserver.game.GameLine.getGameMap(chara.line, chara.mapName).joinduiyuan(org.linlinjava.litemall.gameserver.game.GameObjectCharMng.getGameObjectChar(chara1.id), chara);
/*    */     
/* 40 */     for (int i = 0; i < chara.npcchubao.size(); i++) {
/* 41 */       if (chara1.mapid == ((Vo_65529_0)chara.npcchubao.get(i)).mapid) {
/* 42 */         GameObjectChar.sendduiwu(new MSG_APPEAR(), chara.npcchubao.get(i), chara.id);
/*    */       }
/*    */     }
/*    */     
/* 46 */     for (int i = 0; i < chara.npcshuadao.size(); i++) {
/* 47 */       if (chara1.mapid == ((Vo_65529_0)chara.npcshuadao.get(i)).mapid) {
/* 48 */         GameObjectChar.sendduiwu(new MSG_APPEAR(), chara.npcshuadao.get(i), chara.id);
/*    */       }
/*    */     }
/*    */     
/*    */ 
/*    */ 
/* 54 */     Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/* 55 */     vo_61671_0.id = chara1.id;
/* 56 */     vo_61671_0.count = 2;
/* 57 */     vo_61671_0.list.add(Integer.valueOf(2));
/* 58 */     vo_61671_0.list.add(Integer.valueOf(5));
/* 59 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/* 60 */     vo_61671_0 = new Vo_61671_0();
/* 61 */     vo_61671_0.id = chara.id;
/* 62 */     vo_61671_0.count = 2;
/* 63 */     vo_61671_0.list.add(Integer.valueOf(2));
/* 64 */     vo_61671_0.list.add(Integer.valueOf(3));
/* 65 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/*    */   }
/*    */   
/*    */   public Vo_65505_0 a65505(Chara chara)
/*    */   {
/* 70 */     Vo_65505_0 vo_65505_1 = new Vo_65505_0();
/* 71 */     vo_65505_1.map_id = chara.mapid;
/* 72 */     vo_65505_1.map_name = GameData.that.baseMapService.findOneByMapId(Integer.valueOf(chara.mapid)).getName();
/* 73 */     vo_65505_1.map_show_name = vo_65505_1.map_name;
/* 74 */     vo_65505_1.x = chara.x;
/* 75 */     vo_65505_1.y = chara.y;
/* 76 */     vo_65505_1.map_index = 50331648;
/* 77 */     vo_65505_1.compact_map_index = 49408;
/* 78 */     vo_65505_1.floor_index = 0;
/* 79 */     vo_65505_1.wall_index = 0;
/* 80 */     vo_65505_1.is_safe_zone = 0;
/* 81 */     vo_65505_1.is_task_walk = 0;
/* 82 */     vo_65505_1.enter_effect_index = 0;
/* 83 */     return vo_65505_1;
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 88 */     return 4248;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4248.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */