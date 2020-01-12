/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20568_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61593_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_TITLE;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*    */ import org.linlinjava.litemall.gameserver.game.GameTeam;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class C30_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 23 */     String new_leader_id = GameReadTool.readString(buff);
/*    */     
/* 25 */     int type = GameReadTool.readByte(buff);
/*    */     
/* 27 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/* 28 */     GameTeam gameTeam = GameObjectChar.getGameObjectChar().gameTeam;
/*    */     
/* 30 */     Vo_61593_0 vo_61593_0 = new Vo_61593_0();
/* 31 */     vo_61593_0.ask_type = "request_join";
/* 32 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61593_0(), vo_61593_0);
/* 33 */     vo_61593_0 = new Vo_61593_0();
/* 34 */     vo_61593_0.ask_type = "request_team_leader";
/* 35 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61593_0(), vo_61593_0);
/*    */     
/* 37 */     Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/* 38 */     vo_61671_0.id = Integer.parseInt(new_leader_id);
/* 39 */     vo_61671_0.count = 2;
/* 40 */     vo_61671_0.list.add(Integer.valueOf(2));
/* 41 */     vo_61671_0.list.add(Integer.valueOf(3));
/* 42 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/* 43 */     vo_61671_0 = new Vo_61671_0();
/* 44 */     vo_61671_0.id = chara.id;
/* 45 */     vo_61671_0.count = 2;
/* 46 */     vo_61671_0.list.add(Integer.valueOf(2));
/* 47 */     vo_61671_0.list.add(Integer.valueOf(5));
/* 48 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/* 49 */     int index = 0;
/* 50 */     for (int i = 0; i < gameTeam.duiwu.size(); i++) {
/* 51 */       if (((Chara)gameTeam.duiwu.get(i)).id == Integer.parseInt(new_leader_id)) {
/* 52 */         index = i;
/*    */       }
/*    */     }
/*    */     
/* 56 */     for (int i = 0; i < gameTeam.duiwu.size(); i++) {
/* 57 */       GameObjectCharMng.getGameObjectChar(((Chara)gameTeam.duiwu.get(i)).id).gameTeam.duiwu.set(index, chara);
/* 58 */       GameObjectCharMng.getGameObjectChar(((Chara)gameTeam.duiwu.get(i)).id).gameTeam.duiwu.set(0, GameObjectCharMng.getGameObjectChar(Integer.parseInt(new_leader_id)).chara);
/* 59 */       if (i != index) {
/* 60 */         Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 61 */         vo_20481_0.msg = (((Chara)gameTeam.duiwu.get(0)).name + "成为队长。");
/* 62 */         vo_20481_0.time = 1562987118;
/* 63 */         GameObjectChar.getGameObjectChar();GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*    */       }
/*    */     }
/* 66 */     Vo_4121_0 vo_4121_0 = (Vo_4121_0)gameTeam.zhanliduiyuan.get(0);
/* 67 */     Vo_4121_0 vo_4121_1 = (Vo_4121_0)gameTeam.zhanliduiyuan.get(index);
/* 68 */     for (int i = 0; i < gameTeam.zhanliduiyuan.size(); i++) {
/* 69 */       GameObjectCharMng.getGameObjectChar(((Vo_4121_0)gameTeam.zhanliduiyuan.get(i)).id).gameTeam.zhanliduiyuan.set(0, vo_4121_1);
/* 70 */       GameObjectCharMng.getGameObjectChar(((Vo_4121_0)gameTeam.zhanliduiyuan.get(i)).id).gameTeam.zhanliduiyuan.set(index, vo_4121_0);
/*    */     }
/* 72 */     Vo_20568_0 vo_20568_0 = new Vo_20568_0();
/* 73 */     vo_20568_0.gid = "";
/* 74 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M20568_0(), vo_20568_0);
/* 75 */     vo_20568_0 = new Vo_20568_0();
/* 76 */     vo_20568_0.gid = "";
/* 77 */     GameObjectCharMng.getGameObjectChar(Integer.parseInt(new_leader_id)).sendOne(new org.linlinjava.litemall.gameserver.data.write.M20568_0(), vo_20568_0);
/* 78 */     Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 79 */     vo_20481_0.msg = "你被提升为队长。";
/* 80 */     vo_20481_0.time = 1562987118;
/* 81 */     GameObjectCharMng.getGameObjectChar(Integer.parseInt(new_leader_id)).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*    */     
/*    */ 
/* 84 */     GameUtil.a4119(gameTeam.duiwu);
/* 85 */     GameUtil.a4121(gameTeam.zhanliduiyuan);
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 91 */     return 30;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C30_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */