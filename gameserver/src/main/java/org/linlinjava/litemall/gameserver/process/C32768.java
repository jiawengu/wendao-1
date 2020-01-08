/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */
/*     */ import org.linlinjava.litemall.db.domain.Renwu;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65505_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR;
import org.linlinjava.litemall.gameserver.data.write.MSG_TASK_PROMPT;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_TITLE;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_APPEARANCE;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameLine;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */
/*     */

/**
 * CMD_TELEPORT 传送
 */
/*     */ @org.springframework.stereotype.Service
/*     */ public class C32768 implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(io.netty.channel.ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  25 */     int mapid = GameReadTool.readInt(buff);
/*  26 */     int x = GameReadTool.readInt(buff);
/*  27 */     int y = GameReadTool.readInt(buff);
/*  28 */     int taskwalk = GameReadTool.readByte(buff);
/*  29 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*  30 */     chara.x = x;
/*  31 */     chara.y = y;
/*  32 */     String[] shidaolevel = { "试道场(60-79)", "试道场(80-89)", "试道场(90-99)", "试道场(100-109)", "试道场(110-119)", "试道场(120-129)" };
/*  33 */     if (chara.mapid == 38004) {
/*  34 */       chara.shidaocishu = 0;
/*  35 */       chara.shidaodaguaijifen = 0;
/*     */     }
/*  37 */     if (mapid == 38004) {
/*  38 */       return;
/*     */     }
/*  40 */     GameLine.getGameMap(chara.line, mapid).join(GameObjectChar.getGameObjectChar());
/*     */     
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*  46 */     for (int i = 0; i < GameLine.gameShuaGuai.shuaXing.size(); i++) {
/*  47 */       if (((Vo_65529_0)GameLine.gameShuaGuai.shuaXing.get(i)).mapid == mapid) {
/*  48 */         GameObjectChar.sendduiwu(new MSG_APPEAR(), GameLine.gameShuaGuai.shuaXing.get(i), chara.id);
/*     */       }
/*     */     }
/*     */     
/*     */ 
/*  53 */     for (int i = 0; i < chara.npcchubao.size(); i++) {
/*  54 */       if (mapid == ((Vo_65529_0)chara.npcchubao.get(i)).mapid) {
/*  55 */         GameObjectChar.sendduiwu(new MSG_APPEAR(), chara.npcchubao.get(i), chara.id);
/*     */       }
/*     */     }
/*     */     
/*  59 */     for (int i = 0; i < chara.npcshuadao.size(); i++) {
/*  60 */       if (mapid == ((Vo_65529_0)chara.npcshuadao.get(i)).mapid) {
/*  61 */         GameObjectChar.sendduiwu(new MSG_APPEAR(), chara.npcshuadao.get(i), chara.id);
/*     */       }
/*     */     }
/*     */     
/*  65 */     for (int i = 0; i < chara.npcxuanshang.size(); i++) {
/*  66 */       if (mapid == ((Vo_65529_0)chara.npcxuanshang.get(i)).mapid) {
/*  67 */         GameObjectChar.sendduiwu(new MSG_APPEAR(), chara.npcxuanshang.get(i), chara.id);
/*     */       }
/*     */     }
/*     */     
/*     */ 
/*  72 */     if ((chara.current_task.equals("主线—浮生若梦_s19")) && (mapid == 5000)) {
/*  73 */       GameUtil.renwujiangli(chara);
/*  74 */       chara.current_task = GameUtil.nextrenw(chara.current_task);
/*  75 */       Renwu tasks = GameData.that.baseRenwuService.findOneByCurrentTask(chara.current_task);
/*     */       
/*     */ 
/*  78 */       org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0 vo_61553_0 = GameUtil.a61553(tasks, chara);
/*  79 */       GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);
/*     */     }
/*  81 */     if ((chara.current_task.equals("主线—浮生若梦_s21")) && ((mapid == 10000) || (mapid == 14000) || (mapid == 15000) || (mapid == 13000) || (mapid == 16000))) {
/*  82 */       GameUtil.renwujiangli(chara);
/*  83 */       chara.current_task = GameUtil.nextrenw(chara.current_task);
/*  84 */       Renwu tasks = GameData.that.baseRenwuService.findOneByCurrentTask(chara.current_task);
/*     */       
/*     */ 
/*  87 */       org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0 vo_61553_0 = GameUtil.a61553(tasks, chara);
/*  88 */       GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);
/*     */     }
/*     */     
/*     */ 
/*  92 */     org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
/*  93 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*  94 */     if ((GameObjectChar.getGameObjectChar().gameTeam != null) && (GameObjectChar.getGameObjectChar().gameTeam.duiwu.size() > 0) && 
/*  95 */       (((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(0)).id == chara.id)) {
/*  96 */       Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/*  97 */       vo_61671_0.id = chara.id;
/*  98 */       vo_61671_0.count = 2;
/*  99 */       vo_61671_0.list.add(Integer.valueOf(2));
/* 100 */       vo_61671_0.list.add(Integer.valueOf(3));
/* 101 */       GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/*     */     }
/*     */     
/*     */ 
/* 105 */     GameUtil.genchongfei(chara);
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */   public Vo_65505_0 a65505(Chara chara)
/*     */   {
/* 112 */     Vo_65505_0 vo_65505_1 = new Vo_65505_0();
/* 113 */     vo_65505_1.map_id = chara.mapid;
/* 114 */     vo_65505_1.map_name = GameData.that.baseMapService.findOneByMapId(Integer.valueOf(chara.mapid)).getName();
/* 115 */     vo_65505_1.map_show_name = vo_65505_1.map_name;
/* 116 */     vo_65505_1.x = chara.x;
/* 117 */     vo_65505_1.y = chara.y;
/* 118 */     vo_65505_1.map_index = 50331648;
/* 119 */     vo_65505_1.compact_map_index = 49408;
/* 120 */     vo_65505_1.floor_index = 0;
/* 121 */     vo_65505_1.wall_index = 0;
/* 122 */     vo_65505_1.is_safe_zone = 0;
/* 123 */     vo_65505_1.is_task_walk = 0;
/* 124 */     vo_65505_1.enter_effect_index = 0;
/* 125 */     return vo_65505_1;
/*     */   }
/*     */   
/*     */   public int cmd()
/*     */   {
/* 130 */     return 32768;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C32768.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */