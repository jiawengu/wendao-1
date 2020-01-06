/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import java.util.ArrayList;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20568_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45124_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49189_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_TITLE;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_APPEARANCE;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*    */ import org.linlinjava.litemall.gameserver.game.GameTeam;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class C4120_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(io.netty.channel.ChannelHandlerContext ctx, io.netty.buffer.ByteBuf buff)
/*    */   {
/* 23 */     String peer_name = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);
/* 24 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 26 */     Chara chara1 = null;
/* 27 */     GameTeam gameTeam = GameObjectChar.getGameObjectChar().gameTeam;
/* 28 */     for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.duiwu.size(); i++) {
/* 29 */       if (((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i)).name.equals(peer_name)) {
/* 30 */         chara1 = (Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i);
/*    */       }
/*    */     }
/*    */     
/* 34 */     for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.duiwu.size(); i++) {
/* 35 */       Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/* 36 */       vo_61671_0.id = chara1.id;
/* 37 */       vo_61671_0.count = 0;
/* 38 */       GameObjectCharMng.getGameObjectChar(((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i)).id).sendOne(new MSG_TITLE(), vo_61671_0);
/*    */     }
/* 40 */     List<org.linlinjava.litemall.gameserver.data.vo.Vo_4119_0> object1 = new ArrayList();
/* 41 */     GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M4119_0(), object1);
/* 42 */     List<Vo_4121_0> vo_4121_0List = new ArrayList();
/* 43 */     GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M4121_0(), vo_4121_0List);
/* 44 */     Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 45 */     vo_20481_0.msg = "你被请离了队伍。";
/* 46 */     vo_20481_0.time = 1562987118;
/* 47 */     GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*    */     
/* 49 */     for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.duiwu.size(); i++) {
/* 50 */       org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i));
/* 51 */       GameObjectCharMng.getGameObjectChar(((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i)).id).sendOne(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/* 52 */       vo_20481_0 = new Vo_20481_0();
/* 53 */       vo_20481_0.msg = (peer_name + "离开了队伍。。");
/* 54 */       vo_20481_0.time = 1562987118;
/* 55 */       if (((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i)).id != chara1.id) {
/* 56 */         GameObjectCharMng.getGameObjectChar(((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i)).id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*    */       } else {
/* 58 */         GameObjectCharMng.getGameObjectChar(((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i)).id).gameTeam.duiwu.remove(GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i));
/* 59 */         GameObjectCharMng.getGameObjectChar(((Vo_4121_0)GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan.get(i)).id).gameTeam.zhanliduiyuan.remove(GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan.get(i));
/* 60 */         GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam = null;
/*    */       }
/*    */     }
/*    */     
/*    */ 
/* 65 */     Vo_20568_0 vo_20568_0 = new Vo_20568_0();
/* 66 */     vo_20568_0.gid = "";
/* 67 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M20568_0(), vo_20568_0);
/* 68 */     GameUtil.a4119(GameObjectChar.getGameObjectChar().gameTeam.duiwu);
/* 69 */     GameUtil.a4121(GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan);
/* 70 */     Vo_49189_0 vo_49189_0 = new Vo_49189_0();
/* 71 */     GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M49189_0(), vo_49189_0);
/*    */     
/* 73 */     Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 74 */     vo_8165_0.msg = "你被请离了队伍";
/* 75 */     vo_8165_0.active = 0;
/* 76 */     GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M8165_0(), vo_8165_0);
/*    */     
/* 78 */     Vo_45124_0 vo_45124_0 = new Vo_45124_0();
/* 79 */     GameObjectChar.getGameObjectChar();GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M45124_0(), vo_45124_0);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 84 */     return 4120;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4120_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */