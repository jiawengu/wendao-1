/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20568_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4119_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M20480_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_TITLE;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_APPEARANCE;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*    */

/*    */
/*    */ @org.springframework.stereotype.Service
/*    */ public class C4128_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 22 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 24 */     Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/* 25 */     vo_61671_0.id = chara.id;
/* 26 */     vo_61671_0.count = 0;
/* 27 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/*    */     
/*    */ 
/* 30 */     List<Chara> list = new java.util.LinkedList();
/* 31 */     list.addAll(GameObjectChar.getGameObjectChar().gameTeam.duiwu);
/*    */     
/*    */ 
/* 34 */     Chara chararemove = null;
/* 35 */     for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.duiwu.size(); i++) {
/* 36 */       if (chara.id == ((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i)).id) {
/* 37 */         chararemove = (Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i);
/*    */       }
/*    */     }
/*    */     
/*    */ 
/* 42 */     for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.duiwu.size(); i++) {
/* 43 */       GameObjectCharMng.getGameObjectChar(((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i)).id).gameTeam.duiwu.remove(chararemove);
/*    */     }
/*    */     
/* 46 */     list.remove(chararemove);
/* 47 */     GameUtil.a4119(list);
/* 48 */     List<Vo_4119_0> object1 = new java.util.ArrayList();
/* 49 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M4119_0(), object1);
/*    */     
/* 51 */     for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan.size(); i++) {
/* 52 */       if (chara.id == ((Vo_4121_0)GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan.get(i)).id) {
/* 53 */         ((Vo_4121_0)GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan.get(i)).memberteam_status = 2;
/*    */       }
/*    */     }
/* 56 */     GameUtil.a4121(GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan);
/*    */     
/*    */ 
/* 59 */     for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.duiwu.size(); i++) {
/* 60 */       org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i));
/* 61 */       GameObjectCharMng.getGameObjectChar(((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i)).id).sendOne(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/* 62 */       Vo_20568_0 vo_20568_0 = new Vo_20568_0();
/* 63 */       vo_20568_0.gid = "";
/* 64 */       GameObjectCharMng.getGameObjectChar(((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i)).id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M20568_0(), vo_20568_0);
/*    */     }
/*    */     
/* 67 */     Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 68 */     vo_20480_0.msg = (chara.name + "暂离了队伍。");
/* 69 */     vo_20480_0.time = 1562593376;
/* 70 */     GameObjectCharMng.getGameObjectChar(((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(0)).id).sendOne(new M20480_0(), vo_20480_0);
/*    */     
/*    */ 
/* 73 */     vo_20480_0 = new Vo_20480_0();
/* 74 */     vo_20480_0.msg = ("你暂时离开了#Y#<" + ((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(0)).name + "#>#n的队伍。");
/* 75 */     vo_20480_0.time = 1562593376;
/* 76 */     GameObjectChar.send(new M20480_0(), vo_20480_0);
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 84 */     return 4128;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4128_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */